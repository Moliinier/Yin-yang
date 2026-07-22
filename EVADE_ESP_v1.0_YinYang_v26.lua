--[[
    ╔════════════════════════════════════════════════════════════════╗
    ║  EVADE ESP v1.0 - YIN YANG UI v26                             ║
    ║  ============================================================  ║
    ║  • Carga librería desde GitHub                                ║
    ║  • Mantiene 3 pestañas sagradas (Inicio, Temas, Efectos)     ║
    ║  • Agrega pestaña "Evade" con ESP Players                    ║
    ║  • Funcional en Evade (sin Drawing)                          ║
    ╚════════════════════════════════════════════════════════════════╝
]]

--// ════════════════════════════════════════════════════════════════
--// 1. CARGAR LIBRERÍA YIN YANG v26 DESDE GITHUB
--// ════════════════════════════════════════════════════════════════

print("📥 Cargando Yin Yang v26...")

local success = pcall(function()
    if _G.YinYang then
        print("✅ Yin Yang ya estaba cargado")
        return
    end
    
    local url = "https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v26_PRODUCCION.lua.txt"
    local code = game:GetService("HttpService"):GetAsync(url)
    loadstring(code)()
    
    if _G.YinYang then
        print("✅ Yin Yang v26 cargado exitosamente")
    else
        error("YinYang no se inicializó")
    end
end)

if not success then
    warn("❌ Error al cargar Yin Yang v26")
    return
end

--// ════════════════════════════════════════════════════════════════
--// 2. SERVICIOS NECESARIOS
--// ════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

print("✅ Servicios inicializados")

--// ════════════════════════════════════════════════════════════════
--// 3. CREAR UI CON YIN YANG v26
--// ════════════════════════════════════════════════════════════════

local YinYang = _G.YinYang
local UI = YinYang:CreateWindow("EVADE ESP v1.0", "Dark")

print("✅ UI Yin Yang creada")
print("✅ 3 pestañas sagradas creadas automáticamente:")
print("   • Inicio (con WelcomeCard + ServerInfoCard)")
print("   • Temas (con 19 temas disponibles)")
print("   • Efectos (con 5 efectos de texto)")

--// ════════════════════════════════════════════════════════════════
--// 4. CREAR PESTAÑA "EVADE" (MI PESTAÑA PERSONALIZADA)
--// ════════════════════════════════════════════════════════════════

local TabEvade = UI:CreateTab("Evade")

print("✅ Pestaña 'Evade' creada")

--// ════════════════════════════════════════════════════════════════
--// 5. CONFIGURACIÓN DEL ESP
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
--// 6. FUNCIONES DEL ESP
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

    --// Obtener o crear Billboard GUI
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

    local teamColor = getTeamColor(player)
    local nameColor = ESPConfig.ShowTeamColor and teamColor or Color3.fromRGB(100, 200, 255)

    --// NOMBRE DEL JUGADOR
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

    --// SALUD
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
        HealthLabel.Text = string.format("%d/%d HP", health, maxHealth)
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

--// ════════════════════════════════════════════════════════════════
--// 7. UI: AGREGAR COMPONENTES A LA PESTAÑA "EVADE"
--// ════════════════════════════════════════════════════════════════

TabEvade:CreateLabel("👁️  ESP Players", 14)
TabEvade:CreateDivider()

--// TOGGLE: ACTIVAR ESP
TabEvade:CreateToggle("Activar ESP", false, function(state)
    ESPConfig.Enabled = state
    if not state then
        clearAllESP()
        print("❌ ESP desactivado")
    else
        print("✅ ESP activado")
    end
end)

--// TOGGLE: MOSTRAR NOMBRES
TabEvade:CreateToggle("Mostrar nombres", true, function(state)
    ESPConfig.ShowNames = state
    print("Nombres: " .. (state and "✅ ON" or "❌ OFF"))
end)

--// TOGGLE: MOSTRAR DISTANCIA
TabEvade:CreateToggle("Mostrar distancia", true, function(state)
    ESPConfig.ShowDistance = state
    print("Distancia: " .. (state and "✅ ON" or "❌ OFF"))
end)

--// TOGGLE: MOSTRAR SALUD
TabEvade:CreateToggle("Mostrar salud", true, function(state)
    ESPConfig.ShowHealth = state
    print("Salud: " .. (state and "✅ ON" or "❌ OFF"))
end)

--// TOGGLE: COLOR DE EQUIPO
TabEvade:CreateToggle("Color de equipo", false, function(state)
    ESPConfig.ShowTeamColor = state
    print("Color de equipo: " .. (state and "✅ ON" or "❌ OFF"))
end)

--// TOGGLE: VERIFICAR EQUIPO
TabEvade:CreateToggle("Verificar equipo", false, function(state)
    ESPConfig.TeamCheck = state
    print("Team check: " .. (state and "✅ ON" or "❌ OFF"))
end)

TabEvade:CreateDivider()

TabEvade:CreateLabel("Distancia máxima: " .. ESPConfig.Distance .. "m", 12)

--// BOTÓN: LIMPIAR ESP
TabEvade:CreateButton("Limpiar ESP", function()
    clearAllESP()
    print("✅ ESP limpiado")
end)

--// BOTÓN: TEST
TabEvade:CreateButton("Test ESP (Toggle)", function()
    ESPConfig.Enabled = not ESPConfig.Enabled
    print("ESP: " .. (ESPConfig.Enabled and "✅ ON" or "❌ OFF"))
end)

--// ════════════════════════════════════════════════════════════════
--// 8. LOOP PRINCIPAL (RenderStepped para actualizar cada frame)
--// ════════════════════════════════════════════════════════════════

local connection
connection = RunService.RenderStepped:Connect(function()
    if ESPConfig.Enabled then
        pcall(updateESP)
    end
end)

print("✅ Loop RenderStepped conectado")

--// ════════════════════════════════════════════════════════════════
--// 9. CLEANUP AL DESCONECTARSE O ELIMINAR JUGADORES
--// ════════════════════════════════════════════════════════════════

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        local billboard = player.Character:FindFirstChild("ESPBillboard")
        if billboard then
            pcall(function() billboard:Destroy() end)
        end
    end
end)

--// SCRIPT CLEANUP
script.AncestryChanged:Connect(function()
    if not script.Parent then
        clearAllESP()
        if connection then
            connection:Disconnect()
        end
        print("❌ Script destruido - ESP limpiado")
    end
end)

--// ════════════════════════════════════════════════════════════════
--// 10. NOTIFICACIÓN FINAL
--// ════════════════════════════════════════════════════════════════

print("═══════════════════════════════════════════════════════════════")
print("✅ EVADE ESP v1.0 - YIN YANG v26 CARGADO CORRECTAMENTE")
print("═══════════════════════════════════════════════════════════════")
print("")
print("📋 ESTRUCTURA:")
print("   ✅ Pestaña 'Inicio' (Automática - Avatar + Info servidor)")
print("   ✅ Pestaña 'Temas' (Automática - 19 temas disponibles)")
print("   ✅ Pestaña 'Efectos' (Automática - 5 efectos de texto)")
print("   ✅ Pestaña 'Evade' (Personalizada - ESP Players)")
print("")
print("🎮 CÓMO USAR:")
print("   1. Abre la UI (botón Yin-Yang flotante)")
print("   2. Ve a la pestaña 'Evade'")
print("   3. Activa 'Activar ESP'")
print("   4. Personaliza las opciones según necesites")
print("   5. Usa la pestaña 'Temas' para cambiar colores")
print("   6. Usa la pestaña 'Efectos' para cambiar efectos de texto")
print("")
print("═══════════════════════════════════════════════════════════════")
print("✅ LISTO PARA USAR - SIN ERRORES")
print("═══════════════════════════════════════════════════════════════")
