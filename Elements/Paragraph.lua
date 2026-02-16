return function(ParagraphConfig, ctx)
    local ParagraphConfig = ParagraphConfig or {}
    ParagraphConfig.Title = ParagraphConfig.Title or "Title"
    ParagraphConfig.Content = ParagraphConfig.Content or "Content"
    ParagraphConfig.Icon = ParagraphConfig.Icon
    ParagraphConfig.ButtonText = ParagraphConfig.ButtonText
    ParagraphConfig.ButtonCallback = ParagraphConfig.ButtonCallback

    local ParagraphFunc = {}

    local Paragraph = Instance.new("Frame")
    local UICorner14 = Instance.new("UICorner")
    local ParagraphTitle = Instance.new("TextLabel")
    local ParagraphContent = Instance.new("TextLabel")

    Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Paragraph.BackgroundTransparency = 0.935
    Paragraph.BorderSizePixel = 0
    Paragraph.LayoutOrder = ctx.CountItem()
    Paragraph.Size = UDim2.new(1, 0, 0, 46)
    Paragraph.Name = "Paragraph"
    Paragraph.Parent = ctx.SectionAdd

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

        if ctx.GuiConfig and ctx.GuiConfig.Icons and ctx.GuiConfig.Icons[ParagraphConfig.Icon] then
            IconImg.Image = ctx.GuiConfig.Icons[ParagraphConfig.Icon]
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

    return ParagraphFunc
end
