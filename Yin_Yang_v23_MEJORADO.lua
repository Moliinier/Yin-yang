--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║  Yin Yang - UI Ultimate Edition (v23) - VERSIÓN MEJORADA      ║
    ║  ============================================================  ║
    ║  CAMBIOS EN v23:                                               ║
    ║  • TAB "INICIO" FIJO - No se puede eliminar                   ║
    ║    - Muestra avatar del jugador                                ║
    ║    - Info del servidor (jugadores, máximo)                     ║
    ║    - Bienvenida personalizada                                  ║
    ║                                                                 ║
    ║  • TAB "🎨 TEMAS" FIJO - No se puede eliminar                 ║
    ║    - Selector visual de temas                                  ║
    ║    - Vista previa de colores                                   ║
    ║    - Cambio instantáneo                                        ║
    ║                                                                 ║
    ║  • El usuario SOLO puede crear tabs adicionales                ║
    ║    via Window:CreateCustomTab(nombre)                          ║
    ║                                                                 ║
    ║  TOKENS:                                                       ║
    ║  - Yin-Yang: 84935900372278                                    ║
    ║  - Click Sound: 138567614125924                                ║
    ║  - Dragon Sound: 7127123554                                    ║
    ╚═══════════════════════════════════════════════════════════════╝
--]]

-- ⚠️ INSTRUCCIONES DE USO:
-- 1. Reemplaza la función Window:CreateTab() en tu librería original con esta
-- 2. Agrega las funciones nuevas: _CreateStartTab(), _CreateThemesTab(), CreateCustomTab()
-- 3. Llama a _CreateStartTab() y _CreateThemesTab() ANTES de retornar Window

-- ============================================================
-- FUNCIÓN PRIVADA: Crear TAB INICIO (FIJO)
-- ============================================================
local function createStartTab(Window, TabList, ContentArea, Theme, mk, corner, stroke, track, LocalPlayer, Players, game)
    --// CREAR BOTÓN TAB
    local TabButton = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Accent,  -- Activo por defecto
        Text = "🏠 INICIO",
        TextColor3 = Theme.AccentText,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        ZIndex = 8
    }, TabList)
    TabButton:SetAttribute("ThemeRole", "Accent")
    TabButton:SetAttribute("IsSystemTab", true)  -- Marca como tab del sistema
    corner(TabButton, 6)

    --// CREAR PÁGINA TAB
    local TabPage = mk("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        Visible = true,  -- Visible por defecto
        ZIndex = 8,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, ContentArea)
    
    mk("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    }, TabPage)

    --// ═══════════════════════════════════════════════════════════
    --// TARJETA DE BIENVENIDA CON AVATAR
    --// ═══════════════════════════════════════════════════════════
    local WelcomeCard = mk("Frame", {
        Parent = TabPage,
        Size = UDim2.new(1, -20, 0, 120),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
    })
    WelcomeCard:SetAttribute("ThemeRole", "Secondary")
    corner(WelcomeCard, 12)
    stroke(WelcomeCard, Theme.Stroke, 1, 0.6)

    --// AVATAR DEL JUGADOR
    local AvatarFrame = mk("Frame", {
        Parent = WelcomeCard,
        Size = UDim2.new(0, 80, 0, 80),
        Position = UDim2.new(0, 15, 0.5, -40),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
    })
    corner(AvatarFrame, 10)
    stroke(AvatarFrame, Theme.Accent, 2)

    local AvatarImage = mk("ImageLabel", {
        Parent = AvatarFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "https://www.roblox.com/bust-thumbnails/" .. LocalPlayer.UserId .. "/420x420.png",
        ZIndex = 10
    })

    --// TEXTO DE BIENVENIDA
    local WelcomeText = mk("TextLabel", {
        Parent = WelcomeCard,
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 105, 0, 0),
        BackgroundTransparency = 1,
        Text = "Bienvenido,",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
    WelcomeText:SetAttribute("ThemeTextRole", "Text")

    --// NOMBRE DEL JUGADOR (GRANDE)
    local NameText = mk("TextLabel", {
        Parent = WelcomeCard,
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 105, 0, 22),
        BackgroundTransparency = 1,
        Text = LocalPlayer.Name,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
    NameText:SetAttribute("ThemeTextRole", "Accent")

    --// ═══════════════════════════════════════════════════════════
    --// GRID DE INFORMACIÓN DEL SERVIDOR
    --// ═══════════════════════════════════════════════════════════
    local ServerTitle = mk("TextLabel", {
        Parent = TabPage,
        Size = UDim2.new(1, -20, 0, 25),
        BackgroundTransparency = 1,
        Text = "📊 SERVIDOR",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    ServerTitle:SetAttribute("ThemeTextRole", "Text")

    --// GRID CONTAINER
    local GridContainer = mk("Frame", {
        Parent = TabPage,
        Size = UDim2.new(1, -20, 0, 100),
        BackgroundTransparency = 1,
    })

    local GridLayout = mk("UIGridLayout", {
        Parent = GridContainer,
        CellSize = UDim2.new(0.5, -5, 1, 0),
        CellPadding = UDim2.new(0, 10, 0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    })

    --// FUNCIÓN PARA CREAR TARJETAS DE ESTADÍSTICA
    local function createStatCard(label, initialValue)
        local Card = mk("Frame", {
            Parent = GridContainer,
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0,
        })
        Card:SetAttribute("ThemeRole", "Secondary")
        corner(Card, 8)
        stroke(Card, Theme.Stroke, 1, 0.6)

        local LabelText = mk("TextLabel", {
            Parent = Card,
            Size = UDim2.new(1, -10, 0, 16),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local ValueText = mk("TextLabel", {
            Parent = Card,
            Size = UDim2.new(1, -10, 1, -25),
            Position = UDim2.new(0, 5, 0, 25),
            BackgroundTransparency = 1,
            Text = tostring(initialValue),
            TextColor3 = Theme.AccentText,
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
        })
        ValueText:SetAttribute("ThemeTextRole", "AccentText")

        return Card, ValueText
    end

    --// CREAR TARJETAS
    local _, playersVal = createStatCard("👥 Jugadores", #Players:GetPlayers())
    local _, maxVal = createStatCard("🔢 Máximo", Players.MaxPlayers)
    local _, pingVal = createStatCard("📡 Ping", "...")
    local _, timeVal = createStatCard("⏱️ Tiempo", "0s")

    --// ACTUALIZAR DATOS EN TIEMPO REAL
    local startClock = os.clock()
    local StatsService = game:GetService("Stats")

    task.spawn(function()
        while TabPage and TabPage.Parent do
            playersVal.Text = tostring(#Players:GetPlayers())
            maxVal.Text = tostring(Players.MaxPlayers)

            local ok, ping = pcall(function()
                return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            pingVal.Text = (ok and ping) and (math.floor(ping) .. " ms") or "N/A"

            local elapsed = os.clock() - startClock
            local hours = math.floor(elapsed / 3600)
            local minutes = math.floor((elapsed % 3600) / 60)
            local seconds = math.floor(elapsed % 60)

            if hours > 0 then
                timeVal.Text = string.format("%dh %dm", hours, minutes)
            elseif minutes > 0 then
                timeVal.Text = string.format("%dm %ds", minutes, seconds)
            else
                timeVal.Text = string.format("%ds", seconds)
            end

            task.wait(1)
        end
    end)

    return {
        Button = TabButton,
        Page = TabPage,
        IsSystemTab = true,
        CanDelete = false
    }
end

--// ============================================================
--// FUNCIÓN PRIVADA: Crear TAB TEMAS (FIJO)
--// ============================================================
local function createThemesTab(Window, TabList, ContentArea, Theme, mk, corner, stroke, setActiveTheme, ThemePalettes, swapThemeColor, Main, BackgroundArt, ThemeBackgroundImages)
    --// CREAR BOTÓN TAB
    local TabButton = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.AccentOff,
        Text = "🎨 TEMAS",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        ZIndex = 8
    }, TabList)
    TabButton:SetAttribute("ThemeRole", "AccentOff")
    TabButton:SetAttribute("IsSystemTab", true)
    corner(TabButton, 6)

    --// CREAR PÁGINA TAB
    local TabPage = mk("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        Visible = false,
        ZIndex = 8,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, ContentArea)

    mk("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    }, TabPage)

    --// SELECTOR DE TEMAS
    local ThemesContainer = mk("Frame", {
        Parent = TabPage,
        Size = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    mk("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    }, ThemesContainer)

    --// CREAR BOTONES DE TEMA
    for themeName, palette in pairs(ThemePalettes) do
        local ThemeButton = mk("TextButton", {
            Parent = ThemesContainer,
            Size = UDim2.new(1, -20, 0, 50),
            BackgroundColor3 = palette.Secondary,
            Text = "✓ " .. themeName,
            TextColor3 = palette.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            BorderSizePixel = 0,
            ZIndex = 9
        })
        corner(ThemeButton, 8)

        --// PREVIEW DE COLORES
        local colorPreview1 = mk("Frame", {
            Parent = ThemeButton,
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(1, -60, 0.5, -6),
            BackgroundColor3 = palette.Accent,
            BorderSizePixel = 0,
        })
        corner(colorPreview1, 2)

        local colorPreview2 = mk("Frame", {
            Parent = ThemeButton,
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(1, -40, 0.5, -6),
            BackgroundColor3 = palette.AccentOff,
            BorderSizePixel = 0,
        })
        corner(colorPreview2, 2)

        --// EVENT DE CLICK
        ThemeButton.MouseButton1Click:Connect(function()
            setActiveTheme(themeName)
            Window.CurrentTheme = themeName

            --// Cambiar colores en toda la UI
            for _, obj in ipairs(Main:GetDescendants()) do
                swapThemeColor(obj, ThemePalettes[themeName])
            end

            --// Cambiar imagen de fondo
            if BackgroundArt then
                BackgroundArt.Image = ThemeBackgroundImages[themeName] or ""
            end

            --// Feedback visual
            ThemeButton.TextColor3 = ThemePalettes[themeName].AccentText
            ThemeButton.BackgroundColor3 = ThemePalettes[themeName].Accent
            task.wait(0.5)
            ThemeButton.TextColor3 = ThemePalettes[themeName].Text
            ThemeButton.BackgroundColor3 = ThemePalettes[themeName].Secondary
        end)
    end

    return {
        Button = TabButton,
        Page = TabPage,
        IsSystemTab = true,
        CanDelete = false
    }
end

--// ============================================================
--// MÉTODO PÚBLICO: Crear TAB PERSONALIZADO (Usuario)
--// ============================================================
-- Esta es la función que reemplaza a CreateTab original
-- El usuario SOLO puede crear tabs con este método
local function createCustomTab(Window, name, iconAsset, TabList, ContentArea, Theme, mk, corner, stroke, resetScrollTop)
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
    TabButton:SetAttribute("IsUserTab", true)  -- Marca como tab del usuario
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

    local Tab = {Button = TabButton, Page = TabPage, IsSystemTab = false}

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
    table.insert(Window.Tabs, Tab)

    --// ═══════════════════════════════════════════════════════════
    --// TODOS LOS MÉTODOS DE COMPONENTES (CreateButton, CreateToggle, etc)
    --// Van aquí... son exactos a los originales
    --// ═══════════════════════════════════════════════════════════

    -- Aquí irían CreateButton, CreateToggle, CreateLabel, etc...
    -- Para no hacer muy largo, copía los métodos existentes de tu librería

    return Tab
end

--// ============================================================
--// INSTRUCCIONES FINALES
--// ============================================================
--[[
    CAMBIOS A HACER EN TU LIBRERÍA ORIGINAL (Yin_Yang_v22.lua):

    1. REEMPLAZA esta sección (alrededor de línea 831):

    --- ANTES (ORIGINAL) ---
    function Window:CreateTab(name, iconAsset)
        ...código original...
    end

    --- DESPUÉS (NUEVO) ---
    function Window:CreateCustomTab(name, iconAsset)
        return createCustomTab(Window, name, iconAsset, TabList, ContentArea, Theme, mk, corner, stroke, resetScrollTop)
    end

    -- ALIAS para compatibilidad (si alguien llama CreateTab, se usa CreateCustomTab)
    Window.CreateTab = Window.CreateCustomTab


    2. ANTES de retornar Window (alrededor de línea 1550):

    --- AGREGAR ESTO ---
    -- Crear tabs del sistema (FIJOS)
    local StartTab = createStartTab(Window, TabList, ContentArea, Theme, mk, corner, stroke, track, LocalPlayer, Players, game)
    table.insert(Window.Tabs, 1, StartTab)  -- Insertar al inicio

    local ThemesTab = createThemesTab(Window, TabList, ContentArea, Theme, mk, corner, stroke, setActiveTheme, ThemePalettes, swapThemeColor, Main, BackgroundArt, ThemeBackgroundImages)
    table.insert(Window.Tabs, 2, ThemesTab)

    -- Seleccionar el tab de inicio por defecto
    StartTab.Button.MouseButton1Click:Fire()

    return Window


    3. PROTEGER TABS DEL SISTEMA:
    Cuando el usuario intente eliminar un tab, agregar validación:

    if Tab.IsSystemTab then
        warn("No puedes eliminar un tab del sistema")
        return false
    end
]]

print("✅ Yin Yang v23 - Módulo de tabs fijos cargado")
print("ℹ️  Copia y pega las funciones en tu librería original")
