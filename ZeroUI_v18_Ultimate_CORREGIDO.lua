--[[
    Zero Mobile - UI Ultimate Edition (v18)
    ============================================================
    ⚡ NUEVAS CARACTERÍSTICAS ÉPICAS:
    
    1. LOGO YIN-YANG ROTATIVO: Logo animado que gira continuamente
    2. SONIDOS INTEGRADOS:
       - Click al activar/desactivar (138567614125924)
       - Dragón aleatorio cuando está cerrado (7127123554)
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

local function playSound(soundId, volume)
    volume = volume or 0.5
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    sound.Parent = workspace
    game:GetService("Debris"):AddItem(sound, 2)
    sound:Play()
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
    Light = {
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
    Green = {
        Background = Color3.fromRGB(10, 30, 15),
        Secondary = Color3.fromRGB(20, 50, 30),
        AccentOff = Color3.fromRGB(40, 90, 60),
        Text = Color3.fromRGB(230, 255, 240),
        TextDim = Color3.fromRGB(150, 220, 180),
        Stroke = Color3.fromRGB(80, 200, 120),
        Accent = Color3.fromRGB(100, 220, 140),
        ToggleOn = Color3.fromRGB(100, 220, 140),
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
}

local Theme = table.clone(ThemePalettes.Dark)

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

local function swapThemeColor(obj, palette)
    local role = obj:GetAttribute("ThemeRole")
    if not role then return end
    local newColor = palette[role]
    if newColor then
        if obj:IsA("GuiObject") and pcall(function() return obj.BackgroundColor3 end) then
            obj.BackgroundColor3 = newColor
        elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
            obj.TextColor3 = newColor
        elseif obj:IsA("UIStroke") then
            obj.Color = newColor
        end
    end
end

--// MAIN OBJECT
local ZeroUI = {}
ZeroUI.__index = ZeroUI

function ZeroUI:CreateWindow(title_text, startTheme)
    startTheme = startTheme or "Dark"
    if ThemePalettes[startTheme] then
        Theme = table.clone(ThemePalettes[startTheme])
    end

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
        Size = UDim2.new(0.8, 0, 0.8, 0),
        Position = UDim2.new(0.1, 0, 0.1, 0),
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

    --// VENTANA PRINCIPAL
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

    function Window:SetTheme(themeName)
        if not ThemePalettes[themeName] then
            warn("Tema no encontrado: " .. tostring(themeName))
            return
        end
        self.CurrentTheme = themeName
        Theme = table.clone(ThemePalettes[themeName])
        
        for _, obj in ipairs(Main:GetDescendants()) do
            swapThemeColor(obj, Theme)
        end
    end

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
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
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
            LabelTxt:SetAttribute("ThemeRole", "Text")

            --// BOTÓN DE FLECHITA PARA DESPRENDER
            local DetachBtn = mk("TextButton", {
                Parent = Holder,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -70, 0.5, -12),
                BackgroundColor3 = Theme.Accent,
                Text = "↗",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                ZIndex = 11
            })
            DetachBtn:SetAttribute("ThemeRole", "Accent")
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
            local isFloating = false
            local isLocked = false

            local function createFloatingWindow()
                FloatingWindow = mk("Frame", {
                    Parent = Window.ScreenGui,
                    Size = UDim2.new(0, 100, 0, 60),
                    Position = UDim2.new(0.5, 50, 0.5, 50),
                    BackgroundColor3 = Theme.Secondary,
                    ZIndex = 150
                })
                FloatingWindow:SetAttribute("ThemeRole", "Secondary")
                corner(FloatingWindow, 6)
                stroke(FloatingWindow, Theme.Stroke, 1, 0.6)

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
                }):SetAttribute("ThemeRole", "Text")

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
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    ZIndex = 151
                })
                PlusBtn:SetAttribute("ThemeRole", "Accent")
                corner(PlusBtn, 3)

                local MinusBtn = mk("TextButton", {
                    Parent = FloatingWindow,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(1, -18, 0.5, -9),
                    BackgroundColor3 = Theme.Accent,
                    Text = "-",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    ZIndex = 151
                })
                MinusBtn:SetAttribute("ThemeRole", "Accent")
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
            LabelTxt:SetAttribute("ThemeRole", "Text")

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
                }):SetAttribute("ThemeRole", "Text")
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
            Label:SetAttribute("ThemeRole", "Text")
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

        return Tab
    end

    function Window:SetTheme(themeName)
        if not ThemePalettes[themeName] then
            warn("Tema no encontrado: " .. tostring(themeName))
            return
        end
        self.CurrentTheme = themeName
        Theme = table.clone(ThemePalettes[themeName])
        
        for _, obj in ipairs(Main:GetDescendants()) do
            swapThemeColor(obj, Theme)
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
--// EJEMPLO DE USO
--// ============================================================

print("🎮 Yin Yang - Iniciando...")
local Zero = ZeroUI:CreateWindow("Yin Yang", "Dark")

local TabHome = Zero:CreateTab("Inicio")
TabHome:CreateLabel("Bienvenido a Zero UI v18", 16)
TabHome:CreateDivider()
TabHome:CreateLabel("✨ Logo Yin-Yang rotativo\n🔊 Sonidos integrados\n🎚️ Toggles flotantes desprendibles", 12)

local TabFeatures = Zero:CreateTab("Features")
TabFeatures:CreateLabel("Features con Toggles Flotantes", 14)
TabFeatures:CreateDivider()

TabFeatures:CreateFloatingToggle("Aimbot", false, function(state)
    print("Aimbot: " .. (state and "ON ✓" or "OFF ✕"))
end)

TabFeatures:CreateFloatingToggle("ESP", false, function(state)
    print("ESP: " .. (state and "ON ✓" or "OFF ✕"))
end)

TabFeatures:CreateFloatingToggle("GodMode", false, function(state)
    print("GodMode: " .. (state and "ON ✓" or "OFF ✕"))
end)

local TabSettings = Zero:CreateTab("Ajustes")
TabSettings:CreateLabel("Personalizaciones", 14)
TabSettings:CreateDivider()

TabSettings:CreateButton("Cambiar a Dark", function()
    Zero:SetTheme("Dark")
    print("✓ Tema cambiado a Dark")
end)

TabSettings:CreateButton("Cambiar a Blue", function()
    Zero:SetTheme("Blue")
    print("✓ Tema cambiado a Blue")
end)

TabSettings:CreateButton("Cambiar a Red", function()
    Zero:SetTheme("Red")
    print("✓ Tema cambiado a Red")
end)

print("✅ Yin Yang - ¡Listo!")
print("🎯 Características: Logo Yin-Yang, Sonidos, Toggles Flotantes")
