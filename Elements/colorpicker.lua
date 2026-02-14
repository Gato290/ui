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
        cursor.Visible = true
    end

    -- Update from position in picker
    local function updateFromPosition(x, y)
        local size = pickerFrame.AbsoluteSize
        local relX = math.clamp(x / size.X, 0, 1)
        local relY = math.clamp(y / size.Y, 0, 1)

        state.saturation = relX
        state.value = 1 - relY
        updatePickerUI()
    end

    -- Update from hue slider position
    local function updateFromHuePosition(x)
        local size = hueSlider.AbsoluteSize.X
        state.hue = math.clamp(x / size, 0, 1)
        updatePickerUI()
    end

    -- Initialize UI
    updatePickerUI()

    -- Picker input handling
    pickerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state.isDragging = true
            updateFromPosition(input.Position.X - pickerFrame.AbsolutePosition.X, 
                input.Position.Y - pickerFrame.AbsolutePosition.Y)
        end
    end)

    pickerFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and state.isDragging then
            updateFromPosition(input.Position.X - pickerFrame.AbsolutePosition.X, 
                input.Position.Y - pickerFrame.AbsolutePosition.Y)
        end
    end)

    -- Hue slider input handling
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

    -- Global input release
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state.isDragging = false
            state.isHueDragging = false
        end
    end)

    -- Button events
    okBtn.MouseButton1Click:Connect(function()
        state.resultColor = state.selectedColor
        state.confirmed = true

        -- Save if needed
        if saveColor then
            configData[elementKey] = {
                R = state.resultColor.R,
                G = state.resultColor.G,
                B = state.resultColor.B
            }
            saveFunction()
        end

        -- Close with animation
        animateFrame(mainFrame, UDim2.new(0, 0, 0, 0), ANIMATION_DURATION, 
            Enum.EasingStyle.Linear, Enum.EasingDirection.Out, function()
            mainFrame.Visible = false
            mainFrame.Size = WINDOW_SIZE
        end)
    end)

    cancelBtn.MouseButton1Click:Connect(function()
        state.confirmed = false
        animateFrame(mainFrame, UDim2.new(0, 0, 0, 0), ANIMATION_DURATION, 
            Enum.EasingStyle.Linear, Enum.EasingDirection.Out, function()
            mainFrame.Visible = false
            mainFrame.Size = WINDOW_SIZE
        end)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        state.confirmed = false
        animateFrame(mainFrame, UDim2.new(0, 0, 0, 0), ANIMATION_DURATION, 
            Enum.EasingStyle.Linear, Enum.EasingDirection.Out, function()
            mainFrame.Visible = false
            mainFrame.Size = WINDOW_SIZE
        end)
    end)

    -- Return control functions
    return {
        Open = function()
            mainFrame.Visible = true
            mainFrame.Size = WINDOW_SIZE
            animateFrame(mainFrame, WINDOW_SIZE, OPEN_ANIMATION_DURATION, 
                Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end,
        Close = function()
            state.confirmed = false
            animateFrame(mainFrame, UDim2.new(0, 0, 0, 0), ANIMATION_DURATION, 
                Enum.EasingStyle.Linear, Enum.EasingDirection.Out, function()
                mainFrame.Visible = false
                mainFrame.Size = WINDOW_SIZE
            end)
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
        GetState = function()
            return state
        end
    }
end

-- Legacy CreateColorpicker function
function ColorpickerModule.CreateColorpicker(parent, config, order, updateCallback)
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
    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = UI_COLORS.TextPrimary
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
        descLabel.TextColor3 = UI_COLORS.TextMuted
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
    btnStroke.Color = UI_COLORS.Stroke
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
        SaveFunction = config.SaveFunction,
        Transparency = transparency
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
        ClosePicker = function()
            colorPicker.Close()
        end,
        UpdatePreview = updatePreview,
        GetPickerState = function()
            return colorPicker.GetState()
        end
    }
end

-- Modern Element-based Colorpicker (from second code)
local Element = {
    UICorner = 9,
}

function Element:Colorpicker(Config, Window, OnApply)
    local Colorpicker = {
        __type = "Colorpicker",
        Title = Config.Title,
        Desc = Config.Desc,
        Default = Config.Value or Config.Default,
        Callback = Config.Callback,
        Transparency = Config.Transparency,
        UIElements = Config.UIElements,
        
        TextPadding = 10,
    }
    
    function Colorpicker:SetHSVFromRGB(Color)
        local H, S, V = Color3.toHSV(Color)
        Colorpicker.Hue = H
        Colorpicker.Sat = S
        Colorpicker.Vib = V
    end

    Colorpicker:SetHSVFromRGB(Colorpicker.Default)
    
    local ColorpickerModule = require("../components/window/Dialog").Init(Window)
    local ColorpickerFrame = ColorpickerModule.Create()
    
    Colorpicker.ColorpickerFrame = ColorpickerFrame
    
    ColorpickerFrame.UIElements.Main.Size = UDim2.new(1,0,0,0)
    
    --ColorpickerFrame:Close()
    
    local Hue, Sat, Vib = Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib

    Colorpicker.UIElements.Title = New("TextLabel", {
        Text = Colorpicker.Title,
        TextSize = 20,
        FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
        TextXAlignment = "Left",
        Size = UDim2.new(1,0,0,0),
        AutomaticSize = "Y",
        ThemeTag = {
            TextColor3 = "Text"
        },
        BackgroundTransparency = 1,
        Parent = ColorpickerFrame.UIElements.Main
    }, {
        New("UIPadding", {
            PaddingTop = UDim.new(0,Colorpicker.TextPadding/2),
            PaddingLeft = UDim.new(0,Colorpicker.TextPadding/2),
            PaddingRight = UDim.new(0,Colorpicker.TextPadding/2),
            PaddingBottom = UDim.new(0,Colorpicker.TextPadding/2),
        })
    })

    local SatCursor = New("Frame", {
        Size = UDim2.new(0,14,0,14),
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0,0),
        BackgroundColor3 = Colorpicker.Default
    }, {
        New("UIStroke", {
            Thickness = 2,
            Transparency = .1,
            ThemeTag = {
                Color = "Text",
            },
        }),
        New("UICorner", {
            CornerRadius = UDim.new(1,0),
        })
    })

    Colorpicker.UIElements.SatVibMap = New("ImageLabel", {
        Size = UDim2.fromOffset(160, 182-24),
        Position = UDim2.fromOffset(0, 40+Colorpicker.TextPadding),
        Image = "rbxassetid://4155801252",
        BackgroundColor3 = Color3.fromHSV(Hue, 1, 1),
        BackgroundTransparency = 0,
        Parent = ColorpickerFrame.UIElements.Main,
      }, {
        New("UICorner", {
            CornerRadius = UDim.new(0,8),
        }),
        Creator.NewRoundFrame(8, "SquircleOutline", {
            ThemeTag = {
                ImageColor3 = "Outline",
            },
            Size = UDim2.new(1,0,1,0),
            ImageTransparency = .85,
            ZIndex = 99999,
        }, {
            New("UIGradient", {
                Rotation = 45,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255)),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0.0, 0.1),
                    NumberSequenceKeypoint.new(0.5, 1),
                    NumberSequenceKeypoint.new(1.0, 0.1),
                })
            })
        }),
    
        SatCursor,
      })
      
    Colorpicker.UIElements.Inputs = New("Frame", {
        AutomaticSize = "XY",
        Size = UDim2.new(0,0,0,0),
        Position = UDim2.fromOffset(Colorpicker.Transparency and 160+10+10+10+10+10+10+20 or 160+10+10+10+20, 40 + Colorpicker.TextPadding),
        BackgroundTransparency = 1,
        Parent = ColorpickerFrame.UIElements.Main
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 4),
            FillDirection = "Vertical",
        })
    })
    
    local OldColorFrame = New("Frame", {
        BackgroundColor3 = Colorpicker.Default,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = Colorpicker.Transparency,
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
    })

    local OldColorFrameChecker = New("ImageLabel", {
        Image = "http://www.roblox.com/asset/?id=14204231522",
        ImageTransparency = 0.45,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.fromOffset(40, 40),
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(75+10, 40+182-24+10 + Colorpicker.TextPadding),
        Size = UDim2.fromOffset(75, 24),
        Parent = ColorpickerFrame.UIElements.Main,
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
        Creator.NewRoundFrame(8, "SquircleOutline", {
            ThemeTag = {
                ImageColor3 = "Outline",
            },
            Size = UDim2.new(1,0,1,0),
            ImageTransparency = .85,
            ZIndex = 99999,
        }, {
            New("UIGradient", {
                Rotation = 60,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255)),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0.0, 0.1),
                    NumberSequenceKeypoint.new(0.5, 1),
                    NumberSequenceKeypoint.new(1.0, 0.1),
                })
            })
        }),
        OldColorFrame,
    })

    local NewDisplayFrame = New("Frame", {
        BackgroundColor3 = Colorpicker.Default,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 0,
        ZIndex = 9,
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
    })

    local NewDisplayFrameChecker = New("ImageLabel", {
        Image = "http://www.roblox.com/asset/?id=14204231522",
        ImageTransparency = 0.45,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.fromOffset(40, 40),
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 40+182-24+10 + Colorpicker.TextPadding),
        Size = UDim2.fromOffset(75, 24),
        Parent = ColorpickerFrame.UIElements.Main,
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
        Creator.NewRoundFrame(8, "SquircleOutline", {
            ThemeTag = {
                ImageColor3 = "Outline",
            },
            Size = UDim2.new(1,0,1,0),
            ImageTransparency = .85,
            ZIndex = 99999,
        }, {
            New("UIGradient", {
                Rotation = 60,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255)),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0.0, 0.1),
                    NumberSequenceKeypoint.new(0.5, 1),
                    NumberSequenceKeypoint.new(1.0, 0.1),
                })
            })
        }),
        NewDisplayFrame,
    })
    
    local SequenceTable = {}

    for Color = 0, 1, 0.1 do
        table.insert(SequenceTable, ColorSequenceKeypoint.new(Color, Color3.fromHSV(Color, 1, 1)))
    end

    local HueSliderGradient = New("UIGradient", {
        Color = ColorSequence.new(SequenceTable),
        Rotation = 90,
    })
    
    local HueDragHolder = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1,
    })

    local HueDrag = New("Frame", {
        Size = UDim2.new(0,14,0,14),
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0,0),
        Parent = HueDragHolder,
        BackgroundColor3 = Colorpicker.Default
    }, {
        New("UIStroke", {
            Thickness = 2,
            Transparency = .1,
            ThemeTag = {
                Color = "Text",
            },
        }),
        New("UICorner", {
            CornerRadius = UDim.new(1,0),
        })
    })

    local HueSlider = New("Frame", {
        Size = UDim2.fromOffset(6, 182+10),
        Position = UDim2.fromOffset(160+10+10, 40 + Colorpicker.TextPadding),
        Parent = ColorpickerFrame.UIElements.Main,
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(1,0),
        }),
        HueSliderGradient,
        HueDragHolder,
    })
    
    function CreateNewInput(Title, Value)
        local InputFrame = CreateInput(Title, nil, Colorpicker.UIElements.Inputs)
        
        New("TextLabel", {
            BackgroundTransparency = 1,
            TextTransparency = .4,
            TextSize = 17,
            FontFace = Font.new(Creator.Font, Enum.FontWeight.Regular),
            AutomaticSize = "XY",
            ThemeTag = {
                TextColor3 = "Placeholder",
            },
            AnchorPoint = Vector2.new(1,0.5),
            Position = UDim2.new(1,-12,0.5,0),
            Parent = InputFrame.Frame,
            Text = Title,
        })
        
        New("UIScale", {
            Parent = InputFrame,
            Scale = .85,
        })
        
        InputFrame.Frame.Frame.TextBox.Text = Value
        InputFrame.Size = UDim2.new(0,30*5,0,42)
        
        return InputFrame
    end
    
    local HexInput = CreateNewInput("Hex", "#" .. Colorpicker.Default:ToHex())
    
    local RedInput = CreateNewInput("Red", ToRGB(Colorpicker.Default)["R"])
    local GreenInput = CreateNewInput("Green", ToRGB(Colorpicker.Default)["G"])
    local BlueInput = CreateNewInput("Blue", ToRGB(Colorpicker.Default)["B"])
    local AlphaInput
    if Colorpicker.Transparency then
        AlphaInput = CreateNewInput("Alpha", ((1 - Colorpicker.Transparency) * 100) .. "%")
    end
    
    local ButtonsContent = New("Frame", {
        Size = UDim2.new(1,0,0,40),
        AutomaticSize = "Y",
        Position = UDim2.new(0,0,0,40+8+182+24 + Colorpicker.TextPadding),
        BackgroundTransparency = 1,
        Parent = ColorpickerFrame.UIElements.Main,
        LayoutOrder = 4,
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = "Horizontal",
            HorizontalAlignment = "Right",
        }),
    })
    
    local Buttons = {
        {
            Title = "Cancel",
            Variant = "Secondary",
            Callback = function() end
        },
        {
            Title = "Apply",
            Icon = "chevron-right",
            Variant = "Primary",
            Callback = function() OnApply(Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib), Colorpicker.Transparency) end
        }
    }
    
    for _,Button in next, Buttons do
        local ButtonFrame = CreateButton(Button.Title, Button.Icon, Button.Callback, Button.Variant, ButtonsContent, ColorpickerFrame, false)
        ButtonFrame.Size = UDim2.new(0.5,-3,0,40)
        ButtonFrame.AutomaticSize = "None"
    end
        
    local TransparencySlider, TransparencyDrag, TransparencyColor
    if Colorpicker.Transparency then
        local TransparencyDragHolder = New("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1,
        })

        TransparencyDrag = New("ImageLabel", {
            Size = UDim2.new(0,14,0,14),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0,0),
            ThemeTag = {
                BackgroundColor3 = "Text",
            },
            Parent = TransparencyDragHolder,
        }, {
            New("UIStroke", {
                Thickness = 2,
                Transparency = .1,
                ThemeTag = {
                    Color = "Text",
                },
            }),
            New("UICorner", {
                CornerRadius = UDim.new(1,0),
            })
        })
        
        TransparencyColor = New("Frame", {
            Size = UDim2.fromScale(1, 1),
        }, {
            New("UIGradient", {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Rotation = 270,
            }),
            New("UICorner", {
                CornerRadius = UDim.new(0, 6),
            }),
        })

        TransparencySlider = New("Frame", {
            Size = UDim2.fromOffset(6, 182+10),
            Position = UDim2.fromOffset(160+10+10+10+10+10, 40 + Colorpicker.TextPadding),
            Parent = ColorpickerFrame.UIElements.Main,
            BackgroundTransparency = 1,
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
            }),
            New("ImageLabel", {
                Image = "rbxassetid://14204231522",
                ImageTransparency = 0.45,
                ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.fromOffset(40, 40),
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(1,0),
                }),
            }),
            TransparencyColor,
            TransparencyDragHolder,
        })
    end
    
    function Colorpicker:Round(Number, Factor)
        if Factor == 0 then
            return math.floor(Number)
        end
        Number = tostring(Number)
        return Number:find("%.") and tonumber(Number:sub(1, Number:find("%.") + Factor)) or Number
    end
    
    function Colorpicker:Update(color, transparency)
        if color then Hue, Sat, Vib = Color3.toHSV(color) else Hue, Sat, Vib = Colorpicker.Hue,Colorpicker.Sat,Colorpicker.Vib end
            
        Colorpicker.UIElements.SatVibMap.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
        SatCursor.Position = UDim2.new(Sat, 0, 1 - Vib, 0)
        SatCursor.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib)
        NewDisplayFrame.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib)
        HueDrag.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
        HueDrag.Position = UDim2.new(0.5, 0, Hue, 0)
        
        HexInput.Frame.Frame.TextBox.Text = "#" .. Color3.fromHSV(Hue, Sat, Vib):ToHex()
        RedInput.Frame.Frame.TextBox.Text = ToRGB(Color3.fromHSV(Hue, Sat, Vib))["R"]
        GreenInput.Frame.Frame.TextBox.Text = ToRGB(Color3.fromHSV(Hue, Sat, Vib))["G"]
        BlueInput.Frame.Frame.TextBox.Text = ToRGB(Color3.fromHSV(Hue, Sat, Vib))["B"]
        
        if transparency or Colorpicker.Transparency then
            NewDisplayFrame.BackgroundTransparency = Colorpicker.Transparency or transparency
            TransparencyColor.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib)
            TransparencyDrag.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib)
            TransparencyDrag.BackgroundTransparency = Colorpicker.Transparency or transparency
            TransparencyDrag.Position = UDim2.new(0.5, 0, 1 - (Colorpicker.Transparency or transparency), 0)
            AlphaInput.Frame.Frame.TextBox.Text = Colorpicker:Round((1 - (Colorpicker.Transparency or transparency)) * 100, 0) .. "%"
        end
    end

    Colorpicker:Update(Colorpicker.Default, Colorpicker.Transparency)
    
    local function GetRGB()
        local Value = Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib)
        return { R = math.floor(Value.r * 255), G = math.floor(Value.g * 255), B = math.floor(Value.b * 255) }
    end
    
    Creator.AddSignal(HexInput.Frame.Frame.TextBox.FocusLost, function(Enter)
        if Enter then
            local hex = HexInput.Frame.Frame.TextBox.Text:gsub("#", "")
            local Success, Result = pcall(Color3.fromHex, hex)
            if Success and typeof(Result) == "Color3" then
                Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = Color3.toHSV(Result)
                Colorpicker:Update()
                Colorpicker.Default = Result
            end
        end
    end)

    local function updateColorFromInput(inputBox, component)
        Creator.AddSignal(inputBox.Frame.Frame.TextBox.FocusLost, function(Enter)
            if Enter then
                local textBox = inputBox.Frame.Frame.TextBox
                local current = GetRGB()
                local clamped = clamp(textBox.Text, 0, 255)
                textBox.Text = tostring(clamped)
                                
                current[component] = clamped
                local Result = Color3.fromRGB(current.R, current.G, current.B)
                Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = Color3.toHSV(Result)
                Colorpicker:Update()
            end
        end)
    end

    updateColorFromInput(RedInput, "R")
    updateColorFromInput(GreenInput, "G")
    updateColorFromInput(BlueInput, "B")
    
    if Colorpicker.Transparency then
        Creator.AddSignal(AlphaInput.Frame.Frame.TextBox.FocusLost, function(Enter)
            if Enter then
                local textBox = AlphaInput.Frame.Frame.TextBox
                local clamped = clamp(textBox.Text, 0, 100)
                textBox.Text = tostring(clamped)
                            
                Colorpicker.Transparency = 1 - clamped * 0.01
                Colorpicker:Update(nil, Colorpicker.Transparency)
            end
        end)
    end

    local SatVibMap = Colorpicker.UIElements.SatVibMap
    Creator.AddSignal(SatVibMap.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                local MinX = SatVibMap.AbsolutePosition.X
                local MaxX = MinX + SatVibMap.AbsoluteSize.X
                local MouseX = math.clamp(Mouse.X, MinX, MaxX)

                local MinY = SatVibMap.AbsolutePosition.Y
                local MaxY = MinY + SatVibMap.AbsoluteSize.Y
                local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                Colorpicker.Sat = (MouseX - MinX) / (MaxX - MinX)
                Colorpicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY))
                Colorpicker:Update()

                RenderStepped:Wait()
            end
        end
    end)

    Creator.AddSignal(HueSlider.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                local MinY = HueSlider.AbsolutePosition.Y
                local MaxY = MinY + HueSlider.AbsoluteSize.Y
                local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                Colorpicker.Hue = ((MouseY - MinY) / (MaxY - MinY))
                Colorpicker:Update()

                RenderStepped:Wait()
            end
        end
    end)
    
    if Colorpicker.Transparency then
        Creator.AddSignal(TransparencySlider.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local MinY = TransparencySlider.AbsolutePosition.Y
                    local MaxY = MinY + TransparencySlider.AbsoluteSize.Y
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                    Colorpicker.Transparency = 1 - ((MouseY - MinY) / (MaxY - MinY))
                    Colorpicker:Update()

                    RenderStepped:Wait()
                end
            end
        end)
    end
    
    return Colorpicker
end

function Element:New(Config) 
    local Colorpicker = {
        __type = "Colorpicker",
        Title = Config.Title or "Colorpicker",
        Desc = Config.Desc or nil,
        Locked = Config.Locked or false,
        LockedTitle = Config.LockedTitle,
        Default = Config.Default or Color3.new(1,1,1),
        Callback = Config.Callback or function() end,
        UIScale = Config.UIScale,
        Transparency = Config.Transparency,
        UIElements = {}
    }
    
    local CanCallback = true
    
    Colorpicker.ColorpickerFrame = require("../components/window/Element")({
        Title = Colorpicker.Title,
        Desc = Colorpicker.Desc,
        Parent = Config.Parent,
        TextOffset = 40,
        Hover = false,
        Tab = Config.Tab,
        Index = Config.Index,
        Window = Config.Window,
        ElementTable = Colorpicker,
        ParentConfig = Config,
    })
    
    Colorpicker.UIElements.Colorpicker = Creator.NewRoundFrame(Element.UICorner, "Squircle",{
        ImageTransparency = 0,
        Active = true,
        ImageColor3 = Colorpicker.Default,
        Parent = Colorpicker.ColorpickerFrame.UIElements.Main,
        Size = UDim2.new(0,26,0,26),
        AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1,0,0,0),
        ZIndex = 2
    }, nil, true)
    
    function Colorpicker:Lock()
        Colorpicker.Locked = true
        CanCallback = false
        return Colorpicker.ColorpickerFrame:Lock(Colorpicker.LockedTitle)
    end
    
    function Colorpicker:Unlock()
        Colorpicker.Locked = false
        CanCallback = true
        return Colorpicker.ColorpickerFrame:Unlock()
    end
    
    if Colorpicker.Locked then
        Colorpicker:Lock()
    end

    function Colorpicker:Update(Color,Transparency)
        Colorpicker.UIElements.Colorpicker.ImageTransparency = Transparency or 0
        Colorpicker.UIElements.Colorpicker.ImageColor3 = Color
        Colorpicker.Default = Color
        if Transparency then
            Colorpicker.Transparency = Transparency
        end
    end
    
    function Colorpicker:Set(c,t)
        return Colorpicker:Update(c,t)
    end
    
    Creator.AddSignal(Colorpicker.UIElements.Colorpicker.MouseButton1Click, function()
        if CanCallback then
            Element:Colorpicker(Colorpicker, Config.Window, function(color, transparency)
                Colorpicker:Update(color, transparency)
                Colorpicker.Default = color
                Colorpicker.Transparency = transparency
                Creator.SafeCallback(Colorpicker.Callback, color, transparency)
            end).ColorpickerFrame:Open()
        end
    end)
    
    return Colorpicker.__type, Colorpicker
end

-- Merge ColorpickerModule functions into Element
for k, v in pairs(ColorpickerModule) do
    Element[k] = v
end

-- Return ColorpickerModule instead of Element
return ColorpickerModule
