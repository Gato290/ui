-- ChloeX UI Library - Elements Module
-- Version: V0.0.3
-- Part 2 of 3

local ElementsModule = {}

-- Services
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Constants
local ANIMATION_SPEED = 0.2
local DEFAULT_TAB_WIDTH = 120
local DEFAULT_COLOR = Color3.fromRGB(255, 0, 255)
local DIALOG_DURATION = 0.3

-- Utility: Better ripple effect with performance optimization
local RippleEffect = {}

function RippleEffect:Create(button, position, color)
    if not button then return end
    
    button.ClipsDescendants = true
    
    local ripple = Instance.new("Frame")
    ripple.Name = "RippleEffect"
    ripple.BackgroundColor3 = color or Color3.fromRGB(80, 80, 80)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.ZIndex = 10
    ripple.Parent = button
    
    -- Make it circular
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    -- Position ripple at click point
    local buttonPos = button.AbsolutePosition
    local buttonSize = button.AbsoluteSize
    local relativeX = (position.X - buttonPos.X) / buttonSize.X
    local relativeY = (position.Y - buttonPos.Y) / buttonSize.Y
    
    ripple.Position = UDim2.new(relativeX, -1, relativeY, -1)
    ripple.Size = UDim2.new(0, 2, 0, 2)
    
    -- Calculate max size
    local maxDimension = math.max(buttonSize.X, buttonSize.Y) * 2
    local targetSize = UDim2.new(0, maxDimension, 0, maxDimension)
    local targetPosition = UDim2.new(0.5, -maxDimension/2, 0.5, -maxDimension/2)
    
    -- Create animation sequence
    local expandTween = TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = targetSize,
        Position = targetPosition,
        BackgroundTransparency = 1
    })
    
    expandTween:Play()
    expandTween.Completed:Connect(function()
        ripple:Destroy()
    end)
    
    return ripple
end

-- Window Manager
local WindowManager = {
    ActiveWindows = {},
    DialogQueue = {}
}

function WindowManager:CreateDialog(title, message, options)
    local dialogConfig = {
        Title = title or "Confirmation",
        Message = message or "Are you sure?",
        Options = options or {
            { Text = "Yes", Color = Color3.fromRGB(0, 170, 255), Callback = function() end },
            { Text = "No", Color = Color3.fromRGB(100, 100, 100), Callback = function() end }
        },
        Duration = DIALOG_DURATION
    }
    
    return dialogConfig
end

function WindowManager:ShowDialog(parent, config)
    local dialogId = tostring(tick())
    
    -- Create overlay
    local overlay = Instance.new("Frame")
    overlay.Name = "DialogOverlay_" .. dialogId
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.ZIndex = 100
    overlay.Parent = parent
    
    -- Animate fade in
    overlay.BackgroundTransparency = 1
    TweenService:Create(overlay, TweenInfo.new(config.Duration), {
        BackgroundTransparency = 0.5
    }):Play()
    
    -- Create dialog container
    local dialogContainer = Instance.new("Frame")
    dialogContainer.Name = "DialogContainer"
    dialogContainer.Size = UDim2.new(0, 320, 0, 180)
    dialogContainer.Position = UDim2.new(0.5, -160, 0.5, -90)
    dialogContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    dialogContainer.BackgroundTransparency = 0.1
    dialogContainer.ZIndex = 101
    dialogContainer.Parent = overlay
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = dialogContainer
    
    -- Add subtle shadow
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
    shadow.ZIndex = 100
    shadow.Parent = dialogContainer
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 40)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = config.Title
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.ZIndex = 102
    titleLabel.Parent = dialogContainer
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 70)
    messageLabel.Position = UDim2.new(0, 10, 0, 50)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Text = config.Message
    messageLabel.TextSize = 14
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextWrapped = true
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.ZIndex = 102
    messageLabel.Parent = dialogContainer
    
    -- Button container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -20, 0, 40)
    buttonContainer.Position = UDim2.new(0, 10, 1, -50)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.ZIndex = 102
    buttonContainer.Parent = dialogContainer
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonLayout.Padding = UDim.new(0, 10)
    buttonLayout.Parent = buttonContainer
    
    -- Create buttons
    for i, option in ipairs(config.Options) do
        local button = Instance.new("TextButton")
        button.Name = "Button_" .. option.Text
        button.Size = UDim2.new(0, 80, 1, 0)
        button.BackgroundColor3 = option.Color
        button.BackgroundTransparency = 0.2
        button.Font = Enum.Font.GothamBold
        button.Text = option.Text
        button.TextSize = 14
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.LayoutOrder = i
        button.ZIndex = 103
        button.Parent = buttonContainer
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        -- Hover effect
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
            -- Ripple effect
            RippleEffect:Create(button, Vector2.new(button.AbsoluteSize.X/2, button.AbsoluteSize.Y/2), Color3.fromRGB(255, 255, 255))
            
            -- Close dialog
            TweenService:Create(dialogContainer, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
            
            TweenService:Create(overlay, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            
            task.wait(0.2)
            
            if option.Callback then
                option.Callback()
            end
            
            overlay:Destroy()
        end)
    end
    
    -- Animate dialog entrance
    dialogContainer.Size = UDim2.new(0, 0, 0, 0)
    dialogContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    TweenService:Create(dialogContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 320, 0, 180),
        Position = UDim2.new(0.5, -160, 0.5, -90)
    }):Play()
    
    return {
        Close = function()
            overlay:Destroy()
        end,
        Overlay = overlay
    }
end

-- Window creation function
function ElementsModule:CreateWindow(config, getIcon, configManager, elements, dragManager, rippleEffect)
    config = config or {}
    config.Title = config.Title or "Chloe X"
    config.Footer = config.Footer or "NexaHub"
    config.Color = config.Color or DEFAULT_COLOR
    config.TabWidth = config.TabWidth or DEFAULT_TAB_WIDTH
    config.Version = config.Version or 1
    
    -- Create main screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ChloeXWindow_" .. HttpService:GenerateGUID(false)
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    -- Create main container with shadow
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainContainer.Size = UDim2.new(0, 650, 0, 450)
    mainContainer.BackgroundTransparency = 1
    mainContainer.Parent = screenGui
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 47, 1, 47)
    shadow.Position = UDim2.new(-0.1, -23.5, -0.1, -23.5)
    shadow.Parent = mainContainer
    
    -- Main window frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    
    if config.Theme then
        mainFrame = Instance.new("ImageLabel")
        mainFrame.Image = "rbxassetid://" .. config.Theme
        mainFrame.ScaleType = Enum.ScaleType.Crop
        mainFrame.BackgroundTransparency = 1
        mainFrame.ImageTransparency = config.ThemeTransparency or 0.15
    else
        mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
        mainFrame.BackgroundTransparency = 0
    end
    
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = mainContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Top bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    topBar.BackgroundTransparency = 0.9
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, 8, 0, 0)
    topBarCorner.Parent = topBar
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = config.Title
    titleLabel.TextColor3 = config.Color
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.Parent = topBar
    
    -- Footer
    local footerLabel = Instance.new("TextLabel")
    footerLabel.Name = "Footer"
    footerLabel.Font = Enum.Font.GothamMedium
    footerLabel.Text = config.Footer
    footerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    footerLabel.TextSize = 12
    footerLabel.TextXAlignment = Enum.TextXAlignment.Left
    footerLabel.BackgroundTransparency = 1
    footerLabel.Size = UDim2.new(1, -(titleLabel.TextBounds.X + 20), 1, 0)
    footerLabel.Position = UDim2.new(0, titleLabel.TextBounds.X + 20, 0, 0)
    footerLabel.Parent = topBar
    
    -- Window controls
    local controlContainer = Instance.new("Frame")
    controlContainer.Name = "Controls"
    controlContainer.Size = UDim2.new(0, 70, 1, 0)
    controlContainer.Position = UDim2.new(1, -75, 0, 0)
    controlContainer.BackgroundTransparency = 1
    controlContainer.Parent = topBar
    
    local controlLayout = Instance.new("UIListLayout")
    controlLayout.FillDirection = Enum.FillDirection.Horizontal
    controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlLayout.Padding = UDim.new(0, 5)
    controlLayout.Parent = controlContainer
    
    -- Minimize button
    local minimizeButton = Instance.new("ImageButton")
    minimizeButton.Name = "Minimize"
    minimizeButton.Size = UDim2.new(0, 25, 0, 25)
    minimizeButton.Image = "rbxassetid://9886659276"
    minimizeButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Parent = controlContainer
    
    local minimizeHover = Instance.new("ImageLabel")
    minimizeHover.Name = "Hover"
    minimizeHover.Size = UDim2.new(1, 0, 1, 0)
    minimizeHover.Image = "rbxassetid://9886659276"
    minimizeHover.ImageColor3 = Color3.fromRGB(255, 255, 255)
    minimizeHover.ImageTransparency = 1
    minimizeHover.BackgroundTransparency = 1
    minimizeHover.Parent = minimizeButton
    
    minimizeButton.MouseEnter:Connect(function()
        TweenService:Create(minimizeHover, TweenInfo.new(0.1), {
            ImageTransparency = 0
        }):Play()
    end)
    
    minimizeButton.MouseLeave:Connect(function()
        TweenService:Create(minimizeHover, TweenInfo.new(0.1), {
            ImageTransparency = 1
        }):Play()
    end)
    
    -- Close button
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "Close"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Image = "rbxassetid://9886659671"
    closeButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
    closeButton.BackgroundTransparency = 1
    closeButton.Parent = controlContainer
    
    local closeHover = Instance.new("ImageLabel")
    closeHover.Name = "Hover"
    closeHover.Size = UDim2.new(1, 0, 1, 0)
    closeHover.Image = "rbxassetid://9886659671"
    closeHover.ImageColor3 = Color3.fromRGB(255, 100, 100)
    closeHover.ImageTransparency = 1
    closeHover.BackgroundTransparency = 1
    closeHover.Parent = closeButton
    
    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeHover, TweenInfo.new(0.1), {
            ImageTransparency = 0
        }):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeHover, TweenInfo.new(0.1), {
            ImageTransparency = 1
        }):Play()
    end)
    
    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, 0, 1, -40)
    contentArea.Position = UDim2.new(0, 0, 0, 40)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame
    
    -- Sidebar for tabs
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, config.TabWidth, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    sidebar.BackgroundTransparency = 0.95
    sidebar.BorderSizePixel = 0
    sidebar.Parent = contentArea
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 0, 0, 0, 8, 0)
    sidebarCorner.Parent = sidebar
    
    -- Tab scrolling frame
    local tabScroller = Instance.new("ScrollingFrame")
    tabScroller.Name = "TabScroller"
    tabScroller.Size = UDim2.new(1, 0, 1, 0)
    tabScroller.BackgroundTransparency = 1
    tabScroller.BorderSizePixel = 0
    tabScroller.ScrollBarThickness = 4
    tabScroller.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    tabScroller.Parent = sidebar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabScroller
    
    -- Main content frame
    local mainContent = Instance.new("Frame")
    mainContent.Name = "MainContent"
    mainContent.Size = UDim2.new(1, -config.TabWidth, 1, 0)
    mainContent.Position = UDim2.new(0, config.TabWidth, 0, 0)
    mainContent.BackgroundTransparency = 1
    mainContent.Parent = contentArea
    
    -- Tab title
    local tabTitle = Instance.new("TextLabel")
    tabTitle.Name = "TabTitle"
    tabTitle.Size = UDim2.new(1, 0, 0, 40)
    tabTitle.BackgroundTransparency = 1
    tabTitle.Font = Enum.Font.GothamBold
    tabTitle.Text = "Welcome"
    tabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabTitle.TextSize = 18
    tabTitle.TextXAlignment = Enum.TextXAlignment.Left
    tabTitle.Parent = mainContent
    
    -- Tab content container
    local tabContent = Instance.new("Frame")
    tabContent.Name = "TabContent"
    tabContent.Size = UDim2.new(1, 0, 1, -40)
    tabContent.Position = UDim2.new(0, 0, 0, 40)
    tabContent.BackgroundTransparency = 1
    tabContent.ClipsDescendants = true
    tabContent.Parent = mainContent
    
    -- Make window draggable and resizable
    dragManager:MakeDraggable(topBar, mainContainer, { boundary = true })
    
    local resizeCorner = Instance.new("Frame")
    resizeCorner.Name = "ResizeCorner"
    resizeCorner.Size = UDim2.new(0, 20, 0, 20)
    resizeCorner.Position = UDim2.new(1, -10, 1, -10)
    resizeCorner.BackgroundTransparency = 1
    resizeCorner.Parent = mainContainer
    
    dragManager:MakeResizable(resizeCorner, mainContainer)
    
    -- Window functions
    local windowFunctions = {
        Tabs = {},
        Minimized = false,
        OriginalSize = mainContainer.Size,
        OriginalPosition = mainContainer.Position
    }
    
    -- Minimize functionality
    minimizeButton.Activated:Connect(function()
        rippleEffect:Create(minimizeButton, Vector2.new(minimizeButton.AbsoluteSize.X/2, minimizeButton.AbsoluteSize.Y/2))
        
        if windowFunctions.Minimized then
            -- Restore
            TweenService:Create(mainContainer, TweenInfo.new(0.3), {
                Size = windowFunctions.OriginalSize,
                Position = windowFunctions.OriginalPosition
            }):Play()
            windowFunctions.Minimized = false
        else
            -- Minimize
            windowFunctions.OriginalSize = mainContainer.Size
            windowFunctions.OriginalPosition = mainContainer.Position
            
            TweenService:Create(mainContainer, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 200, 0, 40),
                Position = UDim2.new(0, 20, 1, -60)
            }):Play()
            windowFunctions.Minimized = true
        end
    end)
    
    -- Close functionality with confirmation dialog
    closeButton.Activated:Connect(function()
        rippleEffect:Create(closeButton, Vector2.new(closeButton.AbsoluteSize.X/2, closeButton.AbsoluteSize.Y/2))
        
        local dialog = WindowManager:ShowDialog(mainContainer, WindowManager:CreateDialog(
            "Close Window",
            "Are you sure you want to close this window?\nYou can reopen it from the toggle button.",
            {
                {
                    Text = "Yes",
                    Color = Color3.fromRGB(255, 50, 50),
                    Callback = function()
                        screenGui:Destroy()
                    end
                },
                {
                    Text = "No",
                    Color = Color3.fromRGB(100, 100, 100),
                    Callback = function() end
                }
            }
        ))
    end)
    
    -- Create toggle button
    local function CreateToggleButton()
        local toggleScreenGui = Instance.new("ScreenGui")
        toggleScreenGui.Name = "ToggleUI"
        toggleScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        toggleScreenGui.ResetOnSpawn = false
        toggleScreenGui.Parent = CoreGui
        
        local toggleButton = Instance.new("ImageButton")
        toggleButton.Name = "ToggleButton"
        toggleButton.Size = UDim2.new(0, 50, 0, 50)
        toggleButton.Position = UDim2.new(0, 20, 0.5, -25)
        toggleButton.Image = getIcon("lexshub") or "rbxassetid://71947103252559"
        toggleButton.ImageColor3 = config.Color
        toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        toggleButton.BackgroundTransparency = 0.2
        toggleButton.Parent = toggleScreenGui
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 12)
        toggleCorner.Parent = toggleButton
        
        -- Pulse animation
        local pulseGlow = Instance.new("Frame")
        pulseGlow.Name = "PulseGlow"
        pulseGlow.Size = UDim2.new(1, 10, 1, 10)
        pulseGlow.Position = UDim2.new(0, -5, 0, -5)
        pulseGlow.BackgroundColor3 = config.Color
        pulseGlow.BackgroundTransparency = 0.8
        pulseGlow.ZIndex = -1
        pulseGlow.Parent = toggleButton
        
        local glowCorner = Instance.new("UICorner")
        glowCorner.CornerRadius = UDim.new(0, 16)
        glowCorner.Parent = pulseGlow
        
        -- Pulsing animation
        local pulseConnection
        pulseConnection = RunService.Heartbeat:Connect(function()
            local time = tick()
            local pulse = math.sin(time * 2) * 0.2 + 0.8
            pulseGlow.BackgroundTransparency = pulse
        end)
        
        -- Toggle visibility
        toggleButton.Activated:Connect(function()
            mainContainer.Visible = not mainContainer.Visible
            rippleEffect:Create(toggleButton, Vector2.new(toggleButton.AbsoluteSize.X/2, toggleButton.AbsoluteSize.Y/2))
        end)
        
        -- Make toggle draggable
        dragManager:MakeDraggable(toggleButton, toggleScreenGui, { boundary = true })
        
        -- Cleanup
        toggleScreenGui.Destroying:Connect(function()
            if pulseConnection then
                pulseConnection:Disconnect()
            end
        end)
        
        return toggleButton
    end
    
    -- Create toggle button
    local toggleButton = CreateToggleButton()
    
    -- Tab creation function
    function windowFunctions:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "New Tab"
        tabConfig.Icon = tabConfig.Icon or "folder"
        tabConfig.Color = tabConfig.Color or config.Color
        
        local tabId = HttpService:GenerateGUID(false)
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "Tab_" .. tabId
        tabButton.Size = UDim2.new(1, -10, 0, 40)
        tabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundTransparency = 0.95
        tabButton.Text = ""
        tabButton.LayoutOrder = #windowFunctions.Tabs + 1
        tabButton.Parent = tabScroller
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = tabButton
        
        -- Tab icon
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0, 10, 0.5, -10)
        icon.Image = getIcon(tabConfig.Icon)
        icon.ImageColor3 = Color3.fromRGB(200, 200, 200)
        icon.BackgroundTransparency = 1
        icon.Parent = tabButton
        
        -- Tab label
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -40, 1, 0)
        label.Position = UDim2.new(0, 40, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamMedium
        label.Text = tabConfig.Name
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = tabButton
        
        -- Selection indicator
        local selectionIndicator = Instance.new("Frame")
        selectionIndicator.Name = "Selection"
        selectionIndicator.Size = UDim2.new(0, 3, 0.6, 0)
        selectionIndicator.Position = UDim2.new(1, -3, 0.2, 0)
        selectionIndicator.BackgroundColor3 = tabConfig.Color
        selectionIndicator.BackgroundTransparency = 0.5
        selectionIndicator.Visible = false
        selectionIndicator.Parent = tabButton
        
        -- Create tab content frame
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Name = "TabFrame_" .. tabId
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.BorderSizePixel = 0
        tabFrame.ScrollBarThickness = 4
        tabFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        tabFrame.Visible = false
        tabFrame.Parent = tabContent
        
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Padding = UDim.new(0, 10)
        tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabLayout.Parent = tabFrame
        
        -- Tab functionality
        local isActive = false
        
        local function ActivateTab()
            -- Deactivate all tabs
            for _, tab in pairs(windowFunctions.Tabs) do
                if tab.Button and tab.Frame then
                    TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.95
                    }):Play()
                    
                    TweenService:Create(tab.Button.Icon, TweenInfo.new(0.2), {
                        ImageColor3 = Color3.fromRGB(200, 200, 200)
                    }):Play()
                    
                    TweenService:Create(tab.Button.Label, TweenInfo.new(0.2), {
                        TextColor3 = Color3.fromRGB(200, 200, 200)
                    }):Play()
                    
                    tab.Button.Selection.Visible = false
                    tab.Frame.Visible = false
                end
            end
            
            -- Activate this tab
            TweenService:Create(tabButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.9
            }):Play()
            
            TweenService:Create(icon, TweenInfo.new(0.2), {
                ImageColor3 = tabConfig.Color
            }):Play()
            
            TweenService:Create(label, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            
            selectionIndicator.Visible = true
            tabFrame.Visible = true
            tabTitle.Text = tabConfig.Name
            
            isActive = true
        end
        
        -- Click event
        tabButton.Activated:Connect(function()
            rippleEffect:Create(tabButton, Vector2.new(tabButton.AbsoluteSize.X/2, tabButton.AbsoluteSize.Y/2))
            ActivateTab()
        end)
        
        -- Hover effects
        tabButton.MouseEnter:Connect(function()
            if not isActive then
                TweenService:Create(tabButton, TweenInfo.new(0.1), {
                    BackgroundTransparency = 0.92
                }):Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if not isActive then
                TweenService:Create(tabButton, TweenInfo.new(0.1), {
                    BackgroundTransparency = 0.95
                }):Play()
            end
        end)
        
        -- Store tab reference
        local tabObject = {
            Name = tabConfig.Name,
            Button = tabButton,
            Frame = tabFrame,
            IsActive = isActive,
            Activate = ActivateTab,
            AddElement = function(self, element)
                element.Parent = tabFrame
                return element
            end
        }
        
        table.insert(windowFunctions.Tabs, tabObject)
        
        -- Activate first tab
        if #windowFunctions.Tabs == 1 then
            ActivateTab()
        end
        
        -- Update scroller size
        local function UpdateScrollerSize()
            local totalHeight = 0
            for _, child in pairs(tabScroller:GetChildren()) do
                if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then
                    totalHeight = totalHeight + child.Size.Y.Offset + 5
                end
            end
            tabScroller.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        end
        
        UpdateScrollerSize()
        tabScroller.ChildAdded:Connect(UpdateScrollerSize)
        tabScroller.ChildRemoved:Connect(UpdateScrollerSize)
        
        return tabObject
    end
    
    -- Add destroy function
    function windowFunctions:Destroy()
        screenGui:Destroy()
        if toggleButton and toggleButton.Parent then
            toggleButton.Parent:Destroy()
        end
    end
    
    -- Add hide/show functions
    function windowFunctions:Hide()
        mainContainer.Visible = false
    end
    
    function windowFunctions:Show()
        mainContainer.Visible = true
    end
    
    -- Store window reference
    WindowManager.ActiveWindows[screenGui.Name] = windowFunctions
    
    return windowFunctions
end

return ElementsModule
