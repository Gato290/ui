-- Elements.lua V0.0.4
-- UI Elements Module for NexaHub
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Elements = {}

-- Private variables (will be set via Initialize)
local GuiConfig, SaveConfig, ConfigData, Icons

-- Constants
local DEFAULT_TRANSPARENCY = 0.935
local DEFAULT_BUTTON_TRANSPARENCY = 0.935
local CORNER_RADIUS = UDim.new(0, 4)
local BUTTON_CORNER_RADIUS = UDim.new(0, 6)
local PADDING = 10
local SMALL_PADDING = 5

-- Utility functions
local function createCorner(instance, radius)
    radius = radius or CORNER_RADIUS
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius
    corner.Parent = instance
    return corner
end

local function createStroke(parent, color, transparency, thickness)
    thickness = thickness or 2
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Thickness = thickness
    stroke.Transparency = transparency or 0.9
    stroke.Parent = parent
    return stroke
end

local function safeCallback(callback, ...)
    if type(callback) == "function" then
        local success, result = pcall(callback, ...)
        if not success then
            warn("Callback error:", result)
        end
        return result
    end
end

local function roundToIncrement(number, increment)
    return math.floor(number / increment + 0.5) * increment
end

-- Element creation functions
function Elements:Initialize(config, saveFunc, configData, icons)
    GuiConfig = config or {}
    SaveConfig = saveFunc or function() end
    ConfigData = configData or {}
    Icons = icons or {}
end

function Elements:CreateParagraph(parent, config, countItem)
    config = config or {}
    config.Title = config.Title or "Title"
    config.Content = config.Content or "Content"
    
    local paragraphFunc = {}
    local iconOffset = PADDING

    -- Main frame
    local paragraph = Instance.new("Frame")
    paragraph.Name = "Paragraph"
    paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    paragraph.BackgroundTransparency = DEFAULT_TRANSPARENCY
    paragraph.BorderSizePixel = 0
    paragraph.LayoutOrder = countItem
    paragraph.Size = UDim2.new(1, 0, 0, 46)
    paragraph.Parent = parent
    
    createCorner(paragraph)

    -- Icon if specified
    if config.Icon then
        local iconImg = Instance.new("ImageLabel")
        iconImg.Name = "ParagraphIcon"
        iconImg.Size = UDim2.new(0, 20, 0, 20)
        iconImg.Position = UDim2.new(0, 8, 0, 12)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = Icons[config.Icon] or config.Icon
        iconImg.Parent = paragraph
        iconOffset = 30
    end

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "ParagraphTitle"
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title
    title.TextColor3 = Color3.fromRGB(231, 231, 231)
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Top
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, iconOffset, 0, PADDING)
    title.Size = UDim2.new(1, -16, 0, 13)
    title.Parent = paragraph

    -- Content
    local content = Instance.new("TextLabel")
    content.Name = "ParagraphContent"
    content.Font = Enum.Font.Gotham
    content.Text = config.Content
    content.TextColor3 = Color3.fromRGB(255, 255, 255)
    content.TextSize = 12
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.BackgroundTransparency = 1
    content.RichText = true
    content.Position = UDim2.new(0, iconOffset, 0, 25)
    content.Size = UDim2.new(1, -16, 0, content.TextBounds.Y)
    content.Parent = paragraph

    -- Button if specified
    local button
    if config.ButtonText then
        button = Instance.new("TextButton")
        button.Name = "ParagraphButton"
        button.Position = UDim2.new(0, PADDING, 0, 42)
        button.Size = UDim2.new(1, -22, 0, 28)
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundTransparency = DEFAULT_BUTTON_TRANSPARENCY
        button.Font = Enum.Font.GothamBold
        button.Text = config.ButtonText
        button.TextSize = 12
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextTransparency = 0.3
        button.Parent = paragraph
        
        createCorner(button, BUTTON_CORNER_RADIUS)
        
        if config.ButtonCallback then
            button.MouseButton1Click:Connect(function()
                safeCallback(config.ButtonCallback)
            end)
        end
    end

    -- Dynamic sizing
    local function updateSize()
        local totalHeight = content.TextBounds.Y + 33
        if button then
            totalHeight = totalHeight + button.Size.Y.Offset + SMALL_PADDING
        end
        paragraph.Size = UDim2.new(1, 0, 0, totalHeight)
    end

    updateSize()
    content:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)

    -- Public methods
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
    panel.Name = "Panel"
    panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    panel.BackgroundTransparency = DEFAULT_TRANSPARENCY
    panel.Size = UDim2.new(1, 0, 0, baseHeight)
    panel.LayoutOrder = countItem
    panel.Parent = parent
    
    createCorner(panel)

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "PanelTitle"
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, PADDING, 0, PADDING)
    title.Size = UDim2.new(1, -20, 0, 13)
    title.Parent = panel

    -- Content
    local content = Instance.new("TextLabel")
    content.Name = "PanelContent"
    content.Font = Enum.Font.Gotham
    content.Text = config.Content
    content.TextSize = 12
    content.TextColor3 = Color3.fromRGB(255, 255, 255)
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.BackgroundTransparency = 1
    content.RichText = true
    content.Position = UDim2.new(0, PADDING, 0, 28)
    content.Size = UDim2.new(1, -20, 0, 14)
    content.Parent = panel

    -- Input box
    local inputBox
    if config.Placeholder then
        local inputFrame = Instance.new("Frame")
        inputFrame.Name = "InputFrame"
        inputFrame.AnchorPoint = Vector2.new(0.5, 0)
        inputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        inputFrame.BackgroundTransparency = 0.95
        inputFrame.Position = UDim2.new(0.5, 0, 0, 48)
        inputFrame.Size = UDim2.new(1, -20, 0, 30)
        inputFrame.Parent = panel
        
        createCorner(inputFrame)

        inputBox = Instance.new("TextBox")
        inputBox.Name = "PanelInput"
        inputBox.Font = Enum.Font.GothamBold
        inputBox.PlaceholderText = config.Placeholder
        inputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        inputBox.Text = config.Default
        inputBox.TextSize = 11
        inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        inputBox.BackgroundTransparency = 1
        inputBox.TextXAlignment = Enum.TextXAlignment.Left
        inputBox.Size = UDim2.new(1, -10, 1, -6)
        inputBox.Position = UDim2.new(0, SMALL_PADDING, 0, 3)
        inputBox.Parent = inputFrame
    end

    local yBtn = config.Placeholder and 88 or 48

    -- Main button
    local mainButton = Instance.new("TextButton")
    mainButton.Name = "MainButton"
    mainButton.Font = Enum.Font.GothamBold
    mainButton.Text = config.ButtonText
    mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainButton.TextSize = 12
    mainButton.TextTransparency = 0.3
    mainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mainButton.BackgroundTransparency = DEFAULT_BUTTON_TRANSPARENCY
    mainButton.Size = config.SubButtonText and UDim2.new(0.5, -12, 0, 30) or UDim2.new(1, -20, 0, 30)
    mainButton.Position = UDim2.new(0, PADDING, 0, yBtn)
    mainButton.Parent = panel
    
    createCorner(mainButton, BUTTON_CORNER_RADIUS)
    
    mainButton.MouseButton1Click:Connect(function()
        safeCallback(config.ButtonCallback, inputBox and inputBox.Text or "")
    end)

    -- Sub button
    if config.SubButtonText then
        local subButton = Instance.new("TextButton")
        subButton.Name = "SubButton"
        subButton.Font = Enum.Font.GothamBold
        subButton.Text = config.SubButtonText
        subButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        subButton.TextSize = 12
        subButton.TextTransparency = 0.3
        subButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        subButton.BackgroundTransparency = DEFAULT_BUTTON_TRANSPARENCY
        subButton.Size = UDim2.new(0.5, -12, 0, 30)
        subButton.Position = UDim2.new(0.5, 2, 0, yBtn)
        subButton.Parent = panel
        
        createCorner(subButton, BUTTON_CORNER_RADIUS)
        
        subButton.MouseButton1Click:Connect(function()
            safeCallback(config.SubButtonCallback, inputBox and inputBox.Text or "")
        end)
    end

    -- Input focus lost
    if inputBox then
        inputBox.FocusLost:Connect(function()
            panelFunc.Value = inputBox.Text
            ConfigData[configKey] = inputBox.Text
            SaveConfig()
        end)
    end

    -- Public methods
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

    local button = Instance.new("Frame")
    button.Name = "Button"
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = DEFAULT_TRANSPARENCY
    button.Size = UDim2.new(1, 0, 0, 40)
    button.LayoutOrder = countItem
    button.Parent = parent
    
    createCorner(button)

    -- Main button
    local mainButton = Instance.new("TextButton")
    mainButton.Name = "MainButton"
    mainButton.Font = Enum.Font.GothamBold
    mainButton.Text = config.Title
    mainButton.TextSize = 12
    mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainButton.TextTransparency = 0.3
    mainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mainButton.BackgroundTransparency = DEFAULT_BUTTON_TRANSPARENCY
    mainButton.Size = config.SubTitle and UDim2.new(0.5, -8, 1, -10) or UDim2.new(1, -12, 1, -10)
    mainButton.Position = UDim2.new(0, 6, 0, SMALL_PADDING)
    mainButton.Parent = button
    
    createCorner(mainButton, BUTTON_CORNER_RADIUS)
    mainButton.MouseButton1Click:Connect(function() safeCallback(config.Callback) end)

    -- Sub button
    if config.SubTitle then
        local subButton = Instance.new("TextButton")
        subButton.Name = "SubButton"
        subButton.Font = Enum.Font.GothamBold
        subButton.Text = config.SubTitle
        subButton.TextSize = 12
        subButton.TextTransparency = 0.3
        subButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        subButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        subButton.BackgroundTransparency = DEFAULT_BUTTON_TRANSPARENCY
        subButton.Size = UDim2.new(0.5, -8, 1, -10)
        subButton.Position = UDim2.new(0.5, 2, 0, SMALL_PADDING)
        subButton.Parent = button
        
        createCorner(subButton, BUTTON_CORNER_RADIUS)
        subButton.MouseButton1Click:Connect(function() safeCallback(config.SubCallback) end)
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
    toggle.Name = "Toggle"
    toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggle.BackgroundTransparency = DEFAULT_TRANSPARENCY
    toggle.BorderSizePixel = 0
    toggle.LayoutOrder = countItem
    toggle.Parent = parent
    
    createCorner(toggle)

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "ToggleTitle"
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(231, 231, 231)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Top
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, PADDING, 0, PADDING)
    title.Size = UDim2.new(1, -100, 0, 13)
    title.Parent = toggle

    -- Second title
    local title2 = Instance.new("TextLabel")
    title2.Name = "ToggleTitle2"
    title2.Font = Enum.Font.GothamBold
    title2.Text = config.Title2
    title2.TextSize = 12
    title2.TextColor3 = Color3.fromRGB(231, 231, 231)
    title2.TextXAlignment = Enum.TextXAlignment.Left
    title2.TextYAlignment = Enum.TextYAlignment.Top
    title2.BackgroundTransparency = 1
    title2.Position = UDim2.new(0, PADDING, 0, 23)
    title2.Size = UDim2.new(1, -100, 0, 12)
    title2.Parent = toggle

    -- Content
    local content = Instance.new("TextLabel")
    content.Name = "ToggleContent"
    content.Font = Enum.Font.GothamBold
    content.Text = config.Content
    content.TextColor3 = Color3.fromRGB(255, 255, 255)
    content.TextSize = 12
    content.TextTransparency = 0.6
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Bottom
    content.BackgroundTransparency = 1
    content.TextWrapped = true
    content.Position = UDim2.new(0, PADDING, 0, config.Title2 ~= "" and 36 or 23)
    content.Size = UDim2.new(1, -100, 0, 12)
    content.Parent = toggle

    -- Toggle button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Text = ""
    toggleButton.BackgroundTransparency = 1
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.Parent = toggle

    -- Toggle frame
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "ToggleFrame"
    toggleFrame.AnchorPoint = Vector2.new(1, 0.5)
    toggleFrame.BackgroundTransparency = 0.92
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Position = UDim2.new(1, -15, 0.5, 0)
    toggleFrame.Size = UDim2.new(0, 30, 0, 15)
    toggleFrame.Parent = toggle
    
    createCorner(toggleFrame)
    local stroke = createStroke(toggleFrame, Color3.fromRGB(255, 255, 255), 0.9)

    -- Toggle circle
    local circle = Instance.new("Frame")
    circle.Name = "ToggleCircle"
    circle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    circle.BorderSizePixel = 0
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Parent = toggleFrame
    
    createCorner(circle, UDim.new(0, 15))

    -- Initial sizing
    local function updateContentSize()
        content.Size = UDim2.new(1, -100, 0, 12 + (12 * math.floor(content.TextBounds.X / math.max(1, content.AbsoluteSize.X))))
        local baseHeight = config.Title2 ~= "" and 47 or 33
        toggle.Size = UDim2.new(1, 0, 0, content.AbsoluteSize.Y + baseHeight)
        if updateSectionSize then updateSectionSize() end
    end
    
    updateContentSize()
    content:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateContentSize)

    -- Toggle functionality
    function toggleFunc:Set(value)
        value = not not value
        toggleFunc.Value = value
        
        safeCallback(config.Callback, value)
        ConfigData[configKey] = value
        SaveConfig()

        if value then
            TweenService:Create(title, TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), { Position = UDim2.new(0, 15, 0, 0) }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), { Color = GuiConfig.Color, Transparency = 0 }):Play()
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), { 
                BackgroundColor3 = GuiConfig.Color, 
                BackgroundTransparency = 0 
            }):Play()
        else
            TweenService:Create(title, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), { Position = UDim2.new(0, 0, 0, 0) }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), { 
                BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
                BackgroundTransparency = 0.92 
            }):Play()
        end
    end

    toggleButton.Activated:Connect(function()
        toggleFunc:Set(not toggleFunc.Value)
    end)

    toggleFunc:Set(toggleFunc.Value)
    
    if elementsTable then
        elementsTable[configKey] = toggleFunc
    end
    
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
    slider.Name = "Slider"
    slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slider.BackgroundTransparency = DEFAULT_TRANSPARENCY
    slider.BorderSizePixel = 0
    slider.LayoutOrder = countItem
    slider.Size = UDim2.new(1, 0, 0, 46)
    slider.Parent = parent
    
    createCorner(slider)

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "SliderTitle"
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title
    title.TextColor3 = Color3.fromRGB(231, 231, 231)
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Top
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, PADDING, 0, PADDING)
    title.Size = UDim2.new(1, -180, 0, 13)
    title.Parent = slider

    -- Content
    local content = Instance.new("TextLabel")
    content.Name = "SliderContent"
    content.Font = Enum.Font.GothamBold
    content.Text = config.Content
    content.TextColor3 = Color3.fromRGB(255, 255, 255)
    content.TextSize = 12
    content.TextTransparency = 0.6
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Bottom
    content.BackgroundTransparency = 1
    content.TextWrapped = true
    content.Position = UDim2.new(0, PADDING, 0, 25)
    content.Size = UDim2.new(1, -180, 0, 12)
    content.Parent = slider

    -- Input box
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "SliderInput"
    inputFrame.AnchorPoint = Vector2.new(0, 0.5)
    inputFrame.BackgroundColor3 = GuiConfig.Color
    inputFrame.BackgroundTransparency = 1
    inputFrame.BorderSizePixel = 0
    inputFrame.Position = UDim2.new(1, -155, 0.5, 0)
    inputFrame.Size = UDim2.new(0, 28, 0, 20)
    inputFrame.Parent = slider
    
    createCorner(inputFrame, UDim.new(0, 2))

    local textBox = Instance.new("TextBox")
    textBox.Name = "ValueBox"
    textBox.Font = Enum.Font.GothamBold
    textBox.Text = tostring(config.Default)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 13
    textBox.TextWrapped = true
    textBox.BackgroundTransparency = 1
    textBox.BorderSizePixel = 0
    textBox.Position = UDim2.new(0, -1, 0, 0)
    textBox.Size = UDim2.new(1, 0, 1, 0)
    textBox.Parent = inputFrame

    -- Slider frame
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "SliderFrame"
    sliderFrame.AnchorPoint = Vector2.new(1, 0.5)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderFrame.BackgroundTransparency = 0.8
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
    sliderFrame.Size = UDim2.new(0, 100, 0, 3)
    sliderFrame.Parent = slider
    
    createCorner(sliderFrame)

    -- Draggable part
    local draggable = Instance.new("Frame")
    draggable.Name = "SliderDraggable"
    draggable.AnchorPoint = Vector2.new(0, 0.5)
    draggable.BackgroundColor3 = GuiConfig.Color
    draggable.BorderSizePixel = 0
    draggable.Position = UDim2.new(0, 0, 0.5, 0)
    draggable.Size = UDim2.new(0.9, 0, 0, 1)
    draggable.Parent = sliderFrame
    
    createCorner(draggable)

    -- Circle handle
    local circle = Instance.new("Frame")
    circle.Name = "SliderCircle"
    circle.AnchorPoint = Vector2.new(1, 0.5)
    circle.BackgroundColor3 = GuiConfig.Color
    circle.BorderSizePixel = 0
    circle.Position = UDim2.new(1, 4, 0.5, 0)
    circle.Size = UDim2.new(0, 8, 0, 8)
    circle.Parent = draggable
    
    createCorner(circle)
    createStroke(circle, GuiConfig.Color, 0)

    -- Dynamic sizing
    local function updateContentSize()
        content.Size = UDim2.new(1, -180, 0, 12 + (12 * math.floor(content.TextBounds.X / math.max(1, content.AbsoluteSize.X))))
        slider.Size = UDim2.new(1, 0, 0, content.AbsoluteSize.Y + 33)
        if updateSectionSize then updateSectionSize() end
    end
    
    updateContentSize()
    content:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateContentSize)

    -- Slider logic
    local dragging = false
    
    local function getValueFromMouse(inputPosition)
        local sizeScale = math.clamp(
            (inputPosition.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X,
            0, 1
        )
        return config.Min + ((config.Max - config.Min) * sizeScale)
    end

    function sliderFunc:Set(value)
        value = math.clamp(roundToIncrement(value, config.Increment), config.Min, config.Max)
        sliderFunc.Value = value
        textBox.Text = tostring(value)
        
        TweenService:Create(
            draggable,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.fromScale((value - config.Min) / (config.Max - config.Min), 1) }
        ):Play()

        safeCallback(config.Callback, value)
        ConfigData[configKey] = value
        SaveConfig()
    end

    -- Mouse events
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            TweenService:Create(circle, TweenInfo.new(0.2), { Size = UDim2.new(0, 14, 0, 14) }):Play()
            sliderFunc:Set(getValueFromMouse(input.Position))
        end
    end)

    sliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            TweenService:Create(circle, TweenInfo.new(0.2), { Size = UDim2.new(0, 8, 0, 8) }):Play()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
            sliderFunc:Set(getValueFromMouse(input.Position))
        end
    end)

    -- Text input
    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        local num = tonumber(textBox.Text:gsub("[^%d.-]", ""))
        sliderFunc:Set(num or config.Min)
    end)

    sliderFunc:Set(config.Default)
    
    if elementsTable then
        elementsTable[configKey] = sliderFunc
    end
    
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
    input.Name = "Input"
    input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundTransparency = DEFAULT_TRANSPARENCY
    input.BorderSizePixel = 0
    input.LayoutOrder = countItem
    input.Size = UDim2.new(1, 0, 0, 46)
    input.Parent = parent
    
    createCorner(input)

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "InputTitle"
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title
    title.TextColor3 = Color3.fromRGB(231, 231, 231)
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Top
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, PADDING, 0, PADDING)
    title.Size = UDim2.new(1, -180, 0, 13)
    title.Parent = input

    -- Content
    local content = Instance.new("TextLabel")
    content.Name = "InputContent"
    content.Font = Enum.Font.GothamBold
    content.Text = config.Content
    content.TextColor3 = Color3.fromRGB(255, 255, 255)
    content.TextSize = 12
    content.TextTransparency = 0.6
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Bottom
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, PADDING, 0, 25)
    content.Size = UDim2.new(1, -180, 0, 12)
    content.Parent = input

    -- Input frame
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.AnchorPoint = Vector2.new(1, 0.5)
    inputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    inputFrame.BackgroundTransparency = 0.95
    inputFrame.BorderSizePixel = 0
    inputFrame.ClipsDescendants = true
    inputFrame.Position = UDim2.new(1, -7, 0.5, 0)
    inputFrame.Size = UDim2.new(0, 148, 0, 30)
    inputFrame.Parent = input
    
    createCorner(inputFrame)

    local textBox = Instance.new("TextBox")
    textBox.Name = "InputTextBox"
    textBox.Font = Enum.Font.GothamBold
    textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    textBox.PlaceholderText = "Input Here"
    textBox.Text = config.Default
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 12
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.AnchorPoint = Vector2.new(0, 0.5)
    textBox.BackgroundTransparency = 1
    textBox.BorderSizePixel = 0
    textBox.Position = UDim2.new(0, SMALL_PADDING, 0.5, 0)
    textBox.Size = UDim2.new(1, -10, 1, -8)
    textBox.Parent = inputFrame

    -- Dynamic sizing
    local function updateContentSize()
        content.Size = UDim2.new(1, -180, 0, 12 + (12 * math.floor(content.TextBounds.X / math.max(1, content.AbsoluteSize.X))))
        input.Size = UDim2.new(1, 0, 0, content.AbsoluteSize.Y + 33)
        if updateSectionSize then updateSectionSize() end
    end
    
    updateContentSize()
    content:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateContentSize)

    -- Input logic
    function inputFunc:Set(value)
        textBox.Text = tostring(value)
        inputFunc.Value = value
        safeCallback(config.Callback, value)
        ConfigData[configKey] = value
        SaveConfig()
    end

    textBox.FocusLost:Connect(function()
        inputFunc:Set(textBox.Text)
    end)

    if elementsTable then
        elementsTable[configKey] = inputFunc
    end
    
    return inputFunc
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

    createCorner(divider, UDim.new(0, 2))

    return divider
end

function Elements:CreateSubSection(parent, title, countItem)
    title = title or "Sub Section"

    local subSection = Instance.new("Frame")
    subSection.Name = "SubSection"
    subSection.Parent = parent
    subSection.BackgroundTransparency = 1
    subSection.Size = UDim2.new(1, 0, 0, 22)
    subSection.LayoutOrder = countItem

    local background = Instance.new("Frame")
    background.Parent = subSection
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    background.BackgroundTransparency = DEFAULT_TRANSPARENCY
    background.BorderSizePixel = 0
    createCorner(background, UDim.new(0, 6))

    local label = Instance.new("TextLabel")
    label.Parent = subSection
    label.AnchorPoint = Vector2.new(0, 0.5)
    label.Position = UDim2.new(0, PADDING, 0.5, 0)
    label.Size = UDim2.new(1, -20, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = "── [ " .. title .. " ] ──"
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    return subSection
end

return Elements
