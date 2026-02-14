-- colorpicker.lua V1.0.0
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ColorpickerModule = {}

local function createColorPickerWindow(parent, config, elementKey, updateCallback)
    local config = config or {}
    local title = config.Title or "Color Picker"
    local defaultColor = config.Default or Color3.fromRGB(255, 255, 255)
    local windowColor = config.WindowColor or Color3.fromRGB(0, 140, 255)
    local saveColor = config.SaveColor or false
    local configData = config.ConfigData or {}
    local saveFunction = config.SaveFunction or function() end
    
    -- Load saved color if exists
    local currentColor = defaultColor
    if saveColor and configData and configData[elementKey] then
        local saved = configData[elementKey]
        if type(saved) == "table" and saved.R and saved.G and saved.B then
            currentColor = Color3.new(saved.R, saved.G, saved.B)
        end
    end
    
    -- Create main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -100, 0.5, -150)
    mainFrame.Size = UDim2.new(0, 200, 0, 300)
    mainFrame.Visible = false
    mainFrame.Parent = parent
    mainFrame.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = windowColor
    stroke.Thickness = 2
    stroke.Transparency = 0.7
    stroke.Parent = mainFrame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Parent = mainFrame
    titleBar.ZIndex = 11
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 6)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Size = UDim2.new(1, -30, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    titleLabel.ZIndex = 12
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.TextSize = 20
    closeBtn.Size = UDim2.new(0, 30, 1, 0)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.Parent = titleBar
    closeBtn.ZIndex = 12
    
    -- Color preview
    local previewFrame = Instance.new("Frame")
    previewFrame.BackgroundColor3 = currentColor
    previewFrame.BorderSizePixel = 0
    previewFrame.Position = UDim2.new(0, 10, 0, 40)
    previewFrame.Size = UDim2.new(1, -20, 0, 40)
    previewFrame.Parent = mainFrame
    previewFrame.ZIndex = 11
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = previewFrame
    
    local previewStroke = Instance.new("UIStroke")
    previewStroke.Color = Color3.fromRGB(255, 255, 255)
    previewStroke.Thickness = 1
    previewStroke.Transparency = 0.7
    previewStroke.Parent = previewFrame
    
    local hexLabel = Instance.new("TextLabel")
    hexLabel.BackgroundTransparency = 1
    hexLabel.Font = Enum.Font.Gotham
    hexLabel.Text = string.format("#%02X%02X%02X", currentColor.R * 255, currentColor.G * 255, currentColor.B * 255)
    hexLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    hexLabel.TextSize = 12
    hexLabel.Size = UDim2.new(1, -10, 0, 15)
    hexLabel.Position = UDim2.new(0, 5, 0, 45)
    hexLabel.TextXAlignment = Enum.TextXAlignment.Left
    hexLabel.Parent = previewFrame
    
    -- Hue/Saturation picker
    local pickerFrame = Instance.new("Frame")
    pickerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    pickerFrame.BorderSizePixel = 0
    pickerFrame.Position = UDim2.new(0, 10, 0, 90)
    pickerFrame.Size = UDim2.new(0, 180, 0, 150)
    pickerFrame.Parent = mainFrame
    pickerFrame.ZIndex = 11
    pickerFrame.ClipsDescendants = true
    
    local pickerCorner = Instance.new("UICorner")
    pickerCorner.CornerRadius = UDim.new(0, 4)
    pickerCorner.Parent = pickerFrame
    
    -- Saturation gradient (white to transparent)
    local satGradient = Instance.new("UIGradient")
    satGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    satGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    satGradient.Rotation = 90
    satGradient.Parent = pickerFrame
    
    -- Hue gradient (rainbow)
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    hueGradient.Rotation = 90
    hueGradient.Parent = pickerFrame
    
    -- Picker cursor
    local cursor = Instance.new("Frame")
    cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    cursor.BorderSizePixel = 0
    cursor.Size = UDim2.new(0, 12, 0, 12)
    cursor.Position = UDim2.new(0, -6, 0, -6)
    cursor.Visible = false
    cursor.Parent = pickerFrame
    cursor.ZIndex = 12
    
    local cursorCorner = Instance.new("UICorner")
    cursorCorner.CornerRadius = UDim.new(1, 0)
    cursorCorner.Parent = cursor
    
    local cursorStroke = Instance.new("UIStroke")
    cursorStroke.Color = Color3.fromRGB(0, 0, 0)
    cursorStroke.Thickness = 2
    cursorStroke.Parent = cursor
    
    -- Hue slider
    local hueSlider = Instance.new("Frame")
    hueSlider.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    hueSlider.BorderSizePixel = 0
    hueSlider.Position = UDim2.new(0, 10, 0, 250)
    hueSlider.Size = UDim2.new(0, 180, 0, 12)
    hueSlider.Parent = mainFrame
    hueSlider.ZIndex = 11
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = hueSlider
    
    local sliderGradient = Instance.new("UIGradient")
    sliderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    sliderGradient.Parent = hueSlider
    
    local sliderCursor = Instance.new("Frame")
    sliderCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderCursor.BorderSizePixel = 0
    sliderCursor.Size = UDim2.new(0, 6, 1, 4)
    sliderCursor.Position = UDim2.new(0, -3, 0, -2)
    sliderCursor.Parent = hueSlider
    sliderCursor.ZIndex = 12
    
    local sliderCursorCorner = Instance.new("UICorner")
    sliderCursorCorner.CornerRadius = UDim.new(0, 2)
    sliderCursorCorner.Parent = sliderCursor
    
    local sliderCursorStroke = Instance.new("UIStroke")
    sliderCursorStroke.Color = Color3.fromRGB(0, 0, 0)
    sliderCursorStroke.Thickness = 1
    sliderCursorStroke.Parent = sliderCursor
    
    -- Buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Position = UDim2.new(0, 10, 0, 272)
    buttonFrame.Size = UDim2.new(1, -20, 0, 25)
    buttonFrame.Parent = mainFrame
    buttonFrame.ZIndex = 11
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.Text = "Cancel"
    cancelBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    cancelBtn.TextSize = 12
    cancelBtn.Size = UDim2.new(0.5, -2, 1, 0)
    cancelBtn.Position = UDim2.new(0, 0, 0, 0)
    cancelBtn.Parent = buttonFrame
    cancelBtn.ZIndex = 12
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 4)
    cancelCorner.Parent = cancelBtn
    
    local okBtn = Instance.new("TextButton")
    okBtn.BackgroundColor3 = windowColor
    okBtn.Font = Enum.Font.GothamBold
    okBtn.Text = "OK"
    okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    okBtn.TextSize = 12
    okBtn.Size = UDim2.new(0.5, -2, 1, 0)
    okBtn.Position = UDim2.new(0.5, 2, 0, 0)
    okBtn.Parent = buttonFrame
    okBtn.ZIndex = 12
    
    local okCorner = Instance.new("UICorner")
    okCorner.CornerRadius = UDim.new(0, 4)
    okCorner.Parent = okBtn
    
    -- State variables
    local isDragging = false
    local isHueDragging = false
    local selectedColor = currentColor
    local hue = 0
    local saturation = 0
    local value = 1
    
    -- Convert RGB to HSV
    local function rgbToHsv(color)
        local r, g, b = color.R, color.G, color.B
        local max = math.max(r, g, b)
        local min = math.min(r, g, b)
        local h, s, v = 0, 0, max
        
        local d = max - min
        if max ~= 0 then s = d / max end
        if max ~= min then
            if max == r then
                h = (g - b) / d
                if g < b then h = h + 6 end
            elseif max == g then
                h = (b - r) / d + 2
            elseif max == b then
                h = (r - g) / d + 4
            end
            h = h / 6
        end
        
        return h, s, v
    end
    
    -- Convert HSV to RGB
    local function hsvToRgb(h, s, v)
        local r, g, b
        local i = math.floor(h * 6)
        local f = h * 6 - i
        local p = v * (1 - s)
        local q = v * (1 - f * s)
        local t = v * (1 - (1 - f) * s)
        
        i = i % 6
        if i == 0 then r, g, b = v, t, p
        elseif i == 1 then r, g, b = q, v, p
        elseif i == 2 then r, g, b = p, v, t
        elseif i == 3 then r, g, b = p, q, v
        elseif i == 4 then r, g, b = t, p, v
        elseif i == 5 then r, g, b = v, p, q
        end
        
        return Color3.new(r, g, b)
    end
    
    -- Update UI from HSV values
    local function updateFromHsv()
        selectedColor = hsvToRgb(hue, saturation, value)
        previewFrame.BackgroundColor3 = selectedColor
        hexLabel.Text = string.format("#%02X%02X%02X", selectedColor.R * 255, selectedColor.G * 255, selectedColor.B * 255)
        
        local posX = saturation * pickerFrame.AbsoluteSize.X
        local posY = (1 - value) * pickerFrame.AbsoluteSize.Y
        cursor.Position = UDim2.new(0, posX - cursor.AbsoluteSize.X/2, 0, posY - cursor.AbsoluteSize.Y/2)
        
        local huePos = hue * hueSlider.AbsoluteSize.X
        sliderCursor.Position = UDim2.new(0, huePos - sliderCursor.AbsoluteSize.X/2, 0, -2)
    end
    
    -- Update from position in picker
    local function updateFromPosition(x, y)
        local size = pickerFrame.AbsoluteSize
        local relX = math.clamp(x / size.X, 0, 1)
        local relY = math.clamp(y / size.Y, 0, 1)
        
        saturation = relX
        value = 1 - relY
        updateFromHsv()
    end
    
    -- Update from hue slider position
    local function updateFromHuePosition(x)
        local size = hueSlider.AbsoluteSize.X
        hue = math.clamp(x / size, 0, 1)
        updateFromHsv()
    end
    
    -- Initialize from current color
    do
        hue, saturation, value = rgbToHsv(currentColor)
        updateFromHsv()
        cursor.Visible = true
    end
    
    -- Picker input handling
    pickerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateFromPosition(input.Position.X - pickerFrame.AbsolutePosition.X, input.Position.Y - pickerFrame.AbsolutePosition.Y)
        end
    end)
    
    pickerFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
            updateFromPosition(input.Position.X - pickerFrame.AbsolutePosition.X, input.Position.Y - pickerFrame.AbsolutePosition.Y)
        end
    end)
    
    -- Hue slider input handling
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isHueDragging = true
            updateFromHuePosition(input.Position.X - hueSlider.AbsolutePosition.X)
        end
    end)
    
    hueSlider.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isHueDragging then
            updateFromHuePosition(input.Position.X - hueSlider.AbsolutePosition.X)
        end
    end)
    
    -- Global input release
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
            isHueDragging = false
        end
    end)
    
    -- Button events
    local resultColor = currentColor
    local confirmed = false
    
    okBtn.MouseButton1Click:Connect(function()
        resultColor = selectedColor
        confirmed = true
        
        -- Save if needed
        if saveColor then
            configData[elementKey] = {
                R = resultColor.R,
                G = resultColor.G,
                B = resultColor.B
            }
            saveFunction()
        end
        
        -- Close with animation
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 0, 0) })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            mainFrame.Visible = false
            mainFrame.Size = UDim2.new(0, 200, 0, 300)
        end)
    end)
    
    cancelBtn.MouseButton1Click:Connect(function()
        confirmed = false
        
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 0, 0) })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            mainFrame.Visible = false
            mainFrame.Size = UDim2.new(0, 200, 0, 300)
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        confirmed = false
        
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 0, 0) })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            mainFrame.Visible = false
            mainFrame.Size = UDim2.new(0, 200, 0, 300)
        end)
    end)
    
    -- Return control functions
    return {
        Open = function()
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 200, 0, 300)
            local openTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 200, 0, 300) })
            openTween:Play()
        end,
        Close = function()
            confirmed = false
            local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 0, 0) })
            closeTween:Play()
            closeTween.Completed:Connect(function()
                mainFrame.Visible = false
                mainFrame.Size = UDim2.new(0, 200, 0, 300)
            end)
        end,
        GetColor = function()
            return resultColor
        end,
        WasConfirmed = function()
            return confirmed
        end,
        SetColor = function(newColor)
            if typeof(newColor) == "Color3" then
                currentColor = newColor
                resultColor = newColor
                hue, saturation, value = rgbToHsv(newColor)
                updateFromHsv()
            end
        end
    }
end

function ColorpickerModule.CreateColorpicker(parent, config, order, updateCallback)
    local config = config or {}
    local title = config.Title or "Colorpicker"
    local defaultColor = config.Default or Color3.fromRGB(255, 255, 255)
    local description = config.Description or ""
    local callback = config.Callback or function() end
    local windowColor = config.WindowColor or Color3.fromRGB(0, 140, 255)
    local elementKey = config.ElementKey or ("Colorpicker_" .. tostring(order))
    
    -- Main container
    local container = Instance.new("Frame")
    container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    container.BackgroundTransparency = 0.95
    container.BorderSizePixel = 0
    container.LayoutOrder = order
    container.Size = UDim2.new(1, 0, 0, 30)
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = container
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0.5, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Parent = container
    
    -- Description if exists
    if description and description ~= "" then
        local descLabel = Instance.new("TextLabel")
        descLabel.BackgroundTransparency = 1
        descLabel.Font = Enum.Font.Gotham
        descLabel.Text = description
        descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        descLabel.TextSize = 11
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Size = UDim2.new(0.5, -10, 1, 0)
        descLabel.Position = UDim2.new(0.5, 0, 0, 0)
        descLabel.Parent = container
    end
    
    -- Color preview button
    local previewBtn = Instance.new("TextButton")
    previewBtn.BackgroundColor3 = defaultColor
    previewBtn.BorderSizePixel = 0
    previewBtn.Size = UDim2.new(0, 30, 0, 20)
    previewBtn.Position = UDim2.new(1, -40, 0.5, -10)
    previewBtn.Parent = container
    previewBtn.ZIndex = 5
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = previewBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.7
    btnStroke.Parent = previewBtn
    
    -- Create color picker window
    local colorPicker = createColorPickerWindow(parent.Parent.Parent.Parent, {
        Title = title,
        Default = defaultColor,
        WindowColor = windowColor,
        SaveColor = config.SaveColor,
        ConfigData = config.ConfigData,
        SaveFunction = config.SaveFunction
    }, elementKey, updateCallback)
    
    -- Button click to open picker
    previewBtn.MouseButton1Click:Connect(function()
        colorPicker.Open()
    end)
    
    -- Update preview when color changes
    local function updatePreview(color)
        if color then
            previewBtn.BackgroundColor3 = color
            callback(color)
        end
    end
    
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
        Set = function(color, skipCallback)
            if typeof(color) == "Color3" then
                previewBtn.BackgroundColor3 = color
                colorPicker.SetColor(color)
                if not skipCallback then
                    callback(color)
                end
            end
        end,
        Get = function()
            return previewBtn.BackgroundColor3
        end,
        OpenPicker = function()
            colorPicker.Open()
        end,
        UpdatePreview = updatePreview
    }
end

return ColorpickerModule
