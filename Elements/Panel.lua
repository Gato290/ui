return function(PanelConfig, ctx)
    PanelConfig = PanelConfig or {}
    PanelConfig.Title = PanelConfig.Title or "Title"
    PanelConfig.Content = PanelConfig.Content or ""
    PanelConfig.Placeholder = PanelConfig.Placeholder or nil
    PanelConfig.Default = PanelConfig.Default or ""
    PanelConfig.ButtonText = PanelConfig.Button or PanelConfig.ButtonText or "Confirm"
    PanelConfig.ButtonCallback = PanelConfig.Callback or PanelConfig.ButtonCallback or function() end
    PanelConfig.SubButtonText = PanelConfig.SubButton or PanelConfig.SubButtonText or nil
    PanelConfig.SubButtonCallback = PanelConfig.SubCallback or PanelConfig.SubButtonCallback or
        function() end

    local configKey = "Panel_" .. PanelConfig.Title
    if ctx.ConfigData[configKey] ~= nil then
        PanelConfig.Default = ctx.ConfigData[configKey]
    end

    local PanelFunc = { Value = PanelConfig.Default, key = configKey }

    local baseHeight = 50

    if PanelConfig.Placeholder then
        baseHeight = baseHeight + 40
    end

    if PanelConfig.SubButtonText then
        baseHeight = baseHeight + 40
    else
        baseHeight = baseHeight + 36
    end

    local Panel = Instance.new("Frame")
    Panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Panel.BackgroundTransparency = 0.935
    Panel.Size = UDim2.new(1, 0, 0, baseHeight)
    Panel.LayoutOrder = ctx.CountItem()
    Panel.Parent = ctx.SectionAdd

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Panel

    local Title = Instance.new("TextLabel")
    Title.Font = Enum.Font.GothamBold
    Title.Text = PanelConfig.Title
    Title.TextSize = 13
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Size = UDim2.new(1, -20, 0, 13)
    Title.Parent = Panel

    local Content = Instance.new("TextLabel")
    Content.Font = Enum.Font.Gotham
    Content.Text = PanelConfig.Content
    Content.TextSize = 12
    Content.TextColor3 = Color3.fromRGB(255, 255, 255)
    Content.TextTransparency = 0
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.BackgroundTransparency = 1
    Content.RichText = true
    Content.Position = UDim2.new(0, 10, 0, 28)
    Content.Size = UDim2.new(1, -20, 0, 14)
    Content.Parent = Panel

    local InputBox
    if PanelConfig.Placeholder then
        local InputFrame = Instance.new("Frame")
        InputFrame.AnchorPoint = Vector2.new(0.5, 0)
        InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputFrame.BackgroundTransparency = 0.95
        InputFrame.Position = UDim2.new(0.5, 0, 0, 48)
        InputFrame.Size = UDim2.new(1, -20, 0, 30)
        InputFrame.Parent = Panel

        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 4)
        inputCorner.Parent = InputFrame

        InputBox = Instance.new("TextBox")
        InputBox.Font = Enum.Font.GothamBold
        InputBox.PlaceholderText = PanelConfig.Placeholder
        InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        InputBox.Text = PanelConfig.Default
        InputBox.TextSize = 11
        InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputBox.BackgroundTransparency = 1
        InputBox.TextXAlignment = Enum.TextXAlignment.Left
        InputBox.Size = UDim2.new(1, -10, 1, -6)
        InputBox.Position = UDim2.new(0, 5, 0, 3)
        InputBox.Parent = InputFrame
    end

    local yBtn = 0
    if PanelConfig.Placeholder then
        yBtn = 88
    else
        yBtn = 48
    end

    local ButtonMain = Instance.new("TextButton")
    ButtonMain.Font = Enum.Font.GothamBold
    ButtonMain.Text = PanelConfig.ButtonText
    ButtonMain.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonMain.TextSize = 12
    ButtonMain.TextTransparency = 0.3
    ButtonMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ButtonMain.BackgroundTransparency = 0.935
    ButtonMain.Size = PanelConfig.SubButtonText and UDim2.new(0.5, -12, 0, 30) or UDim2.new(1, -20, 0, 30)
    ButtonMain.Position = UDim2.new(0, 10, 0, yBtn)
    ButtonMain.Parent = Panel

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = ButtonMain

    ButtonMain.MouseButton1Click:Connect(function()
        PanelConfig.ButtonCallback(InputBox and InputBox.Text or "")
    end)

    if PanelConfig.SubButtonText then
        local SubButton = Instance.new("TextButton")
        SubButton.Font = Enum.Font.GothamBold
        SubButton.Text = PanelConfig.SubButtonText
        SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        SubButton.TextSize = 12
        SubButton.TextTransparency = 0.3
        SubButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SubButton.BackgroundTransparency = 0.935
        SubButton.Size = UDim2.new(0.5, -12, 0, 30)
        SubButton.Position = UDim2.new(0.5, 2, 0, yBtn)
        SubButton.Parent = Panel

        local subCorner = Instance.new("UICorner")
        subCorner.CornerRadius = UDim.new(0, 6)
        subCorner.Parent = SubButton

        SubButton.MouseButton1Click:Connect(function()
            PanelConfig.SubButtonCallback(InputBox and InputBox.Text or "")
        end)
    end

    if InputBox then
        InputBox.FocusLost:Connect(function()
            PanelFunc.Value = InputBox.Text
            ctx.ConfigData[configKey] = InputBox.Text
            ctx.SaveConfig()
        end)
    end

    function PanelFunc:GetInput()
        return InputBox and InputBox.Text or ""
    end

    return PanelFunc
end
