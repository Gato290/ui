-- Elements.lua - UI Elements Module (COMPATIBLE VERSION)
-- Version 1.2.2 - Compatible dengan Main.lua independen
-- GitHub: https://github.com/Gato290/ui

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local ElementsModule = {}

-- Configuration
local MainColor = Color3.fromRGB(255, 0, 255)
local SaveConfigFunc = function() end
local ConfigData = {}

-- Store all elements
local AllElements = {}

-- Tween info presets untuk konsistensi
local TweenInfoPresets = {
    Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
}

-- Helper function untuk membuat badge
local function createBadge(parent, config)
    if not config.New or config.New ~= "true" then return nil end
    
    local BadgeFrame = Instance.new("Frame")
    BadgeFrame.BackgroundColor3 = MainColor
    BadgeFrame.BackgroundTransparency = 0.2
    BadgeFrame.Size = UDim2.new(0, 34, 0, 16)
    BadgeFrame.Position = UDim2.new(1, -50, 0, 8)
    BadgeFrame.Parent = parent
    BadgeFrame.Name = "BadgeFrame"
    BadgeFrame.ZIndex = 5

    local BadgeCorner = Instance.new("UICorner")
    BadgeCorner.CornerRadius = UDim.new(0, 8)
    BadgeCorner.Parent = BadgeFrame

    local BadgeText = Instance.new("TextLabel")
    BadgeText.Font = Enum.Font.GothamBold
    BadgeText.Text = "NEW"
    BadgeText.TextSize = 9
    BadgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    BadgeText.BackgroundTransparency = 1
    BadgeText.Size = UDim2.new(1, 0, 1, 0)
    BadgeText.Parent = BadgeFrame
    BadgeText.ZIndex = 6
    
    -- Animasi masuk
    BadgeFrame.Size = UDim2.new(0, 0, 0, 0)
    task.wait()
    TweenService:Create(BadgeFrame, TweenInfoPresets.Bounce, {Size = UDim2.new(0, 34, 0, 16)}):Play()
    
    return BadgeFrame
end

function ElementsModule.Initialize(color, saveFunc, config)
    MainColor = color or MainColor
    SaveConfigFunc = saveFunc or function() end
    ConfigData = config or {}
end

function ElementsModule.GetAll()
    return AllElements
end

function ElementsModule.AddParagraph(parent, config, countItem, updateSizeCallback)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Content = config.Content or "Content"
    config.Icon = config.Icon or nil
    config.ButtonText = config.ButtonText or nil
    config.ButtonCallback = config.ButtonCallback or function() end
    config.New = config.New or "false"

    local ParagraphFunc = {}

    local Paragraph = Instance.new("Frame")
    local UICorner14 = Instance.new("UICorner")
    local ParagraphTitle = Instance.new("TextLabel")
    local ParagraphContent = Instance.new("TextLabel")

    Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Paragraph.BackgroundTransparency = 0.935
    Paragraph.BorderSizePixel = 0
    Paragraph.LayoutOrder = countItem
    Paragraph.Size = UDim2.new(1, 0, 0, 46)
    Paragraph.Name = "Paragraph"
    Paragraph.Parent = parent

    UICorner14.CornerRadius = UDim.new(0, 4)
    UICorner14.Parent = Paragraph

    local iconOffset = 10
    if config.Icon then
        local IconImg = Instance.new("ImageLabel")
        IconImg.Size = UDim2.new(0, 20, 0, 20)
        IconImg.Position = UDim2.new(0, 8, 0, 12)
        IconImg.BackgroundTransparency = 1
        IconImg.Name = "ParagraphIcon"
        IconImg.Parent = Paragraph

        IconImg.Image = config.Icon
        iconOffset = 30
    end

    ParagraphTitle.Font = Enum.Font.GothamBold
    ParagraphTitle.Text = config.Title
    ParagraphTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    ParagraphTitle.TextSize = 13
    ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphTitle.BackgroundTransparency = 1
    ParagraphTitle.Position = UDim2.new(0, iconOffset, 0, 10)
    ParagraphTitle.Size = UDim2.new(1, -80, 0, 13)
    ParagraphTitle.Name = "ParagraphTitle"
    ParagraphTitle.Parent = Paragraph

    ParagraphContent.Font = Enum.Font.Gotham
    ParagraphContent.Text = config.Content
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

    ParagraphContent.Size = UDim2.new(1, -80, 0, ParagraphContent.TextBounds.Y)

    -- Buat badge
    local Badge = createBadge(Paragraph, config)
    if Badge then
        Badge.Position = UDim2.new(1, -90, 0, 8)
    end

    local ParagraphButton
    if config.ButtonText then
        ParagraphButton = Instance.new("TextButton")
        ParagraphButton.Position = UDim2.new(0, 10, 0, 42)
        ParagraphButton.Size = UDim2.new(1, -22, 0, 28)
        ParagraphButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.BackgroundTransparency = 0.935
        ParagraphButton.Font = Enum.Font.GothamBold
        ParagraphButton.TextSize = 12
        ParagraphButton.TextTransparency = 0.3
        ParagraphButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.Text = config.ButtonText
        ParagraphButton.Parent = Paragraph

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = ParagraphButton
        
        ParagraphButton.MouseEnter:Connect(function()
            TweenService:Create(ParagraphButton, TweenInfoPresets.Quick, {BackgroundTransparency = 0.85}):Play()
            TweenService:Create(ParagraphButton, TweenInfoPresets.Quick, {TextTransparency = 0}):Play()
        end)
        
        ParagraphButton.MouseLeave:Connect(function()
            TweenService:Create(ParagraphButton, TweenInfoPresets.Quick, {BackgroundTransparency = 0.935}):Play()
            TweenService:Create(ParagraphButton, TweenInfoPresets.Quick, {TextTransparency = 0.3}):Play()
        end)

        if config.ButtonCallback then
            ParagraphButton.MouseButton1Click:Connect(config.ButtonCallback)
        end
    end

    local function UpdateSize()
        local totalHeight = ParagraphContent.TextBounds.Y + 33
        if ParagraphButton then
            totalHeight = totalHeight + ParagraphButton.Size.Y.Offset + 5
        end
        Paragraph.Size = UDim2.new(1, 0, 0, totalHeight)
        if updateSizeCallback then updateSizeCallback() end
    end

    UpdateSize()
    ParagraphContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)

    function ParagraphFunc:SetContent(content)
        content = content or "Content"
        ParagraphContent.Text = content
        UpdateSize()
    end

    AllElements["Paragraph_" .. config.Title] = ParagraphFunc
    return ParagraphFunc
end

function ElementsModule.AddPanel(parent, config, countItem, updateSizeCallback)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Content = config.Content or ""
    config.Placeholder = config.Placeholder or nil
    config.Default = config.Default or ""
    config.ButtonText = config.Button or config.ButtonText or "Confirm"
    config.ButtonCallback = config.Callback or config.ButtonCallback or function() end
    config.SubButtonText = config.SubButton or config.SubButtonText or nil
    config.SubButtonCallback = config.SubCallback or config.SubButtonCallback or function() end
    config.New = config.New or "false"

    local configKey = "Panel_" .. config.Title
    if ConfigData[configKey] ~= nil then
        config.Default = ConfigData[configKey]
    end

    local PanelFunc = { Value = config.Default }

    local baseHeight = 50
    if config.Placeholder then baseHeight = baseHeight + 40 end
    if config.SubButtonText then baseHeight = baseHeight + 40 else baseHeight = baseHeight + 36 end

    local Panel = Instance.new("Frame")
    Panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Panel.BackgroundTransparency = 0.935
    Panel.Size = UDim2.new(1, 0, 0, baseHeight)
    Panel.LayoutOrder = countItem
    Panel.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Panel

    local Title = Instance.new("TextLabel")
    Title.Font = Enum.Font.GothamBold
    Title.Text = config.Title
    Title.TextSize = 13
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Size = UDim2.new(1, -80, 0, 13)
    Title.Parent = Panel

    local Badge = createBadge(Panel, config)
    if Badge then
        Badge.Position = UDim2.new(1, -60, 0, 8)
    end

    local Content = Instance.new("TextLabel")
    Content.Font = Enum.Font.Gotham
    Content.Text = config.Content
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
    if config.Placeholder then
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
        InputBox.PlaceholderText = config.Placeholder
        InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        InputBox.Text = config.Default
        InputBox.TextSize = 11
        InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputBox.BackgroundTransparency = 1
        InputBox.TextXAlignment = Enum.TextXAlignment.Left
        InputBox.Size = UDim2.new(1, -10, 1, -6)
        InputBox.Position = UDim2.new(0, 5, 0, 3)
        InputBox.Parent = InputFrame
        
        InputBox.Focused:Connect(function()
            TweenService:Create(InputFrame, TweenInfoPresets.Normal, {BackgroundTransparency = 0.9}):Play()
        end)
        
        InputBox.FocusLost:Connect(function()
            TweenService:Create(InputFrame, TweenInfoPresets.Normal, {BackgroundTransparency = 0.95}):Play()
        end)
    end

    local yBtn = config.Placeholder and 88 or 48

    local ButtonMain = Instance.new("TextButton")
    ButtonMain.Font = Enum.Font.GothamBold
    ButtonMain.Text = config.ButtonText
    ButtonMain.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonMain.TextSize = 12
    ButtonMain.TextTransparency = 0.3
    ButtonMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ButtonMain.BackgroundTransparency = 0.935
    ButtonMain.Size = config.SubButtonText and UDim2.new(0.5, -12, 0, 30) or UDim2.new(1, -20, 0, 30)
    ButtonMain.Position = UDim2.new(0, 10, 0, yBtn)
    ButtonMain.Parent = Panel

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = ButtonMain
    
    ButtonMain.MouseEnter:Connect(function()
        TweenService:Create(ButtonMain, TweenInfoPresets.Quick, {BackgroundTransparency = 0.85}):Play()
        TweenService:Create(ButtonMain, TweenInfoPresets.Quick, {TextTransparency = 0}):Play()
    end)
    
    ButtonMain.MouseLeave:Connect(function()
        TweenService:Create(ButtonMain, TweenInfoPresets.Quick, {BackgroundTransparency = 0.935}):Play()
        TweenService:Create(ButtonMain, TweenInfoPresets.Quick, {TextTransparency = 0.3}):Play()
    end)

    ButtonMain.MouseButton1Click:Connect(function()
        config.ButtonCallback(InputBox and InputBox.Text or "")
    end)

    if config.SubButtonText then
        local SubButton = Instance.new("TextButton")
        SubButton.Font = Enum.Font.GothamBold
        SubButton.Text = config.SubButtonText
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
        
        SubButton.MouseEnter:Connect(function()
            TweenService:Create(SubButton, TweenInfoPresets.Quick, {BackgroundTransparency = 0.85}):Play()
            TweenService:Create(SubButton, TweenInfoPresets.Quick, {TextTransparency = 0}):Play()
        end)
        
        SubButton.MouseLeave:Connect(function()
            TweenService:Create(SubButton, TweenInfoPresets.Quick, {BackgroundTransparency = 0.935}):Play()
            TweenService:Create(SubButton, TweenInfoPresets.Quick, {TextTransparency = 0.3}):Play()
        end)

        SubButton.MouseButton1Click:Connect(function()
            config.SubButtonCallback(InputBox and InputBox.Text or "")
        end)
    end

    if InputBox then
        InputBox.FocusLost:Connect(function()
            PanelFunc.Value = InputBox.Text
            ConfigData[configKey] = InputBox.Text
            SaveConfigFunc()
        end)
    end

    function PanelFunc:GetInput()
        return InputBox and InputBox.Text or ""
    end

    AllElements[configKey] = PanelFunc
    return PanelFunc
end

function ElementsModule.AddButton(parent, config, countItem, updateSizeCallback)
    config = config or {}
    config.Title = config.Title or "Confirm"
    config.Callback = config.Callback or function() end
    config.SubTitle = config.SubTitle or nil
    config.SubCallback = config.SubCallback or function() end
    config.New = config.New or "false"
    
    local isV2 = config.New == "true" or config.Title2 ~= nil

    if isV2 then
        config.Title2 = config.Title2 or ""
        config.New = config.New == "true"
        
        local Button = Instance.new("Frame")
        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundTransparency = 0.935
        Button.Size = UDim2.new(1, 0, 0, 48)
        Button.LayoutOrder = countItem
        Button.Parent = parent

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 6)
        UICorner.Parent = Button

        local ArrowIcon = Instance.new("ImageLabel")
        ArrowIcon.Size = UDim2.new(0, 16, 0, 16)
        ArrowIcon.Position = UDim2.new(1, -24, 0.5, 0)
        ArrowIcon.AnchorPoint = Vector2.new(0, 0.5)
        ArrowIcon.BackgroundTransparency = 1
        ArrowIcon.Image = "rbxassetid://16851841101"
        ArrowIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        ArrowIcon.ImageTransparency = 0.3
        ArrowIcon.Rotation = -90
        ArrowIcon.Name = "ArrowIcon"
        ArrowIcon.Parent = Button

        local MainTitle = Instance.new("TextLabel")
        MainTitle.Font = Enum.Font.GothamBold
        MainTitle.Text = config.Title
        MainTitle.TextSize = 14
        MainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        MainTitle.TextXAlignment = Enum.TextXAlignment.Left
        MainTitle.TextYAlignment = Enum.TextYAlignment.Top
        MainTitle.BackgroundTransparency = 1
        MainTitle.Position = UDim2.new(0, 10, 0, 8)
        MainTitle.Size = UDim2.new(1, -80, 0, 16)
        MainTitle.Name = "MainTitle"
        MainTitle.Parent = Button

        local SubTitle = Instance.new("TextLabel")
        SubTitle.Font = Enum.Font.Gotham
        SubTitle.Text = config.Title2
        SubTitle.TextSize = 11
        SubTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
        SubTitle.TextXAlignment = Enum.TextXAlignment.Left
        SubTitle.TextYAlignment = Enum.TextYAlignment.Top
        SubTitle.BackgroundTransparency = 1
        SubTitle.Position = UDim2.new(0, 10, 0, 24)
        SubTitle.Size = UDim2.new(1, -80, 0, 14)
        SubTitle.Name = "SubTitle"
        SubTitle.Parent = Button

        if config.New then
            local BadgeFrame = Instance.new("Frame")
            BadgeFrame.BackgroundColor3 = MainColor
            BadgeFrame.BackgroundTransparency = 0.2
            BadgeFrame.Size = UDim2.new(0, 34, 0, 16)
            BadgeFrame.Position = UDim2.new(1, -60, 0, 8)
            BadgeFrame.Parent = Button
            BadgeFrame.Name = "BadgeFrame"
            BadgeFrame.ZIndex = 5

            local BadgeCorner = Instance.new("UICorner")
            BadgeCorner.CornerRadius = UDim.new(0, 8)
            BadgeCorner.Parent = BadgeFrame

            local BadgeText = Instance.new("TextLabel")
            BadgeText.Font = Enum.Font.GothamBold
            BadgeText.Text = "NEW"
            BadgeText.TextSize = 9
            BadgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
            BadgeText.BackgroundTransparency = 1
            BadgeText.Size = UDim2.new(1, 0, 1, 0)
            BadgeText.Parent = BadgeFrame
            BadgeText.ZIndex = 6
        end

        local MainButton = Instance.new("TextButton")
        MainButton.Font = Enum.Font.SourceSans
        MainButton.Text = ""
        MainButton.BackgroundTransparency = 1
        MainButton.Size = UDim2.new(1, 0, 1, 0)
        MainButton.Parent = Button

        MainButton.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfoPresets.Quick, {BackgroundTransparency = 0.85}):Play()
            TweenService:Create(ArrowIcon, TweenInfoPresets.Quick, {ImageTransparency = 0}):Play()
            TweenService:Create(ArrowIcon, TweenInfoPresets.Quick, {Size = UDim2.new(0, 18, 0, 18)}):Play()
        end)

        MainButton.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfoPresets.Quick, {BackgroundTransparency = 0.935}):Play()
            TweenService:Create(ArrowIcon, TweenInfoPresets.Quick, {ImageTransparency = 0.3}):Play()
            TweenService:Create(ArrowIcon, TweenInfoPresets.Quick, {Size = UDim2.new(0, 16, 0, 16)}):Play()
        end)

        MainButton.MouseButton1Down:Connect(function()
            TweenService:Create(Button, TweenInfoPresets.Quick, {BackgroundTransparency = 0.8}):Play()
            TweenService:Create(ArrowIcon, TweenInfoPresets.Quick, {Size = UDim2.new(0, 14, 0, 14)}):Play()
        end)

        MainButton.MouseButton1Up:Connect(function()
            TweenService:Create(Button, TweenInfoPresets.Quick, {BackgroundTransparency = 0.85}):Play()
            TweenService:Create(ArrowIcon, TweenInfoPresets.Quick, {Size = UDim2.new(0, 18, 0, 18)}):Play()
        end)

        MainButton.MouseButton1Click:Connect(config.Callback)

        AllElements["Button_V2_" .. config.Title] = {Click = config.Callback}
        return {Click = config.Callback}

    else
        local Button = Instance.new("Frame")
        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundTransparency = 0.935
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.LayoutOrder = countItem
        Button.Parent = parent

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 4)
        UICorner.Parent = Button

        local Badge = createBadge(Button, config)
        if Badge then
            Badge.Position = UDim2.new(1, -45, 0, 5)
        end

        local MainButton = Instance.new("TextButton")
        MainButton.Font = Enum.Font.GothamBold
        MainButton.Text = config.Title
        MainButton.TextSize = 12
        MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        MainButton.TextTransparency = 0.3
        MainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        MainButton.BackgroundTransparency = 0.935
        MainButton.Size = config.SubTitle and UDim2.new(0.5, -8, 1, -10) or UDim2.new(1, -12, 1, -10)
        MainButton.Position = UDim2.new(0, 6, 0, 5)
        MainButton.Parent = Button

        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 4)
        mainCorner.Parent = MainButton
        
        MainButton.MouseEnter:Connect(function()
            TweenService:Create(MainButton, TweenInfoPresets.Quick, {BackgroundTransparency = 0.85}):Play()
            TweenService:Create(MainButton, TweenInfoPresets.Quick, {TextTransparency = 0}):Play()
        end)
        
        MainButton.MouseLeave:Connect(function()
            TweenService:Create(MainButton, TweenInfoPresets.Quick, {BackgroundTransparency = 0.935}):Play()
            TweenService:Create(MainButton, TweenInfoPresets.Quick, {TextTransparency = 0.3}):Play()
        end)

        MainButton.MouseButton1Click:Connect(config.Callback)

        if config.SubTitle then
            local SubButton = Instance.new("TextButton")
            SubButton.Font = Enum.Font.GothamBold
            SubButton.Text = config.SubTitle
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
            
            SubButton.MouseEnter:Connect(function()
                TweenService:Create(SubButton, TweenInfoPresets.Quick, {BackgroundTransparency = 0.85}):Play()
                TweenService:Create(SubButton, TweenInfoPresets.Quick, {TextTransparency = 0}):Play()
            end)
            
            SubButton.MouseLeave:Connect(function()
                TweenService:Create(SubButton, TweenInfoPresets.Quick, {BackgroundTransparency = 0.935}):Play()
                TweenService:Create(SubButton, TweenInfoPresets.Quick, {TextTransparency = 0.3}):Play()
            end)

            SubButton.MouseButton1Click:Connect(config.SubCallback)
        end

        AllElements["Button_" .. config.Title] = {Click = config.Callback}
        return {Click = config.Callback}
    end
end

function ElementsModule.AddToggle(parent, config, countItem, updateSizeCallback)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Title2 = config.Title2 or ""
    config.Content = config.Content or ""
    config.Default = config.Default or false
    config.Callback = config.Callback or function() end
    config.New = config.New or "false"

    local configKey = "Toggle_" .. config.Title
    if ConfigData[configKey] ~= nil then
        config.Default = ConfigData[configKey]
    end

    local ToggleFunc = { Value = config.Default }

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
    Toggle.LayoutOrder = countItem
    Toggle.Name = "Toggle"
    Toggle.Parent = parent

    UICorner20.CornerRadius = UDim.new(0, 4)
    UICorner20.Parent = Toggle

    ToggleTitle.Font = Enum.Font.GothamBold
    ToggleTitle.Text = config.Title
    ToggleTitle.TextSize = 13
    ToggleTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
    ToggleTitle.BackgroundTransparency = 1
    ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
    ToggleTitle.Size = UDim2.new(1, -120, 0, 13)
    ToggleTitle.Name = "ToggleTitle"
    ToggleTitle.Parent = Toggle

    local Badge = createBadge(Toggle, config)
    if Badge then
        Badge.Position = UDim2.new(1, -70, 0, 8)
    end

    local ToggleTitle2 = Instance.new("TextLabel")
    ToggleTitle2.Font = Enum.Font.GothamBold
    ToggleTitle2.Text = config.Title2
    ToggleTitle2.TextSize = 12
    ToggleTitle2.TextColor3 = Color3.fromRGB(231, 231, 231)
    ToggleTitle2.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle2.TextYAlignment = Enum.TextYAlignment.Top
    ToggleTitle2.BackgroundTransparency = 1
    ToggleTitle2.Position = UDim2.new(0, 10, 0, 23)
    ToggleTitle2.Size = UDim2.new(1, -120, 0, 12)
    ToggleTitle2.Name = "ToggleTitle2"
    ToggleTitle2.Parent = Toggle

    ToggleContent.Font = Enum.Font.GothamBold
    ToggleContent.Text = config.Content
    ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleContent.TextSize = 12
    ToggleContent.TextTransparency = 0.6
    ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
    ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
    ToggleContent.BackgroundTransparency = 1
    ToggleContent.Size = UDim2.new(1, -120, 0, 12)
    ToggleContent.Name = "ToggleContent"
    ToggleContent.Parent = Toggle

    if config.Title2 ~= "" then
        Toggle.Size = UDim2.new(1, 0, 0, 57)
        ToggleContent.Position = UDim2.new(0, 10, 0, 36)
        ToggleTitle2.Visible = true
    else
        Toggle.Size = UDim2.new(1, 0, 0, 46)
        ToggleContent.Position = UDim2.new(0, 10, 0, 23)
        ToggleTitle2.Visible = false
    end

    ToggleContent.Size = UDim2.new(1, -120, 0, 12 + (12 * (ToggleContent.TextBounds.X // ToggleContent.AbsoluteSize.X)))
    ToggleContent.TextWrapped = true
    if config.Title2 ~= "" then
        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
    else
        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
    end

    ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        ToggleContent.TextWrapped = false
        ToggleContent.Size = UDim2.new(1, -120, 0, 12 + (12 * (ToggleContent.TextBounds.X // ToggleContent.AbsoluteSize.X)))
        if config.Title2 ~= "" then
            Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
        else
            Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
        end
        ToggleContent.TextWrapped = true
        if updateSizeCallback then updateSizeCallback() end
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
        if typeof(config.Callback) == "function" then
            local ok, err = pcall(function()
                config.Callback(Value)
            end)
            if not ok then warn("Toggle Callback error:", err) end
        end
        ConfigData[configKey] = Value
        SaveConfigFunc()
        if Value then
            TweenService:Create(ToggleTitle, TweenInfoPresets.Normal, { TextColor3 = MainColor }):Play()
            TweenService:Create(ToggleCircle, TweenInfoPresets.Slow, { Position = UDim2.new(0, 15, 0, 0) }):Play()
            TweenService:Create(UIStroke8, TweenInfoPresets.Normal, { Color = MainColor, Transparency = 0 }):Play()
            TweenService:Create(FeatureFrame2, TweenInfoPresets.Normal,
                { BackgroundColor3 = MainColor, BackgroundTransparency = 0 }):Play()
        else
            TweenService:Create(ToggleTitle, TweenInfoPresets.Normal,
                { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
            TweenService:Create(ToggleCircle, TweenInfoPresets.Slow, { Position = UDim2.new(0, 0, 0, 0) }):Play()
            TweenService:Create(UIStroke8, TweenInfoPresets.Normal,
                { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
            TweenService:Create(FeatureFrame2, TweenInfoPresets.Normal,
                { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
        end
    end

    ToggleFunc:Set(ToggleFunc.Value)
    AllElements[configKey] = ToggleFunc
    return ToggleFunc
end

function ElementsModule.AddSlider(parent, config, countItem, updateSizeCallback)
    config = config or {}
    config.Title = config.Title or "Slider"
    config.Content = config.Content or ""
    config.Increment = config.Increment or 1
    config.Min = config.Min or 0
    config.Max = config.Max or 100
    config.Default = config.Default or 50
    config.Callback = config.Callback or function() end
    config.New = config.New or "false"

    local configKey = "Slider_" .. config.Title
    if ConfigData[configKey] ~= nil then
        config.Default = ConfigData[configKey]
    end

    local SliderFunc = { Value = config.Default }

    local Slider = Instance.new("Frame");
    local UICorner15 = Instance.new("UICorner");
    local SliderTitle = Instance.new("TextLabel");
    local SliderContent = Instance.new("TextLabel");
    local SliderInput = Instance.new("Frame");
    local UICorner16 = Instance.new("UICorner");
    local TextBox = Instance.new("TextBox");
    local SliderFrame = Instance.new("Frame");
    local UICorner17 = Instance.new("UICorner");
    local SliderDraggable = Instance.new("Frame");
    local UICorner18 = Instance.new("UICorner");
    local UIStroke5 = Instance.new("UIStroke");
    local SliderCircle = Instance.new("Frame");
    local UICorner19 = Instance.new("UICorner");
    local UIStroke6 = Instance.new("UIStroke");
    local UIStroke7 = Instance.new("UIStroke");

    Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Slider.BackgroundTransparency = 0.935
    Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Slider.BorderSizePixel = 0
    Slider.LayoutOrder = countItem
    Slider.Size = UDim2.new(1, 0, 0, 46)
    Slider.Name = "Slider"
    Slider.Parent = parent

    UICorner15.CornerRadius = UDim.new(0, 4)
    UICorner15.Parent = Slider

    SliderTitle.Font = Enum.Font.GothamBold
    SliderTitle.Text = config.Title
    SliderTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    SliderTitle.TextSize = 13
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
    SliderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderTitle.BackgroundTransparency = 0.999
    SliderTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SliderTitle.BorderSizePixel = 0
    SliderTitle.Position = UDim2.new(0, 10, 0, 10)
    SliderTitle.Size = UDim2.new(1, -200, 0, 13)
    SliderTitle.Name = "SliderTitle"
    SliderTitle.Parent = Slider

    local Badge = createBadge(Slider, config)
    if Badge then
        Badge.Position = UDim2.new(1, -170, 0, 8)
    end

    SliderContent.Font = Enum.Font.GothamBold
    SliderContent.Text = config.Content
    SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderContent.TextSize = 12
    SliderContent.TextTransparency = 0.6
    SliderContent.TextXAlignment = Enum.TextXAlignment.Left
    SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
    SliderContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderContent.BackgroundTransparency = 0.999
    SliderContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SliderContent.BorderSizePixel = 0
    SliderContent.Position = UDim2.new(0, 10, 0, 25)
    SliderContent.Size = UDim2.new(1, -200, 0, 12)
    SliderContent.Name = "SliderContent"
    SliderContent.Parent = Slider

    SliderContent.Size = UDim2.new(1, -200, 0, 12 + (12 * (SliderContent.TextBounds.X // SliderContent.AbsoluteSize.X)))
    SliderContent.TextWrapped = true
    Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)

    SliderContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        SliderContent.TextWrapped = false
        SliderContent.Size = UDim2.new(1, -200, 0, 12 + (12 * (SliderContent.TextBounds.X // SliderContent.AbsoluteSize.X)))
        Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
        SliderContent.TextWrapped = true
        if updateSizeCallback then updateSizeCallback() end
    end)

    SliderInput.AnchorPoint = Vector2.new(0, 0.5)
    SliderInput.BackgroundColor3 = MainColor
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
    TextBox.BackgroundTransparency = 0.999
    TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.BorderSizePixel = 0
    TextBox.Position = UDim2.new(0, -1, 0, 0)
    TextBox.Size = UDim2.new(1, 0, 1, 0)
    TextBox.Parent = SliderInput

    SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderFrame.BackgroundTransparency = 0.8
    SliderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
    SliderFrame.Size = UDim2.new(0, 100, 0, 3)
    SliderFrame.Name = "SliderFrame"
    SliderFrame.Parent = Slider

    UICorner17.Parent = SliderFrame

    SliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
    SliderDraggable.BackgroundColor3 = MainColor
    SliderDraggable.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SliderDraggable.BorderSizePixel = 0
    SliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
    SliderDraggable.Size = UDim2.new(0.9, 0, 0, 1)
    SliderDraggable.Name = "SliderDraggable"
    SliderDraggable.Parent = SliderFrame

    UICorner18.Parent = SliderDraggable

    SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
    SliderCircle.BackgroundColor3 = MainColor
    SliderCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SliderCircle.BorderSizePixel = 0
    SliderCircle.Position = UDim2.new(1, 4, 0.5, 0)
    SliderCircle.Size = UDim2.new(0, 8, 0, 8)
    SliderCircle.Name = "SliderCircle"
    SliderCircle.Parent = SliderDraggable

    UICorner19.Parent = SliderCircle

    UIStroke6.Color = MainColor
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
        Value = math.clamp(Round(Value, config.Increment), config.Min, config.Max)
        SliderFunc.Value = Value
        TextBox.Text = tostring(Value)
        
        local targetSize = UDim2.fromScale((Value - config.Min) / (config.Max - config.Min), 1)
        TweenService:Create(SliderDraggable, TweenInfoPresets.Slow, { Size = targetSize }):Play()
        
        local success, err = pcall(function()
            config.Callback(Value)
        end)
        if not success then warn("Slider Callback error:", err) end
        
        ConfigData[configKey] = Value
        SaveConfigFunc()
    end

    SliderFrame.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            TweenService:Create(SliderCircle, TweenInfoPresets.Normal, { Size = UDim2.new(0, 14, 0, 14) }):Play()
            
            local SizeScale = math.clamp(
                (Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X,
                0,
                1
            )
            SliderFunc:Set(config.Min + ((config.Max - config.Min) * SizeScale))
        end
    end)

    SliderFrame.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            TweenService:Create(SliderCircle, TweenInfoPresets.Normal, { Size = UDim2.new(0, 8, 0, 8) }):Play()
            
            local success, err = pcall(function()
                config.Callback(SliderFunc.Value)
            end)
            if not success then warn("Slider Callback error:", err) end
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local SizeScale = math.clamp(
                (Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X,
                0,
                1
            )
            SliderFunc:Set(config.Min + ((config.Max - config.Min) * SizeScale))
        end
    end)

    TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local Valid = TextBox.Text:gsub("[^%d]", "")
        if Valid ~= "" then
            local ValidNumber = math.clamp(tonumber(Valid), config.Min, config.Max)
            SliderFunc:Set(ValidNumber)
        else
            SliderFunc:Set(config.Min)
        end
    end)
    
    SliderFunc:Set(config.Default)
    AllElements[configKey] = SliderFunc
    return SliderFunc
end

function ElementsModule.AddInput(parent, config, countItem, updateSizeCallback)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Content = config.Content or ""
    config.Callback = config.Callback or function() end
    config.Default = config.Default or ""
    config.New = config.New or "false"

    local configKey = "Input_" .. config.Title
    if ConfigData[configKey] ~= nil then
        config.Default = ConfigData[configKey]
    end

    local InputFunc = { Value = config.Default }

    local Input = Instance.new("Frame");
    local UICorner12 = Instance.new("UICorner");
    local InputTitle = Instance.new("TextLabel");
    local InputContent = Instance.new("TextLabel");
    local InputFrame = Instance.new("Frame");
    local UICorner13 = Instance.new("UICorner");
    local InputTextBox = Instance.new("TextBox");

    Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Input.BackgroundTransparency = 0.935
    Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Input.BorderSizePixel = 0
    Input.LayoutOrder = countItem
    Input.Size = UDim2.new(1, 0, 0, 46)
    Input.Name = "Input"
    Input.Parent = parent

    UICorner12.CornerRadius = UDim.new(0, 4)
    UICorner12.Parent = Input

    InputTitle.Font = Enum.Font.GothamBold
    InputTitle.Text = config.Title or "TextBox"
    InputTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    InputTitle.TextSize = 13
    InputTitle.TextXAlignment = Enum.TextXAlignment.Left
    InputTitle.TextYAlignment = Enum.TextYAlignment.Top
    InputTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InputTitle.BackgroundTransparency = 0.999
    InputTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InputTitle.BorderSizePixel = 0
    InputTitle.Position = UDim2.new(0, 10, 0, 10)
    InputTitle.Size = UDim2.new(1, -200, 0, 13)
    InputTitle.Name = "InputTitle"
    InputTitle.Parent = Input

    local Badge = createBadge(Input, config)
    if Badge then
        Badge.Position = UDim2.new(1, -170, 0, 8)
    end

    InputContent.Font = Enum.Font.GothamBold
    InputContent.Text = config.Content or "This is a TextBox"
    InputContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputContent.TextSize = 12
    InputContent.TextTransparency = 0.6
    InputContent.TextWrapped = true
    InputContent.TextXAlignment = Enum.TextXAlignment.Left
    InputContent.TextYAlignment = Enum.TextYAlignment.Bottom
    InputContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InputContent.BackgroundTransparency = 0.999
    InputContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InputContent.BorderSizePixel = 0
    InputContent.Position = UDim2.new(0, 10, 0, 25)
    InputContent.Size = UDim2.new(1, -200, 0, 12)
    InputContent.Name = "InputContent"
    InputContent.Parent = Input

    InputContent.Size = UDim2.new(1, -200, 0, 12 + (12 * (InputContent.TextBounds.X // InputContent.AbsoluteSize.X)))
    InputContent.TextWrapped = true
    Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)

    InputContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        InputContent.TextWrapped = false
        InputContent.Size = UDim2.new(1, -200, 0, 12 + (12 * (InputContent.TextBounds.X // InputContent.AbsoluteSize.X)))
        Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)
        InputContent.TextWrapped = true
        if updateSizeCallback then updateSizeCallback() end
    end)

    InputFrame.AnchorPoint = Vector2.new(1, 0.5)
    InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InputFrame.BackgroundTransparency = 0.95
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
    InputTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    InputTextBox.PlaceholderText = "Input Here"
    InputTextBox.Text = config.Default
    InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputTextBox.TextSize = 12
    InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
    InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
    InputTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InputTextBox.BackgroundTransparency = 0.999
    InputTextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InputTextBox.BorderSizePixel = 0
    InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
    InputTextBox.Size = UDim2.new(1, -10, 1, -8)
    InputTextBox.Name = "InputTextBox"
    InputTextBox.Parent = InputFrame
    
    InputTextBox.Focused:Connect(function()
        TweenService:Create(InputFrame, TweenInfoPresets.Normal, {BackgroundTransparency = 0.9}):Play()
    end)
    
    InputTextBox.FocusLost:Connect(function()
        TweenService:Create(InputFrame, TweenInfoPresets.Normal, {BackgroundTransparency = 0.95}):Play()
    end)
    
    function InputFunc:Set(Value)
        InputTextBox.Text = Value
        InputFunc.Value = Value
        config.Callback(Value)
        ConfigData[configKey] = Value
        SaveConfigFunc()
    end

    InputFunc:Set(InputFunc.Value)

    InputTextBox.FocusLost:Connect(function()
        InputFunc:Set(InputTextBox.Text)
    end)
    
    AllElements[configKey] = InputFunc
    return InputFunc
end

-- DROPDOWN - Compatible dengan Main.lua independen
function ElementsModule.AddDropdown(parent, config, countItem, countDropdown, blurContainer, dropPageLayout, updateSizeCallback)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Content = config.Content or ""
    config.Multi = config.Multi or false
    config.Options = config.Options or {}
    config.Default = config.Default or (config.Multi and {} or nil)
    config.Callback = config.Callback or function() end
    config.New = config.New or "false"

    local configKey = "Dropdown_" .. config.Title
    if ConfigData[configKey] ~= nil then
        config.Default = ConfigData[configKey]
    end

    local DropdownFunc = { Value = config.Default, Options = config.Options }

    -- SAFETY CHECK
    if not blurContainer or not dropPageLayout then
        warn("Dropdown Error: blurContainer or dropPageLayout is nil")
        return {
            Clear = function() end,
            AddOption = function() end,
            Set = function() end,
            SetValues = function() end,
            GetValue = function() return nil end
        }
    end

    local Dropdown = Instance.new("Frame")
    local DropdownButton = Instance.new("TextButton")
    local UICorner10 = Instance.new("UICorner")
    local DropdownTitle = Instance.new("TextLabel")
    local DropdownContent = Instance.new("TextLabel")
    local SelectOptionsFrame = Instance.new("Frame")
    local UICorner11 = Instance.new("UICorner")
    local OptionSelecting = Instance.new("TextLabel")
    local OptionImg = Instance.new("ImageLabel")

    Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dropdown.BackgroundTransparency = 0.935
    Dropdown.BorderSizePixel = 0
    Dropdown.LayoutOrder = countItem
    Dropdown.Size = UDim2.new(1, 0, 0, 46)
    Dropdown.Name = "Dropdown"
    Dropdown.Parent = parent

    DropdownButton.Text = ""
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.Name = "ToggleButton"
    DropdownButton.Parent = Dropdown

    UICorner10.CornerRadius = UDim.new(0, 4)
    UICorner10.Parent = Dropdown

    DropdownTitle.Font = Enum.Font.GothamBold
    DropdownTitle.Text = config.Title
    DropdownTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    DropdownTitle.TextSize = 13
    DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
    DropdownTitle.BackgroundTransparency = 1
    DropdownTitle.Position = UDim2.new(0, 10, 0, 10)
    DropdownTitle.Size = UDim2.new(1, -180, 0, 13)
    DropdownTitle.Name = "DropdownTitle"
    DropdownTitle.Parent = Dropdown

    local Badge = createBadge(Dropdown, config)
    if Badge then
        Badge.Position = UDim2.new(1, -170, 0, 8)
    end

    DropdownContent.Font = Enum.Font.GothamBold
    DropdownContent.Text = config.Content
    DropdownContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownContent.TextSize = 12
    DropdownContent.TextTransparency = 0.6
    DropdownContent.TextWrapped = true
    DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
    DropdownContent.BackgroundTransparency = 1
    DropdownContent.Position = UDim2.new(0, 10, 0, 25)
    DropdownContent.Size = UDim2.new(1, -180, 0, 12)
    DropdownContent.Name = "DropdownContent"
    DropdownContent.Parent = Dropdown

    SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
    SelectOptionsFrame.BackgroundTransparency = 0.95
    SelectOptionsFrame.Position = UDim2.new(1, -7, 0.5, 0)
    SelectOptionsFrame.Size = UDim2.new(0, 148, 0, 30)
    SelectOptionsFrame.Name = "SelectOptionsFrame"
    SelectOptionsFrame.LayoutOrder = countDropdown
    SelectOptionsFrame.Parent = Dropdown

    UICorner11.CornerRadius = UDim.new(0, 4)
    UICorner11.Parent = SelectOptionsFrame

    SelectOptionsFrame.MouseEnter:Connect(function()
        TweenService:Create(SelectOptionsFrame, TweenInfoPresets.Quick, {BackgroundTransparency = 0.9}):Play()
    end)
    
    SelectOptionsFrame.MouseLeave:Connect(function()
        TweenService:Create(SelectOptionsFrame, TweenInfoPresets.Quick, {BackgroundTransparency = 0.95}):Play()
    end)

    -- Dropdown button click handler
    DropdownButton.Activated:Connect(function()
        if not blurContainer then 
            warn("Dropdown Error: blurContainer is nil")
            return 
        end
        
        if not blurContainer.Visible then
            blurContainer.Visible = true
            
            if dropPageLayout then
                dropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder or 0)
            end
            
            pcall(function()
                TweenService:Create(blurContainer, TweenInfoPresets.Slow, { BackgroundTransparency = 1 }):Play()
            end)
            
            -- Cari DropdownSelect - untuk mode independen, namanya "DropdownSelect_" .. countItem
            local dropdownSelectName = "DropdownSelect_" .. countItem
            local dropdownSelect = blurContainer:FindFirstChild(dropdownSelectName)
            
            -- Fallback ke pencarian umum
            if not dropdownSelect then
                dropdownSelect = blurContainer:FindFirstChild("DropdownSelect")
            end
            
            if dropdownSelect then
                pcall(function()
                    TweenService:Create(dropdownSelect, TweenInfoPresets.Slow, { Position = UDim2.new(1, -11, 0.5, 0) }):Play()
                end)
            else
                warn("DropdownSelect not found in", blurContainer.Name)
            end
            
            TweenService:Create(OptionImg, TweenInfoPresets.Normal, {Rotation = 180}):Play()
        else
            blurContainer.Visible = false
            TweenService:Create(OptionImg, TweenInfoPresets.Normal, {Rotation = 0}):Play()
        end
    end)

    OptionSelecting.Font = Enum.Font.GothamBold
    OptionSelecting.Text = config.Multi and "Select Options" or "Select Option"
    OptionSelecting.TextColor3 = Color3.fromRGB(255, 255, 255)
    OptionSelecting.TextSize = 12
    OptionSelecting.TextTransparency = 0.6
    OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
    OptionSelecting.AnchorPoint = Vector2.new(0, 0.5)
    OptionSelecting.BackgroundTransparency = 1
    OptionSelecting.Position = UDim2.new(0, 5, 0.5, 0)
    OptionSelecting.Size = UDim2.new(1, -30, 1, -8)
    OptionSelecting.Name = "OptionSelecting"
    OptionSelecting.Parent = SelectOptionsFrame

    OptionImg.Image = "rbxassetid://16851841101"
    OptionImg.ImageColor3 = Color3.fromRGB(230, 230, 230)
    OptionImg.AnchorPoint = Vector2.new(1, 0.5)
    OptionImg.BackgroundTransparency = 1
    OptionImg.Position = UDim2.new(1, 0, 0.5, 0)
    OptionImg.Size = UDim2.new(0, 25, 0, 25)
    OptionImg.Name = "OptionImg"
    OptionImg.Parent = SelectOptionsFrame

    -- Cari folder untuk dropdown items
    local dropdownFolder
    if blurContainer then
        -- Coba cari dengan nama spesifik dulu
        local dropdownSelectName = "DropdownSelect_" .. countItem
        local dropdownSelect = blurContainer:FindFirstChild(dropdownSelectName)
        
        if dropdownSelect then
            local dropdownSelectReal = dropdownSelect:FindFirstChild("DropdownSelectReal_" .. countItem)
            if dropdownSelectReal then
                dropdownFolder = dropdownSelectReal:FindFirstChild("DropdownFolder_" .. countItem)
            end
        end
        
        -- Fallback ke pencarian umum
        if not dropdownFolder then
            local dropdownSelect = blurContainer:FindFirstChild("DropdownSelect")
            if dropdownSelect then
                local dropdownSelectReal = dropdownSelect:FindFirstChild("DropdownSelectReal")
                if dropdownSelectReal then
                    dropdownFolder = dropdownSelectReal:FindFirstChild("DropdownFolder")
                end
            end
        end
    end

    if not dropdownFolder then
        warn("Dropdown Error: Cannot find dropdown folder")
        return {
            Clear = function() end,
            AddOption = function() end,
            Set = function() end,
            SetValues = function() end,
            GetValue = function() return nil end
        }
    end

    local DropdownContainer = Instance.new("Frame")
    DropdownContainer.Size = UDim2.new(1, 0, 1, 0)
    DropdownContainer.BackgroundTransparency = 1
    DropdownContainer.Parent = dropdownFolder

    local SearchBox = Instance.new("TextBox")
    SearchBox.PlaceholderText = "Search"
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Text = ""
    SearchBox.TextSize = 12
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SearchBox.BackgroundTransparency = 0.9
    SearchBox.BorderSizePixel = 0
    SearchBox.Size = UDim2.new(1, 0, 0, 25)
    SearchBox.Position = UDim2.new(0, 0, 0, 0)
    SearchBox.ClearTextOnFocus = false
    SearchBox.Name = "SearchBox"
    SearchBox.Parent = DropdownContainer

    local ScrollSelect = Instance.new("ScrollingFrame")
    ScrollSelect.Size = UDim2.new(1, 0, 1, -30)
    ScrollSelect.Position = UDim2.new(0, 0, 0, 30)
    ScrollSelect.ScrollBarImageTransparency = 1
    ScrollSelect.BorderSizePixel = 0
    ScrollSelect.BackgroundTransparency = 1
    ScrollSelect.ScrollBarThickness = 0
    ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollSelect.Name = "ScrollSelect"
    ScrollSelect.Parent = DropdownContainer

    local UIListLayout4 = Instance.new("UIListLayout")
    UIListLayout4.Padding = UDim.new(0, 3)
    UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout4.Parent = ScrollSelect

    UIListLayout4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
    end)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, option in pairs(ScrollSelect:GetChildren()) do
            if option.Name == "Option" and option:FindFirstChild("OptionText") then
                local text = string.lower(option.OptionText.Text)
                option.Visible = query == "" or string.find(text, query, 1, true)
            end
        end
        ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
    end)

    function DropdownFunc:Clear()
        for _, DropFrame in ScrollSelect:GetChildren() do
            if DropFrame.Name == "Option" then
                DropFrame:Destroy()
            end
        end
        DropdownFunc.Value = config.Multi and {} or nil
        DropdownFunc.Options = {}
        OptionSelecting.Text = config.Multi and "Select Options" or "Select Option"
    end

    function DropdownFunc:AddOption(option)
        local label, value
        if typeof(option) == "table" and option.Label and option.Value ~= nil then
            label = tostring(option.Label)
            value = option.Value
        else
            label = tostring(option)
            value = option
        end

        local Option = Instance.new("Frame")
        local OptionButton = Instance.new("TextButton")
        local OptionText = Instance.new("TextLabel")
        local ChooseFrame = Instance.new("Frame")
        local UIStroke15 = Instance.new("UIStroke")
        local UICorner38 = Instance.new("UICorner")
        local UICorner37 = Instance.new("UICorner")

        Option.BackgroundTransparency = 1
        Option.Size = UDim2.new(1, 0, 0, 30)
        Option.Name = "Option"
        Option.Parent = ScrollSelect

        UICorner37.CornerRadius = UDim.new(0, 3)
        UICorner37.Parent = Option

        OptionButton.BackgroundTransparency = 1
        OptionButton.Size = UDim2.new(1, 0, 1, 0)
        OptionButton.Text = ""
        OptionButton.Name = "OptionButton"
        OptionButton.Parent = Option
        
        OptionButton.MouseEnter:Connect(function()
            TweenService:Create(Option, TweenInfoPresets.Quick, {BackgroundTransparency = 0.95}):Play()
        end)
        
        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(Option, TweenInfoPresets.Quick, {BackgroundTransparency = 1}):Play()
        end)

        OptionText.Font = Enum.Font.GothamBold
        OptionText.Text = label
        OptionText.TextSize = 13
        OptionText.TextColor3 = Color3.fromRGB(230, 230, 230)
        OptionText.Position = UDim2.new(0, 8, 0, 8)
        OptionText.Size = UDim2.new(1, -100, 0, 13)
        OptionText.BackgroundTransparency = 1
        OptionText.TextXAlignment = Enum.TextXAlignment.Left
        OptionText.Name = "OptionText"
        OptionText.Parent = Option

        Option:SetAttribute("RealValue", value)

        ChooseFrame.AnchorPoint = Vector2.new(0, 0.5)
        ChooseFrame.BackgroundColor3 = MainColor
        ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
        ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
        ChooseFrame.Name = "ChooseFrame"
        ChooseFrame.Parent = Option

        UIStroke15.Color = MainColor
        UIStroke15.Thickness = 1.6
        UIStroke15.Transparency = 0.999
        UIStroke15.Parent = ChooseFrame
        UICorner38.Parent = ChooseFrame

        OptionButton.Activated:Connect(function()
            if config.Multi then
                if not table.find(DropdownFunc.Value, value) then
                    table.insert(DropdownFunc.Value, value)
                else
                    for i, v in pairs(DropdownFunc.Value) do
                        if v == value then
                            table.remove(DropdownFunc.Value, i)
                            break
                        end
                    end
                end
            else
                DropdownFunc.Value = value
            end
            DropdownFunc:Set(DropdownFunc.Value)
        end)
    end

    function DropdownFunc:Set(Value)
        if config.Multi then
            DropdownFunc.Value = type(Value) == "table" and Value or {}
        else
            DropdownFunc.Value = (type(Value) == "table" and Value[1]) or Value
        end

        ConfigData[configKey] = DropdownFunc.Value
        SaveConfigFunc()

        local texts = {}
        for _, Drop in ScrollSelect:GetChildren() do
            if Drop.Name == "Option" and Drop:FindFirstChild("OptionText") then
                local v = Drop:GetAttribute("RealValue")
                local selected = config.Multi and table.find(DropdownFunc.Value, v) or DropdownFunc.Value == v

                if selected then
                    TweenService:Create(Drop.ChooseFrame, TweenInfoPresets.Slow,
                        { Size = UDim2.new(0, 1, 0, 12) }):Play()
                    TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfoPresets.Normal, { Transparency = 0 }):Play()
                    TweenService:Create(Drop, TweenInfoPresets.Normal, { BackgroundTransparency = 0.935 }):Play()
                    table.insert(texts, Drop.OptionText.Text)
                else
                    TweenService:Create(Drop.ChooseFrame, TweenInfoPresets.Normal,
                        { Size = UDim2.new(0, 0, 0, 0) }):Play()
                    TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfoPresets.Normal,
                        { Transparency = 0.999 }):Play()
                    TweenService:Create(Drop, TweenInfoPresets.Normal, { BackgroundTransparency = 0.999 }):Play()
                end
            end
        end

        OptionSelecting.Text = (#texts == 0)
            and (config.Multi and "Select Options" or "Select Option")
            or table.concat(texts, ", ")

        if config.Callback then
            if config.Multi then
                config.Callback(DropdownFunc.Value)
            else
                local str = (DropdownFunc.Value ~= nil) and tostring(DropdownFunc.Value) or ""
                config.Callback(str)
            end
        end
    end

    function DropdownFunc:SetValue(val)
        self:Set(val)
    end

    function DropdownFunc:GetValue()
        return self.Value
    end

    function DropdownFunc:SetValues(newList, selecting)
        newList = newList or {}
        selecting = selecting or (config.Multi and {} or nil)
        DropdownFunc:Clear()
        for _, v in ipairs(newList) do
            DropdownFunc:AddOption(v)
        end
        DropdownFunc.Options = newList
        DropdownFunc:Set(selecting)
    end

    DropdownFunc:SetValues(DropdownFunc.Options, DropdownFunc.Value)

    AllElements[configKey] = DropdownFunc
    return DropdownFunc
end

function ElementsModule.AddDivider(parent, countItem, updateSizeCallback)
    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.Parent = parent
    Divider.AnchorPoint = Vector2.new(0.5, 0)
    Divider.Position = UDim2.new(0.5, 0, 0, 0)
    Divider.Size = UDim2.new(1, 0, 0, 2)
    Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Divider.BackgroundTransparency = 0
    Divider.BorderSizePixel = 0
    Divider.LayoutOrder = countItem

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
        ColorSequenceKeypoint.new(0.5, MainColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    }
    UIGradient.Parent = Divider

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 2)
    UICorner.Parent = Divider

    return Divider
end

function ElementsModule.AddSubSection(parent, title, countItem, updateSizeCallback)
    title = title or "Sub Section"

    local SubSection = Instance.new("Frame")
    SubSection.Name = "SubSection"
    SubSection.Parent = parent
    SubSection.BackgroundTransparency = 1
    SubSection.Size = UDim2.new(1, 0, 0, 22)
    SubSection.LayoutOrder = countItem

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

    return SubSection
end

return ElementsModule
