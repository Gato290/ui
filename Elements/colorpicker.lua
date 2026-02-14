local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local cloneref = (cloneref or clonereference or function(instance) return instance end)

local UserInputService = cloneref(game:GetService("UserInputService"))
local TouchInputService = cloneref(game:GetService("TouchInputService"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local TweenService = game:GetService("TweenService")

local RenderStepped = RunService.RenderStepped
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local CreateButton = require("../components/ui/Button").New
local CreateInput = require("../components/ui/Input").New

local Element = {
    UICorner = 9,
}

-- Internal helper functions for HSV/RGB conversion
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

local function toRGB(color)
    return {
        R = math.floor(color.R * 255),
        G = math.floor(color.G * 255),
        B = math.floor(color.B * 255)
    }
end

local function clamp(val, min, max)
    return math.clamp(tonumber(val) or 0, min, max)
end

-- Advanced colorpicker dialog
function Element:ColorpickerDialog(Config, OnApply)
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
    
    local ColorpickerModule = require("../components/window/Dialog").Init(Config.Window)
    local ColorpickerFrame = ColorpickerModule.Create()
    
    Colorpicker.ColorpickerFrame = ColorpickerFrame
    
    ColorpickerFrame.UIElements.Main.Size = UDim2.new(1,0,0,0)
    
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
    
    local RedInput = CreateNewInput("Red", toRGB(Colorpicker.Default)["R"])
    local GreenInput = CreateNewInput("Green", toRGB(Colorpicker.Default)["G"])
    local BlueInput = CreateNewInput("Blue", toRGB(Colorpicker.Default)["B"])
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
        RedInput.Frame.Frame.TextBox.Text = toRGB(Color3.fromHSV(Hue, Sat, Vib))["R"]
        GreenInput.Frame.Frame.TextBox.Text = toRGB(Color3.fromHSV(Hue, Sat, Vib))["G"]
        BlueInput.Frame.Frame.TextBox.Text = toRGB(Color3.fromHSV(Hue, Sat, Vib))["B"]
        
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
    
    -- Input handlers
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

    -- Drag handlers
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

-- Main Colorpicker class that will be returned by Tab:AddColorpicker
local ColorpickerClass = {}
ColorpickerClass.__index = ColorpickerClass

function ColorpickerClass.new(Config)
    local self = setmetatable({}, ColorpickerClass)
    
    self.Title = Config.Title or "Colorpicker"
    self.Desc = Config.Desc
    self.Default = Config.Default or Color3.new(1,1,1)
    self.Transparency = Config.Transparency or 0
    self.Locked = Config.Locked or false
    self.LockedTitle = Config.LockedTitle
    self.Callback = Config.Callback or function() end
    self.Parent = Config.Parent
    self.Tab = Config.Tab
    self.Index = Config.Index
    self.Window = Config.Window
    
    self.CanCallback = true
    self.UIElements = {}
    
    -- Create the element frame
    self.ColorpickerFrame = require("../components/window/Element")({
        Title = self.Title,
        Desc = self.Desc,
        Parent = self.Parent,
        TextOffset = 40,
        Hover = false,
        Tab = self.Tab,
        Index = self.Index,
        Window = self.Window,
        ElementTable = self,
        ParentConfig = Config,
    })
    
    -- Create the color preview button
    self.UIElements.Colorpicker = Creator.NewRoundFrame(Element.UICorner, "Squircle", {
        ImageTransparency = self.Transparency,
        Active = true,
        ImageColor3 = self.Default,
        Parent = self.ColorpickerFrame.UIElements.Main,
        Size = UDim2.new(0,26,0,26),
        AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1,0,0,0),
        ZIndex = 2
    }, nil, true)
    
    -- Lock functionality
    function self:Lock()
        self.Locked = true
        self.CanCallback = false
        return self.ColorpickerFrame:Lock(self.LockedTitle)
    end
    
    function self:Unlock()
        self.Locked = false
        self.CanCallback = true
        return self.ColorpickerFrame:Unlock()
    end
    
    if self.Locked then
        self:Lock()
    end
    
    -- Update the color preview
    function self:Update(color, transparency)
        self.UIElements.Colorpicker.ImageColor3 = color
        if transparency ~= nil then
            self.UIElements.Colorpicker.ImageTransparency = transparency
            self.Transparency = transparency
        end
        self.Default = color
    end
    
    -- Set color (alias for Update)
    function self:Set(color, transparency)
        return self:Update(color, transparency)
    end
    
    -- Get current color
    function self:Get()
        return self.UIElements.Colorpicker.ImageColor3
    end
    
    -- Get current transparency
    function self:GetTransparency()
        return self.UIElements.Colorpicker.ImageTransparency
    end
    
    -- Open colorpicker dialog
    function self:Open()
        if self.CanCallback then
            Element:ColorpickerDialog({
                Title = self.Title,
                Desc = self.Desc,
                Default = self.Default,
                Transparency = self.Transparency,
                Window = self.Window
            }, function(color, transparency)
                self:Update(color, transparency)
                Creator.SafeCallback(self.Callback, color, transparency)
            end).ColorpickerFrame:Open()
        end
    end
    
    -- Click handler to open dialog
    Creator.AddSignal(self.UIElements.Colorpicker.MouseButton1Click, function()
        self:Open()
    end)
    
    return self
end

-- Simple Colorpicker class (alternative style)
local SimpleColorpickerClass = {}
SimpleColorpickerClass.__index = SimpleColorpickerClass

function SimpleColorpickerClass.new(Config)
    local self = setmetatable({}, SimpleColorpickerClass)
    
    self.Title = Config.Title or "Colorpicker"
    self.Desc = Config.Desc
    self.Default = Config.Default or Color3.fromRGB(255, 255, 255)
    self.Callback = Config.Callback or function() end
    self.WindowColor = Config.WindowColor or Color3.fromRGB(0, 140, 255)
    self.ElementKey = Config.ElementKey or ("Colorpicker_" .. tostring(Config.Index or 0))
    self.SaveColor = Config.SaveColor or false
    self.ConfigData = Config.ConfigData or {}
    self.SaveFunction = Config.SaveFunction or function() end
    self.Parent = Config.Parent
    
    -- Load saved color if exists
    local currentColor = self.Default
    if self.SaveColor and self.ConfigData and self.ConfigData[self.ElementKey] then
        local saved = self.ConfigData[self.ElementKey]
        if type(saved) == "table" and saved.R and saved.G and saved.B then
            currentColor = Color3.new(saved.R, saved.G, saved.B)
        end
    end
    
    -- Main container
    self.Container = Instance.new("Frame")
    self.Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Container.BackgroundTransparency = 0.95
    self.Container.BorderSizePixel = 0
    self.Container.LayoutOrder = Config.Index or 0
    self.Container.Size = UDim2.new(1, 0, 0, 30)
    self.Container.Parent = self.Parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = self.Container
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = self.Title
    titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0.5, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Parent = self.Container
    
    -- Description if exists
    if self.Desc and self.Desc ~= "" then
        local descLabel = Instance.new("TextLabel")
        descLabel.BackgroundTransparency = 1
        descLabel.Font = Enum.Font.Gotham
        descLabel.Text = self.Desc
        descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        descLabel.TextSize = 11
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Size = UDim2.new(0.5, -10, 1, 0)
        descLabel.Position = UDim2.new(0.5, 0, 0, 0)
        descLabel.Parent = self.Container
    end
    
    -- Color preview button
    self.PreviewBtn = Instance.new("TextButton")
    self.PreviewBtn.BackgroundColor3 = currentColor
    self.PreviewBtn.BorderSizePixel = 0
    self.PreviewBtn.Size = UDim2.new(0, 30, 0, 20)
    self.PreviewBtn.Position = UDim2.new(1, -40, 0.5, -10)
    self.PreviewBtn.Parent = self.Container
    self.PreviewBtn.ZIndex = 5
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = self.PreviewBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.7
    btnStroke.Parent = self.PreviewBtn
    
    -- Create simple color picker window
    self.PickerWindow = self:CreatePickerWindow(currentColor)
    
    -- Click handler
    self.PreviewBtn.MouseButton1Click:Connect(function()
        self:Open()
    end)
    
    return self
end

function SimpleColorpickerClass:CreatePickerWindow(initialColor)
    local mainFrame = Instance.new("Frame")
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -100, 0.5, -150)
    mainFrame.Size = UDim2.new(0, 200, 0, 300)
    mainFrame.Visible = false
    mainFrame.Parent = self.Parent.Parent.Parent.Parent  -- Adjust parent as needed
    mainFrame.ZIndex = 10
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = mainFrame
    
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = self.WindowColor
    frameStroke.Thickness = 2
    frameStroke.Transparency = 0.7
    frameStroke.Parent = mainFrame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Parent = mainFrame
    titleBar.ZIndex = 11
    
    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 6)
    titleBarCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = self.Title
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
    previewFrame.BackgroundColor3 = initialColor
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
    hexLabel.Text = string.format("#%02X%02X%02X", initialColor.R * 255, initialColor.G * 255, initialColor.B * 255)
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
    okBtn.BackgroundColor3 = self.WindowColor
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
    local selectedColor = initialColor
    local hue, saturation, value = rgbToHsv(initialColor)
    
    -- Update UI from HSV
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
    
    -- Initialize
    updateFromHsv()
    cursor.Visible = true
    
    -- Input handling
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
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
            isHueDragging = false
        end
    end)
    
    -- Button events
    okBtn.MouseButton1Click:Connect(function()
        -- Update preview
        self.PreviewBtn.BackgroundColor3 = selectedColor
        
        -- Save if needed
        if self.SaveColor then
            self.ConfigData[self.ElementKey] = {
                R = selectedColor.R,
                G = selectedColor.G,
                B = selectedColor.B
            }
            self.SaveFunction()
        end
        
        -- Call callback
        self.Callback(selectedColor)
        
        -- Close with animation
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 0, 0) })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            mainFrame.Visible = false
            mainFrame.Size = UDim2.new(0, 200, 0, 300)
        end)
    end)
    
    cancelBtn.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 0, 0) })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            mainFrame.Visible = false
            mainFrame.Size = UDim2.new(0, 200, 0, 300)
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 0, 0) })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            mainFrame.Visible = false
            mainFrame.Size = UDim2.new(0, 200, 0, 300)
        end)
    end)
    
    return {
        Open = function()
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 200, 0, 300)
            local openTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 200, 0, 300) })
            openTween:Play()
        end,
        Close = function()
            local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 0, 0) })
            closeTween:Play()
            closeTween.Completed:Connect(function()
                mainFrame.Visible = false
                mainFrame.Size = UDim2.new(0, 200, 0, 300)
            end)
        end,
        SetColor = function(newColor)
            if typeof(newColor) == "Color3" then
                initialColor = newColor
                selectedColor = newColor
                hue, saturation, value = rgbToHsv(newColor)
                updateFromHsv()
            end
        end
    }
end

function SimpleColorpickerClass:Set(color, skipCallback)
    if typeof(color) == "Color3" then
        self.PreviewBtn.BackgroundColor3 = color
        self.PickerWindow.SetColor(color)
        if not skipCallback then
            self.Callback(color)
        end
    end
end

function SimpleColorpickerClass:Get()
    return self.PreviewBtn.BackgroundColor3
end

function SimpleColorpickerClass:Open()
    self.PickerWindow.Open()
end

function SimpleColorpickerClass:Close()
    self.PickerWindow.Close()
end

-- Main export function that matches your usage pattern
local function NewColorpicker(Config)
    -- Check if we should use simple or advanced style
    -- Default to advanced style unless Simple=true is specified
    if Config.Simple then
        return SimpleColorpickerClass.new(Config)
    else
        return ColorpickerClass.new(Config)
    end
end

return ColorpickerModule
