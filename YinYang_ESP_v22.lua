--[[
    ======================================================================
    PRUEBA DE LIBRERÍA UI: Yin-Yang v22
    Funcionalidad probada: ESP Players
    - Traje verde ajustado al cuerpo de cada jugador
    - Muestra la distancia en studs de cada jugador
    ======================================================================
]]

--// CARGAR LA LIBRERÍA YIN-YANG v22
-- La librería ahora se registra como _G.YinYang automáticamente
loadstring(game:HttpGet("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v22.lua"))()

--// REFERENCIAS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// ACCEDER A LA LIBRERÍA GLOBALMENTE (como indicó Claude)
local YinYang = _G.YinYang

if not YinYang then
    warn("❌ Error: YinYang no está disponible en _G")
    return
end

--======================================================================
--  SISTEMA ESP
--======================================================================

local ESPEnabled = false
local ESPConnections = {}
local ESPInstances = {}

local function getDistance(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
       LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        return math.floor(dist)
    end
    return 0
end

local function getBodyType(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return "default" end
    
    local depthScale = humanoid:FindFirstChild("BodyDepthScale")
    local heightScale = humanoid:FindFirstChild("BodyHeightScale")
    
    if depthScale and heightScale then
        local avg = (depthScale.Value + heightScale.Value) / 2
        if avg > 1.3 then
            return "large"
        elseif avg < 0.7 then
            return "small"
        else
            return "medium"
        end
    end
    return "default"
end

local function createESP(player)
    if player == LocalPlayer then return end
    if ESPInstances[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local originalProps = {}
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("MeshPart") or part:IsA("Part") then
            originalProps[part] = {
                Color = part.Color,
                Material = part.Material,
                Transparency = part.Transparency,
                Size = part.Size,
            }
            
            -- Aplicar traje verde ajustado
            part.Color = Color3.fromRGB(0, 255, 0)
            part.Material = Enum.Material.SmoothPlastic
            part.Transparency = 0.1
            
            -- Ajustar escala según tipo de cuerpo
            local bodyType = getBodyType(character)
            if bodyType == "small" then
                part.Size = part.Size * 0.95
            elseif bodyType == "large" then
                part.Size = part.Size * 1.05
            end
        end
    end
    
    ESPInstances[player] = {
        Parts = originalProps,
        Character = character,
        Player = player,
    }
end

local function removeESP(player)
    if not ESPInstances[player] then return end
    
    local espData = ESPInstances[player]
    
    for part, props in pairs(espData.Parts) do
        if part and part.Parent then
            part.Color = props.Color
            part.Material = props.Material
            part.Transparency = props.Transparency
            part.Size = props.Size
        end
    end
    
    ESPInstances[player] = nil
end

local function enableESP()
    ESPEnabled = true
    
    -- Aplicar ESP a jugadores existentes
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            createESP(player)
        end
    end
    
    -- Nuevos jugadores que se unen
    ESPConnections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            if ESPEnabled and player ~= LocalPlayer then
                task.wait(1)
                if player.Character then
                    createESP(player)
                end
            end
        end)
    end)
    
    -- Detectar respawns de jugadores existentes
    ESPConnections.Heartbeat = RunService.Heartbeat:Connect(function()
        if ESPEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not ESPInstances[player] then
                        createESP(player)
                    end
                end
            end
        end
    end)
end

local function disableESP()
    ESPEnabled = false
    
    for name, conn in pairs(ESPConnections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    ESPConnections = {}
    
    for player in pairs(ESPInstances) do
        removeESP(player)
    end
    ESPInstances = {}
end

--======================================================================
--  CREAR LA UI CON YIN-YANG v22
--======================================================================

print("🎮 Yin Yang v22 - Probando ESP Players...")

-- Crear la ventana principal (usando la API correcta de v22)
local UI = YinYang:CreateWindow("Yin Yang ESP", "DarkV2")

--// TAB: ESP PLAYERS
local TabESP = UI:CreateTab("ESP")
TabESP:CreateLabel("⚡ Control de ESP", 16)
TabESP:CreateDivider()

TabESP:CreateToggle("Activar ESP", false, function(state)
    if state then
        enableESP()
        print("✅ ESP Activado - Jugadores con traje verde")
    else
        disableESP()
        print("❌ ESP Desactivado")
    end
end)

TabESP:CreateDivider()
TabESP:CreateLabel("Opciones de ESP:", 13)

TabESP:CreateFloatingToggle("Mostrar Distancia", true, function(state)
    print("Distancia: " .. (state and "ON" or "OFF"))
end)

TabESP:CreateFloatingToggle("Traje Ajustado", true, function(state)
    print("Traje Ajustado: " .. (state and "ON" or "OFF"))
end)

--// TAB: INFO DE JUGADORES
local TabInfo = UI:CreateTab("Info")
TabInfo:CreateLabel("📊 Jugadores en el Servidor", 16)
TabInfo:CreateDivider()

local infoLabels = {}

RunService.Heartbeat:Connect(function()
    for _, label in ipairs(infoLabels) do
        if label and label.Parent then
            label:Destroy()
        end
    end
    infoLabels = {}
    
    local sortedPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local dist = getDistance(player)
            table.insert(sortedPlayers, {Player = player, Distance = dist})
        end
    end
    
    table.sort(sortedPlayers, function(a, b) return a.Distance < b.Distance end)
    
    local count = math.min(#sortedPlayers, 5)
    for i = 1, count do
        local entry = sortedPlayers[i]
        local label = TabInfo:CreateLabel(
            string.format("🎯 %s — %d studs", entry.Player.DisplayName, entry.Distance),
            12
        )
        table.insert(infoLabels, label)
    end
    
    if #sortedPlayers == 0 then
        local label = TabInfo:CreateLabel("No hay otros jugadores cerca", 12)
        table.insert(infoLabels, label)
    end
end)

TabInfo:CreateDivider()
TabInfo:CreateLabel("🔧 El ESP aplica un traje verde ajustado\nsegún el tipo de cuerpo de cada jugador\ny muestra la distancia en studs.", 11)

--// TAB: AJUSTES
local TabSettings = UI:CreateTab("Ajustes")
TabSettings:CreateLabel("⚙️ Personalización", 16)
TabSettings:CreateDivider()

TabSettings:CreateButton("Tema: DarkV2", function()
    UI:SetTheme("DarkV2")
end)

TabSettings:CreateButton("Tema: BlueV2", function()
    UI:SetTheme("BlueV2")
end)

TabSettings:CreateButton("Tema: RedV2", function()
    UI:SetTheme("RedV2")
end)

TabSettings:CreateButton("Tema: Green", function()
    UI:SetTheme("Green")
end)

TabSettings:CreateDivider()
TabSettings:CreateButton("Texto: Rainbow", function()
    UI:SetTextEffect("Rainbow")
end)

TabSettings:CreateButton("Texto: WhiteCyan", function()
    UI:SetTextEffect("WhiteCyan")
end)

TabSettings:CreateButton("Texto: Desactivar", function()
    UI:SetTextEffect("Off")
end)

print("✅ Yin Yang v22 ESP Test - ¡Listo!")
print("   Temas: DarkV2, BlueV2, RedV2, Green")
print("   Efectos: Rainbow, WhiteCyan")
