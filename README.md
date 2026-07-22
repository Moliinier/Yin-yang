# 📖 Yin Yang UI v25 - Guía de Uso para Scripters

## 🚀 Inicio Rápido

### Paso 1: Importar la Librería
```lua
local ZeroUI = require(script.Parent:WaitForChild("Yin_Yang_v21"))
```

### Paso 2: Crear una Ventana
```lua
local miApp = ZeroUI:CreateWindow("Mi Aplicación", "Dark")
--                                  ↓ Nombre     ↓ Tema inicial
```

### Paso 3: Crear Tabs (Pestañas)
```lua
local tabInicio = miApp:CreateTab("Inicio")
local tabOpciones = miApp:CreateTab("Opciones")
```

### Paso 4: Agregar Contenido
```lua
tabInicio:CreateLabel("Bienvenido", 16)
tabInicio:CreateDivider()
tabInicio:CreateButton("Hacer algo", function()
    print("¡Botón presionado!")
end)
```

---

## 📚 API Completa

### Window: CreateWindow(title, theme)
Crea una ventana principal.

**Parámetros:**
- `title` (string): Título de la ventana
- `theme` (string): Tema inicial (ver lista de temas abajo)

**Retorna:** Window object

**Ejemplo:**
```lua
local win = ZeroUI:CreateWindow("Mi App", "DarkV2")
```

---

### Tab: CreateTab(name, icon)
Crea una pestaña nueva en la ventana.

**Parámetros:**
- `name` (string): Nombre de la pestaña
- `icon` (string, opcional): Asset ID de un icono

**Retorna:** Tab object

**Ejemplo:**
```lua
local tab = win:CreateTab("Settings")
```

---

### Tab: CreateLabel(text, fontSize)
Crea un label de texto.

**Parámetros:**
- `text` (string): Texto a mostrar
- `fontSize` (number, opcional): Tamaño de fuente (default: 14)

**Ejemplo:**
```lua
tab:CreateLabel("Este es un título", 16)
tab:CreateLabel("Subtítulo pequeño", 11)
```

---

### Tab: CreateButton(text, callback, iconAsset)
Crea un botón clickeable.

**Parámetros:**
- `text` (string): Texto del botón
- `callback` (function): Función que se ejecuta al hacer click
- `iconAsset` (string, opcional): ID de imagen para un icono

**Ejemplo:**
```lua
tab:CreateButton("Eliminar", function()
    print("Botón eliminado presionado")
end)
```

---

### Tab: CreateToggle(text, default, callback)
Crea un switch toggle (encendido/apagado).

**Parámetros:**
- `text` (string): Etiqueta del toggle
- `default` (boolean): Estado inicial (true = encendido)
- `callback` (function): Se ejecuta cada vez que cambia el estado
  - Recibe: `state` (boolean) = nuevo estado

**Ejemplo:**
```lua
tab:CreateToggle("Modo oscuro", false, function(state)
    print("Modo oscuro: " .. (state and "ON" or "OFF"))
end)
```

---

### Tab: CreateFloatingToggle(text, default, callback)
Crea un toggle que se puede **desprender** y flotar libremente en pantalla.

**Parámetros:** Iguales a CreateToggle

**Características especiales:**
- Botón "↗" para desprender/acoplar
- Botón "+" para fijar la posición
- Botón "-" para soltar la posición
- Se puede arrastrar por la pantalla

**Ejemplo:**
```lua
tab:CreateFloatingToggle("Aimbot", false, function(state)
    print("Aimbot: " .. (state and "ACTIVO" or "INACTIVO"))
end)
```

---

### Tab: CreateDivider()
Crea una línea divisoria.

**Ejemplo:**
```lua
tab:CreateLabel("Sección 1", 14)
tab:CreateDivider()
tab:CreateLabel("Sección 2", 14)
```

---

### Window: SetTheme(themeName)
Cambia el tema de la ventana dinámicamente.

**Parámetros:**
- `themeName` (string): Nombre del tema

**Ejemplo:**
```lua
win:SetTheme("BlueV2")
print("✓ Tema cambiado a BlueV2")
```

---

### Window: SetTextEffect(mode)
Aplica un efecto animado a **todos los textos** de la ventana.

**Parámetros:**
- `mode` (string): Tipo de efecto
  - `"Off"` - Desactiva el efecto
  - `"WhiteCyan"` - Pulso blanco ↔ celeste
  - `"WhitePink"` - Pulso blanco ↔ rosa (lento)
  - `"Rainbow"` - Recorre todo el espectro de color

**Ejemplo:**
```lua
win:SetTextEffect("Rainbow")
-- Todos los textos cambiarán de color continuamente

win:SetTextEffect("Off")
-- Vuelven a los colores normales
```

---

### Window: Destroy()
Destruye la ventana y limpia todas las conexiones.

**Importante:** Llamá esto cuando ya no necesites la ventana, para evitar memory leaks.

**Ejemplo:**
```lua
win:Destroy()
```

---

## 🎨 Lista de Temas Disponibles

| Tema | ID | Mejor para |
|------|----|----|
| `"Dark"` | RGB(24,24,27) | Fondos oscuros normales |
| `"DarkV2"` | RGB(15,15,18) | Fondos muy oscuros |
| `"Blue"` | RGB(10,20,40) | Fondos azules oscuros |
| `"BlueV2"` | RGB(30,50,90) | Fondos azules brillantes |
| `"Red"` | RGB(40,10,15) | Fondos rojos oscuros |
| `"RedV2"` | RGB(50,12,20) | Fondos rojos profundos |
| `"Pink"` | RGB(35,15,25) | Fondos rosa oscuros |
| `"PinkV2"` | RGB(240,200,220) | Fondos rosa brillantes ⭐ |
| `"PinkV3"` | RGB(200,140,180) | Fondos rosa medios |
| `"Green"` | RGB(20,50,35) | Fondos verdes naturales 🌿 |
| `"Light"` | RGB(255,255,255) | Fondos claros (alias de White) |
| `"WhiteV2"` | RGB(255,255,255) | Blanco puro mejorado |
| `"WhiteV3"` | RGB(0,255,255) | Blanco con textos NEON ✨ |
| `"WhiteAndDark"` | Gris claro | Tema Yin-Yang 🖤🤍 |
| `"Purple"` | RGB(20,10,35) | Fondos púrpuras |
| `"Orange"` | RGB(40,20,10) | Fondos naranjas |

---

## 💡 Ejemplos Prácticos

### Ejemplo 1: App de Configuración Completa
```lua
local ZeroUI = require(script.Parent:WaitForChild("Yin_Yang_v21"))
local app = ZeroUI:CreateWindow("Mi App", "Dark")

-- Tab de Inicio
local tabHome = app:CreateTab("Inicio")
tabHome:CreateLabel("Bienvenido a Mi App", 16)
tabHome:CreateDivider()
tabHome:CreateLabel("Versión 1.0", 12)

-- Tab de Opciones
local tabSettings = app:CreateTab("Ajustes")
tabSettings:CreateLabel("Preferencias", 14)
tabSettings:CreateToggle("Sonidos", true, function(state)
    print("Sonidos: " .. (state and "activados" or "desactivados"))
end)

tabSettings:CreateDivider()
tabSettings:CreateLabel("Temas", 12)
tabSettings:CreateButton("Dark", function() app:SetTheme("Dark") end)
tabSettings:CreateButton("BlueV2", function() app:SetTheme("BlueV2") end)
tabSettings:CreateButton("PinkV2", function() app:SetTheme("PinkV2") end)

print("✅ App inicializada")
```

---

### Ejemplo 2: Features con Toggles Flotantes
```lua
local ZeroUI = require(script.Parent:WaitForChild("Yin_Yang_v21"))
local cheat = ZeroUI:CreateWindow("Cheat Menu", "DarkV2")

local tabFeatures = cheat:CreateTab("Features")

cheat:CreateFloatingToggle("Aimbot", false, function(state)
    if state then
        print("🎯 Aimbot activado")
    else
        print("🎯 Aimbot desactivado")
    end
end)

cheat:CreateFloatingToggle("ESP", false, function(state)
    if state then
        print("👁️ ESP activado")
    else
        print("👁️ ESP desactivado")
    end
end)
```

---

### Ejemplo 3: Efectos de Texto
```lua
local app = ZeroUI:CreateWindow("Rainbow App", "WhiteV2")

local tab = app:CreateTab("Main")
tab:CreateLabel("Texto Normal", 16)

-- Después de 2 segundos, activa efecto rainbow
task.wait(2)
app:SetTextEffect("Rainbow")
print("✨ Rainbow activado")

-- Después de 5 segundos, cambia a otro efecto
task.wait(5)
app:SetTextEffect("WhitePink")
print("💗 Efecto rosa activado")
```

---

## ⚠️ Consideraciones Importantes

### 1. **Limpieza de Recursos**
Siempre llamá a `Window:Destroy()` cuando termines:
```lua
local app = ZeroUI:CreateWindow("Mi App", "Dark")
-- ... usar la app ...
app:Destroy()  -- ¡IMPORTANTE para evitar memory leaks!
```

### 2. **No Modifiques Internos de la Librería**
Usá solo la API pública (CreateWindow, SetTheme, etc.). No accedas a propiedades privadas como `Main`, `Theme`, etc.

### 3. **SetTextEffect Afecta TODO**
Cuando activás un efecto de texto, **todos** los textos de la ventana cambiarán. Esto incluye labels, botones, toggles, todo.

### 4. **Los Temas son Globales por Window**
Cada ventana (`Window` object) tiene su propio tema. Si creás múltiples ventanas, cada una puede tener un tema diferente.

### 5. **Verificá los IDs de Tema**
Si pasás un tema que no existe, te muestra un warning en la consola:
```
Tema no encontrado: MiTemaInventado
```

---

## 🐛 Troubleshooting

### La ventana no aparece
- ¿Estás en un LocalScript? La librería crea una ScreenGui en PlayerGui
- ¿El require() funciona? Verifica que el path sea correcto

### Los botones no responden
- ¿Es una función válida el callback? Verificá que no haya errores adentro
- Probá con `print("test")` para ver si se ejecuta

### Efecto de texto no funciona
- Probá primero con `SetTextEffect("Off")` para resetear
- Algunos temas con colores ya muy saturados pueden no mostrar diferencia visible

### Memory leak / Performance baja
- ¿Llamaste a `Window:Destroy()` cuando terminaste?
- ¿Estás creando muchas ventanas sin borrarlas? Limpia las viejas

---

## 📊 Propiedades Públicas de Window

Podés acceder a estas desde afuera:

```lua
local app = ZeroUI:CreateWindow("Mi App", "Dark")

-- Propiedades que podés consultar (solo lectura):
print(app.CurrentTheme)          -- "Dark"
print(app.CurrentTextEffect)     -- "Off"
print(table.getn(app.Tabs))      -- Cantidad de tabs
print(table.getn(app.FloatingToggles))  -- Toggles flotantes activos

-- Tablas útiles:
print(app.AllThemes)             -- Tabla con todas las paletas de color
print(app.Assets)                -- Tabla de assets
```

---

## 🔧 Si Querés Agregar Temas Personalizados

Leé el archivo: **GUIA_AJUSTE_BACKGROUNDS.md**

Te explica cómo agregar nuevos temas sin quebrar la librería.

---

## 📝 Notas de Versión

**v21** (Actual)
- ✅ Sistemas de efectos de texto (Rainbow, WhiteCyan, WhitePink)
- ✅ Temas Green y WhiteV3 (Neon)
- ✅ Fondos decorativos centrados perfectamente
- ✅ API completamente estable

**v20**
- Primeros 7 temas V2/V3 agregados
- Sistema de toggles flotantes

---

**¿Preguntas o bugs?** Leé las guías o contactá al desarrollador.

**Última actualización:** v21 - Julio 2026  
**Autor Original:** Frf  
**Validado en:** Roblox Studio Lite (Delta Executor)
