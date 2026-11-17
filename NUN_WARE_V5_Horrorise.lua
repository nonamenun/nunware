
--====================================================
--                  NUN WARE V5
--             DEVELOPER TESTING TOOL
--====================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--====================================================
-- OPEN ACCESS (no UserId allowlist)
--====================================================

--====================================================
-- CONFIGURATION
--====================================================

local S = {
    AimLock = false,
    AimMode = "Smooth Aim",
    AimKey = Enum.KeyCode.Q,
    MenuKey = Enum.KeyCode.RightControl,
    Listening = false,

    Prediction = true,
    PredictionAmount = 0.12,
    Smoothness = 0.15,
    FOV = 200,
    Reminder = true,

    ESP = false,
    Box = true,
    Name = true,
    Health = true,
    Tracers = false,
    TeamCheck = false,
}

local COLORS = {
    Background = Color3.fromRGB(17, 27, 39),
    Panel = Color3.fromRGB(25, 38, 53),
    Element = Color3.fromRGB(31, 47, 64),
    Blue = Color3.fromRGB(55, 150, 225),
    White = Color3.fromRGB(225, 233, 242),
    Muted = Color3.fromRGB(135, 155, 175),
    Green = Color3.fromRGB(75, 205, 125),
}

local TargetPlayer
local ESPObjects = {}
local Connections = {}
local Alive = true
local NotificationToken = 0

--====================================================
-- GUI CONSTRUCTION
--====================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "NunWareV5"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local function Round(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
end

local function Stroke(object, color, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Transparency = transparency or 0.5
    stroke.Parent = object
    return stroke
end

local function Label(parent, text, x, y, w, h, size, color)
    local obj = Instance.new("TextLabel")
    obj.Position = UDim2.fromOffset(x, y)
    obj.Size = UDim2.fromOffset(w, h)
    obj.BackgroundTransparency = 1
    obj.Text = text
    obj.TextColor3 = color or COLORS.White
    obj.Font = Enum.Font.GothamMedium
    obj.TextSize = size or 11
    obj.TextXAlignment = Enum.TextXAlignment.Left
    obj.Parent = parent
    return obj
end

local function Button(parent, text, x, y, w, h)
    local obj = Instance.new("TextButton")
    obj.Position = UDim2.fromOffset(x, y)
    obj.Size = UDim2.fromOffset(w, h)
    obj.BackgroundColor3 = COLORS.Element
    obj.BorderSizePixel = 0
    obj.Text = text
    obj.TextColor3 = COLORS.White
    obj.Font = Enum.Font.GothamMedium
    obj.TextSize = 10
    obj.AutoButtonColor = true
    obj.Parent = parent
    Round(obj, 4)
    return obj
end

--====================================================
-- MAIN WINDOW
--====================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(510, 390)
Main.Position = UDim2.new(0.5, -255, 0.5, -195)
Main.BackgroundColor3 = COLORS.Background
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

Round(Main, 7)
Stroke(Main, COLORS.Blue, 0.65)

-- Draggable header

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 54)
Header.BackgroundTransparency = 1
Header.Parent = Main

local HeaderTitle = Label(
    Header, "NunWare", 14, 5, 250, 27, 19, COLORS.Blue
)

Label(
    Header, "made by @horrorise", 15, 31, 200, 14, 8, COLORS.Muted
)

local Close = Button(Header, "X", 475, 12, 23, 23)

-- Dragging support

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--====================================================
-- CONTENT AND TABS
--====================================================

local TabBar = Instance.new("Frame")
TabBar.Position = UDim2.fromOffset(10, 57)
TabBar.Size = UDim2.new(1, -20, 0, 28)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(10, 91)
Content.Size = UDim2.new(1, -20, 1, -101)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function CreatePage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundColor3 = COLORS.Panel
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = COLORS.Blue
    page.CanvasSize = UDim2.fromOffset(0, 440)
    page.Visible = false
    page.Parent = Content
    Round(page, 5)
    return page
end

local VisualPage = CreatePage()
local AimPage = CreatePage()
local MiscPage = CreatePage()

local Pages = {
    Visual = VisualPage,
    Aimbot = AimPage,
    Misc = MiscPage,
}

local TabButtons = {}

local function SelectTab(name)
    for pageName, page in pairs(Pages) do
        page.Visible = pageName == name
    end

    for _, button in ipairs(TabButtons) do
        local selected = button.Text == name
        button.TextColor3 = selected and COLORS.Blue or COLORS.White
        button.BackgroundColor3 = selected
            and COLORS.Element or COLORS.Background
    end
end

for i, name in ipairs({"Visual", "Aimbot", "Misc"}) do
    local button = Button(
        TabBar, name,
        (i - 1) * 163, 0, 158, 26
    )

    table.insert(TabButtons, button)

    button.MouseButton1Click:Connect(function()
        SelectTab(name)
    end)
end

--====================================================
-- TOGGLE COMPONENT
--====================================================

local function MakeToggle(parent, title, setting, y)
    local row = Button(parent, "", 12, y, 466, 27)

    local text = Label(
        row, title, 9, 0, 300, 27, 10, COLORS.White
    )
    text.ZIndex = row.ZIndex + 1

    local switch = Instance.new("Frame")
    switch.Size = UDim2.fromOffset(24, 12)
    switch.Position = UDim2.new(1, -34, 0.5, -6)
    switch.BackgroundColor3 = COLORS.Element
    switch.BorderSizePixel = 0
    switch.Parent = row
    Round(switch, 10)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(8, 8)
    dot.Position = UDim2.fromOffset(2, 2)
    dot.BackgroundColor3 = COLORS.White
    dot.BorderSizePixel = 0
    dot.Parent = switch
    Round(dot, 10)

    local function Refresh()
        switch.BackgroundColor3 = S[setting]
            and COLORS.Blue or Color3.fromRGB(65, 76, 88)

        dot.Position = S[setting]
            and UDim2.fromOffset(14, 2)
            or UDim2.fromOffset(2, 2)
    end

    Refresh()

    row.MouseButton1Click:Connect(function()
        S[setting] = not S[setting]
        Refresh()
    end)

    return row
end

--====================================================
-- NUMBER INPUT
--====================================================

local function MakeNumber(parent, title, setting, y, minimum, maximum)
    local row = Button(parent, "", 12, y, 466, 27)

    local text = Label(
        row, title, 9, 0, 300, 27, 10, COLORS.White
    )
    text.ZIndex = row.ZIndex + 1

    local input = Instance.new("TextBox")
    input.Size = UDim2.fromOffset(60, 20)
    input.Position = UDim2.new(1, -68, 0, 3)
    input.BackgroundColor3 = COLORS.Background
    input.TextColor3 = COLORS.Blue
    input.Text = tostring(S[setting])
    input.Font = Enum.Font.GothamMedium
    input.TextSize = 10
    input.ClearTextOnFocus = false
    input.Parent = row
    Round(input, 3)

    input.FocusLost:Connect(function()
        local value = tonumber(input.Text)

        if value then
            S[setting] = math.clamp(value, minimum, maximum)
        end

        input.Text = tostring(S[setting])
    end)

    return input
end

--====================================================
-- VISUAL PAGE
--====================================================

Label(VisualPage, "ESP", 14, 8, 200, 20, 10, COLORS.Blue)

MakeToggle(VisualPage, "ESP Enable", "ESP", 34)
MakeToggle(VisualPage, "Box", "Box", 65)
MakeToggle(VisualPage, "Name", "Name", 96)
MakeToggle(VisualPage, "Health", "Health", 127)
MakeToggle(VisualPage, "Tracer", "Tracers", 158)
MakeToggle(VisualPage, "Team Check", "TeamCheck", 189)

--====================================================
-- AIM PAGE
--====================================================

Label(AimPage, "AIM SETTINGS", 14, 8, 200, 20, 10, COLORS.Blue)

MakeToggle(AimPage, "Camera Tracking", "AimLock", 34)
MakeToggle(AimPage, "Prediction", "Prediction", 65)
MakeToggle(AimPage, "Notification", "Reminder", 96)

MakeNumber(AimPage, "Smoothness", "Smoothness", 132, 0.01, 1)
MakeNumber(AimPage, "Prediction Time", "PredictionAmount", 163, 0, 1)
MakeNumber(AimPage, "FOV", "FOV", 194, 20, 1000)

Label(AimPage, "MODE", 14, 231, 200, 20, 10, COLORS.Blue)

local ModeNames = {
    "Cam Lock",
    "Smooth Aim",
    "Soft Aim"
}

local ModeButtons = {}

local function RefreshModes()
    for _, button in ipairs(ModeButtons) do
        local active = button:GetAttribute("Mode") == S.AimMode

        button.BackgroundColor3 = active
            and COLORS.Blue or COLORS.Background
    end
end

for i, mode in ipairs(ModeNames) do
    local button = Button(
        AimPage,
        mode,
        14 + (i - 1) * 155,
        254,
        145,
        27
    )

    button:SetAttribute("Mode", mode)

    button.MouseButton1Click:Connect(function()
        S.AimMode = mode
        RefreshModes()
    end)

    table.insert(ModeButtons, button)
end

RefreshModes()

Label(AimPage, "AIM KEY", 14, 291, 100, 20, 10, COLORS.Blue)

local KeyButton = Button(
    AimPage,
    "KEY: " .. S.AimKey.Name,
    14, 314, 464, 27
)

KeyButton.MouseButton1Click:Connect(function()
    S.Listening = true
    KeyButton.Text = "PRESS A KEY..."
end)

--====================================================
-- MISC PAGE
--====================================================

Label(MiscPage, "GENERAL", 14, 8, 200, 20, 10, COLORS.Blue)

Label(
    MiscPage, "MENU KEY", 14, 38, 150, 20, 10, COLORS.White
)

local MenuKeyButton = Button(
    MiscPage,
    "RIGHT CTRL",
    14, 62, 464, 27
)

MenuKeyButton.MouseButton1Click:Connect(function()
    S.MenuListening = true
    MenuKeyButton.Text = "PRESS A KEY..."
end)

Label(
    MiscPage,
    "NUN WARE V5",
    14, 110, 200, 20, 11, COLORS.Blue
)

Label(
    MiscPage,
    "Developer testing interface",
    14, 132, 300, 20, 9, COLORS.Muted
)

--====================================================
-- NOTIFICATIONS
--====================================================

local Notification = Instance.new("TextLabel")
Notification.Size = UDim2.fromOffset(250, 30)
Notification.Position = UDim2.new(0.5, -125, 0, 12)
Notification.BackgroundColor3 = COLORS.Background
Notification.TextColor3 = COLORS.Blue
Notification.Font = Enum.Font.GothamBold
Notification.TextSize = 11
Notification.Visible = false
Notification.Parent = Gui
Round(Notification, 5)
Stroke(Notification, COLORS.Blue, 0.6)

local function Notify(message)
    if not S.Reminder then return end

    NotificationToken += 1
    local token = NotificationToken

    Notification.Text = message
    Notification.Visible = true

    task.delay(2.5, function()
        if token == NotificationToken then
            Notification.Visible = false
        end
    end)
end

--====================================================
-- TARGET VALIDATION
--====================================================

local function IsValidTarget(target)
    if not target or target == Player then
        return false
    end

    if not target.Parent or not target.Character then
        return false
    end

    local character = target.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")

    if not humanoid or humanoid.Health <= 0 or not head then
        return false
    end

    if S.TeamCheck and Player.Team ~= nil
        and target.Team == Player.Team then
        return false
    end

    return true
end

--====================================================
-- CLOSEST TO MOUSE
--====================================================

local function GetClosestTarget()
    local closest = nil
    local shortest = S.FOV

    local inset = GuiService:GetGuiInset()
    local mouse = UIS:GetMouseLocation() - inset

    for _, target in ipairs(Players:GetPlayers()) do
        if IsValidTarget(target) then
            local head = target.Character.Head

            local position, visible =
                Camera:WorldToViewportPoint(head.Position)

            if visible and position.Z > 0 then
                local distance = (
                    Vector2.new(position.X, position.Y) - mouse
                ).Magnitude

                if distance < shortest then
                    shortest = distance
                    closest = target
                end
            end
        end
    end

    return closest
end

--====================================================
-- ESP MANAGEMENT
--====================================================

local function RemoveESP(target)
    local objects = ESPObjects[target]
    if not objects then return end

    for _, object in pairs(objects) do
        if object and object.Parent then
            object:Destroy()
        end
    end

    ESPObjects[target] = nil
end

local function CreateESP(target)
    if not IsValidTarget(target) then return end

    local character = target.Character
    local head = character:FindFirstChild("Head")

    local objects = {}

    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillColor = COLORS.Blue
    highlight.OutlineColor = COLORS.Blue
    highlight.FillTransparency = 0.9
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = character
    objects.Highlight = highlight

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NunWareESP"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(120, 32)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = Gui
    objects.Billboard = billboard

    local name = Instance.new("TextLabel")
    name.Size = UDim2.fromScale(1, 0.55)
    name.BackgroundTransparency = 1
    name.Text = target.DisplayName
    name.TextColor3 = COLORS.Blue
    name.TextStrokeTransparency = 0.4
    name.Font = Enum.Font.GothamBold
    name.TextSize = 11
    name.Parent = billboard
    objects.Name = name

    local healthBack = Instance.new("Frame")
    healthBack.Position = UDim2.new(0.1, 0, 0.75, 0)
    healthBack.Size = UDim2.new(0.8, 0, 0, 4)
    healthBack.BackgroundColor3 = COLORS.Background
    healthBack.BorderSizePixel = 0
    healthBack.Parent = billboard
    objects.HealthBack = healthBack

    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.fromScale(1, 1)
    healthFill.BackgroundColor3 = COLORS.Green
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBack
    objects.HealthFill = healthFill

    ESPObjects[target] = objects
end

local function UpdateESP()
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= Player then
            if not S.ESP or not IsValidTarget(target) then
                RemoveESP(target)
            else
                local objects = ESPObjects[target]

                if objects and
                    objects.Highlight.Adornee ~= target.Character then
                    RemoveESP(target)
                    objects = nil
                end

                if not objects then
                    CreateESP(target)
                    objects = ESPObjects[target]
                end

                if objects then
                    objects.Highlight.Enabled =
                        S.Box

                    objects.Name.Visible =
                        S.Name

                    objects.HealthBack.Visible =
                        S.Health

                    local humanoid =
                        target.Character:FindFirstChildOfClass("Humanoid")

                    if humanoid then
                        objects.HealthFill.Size = UDim2.fromScale(
                            math.clamp(
                                humanoid.Health /
                                math.max(humanoid.MaxHealth, 1),
                                0, 1
                            ),
                            1
                        )
                    end
                end
            end
        end
    end
end

--====================================================
-- TRACERS
--====================================================

local function UpdateTracers()
    for target, objects in pairs(ESPObjects) do
        local character = target.Character
        local root = character and
            character:FindFirstChild("HumanoidRootPart")

        if root and S.ESP and S.Tracers and IsValidTarget(target) then
            local position, visible =
                Camera:WorldToViewportPoint(root.Position)

            if visible and position.Z > 0 then
                local start = Vector2.new(
                    Camera.ViewportSize.X / 2,
                    Camera.ViewportSize.Y
                )

                local finish = Vector2.new(position.X, position.Y)
                local delta = finish - start

                local tracer = objects.Tracer

                if not tracer then
                    tracer = Instance.new("Frame")
                    tracer.AnchorPoint = Vector2.new(0, 0.5)
                    tracer.BackgroundColor3 = COLORS.Blue
                    tracer.BorderSizePixel = 0
                    tracer.Parent = Gui
                    objects.Tracer = tracer
                end

                tracer.Visible = true
                tracer.Position = UDim2.fromOffset(start.X, start.Y)
                tracer.Size = UDim2.fromOffset(delta.Magnitude, 1)
                tracer.Rotation = math.deg(
                    math.atan2(delta.Y, delta.X)
                )
            elseif objects.Tracer then
                objects.Tracer.Visible = false
            end
        elseif objects.Tracer then
            objects.Tracer.Visible = false
        end
    end
end

--====================================================
-- CAMERA TRACKING
--====================================================

local function UpdateCamera()
    if not S.AimLock then
        TargetPlayer = nil
        return
    end

    -- Sticky target: only choose a new player if the
    -- current player becomes invalid.
    if not IsValidTarget(TargetPlayer) then
        TargetPlayer = GetClosestTarget()

        if TargetPlayer then
            Notify('LOCKED: ' .. TargetPlayer.DisplayName)
        end
    end

    local target = TargetPlayer
    if not target then return end

    local character = target.Character
    local head = character:FindFirstChild("Head")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not head or not root then return end

    local position = head.Position

    if S.Prediction then
        position += root.AssemblyLinearVelocity *
            S.PredictionAmount
    end

    local goal = CFrame.lookAt(
        Camera.CFrame.Position,
        position
    )

    local alpha

    if S.AimMode == "Cam Lock" then
        alpha = 1
    elseif S.AimMode == "Smooth Aim" then
        alpha = S.Smoothness
    else
        alpha = math.clamp(
            S.Smoothness * 0.35,
            0.01,
            0.15
        )
    end

    Camera.CFrame = Camera.CFrame:Lerp(goal, alpha)
end

--====================================================
-- MAIN UPDATE LOOP
--====================================================

Connections.Render = RunService.RenderStepped:Connect(function()
    if not Alive then return end

    Camera = workspace.CurrentCamera

    UpdateESP()
    UpdateTracers()
    UpdateCamera()
end)

--====================================================
-- INPUT HANDLER
--====================================================

Connections.Input = UIS.InputBegan:Connect(function(input, processed)

    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end

    if S.Listening then
        if input.KeyCode == Enum.KeyCode.Escape then
            S.Listening = false
            KeyButton.Text = "KEY: " .. S.AimKey.Name
            return
        end

        if input.KeyCode ~= Enum.KeyCode.Unknown then
            S.AimKey = input.KeyCode
            S.Listening = false
            KeyButton.Text = "KEY: " .. S.AimKey.Name
        end

        return
    end

    if S.MenuListening then
        if input.KeyCode == Enum.KeyCode.Escape then
            S.MenuListening = false
            MenuKeyButton.Text = S.MenuKey.Name
            return
        end

        if input.KeyCode ~= Enum.KeyCode.Unknown then
            S.MenuKey = input.KeyCode
            S.MenuListening = false
            MenuKeyButton.Text = S.MenuKey.Name
        end

        return
    end

    if processed then return end

    if input.KeyCode == S.AimKey then
        S.AimLock = not S.AimLock

        TargetPlayer = nil

        if not S.AimLock then
            Notification.Visible = false
        end
    end

    if input.KeyCode == S.MenuKey then
        Main.Visible = not Main.Visible
    end
end)

--====================================================
-- CLEANUP
--====================================================

Connections.PlayerRemoving =
    Players.PlayerRemoving:Connect(function(target)
        RemoveESP(target)

        if TargetPlayer == target then
            TargetPlayer = nil
        end
    end)

Connections.Destroying =
    Gui.Destroying:Connect(function()
        Alive = false

        for _, connection in pairs(Connections) do
            connection:Disconnect()
        end

        for target in pairs(ESPObjects) do
            RemoveESP(target)
        end
    end)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

SelectTab("Visual")

print("================================")
print("          NUN WARE V5")
print("       DEVELOPER TOOL READY")
print("================================")
