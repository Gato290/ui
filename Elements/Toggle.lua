local TweenService = game:GetService("TweenService")
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Utils.lua"))()
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Config.lua"))()

local ToggleElement = {}

function ToggleElement:Create(ToggleConfig, GuiConfig, configKey)
    ToggleConfig = ToggleConfig or {}
    ToggleConfig.Title = ToggleConfig.Title or "Title"
    ToggleConfig.Title2 = ToggleConfig.Title2 or ""
    ToggleConfig.Content = ToggleConfig.Content or ""
    ToggleConfig.Default = ToggleConfig.Default or false
    ToggleConfig.Callback = ToggleConfig.Callback or function() end

    -- Check if config exists
    if configKey and Config.ConfigData[configKey] ~= nil then
        ToggleConfig.Default = Config.ConfigData[configKey]
    end

    local ToggleFunc = { Value = ToggleConfig.Default }

    local Toggle = Instance.new("Frame")
    local UICorner20 = Instance.new("UICorner")
    local ToggleTitle = Instance.new("TextLabel")
    local ToggleButton = Instance.new("TextButton")
    local FeatureFrame2 = Instance.new("Frame")
    local UICorner22 = Instance.new("UICorner")
    local UIStroke8 = Instance.new("UIStroke")
    local ToggleCircle = Instance.new("Frame")
    local UICorner23 = Instance.new("UICorner")

    Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.BackgroundTransparency = 0.935
    Toggle.BorderSizePixel = 0
    Toggle.Name = "Toggle"
    Toggle.Parent = parent

    UICorner20.CornerRadius = UDim.new(0, 4)
    UICorner20.Parent = Toggle

    ToggleTitle.Font = Enum.Font.GothamBold
    ToggleTitle.Text = ToggleConfig.Title
    ToggleTitle.TextSize = 13
    ToggleTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
    ToggleTitle.BackgroundTransparency = 1
    ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
    ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
    ToggleTitle.Name = "ToggleTitle"
    ToggleTitle.Parent = Toggle

    local ToggleTitle2 = Instance.new("TextLabel")
    ToggleTitle2.Font = Enum.Font.GothamBold
    ToggleTitle2.Text = ToggleConfig.Title2
    ToggleTitle2.TextSize = 12
    ToggleTitle2.TextColor3 = Color3.fromRGB(231, 231, 231)
    ToggleTitle2.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle2.TextYAlignment = Enum.TextYAlignment.Top
    ToggleTitle2.BackgroundTransparency = 1
    ToggleTitle2.Position = UDim2.new(0, 10, 0, 23)
    ToggleTitle2.Size = UDim2.new(1, -100, 0, 12)
    ToggleTitle2.Name = "ToggleTitle2"
    ToggleTitle2.Parent = Toggle

    local ToggleContent = Instance.new("TextLabel")
    ToggleContent.Font = Enum.Font.GothamBold
    ToggleContent.Text = ToggleConfig.Content
    ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleContent.TextSize = 12
    ToggleContent.TextTransparency = 0.6
    ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
    ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
    ToggleContent.BackgroundTransparency = 1
    ToggleContent.Size = UDim2.new(1, -100, 0, 12)
    ToggleContent.Name = "ToggleContent"
    ToggleContent.Parent = Toggle

    if ToggleConfig.Title2 ~= "" then
        Toggle.Size = UDim2.new(1, 0, 0, 57)
        ToggleContent.Position = UDim2.new(0, 10, 0, 36)
        ToggleTitle2.Visible = true
    else
        Toggle.Size = UDim2.new(1, 0, 0, 46)
        ToggleContent.Position = UDim2.new(0, 10, 0, 23)
        ToggleTitle2.Visible = false
    end

    ToggleContent.Size = UDim2.new(1, -100, 0,
        12 + (12 * (ToggleContent.TextBounds.X // ToggleContent.AbsoluteSize.X)))
    ToggleContent.TextWrapped = true
    if ToggleConfig.Title2 ~= "" then
        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
    else
        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
    end

    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.Text = ""
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = Toggle

    FeatureFrame2.AnchorPoint = Vector2.new(1, 0.5)
    FeatureFrame2.BackgroundTransparency = 0.92
    FeatureFrame2.BorderSizePixel = 0
    FeatureFrame2.Position = UDim2.new(1, -15, 0.5, 0)
    FeatureFrame2.Size = UDim2.new(0, 30, 0, 15)
    FeatureFrame2.Name = "FeatureFrame"
    FeatureFrame2.Parent = Toggle

    UICorner22.Parent = FeatureFrame2

    UIStroke8.Color = Color3.fromRGB(255, 255, 255)
    UIStroke8.Thickness = 2
    UIStroke8.Transparency = 0.9
    UIStroke8.Parent = FeatureFrame2

    ToggleCircle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
    ToggleCircle.Name = "ToggleCircle"
    ToggleCircle.Parent = FeatureFrame2

    UICorner23.CornerRadius = UDim.new(0, 15)
    UICorner23.Parent = ToggleCircle

    -- Click handler
    ToggleButton.Activated:Connect(function()
        Utils.CircleClick(ToggleButton, 
            game:GetService("Players").LocalPlayer:GetMouse().X, 
            game:GetService("Players").LocalPlayer:GetMouse().Y)
        ToggleFunc.Value = not ToggleFunc.Value
        ToggleFunc:Set(ToggleFunc.Value)
    end)

    -- Set function
    function ToggleFunc:Set(Value, silent)
        self.Value = Value
        
        -- Save to config
        if configKey then
            Config.ConfigData[configKey] = Value
            Config.SaveConfig()
        end
        
        -- Visual update
        if Value then
            TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 15, 0, 0) }):Play()
            TweenService:Create(UIStroke8, TweenInfo.new(0.2), { Color = GuiConfig.Color, Transparency = 0 }):Play()
            TweenService:Create(FeatureFrame2, TweenInfo.new(0.2),
                { BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0 }):Play()
        else
            TweenService:Create(ToggleTitle, TweenInfo.new(0.2),
                { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 0, 0, 0) }):Play()
            TweenService:Create(UIStroke8, TweenInfo.new(0.2),
                { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
            TweenService:Create(FeatureFrame2, TweenInfo.new(0.2),
                { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
        end
        
        -- Callback (if not silent)
        if not silent and ToggleConfig.Callback then
            local success, err = pcall(function()
                ToggleConfig.Callback(Value)
            end)
            if not success then
                warn("Toggle callback error:", err)
            end
        end
    end

    -- Get function
    function ToggleFunc:Get()
        return self.Value
    end

    -- Toggle function
    function ToggleFunc:Toggle()
        self.Value = not self.Value
        self:Set(self.Value)
    end

    -- Connect to config system
    if configKey then
        Config.Elements[configKey] = ToggleFunc
    end

    -- Initialize
    ToggleFunc:Set(ToggleFunc.Value, true)

    return Toggle
end

return ToggleElement
