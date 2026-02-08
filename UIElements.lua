-- ChloeX UI Library - UI Elements Module
-- Version: V0.0.3
-- Part 3 of 3

local UIElements = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Constants
local ANIMATION_DURATION = 0.2
local DEFAULT_COLOR = Color3.fromRGB(255, 0, 255)

-- Element Manager
local ElementManager = {
    ActiveElements = {}
}

function ElementManager:RegisterElement(element, id)
    local elementId = id or HttpService:GenerateGUID(false)
    self.ActiveElements[elementId] = {
        Element = element,
        Created = tick()
    }
    return elementId
end

function ElementManager:Cleanup()
    local now = tick()
    for id, data in pairs(self.ActiveElements) do
        if now - data.Created > 3600 then -- 1 hour cleanup
            if data.Element and data.Element.Parent then
                data.Element:Destroy()
            end
            self.ActiveElements[id] = nil
        end
    end
end

-- Color utility
local function GetBrightness(color)
    return (0.299 * color.R + 0.587 * color.G + 0.114 * color.B)
end

local function AdjustColorForContrast(color)
    local brightness = GetBrightness(color)
    if brightness < 0.3 then
        return Color3.new(color.R * 1.5, color.G * 1.5, color.B * 1.5)
    elseif brightness > 0.7 then
        return Color3.new(color.R * 0.7, color.G * 0.7, color.B * 0.7)
    end
    return color
end

-- Enhanced ripple effect
local function CreateRippleEffect(parent, position, color)
    local ripple = Instance.new("Frame")
    ripple.Name = "RippleEffect"
    ripple.BackgroundColor3 = color or Color3.fromRGB(200, 200, 200)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.ZIndex = 100
    ripple.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    -- Position at click
    local parentPos = parent.AbsolutePosition
    local parentSize = parent.AbsoluteSize
    local relativeX = (position.X - parentPos.X) / parentSize.X
    local relativeY = (position.Y - parentPos.Y) / parentSize.Y
    
    ripple.Position = UDim2.new(relativeX, -10, relativeY, -10)
    ripple.Size = UDim2.new(0, 20, 0, 20)
    
    -- Expand animation
    local maxSize = math.max(parentSize.X, parentSize.Y) * 2.5
    local expand = TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        Position = UDim2.new(0.5, -maxSize/2, 0.5, -maxSize/2),
        BackgroundTransparency = 1
    })
    
    expand:Play()
    expand.Completed:Connect(function()
        ripple:Destroy()
    end)
    
    return ripple
end

-- Paragraph Element
function UIElements:CreateParagraph(section, config, themeColor, elements, configManager)
    config = config or {}
    config.Title = config.Title or "Information"
    config.Content = config.Content or "No content provided"
    config.Icon = config.Icon
    config.ButtonText = config.ButtonText
    config.ButtonCallback = config.ButtonCallback
    config.ButtonColor = config.ButtonColor or themeColor
    
    local paragraphId = ElementManager:RegisterElement(nil, "Paragraph_" .. config.Title)
    
    local container = Instance.new("Frame")
    container.Name = "ParagraphContainer"
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    container.BackgroundTransparency = 0.1
    container.Size = UDim2.new(1, 0, 0, 50)
    container.Parent = section
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 47, 1, 47)
    shadow.Position = UDim2.new(-0.1, -23.5, -0.1, -23.5)
    shadow.ZIndex = -1
    shadow.Parent = container
    
    local iconOffset = 10
    if config.Icon then
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 24, 0, 24)
        icon.Position = UDim2.new(0, 10, 0, 13)
        icon.BackgroundTransparency = 1
        icon.Image = config.Icon
        icon.ImageColor3 = themeColor
        icon.Parent = container
        iconOffset = 40
    end
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, iconOffset, 0, 10)
    title.Size = UDim2.new(1, -iconOffset - 10, 0, 18)
    title.Parent = container
    
    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.Font = Enum.Font.Gotham
    content.Text = config.Content
    content.TextColor3 = Color3.fromRGB(180, 180, 180)
    content.TextSize = 12
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.BackgroundTransparency = 1
    content.TextWrapped = true
    content.RichText = true
    content.Position = UDim2.new(0, iconOffset, 0, 30)
    content.Size = UDim2.new(1, -iconOffset - 10, 1, -40)
    content.Parent = container
    
    local button
    if config.ButtonText then
        button = Instance.new("TextButton")
        button.Name = "ActionButton"
        button.Font = Enum.Font.GothamBold
        button.Text = config.ButtonText
        button.TextSize = 12
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = config.ButtonColor
        button.BackgroundTransparency = 0.2
        button.Size = UDim2.new(0.4, 0, 0, 28)
        button.Position = UDim2.new(0.6, 10, 1, -35)
        button.Parent = container
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        -- Hover effects
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.1
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.2
            }):Play()
        end)
        
        button.Activated:Connect(function()
            CreateRippleEffect(button, Vector2.new(button.AbsoluteSize.X/2, button.AbsoluteSize.Y/2), Color3.fromRGB(255, 255, 255))
            if config.ButtonCallback then
                config.ButtonCallback()
            end
        end)
    end
    
    -- Auto-size functionality
    local function UpdateSize()
        local contentHeight = content.TextBounds.Y
        local totalHeight = math.max(50, contentHeight + 40)
        
        if button then
            totalHeight = math.max(totalHeight, 80)
        end
        
        TweenService:Create(container, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 0, 0, totalHeight)
        }):Play()
    end
    
    content:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)
    UpdateSize()
    
    -- Paragraph API
    local paragraphAPI = {}
    
    function paragraphAPI:UpdateContent(newContent)
        content.Text = newContent or config.Content
        return self
    end
    
    function paragraphAPI:UpdateTitle(newTitle)
        title.Text = newTitle or config.Title
        return self
    end
    
    function paragraphAPI:SetVisible(visible)
        container.Visible = visible
        return self
    end
    
    function paragraphAPI:Destroy()
        container:Destroy()
        ElementManager.ActiveElements[paragraphId] = nil
    end
    
    ElementManager.ActiveElements[paragraphId].Element = paragraphAPI
    
    return paragraphAPI
end

-- Panel Element (Form-like)
function UIElements:CreatePanel(section, config, themeColor, elements, configManager)
    config = config or {}
    config.Title = config.Title or "Panel"
    config.Description = config.Description or ""
    config.InputPlaceholder = config.InputPlaceholder
    config.InputDefault = config.InputDefault or ""
    config.PrimaryButton = config.PrimaryButton or "Confirm"
    config.PrimaryCallback = config.PrimaryCallback or function(value) print("Primary:", value) end
    config.SecondaryButton = config.SecondaryButton
    config.SecondaryCallback = config.SecondaryCallback or function(value) print("Secondary:", value) end
    
    local panelId = ElementManager:RegisterElement(nil, "Panel_" .. config.Title)
    
    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    panel.BackgroundTransparency = 0.1
    panel.Size = UDim2.new(1, 0, 0, 120)
    panel.Parent = section
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = panel
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 47, 1, 47)
    shadow.Position = UDim2.new(-0.1, -23.5, -0.1, -23.5)
    shadow.ZIndex = -1
    shadow.Parent = panel
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title
    title.TextColor3 = themeColor
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 10)
    title.Size = UDim2.new(1, -30, 0, 20)
    title.Parent = panel
    
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Font = Enum.Font.Gotham
    description.Text = config.Description
    description.TextColor3 = Color3.fromRGB(180, 180, 180)
    description.TextSize = 12
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.BackgroundTransparency = 1
    description.TextWrapped = true
    description.Position = UDim2.new(0, 15, 0, 35)
    description.Size = UDim2.new(1, -30, 0, 0)
    description.Parent = panel
    
    local inputField
    if config.InputPlaceholder then
        local inputContainer = Instance.new("Frame")
        inputContainer.Name = "InputContainer"
        inputContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        inputContainer.BackgroundTransparency = 0.1
        inputContainer.Size = UDim2.new(1, -30, 0, 36)
        inputContainer.Position = UDim2.new(0, 15, 0, 60)
        inputContainer.Parent = panel
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = inputContainer
        
        inputField = Instance.new("TextBox")
        inputField.Name = "Input"
        inputField.Font = Enum.Font.Gotham
        inputField.PlaceholderText = config.InputPlaceholder
        inputField.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        inputField.Text = config.InputDefault
        inputField.TextColor3 = Color3.fromRGB(255, 255, 255)
        inputField.TextSize = 12
        inputField.BackgroundTransparency = 1
        inputField.Size = UDim2.new(1, -20, 1, 0)
        inputField.Position = UDim2.new(0, 10, 0, 0)
        inputField.Parent = inputContainer
    end
    
    local buttonY = 105
    if config.InputPlaceholder then
        buttonY = 105
    else
        buttonY = 70
        panel.Size = UDim2.new(1, 0, 0, 100)
    end
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Size = UDim2.new(1, -30, 0, 32)
    buttonContainer.Position = UDim2.new(0, 15, 0, buttonY)
    buttonContainer.Parent = panel
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonLayout.Padding = UDim.new(0, 10)
    buttonLayout.Parent = buttonContainer
    
    local primaryButton = Instance.new("TextButton")
    primaryButton.Name = "PrimaryButton"
    primaryButton.Font = Enum.Font.GothamBold
    primaryButton.Text = config.PrimaryButton
    primaryButton.TextSize = 12
    primaryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    primaryButton.BackgroundColor3 = themeColor
    primaryButton.BackgroundTransparency = 0.2
    primaryButton.Size = UDim2.new(0, 100, 1, 0)
    primaryButton.Parent = buttonContainer
    
    local primaryCorner = Instance.new("UICorner")
    primaryCorner.CornerRadius = UDim.new(0, 6)
    primaryCorner.Parent = primaryButton
    
    primaryButton.MouseEnter:Connect(function()
        TweenService:Create(primaryButton, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.1
        }):Play()
    end)
    
    primaryButton.MouseLeave:Connect(function()
        TweenService:Create(primaryButton, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.2
        }):Play()
    end)
    
    primaryButton.Activated:Connect(function()
        CreateRippleEffect(primaryButton, Vector2.new(primaryButton.AbsoluteSize.X/2, primaryButton.AbsoluteSize.Y/2))
        local value = inputField and inputField.Text or ""
        config.PrimaryCallback(value)
    end)
    
    local secondaryButton
    if config.SecondaryButton then
        secondaryButton = Instance.new("TextButton")
        secondaryButton.Name = "SecondaryButton"
        secondaryButton.Font = Enum.Font.GothamBold
        secondaryButton.Text = config.SecondaryButton
        secondaryButton.TextSize = 12
        secondaryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        secondaryButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        secondaryButton.BackgroundTransparency = 0.2
        secondaryButton.Size = UDim2.new(0, 100, 1, 0)
        secondaryButton.Parent = buttonContainer
        
        local secondaryCorner = Instance.new("UICorner")
        secondaryCorner.CornerRadius = UDim.new(0, 6)
        secondaryCorner.Parent = secondaryButton
        
        secondaryButton.MouseEnter:Connect(function()
            TweenService:Create(secondaryButton, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.1
            }):Play()
        end)
        
        secondaryButton.MouseLeave:Connect(function()
            TweenService:Create(secondaryButton, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.2
            }):Play()
        end)
        
        secondaryButton.Activated:Connect(function()
            CreateRippleEffect(secondaryButton, Vector2.new(secondaryButton.AbsoluteSize.X/2, secondaryButton.AbsoluteSize.Y/2))
            local value = inputField and inputField.Text or ""
            config.SecondaryCallback(value)
        end)
    end
    
    -- Panel API
    local panelAPI = {}
    
    function panelAPI:GetInputValue()
        return inputField and inputField.Text or ""
    end
    
    function panelAPI:SetInputValue(value)
        if inputField then
            inputField.Text = value
        end
        return self
    end
    
    function panelAPI:UpdateTitle(newTitle)
        title.Text = newTitle or config.Title
        return self
    end
    
    function panelAPI:UpdateDescription(newDesc)
        description.Text = newDesc or config.Description
        return self
    end
    
    function panelAPI:Destroy()
        panel:Destroy()
        ElementManager.ActiveElements[panelId] = nil
    end
    
    ElementManager.ActiveElements[panelId].Element = panelAPI
    
    return panelAPI
end

-- Toggle Element
function UIElements:CreateToggle(section, config, themeColor, elements, configManager)
    config = config or {}
    config.Title = config.Title or "Toggle"
    config.Description = config.Description or ""
    config.Default = config.Default or false
    config.Callback = config.Callback or function(value) print("Toggle:", value) end
    
    local configKey = "Toggle_" .. config.Title
    local savedValue = configManager:Get(configKey, config.Default)
    
    local toggleId = ElementManager:RegisterElement(nil, configKey)
    
    local toggle = Instance.new("Frame")
    toggle.Name = "Toggle"
    toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    toggle.BackgroundTransparency = 0.1
    toggle.Size = UDim2.new(1, 0, 0, 50)
    toggle.Parent = section
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = toggle
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 47, 1, 47)
    shadow.Position = UDim2.new(-0.1, -23.5, -0.1, -23.5)
    shadow.ZIndex = -1
    shadow.Parent = toggle
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 10)
    title.Size = UDim2.new(1, -80, 0, 18)
    title.Parent = toggle
    
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Font = Enum.Font.Gotham
    description.Text = config.Description
    description.TextColor3 = Color3.fromRGB(180, 180, 180)
    description.TextSize = 12
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.BackgroundTransparency = 1
    description.Position = UDim2.new(0, 15, 0, 30)
    description.Size = UDim2.new(1, -80, 1, -35)
    description.Parent = toggle
    
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = "ToggleContainer"
    toggleContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    toggleContainer.BackgroundTransparency = 0.1
    toggleContainer.Size = UDim2.new(0, 50, 0, 24)
    toggleContainer.Position = UDim2.new(1, -70, 0.5, -12)
    toggleContainer.Parent = toggle
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(1, 0)
    containerCorner.Parent = toggleContainer
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "ToggleKnob"
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.BackgroundTransparency = 0.1
    toggleKnob.Size = UDim2.new(0, 18, 0, 18)
    toggleKnob.Position = UDim2.new(0, 3, 0.5, -9)
    toggleKnob.Parent = toggleContainer
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = toggleKnob
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.BackgroundTransparency = 1
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.Text = ""
    toggleButton.Parent = toggle
    
    local isToggled = savedValue
    
    local function UpdateToggleState()
        if isToggled then
            TweenService:Create(toggleContainer, TweenInfo.new(0.2), {
                BackgroundColor3 = themeColor
            }):Play()
            
            TweenService:Create(toggleKnob, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -21, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            
            TweenService:Create(title, TweenInfo.new(0.2), {
                TextColor3 = themeColor
            }):Play()
        else
            TweenService:Create(toggleContainer, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            }):Play()
            
            TweenService:Create(toggleKnob, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
            
            TweenService:Create(title, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end
    
    toggleButton.Activated:Connect(function()
        CreateRippleEffect(toggleButton, Vector2.new(toggleButton.AbsoluteSize.X/2, toggleButton.AbsoluteSize.Y/2))
        isToggled = not isToggled
        UpdateToggleState()
        config.Callback(isToggled)
        configManager:Set(configKey, isToggled)
    end)
    
    UpdateToggleState()
    
    -- Toggle API
    local toggleAPI = {
        Value = isToggled
    }
    
    function toggleAPI:Set(value)
        isToggled = value
        UpdateToggleState()
        config.Callback(isToggled)
        configManager:Set(configKey, isToggled)
        return self
    end
    
    function toggleAPI:Toggle()
        self:Set(not isToggled)
        return self
    end
    
    function toggleAPI:Destroy()
        toggle:Destroy()
        ElementManager.ActiveElements[toggleId] = nil
    end
    
    ElementManager.ActiveElements[toggleId].Element = toggleAPI
    
    return toggleAPI
end

-- Slider Element
function UIElements:CreateSlider(section, config, themeColor, elements, configManager)
    config = config or {}
    config.Title = config.Title or "Slider"
    config.Description = config.Description or ""
    config.Min = config.Min or 0
    config.Max = config.Max or 100
    config.Default = config.Default or 50
    config.Increment = config.Increment or 1
    config.Callback = config.Callback or function(value) print("Slider:", value) end
    
    local configKey = "Slider_" .. config.Title
    local savedValue = configManager:Get(configKey, config.Default)
    
    local sliderId = ElementManager:RegisterElement(nil, configKey)
    
    local slider = Instance.new("Frame")
    slider.Name = "Slider"
    slider.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    slider.BackgroundTransparency = 0.1
    slider.Size = UDim2.new(1, 0, 0, 70)
    slider.Parent = section
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = slider
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 47, 1, 47)
    shadow.Position = UDim2.new(-0.1, -23.5, -0.1, -23.5)
    shadow.ZIndex = -1
    shadow.Parent = slider
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 10)
    title.Size = UDim2.new(1, -30, 0, 18)
    title.Parent = slider
    
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Font = Enum.Font.Gotham
    description.Text = config.Description
    description.TextColor3 = Color3.fromRGB(180, 180, 180)
    description.TextSize = 12
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.BackgroundTransparency = 1
    description.Position = UDim2.new(0, 15, 0, 32)
    description.Size = UDim2.new(1, -30, 0, 16)
    description.Parent = slider
    
    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Name = "ValueDisplay"
    valueDisplay.Font = Enum.Font.GothamBold
    valueDisplay.Text = tostring(savedValue)
    valueDisplay.TextColor3 = themeColor
    valueDisplay.TextSize = 14
    valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Position = UDim2.new(1, -60, 0, 10)
    valueDisplay.Size = UDim2.new(0, 45, 0, 18)
    valueDisplay.Parent = slider
    
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    track.BackgroundTransparency = 0.1
    track.Size = UDim2.new(1, -30, 0, 6)
    track.Position = UDim2.new(0, 15, 1, -20)
    track.Parent = slider
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.BackgroundColor3 = themeColor
    fill.BackgroundTransparency = 0.2
    fill.Size = UDim2.new((savedValue - config.Min) / (config.Max - config.Min), 0, 1, 0)
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local handle = Instance.new("Frame")
    handle.Name = "Handle"
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BackgroundTransparency = 0.1
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new((savedValue - config.Min) / (config.Max - config.Min), -8, 0.5, -8)
    handle.Parent = track
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle
    
    local handleShadow = Instance.new("ImageLabel")
    handleShadow.Name = "Shadow"
    handleShadow.Image = "rbxassetid://6015897843"
    handleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    handleShadow.ImageTransparency = 0.5
    handleShadow.ScaleType = Enum.ScaleType.Slice
    handleShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    handleShadow.BackgroundTransparency = 1
    handleShadow.Size = UDim2.new(1, 47, 1, 47)
    handleShadow.Position = UDim2.new(-0.1, -23.5, -0.1, -23.5)
    handleShadow.ZIndex = -1
    handleShadow.Parent = handle
    
    local isDragging = false
    
    local function RoundValue(value)
        return math.floor((value - config.Min) / config.Increment + 0.5) * config.Increment + config.Min
    end
    
    local function UpdateSlider(value)
        value = math.clamp(value, config.Min, config.Max)
        value = RoundValue(value)
        
        local percent = (value - config.Min) / (config.Max - config.Min)
        
        TweenService:Create(fill, TweenInfo.new(0.1), {
            Size = UDim2.new(percent, 0, 1, 0)
        }):Play()
        
        TweenService:Create(handle, TweenInfo.new(0.1), {
            Position = UDim2.new(percent, -8, 0.5, -8)
        }):Play()
        
        valueDisplay.Text = tostring(value)
        config.Callback(value)
        configManager:Set(configKey, value)
    end
    
    local function OnInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            
            local connection
            connection = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or 
                   moveInput.UserInputType == Enum.UserInputType.Touch then
                    local relativeX = (moveInput.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                    relativeX = math.clamp(relativeX, 0, 1)
                    local value = config.Min + (config.Max - config.Min) * relativeX
                    UpdateSlider(value)
                end
            end)
            
            local releaseConnection
            releaseConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                    connection:Disconnect()
                    releaseConnection:Disconnect()
                end
            end)
        end
    end
    
    track.InputBegan:Connect(OnInput)
    handle.InputBegan:Connect(OnInput)
    
    -- Slider API
    local sliderAPI = {
        Value = savedValue
    }
    
    function sliderAPI:Set(value)
        UpdateSlider(value)
        self.Value = value
        return self
    end
    
    function sliderAPI:Destroy()
        slider:Destroy()
        ElementManager.ActiveElements[sliderId] = nil
    end
    
    ElementManager.ActiveElements[sliderId].Element = sliderAPI
    
    return sliderAPI
end

-- Input Element
function UIElements:CreateInput(section, config, themeColor, elements, configManager)
    config = config or {}
    config.Title = config.Title or "Input"
    config.Description = config.Description or ""
    config.Placeholder = config.Placeholder or "Enter text..."
    config.Default = config.Default or ""
    config.Callback = config.Callback or function(value) print("Input:", value) end
    
    local configKey = "Input_" .. config.Title
    local savedValue = configManager:Get(configKey, config.Default)
    
    local inputId = ElementManager:RegisterElement(nil, configKey)
    
    local inputContainer = Instance.new("Frame")
    inputContainer.Name = "InputContainer"
    inputContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    inputContainer.BackgroundTransparency = 0.1
    inputContainer.Size = UDim2.new(1, 0, 0, 70)
    inputContainer.Parent = section
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = inputContainer
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 47, 1, 47)
    shadow.Position = UDim2.new(-0.1, -23.5, -0.1, -23.5)
    shadow.ZIndex = -1
    shadow.Parent = inputContainer
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 10)
    title.Size = UDim2.new(1, -30, 0, 18)
    title.Parent = inputContainer
    
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Font = Enum.Font.Gotham
    description.Text = config.Description
    description.TextColor3 = Color3.fromRGB(180, 180, 180)
    description.TextSize = 12
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.BackgroundTransparency = 1
    description.Position = UDim2.new(0, 15, 0, 32)
    description.Size = UDim2.new(1, -30, 0, 16)
    description.Parent = inputContainer
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    inputFrame.BackgroundTransparency = 0.1
    inputFrame.Size = UDim2.new(1, -30, 0, 32)
    inputFrame.Position = UDim2.new(0, 15, 1, -40)
    inputFrame.Parent = inputContainer
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.Font = Enum.Font.Gotham
    textBox.PlaceholderText = config.Placeholder
    textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    textBox.Text = savedValue
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 12
    textBox.BackgroundTransparency = 1
    textBox.Size = UDim2.new(1, -20, 1, 0)
    textBox.Position = UDim2.new(0, 10, 0, 0)
    textBox.Parent = inputFrame
    
    -- Focus effects
    textBox.Focused:Connect(function()
        TweenService:Create(inputFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = themeColor,
            BackgroundTransparency = 0.3
        }):Play()
    end)
    
    textBox.FocusLost:Connect(function()
        TweenService:Create(inputFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 45),
            BackgroundTransparency = 0.1
        }):Play()
        
        config.Callback(textBox.Text)
        configManager:Set(configKey, textBox.Text)
    end)
    
    -- Input API
    local inputAPI = {
        Value = savedValue
    }
    
    function inputAPI:Set(value)
        textBox.Text = value
        self.Value = value
        config.Callback(value)
        configManager:Set(configKey, value)
        return self
    end
    
    function inputAPI:Clear()
        self:Set("")
        return self
    end
    
    function inputAPI:Destroy()
        inputContainer:Destroy()
        ElementManager.ActiveElements[inputId] = nil
    end
    
    ElementManager.ActiveElements[inputId].Element = inputAPI
    
    return inputAPI
end

-- Divider Element
function UIElements:CreateDivider(section, config, themeColor)
    config = config or {}
    config.Thickness = config.Thickness or 2
    config.Margin = config.Margin or 10
    config.Color = config.Color or themeColor
    
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.BackgroundTransparency = 1
    divider.Size = UDim2.new(1, 0, 0, config.Thickness + config.Margin * 2)
    divider.Parent = section
    
    local line = Instance.new("Frame")
    line.Name = "Line"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Position = UDim2.new(0.5, 0, 0.5, 0)
    line.Size = UDim2.new(1, -20, 0, config.Thickness)
    line.BackgroundColor3 = config.Color
    line.BackgroundTransparency = 0.3
    line.Parent = divider
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = line
    
    -- Gradient effect
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.2, config.Color),
        ColorSequenceKeypoint.new(0.8, config.Color),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    })
    gradient.Transparency = NumberSequence.new(0.7)
    gradient.Parent = line
    
    return divider
end

-- Label Element
function UIElements:CreateLabel(section, config, themeColor)
    config = config or {}
    config.Text = config.Text or "Label"
    config.Color = config.Color or themeColor
    config.Size = config.Size or 14
    config.Bold = config.Bold or false
    config.Alignment = config.Alignment or Enum.TextXAlignment.Left
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Font = config.Bold and Enum.Font.GothamBold or Enum.Font.Gotham
    label.Text = config.Text
    label.TextColor3 = config.Color
    label.TextSize = config.Size
    label.TextXAlignment = config.Alignment
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, config.Size + 10)
    label.Parent = section
    
    return label
end

-- Button Element
function UIElements:CreateButton(section, config, themeColor, elements, configManager)
    config = config or {}
    config.Text = config.Text or "Button"
    config.Color = config.Color or themeColor
    config.Callback = config.Callback or function() end
    config.Icon = config.Icon
    
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Font = Enum.Font.GothamBold
    button.Text = config.Text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.BackgroundColor3 = config.Color
    button.BackgroundTransparency = 0.2
    button.Size = UDim2.new(1, 0, 0, 36)
    button.Parent = section
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 47, 1, 47)
    shadow.Position = UDim2.new(-0.1, -23.5, -0.1, -23.5)
    shadow.ZIndex = -1
    shadow.Parent = button
    
    if config.Icon then
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0, 10, 0.5, -10)
        icon.BackgroundTransparency = 1
        icon.Image = config.Icon
        icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        icon.Parent = button
        
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.PaddingLeft = UDim.new(0, 35)
    end
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.1
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.2
        }):Play()
    end)
    
    button.Activated:Connect(function()
        CreateRippleEffect(button, Vector2.new(button.AbsoluteSize.X/2, button.AbsoluteSize.Y/2))
        config.Callback()
    end)
    
    -- Button API
    local buttonAPI = {}
    
    function buttonAPI:SetText(text)
        button.Text = text
        return self
    end
    
    function buttonAPI:SetColor(color)
        button.BackgroundColor3 = color
        return self
    end
    
    function buttonAPI:SetEnabled(enabled)
        button.Active = enabled
        button.TextTransparency = enabled and 0 or 0.5
        return self
    end
    
    function buttonAPI:Destroy()
        button:Destroy()
    end
    
    return buttonAPI
end

-- Dropdown Element
function UIElements:CreateDropdown(section, config, themeColor, elements, configManager)
    config = config or {}
    config.Title = config.Title or "Dropdown"
    config.Description = config.Description or ""
    config.Options = config.Options or {"Option 1", "Option 2", "Option 3"}
    config.Default = config.Default or config.Options[1]
    config.Callback = config.Callback or function(value) print("Selected:", value) end
    
    local configKey = "Dropdown_" .. config.Title
    local savedValue = configManager:Get(configKey, config.Default)
    
    local dropdownId = ElementManager:RegisterElement(nil, configKey)
    
    local dropdown = Instance.new("Frame")
    dropdown.Name = "Dropdown"
    dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    dropdown.BackgroundTransparency = 0.1
    dropdown.Size = UDim2.new(1, 0, 0, 60)
    dropdown.ClipsDescendants = true
    dropdown.Parent = section
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = dropdown
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 47, 1, 47)
    shadow.Position = UDim2.new(-0.1, -23.5, -0.1, -23.5)
    shadow.ZIndex = -1
    shadow.Parent = dropdown
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 10)
    title.Size = UDim2.new(1, -80, 0, 18)
    title.Parent = dropdown
    
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Font = Enum.Font.Gotham
    description.Text = config.Description
    description.TextColor3 = Color3.fromRGB(180, 180, 180)
    description.TextSize = 12
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.BackgroundTransparency = 1
    description.Position = UDim2.new(0, 15, 0, 32)
    description.Size = UDim2.new(1, -80, 0, 16)
    description.Parent = dropdown
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Name = "Selected"
    selectedLabel.Font = Enum.Font.Gotham
    selectedLabel.Text = savedValue
    selectedLabel.TextColor3 = themeColor
    selectedLabel.TextSize = 12
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Position = UDim2.new(1, -90, 0, 10)
    selectedLabel.Size = UDim2.new(0, 75, 0, 18)
    selectedLabel.Parent = dropdown
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Text = ""
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.Parent = dropdown
    
    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.Image = "rbxassetid://6031091004"
    arrow.ImageColor3 = themeColor
    arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -35, 0.5, -8)
    arrow.Parent = dropdown
    
    local optionsContainer
    local isOpen = false
    
    local function ToggleDropdown()
        isOpen = not isOpen
        
        if isOpen then
            -- Create options container
            optionsContainer = Instance.new("Frame")
            optionsContainer.Name = "OptionsContainer"
            optionsContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            optionsContainer.BackgroundTransparency = 0.1
            optionsContainer.Size = UDim2.new(1, -10, 0, 0)
            optionsContainer.Position = UDim2.new(0, 5, 1, 5)
            optionsContainer.ClipsDescendants = true
            optionsContainer.Parent = dropdown
            
            local optionsCorner = Instance.new("UICorner")
            optionsCorner.CornerRadius = UDim.new(0, 6)
            optionsCorner.Parent = optionsContainer
            
            local optionsLayout = Instance.new("UIListLayout")
            optionsLayout.Padding = UDim.new(0, 2)
            optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionsLayout.Parent = optionsContainer
            
            for i, option in ipairs(config.Options) do
                local optionButton = Instance.new("TextButton")
                optionButton.Name = "Option_" .. i
                optionButton.Text = option
                optionButton.Font = Enum.Font.Gotham
                optionButton.TextSize = 12
                optionButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                optionButton.BackgroundTransparency = 0.1
                optionButton.Size = UDim2.new(1, 0, 0, 30)
                optionButton.LayoutOrder = i
                optionButton.Parent = optionsContainer
                
                local optionCorner = Instance.new("UICorner")
                optionCorner.CornerRadius = UDim.new(0, 4)
                optionCorner.Parent = optionButton
                
                optionButton.MouseEnter:Connect(function()
                    TweenService:Create(optionButton, TweenInfo.new(0.1), {
                        BackgroundColor3 = themeColor,
                        BackgroundTransparency = 0.3
                    }):Play()
                end)
                
                optionButton.MouseLeave:Connect(function()
                    TweenService:Create(optionButton, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(50, 50, 55),
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                
                optionButton.Activated:Connect(function()
                    selectedLabel.Text = option
                    config.Callback(option)
                    configManager:Set(configKey, option)
                    TweenService:Create(optionsContainer, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, -10, 0, 0)
                    }):Play()
                    task.wait(0.2)
                    optionsContainer:Destroy()
                    isOpen = false
                end)
            end
            
            local totalHeight = #config.Options * 32
            TweenService:Create(optionsContainer, TweenInfo.new(0.2), {
                Size = UDim2.new(1, -10, 0, totalHeight)
            }):Play()
            
            TweenService:Create(arrow, TweenInfo.new(0.2), {
                Rotation = 180
            }):Play()
        else
            if optionsContainer then
                TweenService:Create(optionsContainer, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, -10, 0, 0)
                }):Play()
                task.wait(0.2)
                optionsContainer:Destroy()
            end
            
            TweenService:Create(arrow, TweenInfo.new(0.2), {
                Rotation = 0
            }):Play()
        end
    end
    
    dropdownButton.Activated:Connect(function()
        ToggleDropdown()
    end)
    
    -- Dropdown API
    local dropdownAPI = {
        Value = savedValue,
        Options = config.Options
    }
    
    function dropdownAPI:Set(value)
        selectedLabel.Text = value
        self.Value = value
        config.Callback(value)
        configManager:Set(configKey, value)
        return self
    end
    
    function dropdownAPI:AddOption(option)
        table.insert(self.Options, option)
        return self
    end
    
    function dropdownAPI:RemoveOption(option)
        for i, opt in ipairs(self.Options) do
            if opt == option then
                table.remove(self.Options, i)
                break
            end
        end
        return self
    end
    
    function dropdownAPI:Destroy()
        dropdown:Destroy()
        ElementManager.ActiveElements[dropdownId] = nil
    end
    
    ElementManager.ActiveElements[dropdownId].Element = dropdownAPI
    
    return dropdownAPI
end

-- Cleanup function
function UIElements:Cleanup()
    ElementManager:Cleanup()
end

return UIElements
