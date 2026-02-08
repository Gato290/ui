-- ChloeX UI Library - Tab System Module
-- Version: V0.0.3
-- Part 3 of 3

local TabSystem = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Constants
local ANIMATION_DURATION = 0.3
local TAB_HEIGHT = 36
local SECTION_HEIGHT = 32

-- Ripple Effect (Optimized)
local function CreateRipple(parent, position, color)
    parent.ClipsDescendants = true
    
    local ripple = Instance.new("Frame")
    ripple.Name = "RippleEffect"
    ripple.BackgroundColor3 = color or Color3.fromRGB(200, 200, 200)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.ZIndex = 10
    ripple.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    -- Calculate position
    local parentPos = parent.AbsolutePosition
    local parentSize = parent.AbsoluteSize
    local relativeX = (position.X - parentPos.X) / parentSize.X
    local relativeY = (position.Y - parentPos.Y) / parentSize.Y
    
    ripple.Position = UDim2.new(relativeX, -1, relativeY, -1)
    ripple.Size = UDim2.new(0, 2, 0, 2)
    
    -- Animate
    local maxSize = math.max(parentSize.X, parentSize.Y) * 2
    local expand = TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        Position = UDim2.new(0.5, -maxSize/2, 0.5, -maxSize/2),
        BackgroundTransparency = 1
    })
    
    expand:Play()
    expand.Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Tab Manager
local TabManager = {
    ActiveTabs = {},
    ActiveSections = {},
    CurrentTab = nil,
    CurrentSection = nil
}

-- Tab Creation
function TabSystem:Create(tabContainer, contentContainer, tabTitle, config, getIcon, configManager, elementManager, uiElements)
    config = config or {}
    local themeColor = config.Color or Color3.fromRGB(255, 0, 255)
    
    local tabSystem = {
        Tabs = {},
        ActiveTab = nil,
        ActiveSections = {},
        TabCount = 0,
        SectionCount = 0
    }
    
    -- Tab scroller
    local tabScroller = Instance.new("ScrollingFrame")
    tabScroller.Name = "TabScroller"
    tabScroller.Size = UDim2.new(1, 0, 1, 0)
    tabScroller.BackgroundTransparency = 1
    tabScroller.BorderSizePixel = 0
    tabScroller.ScrollBarThickness = 4
    tabScroller.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    tabScroller.Parent = tabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabScroller
    
    -- Selection indicator
    local selectionIndicator = Instance.new("Frame")
    selectionIndicator.Name = "SelectionIndicator"
    selectionIndicator.BackgroundColor3 = themeColor
    selectionIndicator.BackgroundTransparency = 0.3
    selectionIndicator.BorderSizePixel = 0
    selectionIndicator.Size = UDim2.new(0, 3, 0, 20)
    selectionIndicator.Position = UDim2.new(0, 5, 0, 0)
    selectionIndicator.Visible = false
    selectionIndicator.Parent = tabScroller
    
    local selectionCorner = Instance.new("UICorner")
    selectionCorner.CornerRadius = UDim.new(1, 0)
    selectionCorner.Parent = selectionIndicator
    
    -- Content scroller
    local contentScroller = Instance.new("ScrollingFrame")
    contentScroller.Name = "ContentScroller"
    contentScroller.Size = UDim2.new(1, 0, 1, 0)
    contentScroller.BackgroundTransparency = 1
    contentScroller.BorderSizePixel = 0
    contentScroller.ScrollBarThickness = 4
    contentScroller.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    contentScroller.Parent = contentContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentScroller
    
    -- Auto-size content
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentScroller.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Function to create a tab
    function tabSystem:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "Tab " .. (self.TabCount + 1)
        tabConfig.Icon = tabConfig.Icon
        tabConfig.Color = tabConfig.Color or themeColor
        
        local tabId = HttpService:GenerateGUID(false)
        local tabIndex = self.TabCount
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "Tab_" .. tabId
        tabButton.Text = ""
        tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        tabButton.BackgroundTransparency = 0.9
        tabButton.Size = UDim2.new(1, -10, 0, TAB_HEIGHT)
        tabButton.LayoutOrder = tabIndex
        tabButton.Parent = tabScroller
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = tabButton
        
        -- Tab icon
        local iconOffset = 10
        if tabConfig.Icon then
            local icon = Instance.new("ImageLabel")
            icon.Name = "Icon"
            icon.Size = UDim2.new(0, 20, 0, 20)
            icon.Position = UDim2.new(0, 10, 0.5, -10)
            icon.Image = tabConfig.Icon
            icon.ImageColor3 = Color3.fromRGB(180, 180, 180)
            icon.BackgroundTransparency = 1
            icon.Parent = tabButton
            iconOffset = 40
        end
        
        -- Tab label
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -iconOffset - 5, 1, 0)
        label.Position = UDim2.new(0, iconOffset, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.Text = tabConfig.Name
        label.TextColor3 = Color3.fromRGB(180, 180, 180)
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = tabButton
        
        -- Create content frame
        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Name = "Content_" .. tabId
        contentFrame.Size = UDim2.new(1, 0, 1, 0)
        contentFrame.BackgroundTransparency = 1
        contentFrame.BorderSizePixel = 0
        contentFrame.ScrollBarThickness = 4
        contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        contentFrame.Visible = false
        contentFrame.Parent = contentScroller
        
        local frameLayout = Instance.new("UIListLayout")
        frameLayout.Padding = UDim.new(0, 10)
        frameLayout.SortOrder = Enum.SortOrder.LayoutOrder
        frameLayout.Parent = contentFrame
        
        frameLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, frameLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab activation function
        local function ActivateTab()
            -- Deactivate all tabs
            for _, tabData in pairs(self.Tabs) do
                if tabData.Button and tabData.Content then
                    TweenService:Create(tabData.Button, TweenInfo.new(ANIMATION_DURATION), {
                        BackgroundTransparency = 0.9
                    }):Play()
                    
                    TweenService:Create(tabData.Button.Label, TweenInfo.new(ANIMATION_DURATION), {
                        TextColor3 = Color3.fromRGB(180, 180, 180)
                    }):Play()
                    
                    if tabData.Button:FindFirstChild("Icon") then
                        TweenService:Create(tabData.Button.Icon, TweenInfo.new(ANIMATION_DURATION), {
                            ImageColor3 = Color3.fromRGB(180, 180, 180)
                        }):Play()
                    end
                    
                    tabData.Content.Visible = false
                    tabData.Active = false
                end
            end
            
            -- Activate this tab
            TweenService:Create(tabButton, TweenInfo.new(ANIMATION_DURATION), {
                BackgroundTransparency = 0.85
            }):Play()
            
            TweenService:Create(label, TweenInfo.new(ANIMATION_DURATION), {
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            
            if tabButton:FindFirstChild("Icon") then
                TweenService:Create(tabButton.Icon, TweenInfo.new(ANIMATION_DURATION), {
                    ImageColor3 = tabConfig.Color
                }):Play()
            end
            
            -- Update selection indicator
            selectionIndicator.Visible = true
            TweenService:Create(selectionIndicator, TweenInfo.new(ANIMATION_DURATION), {
                Position = UDim2.new(0, 5, 0, tabButton.AbsolutePosition.Y - tabScroller.AbsolutePosition.Y + 8)
            }):Play()
            
            contentFrame.Visible = true
            tabTitle.Text = tabConfig.Name
            
            self.ActiveTab = tabId
            TabManager.CurrentTab = tabId
        end
        
        -- Tab click handler
        tabButton.Activated:Connect(function(input)
            CreateRipple(tabButton, input.Position, tabConfig.Color)
            ActivateTab()
        end)
        
        -- Hover effects
        local function UpdateHoverState(hovering)
            if self.ActiveTab ~= tabId then
                TweenService:Create(tabButton, TweenInfo.new(0.1), {
                    BackgroundTransparency = hovering and 0.87 or 0.9
                }):Play()
            end
        end
        
        tabButton.MouseEnter:Connect(function()
            UpdateHoverState(true)
        end)
        
        tabButton.MouseLeave:Connect(function()
            UpdateHoverState(false)
        end)
        
        -- Section system for this tab
        local sectionSystem = {
            Sections = {},
            ActiveSections = {},
            SectionCount = 0
        }
        
        function sectionSystem:AddSection(sectionConfig)
            sectionConfig = sectionConfig or {}
            sectionConfig.Title = sectionConfig.Title or "Section"
            sectionConfig.AlwaysOpen = sectionConfig.AlwaysOpen or false
            sectionConfig.Color = sectionConfig.Color or tabConfig.Color
            
            local sectionId = HttpService:GenerateGUID(false)
            local sectionIndex = self.SectionCount
            
            -- Create section container
            local sectionContainer = Instance.new("Frame")
            sectionContainer.Name = "Section_" .. sectionId
            sectionContainer.BackgroundTransparency = 1
            sectionContainer.Size = UDim2.new(1, 0, 0, SECTION_HEIGHT)
            sectionContainer.LayoutOrder = sectionIndex
            sectionContainer.ClipsDescendants = true
            sectionContainer.Parent = contentFrame
            
            -- Section header
            local sectionHeader = Instance.new("Frame")
            sectionHeader.Name = "Header"
            sectionHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            sectionHeader.BackgroundTransparency = 0.1
            sectionHeader.Size = UDim2.new(1, 0, 0, SECTION_HEIGHT)
            sectionHeader.Parent = sectionContainer
            
            local headerCorner = Instance.new("UICorner")
            headerCorner.CornerRadius = UDim.new(0, 6)
            headerCorner.Parent = sectionHeader
            
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
            shadow.Parent = sectionHeader
            
            -- Section toggle button
            local toggleButton = Instance.new("TextButton")
            toggleButton.Name = "ToggleButton"
            toggleButton.Text = ""
            toggleButton.BackgroundTransparency = 1
            toggleButton.Size = UDim2.new(1, 0, 1, 0)
            toggleButton.Parent = sectionHeader
            
            -- Section title
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Name = "Title"
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Text = sectionConfig.Title
            titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
            titleLabel.TextSize = 13
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.BackgroundTransparency = 1
            titleLabel.Position = UDim2.new(0, 15, 0, 0)
            titleLabel.Size = UDim2.new(1, -50, 1, 0)
            titleLabel.Parent = sectionHeader
            
            -- Expand/collapse icon
            local expandIcon = Instance.new("ImageLabel")
            expandIcon.Name = "ExpandIcon"
            expandIcon.Image = "rbxassetid://6031091004"
            expandIcon.ImageColor3 = sectionConfig.Color
            expandIcon.BackgroundTransparency = 1
            expandIcon.Size = UDim2.new(0, 16, 0, 16)
            expandIcon.Position = UDim2.new(1, -30, 0.5, -8)
            expandIcon.Parent = sectionHeader
            
            -- Content area
            local contentArea = Instance.new("Frame")
            contentArea.Name = "ContentArea"
            contentArea.BackgroundTransparency = 1
            contentArea.Position = UDim2.new(0, 0, 0, SECTION_HEIGHT + 5)
            contentArea.Size = UDim2.new(1, 0, 0, 0)
            contentArea.ClipsDescendants = true
            contentArea.Parent = sectionContainer
            
            local contentLayout = Instance.new("UIListLayout")
            contentLayout.Padding = UDim.new(0, 8)
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.Parent = contentArea
            
            contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if self.ActiveSections[sectionId] then
                    contentArea.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y)
                    sectionContainer.Size = UDim2.new(1, 0, 0, SECTION_HEIGHT + 5 + contentLayout.AbsoluteContentSize.Y)
                end
            end)
            
            -- State
            local isExpanded = sectionConfig.AlwaysOpen
            
            -- Toggle function
            local function ToggleSection()
                isExpanded = not isExpanded
                self.ActiveSections[sectionId] = isExpanded
                
                if isExpanded then
                    -- Expand
                    TweenService:Create(expandIcon, TweenInfo.new(ANIMATION_DURATION), {
                        Rotation = 180
                    }):Play()
                    
                    TweenService:Create(contentArea, TweenInfo.new(ANIMATION_DURATION), {
                        Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y)
                    }):Play()
                    
                    TweenService:Create(sectionContainer, TweenInfo.new(ANIMATION_DURATION), {
                        Size = UDim2.new(1, 0, 0, SECTION_HEIGHT + 5 + contentLayout.AbsoluteContentSize.Y)
                    }):Play()
                else
                    -- Collapse
                    TweenService:Create(expandIcon, TweenInfo.new(ANIMATION_DURATION), {
                        Rotation = 0
                    }):Play()
                    
                    TweenService:Create(contentArea, TweenInfo.new(ANIMATION_DURATION), {
                        Size = UDim2.new(1, 0, 0, 0)
                    }):Play()
                    
                    TweenService:Create(sectionContainer, TweenInfo.new(ANIMATION_DURATION), {
                        Size = UDim2.new(1, 0, 0, SECTION_HEIGHT)
                    }):Play()
                end
            end
            
            -- Click handler
            toggleButton.Activated:Connect(function(input)
                if not sectionConfig.AlwaysOpen then
                    CreateRipple(toggleButton, input.Position, sectionConfig.Color)
                    ToggleSection()
                end
            end)
            
            -- Initialize based on AlwaysOpen
            if sectionConfig.AlwaysOpen then
                expandIcon.Rotation = 180
                isExpanded = true
                self.ActiveSections[sectionId] = true
                contentArea.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y)
                sectionContainer.Size = UDim2.new(1, 0, 0, SECTION_HEIGHT + 5 + contentLayout.AbsoluteContentSize.Y)
            end
            
            -- Element creation functions
            local sectionElements = {
                AddParagraph = function(paragraphConfig)
                    return uiElements:CreateParagraph(contentArea, paragraphConfig, sectionConfig.Color, elementManager, configManager)
                end,
                
                AddPanel = function(panelConfig)
                    return uiElements:CreatePanel(contentArea, panelConfig, sectionConfig.Color, elementManager, configManager)
                end,
                
                AddToggle = function(toggleConfig)
                    return uiElements:CreateToggle(contentArea, toggleConfig, sectionConfig.Color, elementManager, configManager)
                end,
                
                AddSlider = function(sliderConfig)
                    return uiElements:CreateSlider(contentArea, sliderConfig, sectionConfig.Color, elementManager, configManager)
                end,
                
                AddInput = function(inputConfig)
                    return uiElements:CreateInput(contentArea, inputConfig, sectionConfig.Color, elementManager, configManager)
                end,
                
                AddButton = function(buttonConfig)
                    return uiElements:CreateButton(contentArea, buttonConfig, sectionConfig.Color, elementManager, configManager)
                end,
                
                AddDropdown = function(dropdownConfig)
                    return uiElements:CreateDropdown(contentArea, dropdownConfig, sectionConfig.Color, elementManager, configManager)
                end,
                
                AddDivider = function(dividerConfig)
                    return uiElements:CreateDivider(contentArea, dividerConfig, sectionConfig.Color)
                end,
                
                AddLabel = function(labelConfig)
                    return uiElements:CreateLabel(contentArea, labelConfig, sectionConfig.Color)
                end,
                
                -- Compatibility functions
                AddParagraph = function(paragraphConfig)
                    return self.AddParagraph(paragraphConfig)
                end,
                
                AddPanel = function(panelConfig)
                    return self.AddPanel(panelConfig)
                end,
                
                AddToggle = function(toggleConfig)
                    return self.AddToggle(toggleConfig)
                end,
                
                AddSlider = function(sliderConfig)
                    return self.AddSlider(sliderConfig)
                end,
                
                AddInput = function(inputConfig)
                    return self.AddInput(inputConfig)
                end,
                
                AddButton = function(buttonConfig)
                    return self.AddButton(buttonConfig)
                end,
                
                AddDivider = function()
                    return self.AddDivider()
                end
            }
            
            -- Store section
            self.Sections[sectionId] = {
                Container = sectionContainer,
                Content = contentArea,
                Elements = sectionElements,
                IsExpanded = isExpanded,
                Config = sectionConfig
            }
            
            self.SectionCount = self.SectionCount + 1
            
            -- Auto-expand if first section
            if sectionIndex == 0 and not sectionConfig.AlwaysOpen then
                task.wait(0.1)
                ToggleSection()
            end
            
            return sectionElements
        end
        
        -- Store tab
        self.Tabs[tabId] = {
            Button = tabButton,
            Content = contentFrame,
            Sections = sectionSystem,
            Active = false,
            Config = tabConfig
        }
        
        self.TabCount = self.TabCount + 1
        
        -- Auto-activate first tab
        if tabIndex == 0 then
            task.spawn(function()
                task.wait(0.1)
                ActivateTab()
            end)
        end
        
        -- Update scroller size
        local function UpdateTabScrollerSize()
            local totalHeight = 0
            for _, child in pairs(tabScroller:GetChildren()) do
                if child:IsA("GuiObject") and child.Name:find("Tab_") then
                    totalHeight = totalHeight + child.Size.Y.Offset + 5
                end
            end
            tabScroller.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        end
        
        UpdateTabScrollerSize()
        tabScroller.ChildAdded:Connect(UpdateTabScrollerSize)
        tabScroller.ChildRemoved:Connect(UpdateTabScrollerSize)
        
        return sectionSystem
    end
    
    -- Tab system API
    function tabSystem:SwitchToTab(tabName)
        for tabId, tabData in pairs(self.Tabs) do
            if tabData.Config.Name == tabName then
                if tabData.Button then
                    tabData.Button.Activated:Connect()
                end
                return true
            end
        end
        return false
    end
    
    function tabSystem:GetTab(tabName)
        for tabId, tabData in pairs(self.Tabs) do
            if tabData.Config.Name == tabName then
                return tabData.Sections
            end
        end
        return nil
    end
    
    function tabSystem:GetActiveTab()
        if self.ActiveTab and self.Tabs[self.ActiveTab] then
            return self.Tabs[self.ActiveTab].Sections
        end
        return nil
    end
    
    function tabSystem:Destroy()
        for tabId, tabData in pairs(self.Tabs) do
            if tabData.Button then
                tabData.Button:Destroy()
            end
            if tabData.Content then
                tabData.Content:Destroy()
            end
        end
        
        tabScroller:Destroy()
        contentScroller:Destroy()
        selectionIndicator:Destroy()
    end
    
    -- Register with manager
    TabManager.ActiveTabs[tostring(tabContainer)] = tabSystem
    
    return tabSystem
end

-- Global tab management
function TabSystem:SwitchToTab(containerName, tabName)
    local tabSystem = TabManager.ActiveTabs[containerName]
    if tabSystem then
        return tabSystem:SwitchToTab(tabName)
    end
    return false
end

function TabSystem:GetTab(containerName, tabName)
    local tabSystem = TabManager.ActiveTabs[containerName]
    if tabSystem then
        return tabSystem:GetTab(tabName)
    end
    return nil
end

function TabSystem:GetActiveTab(containerName)
    local tabSystem = TabManager.ActiveTabs[containerName]
    if tabSystem then
        return tabSystem:GetActiveTab()
    end
    return nil
end

function TabSystem:Cleanup()
    for containerName, tabSystem in pairs(TabManager.ActiveTabs) do
        if not tabSystem or not tabSystem.Destroy then
            TabManager.ActiveTabs[containerName] = nil
        end
    end
end

return TabSystem
