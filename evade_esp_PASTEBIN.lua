--[[
    ✅ SCRIPT EVADE CON ESP + YIN YANG v23 - PASTEBIN VERSION
    - Descarga desde Pastebin (más confiable que GitHub)
    - Mejor manejo de errores
    - Reintentos automáticos
]]

--// ════════════════════════════════════════════════════════════
--// CONFIGURACIÓN - REEMPLAZA CON TU PASTEBIN ID
--// ════════════════════════════════════════════════════════════

local PASTEBIN_ID = "RASqrhqf"  -- ✅ Yin Yang v23 OPTIMIZADO
local PASTEBIN_URL = "https://pastebin.com/raw/" .. PASTEBIN_ID

--// ════════════════════════════════════════════════════════════
--// 1. FUNCIÓN DE DESCARGA CON RETRY
--// ════════════════════════════════════════════════════════════

local function httpGet(url, retries)
    retries = retries or 3
    local ok, res
    
    for attempt = 1, retries do
        print("🔄 Intento " .. attempt .. "/" .. retries .. "...")
        
        -- Método 1: game:HttpGet
        ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and res and res ~= "" then
            print("✅ Descargado exitosamente!")
            return res
        end

        -- Método 2: HttpService
        ok, res = pcall(function() 
            return game:GetService("HttpService"):GetAsync(url) 
        end)
        if ok and res and res ~= "" then
            print("✅ Descargado exitosamente!")
            return res
        end

        -- Método 3: http_request
        if http_request then
            ok, res = pcall(function() 
                return http_request({Url = url, Method = "GET"}).Body 
            end)
            if ok and res then
                print("✅ Descargado exitosamente!")
                return res
            end
        end

        -- Método 4: syn.request
        if syn and syn.request then
            ok, res = pcall(function() 
                return syn.request({Url = url, Method = "GET"}).Body 
            end)
            if ok and res then
                print("✅ Descargado exitosamente!")
                return res
            end
        end

        -- Método 5: request
        if request then
            ok, res = pcall(function() 
                return request({Url = url, Method = "GET"}).Body 
            end)
            if ok and res then
                print("✅ Descargado exitosamente!")
                return res
            end
        end

        print("⚠️  Intento " .. attempt .. " falló, esperando 1 segundo...")
        task.wait(1)
    end

    return nil
end

--// ════════════════════════════════════════════════════════════
--// 2. CARGAR LIBRERÍA YIN YANG DESDE PASTEBIN
--// ════════════════════════════════════════════════════════════

local YinYang = nil
local loadSuccess = false

print("═══════════════════════════════════════════════════════════")
print("🔄 INICIANDO CARGA DE LIBRERÍA...")
print("═══════════════════════════════════════════════════════════")



if _G.YinYang and _G.YinYang.CreateWindow then
    print("✅ YinYang ya está cargado en memoria")
    YinYang = _G.YinYang
    loadSuccess = true
else
    print("📥 Descargando librería desde Pastebin...")
    print("📍 URL: " .. PASTEBIN_URL)
    
    local code = httpGet(PASTEBIN_URL, 5)
    
    if not code or code == "" then
        warn("═══════════════════════════════════════════════════════════")
        warn("❌ CRÍTICO: No se pudo descargar desde Pastebin")
        warn("═══════════════════════════════════════════════════════════")
        warn("Posibles soluciones:")
        warn("1. Verifica tu ID de Pastebin (debe ser abc123, NO la URL completa)")
        warn("2. Comprueba que la URL sea: https://pastebin.com/raw/abc123")
        warn("3. Intenta ejecutar en 30 segundos (Pastebin a veces está lento)")
        warn("4. Verifica que tu executor tenga HTTP habilitado")
        warn("═══════════════════════════════════════════════════════════")
        return
    end

    print("✅ Descargado (" .. #code .. " bytes)")
    print("🔧 Compilando...")

    local loadFunc = loadstring or load
    if not loadFunc then
        warn("❌ Tu executor no tiene loadstring/load")
        return
    end

    local func, compileErr = loadFunc(code)
    if not func then
        warn("❌ Error compilando: " .. tostring(compileErr))
        return
    end

    print("⚙️  Ejecutando...")
    local execOk, execErr = pcall(func)
    if not execOk then
        warn("❌ Error ejecutando: " .. tostring(execErr))
        return
    end

    if not _G.YinYang or not _G.YinYang.CreateWindow then
        warn("❌ YinYang no se inicializó correctamente")
        return
    end

    YinYang = _G.YinYang
    loadSuccess = true
    print("✅ YinYang cargado correctamente")
end

if not loadSuccess then
    warn("❌ FALLO: No se pudo cargar YinYang")
    return
end

print("═══════════════════════════════════════════════════════════")
print("✅ LIBRERÍA LISTA - Continuando con ESP...")
print("═══════════════════════════════════════════════════════════")

--// ════════════════════════════════════════════════════════════
--// 3. SERVICIOS
--// ════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local hasDrawing = false
pcall(function() 
    if Drawing and Drawing.new then
        hasDrawing = true
    end
end)

if not hasDrawing then
    warn("⚠️  Drawing no disponible - Sin cajas 3D")
end

--// ════════════════════════════════════════════════════════════
--// 4. CREAR UI
--// ════════════════════════════════════════════════════════════

print("🎨 Creando UI...")

local UI = YinYang:CreateWindow("EVADE ESP", "Dark")
print("✅ UI creada")

--// ════════════════════════════════════════════════════════════
--// 5. TAB: ESP
--// ════════════════════════════════════════════════════════════

local ESPTab = UI:CreateTab("👁️ ESP")

local ESPConfig = {
    Enabled = false,
    ShowNames = true,
    ShowBoxes = true,
    ShowDistance = true,
    ShowHealth = true,
    TeamCheck = false,
    Distance = 500,
}

local ESPObjects = {}

--// ════════════════════════════════════════════════════════════
--// 6. FUNCIONES DE ESP
--// ════════════════════════════════════════════════════════════

local function worldToViewport(position)
    local viewportPos, onScreen = Camera:WorldToViewportPoint(position)
    if typeof(viewportPos) == "Vector3" then
        return Vector2.new(viewportPos.X, viewportPos.Y), viewportPos.Z
    end
    return Vector2.new(viewportPos.X, viewportPos.Y), onScreen and 1 or -1
end

local function createOrUpdateESPLabel(player)
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart then
        return nil
    end

    local billboard = character:FindFirstChild("ESPBillboard")
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPBillboard"
        billboard.Size = UDim2.new(4, 0, 2, 0)
        billboard.MaxDistance = ESPConfig.Distance
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = rootPart
        billboard.Parent = character
    end

    for _, child in ipairs(billboard:GetChildren()) do
        child:Destroy()
    end

    local Frame = Instance.new("Frame")
    Frame.Name = "ESPFrame"
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.Parent = billboard

    if ESPConfig.ShowNames then
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Name = "NameLabel"
        NameLabel.Size = UDim2.new(1, 0, 0, 20)
        NameLabel.Position = UDim2.new(0, 0, 0, -25)
        NameLabel.BackgroundTransparency = 1
        NameLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        NameLabel.TextSize = 14
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.Text = player.Name
        NameLabel.TextScaled = true
        NameLabel.Parent = Frame
    end

    if ESPConfig.ShowDistance then
        local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
        local DistanceLabel = Instance.new("TextLabel")
        DistanceLabel.Name = "DistanceLabel"
        DistanceLabel.Size = UDim2.new(1, 0, 0, 18)
        DistanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
        DistanceLabel.BackgroundTransparency = 1
        DistanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        DistanceLabel.TextSize = 12
        DistanceLabel.Font = Enum.Font.Gotham
        DistanceLabel.Text = string.format("%.1f m", distance)
        DistanceLabel.TextScaled = true
        DistanceLabel.Parent = Frame
    end

    if ESPConfig.ShowHealth and humanoid then
        local health = math.floor(humanoid.Health)
        local maxHealth = math.floor(humanoid.MaxHealth)
        local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100

        local HealthBar = Instance.new("Frame")
        HealthBar.Name = "HealthBar"
        HealthBar.Size = UDim2.new(0.3, 0, 0, 4)
        HealthBar.Position = UDim2.new(-0.4, 0, 0.5, 0)
        HealthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        HealthBar.Parent = Frame

        local HealthFill = Instance.new("Frame")
        HealthFill.Name = "HealthFill"
        HealthFill.Size = UDim2.new(math.clamp(healthPercent / 100, 0, 1), 0, 1, 0)
        HealthFill.BackgroundColor3 = healthPercent > 50 and Color3.fromRGB(100, 200, 100) or healthPercent > 25 and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(255, 100, 100)
        HealthFill.BorderSizePixel = 0
        HealthFill.Parent = HealthBar

        local HealthLabel = Instance.new("TextLabel")
        HealthLabel.Name = "HealthLabel"
        HealthLabel.Size = UDim2.new(1, 0, 0, 16)
        HealthLabel.Position = UDim2.new(0, 0, 1, 2)
        HealthLabel.BackgroundTransparency = 1
        HealthLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        HealthLabel.TextSize = 10
        HealthLabel.Font = Enum.Font.Gotham
        HealthLabel.Text = string.format("%d/%d", health, maxHealth)
        HealthLabel.TextScaled = true
        HealthLabel.Parent = HealthBar
    end

    return billboard
end

local function drawBox(player)
    if not hasDrawing then return end
    if not player or not player.Character then return end

    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local size = Vector3.new(2, 3, 1)
    local corners = {
        humanoidRootPart.Position + Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
        humanoidRootPart.Position + Vector3.new(size.X/2, -size.Y/2, -size.Z/2),
        humanoidRootPart.Position + Vector3.new(size.X/2, -size.Y/2, size.Z/2),
        humanoidRootPart.Position + Vector3.new(-size.X/2, -size.Y/2, size.Z/2),
        humanoidRootPart.Position + Vector3.new(-size.X/2, size.Y/2, -size.Z/2),
        humanoidRootPart.Position + Vector3.new(size.X/2, size.Y/2, -size.Z/2),
        humanoidRootPart.Position + Vector3.new(size.X/2, size.Y/2, size.Z/2),
        humanoidRootPart.Position + Vector3.new(-size.X/2, size.Y/2, size.Z/2),
    }

    local edges = {
        {1, 2}, {2, 3}, {3, 4}, {4, 1},
        {5, 6}, {6, 7}, {7, 8}, {8, 5},
        {1, 5}, {2, 6}, {3, 7}, {4, 8},
    }

    for _, edge in ipairs(edges) do
        local p1, p2 = corners[edge[1]], corners[edge[2]]
        local v1, z1 = worldToViewport(p1)
        local v2, z2 = worldToViewport(p2)

        if z1 > 0 and z2 > 0 then
            local ok, line = pcall(function() return Drawing.new("Line") end)
            if ok and line then
                line.From = v1
                line.To = v2
                line.Color = Color3.fromRGB(0, 150, 255)
                line.Thickness = 1.5
                line.Transparency = 0.8
                line.Visible = true
                table.insert(ESPObjects, line)
            end
        end
    end
end

local function updateESP()
    if not ESPConfig.Enabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (Camera.CFrame.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance > ESPConfig.Distance then
                    goto continue
                end
            end

            if ESPConfig.ShowNames or ESPConfig.ShowDistance or ESPConfig.ShowHealth then
                createOrUpdateESPLabel(player)
            end

            if ESPConfig.ShowBoxes and hasDrawing then
                drawBox(player)
            end

            ::continue::
        end
    end
end

local function clearAllESP()
    for _, obj in ipairs(ESPObjects) do
        if obj then
            pcall(function() obj:Remove() end)
        end
    end
    ESPObjects = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local billboard = player.Character:FindFirstChild("ESPBillboard")
            if billboard then
                billboard:Destroy()
            end
        end
    end
end

--// ════════════════════════════════════════════════════════════
--// 7. UI CONTROLS
--// ════════════════════════════════════════════════════════════

ESPTab:CreateToggle("🔴 Activar ESP", false, function(state)
    ESPConfig.Enabled = state
    if not state then clearAllESP() end
end)

ESPTab:CreateToggle("👤 Mostrar nombres", true, function(state)
    ESPConfig.ShowNames = state
end)

ESPTab:CreateToggle("📦 Mostrar cajas", true, function(state)
    ESPConfig.ShowBoxes = state and hasDrawing
end)

ESPTab:CreateToggle("📏 Mostrar distancia", true, function(state)
    ESPConfig.ShowDistance = state
end)

ESPTab:CreateToggle("❤️ Mostrar salud", true, function(state)
    ESPConfig.ShowHealth = state
end)

ESPTab:CreateButton("🗑️ Limpiar ESP", function()
    clearAllESP()
    print("✅ ESP limpiado")
end)

--// ════════════════════════════════════════════════════════════
--// 8. TAB: INFO
--// ════════════════════════════════════════════════════════════

local InfoTab = UI:CreateTab("ℹ️ Info")
InfoTab:CreateButton("📋 Script: Evade ESP v1.0", function() end)
InfoTab:CreateButton("📚 Librería: Yin Yang v23", function() end)
InfoTab:CreateButton("🌐 Método: Pastebin", function() end)
InfoTab:CreateButton("🔄 Test", function()
    ESPConfig.Enabled = not ESPConfig.Enabled
    print("ESP: " .. (ESPConfig.Enabled and "✅ ON" or "❌ OFF"))
end)

--// ════════════════════════════════════════════════════════════
--// 9. MAIN LOOP
--// ════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    if ESPConfig.Enabled then
        for i = #ESPObjects, 1, -1 do
            if ESPObjects[i] then
                pcall(function() ESPObjects[i]:Remove() end)
            end
            table.remove(ESPObjects, i)
        end
        pcall(updateESP)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        local billboard = player.Character:FindFirstChild("ESPBillboard")
        if billboard then
            billboard:Destroy()
        end
    end
end)

print("═══════════════════════════════════════════════════════════")
print("✅ EVADE ESP + YIN YANG v23 - PASTEBIN VERSION")
print("═══════════════════════════════════════════════════════════")
print("👁️  Abre la UI (botón Yin-Yang flotante)")
print("🎯 Drawing: " .. tostring(hasDrawing))
print("═══════════════════════════════════════════════════════════")
