local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")

-- Import modules
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Utils.lua"))()
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Config.lua"))()

-- Import elements
local ButtonElement = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Elements/Button.lua"))()
local ToggleElement = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Elements/Toggle.lua"))()
local SliderElement = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Elements/Slider.lua"))()
local InputElement = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Elements/Input.lua"))()
local DropdownElement = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Elements/Dropdown.lua"))()
local PanelElement = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Elements/Panel.lua"))()
local ParagraphElement = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Elements/Paragraph.lua"))()

local Icons = {
    alert     = "rbxassetid://73186275216515",
    bag       = "rbxassetid://8601111810",
    boss      = "rbxassetid://13132186360",
    cart      = "rbxassetid://128874923961846",
    compas    = "rbxassetid://125300760963399",
    crosshair = "rbxassetid://12614416478",
    dcs       = "rbxassetid://15310731934",
    discord   = "rbxassetid://94434236999817",
    eyes      = "rbxassetid://14321059114",
    fish      = "rbxassetid://97167558235554",
    folder    = "rbxassetid://111411260968321",
    gamepad   = "rbxassetid://84173963561612",
    gps       = "rbxassetid://17824309485",
    home      = "rbxassetid://70416927963252",
    idea      = "rbxassetid://16833255748",
    lexshub   = "rbxassetid://71947103252559",
    loop      = "rbxassetid://122032243989747",
    menu      = "rbxassetid://6340513838",
    next      = "rbxassetid://12662718374",
    Nt        = "rbxassetid://70884221600423",
    payment   = "rbxassetid://18747025078",
    player    = "rbxassetid://12120698352",
    plug      = "rbxassetid://137601480983962",
    question  = "rbxassetid://17510196486",
    rod       = "rbxassetid://103247953194129",
    scan      = "rbxassetid://109869955247116",
    scroll    = "rbxassetid://114127804740858",
    settings  = "rbxassetid://70386228443175",
    shop      = "rbxassetid://4985385964",
    skeleton  = "rbxassetid://17313330026",
    star      = "rbxassetid://107005941750079",
    start     = "rbxassetid://108886429866687",
    stat      = "rbxassetid://12094445329",
    strom     = "rbxassetid://13321880293",
    sword     = "rbxassetid://82472368671405",
    user      = "rbxassetid://108483430622128",
    water     = "rbxassetid://100076212630732",
    web       = "rbxassetid://137601480983962",
}

local Chloex = {}

-- Notify function
function Chloex:MakeNotify(NotifyConfig)
    return Utils.MakeNotify(NotifyConfig)
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

-- Window function
function Chloex:Window(GuiConfig)
    GuiConfig = GuiConfig or {}
    GuiConfig.Title = GuiConfig.Title or "Chloe X"
    GuiConfig.Footer = GuiConfig.Footer or "Chloee :3"
    GuiConfig.Color = GuiConfig.Color or Color3.fromRGB(255, 0, 255)
    GuiConfig["Tab Width"] = GuiConfig["Tab Width"] or 120
    GuiConfig.Version = GuiConfig.Version or 1

    CURRENT_VERSION = GuiConfig.Version
    Config.LoadConfigFromFile()

    local GuiFunc = {}
    local gui = Utils.CreateMainWindow(GuiConfig, Icons)
    
    function GuiFunc:DestroyGui()
        if CoreGui:FindFirstChild("Chloeex") then
            CoreGui.Chloeex:Destroy()
        end
    end

    function GuiFunc:ToggleUI()
        Utils.CreateToggleUI(GuiConfig)
    end

    local Tabs = {}
    local CountTab = 0
    
    function Tabs:AddTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""
        
        local tabFrame = Utils.CreateTabFrame(gui, TabConfig, CountTab, GuiConfig)
        
        CountTab = CountTab + 1
        
        local Sections = {}
        local CountSection = 0
        
        function Sections:AddSection(Title, AlwaysOpen)
            Title = Title or "Title"
            AlwaysOpen = AlwaysOpen or false
            
            local sectionData = Utils.CreateSection(gui.LayersFolder, Title, AlwaysOpen, GuiConfig)
            local Items = {}
            local CountItem = 0
            
            -- Add Button element
            function Items:AddButton(ButtonConfig)
                local button = ButtonElement:Create(ButtonConfig, GuiConfig)
                button.Parent = sectionData.SectionAdd
                button.LayoutOrder = CountItem
                CountItem = CountItem + 1
                return button
            end
            
            -- Add Toggle element
            function Items:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                local configKey = "Toggle_" .. (ToggleConfig.Title or "Toggle")
                
                local toggle = ToggleElement:Create(ToggleConfig, GuiConfig, configKey)
                toggle.Parent = sectionData.SectionAdd
                toggle.LayoutOrder = CountItem
                CountItem = CountItem + 1
                return toggle
            end
            
            -- Add Slider element
            function Items:AddSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                local configKey = "Slider_" .. (SliderConfig.Title or "Slider")
                
                local slider = SliderElement:Create(SliderConfig, GuiConfig, configKey)
                slider.Parent = sectionData.SectionAdd
                slider.LayoutOrder = CountItem
                CountItem = CountItem + 1
                return slider
            end
            
            -- Add Input element
            function Items:AddInput(InputConfig)
                InputConfig = InputConfig or {}
                local configKey = "Input_" .. (InputConfig.Title or "Input")
                
                local input = InputElement:Create(InputConfig, GuiConfig, configKey)
                input.Parent = sectionData.SectionAdd
                input.LayoutOrder = CountItem
                CountItem = CountItem + 1
                return input
            end
            
            -- Add Dropdown element
            function Items:AddDropdown(DropdownConfig)
                DropdownConfig = DropdownConfig or {}
                local configKey = "Dropdown_" .. (DropdownConfig.Title or "Dropdown")
                
                local dropdown = DropdownElement:Create(DropdownConfig, GuiConfig, configKey)
                dropdown.Parent = sectionData.SectionAdd
                dropdown.LayoutOrder = CountItem
                CountItem = CountItem + 1
                return dropdown
            end
            
            -- Add Panel element
            function Items:AddPanel(PanelConfig)
                PanelConfig = PanelConfig or {}
                local configKey = "Panel_" .. (PanelConfig.Title or "Panel")
                
                local panel = PanelElement:Create(PanelConfig, GuiConfig, configKey)
                panel.Parent = sectionData.SectionAdd
                panel.LayoutOrder = CountItem
                CountItem = CountItem + 1
                return panel
            end
            
            -- Add Paragraph element
            function Items:AddParagraph(ParagraphConfig)
                ParagraphConfig = ParagraphConfig or {}
                
                local paragraph = ParagraphElement:Create(ParagraphConfig, GuiConfig)
                paragraph.Parent = sectionData.SectionAdd
                paragraph.LayoutOrder = CountItem
                CountItem = CountItem + 1
                return paragraph
            end
            
            CountSection = CountSection + 1
            return Items
        end
        
        return Sections
    end
    
    GuiFunc:ToggleUI()
    return Tabs, GuiFunc
end

-- Load configurations after UI is built
spawn(function()
    Config.LoadConfigElements()
end)

return Chloex
