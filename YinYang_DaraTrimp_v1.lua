--[[
    Dara Trimp · standalone (v1)
    Lógica copiada TAL CUAL de YinYang_V39_UnlockAll_v2.lua (líneas 3403-3540, bloque "Dara Trimp"):
      · mismo hook a ReplicatedStorage.Objects.Game.Character.Client.Movement.Update
      · mismos valores: MaxSpeed 99, SpeedAcceleration 9, SmoothAcceleration true, MovementType "Camera"
      · misma tecla Q para prender/apagar con la notificación "Fake Trimp"
    Lo único nuevo: mini ventana propia con un toggle y un botón ✕ que cierra todo
    (devuelve el Movement.Update original, desconecta la tecla Q y borra la ventana).
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- si se vuelve a ejecutar, primero se cierra la copia anterior (así el hook no queda duplicado)
local env = (typeof(getgenv) == "function" and getgenv()) or _G
if type(env.DaraTrimpStandaloneClose) == "function" then
    pcall(env.DaraTrimpStandaloneClose)
end

-- ==================== LÓGICA ORIGINAL (sin cambios) ====================
local FakeTrimp = {
    Enabled = false,
    MovementType = "Camera",
    CameraDirection = Vector3.new(0, 0, -1),
    SmoothAcceleration = true,
    SpeedAcceleration = 9,
    MaxSpeed = 99,
    State = { MoveDir = Vector3.new(1, 0, 0) }
}

local currentSpeed = 0
local currentDir = Vector3.new(1, 0, 0)
local oldUpdate = nil

local movementOk, Movement = pcall(function()
    return require(ReplicatedStorage.Objects.Game.Character.Client.Movement)
end)
local trimpReady = movementOk and type(Movement) == "table" and Movement.Update ~= nil

local function FakeTimpUpdate(self, dt)
    oldUpdate(self, dt)
    if not FakeTrimp.Enabled then
        currentSpeed = 0
        return
    end

    local hrp = self.Character and self.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = self.Character and self.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local moveDir = Vector3.new()
    if FakeTrimp.MovementType == "Camera" then
        local cam = workspace.CurrentCamera
        if cam then
            local lookDir = cam.CFrame:VectorToWorldSpace(FakeTrimp.CameraDirection)
            moveDir = Vector3.new(lookDir.X, 0, lookDir.Z).Unit
        end
    else
        moveDir = humanoid.MoveDirection
    end

    if moveDir.Magnitude > 0 then
        FakeTrimp.State.MoveDir = moveDir.Unit
    end

    currentDir = FakeTrimp.State.MoveDir
    local targetSpeed = FakeTrimp.MaxSpeed * 90

    if FakeTrimp.SmoothAcceleration then
        currentSpeed = currentSpeed + (targetSpeed - currentSpeed) * math.min(FakeTrimp.SpeedAcceleration * dt, 1)
    else
        currentSpeed = targetSpeed
    end

    local newVelocity = currentDir * currentSpeed
    self.DataRegistry:Set("Velocity", newVelocity)

    local horizontal = Vector3.new(newVelocity.X, 0, newVelocity.Z) / 90
    hrp.AssemblyLinearVelocity = Vector3.new(horizontal.X, hrp.AssemblyLinearVelocity.Y, horizontal.Z)
end

if trimpReady and not oldUpdate then
    oldUpdate = Movement.Update
    Movement.Update = FakeTimpUpdate
end

-- ==================== MINI VENTANA ====================
local C = {
    Bg = Color3.fromRGB(255, 255, 255), Field = Color3.fromRGB(242, 242, 246), Stroke = Color3.fromRGB(214, 214, 222),
    Text = Color3.fromRGB(16, 16, 20), Dim = Color3.fromRGB(104, 104, 118), On = Color3.fromRGB(16, 16, 20), Off = Color3.fromRGB(206, 206, 214),
}
local function mk(class, props)
    local inst = Instance.new(class)
    for key, value in pairs(props) do
        if key ~= "Parent" then inst[key] = value end
    end
    inst.Parent = props.Parent
    return inst
end
local function corner(parent, radius) return mk("UICorner", {CornerRadius = UDim.new(0, radius), Parent = parent}) end
local function stroke(parent, color, transparency) return mk("UIStroke", {Color = color, Transparency = transparency or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent}) end
local function tween(inst, time, goals, style)
    TweenService:Create(inst, TweenInfo.new(time, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), goals):Play()
end

local guiParent = LocalPlayer:WaitForChild("PlayerGui")
pcall(function()
    if typeof(gethui) == "function" then
        local hidden = gethui()
        if hidden then guiParent = hidden end
    end
end)
local oldGui = guiParent:FindFirstChild("DaraTrimp_Standalone")
if oldGui then oldGui:Destroy() end

local Connections = {}
local Gui = mk("ScreenGui", {Name = "DaraTrimp_Standalone", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 80, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = guiParent})
local Window = mk("Frame", {Size = UDim2.fromOffset(230, 104), Position = UDim2.new(0, 24, 0.5, -52), BackgroundColor3 = C.Bg, BorderSizePixel = 0, Parent = Gui})
corner(Window, 16)
stroke(Window, C.Stroke, 0)
local WindowScale = mk("UIScale", {Scale = 0.9, Parent = Window})

-- cabecera (se arrastra desde acá) con el ✕ en la esquina
local Header = mk("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = Window})
mk("TextLabel", {Size = UDim2.new(1, -56, 0, 18), Position = UDim2.fromOffset(14, 8), BackgroundTransparency = 1, Text = "Dara Trimp", TextColor3 = C.Text, Font = Enum.Font.GothamBlack, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header})
local Status = mk("TextLabel", {Size = UDim2.new(1, -56, 0, 12), Position = UDim2.fromOffset(14, 25), BackgroundTransparency = 1, Text = trimpReady and "Tecla Q también lo prende" or "No disponible en este juego", TextColor3 = C.Dim, Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header})
local CloseButton = mk("TextButton", {Size = UDim2.fromOffset(26, 26), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 8), BackgroundColor3 = C.Field, AutoButtonColor = false, Text = "✕", TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 13, Parent = Window})
corner(CloseButton, 999)
stroke(CloseButton, C.Stroke, 0.2)

-- fila del toggle
local Row = mk("TextButton", {Size = UDim2.new(1, -20, 0, 44), Position = UDim2.fromOffset(10, 50), BackgroundColor3 = C.Field, AutoButtonColor = false, Text = "", Parent = Window})
corner(Row, 12)
local RowStroke = stroke(Row, C.Stroke, 0.3)
mk("TextLabel", {Size = UDim2.new(1, -70, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Text = "Activar", TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = Row})
local Switch = mk("Frame", {Size = UDim2.fromOffset(42, 24), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), BackgroundColor3 = C.Off, BorderSizePixel = 0, Parent = Row})
corner(Switch, 999)
local Knob = mk("Frame", {Size = UDim2.fromOffset(18, 18), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = Switch})
corner(Knob, 999)

local function paint(animate)
    local on = FakeTrimp.Enabled
    local t = animate and 0.25 or 0
    tween(Switch, t, {BackgroundColor3 = on and C.On or C.Off})
    tween(Knob, t, {Position = on and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, Enum.EasingStyle.Back)
    tween(RowStroke, t, {Color = on and C.On or C.Stroke, Transparency = on and 0.2 or 0.3})
end

-- mismo comportamiento que el toggle original
local function setEnabled(enabled)
    if not trimpReady then
        warn("[Dara Trimp] No disponible: no se encontro ReplicatedStorage.Objects.Game.Character.Client.Movement en este juego")
        paint(true)
        return
    end
    FakeTrimp.Enabled = enabled
    if not enabled then currentSpeed = 0 end
    paint(true)
end
Row.MouseButton1Click:Connect(function()
    setEnabled(not FakeTrimp.Enabled)
end)

-- tecla Q original (con su notificación)
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Q then
        if not trimpReady then return end
        FakeTrimp.Enabled = not FakeTrimp.Enabled
        if not FakeTrimp.Enabled then currentSpeed = 0 end
        paint(true)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Fake Trimp",
            Text = FakeTrimp.Enabled and "ON" or "OFF",
            Duration = 2
        })
    end
end))

-- arrastrar desde la cabecera (mouse y táctil)
do
    local dragging, dragStart, startPos = false, nil, nil
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, Window.Position
        end
    end)
    table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

-- ✕: cierra por completo
local closed = false
local function closeAll()
    if closed then return end
    closed = true
    FakeTrimp.Enabled = false
    currentSpeed = 0
    -- se devuelve el Movement.Update original del juego (solo si sigue siendo el nuestro)
    if trimpReady and oldUpdate and Movement.Update == FakeTimpUpdate then
        Movement.Update = oldUpdate
    end
    for _, connection in ipairs(Connections) do pcall(function() connection:Disconnect() end) end
    if env.DaraTrimpStandaloneClose == closeAll then env.DaraTrimpStandaloneClose = nil end
    if Gui.Parent then Gui:Destroy() end
end
env.DaraTrimpStandaloneClose = closeAll
CloseButton.MouseButton1Click:Connect(function()
    tween(WindowScale, 0.15, {Scale = 0.85})
    closeAll()
end)

paint(false)
tween(WindowScale, 0.3, {Scale = 1}, Enum.EasingStyle.Back)
