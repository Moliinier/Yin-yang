--[[
    ======================================================================
    PRUEBA DE LIBRERÍA UI: Yin-Yang v22
    Funcionalidades:
      - ESP Player (Highlight morado)
      - Jump Power (Slider + Toggle Enable)
      - Teleport Walk Speed (Slider + Toggle Enable)
      - Full Bright
      - Instant Revive
      - Revive Aura
      - Auto Carry
    ======================================================================
]]

--// CARGAR LA LIBRERÍA YIN-YANG v22
loadstring(game:HttpGet("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v22.lua"))()

--// REFERENCIAS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

--// ACCEDER A LA LIBRERÍA GLOBALMENTE
local YinYang = _G.YinYang

if not YinYang then
    warn("❌ Error: YinYang no está disponible en _G")
    return
end

--======================================================================
--  ESTADO DE LAS OPCIONES
--======================================================================

local ESPEnabled = false
local ESPInstances = {}

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
local AutoCarryConnections = {}

--======================================================================
--  ESP PLAYER (Highlight Morado)
--======================================================================

local ESP_FillColor = Color3.fromRGB(175, 25, 255)
local ESP_DepthMode = Enum.DepthMode.AlwaysOnTop
local ESP_FillTransparency = 0.5
local ESP_OutlineColor = Color3.fromRGB(255, 255, 255)
local ESP_OutlineTransparency = 0

local ESPStorage = Instance.new("Folder")
ESPStorage.Name = "Highlight_Storage"
ESPStorage.Parent = game:GetService("CoreGui")

local function Highlight(plr)
    if plr == LocalPlayer then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = plr.Name
    highlight.FillColor = ESP_FillColor
    highlight.DepthMode = ESP_DepthMode
    highlight.FillTransparency = ESP_FillTransparency
    highlight.OutlineColor = ESP_OutlineColor
    highlight.OutlineTransparency = ESP_OutlineTransparency
    highlight.Parent = ESPStorage
    
    local plrchar = plr.Character
    if plrchar then
        highlight.Adornee = plrchar
    end

    if plr.CharacterAdded then
        plr.CharacterAdded:Connect(function(char)
            highlight.Adornee = char
        end)
    end
end

local function enableESP()
    ESPEnabled = true
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            Highlight(player)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        if ESPEnabled and player ~= LocalPlayer then
            Highlight(player)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(plr)
        if ESPStorage:FindFirstChild(plr.Name) then
            ESPStorage[plr.Name]:Destroy()
        end
    end)
end

local function disableESP()
    ESPEnabled = false
    ESPStorage:ClearAllChildren()
end

--======================================================================
--  JUMP POWER
--======================================================================

local JumpPowerConnections = {}

local function enableJumpPower()
    JumpPowerEnabled = true
    local character = LocalPlayer.Character
    
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = JumpPowerValue
            humanoid.UseJumpPower = true
        end
    end
    
    -- Monitorear cambios de personaje
    if JumpPowerConnections.CharacterAdded then
        JumpPowerConnections.CharacterAdded:Disconnect()
    end
    
    JumpPowerConnections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if JumpPowerEnabled then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = JumpPowerValue
                humanoid.UseJumpPower = true
            end
        end
    end)
    
    -- Forzar constantemente
    if JumpPowerConnections.Heartbeat then
        JumpPowerConnections.Heartbeat:Disconnect()
    end
    
    JumpPowerConnections.Heartbeat = RunService.Heartbeat:Connect(function()
        if JumpPowerEnabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.JumpPower ~= JumpPowerValue then
                humanoid.JumpPower = JumpPowerValue
                humanoid.UseJumpPower = true
            end
        end
    end)
end

local function disableJumpPower()
    JumpPowerEnabled = false
    
    for name, conn in pairs(JumpPowerConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    JumpPowerConnections = {}
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
            humanoid.UseJumpPower = true
        end
    end
end

--======================================================================
--  TELEPORT WALK SPEED
--======================================================================

local TeleportWalkConnections = {}

local function enableTeleportWalk()
    TeleportWalkEnabled = true
    
    if TeleportWalkConnections.Heartbeat then
        TeleportWalkConnections.Heartbeat:Disconnect()
    end
    
    TeleportWalkConnections.Heartbeat = RunService.Heartbeat:Connect(function()
        if TeleportWalkEnabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.WalkSpeed ~= TeleportWalkValue then
                humanoid.WalkSpeed = TeleportWalkValue
            end
        end
    end)
    
    if TeleportWalkConnections.CharacterAdded then
        TeleportWalkConnections.CharacterAdded:Disconnect()
    end
    
    TeleportWalkConnections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if TeleportWalkEnabled then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = TeleportWalkValue
            end
        end
    end)
end

local function disableTeleportWalk()
    TeleportWalkEnabled = false
    
    for name, conn in pairs(TeleportWalkConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    TeleportWalkConnections = {}
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end

--======================================================================
--  FULL BRIGHT
--======================================================================

local function enableFullBright()
    FullBrightEnabled = true
    Lighting.ExposureCompensation = 2
    Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    
    if Lighting:FindFirstChild("Atmosphere") then
        Lighting:FindFirstChild("Atmosphere").Density = 0
        Lighting:FindFirstChild("Atmosphere").Haze = 0
        Lighting:FindFirstChild("Atmosphere").Glare = 0
    end
    
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("ColorCorrectionEffect") then
            effect.Brightness = 1
        end
    end
end

local function disableFullBright()
    FullBrightEnabled = false
    Lighting.ExposureCompensation = OriginalBrightness
    Lighting.Ambient = OriginalAmbient
    
    if Lighting:FindFirstChild("Atmosphere") then
        Lighting:FindFirstChild("Atmosphere").Density = 0.35
        Lighting:FindFirstChild("Atmosphere").Haze = 0.5
        Lighting:FindFirstChild("Atmosphere").Glare = 0
    end
    
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("ColorCorrectionEffect") then
            effect.Brightness = 0
        end
    end
end

--======================================================================
--  INSTANT REVIVE
--======================================================================

local ReviveConnection = nil

local function enableInstantRevive()
    InstantReviveEnabled = true
    
    if ReviveConnection then ReviveConnection:Disconnect() end
    
    ReviveConnection = LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.1)
        if InstantReviveEnabled then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = humanoid.MaxHealth
            end
        end
    end)
end

local function disableInstantRevive()
    InstantReviveEnabled = false
    if ReviveConnection then
        ReviveConnection:Disconnect()
        ReviveConnection = nil
    end
end

--======================================================================
--  REVIVE AURA
--======================================================================

local AuraConnection = nil

local function enableReviveAura()
    ReviveAuraEnabled = true
    
    if AuraConnection then AuraConnection:Disconnect() end
    
    AuraConnection = RunService.Heartbeat:Connect(function()
        if not ReviveAuraEnabled then return end
        
        if not LocalPlayer.Character then return end
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local theirRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if theirRoot then
                    local dist = (myRoot.Position - theirRoot.Position).Magnitude
                    if dist <= 15 then
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            -- Revivir al jugador cercano
                            humanoid.Health = humanoid.MaxHealth
                        end
                    end
                end
            end
        end
    end)
end

local function disableReviveAura()
    ReviveAuraEnabled = false
    if AuraConnection then
        AuraConnection:Disconnect()
        AuraConnection = nil
    end
end

--======================================================================
--  AUTO CARRY
--======================================================================

local CarryConnection = nil
local currentCarry = nil

local function enableAutoCarry()
    AutoCarryEnabled = true
    
    if CarryConnection then CarryConnection:Disconnect() end
    
    CarryConnection = RunService.Heartbeat:Connect(function()
        if not AutoCarryEnabled then return end
        
        -- Buscar un jugador caído cercano
        if not LocalPlayer.Character then return end
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        
        local closestDowned = nil
        local closestDist = math.huge
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local theirRoot = player.Character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoid.Health > 0 and theirRoot then
                    local dist = (myRoot.Position - theirRoot.Position).Magnitude
                    
                    -- Verificar si está caído (en muchos juegos, cuando un jugador está caído,
                    -- su HumanoidStateType es "Ragdoll" o "Landed" con Health muy baja)
                    local isDowned = false
                    if humanoid.Health <= 1 or 
                       (humanoid:GetState() == Enum.HumanoidStateType.Ragdoll) or
                       (humanoid:GetState() == Enum.HumanoidStateType.Physics) or
                       (humanoid:GetState() == Enum.HumanoidStateType.FallingDown) then
                        isDowned = true
                    end
                    
                    -- También buscar si tiene un BodyVelocity o BodyGyro (indicador de estar caído en algunos juegos)
                    if player.Character:FindFirstChild("Downed") or 
                       player.Character:FindFirstChild("Stunned") then
                        isDowned = true
                    end
                    
                    if isDowned and dist < closestDist then
                        closestDist = dist
                        closestDowned = {Player = player, Root = theirRoot}
                    end
                end
            end
        end
        
        if closestDowned and closestDist <= 20 then
            -- Caminar hacia el jugador caído
            local myHumanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHumanoid and myHumanoid.Health > 0 then
                myHumanoid:MoveTo(closestDowned.Root.Position)
            end
        end
    end)
end

local function disableAutoCarry()
    AutoCarryEnabled = false
    if CarryConnection then
        CarryConnection:Disconnect()
        CarryConnection = nil
    end
    currentCarry = nil
end

--======================================================================
--  CREAR LA UI CON YIN-YANG v22
--======================================================================

print("🎮 Yin Yang v22 - Script Final Cargado...")

local UI = YinYang:CreateWindow("Yin Yang", "DarkV2")

--// TAB: ESP PLAYERS
local TabESP = UI:CreateTab("ESP")
TabESP:CreateLabel("⚡ ESP Player", 16)
TabESP:CreateDivider()

TabESP:CreateToggle("Activar ESP", false, function(state)
    if state then
        enableESP()
        print("✅ ESP Activado")
    else
        disableESP()
        print("❌ ESP Desactivado")
    end
end)

--// TAB: MOVIMIENTO
local TabMove = UI:CreateTab("Movimiento")
TabMove:CreateLabel("🏃 Movimiento", 16)
TabMove:CreateDivider()

-- Jump Power
TabMove:CreateToggle("Enable Jump Power", false, function(state)
    if state then
        enableJumpPower()
        print("✅ Jump Power Activado: " .. JumpPowerValue)
    else
        disableJumpPower()
        print("❌ Jump Power Desactivado")
    end
end)

TabMove:CreateDivider()
TabMove:CreateLabel("Opciones:", 13)

-- (Nota: la librería v22 no tiene slider, así que usamos botones para ajustar)
TabMove:CreateButton("Jump Power: +10", function()
    JumpPowerValue = math.min(JumpPowerValue + 10, 200)
    print("🔼 Jump Power: " .. JumpPowerValue)
    if JumpPowerEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = JumpPowerValue
            humanoid.UseJumpPower = true
        end
    end
end)

TabMove:CreateButton("Jump Power: -10", function()
    JumpPowerValue = math.max(JumpPowerValue - 10, 0)
    print("🔽 Jump Power: " .. JumpPowerValue)
    if JumpPowerEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = JumpPowerValue
            humanoid.UseJumpPower = true
        end
    end
end)

TabMove:CreateButton("Jump Power: Reset (50)", function()
    JumpPowerValue = 50
    print("🔄 Jump Power reseteado a 50")
    if JumpPowerEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
            humanoid.UseJumpPower = true
        end
    end
end)

TabMove:CreateLabel("Jump Power actual: " .. JumpPowerValue, 12)

TabMove:CreateDivider()

-- Teleport Walk Speed
TabMove:CreateToggle("Enable Teleport Walk", false, function(state)
    if state then
        enableTeleportWalk()
        print("✅ Teleport Walk Activado: " .. TeleportWalkValue)
    else
        disableTeleportWalk()
        print("❌ Teleport Walk Desactivado")
    end
end)

TabMove:CreateButton("Walk Speed: +10", function()
    TeleportWalkValue = math.min(TeleportWalkValue + 10, 200)
    print("🔼 Walk Speed: " .. TeleportWalkValue)
    if TeleportWalkEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = TeleportWalkValue
        end
    end
end)

TabMove:CreateButton("Walk Speed: -10", function()
    TeleportWalkValue = math.max(TeleportWalkValue - 10, 16)
    print("🔽 Walk Speed: " .. TeleportWalkValue)
    if TeleportWalkEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = TeleportWalkValue
        end
    end
end)

TabMove:CreateButton("Walk Speed: Reset (50)", function()
    TeleportWalkValue = 50
    print("🔄 Walk Speed reseteado a 50")
    if TeleportWalkEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 50
        end
    end
end)

TabMove:CreateLabel("Walk Speed actual: " .. TeleportWalkValue, 12)

--// TAB: VISUAL
local TabVisual = UI:CreateTab("Visual")
TabVisual:CreateLabel("👁️ Efectos Visuales", 16)
TabVisual:CreateDivider()

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
local TabRevive = UI:CreateTab("Revive")
TabRevive:CreateLabel("💀 Sistema de Revive", 16)
TabRevive:CreateDivider()

TabRevive:CreateToggle("Instant Revive", false, function(state)
    if state then
        enableInstantRevive()
        print("✅ Instant Revive Activado")
    else
        disableInstantRevive()
        print("❌ Instant Revive Desactivado")
    end
end)

TabRevive:CreateDivider()

TabRevive:CreateToggle("Revive Aura (15 studs)", false, function(state)
    if state then
        enableReviveAura()
        print("✅ Revive Aura Activado")
    else
        disableReviveAura()
        print("❌ Revive Aura Desactivado")
    end
end)

TabRevive:CreateDivider()

TabRevive:CreateToggle("Auto Carry", false, function(state)
    if state then
        enableAutoCarry()
        print("✅ Auto Carry Activado")
    else
        disableAutoCarry()
        print("❌ Auto Carry Desactivado")
    end
end)

TabRevive:CreateDivider()
TabRevive:CreateLabel("📝 Notas:\n• Instant Revive: Te revive al instante al caer\n• Revive Aura: Revive jugadores en un radio de 15 studs\n• Auto Carry: Camina automáticamente hacia jugadores caídos\n  cercanos para cargarlos", 11)

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

print("✅ Yin Yang v22 - ¡Script listo!")
print("   Tabs: ESP | Movimiento | Visual | Revive | Ajustes")
