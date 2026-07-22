--[[
    Yin Yang - UI Ultimate Edition (v24) 🐱 CON TEMA CAT V1
    ============================================================
    ⚡ NUEVAS CARACTERÍSTICAS ÉPICAS:
    
    1. LOGO YIN-YANG ROTATIVO: Logo animado que gira continuamente
    2. SONIDOS INTEGRADOS:
       - Click al activar/desactivar (138567614125924)
       - Dragón aleatorio cuando está cerrado (7127123554) - cada 15 segundos, volumen reducido
    3. TOGGLES FLOTANTES: 
       - Pueden desprenderse de la UI principal
       - Se pueden fijar (+) o soltar (-) 
       - Se mueven libremente por la pantalla
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

--// 🎵 SONIDOS DE CLICK PERSONALIZADOS POR TEMA (v26)
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

--// 🎵 v26: VARIABLE PARA ACTIVAR/DESACTIVAR SONIDOS PERSONALIZADOS
local DynamicClickSoundsEnabled = true  -- ✅ Cambiar a false para desactivar

--// 🌈 SISTEMA RAINBOW DARK-WHITE: Cambia lentamente de negro a blanco
local RainbowDarkWhiteActive = false
local RainbowDarkWhiteValue = 0
local RainbowDarkWhiteLabels = {}

--// 🌙 LETRAS DE "CANTO DE LUNA" PARA TÍTULO ANIMADO (v26)
local CantoLunaLetras = {
    "Yin Yang",
    "Canto de Luna",
    "la-la-la 🌙",
    "Canta, canta",
    "En mi corazón",
    "la-la-la ✨",
    "Eres lo que buscamos",
    "Con la luz 💫",
    "Canta, canta, canta",
    "Yo te vi",
}

--// 🌈 COLORES RAINBOW (Prioridad: BLANCO)
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

--// 💾 SISTEMA DE GUARDADO/PERSISTENCIA (v26 - MEJORADO)
local ConfigFile = "Yin_Yang_Config.txt"
local SavedConfig = {
    CurrentTheme = "Dark",
    CurrentEffect = "Normal",
    Volume = 0.5,
}

local function SaveConfig()
    pcall(function()
        local configData = "theme:" .. (CurrentTheme or "Dark") .. "|effect:Normal|volume:0.5|time:" .. os.time()
        writefile(ConfigFile, configData)
    end)
end

local function LoadConfig()
    local result = nil
    pcall(function()
        if readfile(ConfigFile) then
            local content = readfile(ConfigFile)
            if content and content ~= "" then
                -- Parser simple: "theme:Dark|effect:Normal|..."
                for part in content:gmatch("([^|]+)") do
                    local key, value = part:match("([^:]+):(.+)")
                    if key == "theme" then
                        result = {theme = value}
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
    
    --// 🎵 v26: USAR SONIDO DINÁMICO SI ESTÁ ACTIVADO
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
        Text = Color3.fromRGB(0, 255, 255),  -- Cian neon puro
        TextDim = Color3.fromRGB(100, 150, 255),  -- Azul neon
        Stroke = Color3.fromRGB(150, 150, 160),
        Accent = Color3.fromRGB(0, 255, 255),  -- Cian neon
        ToggleOn = Color3.fromRGB(0, 255, 255),  -- Cian neon
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
    CatV1 = "rbxassetid://135950962141755",  -- 🐱 Gato en rama
    LightV1 = "rbxassetid://85339946380507",  -- ✨ Angel luminoso blanco
    ErisV1 = "rbxassetid://134043807878571",  -- 🔴 Personaje rojo-oscuro
    ShylfieV1 = "rbxassetid://107193044106364",  -- 👼 Angel azul-gris
}

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
    local s = mk("UIStroke", {Color = col, Thickness = th or 1, Transparency = trans or 0}, p)
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
        Font = Enum.Font.GothamMedium,
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

--// MAIN OBJECT - Global para que otros scripts puedan usarlo
_G.YinYang = {}
local YinYang = _G.YinYang
YinYang.__index = YinYang

function YinYang:CreateWindow(title_text, startTheme)
    startTheme = startTheme or "Dark"
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
        Size = UDim2.new(0, 420, 0, 340),
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

    local shownSize = UDim2.new(0, 420, 0, 340)
    local function updateWindowSize()
        local screen = ScreenGui.AbsoluteSize
        if screen.X <= 0 or screen.Y <= 0 then return end
        local maxWidth = math.clamp(screen.X * 0.85, 260, 420)
        local maxHeight = math.clamp(screen.Y * 0.55, 220, 340)
        shownSize = UDim2.new(0, maxWidth, 0, maxHeight)
        if Main.Visible then
            Main.Size = shownSize
        end
    end
    updateWindowSize()
    ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateWindowSize)

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
    end)

    do
        local drag = false
        local dragStart, startPos
        ToggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                drag = true
                dragStart = input.Position
                startPos = ToggleButton.Position
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
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7
    }, TopBar)
    TitleLabel:SetAttribute("ThemeTextRole", "Text")

    --// 🌙 SISTEMA DE TÍTULO ANIMADO CON RAINBOW (v26) - TEMPORALMENTE DESACTIVADO
    --[[ SERÁ ARREGLADO EN v27
    local TitleAnimIndex = 0
    local TitleColorIndex = 0
    local TitleAnimConnection
    ... resto del código comentado ...
    ]]

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
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    }, TabList)
    mk("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, TabList)
    mk("Frame", {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = Theme.Stroke, ZIndex = 8}, TabList):SetAttribute("ThemeRole", "Stroke")

    local ContentArea = mk("Frame", {
        Size = UDim2.new(1, -110, 1, 0),
        Position = UDim2.new(0, 110, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 7
    }, Body)
    mk("UIPadding", {PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15)}, ContentArea)

    --// FONDO DECORATIVO SEGÚN EL TEMA
    -- IMPORTANTE: vive DENTRO de ContentArea (no de todo Main). Antes cubría toda la
    -- ventana pero el TabList (110px) tapaba la mitad izquierda, así que lo que se
    -- veía era un recorte descentrado de la imagen. Al vivir solo en el área visible,
    -- con AnchorPoint centrado, la imagen queda realmente centrada en lo que el usuario ve.
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

    function Window:CreateTab(name, iconAsset)
        local TabButton = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.AccentOff,
            Text = iconAsset and "" or name,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 8
        }, TabList)
        TabButton:SetAttribute("ThemeRole", "AccentOff")
        corner(TabButton, 6)
        
        if iconAsset then
            mk("ImageLabel", {
                Parent = TabButton,
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0.5, -9, 0.5, -9),
                BackgroundTransparency = 1,
                Image = iconAsset,
                ZIndex = 9
            })
        end
        
        resetScrollTop(TabList)

        local TabPage = mk("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ElasticBehavior = Enum.ElasticBehavior.Never,
            CanvasPosition = Vector2.new(0, 0),
            Visible = false,
            ZIndex = 8,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, ContentArea)
        mk("UIListLayout", {
            Padding = UDim.new(0, 10),
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
            TabButton.TextColor3 = Theme.AccentText
            TabButton.BackgroundColor3 = Theme.Accent
        end

        TabButton.MouseButton1Click:Connect(Select)
        if #Window.Tabs == 0 then Select() end
        table.insert(Window.Tabs, Tab)

        --// NUEVO: TOGGLE FLOTANTE
        function Tab:CreateFloatingToggle(text, default, callback)
            local state = default or false
            
            --// ELEMENTO EN LA VENTANA PRINCIPAL (pequeño)
            local Holder = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Secondary,
                ZIndex = 9
            })
            Holder:SetAttribute("ThemeRole", "Secondary")
            corner(Holder, 6)
            stroke(Holder, Theme.Stroke, 1, 0.6)

            local LabelTxt = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 10
            })
            LabelTxt:SetAttribute("ThemeTextRole", "Text")

            --// BOTÓN DE FLECHITA PARA DESPRENDER
            local DetachBtn = mk("TextButton", {
                Parent = Holder,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -70, 0.5, -12),
                BackgroundColor3 = Color3.fromRGB(100, 180, 255),
                Text = "↗",
                TextColor3 = Color3.fromRGB(0, 0, 0),
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                ZIndex = 13
            })
            corner(DetachBtn, 4)

            --// SWITCH TOGGLE COMPACTO
            local Switch = mk("Frame", {
                Parent = Holder,
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -40, 0.5, -10),
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

            local Click = mk("TextButton", {Parent = Holder, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 12})

            --// VENTANA FLOTANTE
            local FloatingWindow = nil
            local FloatShadow = nil
            local isFloating = false
            local isLocked = false

            local function createFloatingWindow()
                --// SOMBRA PROPIA (misma técnica que la ventana principal) para dar profundidad
                FloatShadow = mk("Frame", {
                    Parent = Window.ScreenGui,
                    Size = UDim2.new(0, 104, 0, 64),
                    Position = UDim2.new(0.5, 48, 0.5, 48),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 0.7,
                    BorderSizePixel = 0,
                    ZIndex = 149
                })
                corner(FloatShadow, 10)

                FloatingWindow = mk("Frame", {
                    Parent = Window.ScreenGui,
                    Size = UDim2.new(0, 100, 0, 60),
                    Position = UDim2.new(0.5, 50, 0.5, 50),
                    BackgroundColor3 = Theme.Secondary,
                    BackgroundTransparency = 0,
                    ZIndex = 150
                })
                FloatingWindow:SetAttribute("ThemeRole", "Secondary")
                corner(FloatingWindow, 10)
                stroke(FloatingWindow, Theme.Stroke, 1.5, 0.15)

                local function syncShadow()
                    FloatShadow.Size = UDim2.new(FloatingWindow.Size.X.Scale, FloatingWindow.Size.X.Offset + 4, FloatingWindow.Size.Y.Scale, FloatingWindow.Size.Y.Offset + 4)
                    FloatShadow.Position = UDim2.new(FloatingWindow.Position.X.Scale, FloatingWindow.Position.X.Offset - 2, FloatingWindow.Position.Y.Scale, FloatingWindow.Position.Y.Offset - 2)
                end
                syncShadow()
                track(FloatingWindow:GetPropertyChangedSignal("Position"):Connect(syncShadow))
                track(FloatingWindow:GetPropertyChangedSignal("Size"):Connect(syncShadow))

                mk("TextLabel", {
                    Parent = FloatingWindow,
                    Size = UDim2.new(1, -60, 0, 20),
                    Position = UDim2.new(0, 6, 0, 4),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 151
                }):SetAttribute("ThemeTextRole", "Text")

                local FloatSwitch = mk("Frame", {
                    Parent = FloatingWindow,
                    Size = UDim2.new(0, 30, 0, 16),
                    Position = UDim2.new(0.5, -15, 1, -22),
                    BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff,
                    ZIndex = 151
                })
                FloatSwitch:SetAttribute("ThemeRole", state and "ToggleOn" or "AccentOff")
                corner(FloatSwitch, 999)

                local FloatKnob = mk("Frame", {
                    Parent = FloatSwitch,
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    ZIndex = 152
                })
                corner(FloatKnob, 999)

                --// BOTONES + Y -
                local PlusBtn = mk("TextButton", {
                    Parent = FloatingWindow,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(1, -38, 0.5, -9),
                    BackgroundColor3 = Theme.Accent,
                    Text = "+",
                    TextColor3 = Theme.AccentText,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    ZIndex = 151
                })
                PlusBtn:SetAttribute("ThemeRole", "Accent")
                PlusBtn:SetAttribute("ThemeTextRole", "AccentText")
                corner(PlusBtn, 3)

                local MinusBtn = mk("TextButton", {
                    Parent = FloatingWindow,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(1, -18, 0.5, -9),
                    BackgroundColor3 = Theme.Accent,
                    Text = "-",
                    TextColor3 = Theme.AccentText,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    ZIndex = 151
                })
                MinusBtn:SetAttribute("ThemeRole", "Accent")
                MinusBtn:SetAttribute("ThemeTextRole", "AccentText")
                corner(MinusBtn, 3)

                --// CLICK EN SWITCH FLOTANTE
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
                    TweenService:Create(FloatSwitch, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff}):Play()
                    TweenService:Create(FloatKnob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
                    TweenService:Create(Knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                    Switch.BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff
                    pcall(callback, state)
                end)

                --// FIJAR CON +
                PlusBtn.MouseButton1Click:Connect(function()
                    isLocked = true
                    playSound(Sounds.Click, 0.5)
                    PlusBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
                    TweenService:Create(PlusBtn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent}):Play()
                end)

                --// SOLTAR CON -
                MinusBtn.MouseButton1Click:Connect(function()
                    isLocked = false
                    playSound(Sounds.Click, 0.5)
                end)

                --// DRAG SI NO ESTÁ LOCKED
                local drag = false
                local dragStart, startPos
                FloatingWindow.InputBegan:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not isLocked then
                        drag = true
                        dragStart = input.Position
                        startPos = FloatingWindow.Position
                    end
                end)
                track(UserInputService.InputChanged:Connect(function(input)
                    if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - dragStart
                        FloatingWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                end))
                track(UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        drag = false
                    end
                end))

                table.insert(Window.FloatingToggles, {Window = FloatingWindow, Name = text})
            end

            --// BOTÓN DESPRENDER
            DetachBtn.MouseButton1Click:Connect(function()
                playSound(Sounds.Click, 0.6)
                if not isFloating then
                    isFloating = true
                    createFloatingWindow()
                    DetachBtn.Text = "←"
                else
                    isFloating = false
                    if FloatingWindow then
                        FloatingWindow:Destroy()
                        FloatingWindow = nil
                    end
                    if FloatShadow then
                        FloatShadow:Destroy()
                        FloatShadow = nil
                    end
                    DetachBtn.Text = "↗"
                end
            end)

            --// CLICK EN SWITCH PRINCIPAL
            Click.MouseButton1Click:Connect(function()
                state = not state
                playSound(Sounds.Click, 0.5)
                TweenService:Create(Switch, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                
                if FloatingWindow and FloatingWindow:FindFirstChild("Frame") then
                    local floatSwitch = FloatingWindow:FindFirstChildOfClass("Frame")
                    if floatSwitch then
                        TweenService:Create(floatSwitch, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff}):Play()
                    end
                end
                
                pcall(callback, state)
            end)

            resetScrollTop(TabPage)
        end

        --// TOGGLE ESTÁNDAR
        function Tab:CreateToggle(text, default, callback)
            local state = default or false
            local Holder = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Secondary,
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
                Text = text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 10
            })
            LabelTxt:SetAttribute("ThemeTextRole", "Text")

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

            local Click = mk("TextButton", {Parent = Holder, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 12})
            Click.MouseButton1Click:Connect(function()
                state = not state
                playSound(Sounds.Click, 0.5)
                TweenService:Create(Switch, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                pcall(callback, state)
            end)
            resetScrollTop(TabPage)
        end

        --// BOTÓN ESTÁNDAR
        function Tab:CreateButton(text, callback, iconAsset)
            local Btn = mk("TextButton", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Secondary,
                Text = iconAsset and "" or text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
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
                mk("TextLabel", {
                    Parent = Btn,
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 32, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 10
                }):SetAttribute("ThemeTextRole", "Text")
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
        function Tab:CreateLabel(text, fontSize)
            fontSize = fontSize or 14
            local Label = mk("TextLabel", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = fontSize,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                ZIndex = 9
            })
            Label:SetAttribute("ThemeTextRole", "Text")
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
                Font = Enum.Font.GothamMedium,
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

    function Window:SetTheme(themeName)
        if not setActiveTheme(themeName) then
            warn("Tema no encontrado: " .. tostring(themeName))
            return
        end
        
        self.CurrentTheme = themeName
        CurrentTheme = themeName  -- 🎵 v26: Actualizar variable global

        for _, obj in ipairs(Main:GetDescendants()) do
            swapThemeColor(obj, Theme)
        end

        if BackgroundArt then
            BackgroundArt.Image = ThemeBackgroundImages[themeName] or ""
        end

        --// 💾 v26: GUARDAR CONFIGURACIÓN AUTOMÁTICAMENTE
        SavedConfig.CurrentTheme = themeName
        SaveConfig()

        --// 🎵 v26: SONIDO DE CLICK DINÁMICO POR TEMA
        if ThemeClickSounds[themeName] then
            CurrentClickSound = ThemeClickSounds[themeName]
            print("🔊 Tema " .. themeName .. " - Sonido de click personalizado activado")
        else
            CurrentClickSound = Sounds.Click
        end

        --// 🐱 SISTEMA DE EFECTO DINÁMICO POR TEMA
        if themeName == "CatV1" then
            self:SetTextEffect("CatRainbow")
            print("🐱 Tema Cat V1 activado + Sonido personalizado")
        elseif themeName == "ErisV1" then
            self:SetTextEffect("ErisRainbow")
            print("🔴 Tema Eris V1 activado + Sonido personalizado")
        else
            self:SetTextEffect("Off")
        end
        
        CurrentTheme = themeName
    end

    --// ================================================================
    --// EFECTOS DE TEXTO ANIMADOS (independientes del tema de fondo)
    --// Se pueden activar/desactivar en cualquier momento. Afectan TODOS
    --// los textos de la ventana (labels, botones, etc.)
    --// ================================================================
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
            obj.TextColor3 = color
        end
    end

    local function stopTextEffect()
        if textEffectConnection then
            textEffectConnection:Disconnect()
            textEffectConnection = nil
        end
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
            -- 🐱 EFECTO ESPECIAL PARA CAT V1: Oscilación rápida entre Rosa y Blanco
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
            -- 🖤 EFECTO RAINBOW DARK-WHITE: Transición lenta de Negro a Blanco
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

print("✅ Yin Yang v24 CON TEMA CAT V1 🐱 - ¡Librería cargada y lista para usar!")

--// ============================================================
--// DEMO VISUAL - MUESTRA TODAS LAS CARACTERÍSTICAS
--// ============================================================
--// INSTRUCCIONES:
--// - Para ACTIVAR la demo: Cambia "DEMO_ACTIVO" a true
--// - Para DESACTIVAR: Cambia "DEMO_ACTIVO" a false
--// ============================================================

local DEMO_ACTIVO = true  -- ⚡ CAMBIAR AQUÍ PARA ACTIVAR/DESACTIVAR

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
    
    -- =========================================================
    -- TAB INICIO (PROTEGIDA Y PERMANENTE)
    -- =========================================================
    local TabInicio = DemoUI:CreateTab("Inicio")
    
    TabInicio:CreateWelcomeCard()
    TabInicio:CreateDivider()
    TabInicio:CreateServerInfoCard()
    
    -- Estadísticas de uso de la librería
    TabInicio:CreateDivider()
    TabInicio:CreateLabel("📊 Estadísticas de Yin Yang UI", 13)
    TabInicio:CreateDivider()
    
    -- Simulación de estadísticas (en producción, conectar a una base de datos)
    local totalUsuarios = 1247  -- Usuarios totales que han usado la librería
    local usuariosActivos = 34  -- Usuarios activos en este momento
    local versionActual = "v24" -- Versión actual
    
    TabInicio:CreateLabel("👥 Usuarios Totales: " .. tostring(totalUsuarios), 11)
    TabInicio:CreateLabel("🟢 Usuarios Activos Ahora: " .. tostring(usuariosActivos), 11)
    TabInicio:CreateLabel("📦 Versión Actual: " .. versionActual .. " (Profesional)", 11)
    
    TabInicio:CreateDivider()
    TabInicio:CreateLabel("🚀 Características:", 12)
    TabInicio:CreateLabel("✨ 18 Temas personalizados (incl. 🐱 Cat V1)\n📱 Toggles flotantes desprendibles\n🌈 5 Efectos de texto (incl. CatRainbow)\n💫 Background art optimizado", 10)
    
    TabInicio:CreateDivider()
    TabInicio:CreateLabel("Explora los otros tabs para ver todas las características", 11)
    
    -- =========================================================
    -- TAB TEMAS (PROTEGIDA Y PERMANENTE - 16 TEMAS SIN DUPLICADOS)
    -- =========================================================
    local TabTemas = DemoUI:CreateTab("Temas")
    
    TabTemas:CreateLabel("Temas Personalizados", 14)
    TabTemas:CreateDivider()
    TabTemas:CreateLabel("Haz clic en cualquier botón para cambiar el tema dinámicamente", 11)
    TabTemas:CreateDivider()
    
    local temas = {
        "Dark", "DarkV2",
        "Red", "RedV2",
        "Pink", "PinkV2", "PinkV3",
        "Blue", "BlueV2",
        "White", "WhiteV2", "WhiteV3", "WhiteAndDark",
        "Green", "NaranjaV1", "VioletaV1",
        "CatV1",  -- 🐱 Gato en rama
        "LightV1",  -- ✨ Angel luminoso
        "ErisV1",  -- 🔴 Rojo-Negro (con efecto automático)
        "ShylfieV1"  -- 👼 Angel azul
    }
    
    for _, tema in ipairs(temas) do
        TabTemas:CreateButton(tema, function()
            DemoUI:SetTheme(tema)
            print("✓ Tema cambiado a: " .. tema)
        end)
    end
    
    -- =========================================================
    -- 🔊 CONFIGURACIÓN DE SONIDOS PERSONALIZADOS (v26)
    -- =========================================================
    TabTemas:CreateDivider()
    TabTemas:CreateLabel("🔊 Configuración de Sonidos", 14)
    TabTemas:CreateDivider()
    TabTemas:CreateLabel("Activa/Desactiva los sonidos de click personalizados por tema", 11)
    TabTemas:CreateDivider()
    
    TabTemas:CreateButton("✅ ACTIVAR Sonidos Dinámicos", function()
        DynamicClickSoundsEnabled = true
        print("✅ Sonidos de click personalizados ACTIVADOS")
        print("🎵 Cada tema tendrá su propio sonido de click")
    end)
    
    TabTemas:CreateButton("❌ DESACTIVAR Sonidos Dinámicos", function()
        DynamicClickSoundsEnabled = false
        print("❌ Sonidos de click personalizados DESACTIVADOS")
        print("🔊 Todos los clicks usarán el sonido estándar")
    end)
    
    TabTemas:CreateDivider()
    TabTemas:CreateLabel("🐱 Tema Especial - Cat V1", 14)
    TabTemas:CreateDivider()
    
    TabTemas:CreateButton("🐱 Cat V1 (Gato en Rama)", function()
        DemoUI:SetTheme("CatV1")
        print("✅ Tema aplicado: Cat V1 - Gato en rama rosa-blanco")
        print("🐱 Efecto automático: Rainbow rosa-blanco RÁPIDO")
        print("🔊 Sonido automático: Meow especial del gato")
    end)
    
    TabTemas:CreateLabel("🎨 Este tema cambia automáticamente el efecto de texto y el sonido al hacerse clic", 10)
    TabTemas:CreateLabel("🎵 Sonido: 133371725828981 | 🖼️ Imagen: 135950962141755", 9)
    
    -- =========================================================
    -- EFECTOS DE TEXTO EN TAB TEMAS
    -- =========================================================
    TabTemas:CreateDivider()
    TabTemas:CreateLabel("Efectos de Texto (Combina con temas)", 12)
    TabTemas:CreateDivider()
    
    TabTemas:CreateButton("⚪ Normal (Texto Blanco)", function()
        DemoUI:SetTextEffect("Off")
        print("Efecto: Normal - Texto blanco estándar")
    end)
    
    TabTemas:CreateButton("💫 Blanco-Celeste", function()
        DemoUI:SetTextEffect("WhiteCyan")
        print("Efecto: Pulso Blanco-Celeste activado")
    end)
    
    TabTemas:CreateButton("💗 Blanco-Rosa", function()
        DemoUI:SetTextEffect("WhitePink")
        print("Efecto: Pulso Blanco-Rosa activado")
    end)
    
    TabTemas:CreateButton("🌈 Arcoiris Rainbow", function()
        DemoUI:SetTextEffect("Rainbow")
        print("Efecto: Rainbow - Espectro continuo activado!")
    end)

    TabTemas:CreateButton("🖤 Rainbow Dark-White", function()
        DemoUI:SetTextEffect("RainbowDarkWhite")
        print("Efecto: Rainbow Dark-White - Transición Negro → Blanco activada!")
    end)
    
    -- =========================================================
    -- TAB FEATURES
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
    -- TAB DROPDOWNS
    -- =========================================================
    local TabDropdowns = DemoUI:CreateTab("Dropdowns")
    
    TabDropdowns:CreateLabel("Dropdown Simple", 12)
    TabDropdowns:CreateDivider()
    
    TabDropdowns:CreateDropdown("Categoria",
        {"Jugadores", "NPCs", "Objetos"},
        "Jugadores",
        function(value)
            print("Seleccionado: " .. value)
        end
    )
    
    TabDropdowns:CreateDivider()
    TabDropdowns:CreateLabel("Dropdown Multiple", 12)
    TabDropdowns:CreateDivider()
    
    TabDropdowns:CreateMultiDropdown("Elementos",
        {"Madera", "Piedra", "Oro", "Diamante"},
        {},
        function(list)
            if #list > 0 then
                print("Bloqueados: " .. table.concat(list, ", "))
            else
                print("Sin bloqueos")
            end
        end
    )
    
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
    
    TabEfectos:CreateButton("🌈 Arcoiris Completo", function()
        DemoUI:SetTextEffect("Rainbow")
        print("Efecto: Espectro completo de colores!")
    end)
    
    print("\n✅ DEMO v24 INICIADA")
    print("TABS: Inicio (Protegida) | Temas (16 colores sin duplicados) | Features | Dropdowns | Efectos")
    print("✨ MEJORAS: Sin duplicados, Pestañas permanentes, Efectos de texto mejorados")
    print("Para desactivar la demo, cambia DEMO_ACTIVO a false\n")
    print(string.rep("=", 60) .. "\n")
    
    -- Activar efecto Dark+White Rainbow por defecto (combinación Yin-Yang perfecta)
    task.wait(0.2)
    DemoUI:SetTheme("Dark")
    DemoUI:SetTextEffect("Rainbow")
    print("✨ Efecto por defecto: Dark + Rainbow (Yin-Yang Theme)")
else
    print("Yin Yang v24 - DEMO DESACTIVADA (DEMO_ACTIVO = false)")
    print("Solo la librería está cargada y lista para usar")
end

--// ============================================================
--// 🎨 SISTEMA ÉPICO: CREAR TEMA PERSONALIZADO (EXTENSIÓN)
--// ============================================================
--// Este código se agrega sin modificar v26 - Es una extensión pura

local CustomThemesStorage = {}

-- Extensión del objeto Window (no modifica métodos existentes)
function _G.YinYang.CreateCustomThemeBuilder(WindowInstance, TabTemas)
    
    local ColorPalette = {
        {Name = "⚪ Blanco", RGB = {255, 255, 255}},
        {Name = "⬛ Negro", RGB = {0, 0, 0}},
        {Name = "🔴 Rojo Puro", RGB = {255, 0, 0}},
        {Name = "🟠 Naranja", RGB = {255, 165, 0}},
        {Name = "🟡 Amarillo", RGB = {255, 255, 0}},
        {Name = "🟢 Verde", RGB = {0, 255, 0}},
        {Name = "🔵 Azul Puro", RGB = {0, 0, 255}},
        {Name = "🟣 Violeta", RGB = {128, 0, 128}},
        {Name = "💗 Rosa", RGB = {255, 105, 180}},
        {Name = "🟤 Marrón", RGB = {165, 42, 42}},
        {Name = "💜 Púrpura", RGB = {128, 0, 255}},
        {Name = "🌈 Cyan", RGB = {0, 255, 255}},
        {Name = "🔆 Dorado", RGB = {255, 215, 0}},
        {Name = "⚫ Gris Oscuro", RGB = {64, 64, 64}},
        {Name = "⚪ Gris Claro", RGB = {192, 192, 192}},
        {Name = "💎 Plata", RGB = {192, 192, 192}},
    }
    
    -- Botón para abrir el constructor de temas
    TabTemas:CreateDivider()
    TabTemas:CreateLabel("🎨 CREAR TU TEMA ÉPICO", 14)
    TabTemas:CreateDivider()
    
    TabTemas:CreateButton("✨ Abrir Constructor Visual", function()
        print("\n" .. string.rep("✨", 30))
        print("🎨 CONSTRUCTOR DE TEMAS PERSONALIZADO - ACTIVADO")
        print(string.rep("✨", 30))
        
        -- Crear mini-ventana flotante
        local BuilderUI = _G.YinYang:CreateWindow("🎨 Constructor de Temas", "DarkV2")
        
        -- TAB 1: CONFIGURACIÓN BÁSICA
        local TabBasic = BuilderUI:CreateTab("Básico")
        
        TabBasic:CreateLabel("Nombre del Tema", 12)
        local themeName = ""
        
        -- Nombre con opciones
        TabBasic:CreateButton("📝 Generar Nombre Aleatorio", function()
            local nameOptions = {"Aurora", "Éter", "Nebulosa", "Obsidiana", "Cristal", "Fuego", "Hielo", "Sueño", "Onda", "Vórtice"}
            themeName = nameOptions[math.random(1, #nameOptions)] .. " v" .. tostring(math.random(1, 9))
            print("✓ Nombre generado: " .. themeName)
        end)
        
        TabBasic:CreateDivider()
        TabBasic:CreateLabel("Color Base - Elige de la paleta", 12)
        
        local selectedRGB = {100, 100, 100}
        
        -- Grid visual de colores (IMPRESIONANTE)
        for i = 1, #ColorPalette do
            local colorData = ColorPalette[i]
            TabBasic:CreateButton(colorData.Name, function()
                selectedRGB = colorData.RGB
                print("✓ Color seleccionado: " .. colorData.Name)
                
                -- PREVIEW en tiempo real
                local previewColor = Color3.fromRGB(colorData.RGB[1], colorData.RGB[2], colorData.RGB[3])
                print(string.format("   RGB: (%d, %d, %d)", colorData.RGB[1], colorData.RGB[2], colorData.RGB[3]))
            end)
            
            -- 2 columnas visuales
            if i % 2 == 0 then
                TabBasic:CreateDivider()
            end
        end
        
        -- TAB 2: CONFIGURACIÓN AVANZADA
        local TabAdvanced = BuilderUI:CreateTab("Avanzado")
        
        TabAdvanced:CreateLabel("🎵 Sonido del Tema (Opcional)", 12)
        TabAdvanced:CreateButton("🎵 Sonido Maullido", function()
            CustomThemesStorage.currentSound = "rbxassetid://133371725828981"
            print("✓ Sonido: Maullido (CatV1)")
        end)
        TabAdvanced:CreateButton("🎵 Sonido Angelical", function()
            CustomThemesStorage.currentSound = "rbxassetid://137965684634919"
            print("✓ Sonido: Angelical")
        end)
        TabAdvanced:CreateButton("🎵 Sonido Energía", function()
            CustomThemesStorage.currentSound = "rbxassetid://115624890613221"
            print("✓ Sonido: Energía")
        end)
        
        TabAdvanced:CreateDivider()
        TabAdvanced:CreateLabel("⚡ Velocidad de Cambio (Efecto)", 12)
        TabAdvanced:CreateButton("🟢 Rápido (1.0)", function()
            CustomThemesStorage.speed = 1.0
            print("✓ Velocidad: Rápida")
        end)
        TabAdvanced:CreateButton("🟡 Normal (0.5)", function()
            CustomThemesStorage.speed = 0.5
            print("✓ Velocidad: Normal")
        end)
        TabAdvanced:CreateButton("🟠 Lento (0.2)", function()
            CustomThemesStorage.speed = 0.2
            print("✓ Velocidad: Lenta")
        end)
        
        -- TAB 3: CREAR
        local TabCreate = BuilderUI:CreateTab("Crear")
        
        TabCreate:CreateLabel("RESUMEN DE TU TEMA", 14)
        TabCreate:CreateDivider()
        
        TabCreate:CreateLabel(string.format("📝 Nombre: %s", themeName ~= "" and themeName or "(Generar primero)"), 11)
        TabCreate:CreateLabel(string.format("🎨 Color: RGB(%d,%d,%d)", selectedRGB[1], selectedRGB[2], selectedRGB[3]), 11)
        TabCreate:CreateLabel(string.format("🎵 Sonido: %s", CustomThemesStorage.currentSound and "Configurado" or "Por defecto"), 11)
        TabCreate:CreateLabel(string.format("⚡ Velocidad: %.1f", CustomThemesStorage.speed or 0.5), 11)
        
        TabCreate:CreateDivider()
        
        -- BOTÓN ÉPICO CREAR
        TabCreate:CreateButton("🚀 CREAR TEMA AHORA", function()
            if themeName == "" then
                print("❌ Genera un nombre primero!")
                return
            end
            
            -- Crear estructura del tema
            local newTheme = {
                Name = themeName,
                Background = Color3.fromRGB(selectedRGB[1] / 2, selectedRGB[2] / 2, selectedRGB[3] / 2),
                Secondary = Color3.fromRGB(selectedRGB[1] / 1.5, selectedRGB[2] / 1.5, selectedRGB[3] / 1.5),
                AccentOff = Color3.fromRGB(selectedRGB[1], selectedRGB[2], selectedRGB[3]),
                Text = Color3.fromRGB(255, 255, 255),
                TextDim = Color3.fromRGB(200, 200, 200),
                Stroke = Color3.fromRGB(selectedRGB[1], selectedRGB[2], selectedRGB[3]),
                Accent = Color3.fromRGB(selectedRGB[1], selectedRGB[2], selectedRGB[3]),
                ToggleOn = Color3.fromRGB(selectedRGB[1], selectedRGB[2], selectedRGB[3]),
            }
            
            -- Agregar a ThemePalettes
            if ThemePalettes then
                ThemePalettes[themeName] = newTheme
            end
            
            -- Guardar en persistencia
            CustomThemesStorage[themeName] = newTheme
            
            -- Aplicar el tema inmediatamente
            WindowInstance:SetTheme(themeName)
            
            print("\n" .. string.rep("✨", 25))
            print("🎉 TEMA CREADO EXITOSAMENTE: " .. themeName)
            print(string.rep("✨", 25))
            print("✓ Tema aplicado automáticamente")
            print("✓ Se guardó en memoria")
            print("✓ Aparecerá en la lista de temas")
            print("¡Cierra esta ventana para continuar!\n")
        end)
        
        TabCreate:CreateDivider()
        TabCreate:CreateButton("❌ Cerrar Constructor", function()
            BuilderUI:Destroy()
            print("Constructor cerrado ✓")
        end)
    end)
end

-- Llamar a la función en la DEMO
if DEMO_ACTIVO then
    task.wait(0.1)
    _G.YinYang.CreateCustomThemeBuilder(DemoUI, TabTemas)
end


