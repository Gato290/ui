local HttpService = game:GetService("HttpService") -- V0.1.0 - UPGRADED

-- ==================== CONFIG SYSTEM ====================
if not isfolder("NexaHub") then makefolder("NexaHub") end
if not isfolder("NexaHub/Config") then makefolder("NexaHub/Config") end

local gameName = tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
gameName = gameName:gsub("[^%w_ ]", ""):gsub("%s+", "_")

local ConfigFile = "NexaHub/Config/CHX_" .. gameName .. ".json"

ConfigData = {}
Elements = {}
CURRENT_VERSION = nil

function SaveConfig()
    if writefile then
        ConfigData._version = CURRENT_VERSION
        local success, err = pcall(function()
            writefile(ConfigFile, HttpService:JSONEncode(ConfigData))
        end)
        if not success then
            warn("Failed to save config:", err)
        end
    end
end

function LoadConfigFromFile()
    if not CURRENT_VERSION then return end
    if isfile and isfile(ConfigFile) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and type(result) == "table" then
            if result._version == CURRENT_VERSION then
                ConfigData = result
            else
                ConfigData = { _version = CURRENT_VERSION }
            end
        else
            ConfigData = { _version = CURRENT_VERSION }
        end
    else
        ConfigData = { _version = CURRENT_VERSION }
    end
end

function LoadConfigElements()
    for key, element in pairs(Elements) do
        if ConfigData[key] ~= nil and element.Set then
            element:Set(ConfigData[key], true)
        end
    end
end

-- ==================== ICONS ====================
local Icons = {
    alert = "rbxassetid://73186275216515",
    bag = "rbxassetid://8601111810",
    boss = "rbxassetid://13132186360",
    cart = "rbxassetid://128874923961846",
    compass = "rbxassetid://125300760963399",
    crosshair = "rbxassetid://12614416478",
    discord = "rbxassetid://94434236999817",
    eyes = "rbxassetid://14321059114",
    fish = "rbxassetid://97167558235554",
    folder = "rbxassetid://111411260968321",
    gamepad = "rbxassetid://84173963561612",
    gps = "rbxassetid://17824309485",
    home = "rbxassetid://70416927963252",
    idea = "rbxassetid://16833255748",
    loop = "rbxassetid://122032243989747",
    menu = "rbxassetid://6340513838",
    next = "rbxassetid://12662718374",
    payment = "rbxassetid://18747025078",
    player = "rbxassetid://12120698352",
    plug = "rbxassetid://137601480983962",
    question = "rbxassetid://17510196486",
    scan = "rbxassetid://109869955247116",
    scroll = "rbxassetid://114127804740858",
    settings = "rbxassetid://70386228443175",
    shop = "rbxassetid://4985385964",
    skeleton = "rbxassetid://17313330026",
    star = "rbxassetid://107005941750079",
    start = "rbxassetid://108886429866687",
    stat = "rbxassetid://12094445329",
    sword = "rbxassetid://82472368671405",
    user = "rbxassetid://108483430622128",
    water = "rbxassetid://100076212630732",
    web = "rbxassetid://137601480983962",
    check = "rbxassetid://3926305904",
    cross = "rbxassetid://3926307971",
    arrow_down = "rbxassetid://16851841101",
    search = "rbxassetid://7072717857",
    bell = "rbxassetid://7072707003",
    gear = "rbxassetid://7072717895",
}

-- ==================== SERVICES ====================
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")
local viewport = workspace.CurrentCamera.ViewportSize

-- ==================== UTILITY FUNCTIONS ====================
local function isMobileDevice()
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
        and not UserInputService.MouseEnabled
end

local isMobile = isMobileDevice()

local function safeSize(pxWidth, pxHeight)
    local scaleX = pxWidth / viewport.X
    local scaleY = pxHeight / viewport.Y

    if isMobile then
        if scaleX > 0.5 then scaleX = 0.5 end
        if scaleY > 0.3 then scaleY = 0.3 end
    end

    return UDim2.new(scaleX, 0, scaleY, 0)
end

local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition

    local function UpdatePos(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
        TweenService:Create(object, TweenInfo.new(0.15), { Position = pos }):Play()
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdatePos(input)
        end
    end)
end

local function MakeResizable(object)
    local Dragging, DragInput, DragStart, StartSize
    local minSizeX, minSizeY = isMobile and 300 or 400, isMobile and 200 or 300
    local defSizeX, defSizeY = isMobile and 470 or 640, isMobile and 270 or 400

    object.Size = UDim2.new(0, defSizeX, 0, defSizeY)

    local resizeHandle = Instance.new("Frame")
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Size = UDim2.new(0, 40, 0, 40)
    resizeHandle.Position = UDim2.new(1, 20, 1, 20)
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Parent = object

    local function UpdateSize(input)
        local Delta = input.Position - DragStart
        local newWidth = math.max(StartSize.X.Offset + Delta.X, minSizeX)
        local newHeight = math.max(StartSize.Y.Offset + Delta.Y, minSizeY)
        TweenService:Create(object, TweenInfo.new(0.15), { Size = UDim2.new(0, newWidth, 0, newHeight) }):Play()
    end

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartSize = object.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    resizeHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdateSize(input)
        end
    end)
end

function CircleClick(Button, X, Y)
    task.spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.9
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Name = "Circle"
        Circle.Parent = Button

        local NewX = X - Circle.AbsolutePosition.X
        local NewY = Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        
        local Size = math.max(Button.AbsoluteSize.X, Button.AbsoluteSize.Y) * 1.5
        local Time = 0.5
        
        Circle:TweenSizeAndPosition(
            UDim2.new(0, Size, 0, Size),
            UDim2.new(0.5, -Size / 2, 0.5, -Size / 2),
            "Out", "Quad", Time, false, nil
        )
        
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.01
            task.wait(Time / 10)
        end
        Circle:Destroy()
    end)
end

-- ==================== NOTIFICATION SYSTEM ====================
local Chloex = {}

function Chloex:MakeNotify(NotifyConfig)
    NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "Chloe X"
    NotifyConfig.Description = NotifyConfig.Description or "Notification"
    NotifyConfig.Content = NotifyConfig.Content or "Content"
    NotifyConfig.Color = NotifyConfig.Color or Color3.fromRGB(255, 0, 255)
    NotifyConfig.Time = NotifyConfig.Time or 0.5
    NotifyConfig.Delay = NotifyConfig.Delay or 5
    NotifyConfig.Icon = NotifyConfig.Icon or nil
    
    local NotifyFunction = {}
    
    task.spawn(function()
        if not CoreGui:FindFirstChild("NotifyGui") then
            local NotifyGui = Instance.new("ScreenGui")
            NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            NotifyGui.Name = "NotifyGui"
            NotifyGui.ResetOnSpawn = false
            NotifyGui.Parent = CoreGui
        end
        
        if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
            local NotifyLayout = Instance.new("Frame")
            NotifyLayout.AnchorPoint = Vector2.new(1, 1)
            NotifyLayout.BackgroundTransparency = 1
            NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
            NotifyLayout.Size = UDim2.new(0, 320, 1, 0)
            NotifyLayout.Name = "NotifyLayout"
            NotifyLayout.Parent = CoreGui.NotifyGui
            
            local Count = 0
            CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for i, v in pairs(CoreGui.NotifyGui.NotifyLayout:GetChildren()) do
                    if v:IsA("Frame") then
                        TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                            { Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count)) }):Play()
                        Count = Count + 1
                    end
                end
            end)
        end
        
        local NotifyPosHeight = 0
        for i, v in pairs(CoreGui.NotifyGui.NotifyLayout:GetChildren()) do
            if v:IsA("Frame") then
                NotifyPosHeight = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
            end
        end
        
        local NotifyFrame = Instance.new("Frame")
        local NotifyFrameReal = Instance.new("Frame")
        local UICorner = Instance.new("UICorner")
        local Top = Instance.new("Frame")
        local TitleLabel = Instance.new("TextLabel")
        local UICorner1 = Instance.new("UICorner")
        local DescLabel = Instance.new("TextLabel")
        local Close = Instance.new("TextButton")
        local CloseImg = Instance.new("ImageLabel")
        local ContentLabel = Instance.new("TextLabel")
        local IconImg = Instance.new("ImageLabel")
        
        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
        NotifyFrame.Name = "NotifyFrame"
        NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout
        NotifyFrame.AnchorPoint = Vector2.new(0, 1)
        NotifyFrame.Position = UDim2.new(0, 0, 1, -NotifyPosHeight)
        
        NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
        NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
        NotifyFrameReal.Name = "NotifyFrameReal"
        NotifyFrameReal.Parent = NotifyFrame
        
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = NotifyFrameReal
        
        Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Top.BackgroundTransparency = 0.999
        Top.Size = UDim2.new(1, 0, 0, 36)
        Top.Name = "Top"
        Top.Parent = NotifyFrameReal
        
        if NotifyConfig.Icon then
            IconImg.BackgroundTransparency = 1
            IconImg.Position = UDim2.new(0, 8, 0, 8)
            IconImg.Size = UDim2.new(0, 20, 0, 20)
            IconImg.Name = "IconImg"
            IconImg.Parent = Top
            
            if Icons[NotifyConfig.Icon] then
                IconImg.Image = Icons[NotifyConfig.Icon]
            else
                IconImg.Image = NotifyConfig.Icon
            end
        end
        
        local titleOffset = NotifyConfig.Icon and 35 or 10
        
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = NotifyConfig.Title
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 14
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Size = UDim2.new(1, 0, 1, 0)
        TitleLabel.Position = UDim2.new(0, titleOffset, 0, 0)
        TitleLabel.Parent = Top
        
        UICorner1.CornerRadius = UDim.new(0, 5)
        UICorner1.Parent = Top
        
        DescLabel.Font = Enum.Font.GothamBold
        DescLabel.Text = NotifyConfig.Description
        DescLabel.TextColor3 = NotifyConfig.Color
        DescLabel.TextSize = 14
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.BackgroundTransparency = 1
        DescLabel.Size = UDim2.new(1, 0, 1, 0)
        DescLabel.Position = UDim2.new(0, TitleLabel.TextBounds.X + titleOffset + 5, 0, 0)
        DescLabel.Parent = Top
        
        Close.Text = ""
        Close.AnchorPoint = Vector2.new(1, 0.5)
        Close.BackgroundTransparency = 1
        Close.Position = UDim2.new(1, -5, 0.5, 0)
        Close.Size = UDim2.new(0, 25, 0, 25)
        Close.Name = "Close"
        Close.Parent = Top
        
        CloseImg.Image = "rbxassetid://9886659671"
        CloseImg.AnchorPoint = Vector2.new(0.5, 0.5)
        CloseImg.BackgroundTransparency = 1
        CloseImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        CloseImg.Size = UDim2.new(1, -8, 1, -8)
        CloseImg.Parent = Close
        
        ContentLabel.Font = Enum.Font.GothamBold
        ContentLabel.Text = NotifyConfig.Content
        ContentLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        ContentLabel.TextSize = 13
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.Position = UDim2.new(0, 10, 0, 27)
        ContentLabel.TextWrapped = true
        ContentLabel.Parent = NotifyFrameReal
        ContentLabel.Size = UDim2.new(1, -20, 0, 13)
        
        ContentLabel.Size = UDim2.new(1, -20, 0, 13 + (13 * (ContentLabel.TextBounds.X // ContentLabel.AbsoluteSize.X)))
        
        local totalHeight = ContentLabel.AbsoluteSize.Y < 27 and 65 or ContentLabel.AbsoluteSize.Y + 40
        NotifyFrame.Size = UDim2.new(1, 0, 0, totalHeight)
        
        local waitbruh = false
        function NotifyFunction:Close()
            if waitbruh then return false end
            waitbruh = true
            TweenService:Create(NotifyFrameReal, TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                { Position = UDim2.new(0, 400, 0, 0) }):Play()
            task.wait(tonumber(NotifyConfig.Time) / 1.2)
            NotifyFrame:Destroy()
        end
        
        Close.Activated:Connect(function()
            NotifyFunction:Close()
        end)
        
        TweenService:Create(NotifyFrameReal, TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
            { Position = UDim2.new(0, 0, 0, 0) }):Play()
        task.wait(tonumber(NotifyConfig.Delay))
        NotifyFunction:Close()
    end)
    
    return NotifyFunction
end

function Nt(msg, delay, color, title, desc)
    return Chloex:MakeNotify({
        Title = title or "NexaHub",
        Description = desc or "Notification",
        Content = msg or "Content",
        Color = color or Color3.fromRGB(0, 208, 255),
        Delay = delay or 4
    })
end

-- ==================== MAIN WINDOW ====================
function Chloex:Window(GuiConfig)
    GuiConfig = GuiConfig or {}
    GuiConfig.Title = GuiConfig.Title or "Chloe X"
    GuiConfig.Footer = GuiConfig.Footer or "Chloee :3"
    GuiConfig.Color = GuiConfig.Color or Color3.fromRGB(255, 0, 255)
    GuiConfig["Tab Width"] = GuiConfig["Tab Width"] or 120
    GuiConfig.Version = GuiConfig.Version or 1
    GuiConfig.Image = GuiConfig.Image or "70884221600423"
    GuiConfig.Theme = GuiConfig.Theme or nil
    GuiConfig.ThemeTransparency = GuiConfig.ThemeTransparency or 0.15
    GuiConfig.CloseCallback = GuiConfig.CloseCallback or function() end
    
    CURRENT_VERSION = GuiConfig.Version
    LoadConfigFromFile()
    
    local GuiFunc = {}
    
    -- Create main GUI
    local Chloeex = Instance.new("ScreenGui")
    Chloeex.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Chloeex.Name = "Chloeex"
    Chloeex.ResetOnSpawn = false
    Chloeex.Parent = CoreGui
    
    local DropShadowHolder = Instance.new("Frame")
    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadowHolder.Size = isMobile and safeSize(470, 270) or safeSize(640, 400)
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = Chloeex
    
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
    DropShadow.ImageTransparency = 1
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.ZIndex = 0
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder
    
    local Main
    if GuiConfig.Theme then
        Main = Instance.new("ImageLabel")
        Main.Image = "rbxassetid://" .. GuiConfig.Theme
        Main.ScaleType = Enum.ScaleType.Crop
        Main.BackgroundTransparency = 1
        Main.ImageTransparency = GuiConfig.ThemeTransparency
    else
        Main = Instance.new("Frame")
        Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Main.BackgroundTransparency = 0
    end
    
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -47, 1, -47)
    Main.Name = "Main"
    Main.Parent = DropShadow
    
    local UICorner = Instance.new("UICorner")
    UICorner.Parent = Main
    
    -- Top bar
    local Top = Instance.new("Frame")
    Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Top.BackgroundTransparency = 0.999
    Top.Size = UDim2.new(1, 0, 0, 38)
    Top.Name = "Top"
    Top.Parent = Main
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.Parent = Top
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = GuiConfig.Title
    TitleLabel.TextColor3 = GuiConfig.Color
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Parent = Top
    
    local FooterLabel = Instance.new("TextLabel")
    FooterLabel.Font = Enum.Font.GothamBold
    FooterLabel.Text = GuiConfig.Footer
    FooterLabel.TextColor3 = GuiConfig.Color
    FooterLabel.TextSize = 14
    FooterLabel.TextXAlignment = Enum.TextXAlignment.Left
    FooterLabel.BackgroundTransparency = 1
    FooterLabel.Size = UDim2.new(1, -(TitleLabel.TextBounds.X + 104), 1, 0)
    FooterLabel.Position = UDim2.new(0, TitleLabel.TextBounds.X + 15, 0, 0)
    FooterLabel.Parent = Top
    
    -- Close button
    local Close = Instance.new("TextButton")
    Close.Text = ""
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundTransparency = 1
    Close.Position = UDim2.new(1, -8, 0.5, 0)
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.Name = "Close"
    Close.Parent = Top
    
    local CloseImg = Instance.new("ImageLabel")
    CloseImg.Image = "rbxassetid://9886659671"
    CloseImg.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseImg.BackgroundTransparency = 1
    CloseImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseImg.Size = UDim2.new(1, -8, 1, -8)
    CloseImg.Parent = Close
    
    -- Minimize button
    local Min = Instance.new("TextButton")
    Min.Text = ""
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.BackgroundTransparency = 1
    Min.Position = UDim2.new(1, -38, 0.5, 0)
    Min.Size = UDim2.new(0, 25, 0, 25)
    Min.Name = "Min"
    Min.Parent = Top
    
    local MinImg = Instance.new("ImageLabel")
    MinImg.Image = "rbxassetid://9886659276"
    MinImg.AnchorPoint = Vector2.new(0.5, 0.5)
    MinImg.BackgroundTransparency = 1
    MinImg.ImageTransparency = 0.2
    MinImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinImg.Size = UDim2.new(1, -9, 1, -9)
    MinImg.Parent = Min
    
    -- Tab section
    local LayersTab = Instance.new("Frame")
    LayersTab.BackgroundTransparency = 0.999
    LayersTab.Position = UDim2.new(0, 9, 0, 50)
    LayersTab.Size = UDim2.new(0, GuiConfig["Tab Width"], 1, -59)
    LayersTab.Name = "LayersTab"
    LayersTab.Parent = Main
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 2)
    TabCorner.Parent = LayersTab
    
    local DecideFrame = Instance.new("Frame")
    DecideFrame.AnchorPoint = Vector2.new(0.5, 0)
    DecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DecideFrame.BackgroundTransparency = 0.85
    DecideFrame.Position = UDim2.new(0.5, 0, 0, 38)
    DecideFrame.Size = UDim2.new(1, 0, 0, 1)
    DecideFrame.Name = "DecideFrame"
    DecideFrame.Parent = Main
    
    -- Content section
    local Layers = Instance.new("Frame")
    Layers.BackgroundTransparency = 0.999
    Layers.Position = UDim2.new(0, GuiConfig["Tab Width"] + 18, 0, 50)
    Layers.Size = UDim2.new(1, -(GuiConfig["Tab Width"] + 27), 1, -59)
    Layers.Name = "Layers"
    Layers.Parent = Main
    
    local LayersCorner = Instance.new("UICorner")
    LayersCorner.CornerRadius = UDim.new(0, 2)
    LayersCorner.Parent = Layers
    
    local NameTab = Instance.new("TextLabel")
    NameTab.Font = Enum.Font.GothamBold
    NameTab.Text = ""
    NameTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameTab.TextSize = 24
    NameTab.TextWrapped = true
    NameTab.TextXAlignment = Enum.TextXAlignment.Left
    NameTab.BackgroundTransparency = 1
    NameTab.Size = UDim2.new(1, 0, 0, 30)
    NameTab.Name = "NameTab"
    NameTab.Parent = Layers
    
    local LayersReal = Instance.new("Frame")
    LayersReal.AnchorPoint = Vector2.new(0, 1)
    LayersReal.BackgroundTransparency = 1
    LayersReal.ClipsDescendants = true
    LayersReal.Position = UDim2.new(0, 0, 1, 0)
    LayersReal.Size = UDim2.new(1, 0, 1, -33)
    LayersReal.Name = "LayersReal"
    LayersReal.Parent = Layers
    
    local LayersFolder = Instance.new("Folder")
    LayersFolder.Name = "LayersFolder"
    LayersFolder.Parent = LayersReal
    
    local LayersPageLayout = Instance.new("UIPageLayout")
    LayersPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LayersPageLayout.TweenTime = 0.5
    LayersPageLayout.EasingDirection = Enum.EasingDirection.InOut
    LayersPageLayout.EasingStyle = Enum.EasingStyle.Quad
    LayersPageLayout.Name = "LayersPageLayout"
    LayersPageLayout.Parent = LayersFolder
    
    local ScrollTab = Instance.new("ScrollingFrame")
    ScrollTab.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    ScrollTab.ScrollBarThickness = 0
    ScrollTab.Active = true
    ScrollTab.BackgroundTransparency = 1
    ScrollTab.Size = UDim2.new(1, 0, 1, 0)
    ScrollTab.Name = "ScrollTab"
    ScrollTab.Parent = LayersTab
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 3)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollTab
    
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollTab.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Dropdown overlay
    local MoreBlur = Instance.new("Frame")
    MoreBlur.AnchorPoint = Vector2.new(1, 1)
    MoreBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BackgroundTransparency = 0.999
    MoreBlur.ClipsDescendants = true
    MoreBlur.Position = UDim2.new(1, 8, 1, 8)
    MoreBlur.Size = UDim2.new(1, 154, 1, 54)
    MoreBlur.Visible = false
    MoreBlur.Name = "MoreBlur"
    MoreBlur.Parent = Layers
    
    local MoreBlurCorner = Instance.new("UICorner")
    MoreBlurCorner.Parent = MoreBlur
    
    local ConnectButton = Instance.new("TextButton")
    ConnectButton.Text = ""
    ConnectButton.BackgroundTransparency = 0.999
    ConnectButton.Size = UDim2.new(1, 0, 1, 0)
    ConnectButton.Name = "ConnectButton"
    ConnectButton.Parent = MoreBlur
    
    ConnectButton.Activated:Connect(function()
        if MoreBlur.Visible then
            TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 0.999 }):Play()
            task.wait(0.3)
            MoreBlur.Visible = false
        end
    end)
    
    local DropdownSelect = Instance.new("Frame")
    DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
    DropdownSelect.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
    DropdownSelect.Size = UDim2.new(0, 160, 1, -16)
    DropdownSelect.ClipsDescendants = true
    DropdownSelect.Name = "DropdownSelect"
    DropdownSelect.Parent = MoreBlur
    
    local DropSelectCorner = Instance.new("UICorner")
    DropSelectCorner.CornerRadius = UDim.new(0, 3)
    DropSelectCorner.Parent = DropdownSelect
    
    local DropStroke = Instance.new("UIStroke")
    DropStroke.Color = Color3.fromRGB(12, 159, 255)
    DropStroke.Thickness = 2.5
    DropStroke.Transparency = 0.8
    DropStroke.Parent = DropdownSelect
    
    local DropdownSelectReal = Instance.new("Frame")
    DropdownSelectReal.AnchorPoint = Vector2.new(0.5, 0.5)
    DropdownSelectReal.BackgroundColor3 = Color3.fromRGB(0, 27, 98)
    DropdownSelectReal.BackgroundTransparency = 0.7
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
    
    -- Button handlers
    function GuiFunc:DestroyGui()
        if CoreGui:FindFirstChild("Chloeex") then
            Chloeex:Destroy()
        end
        if CoreGui:FindFirstChild("ToggleUIButton") then
            CoreGui.ToggleUIButton:Destroy()
        end
    end
    
    Min.Activated:Connect(function()
        CircleClick(Min, Mouse.X, Mouse.Y)
        DropShadowHolder.Visible = false
    end)
    
    Close.Activated:Connect(function()
        CircleClick(Close, Mouse.X, Mouse.Y)
        
        -- Create confirmation dialog
        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.3
        Overlay.ZIndex = 50
        Overlay.Parent = DropShadowHolder
        
        local Dialog = Instance.new("ImageLabel")
        Dialog.Size = UDim2.new(0, 300, 0, 150)
        Dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
        Dialog.Image = "rbxassetid://9542022979"
        Dialog.ZIndex = 51
        Dialog.Parent = Overlay
        
        local DialogCorner = Instance.new("UICorner")
        DialogCorner.CornerRadius = UDim.new(0, 8)
        DialogCorner.Parent = Dialog
        
        local DialogGlow = Instance.new("Frame")
        DialogGlow.Size = UDim2.new(0, 310, 0, 160)
        DialogGlow.Position = UDim2.new(0.5, -155, 0.5, -80)
        DialogGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DialogGlow.BackgroundTransparency = 0.75
        DialogGlow.ZIndex = 50
        DialogGlow.Parent = Overlay
        
        local GlowCorner = Instance.new("UICorner")
        GlowCorner.CornerRadius = UDim.new(0, 10)
        GlowCorner.Parent = DialogGlow
        
        local Gradient = Instance.new("UIGradient")
        Gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(0, 191, 255)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 140, 255)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(0, 191, 255))
        })
        Gradient.Rotation = 90
        Gradient.Parent = DialogGlow
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 40)
        Title.Position = UDim2.new(0, 0, 0, 4)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamBold
        Title.Text = "Close Window?"
        Title.TextSize = 22
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.ZIndex = 52
        Title.Parent = Dialog
        
        local Message = Instance.new("TextLabel")
        Message.Size = UDim2.new(1, -20, 0, 60)
        Message.Position = UDim2.new(0, 10, 0, 30)
        Message.BackgroundTransparency = 1
        Message.Font = Enum.Font.Gotham
        Message.Text = "Are you sure you want to close?\nThis will destroy the UI"
        Message.TextSize = 14
        Message.TextColor3 = Color3.fromRGB(200, 200, 200)
        Message.TextWrapped = true
        Message.ZIndex = 52
        Message.Parent = Dialog
        
        local Yes = Instance.new("TextButton")
        Yes.Size = UDim2.new(0.45, -10, 0, 35)
        Yes.Position = UDim2.new(0.05, 0, 1, -55)
        Yes.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Yes.BackgroundTransparency = 0.935
        Yes.Text = "Yes"
        Yes.Font = Enum.Font.GothamBold
        Yes.TextSize = 15
        Yes.TextColor3 = Color3.fromRGB(255, 255, 255)
        Yes.TextTransparency = 0.3
        Yes.ZIndex = 52
        Yes.Parent = Dialog
        
        local YesCorner = Instance.new("UICorner")
        YesCorner.CornerRadius = UDim.new(0, 6)
        YesCorner.Parent = Yes
        
        local Cancel = Instance.new("TextButton")
        Cancel.Size = UDim2.new(0.45, -10, 0, 35)
        Cancel.Position = UDim2.new(0.5, 10, 1, -55)
        Cancel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.BackgroundTransparency = 0.935
        Cancel.Text = "Cancel"
        Cancel.Font = Enum.Font.GothamBold
        Cancel.TextSize = 15
        Cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.TextTransparency = 0.3
        Cancel.ZIndex = 52
        Cancel.Parent = Dialog
        
        local CancelCorner = Instance.new("UICorner")
        CancelCorner.CornerRadius = UDim.new(0, 6)
        CancelCorner.Parent = Cancel
        
        Yes.MouseButton1Click:Connect(function()
            GuiConfig.CloseCallback()
            GuiFunc:DestroyGui()
        end)
        
        Cancel.MouseButton1Click:Connect(function()
            Overlay:Destroy()
        end)
    end)
    
    -- Toggle UI button
    function GuiFunc:ToggleUI()
        if CoreGui:FindFirstChild("ToggleUIButton") then
            CoreGui.ToggleUIButton:Destroy()
        end
        
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Name = "ToggleUIButton"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = CoreGui
        
        local MainButton = Instance.new("ImageLabel")
        MainButton.Size = UDim2.new(0, 40, 0, 40)
        MainButton.Position = UDim2.new(0, 20, 0, 100)
        MainButton.BackgroundTransparency = 1
        MainButton.Image = "rbxassetid://" .. GuiConfig.Image
        MainButton.ScaleType = Enum.ScaleType.Fit
        MainButton.Parent = ScreenGui
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 6)
        UICorner.Parent = MainButton
        
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = ""
        Button.Parent = MainButton
        
        Button.MouseButton1Click:Connect(function()
            if DropShadowHolder then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
            end
        end)
        
        -- Make draggable
        local dragging, dragStart, startPos
        
        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainButton.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                MainButton.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    GuiFunc:ToggleUI()
    
    DropShadowHolder.Size = UDim2.new(0, 115 + TitleLabel.TextBounds.X + 1 + FooterLabel.TextBounds.X, 0, 350)
    MakeDraggable(Top, DropShadowHolder)
    MakeResizable(DropShadowHolder)
    
    -- Tab management
    local Tabs = {}
    local CountTab = 0
    local CountDropdown = 0
    
    function Tabs:AddTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""
        
        local ScrolLayers = Instance.new("ScrollingFrame")
        ScrolLayers.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        ScrolLayers.ScrollBarThickness = 0
        ScrolLayers.Active = true
        ScrolLayers.LayoutOrder = CountTab
        ScrolLayers.BackgroundTransparency = 1
        ScrolLayers.Size = UDim2.new(1, 0, 1, 0)
        ScrolLayers.Name = "ScrolLayers"
        ScrolLayers.Parent = LayersFolder
        
        local UIListLayout1 = Instance.new("UIListLayout")
        UIListLayout1.Padding = UDim.new(0, 3)
        UIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout1.Parent = ScrolLayers
        
        UIListLayout1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, UIListLayout1.AbsoluteContentSize.Y + 10)
        end)
        
        local Tab = Instance.new("Frame")
        Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Tab.BackgroundTransparency = (CountTab == 0) and 0.92 or 0.999
        Tab.LayoutOrder = CountTab
        Tab.Size = UDim2.new(1, 0, 0, 30)
        Tab.Name = "Tab"
        Tab.Parent = ScrollTab
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = Tab
        
        local TabButton = Instance.new("TextButton")
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = ""
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Name = "TabButton"
        TabButton.Parent = Tab
        
        local TabName = Instance.new("TextLabel")
        TabName.Font = Enum.Font.GothamBold
        TabName.Text = "| " .. tostring(TabConfig.Name)
        TabName.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabName.TextSize = 13
        TabName.TextXAlignment = Enum.TextXAlignment.Left
        TabName.BackgroundTransparency = 1
        TabName.Size = UDim2.new(1, 0, 1, 0)
        TabName.Position = UDim2.new(0, 30, 0, 0)
        TabName.Name = "TabName"
        TabName.Parent = Tab
        
        local FeatureImg = Instance.new("ImageLabel")
        FeatureImg.BackgroundTransparency = 1
        FeatureImg.Position = UDim2.new(0, 9, 0, 7)
        FeatureImg.Size = UDim2.new(0, 16, 0, 16)
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = Tab
        
        if TabConfig.Icon ~= "" then
            if Icons[TabConfig.Icon] then
                FeatureImg.Image = Icons[TabConfig.Icon]
            else
                FeatureImg.Image = TabConfig.Icon
            end
        end
        
        if CountTab == 0 then
            LayersPageLayout:JumpToIndex(0)
            NameTab.Text = TabConfig.Name
            
            local ChooseFrame = Instance.new("Frame")
            ChooseFrame.BackgroundColor3 = GuiConfig.Color
            ChooseFrame.Position = UDim2.new(0, 2, 0, 9)
            ChooseFrame.Size = UDim2.new(0, 1, 0, 12)
            ChooseFrame.Name = "ChooseFrame"
            ChooseFrame.Parent = Tab
            
            local ChooseCorner = Instance.new("UICorner")
            ChooseCorner.Parent = ChooseFrame
            
            local ChooseStroke = Instance.new("UIStroke")
            ChooseStroke.Color = GuiConfig.Color
            ChooseStroke.Thickness = 1.6
            ChooseStroke.Parent = ChooseFrame
        end
        
        TabButton.Activated:Connect(function()
            CircleClick(TabButton, Mouse.X, Mouse.Y)
            
            local FrameChoose
            for _, s in pairs(ScrollTab:GetChildren()) do
                for _, v in pairs(s:GetChildren()) do
                    if v.Name == "ChooseFrame" then
                        FrameChoose = v
                        break
                    end
                end
            end
            
            if FrameChoose and Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
                for _, TabFrame in pairs(ScrollTab:GetChildren()) do
                    if TabFrame.Name == "Tab" then
                        TweenService:Create(TabFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                            { BackgroundTransparency = 0.999 }):Play()
                    end
                end
                
                TweenService:Create(Tab, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                    { BackgroundTransparency = 0.92 }):Play()
                TweenService:Create(FrameChoose, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Position = UDim2.new(0, 2, 0, 9 + (33 * Tab.LayoutOrder)) }):Play()
                LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
                task.wait(0.05)
                NameTab.Text = TabConfig.Name
                TweenService:Create(FrameChoose, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Size = UDim2.new(0, 1, 0, 20) }):Play()
                task.wait(0.2)
                TweenService:Create(FrameChoose, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Size = UDim2.new(0, 1, 0, 12) }):Play()
            end
        end)
        
        local Sections = {}
        local CountSection = 0
        
        function Sections:AddSection(Title, AlwaysOpen)
            Title = Title or "Title"
            
            local Section = Instance.new("Frame")
            Section.BackgroundTransparency = 1
            Section.LayoutOrder = CountSection
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(1, 0, 0, 30)
            Section.Name = "Section"
            Section.Parent = ScrolLayers
            
            local SectionReal = Instance.new("Frame")
            SectionReal.AnchorPoint = Vector2.new(0.5, 0)
            SectionReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionReal.BackgroundTransparency = 0.935
            SectionReal.Position = UDim2.new(0.5, 0, 0, 0)
            SectionReal.Size = UDim2.new(1, 1, 0, 30)
            SectionReal.Name = "SectionReal"
            SectionReal.Parent = Section
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 4)
            SectionCorner.Parent = SectionReal
            
            local SectionButton = Instance.new("TextButton")
            SectionButton.Text = ""
            SectionButton.BackgroundTransparency = 1
            SectionButton.Size = UDim2.new(1, 0, 1, 0)
            SectionButton.Name = "SectionButton"
            SectionButton.Parent = SectionReal
            
            local FeatureFrame = Instance.new("Frame")
            FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
            FeatureFrame.BackgroundTransparency = 1
            FeatureFrame.Position = UDim2.new(1, -5, 0.5, 0)
            FeatureFrame.Size = UDim2.new(0, 20, 0, 20)
            FeatureFrame.Name = "FeatureFrame"
            FeatureFrame.Parent = SectionReal
            
            local FeatureImg = Instance.new("ImageLabel")
            FeatureImg.Image = "rbxassetid://16851841101"
            FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
            FeatureImg.BackgroundTransparency = 1
            FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
            FeatureImg.Rotation = -90
            FeatureImg.Size = UDim2.new(1, 6, 1, 6)
            FeatureImg.Name = "FeatureImg"
            FeatureImg.Parent = FeatureFrame
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = Title
            SectionTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
            SectionTitle.TextSize = 13
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.TextYAlignment = Enum.TextYAlignment.Top
            SectionTitle.AnchorPoint = Vector2.new(0, 0.5)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 10, 0.5, 0)
            SectionTitle.Size = UDim2.new(1, -50, 0, 13)
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionReal
            
            local SectionDecideFrame = Instance.new("Frame")
            SectionDecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionDecideFrame.AnchorPoint = Vector2.new(0.5, 0)
            SectionDecideFrame.Position = UDim2.new(0.5, 0, 0, 33)
            SectionDecideFrame.Size = UDim2.new(0, 0, 0, 2)
            SectionDecideFrame.Name = "SectionDecideFrame"
            SectionDecideFrame.Parent = Section
            
            local SectionDivCorner = Instance.new("UICorner")
            SectionDivCorner.Parent = SectionDecideFrame
            
            local SectionGradient = Instance.new("UIGradient")
            SectionGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
                ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
            })
            SectionGradient.Parent = SectionDecideFrame
            
            local SectionAdd = Instance.new("Frame")
            SectionAdd.AnchorPoint = Vector2.new(0.5, 0)
            SectionAdd.BackgroundTransparency = 1
            SectionAdd.ClipsDescendants = true
            SectionAdd.Position = UDim2.new(0.5, 0, 0, 38)
            SectionAdd.Size = UDim2.new(1, 0, 0, 100)
            SectionAdd.Name = "SectionAdd"
            SectionAdd.Parent = Section
            
            local AddCorner = Instance.new("UICorner")
            AddCorner.CornerRadius = UDim.new(0, 2)
            AddCorner.Parent = SectionAdd
            
            local UIListLayout2 = Instance.new("UIListLayout")
            UIListLayout2.Padding = UDim.new(0, 3)
            UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout2.Parent = SectionAdd
            
            local OpenSection = false
            
            local function UpdateSizeScroll()
                task.wait()
                local OffsetY = 0
                for _, child in pairs(ScrolLayers:GetChildren()) do
                    if child.Name ~= "UIListLayout" then
                        OffsetY = OffsetY + 3 + child.Size.Y.Offset
                    end
                end
                ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
            end
            
            local function UpdateSizeSection()
                if OpenSection then
                    local SectionSizeYWidth = 38
                    for _, v in pairs(SectionAdd:GetChildren()) do
                        if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
                            SectionSizeYWidth = SectionSizeYWidth + v.Size.Y.Offset + 3
                        end
                    end
                    TweenService:Create(FeatureFrame, TweenInfo.new(0.5), { Rotation = 90 }):Play()
                    TweenService:Create(Section, TweenInfo.new(0.5), { Size = UDim2.new(1, 1, 0, SectionSizeYWidth) }):Play()
                    TweenService:Create(SectionAdd, TweenInfo.new(0.5), { Size = UDim2.new(1, 0, 0, SectionSizeYWidth - 38) }):Play()
                    TweenService:Create(SectionDecideFrame, TweenInfo.new(0.5), { Size = UDim2.new(1, 0, 0, 2) }):Play()
                    task.wait(0.5)
                    UpdateSizeScroll()
                end
            end
            
            if AlwaysOpen == true then
                SectionButton:Destroy()
                FeatureFrame:Destroy()
                OpenSection = true
                UpdateSizeSection()
            elseif AlwaysOpen == false then
                OpenSection = true
                UpdateSizeSection()
            else
                OpenSection = false
            end
            
            if AlwaysOpen ~= true then
                SectionButton.Activated:Connect(function()
                    CircleClick(SectionButton, Mouse.X, Mouse.Y)
                    if OpenSection then
                        TweenService:Create(FeatureFrame, TweenInfo.new(0.5), { Rotation = 0 }):Play()
                        TweenService:Create(Section, TweenInfo.new(0.5), { Size = UDim2.new(1, 1, 0, 30) }):Play()
                        TweenService:Create(SectionDecideFrame, TweenInfo.new(0.5), { Size = UDim2.new(0, 0, 0, 2) }):Play()
                        OpenSection = false
                        task.wait(0.5)
                        UpdateSizeScroll()
                    else
                        OpenSection = true
                        UpdateSizeSection()
                    end
                end)
            end
            
            if AlwaysOpen then
                OpenSection = true
                local SectionSizeYWidth = 38
                for _, v in pairs(SectionAdd:GetChildren()) do
                    if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
                        SectionSizeYWidth = SectionSizeYWidth + v.Size.Y.Offset + 3
                    end
                end
                if AlwaysOpen ~= true then
                    FeatureFrame.Rotation = 90
                end
                Section.Size = UDim2.new(1, 1, 0, SectionSizeYWidth)
                SectionAdd.Size = UDim2.new(1, 0, 0, SectionSizeYWidth - 38)
                SectionDecideFrame.Size = UDim2.new(1, 0, 0, 2)
                UpdateSizeScroll()
            end
            
            SectionAdd.ChildAdded:Connect(UpdateSizeSection)
            SectionAdd.ChildRemoved:Connect(UpdateSizeSection)
            
            local Items = {}
            local CountItem = 0
            
            -- ==================== ADD PARAGRAPH ====================
            function Items:AddParagraph(ParagraphConfig)
                ParagraphConfig = ParagraphConfig or {}
                ParagraphConfig.Title = ParagraphConfig.Title or "Title"
                ParagraphConfig.Content = ParagraphConfig.Content or "Content"
                ParagraphConfig.Icon = ParagraphConfig.Icon or nil
                ParagraphConfig.ButtonText = ParagraphConfig.ButtonText or nil
                ParagraphConfig.ButtonCallback = ParagraphConfig.ButtonCallback or function() end
                
                local ParagraphFunc = {}
                
                local Paragraph = Instance.new("Frame")
                Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Paragraph.BackgroundTransparency = 0.935
                Paragraph.LayoutOrder = CountItem
                Paragraph.Size = UDim2.new(1, 0, 0, 46)
                Paragraph.Name = "Paragraph"
                Paragraph.Parent = SectionAdd
                
                local ParaCorner = Instance.new("UICorner")
                ParaCorner.CornerRadius = UDim.new(0, 4)
                ParaCorner.Parent = Paragraph
                
                local iconOffset = 10
                if ParagraphConfig.Icon then
                    local IconImg = Instance.new("ImageLabel")
                    IconImg.Size = UDim2.new(0, 20, 0, 20)
                    IconImg.Position = UDim2.new(0, 8, 0, 12)
                    IconImg.BackgroundTransparency = 1
                    IconImg.Name = "ParagraphIcon"
                    IconImg.Parent = Paragraph
                    
                    if Icons[ParagraphConfig.Icon] then
                        IconImg.Image = Icons[ParagraphConfig.Icon]
                    else
                        IconImg.Image = ParagraphConfig.Icon
                    end
                    
                    iconOffset = 35
                end
                
                local ParagraphTitle = Instance.new("TextLabel")
                ParagraphTitle.Font = Enum.Font.GothamBold
                ParagraphTitle.Text = ParagraphConfig.Title
                ParagraphTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
                ParagraphTitle.TextSize = 13
                ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
                ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
                ParagraphTitle.BackgroundTransparency = 1
                ParagraphTitle.Position = UDim2.new(0, iconOffset, 0, 10)
                ParagraphTitle.Size = UDim2.new(1, -iconOffset - 10, 0, 13)
                ParagraphTitle.Name = "ParagraphTitle"
                ParagraphTitle.Parent = Paragraph
                
                local ParagraphContent = Instance.new("TextLabel")
                ParagraphContent.Font = Enum.Font.Gotham
                ParagraphContent.Text = ParagraphConfig.Content
                ParagraphContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                ParagraphContent.TextSize = 12
                ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
                ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
                ParagraphContent.BackgroundTransparency = 1
                ParagraphContent.Position = UDim2.new(0, iconOffset, 0, 25)
                ParagraphContent.TextWrapped = true
                ParagraphContent.RichText = true
                ParagraphContent.Name = "ParagraphContent"
                ParagraphContent.Parent = Paragraph
                
                ParagraphContent.Size = UDim2.new(1, -iconOffset - 10, 0, ParagraphContent.TextBounds.Y)
                
                local ParagraphButton
                if ParagraphConfig.ButtonText then
                    ParagraphButton = Instance.new("TextButton")
                    ParagraphButton.Position = UDim2.new(0, 10, 0, 42)
                    ParagraphButton.Size = UDim2.new(1, -20, 0, 28)
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
                    
                    ParagraphButton.MouseButton1Click:Connect(function()
                        CircleClick(ParagraphButton, Mouse.X, Mouse.Y)
                        task.spawn(ParagraphConfig.ButtonCallback)
                    end)
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
                
                function ParagraphFunc:SetTitle(title)
                    title = title or "Title"
                    ParagraphTitle.Text = title
                end
                
                CountItem = CountItem + 1
                return ParagraphFunc
            end
            
            -- ==================== ADD PANEL ====================
            function Items:AddPanel(PanelConfig)
                PanelConfig = PanelConfig or {}
                PanelConfig.Title = PanelConfig.Title or "Title"
                PanelConfig.Content = PanelConfig.Content or ""
                PanelConfig.Placeholder = PanelConfig.Placeholder or nil
                PanelConfig.Default = PanelConfig.Default or ""
                PanelConfig.ButtonText = PanelConfig.Button or PanelConfig.ButtonText or "Confirm"
                PanelConfig.ButtonCallback = PanelConfig.Callback or PanelConfig.ButtonCallback or function() end
                PanelConfig.SubButtonText = PanelConfig.SubButton or PanelConfig.SubButtonText or nil
                PanelConfig.SubButtonCallback = PanelConfig.SubCallback or PanelConfig.SubButtonCallback or function() end
                
                local configKey = "Panel_" .. PanelConfig.Title
                if ConfigData[configKey] ~= nil then
                    PanelConfig.Default = ConfigData[configKey]
                end
                
                local PanelFunc = { Value = PanelConfig.Default }
                
                local baseHeight = 50
                if PanelConfig.Placeholder then
                    baseHeight = baseHeight + 40
                end
                if PanelConfig.SubButtonText then
                    baseHeight = baseHeight + 40
                else
                    baseHeight = baseHeight + 36
                end
                
                local Panel = Instance.new("Frame")
                Panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Panel.BackgroundTransparency = 0.935
                Panel.Size = UDim2.new(1, 0, 0, baseHeight)
                Panel.LayoutOrder = CountItem
                Panel.Name = "Panel"
                Panel.Parent = SectionAdd
                
                local PanelCorner = Instance.new("UICorner")
                PanelCorner.CornerRadius = UDim.new(0, 4)
                PanelCorner.Parent = Panel
                
                local Title = Instance.new("TextLabel")
                Title.Font = Enum.Font.GothamBold
                Title.Text = PanelConfig.Title
                Title.TextSize = 13
                Title.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 10)
                Title.Size = UDim2.new(1, -20, 0, 13)
                Title.Parent = Panel
                
                local Content = Instance.new("TextLabel")
                Content.Font = Enum.Font.Gotham
                Content.Text = PanelConfig.Content
                Content.TextSize = 12
                Content.TextColor3 = Color3.fromRGB(255, 255, 255)
                Content.TextTransparency = 0
                Content.TextXAlignment = Enum.TextXAlignment.Left
                Content.BackgroundTransparency = 1
                Content.RichText = true
                Content.Position = UDim2.new(0, 10, 0, 28)
                Content.Size = UDim2.new(1, -20, 0, 14)
                Content.Parent = Panel
                
                local InputBox
                if PanelConfig.Placeholder then
                    local InputFrame = Instance.new("Frame")
                    InputFrame.AnchorPoint = Vector2.new(0.5, 0)
                    InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    InputFrame.BackgroundTransparency = 0.95
                    InputFrame.Position = UDim2.new(0.5, 0, 0, 48)
                    InputFrame.Size = UDim2.new(1, -20, 0, 30)
                    InputFrame.Parent = Panel
                    
                    local inputCorner = Instance.new("UICorner")
                    inputCorner.CornerRadius = UDim.new(0, 4)
                    inputCorner.Parent = InputFrame
                    
                    InputBox = Instance.new("TextBox")
                    InputBox.Font = Enum.Font.GothamBold
                    InputBox.PlaceholderText = PanelConfig.Placeholder
                    InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                    InputBox.Text = PanelConfig.Default
                    InputBox.TextSize = 11
                    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    InputBox.BackgroundTransparency = 1
                    InputBox.TextXAlignment = Enum.TextXAlignment.Left
                    InputBox.Size = UDim2.new(1, -10, 1, -6)
                    InputBox.Position = UDim2.new(0, 5, 0, 3)
                    InputBox.ClearTextOnFocus = false
                    InputBox.Parent = InputFrame
                end
                
                local yBtn = PanelConfig.Placeholder and 88 or 48
                
                local ButtonMain = Instance.new("TextButton")
                ButtonMain.Font = Enum.Font.GothamBold
                ButtonMain.Text = PanelConfig.ButtonText
                ButtonMain.TextColor3 = Color3.fromRGB(255, 255, 255)
                ButtonMain.TextSize = 12
                ButtonMain.TextTransparency = 0.3
                ButtonMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ButtonMain.BackgroundTransparency = 0.935
                ButtonMain.Size = PanelConfig.SubButtonText and UDim2.new(0.5, -12, 0, 30) or UDim2.new(1, -20, 0, 30)
                ButtonMain.Position = UDim2.new(0, 10, 0, yBtn)
                ButtonMain.Parent = Panel
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 6)
                btnCorner.Parent = ButtonMain
                
                ButtonMain.MouseButton1Click:Connect(function()
                    CircleClick(ButtonMain, Mouse.X, Mouse.Y)
                    task.spawn(function()
                        PanelConfig.ButtonCallback(InputBox and InputBox.Text or "")
                    end)
                end)
                
                if PanelConfig.SubButtonText then
                    local SubButton = Instance.new("TextButton")
                    SubButton.Font = Enum.Font.GothamBold
                    SubButton.Text = PanelConfig.SubButtonText
                    SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.TextSize = 12
                    SubButton.TextTransparency = 0.3
                    SubButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.BackgroundTransparency = 0.935
                    SubButton.Size = UDim2.new(0.5, -12, 0, 30)
                    SubButton.Position = UDim2.new(0.5, 2, 0, yBtn)
                    SubButton.Parent = Panel
                    
                    local subCorner = Instance.new("UICorner")
                    subCorner.CornerRadius = UDim.new(0, 6)
                    subCorner.Parent = SubButton
                    
                    SubButton.MouseButton1Click:Connect(function()
                        CircleClick(SubButton, Mouse.X, Mouse.Y)
                        task.spawn(function()
                            PanelConfig.SubButtonCallback(InputBox and InputBox.Text or "")
                        end)
                    end)
                end
                
                if InputBox then
                    InputBox.FocusLost:Connect(function()
                        PanelFunc.Value = InputBox.Text
                        ConfigData[configKey] = InputBox.Text
                        SaveConfig()
                    end)
                end
                
                function PanelFunc:GetInput()
                    return InputBox and InputBox.Text or ""
                end
                
                function PanelFunc:SetInput(text)
                    if InputBox then
                        InputBox.Text = text
                        PanelFunc.Value = text
                        ConfigData[configKey] = text
                        SaveConfig()
                    end
                end
                
                CountItem = CountItem + 1
                Elements[configKey] = PanelFunc
                return PanelFunc
            end
            
            -- ==================== ADD BUTTON ====================
            function Items:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Title = ButtonConfig.Title or "Confirm"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                ButtonConfig.SubTitle = ButtonConfig.SubTitle or nil
                ButtonConfig.SubCallback = ButtonConfig.SubCallback or function() end
                
                local Button = Instance.new("Frame")
                Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Button.BackgroundTransparency = 0.935
                Button.Size = UDim2.new(1, 0, 0, 40)
                Button.LayoutOrder = CountItem
                Button.Name = "Button"
                Button.Parent = SectionAdd
                
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 4)
                BtnCorner.Parent = Button
                
                local MainButton = Instance.new("TextButton")
                MainButton.Font = Enum.Font.GothamBold
                MainButton.Text = ButtonConfig.Title
                MainButton.TextSize = 12
                MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                MainButton.TextTransparency = 0.3
                MainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                MainButton.BackgroundTransparency = 0.935
                MainButton.Size = ButtonConfig.SubTitle and UDim2.new(0.5, -8, 1, -10) or UDim2.new(1, -12, 1, -10)
                MainButton.Position = UDim2.new(0, 6, 0, 5)
                MainButton.Parent = Button
                
                local mainCorner = Instance.new("UICorner")
                mainCorner.CornerRadius = UDim.new(0, 4)
                mainCorner.Parent = MainButton
                
                MainButton.MouseButton1Click:Connect(function()
                    CircleClick(MainButton, Mouse.X, Mouse.Y)
                    task.spawn(ButtonConfig.Callback)
                end)
                
                if ButtonConfig.SubTitle then
                    local SubButton = Instance.new("TextButton")
                    SubButton.Font = Enum.Font.GothamBold
                    SubButton.Text = ButtonConfig.SubTitle
                    SubButton.TextSize = 12
                    SubButton.TextTransparency = 0.3
                    SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    SubButton.BackgroundTransparency = 0.935
                    SubButton.Size = UDim2.new(0.5, -8, 1, -10)
                    SubButton.Position = UDim2.new(0.5, 2, 0, 5)
                    SubButton.Parent = Button
                    
                    local subCorner = Instance.new("UICorner")
                    subCorner.CornerRadius = UDim.new(0, 4)
                    subCorner.Parent = SubButton
                    
                    SubButton.MouseButton1Click:Connect(function()
                        CircleClick(SubButton, Mouse.X, Mouse.Y)
                        task.spawn(ButtonConfig.SubCallback)
                    end)
                end
                
                CountItem = CountItem + 1
            end
            
            -- ==================== ADD TOGGLE ====================
            function Items:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Title = ToggleConfig.Title or "Title"
                ToggleConfig.Title2 = ToggleConfig.Title2 or ""
                ToggleConfig.Content = ToggleConfig.Content or ""
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end
                
                local configKey = "Toggle_" .. ToggleConfig.Title
                if ConfigData[configKey] ~= nil then
                    ToggleConfig.Default = ConfigData[configKey]
                end
                
                local ToggleFunc = { Value = ToggleConfig.Default }
                
                local Toggle = Instance.new("Frame")
                Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Toggle.BackgroundTransparency = 0.935
                Toggle.LayoutOrder = CountItem
                Toggle.Name = "Toggle"
                Toggle.Parent = SectionAdd
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(0, 4)
                ToggleCorner.Parent = Toggle
                
                local ToggleTitle = Instance.new("TextLabel")
                ToggleTitle.Font = Enum.Font.GothamBold
                ToggleTitle.Text = ToggleConfig.Title
                ToggleTitle.TextSize = 13
                ToggleTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
                ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
                ToggleTitle.BackgroundTransparency = 1
                ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
                ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
                ToggleTitle.Name = "ToggleTitle"
                ToggleTitle.Parent = Toggle
                
                local ToggleTitle2 = Instance.new("TextLabel")
                ToggleTitle2.Font = Enum.Font.GothamBold
                ToggleTitle2.Text = ToggleConfig.Title2
                ToggleTitle2.TextSize = 12
                ToggleTitle2.TextColor3 = Color3.fromRGB(231, 231, 231)
                ToggleTitle2.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle2.TextYAlignment = Enum.TextYAlignment.Top
                ToggleTitle2.BackgroundTransparency = 1
                ToggleTitle2.Position = UDim2.new(0, 10, 0, 23)
                ToggleTitle2.Size = UDim2.new(1, -100, 0, 12)
                ToggleTitle2.Visible = (ToggleConfig.Title2 ~= "")
                ToggleTitle2.Name = "ToggleTitle2"
                ToggleTitle2.Parent = Toggle
                
                local ToggleContent = Instance.new("TextLabel")
                ToggleContent.Font = Enum.Font.GothamBold
                ToggleContent.Text = ToggleConfig.Content
                ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                ToggleContent.TextSize = 12
                ToggleContent.TextTransparency = 0.6
                ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
                ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
                ToggleContent.BackgroundTransparency = 1
                ToggleContent.Size = UDim2.new(1, -100, 0, 12)
                ToggleContent.TextWrapped = true
                ToggleContent.Name = "ToggleContent"
                ToggleContent.Parent = Toggle
                
                if ToggleConfig.Title2 ~= "" then
                    Toggle.Size = UDim2.new(1, 0, 0, 57)
                    ToggleContent.Position = UDim2.new(0, 10, 0, 36)
                else
                    Toggle.Size = UDim2.new(1, 0, 0, 46)
                    ToggleContent.Position = UDim2.new(0, 10, 0, 23)
                end
                
                ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * (ToggleContent.TextBounds.X // math.max(ToggleContent.AbsoluteSize.X, 1))))
                if ToggleConfig.Title2 ~= "" then
                    Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
                else
                    Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
                end
                
                ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    ToggleContent.TextWrapped = false
                    ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * (ToggleContent.TextBounds.X // math.max(ToggleContent.AbsoluteSize.X, 1))))
                    if ToggleConfig.Title2 ~= "" then
                        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 47)
                    else
                        Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
                    end
                    ToggleContent.TextWrapped = true
                    UpdateSizeSection()
                end)
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Text = ""
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Parent = Toggle
                
                local FeatureFrame = Instance.new("Frame")
                FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
                FeatureFrame.BackgroundTransparency = 0.92
                FeatureFrame.Position = UDim2.new(1, -15, 0.5, 0)
                FeatureFrame.Size = UDim2.new(0, 30, 0, 15)
                FeatureFrame.Name = "FeatureFrame"
                FeatureFrame.Parent = Toggle
                
                local FrameCorner = Instance.new("UICorner")
                FrameCorner.Parent = FeatureFrame
                
                local FrameStroke = Instance.new("UIStroke")
                FrameStroke.Color = Color3.fromRGB(255, 255, 255)
                FrameStroke.Thickness = 2
                FrameStroke.Transparency = 0.9
                FrameStroke.Parent = FeatureFrame
                
                local ToggleCircle = Instance.new("Frame")
                ToggleCircle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
                ToggleCircle.Position = UDim2.new(0, 0, 0, 0)
                ToggleCircle.Name = "ToggleCircle"
                ToggleCircle.Parent = FeatureFrame
                
                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(0, 15)
                CircleCorner.Parent = ToggleCircle
                
                ToggleButton.Activated:Connect(function()
                    CircleClick(ToggleButton, Mouse.X, Mouse.Y)
                    ToggleFunc.Value = not ToggleFunc.Value
                    ToggleFunc:Set(ToggleFunc.Value)
                end)
                
                function ToggleFunc:Set(Value, silent)
                    ToggleFunc.Value = Value
                    ConfigData[configKey] = Value
                    SaveConfig()
                    
                    if Value then
                        TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 15, 0, 0) }):Play()
                        TweenService:Create(FrameStroke, TweenInfo.new(0.2), { Color = GuiConfig.Color, Transparency = 0 }):Play()
                        TweenService:Create(FeatureFrame, TweenInfo.new(0.2), { BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0 }):Play()
                    else
                        TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 0, 0, 0) }):Play()
                        TweenService:Create(FrameStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
                        TweenService:Create(FeatureFrame, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
                    end
                    
                    if not silent and typeof(ToggleConfig.Callback) == "function" then
                        task.spawn(function()
                            local success, err = pcall(ToggleConfig.Callback, Value)
                            if not success then
                                warn("Toggle Callback error:", err)
                            end
                        end)
                    end
                end
                
                ToggleFunc:Set(ToggleFunc.Value, true)
                CountItem = CountItem + 1
                Elements[configKey] = ToggleFunc
                return ToggleFunc
            end
            
            -- ==================== ADD SLIDER ====================
            function Items:AddSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                SliderConfig.Title = SliderConfig.Title or "Slider"
                SliderConfig.Content = SliderConfig.Content or ""
                SliderConfig.Increment = SliderConfig.Increment or 1
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Default = SliderConfig.Default or 50
                SliderConfig.Callback = SliderConfig.Callback or function() end
                
                local configKey = "Slider_" .. SliderConfig.Title
                if ConfigData[configKey] ~= nil then
                    SliderConfig.Default = ConfigData[configKey]
                end
                
                local SliderFunc = { Value = SliderConfig.Default }
                
                local Slider = Instance.new("Frame")
                Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Slider.BackgroundTransparency = 0.935
                Slider.LayoutOrder = CountItem
                Slider.Size = UDim2.new(1, 0, 0, 46)
                Slider.Name = "Slider"
                Slider.Parent = SectionAdd
                
                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, 4)
                SliderCorner.Parent = Slider
                
                local SliderTitle = Instance.new("TextLabel")
                SliderTitle.Font = Enum.Font.GothamBold
                SliderTitle.Text = SliderConfig.Title
                SliderTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
                SliderTitle.TextSize = 13
                SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
                SliderTitle.BackgroundTransparency = 1
                SliderTitle.Position = UDim2.new(0, 10, 0, 10)
                SliderTitle.Size = UDim2.new(1, -180, 0, 13)
                SliderTitle.Name = "SliderTitle"
                SliderTitle.Parent = Slider
                
                local SliderContent = Instance.new("TextLabel")
                SliderContent.Font = Enum.Font.GothamBold
                SliderContent.Text = SliderConfig.Content
                SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderContent.TextSize = 12
                SliderContent.TextTransparency = 0.6
                SliderContent.TextXAlignment = Enum.TextXAlignment.Left
                SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
                SliderContent.BackgroundTransparency = 1
                SliderContent.Position = UDim2.new(0, 10, 0, 25)
                SliderContent.TextWrapped = true
                SliderContent.Size = UDim2.new(1, -180, 0, 12)
                SliderContent.Name = "SliderContent"
                SliderContent.Parent = Slider
                
                SliderContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (SliderContent.TextBounds.X // math.max(SliderContent.AbsoluteSize.X, 1))))
                Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
                
                SliderContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    SliderContent.TextWrapped = false
                    SliderContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (SliderContent.TextBounds.X // math.max(SliderContent.AbsoluteSize.X, 1))))
                    Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
                    SliderContent.TextWrapped = true
                    UpdateSizeSection()
                end)
                
                local SliderInput = Instance.new("Frame")
                SliderInput.AnchorPoint = Vector2.new(0, 0.5)
                SliderInput.BackgroundColor3 = GuiConfig.Color
                SliderInput.BackgroundTransparency = 1
                SliderInput.Position = UDim2.new(1, -155, 0.5, 0)
                SliderInput.Size = UDim2.new(0, 28, 0, 20)
                SliderInput.Name = "SliderInput"
                SliderInput.Parent = Slider
                
                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 2)
                InputCorner.Parent = SliderInput
                
                local TextBox = Instance.new("TextBox")
                TextBox.Font = Enum.Font.GothamBold
                TextBox.Text = tostring(SliderConfig.Default)
                TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextBox.TextSize = 13
                TextBox.TextWrapped = true
                TextBox.BackgroundTransparency = 1
                TextBox.Position = UDim2.new(0, -1, 0, 0)
                TextBox.Size = UDim2.new(1, 0, 1, 0)
                TextBox.ClearTextOnFocus = false
                TextBox.Parent = SliderInput
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
                SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderFrame.BackgroundTransparency = 0.8
                SliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
                SliderFrame.Size = UDim2.new(0, 100, 0, 3)
                SliderFrame.Name = "SliderFrame"
                SliderFrame.Parent = Slider
                
                local FrameCorner = Instance.new("UICorner")
                FrameCorner.Parent = SliderFrame
                
                local SliderDraggable = Instance.new("Frame")
                SliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
                SliderDraggable.BackgroundColor3 = GuiConfig.Color
                SliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
                SliderDraggable.Size = UDim2.new(0.9, 0, 0, 1)
                SliderDraggable.Name = "SliderDraggable"
                SliderDraggable.Parent = SliderFrame
                
                local DragCorner = Instance.new("UICorner")
                DragCorner.Parent = SliderDraggable
                
                local SliderCircle = Instance.new("Frame")
                SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
                SliderCircle.BackgroundColor3 = GuiConfig.Color
                SliderCircle.Position = UDim2.new(1, 4, 0.5, 0)
                SliderCircle.Size = UDim2.new(0, 8, 0, 8)
                SliderCircle.Name = "SliderCircle"
                SliderCircle.Parent = SliderDraggable
                
                local CircleCorner = Instance.new("UICorner")
                CircleCorner.Parent = SliderCircle
                
                local CircleStroke = Instance.new("UIStroke")
                CircleStroke.Color = GuiConfig.Color
                CircleStroke.Parent = SliderCircle
                
                local Dragging = false
                
                local function Round(Number, Factor)
                    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
                    if Result < 0 then Result = Result + Factor end
                    return Result
                end
                
                function SliderFunc:Set(Value, silent)
                    Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
                    SliderFunc.Value = Value
                    TextBox.Text = tostring(Value)
                    
                    TweenService:Create(SliderDraggable, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { Size = UDim2.fromScale((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1) }):Play()
                    
                    ConfigData[configKey] = Value
                    SaveConfig()
                    
                    if not silent and typeof(SliderConfig.Callback) == "function" then
                        task.spawn(function()
                            local success, err = pcall(SliderConfig.Callback, Value)
                            if not success then
                                warn("Slider Callback error:", err)
                            end
                        end)
                    end
                end
                
                SliderFrame.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        TweenService:Create(SliderCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            { Size = UDim2.new(0, 14, 0, 14) }):Play()
                        local SizeScale = math.clamp((Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
                        SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
                    end
                end)
                
                SliderFrame.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                        TweenService:Create(SliderCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            { Size = UDim2.new(0, 8, 0, 8) }):Play()
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        local SizeScale = math.clamp((Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
                        SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
                    end
                end)
                
                TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local Valid = TextBox.Text:gsub("[^%d.-]", "")
                    if Valid ~= "" then
                        local ValidNumber = tonumber(Valid)
                        if ValidNumber then
                            ValidNumber = math.clamp(ValidNumber, SliderConfig.Min, SliderConfig.Max)
                            SliderFunc:Set(ValidNumber)
                        end
                    else
                        SliderFunc:Set(SliderConfig.Min)
                    end
                end)
                
                SliderFunc:Set(SliderConfig.Default, true)
                CountItem = CountItem + 1
                Elements[configKey] = SliderFunc
                return SliderFunc
            end
            
            -- ==================== ADD INPUT ====================
            function Items:AddInput(InputConfig)
                InputConfig = InputConfig or {}
                InputConfig.Title = InputConfig.Title or "Title"
                InputConfig.Content = InputConfig.Content or ""
                InputConfig.Placeholder = InputConfig.Placeholder or "Input Here"
                InputConfig.Callback = InputConfig.Callback or function() end
                InputConfig.Default = InputConfig.Default or ""
                
                local configKey = "Input_" .. InputConfig.Title
                if ConfigData[configKey] ~= nil then
                    InputConfig.Default = ConfigData[configKey]
                end
                
                local InputFunc = { Value = InputConfig.Default }
                
                local Input = Instance.new("Frame")
                Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Input.BackgroundTransparency = 0.935
                Input.LayoutOrder = CountItem
                Input.Size = UDim2.new(1, 0, 0, 46)
                Input.Name = "Input"
                Input.Parent = SectionAdd
                
                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 4)
                InputCorner.Parent = Input
                
                local InputTitle = Instance.new("TextLabel")
                InputTitle.Font = Enum.Font.GothamBold
                InputTitle.Text = InputConfig.Title
                InputTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
                InputTitle.TextSize = 13
                InputTitle.TextXAlignment = Enum.TextXAlignment.Left
                InputTitle.TextYAlignment = Enum.TextYAlignment.Top
                InputTitle.BackgroundTransparency = 1
                InputTitle.Position = UDim2.new(0, 10, 0, 10)
                InputTitle.Size = UDim2.new(1, -180, 0, 13)
                InputTitle.Name = "InputTitle"
                InputTitle.Parent = Input
                
                local InputContent = Instance.new("TextLabel")
                InputContent.Font = Enum.Font.GothamBold
                InputContent.Text = InputConfig.Content
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
                
                InputContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (InputContent.TextBounds.X // math.max(InputContent.AbsoluteSize.X, 1))))
                Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)
                
                InputContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    InputContent.TextWrapped = false
                    InputContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (InputContent.TextBounds.X // math.max(InputContent.AbsoluteSize.X, 1))))
                    Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)
                    InputContent.TextWrapped = true
                    UpdateSizeSection()
                end)
                
                local InputFrame = Instance.new("Frame")
                InputFrame.AnchorPoint = Vector2.new(1, 0.5)
                InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                InputFrame.BackgroundTransparency = 0.95
                InputFrame.ClipsDescendants = true
                InputFrame.Position = UDim2.new(1, -7, 0.5, 0)
                InputFrame.Size = UDim2.new(0, 148, 0, 30)
                InputFrame.Name = "InputFrame"
                InputFrame.Parent = Input
                
                local FrameCorner = Instance.new("UICorner")
                FrameCorner.CornerRadius = UDim.new(0, 4)
                FrameCorner.Parent = InputFrame
                
                local InputTextBox = Instance.new("TextBox")
                InputTextBox.CursorPosition = -1
                InputTextBox.Font = Enum.Font.GothamBold
                InputTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                InputTextBox.PlaceholderText = InputConfig.Placeholder
                InputTextBox.Text = InputConfig.Default
                InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                InputTextBox.TextSize = 12
                InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
                InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
                InputTextBox.BackgroundTransparency = 1
                InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
                InputTextBox.Size = UDim2.new(1, -10, 1, -8)
                InputTextBox.ClearTextOnFocus = false
                InputTextBox.Name = "InputTextBox"
                InputTextBox.Parent = InputFrame
                
                function InputFunc:Set(Value, silent)
                    InputTextBox.Text = tostring(Value)
                    InputFunc.Value = Value
                    ConfigData[configKey] = Value
                    SaveConfig()
                    
                    if not silent and typeof(InputConfig.Callback) == "function" then
                        task.spawn(function()
                            local success, err = pcall(InputConfig.Callback, Value)
                            if not success then
                                warn("Input Callback error:", err)
                            end
                        end)
                    end
                end
                
                InputFunc:Set(InputFunc.Value, true)
                
                InputTextBox.FocusLost:Connect(function()
                    InputFunc:Set(InputTextBox.Text)
                end)
                
                CountItem = CountItem + 1
                Elements[configKey] = InputFunc
                return InputFunc
            end
            
            -- ==================== ADD DROPDOWN ====================
            function Items:AddDropdown(DropdownConfig)
                DropdownConfig = DropdownConfig or {}
                DropdownConfig.Title = DropdownConfig.Title or "Title"
                DropdownConfig.Content = DropdownConfig.Content or ""
                DropdownConfig.Multi = DropdownConfig.Multi or false
                DropdownConfig.Options = DropdownConfig.Options or {}
                DropdownConfig.Default = DropdownConfig.Default or (DropdownConfig.Multi and {} or nil)
                DropdownConfig.Callback = DropdownConfig.Callback or function() end
                
                local configKey = "Dropdown_" .. DropdownConfig.Title
                if ConfigData[configKey] ~= nil then
                    DropdownConfig.Default = ConfigData[configKey]
                end
                
                local DropdownFunc = { Value = DropdownConfig.Default, Options = DropdownConfig.Options }
                
                local Dropdown = Instance.new("Frame")
                Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Dropdown.BackgroundTransparency = 0.935
                Dropdown.LayoutOrder = CountItem
                Dropdown.Size = UDim2.new(1, 0, 0, 46)
                Dropdown.Name = "Dropdown"
                Dropdown.Parent = SectionAdd
                
                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 4)
                DropCorner.Parent = Dropdown
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Text = ""
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Size = UDim2.new(1, 0, 1, 0)
                DropdownButton.Name = "DropdownButton"
                DropdownButton.Parent = Dropdown
                
                local DropdownTitle = Instance.new("TextLabel")
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
                
                local DropdownContent = Instance.new("TextLabel")
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
                
                local SelectOptionsFrame = Instance.new("Frame")
                SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
                SelectOptionsFrame.BackgroundTransparency = 0.95
                SelectOptionsFrame.Position = UDim2.new(1, -7, 0.5, 0)
                SelectOptionsFrame.Size = UDim2.new(0, 148, 0, 30)
                SelectOptionsFrame.LayoutOrder = CountDropdown
                SelectOptionsFrame.Name = "SelectOptionsFrame"
                SelectOptionsFrame.Parent = Dropdown
                
                local SelectCorner = Instance.new("UICorner")
                SelectCorner.CornerRadius = UDim.new(0, 4)
                SelectCorner.Parent = SelectOptionsFrame
                
                DropdownButton.Activated:Connect(function()
                    if not MoreBlur.Visible then
                        MoreBlur.Visible = true
                        DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)
                        TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 0.3 }):Play()
                        TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, -11, 0.5, 0) }):Play()
                    end
                end)
                
                local OptionSelecting = Instance.new("TextLabel")
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
                
                local OptionImg = Instance.new("ImageLabel")
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
                
                local SearchCorner = Instance.new("UICorner")
                SearchCorner.CornerRadius = UDim.new(0, 3)
                SearchCorner.Parent = SearchBox
                
                local ScrollSelect = Instance.new("ScrollingFrame")
                ScrollSelect.Size = UDim2.new(1, 0, 1, -30)
                ScrollSelect.Position = UDim2.new(0, 0, 0, 30)
                ScrollSelect.ScrollBarImageTransparency = 1
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
                    ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
                end)
                
                function DropdownFunc:Clear()
                    for _, DropFrame in pairs(ScrollSelect:GetChildren()) do
                        if DropFrame.Name == "Option" then
                            DropFrame:Destroy()
                        end
                    end
                    DropdownFunc.Value = DropdownConfig.Multi and {} or nil
                    DropdownFunc.Options = {}
                    OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
                end
                
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
                    Option.BackgroundTransparency = 1
                    Option.Size = UDim2.new(1, 0, 0, 30)
                    Option.Name = "Option"
                    Option.Parent = ScrollSelect
                    
                    local OptionCorner = Instance.new("UICorner")
                    OptionCorner.CornerRadius = UDim.new(0, 3)
                    OptionCorner.Parent = Option
                    
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
                    
                    local ChooseCorner = Instance.new("UICorner")
                    ChooseCorner.Parent = ChooseFrame
                    
                    local ChooseStroke = Instance.new("UIStroke")
                    ChooseStroke.Color = GuiConfig.Color
                    ChooseStroke.Thickness = 1.6
                    ChooseStroke.Transparency = 0.999
                    ChooseStroke.Parent = ChooseFrame
                    
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
                
                function DropdownFunc:Set(Value, silent)
                    if DropdownConfig.Multi then
                        DropdownFunc.Value = type(Value) == "table" and Value or {}
                    else
                        DropdownFunc.Value = (type(Value) == "table" and Value[1]) or Value
                    end
                    
                    ConfigData[configKey] = DropdownFunc.Value
                    SaveConfig()
                    
                    local texts = {}
                    for _, Drop in pairs(ScrollSelect:GetChildren()) do
                        if Drop.Name == "Option" and Drop:FindFirstChild("OptionText") then
                            local v = Drop:GetAttribute("RealValue")
                            local selected = DropdownConfig.Multi and table.find(DropdownFunc.Value, v) or DropdownFunc.Value == v
                            
                            if selected then
                                TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, 1, 0, 12) }):Play()
                                TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.2), { Transparency = 0 }):Play()
                                TweenService:Create(Drop, TweenInfo.new(0.2), { BackgroundTransparency = 0.935 }):Play()
                                table.insert(texts, Drop.OptionText.Text)
                            else
                                TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.1), { Size = UDim2.new(0, 0, 0, 0) }):Play()
                                TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.1), { Transparency = 0.999 }):Play()
                                TweenService:Create(Drop, TweenInfo.new(0.1), { BackgroundTransparency = 0.999 }):Play()
                            end
                        end
                    end
                    
                    OptionSelecting.Text = (#texts == 0) and (DropdownConfig.Multi and "Select Options" or "Select Option") or table.concat(texts, ", ")
                    
                    if not silent and typeof(DropdownConfig.Callback) == "function" then
                        task.spawn(function()
                            local success, err
                            if DropdownConfig.Multi then
                                success, err = pcall(DropdownConfig.Callback, DropdownFunc.Value)
                            else
                                local str = (DropdownFunc.Value ~= nil) and tostring(DropdownFunc.Value) or ""
                                success, err = pcall(DropdownConfig.Callback, str)
                            end
                            if not success then
                                warn("Dropdown Callback error:", err)
                            end
                        end)
                    end
                end
                
                function DropdownFunc:SetValue(val)
                    self:Set(val)
                end
                
                function DropdownFunc:GetValue()
                    return self.Value
                end
                
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
                
                DropdownFunc:SetValues(DropdownFunc.Options, DropdownFunc.Value)
                
                CountItem = CountItem + 1
                CountDropdown = CountDropdown + 1
                Elements[configKey] = DropdownFunc
                return DropdownFunc
            end
            
            -- ==================== ADD DIVIDER ====================
            function Items:AddDivider()
                local Divider = Instance.new("Frame")
                Divider.Name = "Divider"
                Divider.AnchorPoint = Vector2.new(0.5, 0)
                Divider.Position = UDim2.new(0.5, 0, 0, 0)
                Divider.Size = UDim2.new(1, 0, 0, 2)
                Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Divider.BackgroundTransparency = 0
                Divider.BorderSizePixel = 0
                Divider.LayoutOrder = CountItem
                Divider.Parent = SectionAdd
                
                local UIGradient = Instance.new("UIGradient")
                UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
                    ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
                })
                UIGradient.Parent = Divider
                
                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 2)
                UICorner.Parent = Divider
                
                CountItem = CountItem + 1
                return Divider
            end
            
            -- ==================== ADD SUBSECTION ====================
            function Items:AddSubSection(title)
                title = title or "Sub Section"
                
                local SubSection = Instance.new("Frame")
                SubSection.Name = "SubSection"
                SubSection.BackgroundTransparency = 1
                SubSection.Size = UDim2.new(1, 0, 0, 22)
                SubSection.LayoutOrder = CountItem
                SubSection.Parent = SectionAdd
                
                local Background = Instance.new("Frame")
                Background.Size = UDim2.new(1, 0, 1, 0)
                Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Background.BackgroundTransparency = 0.935
                Background.BorderSizePixel = 0
                Background.Parent = SubSection
                
                local BgCorner = Instance.new("UICorner")
                BgCorner.CornerRadius = UDim.new(0, 6)
                BgCorner.Parent = Background
                
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
                
                CountItem = CountItem + 1
                return SubSection
            end
            
            CountSection = CountSection + 1
            return Items
        end
        
        CountTab = CountTab + 1
        local safeName = TabConfig.Name:gsub("%s+", "_")
        _G[safeName] = Sections
        return Sections
    end
    
    -- Load saved config after all elements are created
    task.spawn(function()
        task.wait(0.5)
        LoadConfigElements()
    end)
    
    return Tabs
end

-- ==================== GLOBAL HELPER FUNCTIONS ====================
_G.Nt = Nt
_G.SaveConfig = SaveConfig
_G.LoadConfigFromFile = LoadConfigFromFile
_G.LoadConfigElements = LoadConfigElements

return Chloex
