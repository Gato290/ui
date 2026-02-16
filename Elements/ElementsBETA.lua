-- Elements.lua V0.0.4
-- UI Elements Module for NexaHub
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Elements = {}

-- Private variables
local GuiConfig, SaveConfig, ConfigData, Icons

-- Constants
local DEFAULT_TRANSPARENCY = 0.935
local INPUT_TRANSPARENCY = 0.95
local CORNER_RADIUS = UDim.new(0, 4)
local SMALL_CORNER = UDim.new(0, 6)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local TITLE_COLOR = Color3.fromRGB(231, 231, 231)
local PLACEHOLDER_COLOR = Color3.fromRGB(120, 120, 120)

-- Utility functions
local function createUICorner(instance, radius)
    radius = radius or CORNER_RADIUS
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius
    corner.Parent = instance
    return corner
end

local function createUIStroke(instance, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Transparency = transparency or 0.9
    stroke.Thickness = thickness or 2
    stroke.Parent = instance
    return stroke
end

local function createTextLabel(parent, config)
    local label = Instance.new("TextLabel")
    label.Font = config.Font or Enum.Font.Gotham
    label.Text = config.Text or ""
    label.TextColor3 = config.Color or TEXT_COLOR
    label.TextSize = config.Size or 12
    label.TextXAlignment = config.XAlign or Enum.TextXAlignment.Left
    label.TextYAlignment = config.YAlign or Enum.TextYAlignment.Center
    label.BackgroundTransparency = 1
    label.Position = config.Position or UDim2.new(0, 0, 0, 0)
    label.Size = config.Size2 or UDim2.new(1, 0, 0, 14)
    label.Parent = parent
    return label
end

local function createButton(parent, config)
    local btn = Instance.new("TextButton")
    btn.Font = Enum.Font.GothamBold
    btn.Text = config.Text or ""
    btn.TextColor3 = config.Color or TEXT_COLOR
    btn.TextSize = config.TextSize or 12
    btn.TextTransparency = config.TextTransparency or 0.3
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = DEFAULT_TRANSPARENCY
    btn.Size = config.Size or UDim2.new(1, -12, 1, -10)
    btn.Position = config.Position or UDim2.new(0, 6, 0, 5)
    btn.Parent = parent
    return btn
end

function Elements:Initialize(config, saveFunc, configData, icons)
    GuiConfig = config
    SaveConfig = saveFunc
    ConfigData = configData
    Icons = icons
end

function Elements:CreateParagraph(parent, config, countItem)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Content = config.Content or "Content"
    
    local paragraphFunc = {}
    local iconOffset = 10

    -- Main frame
    local paragraph = Instance.new("Frame")
    paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    paragraph.BackgroundTransparency = DEFAULT_TRANSPARENCY
    paragraph.BorderSizePixel = 0
    paragraph.LayoutOrder = countItem
    paragraph.Size = UDim2.new(1, 0, 0, 46)
    paragraph.Name = "Paragraph"
    paragraph.Parent = parent
    
    createUICorner(paragraph)

    -- Icon (if specified)
    if config.Icon then
        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 20, 0, 20)
        iconImg.Position = UDim2.new(0, 8, 0, 12)
        iconImg.BackgroundTransparency = 1
        iconImg.Name = "ParagraphIcon"
        iconImg.Image = Icons and Icons[config.Icon] or config.Icon
        iconImg.Parent = paragraph
        iconOffset = 30
    end

    -- Title
    local title = createTextLabel(paragraph, {
        Font = Enum.Font.GothamBold,
        Text = config.Title,
        Color = TITLE_COLOR,
        Size = 13,
        XAlign = Enum.TextXAlignment.Left,
        YAlign = Enum.TextYAlignment.Top,
        Position = UDim2.new(0, iconOffset, 0, 10),
        Size2 = UDim2.new(1, -16, 0, 13)
    })
    title.Name = "ParagraphTitle"

    -- Content
    local content = createTextLabel(paragraph, {
        Font = Enum.Font.Gotham,
        Text = config.Content,
        Color = TEXT_COLOR,
        Size = 12,
        XAlign = Enum.TextXAlignment.Left,
        YAlign = Enum.TextYAlignment.Top,
        Position = UDim2.new(0, iconOffset, 0, 25),
        Size2 = UDim2.new(1, -16, 0, 14)
    })
    content.Name = "ParagraphContent"
    content.TextWrapped = false
    content.RichText = true

    -- Button (if specified)
    local button
    if config.ButtonText then
        button = createButton(paragraph, {
            Text = config.ButtonText,
            Position = UDim2.new(0, 10, 0, 42),
            Size = UDim2.new(1, -22, 0, 28)
        })
        createUICorner(button, SMALL_CORNER)
        
        if config.ButtonCallback then
            button.MouseButton1Click:Connect(config.ButtonCallback)
        end
    end

    -- Dynamic sizing
    local function updateSize()
        local totalHeight = content.TextBounds.Y + 33
        if button then
            totalHeight = totalHeight + button.Size.Y.Offset + 5
        end
        paragraph.Size = UDim2.new(1, 0, 0, totalHeight)
    end

    updateSize()
    content:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)

    function paragraphFunc:SetContent(newContent)
        content.Text = newContent or "Content"
        updateSize()
    end

    return paragraphFunc
end

function Elements:CreatePanel(parent, config, countItem)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Content = config.Content or ""
    config.Placeholder = config.Placeholder
    config.Default = config.Default or ""
    config.ButtonText = config.Button or config.ButtonText or "Confirm"
    config.ButtonCallback = config.Callback or config.ButtonCallback or function() end
    config.SubButtonText = config.SubButton or config.SubButtonText
    config.SubButtonCallback = config.SubCallback or config.SubButtonCallback or function() end

    local configKey = "Panel_" .. config.Title
    if ConfigData[configKey] ~= nil then
        config.Default = ConfigData[configKey]
    end

    local panelFunc = { Value = config.Default }

    -- Calculate height
    local baseHeight = 50
    if config.Placeholder then baseHeight = baseHeight + 40 end
    baseHeight = baseHeight + (config.SubButtonText and 40 or 36)

    -- Main frame
    local panel = Instance.new("Frame")
    panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    panel.BackgroundTransparency = DEFAULT_TRANSPARENCY
    panel.Size = UDim2.new(1, 0, 0, baseHeight)
    panel.LayoutOrder = countItem
    panel.Parent = parent
    
    createUICorner(panel)

    -- Title
    local title = createTextLabel(panel, {
        Font = Enum.Font.GothamBold,
        Text = config.Title,
        Color = TEXT_COLOR,
        Size = 13,
        XAlign = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 10, 0, 10),
        Size2 = UDim2.new(1, -20, 0, 13)
    })

    -- Content
    local content = createTextLabel(panel, {
        Text = config.Content,
        Color = TEXT_COLOR,
        Size = 12,
        XAlign = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 10, 0, 28),
        Size2 = UDim2.new(1, -20, 0, 14)
    })
    content.RichText = true

    -- Input box
    local inputBox
    if config.Placeholder then
        local inputFrame = Instance.new("Frame")
        inputFrame.AnchorPoint = Vector2.new(0.5, 0)
        inputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        inputFrame.BackgroundTransparency = INPUT_TRANSPARENCY
        inputFrame.Position = UDim2.new(0.5, 0, 0, 48)
        inputFrame.Size = UDim2.new(1, -20, 0, 30)
        inputFrame.Parent = panel
        createUICorner(inputFrame, SMALL_CORNER)

        inputBox = Instance.new("TextBox")
        inputBox.Font = Enum.Font.GothamBold
        inputBox.PlaceholderText = config.Placeholder
        inputBox.PlaceholderColor3 = PLACEHOLDER_COLOR
        inputBox.Text = config.Default
        inputBox.TextSize = 11
        inputBox.TextColor3 = TEXT_COLOR
        inputBox.BackgroundTransparency = 1
        inputBox.TextXAlignment = Enum.TextXAlignment.Left
        inputBox.Size = UDim2.new(1, -10, 1, -6)
        inputBox.Position = UDim2.new(0, 5, 0, 3)
        inputBox.Parent = inputFrame
    end

    -- Buttons
    local yBtn = config.Placeholder and 88 or 48
    
    local mainButton = createButton(panel, {
        Text = config.ButtonText,
        Position = UDim2.new(0, 10, 0, yBtn),
        Size = config.SubButtonText and UDim2.new(0.5, -12, 0, 30) or UDim2.new(1, -20, 0, 30)
    })
    createUICorner(mainButton, SMALL_CORNER)
    
    mainButton.MouseButton1Click:Connect(function()
        config.ButtonCallback(inputBox and inputBox.Text or "")
    end)

    if config.SubButtonText then
        local subButton = createButton(panel, {
            Text = config.SubButtonText,
            Position = UDim2.new(0.5, 2, 0, yBtn),
            Size = UDim2.new(0.5, -12, 0, 30)
        })
        createUICorner(subButton, SMALL_CORNER)
        
        subButton.MouseButton1Click:Connect(function()
            config.SubButtonCallback(inputBox and inputBox.Text or "")
        end)
    end

    -- Input events
    if inputBox then
        inputBox.FocusLost:Connect(function()
            panelFunc.Value = inputBox.Text
            ConfigData[configKey] = inputBox.Text
            SaveConfig()
        end)
    end

    function panelFunc:GetInput()
        return inputBox and inputBox.Text or ""
    end

    return panelFunc
end

function Elements:CreateButton(parent, config, countItem)
    config = config or {}
    config.Title = config.Title or "Confirm"
    config.Callback = config.Callback or function() end
    config.SubTitle = config.SubTitle
    config.SubCallback = config.SubCallback or function() end

    -- Main frame
    local button = Instance.new("Frame")
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = DEFAULT_TRANSPARENCY
    button.Size = UDim2.new(1, 0, 0, 40)
    button.LayoutOrder = countItem
    button.Parent = parent
    
    createUICorner(button)

    -- Main button
    local mainButton = createButton(button, {
        Text = config.Title,
        Size = config.SubTitle and UDim2.new(0.5, -8, 1, -10) or UDim2.new(1, -12, 1, -10)
    })
    createUICorner(mainButton, SMALL_CORNER)
    mainButton.MouseButton1Click:Connect(config.Callback)

    -- Sub button
    if config.SubTitle then
        local subButton = createButton(button, {
            Text = config.SubTitle,
            Position = UDim2.new(0.5, 2, 0, 5),
            Size = UDim2.new(0.5, -8, 1, -10)
        })
        createUICorner(subButton, SMALL_CORNER)
        subButton.MouseButton1Click:Connect(config.SubCallback)
    end
end

function Elements:CreateToggle(parent, config, countItem, updateSectionSize, elementsTable)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Title2 = config.Title2 or ""
    config.Content = config.Content or ""
    config.Default = config.Default or false
    config.Callback = config.Callback or function() end

    local configKey = "Toggle_" .. config.Title
    if ConfigData[configKey] ~= nil then
        config.Default = ConfigData[configKey]
    end

    local toggleFunc = { Value = config.Default }

    -- Main frame
    local toggle = Instance.new("Frame")
    toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggle.BackgroundTransparency = DEFAULT_TRANSPARENCY
    toggle.BorderSizePixel = 0
    toggle.LayoutOrder = countItem
    toggle.Name = "Toggle"
    toggle.Parent = parent
    
    createUICorner(toggle)

    -- Title
    local title = createTextLabel(toggle, {
        Font = Enum.Font.GothamBold,
        Text = config.Title,
        Color = TITLE_COLOR,
        Size = 13,
        XAlign = Enum.TextXAlignment.Left,
        YAlign = Enum.TextYAlignment.Top,
        Position = UDim2.new(0, 10, 0, 10),
        Size2 = UDim2.new(1, -100, 0, 13)
    })
    title.Name = "ToggleTitle"

    -- Second title
    local title2 = createTextLabel(toggle, {
        Font = Enum.Font.GothamBold,
        Text = config.Title2,
        Color = TITLE_COLOR,
        Size = 12,
        XAlign = Enum.TextXAlignment.Left,
        YAlign = Enum.TextYAlignment.Top,
        Position = UDim2.new(0, 10, 0, 23),
        Size2 = UDim2.new(1, -100, 0, 12)
    })
    title2.Name = "ToggleTitle2"
    title2.Visible = config.Title2 ~= ""

    -- Content
    local content = createTextLabel(toggle, {
        Font = Enum.Font.GothamBold,
        Text = config.Content,
        Color = TEXT_COLOR,
        Size = 12,
        TextTransparency = 0.6,
        XAlign = Enum.TextXAlignment.Left,
        YAlign = Enum.TextYAlignment.Bottom,
        Position = UDim2.new(0, 10, config.Title2 ~= "" and 36 or 23, 0),
        Size2 = UDim2.new(1, -100, 0, 12)
    })
    content.Name = "ToggleContent"
    content.TextWrapped = true

    -- Toggle button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Font = Enum.Font.SourceSans
    toggleButton.Text = ""
    toggleButton.BackgroundTransparency = 1
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.Name = "ToggleButton"
    toggleButton.Parent = toggle

    -- Toggle frame
    local featureFrame = Instance.new("Frame")
    featureFrame.AnchorPoint = Vector2.new(1, 0.5)
    featureFrame.BackgroundTransparency = 0.92
    featureFrame.BorderSizePixel = 0
    featureFrame.Position = UDim2.new(1, -15, 0.5, 0)
    featureFrame.Size = UDim2.new(0, 30, 0, 15)
    featureFrame.Name = "FeatureFrame"
    featureFrame.Parent = toggle
    
    createUICorner(featureFrame)
    
    local stroke = createUIStroke(featureFrame, Color3.fromRGB(255, 255, 255), 0.9, 2)

    -- Toggle circle
    local circle = Instance.new("Frame")
    circle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    circle.BorderSizePixel = 0
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Name = "ToggleCircle"
    circle.Parent = featureFrame
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0, 15)
    circleCorner.Parent = circle

    -- Dynamic sizing
    local function updateSize()
        content.Size = UDim2.new(1, -100, 0, content.TextBounds.Y + 2)
        local baseHeight = config.Title2 ~= "" and 47 or 33
        toggle.Size = UDim2.new(1, 0, 0, content.AbsoluteSize.Y + baseHeight)
        if updateSectionSize then updateSectionSize() end
    end

    content:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
    updateSize()

    -- Toggle functionality
    toggleButton.Activated:Connect(function()
        toggleFunc.Value = not toggleFunc.Value
        toggleFunc:Set(toggleFunc.Value)
    end)

    function toggleFunc:Set(value)
        toggleFunc.Value = value
        
        -- Safe callback execution
        local success, err = pcall(config.Callback, value)
        if not success then warn("Toggle callback error:", err) end
        
        -- Save config
        ConfigData[configKey] = value
        SaveConfig()
        
        -- Visual updates
        local titleColor = value and GuiConfig.Color or Color3.fromRGB(230, 230, 230)
        TweenService:Create(title, TweenInfo.new(0.2), { TextColor3 = titleColor }):Play()
        
        local circlePos = value and UDim2.new(0, 15, 0, 0) or UDim2.new(0, 0, 0, 0)
        TweenService:Create(circle, TweenInfo.new(0.2), { Position = circlePos }):Play()
        
        if value then
            TweenService:Create(stroke, TweenInfo.new(0.2), { Color = GuiConfig.Color, Transparency = 0 }):Play()
            TweenService:Create(featureFrame, TweenInfo.new(0.2), { 
                BackgroundColor3 = GuiConfig.Color, 
                BackgroundTransparency = 0 
            }):Play()
        else
            TweenService:Create(stroke, TweenInfo.new(0.2), { 
                Color = Color3.fromRGB(255, 255, 255), 
                Transparency = 0.9 
            }):Play()
            TweenService:Create(featureFrame, TweenInfo.new(0.2), { 
                BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
                BackgroundTransparency = 0.92 
            }):Play()
        end
    end

    toggleFunc:Set(toggleFunc.Value)
    elementsTable[configKey] = toggleFunc
    return toggleFunc
end

function Elements:CreateSlider(parent, config, countItem, updateSectionSize, elementsTable)
    config = config or {}
    config.Title = config.Title or "Slider"
    config.Content = config.Content or ""
    config.Increment = config.Increment or 1
    config.Min = config.Min or 0
    config.Max = config.Max or 100
    config.Default = config.Default or 50
    config.Callback = config.Callback or function() end

    local configKey = "Slider_" .. config.Title
    if ConfigData[configKey] ~= nil then
        config.Default = ConfigData[configKey]
    end

    local sliderFunc = { Value = config.Default }

    -- Main frame
    local slider = Instance.new("Frame")
    slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slider.BackgroundTransparency = DEFAULT_TRANSPARENCY
    slider.BorderSizePixel = 0
    slider.LayoutOrder = countItem
    slider.Size = UDim2.new(1, 0, 0, 46)
    slider.Name = "Slider"
    slider.Parent = parent
    
    createUICorner(slider)

    -- Title
    local title = createTextLabel(slider, {
        Font = Enum.Font.GothamBold,
        Text = config.Title,
        Color = TITLE_COLOR,
        Size = 13,
        XAlign = Enum.TextXAlignment.Left,
        YAlign = Enum.TextYAlignment.Top,
        Position = UDim2.new(0, 10, 0, 10),
        Size2 = UDim2.new(1, -180, 0, 13)
    })
    title.Name = "SliderTitle"

    -- Content
    local content = createTextLabel(slider, {
        Font = Enum.Font.GothamBold,
        Text = config.Content,
        Color = TEXT_COLOR,
        Size = 12,
        TextTransparency = 0.6,
        XAlign = Enum.TextXAlignment.Left,
        YAlign = Enum.TextYAlignment.Bottom,
        Position = UDim2.new(0, 10, 0, 25),
        Size2 = UDim2.new(1, -180, 0, 12)
    })
    content.Name = "SliderContent"
    content.TextWrapped = true

    -- Input box
    local inputFrame = Instance.new("Frame")
    inputFrame.AnchorPoint = Vector2.new(0, 0.5)
    inputFrame.BackgroundColor3 = GuiConfig.Color
    inputFrame.BackgroundTransparency = 1
    inputFrame.BorderSizePixel = 0
    inputFrame.Position = UDim2.new(1, -155, 0.5, 0)
    inputFrame.Size = UDim2.new(0, 28, 0, 20)
    inputFrame.Name = "SliderInput"
    inputFrame.Parent = slider
    
    createUICorner(inputFrame, UDim.new(0, 2))

    local textBox = Instance.new("TextBox")
    textBox.Font = Enum.Font.GothamBold
    textBox.Text = tostring(config.Default)
    textBox.TextColor3 = TEXT_COLOR
    textBox.TextSize = 13
    textBox.TextWrapped = true
    textBox.BackgroundTransparency = 1
    textBox.BorderSizePixel = 0
    textBox.Position = UDim2.new(0, -1, 0, 0)
    textBox.Size = UDim2.new(1, 0, 1, 0)
    textBox.Parent = inputFrame

    -- Slider track
    local sliderFrame = Instance.new("Frame")
    sliderFrame.AnchorPoint = Vector2.new(1, 0.5)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderFrame.BackgroundTransparency = 0.8
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
    sliderFrame.Size = UDim2.new(0, 100, 0, 3)
    sliderFrame.Name = "SliderFrame"
    sliderFrame.Parent = slider
    
    createUICorner(sliderFrame)

    -- Slider draggable part
    local sliderDraggable = Instance.new("Frame")
    sliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
    sliderDraggable.BackgroundColor3 = GuiConfig.Color
    sliderDraggable.BorderSizePixel = 0
    sliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
    sliderDraggable.Name = "SliderDraggable"
    sliderDraggable.Parent = sliderFrame
    
    createUICorner(sliderDraggable)

    -- Slider handle
    local sliderCircle = Instance.new("Frame")
    sliderCircle.AnchorPoint = Vector2.new(1, 0.5)
    sliderCircle.BackgroundColor3 = GuiConfig.Color
    sliderCircle.BorderSizePixel = 0
    sliderCircle.Position = UDim2.new(1, 4, 0.5, 0)
    sliderCircle.Size = UDim2.new(0, 8, 0, 8)
    sliderCircle.Name = "SliderCircle"
    sliderCircle.Parent = sliderDraggable
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.Parent = sliderCircle
    
    createUIStroke(sliderCircle, GuiConfig.Color)

    -- Dynamic sizing
    local function updateSize()
        content.Size = UDim2.new(1, -180, 0, content.TextBounds.Y + 2)
        slider.Size = UDim2.new(1, 0, 0, content.AbsoluteSize.Y + 33)
        if updateSectionSize then updateSectionSize() end
    end

    content:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
    updateSize()

    -- Slider logic
    local dragging = false
    
    local function roundToIncrement(number)
        local rounded = math.floor(number / config.Increment + 0.5) * config.Increment
        return math.clamp(rounded, config.Min, config.Max)
    end

    function sliderFunc:Set(value)
        value = roundToIncrement(value)
        sliderFunc.Value = value
        textBox.Text = tostring(value)
        
        local scale = (value - config.Min) / (config.Max - config.Min)
        TweenService:Create(
            sliderDraggable,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.fromScale(scale, 1) }
        ):Play()
        
        pcall(config.Callback, value)
        ConfigData[configKey] = value
        SaveConfig()
    end

    -- Input handling
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            TweenService:Create(sliderCircle, TweenInfo.new(0.2), { Size = UDim2.new(0, 14, 0, 14) }):Play()
            
            local scale = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            sliderFunc:Set(config.Min + ((config.Max - config.Min) * scale))
        end
    end)

    sliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            pcall(config.Callback, sliderFunc.Value)
            TweenService:Create(sliderCircle, TweenInfo.new(0.2), { Size = UDim2.new(0, 8, 0, 8) }):Play()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
            local scale = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            sliderFunc:Set(config.Min + ((config.Max - config.Min) * scale))
        end
    end)

    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        local num = tonumber(textBox.Text:gsub("[^%d.-]", ""))
        sliderFunc:Set(num and math.clamp(num, config.Min, config.Max) or config.Min)
    end)

    sliderFunc:Set(config.Default)
    elementsTable[configKey] = sliderFunc
    return sliderFunc
end

function Elements:CreateInput(parent, config, countItem, updateSectionSize, elementsTable)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Content = config.Content or ""
    config.Callback = config.Callback or function() end
    config.Default = config.Default or ""

    local configKey = "Input_" .. config.Title
    if ConfigData[configKey] ~= nil then
        config.Default = ConfigData[configKey]
    end

    local inputFunc = { Value = config.Default }

    -- Main frame
    local input = Instance.new("Frame")
    input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundTransparency = DEFAULT_TRANSPARENCY
    input.BorderSizePixel = 0
    input.LayoutOrder = countItem
    input.Size = UDim2.new(1, 0, 0, 46)
    input.Name = "Input"
    input.Parent = parent
    
    createUICorner(input)

    -- Title
    local title = createTextLabel(input, {
        Font = Enum.Font.GothamBold,
        Text = config.Title,
        Color = TITLE_COLOR,
        Size = 13,
        XAlign = Enum.TextXAlignment.Left,
        YAlign = Enum.TextYAlignment.Top,
        Position = UDim2.new(0, 10, 0, 10),
        Size2 = UDim2.new(1, -180, 0, 13)
    })
    title.Name = "InputTitle"

    -- Content
    local content = createTextLabel(input, {
        Font = Enum.Font.GothamBold,
        Text = config.Content,
        Color = TEXT_COLOR,
        Size = 12,
        TextTransparency = 0.6,
        XAlign = Enum.TextXAlignment.Left,
        YAlign = Enum.TextYAlignment.Bottom,
        Position = UDim2.new(0, 10, 0, 25),
        Size2 = UDim2.new(1, -180, 0, 12)
    })
    content.Name = "InputContent"
    content.TextWrapped = true

    -- Input frame
    local inputFrame = Instance.new("Frame")
    inputFrame.AnchorPoint = Vector2.new(1, 0.5)
    inputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    inputFrame.BackgroundTransparency = INPUT_TRANSPARENCY
    inputFrame.BorderSizePixel = 0
    inputFrame.ClipsDescendants = true
    inputFrame.Position = UDim2.new(1, -7, 0.5, 0)
    inputFrame.Size = UDim2.new(0, 148, 0, 30)
    inputFrame.Name = "InputFrame"
    inputFrame.Parent = input
    
    createUICorner(inputFrame, SMALL_CORNER)

    -- Text box
    local textBox = Instance.new("TextBox")
    textBox.Font = Enum.Font.GothamBold
    textBox.PlaceholderColor3 = PLACEHOLDER_COLOR
    textBox.PlaceholderText = "Input Here"
    textBox.Text = config.Default
    textBox.TextColor3 = TEXT_COLOR
    textBox.TextSize = 12
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.AnchorPoint = Vector2.new(0, 0.5)
    textBox.BackgroundTransparency = 1
    textBox.BorderSizePixel = 0
    textBox.Position = UDim2.new(0, 5, 0.5, 0)
    textBox.Size = UDim2.new(1, -10, 1, -8)
    textBox.Name = "InputTextBox"
    textBox.Parent = inputFrame

    -- Dynamic sizing
    local function updateSize()
        content.Size = UDim2.new(1, -180, 0, content.TextBounds.Y + 2)
        input.Size = UDim2.new(1, 0, 0, content.AbsoluteSize.Y + 33)
        if updateSectionSize then updateSectionSize() end
    end

    content:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
    updateSize()

    -- Input functionality
    function inputFunc:Set(value)
        textBox.Text = tostring(value)
        inputFunc.Value = value
        pcall(config.Callback, value)
        ConfigData[configKey] = value
        SaveConfig()
    end

    textBox.FocusLost:Connect(function()
        inputFunc:Set(textBox.Text)
    end)

    elementsTable[configKey] = inputFunc
    return inputFunc
end

function Elements:CreateDropdown(parent, config, countItem, countDropdown, dropdownFolder, moreBlur, dropdownSelect, dropPageLayout, elementsTable)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Content = config.Content or ""
    config.Multi = config.Multi or false
    config.Options = config.Options or {}
    config.Default = config.Default or (config.Multi and {} or nil)
    config.Callback = config.Callback or function() end

    local configKey = "Dropdown_" .. config.Title
    if ConfigData[configKey] ~= nil then
        config.Default = ConfigData[configKey]
    end

    local dropdownFunc = { Value = config.Default, Options = config.Options }

    -- Main frame
    local dropdown = Instance.new("Frame")
    dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.BackgroundTransparency = DEFAULT_TRANSPARENCY
    dropdown.BorderSizePixel = 0
    dropdown.LayoutOrder = countItem
    dropdown.Size = UDim2.new(1, 0, 0, 46)
    dropdown.Name = "Dropdown"
    dropdown.Parent = parent
    
    createUICorner(dropdown)

    -- Dropdown button
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Text = ""
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.Name = "ToggleButton"
    dropdownButton.Parent = dropdown

    -- Title
    local title = createTextLabel(dropdown, {
        Font = Enum.Font.GothamBold,
        Text = config.Title,
        Color = TITLE_COLOR,
        Size = 13,
        XAlign = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 10, 0, 10),
        Size2 = UDim2.new(1, -180, 0, 13)
    })
    title.Name = "DropdownTitle"

    -- Content
    local content = createTextLabel(dropdown, {
        Font = Enum.Font.GothamBold,
        Text = config.Content,
        Color = TEXT_COLOR,
        Size = 12,
        TextTransparency = 0.6,
        XAlign = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 10, 0, 25),
        Size2 = UDim2.new(1, -180, 0, 12)
    })
    content.Name = "DropdownContent"
    content.TextWrapped = true

    -- Selection frame
    local selectFrame = Instance.new("Frame")
    selectFrame.AnchorPoint = Vector2.new(1, 0.5)
    selectFrame.BackgroundTransparency = INPUT_TRANSPARENCY
    selectFrame.Position = UDim2.new(1, -7, 0.5, 0)
    selectFrame.Size = UDim2.new(0, 148, 0, 30)
    selectFrame.Name = "SelectOptionsFrame"
    selectFrame.LayoutOrder = countDropdown
    selectFrame.Parent = dropdown
    
    createUICorner(selectFrame, SMALL_CORNER)

    local optionText = createTextLabel(selectFrame, {
        Font = Enum.Font.GothamBold,
        Text = config.Multi and "Select Options" or "Select Option",
        Color = TEXT_COLOR,
        Size = 12,
        TextTransparency = 0.6,
        XAlign = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 5, 0.5, 0),
        Size2 = UDim2.new(1, -30, 1, -8)
    })
    optionText.Name = "OptionSelecting"

    local optionImg = Instance.new("ImageLabel")
    optionImg.Image = "rbxassetid://16851841101"
    optionImg.ImageColor3 = TITLE_COLOR
    optionImg.AnchorPoint = Vector2.new(1, 0.5)
    optionImg.BackgroundTransparency = 1
    optionImg.Position = UDim2.new(1, 0, 0.5, 0)
    optionImg.Size = UDim2.new(0, 25, 0, 25)
    optionImg.Name = "OptionImg"
    optionImg.Parent = selectFrame

    -- Dropdown container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = dropdownFolder

    -- Search box
    local searchBox = Instance.new("TextBox")
    searchBox.PlaceholderText = "Search"
    searchBox.Font = Enum.Font.Gotham
    searchBox.Text = ""
    searchBox.TextSize = 12
    searchBox.TextColor3 = TEXT_COLOR
    searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    searchBox.BackgroundTransparency = 0.9
    searchBox.BorderSizePixel = 0
    searchBox.Size = UDim2.new(1, 0, 0, 25)
    searchBox.Position = UDim2.new(0, 0, 0, 0)
    searchBox.ClearTextOnFocus = false
    searchBox.Name = "SearchBox"
    searchBox.Parent = container

    -- Scroll frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -30)
    scroll.Position = UDim2.new(0, 0, 0, 30)
    scroll.ScrollBarImageTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 0
    scroll.Name = "ScrollSelect"
    scroll.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 3)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scroll

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)

    -- Search functionality
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text:lower()
        for _, option in scroll:GetChildren() do
            if option.Name == "Option" and option:FindFirstChild("OptionText") then
                local text = option.OptionText.Text:lower()
                option.Visible = query == "" or text:find(query, 1, true)
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)

    -- Dropdown open
    dropdownButton.Activated:Connect(function()
        if moreBlur and not moreBlur.Visible then
            moreBlur.Visible = true
            if dropPageLayout then
                dropPageLayout:JumpToIndex(selectFrame.LayoutOrder)
            end
            TweenService:Create(moreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            if dropdownSelect then
                TweenService:Create(dropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, -11, 0.5, 0) }):Play()
            end
        end
    end)

    -- Helper functions
    function dropdownFunc:Clear()
        for _, option in scroll:GetChildren() do
            if option.Name == "Option" then
                option:Destroy()
            end
        end
        dropdownFunc.Value = config.Multi and {} or nil
        dropdownFunc.Options = {}
        optionText.Text = config.Multi and "Select Options" or "Select Option"
    end

    function dropdownFunc:AddOption(option)
        local label, value
        
        if typeof(option) == "table" and option.Label and option.Value ~= nil then
            label = tostring(option.Label)
            value = option.Value
        else
            label = tostring(option)
            value = option
        end

        local optionFrame = Instance.new("Frame")
        optionFrame.BackgroundTransparency = 1
        optionFrame.Size = UDim2.new(1, 0, 0, 30)
        optionFrame.Name = "Option"
        optionFrame.Parent = scroll
        
        createUICorner(optionFrame, UDim.new(0, 3))

        local optionButton = Instance.new("TextButton")
        optionButton.BackgroundTransparency = 1
        optionButton.Size = UDim2.new(1, 0, 1, 0)
        optionButton.Text = ""
        optionButton.Name = "OptionButton"
        optionButton.Parent = optionFrame

        local optionLabel = createTextLabel(optionFrame, {
            Font = Enum.Font.GothamBold,
            Text = label,
            Color = TITLE_COLOR,
            Size = 13,
            XAlign = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 8, 0, 8),
            Size2 = UDim2.new(1, -100, 0, 13)
        })
        optionLabel.Name = "OptionText"

        optionFrame:SetAttribute("RealValue", value)

        local chooseFrame = Instance.new("Frame")
        chooseFrame.AnchorPoint = Vector2.new(0, 0.5)
        chooseFrame.BackgroundColor3 = GuiConfig.Color
        chooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
        chooseFrame.Size = UDim2.new(0, 0, 0, 0)
        chooseFrame.Name = "ChooseFrame"
        chooseFrame.Parent = optionFrame
        
        createUIStroke(chooseFrame, GuiConfig.Color, 0.999, 1.6)
        createUICorner(chooseFrame)

        optionButton.Activated:Connect(function()
            if config.Multi then
                if not table.find(dropdownFunc.Value, value) then
                    table.insert(dropdownFunc.Value, value)
                else
                    for i, v in ipairs(dropdownFunc.Value) do
                        if v == value then
                            table.remove(dropdownFunc.Value, i)
                            break
                        end
                    end
                end
            else
                dropdownFunc.Value = value
            end
            dropdownFunc:Set(dropdownFunc.Value)
        end)
    end

    function dropdownFunc:Set(value)
        if config.Multi then
            dropdownFunc.Value = type(value) == "table" and value or {}
        else
            dropdownFunc.Value = (type(value) == "table" and value[1]) or value
        end

        ConfigData[configKey] = dropdownFunc.Value
        SaveConfig()

        local selectedTexts = {}
        
        for _, option in scroll:GetChildren() do
            if option.Name == "Option" and option:FindFirstChild("OptionText") then
                local optionValue = option:GetAttribute("RealValue")
                local selected = config.Multi and table.find(dropdownFunc.Value, optionValue) or dropdownFunc.Value == optionValue
                
                if selected then
                    TweenService:Create(option.ChooseFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, 1, 0, 12) }):Play()
                    TweenService:Create(option.ChooseFrame.UIStroke, TweenInfo.new(0.2), { Transparency = 0 }):Play()
                    TweenService:Create(option, TweenInfo.new(0.2), { BackgroundTransparency = DEFAULT_TRANSPARENCY }):Play()
                    table.insert(selectedTexts, option.OptionText.Text)
                else
                    TweenService:Create(option.ChooseFrame, TweenInfo.new(0.1), { Size = UDim2.new(0, 0, 0, 0) }):Play()
                    TweenService:Create(option.ChooseFrame.UIStroke, TweenInfo.new(0.1), { Transparency = 0.999 }):Play()
                    TweenService:Create(option, TweenInfo.new(0.1), { BackgroundTransparency = 0.999 }):Play()
                end
            end
        end

        if #selectedTexts == 0 then
            optionText.Text = config.Multi and "Select Options" or "Select Option"
        else
            optionText.Text = table.concat(selectedTexts, ", ")
        end

        if config.Multi then
            pcall(config.Callback, dropdownFunc.Value)
        else
            pcall(config.Callback, tostring(dropdownFunc.Value or ""))
        end
    end

    function dropdownFunc:SetValues(newOptions, selected)
        dropdownFunc:Clear()
        for _, opt in ipairs(newOptions or {}) do
            dropdownFunc:AddOption(opt)
        end
        dropdownFunc.Options = newOptions or {}
        dropdownFunc:Set(selected or (config.Multi and {} or nil))
    end

    -- Initialize
    dropdownFunc:SetValues(dropdownFunc.Options, dropdownFunc.Value)
    elementsTable[configKey] = dropdownFunc
    return dropdownFunc
end

function Elements:CreateDivider(parent, countItem)
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Parent = parent
    divider.AnchorPoint = Vector2.new(0.5, 0)
    divider.Position = UDim2.new(0.5, 0, 0, 0)
    divider.Size = UDim2.new(1, 0, 0, 2)
    divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider.BackgroundTransparency = 0
    divider.BorderSizePixel = 0
    divider.LayoutOrder = countItem

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
        ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    })
    gradient.Parent = divider
    
    createUICorner(divider, UDim.new(0, 2))

    return divider
end

function Elements:CreateSubSection(parent, title, countItem)
    title = title or "Sub Section"

    local subsection = Instance.new("Frame")
    subsection.Name = "SubSection"
    subsection.Parent = parent
    subsection.BackgroundTransparency = 1
    subsection.Size = UDim2.new(1, 0, 0, 22)
    subsection.LayoutOrder = countItem

    local background = Instance.new("Frame")
    background.Parent = subsection
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    background.BackgroundTransparency = DEFAULT_TRANSPARENCY
    background.BorderSizePixel = 0
    createUICorner(background, SMALL_CORNER)

    local label = Instance.new("TextLabel")
    label.Parent = subsection
    label.AnchorPoint = Vector2.new(0, 0.5)
    label.Position = UDim2.new(0, 10, 0.5, 0)
    label.Size = UDim2.new(1, -20, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = "── [ " .. title .. " ] ──"
    label.TextColor3 = TITLE_COLOR
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    return subsection
end

return Elements
