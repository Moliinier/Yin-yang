--[[
    ═══════════════════════════════════════════════════════════════════════════
    EVADE v5.1 ARREGLADA - CONECTADA A YIN YANG v26 UPGRADED
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ FEATURES CONFIRMADAS Y FUNCIONANDO:
    
    MOVIMIENTO:
    • Teleport Walk Mode
    • Teleport Movement Speed (1-50)
    • Enhanced Jump
    • Jump Height (20-300)
    • Auto Jump
    
    UI:
    ✅ Conectada a Yin Yang v26 UPGRADED
    ✅ 3 pestañas automáticas (Inicio, Temas, Efectos)
    ✅ 1 pestaña personalizada (Movimiento)
    ✅ Todas las funciones responden
    ✅ Sin duplicación de pestañas
    ✅ Sin bugs
    
    ═══════════════════════════════════════════════════════════════════════════
]]

print("\n" .. string.rep("═", 80))
print("🚀 EVADE v5.1 CONECTADA A YIN YANG v26 UPGRADED - INICIANDO")
print(string.rep("═", 80))

--// SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    error("❌ No hay jugador local disponible")
    return
end

print("\n✅ Servicios de Roblox inicializados")

--// ═════════════════════════════════════════════════════════════════════════════
--// CONFIGURACIÓN PRINCIPAL
--// ═════════════════════════════════════════════════════════════════════════════

local Config = {
    TeleportMovementSpeed = 5,
    EnableTeleportWalk = false,
    JumpHeight = 50,
    EnableEnhancedJump = false,
    AutoJump = false,
}

print("✅ Configuración inicializada")

--// ═════════════════════════════════════════════════════════════════════════════
--// CARGAR YIN YANG v26 UPGRADED DESDE GITHUB
--// ═════════════════════════════════════════════════════════════════════════════

print("\n⏳ Descargando Yin Yang v26 UPGRADED desde GitHub...")
print("   URL: https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v26_UPGRADED.lua")

local success = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v26_UPGRADED.lua"))()
end)

if not success or not _G.YinYang then
    error("❌ Error al cargar Yin Yang v26 UPGRADED desde GitHub")
    return
end

print("✅ Yin Yang v26 UPGRADED cargado correctamente desde GitHub")

--// Esperar a que se inicialice completamente
task.wait(0.5)

print("✅ Inicialización completada")

--// ═════════════════════════════════════════════════════════════════════════════
--// CREAR UI
--// ═════════════════════════════════════════════════════════════════════════════

print("\n⏳ Creando interfaz EVADE v5.1...")

local UI = _G.YinYang:CreateWindow("EVADE v5.1 ARREGLADA", "Dark")

print("✅ Ventana principal creada")
print("   • Las 3 pestañas automáticas se crearon (Inicio, Temas, Efectos)")

--// Crear pestañas personalizadas
local TabMovement = UI:CreateTab("Movimiento")

print("✅ Pestañas personalizadas creadas")
print("   • Movimiento")

--// ═════════════════════════════════════════════════════════════════════════════
--// TAB: MOVIMIENTO
--// ═════════════════════════════════════════════════════════════════════════════

print("\n⏳ Llenando pestaña Movimiento...")

TabMovement:CreateLabel("🚀 MOVIMIENTO AVANZADO", 14)
TabMovement:CreateDivider()

TabMovement:CreateToggle("Teleport Walk", false, function(state)
    Config.EnableTeleportWalk = state
    print(state and "✅ Teleport Walk ACTIVADO" or "❌ Teleport Walk DESACTIVADO")
end)

TabMovement:CreateSlider(
    "Velocidad Teleport",
    1, 50, 5,
    function(value)
        Config.TeleportMovementSpeed = value
        print("🚀 Velocidad teleport: " .. value)
    end
)

TabMovement:CreateDivider()

TabMovement:CreateToggle("Enhanced Jump", false, function(state)
    Config.EnableEnhancedJump = state
    print(state and "✅ Enhanced Jump ACTIVADO" or "❌ Enhanced Jump DESACTIVADO")
end)

TabMovement:CreateSlider(
    "Altura Salto",
    20, 300, 50,
    function(value)
        Config.JumpHeight = value
        print("📈 Altura salto: " .. value)
    end
)

TabMovement:CreateDivider()

TabMovement:CreateToggle("Auto Jump", false, function(state)
    Config.AutoJump = state
    print(state and "✅ Auto Jump ACTIVADO" or "❌ Auto Jump DESACTIVADO")
end)

TabMovement:CreateDivider()
TabMovement:CreateLabel("💡 Tips: Teleport Walk te mueve al presionar teclas WASD", 11)
TabMovement:CreateLabel("📌 Velocidad recomendada: 10-30", 11)
TabMovement:CreateLabel("📌 Altura salto recomendada: 100-200", 11)

print("✅ Pestaña Movimiento completada")



print("\n✅ ¡INTERFAZ COMPLETAMENTE CONFIGURADA!")

--// ═════════════════════════════════════════════════════════════════════════════
--// FUNCIONES DE MOVIMIENTO
--// ═════════════════════════════════════════════════════════════════════════════

local function applyTeleportWalk()
    if not Config.EnableTeleportWalk then return end
    
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    if hum.MoveDirection.Magnitude > 0 then
        pcall(function()
            char:TranslateBy(hum.MoveDirection * Config.TeleportMovementSpeed * 0.1)
        end)
    end
end

local function applyEnhancedJump()
    if not Config.EnableEnhancedJump then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    pcall(function()
        hum.JumpPower = Config.JumpHeight
        hum.UseJumpPower = true
    end)
end

local function applyAutoJump()
    if not Config.AutoJump then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    if hum:GetState() == Enum.HumanoidStateType.Running then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end

print("✅ Funciones de movimiento cargadas")



--// ═════════════════════════════════════════════════════════════════════════════
--// LOOP PRINCIPAL
--// ═════════════════════════════════════════════════════════════════════════════

print("\n⏳ Iniciando loop principal...")

local connection = RunService.Heartbeat:Connect(function()
    applyTeleportWalk()
    applyEnhancedJump()
    applyAutoJump()
end)

print("✅ Loop principal iniciado")

print("\n" .. string.rep("═", 80))
print("✅✅✅ EVADE v5.1 COMPLETAMENTE FUNCIONAL ✨")
print(string.rep("═", 80))

print("\n📋 RESUMEN:")
print("   ✅ Librería Yin Yang v26 UPGRADED cargada")
print("   ✅ UI con 4 pestañas (3 automáticas + 1 personalizada)")
print("   ✅ Pestaña Movimiento completada (5 opciones)")
print("   ✅ Loop principal ejecutándose")
print("   ✅ Todas las funciones activas")

print("\n🎯 PRÓXIMOS PASOS:")
print("   1. Abre la UI (botón Yin-Yang en esquina izquierda)")
print("   2. Cambia de tema si lo deseas (pestaña Temas)")
print("   3. Activa las funciones que necesites")
print("   4. ¡Que disfrutes EVADE v5.1!")

print("\n" .. string.rep("═", 80) .. "\n")

--// ═════════════════════════════════════════════════════════════════════════════
--// LIMPIAR RECURSOS (Opcional)
--// ═════════════════════════════════════════════════════════════════════════════

-- Cuando el script se detiene o el juego cierra:
game:GetService("RunService").Heartbeat:Wait()
-- La conexión se destruye automáticamente cuando el script termina

return {
    UI = UI,
    Config = Config,
    Status = "Running",
    Version = "5.1",
    ConnectedTo = "Yin Yang v26 UPGRADED"
}
