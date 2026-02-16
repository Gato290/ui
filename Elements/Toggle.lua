return function(ToggleConfig, ctx)
    local ToggleConfig = ToggleConfig or {}
    ToggleConfig.Title = ToggleConfig.Title or "Title"
    ToggleConfig.Title2 = ToggleConfig.Title2 or ""
    ToggleConfig.Content = ToggleConfig.Content or ""
    ToggleConfig.Default = ToggleConfig.Default or false
    ToggleConfig.Callback = ToggleConfig.Callback or function() end

    local configKey = "Toggle_" .. ToggleConfig.Title
    if ctx.ConfigData[configKey] ~= nil then
        ToggleConfig.Default = ctx.ConfigData[configKey]
    end

    local ToggleFunc = { Value = ToggleConfig.Default, key = configKey }

    local Toggle = Instance.new("Frame")
    local UICorner20 = Instance.new("UICorner")
    local ToggleTitle = Instance.new("TextLabel")
    local ToggleContent = Instance.new("TextLabel")
    local ToggleButton = Instance.new("TextButton")
    local FeatureFrame2 = Instance.new("Frame")
    local UICorner22 = Instance.new("UICorner")
    local UIStroke8 = Instance.new("UIStroke")
    local ToggleCircle = Instance.new("Frame")
    local UICorner23 = Instance.new("UICorner")

    Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.BackgroundTransparency = 0.935
    Toggle.BorderSizePixel = 0
    Toggle.LayoutOrder = ctx.CountItem()
    Toggle.Name = "Toggle"
    Toggle.Parent = ctx.SectionAdd

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

    ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        ToggleContent.TextWrapped = false
        ToggleContent.Size = UDim2.new(1, -100, 0,
            12 + (12 * (ToggleContent.TextBounds.X // ToggleContent.AbsoluteSize.X)))
        if ToggleConfig.Title2 ~= "" then
            Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
        else
            Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
        end
        ToggleContent.TextWrapped = true
        ctx.UpdateSizeSection()
    end)

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

    ToggleButton.Activated:Connect(function()
        ctx.CircleClick(ToggleButton, ctx.Mouse.X, ctx.Mouse.Y)
        ToggleFunc.Value = not ToggleFunc.Value
        ToggleFunc:Set(ToggleFunc.Value)
    end)

    function ToggleFunc:Set(Value)
        if typeof(ToggleConfig.Callback) == "function" then
            local ok, err = pcall(function()
                ToggleConfig.Callback(Value)
            end)
            if not ok then warn("Toggle Callback error:", err) end
        end
        ctx.ConfigData[configKey] = Value
        ctx.SaveConfig()
        if Value then
            ctx.TweenService:Create(ToggleTitle, ctx.TweenInfo.new(0.2), { TextColor3 = ctx.GuiConfig.Color }):Play()
            ctx.TweenService:Create(ToggleCircle, ctx.TweenInfo.new(0.2), { Position = UDim2.new(0, 15, 0, 0) })
                :Play()
            ctx.TweenService:Create(UIStroke8, ctx.TweenInfo.new(0.2), { Color = ctx.GuiConfig.Color, Transparency = 0 })
                :Play()
            ctx.TweenService:Create(FeatureFrame2, ctx.TweenInfo.new(0.2),
                { BackgroundColor3 = ctx.GuiConfig.Color, BackgroundTransparency = 0 }):Play()
        else
            ctx.TweenService:Create(ToggleTitle, ctx.TweenInfo.new(0.2),
                { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
            ctx.TweenService:Create(ToggleCircle, ctx.TweenInfo.new(0.2), { Position = UDim2.new(0, 0, 0, 0) }):Play()
            ctx.TweenService:Create(UIStroke8, ctx.TweenInfo.new(0.2),
                { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
            ctx.TweenService:Create(FeatureFrame2, ctx.TweenInfo.new(0.2),
                { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
        end
    end

    ToggleFunc:Set(ToggleFunc.Value)
    
    return ToggleFunc
end
