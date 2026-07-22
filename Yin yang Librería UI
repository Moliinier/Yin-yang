# 📖 GUÍA OFICIAL DE DESARROLLADORES - YIN YANG UI v26

**Documentación Completa para Integración, Extensión y Uso Profesional**

---

## 📑 TABLA DE CONTENIDOS

1. [Inicio Rápido](#inicio-rápido)
2. [Estructura de la Librería](#estructura-de-la-librería)
3. [Cómo Crear Nuevas Pestañas](#cómo-crear-nuevas-pestañas)
4. [Componentes Disponibles](#componentes-disponibles)
5. [Las 3 Pestañas Sagradas - Información Crítica](#las-3-pestañas-sagradas---información-crítica)
6. [Ejemplos Prácticos](#ejemplos-prácticos)
7. [Mejores Prácticas](#mejores-prácticas)

---

# 🚀 INICIO RÁPIDO

## Paso 1: Cargar la Librería

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v26_PRODUCCION.lua"))()

-- La librería se carga en _G.YinYang
```

## Paso 2: Crear tu Primera UI

```lua
local YinYang = _G.YinYang
local UI = YinYang:CreateWindow("Mi Script v1.0", "Dark")
```

## Paso 3: Crear una Nueva Pestaña (La tuya)

```lua
local MiPestana = UI:CreateTab("Mi Pestaña")
MiPestana:CreateButton("Mi Botón", function()
    print("¡Hola desde Yin Yang!")
end)
```

## Paso 4: ¡Listo!

Tu UI ahora tiene:
- ✅ **Pestaña Inicio** (automática)
- ✅ **Pestaña Temas** (automática)
- ✅ **Pestaña Efectos** (automática)
- ✅ **Pestaña "Mi Pestaña"** (tu creación)

---

# 🏗️ ESTRUCTURA DE LA LIBRERÍA

## Flujo de Carga

```
1. Cargas la librería con loadstring()
   ↓
2. Se inicializa _G.YinYang
   ↓
3. Llamas a _G.YinYang:CreateWindow()
   ↓
4. Se crean AUTOMÁTICAMENTE:
   - TabInicio (con WelcomeCard + ServerInfoCard)
   - TabTemas (con 19 temas)
   - TabEfectos (con 5 efectos)
   ↓
5. Luego tú creas tus propias pestañas
```

## Jerarquía de Objetos

```
YinYang (Global)
  └─ CreateWindow("Nombre", "Tema")
      └─ Window
          ├─ TabInicio (SAGRADA)
          ├─ TabTemas (SAGRADA)
          ├─ TabEfectos (SAGRADA)
          ├─ TuPestana1
          ├─ TuPestana2
          └─ TuPestana3
```

---

# 📝 CÓMO CREAR NUEVAS PESTAÑAS

## Sintaxis Básica

```lua
local MiPestana = UI:CreateTab("Nombre de la Pestaña")
```

## Ejemplo Completo

```lua
local YinYang = _G.YinYang
local UI = YinYang:CreateWindow("Mi Script", "Dark")

-- Crear una pestaña personalizada
local TabEconomia = UI:CreateTab("Economia")

-- Agregar componentes
TabEconomia:CreateButton("Ganar Dinero", function()
    print("Ganaste 1000 monedas")
end)

TabEconomia:CreateToggle("Modo Infinito", false, function(state)
    if state then
        print("Modo Infinito ACTIVADO")
    else
        print("Modo Infinito DESACTIVADO")
    end
end)
```

## Convenciones de Nombres

```lua
-- ✅ BIEN: Nombres descriptivos
local TabEconomia = UI:CreateTab("Economia")
local TabCombate = UI:CreateTab("Combate")
local TabMagia = UI:CreateTab("Magia")

-- ❌ MAL: Nombres ambiguos o muy largos
local Tab1 = UI:CreateTab("Tab1")
local MuyCosasAquiQueNoSePuedenExpresarEnUnNombre = UI:CreateTab("...")
```

---

# 🎮 COMPONENTES DISPONIBLES

## 1. CreateButton

**Crea un botón que ejecuta una acción**

```lua
Tab:CreateButton("Nombre del Botón", function()
    -- Tu código aquí
    print("Botón presionado")
end)
```

### Ejemplo

```lua
local TabAcciones = UI:CreateTab("Acciones")

TabAcciones:CreateButton("Saludar", function()
    print("¡Hola, mundo!")
end)

TabAcciones:CreateButton("Cambiar Dinero", function()
    local player = game.Players.LocalPlayer
    print("Dinero: " .. player.leaderstats.Money.Value)
end)
```

---

## 2. CreateToggle

**Crea un interruptor ON/OFF que persiste su estado**

```lua
Tab:CreateToggle("Nombre del Toggle", false, function(state)
    -- state = true (activado) o false (desactivado)
    if state then
        print("Toggle ACTIVADO")
    else
        print("Toggle DESACTIVADO")
    end
end)
```

### Ejemplo

```lua
local TabFunciones = UI:CreateTab("Funciones")

local ESPActivado = false
TabFunciones:CreateToggle("Activar ESP", false, function(state)
    ESPActivado = state
    print("ESP: " .. (state and "ON" or "OFF"))
end)

TabFunciones:CreateToggle("Aimbot", false, function(state)
    print("Aimbot: " .. (state and "ON" or "OFF"))
end)
```

---

## 3. CreateFloatingToggle

**Crea un toggle que se puede desprender y mover libremente por la pantalla**

```lua
Tab:CreateFloatingToggle("Nombre", false, function(state)
    print("Estado: " .. (state and "ON" or "OFF"))
end)
```

### Ejemplo

```lua
local TabFlotantes = UI:CreateTab("Flotantes")

TabFlotantes:CreateFloatingToggle("Macro 1", false, function(state)
    print("Macro 1: " .. (state and "Ejecutando" or "Detenido"))
end)

TabFlotantes:CreateFloatingToggle("Macro 2", false, function(state)
    print("Macro 2: " .. (state and "Ejecutando" or "Detenido"))
end)
```

---

## 4. CreateDropdown

**Crea una lista desplegable de opciones**

```lua
Tab:CreateDropdown("Nombre", 
    {"Opcion 1", "Opcion 2", "Opcion 3"},  -- Opciones disponibles
    "Opcion 1",  -- Opción por defecto
    function(selected)
        print("Seleccionaste: " .. selected)
    end
)
```

### Ejemplo

```lua
local TabSeleccion = UI:CreateTab("Seleccion")

TabSeleccion:CreateDropdown("Elige un Personaje",
    {"Warrior", "Mage", "Archer", "Rogue"},
    "Warrior",
    function(selected)
        print("Personaje elegido: " .. selected)
    end
)
```

---

## 5. CreateMultiDropdown

**Crea una lista donde se pueden seleccionar múltiples opciones**

```lua
Tab:CreateMultiDropdown("Nombre",
    {"Opcion 1", "Opcion 2", "Opcion 3"},  -- Opciones disponibles
    {},  -- Opciones pre-seleccionadas (tabla vacía = ninguna)
    function(selected)
        -- selected es una tabla con las opciones seleccionadas
        for _, item in ipairs(selected) do
            print("Seleccionaste: " .. item)
        end
    end
)
```

### Ejemplo

```lua
local TabMulti = UI:CreateTab("Multi")

TabMulti:CreateMultiDropdown("Elige Habilidades",
    {"Fuego", "Hielo", "Rayo", "Viento"},
    {},
    function(selected)
        if #selected > 0 then
            print("Habilidades: " .. table.concat(selected, ", "))
        else
            print("Sin habilidades seleccionadas")
        end
    end
)
```

---

## 6. SetTheme

**Cambia el tema de la UI dinámicamente**

```lua
UI:SetTheme("Dark")    -- Cambia a tema Dark
UI:SetTheme("Pink")    -- Cambia a tema Pink
UI:SetTheme("Rainbow") -- Etc.
```

### Temas Disponibles

```lua
-- Los 19 temas que siempre estarán disponibles:
"Dark", "DarkV2",
"Red", "RedV2",
"Pink", "PinkV2", "PinkV3",
"Blue", "BlueV2",
"White", "WhiteV2", "WhiteV3", "WhiteAndDark",
"Green", "NaranjaV1", "VioletaV1",
"CatV1",     -- Con efecto automático
"LightV1",
"ErisV1",    -- Con efecto automático
"ShylfieV1"
```

---

## 7. SetTextEffect

**Cambia el efecto visual del texto**

```lua
UI:SetTextEffect("Off")              -- Normal
UI:SetTextEffect("WhiteCyan")        -- Pulso Blanco-Celeste
UI:SetTextEffect("WhitePink")        -- Pulso Blanco-Rosa
UI:SetTextEffect("Rainbow")          -- Espectro completo
UI:SetTextEffect("RainbowDarkWhite") -- Negro → Blanco
```

### Ejemplo

```lua
local TabEfectos = UI:CreateTab("Efectos")

TabEfectos:CreateButton("Activar Rainbow", function()
    UI:SetTextEffect("Rainbow")
    print("Efecto Rainbow activado")
end)

TabEfectos:CreateButton("Efectos Normales", function()
    UI:SetTextEffect("Off")
    print("Efecto normal (sin animación)")
end)
```

---

## 8. Destroy

**Destruye la UI y limpia todas las conexiones**

```lua
UI:Destroy()  -- Cierra y limpia completamente
```

---

# 🔐 LAS 3 PESTAÑAS SAGRADAS - INFORMACIÓN CRÍTICA

## Advertencia Formal

**ATENCIÓN DESARROLLADORES:**

Las siguientes 3 pestañas son **OBLIGATORIAS**, **INMUTABLES** y **PERMANENTES** en TODAS las implementaciones de Yin Yang UI v26:

1. **TabInicio**
2. **TabTemas**
3. **TabEfectos**

**NO INTENTAR ELIMINARLAS, MODIFICARLAS O DESACTIVARLAS**

---

## ¿POR QUÉ SON SAGRADAS?

### RAZÓN 1: Identidad de la Librería

Yin Yang UI se reconoce por estas 3 pestañas. Un usuario que usa tu script con Yin Yang v26 **SIEMPRE** verá:

- Una pestaña "Inicio" con su avatar y información del servidor
- Una pestaña "Temas" con 19 opciones de personalización
- Una pestaña "Efectos" con 5 efectos de texto

Si faltan, **NO ES YIN YANG UI v26 válido.**

### RAZÓN 2: Experiencia Consistente

Todos los scripts que usan Yin Yang v26 deben ofrecer la **MISMA EXPERIENCIA FUNDAMENTAL**.

Sin estas 3 pestañas, cada desarrollador crearía su propia versión, y:
- Los usuarios estarían confundidos
- No habría uniformidad
- Se perdería la "marca" de Yin Yang

### RAZÓN 3: Características Críticas

Cada pestaña ofrece una funcionalidad **ÚNICA Y EXCLUSIVA** de Yin Yang:

- **Inicio** = Integración con datos del servidor (solo Yin Yang lo hace)
- **Temas** = 19 temas diferentes dinámicamente (solo Yin Yang tiene esto)
- **Efectos** = 5 efectos de texto avanzados (solo Yin Yang los ofrece)

Eliminar cualquiera de estas es **perder una característica distintiva**.

### RAZÓN 4: Restricción por Diseño

Estas pestañas se crean **AUTOMÁTICAMENTE** y **NO** pueden ser controladas por el desarrollador.

Esto garantiza que:
- Nadie las pueda "olvidar"
- Nadie las pueda "desactivar"
- Nadie las pueda "esconder"

---

## Documento Legal Formal

**CLÁUSULA DE RESTRICCIÓN - YIN YANG UI v26**

El desarrollador que use Yin Yang UI v26 **ACEPTA** y **RECONOCE** que:

1. Las 3 pestañas (Inicio, Temas, Efectos) son **PROPIEDADES INTELECTUALES DE MOFUZII**
2. El desarrollador **NO TIENE PERMISO** para:
   - Eliminarlas
   - Modificarlas
   - Desactivarlas
   - Ocultarlas
   - Fusionarlas con otras
   - Cambiar su contenido esencial

3. El desarrollador **TIENE PERMISO** para:
   - Crear nuevas pestañas personalizadas
   - Agregar contenido adicional DESPUÉS del contenido sagrado
   - Cambiar temas y efectos
   - Usar todos los componentes de la librería

4. El incumplimiento de esta cláusula resulta en:
   - Que el script NO sea considerado "Yin Yang UI v26 válido"
   - Pérdida de compatibilidad y beneficios de la librería
   - Posible reporte de violación de términos

**Al usar Yin Yang v26, aceptas estas restricciones.**

---

# 💡 EJEMPLOS PRÁCTICOS

## Ejemplo 1: Script Simple de ESP

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v26_PRODUCCION.lua"))()

local YinYang = _G.YinYang
local UI = YinYang:CreateWindow("Mi ESP v1.0", "Dark")

-- NOTA: Las 3 pestañas sagradas se crean AUTOMÁTICAMENTE
-- TabInicio, TabTemas, TabEfectos ya existen

-- AQUÍ CREO MIS PROPIAS PESTAÑAS:
local TabESP = UI:CreateTab("ESP")

TabESP:CreateToggle("Activar ESP", false, function(state)
    if state then
        print("ESP Activado")
        -- Tu código para activar ESP
    else
        print("ESP Desactivado")
        -- Tu código para desactivar ESP
    end
end)

TabESP:CreateToggle("Mostrar Nombres", true, function(state)
    print("Nombres: " .. (state and "ON" or "OFF"))
end)

TabESP:CreateToggle("Mostrar Distancia", true, function(state)
    print("Distancia: " .. (state and "ON" or "OFF"))
end)

print("ESP Script cargado exitosamente")
```

---

## Ejemplo 2: Script de Admin Panel

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v26_PRODUCCION.lua"))()

local YinYang = _G.YinYang
local UI = YinYang:CreateWindow("Admin Panel", "Blue")

-- Las 3 pestañas sagradas se crean automáticamente

-- MIS PESTAÑAS PERSONALIZADAS:
local TabJugadores = UI:CreateTab("Jugadores")
local TabServ = UI:CreateTab("Servidor")
local TabBans = UI:CreateTab("Bans")

-- PESTAÑA 1: Jugadores
TabJugadores:CreateButton("Listar Jugadores", function()
    for _, player in ipairs(game.Players:GetPlayers()) do
        print("- " .. player.Name)
    end
end)

TabJugadores:CreateDropdown("Seleccionar Jugador",
    {},  -- Se llenaría dinámicamente
    "Nadie",
    function(selected)
        print("Seleccionaste: " .. selected)
    end
)

-- PESTAÑA 2: Servidor
TabServ:CreateToggle("Modo Mantenimiento", false, function(state)
    print("Servidor en mantenimiento: " .. (state and "Sí" or "No"))
end)

TabServ:CreateButton("Reiniciar Servidor", function()
    print("Iniciando reinicio...")
end)

-- PESTAÑA 3: Bans
TabBans:CreateButton("Buscar Usuario Baneado", function()
    print("Buscando...")
end)

TabBans:CreateToggle("Modo Moderacion", false, function(state)
    print("Modo Moderacion: " .. (state and "Activo" or "Inactivo"))
end)

print("Admin Panel cargado")
```

---

## Ejemplo 3: Script con Cambio Dinámico de Temas

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Moliinier/Yin-yang/refs/heads/main/Yin_Yang_v26_PRODUCCION.lua"))()

local YinYang = _G.YinYang
local UI = YinYang:CreateWindow("Mi Script", "Dark")

-- Las 3 pestañas sagradas ya existen automáticamente
-- (incluyendo TabTemas que permite cambiar tema)

-- MIS PROPIAS PESTAÑAS:
local TabDivertido = UI:CreateTab("Divertido")

TabDivertido:CreateButton("Tema Aleatorio", function()
    local temas = {"Dark", "Pink", "Blue", "Red", "Purple", "Green"}
    local tema = temas[math.random(1, #temas)]
    UI:SetTheme(tema)
    print("Tema cambiado a: " .. tema)
end)

TabDivertido:CreateButton("Efecto Aleatorio", function()
    local efectos = {"Off", "WhiteCyan", "WhitePink", "Rainbow", "RainbowDarkWhite"}
    local efecto = efectos[math.random(1, #efectos)]
    UI:SetTextEffect(efecto)
    print("Efecto cambiado a: " .. efecto)
end)

TabDivertido:CreateFloatingToggle("Modo Fiesta", false, function(state)
    if state then
        -- Cambiar tema y efecto continuamente
        print("¡Modo Fiesta ACTIVADO!")
    else
        print("Modo Fiesta desactivado")
    end
end)
```

---

# 📋 MEJORES PRÁCTICAS

## 1. Nombra tus pestañas claramente

```lua
-- ✅ BIEN
local TabEconomia = UI:CreateTab("Economia")
local TabCombate = UI:CreateTab("Combate")
local TabConfiguracion = UI:CreateTab("Configuracion")

-- ❌ MAL
local Tab1 = UI:CreateTab("1")
local Tab2 = UI:CreateTab("2")
local Tab3 = UI:CreateTab("3")
```

---

## 2. Agrupa funcionalidad relacionada

```lua
-- ✅ BIEN - Relacionado
local TabArmas = UI:CreateTab("Armas")
TabArmas:CreateButton("Espada", function() end)
TabArmas:CreateButton("Arco", function() end)
TabArmas:CreateButton("Magia", function() end)

-- ❌ MAL - Mezclado
local TabVario = UI:CreateTab("Vario")
TabVario:CreateButton("Espada", function() end)
TabVario:CreateButton("Curar", function() end)
TabVario:CreateButton("Dinero", function() end)
TabVario:CreateButton("Teletransporte", function() end)
```

---

## 3. Usa títulos descriptivos

```lua
-- ✅ BIEN
TabCombate:CreateToggle("Autofight con espada", false, function(state) end)
TabCombate:CreateToggle("Esquivar enemigos", false, function(state) end)

-- ❌ MAL
TabCombate:CreateToggle("Lucha", false, function(state) end)
TabCombate:CreateToggle("Otra cosa", false, function(state) end)
```

---

## 4. Maneja errores con pcall

```lua
-- ✅ BIEN
TabAcciones:CreateButton("Accion Risky", function()
    local ok, err = pcall(function()
        -- Tu código risky aquí
        print("Ejecutado")
    end)
    if not ok then
        print("Error: " .. tostring(err))
    end
end)

-- ❌ MAL (sin manejo de errores)
TabAcciones:CreateButton("Accion Risky", function()
    -- Código que puede fallar sin protección
    player:TakeAction()  -- Si falla, todo se rompe
end)
```

---

## 5. Limpia recursos

```lua
-- ✅ BIEN - Destruir cuando sea necesario
local UI = YinYang:CreateWindow("Mi Script", "Dark")

-- ... tu código ...

-- Cuando el script termine o se detenga:
UI:Destroy()  -- Limpia conexiones y elementos

-- ❌ MAL - Dejar recursos sin limpiar
local UI = YinYang:CreateWindow("Mi Script", "Dark")
-- Si no llamas a Destroy(), los elementos quedan en memoria
```

---

## 6. Respeta las 3 pestañas sagradas

```lua
-- ✅ BIEN - No tocar TabInicio, TabTemas, TabEfectos
local TabMio = UI:CreateTab("Mi Pestaña")
TabMio:CreateButton("Mi Boton", function() end)

-- ❌ MAL - Intentar acceder a las sagradas
local TabInicio = UI:CreateTab("Inicio")  -- NO, ya existe
TabInicio:CreateButton("Mi Boton", function() end)  -- NO hagas esto

-- ❌ MAL - Intentar eliminarlas
UI.TabInicio = nil  -- NO, no hagas esto
```

---

# 🔗 CONEXIONES Y MEMORIA

## Conexiones Automáticas

Yin Yang v26 gestiona automáticamente todas las conexiones:
- Click en botones
- Estado de toggles
- Cambios de tema
- Cambios de efecto

**TÚ NO NECESITAS MANEJAR ESTO MANUALMENTE**

```lua
-- Todo es automático:
TabMio:CreateButton("Click", function()
    print("Presionado")
    -- La conexión se crea y se destruye automáticamente
end)
```

## Limpiar Memoria

Cuando destruyes la UI, se limpian todas las conexiones:

```lua
local UI = YinYang:CreateWindow("Script", "Dark")

-- ... usas la UI ...

-- Finalmente:
UI:Destroy()  -- Limpia TODO automáticamente
```

---

# 📞 SOPORTE Y CONTACTO

Si tienes preguntas sobre Yin Yang v26:

1. Lee esta documentación (probablemente aquí esté la respuesta)
2. Revisa el Manual de Protección (`MANUAL_PROTECCION_YIN_YANG_v26.md`)
3. Revisa los ejemplos de este archivo

**Desarrollador Original:** MOFUZII  
**Versión:** v26  
**Última Actualización:** 22 Julio 2026

---

# ⚖️ TÉRMINOS Y CONDICIONES DE USO

**Al usar Yin Yang UI v26, aceptas:**

1. ✅ Las 3 pestañas (Inicio, Temas, Efectos) son permanentes e inmutables
2. ✅ No intentarás modificar o eliminar estas pestañas
3. ✅ Reconoces que son propiedad intelectual de MOFUZII
4. ✅ Podrás crear nuevas pestañas y funcionalidades personalizadas
5. ✅ Debes mantener el patrón de calidad profesional de Yin Yang

**Violaciones de estos términos pueden resultar en:**
- Que tu script no sea considerado "Yin Yang UI v26 válido"
- Pérdida de beneficios y compatibilidad
- Posibles sanciones

---

**¡Gracias por usar Yin Yang UI v26!**

Esperamos que disfrutes creando scripts increíbles con nuestra librería.

**MOFUZII © 2026**
