--[[
    ======================================================================
    PRUEBA DE LIBRERÍA UI: Yin-Yang v21
    Funcionalidad probada: ESP Players
    - Traje verde ajustado al cuerpo de cada jugador
    - Muestra la distancia en studs de cada jugador
    ======================================================================
]]

--// CARGAR LA LIBRERÍA COMPLETA (incluye su ejemplo)
local libSource = game:HttpGet("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v21.lua")

-- Ejecutar toda la librería (esto también crea el ejemplo de uso)
local loadstring_func = loadstring or load
loadstring_func(libSource)()

--======================================================================
--  DESTRUIR EL EJEMPLO DE USO QUE LA LIBRERÍA CREÓ AUTOMÁTICAMENTE
--======================================================================

-- La librería tiene un ejemplo integrado que se ejecuta al final.
-- Su UI se llama "ZeroMobile" y vive en PlayerGui.
-- La destruimos para que no interfiera con nuestra UI.
task.wait(0.5)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if LocalPlayer.PlayerGui:FindFirstChild("ZeroMobile") then
    LocalPlayer.PlayerGui.ZeroMobile:Destroy()
    print("🗑️ UI de ejemplo eliminada")
end

-- También limpiamos la variable global Zero para que no interfiera
Zero = nil

--======================================================================
--  REFERENCIAS
--======================================================================

local RunService = game:GetService("RunService")

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
            
            part.Color = Color3.fromRGB(0, 255, 0)
            part.Material = Enum.Material.SmoothPlastic
            part.Transparency = 0.1
            
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
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            createESP(player)
        end
    end
    
    ESPConnections.CharacterAdded = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            if ESPEnabled and player ~= LocalPlayer then
                task.wait(1)
                if player.Character then
                    createESP(player)
                end
            end
        end)
    end)
    
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
--  CREAR LA UI CON YIN-YANG v21 (NUESTRA UI)
--======================================================================

print("🎮 Yin Yang v21 - Probando con ESP Players...")

if not ZeroUI then
    warn("❌ Error: La librería ZeroUI no se cargó correctamente.")
    print("Posible causa: El script de la librería pudo haber fallado.")
    return
end

local Zero = ZeroUI:CreateWindow("Yin Yang ESP", "DarkV2")

--// TAB: ESP PLAYERS
local TabESP = Zero:CreateTab("ESP")
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

--// TAB: SISTEMA DE DISTANCIA
local TabInfo = Zero:CreateTab("Info")
TabInfo:CreateLabel("📊 Información en Tiempo Real", 16)
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
TabInfo:CreateLabel("🔧 El sistema ESP aplica un traje verde\najustado según el tipo de cuerpo de cada\njugador y muestra la distancia en studs.", 11)

--// TAB: AJUSTES
local TabSettings = Zero:CreateTab("Ajustes")
TabSettings:CreateLabel("⚙️ Personalización", 16)
TabSettings:CreateDivider()

TabSettings:CreateButton("Tema: DarkV2", function()
    Zero:SetTheme("DarkV2")
end)

TabSettings:CreateButton("Tema: BlueV2", function()
    Zero:SetTheme("BlueV2")
end)

TabSettings:CreateButton("Tema: RedV2", function()
    Zero:SetTheme("RedV2")
end)

TabSettings:CreateButton("Tema: Green", function()
    Zero:SetTheme("Green")
end)

TabSettings:CreateDivider()
TabSettings:CreateButton("Texto: Rainbow", function()
    Zero:SetTextEffect("Rainbow")
end)

TabSettings:CreateButton("Texto: WhiteCyan", function()
    Zero:SetTextEffect("WhiteCyan")
end)

TabSettings:CreateButton("Texto: Desactivar", function()
    Zero:SetTextEffect("Off")
end)

print("✅ Yin Yang v21 ESP Test - ¡Listo!")
