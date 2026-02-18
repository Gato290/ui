local HttpService = game:GetService("HttpService") -- V0.0.6
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load Color Module
local ColorModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/refs/heads/main/Elements/color.lua"))()

-- Load Elements Module
local ElementsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/refs/heads/main/Elements/Elements.lua"))()

-- Load Icon Libraries
local defaultIcons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/refs/heads/main/Icon/defaulticons.lua"))()
local lucideIcons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/refs/heads/main/Icon/lucideIcons.lua"))()
local solarIcons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/refs/heads/main/Icon/solarIcons.lua"))()

-- Merge all icons
local Icons = {}
for name, id in pairs(defaultIcons) do Icons[name] = id end
for name, id in pairs(lucideIcons) do Icons["lucide:" .. name] = id end
for name, id in pairs(solarIcons) do Icons["solar:" .. name] = id end

local function getIconId(iconName)
    if not iconName or iconName == "" then return "" end
    if iconName:match("^%d+$") then return "rbxassetid://" .. iconName end
    if Icons[iconName] then return Icons[iconName] end
    if iconName:match("^https?://") then return iconName end
    return ""
end

local function getColor(colorInput)
    if typeof(colorInput) == "Color3" then return colorInput end
    if type(colorInput) == "string" then
        if ColorModule[colorInput] then return ColorModule[colorInput] end
        warn("Color '" .. colorInput .. "' not found, using Default")
        return ColorModule["Default"] or Color3.fromRGB(0, 208, 255)
    end
    return ColorModule["Default"] or Color3.fromRGB(0, 208, 255)
end

local ConfigFolder = "Velaris UI"
local ConfigFile = ""

-- FIX: ConfigData dibuat sebagai shared reference table agar update dari
--      Elements.lua (yang menerima referensi ini) langsung reflect di sini.
local ConfigData = {}

-- FIX: Elements table juga shared reference ke ElementsModule agar
--      LoadConfigElements bisa memanggil :Set() pada semua elemen yang terdaftar.
local Elements = {}

local CURRENT_VERSION = nil
local AUTO_SAVE = false
local AUTO_LOAD = false

function SaveConfig()
    if writefile and ConfigFile ~= "" then
        ConfigData._version = CURRENT_VERSION
        writefile(ConfigFile, HttpService:JSONEncode(ConfigData))
    end
end

function LoadConfigFromFile()
    if not CURRENT_VERSION or ConfigFile == "" then return end
    if isfile and isfile(ConfigFile) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and type(result) == "table" then
            if result._version == CURRENT_VERSION then
                -- FIX: copy isi result ke ConfigData (jaga referensi table yang sama)
                for k, v in pairs(result) do
                    ConfigData[k] = v
                end
            else
                -- version mismatch: reset tapi jaga referensi
                for k in pairs(ConfigData) do ConfigData[k] = nil end
                ConfigData._version = CURRENT_VERSION
            end
        else
            for k in pairs(ConfigData) do ConfigData[k] = nil end
            ConfigData._version = CURRENT_VERSION
        end
    else
        ConfigData._version = CURRENT_VERSION
    end
end

-- FIX: LoadConfigElements sekarang dipanggil SETELAH semua elemen dibuat
--      (bukan saat init). Fungsi ini iterate Elements table dan restore value.
function LoadConfigElements()
    for key, element in pairs(Elements) do
        if ConfigData[key] ~= nil and element.Set then
            pcall(function()
                element:Set(ConfigData[key])
            end)
        end
    end
end

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")
local viewport = workspace.CurrentCamera.ViewportSize

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
    local function CustomPos(topbarobject, object)
        local Dragging, DragInput, DragStart, StartPosition

        local function UpdatePos(input)
            local Delta = input.Position - DragStart
            local pos = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
            TweenService:Create(object, TweenInfo.new(0.2), { Position = pos }):Play()
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
            if input == DragInput and Dragging then UpdatePos(input) end
        end)
    end

    local function CustomSize(object)
        local Dragging, DragInput, DragStart, StartSize
        local minSizeX, minSizeY = 100, 100
        local defSizeX, defSizeY

        if isMobile then
            defSizeX, defSizeY = 470, 270
        else
            defSizeX, defSizeY = 640, 400
        end

        object.Size = UDim2.new(0, defSizeX, 0, defSizeY)

        local changesizeobject = Instance.new("Frame")
        changesizeobject.AnchorPoint = Vector2.new(1, 1)
        changesizeobject.BackgroundTransparency = 1
        changesizeobject.Size = UDim2.new(0, 40, 0, 40)
        changesizeobject.Position = UDim2.new(1, 20, 1, 20)
        changesizeobject.Name = "changesizeobject"
        changesizeobject.Parent = object

        local function UpdateSize(input)
            local Delta = input.Position - DragStart
            local newWidth  = math.max(StartSize.X.Offset + Delta.X, minSizeX)
            local newHeight = math.max(StartSize.Y.Offset + Delta.Y, minSizeY)
            TweenService:Create(object, TweenInfo.new(0.2), { Size = UDim2.new(0, newWidth, 0, newHeight) }):Play()
        end

        changesizeobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartSize = object.Size
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then Dragging = false end
                end)
            end
        end)

        changesizeobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then UpdateSize(input) end
        end)
    end

    CustomSize(object)
    CustomPos(topbarobject, object)
end

function CircleClick(Button, X, Y)
    spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.9
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
            wait(Time / 10)
        end
        Circle:Destroy()
    end)
end

local Chloex = {}

function Chloex:MakeNotify(NotifyConfig)
    NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title       = NotifyConfig.Title       or "Chloe X"
    NotifyConfig.Description = NotifyConfig.Description or "Notification"
    NotifyConfig.Content     = NotifyConfig.Content     or "Content"
    NotifyConfig.Color       = getColor(NotifyConfig.Color or "Default")
    NotifyConfig.Time        = NotifyConfig.Time        or 0.5
    NotifyConfig.Delay       = NotifyConfig.Delay       or 5

    local NotifyFunction = {}
    spawn(function()
        if not CoreGui:FindFirstChild("NotifyGui") then
            local NotifyGui = Instance.new("ScreenGui")
            NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            NotifyGui.Name = "NotifyGui"
            NotifyGui.Parent = CoreGui
        end

        if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
            local NotifyLayout = Instance.new("Frame")
            NotifyLayout.AnchorPoint = Vector2.new(1, 1)
            NotifyLayout.BackgroundTransparency = 0.999
            NotifyLayout.BorderSizePixel = 0
            NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
            NotifyLayout.Size = UDim2.new(0, 320, 1, 0)
            NotifyLayout.Name = "NotifyLayout"
            NotifyLayout.Parent = CoreGui.NotifyGui

            local Count = 0
            CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for _, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                    TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                        Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count))
                    }):Play()
                    Count = Count + 1
                end
            end)
        end

        local NotifyPosHeigh = 0
        for _, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
            NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
        end

        local NotifyFrame     = Instance.new("Frame")
        local NotifyFrameReal = Instance.new("Frame")
        local UICorner        = Instance.new("UICorner")
        local Top             = Instance.new("Frame")
        local TextLabel       = Instance.new("TextLabel")
        local UICorner1       = Instance.new("UICorner")
        local TextLabel1      = Instance.new("TextLabel")
        local Close           = Instance.new("TextButton")
        local ImageLabel      = Instance.new("ImageLabel")
        local TextLabel2      = Instance.new("TextLabel")

        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.BorderSizePixel = 0
        NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
        NotifyFrame.Name = "NotifyFrame"
        NotifyFrame.AnchorPoint = Vector2.new(0, 1)
        NotifyFrame.Position = UDim2.new(0, 0, 1, -NotifyPosHeigh)
        NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout

        NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrameReal.BorderSizePixel = 0
        NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
        NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
        NotifyFrameReal.Name = "NotifyFrameReal"
        NotifyFrameReal.Parent = NotifyFrame

        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = NotifyFrameReal

        Top.BackgroundTransparency = 0.999
        Top.BorderSizePixel = 0
        Top.Size = UDim2.new(1, 0, 0, 36)
        Top.Name = "Top"
        Top.Parent = NotifyFrameReal

        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.Text = NotifyConfig.Title
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextSize = 14
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.Position = UDim2.new(0, 10, 0, 0)
        TextLabel.Parent = Top

        UICorner1.CornerRadius = UDim.new(0, 5)
        UICorner1.Parent = Top

        TextLabel1.Font = Enum.Font.GothamBold
        TextLabel1.Text = NotifyConfig.Description
        TextLabel1.TextColor3 = NotifyConfig.Color
        TextLabel1.TextSize = 14
        TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel1.BackgroundTransparency = 1
        TextLabel1.BorderSizePixel = 0
        TextLabel1.Size = UDim2.new(1, 0, 1, 0)
        TextLabel1.Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0, 0)
        TextLabel1.Parent = Top

        Close.Font = Enum.Font.SourceSans
        Close.Text = ""
        Close.AnchorPoint = Vector2.new(1, 0.5)
        Close.BackgroundTransparency = 0.999
        Close.BorderSizePixel = 0
        Close.Position = UDim2.new(1, -5, 0.5, 0)
        Close.Size = UDim2.new(0, 25, 0, 25)
        Close.Name = "Close"
        Close.Parent = Top

        ImageLabel.Image = "rbxassetid://9886659671"
        ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        ImageLabel.BackgroundTransparency = 1
        ImageLabel.BorderSizePixel = 0
        ImageLabel.Position = UDim2.new(0.49, 0, 0.5, 0)
        ImageLabel.Size = UDim2.new(1, -8, 1, -8)
        ImageLabel.Parent = Close

        TextLabel2.Font = Enum.Font.GothamBold
        TextLabel2.Text = NotifyConfig.Content
        TextLabel2.TextColor3 = Color3.fromRGB(150, 150, 150)
        TextLabel2.TextSize = 13
        TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
        TextLabel2.BackgroundTransparency = 1
        TextLabel2.BorderSizePixel = 0
        TextLabel2.Position = UDim2.new(0, 10, 0, 27)
        TextLabel2.Size = UDim2.new(1, -20, 0, 13)
        TextLabel2.TextWrapped = true
        TextLabel2.Parent = NotifyFrameReal

        TextLabel2.Size = UDim2.new(1, -20, 0, 13 + (13 * (TextLabel2.TextBounds.X // math.max(1, TextLabel2.AbsoluteSize.X))))

        if TextLabel2.AbsoluteSize.Y < 27 then
            NotifyFrame.Size = UDim2.new(1, 0, 0, 65)
        else
            NotifyFrame.Size = UDim2.new(1, 0, 0, TextLabel2.AbsoluteSize.Y + 40)
        end

        local waitbruh = false
        function NotifyFunction:Close()
            if waitbruh then return false end
            waitbruh = true
            TweenService:Create(NotifyFrameReal,
                TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                { Position = UDim2.new(0, 400, 0, 0) }
            ):Play()
            task.wait(tonumber(NotifyConfig.Time) / 1.2)
            NotifyFrame:Destroy()
        end

        Close.Activated:Connect(function() NotifyFunction:Close() end)

        TweenService:Create(NotifyFrameReal,
            TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
            { Position = UDim2.new(0, 0, 0, 0) }
        ):Play()

        task.wait(tonumber(NotifyConfig.Delay))
        NotifyFunction:Close()
    end)
    return NotifyFunction
end

function Nt(msg, delay, color, title, desc)
    return Chloex:MakeNotify({
        Title       = title or "Velaris UI",
        Description = desc  or "Notification",
        Content     = msg   or "Content",
        Color       = getColor(color or "Default"),
        Delay       = delay or 4,
    })
end

local ActiveDialog = nil

function Chloex:Dialog(DialogConfig)
    DialogConfig         = DialogConfig or {}
    DialogConfig.Title   = DialogConfig.Title   or "Dialog"
    DialogConfig.Content = DialogConfig.Content or ""
    DialogConfig.Buttons = DialogConfig.Buttons or {}

    if ActiveDialog and ActiveDialog.Parent then
        pcall(function() ActiveDialog:Destroy() end)
    end

    local DialogGui = Instance.new("ScreenGui")
    DialogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    DialogGui.Name = "DialogGui"
    DialogGui.Parent = CoreGui

    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.ZIndex = 50
    Overlay.Parent = DialogGui

    local Dialog = Instance.new("ImageLabel")
    Dialog.Size = UDim2.new(0, 300, 0, 150)
    Dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
    Dialog.Image = "rbxassetid://9542022979"
    Dialog.BorderSizePixel = 0
    Dialog.ZIndex = 51
    Dialog.Parent = Overlay
    Instance.new("UICorner", Dialog).CornerRadius = UDim.new(0, 8)

    local DialogGlow = Instance.new("Frame")
    DialogGlow.Size = UDim2.new(0, 310, 0, 160)
    DialogGlow.Position = UDim2.new(0.5, -155, 0.5, -80)
    DialogGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DialogGlow.BackgroundTransparency = 0.75
    DialogGlow.BorderSizePixel = 0
    DialogGlow.ZIndex = 50
    DialogGlow.Parent = Overlay
    Instance.new("UICorner", DialogGlow).CornerRadius = UDim.new(0, 10)

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 191, 255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 140, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 191, 255)),
    })
    Gradient.Rotation = 90
    Gradient.Parent = DialogGlow

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 4)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = DialogConfig.Title
    Title.TextSize = 22
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.ZIndex = 52
    Title.Parent = Dialog

    local Message = Instance.new("TextLabel")
    Message.Size = UDim2.new(1, -20, 0, 60)
    Message.Position = UDim2.new(0, 10, 0, 30)
    Message.BackgroundTransparency = 1
    Message.Font = Enum.Font.Gotham
    Message.Text = DialogConfig.Content
    Message.TextSize = 14
    Message.TextColor3 = Color3.fromRGB(200, 200, 200)
    Message.TextWrapped = true
    Message.ZIndex = 52
    Message.Parent = Dialog

    for i, buttonConfig in ipairs(DialogConfig.Buttons) do
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0.45, -10, 0, 35)
        Button.Position = (i == 1)
            and UDim2.new(0.05, 0, 1, -55)
            or  UDim2.new(0.50, 10, 1, -55)
        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundTransparency = 0.935
        Button.Text = buttonConfig.Name or "Button"
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 15
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextTransparency = 0.3
        Button.ZIndex = 52
        Button.Name = "DialogButton_" .. i
        Button.Parent = Dialog
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

        Button.MouseButton1Click:Connect(function()
            pcall(function() CircleClick(Button, Mouse.X, Mouse.Y) end)
            if type(buttonConfig.Callback) == "function" then
                pcall(buttonConfig.Callback)
            end
            pcall(function()
                DialogGui:Destroy()
                if ActiveDialog == DialogGui then ActiveDialog = nil end
            end)
        end)
    end

    ActiveDialog = DialogGui

    Dialog.Size = UDim2.new(0, 0, 0, 0)
    Dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    DialogGlow.Size = UDim2.new(0, 0, 0, 0)
    DialogGlow.Position = UDim2.new(0.5, 0, 0.5, 0)

    TweenService:Create(Dialog, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 300, 0, 150),
        Position = UDim2.new(0.5, -150, 0.5, -75),
    }):Play()
    TweenService:Create(DialogGlow, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 310, 0, 160),
        Position = UDim2.new(0.5, -155, 0.5, -80),
    }):Play()

    return DialogGui
end

function Chloex:Window(GuiConfig)
    GuiConfig                = GuiConfig or {}
    GuiConfig.Title          = GuiConfig.Title          or "Chloe X"
    GuiConfig.Footer         = GuiConfig.Footer         or "Chloee :3"
    GuiConfig.Content        = GuiConfig.Content        or ""
    GuiConfig.ShowUser       = GuiConfig.ShowUser       or false
    GuiConfig.Color          = getColor(GuiConfig.Color or "Default")
    GuiConfig["Tab Width"]   = GuiConfig["Tab Width"]   or 120
    GuiConfig.Version        = GuiConfig.Version        or 1
    GuiConfig.Uitransparent  = GuiConfig.Uitransparent  or 0
    GuiConfig.Image          = GuiConfig.Image          or "70884221600423"
    GuiConfig.Configname     = GuiConfig.Configname     or "Velaris UI"
    GuiConfig.Config         = GuiConfig.Config         or {}
    GuiConfig.Config.AutoSave = GuiConfig.Config.AutoSave ~= nil and GuiConfig.Config.AutoSave or true
    GuiConfig.Config.AutoLoad = GuiConfig.Config.AutoLoad ~= nil and GuiConfig.Config.AutoLoad or true

    CURRENT_VERSION = GuiConfig.Version
    AUTO_SAVE       = GuiConfig.Config.AutoSave
    AUTO_LOAD       = GuiConfig.Config.AutoLoad
    ConfigFolder    = GuiConfig.Configname

    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    if not isfolder(ConfigFolder .. "/Config") then makefolder(ConfigFolder .. "/Config") end

    local gameName = tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
    gameName = gameName:gsub("[^%w_ ]", ""):gsub("%s+", "_")
    ConfigFile = ConfigFolder .. "/Config/CHX_" .. gameName .. ".json"

    if AUTO_LOAD then LoadConfigFromFile() end

    -- FIX: Pass ConfigData dan Elements sebagai referensi yang sama.
    --      Elements.lua akan mengisi table Elements dengan key configKey → func.
    ElementsModule:Initialize(GuiConfig, SaveConfig, ConfigData, Icons)

    local GuiFunc = {}

    -- GUI building (tidak ada perubahan struktur, hanya cleanup kecil)
    local Chloeex = Instance.new("ScreenGui")
    Chloeex.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Chloeex.Name = "Chloeex"
    Chloeex.ResetOnSpawn = false
    Chloeex.Parent = CoreGui

    local DropShadowHolder = Instance.new("Frame")
    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadowHolder.Size = isMobile and safeSize(470, 270) or safeSize(640, 400)
    DropShadowHolder.ZIndex = 0
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = Chloeex

    DropShadowHolder.Position = UDim2.new(0,
        Chloeex.AbsoluteSize.X // 2 - DropShadowHolder.Size.X.Offset // 2,
        0,
        Chloeex.AbsoluteSize.Y // 2 - DropShadowHolder.Size.Y.Offset // 2
    )

    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
    DropShadow.ImageTransparency = 1
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.BorderSizePixel = 0
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
        Main.ImageTransparency = GuiConfig.ThemeTransparency or GuiConfig.Uitransparent or 0.15
    else
        Main = Instance.new("Frame")
        Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Main.BackgroundTransparency = GuiConfig.Uitransparent or 0
    end
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -47, 1, -47)
    Main.Name = "Main"
    Main.Parent = DropShadow
    Instance.new("UICorner", Main)

    local Top = Instance.new("Frame")
    Top.BackgroundTransparency = 0.999
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 38)
    Top.Name = "Top"
    Top.Parent = Main

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = GuiConfig.Title
    TextLabel.TextColor3 = GuiConfig.Color
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundTransparency = 1
    TextLabel.BorderSizePixel = 0
    TextLabel.Size = UDim2.new(1, -100, 1, 0)
    TextLabel.Position = UDim2.new(0, 10, 0, 0)
    TextLabel.Parent = Top
    Instance.new("UICorner", Top)

    local TextLabel1 = Instance.new("TextLabel")
    TextLabel1.Font = Enum.Font.GothamBold
    TextLabel1.Text = GuiConfig.Footer
    TextLabel1.TextColor3 = GuiConfig.Color
    TextLabel1.TextSize = 14
    TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel1.BackgroundTransparency = 1
    TextLabel1.BorderSizePixel = 0
    TextLabel1.Size = UDim2.new(1, -(TextLabel.TextBounds.X + 104), 1, 0)
    TextLabel1.Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0, 0)
    TextLabel1.Parent = Top

    local Close = Instance.new("TextButton")
    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundTransparency = 0.999
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(1, -8, 0.5, 0)
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.Name = "Close"
    Close.Parent = Top

    local ImageLabel1 = Instance.new("ImageLabel")
    ImageLabel1.Image = "rbxassetid://9886659671"
    ImageLabel1.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel1.BackgroundTransparency = 1
    ImageLabel1.BorderSizePixel = 0
    ImageLabel1.Position = UDim2.new(0.49, 0, 0.5, 0)
    ImageLabel1.Size = UDim2.new(1, -8, 1, -8)
    ImageLabel1.Parent = Close

    local Min = Instance.new("TextButton")
    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.BackgroundTransparency = 0.999
    Min.BorderSizePixel = 0
    Min.Position = UDim2.new(1, -38, 0.5, 0)
    Min.Size = UDim2.new(0, 25, 0, 25)
    Min.Name = "Min"
    Min.Parent = Top

    local ImageLabel2 = Instance.new("ImageLabel")
    ImageLabel2.Image = "rbxassetid://9886659276"
    ImageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel2.BackgroundTransparency = 1
    ImageLabel2.ImageTransparency = 0.2
    ImageLabel2.BorderSizePixel = 0
    ImageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel2.Size = UDim2.new(1, -9, 1, -9)
    ImageLabel2.Parent = Min

    -- Content bar di bawah title
    if GuiConfig.Content and GuiConfig.Content ~= "" then
        local ContentFrame = Instance.new("Frame")
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.BorderSizePixel = 0
        ContentFrame.Size = UDim2.new(1, 0, 0, 35)
        ContentFrame.Position = UDim2.new(0, 0, 0, 38)
        ContentFrame.Name = "ContentFrame"
        ContentFrame.Parent = Main

        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Font = Enum.Font.GothamBold
        ContentLabel.Text = GuiConfig.Content
        ContentLabel.TextColor3 = GuiConfig.Color
        ContentLabel.TextSize = 14
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Center
        ContentLabel.TextYAlignment = Enum.TextYAlignment.Center
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.Size = UDim2.new(1, -20, 1, 0)
        ContentLabel.Position = UDim2.new(0, 10, 0, 0)
        ContentLabel.Parent = ContentFrame

        local Divider = Instance.new("Frame")
        Divider.BackgroundColor3 = GuiConfig.Color
        Divider.BackgroundTransparency = 0.8
        Divider.BorderSizePixel = 0
        Divider.Size = UDim2.new(1, -20, 0, 1)
        Divider.Position = UDim2.new(0, 10, 1, -1)
        Divider.Parent = ContentFrame
    end

    local topOffset = (GuiConfig.Content and GuiConfig.Content ~= "") and (38 + 35 + 10) or 50

    local LayersTab = Instance.new("Frame")
    LayersTab.BackgroundTransparency = 0.999
    LayersTab.BorderSizePixel = 0
    LayersTab.Position = UDim2.new(0, 9, 0, topOffset)
    LayersTab.Size = UDim2.new(0, GuiConfig["Tab Width"], 1, -(topOffset + 9))
    LayersTab.Name = "LayersTab"
    LayersTab.Parent = Main
    Instance.new("UICorner", LayersTab).CornerRadius = UDim.new(0, 2)

    local ScrollTab = Instance.new("ScrollingFrame")
    ScrollTab.CanvasSize = UDim2.new(0, 0, 1.1, 0)
    ScrollTab.ScrollBarThickness = 0
    ScrollTab.Active = true
    ScrollTab.BackgroundTransparency = 0.999
    ScrollTab.BorderSizePixel = 0
    ScrollTab.Position = UDim2.new(0, 0, 0, 0)
    ScrollTab.Size = GuiConfig.ShowUser and UDim2.new(1, 0, 1, -40) or UDim2.new(1, 0, 1, 0)
    ScrollTab.Name = "ScrollTab"
    ScrollTab.Parent = LayersTab

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 3)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollTab

    local function UpdateSize1()
        local OffsetY = 0
        for _, child in ScrollTab:GetChildren() do
            if child.Name ~= "UIListLayout" then
                OffsetY = OffsetY + 3 + child.Size.Y.Offset
            end
        end
        ScrollTab.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
    end
    ScrollTab.ChildAdded:Connect(UpdateSize1)
    ScrollTab.ChildRemoved:Connect(UpdateSize1)

    if GuiConfig.ShowUser then
        local UserInfoFrame = Instance.new("Frame")
        UserInfoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        UserInfoFrame.BackgroundTransparency = 0.3
        UserInfoFrame.BorderSizePixel = 0
        UserInfoFrame.Position = UDim2.new(0, 5, 1, -45)
        UserInfoFrame.Size = UDim2.new(1, -10, 0, 40)
        UserInfoFrame.Name = "UserInfoFrame"
        UserInfoFrame.Parent = LayersTab
        Instance.new("UICorner", UserInfoFrame).CornerRadius = UDim.new(0, 6)

        local Avatar = Instance.new("ImageLabel")
        Avatar.BackgroundTransparency = 0.5
        Avatar.BorderSizePixel = 0
        Avatar.Position = UDim2.new(0, 5, 0.5, -15)
        Avatar.Size = UDim2.new(0, 30, 0, 30)
        Avatar.Parent = UserInfoFrame
        Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

        local success, content = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        Avatar.Image = success and content or "rbxasset://textures/ui/GuiImagePlaceholder.png"

        local DisplayName = Instance.new("TextLabel")
        DisplayName.Font = Enum.Font.GothamBold
        DisplayName.Text = LocalPlayer.DisplayName
        DisplayName.TextColor3 = Color3.fromRGB(255, 255, 255)
        DisplayName.TextSize = 13
        DisplayName.TextXAlignment = Enum.TextXAlignment.Left
        DisplayName.BackgroundTransparency = 1
        DisplayName.Position = UDim2.new(0, 40, 0, 6)
        DisplayName.Size = UDim2.new(1, -45, 0, 16)
        DisplayName.Parent = UserInfoFrame

        local Username = Instance.new("TextLabel")
        Username.Font = Enum.Font.Gotham
        Username.Text = "@" .. LocalPlayer.Name
        Username.TextColor3 = Color3.fromRGB(150, 150, 150)
        Username.TextSize = 11
        Username.TextXAlignment = Enum.TextXAlignment.Left
        Username.BackgroundTransparency = 1
        Username.Position = UDim2.new(0, 40, 0, 22)
        Username.Size = UDim2.new(1, -45, 0, 14)
        Username.Parent = UserInfoFrame
    end

    _G.ScrollTab = ScrollTab

    local DecideFrame = Instance.new("Frame")
    DecideFrame.AnchorPoint = Vector2.new(0.5, 0)
    DecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DecideFrame.BackgroundTransparency = 0.85
    DecideFrame.BorderSizePixel = 0
    DecideFrame.Position = UDim2.new(0.5, 0, 0, 38)
    DecideFrame.Size = UDim2.new(1, 0, 0, 1)
    DecideFrame.Name = "DecideFrame"
    DecideFrame.Parent = Main

    local Layers = Instance.new("Frame")
    Layers.BackgroundTransparency = 0.999
    Layers.BorderSizePixel = 0
    Layers.Position = UDim2.new(0, GuiConfig["Tab Width"] + 18, 0, topOffset)
    Layers.Size = UDim2.new(1, -(GuiConfig["Tab Width"] + 9 + 18), 1, -(topOffset + 9))
    Layers.Name = "Layers"
    Layers.Parent = Main
    Instance.new("UICorner", Layers).CornerRadius = UDim.new(0, 2)

    local NameTab = Instance.new("TextLabel")
    NameTab.Font = Enum.Font.GothamBold
    NameTab.Text = ""
    NameTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameTab.TextSize = 24
    NameTab.TextWrapped = true
    NameTab.TextXAlignment = Enum.TextXAlignment.Left
    NameTab.BackgroundTransparency = 0.999
    NameTab.BorderSizePixel = 0
    NameTab.Size = UDim2.new(1, 0, 0, 30)
    NameTab.Name = "NameTab"
    NameTab.Parent = Layers

    local LayersReal = Instance.new("Frame")
    LayersReal.AnchorPoint = Vector2.new(0, 1)
    LayersReal.BackgroundTransparency = 0.999
    LayersReal.BorderSizePixel = 0
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

    function GuiFunc:DestroyGui()
        if CoreGui:FindFirstChild("Chloeex") then Chloeex:Destroy() end
    end

    Min.Activated:Connect(function()
        CircleClick(Min, Mouse.X, Mouse.Y)
        DropShadowHolder.Visible = false
    end)

    Close.Activated:Connect(function()
        CircleClick(Close, Mouse.X, Mouse.Y)
        Chloex:Dialog({
            Title = GuiConfig.Configname .. " Window",
            Content = "Do you want to close this window?\nYou will not be able to open it again",
            Buttons = {
                {
                    Name = "Yes",
                    Callback = function()
                        if Chloeex then Chloeex:Destroy() end
                        if CoreGui:FindFirstChild("ToggleUIButton") then
                            CoreGui.ToggleUIButton:Destroy()
                        end
                    end,
                },
                { Name = "Cancel", Callback = function() end },
            },
        })
    end)

    function GuiFunc:ToggleUI()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = CoreGui
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Name = "ToggleUIButton"

        local MainButton = Instance.new("ImageLabel")
        MainButton.Parent = ScreenGui
        MainButton.Size = UDim2.new(0, 40, 0, 40)
        MainButton.Position = UDim2.new(0, 20, 0, 100)
        MainButton.BackgroundTransparency = 1
        MainButton.Image = "rbxassetid://" .. GuiConfig.Image
        MainButton.ScaleType = Enum.ScaleType.Fit
        Instance.new("UICorner", MainButton).CornerRadius = UDim.new(0, 6)

        local Button = Instance.new("TextButton")
        Button.Parent = MainButton
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = ""

        Button.MouseButton1Click:Connect(function()
            if DropShadowHolder then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
            end
        end)

        local dragging, dragStart, startPos = false, nil, nil
        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainButton.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    GuiFunc:ToggleUI()
    DropShadowHolder.Size = UDim2.new(0, 115 + TextLabel.TextBounds.X + 1 + TextLabel1.TextBounds.X, 0, 350)
    MakeDraggable(Top, DropShadowHolder)

    -- Dropdown overlay
    local MoreBlur = Instance.new("Frame")
    MoreBlur.AnchorPoint = Vector2.new(1, 1)
    MoreBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BackgroundTransparency = 0.999
    MoreBlur.BorderSizePixel = 0
    MoreBlur.ClipsDescendants = true
    MoreBlur.Position = UDim2.new(1, 8, 1, 8)
    MoreBlur.Size = UDim2.new(1, 154, 1, 54)
    MoreBlur.Visible = false
    MoreBlur.Name = "MoreBlur"
    MoreBlur.Parent = Layers
    Instance.new("UICorner", MoreBlur)

    local DropShadowHolder1 = Instance.new("Frame")
    DropShadowHolder1.BackgroundTransparency = 1
    DropShadowHolder1.BorderSizePixel = 0
    DropShadowHolder1.Size = UDim2.new(1, 0, 1, 0)
    DropShadowHolder1.ZIndex = 0
    DropShadowHolder1.Parent = MoreBlur

    local DropShadow1 = Instance.new("ImageLabel")
    DropShadow1.Image = "rbxassetid://6015897843"
    DropShadow1.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow1.ImageTransparency = 1
    DropShadow1.ScaleType = Enum.ScaleType.Slice
    DropShadow1.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow1.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow1.BackgroundTransparency = 1
    DropShadow1.BorderSizePixel = 0
    DropShadow1.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow1.Size = UDim2.new(1, 35, 1, 35)
    DropShadow1.ZIndex = 0
    DropShadow1.Parent = DropShadowHolder1

    local ConnectButton = Instance.new("TextButton")
    ConnectButton.Font = Enum.Font.SourceSans
    ConnectButton.Text = ""
    ConnectButton.BackgroundTransparency = 0.999
    ConnectButton.BorderSizePixel = 0
    ConnectButton.Size = UDim2.new(1, 0, 1, 0)
    ConnectButton.Name = "ConnectButton"
    ConnectButton.Parent = MoreBlur

    local DropdownSelect = Instance.new("Frame")
    DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
    DropdownSelect.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropdownSelect.BorderSizePixel = 0
    DropdownSelect.LayoutOrder = 1
    DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
    DropdownSelect.Size = UDim2.new(0, 160, 1, -16)
    DropdownSelect.Name = "DropdownSelect"
    DropdownSelect.ClipsDescendants = true
    DropdownSelect.Parent = MoreBlur
    Instance.new("UICorner", DropdownSelect).CornerRadius = UDim.new(0, 3)

    local UIStroke14 = Instance.new("UIStroke")
    UIStroke14.Color = Color3.fromRGB(12, 159, 255)
    UIStroke14.Thickness = 2.5
    UIStroke14.Transparency = 0.8
    UIStroke14.Parent = DropdownSelect

    local DropdownSelectReal = Instance.new("Frame")
    DropdownSelectReal.AnchorPoint = Vector2.new(0.5, 0.5)
    DropdownSelectReal.BackgroundColor3 = Color3.fromRGB(0, 27, 98)
    DropdownSelectReal.BackgroundTransparency = 0.7
    DropdownSelectReal.BorderSizePixel = 0
    DropdownSelectReal.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropdownSelectReal.Size = UDim2.new(1, 1, 1, 1)
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
    DropPageLayout.Archivable = false
    DropPageLayout.Name = "DropPageLayout"
    DropPageLayout.Parent = DropdownFolder

    ConnectButton.Activated:Connect(function()
        if MoreBlur.Visible then
            TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 0.999 }):Play()
            TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
            task.wait(0.3)
            MoreBlur.Visible = false
        end
    end)

    -- FIX: CountDropdown sekarang ada di level Window agar tidak collision
    --      antar section yang berbeda dalam window yang sama.
    local CountDropdown = 0

    local Tabs = {}
    local CountTab = 0

    function Tabs:AddTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""

        local ScrolLayers = Instance.new("ScrollingFrame")
        ScrolLayers.ScrollBarThickness = 0
        ScrolLayers.Active = true
        ScrolLayers.LayoutOrder = CountTab
        ScrolLayers.BackgroundTransparency = 0.999
        ScrolLayers.BorderSizePixel = 0
        ScrolLayers.Size = UDim2.new(1, 0, 1, 0)
        ScrolLayers.Name = "ScrolLayers"
        ScrolLayers.Parent = LayersFolder

        local UIListLayout1 = Instance.new("UIListLayout")
        UIListLayout1.Padding = UDim.new(0, 3)
        UIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout1.Parent = ScrolLayers

        local Tab = Instance.new("Frame")
        Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Tab.BackgroundTransparency = CountTab == 0 and 0.92 or 0.999
        Tab.BorderSizePixel = 0
        Tab.LayoutOrder = CountTab
        Tab.Size = UDim2.new(1, 0, 0, 30)
        Tab.Name = "Tab"
        Tab.Parent = _G.ScrollTab
        Instance.new("UICorner", Tab).CornerRadius = UDim.new(0, 4)

        local TabButton = Instance.new("TextButton")
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = ""
        TabButton.BackgroundTransparency = 0.999
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Name = "TabButton"
        TabButton.Parent = Tab

        local TabName = Instance.new("TextLabel")
        TabName.Font = Enum.Font.GothamBold
        TabName.Text = "| " .. tostring(TabConfig.Name)
        TabName.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabName.TextSize = 13
        TabName.TextXAlignment = Enum.TextXAlignment.Left
        TabName.BackgroundTransparency = 0.999
        TabName.BorderSizePixel = 0
        TabName.Size = UDim2.new(1, 0, 1, 0)
        TabName.Position = UDim2.new(0, 30, 0, 0)
        TabName.Parent = Tab

        local FeatureImg = Instance.new("ImageLabel")
        FeatureImg.BackgroundTransparency = 0.999
        FeatureImg.BorderSizePixel = 0
        FeatureImg.Position = UDim2.new(0, 9, 0, 7)
        FeatureImg.Size = UDim2.new(0, 16, 0, 16)
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = Tab

        if TabConfig.Icon and TabConfig.Icon ~= "" then
            local iconId = getIconId(TabConfig.Icon)
            if iconId and iconId ~= "" then FeatureImg.Image = iconId end
        end

        if CountTab == 0 then
            LayersPageLayout:JumpToIndex(0)
            NameTab.Text = TabConfig.Name
            local ChooseFrame = Instance.new("Frame")
            ChooseFrame.BackgroundColor3 = GuiConfig.Color
            ChooseFrame.BorderSizePixel = 0
            ChooseFrame.Position = UDim2.new(0, 2, 0, 9)
            ChooseFrame.Size = UDim2.new(0, 1, 0, 12)
            ChooseFrame.Name = "ChooseFrame"
            ChooseFrame.Parent = Tab
            Instance.new("UICorner", ChooseFrame)
            local UIStroke2 = Instance.new("UIStroke")
            UIStroke2.Color = GuiConfig.Color
            UIStroke2.Thickness = 1.6
            UIStroke2.Parent = ChooseFrame
        end

        TabButton.Activated:Connect(function()
            CircleClick(TabButton, Mouse.X, Mouse.Y)
            local FrameChoose
            for _, s in _G.ScrollTab:GetChildren() do
                for _, v in s:GetChildren() do
                    if v.Name == "ChooseFrame" then FrameChoose = v break end
                end
                if FrameChoose then break end
            end

            if FrameChoose and Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
                for _, TabFrame in _G.ScrollTab:GetChildren() do
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

        function Sections:AddSection(SectionConfig)
            local Title, Icon, Open = "Section", "", false
            if type(SectionConfig) == "string" then
                Title = SectionConfig
            elseif type(SectionConfig) == "table" then
                Title = SectionConfig.Title or "Section"
                Icon  = SectionConfig.Icon  or ""
                Open  = SectionConfig.Open  or false
            end

            local Section = Instance.new("Frame")
            Section.BackgroundTransparency = 0.999
            Section.BorderSizePixel = 0
            Section.LayoutOrder = CountSection
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(1, 0, 0, 30)
            Section.Name = "Section"
            Section.Parent = ScrolLayers

            local SectionReal = Instance.new("Frame")
            SectionReal.AnchorPoint = Vector2.new(0.5, 0)
            SectionReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionReal.BackgroundTransparency = 0.935
            SectionReal.BorderSizePixel = 0
            SectionReal.Position = UDim2.new(0.5, 0, 0, 0)
            SectionReal.Size = UDim2.new(1, 1, 0, 30)
            SectionReal.Name = "SectionReal"
            SectionReal.Parent = Section
            Instance.new("UICorner", SectionReal).CornerRadius = UDim.new(0, 4)

            if Icon and Icon ~= "" then
                local SectionIcon = Instance.new("ImageLabel")
                SectionIcon.BackgroundTransparency = 0.999
                SectionIcon.BorderSizePixel = 0
                SectionIcon.Position = UDim2.new(0, 10, 0.5, -8)
                SectionIcon.Size = UDim2.new(0, 16, 0, 16)
                SectionIcon.Name = "SectionIcon"
                SectionIcon.Parent = SectionReal
                local iconId = getIconId(Icon)
                if iconId and iconId ~= "" then SectionIcon.Image = iconId end
            end

            local SectionButton = Instance.new("TextButton")
            SectionButton.Font = Enum.Font.SourceSans
            SectionButton.Text = ""
            SectionButton.BackgroundTransparency = 0.999
            SectionButton.BorderSizePixel = 0
            SectionButton.Size = UDim2.new(1, 0, 1, 0)
            SectionButton.Name = "SectionButton"
            SectionButton.Parent = SectionReal

            local FeatureFrame = Instance.new("Frame")
            FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
            FeatureFrame.BackgroundTransparency = 0.999
            FeatureFrame.BorderSizePixel = 0
            FeatureFrame.Position = UDim2.new(1, -5, 0.5, 0)
            FeatureFrame.Size = UDim2.new(0, 20, 0, 20)
            FeatureFrame.Name = "FeatureFrame"
            FeatureFrame.Parent = SectionReal

            local FeatureImg = Instance.new("ImageLabel")
            FeatureImg.Image = "rbxassetid://16851841101"
            FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
            FeatureImg.BackgroundTransparency = 0.999
            FeatureImg.BorderSizePixel = 0
            FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
            FeatureImg.Rotation = -90
            FeatureImg.Size = UDim2.new(1, 6, 1, 6)
            FeatureImg.Name = "FeatureImg"
            FeatureImg.Parent = FeatureFrame

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = Title
            SectionTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
            SectionTitle.TextSize = 13
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.AnchorPoint = Vector2.new(0, 0.5)
            SectionTitle.BackgroundTransparency = 0.999
            SectionTitle.BorderSizePixel = 0
            SectionTitle.Position = (Icon and Icon ~= "") and UDim2.new(0, 32, 0.5, 0) or UDim2.new(0, 10, 0.5, 0)
            SectionTitle.Size = UDim2.new(1, -50, 0, 13)
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionReal

            local SectionDecideFrame = Instance.new("Frame")
            SectionDecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionDecideFrame.AnchorPoint = Vector2.new(0.5, 0)
            SectionDecideFrame.BorderSizePixel = 0
            SectionDecideFrame.Position = UDim2.new(0.5, 0, 0, 33)
            SectionDecideFrame.Size = UDim2.new(0, 0, 0, 2)
            SectionDecideFrame.Name = "SectionDecideFrame"
            SectionDecideFrame.Parent = Section
            Instance.new("UICorner", SectionDecideFrame)

            local UIGradient = Instance.new("UIGradient")
            UIGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0,   Color3.fromRGB(20, 20, 20)),
                ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
                ColorSequenceKeypoint.new(1,   Color3.fromRGB(20, 20, 20)),
            }
            UIGradient.Parent = SectionDecideFrame

            local SectionAdd = Instance.new("Frame")
            SectionAdd.AnchorPoint = Vector2.new(0.5, 0)
            SectionAdd.BackgroundTransparency = 0.999
            SectionAdd.BorderSizePixel = 0
            SectionAdd.ClipsDescendants = true
            SectionAdd.Position = UDim2.new(0.5, 0, 0, 38)
            SectionAdd.Size = UDim2.new(1, 0, 0, 100)
            SectionAdd.Name = "SectionAdd"
            SectionAdd.Parent = Section
            Instance.new("UICorner", SectionAdd).CornerRadius = UDim.new(0, 2)

            local UIListLayout2 = Instance.new("UIListLayout")
            UIListLayout2.Padding = UDim.new(0, 3)
            UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout2.Parent = SectionAdd

            local OpenSection = Open

            local function UpdateSizeScroll()
                local OffsetY = 0
                for _, child in ScrolLayers:GetChildren() do
                    if child.Name ~= "UIListLayout" then
                        OffsetY = OffsetY + 3 + child.Size.Y.Offset
                    end
                end
                ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
            end

            local function UpdateSizeSection()
                if OpenSection then
                    local h = 38
                    for _, v in SectionAdd:GetChildren() do
                        if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
                            h = h + v.Size.Y.Offset + 3
                        end
                    end
                    TweenService:Create(FeatureFrame, TweenInfo.new(0.5), { Rotation = 90 }):Play()
                    TweenService:Create(Section,     TweenInfo.new(0.5), { Size = UDim2.new(1, 1, 0, h) }):Play()
                    TweenService:Create(SectionAdd,  TweenInfo.new(0.5), { Size = UDim2.new(1, 0, 0, h - 38) }):Play()
                    TweenService:Create(SectionDecideFrame, TweenInfo.new(0.5), { Size = UDim2.new(1, 0, 0, 2) }):Play()
                    task.wait(0.5)
                    UpdateSizeScroll()
                end
            end

            if OpenSection then UpdateSizeSection() end

            SectionButton.Activated:Connect(function()
                CircleClick(SectionButton, Mouse.X, Mouse.Y)
                if OpenSection then
                    TweenService:Create(FeatureFrame,       TweenInfo.new(0.5), { Rotation = 0 }):Play()
                    TweenService:Create(Section,            TweenInfo.new(0.5), { Size = UDim2.new(1, 1, 0, 30) }):Play()
                    TweenService:Create(SectionDecideFrame, TweenInfo.new(0.5), { Size = UDim2.new(0, 0, 0, 2) }):Play()
                    OpenSection = false
                    task.wait(0.5)
                    UpdateSizeScroll()
                else
                    OpenSection = true
                    UpdateSizeSection()
                end
            end)

            SectionAdd.ChildAdded:Connect(UpdateSizeSection)
            SectionAdd.ChildRemoved:Connect(UpdateSizeSection)

            local layout = ScrolLayers:FindFirstChildOfClass("UIListLayout")
            if layout then
                layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
                end)
            end

            local Items = {}
            local CountItem = 0

            function Items:AddParagraph(ParagraphConfig)
                local func = ElementsModule:CreateParagraph(SectionAdd, ParagraphConfig, CountItem)
                CountItem = CountItem + 1
                return func
            end

            -- FIX: AddEditableParagraph sekarang tersedia (sebelumnya tidak di-expose)
            function Items:AddEditableParagraph(ParagraphConfig)
                local func = ElementsModule:CreateEditableParagraph(SectionAdd, ParagraphConfig, CountItem)
                CountItem = CountItem + 1
                return func
            end

            function Items:AddPanel(PanelConfig)
                local func = ElementsModule:CreatePanel(SectionAdd, PanelConfig, CountItem)
                CountItem = CountItem + 1
                return func
            end

            -- FIX: AddButton sekarang return ButtonFunc agar caller bisa pakai Fire(), SetTitle(), dll.
            function Items:AddButton(ButtonConfig)
                local func = ElementsModule:CreateButton(SectionAdd, ButtonConfig, CountItem)
                CountItem = CountItem + 1
                return func  -- sebelumnya tidak return apapun
            end

            function Items:AddToggle(ToggleConfig)
                local func = ElementsModule:CreateToggle(SectionAdd, ToggleConfig, CountItem, UpdateSizeSection, Elements)
                CountItem = CountItem + 1
                return func
            end

            function Items:AddSlider(SliderConfig)
                local func = ElementsModule:CreateSlider(SectionAdd, SliderConfig, CountItem, UpdateSizeSection, Elements)
                CountItem = CountItem + 1
                return func
            end

            function Items:AddInput(InputConfig)
                local func = ElementsModule:CreateInput(SectionAdd, InputConfig, CountItem, UpdateSizeSection, Elements)
                CountItem = CountItem + 1
                return func
            end

            -- FIX: CountDropdown di-share dari level Window, bukan lokal per section
            function Items:AddDropdown(DropdownConfig)
                local func = ElementsModule:CreateDropdown(
                    SectionAdd, DropdownConfig, CountItem,
                    CountDropdown, DropdownFolder, MoreBlur,
                    DropdownSelect, DropPageLayout, Elements
                )
                CountItem = CountItem + 1
                CountDropdown = CountDropdown + 1
                return func
            end

            function Items:AddDivider()
                local divider = ElementsModule:CreateDivider(SectionAdd, CountItem)
                CountItem = CountItem + 1
                return divider
            end

            function Items:AddSubSection(title)
                local subsection = ElementsModule:CreateSubSection(SectionAdd, title, CountItem)
                CountItem = CountItem + 1
                return subsection
            end

            CountSection = CountSection + 1
            return Items
        end

        CountTab = CountTab + 1
        local safeName = TabConfig.Name:gsub("%s+", "_")
        _G[safeName] = Sections
        return Sections
    end

    -- FIX: LoadConfigElements dipanggil setelah Tabs siap dibuat,
    --      tapi sebelum return — sehingga semua elemen yang dibuat user
    --      lewat AddToggle/AddSlider/dll bisa di-restore.
    --      Namun karena elemen dibuat SETELAH Window return,
    --      kita expose fungsi ini agar dipanggil manual oleh user
    --      setelah semua elemen selesai dibuat.
    function GuiFunc:LoadConfig()
        LoadConfigElements()
    end

    return Tabs, GuiFunc
end

return Chloex
