-- Yin_SolaraScanner.lua  v1
-- Mini scanner de diagnostico para el bug de velocidad 0 en Solara.
-- Pasos 1-3 son de solo lectura. El paso 4 es OPCIONAL y riesgoso (ver boton).
-- Uso: ejecutar este script, tocar "Iniciar", luego "Copiar" y mandar el log.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

-- Si se vuelve a ejecutar, quitar la ventana anterior
pcall(function()
    local prev = (type(gethui) == "function" and gethui() or game:GetService("CoreGui")):FindFirstChild("YinSolaraScanner")
    if prev then prev:Destroy() end
end)

-- ===== Estado =====
local running = false
local paused = false
local stopFlag = false
local lines = {}
local speedTable = nil
local step4Armed = 0

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "YinSolaraScanner"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999

local parented = pcall(function()
    gui.Parent = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")
end)
if not parented or not gui.Parent then
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local win = Instance.new("Frame")
win.Size = UDim2.new(0, 290, 0, 320)
win.Position = UDim2.new(0, 20, 0, 80)
win.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
win.BorderSizePixel = 0
win.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -28, 0, 24)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
title.BorderSizePixel = 0
title.Text = "  Yin Solara Scanner v1"
title.TextColor3 = Color3.fromRGB(235, 235, 245)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = win

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = win

local logFrame = Instance.new("ScrollingFrame")
logFrame.Position = UDim2.new(0, 6, 0, 86)
logFrame.Size = UDim2.new(1, -12, 1, -92)
logFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 4
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logFrame.Parent = win

local logLabel = Instance.new("TextLabel")
logLabel.Size = UDim2.new(1, -6, 0, 0)
logLabel.AutomaticSize = Enum.AutomaticSize.Y
logLabel.BackgroundTransparency = 1
logLabel.TextColor3 = Color3.fromRGB(200, 230, 200)
logLabel.TextXAlignment = Enum.TextXAlignment.Left
logLabel.TextYAlignment = Enum.TextYAlignment.Top
logLabel.TextWrapped = true
logLabel.Font = Enum.Font.Code
logLabel.TextSize = 11
logLabel.Text = ""
logLabel.Parent = logFrame

local function makeBtn(text, col, row, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 88, 0, 24)
    b.Position = UDim2.new(0, 6 + (col * 94), 0, 30 + (row * 28))
    b.BackgroundColor3 = color or Color3.fromRGB(55, 55, 75)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.Parent = win
    return b
end

local btnStart = makeBtn("Iniciar", 0, 0, Color3.fromRGB(40, 120, 60))
local btnStop = makeBtn("Detener", 1, 0, Color3.fromRGB(140, 60, 60))
local btnPause = makeBtn("Pausar", 2, 0)
local btnClear = makeBtn("Limpiar", 0, 1)
local btnCopy = makeBtn("Copiar log", 1, 1, Color3.fromRGB(50, 90, 150))
local btnStep4 = makeBtn("Paso 4 (riesgo)", 2, 1, Color3.fromRGB(150, 100, 30))

-- Arrastrar la ventana desde la barra de titulo
do
    local dragging, dragStart, startPos = false, nil, nil
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = win.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ===== Log =====
local MAX_LINES = 250

local function log(msg)
    lines[#lines + 1] = tostring(msg)
    if #lines > MAX_LINES then table.remove(lines, 1) end
    logLabel.Text = table.concat(lines, "\n")
    task.defer(function()
        logFrame.CanvasPosition = Vector2.new(0, 1000000)
    end)
end

local function waitIfPaused()
    while paused and not stopFlag do task.wait(0.1) end
    return stopFlag
end

local function has(name, v)
    log("  " .. name .. ": " .. (type(v) == "function" and "OK" or "FALTA"))
end

-- ===== Paso 1: entorno (solo lectura) =====
local function step1()
    log("[1] Entorno")
    local okId, exName, exVer = pcall(function()
        if type(identifyexecutor) == "function" then return identifyexecutor() end
        return nil
    end)
    log("  executor: " .. tostring(okId and exName or "desconocido") .. " " .. tostring(okId and exVer or ""))
    log("  PlaceId: " .. tostring(game.PlaceId))
    has("hookfunction", hookfunction)
    has("getgc", getgc)
    has("firesignal", firesignal)
    has("getrawmetatable", getrawmetatable)
    has("setreadonly", setreadonly)
    has("newcclosure", newcclosure)
    has("getnamecallmethod", getnamecallmethod)
    has("getconnections", getconnections)
    has("islclosure", islclosure)
    has("setclipboard", setclipboard)
end

-- ===== Paso 2: hookfunction sobre un closure Lua propio (mismo patron que Yin.lua) =====
local function step2()
    log("[2] hookfunction sobre closure propio")
    if type(hookfunction) ~= "function" then
        log("  hookfunction no existe, salto")
        return
    end
    local t = {}
    function t.F(self, state, value) return value end
    local orig
    local ok, err = pcall(function()
        orig = hookfunction(t.F, function(self, state, value)
            return orig(self, state, value * 2)
        end)
    end)
    log("  pcall(hookfunction) ok=" .. tostring(ok) .. (ok and "" or (" err=" .. tostring(err))))
    log("  tipo de lo que devolvio: " .. type(orig))
    if type(orig) == "function" then
        local ok2, r2 = pcall(t.F, t, "State", 5)
        log("  llamar t.F tras hook: ok=" .. tostring(ok2) .. " res=" .. tostring(r2) .. " (esperado 10)")
        local ok3, r3 = pcall(orig, t, "State", 5)
        log("  llamar original: ok=" .. tostring(ok3) .. " res=" .. tostring(r3) .. " (esperado 5)")
    else
        log("  >> el original NO es llamable: este es el caso que rompe SpeedChange en Yin.lua")
    end
end

-- ===== Paso 3: buscar la tabla con SpeedChange en getgc, por partes =====
local function step3()
    log("[3] getgc: buscar tabla con SpeedChange")
    if type(getgc) ~= "function" then
        log("  getgc no existe, salto")
        return
    end
    local ok, gc = pcall(getgc, true)
    log("  getgc(true) ok=" .. tostring(ok) .. " tipo=" .. type(gc)
        .. " total=" .. (type(gc) == "table" and tostring(#gc) or "n/a"))
    if not ok or type(gc) ~= "table" then return end

    local n = #gc
    local CHUNK = 1500
    local i = 1
    local tablesSeen, found = 0, 0
    local chunks = 0
    while i <= n do
        if waitIfPaused() then
            log("  detenido en " .. i .. "/" .. n)
            return
        end
        local last = math.min(i + CHUNK - 1, n)
        for j = i, last do
            local v = gc[j]
            if type(v) == "table" then
                tablesSeen = tablesSeen + 1
                local ok2, valid = pcall(function()
                    local f = rawget(v, "SpeedChange")
                    return f ~= nil and type(f) == "function"
                end)
                if ok2 and valid then
                    found = found + 1
                    if not speedTable then speedTable = v end
                end
            end
        end
        i = last + 1
        chunks = chunks + 1
        if chunks % 10 == 0 then log("  progreso " .. math.min(i - 1, n) .. "/" .. n) end
        task.wait()
    end
    log("  tablas vistas: " .. tablesSeen .. " | con SpeedChange: " .. found)
    if speedTable then
        local f = rawget(speedTable, "SpeedChange")
        local isL = "n/a"
        if type(islclosure) == "function" then
            local okL, r = pcall(islclosure, f)
            isL = okL and tostring(r) or "error"
        end
        log("  SpeedChange es closure Lua: " .. isL)
    else
        log("  >> NO se encontro la tabla (en Yin.lua el hook no se instalaria)")
    end
end

-- ===== Paso 4 (OPCIONAL, riesgoso): hook pasa-todo sobre el SpeedChange real =====
local function step4()
    log("[4] hook REAL de SpeedChange (pasa-todo)")
    if type(hookfunction) ~= "function" then log("  hookfunction no existe") return end
    if not speedTable then log("  primero corre Iniciar y que el paso 3 encuentre la tabla") return end
    local f = rawget(speedTable, "SpeedChange")
    local orig
    local calls, nilCalls = 0, 0
    local ok, err = pcall(function()
        orig = hookfunction(f, function(...)
            calls = calls + 1
            if orig then return orig(...) end
            nilCalls = nilCalls + 1
        end)
    end)
    log("  pcall(hookfunction) ok=" .. tostring(ok) .. (ok and "" or (" err=" .. tostring(err))))
    log("  tipo del original devuelto: " .. type(orig))
    if type(orig) ~= "function" then
        log("  >> original nil: la velocidad puede quedar en 0 hasta reentrar al juego")
    end
    task.wait(6)
    log("  llamadas al wrapper en 6s: " .. calls .. " | con original nil: " .. nilCalls)
    log("  el wrapper queda activo hasta reentrar al juego")
end

-- ===== Control =====
local function runAll()
    if running then return end
    running, paused, stopFlag = true, false, false
    btnPause.Text = "Pausar"
    task.spawn(function()
        local ok, err = pcall(function()
            step1()
            if waitIfPaused() then return end
            step2()
            if waitIfPaused() then return end
            step3()
        end)
        if not ok then log("ERROR: " .. tostring(err)) end
        log(stopFlag and "-- detenido --" or "-- fin pasos 1-3 --")
        running = false
    end)
end

btnStart.MouseButton1Click:Connect(runAll)

btnStop.MouseButton1Click:Connect(function()
    stopFlag = true
    paused = false
end)

btnPause.MouseButton1Click:Connect(function()
    if not running then return end
    paused = not paused
    btnPause.Text = paused and "Reanudar" or "Pausar"
    log(paused and "-- pausado --" or "-- reanudado --")
end)

btnClear.MouseButton1Click:Connect(function()
    lines = {}
    logLabel.Text = ""
end)

btnCopy.MouseButton1Click:Connect(function()
    local text = table.concat(lines, "\n")
    local clip = (type(setclipboard) == "function" and setclipboard)
        or (type(toclipboard) == "function" and toclipboard)
    if clip then
        local ok = pcall(clip, text)
        log(ok and "-- log copiado --" or "-- fallo al copiar --")
    else
        print(text)
        log("-- sin setclipboard: log impreso en consola (F9) --")
    end
end)

btnStep4.MouseButton1Click:Connect(function()
    if running then log("espera a que terminen los pasos 1-3") return end
    if os.clock() - step4Armed > 6 then
        step4Armed = os.clock()
        log("!! Paso 4 hookea la funcion REAL del juego y puede dejar tu velocidad en 0 hasta reentrar. Toca de nuevo en 6s para confirmar.")
        return
    end
    step4Armed = 0
    running = true
    task.spawn(function()
        local ok, err = pcall(step4)
        if not ok then log("ERROR: " .. tostring(err)) end
        running = false
    end)
end)

closeBtn.MouseButton1Click:Connect(function()
    stopFlag = true
    gui:Destroy()
end)

log("Listo. Toca Iniciar (pasos 1-3, solo lectura).")
