--[[
    ======================================================================
    PRUEBA DE LIBRERÍA UI: Yin-Yang v21
    Funcionalidad probada: ESP Players
    - Traje verde ajustado al cuerpo de cada jugador
    - Muestra la distancia en studs de cada jugador
    ======================================================================
]]

--// CARGAR LA LIBRERÍA YIN-YANG v21 (SOLO EL CORE, SIN EL EJEMPLO)
-- La librería tiene un ejemplo de uso incluido al final (líneas 346-1479)
-- que se ejecuta automáticamente. Para evitarlo, cargamos solo la parte
-- funcional (líneas 1-345) y construimos nuestra propia UI.

local lib = game:HttpGet("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v21.lua")

--// Extraemos solo el código de la librería (sin el ejemplo de uso)
-- El ejemplo de uso comienza en la línea 346 con "--// EJEMPLO DE USO"
local coreCode = lib:sub(1, lib:find("\n%-%-//%s*=%=+%s*\n%-%-//%s*EJEMPLO")) or lib

-- Ejecutar solo el core de la librería (define ZeroUI globalmente)
local loadstring_func = loadstring or load
loadstring_func(coreCode)()

--======================================================================
--  REFERENCIAS
--======================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--======================================================================
--  SISTEMA ESP
--======================================================================

local ESPEnabled = false
local ESPConnections = {}
local ESPInstances = {}

-- Función para obtener la distancia en studs entre el jugador local y otro
local function getDistance(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
       LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        return math.floor(dist)
    end
    return 0
end

-- Función para determinar el tipo de cuerpo del personaje (escala)
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

-- Función para crear el ESP de un jugador
local function createESP(player)
    if player == LocalPlayer then return end
    if ESPInstances[player] then return end
    
    local character = player.Character
    if not character then return end
    
    -- Guardar las propiedades originales de las partes del cuerpo
    local originalProps = {}
    
    -- Iterar por todas las partes visibles del cuerpo
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("MeshPart") or part:IsA("Part") then
            originalProps[part] = {
                Color = part.Color,
                Material = part.Material,
                Transparency = part.Transparency,
                Size = part.Size,
            }
            
            -- Aplicar el traje verde ajustado
            part.Color = Color3.fromRGB(0, 255, 0)  -- Verde brillante
            part.Material = Enum.Material.SmoothPlastic  -- Textura lisa y uniforme
            part.Transparency = 0.1  -- Ligeramente visible
            
            -- Ajustar la escala según el tipo de cuerpo para que se vea ajustado
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

-- Función para remover el ESP de un jugador
local function removeESP(player)
    if not ESPInstances[player] then return end
    
    local espData = ESPInstances[player]
    
    -- Restaurar las propiedades originales
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

-- Función para activar el ESP en todos los jugadores
local function enableESP()
    ESPEnabled = true
    
    -- Aplicar ESP a jugadores existentes
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            createESP(player)
        end
    end
    
    -- Conectar para nuevos personajes/spawns
    ESPConnections.CharacterAdded = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            if ESPEnabled and player ~= LocalPlayer then
                task.wait(1) -- Esperar a que cargue el modelo
                if player.Character then
                    createESP(player)
                end
            end
        end)
    end)
    
    -- Conectar para cambios de personaje en jugadores existentes
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

-- Función para desactivar el ESP
local function disableESP()
    ESPEnabled = false
    
    -- Desconectar eventos
    for name, conn in pairs(ESPConnections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    ESPConnections = {}
    
    -- Remover ESP de todos los jugadores
    for player in pairs(ESPInstances) do
        removeESP(player)
    end
    ESPInstances = {}
end

--======================================================================
--  CREAR LA UI CON YIN-YANG v21
--======================================================================

print("🎮 Yin Yang v21 - Probando con ESP Players...")

-- Verificar que la librería se cargó correctamente
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

-- Crear labels dinámicos para mostrar la información
local infoLabels = {}

-- Actualizar información de distancia cada segundo
local updateConnection = RunService.Heartbeat:Connect(function()
    -- Limpiar labels anteriores
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
    
    -- Ordenar por distancia
    table.sort(sortedPlayers, function(a, b) return a.Distance < b.Distance end)
    
    -- Mostrar solo los 5 más cercanos
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
print("   Temas: DarkV2, BlueV2, RedV2, Green")
print("   Efectos: Rainbow, WhiteCyan")
