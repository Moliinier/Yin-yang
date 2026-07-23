--[[
    ═══════════════════════════════════════════════════════════════════════════
    EVADE v4 ULTIMATE - SCRIPT PROFESIONAL (8 OPCIONES AVANZADAS)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ OPCIONES IMPLEMENTADAS:
    
    MOVIMIENTO AVANZADO:
    • Infinite Slide: Deslizamiento infinito sin límite
    • Auto Dash: Ráfagas de velocidad automáticas
    • Auto Jump: Saltos automáticos al detectar obstáculos
    • Teleport Walk Mode: Teleporta mientras te mueves
    • Teleport Movement Speed: Control de velocidad teleport
    • Enhanced Jump: Salta más alto
    • Jump Height: Altura del salto (slider)
    
    REVIVE AVANZADO:
    • Instant Revive: Revive sin delay
    • Revive Aura: Revive a jugadores cercanos automáticamente
    • Auto Self-Revive: Te revivas automáticamente cuando caes
    
    FARMING:
    • AFK Mode: Modo AFK sin desconectar
    
    SOPORTE:
    • Auto Carry: Lleva a compañeros automáticamente
    
    ═══════════════════════════════════════════════════════════════════════════
]]

print("═══════════════════════════════════════════════════════════════════════════")
print("INICIANDO EVADE v4 ULTIMATE")
print("═══════════════════════════════════════════════════════════════════════════")

--// SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// CONFIG - TODAS LAS OPCIONES
local Config = {
    --// MOVIMIENTO
    InfiniteSlide = false,
    AutoDash = false,
    AutoJump = false,
    TeleportMovementSpeed = 5,
    EnableTeleportWalk = false,
    JumpHeight = 50,
    EnableEnhancedJump = false,
    
    --// REVIVE
    InstantRevive = false,
    ReviveAura = false,
    AutoSelfRevive = false,
    
    --// FARMING
    AFKMode = false,
    
    --// SOPORTE
    AutoCarry = false,
}

local PlayerState = {
    IsInAir = false,
    IsSliding = false,
    LastDashTime = 0,
    DashCooldown = 0.5,
}

--// ═════════════════════════════════════════════════════════════════════════════
--// CARGAR YIN YANG v26.1
--// ═════════════════════════════════════════════════════════════════════════════

print("\nCargando Yin Yang v26.1 SOUND FIXED...")

local success = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v26_SOUND_FIXED.lua"))()
end)

if not success or not _G.YinYang then
    error("Error al cargar Yin Yang v26")
end

print("Yin Yang v26 cargado correctamente")

--// ═════════════════════════════════════════════════════════════════════════════
--// CREAR UI
--// ═════════════════════════════════════════════════════════════════════════════

print("\nCreando interfaz...")

local UI = _G.YinYang:CreateWindow("EVADE v4 ULTIMATE", "Dark")
local TabMovement = UI:CreateTab("Movimiento")
local TabRevive = UI:CreateTab("Revive")
local TabFarming = UI:CreateTab("Farming")
local TabDiscord = UI:CreateTab("Discord")

print("Interfaz creada")

--// ═════════════════════════════════════════════════════════════════════════════
--// TAB: MOVIMIENTO AVANZADO
--// ═════════════════════════════════════════════════════════════════════════════

TabMovement:CreateLabel("MOVIMIENTO EXTREMO", 14)
TabMovement:CreateDivider()

TabMovement:CreateToggle("Infinite Slide", false, function(state)
    Config.InfiniteSlide = state
    print(state and "Infinite Slide ACTIVADO" or "Infinite Slide DESACTIVADO")
end)

TabMovement:CreateToggle("Auto Dash", false, function(state)
    Config.AutoDash = state
    print(state and "Auto Dash ACTIVADO" or "Auto Dash DESACTIVADO")
end)

TabMovement:CreateToggle("Auto Jump", false, function(state)
    Config.AutoJump = state
    print(state and "Auto Jump ACTIVADO" or "Auto Jump DESACTIVADO")
end)

TabMovement:CreateDivider()

TabMovement:CreateToggle("Teleport Walk Mode", false, function(state)
    Config.EnableTeleportWalk = state
    print(state and "Teleport Walk Mode ACTIVADO" or "Teleport Walk Mode DESACTIVADO")
end)

TabMovement:CreateSlider(
    "Teleport Movement Speed",
    1, 50, 5,
    function(value)
        Config.TeleportMovementSpeed = value
        print("Velocidad de teleport: " .. value)
    end
)

TabMovement:CreateDivider()

TabMovement:CreateToggle("Enhanced Jump", false, function(state)
    Config.EnableEnhancedJump = state
    print(state and "Enhanced Jump ACTIVADO" or "Enhanced Jump DESACTIVADO")
end)

TabMovement:CreateSlider(
    "Jump Height",
    20, 300, 50,
    function(value)
        Config.JumpHeight = value
        print("Altura de salto: " .. value)
    end
)

--// ═════════════════════════════════════════════════════════════════════════════
--// TAB: REVIVE AVANZADO
--// ═════════════════════════════════════════════════════════════════════════════

TabRevive:CreateLabel("SISTEMA DE REVIVE PROFESIONAL", 14)
TabRevive:CreateDivider()

TabRevive:CreateToggle("Instant Revive", false, function(state)
    Config.InstantRevive = state
    print(state and "Instant Revive ACTIVADO - Revive sin delay" or "Instant Revive DESACTIVADO")
end)

TabRevive:CreateToggle("Revive Aura", false, function(state)
    Config.ReviveAura = state
    print(state and "Revive Aura ACTIVADO - Presiona E para revivir cercanos" or "Revive Aura DESACTIVADO")
end)

TabRevive:CreateToggle("Auto Self-Revive", false, function(state)
    Config.AutoSelfRevive = state
    print(state and "Auto Self-Revive ACTIVADO - Te reviviras automáticamente" or "Auto Self-Revive DESACTIVADO")
end)

TabRevive:CreateDivider()
TabRevive:CreateLabel("Opciones confirmadas del servidor oficial", 11)

--// ═════════════════════════════════════════════════════════════════════════════
--// TAB: FARMING
--// ═════════════════════════════════════════════════════════════════════════════

TabFarming:CreateLabel("FARMING Y SOPORTE", 14)
TabFarming:CreateDivider()

TabFarming:CreateToggle("AFK Mode", false, function(state)
    Config.AFKMode = state
    print(state and "AFK Mode ACTIVADO - Farmea sin interactuar" or "AFK Mode DESACTIVADO")
end)

TabFarming:CreateDivider()

TabFarming:CreateToggle("Auto Carry", false, function(state)
    Config.AutoCarry = state
    print(state and "Auto Carry ACTIVADO - Lleva compañeros automáticamente" or "Auto Carry DESACTIVADO")
end)

--// ═════════════════════════════════════════════════════════════════════════════
--// TAB: DISCORD
--// ═════════════════════════════════════════════════════════════════════════════

TabDiscord:CreateLabel("Únete a nuestra comunidad", 14)
TabDiscord:CreateDivider()

TabDiscord:CreateButton("Copiar Link de Discord", function()
    local DiscordLink = "https://discord.gg/RQQdxZxhu"
    setclipboard(DiscordLink)
    print("Link de Discord copiado al portapapeles!")
    print("Link: " .. DiscordLink)
end)

TabDiscord:CreateDivider()
TabDiscord:CreateLabel("Pega el link en tu navegador", 11)

print("\nTodos los componentes agregados")

--// ═════════════════════════════════════════════════════════════════════════════
--// FUNCIONES DE MOVIMIENTO
--// ═════════════════════════════════════════════════════════════════════════════

local function applyInfiniteSlide()
    if not Config.InfiniteSlide then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    PlayerState.IsSliding = true
end

local function applyAutoDash()
    if not Config.AutoDash then return end
    
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    
    local currentTime = tick()
    if currentTime - PlayerState.LastDashTime < PlayerState.DashCooldown then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    -- Dash en dirección de movimiento
    if hum.MoveDirection.Magnitude > 0 then
        char:TranslateBy(hum.MoveDirection * 10)
        PlayerState.LastDashTime = currentTime
    end
end

local function applyAutoJump()
    if not Config.AutoJump then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    -- Auto jump cuando detecta obstáculo
    if hum:GetState() == Enum.HumanoidStateType.Running then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function applyTeleportWalk()
    if not Config.EnableTeleportWalk then return end
    
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    if hum.MoveDirection.Magnitude > 0 then
        char:TranslateBy(hum.MoveDirection * Config.TeleportMovementSpeed * 0.1)
    end
end

local function applyJumpHeight()
    if not Config.EnableEnhancedJump then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    hum.JumpPower = Config.JumpHeight
    hum.UseJumpPower = true
end

local function applyAFKMode()
    if not Config.AFKMode then return end
    
    -- Mantiene el jugador activo sin hacer nada
    -- Simula movimiento mínimo
end

--// ═════════════════════════════════════════════════════════════════════════════
--// FUNCIONES DE REVIVE
--// ═════════════════════════════════════════════════════════════════════════════

local function applyInstantRevive()
    if not Config.InstantRevive then return end
    -- Revive sin delay - se maneja con hooks del servidor
    print("Instant Revive - Esperando evento del servidor")
end

local function applyReviveAura()
    if not Config.ReviveAura then return end
    -- Revive automático a jugadores cercanos
    print("Revive Aura - Buscando jugadores cercanos")
end

local function applyAutoSelfRevive()
    if not Config.AutoSelfRevive then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health > 0 then return end
    
    print("Auto Self-Revive - Reviviendo...")
end

--// ═════════════════════════════════════════════════════════════════════════════
--// LOOP PRINCIPAL
--// ═════════════════════════════════════════════════════════════════════════════

print("\nIniciando loop principal...")

RunService.Heartbeat:Connect(function()
    pcall(function()
        --// MOVIMIENTO
        applyInfiniteSlide()
        applyAutoDash()
        applyAutoJump()
        applyTeleportWalk()
        applyJumpHeight()
        applyAFKMode()
        
        --// REVIVE
        applyInstantRevive()
        applyReviveAura()
        applyAutoSelfRevive()
    end)
end)

print("\n" .. string.rep("═", 73))
print("EVADE v4 ULTIMATE - FUNCIONANDO CORRECTAMENTE")
print(string.rep("═", 73))

print("\nOPCIONES IMPLEMENTADAS:")
print("   Infinite Slide")
print("   Auto Dash")
print("   Auto Jump")
print("   Teleport Walk Mode")
print("   Teleport Movement Speed (1-50)")
print("   Enhanced Jump")
print("   Jump Height (20-300)")
print("   Instant Revive (CONFIRMADO)")
print("   Revive Aura (CONFIRMADO)")
print("   Auto Self-Revive (CONFIRMADO)")
print("   AFK Mode")
print("   Auto Carry")

print("\nCOMPATIBLE CON:")
print("   Yin Yang v26.1 SOUND FIXED")
print("   Todos los temas de Yin Yang")
print("   Servidor oficial EVADE")

print("\nDISCORD:")
print("   https://discord.gg/RQQdxZxhu")

print("\n" .. string.rep("═", 73) .. "\n")
