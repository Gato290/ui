
-- keybind.lua V1.0.0
-- Module untuk menangani fungsionalitas Keybind
-- Terintegrasi dengan Chloe X UI

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local KeybindModule = {}

-- Fungsi untuk membuat efek circle click
local function CircleClick(Button, X, Y)
    spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.8999999761581421
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Name = "Circle"
        Circle.Parent = Button

        local NewX = X - Circle.AbsolutePosition.X
        local NewY = Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        local Size = 0
        if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.Y * 1.5
        elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        end

        local Time = 0.5
        Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size / 2, 0.5, -Size / 2), "Out", "Quad",
            Time, false, nil)
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.01
            wait(Time / 10)
        end
        Circle:Destroy()
    end)
end

-- Fungsi untuk mengkonversi input ke string key yang konsisten
local function GetKeyString(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        return input.KeyCode.Name
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        return "LMB"
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        return "RMB"
    elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
        return "MMB"
    end
    return ""
end

-- Fungsi untuk membuat keybind UI element
function KeybindModule.CreateKeybind(parent, config, countItem, updateCallback)
    config = config or {}
    config.Title = config.Title or "Keybind"
    config.Value = config.Value or "V"
    config.Callback = config.Callback or function() end
    config.SaveKey = config.SaveKey or false
    config.ConfigData = config.ConfigData or {}
    config.SaveFunction = config.SaveFunction or nil

    local KeybindFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local KeybindTitle = Instance.new("TextLabel")
    local KeybindButton = Instance.new("TextButton")
    local KeybindButtonCorner = Instance.new("UICorner")

    KeybindFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    KeybindFrame.BackgroundTransparency = 0.935
    KeybindFrame.BorderSizePixel = 0
    KeybindFrame.Size = UDim2.new(1, 0, 0, 30)
    KeybindFrame.LayoutOrder = countItem
    KeybindFrame.Name = "KeybindFrame_" .. config.Title:gsub("%s+", "_")
    KeybindFrame.Parent = parent

    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = KeybindFrame

    KeybindTitle.Font = Enum.Font.GothamBold
    KeybindTitle.Text = config.Title
    KeybindTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    KeybindTitle.TextSize = 13
    KeybindTitle.TextXAlignment = Enum.TextXAlignment.Left
    KeybindTitle.BackgroundTransparency = 1
    KeybindTitle.Position = UDim2.new(0, 10, 0, 0)
    KeybindTitle.Size = UDim2.new(0.6, 0, 1, 0)
    KeybindTitle.Name = "KeybindTitle"
    KeybindTitle.Parent = KeybindFrame

    KeybindButton.Font = Enum.Font.GothamBold
    KeybindButton.Text = config.Value
    KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeybindButton.TextSize = 12
    KeybindButton.AnchorPoint = Vector2.new(1, 0.5)
    KeybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    KeybindButton.BorderSizePixel = 0
    KeybindButton.Position = UDim2.new(1, -10, 0.5, 0)
    KeybindButton.Size = UDim2.new(0, 60, 0, 22)
    KeybindButton.Name = "KeybindButton"
    KeybindButton.Parent = KeybindFrame

    KeybindButtonCorner.CornerRadius = UDim.new(0, 4)
    KeybindButtonCorner.Parent = KeybindButton

    local currentKey = config.Value
    local isBinding = false
    local connection = nil
    local keybindFunctions = {}

    -- Load dari config jika ada
    if config.SaveKey and config.ConfigData and config.ConfigData[config.Title] then
        currentKey = config.ConfigData[config.Title]
        KeybindButton.Text = currentKey
    end

    local function updateDisplay(key)
        currentKey = key
        KeybindButton.Text = key
        
        -- Save ke config jika diperlukan
        if config.SaveKey and config.ConfigData and config.SaveFunction then
            config.ConfigData[config.Title] = key
            config.SaveFunction()
        end
    end

    -- Handle button click untuk memulai binding
    KeybindButton.Activated:Connect(function()
        if isBinding then return end
        
        isBinding = true
        KeybindButton.Text = "..."
        CircleClick(KeybindButton, Mouse.X, Mouse.Y)

        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            local key = GetKeyString(input)
            
            if key ~= "" and key ~= "Unknown" then
                updateDisplay(key)
                isBinding = false
                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end)
    end)

    -- Listener global untuk mendeteksi saat key ditekan
    local globalConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or isBinding then return end
        
        local pressedKey = GetKeyString(input)

        if pressedKey == currentKey then
            local success, err = pcall(function()
                config.Callback(currentKey)
            end)
            if not success then
                warn("Error in keybind callback:", err)
            end
        end
    end)

    -- Cleanup function
    function keybindFunctions:Destroy()
        if globalConnection then
            globalConnection:Disconnect()
        end
        if connection then
            connection:Disconnect()
        end
        KeybindFrame:Destroy()
    end

    -- Set keybind ke key baru
    function keybindFunctions:Set(key)
        if key and type(key) == "string" then
            updateDisplay(key)
        end
        return self
    end

    -- Get current key
    function keybindFunctions:Get()
        return currentKey
    end

    -- Update callback
    function keybindFunctions:SetCallback(newCallback)
        if newCallback and type(newCallback) == "function" then
            config.Callback = newCallback
        end
        return self
    end

    -- Update title
    function keybindFunctions:SetTitle(newTitle)
        if newTitle then
            config.Title = newTitle
            KeybindTitle.Text = newTitle
        end
        return self
    end

    -- Enable/disable keybind
    function keybindFunctions:SetEnabled(enabled)
        if enabled then
            if not globalConnection then
                globalConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed or isBinding then return end
                    local pressedKey = GetKeyString(input)
                    if pressedKey == currentKey then
                        pcall(config.Callback, currentKey)
                    end
                end)
            end
        else
            if globalConnection then
                globalConnection:Disconnect()
                globalConnection = nil
            end
        end
        return self
    end

    if updateCallback then
        updateCallback()
    end

    return keybindFunctions
end

-- Fungsi untuk membuat standalone keybind (tanpa UI element)
function KeybindModule.CreateStandaloneKeybind(config)
    config = config or {}
    config.Key = config.Key or "V"
    config.Callback = config.Callback or function() end
    config.Name = config.Name or "StandaloneKeybind"

    local currentKey = config.Key
    local isEnabled = true
    local standaloneFunctions = {}

    local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not isEnabled then return end
        
        local pressedKey = GetKeyString(input)

        if pressedKey == currentKey then
            local success, err = pcall(function()
                config.Callback(currentKey)
            end)
            if not success then
                warn("Error in standalone keybind callback:", err)
            end
        end
    end)

    function standaloneFunctions:SetKey(key)
        if key and type(key) == "string" then
            currentKey = key
        end
        return self
    end

    function standaloneFunctions:GetKey()
        return currentKey
    end

    function standaloneFunctions:SetCallback(newCallback)
        if newCallback and type(newCallback) == "function" then
            config.Callback = newCallback
        end
        return self
    end

    function standaloneFunctions:Enable()
        isEnabled = true
        return self
    end

    function standaloneFunctions:Disable()
        isEnabled = false
        return self
    end

    function standaloneFunctions:Toggle()
        isEnabled = not isEnabled
        return self
    end

    function standaloneFunctions:IsEnabled()
        return isEnabled
    end

    function standaloneFunctions:Destroy()
        if connection then
            connection:Disconnect()
        end
    end

    return standaloneFunctions
end

-- Fungsi untuk memformat nama key agar lebih user-friendly
function KeybindModule.FormatKeyName(key)
    if key == "LMB" then
        return "Left Mouse"
    elseif key == "RMB" then
        return "Right Mouse"
    elseif key == "MMB" then
        return "Middle Mouse"
    elseif key:match("^Mouse") then
        return key:gsub("Button", " Mouse")
    else
        if #key == 1 then
            return key:upper()
        else
            return key:sub(1,1):upper() .. key:sub(2):lower()
        end
    end
end

return KeybindModule
