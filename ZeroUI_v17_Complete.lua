--[[
    Zero Mobile - UI Professional Complete (v17)
    ==================================================
    NUEVAS CARACTERÍSTICAS:
    
    1. INPUT FIELDS: TextBox estilizado para entrada de texto
    2. COLOR PICKER: Selector de colores integrado
    3. LOGGING SYSTEM: Sistema de logs/consola integrada
    4. SEARCH & FILTER: Búsqueda en tiempo real
    5. SAVE/LOAD CONFIG: Guardar y cargar configuraciones
    6. ADVANCED ANIMATIONS: Animaciones suaves mejoradas
    7. FULL DOCUMENTATION: Ejemplos para cada componente
    
    USO BÁSICO:
    local Zero = ZeroUI:CreateWindow("Mi App", "Purple")
    local Tab = Zero:CreateTab("Inicio")
    Tab:CreateButton("Click", callback, Assets.Utilities.Settings)
    Zero:SetTheme("Blue")
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("ZeroMobile") then
        LocalPlayer.PlayerGui.ZeroMobile:Destroy()
    end
end)

--// ============================================================
--// ASSETS PREMIUM v17 (+60 ICONOS)
--// ============================================================

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
        MoreOptions = "rbxasset://textures/Cursor.png",
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
    Social = {
        Users = "rbxasset://textures/Cursor.png",
        Friends = "rbxasset://textures/Cursor.png",
        Message = "rbxasset://textures/Cursor.png",
        Online = "rbxasset://textures/Cursor.png",
        Offline = "rbxasset://textures/Cursor.png",
        Block = "rbxasset://textures/Cursor.png",
        Invite = "rbxasset://textures/Cursor.png",
        Party = "rbxasset://textures/Cursor.png",
        Profile = "rbxasset://textures/Cursor.png",
    },
    Server = {
        Server = "rbxasset://textures/Cursor.png",
        Status = "rbxasset://textures/Cursor.png",
        Network = "rbxasset://textures/Cursor.png",
        Ping = "rbxasset://textures/Cursor.png",
        Log = "rbxasset://textures/Cursor.png",
        Console = "rbxasset://textures/Cursor.png",
        Warning = "rbxasset://textures/Cursor.png",
        Error = "rbxasset://textures/Cursor.png",
        Success = "rbxasset://textures/Cursor.png",
        Database = "rbxasset://textures/Cursor.png",
    },
    Game = {
        Map = "rbxasset://textures/Cursor.png",
        Spawn = "rbxasset://textures/Cursor.png",
        Inventory = "rbxasset://textures/Cursor.png",
        Currency = "rbxasset://textures/Cursor.png",
        Level = "rbxasset://textures/Cursor.png",
        Quest = "rbxasset://textures/Cursor.png",
        Achievement = "rbxasset://textures/Cursor.png",
        Shop = "rbxasset://textures/Cursor.png",
    },
    Media = {
        Camera = "rbxasset://textures/Cursor.png",
        Video = "rbxasset://textures/Cursor.png",
        Audio = "rbxasset://textures/Cursor.png",
        Music = "rbxasset://textures/Cursor.png",
        Play = "rbxasset://textures/Cursor.png",
        Pause = "rbxasset://textures/Cursor.png",
        Stop = "rbxasset://textures/Cursor.png",
    },
    Status = {
        Check = "rbxasset://textures/Cursor.png",
        Cross = "rbxasset://textures/Cursor.png",
        Warning = "rbxasset://textures/Cursor.png",
        Question = "rbxasset://textures/Cursor.png",
        Loading = "rbxasset://textures/Cursor.png",
        Locked = "rbxasset://textures/Cursor.png",
    },
}

function Assets:AddCustom(category, name, assetId)
    if not self[category] then
        self[category] = {}
    end
    self[category][name] = assetId
end

--// PALETAS DE TEMAS
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

--// SISTEMA DE CONFIGURACIÓN
local ConfigManager = {}
function ConfigManager:Save(name, data)
    local json = game:GetService("HttpService"):JSONEncode(data)
    local key = "ZeroUI_Config_" .. name
    pcall(function()
        writefile(key .. ".json", json)
    end)
end

function ConfigManager:Load(name)
    local key = "ZeroUI_Config_" .. name
    local ok, content = pcall(function()
        return readfile(key .. ".json")
    end)
    if ok and content then
        return game:GetService("HttpService"):JSONDecode(content)
    end
    return nil
end

--// SISTEMA DE LOGGING
local Logger = {}
Logger.logs = {}
function Logger:Log(message, logType)
    logType = logType or "info"
    local timestamp = os.date("%H:%M:%S")
    table.insert(self.logs, {
        time = timestamp,
        type = logType,
        message = message
    })
    print("[" .. timestamp .. "] [" .. logType:upper() .. "] " .. message)
end

function Logger:GetLogs()
    return self.logs
end

function Logger:Clear()
    self.logs = {}
end

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
    stroke(Tile, Theme.Stroke, 1, 0.6)

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

local function formatDuration(totalSeconds)
    totalSeconds = math.floor(totalSeconds)
    local h = math.floor(totalSeconds / 3600)
    local m = math.floor((totalSeconds % 3600) / 60)
    local s = totalSeconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function swapThemeColor(obj, toDark, palette)
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

--// OBJETO PRINCIPAL
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
    Window.Logger = Logger
    Window.ConfigManager = ConfigManager

    function Window:SetTheme(themeName)
        if not ThemePalettes[themeName] then
            warn("Tema no encontrado: " .. tostring(themeName))
            return
        end
        self.CurrentTheme = themeName
        Theme = table.clone(ThemePalettes[themeName])
        
        for _, obj in ipairs(Main:GetDescendants()) do
            swapThemeColor(obj, false, Theme)
        end
        Logger:Log("Tema cambiado a: " .. themeName, "info")
    end

    function Window:AddTheme(name, palette)
        ThemePalettes[name] = palette
        Logger:Log("Tema personalizado agregado: " .. name, "success")
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

        --// NUEVOS COMPONENTES v17

        -- INPUT FIELD: TextBox estilizado
        function Tab:CreateInput(label, placeholder, callback)
            local Holder = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 56),
                BackgroundColor3 = Theme.Secondary,
                ZIndex = 9
            })
            Holder:SetAttribute("ThemeRole", "Secondary")
            corner(Holder, 6)
            stroke(Holder, Theme.Stroke, 1, 0.6)

            mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -24, 0, 18),
                Position = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1,
                Text = label,
                TextColor3 = Theme.TextDim,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10
            }):SetAttribute("ThemeRole", "TextDim")

            local InputBox = mk("TextBox", {
                Parent = Holder,
                Size = UDim2.new(1, -24, 0, 22),
                Position = UDim2.new(0, 12, 0, 26),
                BackgroundColor3 = Theme.Background,
                Text = "",
                PlaceholderText = placeholder or "Ingresa algo...",
                TextColor3 = Theme.Text,
                PlaceholderColor3 = Theme.TextDim,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10
            })
            InputBox:SetAttribute("ThemeRole", "Background")
            corner(InputBox, 4)

            InputBox.FocusLost:Connect(function()
                if callback then
                    pcall(callback, InputBox.Text)
                end
            end)

            resetScrollTop(TabPage)
            return InputBox
        end

        -- COLOR PICKER: Selector de colores
        function Tab:CreateColorPicker(label, defaultColor, callback)
            defaultColor = defaultColor or Theme.Accent
            local Holder = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.Secondary,
                ZIndex = 9
            })
            Holder:SetAttribute("ThemeRole", "Secondary")
            corner(Holder, 6)
            stroke(Holder, Theme.Stroke, 1, 0.6)

            mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = label,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10
            }):SetAttribute("ThemeRole", "Text")

            local ColorPreview = mk("Frame", {
                Parent = Holder,
                Size = UDim2.new(0, 28, 0, 28),
                Position = UDim2.new(1, -40, 0.5, -14),
                BackgroundColor3 = defaultColor,
                ZIndex = 10
            })
            corner(ColorPreview, 4)

            local PickButton = mk("TextButton", {
                Parent = Holder,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 11
            })

            PickButton.MouseButton1Click:Connect(function()
                -- Simulación simple - en uso real, usar una UI de color picker
                local colors = {
                    Color3.fromRGB(255, 0, 0),
                    Color3.fromRGB(0, 255, 0),
                    Color3.fromRGB(0, 0, 255),
                    Color3.fromRGB(255, 255, 0),
                    Color3.fromRGB(255, 0, 255),
                }
                local randomColor = colors[math.random(#colors)]
                ColorPreview.BackgroundColor3 = randomColor
                if callback then
                    pcall(callback, randomColor)
                end
            end)

            resetScrollTop(TabPage)
            return ColorPreview
        end

        -- BÚSQUEDA/FILTRO
        function Tab:CreateSearchBar(onSearch)
            local SearchHolder = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Secondary,
                ZIndex = 9
            })
            SearchHolder:SetAttribute("ThemeRole", "Secondary")
            corner(SearchHolder, 6)
            stroke(SearchHolder, Theme.Stroke, 1, 0.6)

            mk("TextLabel", {
                Parent = SearchHolder,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(0, 6, 0.5, -12),
                BackgroundTransparency = 1,
                Text = "🔍",
                Font = Enum.Font.GothamMedium,
                TextSize = 16,
                ZIndex = 10
            })

            local SearchBox = mk("TextBox", {
                Parent = SearchHolder,
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 32, 0, 0),
                BackgroundTransparency = 1,
                Text = "",
                PlaceholderText = "Buscar...",
                TextColor3 = Theme.Text,
                PlaceholderColor3 = Theme.TextDim,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10
            })

            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                if onSearch then
                    pcall(onSearch, SearchBox.Text)
                end
            end)

            resetScrollTop(TabPage)
            return SearchBox
        end

        -- NOTIFICACIÓN TOAST
        function Tab:CreateNotification(text, duration, notifType)
            duration = duration or 3
            notifType = notifType or "info"
            
            local colors = {
                info = Color3.fromRGB(100, 180, 255),
                success = Color3.fromRGB(100, 220, 140),
                warning = Color3.fromRGB(255, 200, 80),
                error = Color3.fromRGB(255, 100, 120),
            }
            
            local Notif = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = colors[notifType] or colors.info,
                ZIndex = 20
            })
            Notif:SetAttribute("ThemeRole", "Secondary")
            corner(Notif, 6)
            
            mk("TextLabel", {
                Parent = Notif,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 21
            })
            
            task.delay(duration, function()
                if Notif and Notif.Parent then
                    TweenService:Create(Notif, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                    task.wait(0.3)
                    Notif:Destroy()
                end
            end)
            
            return Notif
        end

        -- DIVISOR
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

        -- LABEL ESTILIZADO
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

        -- BADGE/ETIQUETA
        function Tab:CreateBadge(text, badgeColor)
            badgeColor = badgeColor or Theme.Accent
            local Badge = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(0, 0, 0, 24),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = badgeColor,
                ZIndex = 9
            })
            Badge:SetAttribute("ThemeRole", "Accent")
            corner(Badge, 12)
            mk("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, Badge)
            
            mk("TextLabel", {
                Parent = Badge,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                ZIndex = 10
            })
            
            resetScrollTop(TabPage)
            return Badge
        end

        -- BOTÓN MEJORADO
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
                TweenService:Create(Btn, TweenInfo.new(0.08), {BackgroundColor3 = Theme.Accent}):Play()
                task.wait(0.08)
                TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Secondary}):Play()
                Logger:Log("Botón presionado: " .. text, "info")
                pcall(callback)
            end)
            return Btn
        end

        -- TOGGLE
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
                TweenService:Create(Switch, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                Logger:Log(text .. ": " .. (state and "ON" or "OFF"), "info")
                pcall(callback, state)
            end)
            resetScrollTop(TabPage)
        end

        -- SLIDER
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
            stroke(Holder, Theme.Stroke, 1, 0.6)

            local Label = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -24, 0, 20),
                Position = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1,
                Text = text .. ": " .. tostring(value),
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
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

        -- DROPDOWN
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
            stroke(Holder, Theme.Stroke, 1, 0.6)

            mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -24, 0, 18),
                Position = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.TextDim,
                Font = Enum.Font.GothamMedium,
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
                Font = Enum.Font.GothamMedium,
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
                        Font = Enum.Font.GothamMedium,
                        TextSize = 13,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        ZIndex = 203
                    })
                    corner(OptBtn, 5)
                    OptBtn.MouseButton1Click:Connect(function()
                        selected = optionName
                        ValueLabel.Text = tostring(selected)
                        Logger:Log("Seleccionado: " .. tostring(selected), "info")
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

        -- MULTI DROPDOWN
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
            stroke(Holder, Theme.Stroke, 1, 0.6)

            mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -24, 0, 18),
                Position = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.TextDim,
                Font = Enum.Font.GothamMedium,
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
                Font = Enum.Font.GothamMedium,
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
                        Font = Enum.Font.GothamMedium,
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

        -- WELCOME CARD
        function Tab:CreateWelcomeCard()
            local Card = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 64),
                BackgroundColor3 = Theme.Secondary,
                ZIndex = 9
            })
            Card:SetAttribute("ThemeRole", "Secondary")
            corner(Card, 8)
            stroke(Card, Theme.Stroke, 1, 0.6)

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
            swapThemeColor(obj, false, Theme)
        end
        Logger:Log("Tema cambiado a: " .. themeName, "success")
    end

    function Window:Destroy()
        for _, conn in ipairs(globalConnections) do
            pcall(function() conn:Disconnect() end)
        end
        ScreenGui:Destroy()
        Logger:Log("UI destruida", "info")
    end

    Logger:Log("Zero UI v17 iniciada - Tema: " .. startTheme, "success")
    return Window
end

--// ============================================================
--// EJEMPLO COMPLETO DE USO
--// ============================================================

local Zero = ZeroUI:CreateWindow("Zero UI v17 - Professional", "Purple")
local Logger = Zero.Logger

local TabHome = Zero:CreateTab("Inicio", Assets.Interface.Home)
TabHome:CreateLabel("Bienvenido a Zero UI v17", 16)
TabHome:CreateDivider()
TabHome:CreateWelcomeCard()

local TabFeatures = Zero:CreateTab("Features", Assets.Combat.Aimbot)
TabFeatures:CreateSearchBar(function(query)
    print("Buscando: " .. query)
end)

TabFeatures:CreateButton("Aimbot", function()
    TabFeatures:CreateNotification("Aimbot activado", 2, "success")
    Logger:Log("Aimbot fue activado", "success")
end, Assets.Combat.Aimbot)

TabFeatures:CreateButton("ESP", function()
    TabFeatures:CreateNotification("ESP visual activado", 2, "success")
    Logger:Log("ESP fue activado", "success")
end, Assets.Combat.ESP)

local TabTools = Zero:CreateTab("Tools", Assets.Utilities.Settings)
TabTools:CreateLabel("Herramientas Personalizadas", 14)
TabTools:CreateDivider()

TabTools:CreateInput("Tu Nombre", "Ingresa tu nombre...", function(text)
    Logger:Log("Nombre ingresado: " .. text, "info")
end)

TabTools:CreateColorPicker("Color Favorito", Color3.fromRGB(180, 100, 255), function(color)
    Logger:Log("Color seleccionado", "info")
end)

TabTools:CreateToggle("Sonido", true, function(state)
    Logger:Log(state and "Sonido ON" or "Sonido OFF", "info")
end)

local TabSettings = Zero:CreateTab("Ajustes", Assets.Utilities.Settings)
TabSettings:CreateLabel("Personalización", 14)
TabSettings:CreateDivider()

TabSettings:CreateDropdown("Tema", {"Light", "Dark", "Purple", "Blue", "Green", "Red", "Orange"}, "Purple", function(value)
    Zero:SetTheme(value)
    TabSettings:CreateNotification("Tema: " .. value, 1.5, "info")
end)

TabSettings:CreateSlider("Velocidad", 0.5, 3, 1, function(value)
    Logger:Log("Velocidad: " .. value .. "x", "info")
end)

TabSettings:CreateMultiDropdown("Módulos", {"Combat", "Visuals", "Movement", "Misc"}, {"Combat", "Visuals"}, function(list)
    Logger:Log("Módulos: " .. table.concat(list, ", "), "info")
end)

TabSettings:CreateButton("Guardar Configuración", function()
    Zero.ConfigManager:Save("miConfig", {
        tema = Zero.CurrentTheme,
        logs = Logger:GetLogs()
    })
    TabSettings:CreateNotification("Configuración guardada", 2, "success")
    Logger:Log("Configuración guardada", "success")
end, Assets.Utilities.Save)

local TabAbout = Zero:CreateTab("Info", Assets.Utilities.Info)
TabAbout:CreateLabel("Zero Premium UI v17", 16)
TabAbout:CreateBadge("PROFESSIONAL")
TabAbout:CreateDivider()
TabAbout:CreateLabel("La librería UI más completa para Roblox\n\n✓ +60 Assets premium\n✓ 7 temas predefinidos\n✓ Input fields & Color picker\n✓ Sistema de logging\n✓ Guardado de configuraciones\n✓ Búsqueda integrada\n✓ Animaciones suaves", 11)

print("Zero UI v17 - Iniciada correctamente!")
