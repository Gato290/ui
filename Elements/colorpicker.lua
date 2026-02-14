-- colorpicker.lua V2.0.0 (Merged Version)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ColorpickerModule = {}

-- Default colors yang bisa diubah via UI
local UI_COLORS = {
    Background = Color3.fromRGB(25, 25, 25),
    TitleBar = Color3.fromRGB(35, 35, 35),
    Button = Color3.fromRGB(45, 45, 45),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(200, 200, 200),
    TextMuted = Color3.fromRGB(150, 150, 150),
    CloseButton = Color3.fromRGB(255, 100, 100),
    Stroke = Color3.fromRGB(255, 255, 255),
    PickerBg = Color3.fromRGB(35, 35, 35),
    ContainerBg = Color3.fromRGB(255, 255, 255)
}

-- Fungsi untuk mengupdate warna UI secara global
local function updateUIColor(newColors)
    for key, value in pairs(newColors) do
        if UI_COLORS[key] then
            UI_COLORS[key] = value
        end
    end
end

-- Constants (ukuran tetap)
local WINDOW_SIZE = UDim2.new(0, 200, 0, 300)
local WINDOW_POSITION = UDim2.new(0.5, -100, 0.5, -150)
local ANIMATION_DURATION = 0.2
local OPEN_ANIMATION_DURATION = 0.3
local STROKE_OPACITY = 0.7

-- Utility Functions
local function formatHex(color)
    return string.format("#%02X%02X%02X", 
        color.R * 255, 
        color.G * 255, 
        color.B * 255
    )
end

local function rgbToHsv(color)
    local r, g, b = color.R, color.G, color.B
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v = 0, 0, max
    
    local delta = max - min
    if max ~= 0 then s = delta / max end
    
    if delta ~= 0 then
        if max == r then
            h = (g - b) / delta
            if g < b then h = h + 6 end
        elseif max == g then
            h = (b - r) / delta + 2
        elseif max == b then
            h = (r - g) / delta + 4
        end
        h = h / 6
    end
    
    return h, s, v
end

local function hsvToRgb(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    i = i % 6
    if i == 0 then
        r, g, b = v, t, p
    elseif i == 1 then
        r, g, b = q, v, p
    elseif i == 2 then
        r, g, b = p, v, t
    elseif i == 3 then
        r, g, b = p, q, v
    elseif i == 4 then
        r, g, b = t, p, v
    elseif i == 5 then
        r, g, b = v, p, q
    end
    
    return Color3.new(r, g, b)
end

local function ToRGB(color)
    return {
        R = math.floor(color.R * 255),
        G = math.floor(color.G * 255),
        B = math.floor(color.B * 255)
    }
end

local function clamp(val, min, max)
    return math.clamp(tonumber(val) or 0, min, max)
end

local function createRoundedFrame(parent, size, position, color, radius)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Size = size
    frame.Position = position
    frame.Parent = parent
    frame.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
    
    return frame
end

local function createStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function createTextLabel(parent, text, size, position, color, fontSize, font, alignment)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextSize = fontSize
    label.Font = font or Enum.Font.Gotham
    label.Size = size
    label.Position = position
    label.TextXAlignment = alignment or Enum.TextXAlignment.Left
    label.Parent = parent
    label.ZIndex = 12
    return label
end

local function createTextButton(parent, text, size, position, bgColor, textColor, fontSize)
    local button = Instance.new("TextButton")
    button.BackgroundColor3 = bgColor
    button.Text = text
    button.TextColor3 = textColor
    button.TextSize = fontSize
    button.Font = Enum.Font.GothamBold
    button.Size = size
    button.Position = position
    button.Parent = parent
    button.ZIndex = 12
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    return button
end

local function createGradient(parent, colorSequence, transparencySequence, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = colorSequence
    if transparencySequence then
        gradient.Transparency = transparencySequence
    end
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

local function animateFrame(frame, targetSize, duration, easingStyle, easingDirection, onComplete)
    local tweenInfo = TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Linear, easingDirection or Enum.EasingDirection.Out)
    local tween = TweenService:Create(frame, tweenInfo, { Size = targetSize })
    tween:Play()
    
    if onComplete then
        tween.Completed:Connect(onComplete)
    end
    
    return tween
end

-- Main Color Picker Window (from first code)
local function createColorPickerWindow(parent, config, elementKey, updateCallback)
    local config = config or {}
    local title = config.Title or "Color Picker"
    local defaultColor = config.Default or Color3.fromRGB(255, 255, 255)
    local windowColor = config.WindowColor or Color3.fromRGB(0, 140, 255)
    local saveColor = config.SaveColor or false
    local configData = config.ConfigData or {}
    local saveFunction = config.SaveFunction or function() end
    local transparency = config.Transparency or false
    
    -- Load saved color if exists
    local currentColor = defaultColor
    if saveColor and configData and configData[elementKey] then
        local saved = configData[elementKey]
        if type(saved) == "table" and saved.R and saved.G and saved.B then
            currentColor = Color3.new(saved.R, saved.G, saved.B)
        end
    end
    
    -- Main frame
    local mainFrame = createRoundedFrame(parent, WINDOW_SIZE, 
        WINDOW_POSITION, UI_COLORS.Background, 6)
    mainFrame.Visible = false
    mainFrame.ZIndex = 10
    
    createStroke(mainFrame, windowColor, 2, STROKE_OPACITY)
    
    -- Title bar
    local titleBar = createRoundedFrame(mainFrame, UDim2.new(1, 0, 0, 30), 
        UDim2.new(0, 0, 0, 0), UI_COLORS.TitleBar, 6)
    titleBar.ZIndex = 11
    
    createTextLabel(titleBar, title, UDim2.new(1, -30, 1, 0), 
        UDim2.new(0, 10, 0, 0), UI_COLORS.TextPrimary, 14, Enum.Font.GothamBold)
    
    local closeBtn = createTextButton(titleBar, "×", UDim2.new(0, 30, 1, 0), 
        UDim2.new(1, -30, 0, 0), Color3.fromRGB(255, 255, 255):lerp(UI_COLORS.CloseButton, 0), 
        UI_COLORS.CloseButton, 20)
    closeBtn.BackgroundTransparency = 1
    
    -- Color preview
    local previewFrame = createRoundedFrame(mainFrame, UDim2.new(1, -20, 0, 40), 
        UDim2.new(0, 10, 0, 40), currentColor, 4)
    previewFrame.ZIndex = 11
    
    createStroke(previewFrame, UI_COLORS.Stroke, 1, STROKE_OPACITY)
    
    createTextLabel(previewFrame, formatHex(currentColor), UDim2.new(1, -10, 0, 15), 
        UDim2.new(0, 5, 0, 45), UI_COLORS.TextSecondary, 12)
    
    -- Hue/Saturation picker
    local pickerFrame = createRoundedFrame(mainFrame, UDim2.new(0, 180, 0, 150), 
        UDim2.new(0, 10, 0, 90), UI_COLORS.PickerBg, 4)
    pickerFrame.ZIndex = 11
    pickerFrame.ClipsDescendants = true
    
    -- Gradients
    createGradient(pickerFrame, 
        ColorSequence.new(Color3.fromRGB(255, 255, 255)), 
        NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        }), 90)
    
    createGradient(pickerFrame, 
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }), nil, 90)
    
    -- Picker cursor
    local cursor = createRoundedFrame(pickerFrame, UDim2.new(0, 12, 0, 12), 
        UDim2.new(0, -6, 0, -6), UI_COLORS.TextPrimary, 6)
    cursor.Visible = false
    cursor.ZIndex = 12
    createStroke(cursor, Color3.fromRGB(0, 0, 0), 2)
    
    -- Hue slider
    local hueSlider = createRoundedFrame(mainFrame, UDim2.new(0, 180, 0, 12), 
        UDim2.new(0, 10, 0, 250), UI_COLORS.PickerBg, 6)
    hueSlider.ZIndex = 11
    
    createGradient(hueSlider, 
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }))
    
    local sliderCursor = createRoundedFrame(hueSlider, UDim2.new(0, 6, 1, 4), 
        UDim2.new(0, -3, 0, -2), UI_COLORS.TextPrimary, 2)
    sliderCursor.ZIndex = 12
    createStroke(sliderCursor, Color3.fromRGB(0, 0, 0), 1)
    
    -- Buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Position = UDim2.new(0, 10, 0, 272)
    buttonFrame.Size = UDim2.new(1, -20, 0, 25)
    buttonFrame.Parent = mainFrame
    buttonFrame.ZIndex = 11
    
    local cancelBtn = createTextButton(buttonFrame, "Cancel", 
        UDim2.new(0.5, -2, 1, 0), UDim2.new(0, 0, 0, 0), 
        UI_COLORS.Button, UI_COLORS.TextSecondary, 12)
    
    local okBtn = createTextButton(buttonFrame, "OK", 
        UDim2.new(0.5, -2, 1, 0), UDim2.new(0.5, 2, 0, 0), 
        windowColor, UI_COLORS.TextPrimary, 12)
    
    -- State variables
    local state = {
        isDragging = false,
        isHueDragging = false,
        selectedColor = currentColor,
        hue = 0,
        saturation = 0,
        value = 1,
        confirmed = false,
        resultColor = currentColor,
        transparency = transparency
    }
    
    -- Initialize from current color
    state.hue, state.saturation, state.value = rgbToHsv(currentColor)
    
    -- Update functions
    local function updatePickerUI()
        state.selectedColor = hsvToRgb(state.hue, state.saturation, state.value)
        previewFrame.BackgroundColor3 = state.selectedColor
        
        -- Update hex label
        for _, child in pairs(previewFrame:GetChildren()) do
            if child:IsA("TextLabel") then
                child.Text = formatHex(state.selectedColor)
            end
        end
        
        local posX = state.saturation * pickerFrame.AbsoluteSize.X
        local posY = (1 - state.value) * pickerFrame.AbsoluteSize.Y
        cursor.Position = UDim2.new(0, posX - cursor.AbsoluteSize.X/2, 0, posY - cursor.AbsoluteSize.Y/2)
        
        local huePos = state.hue * hueSlider.AbsoluteSize.X
        sliderCursor.Position = UDim2.new(0, huePos - sliderCursor.AbsoluteSize.X/2, 0, -2)
    end
    
    local function updateFromPosition(x, y)
        local size = pickerFrame.AbsoluteSize
        local relX = math.clamp(x / size.X, 0, 1)
        local relY = math.clamp(y / size.Y, 0, 1)
        
        state.saturation = relX
        state.value = 1 - relY
        updatePickerUI()
    end
    
    local function updateFromHuePosition(x)
        local size = hueSlider.AbsoluteSize.X
        state.hue = math.clamp(x / size, 0, 1)
        updatePickerUI()
    end
    
    -- Input handling
    local function setupInputHandling()
        pickerFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state.isDragging = true
                updateFromPosition(
                    input.Position.X - pickerFrame.AbsolutePosition.X,
                    input.Position.Y - pickerFrame.AbsolutePosition.Y
                )
            end
        end)
        
        pickerFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and state.isDragging then
                updateFromPosition(
                    input.Position.X - pickerFrame.AbsolutePosition.X,
                    input.Position.Y - pickerFrame.AbsolutePosition.Y
                )
            end
        end)
        
        hueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state.isHueDragging = true
                updateFromHuePosition(input.Position.X - hueSlider.AbsolutePosition.X)
            end
        end)
        
        hueSlider.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and state.isHueDragging then
                updateFromHuePosition(input.Position.X - hueSlider.AbsolutePosition.X)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state.isDragging = false
                state.isHueDragging = false
            end
        end)
    end
    
    -- Button handlers
    local function closePicker(confirmed)
        state.confirmed = confirmed
        if confirmed then
            state.resultColor = state.selectedColor
            if saveColor then
                configData[elementKey] = {
                    R = state.resultColor.R,
                    G = state.resultColor.G,
                    B = state.resultColor.B
                }
                saveFunction()
            end
        end
        
        animateFrame(mainFrame, UDim2.new(0, 0, 0, 0), ANIMATION_DURATION, 
            nil, nil, function()
                mainFrame.Visible = false
                mainFrame.Size = WINDOW_SIZE
            end)
    end
    
    okBtn.MouseButton1Click:Connect(function() closePicker(true) end)
    cancelBtn.MouseButton1Click:Connect(function() closePicker(false) end)
    closeBtn.MouseButton1Click:Connect(function() closePicker(false) end)
    
    -- Initialize
    setupInputHandling()
    updatePickerUI()
    cursor.Visible = true
    
    -- Return control functions
    return {
        Open = function()
            mainFrame.Visible = true
            animateFrame(mainFrame, WINDOW_SIZE, 
                OPEN_ANIMATION_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end,
        Close = function()
            closePicker(false)
        end,
        GetColor = function()
            return state.resultColor
        end,
        WasConfirmed = function()
            return state.confirmed
        end,
        SetColor = function(newColor)
            if typeof(newColor) == "Color3" then
                currentColor = newColor
                state.resultColor = newColor
                state.hue, state.saturation, state.value = rgbToHsv(newColor)
                updatePickerUI()
            end
        end,
        GetTransparency = function()
            return state.transparency
        end,
        SetTransparency = function(newTransparency)
            state.transparency = newTransparency
        end,
        -- Fungsi untuk mengupdate warna UI
        UpdateUIColor = function(newColors)
            updateUIColor(newColors)
            -- Update UI elements dengan warna baru
            mainFrame.BackgroundColor3 = UI_COLORS.Background
            titleBar.BackgroundColor3 = UI_COLORS.TitleBar
            cancelBtn.BackgroundColor3 = UI_COLORS.Button
            cancelBtn.TextColor3 = UI_COLORS.TextSecondary
            okBtn.TextColor3 = UI_COLORS.TextPrimary
            pickerFrame.BackgroundColor3 = UI_COLORS.PickerBg
            hueSlider.BackgroundColor3 = UI_COLORS.PickerBg
            
            -- Update text colors
            for _, child in pairs(titleBar:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.TextColor3 = UI_COLORS.TextPrimary
                end
            end
            
            for _, child in pairs(previewFrame:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.TextColor3 = UI_COLORS.TextSecondary
                end
            end
        end
    }
end

-- Element creation function (from second code, adapted)
local function createElement(parent, config, order, updateCallback)
    local config = config or {}
    local title = config.Title or "Colorpicker"
    local defaultColor = config.Default or Color3.fromRGB(255, 255, 255)
    local description = config.Description or ""
    local callback = config.Callback or function() end
    local windowColor = config.WindowColor or Color3.fromRGB(0, 140, 255)
    local elementKey = config.ElementKey or ("Colorpicker_" .. tostring(order))
    local transparency = config.Transparency or false
    
    -- Main container
    local container = Instance.new("Frame")
    container.BackgroundColor3 = UI_COLORS.ContainerBg
    container.BackgroundTransparency = 0.95
    container.BorderSizePixel = 0
    container.LayoutOrder = order
    container.Size = UDim2.new(1, 0, 0, 30)
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = container
    
    -- Title
    local titleLabel = createTextLabel(container, title, UDim2.new(0.5, -10, 1, 0), 
        UDim2.new(0, 10, 0, 0), UI_COLORS.TextPrimary, 13, Enum.Font.GothamBold)
    
    -- Description if exists
    if description and description ~= "" then
        local descLabel = createTextLabel(container, description, UDim2.new(0.5, -10, 1, 0), 
            UDim2.new(0.5, 0, 0, 0), UI_COLORS.TextMuted, 11)
    end
    
    -- Color preview button
    local previewBtn = Instance.new("TextButton")
    previewBtn.BackgroundColor3 = defaultColor
    previewBtn.BackgroundTransparency = transparency or 0
    previewBtn.BorderSizePixel = 0
    previewBtn.Size = UDim2.new(0, 30, 0, 20)
    previewBtn.Position = UDim2.new(1, -40, 0.5, -10)
    previewBtn.Parent = container
    previewBtn.ZIndex = 5
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = previewBtn
    
    createStroke(previewBtn, UI_COLORS.Stroke, 1, STROKE_OPACITY)
    
    -- Create color picker window
    local colorPicker = createColorPickerWindow(parent.Parent.Parent.Parent, {
        Title = title,
        Default = defaultColor,
        WindowColor = windowColor,
        SaveColor = config.SaveColor,
        ConfigData = config.ConfigData,
        SaveFunction = config.SaveFunction,
        Transparency = transparency
    }, elementKey, updateCallback)
    
    -- Button click to open picker
    previewBtn.MouseButton1Click:Connect(function()
        colorPicker.Open()
    end)
    
    -- Check for saved color
    if config.SaveColor and config.ConfigData and config.ConfigData[elementKey] then
        local saved = config.ConfigData[elementKey]
        if saved and saved.R and saved.G and saved.B then
            local savedColor = Color3.new(saved.R, saved.G, saved.B)
            previewBtn.BackgroundColor3 = savedColor
        end
    end
    
    -- Return control functions
    return {
        Set = function(color, skipCallback, transparency)
            if typeof(color) == "Color3" then
                previewBtn.BackgroundColor3 = color
                if transparency then
                    previewBtn.BackgroundTransparency = transparency
                end
                colorPicker.SetColor(color)
                if transparency then
                    colorPicker.SetTransparency(transparency)
                end
                if not skipCallback then
                    callback(color, transparency)
                end
            end
        end,
        Get = function()
            return previewBtn.BackgroundColor3
        end,
        GetTransparency = function()
            return previewBtn.BackgroundTransparency
        end,
        OpenPicker = function()
            colorPicker.Open()
        end,
        -- Fungsi untuk mengupdate warna UI dari element ini
        UpdateElementColors = function(newColors)
            if newColors.TextPrimary then
                titleLabel.TextColor3 = newColors.TextPrimary
            end
            if newColors.ContainerBg then
                container.BackgroundColor3 = newColors.ContainerBg
            end
            if newColors.Stroke then
                -- Update stroke jika ada
                for _, child in pairs(previewBtn:GetChildren()) do
                    if child:IsA("UIStroke") then
                        child.Color = newColors.Stroke
                    end
                end
            end
        end,
        -- Update warna picker window
        UpdatePickerColors = function(newColors)
            colorPicker.UpdateUIColor(newColors)
        end
    }
end

-- Main API Functions
function ColorpickerModule.CreateColorpicker(parent, config, order, updateCallback)
    return createElement(parent, config, order, updateCallback)
end

-- Legacy support for the second code's format
function ColorpickerModule.Element(config)
    local element = {
        __type = "Colorpicker",
        Title = config.Title or "Colorpicker",
        Desc = config.Desc or nil,
        Locked = config.Locked or false,
        LockedTitle = config.LockedTitle,
        Default = config.Default or Color3.new(1,1,1),
        Callback = config.Callback or function() end,
        Transparency = config.Transparency,
        UIElements = {}
    }
    
    local CanCallback = true
    
    element.UIElements = {
        Colorpicker = Instance.new("ImageButton")
    }
    
    element.UIElements.Colorpicker.ImageColor3 = element.Default
    element.UIElements.Colorpicker.Size = UDim2.new(0, 26, 0, 26)
    element.UIElements.Colorpicker.BackgroundTransparency = 1
    
    function element:Lock()
        element.Locked = true
        CanCallback = false
        return element
    end
    
    function element:Unlock()
        element.Locked = false
        CanCallback = true
        return element
    end
    
    function element:Update(color, transparency)
        element.UIElements.Colorpicker.ImageColor3 = color
        element.Default = color
        if transparency then
            element.Transparency = transparency
        end
    end
    
    function element:Set(c, t)
        return element:Update(c, t)
    end
    
    element.UIElements.Colorpicker.MouseButton1Click:Connect(function()
        if CanCallback then
            local picker = createColorPickerWindow(config.Parent.Parent, {
                Title = element.Title,
                Default = element.Default,
                WindowColor = config.WindowColor or Color3.fromRGB(0, 140, 255),
                Transparency = element.Transparency
            }, "element", function() end)
            
            picker.Open()
        end
    end)
    
    return element
end

-- Fungsi global untuk mengupdate semua warna UI
function ColorpickerModule.SetGlobalUIColors(newColors)
    updateUIColor(newColors)
end

-- Fungsi untuk mendapatkan warna UI saat ini
function ColorpickerModule.GetUIColors()
    return table.clone(UI_COLORS)
end

return ColorpickerModule
