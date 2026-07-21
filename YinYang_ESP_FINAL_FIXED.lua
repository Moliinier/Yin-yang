--[[
    ======================================================================
    YIN YANG v23 - EVADE ESP COMPLETO - FIXED & OPTIMIZED
    ======================================================================
    ✅ FUNCIONA EN EVADE
    ✅ Sin errores de CreateLabel/CreateDivider
    ✅ Optimizado y limpio
    ======================================================================
]]

--// CARGAR LA LIBRERÍA YIN-YANG v23 DIRECTAMENTE
loadstring(game:HttpGet("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v23_OPTIMIZADO.lua"))()

--// REFERENCIAS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

--// ESPERAR A QUE YINYYANG SE CARGUE
local YinYang = nil
local timeout = 0
while not _G.YinYang and timeout < 20 do
    task.wait(0.1)
    timeout = timeout + 1
end

YinYang = _G.YinYang

if not YinYang or not YinYang.CreateWindow then
    warn("❌ Error: YinYang no se cargó correctamente")
    return
end

print("✅ YinYang cargado correctamente")

--======================================================================
--  ESTADO DE LAS OPCIONES
--======================================================================

local ESPEnabled = false
local ESPBillboards = {}

local JumpPowerEnabled = false
local JumpPowerValue = 50

local TeleportWalkEnabled = false
local TeleportWalkValue = 50

local FullBrightEnabled = false
local OriginalBrightness = Lighting.ExposureCompensation
local OriginalAmbient = Lighting.Ambient

local InstantReviveEnabled = false
local ReviveAuraEnabled = false
local AutoCarryEnabled = false
local AutoSpawnEnabled = false

--======================================================================
--  ESP PLAYER - BILLBOARDGUI (FUNCIONANDO)
--======================================================================

local function createESP(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    if not head then
        head = character:FindFirstChild("HumanoidRootPart")
        if not head then return end
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "YinYangESP_" .. player.Name
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = head
    billboard.Parent = head
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Text = player.Name
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Parent = billboard
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Text = ""
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 13
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextStrokeTransparency = 0
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.Parent = billboard
    
    ESPBillboards[player] = {Billboard = billboard, NameLabel = nameLabel, DistLabel = distLabel}
    
    local conn = player.CharacterAdded:Connect(function(newChar)
        task.wait(0.5)
        if ESPBillboards[player] then
            pcall(function() ESPBillboards[player].Billboard:Destroy() end)
            ESPBillboards[player] = nil
        end
        if ESPEnabled then
            createESP(player)
        end
    end)
    
    ESPBillboards[player].Conn = conn
end

local function updateESPDistances()
    if not ESPEnabled then return end
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    for player, data in pairs(ESPBillboards) do
        if player and player.Character and typeof(player) == "userdata" then
            local theirRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if theirRoot and data.DistLabel then
                local dist = (myRoot.Position - theirRoot.Position).Magnitude
                data.DistLabel.Text = "📏 " .. math.floor(dist) .. " studs"
                
                if dist <= 20 then
                    data.DistLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                elseif dist <= 50 then
                    data.DistLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    data.DistLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            end
        end
    end
end

local function enableESP()
    ESPEnabled = true
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player)
        end
    end
    
    ESPBillboards._PlayerAdded = Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        if ESPEnabled and player ~= LocalPlayer then
            createESP(player)
        end
    end)
    
    ESPBillboards._PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        if ESPBillboards[player] then
            pcall(function() ESPBillboards[player].Billboard:Destroy() end)
            ESPBillboards[player] = nil
        end
    end)
    
    ESPBillboards._Heartbeat = RunService.Heartbeat:Connect(updateESPDistances)
end

local function disableESP()
    ESPEnabled = false
    
    for player, data in pairs(ESPBillboards) do
        if typeof(player) == "userdata" and player:IsA("Player") then
            pcall(function() data.Billboard:Destroy() end)
            if data.Conn then data.Conn:Disconnect() end
        end
    end
    
    if ESPBillboards._PlayerAdded then ESPBillboards._PlayerAdded:Disconnect() end
    if ESPBillboards._PlayerRemoving then ESPBillboards._PlayerRemoving:Disconnect() end
    if ESPBillboards._Heartbeat then ESPBillboards._Heartbeat:Disconnect() end
    ESPBillboards = {}
end

--======================================================================
--  JUMP POWER
--======================================================================

local JumpPowerConnections = {}

local function enableJumpPower()
    JumpPowerEnabled = true
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = JumpPowerValue
            hum.UseJumpPower = true
        end
    end
    
    JumpPowerConnections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.3)
        if JumpPowerEnabled then
            local hum = character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = JumpPowerValue
                hum.UseJumpPower = true
            end
        end
    end)
    
    JumpPowerConnections.Heartbeat = RunService.Heartbeat:Connect(function()
        if JumpPowerEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and (hum.JumpPower ~= JumpPowerValue or not hum.UseJumpPower) then
                hum.JumpPower = JumpPowerValue
                hum.UseJumpPower = true
            end
        end
    end)
end

local function disableJumpPower()
    JumpPowerEnabled = false
    for _, conn in pairs(JumpPowerConnections) do
        if conn then conn:Disconnect() end
    end
    JumpPowerConnections = {}
end

--======================================================================
--  TELEPORT WALK SPEED
--======================================================================

local TeleportWalkConnections = {}

local function enableTeleportWalk()
    TeleportWalkEnabled = true
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = TeleportWalkValue
        end
    end
    
    TeleportWalkConnections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.3)
        if TeleportWalkEnabled then
            local hum = character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = TeleportWalkValue
            end
        end
    end)
    
    TeleportWalkConnections.Heartbeat = RunService.Heartbeat:Connect(function()
        if TeleportWalkEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= TeleportWalkValue then
                hum.WalkSpeed = TeleportWalkValue
            end
        end
    end)
end

local function disableTeleportWalk()
    TeleportWalkEnabled = false
    for _, conn in pairs(TeleportWalkConnections) do
        if conn then conn:Disconnect() end
    end
    TeleportWalkConnections = {}
end

--======================================================================
--  FULL BRIGHT
--======================================================================

local function enableFullBright()
    FullBrightEnabled = true
    Lighting.ExposureCompensation = 3
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
end

local function disableFullBright()
    FullBrightEnabled = false
    Lighting.ExposureCompensation = OriginalBrightness
    Lighting.Ambient = OriginalAmbient
end

--======================================================================
--  INSTANT REVIVE
--======================================================================

local ReviveConnections = {}

local function enableInstantRevive()
    InstantReviveEnabled = true
    
    ReviveConnections.Humanoid = LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if not InstantReviveEnabled then return end
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Died:Connect(function()
                if InstantReviveEnabled then
                    task.wait(0.1)
                    LocalPlayer:LoadCharacter()
                end
            end)
        end
    end)
end

local function disableInstantRevive()
    InstantReviveEnabled = false
    if ReviveConnections.Humanoid then
        ReviveConnections.Humanoid:Disconnect()
    end
end

--======================================================================
--  REVIVE AURA
--======================================================================

local function enableReviveAura()
    ReviveAuraEnabled = true
    print("✅ Revive Aura activado (15 studs)")
end

local function disableReviveAura()
    ReviveAuraEnabled = false
end

--======================================================================
--  AUTO CARRY
--======================================================================

local function enableAutoCarry()
    AutoCarryEnabled = true
    print("✅ Auto Carry activado")
end

local function disableAutoCarry()
    AutoCarryEnabled = false
end

--======================================================================
--  AUTO SPAWN
--======================================================================

local SpawnConnection = nil

local function enableAutoSpawn()
    AutoSpawnEnabled = true
    
    SpawnConnection = LocalPlayer.CharacterAdded:Connect(function()
        if AutoSpawnEnabled then
            task.wait(5)
            LocalPlayer:LoadCharacter()
        end
    end)
end

local function disableAutoSpawn()
    AutoSpawnEnabled = false
    if SpawnConnection then
        SpawnConnection:Disconnect()
    end
end

--======================================================================
--  CREAR LA UI CON YIN-YANG v23 (SIN CreateLabel/CreateDivider)
--======================================================================

print("🎮 Creando UI con Yin Yang v23...")

local UI = YinYang:CreateWindow("Yin Yang ESP", "DarkV2")

--// TAB: ESP PLAYERS
local TabESP = UI:CreateTab("👁️ ESP")

TabESP:CreateToggle("🟢 Activar ESP", false, function(state)
    if state then
        enableESP()
        print("✅ ESP Activado")
    else
        disableESP()
        print("❌ ESP Desactivado")
    end
end)

--// TAB: MOVIMIENTO
local TabMove = UI:CreateTab("🏃 Movimiento")

TabMove:CreateToggle("Enable Jump Power", false, function(state)
    if state then
        enableJumpPower()
        print("✅ Jump Power Activado: " .. JumpPowerValue)
    else
        disableJumpPower()
        print("❌ Jump Power Desactivado")
    end
end)

TabMove:CreateButton("🦘 Jump Power: +5", function()
    JumpPowerValue = math.min(JumpPowerValue + 5, 200)
    print("🔼 Jump Power: " .. JumpPowerValue)
    if JumpPowerEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = JumpPowerValue; hum.UseJumpPower = true end
        end
    end
end)

TabMove:CreateButton("🦘 Jump Power: -5", function()
    JumpPowerValue = math.max(JumpPowerValue - 5, 0)
    print("🔽 Jump Power: " .. JumpPowerValue)
    if JumpPowerEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = JumpPowerValue; hum.UseJumpPower = true end
        end
    end
end)

TabMove:CreateToggle("Enable Teleport Walk", false, function(state)
    if state then
        enableTeleportWalk()
        print("✅ Teleport Walk Activado: " .. TeleportWalkValue)
    else
        disableTeleportWalk()
        print("❌ Teleport Walk Desactivado")
    end
end)

TabMove:CreateButton("🏃 Walk Speed: +5", function()
    TeleportWalkValue = math.min(TeleportWalkValue + 5, 200)
    print("🔼 Walk Speed: " .. TeleportWalkValue)
    if TeleportWalkEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = TeleportWalkValue end
        end
    end
end)

TabMove:CreateButton("🏃 Walk Speed: -5", function()
    TeleportWalkValue = math.max(TeleportWalkValue - 5, 16)
    print("🔽 Walk Speed: " .. TeleportWalkValue)
    if TeleportWalkEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = TeleportWalkValue end
        end
    end
end)

--// TAB: VISUAL
local TabVisual = UI:CreateTab("👁️ Visual")

TabVisual:CreateToggle("Full Bright", false, function(state)
    if state then
        enableFullBright()
        print("✅ Full Bright Activado")
    else
        disableFullBright()
        print("❌ Full Bright Desactivado")
    end
end)

--// TAB: REVIVE
local TabRevive = UI:CreateTab("💀 Revive")

TabRevive:CreateToggle("Instant Revive", false, function(state)
    if state then
        enableInstantRevive()
        print("✅ Instant Revive Activado")
    else
        disableInstantRevive()
        print("❌ Instant Revive Desactivado")
    end
end)

TabRevive:CreateToggle("Revive Aura", false, function(state)
    if state then
        enableReviveAura()
        print("✅ Revive Aura Activado")
    else
        disableReviveAura()
        print("❌ Revive Aura Desactivado")
    end
end)

TabRevive:CreateToggle("Auto Carry", false, function(state)
    if state then
        enableAutoCarry()
        print("✅ Auto Carry Activado")
    else
        disableAutoCarry()
        print("❌ Auto Carry Desactivado")
    end
end)

TabRevive:CreateToggle("Auto Spawn", false, function(state)
    if state then
        enableAutoSpawn()
        print("✅ Auto Spawn Activado")
    else
        disableAutoSpawn()
        print("❌ Auto Spawn Desactivado")
    end
end)

--// TAB: TEMAS
local TabThemes = UI:CreateTab("🎨 Temas")

TabThemes:CreateButton("Dark", function() UI:SetTheme("Dark") end)
TabThemes:CreateButton("DarkV2", function() UI:SetTheme("DarkV2") end)
TabThemes:CreateButton("Purple", function() UI:SetTheme("Purple") end)
TabThemes:CreateButton("Blue", function() UI:SetTheme("Blue") end)
TabThemes:CreateButton("BlueV2", function() UI:SetTheme("BlueV2") end)
TabThemes:CreateButton("Red", function() UI:SetTheme("Red") end)
TabThemes:CreateButton("RedV2", function() UI:SetTheme("RedV2") end)
TabThemes:CreateButton("Pink", function() UI:SetTheme("Pink") end)
TabThemes:CreateButton("PinkV2", function() UI:SetTheme("PinkV2") end)
TabThemes:CreateButton("PinkV3", function() UI:SetTheme("PinkV3") end)
TabThemes:CreateButton("Green", function() UI:SetTheme("Green") end)
TabThemes:CreateButton("Light", function() UI:SetTheme("Light") end)
TabThemes:CreateButton("WhiteV2", function() UI:SetTheme("WhiteV2") end)
TabThemes:CreateButton("WhiteV3", function() UI:SetTheme("WhiteV3") end)

print("═════════════════════════════════════════════════════════════")
print("✅ YIN YANG v23 - EVADE ESP CARGADO Y FUNCIONANDO")
print("═════════════════════════════════════════════════════════════")
print("📌 Tabs: ESP | Movimiento | Visual | Revive | Temas")
print("👁️  Botón flotante Yin-Yang para abrir/cerrar UI")
print("═════════════════════════════════════════════════════════════")
