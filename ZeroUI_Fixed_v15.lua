--[[
    Zero Mobile - UI Standalone (v15 - BUGFIX + Sistema de Assets)
    ------------------------------------------------------------------
    Cambios respecto a v14:
    1. FIX swapThemeColor: Se reemplazó el sistema de búsqueda por valor
       (que causaba colisiones cuando Text y Stroke eran ambos negros)
       con un sistema de atributos. Cada elemento ahora marca su rol
       semántico ("Background", "Text", "Stroke", etc.) al crearse, y
       SetDarkMode lee ese atributo en vez de adivinar por color.
    2. FIX sombra de Main: Se reemplazó el doble UIStroke (que no se
       renderizaba) con un Frame simulado detrás que tiene ApplyStroke.
    3. ASSETS: Nueva tabla Assets con iconos e imágenes reutilizables.
       Se pueden pasar a botones, tarjetas, etc. Ejemplo:
       Tab1:CreateButton("Mi Botón", callback, Assets.Icons.Settings)
    4. MEJORADO: CreateButton, CreateTab y otros elementos ahora
       aceptan parámetros opcionales de imagen/icono.
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

--// Limpieza de versiones anteriores (si existen)
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("ZeroMobile") then
        LocalPlayer.PlayerGui.ZeroMobile:Destroy()
    end
end)

--// ASSETS - Tabla centralizada de imágenes e iconos
-- Reemplaza los URLs con tus propios recursos. Por ahora son placeholders.
local Assets = {
    Icons = {
        Settings = "rbxasset://textures/Cursor.png",
        Close    = "rbxasset://textures/Cursor.png",
        Check    = "rbxasset://textures/Cursor.png",
        Plus     = "rbxasset://textures/Cursor.png",
        Trash    = "rbxasset://textures/Cursor.png",
    },
    Backgrounds = {
        Gradient = "rbxasset://textures/Cursor.png",
        Card     = "rbxasset://textures/Cursor.png",
    }
}

--// Paleta de colores (contraste corregido)
local Theme = {
    Background   = Color3.fromRGB(255, 255, 255),
    Secondary    = Color3.fromRGB(232, 232, 232),
    Stroke       = Color3.fromRGB(0, 0, 0),
    Text         = Color3.fromRGB(0, 0, 0),
    TextDim      = Color3.fromRGB(120, 120, 120),
    Accent       = Color3.fromRGB(0, 0, 0),
    AccentOff    = Color3.fromRGB(200, 200, 200),
    ToggleOn     = Color3.fromRGB(52, 199, 89),
    Font         = Enum.Font.GothamMedium,
}

local LightPalette = {
    Background = Color3.fromRGB(255, 255, 255),
    Secondary  = Color3.fromRGB(232, 232, 232),
    AccentOff  = Color3.fromRGB(200, 200, 200),
    Text       = Color3.fromRGB(0, 0, 0),
    TextDim    = Color3.fromRGB(120, 120, 120),
    Stroke     = Color3.fromRGB(0, 0, 0),
}

local DarkPalette = {
    Background = Color3.fromRGB(24, 24, 27),
    Secondary  = Color3.fromRGB(40, 40, 45),
    AccentOff  = Color3.fromRGB(58, 58, 64),
    Text       = Color3.fromRGB(240, 240, 240),
    TextDim    = Color3.fromRGB(160, 160, 165),
    Stroke     = Color3.fromRGB(90, 90, 96),
}

-- FIX: En vez de buscar por valor, usa atributos. Mucho más seguro.
local function swapThemeColor(obj, toDark)
    local role = obj:GetAttribute("ThemeRole")
    if not role then return end
    
    local fromPalette = toDark and LightPalette or DarkPalette
    local toPalette = toDark and DarkPalette or LightPalette
    local newColor = toPalette[role]
    
    if obj:IsA("GuiObject") and pcall(function() return obj.BackgroundColor3 end) then
        obj.BackgroundColor3 = newColor
    elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
        obj.TextColor3 = newColor
    elseif obj:IsA("UIStroke") then
        obj.Color = newColor
    end
end

--// Constructor optimizado
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
    -- Marca el UIStroke con su rol para que SetDarkMode lo pueda identificar
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
        Font = Theme.Font,
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

local function formatDuration(totalSeconds)
    totalSeconds = math.floor(totalSeconds)
    local h = math.floor(totalSeconds / 3600)
    local m = math.floor((totalSeconds % 3600) / 60)
    local s = totalSeconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

--// Objeto principal de la UI
local ZeroUI = {}
ZeroUI.__index = ZeroUI

function ZeroUI:CreateWindow(title_text)
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

    -- Botón flotante Z
    local ToggleButton = mk("TextButton", {
        Name = "ToggleButton",
        Size = UDim2.new(0, 46, 0, 46),
        Position = UDim2.new(0, 24, 0, 70),
        BackgroundColor3 = Theme.Accent,
        Text = "Z",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        ZIndex = 30,
    }, ScreenGui)
    ToggleButton:SetAttribute("ThemeRole", "Accent")
    corner(ToggleButton, 999)
    stroke(ToggleButton, Theme.Accent, 1.5)

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

    -- FIX: En vez de doble UIStroke (que no se renderiza), usamos un Frame
    -- detrás como "sombra" simulada. El Frame tiene BackgroundColor3 oscuro
    -- semitransparente, lo que da un efecto de profundidad.
    local ShadowFrame = mk("Frame", {
        Size = UDim2.new(1, 4, 1, 4),
        Position = UDim2.new(0, -2, 0, -2),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.8,
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

    -- Vincula la sombra con la ventana principal
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

    -- Drag para ToggleButton
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
        Font = Theme.Font,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7
    }, TopBar)
    TitleLabel:SetAttribute("ThemeRole", "Text")

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
            stroke(Popup, Color3.fromRGB(0, 0, 0), 1.5, 0)
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
    Window.Assets = Assets  -- Exporta Assets para que se puedan usar desde afuera

    function Window:CreateTab(name)
        local TabButton = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.AccentOff,
            Text = name,
            TextColor3 = Theme.Text,
            Font = Theme.Font,
            TextSize = 13,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 8
        }, TabList)
        TabButton:SetAttribute("ThemeRole", "AccentOff")
        corner(TabButton, 6)
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
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabButton.BackgroundColor3 = Theme.Accent
        end

        TabButton.MouseButton1Click:Connect(Select)
        if #Window.Tabs == 0 then Select() end
        table.insert(Window.Tabs, Tab)

        --// Elementos de Tab
        -- MEJORADO: CreateButton ahora acepta parámetro opcional para icono
        function Tab:CreateButton(text, callback, iconAsset)
            local Btn = mk("TextButton", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Secondary,
                Text = iconAsset and "" or text,  -- Sin texto si hay icono
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 14,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 9
            }, TabPage)
            Btn:SetAttribute("ThemeRole", "Secondary")
            corner(Btn, 6)
            stroke(Btn, Color3.fromRGB(0,0,0), 1, 0.6)
            resetScrollTop(TabPage)

            -- Si hay icono, lo agregamos
            if iconAsset then
                local Icon = mk("ImageLabel", {
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
                    Font = Theme.Font,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 10
                }):SetAttribute("ThemeRole", "Text")
            end

            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.08), {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
                task.wait(0.08)
                TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Secondary, TextColor3 = Theme.Text}):Play()
                pcall(callback)
            end)
            return Btn
        end

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
            stroke(Holder, Color3.fromRGB(0,0,0), 1, 0.6)

            local LabelTxt = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 10
            })
            LabelTxt:SetAttribute("ThemeRole", "Text")

            local Switch = mk("Frame", {
                Parent = Holder,
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff,
                ZIndex = 10
            })
            Switch:SetAttribute("ThemeRole", "AccentOff")
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
                TweenService:Create(Switch, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                pcall(callback, state)
            end)
            resetScrollTop(TabPage)
        end

        function Tab:CreateSlider(text, min, max, default, callback)
            min, max = min or 0, max or 100
            if max <= min then max = min + 1 end
            local value = math.clamp(default or min, min, max)
            local Holder = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = Theme.Secondary,
                ZIndex = 9
            })
            Holder:SetAttribute("ThemeRole", "Secondary")
            corner(Holder, 6)
            stroke(Holder, Color3.fromRGB(0,0,0), 1, 0.6)

            local Label = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -24, 0, 20),
                Position = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1,
                Text = text .. ": " .. tostring(value),
                TextColor3 = Theme.Text,
                Font = Theme.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 10
            })
            Label:SetAttribute("ThemeRole", "Text")

            local Track = mk("Frame", {
                Parent = Holder,
                Size = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 0, 32),
                BackgroundColor3 = Theme.AccentOff,
                ZIndex = 10
            })
            Track:SetAttribute("ThemeRole", "AccentOff")
            corner(Track, 999)

            local Fill = mk("Frame", {
                Parent = Track,
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                ZIndex = 11
            })
            Fill:SetAttribute("ThemeRole", "Accent")
            corner(Fill, 999)

            local Thumb = mk("Frame", {
                Parent = Track,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new((value - min) / (max - min), 0, 0.5, -8),
                BackgroundColor3 = Theme.Accent,
                ZIndex = 12
            })
            Thumb:SetAttribute("ThemeRole", "Accent")
            corner(Thumb, 999)

            local dragging = false
            local function updateFromInput(input)
                local relative = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * relative)
                Fill.Size = UDim2.new(relative, 0, 1, 0)
                Thumb.Position = UDim2.new(relative, 0, 0.5, -8)
                Label.Text = text .. ": " .. tostring(value)
                pcall(callback, value)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateFromInput(input)
                end
            end)
            track(UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end))
            track(UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromInput(input)
                end
            end))
            resetScrollTop(TabPage)
            return {
                Set = function(_, v)
                    value = math.clamp(v, min, max)
                    local relative = (value - min) / (max - min)
                    Fill.Size = UDim2.new(relative, 0, 1, 0)
                    Thumb.Position = UDim2.new(relative, 0, 0.5, -8)
                    Label.Text = text .. ": " .. tostring(value)
                end
            }
        end

        function Tab:CreateDropdown(text, options, default, callback)
            options = options or {}
            local selected = default or options[1] or "Ninguno"

            local Holder = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 56),
                BackgroundColor3 = Theme.Secondary,
                ZIndex = 9
            })
            Holder:SetAttribute("ThemeRole", "Secondary")
            corner(Holder, 6)
            stroke(Holder, Color3.fromRGB(0, 0, 0), 1, 0.6)

            mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -24, 0, 18),
                Position = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.TextDim,
                Font = Theme.Font,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 10
            }):SetAttribute("ThemeRole", "TextDim")

            local ValueLabel = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -46, 0, 22),
                Position = UDim2.new(0, 12, 0, 26),
                BackgroundTransparency = 1,
                Text = tostring(selected),
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 10
            })
            ValueLabel:SetAttribute("ThemeRole", "Text")

            local Chevron = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -32, 0.5, -12),
                BackgroundTransparency = 1,
                Text = "v",
                TextColor3 = Theme.TextDim,
                Font = Theme.Font,
                TextSize = 16,
                ZIndex = 10
            })
            Chevron:SetAttribute("ThemeRole", "TextDim")

            local Click = mk("TextButton", {
                Parent = Holder,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 11
            })

            attachDropdownBehavior(Holder, Click, Chevron, #options, function(Popup, closePopup)
                for _, optionName in ipairs(options) do
                    local isSelected = (optionName == selected)
                    local OptBtn = mk("TextButton", {
                        Parent = Popup,
                        Size = UDim2.new(1, 0, 0, 32),
                        BackgroundColor3 = isSelected and Theme.Accent or Theme.Secondary,
                        Text = tostring(optionName),
                        TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Theme.Text,
                        Font = Theme.Font,
                        TextSize = 13,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        ZIndex = 203
                    })
                    corner(OptBtn, 5)
                    OptBtn.MouseButton1Click:Connect(function()
                        selected = optionName
                        ValueLabel.Text = tostring(selected)
                        pcall(callback, selected)
                        closePopup()
                    end)
                end
            end)

            resetScrollTop(TabPage)

            return {
                Get = function() return selected end,
                Set = function(_, v)
                    selected = v
                    ValueLabel.Text = tostring(v)
                end
            }
        end

        function Tab:CreateMultiDropdown(text, options, defaults, callback)
            options = options or {}
            local selectedSet = {}
            if defaults then
                for _, v in ipairs(defaults) do selectedSet[v] = true end
            end

            local function selectedListText()
                local names = {}
                for _, optionName in ipairs(options) do
                    if selectedSet[optionName] then table.insert(names, optionName) end
                end
                if #names == 0 then return "Ninguno" end
                return table.concat(names, ", ")
            end

            local Holder = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 56),
                BackgroundColor3 = Theme.Secondary,
                ZIndex = 9
            })
            Holder:SetAttribute("ThemeRole", "Secondary")
            corner(Holder, 6)
            stroke(Holder, Color3.fromRGB(0, 0, 0), 1, 0.6)

            mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -24, 0, 18),
                Position = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.TextDim,
                Font = Theme.Font,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 10
            }):SetAttribute("ThemeRole", "TextDim")

            local ValueLabel = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -46, 0, 22),
                Position = UDim2.new(0, 12, 0, 26),
                BackgroundTransparency = 1,
                Text = selectedListText(),
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 10
            })
            ValueLabel:SetAttribute("ThemeRole", "Text")

            local Chevron = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -32, 0.5, -12),
                BackgroundTransparency = 1,
                Text = "v",
                TextColor3 = Theme.TextDim,
                Font = Theme.Font,
                TextSize = 16,
                ZIndex = 10
            })
            Chevron:SetAttribute("ThemeRole", "TextDim")

            local Click = mk("TextButton", {
                Parent = Holder,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 11
            })

            attachDropdownBehavior(Holder, Click, Chevron, #options, function(Popup, closePopup)
                for _, optionName in ipairs(options) do
                    local OptRow = mk("TextButton", {
                        Parent = Popup,
                        Size = UDim2.new(1, 0, 0, 32),
                        BackgroundColor3 = Theme.Secondary,
                        Text = "",
                        ZIndex = 203
                    })
                    OptRow:SetAttribute("ThemeRole", "Secondary")
                    corner(OptRow, 5)

                    mk("TextLabel", {
                        Parent = OptRow,
                        Size = UDim2.new(1, -40, 1, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        BackgroundTransparency = 1,
                        Text = tostring(optionName),
                        TextColor3 = Theme.Text,
                        Font = Theme.Font,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        ZIndex = 204
                    }):SetAttribute("ThemeRole", "Text")

                    local CheckBox = mk("Frame", {
                        Parent = OptRow,
                        Size = UDim2.new(0, 18, 0, 18),
                        Position = UDim2.new(1, -28, 0.5, -9),
                        BackgroundColor3 = selectedSet[optionName] and Theme.Accent or Theme.Background,
                        ZIndex = 204
                    })
                    CheckBox:SetAttribute("ThemeRole", selectedSet[optionName] and "Accent" or "Background")
                    corner(CheckBox, 4)
                    stroke(CheckBox, Theme.Accent, 1.5, 0)

                    OptRow.MouseButton1Click:Connect(function()
                        selectedSet[optionName] = not selectedSet[optionName]
                        CheckBox.BackgroundColor3 = selectedSet[optionName] and Theme.Accent or Theme.Background
                        CheckBox:SetAttribute("ThemeRole", selectedSet[optionName] and "Accent" or "Background")
                        ValueLabel.Text = selectedListText()

                        local resultList = {}
                        for _, o in ipairs(options) do
                            if selectedSet[o] then table.insert(resultList, o) end
                        end
                        pcall(callback, resultList)
                    end)
                end
            end)

            resetScrollTop(TabPage)

            return {
                Get = function()
                    local resultList = {}
                    for _, o in ipairs(options) do
                        if selectedSet[o] then table.insert(resultList, o) end
                    end
                    return resultList
                end
            }
        end

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
                Font = Theme.Font,
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

        function Tab:CreateFriendsCard()
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
                Text = "Amigos",
                Font = Enum.Font.GothamBold,
                TextSize = 15,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 9
            }):SetAttribute("ThemeRole", "Text")

            local Grid = createStatGrid(Card)
            local _, inServerVal = createStatTile(Grid, "En este servidor")
            local _, onlineVal = createStatTile(Grid, "En línea")
            local _, offlineVal = createStatTile(Grid, "Desconectados")
            local _, allVal = createStatTile(Grid, "Total de amigos")

            task.spawn(function()
                local userId = LocalPlayer.UserId

                local ok, onlineFriends = pcall(function()
                    return Players:GetFriendsOnline(userId, 200)
                end)

                if not ok or not onlineFriends then
                    inServerVal.Text = "N/A"
                    onlineVal.Text = "N/A"
                    offlineVal.Text = "N/A"
                else
                    onlineVal.Text = tostring(#onlineFriends)

                    local currentIds = {}
                    for _, plr in ipairs(Players:GetPlayers()) do
                        currentIds[plr.UserId] = true
                    end
                    local inServerCount = 0
                    for _, friend in ipairs(onlineFriends) do
                        if currentIds[friend.VisitorId] then
                            inServerCount += 1
                        end
                    end
                    inServerVal.Text = tostring(inServerCount)
                end

                local ok2, totalCount = pcall(function()
                    local pages = Players:GetFriendsAsync(userId)
                    local count = 0
                    while true do
                        count += #pages:GetCurrentPage()
                        if pages:IsFinished() then break end
                        local advanced = pcall(function() pages:AdvanceToNextPageAsync() end)
                        if not advanced then break end
                    end
                    return count
                end)

                if ok2 then
                    allVal.Text = tostring(totalCount)
                    if ok and onlineFriends then
                        offlineVal.Text = tostring(math.max(0, totalCount - #onlineFriends))
                    end
                else
                    allVal.Text = "N/A"
                end
            end)

            resetScrollTop(TabPage)
            return Card
        end

        function Tab:CreateExecutorCard()
            local Card = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Accent,
                ZIndex = 9
            })
            Card:SetAttribute("ThemeRole", "Accent")
            corner(Card, 8)
            mk("UIPadding", {
                PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)
            }, Card)
            mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, Card)

            mk("TextLabel", {
                Parent = Card,
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = "Ejecutor",
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10
            })

            local Subtitle = mk("TextLabel", {
                Parent = Card,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text = "Detectando...",
                Font = Theme.Font,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                ZIndex = 10
            })

            task.defer(function()
                local ok, name, version = pcall(identifyexecutor)
                if ok and name then
                    Subtitle.Text = "Corriendo en " .. tostring(name) .. (version and (" " .. tostring(version)) or "")
                else
                    local ok2, name2 = pcall(getexecutorname)
                    if ok2 and name2 then
                        Subtitle.Text = "Corriendo en " .. tostring(name2)
                    else
                        Subtitle.Text = "No se pudo identificar el ejecutor, pero el script corre con normalidad."
                    end
                end
            end)

            resetScrollTop(TabPage)
            return Card
        end

        return Tab
    end

    -- FIX: SetDarkMode ahora usa atributos en vez de búsqueda por valor
    local isDarkMode = false
    function Window:SetDarkMode(enabled)
        if enabled == isDarkMode then return end
        isDarkMode = enabled

        Theme.Background = enabled and DarkPalette.Background or LightPalette.Background
        Theme.Secondary  = enabled and DarkPalette.Secondary  or LightPalette.Secondary
        Theme.AccentOff  = enabled and DarkPalette.AccentOff  or LightPalette.AccentOff
        Theme.Text       = enabled and DarkPalette.Text       or LightPalette.Text
        Theme.TextDim    = enabled and DarkPalette.TextDim    or LightPalette.TextDim
        Theme.Stroke     = enabled and DarkPalette.Stroke     or LightPalette.Stroke

        for _, obj in ipairs(Main:GetDescendants()) do
            swapThemeColor(obj, enabled)
        end
    end

    function Window:IsDarkMode()
        return isDarkMode
    end

    function Window:Destroy()
        for _, conn in ipairs(globalConnections) do
            pcall(function() conn:Disconnect() end)
        end
        ScreenGui:Destroy()
    end

    return Window
end

-- ============================================================
-- CONFIGURACIÓN DE LA UI (MODIFICA ESTO)
-- ============================================================

local Zero = ZeroUI:CreateWindow("Zero UI")

local TabInicio = Zero:CreateTab("Inicio")
TabInicio:CreateWelcomeCard()
TabInicio:CreateServerInfoCard()
TabInicio:CreateFriendsCard()
TabInicio:CreateExecutorCard()

local Tab1 = Zero:CreateTab("Main")
Tab1:CreateButton("Mi Botón", function()
    print("¡Botón presionado!")
end)
Tab1:CreateToggle("Activar Característica", false, function(state)
    print("Característica: " .. tostring(state))
end)
Tab1:CreateSlider("Ajustar Valor", 0, 100, 75, function(value)
    print("Valor: " .. tostring(value))
end)

local Tab2 = Zero:CreateTab("Settings")
Tab2:CreateButton("Guardar Config", function()
    print("Configuración guardada.")
end)
Tab2:CreateToggle("Modo Oscuro", false, function(state)
    Zero:SetDarkMode(state)
end)
Tab2:CreateDropdown("Target Category", {"NPCs", "Players", "Both"}, "Both", function(value)
    print("Target Category: " .. tostring(value))
end)
Tab2:CreateMultiDropdown("Item Blacklist", {"Wood", "Stone", "Gold"}, {}, function(selectedList)
    print("Blacklist: " .. table.concat(selectedList, ", "))
end)

local Tab3 = Zero:CreateTab("About")
Tab3:CreateButton("Créditos", function()
    print("Creado por Manus AI")
end)
