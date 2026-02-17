-- Elements.lua V0.1.0
-- UI Elements Module for NexaHub
-- FIXED: All public API methods repaired and hardened
-- FIXED: CreateParagraph - SetContent/SetTitle now triggers UpdateSize
-- FIXED: CreateToggle - Value sync sebelum callback, pcall pada Set
-- FIXED: CreateSlider - Round edge-case, TextBox infinite-loop guard, clamp input
-- FIXED: CreateInput - Set() update Value sebelum callback
-- FIXED: CreateDropdown - nil-safe Set(), AddOption() update Options table, Clear() reset benar
-- FIXED: CreateEditableParagraph - SetContent triggers UpdateSize, GetContent added
-- FIXED: CreatePanel - tambah GetValue(), GetInput(), error-safe callbacks
-- FIXED: CreateButton - return ButtonFunc dengan Fire() API

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local Elements = {}

local SaveConfig, ConfigData, GuiConfig, Icons

function Elements:Initialize(config, saveFunc, configData, icons)
    GuiConfig = config
    SaveConfig = saveFunc
    ConfigData = configData
    Icons = icons
end

-- ── Helper: animasi klik tombol ─────────────────────────────────────────────
local function AnimateButtonClick(button, color)
    color = color or GuiConfig.Color
    local origTrans = button.BackgroundTransparency
    local origColor = button.BackgroundColor3

    TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.7,
        BackgroundColor3 = color,
    }):Play()
    task.wait(0.1)
    TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = origTrans,
        BackgroundColor3 = origColor,
    }):Play()
end

-- ── Helper: badge "NEW" dengan animasi pulse ─────────────────────────────────
local function CreateNewBadge(parent)
    local NewBadge = Instance.new("Frame")
    NewBadge.Name = "NewBadge"
    NewBadge.AnchorPoint = Vector2.new(1, 0)
    NewBadge.Position = UDim2.new(1, -8, 0, 8)
    NewBadge.Size = UDim2.new(0, 35, 0, 16)
    NewBadge.BackgroundColor3 = GuiConfig.Color
    NewBadge.BorderSizePixel = 0
    NewBadge.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = NewBadge

    local BadgeText = Instance.new("TextLabel")
    BadgeText.Name = "BadgeText"
    BadgeText.Size = UDim2.new(1, 0, 1, 0)
    BadgeText.BackgroundTransparency = 1
    BadgeText.Font = Enum.Font.GothamBold
    BadgeText.Text = "NEW"
    BadgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    BadgeText.TextSize = 10
    BadgeText.Parent = NewBadge

    local pulseIn = TweenService:Create(NewBadge,
        TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        { Size = UDim2.new(0, 38, 0, 18) })
    local pulseOut = TweenService:Create(NewBadge,
        TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        { Size = UDim2.new(0, 35, 0, 16) })

    pulseIn.Completed:Connect(function() pulseOut:Play() end)
    pulseOut.Completed:Connect(function() pulseIn:Play() end)
    pulseIn:Play()
    return NewBadge
end

-- ── Helper: safe callback ─────────────────────────────────────────────────────
local function SafeCall(fn, ...)
    if typeof(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok then warn("[Elements] Callback error:", err) end
end

-- ── Helper: round slider value ────────────────────────────────────────────────
local function RoundToFactor(value, factor)
    if factor == 0 then return value end
    return math.floor(value / factor + 0.5) * factor
end

-- ─────────────────────────────────────────────────────────────────────────────
--  CreateParagraph
--  FIX: SetContent/SetTitle sekarang trigger UpdateSize
--  FIX: Layout icon diperbaiki agar tidak overlap
-- ─────────────────────────────────────────────────────────────────────────────
function Elements:CreateParagraph(parent, config, countItem)
    local cfg = config or {}
    cfg.Title          = cfg.Title   or "Title"
    cfg.Content        = cfg.Content or "Content"
    cfg.New            = cfg.New     or false
    cfg.Color          = cfg.Color   or nil

    local ParagraphFunc = {}

    local Paragraph = Instance.new("Frame")
    Paragraph.Name = "Paragraph"
    Paragraph.BorderSizePixel = 0
    Paragraph.LayoutOrder = countItem
    Paragraph.Size = UDim2.new(1, 0, 0, 56)
    Paragraph.ClipsDescendants = true
    Paragraph.Parent = parent

    if cfg.Color then
        Paragraph.BackgroundColor3 = cfg.Color
        Paragraph.BackgroundTransparency = 0
    else
        Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Paragraph.BackgroundTransparency = 0.935
    end

    Instance.new("UICorner", Paragraph).CornerRadius = UDim.new(0, 8)

    if cfg.New then CreateNewBadge(Paragraph) end

    -- Icon
    local iconSize = 0
    local iconPadL = 0
    if cfg.Icon then
        iconSize = 36
        iconPadL = 10
        local IconContainer = Instance.new("Frame")
        IconContainer.Name = "IconContainer"
        IconContainer.Position = UDim2.new(0, iconPadL, 0, 10)
        IconContainer.Size = UDim2.new(0, iconSize, 0, iconSize)
        IconContainer.BackgroundTransparency = 1
        IconContainer.Parent = Paragraph

        local IconImg = Instance.new("ImageLabel")
        IconImg.Name = "ParagraphIcon"
        IconImg.Size = UDim2.new(1, 0, 1, 0)
        IconImg.BackgroundTransparency = 1
        IconImg.ScaleType = Enum.ScaleType.Fit
        IconImg.Image = (Icons and Icons[cfg.Icon]) and Icons[cfg.Icon] or tostring(cfg.Icon)
        IconImg.Parent = IconContainer
    end

    local textLeft = iconPadL + iconSize + 10

    local ParagraphTitle = Instance.new("TextLabel")
    ParagraphTitle.Name = "ParagraphTitle"
    ParagraphTitle.Font = Enum.Font.GothamBold
    ParagraphTitle.Text = cfg.Title
    ParagraphTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ParagraphTitle.TextSize = 13
    ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphTitle.BackgroundTransparency = 1
    ParagraphTitle.Position = UDim2.new(0, textLeft, 0, 10)
    ParagraphTitle.Size = UDim2.new(1, -(textLeft + 10), 0, 15)
    ParagraphTitle.TextWrapped = false
    ParagraphTitle.Parent = Paragraph

    local ParagraphContent = Instance.new("TextLabel")
    ParagraphContent.Name = "ParagraphContent"
    ParagraphContent.Font = Enum.Font.GothamBold
    ParagraphContent.Text = cfg.Content
    ParagraphContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    ParagraphContent.TextSize = 11
    ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphContent.BackgroundTransparency = 1
    ParagraphContent.Position = UDim2.new(0, textLeft, 0, 27)
    ParagraphContent.Size = UDim2.new(1, -(textLeft + 10), 0, 12)
    ParagraphContent.TextWrapped = true
    ParagraphContent.RichText = true
    ParagraphContent.Parent = Paragraph

    -- Tombol
    local btnBgColor = cfg.ButtonColor    or Color3.fromRGB(255, 255, 255)
    local subBgColor = cfg.SubButtonColor or Color3.fromRGB(255, 255, 255)
    local btnBgTrans = cfg.ButtonColor    and 0.15 or 0.85
    local subBgTrans = cfg.SubButtonColor and 0.15 or 0.85

    local ParagraphButton, ParagraphSubButton

    if cfg.ButtonText then
        local hasSubBtn = cfg.SubButtonText ~= nil

        ParagraphButton = Instance.new("TextButton")
        ParagraphButton.Name = "ParagraphButton"
        ParagraphButton.BackgroundColor3 = btnBgColor
        ParagraphButton.BackgroundTransparency = btnBgTrans
        ParagraphButton.Font = Enum.Font.GothamBold
        ParagraphButton.TextSize = 12
        ParagraphButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.TextTransparency = 0
        ParagraphButton.Text = cfg.ButtonText
        ParagraphButton.Size = hasSubBtn and UDim2.new(0.5, -13, 0, 28) or UDim2.new(1, -16, 0, 28)
        ParagraphButton.Position = UDim2.new(0, 8, 0, 0)
        ParagraphButton.Parent = Paragraph
        Instance.new("UICorner", ParagraphButton).CornerRadius = UDim.new(0, 6)

        ParagraphButton.MouseButton1Click:Connect(function()
            AnimateButtonClick(ParagraphButton, btnBgColor)
            SafeCall(cfg.ButtonCallback)
        end)

        if hasSubBtn then
            ParagraphSubButton = Instance.new("TextButton")
            ParagraphSubButton.Name = "ParagraphSubButton"
            ParagraphSubButton.BackgroundColor3 = subBgColor
            ParagraphSubButton.BackgroundTransparency = subBgTrans
            ParagraphSubButton.Font = Enum.Font.GothamBold
            ParagraphSubButton.TextSize = 12
            ParagraphSubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ParagraphSubButton.TextTransparency = 0
            ParagraphSubButton.Text = cfg.SubButtonText
            ParagraphSubButton.Size = UDim2.new(0.5, -13, 0, 28)
            ParagraphSubButton.Position = UDim2.new(0.5, 5, 0, 0)
            ParagraphSubButton.Parent = Paragraph
            Instance.new("UICorner", ParagraphSubButton).CornerRadius = UDim.new(0, 6)

            ParagraphSubButton.MouseButton1Click:Connect(function()
                AnimateButtonClick(ParagraphSubButton, subBgColor)
                SafeCall(cfg.SubButtonCallback)
            end)
        end
    end

    -- UpdateSize
    local function UpdateSize()
        task.wait()
        local contentH = math.max(12, ParagraphContent.TextBounds.Y)
        ParagraphContent.Size = UDim2.new(1, -(textLeft + 10), 0, contentH)

        local headerBottom = math.max(10 + 15 + 2 + contentH + 8, iconSize > 0 and (iconSize + 20) or 0)
        local totalH = headerBottom

        if ParagraphButton then
            ParagraphButton.Position = UDim2.new(0, 8, 0, headerBottom)
            if ParagraphSubButton then
                ParagraphSubButton.Position = UDim2.new(0.5, 5, 0, headerBottom)
            end
            totalH = headerBottom + 28 + 8
        end

        Paragraph.Size = UDim2.new(1, 0, 0, totalH)
    end

    UpdateSize()
    ParagraphContent:GetPropertyChangedSignal("Text"):Connect(UpdateSize)
    ParagraphContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)
    Paragraph:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)

    -- ── API ──────────────────────────────────────────────────────────────────
    -- FIX: Set methods sekarang trigger UpdateSize
    function ParagraphFunc:SetContent(content)
        ParagraphContent.Text = tostring(content or "Content")
        UpdateSize()
    end

    function ParagraphFunc:SetTitle(title)
        ParagraphTitle.Text = tostring(title or "Title")
    end

    -- FIX: tambah GetContent & GetTitle
    function ParagraphFunc:GetContent()
        return ParagraphContent.Text
    end

    function ParagraphFunc:GetTitle()
        return ParagraphTitle.Text
    end

    return ParagraphFunc
end

-- ─────────────────────────────────────────────────────────────────────────────
--  CreateEditableParagraph
--  FIX: SetContent triggers UpdateSize
--  FIX: GetContent tersedia (sudah ada, pastikan konsisten)
--  FIX: callback dipanggil dengan SafeCall
-- ─────────────────────────────────────────────────────────────────────────────
function Elements:CreateEditableParagraph(parent, config, countItem)
    local cfg = config or {}
    cfg.Title       = cfg.Title       or "Title"
    cfg.Content     = cfg.Content     or "Type here..."
    cfg.Placeholder = cfg.Placeholder or "Type something..."
    cfg.Callback    = cfg.Callback    or function() end
    cfg.Default     = cfg.Default     or ""
    cfg.New         = cfg.New         or false

    local configKey = "EditableParagraph_" .. cfg.Title
    if ConfigData[configKey] ~= nil then
        cfg.Default = ConfigData[configKey]
    end

    local ParagraphFunc = { Value = cfg.Default }

    local Paragraph     = Instance.new("Frame")
    local UICorner      = Instance.new("UICorner")
    local ParagraphTitle = Instance.new("TextLabel")
    local TextBoxFrame  = Instance.new("Frame")
    local TextBoxCorner = Instance.new("UICorner")
    local ParagraphTextBox = Instance.new("TextBox")

    Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Paragraph.BackgroundTransparency = 0.935
    Paragraph.BorderSizePixel = 0
    Paragraph.LayoutOrder = countItem
    Paragraph.Size = UDim2.new(1, 0, 0, 80)
    Paragraph.Name = "EditableParagraph"
    Paragraph.Parent = parent

    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Paragraph

    if cfg.New then CreateNewBadge(Paragraph) end

    local iconOffset = 10
    if cfg.Icon then
        local IconImg = Instance.new("ImageLabel")
        IconImg.Size = UDim2.new(0, 20, 0, 20)
        IconImg.Position = UDim2.new(0, 8, 0, 10)
        IconImg.BackgroundTransparency = 1
        IconImg.Name = "ParagraphIcon"
        IconImg.Image = (Icons and Icons[cfg.Icon]) and Icons[cfg.Icon] or tostring(cfg.Icon)
        IconImg.Parent = Paragraph
        iconOffset = 35
    end

    ParagraphTitle.Font = Enum.Font.GothamBold
    ParagraphTitle.Text = cfg.Title
    ParagraphTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    ParagraphTitle.TextSize = 13
    ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphTitle.BackgroundTransparency = 1
    ParagraphTitle.Position = UDim2.new(0, iconOffset, 0, 10)
    ParagraphTitle.Size = UDim2.new(1, -iconOffset - 10, 0, 13)
    ParagraphTitle.Name = "ParagraphTitle"
    ParagraphTitle.Parent = Paragraph

    TextBoxFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextBoxFrame.BackgroundTransparency = 0.95
    TextBoxFrame.BorderSizePixel = 0
    TextBoxFrame.Position = UDim2.new(0, 10, 0, 30)
    TextBoxFrame.Size = UDim2.new(1, -20, 0, 40)
    TextBoxFrame.Name = "TextBoxFrame"
    TextBoxFrame.Parent = Paragraph

    TextBoxCorner.CornerRadius = UDim.new(0, 4)
    TextBoxCorner.Parent = TextBoxFrame

    ParagraphTextBox.Font = Enum.Font.Gotham
    ParagraphTextBox.PlaceholderText = cfg.Placeholder
    ParagraphTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    ParagraphTextBox.Text = cfg.Default
    ParagraphTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    ParagraphTextBox.TextSize = 12
    ParagraphTextBox.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphTextBox.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphTextBox.BackgroundTransparency = 1
    ParagraphTextBox.Position = UDim2.new(0, 8, 0, 6)
    ParagraphTextBox.Size = UDim2.new(1, -16, 1, -12)
    ParagraphTextBox.Name = "ParagraphTextBox"
    ParagraphTextBox.TextWrapped = true
    ParagraphTextBox.MultiLine = true
    ParagraphTextBox.ClearTextOnFocus = false
    ParagraphTextBox.RichText = false
    ParagraphTextBox.Parent = TextBoxFrame

    local ParagraphButton
    if cfg.ButtonText then
        ParagraphButton = Instance.new("TextButton")
        ParagraphButton.Size = UDim2.new(1, -20, 0, 28)
        ParagraphButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.BackgroundTransparency = 0.935
        ParagraphButton.Font = Enum.Font.GothamBold
        ParagraphButton.TextSize = 12
        ParagraphButton.TextTransparency = 0.3
        ParagraphButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphButton.Text = cfg.ButtonText
        ParagraphButton.Position = UDim2.new(0, 10, 0, 75)
        ParagraphButton.Parent = Paragraph
        Instance.new("UICorner", ParagraphButton).CornerRadius = UDim.new(0, 6)

        ParagraphButton.MouseButton1Click:Connect(function()
            AnimateButtonClick(ParagraphButton)
            SafeCall(cfg.ButtonCallback, ParagraphTextBox.Text)
        end)
    end

    local function UpdateSize()
        local textHeight = math.max(40, ParagraphTextBox.TextBounds.Y + 12)
        TextBoxFrame.Size = UDim2.new(1, -20, 0, textHeight)
        local totalHeight = 30 + textHeight + 10
        if ParagraphButton then
            ParagraphButton.Position = UDim2.new(0, 10, 0, 30 + textHeight + 5)
            totalHeight = totalHeight + ParagraphButton.Size.Y.Offset + 10
        end
        Paragraph.Size = UDim2.new(1, 0, 0, totalHeight)
    end

    UpdateSize()

    ParagraphTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        UpdateSize()
        ParagraphFunc.Value = ParagraphTextBox.Text
        ConfigData[configKey] = ParagraphTextBox.Text
        SaveConfig()
        SafeCall(cfg.Callback, ParagraphTextBox.Text)
    end)

    ParagraphTextBox:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)
    Paragraph:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)

    -- ── API ──────────────────────────────────────────────────────────────────
    -- FIX: SetContent sekarang trigger UpdateSize dan update Value
    function ParagraphFunc:SetContent(content)
        ParagraphTextBox.Text = tostring(content or "")
        ParagraphFunc.Value = ParagraphTextBox.Text
        UpdateSize()
    end

    function ParagraphFunc:GetContent()
        return ParagraphTextBox.Text
    end

    -- FIX: SetTitle tersedia
    function ParagraphFunc:SetTitle(title)
        ParagraphTitle.Text = tostring(title or "Title")
    end

    function ParagraphFunc:GetTitle()
        return ParagraphTitle.Text
    end

    return ParagraphFunc
end

-- ─────────────────────────────────────────────────────────────────────────────
--  CreatePanel
--  FIX: tambah GetValue(), callback dipanggil dengan SafeCall
--  FIX: GetInput() sekarang safe jika tidak ada InputBox
-- ─────────────────────────────────────────────────────────────────────────────
function Elements:CreatePanel(parent, config, countItem)
    local cfg = config or {}
    cfg.Title            = cfg.Title          or "Title"
    cfg.Content          = cfg.Content        or ""
    cfg.Placeholder      = cfg.Placeholder    or nil
    cfg.Default          = cfg.Default        or ""
    cfg.ButtonText       = cfg.Button         or cfg.ButtonText    or "Confirm"
    cfg.ButtonCallback   = cfg.Callback       or cfg.ButtonCallback or function() end
    cfg.SubButtonText    = cfg.SubButton      or cfg.SubButtonText  or nil
    cfg.SubButtonCallback = cfg.SubCallback  or cfg.SubButtonCallback or function() end
    cfg.New              = cfg.New            or false

    local configKey = "Panel_" .. cfg.Title
    if ConfigData[configKey] ~= nil then
        cfg.Default = ConfigData[configKey]
    end

    local PanelFunc = { Value = cfg.Default }

    local baseHeight = 50
    if cfg.Placeholder then baseHeight = baseHeight + 40 end
    if cfg.SubButtonText then baseHeight = baseHeight + 40 else baseHeight = baseHeight + 36 end

    local Panel = Instance.new("Frame")
    Panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Panel.BackgroundTransparency = 0.935
    Panel.Size = UDim2.new(1, 0, 0, baseHeight)
    Panel.LayoutOrder = countItem
    Panel.Parent = parent

    Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 4)
    if cfg.New then CreateNewBadge(Panel) end

    local Title = Instance.new("TextLabel")
    Title.Font = Enum.Font.GothamBold
    Title.Text = cfg.Title
    Title.TextSize = 13
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Size = UDim2.new(1, -20, 0, 13)
    Title.Parent = Panel

    local Content = Instance.new("TextLabel")
    Content.Font = Enum.Font.Gotham
    Content.Text = cfg.Content
    Content.TextSize = 12
    Content.TextColor3 = Color3.fromRGB(255, 255, 255)
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.BackgroundTransparency = 1
    Content.RichText = true
    Content.Position = UDim2.new(0, 10, 0, 28)
    Content.Size = UDim2.new(1, -20, 0, 14)
    Content.Parent = Panel

    local InputBox
    if cfg.Placeholder then
        local InputFrame = Instance.new("Frame")
        InputFrame.AnchorPoint = Vector2.new(0.5, 0)
        InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputFrame.BackgroundTransparency = 0.95
        InputFrame.Position = UDim2.new(0.5, 0, 0, 48)
        InputFrame.Size = UDim2.new(1, -20, 0, 30)
        InputFrame.Parent = Panel
        Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 4)

        InputBox = Instance.new("TextBox")
        InputBox.Font = Enum.Font.GothamBold
        InputBox.PlaceholderText = cfg.Placeholder
        InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        InputBox.Text = cfg.Default
        InputBox.TextSize = 11
        InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputBox.BackgroundTransparency = 1
        InputBox.TextXAlignment = Enum.TextXAlignment.Left
        InputBox.Size = UDim2.new(1, -10, 1, -6)
        InputBox.Position = UDim2.new(0, 5, 0, 3)
        InputBox.ClearTextOnFocus = false
        InputBox.Parent = InputFrame
    end

    local yBtn = cfg.Placeholder and 88 or 48

    local ButtonMain = Instance.new("TextButton")
    ButtonMain.Font = Enum.Font.GothamBold
    ButtonMain.Text = cfg.ButtonText
    ButtonMain.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonMain.TextSize = 12
    ButtonMain.TextTransparency = 0.3
    ButtonMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ButtonMain.BackgroundTransparency = 0.935
    ButtonMain.Size = cfg.SubButtonText and UDim2.new(0.5, -12, 0, 30) or UDim2.new(1, -20, 0, 30)
    ButtonMain.Position = UDim2.new(0, 10, 0, yBtn)
    ButtonMain.Parent = Panel
    Instance.new("UICorner", ButtonMain).CornerRadius = UDim.new(0, 6)

    ButtonMain.MouseButton1Click:Connect(function()
        AnimateButtonClick(ButtonMain)
        local inputVal = InputBox and InputBox.Text or ""
        PanelFunc.Value = inputVal
        SafeCall(cfg.ButtonCallback, inputVal)
    end)

    if cfg.SubButtonText then
        local SubButton = Instance.new("TextButton")
        SubButton.Font = Enum.Font.GothamBold
        SubButton.Text = cfg.SubButtonText
        SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        SubButton.TextSize = 12
        SubButton.TextTransparency = 0.3
        SubButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SubButton.BackgroundTransparency = 0.935
        SubButton.Size = UDim2.new(0.5, -12, 0, 30)
        SubButton.Position = UDim2.new(0.5, 2, 0, yBtn)
        SubButton.Parent = Panel
        Instance.new("UICorner", SubButton).CornerRadius = UDim.new(0, 6)

        SubButton.MouseButton1Click:Connect(function()
            AnimateButtonClick(SubButton)
            local inputVal = InputBox and InputBox.Text or ""
            SafeCall(cfg.SubButtonCallback, inputVal)
        end)
    end

    if InputBox then
        InputBox.FocusLost:Connect(function()
            PanelFunc.Value = InputBox.Text
            ConfigData[configKey] = InputBox.Text
            SaveConfig()
        end)
    end

    -- ── API ──────────────────────────────────────────────────────────────────
    -- FIX: GetInput() safe jika tidak ada InputBox
    function PanelFunc:GetInput()
        return InputBox and InputBox.Text or ""
    end

    -- FIX: GetValue() tersedia
    function PanelFunc:GetValue()
        return PanelFunc.Value
    end

    -- FIX: SetContent() untuk update label content
    function PanelFunc:SetContent(text)
        Content.Text = tostring(text or "")
    end

    -- FIX: SetTitle() tersedia
    function PanelFunc:SetTitle(text)
        Title.Text = tostring(text or "Title")
    end

    return PanelFunc
end

-- ─────────────────────────────────────────────────────────────────────────────
--  CreateButton
--  FIX: sekarang return ButtonFunc dengan Fire() dan SetTitle() API
--  FIX: SafeCall pada semua callback
-- ─────────────────────────────────────────────────────────────────────────────
function Elements:CreateButton(parent, config, countItem)
    local cfg = config or {}
    cfg.Title       = cfg.Title       or "Confirm"
    cfg.Callback    = cfg.Callback    or function() end
    cfg.SubTitle    = cfg.SubTitle    or nil
    cfg.SubCallback = cfg.SubCallback or function() end
    cfg.New         = cfg.New         or false

    local ButtonFunc = {}

    local Button = Instance.new("Frame")
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundTransparency = 0.935
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.LayoutOrder = countItem
    Button.Parent = parent

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)
    if cfg.New then CreateNewBadge(Button) end

    local MainButton = Instance.new("TextButton")
    MainButton.Font = Enum.Font.GothamBold
    MainButton.Text = cfg.Title
    MainButton.TextSize = 12
    MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainButton.TextTransparency = 0.3
    MainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainButton.BackgroundTransparency = 0.935
    MainButton.Size = cfg.SubTitle and UDim2.new(0.5, -8, 1, -10) or UDim2.new(1, -12, 1, -10)
    MainButton.Position = UDim2.new(0, 6, 0, 5)
    MainButton.Parent = Button
    Instance.new("UICorner", MainButton).CornerRadius = UDim.new(0, 4)

    MainButton.MouseButton1Click:Connect(function()
        AnimateButtonClick(MainButton)
        SafeCall(cfg.Callback)
    end)

    local SubButtonRef
    if cfg.SubTitle then
        SubButtonRef = Instance.new("TextButton")
        SubButtonRef.Font = Enum.Font.GothamBold
        SubButtonRef.Text = cfg.SubTitle
        SubButtonRef.TextSize = 12
        SubButtonRef.TextTransparency = 0.3
        SubButtonRef.TextColor3 = Color3.fromRGB(255, 255, 255)
        SubButtonRef.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SubButtonRef.BackgroundTransparency = 0.935
        SubButtonRef.Size = UDim2.new(0.5, -8, 1, -10)
        SubButtonRef.Position = UDim2.new(0.5, 2, 0, 5)
        SubButtonRef.Parent = Button
        Instance.new("UICorner", SubButtonRef).CornerRadius = UDim.new(0, 4)

        SubButtonRef.MouseButton1Click:Connect(function()
            AnimateButtonClick(SubButtonRef)
            SafeCall(cfg.SubCallback)
        end)
    end

    -- ── API ──────────────────────────────────────────────────────────────────
    -- FIX: Fire() untuk trigger tombol utama secara programatik
    function ButtonFunc:Fire()
        AnimateButtonClick(MainButton)
        SafeCall(cfg.Callback)
    end

    -- FIX: FireSub() untuk trigger tombol kedua secara programatik
    function ButtonFunc:FireSub()
        if SubButtonRef then
            AnimateButtonClick(SubButtonRef)
            SafeCall(cfg.SubCallback)
        end
    end

    -- FIX: SetTitle() untuk ganti label tombol
    function ButtonFunc:SetTitle(text)
        MainButton.Text = tostring(text or "Confirm")
        cfg.Title = MainButton.Text
    end

    function ButtonFunc:SetSubTitle(text)
        if SubButtonRef then
            SubButtonRef.Text = tostring(text or "")
            cfg.SubTitle = SubButtonRef.Text
        end
    end

    -- FIX: SetCallback() untuk ganti callback
    function ButtonFunc:SetCallback(fn)
        cfg.Callback = typeof(fn) == "function" and fn or function() end
    end

    function ButtonFunc:SetSubCallback(fn)
        cfg.SubCallback = typeof(fn) == "function" and fn or function() end
    end

    return ButtonFunc
end

-- ─────────────────────────────────────────────────────────────────────────────
--  CreateToggle
--  FIX: Set() sekarang update ToggleFunc.Value SEBELUM callback
--  FIX: SafeCall menggantikan pcall manual
--  FIX: Set(nil) di-handle dengan aman (default false)
-- ─────────────────────────────────────────────────────────────────────────────
function Elements:CreateToggle(parent, config, countItem, updateSectionSize, Elements_Table)
    local cfg = config or {}
    cfg.Title    = cfg.Title    or "Title"
    cfg.Title2   = cfg.Title2   or ""
    cfg.Content  = cfg.Content  or ""
    cfg.Default  = cfg.Default  or false
    cfg.Callback = cfg.Callback or function() end
    cfg.New      = cfg.New      or false

    local configKey = "Toggle_" .. cfg.Title
    if ConfigData[configKey] ~= nil then
        cfg.Default = ConfigData[configKey]
    end

    -- FIX: pastikan Default adalah boolean, bukan nil/string
    if typeof(cfg.Default) ~= "boolean" then
        cfg.Default = cfg.Default and true or false
    end

    local ToggleFunc = { Value = cfg.Default }

    local Toggle       = Instance.new("Frame")
    local UICorner20   = Instance.new("UICorner")
    local ToggleTitle  = Instance.new("TextLabel")
    local ToggleTitle2 = Instance.new("TextLabel")
    local ToggleContent = Instance.new("TextLabel")
    local ToggleButton = Instance.new("TextButton")
    local FeatureFrame = Instance.new("Frame")
    local UICorner22   = Instance.new("UICorner")
    local UIStroke8    = Instance.new("UIStroke")
    local ToggleCircle = Instance.new("Frame")
    local UICorner23   = Instance.new("UICorner")

    Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.BackgroundTransparency = 0.935
    Toggle.BorderSizePixel = 0
    Toggle.LayoutOrder = countItem
    Toggle.Name = "Toggle"
    Toggle.Parent = parent

    UICorner20.CornerRadius = UDim.new(0, 4)
    UICorner20.Parent = Toggle

    if cfg.New then CreateNewBadge(Toggle) end

    ToggleTitle.Font = Enum.Font.GothamBold
    ToggleTitle.Text = cfg.Title
    ToggleTitle.TextSize = 13
    ToggleTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
    ToggleTitle.BackgroundTransparency = 1
    ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
    ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
    ToggleTitle.Name = "ToggleTitle"
    ToggleTitle.Parent = Toggle

    ToggleTitle2.Font = Enum.Font.GothamBold
    ToggleTitle2.Text = cfg.Title2
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
    ToggleContent.Text = cfg.Content
    ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleContent.TextSize = 12
    ToggleContent.TextTransparency = 0.6
    ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
    ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
    ToggleContent.BackgroundTransparency = 1
    ToggleContent.Name = "ToggleContent"
    ToggleContent.Parent = Toggle

    if cfg.Title2 ~= "" then
        Toggle.Size = UDim2.new(1, 0, 0, 57)
        ToggleContent.Position = UDim2.new(0, 10, 0, 36)
        ToggleTitle2.Visible = true
    else
        Toggle.Size = UDim2.new(1, 0, 0, 46)
        ToggleContent.Position = UDim2.new(0, 10, 0, 23)
        ToggleTitle2.Visible = false
    end

    ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * (ToggleContent.TextBounds.X // math.max(1, ToggleContent.AbsoluteSize.X))))
    ToggleContent.TextWrapped = true

    if cfg.Title2 ~= "" then
        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
    else
        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
    end

    ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        ToggleContent.TextWrapped = false
        ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * (ToggleContent.TextBounds.X // math.max(1, ToggleContent.AbsoluteSize.X))))
        if cfg.Title2 ~= "" then
            Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
        else
            Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
        end
        ToggleContent.TextWrapped = true
        if updateSectionSize then updateSectionSize() end
    end)

    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.Text = ""
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = Toggle

    FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
    FeatureFrame.BackgroundTransparency = 0.92
    FeatureFrame.BorderSizePixel = 0
    FeatureFrame.Position = UDim2.new(1, -15, 0.5, 0)
    FeatureFrame.Size = UDim2.new(0, 30, 0, 15)
    FeatureFrame.Name = "FeatureFrame"
    FeatureFrame.Parent = Toggle

    UICorner22.Parent = FeatureFrame

    UIStroke8.Color = Color3.fromRGB(255, 255, 255)
    UIStroke8.Thickness = 2
    UIStroke8.Transparency = 0.9
    UIStroke8.Parent = FeatureFrame

    ToggleCircle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
    ToggleCircle.Name = "ToggleCircle"
    ToggleCircle.Parent = FeatureFrame

    UICorner23.CornerRadius = UDim.new(0, 15)
    UICorner23.Parent = ToggleCircle

    ToggleButton.Activated:Connect(function()
        ToggleFunc:Set(not ToggleFunc.Value)
    end)

    -- ── API ──────────────────────────────────────────────────────────────────
    function ToggleFunc:Set(Value)
        -- FIX: normalize ke boolean
        Value = Value and true or false

        -- FIX: update Value SEBELUM callback dipanggil
        ToggleFunc.Value = Value
        ConfigData[configKey] = Value
        SaveConfig()

        -- FIX: SafeCall menggantikan manual pcall
        SafeCall(cfg.Callback, Value)

        if Value then
            TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 15, 0, 0) }):Play()
            TweenService:Create(UIStroke8, TweenInfo.new(0.2), { Color = GuiConfig.Color, Transparency = 0 }):Play()
            TweenService:Create(FeatureFrame, TweenInfo.new(0.2), { BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0 }):Play()
        else
            TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 0, 0, 0) }):Play()
            TweenService:Create(UIStroke8, TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
            TweenService:Create(FeatureFrame, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
        end
    end

    -- FIX: GetValue() tersedia
    function ToggleFunc:GetValue()
        return ToggleFunc.Value
    end

    ToggleFunc:Set(ToggleFunc.Value)
    Elements_Table[configKey] = ToggleFunc
    return ToggleFunc
end

-- ─────────────────────────────────────────────────────────────────────────────
--  CreateSlider
--  FIX: Round() infinite-loop / edge-case di-fix dengan RoundToFactor()
--  FIX: TextBox input loop guard (ignore perubahan dari Set sendiri)
--  FIX: Set() clamp dan round sebelum apply
--  FIX: SafeCall pada Callback
-- ─────────────────────────────────────────────────────────────────────────────
function Elements:CreateSlider(parent, config, countItem, updateSectionSize, Elements_Table)
    local cfg = config or {}
    cfg.Title     = cfg.Title     or "Slider"
    cfg.Content   = cfg.Content   or ""
    cfg.Increment = cfg.Increment or 1
    cfg.Min       = cfg.Min       or 0
    cfg.Max       = cfg.Max       or 100
    cfg.Default   = cfg.Default   or 50
    cfg.Callback  = cfg.Callback  or function() end
    cfg.New       = cfg.New       or false

    -- FIX: pastikan Min < Max
    if cfg.Min >= cfg.Max then cfg.Max = cfg.Min + 1 end
    -- FIX: pastikan Increment > 0
    if cfg.Increment <= 0 then cfg.Increment = 1 end

    local configKey = "Slider_" .. cfg.Title
    if ConfigData[configKey] ~= nil then
        cfg.Default = ConfigData[configKey]
    end

    local SliderFunc = { Value = cfg.Default }

    local Slider        = Instance.new("Frame")
    local UICorner15    = Instance.new("UICorner")
    local SliderTitle   = Instance.new("TextLabel")
    local SliderContent = Instance.new("TextLabel")
    local SliderInput   = Instance.new("Frame")
    local UICorner16    = Instance.new("UICorner")
    local TextBox       = Instance.new("TextBox")
    local SliderFrame   = Instance.new("Frame")
    local UICorner17    = Instance.new("UICorner")
    local SliderDraggable = Instance.new("Frame")
    local UICorner18    = Instance.new("UICorner")
    local SliderCircle  = Instance.new("Frame")
    local UICorner19    = Instance.new("UICorner")
    local UIStroke6     = Instance.new("UIStroke")

    Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Slider.BackgroundTransparency = 0.935
    Slider.BorderSizePixel = 0
    Slider.LayoutOrder = countItem
    Slider.Size = UDim2.new(1, 0, 0, 46)
    Slider.Name = "Slider"
    Slider.Parent = parent

    UICorner15.CornerRadius = UDim.new(0, 4)
    UICorner15.Parent = Slider

    if cfg.New then CreateNewBadge(Slider) end

    SliderTitle.Font = Enum.Font.GothamBold
    SliderTitle.Text = cfg.Title
    SliderTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    SliderTitle.TextSize = 13
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Position = UDim2.new(0, 10, 0, 10)
    SliderTitle.Size = UDim2.new(1, -180, 0, 13)
    SliderTitle.Name = "SliderTitle"
    SliderTitle.Parent = Slider

    SliderContent.Font = Enum.Font.GothamBold
    SliderContent.Text = cfg.Content
    SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderContent.TextSize = 12
    SliderContent.TextTransparency = 0.6
    SliderContent.TextXAlignment = Enum.TextXAlignment.Left
    SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
    SliderContent.BackgroundTransparency = 1
    SliderContent.Position = UDim2.new(0, 10, 0, 25)
    SliderContent.Size = UDim2.new(1, -180, 0, 12)
    SliderContent.Name = "SliderContent"
    SliderContent.Parent = Slider

    SliderContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (SliderContent.TextBounds.X // math.max(1, SliderContent.AbsoluteSize.X))))
    SliderContent.TextWrapped = true
    Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)

    SliderContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        SliderContent.TextWrapped = false
        SliderContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (SliderContent.TextBounds.X // math.max(1, SliderContent.AbsoluteSize.X))))
        Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
        SliderContent.TextWrapped = true
        if updateSectionSize then updateSectionSize() end
    end)

    SliderInput.AnchorPoint = Vector2.new(0, 0.5)
    SliderInput.BackgroundColor3 = GuiConfig.Color
    SliderInput.BackgroundTransparency = 1
    SliderInput.BorderSizePixel = 0
    SliderInput.Position = UDim2.new(1, -155, 0.5, 0)
    SliderInput.Size = UDim2.new(0, 28, 0, 20)
    SliderInput.Name = "SliderInput"
    SliderInput.Parent = Slider

    UICorner16.CornerRadius = UDim.new(0, 2)
    UICorner16.Parent = SliderInput

    TextBox.Font = Enum.Font.GothamBold
    TextBox.Text = tostring(cfg.Default)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.TextSize = 13
    TextBox.TextWrapped = true
    TextBox.BackgroundTransparency = 1
    TextBox.BorderSizePixel = 0
    TextBox.Position = UDim2.new(0, -1, 0, 0)
    TextBox.Size = UDim2.new(1, 0, 1, 0)
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = SliderInput

    SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderFrame.BackgroundTransparency = 0.8
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
    SliderFrame.Size = UDim2.new(0, 100, 0, 3)
    SliderFrame.Name = "SliderFrame"
    SliderFrame.Parent = Slider

    UICorner17.Parent = SliderFrame

    SliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
    SliderDraggable.BackgroundColor3 = GuiConfig.Color
    SliderDraggable.BorderSizePixel = 0
    SliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
    SliderDraggable.Size = UDim2.new(0.9, 0, 0, 1)
    SliderDraggable.Name = "SliderDraggable"
    SliderDraggable.Parent = SliderFrame

    UICorner18.Parent = SliderDraggable

    SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
    SliderCircle.BackgroundColor3 = GuiConfig.Color
    SliderCircle.BorderSizePixel = 0
    SliderCircle.Position = UDim2.new(1, 4, 0.5, 0)
    SliderCircle.Size = UDim2.new(0, 8, 0, 8)
    SliderCircle.Name = "SliderCircle"
    SliderCircle.Parent = SliderDraggable

    UICorner19.Parent = SliderCircle

    UIStroke6.Color = GuiConfig.Color
    UIStroke6.Parent = SliderCircle

    local Dragging = false
    -- FIX: guard agar Set() tidak re-trigger TextBox Changed secara loop
    local _settingFromCode = false

    -- ── API ──────────────────────────────────────────────────────────────────
    function SliderFunc:Set(Value)
        -- FIX: gunakan RoundToFactor yang aman
        Value = math.clamp(RoundToFactor(tonumber(Value) or cfg.Min, cfg.Increment), cfg.Min, cfg.Max)
        SliderFunc.Value = Value

        _settingFromCode = true
        TextBox.Text = tostring(Value)
        _settingFromCode = false

        local scale = (Value - cfg.Min) / (cfg.Max - cfg.Min)
        TweenService:Create(
            SliderDraggable,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.fromScale(scale, 1) }
        ):Play()

        SafeCall(cfg.Callback, Value)
        ConfigData[configKey] = Value
        SaveConfig()
    end

    -- FIX: GetValue() tersedia
    function SliderFunc:GetValue()
        return SliderFunc.Value
    end

    -- FIX: SetMin/SetMax untuk update batas secara dinamis
    function SliderFunc:SetMin(min)
        cfg.Min = tonumber(min) or cfg.Min
        if cfg.Min >= cfg.Max then cfg.Max = cfg.Min + 1 end
        SliderFunc:Set(SliderFunc.Value)
    end

    function SliderFunc:SetMax(max)
        cfg.Max = tonumber(max) or cfg.Max
        if cfg.Max <= cfg.Min then cfg.Min = cfg.Max - 1 end
        SliderFunc:Set(SliderFunc.Value)
    end

    -- Drag input
    SliderFrame.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            TweenService:Create(SliderCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 14, 0, 14) }):Play()
            local SizeScale = math.clamp((Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
            SliderFunc:Set(cfg.Min + ((cfg.Max - cfg.Min) * SizeScale))
        end
    end)

    SliderFrame.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            TweenService:Create(SliderCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 8, 0, 8) }):Play()
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local SizeScale = math.clamp((Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
            SliderFunc:Set(cfg.Min + ((cfg.Max - cfg.Min) * SizeScale))
        end
    end)

    -- FIX: guard infinite-loop dari TextBox yang diubah oleh Set()
    TextBox.FocusLost:Connect(function()
        if _settingFromCode then return end
        local raw = TextBox.Text:gsub("[^%d%-%.]+", "")
        local num = tonumber(raw)
        if num then
            SliderFunc:Set(num)
        else
            -- restore ke value saat ini kalau input tidak valid
            _settingFromCode = true
            TextBox.Text = tostring(SliderFunc.Value)
            _settingFromCode = false
        end
    end)

    SliderFunc:Set(cfg.Default)
    Elements_Table[configKey] = SliderFunc
    return SliderFunc
end

-- ─────────────────────────────────────────────────────────────────────────────
--  CreateInput
--  FIX: Set() update Value SEBELUM callback, bukan setelah
--  FIX: SafeCall pada Callback
--  FIX: GetValue() tersedia
-- ─────────────────────────────────────────────────────────────────────────────
function Elements:CreateInput(parent, config, countItem, updateSectionSize, Elements_Table)
    local cfg = config or {}
    cfg.Title    = cfg.Title    or "Title"
    cfg.Content  = cfg.Content  or ""
    cfg.Callback = cfg.Callback or function() end
    cfg.Default  = cfg.Default  or ""
    cfg.New      = cfg.New      or false

    local configKey = "Input_" .. cfg.Title
    if ConfigData[configKey] ~= nil then
        cfg.Default = ConfigData[configKey]
    end

    local InputFunc = { Value = cfg.Default }

    local Input        = Instance.new("Frame")
    local UICorner12   = Instance.new("UICorner")
    local InputTitle   = Instance.new("TextLabel")
    local InputContent = Instance.new("TextLabel")
    local InputFrame   = Instance.new("Frame")
    local UICorner13   = Instance.new("UICorner")
    local InputTextBox = Instance.new("TextBox")

    Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Input.BackgroundTransparency = 0.935
    Input.BorderSizePixel = 0
    Input.LayoutOrder = countItem
    Input.Size = UDim2.new(1, 0, 0, 46)
    Input.Name = "Input"
    Input.Parent = parent

    UICorner12.CornerRadius = UDim.new(0, 4)
    UICorner12.Parent = Input

    if cfg.New then CreateNewBadge(Input) end

    InputTitle.Font = Enum.Font.GothamBold
    InputTitle.Text = cfg.Title
    InputTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
    InputTitle.TextSize = 13
    InputTitle.TextXAlignment = Enum.TextXAlignment.Left
    InputTitle.TextYAlignment = Enum.TextYAlignment.Top
    InputTitle.BackgroundTransparency = 1
    InputTitle.Position = UDim2.new(0, 10, 0, 10)
    InputTitle.Size = UDim2.new(1, -180, 0, 13)
    InputTitle.Name = "InputTitle"
    InputTitle.Parent = Input

    InputContent.Font = Enum.Font.GothamBold
    InputContent.Text = cfg.Content
    InputContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputContent.TextSize = 12
    InputContent.TextTransparency = 0.6
    InputContent.TextWrapped = true
    InputContent.TextXAlignment = Enum.TextXAlignment.Left
    InputContent.TextYAlignment = Enum.TextYAlignment.Bottom
    InputContent.BackgroundTransparency = 1
    InputContent.Position = UDim2.new(0, 10, 0, 25)
    InputContent.Size = UDim2.new(1, -180, 0, 12)
    InputContent.Name = "InputContent"
    InputContent.Parent = Input

    InputContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (InputContent.TextBounds.X // math.max(1, InputContent.AbsoluteSize.X))))
    InputContent.TextWrapped = true
    Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)

    InputContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        InputContent.TextWrapped = false
        InputContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (InputContent.TextBounds.X // math.max(1, InputContent.AbsoluteSize.X))))
        Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)
        InputContent.TextWrapped = true
        if updateSectionSize then updateSectionSize() end
    end)

    InputFrame.AnchorPoint = Vector2.new(1, 0.5)
    InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InputFrame.BackgroundTransparency = 0.95
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
    InputTextBox.Text = cfg.Default
    InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputTextBox.TextSize = 12
    InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
    InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
    InputTextBox.BackgroundTransparency = 1
    InputTextBox.BorderSizePixel = 0
    InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
    InputTextBox.Size = UDim2.new(1, -10, 1, -8)
    InputTextBox.ClearTextOnFocus = false
    InputTextBox.Name = "InputTextBox"
    InputTextBox.Parent = InputFrame

    -- ── API ──────────────────────────────────────────────────────────────────
    function InputFunc:Set(Value)
        Value = tostring(Value or "")
        -- FIX: update Value SEBELUM callback dan SEBELUM update TextBox
        InputFunc.Value = Value
        InputTextBox.Text = Value
        ConfigData[configKey] = Value
        SaveConfig()
        SafeCall(cfg.Callback, Value)
    end

    -- FIX: GetValue() tersedia
    function InputFunc:GetValue()
        return InputFunc.Value
    end

    -- FIX: Clear() tersedia
    function InputFunc:Clear()
        InputFunc:Set("")
    end

    InputTextBox.FocusLost:Connect(function()
        InputFunc:Set(InputTextBox.Text)
    end)

    InputFunc:Set(InputFunc.Value)
    Elements_Table[configKey] = InputFunc
    return InputFunc
end

-- ─────────────────────────────────────────────────────────────────────────────
--  CreateDropdown
--  FIX: Set() nil-safe untuk single dan multi mode
--  FIX: AddOption() sekarang update DropdownFunc.Options
--  FIX: Clear() reset Value dengan benar sesuai mode
--  FIX: SetValues() tidak crash jika dipanggil dengan nil
--  FIX: SafeCall pada Callback
-- ─────────────────────────────────────────────────────────────────────────────
function Elements:CreateDropdown(parent, config, countItem, countDropdown, DropdownFolder, MoreBlur, DropdownSelect, DropPageLayout, Elements_Table)
    local cfg = config or {}
    cfg.Title    = cfg.Title    or "Title"
    cfg.Content  = cfg.Content  or ""
    cfg.Multi    = cfg.Multi    or false
    cfg.Options  = cfg.Options  or {}
    cfg.Default  = cfg.Default  or (cfg.Multi and {} or nil)
    cfg.Callback = cfg.Callback or function() end
    cfg.New      = cfg.New      or false

    local configKey = "Dropdown_" .. cfg.Title
    if ConfigData[configKey] ~= nil then
        cfg.Default = ConfigData[configKey]
    end

    local DropdownFunc = { Value = cfg.Default, Options = {} }

    local Dropdown        = Instance.new("Frame")
    local DropdownButton  = Instance.new("TextButton")
    local UICorner10      = Instance.new("UICorner")
    local DropdownTitle   = Instance.new("TextLabel")
    local DropdownContent = Instance.new("TextLabel")
    local SelectOptionsFrame = Instance.new("Frame")
    local UICorner11      = Instance.new("UICorner")
    local OptionSelecting = Instance.new("TextLabel")
    local OptionImg       = Instance.new("ImageLabel")

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

    if cfg.New then CreateNewBadge(Dropdown) end

    DropdownTitle.Font = Enum.Font.GothamBold
    DropdownTitle.Text = cfg.Title
    DropdownTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    DropdownTitle.TextSize = 13
    DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
    DropdownTitle.BackgroundTransparency = 1
    DropdownTitle.Position = UDim2.new(0, 10, 0, 10)
    DropdownTitle.Size = UDim2.new(1, -180, 0, 13)
    DropdownTitle.Name = "DropdownTitle"
    DropdownTitle.Parent = Dropdown

    DropdownContent.Font = Enum.Font.GothamBold
    DropdownContent.Text = cfg.Content
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

    DropdownButton.Activated:Connect(function()
        if not MoreBlur.Visible then
            MoreBlur.Visible = true
            DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)
            TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, -11, 0.5, 0) }):Play()
        end
    end)

    OptionSelecting.Font = Enum.Font.GothamBold
    OptionSelecting.Text = cfg.Multi and "Select Options" or "Select Option"
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

    local DropdownContainer = Instance.new("Frame")
    DropdownContainer.Size = UDim2.new(1, 0, 1, 0)
    DropdownContainer.BackgroundTransparency = 1
    DropdownContainer.Parent = DropdownFolder

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
                option.Visible = query == "" or string.find(text, query, 1, true) ~= nil
            end
        end
    end)

    -- ── API ──────────────────────────────────────────────────────────────────

    -- FIX: Clear() reset Value sesuai mode dan hapus semua option frame
    function DropdownFunc:Clear()
        for _, child in ScrollSelect:GetChildren() do
            if child.Name == "Option" then child:Destroy() end
        end
        DropdownFunc.Value = cfg.Multi and {} or nil
        DropdownFunc.Options = {}
        OptionSelecting.Text = cfg.Multi and "Select Options" or "Select Option"
    end

    -- FIX: AddOption() update DropdownFunc.Options
    function DropdownFunc:AddOption(option)
        local label, value
        if typeof(option) == "table" and option.Label and option.Value ~= nil then
            label = tostring(option.Label)
            value = option.Value
        else
            label = tostring(option)
            value = option
        end

        -- FIX: track di Options list
        table.insert(DropdownFunc.Options, option)

        local Option = Instance.new("Frame")
        Instance.new("UICorner", Option).CornerRadius = UDim.new(0, 3)
        Option.BackgroundTransparency = 0.999
        Option.Size = UDim2.new(1, 0, 0, 30)
        Option.Name = "Option"
        Option.Parent = ScrollSelect

        local OptionButton = Instance.new("TextButton")
        OptionButton.BackgroundTransparency = 1
        OptionButton.Size = UDim2.new(1, 0, 1, 0)
        OptionButton.Text = ""
        OptionButton.Name = "OptionButton"
        OptionButton.Parent = Option

        local OptionText = Instance.new("TextLabel")
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

        local ChooseFrame = Instance.new("Frame")
        ChooseFrame.AnchorPoint = Vector2.new(0, 0.5)
        ChooseFrame.BackgroundColor3 = GuiConfig.Color
        ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
        ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
        ChooseFrame.Name = "ChooseFrame"
        ChooseFrame.Parent = Option
        Instance.new("UICorner", ChooseFrame)

        local UIStroke = Instance.new("UIStroke")
        UIStroke.Color = GuiConfig.Color
        UIStroke.Thickness = 1.6
        UIStroke.Transparency = 0.999
        UIStroke.Name = "UIStroke"
        UIStroke.Parent = ChooseFrame

        OptionButton.Activated:Connect(function()
            if cfg.Multi then
                local idx = table.find(DropdownFunc.Value, value)
                if not idx then
                    table.insert(DropdownFunc.Value, value)
                else
                    table.remove(DropdownFunc.Value, idx)
                end
                DropdownFunc:Set(DropdownFunc.Value)
            else
                -- FIX: toggle deselect jika klik item yang sama
                if DropdownFunc.Value == value then
                    DropdownFunc:Set(nil)
                else
                    DropdownFunc:Set(value)
                end
            end
        end)
    end

    -- FIX: Set() nil-safe untuk single dan multi
    function DropdownFunc:Set(Value)
        if cfg.Multi then
            if type(Value) == "table" then
                DropdownFunc.Value = Value
            elseif Value == nil then
                DropdownFunc.Value = {}
            else
                -- single value dimasukkan ke table
                DropdownFunc.Value = { Value }
            end
        else
            -- FIX: handle table input untuk mode single
            if type(Value) == "table" then
                DropdownFunc.Value = Value[1]
            else
                DropdownFunc.Value = Value  -- bisa nil (deselect)
            end
        end

        ConfigData[configKey] = DropdownFunc.Value
        SaveConfig()

        local texts = {}
        for _, Drop in ScrollSelect:GetChildren() do
            if Drop.Name == "Option" and Drop:FindFirstChild("OptionText") then
                local v = Drop:GetAttribute("RealValue")
                local selected = cfg.Multi
                    and (type(DropdownFunc.Value) == "table" and table.find(DropdownFunc.Value, v) ~= nil)
                    or (DropdownFunc.Value == v)

                local cf = Drop:FindFirstChild("ChooseFrame")
                local st = cf and cf:FindFirstChild("UIStroke")

                if selected then
                    if cf then TweenService:Create(cf, TweenInfo.new(0.2), { Size = UDim2.new(0, 1, 0, 12) }):Play() end
                    if st then TweenService:Create(st, TweenInfo.new(0.2), { Transparency = 0 }):Play() end
                    TweenService:Create(Drop, TweenInfo.new(0.2), { BackgroundTransparency = 0.935 }):Play()
                    table.insert(texts, Drop.OptionText.Text)
                else
                    if cf then TweenService:Create(cf, TweenInfo.new(0.1), { Size = UDim2.new(0, 0, 0, 0) }):Play() end
                    if st then TweenService:Create(st, TweenInfo.new(0.1), { Transparency = 0.999 }):Play() end
                    TweenService:Create(Drop, TweenInfo.new(0.1), { BackgroundTransparency = 0.999 }):Play()
                end
            end
        end

        OptionSelecting.Text = (#texts == 0)
            and (cfg.Multi and "Select Options" or "Select Option")
            or table.concat(texts, ", ")

        -- FIX: SafeCall dan kirim value yang benar sesuai mode
        if cfg.Multi then
            SafeCall(cfg.Callback, DropdownFunc.Value)
        else
            SafeCall(cfg.Callback, DropdownFunc.Value ~= nil and tostring(DropdownFunc.Value) or nil)
        end
    end

    function DropdownFunc:SetValue(val) self:Set(val) end
    function DropdownFunc:GetValue() return self.Value end

    -- FIX: SetValues() safe jika argumen nil
    function DropdownFunc:SetValues(newList, selecting)
        newList   = newList   or {}
        selecting = selecting or (cfg.Multi and {} or nil)
        DropdownFunc:Clear()
        for _, v in ipairs(newList) do
            DropdownFunc:AddOption(v)
        end
        DropdownFunc:Set(selecting)
    end

    DropdownFunc:SetValues(cfg.Options, cfg.Default)
    Elements_Table[configKey] = DropdownFunc
    return DropdownFunc
end

-- ─────────────────────────────────────────────────────────────────────────────
--  CreateDivider — tidak ada perubahan fungsional, hanya cleanup kecil
-- ─────────────────────────────────────────────────────────────────────────────
function Elements:CreateDivider(parent, countItem)
    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.AnchorPoint = Vector2.new(0.5, 0)
    Divider.Position = UDim2.new(0.5, 0, 0, 0)
    Divider.Size = UDim2.new(1, 0, 0, 2)
    Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Divider.BackgroundTransparency = 0
    Divider.BorderSizePixel = 0
    Divider.LayoutOrder = countItem
    Divider.Parent = parent

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
        ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)),
    }
    UIGradient.Parent = Divider
    Instance.new("UICorner", Divider).CornerRadius = UDim.new(0, 2)

    return Divider
end

-- ─────────────────────────────────────────────────────────────────────────────
--  CreateSubSection — tidak ada perubahan fungsional
-- ─────────────────────────────────────────────────────────────────────────────
function Elements:CreateSubSection(parent, title, countItem)
    title = title or "Sub Section"

    local SubSection = Instance.new("Frame")
    SubSection.Name = "SubSection"
    SubSection.BackgroundTransparency = 1
    SubSection.Size = UDim2.new(1, 0, 0, 22)
    SubSection.LayoutOrder = countItem
    SubSection.Parent = parent

    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Background.BackgroundTransparency = 0.935
    Background.BorderSizePixel = 0
    Background.Parent = SubSection
    Instance.new("UICorner", Background).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.AnchorPoint = Vector2.new(0, 0.5)
    Label.Position = UDim2.new(0, 10, 0.5, 0)
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = "── [ " .. title .. " ] ──"
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SubSection

    return SubSection
end

return Elements
