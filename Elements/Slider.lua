local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Utils.lua"))()
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Config.lua"))()

local SliderElement = {}

function SliderElement:Create(SliderConfig, GuiConfig, configKey)
    SliderConfig = SliderConfig or {}
    SliderConfig.Title = SliderConfig.Title or "Slider"
    SliderConfig.Content = SliderConfig.Content or ""
    SliderConfig.Increment = SliderConfig.Increment or 1
    SliderConfig.Min = SliderConfig.Min or 0
    SliderConfig.Max = SliderConfig.Max or 100
    SliderConfig.Default = SliderConfig.Default or 50
    SliderConfig.Callback = SliderConfig.Callback or function() end

    -- Check if config exists
    if configKey and Config.ConfigData[configKey] ~= nil then
        SliderConfig.Default = Config.ConfigData[configKey]
    end

    local SliderFunc = { Value = SliderConfig.Default }

    local Slider = Instance.new("Frame")
    local UICorner15 = Instance.new("UICorner")
    local SliderTitle = Instance.new("TextLabel")
    local SliderContent = Instance.new("TextLabel")
    local SliderInput = Instance.new("Frame")
    local UICorner16 = Instance.new("UICorner")
    local TextBox = Instance.new("TextBox")
    local SliderFrame = Instance.new("Frame")
    local UICorner17 = Instance.new("UICorner")
    local SliderDraggable = Instance.new("Frame")
    local UICorner18 = Instance.new("UICorner")
    local SliderCircle = Instance.new("Frame")
    local UICorner19 = Instance.new("UICorner")
    local UIStroke6 = Instance.new("UIStroke")

    Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Slider.BackgroundTransparency = 0.935
    Slider.BorderSizePixel = 0
    Slider.Name = "Slider"
    Slider.Parent = parent

    UICorner15.CornerRadius = UDim.new(0, 4)
    UICorner15.Parent = Slider

    SliderTitle.Font = Enum.Font.GothamBold
    SliderTitle.Text = SliderConfig.Title
    SliderTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    SliderTitle.TextSize = 13
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Position = UDim2.new(0, 10, 0, 10)
    SliderTitle.Size = UDim2.new(1, -180, 0, 13)
    SliderTitle.Name = "SliderTitle"
    SliderTitle.Parent = Slider

    SliderContent.Font = Enum.Font.GothamBold
    SliderContent.Text = SliderConfig.Content
    SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderContent.TextSize = 12
    SliderContent.TextTransparency = 0.6
    SliderContent.TextXAlignment = Enum.TextXAlignment.Left
    SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
    SliderContent.BackgroundTransparency = 1
    SliderContent.Position = UDim2.new(0, 10, 0, 25)
    SliderContent.Size = UDim2.new(1, -180, 0, 12)
    SliderContent.Name = "SliderContent"
    SliderContent.Parent = Slider

    SliderContent.Size = UDim2.new(1, -180, 0,
        12 + (12 * (SliderContent.TextBounds.X // SliderContent.AbsoluteSize.X)))
    SliderContent.TextWrapped = true
    Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)

    SliderInput.AnchorPoint = Vector2.new(0, 0.5)
    SliderInput.BackgroundColor3 = GuiConfig.Color
    SliderInput.BackgroundTransparency = 1
    SliderInput.BorderSizePixel = 0
    SliderInput.Position = UDim2.new(1, -155, 0.5, 0)
    SliderInput.Size = UDim2.new(0, 28, 0, 20)
    SliderInput.Name = "SliderInput"
    SliderInput.Parent = Slider

    UICorner16.CornerRadius = UDim.new(0, 2)
    UICorner16.Parent = SliderInput

    TextBox.Font = Enum.Font.GothamBold
    TextBox.Text = tostring(SliderConfig.Default)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.TextSize = 13
    TextBox.TextWrapped = true
    TextBox.BackgroundTransparency = 1
    TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.BorderSizePixel = 0
    TextBox.Position = UDim2.new(0, -1, 0, 0)
    TextBox.Size = UDim2.new(1, 0, 1, 0)
    TextBox.Parent = SliderInput

    SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderFrame.BackgroundTransparency = 0.8
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
    SliderFrame.Size = UDim2.new(0, 100, 0, 3)
    SliderFrame.Name = "SliderFrame"
    SliderFrame.Parent = Slider

    UICorner17.Parent = SliderFrame

    SliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
    SliderDraggable.BackgroundColor3 = GuiConfig.Color
    SliderDraggable.BorderSizePixel = 0
    SliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
    SliderDraggable.Size = UDim2.new(0.9, 0, 0, 1)
    SliderDraggable.Name = "SliderDraggable"
    SliderDraggable.Parent = SliderFrame

    UICorner18.Parent = SliderDraggable

    SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
    SliderCircle.BackgroundColor3 = GuiConfig.Color
    SliderCircle.BorderSizePixel = 0
    SliderCircle.Position = UDim2.new(1, 4, 0.5, 0)
    SliderCircle.Size = UDim2.new(0, 8, 0, 8)
    SliderCircle.Name = "SliderCircle"
    SliderCircle.Parent = SliderDraggable

    UICorner19.Parent = SliderCircle

    UIStroke6.Color = GuiConfig.Color
    UIStroke6.Parent = SliderCircle

    local Dragging = false
    
    local function Round(Number, Factor)
        local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
        if Result < 0 then
            Result = Result + Factor
        end
        return Result
    end
    
    function SliderFunc:Set(Value, silent)
        Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
        SliderFunc.Value = Value
        TextBox.Text = tostring(Value)
        
        local ratio = (Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
        TweenService:Create(
            SliderDraggable,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.fromScale(ratio, 1) }
        ):Play()

        -- Save to config
        if configKey then
            Config.ConfigData[configKey] = Value
            Config.SaveConfig()
        end
        
        -- Callback (if not silent)
        if not silent and SliderConfig.Callback then
            local success, err = pcall(function()
                SliderConfig.Callback(Value)
            end)
            if not success then
                warn("Slider callback error:", err)
            end
        end
    end

    function SliderFunc:Get()
        return self.Value
    end

    -- TextBox input
    TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local Valid = TextBox.Text:gsub("[^%d]", "")
        if Valid ~= "" then
            local ValidNumber = math.clamp(tonumber(Valid), SliderConfig.Min, SliderConfig.Max)
            SliderFunc:Set(ValidNumber)
        else
            SliderFunc:Set(SliderConfig.Min)
        end
    end)

    -- Slider dragging
    SliderFrame.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            TweenService:Create(
                SliderCircle,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.new(0, 14, 0, 14) }
            ):Play()
            
            local SizeScale = math.clamp(
                (Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X,
                0,
                1
            )
            SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
        end
    end)

    SliderFrame.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            TweenService:Create(
                SliderCircle,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.new(0, 8, 0, 8) }
            ):Play()
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local SizeScale = math.clamp(
                (Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X,
                0,
                1
            )
            SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
        end
    end)

    -- Connect to config system
    if configKey then
        Config.Elements[configKey] = SliderFunc
    end

    -- Initialize
    SliderFunc:Set(SliderFunc.Value, true)

    return Slider
end

return SliderElement
