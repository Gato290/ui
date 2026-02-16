local Chloex = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/refs/heads/main/ChloeX%20V3"))()

local Window = Chloex:Window({
    Title = "Title", -- Main title displayed at the top of the window
    Footer = "Footer", -- Footer text shown at the bottom
    Color = "Default", -- UI theme color (Default or custom theme)
    Version = 1.0,
    ["Tab Width"] = 120, -- Width size of the tab section
    Image = "70884221600423", -- Window icon asset ID (replace with your own)
    Configname = "MyCustomConfig", -- Configuration file name for saving settings
    Uitransparent = 0.15, -- UI transparency (0 = solid, 1 = fully transparent)
    Config = {
        AutoSave = true, -- Automatically save settings
        AutoLoad = true -- Automatically load saved settings
    }
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
    Open = true
})

-- Example Button (Single)
Sec.Button:AddButton({
    Title = "Example",
    Callback = function()
        print("This is an example button")
        Nt("Example clicked!", 2)
    end
})

-- Example Button (Dual Button)
Sec.Button:AddButton({
    Title = "Example",
    Callback = function()
        print("Example ON")
        Nt("Example enabled!", 2)
    end,

    SubTitle = "Example Off",
    SubCallback = function()
        print("Example OFF")
        Nt("Example disabled!", 2)
    end
})


Sec.Toggle = Tabs.Toggle:AddSection({
    Title = "Toggle Section",
    Open = true
})

-- Example Basic
Sec.Toggle:AddToggle({
    Title = "Example",
    Default = false,
    Callback = function(value)
        print("Example toggle:", value)

        if value then
            Nt("Example enabled!", 2)
        else
            Nt("Example disabled!", 2)
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
            Nt("Example enabled!", 2)
        else
            print("Example OFF")
            Nt("Example disabled!", 2)
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
            Nt("Example enabled!", 2)
        else
            Nt("Example disabled!", 2)
        end
    end
})

Sec.Dropdown = Tabs.Dropdown:AddSection({
    Title = "Dropdown Section",
    Open = true
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

Sec.Input = Tabs.Input:AddSection({
    Title = "Input Section",
    Open = true
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

Sec.Panel = Tabs.Panel:AddSection({
    Title = "Panel Section",
    Open = true
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
        Nt("Example action executed!", 2)
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
            Nt("Example saved!", 2)
        else
            Nt("Example name required!", 2)
        end
    end,

    SubButtonText = "Example Load",
    SubButtonCallback = function(value)
        if value ~= "" then
            print("Example load:", value)
            Nt("Example loaded!", 2)
        else
            Nt("Example name required!", 2)
        end
    end
})

Sec.Keybind = Tabs.Keybind:AddSection({
    Title = "Keybind Section (Soon)",
    Open = true
})

Sec.Slider = Tabs.Slider:AddSection({
    Title = "Slider Section",
    Open = true
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

Sec.Paragraph = Tabs.Paragraph:AddSection({
    Title = "Paragraph Section",
    Open = true
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
