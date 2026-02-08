local TweenService = game:GetService("TweenService")
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Utils.lua"))()
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Config.lua"))()

local DropdownElement = {}

-- Global dropdown variables
local DropdownCount = 0
local CurrentDropdownGUI = nil

function DropdownElement:Create(DropdownConfig, GuiConfig, configKey, parentContainer)
    DropdownConfig = DropdownConfig or {}
    DropdownConfig.Title = DropdownConfig.Title or "Dropdown"
    DropdownConfig.Content = DropdownConfig.Content or ""
    DropdownConfig.Multi = DropdownConfig.Multi or false
    DropdownConfig.Options = DropdownConfig.Options or {}
    DropdownConfig.Default = DropdownConfig.Default or (DropdownConfig.Multi and {} or nil)
    DropdownConfig.Callback = DropdownConfig.Callback or function() end

    -- Check if config exists
    if configKey and Config.ConfigData[configKey] ~= nil then
        DropdownConfig.Default = Config.ConfigData[configKey]
    end

    local DropdownFunc = { 
        Value = DropdownConfig.Default, 
        Options = DropdownConfig.Options 
    }

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
    Dropdown.Name = "Dropdown"
    Dropdown.Parent = parentContainer

    DropdownButton.Text = ""
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.Name = "ToggleButton"
    DropdownButton.Parent = Dropdown

    UICorner10.CornerRadius = UDim.new(0, 4)
    UICorner10.Parent = Dropdown

    DropdownTitle.Font = Enum.Font.GothamBold
    DropdownTitle.Text = DropdownConfig.Title
    DropdownTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    DropdownTitle.TextSize = 13
    DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
    DropdownTitle.BackgroundTransparency = 1
    DropdownTitle.Position = UDim2.new(0, 10, 0, 10)
    DropdownTitle.Size = UDim2.new(1, -180, 0, 13)
    DropdownTitle.Name = "DropdownTitle"
    DropdownTitle.Parent = Dropdown

    DropdownContent.Font = Enum.Font.GothamBold
    DropdownContent.Text = DropdownConfig.Content
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

    DropdownContent.Size = UDim2.new(1, -180, 0,
        12 + (12 * (DropdownContent.TextBounds.X // DropdownContent.AbsoluteSize.X)))
    DropdownContent.TextWrapped = true
    Dropdown.Size = UDim2.new(1, 0, 0, DropdownContent.AbsoluteSize.Y + 33)

    SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
    SelectOptionsFrame.BackgroundTransparency = 0.95
    SelectOptionsFrame.Position = UDim2.new(1, -7, 0.5, 0)
    SelectOptionsFrame.Size = UDim2.new(0, 148, 0, 30)
    SelectOptionsFrame.Name = "SelectOptionsFrame"
    SelectOptionsFrame.LayoutOrder = DropdownCount
    SelectOptionsFrame.Parent = Dropdown

    UICorner11.CornerRadius = UDim.new(0, 4)
    UICorner11.Parent = SelectOptionsFrame

    OptionSelecting.Font = Enum.Font.GothamBold
    OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
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

    -- Create dropdown container
    local DropdownContainer = Instance.new("Frame")
    DropdownContainer.Size = UDim2.new(1, 0, 1, 0)
    DropdownContainer.BackgroundTransparency = 1
    DropdownContainer.Name = "DropdownContainer_" .. DropdownCount
    DropdownContainer.Parent = nil -- Will be parented later

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

    -- Get the main GUI instance
    local function GetMainGUI()
        if CurrentDropdownGUI then
            return CurrentDropdownGUI
        end
        
        -- Try to find existing GUI
        local screenGui = game:GetService("CoreGui"):FindFirstChild("Chloeex")
        if screenGui then
            CurrentDropdownGUI = screenGui
            return screenGui
        end
        
        -- Create a new dropdown GUI container
        local dropdownScreenGui = Instance.new("ScreenGui")
        dropdownScreenGui.Name = "DropdownGUI"
        dropdownScreenGui.Parent = game:GetService("CoreGui")
        dropdownScreenGui.ResetOnSpawn = false
        dropdownScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        CurrentDropdownGUI = dropdownScreenGui
        return dropdownScreenGui
    end

    -- Create dropdown UI
    local MoreBlur = Instance.new("Frame")
    MoreBlur.AnchorPoint = Vector2.new(1, 1)
    MoreBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BackgroundTransparency = 0.999
    MoreBlur.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BorderSizePixel = 0
    MoreBlur.ClipsDescendants = true
    MoreBlur.Position = UDim2.new(1, 8, 1, 8)
    MoreBlur.Size = UDim2.new(1, 154, 1, 54)
    MoreBlur.Visible = false
    MoreBlur.Name = "MoreBlur"
    MoreBlur.Parent = parentContainer

    local DropdownSelect = Instance.new("Frame")
    DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
    DropdownSelect.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropdownSelect.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DropdownSelect.BorderSizePixel = 0
    DropdownSelect.LayoutOrder = 1
    DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
    DropdownSelect.Size = UDim2.new(0, 160, 1, -16)
    DropdownSelect.Name = "DropdownSelect"
    DropdownSelect.ClipsDescendants = true
    DropdownSelect.Parent = MoreBlur

    local UICorner36 = Instance.new("UICorner")
    UICorner36.CornerRadius = UDim.new(0, 3)
    UICorner36.Parent = DropdownSelect

    local UIStroke14 = Instance.new("UIStroke")
    UIStroke14.Color = Color3.fromRGB(12, 159, 255)
    UIStroke14.Thickness = 2.5
    UIStroke14.Transparency = 0.8
    UIStroke14.Parent = DropdownSelect

    local DropdownSelectReal = Instance.new("Frame")
    DropdownSelectReal.AnchorPoint = Vector2.new(0.5, 0.5)
    DropdownSelectReal.BackgroundColor3 = Color3.fromRGB(0, 27, 98)
    DropdownSelectReal.BackgroundTransparency = 0.7
    DropdownSelectReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DropdownSelectReal.BorderSizePixel = 0
    DropdownSelectReal.LayoutOrder = 1
    DropdownSelectReal.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropdownSelectReal.Size = UDim2.new(1, 1, 1, 1)
    DropdownSelectReal.Name = "DropdownSelectReal"
    DropdownSelectReal.Parent = DropdownSelect

    local DropdownFolder = Instance.new("Folder")
    DropdownFolder.Name = "DropdownFolder"
    DropdownFolder.Parent = DropdownSelectReal

    local DropPageLayout = Instance.new("UIPageLayout")
    DropPageLayout.EasingDirection = Enum.EasingDirection.InOut
    DropPageLayout.EasingStyle = Enum.EasingStyle.Quad
    DropPageLayout.TweenTime = 0.01
    DropPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropPageLayout.FillDirection = Enum.FillDirection.Vertical
    DropPageLayout.Name = "DropPageLayout"
    DropPageLayout.Parent = DropdownFolder

    -- Parent dropdown container to dropdown folder
    DropdownContainer.Parent = DropdownFolder

    -- Connect dropdown button
    DropdownButton.Activated:Connect(function()
        Utils.CircleClick(DropdownButton, 
            game:GetService("Players").LocalPlayer:GetMouse().X, 
            game:GetService("Players").LocalPlayer:GetMouse().Y)
            
        if not MoreBlur.Visible then
            MoreBlur.Visible = true
            DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)
            TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, -11, 0.5, 0) }):Play()
        end
    end)

    -- Close dropdown when clicking outside
    local ConnectButton = Instance.new("TextButton")
    ConnectButton.Text = ""
    ConnectButton.BackgroundTransparency = 1
    ConnectButton.Size = UDim2.new(1, 0, 1, 0)
    ConnectButton.Name = "ConnectButton"
    ConnectButton.Parent = MoreBlur

    ConnectButton.Activated:Connect(function()
        if MoreBlur.Visible then
            TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 0.999 }):Play()
            TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
            task.wait(0.3)
            MoreBlur.Visible = false
        end
    end)

    -- Function to create option
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
        ChooseFrame.BackgroundColor3 = GuiConfig.Color
        ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
        ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
        ChooseFrame.Name = "ChooseFrame"
        ChooseFrame.Parent = Option

        UIStroke15.Color = GuiConfig.Color
        UIStroke15.Thickness = 1.6
        UIStroke15.Transparency = 0.999
        UIStroke15.Parent = ChooseFrame
        UICorner38.Parent = ChooseFrame

        OptionButton.Activated:Connect(function()
            if DropdownConfig.Multi then
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

    -- Function to clear all options
    function DropdownFunc:Clear()
        for _, DropFrame in ScrollSelect:GetChildren() do
            if DropFrame.Name == "Option" then
                DropFrame:Destroy()
            end
        end
        DropdownFunc.Value = DropdownConfig.Multi and {} or nil
        DropdownFunc.Options = {}
        OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
    end

    -- Function to set value
    function DropdownFunc:Set(Value, silent)
        if DropdownConfig.Multi then
            DropdownFunc.Value = type(Value) == "table" and Value or {}
        else
            DropdownFunc.Value = (type(Value) == "table" and Value[1]) or Value
        end

        -- Save to config
        if configKey then
            Config.ConfigData[configKey] = DropdownFunc.Value
            Config.SaveConfig()
        end

        -- Update UI
        local texts = {}
        for _, Drop in ScrollSelect:GetChildren() do
            if Drop.Name == "Option" and Drop:FindFirstChild("OptionText") then
                local v = Drop:GetAttribute("RealValue")
                local selected = DropdownConfig.Multi and table.find(DropdownFunc.Value, v) or
                    DropdownFunc.Value == v

                if selected then
                    TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.2),
                        { Size = UDim2.new(0, 1, 0, 12) }):Play()
                    TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.2), { Transparency = 0 }):Play()
                    TweenService:Create(Drop, TweenInfo.new(0.2), { BackgroundTransparency = 0.935 }):Play()
                    table.insert(texts, Drop.OptionText.Text)
                else
                    TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.1),
                        { Size = UDim2.new(0, 0, 0, 0) }):Play()
                    TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.1),
                        { Transparency = 0.999 }):Play()
                    TweenService:Create(Drop, TweenInfo.new(0.1), { BackgroundTransparency = 0.999 }):Play()
                end
            end
        end

        OptionSelecting.Text = (#texts == 0)
            and (DropdownConfig.Multi and "Select Options" or "Select Option")
            or table.concat(texts, ", ")

        -- Callback (if not silent)
        if not silent and DropdownConfig.Callback then
            local success, err = pcall(function()
                if DropdownConfig.Multi then
                    DropdownConfig.Callback(DropdownFunc.Value)
                else
                    local str = (DropdownFunc.Value ~= nil) and tostring(DropdownFunc.Value) or ""
                    DropdownConfig.Callback(str)
                end
            end)
            if not success then
                warn("Dropdown callback error:", err)
            end
        end
    end

    -- Function to get value
    function DropdownFunc:Get()
        return self.Value
    end

    -- Function to set all values at once
    function DropdownFunc:SetValues(newList, selecting)
        newList = newList or {}
        selecting = selecting or (DropdownConfig.Multi and {} or nil)
        DropdownFunc:Clear()
        for _, v in ipairs(newList) do
            DropdownFunc:AddOption(v)
        end
        DropdownFunc.Options = newList
        DropdownFunc:Set(selecting, true)
    end

    -- Function to get options
    function DropdownFunc:GetOptions()
        return self.Options
    end

    -- Search functionality
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

    -- Auto-update canvas size
    UIListLayout4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
    end)

    -- Initialize with options
    DropdownFunc:SetValues(DropdownConfig.Options, DropdownConfig.Default)

    -- Connect to config system
    if configKey then
        Config.Elements[configKey] = DropdownFunc
    end

    DropdownCount = DropdownCount + 1

    return Dropdown
end

-- Utility functions
function DropdownElement:CreateOption(label, value)
    return {
        Label = label,
        Value = value
    }
end

return DropdownElement
