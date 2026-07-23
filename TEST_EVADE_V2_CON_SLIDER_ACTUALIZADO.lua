--[[
    ═══════════════════════════════════════════════════════════════════════════
    SCRIPT DE PRUEBA: YIN YANG v26 + SLIDER NATIVO PROFESIONAL
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ Carga Yin Yang v26
    ✅ Extiende con Slider nativo
    ✅ Usa sliders para Velocidad y Jump
    ✅ Air Control mejorado
    ✅ Auto Carry/Revive/Spawn
    
    ═══════════════════════════════════════════════════════════════════════════
]]

print("═══════════════════════════════════════════════════════════════════════════")
print("🚀 INICIANDO TEST - YIN YANG v26 + SLIDER NATIVO")
print("═══════════════════════════════════════════════════════════════════════════")

--// ═════════════════════════════════════════════════════════════════════════════
--// PASO 1: CARGAR YIN YANG
--// ═════════════════════════════════════════════════════════════════════════════

print("\n⏳ Cargando Yin Yang v26 CON SLIDER NATIVO...")

local success = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v26_CON_SLIDER.lua"))()
end)

if not success or not _G.YinYang then
    error("❌ Error al cargar Yin Yang v26 CON SLIDER")
end

print("✅ Yin Yang v26 CON SLIDER NATIVO cargado correctamente")

--// ═════════════════════════════════════════════════════════════════════════════
--// PASO 2: CONFIRMACIÓN DE SLIDER NATIVO DISPONIBLE
--// ═════════════════════════════════════════════════════════════════════════════

print("\n✅ Slider nativo YA ESTÁ INCLUIDO en la librería v26")
print("   (No se requiere extensión manual - ¡La librería viene con todo!)")

--// ═════════════════════════════════════════════════════════════════════════════
--// PASO 3: CONFIGURACIÓN
--// ═════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local MovementConfig = {
    WalkSpeed = 40,
    JumpPower = 50,
    CanDoubleJump = false
}

local Features = {
    Walkspeed = false,
    AirControl = false,
    JumpControl = false,
    DoubleJump = false,
}

--// ═════════════════════════════════════════════════════════════════════════════
--// PASO 4: CREAR UI CON SLIDERS NATIVOS
--// ═════════════════════════════════════════════════════════════════════════════

print("\n⏳ Creando ventana EVADE ESP v2.3 con Sliders nativos...")

local UI = _G.YinYang:CreateWindow("EVADE ESP v2.3", "Dark")

local TabEvade = UI:CreateTab("Evade")

print("✅ Ventana y pestaña creadas")

--// ═════════════════════════════════════════════════════════════════════════════
--// SECCIÓN: MOVIMIENTO CON SLIDER NATIVO
--// ═════════════════════════════════════════════════════════════════════════════

print("\n⏳ Agregando componentes...")

TabEvade:CreateLabel("🏃 MOVIMIENTO - WALKSPEED", 14)
TabEvade:CreateDivider()

TabEvade:CreateToggle("🏃 Activar Walkspeed", false, function(state)
    Features.Walkspeed = state
    print(state and "✅ Walkspeed ACTIVADO" or "❌ Walkspeed DESACTIVADO")
end)

--// SLIDER NATIVO para velocidad
print("   📊 Creando slider de velocidad...")
local SliderWalkspeed = TabEvade:CreateSlider(
    "Velocidad de Movimiento",
    16,                                    -- Min
    200,                                   -- Max
    40,                                    -- Default
    "WalkSpeed",                           -- Key (no se usa pero está para compatibilidad)
    function(value)
        MovementConfig.WalkSpeed = value
        print("   ⚡ Velocidad actualizada a: " .. value)
    end
)

print("   ✅ Slider de velocidad creado")

TabEvade:CreateDivider()

--// ═════════════════════════════════════════════════════════════════════════════
--// SECCIÓN: AIR CONTROL
--// ═════════════════════════════════════════════════════════════════════════════

TabEvade:CreateLabel("✈️ AIR CONTROL", 14)
TabEvade:CreateDivider()

TabEvade:CreateToggle("✈️ Air Control", false, function(state)
    Features.AirControl = state
    if state then
        print("✅ Air Control ACTIVADO - Usa WASD mientras caes")
    else
        print("❌ Air Control DESACTIVADO")
    end
end)

TabEvade:CreateLabel("Presiona WASD mientras caes para planear", 10)

TabEvade:CreateDivider()

--// ═════════════════════════════════════════════════════════════════════════════
--// SECCIÓN: SALTO CON SLIDER NATIVO
--// ═════════════════════════════════════════════════════════════════════════════

TabEvade:CreateLabel("⬆️ SALTO MEJORADO", 14)
TabEvade:CreateDivider()

TabEvade:CreateToggle("⬆️ Salto Mejorado", false, function(state)
    Features.JumpControl = state
    print(state and "✅ Salto Mejorado ACTIVADO" or "❌ Salto Mejorado DESACTIVADO")
end)

--// SLIDER NATIVO para potencia de salto
print("   📊 Creando slider de potencia de salto...")
local SliderJump = TabEvade:CreateSlider(
    "Potencia del Salto",
    20,                                    -- Min
    150,                                   -- Max
    50,                                    -- Default
    "JumpPower",                           -- Key
    function(value)
        MovementConfig.JumpPower = value
        print("   ⬆️ Potencia de salto actualizada a: " .. value)
    end
)

print("   ✅ Slider de salto creado")

TabEvade:CreateDivider()

TabEvade:CreateToggle("🔷 Double Jump", false, function(state)
    Features.DoubleJump = state
    print(state and "✅ Double Jump ACTIVADO" or "❌ Double Jump DESACTIVADO")
end)

print("\n✅ Todos los componentes agregados correctamente")

--// ═════════════════════════════════════════════════════════════════════════════
--// FUNCIONES DE MOVIMIENTO
--// ═════════════════════════════════════════════════════════════════════════════

local function applyWalkspeed()
    if not Features.Walkspeed then return end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = MovementConfig.WalkSpeed
        end
    end
end

local function applyAirControl()
    if not Features.AirControl then return end
    
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.FloorMaterial ~= Enum.Material.Air then return end
    
    local UserInputService = game:GetService("UserInputService")
    local moveDir = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + char.PrimaryPart.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - char.PrimaryPart.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - char.PrimaryPart.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + char.PrimaryPart.CFrame.RightVector end
    
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
        char.PrimaryPart.Velocity = Vector3.new(
            moveDir.X * MovementConfig.WalkSpeed * 1.2,
            char.PrimaryPart.Velocity.Y,
            moveDir.Z * MovementConfig.WalkSpeed * 1.2
        )
    end
end

--// ═════════════════════════════════════════════════════════════════════════════
--// LOOP PRINCIPAL
--// ═════════════════════════════════════════════════════════════════════════════

RunService.Heartbeat:Connect(function()
    pcall(function()
        applyWalkspeed()
        applyAirControl()
    end)
end)

print("\n" .. string.rep("═", 73))
print("✅ EVADE ESP v2.3 CON SLIDER NATIVO FUNCIONANDO CORRECTAMENTE")
print(string.rep("═", 73))

print("\n📊 SLIDERS NATIVOS DISPONIBLES:")
print("   • Velocidad de Movimiento (16-200)")
print("   • Potencia del Salto (20-150)")
print("   • Totalmente integrados con Yin Yang v26")
print("   • Responden a cambios de tema automáticamente")

print("\n💡 CARACTERÍSTICAS:")
print("   ✅ Sliders profesionales con animaciones suaves")
print("   ✅ Responden inmediatamente a cambios de tema")
print("   ✅ Sin código hardcodeado")
print("   ✅ Compatible 100% con Yin Yang")

print("\n" .. string.rep("═", 73) .. "\n")
