--[[
    Death Log · Evade (v1)
    Consola para encontrar POR QUÉ el personaje muere al ejecutar Dara Trimp en PC.
    Se ejecuta ANTES del script. Arranca grabando solo. No cambia nada del juego por sí misma
    (salvo los botones de "Pruebas por pasos", que solo hacen algo si los tocás).

    Qué anota:
      ✖ MUERTE        con todo el contexto: vida antes de morir (de golpe o de a poco), posición y velocidad
                      (si hay NaN o caíste debajo del mapa), últimos estados del Humanoid, qué paso de prueba
                      estaba activo, y si Movement.Update estaba reemplazado.
      ♥ VIDA          cada bajada de vida.
      ◆ ESTADO        cambios de estado del Humanoid y cambios de atributos del personaje y del jugador.
      ⚠ ERROR         errores y warnings del juego y del executor, con su traza (ScriptContext.Error / LogService).
      → REMOTE        lo que tu cliente le manda al servidor (FireServer/InvokeServer), marcando si lo mandó
                      el JUEGO o el EXECUTOR. Lo muy repetido se resume.
      ⚙ MOVEMENT      si alguien reemplaza ReplicatedStorage.Objects.Game.Character.Client.Movement.Update
                      (lo revisa cada cuadro, solo después del Paso 1), y con cuántos argumentos lo llama el juego.

    Pruebas por pasos (para aislar la causa sin ejecutar el script):
      1 · Require       solo hace require() del módulo Movement y anota cuántos parámetros recibe Update.
      2 · Hook limpio   reemplaza Update por uno que le pasa TODO al original (todos los argumentos y respuestas).
      3 · Hook script   reemplaza Update igual que Dara Trimp apagado: original(self, dt) y nada más.
      ↺ · Restaurar     devuelve el Update original.
    Si morís en el paso 1 → el problema es el require. En el 2 → el juego detecta que se cambió la función.
    Solo en el 3 → el script pierde argumentos o respuestas que el juego necesita.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LogService = game:GetService("LogService")
local ScriptContext = game:GetService("ScriptContext")
local LocalPlayer = Players.LocalPlayer

local env = (typeof(getgenv) == "function" and getgenv()) or _G
if env.DeathLogState then env.DeathLogState.alive = false end
if type(env.DeathLogClose) == "function" then pcall(env.DeathLogClose) end
local State = {alive = true, running = true, paused = false, remotes = true}
env.DeathLogState = State

local guiParent = LocalPlayer:WaitForChild("PlayerGui")
pcall(function()
    if typeof(gethui) == "function" then
        local hidden = gethui()
        if hidden then guiParent = hidden end
    end
end)
local oldGui = guiParent:FindFirstChild("DeathLog_Evade")
if oldGui then oldGui:Destroy() end

local MAX_LINES, DRAW_PER_TICK = 600, 14
local Queue, Lines = {}, {}
local Connections = {}
local function track(connection) table.insert(Connections, connection) return connection end
local startClock = os.clock()
local function now() return os.clock() - startClock end

-- ==================== FORMATO ====================
local function round(n)
    if n ~= n then return "NaN" end
    if n == math.huge or n == -math.huge then return tostring(n) end
    if n == math.floor(n) then return tostring(n) end
    return string.format("%.2f", n)
end
local function serialize(value, depth)
    depth = depth or 0
    local kind = typeof(value)
    if kind == "string" then
        if #value > 70 then value = value:sub(1, 70) .. "…" end
        return string.format("%q", value)
    elseif kind == "number" then
        return round(value)
    elseif kind == "boolean" or kind == "nil" then
        return tostring(value)
    elseif kind == "Instance" then
        local ok, name = pcall(function() return value:GetFullName() end)
        return (ok and name or tostring(value)) .. " <" .. value.ClassName .. ">"
    elseif kind == "Vector3" then
        return "V3(" .. round(value.X) .. ", " .. round(value.Y) .. ", " .. round(value.Z) .. ")"
    elseif kind == "CFrame" then
        local p = value.Position
        return "CF(" .. round(p.X) .. ", " .. round(p.Y) .. ", " .. round(p.Z) .. ")"
    elseif kind == "table" then
        if depth >= 2 then return "{…}" end
        local parts, n = {}, 0
        for key, item in pairs(value) do
            n = n + 1
            if n > 8 then table.insert(parts, "…") break end
            table.insert(parts, "[" .. serialize(key, depth + 1) .. "]=" .. serialize(item, depth + 1))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    return kind .. "(" .. tostring(value) .. ")"
end
local function serializeArgs(args)
    if args.n == 0 then return "(sin argumentos)" end
    local parts = {}
    for i = 1, args.n do parts[i] = serialize(args[i]) end
    return table.concat(parts, ", ")
end
local function typesOf(args)
    local parts = {}
    for i = 1, args.n do parts[i] = typeof(args[i]) end
    return args.n .. " → (" .. table.concat(parts, ", ") .. ")"
end

-- historial corto para dar contexto al morir
local Recent = {} -- últimas 30 líneas importantes {time, text}
local function push(kind, text)
    if not State.alive then return end
    local entry = {kind = kind, time = now(), text = text}
    table.insert(Recent, entry)
    if #Recent > 40 then table.remove(Recent, 1) end
    if not State.running or State.paused then return end
    table.insert(Queue, entry)
end

-- ==================== MOVEMENT (solo con las pruebas) ====================
local Probe = {module = nil, original = nil, step = "ninguno", argsSeen = nil, argsLast = 0, watching = false, lastKnown = nil, ourHook = nil}
local MOVEMENT_PATH = "ReplicatedStorage.Objects.Game.Character.Client.Movement"
local function findMovementModule()
    local objects = ReplicatedStorage:FindFirstChild("Objects")
    local gameFolder = objects and objects:FindFirstChild("Game")
    local character = gameFolder and gameFolder:FindFirstChild("Character")
    local client = character and character:FindFirstChild("Client")
    return client and client:FindFirstChild("Movement")
end
local function describeFunction(fn)
    if type(fn) ~= "function" then return tostring(fn) end
    local info = {}
    pcall(function()
        local params, vararg = debug.info(fn, "a")
        table.insert(info, "parámetros=" .. tostring(params) .. (vararg and " +vararg(...)" or ""))
    end)
    pcall(function()
        local source, line = debug.info(fn, "sl")
        table.insert(info, "fuente=" .. tostring(source) .. ":" .. tostring(line))
    end)
    pcall(function()
        if typeof(iscclosure) == "function" then table.insert(info, iscclosure(fn) and "C" or "Lua") end
    end)
    return table.concat(info, "  ")
end
local function stepRequire()
    if Probe.module then
        push("movement", "Paso 1 ya hecho · Update actual: " .. describeFunction(Probe.module.Update))
        return true
    end
    local moduleScript = findMovementModule()
    if not moduleScript then
        push("movement", "Paso 1 · NO existe " .. MOVEMENT_PATH)
        return false
    end
    Probe.step = "1 · require"
    push("movement", "Paso 1 · require(" .. MOVEMENT_PATH .. ") …")
    local ok, result = pcall(require, moduleScript)
    if not ok then
        push("error", "Paso 1 · require falló: " .. tostring(result))
        return false
    end
    if type(result) ~= "table" then
        push("movement", "Paso 1 · el módulo devolvió " .. typeof(result) .. ", no una tabla")
        return false
    end
    Probe.module = result
    Probe.original = result.Update
    Probe.lastKnown = result.Update
    Probe.watching = true
    local keys = {}
    for key, value in pairs(result) do
        if #keys < 25 then table.insert(keys, tostring(key) .. ":" .. typeof(value)) end
    end
    push("movement", "Paso 1 · OK. Claves del módulo: " .. table.concat(keys, ", "))
    push("movement", "Paso 1 · Update original: " .. describeFunction(result.Update))
    return true
end
local function stepCleanHook()
    if not stepRequire() then return end
    local original = Probe.original
    if type(original) ~= "function" then push("movement", "Paso 2 · Update no es una función") return end
    Probe.step = "2 · hook limpio"
    local wrapper
    wrapper = function(...)
        local args = table.pack(...)
        local clock = os.clock()
        if Probe.argsSeen == nil or clock - Probe.argsLast > 2 then
            Probe.argsLast = clock
            Probe.argsSeen = typesOf(args)
            push("movement", "El juego llama Update con " .. Probe.argsSeen)
        end
        return original(...)
    end
    Probe.module.Update = wrapper
    Probe.lastKnown = wrapper
    Probe.ourHook = wrapper
    push("movement", "Paso 2 · hook limpio puesto (pasa todos los argumentos y respuestas). Esperá unos segundos.")
end
local function stepScriptHook()
    if not stepRequire() then return end
    local original = Probe.original
    if type(original) ~= "function" then push("movement", "Paso 3 · Update no es una función") return end
    Probe.step = "3 · hook como el script"
    local function sameAsScript(self, dt)
        original(self, dt)
    end
    Probe.module.Update = sameAsScript
    Probe.lastKnown = sameAsScript
    Probe.ourHook = sameAsScript
    push("movement", "Paso 3 · hook igual al de Dara Trimp apagado: original(self, dt) sin devolver nada. Esperá unos segundos.")
end
local function stepRestore()
    if Probe.module and Probe.original then
        Probe.module.Update = Probe.original
        Probe.lastKnown = Probe.original
        Probe.ourHook = nil
        Probe.step = "restaurado"
        push("movement", "↺ Update original devuelto")
    else
        push("movement", "↺ No hay nada para restaurar (el Paso 1 no se hizo)")
    end
end

-- vigila si OTRO (por ejemplo Dara Trimp) reemplaza Update
track(RunService.Heartbeat:Connect(function()
    if not Probe.watching or not Probe.module then return end
    local current = Probe.module.Update
    if current ~= Probe.lastKnown then
        Probe.lastKnown = current
        local who = current == Probe.original and "volvió al ORIGINAL" or "fue REEMPLAZADO por otro script"
        push("movement", "Movement.Update " .. who .. " · " .. describeFunction(current))
    end
end))

-- ==================== PERSONAJE: VIDA, ESTADOS, MUERTE ====================
local charConnections = {}
local healthHistory = {}
local stateHistory = {}
local function clearCharConnections()
    for _, connection in ipairs(charConnections) do pcall(function() connection:Disconnect() end) end
    charConnections = {}
end
local processRemotes -- se define más abajo (remotes pendientes antes del reporte)
local function deathReport(character, humanoid, reason)
    if processRemotes then pcall(processRemotes) end
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local lines = {"✖✖✖ " .. reason .. " ✖✖✖"}
    local history = {}
    for i = math.max(1, #healthHistory - 6), #healthHistory do
        local h = healthHistory[i]
        table.insert(history, string.format("%.2fs=%s", h.time, round(h.value)))
    end
    table.insert(lines, "   vida (últimos cambios): " .. (#history > 0 and table.concat(history, " → ") or "sin cambios registrados"))
    if #healthHistory >= 1 then
        local last = healthHistory[#healthHistory]
        local before = healthHistory[#healthHistory - 1]
        if before and before.value > 0 and last.value <= 0 and last.time - before.time < 0.1 then
            table.insert(lines, "   → la vida bajó DE GOLPE a 0 (típico de que el servidor o un script te mató, no de daño normal)")
        end
    end
    if root then
        local position, velocity = root.Position, root.AssemblyLinearVelocity
        table.insert(lines, "   posición " .. serialize(position) .. "  velocidad " .. serialize(velocity))
        if position.Y ~= position.Y or velocity.X ~= velocity.X or velocity.Y ~= velocity.Y or velocity.Z ~= velocity.Z then
            table.insert(lines, "   → hay NaN en la posición o la velocidad (un cálculo roto mandó el personaje a cualquier lado)")
        end
        local destroyHeight = workspace.FallenPartsDestroyHeight
        if position.Y < destroyHeight + 20 then
            table.insert(lines, "   → estás cerca o debajo de FallenPartsDestroyHeight (" .. round(destroyHeight) .. "): caíste del mapa")
        end
        if velocity.Magnitude > 500 then
            table.insert(lines, "   → velocidad enorme (" .. round(velocity.Magnitude) .. ")")
        end
    else
        table.insert(lines, "   sin HumanoidRootPart")
    end
    local states = {}
    for i = math.max(1, #stateHistory - 6), #stateHistory do table.insert(states, stateHistory[i]) end
    table.insert(lines, "   estados: " .. (#states > 0 and table.concat(states, " → ") or "—"))
    local updateInfo = "Paso 1 no hecho (no se sabe)"
    if Probe.module then
        updateInfo = (Probe.module.Update == Probe.original) and "ORIGINAL" or "REEMPLAZADO"
    end
    table.insert(lines, "   paso de prueba activo: " .. Probe.step .. " · Movement.Update: " .. updateInfo)
    local context = {}
    local deathTime = now()
    for _, entry in ipairs(Recent) do
        if deathTime - entry.time <= 4 and entry.kind ~= "death" then
            table.insert(context, string.format("      [%.2f] %s", entry.time, entry.text))
        end
    end
    table.insert(lines, "   lo que pasó en los 4 s anteriores:")
    for _, line in ipairs(context) do table.insert(lines, line) end
    if #context == 0 then table.insert(lines, "      (nada)") end
    for _, line in ipairs(lines) do push("death", line) end
end
local function watchCharacter(character)
    clearCharConnections()
    healthHistory, stateHistory = {}, {}
    push("state", "Personaje nuevo: " .. character.Name)
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
    if not humanoid then
        push("state", "El personaje no tiene Humanoid")
        return
    end
    local lastHealth = humanoid.Health
    table.insert(healthHistory, {time = now(), value = lastHealth})
    table.insert(charConnections, humanoid.HealthChanged:Connect(function(health)
        table.insert(healthHistory, {time = now(), value = health})
        if #healthHistory > 40 then table.remove(healthHistory, 1) end
        if health < lastHealth then
            push("health", "Vida " .. round(lastHealth) .. " → " .. round(health))
        end
        lastHealth = health
    end))
    table.insert(charConnections, humanoid.StateChanged:Connect(function(_, newState)
        table.insert(stateHistory, string.format("%.2fs %s", now(), newState.Name))
        if #stateHistory > 20 then table.remove(stateHistory, 1) end
        if newState == Enum.HumanoidStateType.Dead or newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.Physics then
            push("state", "Estado del Humanoid: " .. newState.Name)
        end
    end))
    table.insert(charConnections, humanoid.Died:Connect(function()
        deathReport(character, humanoid, "MUERTE (Humanoid.Died)")
    end))
    table.insert(charConnections, character.AttributeChanged:Connect(function(name)
        push("state", "Atributo del personaje " .. name .. " = " .. serialize(character:GetAttribute(name)))
    end))
    table.insert(charConnections, character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            push("state", "El personaje fue BORRADO del mapa")
        end
    end))
end
if LocalPlayer.Character then task.spawn(watchCharacter, LocalPlayer.Character) end
track(LocalPlayer.CharacterAdded:Connect(function(character) task.spawn(watchCharacter, character) end))
track(LocalPlayer.CharacterRemoving:Connect(function(character)
    push("state", "CharacterRemoving: el juego está sacando tu personaje")
end))
track(LocalPlayer.AttributeChanged:Connect(function(name)
    push("state", "Atributo del jugador " .. name .. " = " .. serialize(LocalPlayer:GetAttribute(name)))
end))

-- ==================== ERRORES ====================
track(ScriptContext.Error:Connect(function(message, trace, scriptInstance)
    local where = scriptInstance and serialize(scriptInstance) or "executor/desconocido"
    push("error", "ERROR en " .. where .. ": " .. tostring(message))
    if trace and trace ~= "" then
        for line in string.gmatch(trace, "[^\n]+") do push("error", "   " .. line) end
    end
end))
track(LogService.MessageOut:Connect(function(message, messageType)
    if messageType == Enum.MessageType.MessageError then
        push("error", "consola ✖ " .. tostring(message))
    elseif messageType == Enum.MessageType.MessageWarning then
        push("error", "consola ⚠ " .. tostring(message))
    end
end))

-- ==================== REMOTES SALIENTES ====================
local NOISE_LIMIT, NOISE_SUMMARY = 4, 5
local Noise = {}
local RemoteQueue = {}
local hookOk = false
if typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" then
    local wrap = (typeof(newcclosure) == "function") and newcclosure or function(f) return f end
    local fromExecutor = (typeof(checkcaller) == "function") and checkcaller or function() return false end
    local oldNamecall
    local ok = pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", wrap(function(self, ...)
            local method = getnamecallmethod()
            if State.alive and State.remotes and (method == "FireServer" or method == "InvokeServer") then
                -- solo se guarda; se arma el texto después, fuera del hook
                local byExecutor = fromExecutor()
                local args = table.pack(...)
                pcall(function()
                    table.insert(RemoteQueue, {remote = self, method = method, args = args, time = now(), executor = byExecutor})
                end)
            end
            return oldNamecall(self, ...)
        end))
    end)
    hookOk = ok and oldNamecall ~= nil
end
function processRemotes()
    if #RemoteQueue == 0 then return end
    local batch = RemoteQueue
    RemoteQueue = {}
    for _, item in ipairs(batch) do
        local okName, name = pcall(function() return item.remote:GetFullName() end)
        name = okName and name or tostring(item.remote)
        local sig = name .. "|" .. item.method
        local entry = Noise[sig]
        if not entry then
            entry = {start = item.time, count = 0, noisy = false, suppressed = 0, name = name}
            Noise[sig] = entry
        end
        if item.time - entry.start >= 1 then entry.start, entry.count = item.time, 0 end
        entry.count = entry.count + 1
        local who = item.executor and "[EXECUTOR] " or "[juego] "
        if entry.count > NOISE_LIMIT or entry.noisy then
            if not entry.noisy then
                entry.noisy = true
                push("remote", who .. name .. " · " .. item.method .. "  ⟲ muy frecuente, se resume. Muestra: " .. serializeArgs(item.args))
            end
            entry.suppressed = entry.suppressed + 1
        else
            push("remote", who .. name .. " · " .. item.method .. "  " .. serializeArgs(item.args))
        end
    end
end
local function flushNoise()
    for _, entry in pairs(Noise) do
        if entry.noisy and entry.suppressed > 0 then
            push("remote", "⟲ " .. entry.name .. " ×" .. entry.suppressed .. " en " .. NOISE_SUMMARY .. " s")
            entry.suppressed = 0
        end
    end
end

-- ==================== GUARDADO EN VIVO ====================
local liveFile = nil
pcall(function()
    if typeof(appendfile) ~= "function" or typeof(writefile) ~= "function" then return end
    if typeof(isfolder) == "function" and typeof(makefolder) == "function" and not isfolder("Extraction") then makefolder("Extraction") end
    local name = "Extraction/DeathLog_Evade_" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".txt"
    local executorName = "?"
    pcall(function() if typeof(identifyexecutor) == "function" then executorName = tostring(identifyexecutor()) end end)
    local platform = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and "móvil" or "PC"
    writefile(name, "Death Log Evade · PlaceId " .. game.PlaceId .. " · " .. os.date("%Y-%m-%d %H:%M:%S") .. " · executor " .. executorName .. " · " .. platform .. "\n")
    liveFile = name
end)

-- ==================== INTERFAZ ====================
local C = {
    Bg = Color3.fromRGB(255, 255, 255), Field = Color3.fromRGB(244, 244, 248), Stroke = Color3.fromRGB(214, 214, 222),
    Text = Color3.fromRGB(16, 16, 20), Dim = Color3.fromRGB(104, 104, 118),
}
local KIND_STYLE = {
    death = {mark = "✖", color = Color3.fromRGB(16, 16, 20), bold = true},
    health = {mark = "♥", color = Color3.fromRGB(60, 60, 70)},
    state = {mark = "◆", color = Color3.fromRGB(90, 90, 104)},
    error = {mark = "⚠", color = Color3.fromRGB(16, 16, 20), bold = true},
    remote = {mark = "→", color = Color3.fromRGB(120, 120, 134)},
    movement = {mark = "⚙", color = Color3.fromRGB(16, 16, 20)},
}
local function mk(class, props)
    local inst = Instance.new(class)
    for key, value in pairs(props) do
        if key ~= "Parent" then inst[key] = value end
    end
    inst.Parent = props.Parent
    return inst
end
local function corner(parent, radius) return mk("UICorner", {CornerRadius = UDim.new(0, radius), Parent = parent}) end
local function stroke(parent, color, transparency) return mk("UIStroke", {Color = color, Transparency = transparency or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent}) end
local function tween(inst, time, goals) TweenService:Create(inst, TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), goals):Play() end

local Gui = mk("ScreenGui", {Name = "DeathLog_Evade", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 90, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = guiParent})
local WIDTH, HEIGHT = 360, 330
local Window = mk("Frame", {Size = UDim2.fromOffset(WIDTH, HEIGHT), Position = UDim2.new(1, -WIDTH - 16, 0.5, -HEIGHT / 2), BackgroundColor3 = C.Bg, BorderSizePixel = 0, ClipsDescendants = true, Parent = Gui})
corner(Window, 16)
stroke(Window, C.Stroke, 0)

local Header = mk("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = Window})
local StatusDot = mk("Frame", {Size = UDim2.fromOffset(10, 10), Position = UDim2.fromOffset(14, 15), BackgroundColor3 = C.Text, BorderSizePixel = 0, Parent = Header})
corner(StatusDot, 999)
mk("TextLabel", {Size = UDim2.new(1, -110, 0, 16), Position = UDim2.fromOffset(32, 6), BackgroundTransparency = 1, Text = "Death Log · Evade", TextColor3 = C.Text, Font = Enum.Font.GothamBlack, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header})
local StatusText = mk("TextLabel", {Size = UDim2.new(1, -110, 0, 12), Position = UDim2.fromOffset(32, 22), BackgroundTransparency = 1, Text = "", TextColor3 = C.Dim, Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Header})
local function headerButton(text, offset)
    local b = mk("TextButton", {Size = UDim2.fromOffset(24, 24), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, offset, 0, 20), BackgroundColor3 = C.Field, AutoButtonColor = false, Text = text, TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 12, Parent = Header})
    corner(b, 999)
    stroke(b, C.Stroke, 0.2)
    return b
end
local MinButton = headerButton("–", -38)
local CloseButton = headerButton("✕", -10)

local function buttonRow(y)
    local row = mk("Frame", {Size = UDim2.new(1, -20, 0, 26), Position = UDim2.fromOffset(10, y), BackgroundTransparency = 1, Parent = Window})
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = row})
    return row
end
local function rowButton(row, order, count, text, filled)
    local b = mk("TextButton", {Size = UDim2.new(1 / count, -4, 1, 0), BackgroundColor3 = filled and C.Text or C.Field, AutoButtonColor = false, Text = text, TextColor3 = filled and C.Bg or C.Text, Font = Enum.Font.GothamBold, TextSize = 10, LayoutOrder = order, Parent = row})
    corner(b, 8)
    stroke(b, C.Stroke, filled and 1 or 0.2)
    b.MouseButton1Down:Connect(function() tween(b, 0.08, {BackgroundTransparency = 0.3}) end)
    b.MouseButton1Up:Connect(function() tween(b, 0.2, {BackgroundTransparency = 0}) end)
    return b
end
local Bar = buttonRow(42)
local StartButton = rowButton(Bar, 1, 6, "Iniciar")
local PauseButton = rowButton(Bar, 2, 6, "Pausar")
local StopButton = rowButton(Bar, 3, 6, "Detener")
local ClearButton = rowButton(Bar, 4, 6, "Limpiar")
local CopyButton = rowButton(Bar, 5, 6, "Copiar")
local RemoteButton = rowButton(Bar, 6, 6, "Remotes ✓")
mk("TextLabel", {Size = UDim2.new(1, -20, 0, 12), Position = UDim2.fromOffset(12, 72), BackgroundTransparency = 1, Text = "PRUEBAS POR PASOS (opcional, sin el script)", TextColor3 = C.Dim, Font = Enum.Font.GothamBold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, Parent = Window})
local Steps = buttonRow(86)
local Step1 = rowButton(Steps, 1, 4, "1 · Require", true)
local Step2 = rowButton(Steps, 2, 4, "2 · Hook limpio", true)
local Step3 = rowButton(Steps, 3, 4, "3 · Hook script", true)
local Restore = rowButton(Steps, 4, 4, "↺ Restaurar")

local Log = mk("ScrollingFrame", {
    Size = UDim2.new(1, -20, 1, -146), Position = UDim2.fromOffset(10, 118), BackgroundColor3 = C.Field, BorderSizePixel = 0,
    ScrollBarThickness = 3, ScrollBarImageColor3 = C.Text, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = Window,
})
corner(Log, 10)
mk("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Log})
mk("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = Log})
local Footer = mk("TextLabel", {Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 1, -24), BackgroundTransparency = 1, Text = liveFile and ("Guardando en vivo: " .. liveFile) or "Sin appendfile: usá Copiar", TextColor3 = C.Dim, Font = Enum.Font.GothamMedium, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Window})

local lineOrder, labelsShown = 0, {}
local function addLabel(text, style)
    lineOrder = lineOrder + 1
    local label = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = text, TextColor3 = style.color, Font = style.bold and Enum.Font.Code or Enum.Font.Code, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = lineOrder, Parent = Log})
    if style.bold then label.Font = Enum.Font.GothamBold end
    table.insert(labelsShown, label)
    if #labelsShown > 150 then table.remove(labelsShown, 1):Destroy() end
end

local function setStatus()
    local mode = not State.running and "Detenido" or (State.paused and "En pausa" or "Grabando")
    StatusText.Text = mode .. " · " .. #Lines .. " líneas · paso: " .. Probe.step .. (hookOk and "" or " · sin hook de remotes")
    tween(StatusDot, 0.2, {BackgroundTransparency = (State.running and not State.paused) and 0 or 0.7})
end

StartButton.MouseButton1Click:Connect(function()
    State.running, State.paused = true, false
    PauseButton.Text = "Pausar"
    setStatus()
end)
PauseButton.MouseButton1Click:Connect(function()
    if not State.running then return end
    State.paused = not State.paused
    PauseButton.Text = State.paused and "Seguir" or "Pausar"
    setStatus()
end)
StopButton.MouseButton1Click:Connect(function()
    State.running, State.paused = false, false
    PauseButton.Text = "Pausar"
    setStatus()
end)
ClearButton.MouseButton1Click:Connect(function()
    Queue, Lines = {}, {}
    for _, label in ipairs(labelsShown) do label:Destroy() end
    labelsShown = {}
    setStatus()
end)
CopyButton.MouseButton1Click:Connect(function()
    local copy = (typeof(setclipboard) == "function" and setclipboard) or (typeof(toclipboard) == "function" and toclipboard)
    if not copy then Footer.Text = "Tu executor no tiene setclipboard" return end
    local ok = pcall(copy, "Death Log Evade · " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n" .. table.concat(Lines, "\n"))
    Footer.Text = ok and ("Copiado: " .. #Lines .. " líneas") or "No se pudo copiar"
end)
RemoteButton.MouseButton1Click:Connect(function()
    State.remotes = not State.remotes
    RemoteButton.Text = State.remotes and "Remotes ✓" or "Remotes ✕"
end)
Step1.MouseButton1Click:Connect(function() stepRequire() setStatus() end)
Step2.MouseButton1Click:Connect(function() stepCleanHook() setStatus() end)
Step3.MouseButton1Click:Connect(function() stepScriptHook() setStatus() end)
Restore.MouseButton1Click:Connect(function() stepRestore() setStatus() end)

-- dibuja de a partes y guarda en vivo
local drawElapsed, summaryElapsed = 0, 0
track(RunService.Heartbeat:Connect(function(dt)
    drawElapsed = drawElapsed + dt
    summaryElapsed = summaryElapsed + dt
    if drawElapsed < 0.2 then return end
    drawElapsed = 0
    processRemotes()
    if summaryElapsed >= NOISE_SUMMARY then
        summaryElapsed = 0
        flushNoise()
    end
    if #Queue == 0 then return end
    local pending = {}
    for _ = 1, math.min(#Queue, DRAW_PER_TICK) do
        local entry = table.remove(Queue, 1)
        local style = KIND_STYLE[entry.kind] or KIND_STYLE.state
        local line = string.format("[%7.2f] %s %s", entry.time, style.mark, entry.text)
        table.insert(Lines, line)
        if #Lines > MAX_LINES then table.remove(Lines, 1) end
        table.insert(pending, line)
        addLabel(line, style)
    end
    if liveFile then pcall(appendfile, liveFile, table.concat(pending, "\n") .. "\n") end
    setStatus()
    Log.CanvasPosition = Vector2.new(0, 1e6)
end))

-- minimizar, arrastrar, cerrar
local minimized = false
MinButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    tween(Window, 0.25, {Size = minimized and UDim2.fromOffset(WIDTH, 40) or UDim2.fromOffset(WIDTH, HEIGHT)})
    MinButton.Text = minimized and "+" or "–"
end)
do
    local dragging, dragStart, startPos = false, nil, nil
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, Window.Position
        end
    end)
    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
end
local function closeAll()
    if not State.alive then return end
    -- si una prueba dejó Update cambiado, se devuelve el original
    if Probe.module and Probe.ourHook and Probe.module.Update == Probe.ourHook then
        pcall(stepRestore)
    end
    State.alive, State.running = false, false -- el hook de remotes queda pasando todo sin tocar nada
    clearCharConnections()
    for _, connection in ipairs(Connections) do pcall(function() connection:Disconnect() end) end
    if env.DeathLogClose == closeAll then env.DeathLogClose = nil end
    if Gui.Parent then Gui:Destroy() end
end
env.DeathLogClose = closeAll
CloseButton.MouseButton1Click:Connect(closeAll)

push("state", "Death Log listo. Ahora ejecutá el script (o usá las pruebas por pasos) y esperá a morir.")
pcall(function()
    if typeof(identifyexecutor) == "function" then push("state", "Executor: " .. tostring(identifyexecutor())) end
end)
push("state", "Plataforma: " .. ((UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) and "móvil" or "PC") .. (hookOk and "" or " · ⚠ sin hookmetamethod: no se ven los remotes"))
setStatus()
