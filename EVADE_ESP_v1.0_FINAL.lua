--[[
    ╔════════════════════════════════════════════════════════════════╗
    ║  EVADE ESP v1.0 - YIN YANG UI v26                             ║
    ║  ============================================================  ║
    ║  Estructura correcta basada en la demo funcional              ║
    ║  • Carga librería desde GitHub                                ║
    ║  • Crea manualmente las 3 pestañas sagradas                   ║
    ║  • Agrega pestaña "Evade" con ESP Players                    ║
    ╚════════════════════════════════════════════════════════════════╝
]]

print("═══════════════════════════════════════════════════════════════")
print("🚀 Iniciando EVADE ESP v1.0")
print("═══════════════════════════════════════════════════════════════")

--// ════════════════════════════════════════════════════════════════
--// 1. CARGAR LIBRERÍA YIN YANG v26
--// ════════════════════════════════════════════════════════════════

if not _G.YinYang then
    print("📥 Cargando Yin Yang v26...")
    local code = game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v26_PRODUCCION.lua")
    loadstring(code)()
    print("✅ Yin Yang v26 cargado")
else
    print("✅ Yin Yang ya estaba cargado")
end

--// ════════════════════════════════════════════════════════════════
--// 2. SERVICIOS NECESARIOS
--// ════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

--// ════════════════════════════════════════════════════════════════
--// 3. CREAR WINDOW
--// ════════════════════════════════════════════════════════════════

local DemoUI = _G.YinYang:CreateWindow("EVADE ESP v1.0", "Dark")
print("✅ Window creado")

--// ════════════════════════════════════════════════════════════════
--// 4. TAB INICIO (SAGRADA - PRIMERA)
--// ════════════════════════════════════════════════════════════════

local TabInicio = DemoUI:CreateTab("Inicio")

TabInicio:CreateWelcomeCard()
TabInicio:CreateDivider()
TabInicio:CreateServerInfoCard()

TabInicio:CreateDivider()
TabInicio:CreateLabel("📊 EVADE ESP v1.0", 13)
TabInicio:CreateDivider()
TabInicio:CreateLabel("Visualización de jugadores en tiempo real", 11)
TabInicio:CreateLabel("Nombres • Distancia • Salud • Color de equipo", 11)

print("✅ Tab 'Inicio' creado")

--// ════════════════════════════════════════════════════════════════
--// 5. TAB TEMAS (SAGRADA - SEGUNDA)
--// ════════════════════════════════════════════════════════════════

local TabTemas = DemoUI:CreateTab("Temas")

TabTemas:CreateLabel("Temas Personalizados", 14)
TabTemas:CreateDivider()
TabTemas:CreateLabel("Haz clic para cambiar el tema dinámicamente", 11)
TabTemas:CreateDivider()

local temas = {
    "Dark", "DarkV2",
    "Red", "RedV2",
    "Pink", "PinkV2", "PinkV3",
    "Blue", "BlueV2",
    "White", "WhiteV2", "WhiteV3", "WhiteAndDark",
    "Green", "NaranjaV1", "VioletaV1",
    "CatV1",
    "LightV1",
    "ErisV1",
    "ShylfieV1"
}

for _, tema in ipairs(temas) do
    TabTemas:CreateButton(tema, function()
        DemoUI:SetTheme(tema)
        print("✓ Tema cambiado a: " .. tema)
    end)
end

TabTemas:CreateDivider()
TabTemas:CreateLabel("Efectos de Texto", 12)
TabTemas:CreateDivider()

TabTemas:CreateButton("⚪ Normal (Blanco)", function()
    DemoUI:SetTextEffect("Off")
    print("Efecto: Normal")
end)

TabTemas:CreateButton("💫 Blanco-Celeste", function()
    DemoUI:SetTextEffect("WhiteCyan")
    print("Efecto: Blanco-Celeste")
end)

TabTemas:CreateButton("💗 Blanco-Rosa", function()
    DemoUI:SetTextEffect("WhitePink")
    print("Efecto: Blanco-Rosa")
end)

TabTemas:CreateButton("🌈 Arcoiris", function()
    DemoUI:SetTextEffect("Rainbow")
    print("Efecto: Rainbow")
end)

TabTemas:CreateButton("🖤 Dark-White", function()
    DemoUI:SetTextEffect("RainbowDarkWhite")
    print("Efecto: Dark-White")
end)

print("✅ Tab 'Temas' creado")

--// ════════════════════════════════════════════════════════════════
--// 6. TAB EFECTOS (SAGRADA - TERCERA) - Duplicado de Temas
--// ════════════════════════════════════════════════════════════════

local TabEfectos = DemoUI:CreateTab("Efectos")

TabEfectos:CreateLabel("Efectos de Texto", 14)
TabEfectos:CreateDivider()
TabEfectos:CreateLabel("Selecciona un efecto para personalizar el texto", 11)
TabEfectos:CreateDivider()

TabEfectos:CreateButton("⚪ Normal (Blanco)", function()
    DemoUI:SetTextEffect("Off")
    print("Efecto: Normal")
end)

TabEfectos:CreateButton("💫 Blanco-Celeste", function()
    DemoUI:SetTextEffect("WhiteCyan")
    print("Efecto: Blanco-Celeste")
end)

TabEfectos:CreateButton("💗 Blanco-Rosa", function()
    DemoUI:SetTextEffect("WhitePink")
    print("Efecto: Blanco-Rosa")
end)

TabEfectos:CreateButton("🌈 Arcoiris Completo", function()
    DemoUI:SetTextEffect("Rainbow")
    print("Efecto: Rainbow Completo")
end)

TabEfectos:CreateButton("🖤 Rainbow Dark-White", function()
    DemoUI:SetTextEffect("RainbowDarkWhite")
    print("Efecto: Dark-White (Negro → Blanco)")
end)

print("✅ Tab 'Efectos' creado")

--// ════════════════════════════════════════════════════════════════
--// 7. CONFIGURACIÓN DEL ESP
--// ════════════════════════════════════════════════════════════════

local ESPConfig = {
    Enabled = false,
    ShowNames = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowTeamColor = false,
    TeamCheck = false,
    Distance = 500,
}

--// ════════════════════════════════════════════════════════════════
--// 8. FUNCIONES DEL ESP
--// ════════════════════════════════════════════════════════════════

local function getTeam(player)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        return player.Team
    end
    return nil
end

local function getTeamColor(player)
    local team = getTeam(player)
    if team then
        return team.TeamColor.Color
    end
    return Color3.fromRGB(100, 200, 255)
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

    local billboard = character:FindFirstChild("ESPBillboard")
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPBillboard"
        billboard.Size = UDim2.new(4, 0, 2.5, 0)
        billboard.MaxDistance = ESPConfig.Distance
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        
        pcall(function()
            billboard.Adornee = rootPart
        end)
        
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

    local teamColor = getTeamColor(player)
    local nameColor = ESPConfig.ShowTeamColor and teamColor or Color3.fromRGB(100, 200, 255)

    if ESPConfig.ShowNames then
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Name = "NameLabel"
        NameLabel.Size = UDim2.new(1, 0, 0, 20)
        NameLabel.Position = UDim2.new(0, 0, 0, -25)
        NameLabel.BackgroundTransparency = 1
        NameLabel.TextColor3 = nameColor
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
        local healthPercent = math.min((humanoid.Health / math.max(humanoid.MaxHealth, 1)) * 100, 100)

        local HealthLabel = Instance.new("TextLabel")
        HealthLabel.Name = "HealthLabel"
        HealthLabel.Size = UDim2.new(1, 0, 0, 16)
        HealthLabel.Position = UDim2.new(0, 0, 1, 0)
        HealthLabel.BackgroundTransparency = 1
        HealthLabel.TextColor3 = healthPercent > 50 and Color3.fromRGB(100, 200, 100) or healthPercent > 25 and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(255, 100, 100)
        HealthLabel.TextSize = 11
        HealthLabel.Font = Enum.Font.Gotham
        HealthLabel.Text = string.format("%d/%d", health, maxHealth)
        HealthLabel.TextScaled = true
        HealthLabel.Parent = Frame
    end

    return billboard
end

local function updateESP()
    if not ESPConfig.Enabled then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if ESPConfig.TeamCheck and getTeam(player) == getTeam(LocalPlayer) then
                goto continue
            end

            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (Camera.CFrame.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance > ESPConfig.Distance then
                    goto continue
                end
            end

            pcall(function()
                createOrUpdateESPLabel(player)
            end)

            ::continue::
        end
    end
end

local function clearAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local billboard = player.Character:FindFirstChild("ESPBillboard")
            if billboard then
                pcall(function() billboard:Destroy() end)
            end
        end
    end
end

print("✅ Funciones ESP definidas")

--// ════════════════════════════════════════════════════════════════
--// 9. TAB EVADE (MI PESTAÑA PERSONALIZADA)
--// ════════════════════════════════════════════════════════════════

local TabEvade = DemoUI:CreateTab("Evade")

TabEvade:CreateLabel("👁️  ESP Players", 14)
TabEvade:CreateDivider()

TabEvade:CreateToggle("Activar ESP", false, function(state)
    ESPConfig.Enabled = state
    if not state then
        clearAllESP()
        print("❌ ESP desactivado")
    else
        print("✅ ESP activado")
    end
end)

TabEvade:CreateToggle("Mostrar nombres", true, function(state)
    ESPConfig.ShowNames = state
    print("Nombres: " .. (state and "✅" or "❌"))
end)

TabEvade:CreateToggle("Mostrar distancia", true, function(state)
    ESPConfig.ShowDistance = state
    print("Distancia: " .. (state and "✅" or "❌"))
end)

TabEvade:CreateToggle("Mostrar salud", true, function(state)
    ESPConfig.ShowHealth = state
    print("Salud: " .. (state and "✅" or "❌"))
end)

TabEvade:CreateToggle("Color de equipo", false, function(state)
    ESPConfig.ShowTeamColor = state
    print("Color de equipo: " .. (state and "✅" or "❌"))
end)

TabEvade:CreateToggle("Verificar equipo", false, function(state)
    ESPConfig.TeamCheck = state
    print("Team check: " .. (state and "✅" or "❌"))
end)

TabEvade:CreateDivider()
TabEvade:CreateLabel("Distancia: " .. ESPConfig.Distance .. "m", 12)

TabEvade:CreateButton("Limpiar ESP", function()
    clearAllESP()
    print("✅ ESP limpiado")
end)

TabEvade:CreateButton("Test ESP", function()
    ESPConfig.Enabled = not ESPConfig.Enabled
    print("ESP: " .. (ESPConfig.Enabled and "✅" or "❌"))
end)

print("✅ Tab 'Evade' creado")

--// ════════════════════════════════════════════════════════════════
--// 10. LOOP PRINCIPAL
--// ════════════════════════════════════════════════════════════════

local connection
connection = RunService.RenderStepped:Connect(function()
    if ESPConfig.Enabled then
        pcall(updateESP)
    end
end)

print("✅ Loop iniciado")

--// ════════════════════════════════════════════════════════════════
--// 11. CLEANUP
--// ════════════════════════════════════════════════════════════════

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        local billboard = player.Character:FindFirstChild("ESPBillboard")
        if billboard then
            pcall(function() billboard:Destroy() end)
        end
    end
end)

script.AncestryChanged:Connect(function()
    if not script.Parent then
        clearAllESP()
        if connection then
            connection:Disconnect()
        end
        print("Script destruido")
    end
end)

--// ════════════════════════════════════════════════════════════════
--// 12. NOTIFICACIÓN FINAL
--// ════════════════════════════════════════════════════════════════

print("═══════════════════════════════════════════════════════════════")
print("✅ EVADE ESP v1.0 - CARGADO EXITOSAMENTE")
print("═══════════════════════════════════════════════════════════════")
print("")
print("📋 PESTAÑAS DISPONIBLES:")
print("   ✅ Inicio (Avatar + Info servidor)")
print("   ✅ Temas (19 temas + 5 efectos)")
print("   ✅ Efectos (Efectos de texto)")
print("   ✅ Evade (ESP Players)")
print("")
print("🎮 CÓMO USAR:")
print("   1. Haz click en el botón Yin-Yang")
print("   2. Ve a 'Evade'")
print("   3. Activa 'Activar ESP'")
print("═══════════════════════════════════════════════════════════════")
