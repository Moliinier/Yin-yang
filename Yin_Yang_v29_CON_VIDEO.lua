--[[
    Yin Yang - UI Ultimate Edition (v26.1)  SOUND BUG FIXED
    ============================================================
     ARREGLOS CRÍTICOS v26.1:
    
    1. FIX SONIDO GLOBAL: El slider ya NO reproduce sonido en inputs globales
       - Eliminado playSound en InputChanged (línea 1508)
       - Cambiado de UserInputService.InputEnded a SliderThumb.InputEnded
       - El sonido SOLO se escucha al ajustar el slider, no en todo input de pantalla
    
    2. AHORA COMPATIBLE: Puedes jugar EVADE sin escuchar sonidos del slider
    
     CARACTERÍSTICAS ORIGINALES MANTENIDAS:
    
    1. LOGO YIN-YANG ROTATIVO: Logo animado que gira continuamente
    2. SONIDOS INTEGRADOS:
       - Click al activar/desactivar (138567614125924)
       - Dragón aleatorio cuando está cerrado (7127123554) - cada 15 segundos, volumen reducido
    3. TOGGLES FLOTANTES: 
       - Pueden desprenderse de la UI principal
       - Se pueden fijar (+) o soltar (-) 
       - Se mueven libremente por la pantalla

--// ══════════════════════════════════════════════════════════════════════════════
--// GUÍA: CÓMO CREAR PESTAÑAS CON ASSETS (ICONOS)
--// ══════════════════════════════════════════════════════════════════════════════
--//
--// SINTAXIS BÁSICA:
--// local MiTab = Window:CreateTab("Nombre de la Pestaña", "rbxassetid://ASSET_ID")
--//
--// EJEMPLO 1: Crear una pestaña con icono de casa
--// local TabCasa = Window:CreateTab("Mi Casa", "rbxassetid://124987849953130")
--//
--// EJEMPLO 2: Crear una pestaña sin icono
--// local TabSimple = Window:CreateTab("Simple", nil)
--// O directamente sin el segundo parámetro:
--// local TabSimple = Window:CreateTab("Simple")
--//
--// EJEMPLO 3: Usar diferentes assets
--// local TabManzana = Window:CreateTab("Frutas", "rbxassetid://84419345138935")
--// local TabRayo = Window:CreateTab("Energía", "rbxassetid://114693810646148")
--// local TabAjustes = Window:CreateTab("Configuración", "rbxassetid://86797720103644")
--//
--// LISTA DE ASSETS DISPONIBLES EN LA LIBRERÍA:
--// • Casa: 124987849953130
--// • Manzana: 84419345138935
--// • Rayo: 114693810646148
--// • Ajustes: 86797720103644
--// • Candado: 115388161816720
--// • Llave: 135318845352652
--// • Lupa: 83456197177232
--// • Brújula: 121857625643442
--// • Y muchos más...
--//
--// NOTA IMPORTANTE:
--// • El icono se mostrará a la IZQUIERDA del nombre de la pestaña
--// • El icono es pequeño (16x16px) pero claramente visible
--// • El tamaño se ajusta automáticamente para no molestar el texto
--// • Los nombres de pestaña siempre permanecen visibles
--//
--// ══════════════════════════════════════════════════════════════════════════════

       - Persistencia de posición
    4. SISTEMA PROFESIONAL DE AUDIO
    5. MANEJO AVANZADO DE VENTANAS FLOTANTES
    
    TOKENS USADOS:
    - Yin-Yang: 84935900372278
    - Click Sound: 138567614125924
    - Dragon Sound: 7127123554
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("ZeroMobile") then
        LocalPlayer.PlayerGui.ZeroMobile:Destroy()
    end
end)

--// SONIDOS
local Sounds = {
    Click = "rbxassetid://138567614125924",
    Dragon = "rbxassetid://7127123554",
}

--// ═════════════════════════════════════════════════════════════════════════════
--// SISTEMA DE LENGUAJE BILINGÜE (v28 PRO)
--// ═════════════════════════════════════════════════════════════════════════════
local LanguageSystem = {
    CurrentLanguage = "es",  -- "es" = Español, "en" = English
    Config = { Language = "es" }
}

local function GetText(spanishText, englishText)
    if LanguageSystem.CurrentLanguage == "es" then
        return spanishText
    else
        return englishText
    end
end

local function ChangeLanguage(newLanguage)
    if newLanguage ~= "es" and newLanguage ~= "en" then
        error("Idioma no válido. Usa 'es' o 'en'")
        return
    end
    LanguageSystem.CurrentLanguage = newLanguage
    LanguageSystem.Config.Language = newLanguage
end

local function SaveLanguageConfig()
    pcall(function()
        if writefile then
            local configJson = HttpService:JSONEncode(LanguageSystem.Config)
            writefile("yin_yang_language_config.json", configJson)
        end
    end)
end

local function LoadLanguageConfig()
    pcall(function()
        if readfile and isfile and isfile("yin_yang_language_config.json") then
            local configJson = readfile("yin_yang_language_config.json")
            LanguageSystem.Config = HttpService:JSONDecode(configJson)
            LanguageSystem.CurrentLanguage = LanguageSystem.Config.Language or "es"
        end
    end)
end

LoadLanguageConfig()
--// ═════════════════════════════════════════════════════════════════════════════

--// VARIABLE DE ESTADO: Freeze Icono
local IconoCongelado = false

--//  SONIDOS DE CLICK PERSONALIZADOS POR TEMA (v26)
local ThemeClickSounds = {
    CatV1 = "rbxassetid://133371725828981",
    PinkV2 = "rbxassetid://136022651109523",
    PinkV1 = "rbxassetid://15675081158",
    PinkV3 = "rbxassetid://75880354609739",
    ErisV1 = "rbxassetid://137965684634919",
    VioletaV1 = "rbxassetid://115624890613221",
    GreenV1 = "rbxassetid://9112751731",
    DarkV2 = "rbxassetid://139804904213958",
    BlueV2 = "rbxassetid://118574877365368",
    WhiteV2 = "rbxassetid://140043289814504",
    WhiteAndDark = "rbxassetid://139239108826837",
    LightV1 = "rbxassetid://99071431420752",
    NaranjaV1 = "rbxassetid://124502189759941",
}

--// SISTEMA DE SONIDO DINÁMICO POR TEMA
local CurrentClickSound = Sounds.Click
local CurrentTheme = "Dark"

--//  v26: VARIABLE PARA ACTIVAR/DESACTIVAR SONIDOS PERSONALIZADOS
local DynamicClickSoundsEnabled = true  --  Cambiar a false para desactivar

--//  SISTEMA RAINBOW DARK-WHITE: Cambia lentamente de negro a blanco
local RainbowDarkWhiteActive = false
local RainbowDarkWhiteValue = 0
local RainbowDarkWhiteLabels = {}
local RainbowDarkWhiteStart = tick()
local RainbowDarkWhiteConnection = nil

--// 🌙 LETRAS DE "CANTO DE LUNA" PARA TÍTULO ANIMADO (v26)
local CantoLunaLetras = {
    "Yin Yang",
    "Canto de Luna",
    "la-la-la 🌙",
    "Canta, canta",
    "En mi corazón",
    "la-la-la ",
    "Eres lo que buscamos",
    "Con la luz 💫",
    "Canta, canta, canta",
    "Yo te vi",
}

--//  COLORES RAINBOW (Prioridad: BLANCO)
local RainbowColors = {
    Color3.fromRGB(255, 255, 0),      -- Amarillo
    Color3.fromRGB(255, 255, 255),    -- BLANCO ⭐
    Color3.fromRGB(255, 0, 0),        -- Rojo
    Color3.fromRGB(255, 255, 255),    -- BLANCO ⭐
    Color3.fromRGB(0, 255, 0),        -- Verde
    Color3.fromRGB(255, 255, 255),    -- BLANCO ⭐
    Color3.fromRGB(0, 0, 255),        -- Azul
    Color3.fromRGB(255, 255, 255),    -- BLANCO ⭐
    Color3.fromRGB(255, 165, 0),      -- Naranja
    Color3.fromRGB(255, 255, 255),    -- BLANCO ⭐
}

--//  COLORES DE BORDE ANIMADO PARA FLOATING TOGGLES (v26.1 PREMIUM)
local FloatingToggleBorderColors = {
    -- DARK THEMES (Azules y Cian)
    Dark = {
        Color3.fromRGB(100, 200, 255),    -- Cian claro
        Color3.fromRGB(150, 100, 255),    -- Púrpura
        Color3.fromRGB(100, 150, 255),    -- Azul
        Color3.fromRGB(200, 150, 255),    -- Púrpura claro
    },
    DarkV2 = {
        Color3.fromRGB(100, 180, 255),
        Color3.fromRGB(120, 200, 255),
        Color3.fromRGB(80, 150, 255),
        Color3.fromRGB(150, 180, 255),
    },
    
    -- RED THEMES (Rojos y Naranjas)
    Red = {
        Color3.fromRGB(255, 100, 100),    -- Rojo claro
        Color3.fromRGB(255, 150, 100),    -- Naranja-rojo
        Color3.fromRGB(255, 80, 120),     -- Rojo-rosa
        Color3.fromRGB(255, 120, 100),    -- Naranja
    },
    RedV2 = {
        Color3.fromRGB(255, 120, 100),
        Color3.fromRGB(255, 100, 150),
        Color3.fromRGB(255, 150, 80),
        Color3.fromRGB(255, 100, 100),
    },
    
    -- PINK THEMES (Rosas y Púrpuras)
    Pink = {
        Color3.fromRGB(255, 100, 200),    -- Rosa
        Color3.fromRGB(255, 150, 200),    -- Rosa claro
        Color3.fromRGB(200, 100, 200),    -- Púrpura-rosa
        Color3.fromRGB(255, 100, 150),    -- Rosa-rojo
    },
    PinkV2 = {
        Color3.fromRGB(255, 120, 200),
        Color3.fromRGB(255, 80, 180),
        Color3.fromRGB(220, 100, 200),
        Color3.fromRGB(255, 150, 200),
    },
    PinkV3 = {
        Color3.fromRGB(255, 100, 180),
        Color3.fromRGB(255, 150, 210),
        Color3.fromRGB(200, 80, 180),
        Color3.fromRGB(255, 120, 190),
    },
    
    -- BLUE THEMES (Azules y Cian)
    Blue = {
        Color3.fromRGB(100, 200, 255),    -- Cian
        Color3.fromRGB(150, 200, 255),    -- Azul claro
        Color3.fromRGB(100, 150, 200),    -- Azul
        Color3.fromRGB(200, 220, 255),    -- Azul muy claro
    },
    BlueV2 = {
        Color3.fromRGB(80, 180, 255),
        Color3.fromRGB(120, 200, 255),
        Color3.fromRGB(100, 160, 255),
        Color3.fromRGB(150, 210, 255),
    },
    
    -- WHITE THEMES (Blancos y Grises)
    White = {
        Color3.fromRGB(200, 200, 200),    -- Gris claro
        Color3.fromRGB(255, 255, 255),    -- Blanco
        Color3.fromRGB(220, 220, 220),    -- Gris
        Color3.fromRGB(240, 240, 240),    -- Blanco roto
    },
    WhiteV2 = {
        Color3.fromRGB(220, 220, 220),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(200, 200, 200),
        Color3.fromRGB(230, 230, 230),
    },
    WhiteV3 = {
        Color3.fromRGB(210, 210, 210),
        Color3.fromRGB(240, 240, 240),
        Color3.fromRGB(190, 190, 190),
        Color3.fromRGB(255, 255, 255),
    },
    WhiteAndDark = {
        Color3.fromRGB(100, 100, 100),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(150, 150, 150),
        Color3.fromRGB(200, 200, 200),
    },
    
    -- GREEN THEME (Verdes)
    Green = {
        Color3.fromRGB(100, 255, 150),    -- Verde claro
        Color3.fromRGB(150, 255, 100),    -- Verde-amarillo
        Color3.fromRGB(100, 200, 150),    -- Verde
        Color3.fromRGB(150, 255, 180),    -- Verde muy claro
    },
    
    -- SPECIAL THEMES
    NaranjaV1 = {
        Color3.fromRGB(255, 150, 50),     -- Naranja
        Color3.fromRGB(255, 100, 80),     -- Naranja-rojo
        Color3.fromRGB(255, 180, 100),    -- Naranja claro
        Color3.fromRGB(255, 120, 60),     -- Naranja oscuro
    },
    VioletaV1 = {
        Color3.fromRGB(180, 100, 255),    -- Púrpura
        Color3.fromRGB(200, 150, 255),    -- Púrpura claro
        Color3.fromRGB(150, 80, 255),     -- Púrpura oscuro
        Color3.fromRGB(220, 180, 255),    -- Púrpura muy claro
    },
    CatV1 = {
        Color3.fromRGB(255, 100, 150),    -- Rosa
        Color3.fromRGB(255, 150, 100),    -- Naranja
        Color3.fromRGB(200, 100, 200),    -- Púrpura
        Color3.fromRGB(255, 120, 120),    -- Rojo-rosa
    },
    LightV1 = {
        Color3.fromRGB(255, 220, 100),    -- Amarillo claro
        Color3.fromRGB(255, 255, 150),    -- Amarillo muy claro
        Color3.fromRGB(255, 200, 100),    -- Amarillo-naranja
        Color3.fromRGB(255, 240, 150),    -- Crema
    },
    ErisV1 = {
        Color3.fromRGB(255, 80, 80),      -- Rojo oscuro
        Color3.fromRGB(180, 50, 50),      -- Rojo muy oscuro
        Color3.fromRGB(255, 100, 100),    -- Rojo claro
        Color3.fromRGB(200, 60, 60),      -- Rojo
    },
    ShylfieV1 = {
        Color3.fromRGB(100, 180, 255),    -- Azul claro
        Color3.fromRGB(150, 200, 255),    -- Azul cielo
        Color3.fromRGB(80, 160, 255),     -- Azul
        Color3.fromRGB(200, 220, 255),    -- Azul muy claro
    },
}

--// 💾 SISTEMA DE GUARDADO/PERSISTENCIA (v26 - MEJORADO)
local ConfigFile = "Yin_Yang_Config.txt"
local SavedConfig = {
    CurrentTheme = "Dark",
    CurrentEffect = "Normal",
    Volume = 0.5,
}

local function SaveConfig()
    pcall(function()
        local configData = table.concat({
            "theme:" .. tostring(SavedConfig.CurrentTheme or CurrentTheme or "Dark"),
            "effect:" .. tostring(SavedConfig.CurrentEffect or "Normal"),
            "volume:" .. tostring(SavedConfig.Volume or 0.5),
            "libMode:" .. tostring(SavedConfig.LibrarySizeMode or "Small"),
            "libHeight:" .. tostring(SavedConfig.LibraryHeight or 340),
            "time:" .. tostring(os.time()),
        }, "|")
        writefile(ConfigFile, configData)
    end)
end

local function LoadConfig()
    local result = {
        theme = nil,
        effect = nil,
        volume = nil,
        libMode = nil,
        libHeight = nil,
    }

    pcall(function()
        if readfile(ConfigFile) then
            local content = readfile(ConfigFile)
            if content and content ~= "" then
                for part in content:gmatch("([^|]+)") do
                    local key, value = part:match("([^:]+):(.+)")
                    if key == "theme" then
                        result.theme = value
                    elseif key == "effect" then
                        result.effect = value
                    elseif key == "volume" then
                        result.volume = tonumber(value)
                    elseif key == "libMode" then
                        result.libMode = value
                    elseif key == "libHeight" then
                        result.libHeight = tonumber(value)
                    end
                end
            end
        end
    end)
    return result
end

--// POOL DE SONIDOS: reutiliza Instances en vez de crear/destruir una por cada click
local SoundPool = {}
local POOL_SIZE = 8
local poolCursor = 0

local function getPooledSound()
    -- 1) intenta encontrar uno libre (que no esté sonando)
    for _, s in ipairs(SoundPool) do
        if not s.IsPlaying then
            return s
        end
    end
    -- 2) si el pool no está lleno, crea uno nuevo y lo agrega
    if #SoundPool < POOL_SIZE then
        local s = Instance.new("Sound")
        s.Parent = SoundService
        table.insert(SoundPool, s)
        return s
    end
    -- 3) pool lleno y todos ocupados: reutiliza el siguiente en rotación (round robin)
    poolCursor = (poolCursor % #SoundPool) + 1
    return SoundPool[poolCursor]
end

local function playSound(soundId, volume)
    volume = volume or 0.5
    
    --//  v26: USAR SONIDO DINÁMICO SI ESTÁ ACTIVADO
    local finalSoundId = soundId
    
    -- Si sonidos dinámicos están activados, ignorar Sounds.Click y usar el del tema
    if DynamicClickSoundsEnabled and (soundId == Sounds.Click or not soundId) then
        if CurrentTheme and ThemeClickSounds[CurrentTheme] then
            finalSoundId = ThemeClickSounds[CurrentTheme]
        else
            finalSoundId = Sounds.Click
        end
    end
    
    if not finalSoundId or finalSoundId == "" then 
        finalSoundId = Sounds.Click
    end
    
    local sound = getPooledSound()
    if sound then
        pcall(function()
            sound.SoundId = finalSoundId
            sound.Volume = math.clamp(volume, 0, 1)
            sound.TimePosition = 0
            sound.Playing = false
            sound:Play()
        end)
    end
end

--// ASSETS & TEMAS
local Assets = {
    Utilities = {
        Settings = "rbxasset://textures/Cursor.png",
        Search = "rbxasset://textures/Cursor.png",
        Download = "rbxasset://textures/Cursor.png",
        Upload = "rbxasset://textures/Cursor.png",
        Copy = "rbxasset://textures/Cursor.png",
        Paste = "rbxasset://textures/Cursor.png",
        Refresh = "rbxasset://textures/Cursor.png",
        Delete = "rbxasset://textures/Cursor.png",
        Edit = "rbxasset://textures/Cursor.png",
        Save = "rbxasset://textures/Cursor.png",
        Export = "rbxasset://textures/Cursor.png",
        Import = "rbxasset://textures/Cursor.png",
        Help = "rbxasset://textures/Cursor.png",
        Info = "rbxasset://textures/Cursor.png",
    },
    Combat = {
        Aimbot = "rbxasset://textures/Cursor.png",
        ESP = "rbxasset://textures/Cursor.png",
        GodMode = "rbxasset://textures/Cursor.png",
        Combat = "rbxasset://textures/Cursor.png",
        Speed = "rbxasset://textures/Cursor.png",
        Flight = "rbxasset://textures/Cursor.png",
        Teleport = "rbxasset://textures/Cursor.png",
        Noclip = "rbxasset://textures/Cursor.png",
        Invisibility = "rbxasset://textures/Cursor.png",
        AutoCollect = "rbxasset://textures/Cursor.png",
        Movement = "rbxasset://textures/Cursor.png",
        Damage = "rbxasset://textures/Cursor.png",
    },
    Interface = {
        Home = "rbxasset://textures/Cursor.png",
        Back = "rbxasset://textures/Cursor.png",
        Forward = "rbxasset://textures/Cursor.png",
        Menu = "rbxasset://textures/Cursor.png",
        Close = "rbxasset://textures/Cursor.png",
        Plus = "rbxasset://textures/Cursor.png",
        Minus = "rbxasset://textures/Cursor.png",
        Folder = "rbxasset://textures/Cursor.png",
        File = "rbxasset://textures/Cursor.png",
        Pin = "rbxasset://textures/Cursor.png",
        Star = "rbxasset://textures/Cursor.png",
    },
}

function Assets:AddCustom(category, name, assetId)
    if not self[category] then
        self[category] = {}
    end
    self[category][name] = assetId
end

local ThemePalettes = {
    --// WHITE V1: Blanco puro, adaptado para fondos blancos claros
    White = {
        Background = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(232, 232, 232),
        AccentOff = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(0, 0, 0),
        TextDim = Color3.fromRGB(120, 120, 120),
        Stroke = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(0, 0, 0),
        ToggleOn = Color3.fromRGB(52, 199, 89),
    },
    Dark = {
        Background = Color3.fromRGB(24, 24, 27),
        Secondary = Color3.fromRGB(40, 40, 45),
        AccentOff = Color3.fromRGB(58, 58, 64),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(160, 160, 165),
        Stroke = Color3.fromRGB(90, 90, 96),
        Accent = Color3.fromRGB(255, 255, 255),
        ToggleOn = Color3.fromRGB(52, 199, 89),
    },
    --// DARK V2: Más oscuro y elegante, adaptado para fondos oscuros (105596249630448)
    DarkV2 = {
        Background = Color3.fromRGB(15, 15, 18),
        Secondary = Color3.fromRGB(30, 30, 36),
        AccentOff = Color3.fromRGB(50, 50, 58),
        Text = Color3.fromRGB(245, 245, 248),
        TextDim = Color3.fromRGB(165, 165, 172),
        Stroke = Color3.fromRGB(80, 80, 90),
        Accent = Color3.fromRGB(255, 255, 255),
        ToggleOn = Color3.fromRGB(52, 199, 89),
    },
    Purple = {
        Background = Color3.fromRGB(20, 10, 35),
        Secondary = Color3.fromRGB(40, 20, 60),
        AccentOff = Color3.fromRGB(70, 40, 100),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(180, 160, 200),
        Stroke = Color3.fromRGB(120, 80, 180),
        Accent = Color3.fromRGB(180, 100, 255),
        ToggleOn = Color3.fromRGB(180, 100, 255),
    },
    Blue = {
        Background = Color3.fromRGB(10, 20, 40),
        Secondary = Color3.fromRGB(20, 40, 70),
        AccentOff = Color3.fromRGB(40, 70, 120),
        Text = Color3.fromRGB(230, 240, 255),
        TextDim = Color3.fromRGB(150, 180, 220),
        Stroke = Color3.fromRGB(80, 140, 220),
        Accent = Color3.fromRGB(100, 180, 255),
        ToggleOn = Color3.fromRGB(100, 180, 255),
    },
    --// BLUE V2: Más claro y vibrante, adaptado para fondos azules brillantes (107573562621514)
    BlueV2 = {
        Background = Color3.fromRGB(30, 50, 90),
        Secondary = Color3.fromRGB(50, 80, 140),
        AccentOff = Color3.fromRGB(70, 110, 170),
        Text = Color3.fromRGB(240, 245, 255),
        TextDim = Color3.fromRGB(180, 200, 240),
        Stroke = Color3.fromRGB(100, 160, 240),
        Accent = Color3.fromRGB(120, 200, 255),
        ToggleOn = Color3.fromRGB(120, 200, 255),
    },
    Red = {
        Background = Color3.fromRGB(40, 10, 15),
        Secondary = Color3.fromRGB(70, 20, 30),
        AccentOff = Color3.fromRGB(120, 40, 60),
        Text = Color3.fromRGB(255, 230, 230),
        TextDim = Color3.fromRGB(220, 150, 160),
        Stroke = Color3.fromRGB(220, 80, 100),
        Accent = Color3.fromRGB(255, 100, 120),
        ToggleOn = Color3.fromRGB(255, 100, 120),
    },
    --// RED V2: Más oscuro y elegante, adaptado para fondos rojos profundos (118635431058555)
    RedV2 = {
        Background = Color3.fromRGB(50, 12, 20),
        Secondary = Color3.fromRGB(80, 25, 40),
        AccentOff = Color3.fromRGB(120, 45, 70),
        Text = Color3.fromRGB(255, 235, 235),
        TextDim = Color3.fromRGB(225, 160, 170),
        Stroke = Color3.fromRGB(220, 100, 130),
        Accent = Color3.fromRGB(255, 120, 150),
        ToggleOn = Color3.fromRGB(255, 120, 150),
    },
    Orange = {
        Background = Color3.fromRGB(40, 20, 10),
        Secondary = Color3.fromRGB(70, 35, 20),
        AccentOff = Color3.fromRGB(120, 60, 30),
        Text = Color3.fromRGB(255, 240, 230),
        TextDim = Color3.fromRGB(220, 180, 150),
        Stroke = Color3.fromRGB(220, 140, 60),
        Accent = Color3.fromRGB(255, 160, 80),
        ToggleOn = Color3.fromRGB(255, 160, 80),
    },
    Pink = {
        Background = Color3.fromRGB(35, 15, 25),
        Secondary = Color3.fromRGB(60, 25, 45),
        AccentOff = Color3.fromRGB(100, 50, 80),
        Text = Color3.fromRGB(255, 240, 245),
        TextDim = Color3.fromRGB(220, 170, 200),
        Stroke = Color3.fromRGB(230, 150, 200),
        Accent = Color3.fromRGB(255, 170, 220),
        ToggleOn = Color3.fromRGB(255, 170, 220),
    },
    --// PINK V2: Mucho más claro y luminoso, adaptado para fondos rosa brillante (140206818990660)
    PinkV2 = {
        Background = Color3.fromRGB(240, 200, 220),
        Secondary = Color3.fromRGB(255, 215, 235),
        AccentOff = Color3.fromRGB(230, 180, 210),
        Text = Color3.fromRGB(60, 20, 40),
        TextDim = Color3.fromRGB(100, 50, 80),
        Stroke = Color3.fromRGB(220, 150, 190),
        Accent = Color3.fromRGB(255, 100, 170),
        ToggleOn = Color3.fromRGB(255, 100, 170),
    },
    --// PINK V3: Versión intermedia, más adaptable (122685629557229)
    PinkV3 = {
        Background = Color3.fromRGB(200, 140, 180),
        Secondary = Color3.fromRGB(220, 160, 200),
        AccentOff = Color3.fromRGB(180, 120, 160),
        Text = Color3.fromRGB(255, 240, 250),
        TextDim = Color3.fromRGB(220, 180, 210),
        Stroke = Color3.fromRGB(230, 130, 190),
        Accent = Color3.fromRGB(255, 80, 160),
        ToggleOn = Color3.fromRGB(255, 80, 160),
    },
    --// WHITE V2: Blanco puro mejorado con mejor legibilidad (90931437124122)
    WhiteV2 = {
        Background = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(245, 245, 245),
        AccentOff = Color3.fromRGB(220, 220, 220),
        Text = Color3.fromRGB(20, 20, 25),
        TextDim = Color3.fromRGB(100, 100, 110),
        Stroke = Color3.fromRGB(180, 180, 185),
        Accent = Color3.fromRGB(50, 50, 60),
        ToggleOn = Color3.fromRGB(52, 199, 89),
    },
    --// WHITE AND DARK: Tema mitad blanco, mitad oscuro (85320264713056)
    WhiteAndDark = {
        Background = Color3.fromRGB(240, 240, 240),
        Secondary = Color3.fromRGB(200, 200, 200),
        AccentOff = Color3.fromRGB(170, 170, 170),
        Text = Color3.fromRGB(40, 40, 45),
        TextDim = Color3.fromRGB(110, 110, 120),
        Stroke = Color3.fromRGB(100, 100, 110),
        Accent = Color3.fromRGB(0, 0, 0),
        ToggleOn = Color3.fromRGB(52, 199, 89),
    },
    Green = {
        Background = Color3.fromRGB(20, 50, 35),
        Secondary = Color3.fromRGB(35, 80, 55),
        AccentOff = Color3.fromRGB(60, 120, 90),
        Text = Color3.fromRGB(230, 255, 240),
        TextDim = Color3.fromRGB(160, 220, 190),
        Stroke = Color3.fromRGB(100, 200, 140),
        Accent = Color3.fromRGB(120, 220, 160),
        ToggleOn = Color3.fromRGB(100, 220, 140),
    },
    --// WHITE V3: Blanco puro con textos NEON brillantes y vibrantes (88768864762169)
    WhiteV3 = {
        Background = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(248, 248, 248),
        AccentOff = Color3.fromRGB(230, 230, 230),
        Text = Color3.fromRGB(30, 30, 35),  -- Gris oscuro para verse sobre blanco
        TextDim = Color3.fromRGB(100, 100, 110),
        Stroke = Color3.fromRGB(150, 150, 160),
        Accent = Color3.fromRGB(0, 180, 220),
        ToggleOn = Color3.fromRGB(0, 180, 220),
    },
    --// NARANJA V1: Naranja vibrante y cálido, adaptado para fondos naranjas (90056518364273)
    NaranjaV1 = {
        Background = Color3.fromRGB(50, 30, 15),
        Secondary = Color3.fromRGB(80, 45, 25),
        AccentOff = Color3.fromRGB(120, 70, 40),
        Text = Color3.fromRGB(255, 245, 230),
        TextDim = Color3.fromRGB(230, 190, 150),
        Stroke = Color3.fromRGB(230, 160, 80),
        Accent = Color3.fromRGB(255, 180, 80),
        ToggleOn = Color3.fromRGB(255, 180, 80),
    },
    --// VIOLETA V1: Violeta profundo y elegante, adaptado para fondos violetas (112714301994517)
    VioletaV1 = {
        Background = Color3.fromRGB(40, 15, 50),
        Secondary = Color3.fromRGB(70, 30, 90),
        AccentOff = Color3.fromRGB(110, 50, 140),
        Text = Color3.fromRGB(240, 220, 255),
        TextDim = Color3.fromRGB(200, 150, 220),
        Stroke = Color3.fromRGB(180, 120, 200),
        Accent = Color3.fromRGB(200, 100, 255),
        ToggleOn = Color3.fromRGB(200, 100, 255),
    },
    --// CAT V1: Tema del gato en rama - Rosa-Blanco con efecto rainbow rápido (135950962141755)
    CatV1 = {
        Background = Color3.fromRGB(245, 235, 240),      -- Rosa muy claro
        Secondary = Color3.fromRGB(230, 210, 225),       -- Rosa pálido
        AccentOff = Color3.fromRGB(210, 180, 200),       -- Rosa apagado
        Text = Color3.fromRGB(40, 25, 35),               -- Marrón oscuro
        TextDim = Color3.fromRGB(120, 90, 110),          -- Marrón tenue
        Stroke = Color3.fromRGB(180, 140, 160),          -- Rosa medio
        Accent = Color3.fromRGB(0, 0, 0),                -- Negro puro
        ToggleOn = Color3.fromRGB(255, 100, 150),        -- Rosa caliente
    },
    --// LIGHT V1: Tema luminoso y angelical, inspirado en luz blanca pura
    LightV1 = {
        Background = Color3.fromRGB(250, 250, 252),      -- Blanco muy claro con toque azul
        Secondary = Color3.fromRGB(235, 235, 240),       -- Gris muy claro
        AccentOff = Color3.fromRGB(210, 210, 220),       -- Gris suave
        Text = Color3.fromRGB(40, 45, 55),               -- Gris azulado oscuro
        TextDim = Color3.fromRGB(130, 135, 150),         -- Gris azulado medio
        Stroke = Color3.fromRGB(180, 185, 200),          -- Gris azulado claro
        Accent = Color3.fromRGB(200, 210, 230),          -- Azul muy claro
        ToggleOn = Color3.fromRGB(100, 150, 220),        -- Azul celeste
    },
    --// ERIS V1: Tema rojo oscuro con énfasis en rojo-negro, efecto Rainbow automático Rojo→Dark→White
    ErisV1 = {
        Background = Color3.fromRGB(20, 10, 15),         -- Negro profundo con toque rojo
        Secondary = Color3.fromRGB(40, 15, 25),          -- Rojo muy oscuro
        AccentOff = Color3.fromRGB(60, 20, 40),          -- Rojo oscuro
        Text = Color3.fromRGB(255, 200, 200),            -- Rojo claro/Rosa
        TextDim = Color3.fromRGB(180, 120, 130),         -- Rojo medio/oscuro
        Stroke = Color3.fromRGB(200, 80, 100),           -- Rojo vibrante
        Accent = Color3.fromRGB(255, 80, 100),           -- Rojo puro
        ToggleOn = Color3.fromRGB(255, 100, 120),        -- Rojo caliente
    },
    --// SHYLFIE V1: Tema angelical azul-gris con énfasis en luminosidad
    ShylfieV1 = {
        Background = Color3.fromRGB(230, 235, 245),      -- Azul muy claro
        Secondary = Color3.fromRGB(210, 220, 240),       -- Azul pálido
        AccentOff = Color3.fromRGB(190, 205, 230),       -- Azul suave
        Text = Color3.fromRGB(30, 50, 80),               -- Azul oscuro
        TextDim = Color3.fromRGB(100, 130, 170),         -- Azul medio
        Stroke = Color3.fromRGB(150, 180, 220),          -- Azul claro
        Accent = Color3.fromRGB(120, 170, 240),          -- Azul vibrante
        ToggleOn = Color3.fromRGB(100, 160, 255),        -- Azul celeste puro
    },
    --// YIN YANG NEW V1: Tema épico con video de fondo
    YinYangNewV1 = {
        Background = Color3.fromRGB(10, 10, 15),
        Secondary = Color3.fromRGB(25, 25, 35),
        AccentOff = Color3.fromRGB(50, 50, 70),
        Text = Color3.fromRGB(240, 240, 245),
        TextDim = Color3.fromRGB(160, 160, 180),
        Stroke = Color3.fromRGB(80, 80, 110),
        Accent = Color3.fromRGB(200, 200, 220),
        ToggleOn = Color3.fromRGB(120, 180, 255),
    },
}

--// IMÁGENES DE FONDO POR TEMA (decorativas, se muestran detrás del contenido)
local ThemeBackgroundImages = {
    Dark = "rbxassetid://138004303203419",
    DarkV2 = "rbxassetid://105596249630448",
    Pink = "rbxassetid://129299161197887",
    PinkV2 = "rbxassetid://140206818990660",
    PinkV3 = "rbxassetid://122685629557229",
    Blue = "rbxassetid://136072951221172",
    BlueV2 = "rbxassetid://107573562621514",
    Red = "rbxassetid://88289923848664",
    RedV2 = "rbxassetid://118635431058555",
    White = "rbxassetid://129555461947864",
    WhiteV2 = "rbxassetid://90931437124122",
    WhiteV3 = "rbxassetid://88768864762169",
    WhiteAndDark = "rbxassetid://85320264713056",
    Green = "rbxassetid://86357167554483",
    NaranjaV1 = "rbxassetid://90056518364273",
    VioletaV1 = "rbxassetid://112714301994517",
    CatV1 = "rbxassetid://135950962141755",  --  Gato en rama
    LightV1 = "rbxassetid://85339946380507",  --  Angel luminoso blanco
    ErisV1 = "rbxassetid://134043807878571",  -- 🔴 Personaje rojo-oscuro
    ShylfieV1 = "rbxassetid://107193044106364",  --  Angel azul-gris
}

--// VIDEOS POR TEMA (para temas con video de fondo)
local ThemeVideos = {
    YinYangNewV1 = "https://raw.githubusercontent.com/Moliinier/VideoLibreryYinYang/main/temaV1.webm"
}

--// VARIABLES GLOBALES PARA VIDEOS
local VideoCache = {}
local CurrentVideoFrame = nil
local VideoFolderName = "YinYangVideos"

local Theme

--// UTILIDADES
local function mk(cls, props, parent)
    local o = Instance.new(cls)
    pcall(function() o.Selectable = false end)
    if o:IsA("TextButton") or o:IsA("ImageButton") then
        pcall(function() o.AutoButtonColor = false end)
    end
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(p, r)
    mk("UICorner", {CornerRadius = UDim.new(0, r or 8)}, p)
end

local function stroke(p, col, th, trans)
    local s = mk("UIStroke", {Color = col, Thickness = th or 1.5, Transparency = trans or 0}, p)
    s:SetAttribute("ThemeRole", "Stroke")
    return s
end

local function resetScrollTop(scrollingFrame)
    task.defer(function()
        if scrollingFrame and scrollingFrame.Parent then
            scrollingFrame.CanvasPosition = Vector2.new(0, 0)
        end
    end)
end

local function formatDuration(totalSeconds)
    totalSeconds = math.floor(totalSeconds)
    local h = math.floor(totalSeconds / 3600)
    local m = math.floor((totalSeconds % 3600) / 60)
    local s = totalSeconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function createStatGrid(parent)
    local Grid = mk("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 9
    })
    mk("UIGridLayout", {
        CellPadding = UDim2.new(0, 8, 0, 8),
        CellSize = UDim2.new(0.5, -4, 0, 54),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, Grid)
    return Grid
end

local function createStatTile(grid, label)
    local Tile = mk("Frame", {
        Parent = grid,
        BackgroundColor3 = Theme.Secondary,
        ZIndex = 9
    })
    Tile:SetAttribute("ThemeRole", "Secondary")
    corner(Tile, 6)
    stroke(Tile, Color3.fromRGB(0, 0, 0), 1, 0.6)

    mk("TextLabel", {
        Parent = Tile,
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 10
    }):SetAttribute("ThemeRole", "TextDim")

    local ValueText = mk("TextLabel", {
        Parent = Tile,
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.new(0, 8, 0, 24),
        BackgroundTransparency = 1,
        Text = "...",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 10
    })
    ValueText:SetAttribute("ThemeRole", "Text")

    return Tile, ValueText
end

--// Calcula si un texto/símbolo debe ser blanco o negro según el brillo del fondo
-- Así garantizamos contraste SIN cambiar el color de acento de ningún tema (ej: el blanco de Dark)
local function getContrastColor(bgColor)
    local luminance = 0.299 * bgColor.R + 0.587 * bgColor.G + 0.114 * bgColor.B
    if luminance > 0.6 then
        return Color3.fromRGB(25, 25, 25)
    end
    return Color3.fromRGB(255, 255, 255)
end

-- ThemeRole -> controla BackgroundColor3 (o Color en UIStroke)
-- ThemeTextRole -> controla TextColor3, independiente del rol de fondo
local function swapThemeColor(obj, palette)
    local bgRole = obj:GetAttribute("ThemeRole")
    if bgRole and palette[bgRole] then
        if obj:IsA("UIStroke") then
            obj.Color = palette[bgRole]
        elseif obj:IsA("GuiObject") then
            pcall(function() obj.BackgroundColor3 = palette[bgRole] end)
        end
    end

    local textRole = obj:GetAttribute("ThemeTextRole")
    if textRole and palette[textRole] then
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.TextColor3 = palette[textRole]
        end
    end
end

--// Centraliza el cambio de tema: clona la paleta y calcula el color de contraste (AccentText)
-- para que cualquier texto/símbolo sobre un fondo Accent (ej: blanco en Dark) siga siendo legible
-- sin tener que tocar el color de acento del tema.
local function setActiveTheme(name)
    local palette = ThemePalettes[name]
    if not palette then return false end
    Theme = table.clone(palette)
    Theme.AccentText = getContrastColor(Theme.Accent)
    return true
end

setActiveTheme("Dark")

--// FUNCIÓN: Descargar y cachear videos para temas con video
local function EnsureVideoCached(themeName)
    if VideoCache[themeName] then
        return VideoCache[themeName]
    end
    
    local videoUrl = ThemeVideos[themeName]
    if not videoUrl then 
        print("❌ Video URL no encontrada para: " .. themeName)
        return nil 
    end
    
    local filePath = VideoFolderName .. "/video_" .. themeName .. ".webm"
    
    --// Intentar descargar si no existe
    if not isfile(filePath) then
        pcall(function()
            print("⏳ Descargando video: " .. videoUrl)
            local success, data = pcall(game.HttpGet, game, videoUrl)
            if success and data and #data > 0 then
                if not isfolder(VideoFolderName) then
                    makefolder(VideoFolderName)
                end
                writefile(filePath, data)
                print("✅ Video descargado exitosamente: " .. filePath)
            else
                print("❌ Error descargando video: URL inaccesible")
            end
        end)
    else
        print("✅ Video ya cacheado: " .. filePath)
    end
    
    --// Intentar cargar el asset
    if isfile(filePath) then
        local ok, asset = pcall(function()
            return getcustomasset(filePath)
        end)
        if ok and asset then
            VideoCache[themeName] = asset
            print("✅ Asset video cargado: " .. tostring(asset))
            return asset
        else
            print("❌ Error cargando asset con getcustomasset()")
        end
    else
        print("❌ Archivo no existe: " .. filePath)
    end
    
    return nil
end

--// MAIN OBJECT - Global para que otros scripts puedan usarlo
_G.YinYang = {}
local YinYang = _G.YinYang
YinYang.__index = YinYang

function YinYang:CreateWindow(title_text, startTheme)
    startTheme = startTheme or "Dark"

    local ConfigCargada = LoadConfig()
    if ConfigCargada then
        if ConfigCargada.libMode then
            SavedConfig.LibrarySizeMode = ConfigCargada.libMode
        end
        if ConfigCargada.libHeight then
            SavedConfig.LibraryHeight = ConfigCargada.libHeight
        end
        if ConfigCargada.effect then
            SavedConfig.CurrentEffect = ConfigCargada.effect
        end
        if ConfigCargada.volume then
            SavedConfig.Volume = ConfigCargada.volume
        end
    end

    setActiveTheme(startTheme)

    local globalConnections = {}
    local function track(conn)
        table.insert(globalConnections, conn)
        return conn
    end

    local ScreenGui = mk("ScreenGui", {
        Name = "ZeroMobile",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 100
    }, LocalPlayer:WaitForChild("PlayerGui"))

    --// BOTÓN TOGGLE CON LOGO YIN-YANG
    local ToggleButton = mk("TextButton", {
        Name = "ToggleButton",
        Size = UDim2.new(0, 46, 0, 46),
        Position = UDim2.new(0, 24, 0, 70),
        BackgroundColor3 = Theme.Accent,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        ZIndex = 30,
    }, ScreenGui)
    ToggleButton:SetAttribute("ThemeRole", "Accent")
    corner(ToggleButton, 999)
    stroke(ToggleButton, Theme.Accent, 1.5)

    --// LOGO YIN-YANG ROTATIVO
    local YinYangLogo = mk("ImageLabel", {
        Parent = ToggleButton,
        Size = UDim2.new(2, 0, 2, 0),
        Position = UDim2.new(-0.5, 0, -0.5, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://84935900372278",
        ZIndex = 31
    })

    --// ROTACIÓN CONTINUA DEL YIN-YANG
    local YinYangRotation = mk("UIAspectRatioConstraint", {
        AspectRatio = 1
    }, YinYangLogo)

    local rotationSpeed = 0
    game:GetService("RunService").RenderStepped:Connect(function()
        rotationSpeed = rotationSpeed + 2
        if rotationSpeed > 360 then rotationSpeed = 0 end
        YinYangLogo.Rotation = rotationSpeed
    end)

    --// SONIDO DE DRAGÓN ALEATORIO CUANDO ESTÁ CERRADO
    local dragonTimer = 0
    local dragonConnection
    dragonConnection = game:GetService("RunService").Heartbeat:Connect(function()
        dragonTimer = dragonTimer + 1
        if dragonTimer > 900 then -- Cada 15 segundos
            dragonTimer = 0
            if not Main or not Main.Visible then
                playSound(Sounds.Dragon, 0.15)
            end
        end
    end)

    local ToggleScale = mk("UIScale", {Scale = 1}, ToggleButton)
    local idlePulse = TweenService:Create(
        ToggleScale,
        TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Scale = 1.08}
    )
    idlePulse:Play()

    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            idlePulse:Pause()
            playSound(Sounds.Click, 0.6)
            TweenService:Create(ToggleScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.88}):Play()
        end
    end)
    ToggleButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local backTween = TweenService:Create(ToggleScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
            backTween:Play()
            backTween.Completed:Once(function()
                idlePulse:Play()
            end)
        end
    end)

    --// VENTANA PRINCIPAL - SOMBRA MEJORADA
    local shownSize = UDim2.new(0, 420, 0, 340)
    local ShadowFrame = mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.98,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = ScreenGui
    })
    corner(ShadowFrame, 10)
    ShadowFrame:SetAttribute("ThemeRole", "Stroke")

    local Main = mk("Frame", {
        Name = "Main",
        Size = shownSize,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = true,
        ZIndex = 5
    }, ScreenGui)
    Main:SetAttribute("ThemeRole", "Background")
    corner(Main, 10)
    stroke(Main, Theme.Stroke, 1.5)

    local BackgroundArt -- se crea más abajo, dentro de ContentArea (ver comentario ahí)

    local function updateShadowPos()
        ShadowFrame.Size = UDim2.new(Main.Size.X.Scale, Main.Size.X.Offset + 4, Main.Size.Y.Scale, Main.Size.Y.Offset + 4)
        ShadowFrame.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset - 2, Main.Position.Y.Scale, Main.Position.Y.Offset - 2)
    end
    Main:GetPropertyChangedSignal("Size"):Connect(updateShadowPos)
    Main:GetPropertyChangedSignal("Position"):Connect(updateShadowPos)

    local uiVisible = true
    ToggleButton.MouseButton1Click:Connect(function()
        uiVisible = not uiVisible
        if uiVisible then
            Main.Visible = true
            Main.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = shownSize}):Play()
        else
            local tw = TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
            tw:Play()
            tw.Completed:Wait()
            Main.Visible = false
        end
        
        --// Play/Pause video si es tema YinYangNewV1
        if CurrentTheme == "YinYangNewV1" and CurrentVideoFrame then
            pcall(function()
                if Main.Visible then
                    CurrentVideoFrame:Play()
                else
                    CurrentVideoFrame:Pause()
                end
            end)
        end
    end)

    do
        local drag = false
        local dragStart, startPos
        ToggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if not IconoCongelado then  -- 🔒 SOLO permitir drag si NO está congelado
                    drag = true
                    dragStart = input.Position
                    startPos = ToggleButton.Position
                end
            end
        end)
        track(UserInputService.InputChanged:Connect(function(input)
            if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                ToggleButton.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
            end
        end))
        track(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
        end))
    end

    local TopBar = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Background,
        ZIndex = 6,
    }, Main)
    TopBar:SetAttribute("ThemeRole", "Background")
    corner(TopBar, 10)
    mk("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Theme.Stroke, ZIndex = 7}, TopBar):SetAttribute("ThemeRole", "Stroke")

    local TitleLabel = mk("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = title_text or "ZERO UI",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7
    }, TopBar)
    TitleLabel:SetAttribute("ThemeTextRole", "Text")

    --//  ANIMACIÓN YIN-YANG ÉPICA EN EL TÍTULO (v27)
    --// Si el título contiene "Yin" o "Yang", aplica animación especial
    if title_text and (string.find(title_text, "Yin") or string.find(title_text, "Yang")) then
        local animValue = 0
        local animSpeed = 0.3  -- Muy lentamente
        local origColor = TitleLabel.TextColor3
        
        track(RunService.RenderStepped:Connect(function()
            animValue = (animValue + animSpeed) % 360
            
            -- Calcular valor de interpolación (0 a 1 a 0)
            local sine = (math.sin(math.rad(animValue)) + 1) / 2  -- 0 a 1
            
            -- Si contiene "Yin", cambia Negro↔Blanco
            -- Si contiene "Yang", cambia Blanco↔Negro (inverso)
            if string.find(title_text, "Yin Yang") or string.find(title_text, "yin yang") then
                -- Ambos presentes: Yin va Negro→Blanco, Yang va Blanco→Negro
                TitleLabel.TextColor3 = Color3.fromRGB(
                    math.floor(255 * sine),
                    math.floor(255 * sine),
                    math.floor(255 * sine)
                )
            else
                TitleLabel.TextColor3 = Color3.fromRGB(
                    math.floor(255 * sine),
                    math.floor(255 * sine),
                    math.floor(255 * sine)
                )
            end
        end))
    end

    do
        local drag = false
        local dragStart, startPos
        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                drag = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)
        track(UserInputService.InputChanged:Connect(function(input)
            if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end))
        track(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
        end))
    end

    local Body = mk("Frame", {
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        ZIndex = 6
    }, Main)

    local TabList = mk("ScrollingFrame", {
        Size = UDim2.new(0, 110, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        CanvasPosition = Vector2.new(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 7
    }, Body)
    TabList:SetAttribute("ThemeRole", "Secondary")
    corner(TabList, 10)
    mk("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    }, TabList)
    mk("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)}, TabList)
    mk("Frame", {Parent = Body, Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0, 109, 0, 0), BackgroundColor3 = Theme.Stroke, BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 8}, Body):SetAttribute("ThemeRole", "Stroke")

    local ContentArea = mk("Frame", {
        Size = UDim2.new(1, -110, 1, 0),
        Position = UDim2.new(0, 110, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 7
    }, Body)
    mk("UIPadding", {PaddingTop = UDim.new(0, 0), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15)}, ContentArea)

    --// FONDO DECORATIVO SEGÚN EL TEMA
    -- IMPORTANTE: vive DENTRO de ContentArea (no de todo Main). Antes cubría toda la
    -- ventana pero el TabList (110px) tapaba la mitad izquierda, así que lo que se
    -- veía era un recorte descentrado de la imagen. Al vivir solo en el área visible,
    -- con AnchorPoint centrado, la imagen queda realmente centrada en lo que el usuario ve.
    --// Crear VideoFrame (siempre, pero invisible inicialmente)
    CurrentVideoFrame = mk("VideoFrame", {
        Name = "BackgroundVideoFrame",
        Parent = ContentArea,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 30, 1, 30),
        BackgroundTransparency = 1,
        Volume = 0.3,
        Looped = true,
        Visible = false,
        ZIndex = 5
    })
    
    --// Crear ImageLabel normalmente
    BackgroundArt = mk("ImageLabel", {
        Name = "BackgroundArt",
        Parent = ContentArea,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 30, 1, 30),  -- Agrandado +15px por lado para desbordar el padding (15px)
        BackgroundTransparency = 1,
        Image = ThemeBackgroundImages[startTheme] or "",
        ImageTransparency = 0.1,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 5
    })
    corner(BackgroundArt, 8)

    local Overlay = mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 200,
    }, Main)

    local currentDropdownClose = nil

    local function attachDropdownBehavior(Holder, Click, Chevron, optionsCount, buildPopupContents)
        local isOpen = false
        local closePopup

        local function open()
            if currentDropdownClose then currentDropdownClose() end
            isOpen = true
            Chevron.Text = "^"

            local backdrop = mk("TextButton", {
                Parent = Overlay,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 201
            })

            local relX = Holder.AbsolutePosition.X - Main.AbsolutePosition.X
            local relY = Holder.AbsolutePosition.Y - Main.AbsolutePosition.Y + Holder.AbsoluteSize.Y + 4
            local itemH = 32
            local maxH = 160
            local contentH = math.max(optionsCount, 1) * (itemH + 4) + 8
            local popupH = math.min(contentH, maxH)

            local Popup = mk("ScrollingFrame", {
                Parent = Overlay,
                Position = UDim2.new(0, relX, 0, relY),
                Size = UDim2.new(0, Holder.AbsoluteSize.X, 0, popupH),
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ElasticBehavior = Enum.ElasticBehavior.Never,
                CanvasPosition = Vector2.new(0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 202
            })
            Popup:SetAttribute("ThemeRole", "Background")
            corner(Popup, 6)
            stroke(Popup, Theme.Stroke, 1.5, 0)
            mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, Popup)
            mk("UIPadding", {
                PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)
            }, Popup)

            closePopup = function()
                isOpen = false
                Chevron.Text = "v"
                backdrop:Destroy()
                Popup:Destroy()
                currentDropdownClose = nil
            end
            currentDropdownClose = closePopup
            backdrop.MouseButton1Click:Connect(function() closePopup() end)

            buildPopupContents(Popup, closePopup)
        end

        Click.MouseButton1Click:Connect(function()
            if isOpen then
                if closePopup then closePopup() end
            else
                open()
            end
        end)
    end

    local Window = setmetatable({}, ZeroUI)
    Window.Tabs = {}
    Window.Assets = Assets
    Window.CurrentTheme = startTheme
    Window.AllThemes = ThemePalettes
    Window.FloatingToggles = {}
    Window.ScreenGui = ScreenGui
    Window.BackgroundArt = BackgroundArt

    --// TAMAÑO DE LA VENTANA: solo dos versiones fijas (sin sliders intermedios)
    local LibrarySizePresets = {
        Small = { Width = 420, Height = 340 },
        Large = { Width = 560, Height = 680 },
    }

    local LibrarySizeMode = ((SavedConfig.LibrarySizeMode or "Small") == "Large") and "Large" or "Small"

    local function getCurrentLibraryPreset()
        return LibrarySizePresets[LibrarySizeMode] or LibrarySizePresets.Small
    end

    local function updateWindowSize()
        local preset = getCurrentLibraryPreset()
        local screen = ScreenGui.AbsoluteSize
        local width = preset.Width
        local height = preset.Height

        if screen.X > 0 and screen.Y > 0 then
            width = math.min(width, math.floor(screen.X * 0.92))
            height = math.min(height, math.floor(screen.Y * 0.92))
        end

        shownSize = UDim2.new(0, width, 0, height)
        if Main then
            Main.Size = shownSize
        end
    end

    updateWindowSize()
    ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateWindowSize)

    function Window:SetLibraryVersion(isLarge)
        LibrarySizeMode = isLarge and "Large" or "Small"
        self.LibrarySizeMode = LibrarySizeMode
        self.LibraryHeight = getCurrentLibraryPreset().Height
        SavedConfig.LibrarySizeMode = LibrarySizeMode
        SavedConfig.LibraryHeight = self.LibraryHeight
        SaveConfig()
        updateWindowSize()
    end

    Window.LibrarySizeMode = LibrarySizeMode
    Window.LibraryHeight = getCurrentLibraryPreset().Height

    function Window:CreateTab(nameSpanish, nameEnglishOrIcon, iconAsset)
        --// COMPATIBILIDAD: Si nameEnglishOrIcon es un icon (rbxassetid), tratarlo como antes
        local nameEnglish = nameSpanish
        if nameEnglishOrIcon and string.find(nameEnglishOrIcon, "rbxassetid") then
            --// Código antiguo: CreateTab(name, iconAsset)
            iconAsset = nameEnglishOrIcon
            nameEnglish = nameSpanish
        elseif nameEnglishOrIcon then
            --// Código nuevo: CreateTab(nameSpanish, nameEnglish, iconAsset)
            nameEnglish = nameEnglishOrIcon
        end
        
        local displayName = GetText(nameSpanish, nameEnglish)
        
        local TabButton = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.AccentOff,
            Text = "",
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.None,
            ClipsDescendants = false,
            ZIndex = 8
        }, TabList)
        TabButton:SetAttribute("ThemeRole", "AccentOff")
        TabButton:SetAttribute("TextSpanish", nameSpanish)
        TabButton:SetAttribute("TextEnglish", nameEnglish)
        corner(TabButton, 6)

        local textStart = 38
        if iconAsset then
            local iconSize = (displayName == "Chat") and 28 or 24
            local iconPos = (displayName == "Chat") and 5 or 7
            mk("ImageLabel", {
                Parent = TabButton,
                Size = UDim2.new(0, iconSize, 0, iconSize),
                Position = UDim2.new(0, iconPos, 0.5, -(iconSize / 2)),
                BackgroundTransparency = 1,
                Image = iconAsset,
                ScaleType = Enum.ScaleType.Fit,
                ZIndex = 9
            })
        end

        local TabNameLabel = mk("TextLabel", {
            Parent = TabButton,
            Size = UDim2.new(1, -(textStart + 10), 1, 0),
            Position = UDim2.new(0, textStart, 0, 0),
            BackgroundTransparency = 1,
            Text = displayName,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.None,
            ClipsDescendants = false,
            ZIndex = 9
        })
        TabNameLabel:SetAttribute("TextSpanish", nameSpanish)
        TabNameLabel:SetAttribute("TextEnglish", nameEnglish)

        resetScrollTop(TabList)

        local TabPage = mk("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ElasticBehavior = Enum.ElasticBehavior.Never,
            CanvasPosition = Vector2.new(0, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            ZIndex = 8,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, ContentArea)
        mk("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top,
        }, TabPage)

        local Tab = {Button = TabButton, Page = TabPage}

        local function Select()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                t.Button.TextColor3 = Theme.Text
                t.Button.BackgroundColor3 = Theme.AccentOff
            end
            TabPage.Visible = true
            TabPage.CanvasPosition = Vector2.new(0, 0)
            task.defer(function()
                if TabPage and TabPage.Parent then
                    TabPage.CanvasPosition = Vector2.new(0, 0)
                end
            end)
            TabButton.TextColor3 = Theme.AccentText
            TabButton.BackgroundColor3 = Theme.Accent
        end

        TabButton.MouseButton1Click:Connect(Select)
        if #Window.Tabs == 0 then Select() end
        table.insert(Window.Tabs, Tab)

        --// NUEVO: TOGGLE FLOTANTE

        --//  FLOATING TOGGLE v2.0 - COMPLETAMENTE RECONSTRUIDO
        function Tab:CreateFloatingToggle(textSpanish, textEnglishOrDefault, defaultOrCallback, callback)
            --// COMPATIBILIDAD: si el 2do argumento es string, es modo bilingüe.
            --// Si es boolean/nil, es la firma antigua: (text, default, callback)
            local textEnglish = textSpanish
            local default, cb

            if type(textEnglishOrDefault) == "string" then
                textEnglish = textEnglishOrDefault
                default = defaultOrCallback
                cb = callback
            else
                default = textEnglishOrDefault
                cb = defaultOrCallback
            end

            local displayText = GetText(textSpanish, textEnglish)
            local state = default or false
            local isFloating = false
            local isLocked = false
            
            --// ═════════════════════════════════════════════════════════════════════════
            --// PARTE 1: ELEMENTO EN LA PESTAÑA (PEQUEÑO)
            --// ═════════════════════════════════════════════════════════════════════════
            
            local Holder = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Secondary,
                ZIndex = 9
            })
            Holder:SetAttribute("ThemeRole", "Secondary")
            corner(Holder, 6)
            stroke(Holder, Theme.Stroke, 1, 0.6)
            
            --// Texto
            local HolderLabel = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = displayText,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 10
            })
            HolderLabel:SetAttribute("ThemeTextRole", "Text")
            HolderLabel:SetAttribute("TextSpanish", textSpanish)
            HolderLabel:SetAttribute("TextEnglish", textEnglish)
            
            --// Botón Desprender
            local DetachBtn = mk("TextButton", {
                Parent = Holder,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -70, 0.5, -12),
                BackgroundColor3 = Theme.Accent,
                Text = "↗",
                TextColor3 = Color3.fromRGB(0, 0, 0),
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                ZIndex = 13
            })
            corner(DetachBtn, 4)
            
            --// Switch Compacto (16x16 knob, 40x20 track)
            local HolderSwitch = mk("Frame", {
                Parent = Holder,
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -40, 0.5, -10),
                BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff,
                ZIndex = 10
            })
            HolderSwitch:SetAttribute("ThemeRole", state and "ToggleOn" or "AccentOff")
            corner(HolderSwitch, 999)
            
            local HolderKnob = mk("Frame", {
                Parent = HolderSwitch,
                Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.new(1, 1, 1),
                ZIndex = 11
            })
            corner(HolderKnob, 999)
            
            --// Área clickeable en la pestaña
            local HolderClick = mk("TextButton", {
                Parent = Holder,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 12
            })
            
            --// ═════════════════════════════════════════════════════════════════════════
            --// PARTE 2: VENTANA FLOTANTE (RECONSTRUIDA)
            --// ═════════════════════════════════════════════════════════════════════════
            
            local FloatingWindow = nil
            local FloatingGlow = nil
            local animationConnection = nil
            
            local function createFloatingWindow()
                
                --// GLOW EXTERIOR - INVISIBLE
                FloatingGlow = mk("Frame", {
                    Parent = Window.ScreenGui,
                    Size = UDim2.fromOffset(200, 40),
                    Position = UDim2.new(0.5, -100, 0.5, -20),
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 1,  -- INVISIBLE
                    BorderSizePixel = 0,
                    ZIndex = 149
                })
                corner(FloatingGlow, 20)
                
                --// VENTANA PRINCIPAL (Más pequeña)
                FloatingWindow = mk("Frame", {
                    Parent = Window.ScreenGui,
                    Size = UDim2.fromOffset(200, 40),  -- TAMAÑO REDUCIDO
                    Position = UDim2.new(0.5, -100, 0.5, -20),
                    BackgroundColor3 = Theme.Secondary,
                    BackgroundTransparency = 0.35,  -- MÁS TRANSPARENTE
                    BorderSizePixel = 0,
                    ZIndex = 150
                })
                corner(FloatingWindow, 999)
                
                --// Borde del tema
                stroke(FloatingWindow, Theme.Accent, 2, 0.5)
                
                --// LAYOUT HORIZONTAL
                local UILayout = mk("UIListLayout", {
                    Parent = FloatingWindow,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                --// TEXTO (Visible y pequeño)
                local FloatLabel = mk("TextLabel", {
                    Parent = FloatingWindow,
                    Size = UDim2.new(0, 60, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = displayText,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 151,
                    LayoutOrder = 1
                })
                FloatLabel:SetAttribute("ThemeTextRole", "Text")
                FloatLabel:SetAttribute("TextSpanish", textSpanish)
                FloatLabel:SetAttribute("TextEnglish", textEnglish)
                
                --// BOTÓN + (Pequeño)
                local PlusBtn = mk("TextButton", {
                    Parent = FloatingWindow,
                    Size = UDim2.fromOffset(16, 16),
                    BackgroundColor3 = Theme.Accent,
                    Text = "+",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 10,
                    ZIndex = 151,
                    LayoutOrder = 2
                })
                corner(PlusBtn, 3)
                
                --// BOTÓN - (Pequeño)
                local MinusBtn = mk("TextButton", {
                    Parent = FloatingWindow,
                    Size = UDim2.fromOffset(16, 16),
                    BackgroundColor3 = Theme.Accent,
                    Text = "-",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    ZIndex = 151,
                    LayoutOrder = 3
                })
                corner(MinusBtn, 3)
                
                --// SWITCH (Pequeño)
                local FloatSwitch = mk("Frame", {
                    Parent = FloatingWindow,
                    Size = UDim2.fromOffset(40, 20),
                    BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff,
                    ZIndex = 151,
                    LayoutOrder = 4
                })
                FloatSwitch:SetAttribute("ThemeRole", state and "ToggleOn" or "AccentOff")
                corner(FloatSwitch, 999)
                
                local FloatKnob = mk("Frame", {
                    Parent = FloatSwitch,
                    Size = UDim2.fromOffset(16, 16),
                    Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    ZIndex = 152
                })
                corner(FloatKnob, 999)
                
                --// SINCRONIZAR GLOW CON VENTANA
                local function syncGlow()
                    if FloatingGlow and FloatingGlow.Parent then
                        FloatingGlow.Size = UDim2.fromOffset(FloatingWindow.Size.X.Offset + 16, FloatingWindow.Size.Y.Offset + 16)
                        FloatingGlow.Position = UDim2.new(FloatingWindow.Position.X.Scale, FloatingWindow.Position.X.Offset - 8, FloatingWindow.Position.Y.Scale, FloatingWindow.Position.Y.Offset - 8)
                    end
                end
                syncGlow()
                track(FloatingWindow:GetPropertyChangedSignal("Position"):Connect(syncGlow))
                
                --// ═════════════════════════════════════════════════════════════════════
                --// INTERACTIVIDAD
                --// ═════════════════════════════════════════════════════════════════════
                
                --// Click en Switch Flotante
                local FloatClick = mk("TextButton", {
                    Parent = FloatSwitch,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 152
                })
                
                FloatClick.MouseButton1Click:Connect(function()
                    state = not state
                    playSound(Sounds.Click, 0.5)
                    
                    --// Tween 1: Color del track
                    TweenService:Create(FloatSwitch, TweenInfo.new(0.15), 
                        {BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff}):Play()
                    
                    --// Tween 2: Movimiento del knob
                    TweenService:Create(FloatKnob, TweenInfo.new(0.15), 
                        {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                    
                    --// NO ANIMAR GLOW - MANTENERLO INVISIBLE
                    FloatingGlow.BackgroundTransparency = 1.0
                    
                    --// Sincronizar con pestaña
                    TweenService:Create(HolderSwitch, TweenInfo.new(0.15), 
                        {BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff}):Play()
                    TweenService:Create(HolderKnob, TweenInfo.new(0.15), 
                        {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                    
                    pcall(cb, state)
                end)
                
                --// Fijar con +
                PlusBtn.MouseButton1Click:Connect(function()
                    isLocked = true
                    playSound(Sounds.Click, 0.5)
                    TweenService:Create(PlusBtn, TweenInfo.new(0.3), 
                        {BackgroundColor3 = Color3.fromRGB(100, 200, 100)}):Play()
                    task.wait(0.3)
                    TweenService:Create(PlusBtn, TweenInfo.new(0.3), 
                        {BackgroundColor3 = Theme.Accent}):Play()
                end)
                
                --// Soltar con -
                MinusBtn.MouseButton1Click:Connect(function()
                    isLocked = false
                    playSound(Sounds.Click, 0.5)
                end)
                
                --// ═════════════════════════════════════════════════════════════════════
                --// DRAG (Solo si no está locked)
                --// ═════════════════════════════════════════════════════════════════════
                
                local dragging = false
                local dragStart, startPos
                
                FloatingWindow.InputBegan:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not isLocked then
                        dragging = true
                        dragStart = input.Position
                        startPos = FloatingWindow.Position
                    end
                end)
                
                track(UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - dragStart
                        FloatingWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                end))
                
                track(UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end))
                
                table.insert(Window.FloatingToggles, {Window = FloatingWindow, Name = displayText})
            end
            
            --// ═════════════════════════════════════════════════════════════════════════
            --// BOTÓN DESPRENDER EN PESTAÑA
            --// ═════════════════════════════════════════════════════════════════════════
            
            DetachBtn.MouseButton1Click:Connect(function()
                playSound(Sounds.Click, 0.6)
                if not isFloating then
                    isFloating = true
                    createFloatingWindow()
                    DetachBtn.Text = "←"
                else
                    isFloating = false
                    if animationConnection then
                        animationConnection:Disconnect()
                        animationConnection = nil
                    end
                    if FloatingWindow then
                        FloatingWindow:Destroy()
                        FloatingWindow = nil
                    end
                    if FloatingGlow then
                        FloatingGlow:Destroy()
                        FloatingGlow = nil
                    end
                    DetachBtn.Text = "↗"
                end
            end)
            
            --// ═════════════════════════════════════════════════════════════════════════
            --// CLICK EN SWITCH DE PESTAÑA
            --// ═════════════════════════════════════════════════════════════════════════
            
            HolderClick.MouseButton1Click:Connect(function()
                state = not state
                playSound(Sounds.Click, 0.5)
                
                --// Tween 1: Color
                TweenService:Create(HolderSwitch, TweenInfo.new(0.15), 
                    {BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff}):Play()
                
                --// Tween 2: Knob
                TweenService:Create(HolderKnob, TweenInfo.new(0.15), 
                    {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                
                --// Sincronizar con flotante si existe
                if isFloating and FloatingWindow and FloatingWindow.Parent then
                    for _, child in ipairs(FloatingWindow:GetDescendants()) do
                        if child:IsA("Frame") and child.Size.X.Offset == 55 and child.Size.Y.Offset == 28 then
                            TweenService:Create(child, TweenInfo.new(0.15), 
                                {BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff}):Play()
                            
                            local knob = child:FindFirstChildWhichIsA("Frame")
                            if knob then
                                TweenService:Create(knob, TweenInfo.new(0.15), 
                                    {Position = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)}):Play()
                            end
                            break
                        end
                    end
                end
                
                pcall(cb, state)
            end)
            
            resetScrollTop(TabPage)
        end


        --// TOGGLE ESTÁNDAR
        function Tab:CreateToggle(textSpanish, textEnglishOrDefault, defaultOrCallback, callback)
            --// COMPATIBILIDAD: si el 2do argumento es string, es modo bilingüe.
            --// Si es boolean/nil, es la firma antigua: (text, default, callback)
            local textEnglish = textSpanish
            local default, cb

            if type(textEnglishOrDefault) == "string" then
                textEnglish = textEnglishOrDefault
                default = defaultOrCallback
                cb = callback
            else
                default = textEnglishOrDefault
                cb = defaultOrCallback
            end

            local displayText = GetText(textSpanish, textEnglish)
            local state = default or false
            local Holder = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Secondary,
                BackgroundTransparency = 0.5,
                ZIndex = 9
            })
            Holder:SetAttribute("ThemeRole", "Secondary")
            corner(Holder, 6)
            stroke(Holder, Theme.Stroke, 1, 0.6)

            local LabelTxt = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = displayText,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 10
            })
            LabelTxt:SetAttribute("ThemeTextRole", "Text")
            LabelTxt:SetAttribute("TextSpanish", textSpanish)
            LabelTxt:SetAttribute("TextEnglish", textEnglish)

            local Switch = mk("Frame", {
                Parent = Holder,
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff,
                ZIndex = 10
            })
            Switch:SetAttribute("ThemeRole", state and "ToggleOn" or "AccentOff")
            corner(Switch, 999)

            local Knob = mk("Frame", {
                Parent = Switch,
                Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.new(1, 1, 1),
                ZIndex = 11
            })
            corner(Knob, 999)

            local Click = mk("TextButton", {
                Parent = Holder,
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 12
            })
            Click.MouseButton1Click:Connect(function()
                state = not state
                playSound(Sounds.Click, 0.5)
                TweenService:Create(Switch, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                pcall(cb, state)
            end)
            resetScrollTop(TabPage)
            
            --// ✨ RETORNAR CONTROLADOR DEL TOGGLE (ChatGPT v1)
            return {
                SetValue = function(value)
                    state = value
                    playSound(Sounds.Click, 0.3)
                    TweenService:Create(Switch, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff}):Play()
                    TweenService:Create(Knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                    --// NO dispara el callback, solo cambia visualmente
                end,

                GetValue = function()
                    return state
                end
            }
        end

        --//  FLOATING TOGGLE SIMPLE (CÁPSULA ELEGANTE)
        function Tab:CreateFloatingToggleSimple(text, default, callback)
            local state = default or false
            local TweenService = game:GetService("TweenService")
            
            --// CREAR FRAME PRINCIPAL (Cápsula)
            local FloatingWindow = mk("Frame", {
                Name = "FloatingToggleSimple_" .. text,
                Size = UDim2.new(0, 220, 0, 50),
                Position = UDim2.new(0.5, -110, 0.1, 0),
                BackgroundColor3 = Theme.Secondary,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                ZIndex = 150,
                CanQuery = true
            }, Window.ScreenGui)
            
            --// ESQUINAS REDONDEADAS
            corner(FloatingWindow, 999)
            
            --// BORDE
            stroke(FloatingWindow, Theme.Accent, 2, 0.5)
            
            --// FRAME CONTENEDOR PARA TEXTOS
            local TextContainer = mk("Frame", {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 151
            }, FloatingWindow)
            
            --// TEXTO DEL NOMBRE (Izquierda)
            local NameLabel = mk("TextLabel", {
                Size = UDim2.new(0.6, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 151
            }, TextContainer)
            NameLabel:SetAttribute("ThemeTextRole", "Text")
            
            --// TEXTO DEL ESTADO (Derecha)
            local StateLabel = mk("TextLabel", {
                Size = UDim2.new(0.35, 0, 1, 0),
                Position = UDim2.new(0.65, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = state and "ON" or "OFF",
                TextColor3 = state and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(155, 155, 155),
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 151
            }, TextContainer)
            
            --// EFECTO SHIMMER (UIGradient)
            local shimmerGradient = Instance.new("UIGradient")
            shimmerGradient.Rotation = 90
            shimmerGradient.ColorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255), 0.9),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255), 0),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255), 0.9)
            })
            shimmerGradient.Parent = FloatingWindow
            
            --// ANIMAR SHIMMER
            local shimmerTween = TweenService:Create(
                shimmerGradient,
                TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0),
                {Offset = Vector2.new(1, 0)}
            )
            shimmerTween:Play()
            track(shimmerTween)
            
            --// EFECTO BREATHING (Pulsación)
            local originalSize = FloatingWindow.Size
            local pulseSize = UDim2.new(0, 230, 0, 55)
            
            local pulseTween = TweenService:Create(
                FloatingWindow,
                TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0),
                {Size = pulseSize}
            )
            pulseTween:Play()
            track(pulseTween)
            
            --// DETECTOR DE CLICKS
            local ClickDetector = mk("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 152
            }, FloatingWindow)
            
            --// VARIABLES DE INTERACCIÓN
            local isDragging = false
            local dragStart = nil
            local dragStartPos = nil
            local isHovering = false
            
            --// FUNCIÓN PARA ACTUALIZAR ESTADO
            local function updateState()
                if state then
                    StateLabel.Text = "ON"
                    StateLabel.TextColor3 = Color3.fromRGB(76, 175, 80)
                else
                    StateLabel.Text = "OFF"
                    StateLabel.TextColor3 = Color3.fromRGB(155, 155, 155)
                end
            end
            
            --// HOVER EFFECT
            track(FloatingWindow.MouseEnter:Connect(function()
                isHovering = true
                TweenService:Create(
                    FloatingWindow,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.15}
                ):Play()
            end))
            
            track(FloatingWindow.MouseLeave:Connect(function()
                isHovering = false
                TweenService:Create(
                    FloatingWindow,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.3}
                ):Play()
            end))
            
            --// CLICK EFFECT Y TOGGLE
            track(ClickDetector.MouseButton1Click:Connect(function()
                state = not state
                updateState()
                
                --// SONIDO
                pcall(function() playSound(Sounds.Click, 0.6) end)
                
                --// EFECTO VISUAL DE PRESIÓN
                local pressSize = UDim2.new(0, 210, 0, 45)
                TweenService:Create(
                    FloatingWindow,
                    TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {Size = pressSize, BackgroundTransparency = 0.5}
                ):Play()
                
                task.wait(0.08)
                
                --// VOLVER AL TAMAÑO NORMAL
                TweenService:Create(
                    FloatingWindow,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = originalSize, BackgroundTransparency = isHovering and 0.15 or 0.3}
                ):Play()
                
                --// EJECUTAR CALLBACK
                if callback then
                    pcall(function() callback(state) end)
                end
                
                print("[" .. text .. "] " .. (state and " ACTIVADO" or " DESACTIVADO"))
            end))
            
            --// DRAG AND DROP
            track(FloatingWindow.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isHovering then
                    isDragging = true
                    dragStart = input.Position
                    dragStartPos = FloatingWindow.Position
                end
            end))
            
            track(UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - dragStart
                    FloatingWindow.Position = UDim2.new(
                        dragStartPos.X.Scale,
                        dragStartPos.X.Offset + delta.X,
                        dragStartPos.Y.Scale,
                        dragStartPos.Y.Offset + delta.Y
                    )
                end
            end))
            
            track(UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end))
            
            return FloatingWindow
        end

        --// 🎚️ SLIDER NATIVO PROFESIONAL (v26 - NUEVO)
        function Tab:CreateSlider(text, min, max, default, callback)
            local value = default or min
            local isDragging = false
            
            local Holder = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = Theme.Secondary,
                BackgroundTransparency = 0.5,
                ZIndex = 9
            })
            Holder:SetAttribute("ThemeRole", "Secondary")
            corner(Holder, 6)
            stroke(Holder, Theme.Stroke, 1, 0.6)

            local LabelTxt = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(0, 150, 0, 20),
                Position = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10
            })
            LabelTxt:SetAttribute("ThemeRole", "Text")

            local ValueLabel = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(0, 60, 0, 20),
                Position = UDim2.new(1, -70, 0, 8),
                BackgroundTransparency = 1,
                Text = tostring(math.floor(value * 100) / 100),
                TextColor3 = Theme.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 10
            })
            ValueLabel:SetAttribute("ThemeRole", "Accent")

            local SliderBackground = mk("Frame", {
                Parent = Holder,
                Size = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 0, 32),
                BackgroundColor3 = Theme.AccentOff,
                ZIndex = 10
            })
            SliderBackground:SetAttribute("ThemeRole", "AccentOff")
            corner(SliderBackground, 3)

            local SliderFill = mk("Frame", {
                Parent = SliderBackground,
                Size = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Theme.Accent,
                ZIndex = 11
            })
            SliderFill:SetAttribute("ThemeRole", "Accent")
            corner(SliderFill, 3)

            local SliderThumb = mk("Frame", {
                Parent = Holder,
                Size = UDim2.new(0, 16, 0, 24),
                Position = UDim2.new(0, 12, 0, 28),
                BackgroundColor3 = Theme.Accent,
                ZIndex = 12
            })
            SliderThumb:SetAttribute("ThemeRole", "Accent")
            corner(SliderThumb, 3)
            stroke(SliderThumb, Theme.Stroke, 1, 0.5)

            local function UpdateSlider(percentage)
                percentage = math.clamp(percentage, 0, 1)
                value = min + (max - min) * percentage
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                SliderThumb.Position = UDim2.new(0, 12 + (Holder.AbsoluteSize.X - 24) * percentage - 8, 0, 28)
                ValueLabel.Text = tostring(math.floor(value * 100) / 100)
                pcall(callback, value)
            end

            local function OnSliderClick(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                end
            end

            SliderBackground.InputBegan:Connect(OnSliderClick)
            SliderThumb.InputBegan:Connect(OnSliderClick)

            track(UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local relativeX = input.Position.X - SliderBackground.AbsolutePosition.X
                    local barWidth = SliderBackground.AbsoluteSize.X
                    local percentage = math.clamp(relativeX / barWidth, 0, 1)
                    UpdateSlider(percentage)
                    --  FIX v26.1: Eliminado playSound en InputChanged (generaba cacofonía)
                    -- El sonido se reproduce solo al soltar en InputEnded
                end
            end))

            --  FIX v26.1: Cambiar de UserInputService.InputEnded (GLOBAL) a SliderThumb.InputEnded (LOCAL)
            -- Ahora el sonido solo se reproduce al soltar DENTRO del slider, no en toda la pantalla
            track(SliderThumb.InputEnded:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    isDragging = false
                    playSound(Sounds.Click, 0.5)
                end
            end))

            UpdateSlider((value - min) / (max - min))
            resetScrollTop(TabPage)
            
            return {
                Set = function(newValue)
                    value = math.clamp(newValue, min, max)
                    UpdateSlider((value - min) / (max - min))
                end,
                Get = function()
                    return value
                end
            }
        end

        --// BOTÓN ESTÁNDAR
        function Tab:CreateButton(textSpanish, textEnglishOrCallback, callbackOrIcon, iconAsset)
            --// COMPATIBILIDAD: si el 2do argumento es string, es modo bilingüe.
            --// Si es function (o nil), es la firma antigua: (text, callback, iconAsset)
            local textEnglish = textSpanish
            local callback, icon

            if type(textEnglishOrCallback) == "string" then
                textEnglish = textEnglishOrCallback
                callback = callbackOrIcon
                icon = iconAsset
            else
                callback = textEnglishOrCallback
                icon = callbackOrIcon
            end

            local displayText = GetText(textSpanish, textEnglish)
            local iconAsset = icon

            local Btn = mk("TextButton", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Secondary,
                Text = iconAsset and "" or displayText,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 9
            }, TabPage)
            Btn:SetAttribute("ThemeRole", "Secondary")
            corner(Btn, 6)
            stroke(Btn, Theme.Stroke, 1, 0.6)
            resetScrollTop(TabPage)

            if iconAsset then
                mk("ImageLabel", {
                    Parent = Btn,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 8, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = iconAsset,
                    ZIndex = 10
                })
                local BtnLabel = mk("TextLabel", {
                    Parent = Btn,
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 32, 0, 0),
                    BackgroundTransparency = 1,
                    Text = displayText,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 10
                })
                BtnLabel:SetAttribute("ThemeTextRole", "Text")
                BtnLabel:SetAttribute("TextSpanish", textSpanish)
                BtnLabel:SetAttribute("TextEnglish", textEnglish)
            else
                --// Sin icono: el texto vive directo en el TextButton
                Btn:SetAttribute("TextSpanish", textSpanish)
                Btn:SetAttribute("TextEnglish", textEnglish)
            end

            Btn.MouseButton1Click:Connect(function()
                playSound(Sounds.Click, 0.6)
                TweenService:Create(Btn, TweenInfo.new(0.08), {BackgroundColor3 = Theme.Accent}):Play()
                task.wait(0.08)
                TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Secondary}):Play()
                pcall(callback)
            end)
            return Btn
        end

        --// LABEL
        function Tab:CreateLabel(textSpanish, textEnglishOrSize, fontSize)
            --// COMPATIBILIDAD: Si textEnglishOrSize es un número, es fontSize (código antiguo)
            local textEnglish = textSpanish
            if type(textEnglishOrSize) == "number" then
                --// Código antiguo: CreateLabel(text, fontSize)
                fontSize = textEnglishOrSize
                textEnglish = textSpanish
            elseif type(textEnglishOrSize) == "string" then
                --// Código nuevo: CreateLabel(textSpanish, textEnglish, fontSize)
                textEnglish = textEnglishOrSize
            end
            
            fontSize = fontSize or 14
            local displayText = GetText(textSpanish, textEnglish)
            
            local Label = mk("TextLabel", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text = displayText,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = fontSize,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                ZIndex = 9
            })
            Label:SetAttribute("ThemeTextRole", "Text")
            Label:SetAttribute("TextSpanish", textSpanish)
            Label:SetAttribute("TextEnglish", textEnglish)
            resetScrollTop(TabPage)
            return Label
        end

        --// DIVISOR
        function Tab:CreateDivider()
            local Divider = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Stroke,
                ZIndex = 9
            })
            Divider:SetAttribute("ThemeRole", "Stroke")
            return Divider
        end

        --// WELCOME CARD CON AVATAR DEL JUGADOR
        function Tab:CreateWelcomeCard()
            local Card = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 64),
                BackgroundColor3 = Theme.Secondary,
                ZIndex = 9
            })
            Card:SetAttribute("ThemeRole", "Secondary")
            corner(Card, 8)
            stroke(Card, Color3.fromRGB(0, 0, 0), 1, 0.6)

            local Avatar = mk("ImageLabel", {
                Parent = Card,
                Size = UDim2.new(0, 48, 0, 48),
                Position = UDim2.new(0, 8, 0.5, -24),
                BackgroundColor3 = Theme.AccentOff,
                ScaleType = Enum.ScaleType.Crop,
                ZIndex = 10
            })
            Avatar:SetAttribute("ThemeRole", "AccentOff")
            corner(Avatar, 999)

            mk("TextLabel", {
                Parent = Card,
                Size = UDim2.new(1, -68, 0, 20),
                Position = UDim2.new(0, 64, 0, 12),
                BackgroundTransparency = 1,
                Text = "Bienvenido,",
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Theme.TextDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10
            }):SetAttribute("ThemeRole", "TextDim")

            mk("TextLabel", {
                Parent = Card,
                Size = UDim2.new(1, -68, 0, 24),
                Position = UDim2.new(0, 64, 0, 30),
                BackgroundTransparency = 1,
                Text = LocalPlayer.Name,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 10
            }):SetAttribute("ThemeRole", "Text")

            task.spawn(function()
                local ok, content = pcall(function()
                    local thumb = Players:GetUserThumbnailAsync(
                        LocalPlayer.UserId,
                        Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size100x100
                    )
                    return thumb
                end)
                if ok and content and Avatar.Parent then
                    Avatar.Image = content
                end
            end)

            resetScrollTop(TabPage)
            return Card
        end

        --// SERVER INFO CARD CON ESTADÍSTICAS DEL SERVIDOR
        function Tab:CreateServerInfoCard()
            local Card = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ZIndex = 9
            })
            mk("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, Card)

            mk("TextLabel", {
                Parent = Card,
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = "Servidor",
                Font = Enum.Font.GothamBold,
                TextSize = 15,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 9
            }):SetAttribute("ThemeRole", "Text")

            local Grid = createStatGrid(Card)
            local _, playersVal = createStatTile(Grid, "Jugadores")
            local _, maxVal = createStatTile(Grid, "Máximo de jugadores")
            local _, pingVal = createStatTile(Grid, "Latencia")
            local _, idVal = createStatTile(Grid, "ID del servidor")
            local joinTile, joinVal = createStatTile(Grid, "Script de unión")
            local _, timeVal = createStatTile(Grid, "Tiempo en el servidor")

            idVal.Text = (game.JobId ~= "" and game.JobId) or "N/A (Studio)"
            joinVal.Text = "Tocar para copiar"

            local JoinClick = mk("TextButton", {
                Parent = joinTile,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 11
            })
            JoinClick.MouseButton1Click:Connect(function()
                local snippet = string.format(
                    'game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)',
                    game.PlaceId, game.JobId
                )
                local ok = pcall(function() setclipboard(snippet) end)
                joinVal.Text = ok and "¡Copiado!" or "No disponible"
                task.delay(2, function()
                    if joinVal and joinVal.Parent then
                        joinVal.Text = "Tocar para copiar"
                    end
                end)
            end)

            local startClock = os.clock()
            local StatsService = game:GetService("Stats")

            task.spawn(function()
                while Card.Parent do
                    playersVal.Text = tostring(#Players:GetPlayers())
                    maxVal.Text = tostring(Players.MaxPlayers)

                    local ok, ping = pcall(function()
                        return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
                    end)
                    pingVal.Text = (ok and ping) and (math.floor(ping) .. " ms") or "N/A"

                    timeVal.Text = formatDuration(os.clock() - startClock)
                    task.wait(1)
                end
            end)

            resetScrollTop(TabPage)
            return Card
        end

        return Tab
    end

    --// ════════════════════════════════════════════════════════════════
    --// FUNCIONES DE EFECTOS DE TEXTO (ANTES DE SetTheme - IMPORTANTE)
    --// ════════════════════════════════════════════════════════════════
    local textEffectConnection = nil
    Window.CurrentTextEffect = "Off"

    local function getAllTextObjects()
        local list = {}
        for _, obj in ipairs(Main:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                table.insert(list, obj)
            end
        end
        return list
    end

    local function applyTextColorToAll(color)
        for _, obj in ipairs(getAllTextObjects()) do
            pcall(function()
                obj.TextColor3 = color
            end)
        end
    end

    local function stopTextEffect()
        if textEffectConnection then
            textEffectConnection:Disconnect()
            textEffectConnection = nil
        end
    end

    --// ════════════════════════════════════════════════════════════════
    --// CAMBIO DE TEMA (SetTheme) 
    --// ════════════════════════════════════════════════════════════════

    function Window:SetTheme(themeName)
        if not setActiveTheme(themeName) then
            warn("Tema no encontrado: " .. tostring(themeName))
            return
        end
        
        self.CurrentTheme = themeName
        CurrentTheme = themeName  --  v26: Actualizar variable global

        for _, obj in ipairs(Main:GetDescendants()) do
            swapThemeColor(obj, Theme)
        end

        -- 🔧 RESETEAR TODOS LOS COLORES DE TEXTO AL NUEVO TEMA
        applyTextColorToAll(Theme.Text)

        --// MANEJO DE VIDEO FRAME vs IMAGE LABEL
        if themeName == "YinYangNewV1" then
            print("🎬 Activando tema YinYangNewV1...")
            --// Cambiar a VideoFrame
            if BackgroundArt and BackgroundArt.Parent then
                BackgroundArt.Visible = false
            end
            if CurrentVideoFrame and CurrentVideoFrame.Parent then
                CurrentVideoFrame.Visible = true
                print("✅ VideoFrame hecho visible")
                
                --// Descargar y asignar video
                local ok, videoAsset = pcall(function()
                    return EnsureVideoCached("YinYangNewV1")
                end)
                
                if ok and videoAsset then
                    pcall(function()
                        CurrentVideoFrame.Video = videoAsset
                        print("✅ Video asignado a VideoFrame")
                        CurrentVideoFrame:Play()
                        print("▶ Video iniciado")
                    end)
                else
                    print("❌ Error obteniendo asset de video")
                end
            else
                print("❌ CurrentVideoFrame no disponible")
            end
        else
            --// Cambiar a ImageLabel
            if CurrentVideoFrame and CurrentVideoFrame.Parent then
                CurrentVideoFrame.Visible = false
                pcall(function()
                    CurrentVideoFrame:Pause()
                    print("⏸ Video pausado")
                end)
            end
            if BackgroundArt and BackgroundArt.Parent then
                BackgroundArt.Visible = true
                pcall(function()
                    BackgroundArt.Image = ThemeBackgroundImages[themeName] or ""
                    print(" Imagen de fondo actualizada")
                end)
            end
        end

        --// 💾 v26: GUARDAR CONFIGURACIÓN AUTOMÁTICAMENTE
        SavedConfig.CurrentTheme = themeName
        SaveConfig()

        --//  v26: SONIDO DE CLICK DINÁMICO POR TEMA
        if ThemeClickSounds[themeName] then
            CurrentClickSound = ThemeClickSounds[themeName]
            print(" Tema " .. themeName .. " - Sonido de click personalizado activado")
        else
            CurrentClickSound = Sounds.Click
        end

        --//  SISTEMA DE EFECTO DINÁMICO POR TEMA
        if themeName == "CatV1" then
            self:SetTextEffect("CatRainbow")
            print(" Tema Cat V1 activado + Sonido personalizado")
        elseif themeName == "ErisV1" then
            self:SetTextEffect("ErisRainbow")
            print("🔴 Tema Eris V1 activado + Sonido personalizado")
        elseif themeName == "YinYangNewV1" then
            self:SetTextEffect("DarkWhiteRainbowEpic")
            print("✨ Tema Yin Yang New V1 activado + Video + Efecto épico")
        else
            self:SetTextEffect("Off")
        end
        
        CurrentTheme = themeName
    end

    -- mode: "Off" | "WhiteCyan" | "WhitePink" | "Rainbow"
    function Window:SetTextEffect(mode)
        stopTextEffect()
        Window.CurrentTextEffect = mode

        if mode == "Off" then
            -- Devuelve cada texto al color que le corresponde según su rol de tema actual
            for _, obj in ipairs(getAllTextObjects()) do
                local role = obj:GetAttribute("ThemeTextRole")
                if role and Theme[role] then
                    obj.TextColor3 = Theme[role]
                end
            end
            return
        end

        local elapsed = 0
        local RunService = game:GetService("RunService")

        if mode == "WhiteCyan" then
            -- Pulso suave entre blanco y celeste, "a ratos" (va y viene)
            local colorA = Color3.fromRGB(255, 255, 255)
            local colorB = Color3.fromRGB(120, 225, 255)
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local alpha = (math.sin(elapsed * 1.6) + 1) / 2
                applyTextColorToAll(colorA:Lerp(colorB, alpha))
            end))

        elseif mode == "WhitePink" then
            -- Igual que el anterior pero más lento y entre blanco y rosa
            local colorA = Color3.fromRGB(255, 255, 255)
            local colorB = Color3.fromRGB(255, 130, 205)
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local alpha = (math.sin(elapsed * 0.6) + 1) / 2
                applyTextColorToAll(colorA:Lerp(colorB, alpha))
            end))

        elseif mode == "Rainbow" then
            -- Recorre todo el espectro de color de forma continua y pareja
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local hue = (elapsed * 0.12) % 1
                applyTextColorToAll(Color3.fromHSV(hue, 0.85, 1))
            end))

        elseif mode == "CatRainbow" then
            --  EFECTO ESPECIAL PARA CAT V1: Oscilación rápida entre Rosa y Blanco
            -- 5x más rápido que Rainbow normal (0.2 seg por ciclo)
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local cycle = (elapsed * 5) % 1  -- 5 ciclos por segundo
                
                local color
                if cycle < 0.5 then
                    -- Primera mitad: Rosa (255, 100, 150) → Blanco (255, 255, 255)
                    local t = cycle * 2
                    color = Color3.fromRGB(
                        255,
                        math.floor(100 + (255 - 100) * t),
                        math.floor(150 + (255 - 150) * t)
                    )
                else
                    -- Segunda mitad: Blanco (255, 255, 255) → Rosa (255, 100, 150)
                    local t = (cycle - 0.5) * 2
                    color = Color3.fromRGB(
                        255,
                        math.floor(255 - (255 - 100) * t),
                        math.floor(255 - (255 - 150) * t)
                    )
                end
                
                applyTextColorToAll(color)
            end))

        elseif mode == "RainbowDarkWhite" then
            --  EFECTO RAINBOW DARK-WHITE: Transición lenta de Negro a Blanco
            -- Cambia muy lentamente (un ciclo cada 4 segundos)
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local cycle = (elapsed * 0.25) % 1  -- Un ciclo cada 4 segundos
                
                -- Interpola lentamente entre negro (0, 0, 0) y blanco (255, 255, 255)
                local color = Color3.fromRGB(
                    math.floor(255 * cycle),
                    math.floor(255 * cycle),
                    math.floor(255 * cycle)
                )
                
                applyTextColorToAll(color)
            end))

        elseif mode == "ErisRainbow" then
            -- 🔴 EFECTO ESPECIAL PARA ERIS V1: Transición lenta Rojo → Negro → Blanco
            -- 3 fases en un ciclo de 6 segundos: Rojo (2s) → Negro (2s) → Blanco (2s)
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local cycle = (elapsed * 0.167) % 1  -- Un ciclo cada 6 segundos (1/6 = 0.167)
                
                local color
                if cycle < 0.333 then
                    -- Primera fase (0-2s): Rojo (255, 0, 0) → Negro (0, 0, 0)
                    local t = cycle / 0.333
                    color = Color3.fromRGB(
                        math.floor(255 - 255 * t),  -- Rojo: 255 → 0
                        0,
                        0
                    )
                elseif cycle < 0.667 then
                    -- Segunda fase (2-4s): Negro (0, 0, 0) → Blanco (255, 255, 255)
                    local t = (cycle - 0.333) / 0.334
                    color = Color3.fromRGB(
                        math.floor(255 * t),
                        math.floor(255 * t),
                        math.floor(255 * t)
                    )
                else
                    -- Tercera fase (4-6s): Blanco (255, 255, 255) → Rojo (255, 0, 0)
                    local t = (cycle - 0.667) / 0.333
                    color = Color3.fromRGB(
                        255,
                        math.floor(255 - 255 * t),  -- Rojo: 255 → 0
                        math.floor(255 - 255 * t)   -- Azul: 255 → 0
                    )
                end
                
                applyTextColorToAll(color)
            end))

        elseif mode == "DarkWhiteRainbowEpic" then
            --// Efecto épico: Oscilación sinusoidal Negro ↔ Blanco con potencia
            RainbowDarkWhiteStart = tick()
            if RainbowDarkWhiteConnection then
                RainbowDarkWhiteConnection:Disconnect()
            end
            RainbowDarkWhiteConnection = track(RunService.Heartbeat:Connect(function()
                if not RainbowDarkWhiteLabels[1] then
                    RainbowDarkWhiteConnection:Disconnect()
                    return
                end
                
                local elapsedTime = tick() - RainbowDarkWhiteStart
                local sineWave = (math.sin(elapsedTime * math.pi) + 1) / 2
                local power = math.pow(sineWave, 1.5)
                local color = Color3.new(power, power, power)
                
                for _, label in ipairs(RainbowDarkWhiteLabels) do
                    if label and label.Parent then
                        label.TextColor3 = color
                    end
                end
            end))

        else
            warn("Efecto de texto no reconocido: " .. tostring(mode))
        end
    end

    function Window:Destroy()
        for _, conn in ipairs(globalConnections) do
            pcall(function() conn:Disconnect() end)
        end
        dragonConnection:Disconnect()
        ScreenGui:Destroy()
    end

    --// ════════════════════════════════════════════════════════════════
    --// CREAR AUTOMÁTICAMENTE LAS 3 PESTAÑAS SAGRADAS (v26 MEJORADO)
    --// ════════════════════════════════════════════════════════════════
    
    -- TAB 1: INICIO (Automático)
    local AutoTabInicio = Window:CreateTab("Inicio", "rbxassetid://124987849953130")
    AutoTabInicio:CreateWelcomeCard()
    AutoTabInicio:CreateDivider()
    AutoTabInicio:CreateServerInfoCard()
    
    -- TAB 2: TEMAS (Automático)
    local AutoTabTemas = Window:CreateTab("Temas", "rbxassetid://84419345138935")
    AutoTabTemas:CreateLabel("Temas Personalizados", 14)
    AutoTabTemas:CreateDivider()
    
    local temas = {
        "Dark", "DarkV2",
        "Red", "RedV2",
        "Pink", "PinkV2", "PinkV3",
        "Blue", "BlueV2",
        "White", "WhiteV2", "WhiteV3", "WhiteAndDark",
        "Green", "NaranjaV1", "VioletaV1",
        "CatV1",
        "LightV1",
        "ErisV1",
        "ShylfieV1",
        "YinYangNewV1"
    }
    
    for _, tema in ipairs(temas) do
        AutoTabTemas:CreateButton(tema, function()
            Window:SetTheme(tema)
        end)
    end
    
    -- TAB 3: EFECTOS (Automático)
    local AutoTabEfectos = Window:CreateTab("Efectos", "rbxassetid://114693810646148")
    AutoTabEfectos:CreateLabel("Efectos de Texto", 14)
    AutoTabEfectos:CreateDivider()
    
    AutoTabEfectos:CreateButton("⚪ Normal (Blanco)", function()
        Window:SetTextEffect("Off")
    end)
    
    AutoTabEfectos:CreateButton("💫 Blanco-Celeste", function()
        Window:SetTextEffect("WhiteCyan")
    end)
    
    AutoTabEfectos:CreateButton("💗 Blanco-Rosa", function()
        Window:SetTextEffect("WhitePink")
    end)
    
    AutoTabEfectos:CreateButton(" Arcoiris", function()
        Window:SetTextEffect("Rainbow")
    end)
    
    AutoTabEfectos:CreateButton(" Dark-White", function()
        Window:SetTextEffect("RainbowDarkWhite")
    end)

    --//  4TA PESTAÑA PERMANENTE: AJUSTES
    local AutoTabAjustes = Window:CreateTab("Ajustes", "rbxassetid://86797720103644")
    AutoTabAjustes:CreateLabel("Configuración", 14)
    AutoTabAjustes:CreateDivider()
    
    AutoTabAjustes:CreateToggle("Freeze Icono", false, function(state)
        IconoCongelado = state
        if Window.Dragon and Window.Dragon.Draggable then
            Window.Dragon.Draggable = not state
        end
        if state then
            AutoTabAjustes:CreateLabel("Icono congelado (No se puede mover)", 11)
        end
    end)
    
    --// ════════════════════════════════════════════════════════════════
    AutoTabAjustes:CreateDivider()
    AutoTabAjustes:CreateLabel("Sonidos", 12)
    AutoTabAjustes:CreateToggle("Sonidos Dinámicos", DynamicClickSoundsEnabled, function(state)
        DynamicClickSoundsEnabled = state
        AutoTabAjustes:CreateLabel(state and " Sonidos por tema activados" or " Sonidos desactivados", 11)
    end)
    
    AutoTabAjustes:CreateDivider()
    --// ════════════════════════════════════════════════════════════════
    --// SISTEMA DE IDIOMA (v28 PRO)
    --// ════════════════════════════════════════════════════════════════
    AutoTabAjustes:CreateLabel("Idioma / Language", 12)
    
    local SpanishToggle
    local EnglishToggle

    SpanishToggle = AutoTabAjustes:CreateToggle(
        "Español",
        "Spanish",
        LanguageSystem.CurrentLanguage == "es",
        function(state)
            if not state then return end

            ChangeLanguage("es")
            SaveLanguageConfig()

            if EnglishToggle then
                EnglishToggle:SetValue(false)
            end
        end
    )

    EnglishToggle = AutoTabAjustes:CreateToggle(
        "English",
        "English",
        LanguageSystem.CurrentLanguage == "en",
        function(state)
            if not state then return end

            ChangeLanguage("en")
            SaveLanguageConfig()

            if SpanishToggle then
                SpanishToggle:SetValue(false)
            end
        end
    )
    
    AutoTabAjustes:CreateDivider()
    AutoTabAjustes:CreateLabel(" Apariencia", 12)
    AutoTabAjustes:CreateLabel("Versión: v28 ULTRA MEJORADA", 10)
    AutoTabAjustes:CreateLabel("Chat Fullscreen:  ACTIVO", 10)
    AutoTabAjustes:CreateLabel("Colores Dinámicos:  ACTIVO", 10)

    
    --//  SISTEMA DE CHAT v27 (NUEVO)
    --// ════════════════════════════════════════════════════════════════
    
    --// Variables de Chat (Almacenamiento en memoria)
    local ChatMessages = {}
    local ChatTyping = {}
    local MAX_MESSAGES = 100
    local MAX_CHAR = 500
    
    --// Función: Agregar mensaje al chat
    local function AddChatMessage(playerName, playerUserId, message, timestamp)
        if #ChatMessages >= MAX_MESSAGES then
            table.remove(ChatMessages, 1)  -- Eliminar primer mensaje
        end
        
        table.insert(ChatMessages, {
            playerName = playerName,
            playerUserId = playerUserId,
            message = message,
            timestamp = timestamp or os.date("%H:%M:%S"),
        })
    end
    
    --// Función: Obtener historial de chat
    local function GetChatHistory()
        return ChatMessages
    end
    
    --// Función: Obtener avatar del jugador
    local function GetPlayerAvatar(userId)
        return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=48&height=48&format=png"
    end
    
    --// ═════════════════════════════════════════════════════════════════════
    --// CHAT SYSTEM
    --// ═════════════════════════════════════════════════════════════════════

    local ChatMessages = {}
    local MAX_MESSAGES = 100
    local MAX_CHAR = 500

    local function AddChatMessage(playerName, playerUserId, message, timestamp)
    	if #ChatMessages >= MAX_MESSAGES then
    		table.remove(ChatMessages, 1)
    	end

    	table.insert(ChatMessages, {
    		playerName = playerName or "Unknown",
    		playerUserId = playerUserId or 0,
    		message = message or "",
    		timestamp = timestamp or os.date("%H:%M:%S"),
    	})
    end

    local function GetChatHistory()
    	return ChatMessages
    end

    local function GetPlayerAvatar(userId)
    	userId = tonumber(userId) or 0
    	return ("rbxthumb://type=AvatarHeadShot&id=%d&w=48&h=48"):format(userId)
    end

    --// ═════════════════════════════════════════════════════════════════════
    --// CHAT GLOBAL BACKEND SYNC (v28 - Tiempo Real)
    --// ═════════════════════════════════════════════════════════════════════
    --// Backend: Node.js + Express corriendo en Replit
    --// Sincroniza mensajes entre TODOS los jugadores conectados
    --// ═════════════════════════════════════════════════════════════════════

    local BACKEND_URL = "https://global-chat-sync--tomasmichi13.replit.app"
    local ChatSyncPollRate = 2  -- segundos entre cada consulta al backend
    local knownServerIds = {}   -- IDs de mensajes de servidor ya renderizados
    local backendConnected = false

    --// Función universal de HTTP request
    --// Usa la función nativa del executor si existe (evita el error
    --// "The current thread cannot call this function (blocked)" que da
    --// HttpService:PostAsync en algunos executors móviles como Delta).
    --// Si no encuentra ninguna, cae a HttpService como último recurso.
    local UniversalRequest = (syn and syn.request)
        or (http and http.request)
        or fluxus_request
        or http_request
        or request
        or (function(opts)
            -- Fallback: HttpService (puede fallar en algunos executors)
            local method = opts.Method or "GET"
            local ok, body = pcall(function()
                if method == "POST" then
                    return HttpService:PostAsync(opts.Url, opts.Body or "", Enum.HttpContentType.ApplicationJson)
                else
                    return HttpService:GetAsync(opts.Url)
                end
            end)
            if ok then
                return { Success = true, Body = body, StatusCode = 200 }
            else
                return { Success = false, Body = tostring(body), StatusCode = 0 }
            end
        end)

    --// Enviar mensaje al backend (no bloqueante)
    local function BackendSendMessage(playerName, playerId, message)
        task.spawn(function()
            local body = HttpService:JSONEncode({
                playerName = tostring(playerName),
                playerId = tostring(playerId),
                message = tostring(message),
            })

            local ok, result = pcall(function()
                return UniversalRequest({
                    Url = BACKEND_URL .. "/api/chat/send",
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = body,
                })
            end)

            if not ok or not result or (result.Success == false) then
                warn("[ChatGlobal] Error al enviar mensaje al backend:", ok and (result and result.StatusCode) or result)
            end
        end)
    end

    --// Polling: pide mensajes nuevos cada ChatSyncPollRate segundos
    --// Se conecta después de crear el ChatTab (usa RenderMessage y AddChatMessage)
    local function StartBackendPolling(onNewMessage)
        task.spawn(function()
            while true do
                local ok, response = pcall(function()
                    return UniversalRequest({
                        Url = BACKEND_URL .. "/api/chat/messages",
                        Method = "GET",
                    })
                end)

                if ok and response and response.Body then
                    local success, data = pcall(HttpService.JSONDecode, HttpService, response.Body)
                    if success and data and data.messages then
                        if not backendConnected then
                            backendConnected = true
                            print("[ChatGlobal] Conectado al backend correctamente")
                        end

                        for _, msg in ipairs(data.messages) do
                            if not knownServerIds[msg.id] then
                                knownServerIds[msg.id] = true
                                -- Evitar re-mostrar el mensaje que YO mismo envié
                                if tostring(msg.playerId) ~= tostring(LocalPlayer.UserId) then
                                    task.spawn(onNewMessage, msg)
                                end
                            end
                        end
                    end
                else
                    if backendConnected then
                        warn("[ChatGlobal] Se perdió conexión con el backend")
                    end
                    backendConnected = false
                end

                task.wait(ChatSyncPollRate)
            end
        end)
    end

    local ChatTab = Window:CreateTab("Chat", "rbxassetid://105823588527532")
    local ChatTabPage = ChatTab.Page
    
    --// Deshabilitar el scroll de ChatTab.Page - Solo ChatContainer debe scrollear
    ChatTabPage.AutomaticCanvasSize = Enum.AutomaticSize.None
    ChatTabPage.CanvasSize = UDim2.new()
    ChatTabPage.ScrollBarThickness = 0
    ChatTabPage.ScrollingEnabled = false

    local ChatRoot = mk("Frame", {
    	Parent = ChatTabPage,
    	Size = UDim2.new(1, 0, 1, 0),
    	BackgroundTransparency = 1,
    	BorderSizePixel = 0,
    	LayoutOrder = 1,
    	ZIndex = 10,
    })

    --// Mini-header dentro de ChatRoot
    local ChatHeader = mk("Frame", {
    	Parent = ChatRoot,
    	Size = UDim2.new(1, 0, 0, 50),
    	Position = UDim2.new(0, 0, 0, 0),
    	BackgroundTransparency = 1,
    	BorderSizePixel = 0,
    	ZIndex = 10,
    })

    mk("UIListLayout", {
    	Parent = ChatHeader,
    	Padding = UDim.new(0, 8),
    	SortOrder = Enum.SortOrder.LayoutOrder,
    	VerticalAlignment = Enum.VerticalAlignment.Top,
    })

    local HeaderLabel = mk("TextLabel", {
    	Parent = ChatHeader,
    	Size = UDim2.new(1, 0, 0, 20),
    	BackgroundTransparency = 1,
    	Text = "🌐 Global Chat ° New",
    	Font = Enum.Font.GothamBold,
    	TextSize = 14,
    	TextColor3 = Theme.Text,
    	TextXAlignment = Enum.TextXAlignment.Left,
    	LayoutOrder = 1,
    	ZIndex = 11,
    })

    local HeaderDivider = mk("Frame", {
    	Parent = ChatHeader,
    	Size = UDim2.new(1, 0, 0, 1),
    	BackgroundColor3 = Theme.Stroke,
    	BorderSizePixel = 0,
    	LayoutOrder = 2,
    	ZIndex = 11,
    })

    local ChatContainer = mk("ScrollingFrame", {
    	Parent = ChatRoot,
    	Size = UDim2.new(1, 0, 1, -94),
    	Position = UDim2.new(0, 0, 0, 50),
    	BackgroundColor3 = Theme.Background,
    	BackgroundTransparency = 1,
    	BorderSizePixel = 0,
    	ScrollBarThickness = 2,
    	CanvasSize = UDim2.new(0, 0, 0, 0),
    	AutomaticCanvasSize = Enum.AutomaticSize.Y,
    	ScrollingDirection = Enum.ScrollingDirection.Y,
    	ClipsDescendants = true,
    	ZIndex = 11,
    })
    corner(ChatContainer, 6)

    mk("UIListLayout", {
    	Parent = ChatContainer,
    	Padding = UDim.new(0, 8),
    	SortOrder = Enum.SortOrder.LayoutOrder,
    	VerticalAlignment = Enum.VerticalAlignment.Top,
    })

    mk("UIPadding", {
    	Parent = ChatContainer,
    	PaddingTop = UDim.new(0, 6),
    	PaddingLeft = UDim.new(0, 8),
    	PaddingRight = UDim.new(0, 8),
    	PaddingBottom = UDim.new(0, 6),
    })

    local ChatFooter = mk("Frame", {
    	Parent = ChatRoot,
    	Size = UDim2.new(1, 0, 0, 44),
    	Position = UDim2.new(0, 0, 1, -44),
    	BackgroundTransparency = 1,
    	BorderSizePixel = 0,
    	ZIndex = 20,
    })

    local MessageInput = mk("TextBox", {
    	Parent = ChatFooter,
    	Size = UDim2.new(1, -76, 0, 36),
    	Position = UDim2.new(0, 8, 0.5, -18),
    	BackgroundColor3 = Theme.Secondary,
    	BackgroundTransparency = 0.25,
    	BorderSizePixel = 0,
    	Text = "",
    	ClearTextOnFocus = false,
    	PlaceholderText = "Escribir...",
    	PlaceholderColor3 = Theme.TextDim,
    	TextColor3 = Theme.Text,
    	TextSize = 13,
    	Font = Enum.Font.Gotham,
    	TextXAlignment = Enum.TextXAlignment.Left,
    	ZIndex = 21,
    })
    MessageInput:SetAttribute("ThemeRole", "Secondary")
    corner(MessageInput, 8)
    mk("UIPadding", {Parent = MessageInput, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})

    local SendButton = mk("ImageButton", {
    	Parent = ChatFooter,
    	Size = UDim2.new(0, 60, 0, 36),
    	Position = UDim2.new(1, -68, 0.5, -18),
    	BackgroundColor3 = Theme.Accent,
    	BorderSizePixel = 0,
    	Image = "rbxassetid://132362297660069",
    	ImageColor3 = Color3.fromRGB(255, 255, 255),
    	ScaleType = Enum.ScaleType.Fit,
    	ZIndex = 21,
    })
    SendButton:SetAttribute("ThemeRole", "Accent")
    corner(SendButton, 8)

    local CharLabel = mk("TextLabel", {
    	Parent = ChatFooter,
    	Size = UDim2.new(0, 90, 0, 12),
    	Position = UDim2.new(0, 0, 1, -10),
    	BackgroundTransparency = 1,
    	Text = "0 / 500",
    	Font = Enum.Font.Gotham,
    	TextSize = 9,
    	TextColor3 = Theme.TextDim,
    	TextXAlignment = Enum.TextXAlignment.Left,
    	ZIndex = 21,
    })

    local function ScrollChatToBottom()
    	task.defer(function()
    		task.wait()
    		if ChatContainer and ChatContainer.Parent then
    			ChatContainer.CanvasPosition = Vector2.new(0, math.max(0, ChatContainer.AbsoluteCanvasSize.Y))
    		end
    	end)
    end

    --// ════════════════════════════════════════════════════════════════
    --// SISTEMA DE BURBUJAS POR USUARIO
    --// ════════════════════════════════════════════════════════════════

    local UserBubbleAssets = {}
    local UserBubbleStyles = {}

    local function NormalizeUserId(userId)
        return tonumber(userId) or 0
    end

    local function GetContrast(bgColor)
        if typeof(bgColor) ~= "Color3" then
            return Color3.fromRGB(255, 255, 255)
        end

        local luminance = (bgColor.R * 0.299) + (bgColor.G * 0.587) + (bgColor.B * 0.114)
        if luminance >= 0.58 then
            return Color3.fromRGB(25, 25, 25)
        end

        return Color3.fromRGB(255, 255, 255)
    end

    function Window:SetUserBubbleAsset(userId, assetId)
        userId = NormalizeUserId(userId)
        if userId == 0 then
            return
        end

        if assetId == nil or assetId == "" then
            UserBubbleAssets[userId] = nil
            return
        end

        UserBubbleAssets[userId] = tostring(assetId)
    end

    function Window:SetUserBubbleStyle(userId, style)
        userId = NormalizeUserId(userId)
        if userId == 0 then
            return
        end

        if type(style) ~= "table" then
            UserBubbleStyles[userId] = nil
            return
        end

        UserBubbleStyles[userId] = table.clone(style)
    end

    local function GetUserBubbleAsset(userId)
        return UserBubbleAssets[NormalizeUserId(userId)]
    end

    local function GetUserBubbleStyle(userId)
        return UserBubbleStyles[NormalizeUserId(userId)] or {}
    end

    --// ════════════════════════════════════════════════════════════════
    --// SISTEMA DE EFECTOS ESPECIALES - ADMIN (MOUSOZA)
    --// ════════════════════════════════════════════════════════════════
    
    local ADMIN_USER_ID = 9549448191
    local ADMIN_ASSET = "rbxassetid://81745105398770"
    
    -- Ciclos de colores para mousoza
    local MouseozaNameColors = {
        Color3.fromRGB(255, 255, 0),      -- Amarillo
        Color3.fromRGB(255, 165, 0),      -- Naranja
        Color3.fromRGB(0, 0, 0),          -- Negro
    }
    
    local MouseozaBorderColors = {
        Color3.fromRGB(255, 255, 255),    -- Blanco
        Color3.fromRGB(0, 0, 0),          -- Negro
    }
    
    local function StartMouseozaNameCycle(UsernameLabel)
        local colorIndex = 1
        local cycleDuration = 2.5
        local colorCount = #MouseozaNameColors
        
        task.spawn(function()
            while UsernameLabel and UsernameLabel.Parent do
                UsernameLabel.TextColor3 = MouseozaNameColors[colorIndex]
                colorIndex = (colorIndex % colorCount) + 1
                task.wait(cycleDuration / colorCount)
            end
        end)
    end
    
    local function StartMouseozaBorderCycle(Bubble, strokeThickness)
        local borderIndex = 1
        local cycleDuration = 2.5
        local borderCount = #MouseozaBorderColors
        
        task.spawn(function()
            while Bubble and Bubble.Parent do
                local stroke = Bubble:FindFirstChild("UIStroke")
                if stroke then
                    stroke.Color = MouseozaBorderColors[borderIndex]
                end
                borderIndex = (borderIndex % borderCount) + 1
                task.wait(cycleDuration / borderCount)
            end
        end)
    end

    local function RenderMessage(playerName, userId, messageText, timeStamp, isSelf)
    	local style = GetUserBubbleStyle(userId)
    	local assetId = GetUserBubbleAsset(userId)

    	local baseColor = style.BackgroundColor3 or (isSelf and Theme.Accent or Theme.Secondary)
    	local baseTransparency = style.BackgroundTransparency
    	    or (assetId and 0.16 or (isSelf and 0.14 or 0.22))

    	local frameTextColor = style.TextColor3 or (assetId and GetContrast(baseColor) or (isSelf and Color3.fromRGB(255, 255, 255) or Theme.Text))
    	local nameColor = style.NameColor3 or (assetId and GetContrast(baseColor) or (isSelf and Color3.fromRGB(200, 255, 200) or Theme.Accent))
    	local strokeColor = style.StrokeColor3 or Theme.Stroke
    	local cornerRadius = style.CornerRadius or 12

    	--// ════════════════════════════════════════════════════════════════
    	--// ESTRUCTURA PROFESIONAL: TARJETA INDEPENDIENTE
    	--// ════════════════════════════════════════════════════════════════

    	-- CONTENEDOR PRINCIPAL DE LA TARJETA
    	local MessageFrame = mk("Frame", {
    	    Parent = ChatContainer,
    	    Size = UDim2.new(1, 0, 0, 0),
    	    AutomaticSize = Enum.AutomaticSize.Y,
    	    BackgroundTransparency = 1,
    	    BorderSizePixel = 0,
    	    ClipsDescendants = false,
    	    LayoutOrder = #ChatMessages,
    	    ZIndex = 12,
    	})

    	-- AVATAR: Arriba izquierda, alineado al inicio
    	local AvatarLabel = mk("ImageLabel", {
    	    Parent = MessageFrame,
    	    Size = UDim2.new(0, 36, 0, 36),
    	    Position = UDim2.new(0, 0, 0, 0),
    	    BackgroundColor3 = style.AvatarBgColor3 or (isSelf and Theme.Accent or Theme.AccentOff),
    	    BackgroundTransparency = style.AvatarBgTransparency or 0.05,
    	    BorderSizePixel = 0,
    	    Image = GetPlayerAvatar(userId),
    	    ScaleType = Enum.ScaleType.Crop,
    	    ZIndex = 14,
    	})
    	corner(AvatarLabel, 999)
    	stroke(AvatarLabel, strokeColor, 1, 0.45)

    	-- CONTENEDOR DE CONTENIDO (Header + Bubble)
    	local ContentFrame = mk("Frame", {
    	    Parent = MessageFrame,
    	    Size = UDim2.new(1, -46, 0, 0),
    	    Position = UDim2.new(0, 46, 0, 0),
    	    AutomaticSize = Enum.AutomaticSize.Y,
    	    BackgroundTransparency = 1,
    	    BorderSizePixel = 0,
    	    ClipsDescendants = false,
    	    ZIndex = 12,
    	})

    	-- LAYOUT VERTICAL PARA HEADER + BUBBLE
    	mk("UIListLayout", {
    	    Parent = ContentFrame,
    	    Padding = UDim.new(0, 4),
    	    SortOrder = Enum.SortOrder.LayoutOrder,
    	    VerticalAlignment = Enum.VerticalAlignment.Top,
    	})

    	--// HEADER: Nombre y Hora
    	local HeaderFrame = mk("Frame", {
    	    Parent = ContentFrame,
    	    Size = UDim2.new(1, 0, 0, 16),
    	    BackgroundTransparency = 1,
    	    BorderSizePixel = 0,
    	    LayoutOrder = 1,
    	    ZIndex = 15,
    	})

    	-- Nombre del usuario (Destacado)
    	local UsernameLabel = mk("TextLabel", {
    	    Parent = HeaderFrame,
    	    Size = UDim2.new(0, 0, 1, 0),
    	    Position = UDim2.new(0, 0, 0, 0),
    	    BackgroundTransparency = 1,
    	    Text = (isSelf and "Tú" or tostring(playerName or "Unknown")),
    	    Font = Enum.Font.GothamBold,
    	    TextSize = 12,
    	    TextColor3 = nameColor,
    	    TextXAlignment = Enum.TextXAlignment.Left,
    	    TextYAlignment = Enum.TextYAlignment.Center,
    	    AutomaticSize = Enum.AutomaticSize.X,
    	    ZIndex = 15,
    	})
    	UsernameLabel:SetAttribute("ThemeTextRole", "Text")

    	--// EFECTOS ESPECIALES PARA MOUSOZA
    	if userId == ADMIN_USER_ID then
    	    StartMouseozaNameCycle(UsernameLabel)
    	    -- Configurar asset especial para mousoza
    	    if not assetId then
    	        assetId = ADMIN_ASSET
    	    end
    	end

    	-- Hora (Discreta, gris)
    	local TimeLabel = mk("TextLabel", {
    	    Parent = HeaderFrame,
    	    Size = UDim2.new(1, 0, 1, 0),
    	    Position = UDim2.new(0, 0, 0, 0),
    	    BackgroundTransparency = 1,
    	    Text = tostring(timeStamp or os.date("%H:%M:%S")),
    	    Font = Enum.Font.Gotham,
    	    TextSize = 10,
    	    TextColor3 = Theme.TextDim,
    	    TextXAlignment = Enum.TextXAlignment.Right,
    	    TextYAlignment = Enum.TextYAlignment.Center,
    	    ZIndex = 15,
    	})
    	TimeLabel:SetAttribute("ThemeTextRole", "Text")

    	--// BURBUJA: Contenedor adaptativo para el texto
    	local Bubble = mk("Frame", {
    	    Parent = ContentFrame,
    	    Size = UDim2.new(1, 0, 0, 0),
    	    AutomaticSize = Enum.AutomaticSize.Y,
    	    BackgroundColor3 = baseColor,
    	    BackgroundTransparency = baseTransparency,
    	    BorderSizePixel = 0,
    	    ClipsDescendants = true,
    	    LayoutOrder = 2,
    	    ZIndex = 12,
    	})
    	Bubble:SetAttribute("ThemeRole", isSelf and "Accent" or "Secondary")
    	corner(Bubble, cornerRadius)
    	stroke(Bubble, strokeColor, 1.25, 0.35)

    	--// EFECTOS DE BORDES PARA MOUSOZA
    	if userId == ADMIN_USER_ID then
    	    StartMouseozaBorderCycle(Bubble, 1.25)
    	end

    	-- PADDING INTERNO: 10px en todos lados
    	mk("UIPadding", {
    	    Parent = Bubble,
    	    PaddingTop = UDim.new(0, 10),
    	    PaddingBottom = UDim.new(0, 10),
    	    PaddingLeft = UDim.new(0, 10),
    	    PaddingRight = UDim.new(0, 10),
    	})

    	-- Asset de fondo opcional
    	if assetId then
    	    local BubbleAsset = mk("ImageLabel", {
    	        Parent = Bubble,
    	        Size = UDim2.new(1, 0, 1, 0),
    	        Position = UDim2.new(0, 0, 0, 0),
    	        BackgroundTransparency = 1,
    	        Image = assetId,
    	        ImageTransparency = style.ImageTransparency or 0.55,
    	        ImageColor3 = style.AssetTintColor3 or Color3.fromRGB(255, 255, 255),
    	        ScaleType = Enum.ScaleType.Crop,
    	        ZIndex = 12,
    	    })

    	    local Wash = mk("Frame", {
    	        Parent = Bubble,
    	        Size = UDim2.new(1, 0, 1, 0),
    	        BackgroundColor3 = style.AssetWashColor3 or baseColor,
    	        BackgroundTransparency = style.AssetWashTransparency or 0.45,
    	        BorderSizePixel = 0,
    	        ZIndex = 12,
    	    })
    	    Wash.Active = false
    	end

    	-- TEXTO DEL MENSAJE: Solo texto en la burbuja
    	local MessageLabel = mk("TextLabel", {
    	    Parent = Bubble,
    	    Size = UDim2.new(1, 0, 0, 0),
    	    BackgroundTransparency = 1,
    	    Text = tostring(messageText or ""),
    	    Font = Enum.Font.GothamBold,
    	    TextSize = 13,
    	    TextColor3 = frameTextColor,
    	    TextWrapped = true,
    	    TextXAlignment = Enum.TextXAlignment.Left,
    	    TextYAlignment = Enum.TextYAlignment.Top,
    	    AutomaticSize = Enum.AutomaticSize.Y,
    	    ZIndex = 15,
    	})
    	MessageLabel:SetAttribute("ThemeTextRole", "Text")

    	--// ANIMACIÓN DE APARICIÓN: Transición suave (0.15s)
    	Bubble.BackgroundTransparency = baseTransparency + 1
    	AvatarLabel.ImageTransparency = 1

    	local tweenInfo = TweenInfo.new(
    	    0.15,
    	    Enum.EasingStyle.Quad,
    	    Enum.EasingDirection.Out
    	)

    	local tweenBubble = TweenService:Create(Bubble, tweenInfo, {BackgroundTransparency = baseTransparency})
    	local tweenAvatar = TweenService:Create(AvatarLabel, tweenInfo, {ImageTransparency = 0})

    	tweenBubble:Play()
    	tweenAvatar:Play()

    	ScrollChatToBottom()
    end

    local function SendMessage()
    	local messageText = MessageInput.Text or ""
    	messageText = messageText:sub(1, MAX_CHAR)

    	if messageText:match("^%s*$") then
    		return
    	end

    	local localPlayer = Players.LocalPlayer
    	local timestamp = os.date("%H:%M:%S")

    	AddChatMessage(localPlayer.Name, localPlayer.UserId, messageText, timestamp)
    	RenderMessage(localPlayer.Name, localPlayer.UserId, messageText, timestamp, true)

    	-- Sincronizar con el backend para que otros jugadores lo reciban
    	BackendSendMessage(localPlayer.Name, localPlayer.UserId, messageText)

    	MessageInput.Text = ""
    	CharLabel.Text = "0 / 500"
    end

    MessageInput.Changed:Connect(function(property)
    	if property ~= "Text" then
    		return
    	end

    	if #MessageInput.Text > MAX_CHAR then
    		MessageInput.Text = MessageInput.Text:sub(1, MAX_CHAR)
    	end

    	CharLabel.Text = tostring(#MessageInput.Text) .. " / " .. tostring(MAX_CHAR)
    end)

    SendButton.MouseButton1Click:Connect(SendMessage)

    MessageInput.FocusLost:Connect(function(enterPressed)
    	if enterPressed then
    		SendMessage()
    	end
    end)

    function Window:SendChatMessage(text)
    	MessageInput.Text = tostring(text or ""):sub(1, MAX_CHAR)
    	SendMessage()
    end

    function Window:GetChatHistory()
    	return GetChatHistory()
    end

    function Window:ReceiveMessage(playerName, userId, message)
    	local timestamp = os.date("%H:%M:%S")
    	AddChatMessage(playerName, userId, message, timestamp)
    	RenderMessage(playerName, userId, message, timestamp, false)
    end

    Window.ChatMessages = ChatMessages
    Window.ChatRoot = ChatRoot
    Window.ChatContainer = ChatContainer
    Window.ChatFooter = ChatFooter
    Window.MessageInput = MessageInput
    Window.SendButton = SendButton
    Window.CharLabel = CharLabel
    Window.AddChatMessage = AddChatMessage
    Window.RenderChatMessage = RenderMessage
    Window.SendMessage = SendMessage

    --// Iniciar sincronización en tiempo real con el backend
    --// Cada mensaje nuevo de OTRO jugador se agrega y renderiza automáticamente
    StartBackendPolling(function(msg)
        AddChatMessage(msg.playerName, msg.playerId, msg.message, os.date("%H:%M:%S", msg.timestamp))
        RenderMessage(msg.playerName, msg.playerId, msg.message, os.date("%H:%M:%S", msg.timestamp), false)
    end)

    --// ════════════════════════════════════════════════════════════════
    --// UPDATE LOOP - Cambio instantáneo de idioma
    --// ════════════════════════════════════════════════════════════════
    local lastLanguage = LanguageSystem.CurrentLanguage
    RunService.RenderStepped:Connect(function()
        if LanguageSystem.CurrentLanguage ~= lastLanguage then
            lastLanguage = LanguageSystem.CurrentLanguage
            
            --// Actualizar todos los elementos con TextSpanish/TextEnglish
            for _, tabData in ipairs(Window.Tabs or {}) do
                if tabData.Button then
                    local span = tabData.Button:GetAttribute("TextSpanish")
                    local eng = tabData.Button:GetAttribute("TextEnglish")
                    if span and eng then
                        for _, child in ipairs(tabData.Button:GetChildren()) do
                            if child:IsA("TextLabel") then
                                child.Text = GetText(span, eng)
                            end
                        end
                    end
                end
                
                if tabData.Page then
                    for _, element in ipairs(tabData.Page:GetDescendants()) do
                        if element:IsA("TextLabel") or element:IsA("TextButton") then
                            local span = element:GetAttribute("TextSpanish")
                            local eng = element:GetAttribute("TextEnglish")
                            if span and eng then
                                element.Text = GetText(span, eng)
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return Window

end

--// ============================================================
--// LIBRERÍA GLOBAL - LISTA PARA USAR
--// ============================================================
--// YinYang es accesible globalmente como _G.YinYang
--// Uso desde otros scripts:
--//
--// local YinYang = _G.YinYang
--// local UI = YinYang:CreateWindow("Mi UI", "Dark")
--// local Tab = UI:CreateTab("Inicio")
--// Tab:CreateWelcomeCard()
--// Tab:CreateServerInfoCard()
--// Tab:CreateButton("Mi Botón", function() print("Click!") end)
--// Tab:CreateToggle("Toggle", false, function(state) print(state) end)
--// Tab:CreateDropdown("Category", {"Op1", "Op2"}, "Op1", function(val) print(val) end)
--// Tab:CreateMultiDropdown("Blacklist", {"A", "B", "C"}, {}, function(tbl) print(table.concat(tbl, ",")) end)
--//
--// ============================================================

print(" Yin Yang v24 CON TEMA CAT V1  - ¡Librería cargada y lista para usar!")

--// ============================================================
--// DEMO VISUAL - MUESTRA TODAS LAS CARACTERÍSTICAS
--// ============================================================
--// INSTRUCCIONES:
--// - Para ACTIVAR la demo: Cambia "DEMO_ACTIVO" a true
--// - Para DESACTIVAR: Cambia "DEMO_ACTIVO" a false
--// ============================================================

local DEMO_ACTIVO = true  --  DESACTIVADA - La librería crea las pestañas automáticamente

if DEMO_ACTIVO then
    task.wait(0.5)
    
    print("\n" .. string.rep("=", 60))
    print("INICIANDO DEMO VISUAL DE YIN YANG v24 - LIBRERÍA PROFESIONAL")
    print(string.rep("=", 60))
    
    --// 💾 v26: CARGAR CONFIGURACIÓN GUARDADA AL INICIAR
    local ConfigCargada = LoadConfig()
    local TemaInicial = "Dark"
    if ConfigCargada and ConfigCargada.theme then
        TemaInicial = ConfigCargada.theme
    end

    local DemoUI = _G.YinYang:CreateWindow("Yin Yang - DEMO v26", TemaInicial)
    
    --//  APLICAR TEMA GUARDADO - Re-pinta TODOS los colores, no solo la variable
    DemoUI:SetTheme(TemaInicial)
    
    -- =========================================================
    -- TAB INICIO (PROTEGIDA Y PERMANENTE)
    -- =========================================================
    local TabFeatures = DemoUI:CreateTab("Features")
    
    TabFeatures:CreateLabel("Toggles Flotantes", 14)
    TabFeatures:CreateDivider()
    
    TabFeatures:CreateFloatingToggle("Aimbot", false, function(state)
        print("Aimbot: " .. (state and "ON" or "OFF"))
    end)
    
    TabFeatures:CreateFloatingToggle("ESP", false, function(state)
        print("ESP: " .. (state and "ON" or "OFF"))
    end)
    
    TabFeatures:CreateFloatingToggle("GodMode", false, function(state)
        print("GodMode: " .. (state and "ON" or "OFF"))
    end)
    
    -- =========================================================
    -- TAB EFECTOS
    -- =========================================================
    local TabEfectos = DemoUI:CreateTab("Efectos")
    
    TabEfectos:CreateLabel("Efectos de Texto Disponibles", 12)
    TabEfectos:CreateDivider()
    
    TabEfectos:CreateLabel("Texto Normal", 11)
    TabEfectos:CreateButton("⚪ Normal (Blanco)", function()
        DemoUI:SetTextEffect("Off")
        print("Efecto: Normal (Texto blanco)")
    end)
    
    TabEfectos:CreateDivider()
    TabEfectos:CreateLabel("Efectos de 2 Colores", 11)
    
    TabEfectos:CreateButton("💫 Blanco - Celeste (Pulso)", function()
        DemoUI:SetTextEffect("WhiteCyan")
        print("Efecto: Pulso suave entre blanco y celeste")
    end)
    
    TabEfectos:CreateButton("💗 Blanco - Rosa (Pulso)", function()
        DemoUI:SetTextEffect("WhitePink")
        print("Efecto: Pulso lento entre blanco y rosa")
    end)
    
    TabEfectos:CreateDivider()
    TabEfectos:CreateLabel("Efecto Rainbow (Espectro Completo)", 11)
    
    TabEfectos:CreateButton(" Arcoiris Completo", function()
        DemoUI:SetTextEffect("Rainbow")
        print("Efecto: Espectro completo de colores!")
    end)
    
    print("\n DEMO v24 INICIADA")
    print("TABS: Inicio (Protegida) | Temas (16 colores sin duplicados) | Features | Dropdowns | Efectos")
    print(" MEJORAS: Sin duplicados, Pestañas permanentes, Efectos de texto mejorados")
    print("Para desactivar la demo, cambia DEMO_ACTIVO a false\n")
    print(string.rep("=", 60) .. "\n")
    
    -- Aplicar efecto Rainbow al tema cargado
    task.wait(0.2)
    DemoUI:SetTextEffect("Rainbow")
    print(" Efecto: " .. TemaInicial .. " + Rainbow (Yin-Yang Theme)")
else
    print("Yin Yang v24 - DEMO DESACTIVADA (DEMO_ACTIVO = false)")
    print("Solo la librería está cargada y lista para usar")
end

--// ============================================================
--// FIN DE LA DEMO
--// ============================================================
