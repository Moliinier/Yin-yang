--[[
    ✅ SCRIPT EVADE CON ESP + YIN YANG v23
    Carga la librería desde GitHub y agrega ESP funcional
    Probado en: Evade (Roblox)
]]

--// ════════════════════════════════════════════════════════════
--// 1. CARGAR LIBRERÍA YIN YANG DESDE GITHUB
--// ════════════════════════════════════════════════════════════

local success = false
local errorMsg = ""

pcall(function()
    if _G.YinYang then
        print("✅ Yin Yang ya está cargado")
        success = true
        return
    end
    
    print("📥 Descargando librería Yin Yang desde GitHub...")
    local HttpService = game:GetService("HttpService")
    
    local url = "https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v23_COMPLETO.lua"
    local code = HttpService:GetAsync(url)
    
    loadstring(code)()
    
    if _G.YinYang then
        print("✅ Yin Yang cargado exitosamente desde GitHub")
        success = true
    else
        errorMsg = "YinYang no se inicializó"
        success = false
    end
end)

if not success then
    warn("❌ Error al cargar Yin Yang: " .. tostring(errorMsg))
    return
end

--// ════════════════════════════════════════════════════════════
--// 2. SERVICIOS NECESARIOS
--// ════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

--// ════════════════════════════════════════════════════════════
--// 3. CREAR UI CON YIN YANG
--// ════════════════════════════════════════════════════════════

local YinYang = _G.YinYang
local UI = YinYang:CreateWindow("EVADE ESP", "Dark")

--// ════════════════════════════════════════════════════════════
--// 4. TAB: ESP
--// ════════════════════════════════════════════════════════════

local ESPTab = UI:CreateTab("👁️ ESP")

ESPTab:CreateLabel("Visualización de jugadores", 14)
ESPTab:CreateDivider()

--// VARIABLES DE CONTROL
local ESPConfig = {
    Enabled = false,
    ShowNames = true,
    ShowBoxes = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowLines = true,
    TeamCheck = false,
    Distance = 500,
}

--// TABLA PARA ALMACENAR ESPs
local ESPObjects = {}

--// ════════════════════════════════════════════════════════════
--// 5. FUNCIONES DE ESP
--// ════════════════════════════════════════════════════════════

local function getTeam(player)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        return player.Team
    end
    return nil
end

local function worldToViewport(position)
    local viewport = Camera:WorldToViewportPoint(position)
    return Vector2.new(viewport.X, viewport.Y), viewport.Z
end

local function createOrUpdateESPLabel(player)
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart then
        return nil
    end

    --// Obtener o crear Billboard GUI
    local billboard = character:FindFirstChild("ESPBillboard")
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPBillboard"
        billboard.Size = UDim2.new(4, 0, 2, 0)
        billboard.MaxDistance = ESPConfig.Distance
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = rootPart
        billboard.Parent = character
    end

    --// LIMPIAR CONTENIDO ANTERIOR
    for _, child in ipairs(billboard:GetChildren()) do
        child:Destroy()
    end

    --// CREAR FRAME PRINCIPAL
    local Frame = Instance.new("Frame")
    Frame.Name = "ESPFrame"
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.Parent = billboard

    --// NOMBRE DEL JUGADOR
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

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 4)
        Corner.Parent = NameLabel
    end

    --// DISTANCIA
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

    --// SALUD (si tiene humanoid)
    if ESPConfig.ShowHealth and humanoid then
        local health = math.floor(humanoid.Health)
        local maxHealth = math.floor(humanoid.MaxHealth)
        local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100

        --// BARRA DE SALUD
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
    if not player or not player.Character then
        return
    end

    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoidRootPart then
        return
    end

    --// CREAR CUADRADO 3D USANDO LÍNEAS
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

    --// CONECTAR ESQUINAS
    local edges = {
        {1, 2}, {2, 3}, {3, 4}, {4, 1},  -- Base inferior
        {5, 6}, {6, 7}, {7, 8}, {8, 5},  -- Base superior
        {1, 5}, {2, 6}, {3, 7}, {4, 8},  -- Vertical
    }

    for _, edge in ipairs(edges) do
        local p1, p2 = corners[edge[1]], corners[edge[2]]
        local v1, z1 = worldToViewport(p1)
        local v2, z2 = worldToViewport(p2)

        if z1 > 0 and z2 > 0 then
            local line = Drawing.new("Line")
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

local function updateESP()
    if not ESPConfig.Enabled then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            --// TEAM CHECK
            if ESPConfig.TeamCheck and getTeam(player) == getTeam(LocalPlayer) then
                goto continue
            end

            --// DISTANCIA CHECK
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (Camera.CFrame.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance > ESPConfig.Distance then
                    goto continue
                end
            end

            --// CREAR O ACTUALIZAR ESP
            if ESPConfig.ShowNames or ESPConfig.ShowDistance or ESPConfig.ShowHealth then
                createOrUpdateESPLabel(player)
            end

            if ESPConfig.ShowBoxes then
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
--// 6. UI: TOGGLES Y BOTONES
--// ════════════════════════════════════════════════════════════

ESPTab:CreateToggle("Activar ESP", false, function(state)
    ESPConfig.Enabled = state
    if not state then
        clearAllESP()
    end
end)

ESPTab:CreateToggle("Mostrar nombres", true, function(state)
    ESPConfig.ShowNames = state
end)

ESPTab:CreateToggle("Mostrar cajas", true, function(state)
    ESPConfig.ShowBoxes = state
end)

ESPTab:CreateToggle("Mostrar distancia", true, function(state)
    ESPConfig.ShowDistance = state
end)

ESPTab:CreateToggle("Mostrar salud", true, function(state)
    ESPConfig.ShowHealth = state
end)

ESPTab:CreateToggle("Verificar equipo", false, function(state)
    ESPConfig.TeamCheck = state
end)

ESPTab:CreateLabel("Configuración", 14)
ESPTab:CreateDivider()

ESPTab:CreateLabel("Distancia máxima: " .. ESPConfig.Distance .. "m", 12)

ESPTab:CreateButton("Limpiar ESP", function()
    clearAllESP()
    print("✅ ESP limpiado")
end)

ESPTab:CreateButton("Recargar script", function()
    print("🔄 Recargando...")
    script:Destroy()
end)

--// ════════════════════════════════════════════════════════════
--// 7. TAB: INFORMACIÓN
--// ════════════════════════════════════════════════════════════

local InfoTab = UI:CreateTab("ℹ️ Info")

InfoTab:CreateLabel("Información del Script", 14)
InfoTab:CreateDivider()

InfoTab:CreateLabel("Script: Evade ESP v1.0", 12)
InfoTab:CreateLabel("Librería: Yin Yang v23", 12)
InfoTab:CreateLabel("Features: ESP, Nombres, Distancia, Salud", 12)

InfoTab:CreateDivider()

InfoTab:CreateButton("Test ESP", function()
    ESPConfig.Enabled = not ESPConfig.Enabled
    print("ESP: " .. (ESPConfig.Enabled and "ON ✅" or "OFF ❌"))
end)

--// ════════════════════════════════════════════════════════════
--// 8. LOOP PRINCIPAL
--// ════════════════════════════════════════════════════════════

local connection
connection = RunService.RenderStepped:Connect(function()
    if ESPConfig.Enabled then
        --// LIMPIAR OBJETOS ANTIGUOS
        for i = #ESPObjects, 1, -1 do
            if not ESPObjects[i] or not ESPObjects[i].Visible then
                table.remove(ESPObjects, i)
            end
        end

        --// ACTUALIZAR ESP
        pcall(updateESP)
    end
end)

--// ════════════════════════════════════════════════════════════
--// 9. CLEANUP AL DESCONECTARSE
--// ════════════════════════════════════════════════════════════

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        local billboard = player.Character:FindFirstChild("ESPBillboard")
        if billboard then
            billboard:Destroy()
        end
    end
end)

--// ════════════════════════════════════════════════════════════
--// 10. NOTIFICACIÓN
--// ════════════════════════════════════════════════════════════

print("═══════════════════════════════════════════════════════════")
print("✅ EVADE ESP CON YIN YANG v23 CARGADO")
print("═══════════════════════════════════════════════════════════")
print("👁️  Abre la UI (botón flotante con Yin-Yang)")
print("📍 Ve a la tab 'ESP' para activar/desactivar")
print("⚙️  Personaliza las opciones según necesites")
print("═══════════════════════════════════════════════════════════")
