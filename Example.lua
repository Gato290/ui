local Chloex = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/refs/heads/main/ChloeX%20V3"))()

local Window = Chloex:Window({
    Title = "Title",
    Footer = "Footer",
    Color = "Default",
    Version = 1.0,
    ["Tab Width"] = 120,
    Image = "70884221600423", -- ganti dengan gamar kalian sendiri
    Configname = "MyCustomConfig",
    Uitransparent = 0.15,  -- 15% transparan
    ShowUser = true,  -- Tampilkan user profile
    UserProfileType = "full", -- atau "simple"
})
local Tabs = {
    -- Default icon 
    Button = Window:AddTab({
        Name = "Button",
        Icon = "lucide:mouse",
    }),

    Toggle = Window:AddTab({
        Name = "Toggle",
        Icon = "lucide:toggle-right",
    }),

    Dropdown = Window:AddTab({
        Name = "Dropdwon",
        Icon = "lucide:menu",
    }),

    Input = Window:AddTab({
        Name = "Input",
        Icon = "lucide:chevrons-left-right-ellipsis",
    }),

    Panel = Window:AddTab({
        Name = "Panel",
        Icon = "lucide:panel-bottom",
    }),

    Keybind = Window:AddTab({
        Name = "Keybind",
        Icon = "lucide:key",
    }),

    Slider = Window:AddTab({
        Name = "Slider",
        Icon = "lucide:settings-2",
    }),

    Paragraph = Window:AddTab({
        Name = "Paragraph",
        Icon = "lucide:rows-2",
    }),
}

local Sec = {}

Sec.Button = Tabs.Button:AddSection({
    Title = "Button Section",
    AlwaysOpen = true
})

-- Example Button (Single)
Sec.Button:AddButton({
    Title = "Example",
    Callback = function()
        print("This is an example button")
        Notify("Example clicked!", 2)
    end
})

-- Example Button (Dual Button)
Sec.Button:AddButton({
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

-- Example Title2
Sec.Button:AddButton({
    Title = "Example",
    Title2 = "Example Sub Title",
    Callback = function()
        print("This is an example button")
        Notify("Example clicked!", 2)
    end
})

-- Example Badge
Sec.Button:AddButton({
    Title = "Example",
    New = "true",
    Callback = function()
        print("This is an example button")
        Notify("Example clicked!", 2)
    end
})

Sec.Toggle = Tabs.Toggle:AddSection({
    Title = "Toggle Section",
    AlwaysOpen = true
})

-- Example Basic
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

-- Example With Title2
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

-- Example With Content
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

-- Example Bedge
Sec.Toggle:AddToggle({
    Title = "Example",
    New = "true",
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

Sec.Dropdown = Tabs.Dropdown:AddSection({
    Title = "Dropdown Section",
    AlwaysOpen = true
})

-- Example Single
Sec.Dropdown:AddDropdown({
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

-- Example Multi
Sec.Dropdown:AddDropdown({
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

-- Example Bedge
Sec.Dropdown:AddDropdown({
    Title = "Example",
    Content = "Example dropdown description",
    New = "true",
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

Sec.Input = Tabs.Input:AddSection({
    Title = "Input Section",
    AlwaysOpen = true
})

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

-- Example Bedge
Sec.Input:AddInput({
    Title = "Add Coins",
    New = "true",
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


Sec.Panel = Tabs.Panel:AddSection({
    Title = "Panel Section",
    AlwaysOpen = true
})

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

-- Example Bedge
Sec.Panel:AddPanel({
    Title = "Example",
    New = "true",
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
Sec.Keybind = Tabs.Keybind:AddSection({
    Title = "Keybind Section",
    AlwaysOpen = true
})

Sec.Keybind:AddKeybind({
    Title = "Keybind",
    Value = "V",  -- Default key
    Placeholder = "Click to set key",
    Callback = function(key)
        print("Key pressed:", key)
    end
})

Sec.Slider = Tabs.Slider:AddSection({
    Title = "Slider Section",
    AlwaysOpen = true
})

-- Example Basic
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

-- Example Alternative
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

-- Example Bedge
Sec.Slider:AddSlider({
    Title = "Example",
    New = "true",
    Content = "Example slider description",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Callback = function(value)
        print("Example slider value:", value)
    end
})

Sec.Paragraph = Tabs.Paragraph:AddSection({
    Title = "Paragraph Section",
    AlwaysOpen = true
})

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

-- Example Bedge
Sec.Paragraph:AddParagraph({
    Title = "Example",
    New = "true",
    Content = "This is an example paragraph.\nUse \\n for new lines."
})
