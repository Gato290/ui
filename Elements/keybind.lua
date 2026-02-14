-- keybind.lua V1.1.0
-- Improved & Optimized Version

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local KeybindModule = {}

-- Modern Ripple Effect
local function CircleClick(Button, X, Y)
    task.spawn(function()
        Button.ClipsDescendants = true

        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(90, 90, 90)
        Circle.BackgroundTransparency = 1
        Circle.ImageTransparency = 0.7
        Circle.ZIndex = 10
        Circle.Size = UDim2.fromOffset(0, 0)
        Circle.Position = UDim2.fromOffset(X - Button.AbsolutePosition.X, Y - Button.AbsolutePosition.Y)
        Circle.AnchorPoint = Vector2.new(0.5, 0.5)
        Circle.Parent = Button

        local Size = math.max(Button.AbsoluteSize.X, Button.AbsoluteSize.Y) * 1.5

        local tween = TweenService:Create(Circle, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(Size, Size),
            Position = UDim2.fromScale(0.5, 0.5),
            ImageTransparency = 1
        })

        tween:Play()
        tween.Completed:Wait()
        Circle:Destroy()
    end)
end

local function GetKeyString(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        return input.KeyCode.Name
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        return "LMB"
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        return "RMB"
    elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
        return "MMB"
    end
    return nil
end

function KeybindModule.CreateKeybind(parent, config, layoutOrder)

    config = config or {}
    config.Title = config.Title or "Keybind"
    config.Value = config.Value or "V"
    config.Callback = config.Callback or function() end

    local currentKey = config.Value
    local isBinding = false
    local isEnabled = true

    local connections = {}

    -- UI
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundTransparency = 0.9
    Frame.LayoutOrder = layoutOrder or 1
    Frame.Parent = parent

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title
    Title.TextColor3 = Color3.fromRGB(230,230,230)
    Title.TextSize = 13
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(60,22)
    Button.Position = UDim2.new(1,-10,0.5,0)
    Button.AnchorPoint = Vector2.new(1,0.5)
    Button.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Button.TextColor3 = Color3.new(1,1,1)
    Button.TextSize = 12
    Button.Font = Enum.Font.GothamBold
    Button.Text = currentKey
    Button.Parent = Frame

    Instance.new("UICorner", Frame)
    Instance.new("UICorner", Button)

    local function updateKey(newKey)
        currentKey = newKey
        Button.Text = newKey or "-"
    end

    -- Binding mode
    Button.Activated:Connect(function()
        if isBinding then return end
        isBinding = true

        Button.Text = "..."
        CircleClick(Button, Mouse.X, Mouse.Y)

        local bindConnection
        bindConnection = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end

            if input.KeyCode == Enum.KeyCode.Escape then
                Button.Text = currentKey
                isBinding = false
                bindConnection:Disconnect()
                return
            end

            if input.KeyCode == Enum.KeyCode.Backspace then
                updateKey(nil)
                isBinding = false
                bindConnection:Disconnect()
                return
            end

            local key = GetKeyString(input)
            if key then
                updateKey(key)
                isBinding = false
                bindConnection:Disconnect()
            end
        end)
    end)

    -- Global Listener
    connections.main = UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not isEnabled or isBinding then return end
        local key = GetKeyString(input)
        if key and key == currentKey then
            pcall(config.Callback, key)
        end
    end)

    -- API
    local API = {}

    function API:Set(key)
        updateKey(key)
        return self
    end

    function API:Get()
        return currentKey
    end

    function API:Enable()
        isEnabled = true
        return self
    end

    function API:Disable()
        isEnabled = false
        return self
    end

    function API:Destroy()
        for _,c in pairs(connections) do
            if c then c:Disconnect() end
        end
        Frame:Destroy()
    end

    return API
end

return KeybindModule
