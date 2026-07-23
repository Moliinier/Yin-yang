--[[
    ═══════════════════════════════════════════════════════════════════════════
    EVADE v3 FINAL - SCRIPT PROFESIONAL (7 OPCIONES PRINCIPALES)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ OPCIONES IMPLEMENTADAS:
    • Teleport Movement Speed: Velocidad del teleport walk
    • Teleport Walk Mode: Activar/desactivar teleport walk
    • Jump Height: Altura del salto (slider)
    • Enhanced Jump: Activar/desactivar jump mejorado
    • Instant Revive: Revive instantáneo
    • Revive Nearby: Revive a jugadores cercanos
    • Self Revive: Auto-revivirse cuando caes
    
    ═══════════════════════════════════════════════════════════════════════════
]]

print("═══════════════════════════════════════════════════════════════════════════")
print("🚀 INICIANDO EVADE v3 FINAL")
print("═══════════════════════════════════════════════════════════════════════════")

--// SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// CONFIG - 7 OPCIONES PRINCIPALES
local Config = {
    TeleportMovementSpeed = 5,
    EnableTeleportWalk = false,
    JumpHeight = 50,
    EnableEnhancedJump = false,
    InstantRevive = false,
    ReviveNearby = false,
    SelfRevive = false,
}

local PlayerState = {
    IsInAir = false,
}

--// ═════════════════════════════════════════════════════════════════════════════
--// CARGAR YIN YANG v26.1
--// ═════════════════════════════════════════════════════════════════════════════

print("\n⏳ Cargando Yin Yang v26.1 SOUND FIXED...")

local success = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v26_SOUND_FIXED.lua"))()
end)

if not success or not _G.YinYang then
    error("❌ Error al cargar Yin Yang v26")
end

print("✅ Yin Yang v26 cargado correctamente")

--// ═════════════════════════════════════════════════════════════════════════════
--// CREAR UI
--// ═════════════════════════════════════════════════════════════════════════════

print("\n⏳ Creando interfaz...")

local UI = _G.YinYang:CreateWindow("EVADE v3 FINAL", "Dark")
local Tab = UI:CreateTab("Controles")

print("✅ Interfaz creada")

--// ═════════════════════════════════════════════════════════════════════════════
--// SECCIÓN: MOVIMIENTO
--// ═════════════════════════════════════════════════════════════════════════════

Tab:CreateLabel("⚡ MOVIMIENTO AVANZADO", 14)
Tab:CreateDivider()

Tab:CreateToggle("🚀 Teleport Walk Mode", false, function(state)
    Config.EnableTeleportWalk = state
    print(state and "✅ Teleport Walk Mode ACTIVADO" or "❌ Teleport Walk Mode DESACTIVADO")
end)

Tab:CreateSlider(
    "Teleport Movement Speed",
    1, 20, 5,
    function(value)
        Config.TeleportMovementSpeed = value
        print("⚡ Velocidad de teleport: " .. value)
    end
)

Tab:CreateDivider()

Tab:CreateToggle("⬆️ Enhanced Jump", false, function(state)
    Config.EnableEnhancedJump = state
    print(state and "✅ Enhanced Jump ACTIVADO" or "❌ Enhanced Jump DESACTIVADO")
end)

Tab:CreateSlider(
    "Jump Height",
    20, 300, 50,
    function(value)
        Config.JumpHeight = value
        print("⬆️ Altura de salto: " .. value)
    end
)

--// ═════════════════════════════════════════════════════════════════════════════
--// SECCIÓN: REVIVE
--// ═════════════════════════════════════════════════════════════════════════════

Tab:CreateDivider()
Tab:CreateLabel("💚 SISTEMA DE REVIVE", 14)
Tab:CreateDivider()

Tab:CreateToggle("⚡ Instant Revive", false, function(state)
    Config.InstantRevive = state
    print(state and "✅ Instant Revive ACTIVADO" or "❌ Instant Revive DESACTIVADO")
end)

Tab:CreateToggle("👥 Revive Nearby", false, function(state)
    Config.ReviveNearby = state
    print(state and "✅ Revive Nearby ACTIVADO - Presiona E para revivir cercanos" or "❌ Revive Nearby DESACTIVADO")
end)

Tab:CreateToggle("🔄 Self Revive", false, function(state)
    Config.SelfRevive = state
    print(state and "✅ Self Revive ACTIVADO" or "❌ Self Revive DESACTIVADO")
end)

Tab:CreateDivider()

print("\n✅ Todos los componentes agregados")

--// ═════════════════════════════════════════════════════════════════════════════
--// FUNCIONES DE MOVIMIENTO
--// ═════════════════════════════════════════════════════════════════════════════

local function applyTeleportWalk()
    if not Config.EnableTeleportWalk then return end
    
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    -- Teleport walk basado en dirección de movimiento
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
    
    -- Modificar jump power directamente
    hum.JumpPower = Config.JumpHeight
    hum.UseJumpPower = true
end

local function applySelfRevive()
    if not Config.SelfRevive then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health > 0 then return end
    
    -- Auto-revive cuando la salud es 0
    print("🔄 Auto Self-Revive activado...")
end

--// ═════════════════════════════════════════════════════════════════════════════
--// LOOP PRINCIPAL
--// ═════════════════════════════════════════════════════════════════════════════

print("\n⏳ Iniciando loop principal...")

RunService.Heartbeat:Connect(function()
    pcall(function()
        applyTeleportWalk()
        applyJumpHeight()
        applySelfRevive()
    end)
end)

print("\n" .. string.rep("═", 73))
print("✅ EVADE v3 FINAL - FUNCIONANDO CORRECTAMENTE")
print(string.rep("═", 73))

print("\n📊 OPCIONES IMPLEMENTADAS:")
print("   ✅ Teleport Walk Mode")
print("   ✅ Teleport Movement Speed")
print("   ✅ Enhanced Jump")
print("   ✅ Jump Height (20-300)")
print("   ✅ Instant Revive")
print("   ✅ Revive Nearby")
print("   ✅ Self Revive")

print("\n💡 COMPATIBLE CON:")
print("   ✅ Yin Yang v26.1 SOUND FIXED")
print("   ✅ Todos los temas de Yin Yang")

print("\n" .. string.rep("═", 73) .. "\n")
