local TweenService = game:GetService("TweenService")
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/main/Utils.lua"))()

local ButtonElement = {}

function ButtonElement:Create(ButtonConfig, GuiConfig)
    ButtonConfig = ButtonConfig or {}
    ButtonConfig.Title = ButtonConfig.Title or "Confirm"
    ButtonConfig.Callback = ButtonConfig.Callback or function() end
    ButtonConfig.SubTitle = ButtonConfig.SubTitle or nil
    ButtonConfig.SubCallback = ButtonConfig.SubCallback or function() end
    ButtonConfig.Color = ButtonConfig.Color or GuiConfig.Color

    local Button = Instance.new("Frame")
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundTransparency = 0.935
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.Name = "Button"

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Button

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
    MainButton.Name = "MainButton"
    MainButton.Parent = Button

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 4)
    mainCorner.Parent = MainButton

    -- Add click animation
    MainButton.MouseButton1Click:Connect(function()
        Utils.CircleClick(MainButton, game:GetService("Players").LocalPlayer:GetMouse().X, game:GetService("Players").LocalPlayer:GetMouse().Y)
        ButtonConfig.Callback()
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
        SubButton.Name = "SubButton"
        SubButton.Parent = Button

        local subCorner = Instance.new("UICorner")
        subCorner.CornerRadius = UDim.new(0, 4)
        subCorner.Parent = SubButton

        SubButton.MouseButton1Click:Connect(function()
            Utils.CircleClick(SubButton, game:GetService("Players").LocalPlayer:GetMouse().X, game:GetService("Players").LocalPlayer:GetMouse().Y)
            ButtonConfig.SubCallback()
        end)
    end

    return Button
end

return ButtonElement
