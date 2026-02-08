![ChloeXUi](https://i.imgur.com/8KqTL0X.jpeg)

# Chloe X UI — Documentation (GitHub README)

UI library Roblox **Chloe X**
Support: VikaiHub & NexaHub version
Dibuat untuk memudahkan pembuatan UI hub dengan sistem tab, section, toggle, dropdown, dll.

> **Catatan:** Dokumentasi ini hanya menjelaskan cara pakai.
> **Tidak ada satu pun kode yang dihapus atau diubah** dari source contoh.
# 📥 Load UI

Pilih salah satu versi.

## loadstring v1
```lua
-- Pilih salah satu

-- VikaiHub
local Chloex = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/refs/heads/main/Chloe%20X%20VikaiHub"))()
-- NexaHub
local Chloex = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/refs/heads/main/Chloe%20X%20NexaHub"))()
```
## loadstring v2
```lua
local Chloex = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/refs/heads/main/ChloeX%20V2"))()
```
# 🎨 Icon Name
List icon yang bisa dipakai di tab / section / paragraph.
```lua
alert, bag, boss, cart, compas, crosshair, dcs, discord, eyes, fish, folder,
gamepad, gps, home, idea, lexshub, loop, menu, next, Notify, payment, player,
plug, question, rod, scan, scroll, settings, shop, skeleton, star, start,
stat, strom, sword, user, water, web
```

# Window v1
```lua
local Window = Chloex:Window({
    Title = "Title",           -- Judul window
    Footer = "Footer",          -- Footer text
    Color = Color3.fromRGB(0, 208, 255),  -- Warna utama
    Version = 1.0,                -- Versi config
    ["Tab Width"] = 120,          -- Lebar sidebar tab
    Image = "70884221600423", -- Icon untuk toggle button
})
```
## Window v2
tambahan ``Configname = "MyCustomConfig"``
```lua
local Window = Chloex:Window({
    Title = "Title",           -- Judul window
    Footer = "Footer",          -- Footer text
    Color = Color3.fromRGB(0, 208, 255),  -- Warna utama
    Version = 1.0,                -- Versi config
    ["Tab Width"] = 120,          -- Lebar sidebar tab
    Image = "70884221600423", -- Icon untuk toggle button
    Configname = "MyCustomConfig"  -- Nama folder config
})
```

# 🗂 Tabs
Contoh membuat tab UI.
```lua
local Tabs = {
    Home = Window:AddTab({
        Name = "Home",
        Icon = "home",
    }),

    Main = Window:AddTab({
        Name = "Main",
        Icon = "gamepad",
    }),
}
```

# 📦 Section
Section adalah container untuk button/toggle dll.
```lua
local Sec = {}

Sec.Section1 = Tabs.Main:AddSection("Section Example 1", true) -- true = selalu terbuka tidak bisa di tutup
Sec.Section2 = Tabs.Main:AddSection("Section Example 2") -- tertutup secara default 
```

# 🔘 Button
```lua
Sec.Botton = Tabs.Main:AddSection("Botton")
```
## Single Button
```lua
-- Example Button (Single)
Sec.Botton:AddButton({
    Title = "Example",
    Callback = function()
        print("This is an example button")
        Notify("Example clicked!", 2)
    end
})
```
## Dual Button
```lua
-- Example Button (Dual Button)
Sec.Botton:AddButton({
    Title = "Example",
    Callback = function()
        print("Example ON")
        Notify("Example enabled!", 2)
    end,

    SubTitle = "Example Off",
    SubCallback = function()
        print("Example OFF")
        Notify("Example disabled!", 2)
    end
})
```

# 🔁 Toggle
```lua
Sec.Toggle = Tabs.Main:AddSection("Toggle")
```

## Basic

```lua
Sec.Toggle:AddToggle({
    Title = "Example",
    Default = false,
    Callback = function(value)
        print("Example toggle:", value)

        if value then
            Notify("Example enabled!", 2)
        else
            Notify("Example disabled!", 2)
        end
    end
})
```

## With Title2

```lua
Sec.Toggle:AddToggle({
    Title = "Example",
    Title2 = "Example Sub Title",
    Default = false,
    Callback = function(value)
        if value then
            print("Example ON")
            Notify("Example enabled!", 2)
        else
            print("Example OFF")
            Notify("Example disabled!", 2)
        end
    end
})
```

## With Content

```lua
Sec.Toggle:AddToggle({
    Title = "Example",
    Content = "This is an example toggle description",
    Default = false,
    Callback = function(value)
        if value then
            Notify("Example enabled!", 2)
        else
            Notify("Example disabled!", 2)
        end
    end
})
```

# 🎚 Slider

```lua
Sec.Slider = Tabs.Main:AddSection("Slider") 
```

## Basic

```lua
Sec.Slider:AddSlider({
    Title = "Example",
    Content = "Example slider description",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Callback = function(value)
        print("Example slider value:", value)
    end
})
```

## Alternative

```lua
Sec.Slider:AddSlider({
    Title = "Example",
    Content = "Another example slider",
    Min = 0,
    Max = 100,
    Default = 70,
    Increment = 5,
    Callback = function(value)
        print("Example value:", value)
    end
})
```


# 📂 Dropdown

```lua
Sec.Dropdwon = Tabs.Main:AddSection("Dropdown")
```

## Single

```lua
Sec.Dropdwon:AddDropdown({
    Title = "Example",
    Content = "Example dropdown description",
    Options = {
        "Option A",
        "Option B",
        "Option C",
        "Option D"
    },
    Multi = false,
    Default = "Option A",
    Callback = function(value)
        print("Example selected:", value)
    end
})
```

## Multi

```lua
Sec.Dropdwon:AddDropdown({
    Title = "Example",
    Content = "Example multi dropdown description",
    Options = {
        "Option 1",
        "Option 2",
        "Option 3",
        "Option 4"
    },
    Multi = true,
    Default = {
        "Option 1",
        "Option 2"
    },
    Callback = function(selectedTable)
        print("Example selected options:")
        for _, v in ipairs(selectedTable) do
            print("- " .. v)
        end
    end
})
```

## Label + Value

```lua
Sec.Dropdwon:AddDropdown({
    Title = "Example",
    Content = "Example value dropdown description",
    Options = {
        { Label = "Option 1", Value = "value_1" },
        { Label = "Option 2", Value = "value_2" },
        { Label = "Option 3", Value = "value_3" }
    },
    Multi = false,
    Default = "value_1",
    Callback = function(value)
        print("Example value selected:", value)
    end
})
```

## Funcions Dropdwom
```lua
-- 1. Get Value
local currentExample = ExampleSelect:GetValue()
print("Current example selected:", currentExample)

-- 2. Set Value
-- Single select
ExampleSelect:Set("Example Option A")

-- Multi select
ExampleMultiSelect:Set({"Example Option 1", "Example Option 2"})

-- 3. Clear Options
ExampleSelect:Clear()

-- 4. Add New Option
ExampleSelect:AddOption("Example Option X")
ExampleSelect:AddOption({Label = "Example Label Y", Value = "example_value_y"})

-- 5. Set All Options
-- Update all options at once, with default value
ExampleSelect:SetValues({
    "Example Option A",
    "Example Option B",
    "Example Option C",
    {Label = "Example Label D", Value = "example_value_d"}
}, "Example Option A") -- Default value after update
```

# ⌨ Input
```lua
Sec.Input = Tabs.Main:AddSection("Input")

Sec.Input:AddInput({
    Title = "Username",
    Content = "Enter your username",
    Default = game.Players.LocalPlayer.Name,
    Callback = function(value)
        print("Username set to:", value)
        -- Save username setting
    end
})

Sec.Input:AddInput({
    Title = "Search Item",
    Content = "Type item name to search",
    Default = "", -- Default kosong
    Callback = function(value)
        if value ~= "" then
            print("Searching for:", value)
            -- Kode search
        end
    end
})

Sec.Input:AddInput({
    Title = "Add Coins",
    Content = "Enter amount to add",
    Default = "1000",
    Callback = function(value)
        local amount = tonumber(value)
        if amount and amount > 0 then
            print("Adding", amount, "coins")
            -- Add coins logic
        else
            Notify("Invalid amount!", 3)
        end
    end
})
```

## Funcions Input
```lua
-- 1. Get Value
local currentExampleInput = ExampleInput.Value
-- atau
local currentExampleInput = ExampleInput:Get()
print("Current example input:", currentExampleInput)

-- 2. Set Value
-- Update input box value
ExampleInput:Set("ExampleNewValue123")

-- Clear input
ExampleInput:Set("")
```

# 🧾 Panel
```lua
Sec.Panel = Tabs.Main:AddSection("Panel")
```
# Single Button
```lua
-- Example Panel (Single Button)
Sec.Panel:AddPanel({
    Title = "Example",
    Content = "Example panel description",
    Placeholder = "Example_Name",
    Default = "ExampleDefault",
    ButtonText = "Example Action",
    ButtonCallback = function(value)
        print("Example value:", value)
        -- Example logic here
        Notify("Example action executed!", 2)
    end
})
```
# Dual Button
```lua
-- Example Panel (Dual Button)
Sec.Panel:AddPanel({
    Title = "Example",
    Content = "Example panel with two actions",
    Placeholder = "Example_Name",
    Default = "",
    ButtonText = "Example Save",
    ButtonCallback = function(value)
        if value ~= "" then
            print("Example save:", value)
            Notify("Example saved!", 2)
        else
            Notify("Example name required!", 2)
        end
    end,

    SubButtonText = "Example Load",
    SubButtonCallback = function(value)
        if value ~= "" then
            print("Example load:", value)
            Notify("Example loaded!", 2)
        else
            Notify("Example name required!", 2)
        end
    end
})
```

## Funcions Panel
```lua
PanelFunc:GetInput()
```

# 📄 Paragraph
```lua
Sec.Paragraph = Tabs.Main:AddSection("Paragraph") 

-- Example Paragraph (Simple)
Sec.Paragraph:AddParagraph({
    Title = "Example",
    Content = "This is an example paragraph.\nUse \\n for new lines."
})

-- Example Paragraph (With Icon)
Sec.Paragraph:AddParagraph({
    Title = "Example",
    Content = "Example information paragraph with an icon.",
    Icon = "example_icon"
})

-- Example Paragraph (With Button)
Sec.Paragraph:AddParagraph({
    Title = "Example",
    Content = "Example paragraph with action button.",
    Icon = "example_action_icon",
    ButtonText = "Example Action",
    ButtonCallback = function()
        print("Example button clicked")
    end
})

-- Example Paragraph (Support Section)
Sec.Paragraph:AddParagraph({
    Title = "Example",
    Content = "Example support paragraph with a button.",
    Icon = "example_help_icon",
    ButtonText = "Get Help",
    ButtonCallback = function()
        print("Support action triggered")
    end
})
```
## Funcions Paragraph
```lua
ParagraphFunc:SetContent(newContent)
```

# ➖ Divider & SubSection
```lua
Sec.Other = Tabs.Main:AddSection("SubSection & Divider")

Sec.Other:AddDivider()
Sec.Other:AddSubSection("Example Sub Section")
```

# 🔔 Notification
```lua
-- Basic notification
Notify(
    "Example message"  -- Notification message
)

-- Notification with custom duration
Notify(
    "Example started!",  -- Message
    5                   -- Duration in seconds
)

-- Notification with custom color
Notify(
    "Example success!",                  -- Message
    3,                                 -- Duration
    Color3.fromRGB(0, 255, 0)           -- Color
)

-- Full notification (message, duration, color, title, subtitle)
Notify(
    "Example completed",                -- Main message
    4,                                 -- Duration
    Color3.fromRGB(0, 208, 255),       -- Color
    "Example System",                   -- Title
    "Example Notification"              -- Subtitle / category
)

-- Custom notification basic
Chloex:MakeNotify({
    Title = "Example Success",                 -- Title
    Description = "Example System",             -- Description / category
    Content = "Example action completed!",     -- Main content
    Color = Color3.fromRGB(0, 255, 0),          -- Color
    Time = 0.5,                                -- Animation time (optional)
    Delay = 3                                  -- Display duration in seconds
})

-- Warning notification
Chloex:MakeNotify({
    Title = "Example Warning",                 -- Title
    Description = "⚠️ Example Alert",           -- Additional description
    Content = "This is an example warning!",   -- Message content
    Color = Color3.fromRGB(255, 165, 0),        -- Warning color
    Delay = 5                                  -- Display duration
})

-- Error notification
Chloex:MakeNotify({
    Title = "Example Error",                   -- Title
    Description = "❌ Example Failed",          -- Error description
    Content = "Example error occurred.",       -- Message
    Color = Color3.fromRGB(255, 0, 0),          -- Error color
    Delay = 4                                  -- Duration
})

-- Create custom notification and save reference
local exampleCustomNotify = Chloex:MakeNotify({
    Title = "Example Title",              -- Title
    Description = "Example Info",         -- Description
    Content = "Click or close manually",  -- Content message
    Delay = 60                            -- Max display time (seconds)
})
```

## Funcions Notify
```lua
NotifyFunc:Close()
```

# 🧩 UI Settings
```lua
Sec.Ui = Tabs.Main:AddSection("Ui")

-- Example Input: UI Transparency
Sec.Ui:AddInput({
    Title = "Example",
    Content = "0 = solid, 1 = transparent",
    Default = "0.15",
    Callback = function(value)
        local transparency = tonumber(value)
        if not transparency then return end

        transparency = math.clamp(transparency, 0, 1)

        -- Contoh update UI element (dummy)
        print("Example transparency set to:", transparency)

        -- Simulasi penyimpanan konfigurasi
        -- ConfigData.ExampleTransparency = transparency
        -- SaveConfig()
    end
})

-- Example Input: Hotkey Setting
Sec.Ui:AddInput({
    Title = "Example",
    Content = "Enter key name (e.g. F4)",
    Default = "F4",
    Callback = function(value)
        print("Example hotkey set to:", value)
        -- Contoh simpan atau bind hotkey
    end
})
```
