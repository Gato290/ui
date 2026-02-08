-- ChloeX UI Library - UI Elements Module
-- Part 4 of 3 (Additional elements)

local UIElements = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function UIElements:CreateItems(SectionAdd, CountSection, GuiConfig, Icons, Elements, ConfigData, SaveConfig, TweenService, UpdateSizeSection)
    local Items = {}
    local CountItem = 0

    -- Paragraph element
    function Items:AddParagraph(ParagraphConfig)
        local ParagraphConfig = ParagraphConfig or {}
        ParagraphConfig.Title = ParagraphConfig.Title or "Title"
        ParagraphConfig.Content = ParagraphConfig.Content or "Content"
        local ParagraphFunc = {}

        local Paragraph = Instance.new("Frame")
        local UICorner14 = Instance.new("UICorner")
        local ParagraphTitle = Instance.new("TextLabel")
        local ParagraphContent = Instance.new("TextLabel")

        Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Paragraph.BackgroundTransparency = 0.935
        Paragraph.BorderSizePixel = 0
        Paragraph.LayoutOrder = CountItem
        Paragraph.Size = UDim2.new(1, 0, 0, 46)
        Paragraph.Name = "Paragraph"
        Paragraph.Parent = SectionAdd

        UICorner14.CornerRadius = UDim.new(0, 4)
        UICorner14.Parent = Paragraph

        local iconOffset = 10
        if ParagraphConfig.Icon then
            local IconImg = Instance.new("ImageLabel")
            IconImg.Size = UDim2.new(0, 20, 0, 20)
            IconImg.Position = UDim2.new(0, 8, 0, 12)
            IconImg.BackgroundTransparency = 1
            IconImg.Name = "ParagraphIcon"
            IconImg.Parent = Paragraph

            if Icons and Icons[ParagraphConfig.Icon] then
                IconImg.Image = Icons[ParagraphConfig.Icon]
            else
                IconImg.Image = ParagraphConfig.Icon
            end

            iconOffset = 30
        end

        ParagraphTitle.Font = Enum.Font.GothamBold
        ParagraphTitle.Text = ParagraphConfig.Title
        ParagraphTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
        ParagraphTitle.TextSize = 13
        ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
        ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
        ParagraphTitle.BackgroundTransparency = 1
        ParagraphTitle.Position = UDim2.new(0, iconOffset, 0, 10)
        ParagraphTitle.Size = UDim2.new(1, -16, 0, 13)
        ParagraphTitle.Name = "ParagraphTitle"
        ParagraphTitle.Parent = Paragraph

        ParagraphContent.Font = Enum.Font.Gotham
        ParagraphContent.Text = ParagraphConfig.Content
        ParagraphContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphContent.TextSize = 12
        ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
        ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
        ParagraphContent.BackgroundTransparency = 1
        ParagraphContent.Position = UDim2.new(0, iconOffset, 0, 25)
        ParagraphContent.Name = "ParagraphContent"
        ParagraphContent.TextWrapped = false
        ParagraphContent.RichText = true
        ParagraphContent.Parent = Paragraph

        ParagraphContent.Size = UDim2.new(1, -16, 0, ParagraphContent.TextBounds.Y)

        local ParagraphButton
        if ParagraphConfig.ButtonText then
            ParagraphButton = Instance.new("TextButton")
            ParagraphButton.Position = UDim2.new(0, 10, 0, 42)
            ParagraphButton.Size = UDim2.new(1, -22, 0, 28)
            ParagraphButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ParagraphButton.BackgroundTransparency = 0.935
            ParagraphButton.Font = Enum.Font.GothamBold
            ParagraphButton.TextSize = 12
            ParagraphButton.TextTransparency = 0.3
            ParagraphButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ParagraphButton.Text = ParagraphConfig.ButtonText
            ParagraphButton.Parent = Paragraph

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = ParagraphButton

            if ParagraphConfig.ButtonCallback then
                ParagraphButton.MouseButton1Click:Connect(ParagraphConfig.ButtonCallback)
            end
        end

        local function UpdateSize()
            local totalHeight = ParagraphContent.TextBounds.Y + 33
            if ParagraphButton then
                totalHeight = totalHeight + ParagraphButton.Size.Y.Offset + 5
            end
            Paragraph.Size = UDim2.new(1, 0, 0, totalHeight)
        end

        UpdateSize()

        ParagraphContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)

        function ParagraphFunc:SetContent(content)
            content = content or "Content"
            ParagraphContent.Text = content
            UpdateSize()
        end

        CountItem = CountItem + 1
        return ParagraphFunc
    end

    -- Panel element
    function Items:AddPanel(PanelConfig)
        PanelConfig = PanelConfig or {}
        PanelConfig.Title = PanelConfig.Title or "Title"
        PanelConfig.Content = PanelConfig.Content or ""
        PanelConfig.Placeholder = PanelConfig.Placeholder or nil
        PanelConfig.Default = PanelConfig.Default or ""
        PanelConfig.ButtonText = PanelConfig.Button or PanelConfig.ButtonText or "Confirm"
        PanelConfig.ButtonCallback = PanelConfig.Callback or PanelConfig.ButtonCallback or function() end
        PanelConfig.SubButtonText = PanelConfig.SubButton or PanelConfig.SubButtonText or nil
        PanelConfig.SubButtonCallback = PanelConfig.SubCallback or PanelConfig.SubButtonCallback or function() end

        local configKey = "Panel_" .. PanelConfig.Title
        if ConfigData[configKey] ~= nil then
            PanelConfig.Default = ConfigData[configKey]
        end

        local PanelFunc = { Value = PanelConfig.Default }

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
        Panel.LayoutOrder = CountItem
        Panel.Parent = SectionAdd

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
                ConfigData[configKey] = InputBox.Text
                SaveConfig()
            end)
        end

        function PanelFunc:GetInput()
            return InputBox and InputBox.Text or ""
        end

        CountItem = CountItem + 1
        return PanelFunc
    end

    -- Button element
    function Items:AddButton(ButtonConfig)
        ButtonConfig = ButtonConfig or {}
        ButtonConfig.Title = ButtonConfig.Title or "Confirm"
        ButtonConfig.Callback = ButtonConfig.Callback or function() end
        ButtonConfig.SubTitle = ButtonConfig.SubTitle or nil
        ButtonConfig.SubCallback = ButtonConfig.SubCallback or function() end

        local Button = Instance.new("Frame")
        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundTransparency = 0.935
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.LayoutOrder = CountItem
        Button.Parent = SectionAdd

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 4)
        UICorner.Parent = Button

        local MainButton = Instance.new("TextButton")
        MainButton.Font = Enum.Font.GothamBold
        MainButton.Text = ButtonConfig.Title
        MainButton.TextSize = 12
        MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        MainButton.TextTransparency = 0.3
        MainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        MainButton.BackgroundTransparency = 0.935
        MainButton.Size = ButtonConfig.SubTitle and UDim2.new(0.5, -8, 1, -10) or UDim2.new(1, -12, 1, -10)
        MainButton.Position = UDim2.new(0, 6, 0, 5)
        MainButton.Parent = Button

        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 4)
        mainCorner.Parent = MainButton

        MainButton.MouseButton1Click:Connect(ButtonConfig.Callback)

        if ButtonConfig.SubTitle then
            local SubButton = Instance.new("TextButton")
            SubButton.Font = Enum.Font.GothamBold
            SubButton.Text = ButtonConfig.SubTitle
            SubButton.TextSize = 12
            SubButton.TextTransparency = 0.3
            SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            SubButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SubButton.BackgroundTransparency = 0.935
            SubButton.Size = UDim2.new(0.5, -8, 1, -10)
            SubButton.Position = UDim2.new(0.5, 2, 0, 5)
            SubButton.Parent = Button

            local subCorner = Instance.new("UICorner")
            subCorner.CornerRadius = UDim.new(0, 4)
            subCorner.Parent = SubButton

            SubButton.MouseButton1Click:Connect(ButtonConfig.SubCallback)
        end

        CountItem = CountItem + 1
    end

    -- Toggle element
    function Items:AddToggle(ToggleConfig)
        local ToggleConfig = ToggleConfig or {}
        ToggleConfig.Title = ToggleConfig.Title or "Title"
        ToggleConfig.Title2 = ToggleConfig.Title2 or ""
        ToggleConfig.Content = ToggleConfig.Content or ""
        ToggleConfig.Default = ToggleConfig.Default or false
        ToggleConfig.Callback = ToggleConfig.Callback or function() end

        local configKey = "Toggle_" .. ToggleConfig.Title
        if ConfigData[configKey] ~= nil then
            ToggleConfig.Default = ConfigData[configKey]
        end

        local ToggleFunc = { Value = ToggleConfig.Default }

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
        Toggle.LayoutOrder = CountItem
        Toggle.Name = "Toggle"
        Toggle.Parent = SectionAdd

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
            UpdateSizeSection()
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
            ConfigData[configKey] = Value
            SaveConfig()
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
        end

        ToggleFunc:Set(ToggleFunc.Value)
        CountItem = CountItem + 1
        Elements[configKey] = ToggleFunc
        return ToggleFunc
    end

    -- Slider element
    function Items:AddSlider(SliderConfig)
        local SliderConfig = SliderConfig or {}
        SliderConfig.Title = SliderConfig.Title or "Slider"
        SliderConfig.Content = SliderConfig.Content or ""
        SliderConfig.Increment = SliderConfig.Increment or 1
        SliderConfig.Min = SliderConfig.Min or 0
        SliderConfig.Max = SliderConfig.Max or 100
        SliderConfig.Default = SliderConfig.Default or 50
        SliderConfig.Callback = SliderConfig.Callback or function() end

        local configKey = "Slider_" .. SliderConfig.Title
        if ConfigData[configKey] ~= nil then
            SliderConfig.Default = ConfigData[configKey]
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
        local UIStroke5 = Instance.new("UIStroke")
        local SliderCircle = Instance.new("Frame")
        local UICorner19 = Instance.new("UICorner")
        local UIStroke6 = Instance.new("UIStroke")
        local UIStroke7 = Instance.new("UIStroke")

        Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Slider.BackgroundTransparency = 0.9350000023841858
        Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Slider.BorderSizePixel = 0
        Slider.LayoutOrder = CountItem
        Slider.Size = UDim2.new(1, 0, 0, 46)
        Slider.Name = "Slider"
        Slider.Parent = SectionAdd

        UICorner15.CornerRadius = UDim.new(0, 4)
        UICorner15.Parent = Slider

        SliderTitle.Font = Enum.Font.GothamBold
        SliderTitle.Text = SliderConfig.Title
        SliderTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
        SliderTitle.TextSize = 13
        SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
        SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
        SliderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderTitle.BackgroundTransparency = 0.9990000128746033
        SliderTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderTitle.BorderSizePixel = 0
        SliderTitle.Position = UDim2.new(0, 10, 0, 10)
        SliderTitle.Size = UDim2.new(1, -180, 0, 13)
        SliderTitle.Name = "SliderTitle"
        SliderTitle.Parent = Slider

        SliderContent.Font = Enum.Font.GothamBold
        SliderContent.Text = SliderConfig.Content
        SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderContent.TextSize = 12
        SliderContent.TextTransparency = 0.6000000238418579
        SliderContent.TextXAlignment = Enum.TextXAlignment.Left
        SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
        SliderContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderContent.BackgroundTransparency = 0.9990000128746033
        SliderContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderContent.BorderSizePixel = 0
        SliderContent.Position = UDim2.new(0, 10, 0, 25)
        SliderContent.Size = UDim2.new(1, -180, 0, 12)
        SliderContent.Name = "SliderContent"
        SliderContent.Parent = Slider

        SliderContent.Size = UDim2.new(1, -180, 0,
            12 + (12 * (SliderContent.TextBounds.X // SliderContent.AbsoluteSize.X)))
        SliderContent.TextWrapped = true
        Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)

        SliderContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            SliderContent.TextWrapped = false
            SliderContent.Size = UDim2.new(1, -180, 0,
                12 + (12 * (SliderContent.TextBounds.X // SliderContent.AbsoluteSize.X)))
            Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
            SliderContent.TextWrapped = true
            UpdateSizeSection()
        end)

        SliderInput.AnchorPoint = Vector2.new(0, 0.5)
        SliderInput.BackgroundColor3 = GuiConfig.Color
        SliderInput.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderInput.BackgroundTransparency = 1
        SliderInput.BorderSizePixel = 0
        SliderInput.Position = UDim2.new(1, -155, 0.5, 0)
        SliderInput.Size = UDim2.new(0, 28, 0, 20)
        SliderInput.Name = "SliderInput"
        SliderInput.Parent = Slider

        UICorner16.CornerRadius = UDim.new(0, 2)
        UICorner16.Parent = SliderInput

        TextBox.Font = Enum.Font.GothamBold
        TextBox.Text = "90"
        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.TextSize = 13
        TextBox.TextWrapped = true
        TextBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TextBox.BackgroundTransparency = 0.9990000128746033
        TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextBox.BorderSizePixel = 0
        TextBox.Position = UDim2.new(0, -1, 0, 0)
        TextBox.Size = UDim2.new(1, 0, 1, 0)
        TextBox.Parent = SliderInput

        SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderFrame.BackgroundTransparency = 0.800000011920929
        SliderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
        SliderFrame.Size = UDim2.new(0, 100, 0, 3)
        SliderFrame.Name = "SliderFrame"
        SliderFrame.Parent = Slider

        UICorner17.Parent = SliderFrame

        SliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
        SliderDraggable.BackgroundColor3 = GuiConfig.Color
        SliderDraggable.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderDraggable.BorderSizePixel = 0
        SliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
        SliderDraggable.Size = UDim2.new(0.899999976, 0, 0, 1)
        SliderDraggable.Name = "SliderDraggable"
        SliderDraggable.Parent = SliderFrame

        UICorner18.Parent = SliderDraggable

        SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
        SliderCircle.BackgroundColor3 = GuiConfig.Color
        SliderCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
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
        
        function SliderFunc:Set(Value)
            Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
            SliderFunc.Value = Value
            TextBox.Text = tostring(Value)
            TweenService:Create(
                SliderDraggable,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.fromScale((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1) }
            ):Play()

            SliderConfig.Callback(Value)
            ConfigData[configKey] = Value
            SaveConfig()
        end

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
                SliderConfig.Callback(SliderFunc.Value)
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

        TextBox:GetPropertyChangedSignal("Text"):Connect(function()
            local Valid = TextBox.Text:gsub("[^%d]", "")
            if Valid ~= "" then
                local ValidNumber = math.clamp(tonumber(Valid), SliderConfig.Min, SliderConfig.Max)
                SliderFunc:Set(ValidNumber)
            else
                SliderFunc:Set(SliderConfig.Min)
            end
        end)
        
        SliderFunc:Set(SliderConfig.Default)
        CountItem = CountItem + 1
        Elements[configKey] = SliderFunc
        return SliderFunc
    end

    -- Input element
    function Items:AddInput(InputConfig)
        local InputConfig = InputConfig or {}
        InputConfig.Title = InputConfig.Title or "Title"
        InputConfig.Content = InputConfig.Content or ""
        InputConfig.Callback = InputConfig.Callback or function() end
        InputConfig.Default = InputConfig.Default or ""

        local configKey = "Input_" .. InputConfig.Title
        if ConfigData[configKey] ~= nil then
            InputConfig.Default = ConfigData[configKey]
        end

        local InputFunc = { Value = InputConfig.Default }

        local Input = Instance.new("Frame")
        local UICorner12 = Instance.new("UICorner")
        local InputTitle = Instance.new("TextLabel")
        local InputContent = Instance.new("TextLabel")
        local InputFrame = Instance.new("Frame")
        local UICorner13 = Instance.new("UICorner")
        local InputTextBox = Instance.new("TextBox")

        Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Input.BackgroundTransparency = 0.9350000023841858
        Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Input.BorderSizePixel = 0
        Input.LayoutOrder = CountItem
        Input.Size = UDim2.new(1, 0, 0, 46)
        Input.Name = "Input"
        Input.Parent = SectionAdd

        UICorner12.CornerRadius = UDim.new(0, 4)
        UICorner12.Parent = Input

        InputTitle.Font = Enum.Font.GothamBold
        InputTitle.Text = InputConfig.Title or "TextBox"
        InputTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
        InputTitle.TextSize = 13
        InputTitle.TextXAlignment = Enum.TextXAlignment.Left
        InputTitle.TextYAlignment = Enum.TextYAlignment.Top
        InputTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputTitle.BackgroundTransparency = 0.9990000128746033
        InputTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputTitle.BorderSizePixel = 0
        InputTitle.Position = UDim2.new(0, 10, 0, 10)
        InputTitle.Size = UDim2.new(1, -180, 0, 13)
        InputTitle.Name = "InputTitle"
        InputTitle.Parent = Input

        InputContent.Font = Enum.Font.GothamBold
        InputContent.Text = InputConfig.Content or "This is a TextBox"
        InputContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputContent.TextSize = 12
        InputContent.TextTransparency = 0.6000000238418579
        InputContent.TextWrapped = true
        InputContent.TextXAlignment = Enum.TextXAlignment.Left
        InputContent.TextYAlignment = Enum.TextYAlignment.Bottom
        InputContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputContent.BackgroundTransparency = 0.9990000128746033
        InputContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputContent.BorderSizePixel = 0
        InputContent.Position = UDim2.new(0, 10, 0, 25)
        InputContent.Size = UDim2.new(1, -180, 0, 12)
        InputContent.Name = "InputContent"
        InputContent.Parent = Input

        InputContent.Size = UDim2.new(1, -180, 0,
            12 + (12 * (InputContent.TextBounds.X // InputContent.AbsoluteSize.X)))
        InputContent.TextWrapped = true
        Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)

        InputContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            InputContent.TextWrapped = false
            InputContent.Size = UDim2.new(1, -180, 0,
                12 + (12 * (InputContent.TextBounds.X // InputContent.AbsoluteSize.X)))
            Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)
            InputContent.TextWrapped = true
            UpdateSizeSection()
        end)

        InputFrame.AnchorPoint = Vector2.new(1, 0.5)
        InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputFrame.BackgroundTransparency = 0.949999988079071
        InputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputFrame.BorderSizePixel = 0
        InputFrame.ClipsDescendants = true
        InputFrame.Position = UDim2.new(1, -7, 0.5, 0)
        InputFrame.Size = UDim2.new(0, 148, 0, 30)
        InputFrame.Name = "InputFrame"
        InputFrame.Parent = Input

        UICorner13.CornerRadius = UDim.new(0, 4)
        UICorner13.Parent = InputFrame

        InputTextBox.CursorPosition = -1
        InputTextBox.Font = Enum.Font.GothamBold
        InputTextBox.PlaceholderColor3 = Color3.fromRGB(120.00000044703484, 120.00000044703484, 120.00000044703484)
        InputTextBox.PlaceholderText = "Input Here"
        InputTextBox.Text = InputConfig.Default
        InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.TextSize = 12
        InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
        InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
        InputTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.BackgroundTransparency = 0.9990000128746033
        InputTextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputTextBox.BorderSizePixel = 0
        InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
        InputTextBox.Size = UDim2.new(1, -10, 1, -8)
        InputTextBox.Name = "InputTextBox"
        InputTextBox.Parent = InputFrame
        
        function InputFunc:Set(Value)
            InputTextBox.Text = Value
            InputFunc.Value = Value
            InputConfig.Callback(Value)
            ConfigData[configKey] = Value
            SaveConfig()
        end

        InputFunc:Set(InputFunc.Value)

        InputTextBox.FocusLost:Connect(function()
            InputFunc:Set(InputTextBox.Text)
        end)
        
        CountItem = CountItem + 1
        Elements[configKey] = InputFunc
        return InputFunc
    end

    -- Divider element
    function Items:AddDivider()
        local Divider = Instance.new("Frame")
        Divider.Name = "Divider"
        Divider.Parent = SectionAdd
        Divider.AnchorPoint = Vector2.new(0.5, 0)
        Divider.Position = UDim2.new(0.5, 0, 0, 0)
        Divider.Size = UDim2.new(1, 0, 0, 2)
        Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Divider.BackgroundTransparency = 0
        Divider.BorderSizePixel = 0
        Divider.LayoutOrder = CountItem

        local UIGradient = Instance.new("UIGradient")
        UIGradient.Color = ColorSequence.new {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
            ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
        }
        UIGradient.Parent = Divider

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 2)
        UICorner.Parent = Divider

        CountItem = CountItem + 1
        return Divider
    end

    -- SubSection element
    function Items:AddSubSection(title)
        title = title or "Sub Section"

        local SubSection = Instance.new("Frame")
        SubSection.Name = "SubSection"
        SubSection.Parent = SectionAdd
        SubSection.BackgroundTransparency = 1
        SubSection.Size = UDim2.new(1, 0, 0, 22)
        SubSection.LayoutOrder = CountItem

        local Background = Instance.new("Frame")
        Background.Parent = SubSection
        Background.Size = UDim2.new(1, 0, 1, 0)
        Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Background.BackgroundTransparency = 0.935
        Background.BorderSizePixel = 0
        Instance.new("UICorner", Background).CornerRadius = UDim.new(0, 6)

        local Label = Instance.new("TextLabel")
        Label.Parent = SubSection
        Label.AnchorPoint = Vector2.new(0, 0.5)
        Label.Position = UDim2.new(0, 10, 0.5, 0)
        Label.Size = UDim2.new(1, -20, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.GothamBold
        Label.Text = "── [ " .. title .. " ] ──"
        Label.TextColor3 = Color3.fromRGB(230, 230, 230)
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left

        CountItem = CountItem + 1
        return SubSection
    end

    return Items
end

return UIElements
