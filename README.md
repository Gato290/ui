# VelarisUI — Documentation (GitHub README)

UI library Roblox **VelarisUI**
Support: VikaiHub & NexaHub version
Dibuat untuk memudahkan pembuatan UI hub dengan sistem tab, section, toggle, dropdown, dll.

> **Catatan:** Dokumentasi ini hanya menjelaskan cara pakai.
> **Tidak ada satu pun kode yang dihapus atau diubah** dari source contoh.

# Update
```yml
Added TextXAlignment = "Left", In AddSection
```
# 📥 Load UI

# loadstring (Recomend)
```lua
local VelarisUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/refs/heads/main/main.lua"))()
```
# Support Icon
```Lucide, Solar```
# Window
```lua
local Window = VelarisUI:Window({
    Title = "Title", -- Main title displayed at the top of the window
    Footer = "Footer", -- Footer text shown at the bottom
    Color = "Default", -- UI theme color (Default or custom theme)
    Version = 1.0, -- Script/UI version number
    ["Tab Width"] = 120, -- Width size of the tab section
    Image = "70884221600423", -- Window icon asset ID (replace with your own)
    Configname = "MyCustomConfig", -- Configuration file name for saving settings
    Uitransparent = 0.20,
    ShowUser = true,
	Search = true,  
    Config = {
        AutoSave = true,
        AutoLoad = true, 
    }
})

```

# 🗂 Tabs
Contoh membuat tab UI.
## Default Icon
```lua
local Tabs = {
    Tabs1 = Window:AddTab({
        Name = "Tabs 1",
        Icon = "home",
    }),

    Tabs2 = Window:AddTab({
        Name = "Tabs 2",
        Icon = "gamepad",
    }),
}
```
## Lucide Icon
```lua
local Tabs = {
    Tabs1 = Window:AddTab({
        Name = "Tabs 1",
        Icon = "lucide:house",
    }),

    Tabs2 = Window:AddTab({
        Name = "Tabs 2",
        Icon = "lucide:sword",
    }),
}
```

## Solar Icon
```lua
local Tabs = {
    Tabs1 = Window:AddTab({
        Name = "Tabs 1",
        Icon = "solar:home",
    }),

    Tabs2 = Window:AddTab({
        Name = "Tabs 2",
        Icon = "solar:gamepad",
    }),
}
```
# 📦 Section
Section adalah container untuk button/toggle dll.

## frugal local
```lua
local Sec = {}
Sec.Player = Tabs.Main:AddSection({
    Title = "Player",
    Icon = "lucide:user",
    Open = true
})

-- Section dengan icon Solar
Sec.Weapon = Tabs.Main:AddSection({
    Title = "Weapons",
    Icon = "solar:home",
    Open = false
})
```
## Basic
```lua
Tabs.Main:AddSection({
    Title = "Player",
    Icon = "lucide:user",
    Open = true
})

-- Section dengan icon Solar
Tabs.Main:AddSection({
    Title = "Weapons",
    Icon = "solar:home",
    Open = false
})
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

## Button V2
```lua
Sec.Button:AddButton({
    Title = "Example Button V2 (Icon)",
    Version = "V2",
    Icon = "rbxassetid://79715859717613",  -- pakai asset id
    Callback = function()
        print("This is an example button")
        Nt("Example clicked!", 2)
    end
})
```

## Funcions Button
```lua
V1:
:Fire() → Trigger callback utama
:FireSub() → Trigger callback sub button
:SetTitle(text) → Ubah teks button utama
:SetSubTitle(text) → Ubah teks sub button
:SetCallback(fn) → Ganti callback utama
:SetSubCallback(fn) → Ganti callback sub button
:SetLocked(state) → Kunci/buka elemen
:GetLocked() → Cek status kunci

V2:
:Fire() → Trigger callback
:SetTitle(text) → Ubah judul
:SetContent(text) → Ubah content
:SetCallback(fn) → Ganti callback
:SetLocked(state) → Kunci/buka elemen
:GetLocked() → Cek status kunci
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

## Funcions Toggle
```lua
.Value → Status toggle saat ini (boolean)
:Set(value) → Set toggle true/false
:GetValue() → Ambil nilai toggle
:SetLocked(state) → Kunci/buka elemen
:GetLocked() → Cek status kunci
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

## Funcions Slider
```lua
.Value → Nilai slider saat ini
:Set(value) → Set nilai slider
:GetValue() → Ambil nilai slider
:SetMin(min) → Ubah nilai minimum
:SetMax(max) → Ubah nilai maximum
:SetLocked(state) → Kunci/buka elemen
:GetLocked() → Cek status kunci
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
.Value → Nilai/opsi terpilih
.Options → List semua opsi
:Set(value) → Set pilihan
:SetValue(val) → Alias dari :Set()
:GetValue() → Ambil nilai terpilih
:AddOption(option) → Tambah satu opsi
:Clear() → Hapus semua opsi & reset
:SetValues(list, selecting) → Reset & isi ulang semua opsi
:SetLocked(state) → Kunci/buka elemen
:GetLocked() → Cek status kunci
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
.Value → Nilai input saat ini
:Set(value) → Set nilai input
:GetValue() → Ambil nilai input
:Clear() → Kosongkan input
:SetLocked(state) → Kunci/buka elemen
:GetLocked() → Cek status kunci
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
Panel — CreatePanel
.Value → Nilai input saat ini
:GetInput() → Ambil teks dari InputBox
:GetValue() → Ambil value tersimpan
:SetContent(text) → Ubah teks content
:SetTitle(text) → Ubah teks judul
:SetLocked(state) → Kunci/buka elemen
:GetLocked() → Cek status kunci
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
Method: :SetContent(content)
Deskripsi: Ubah teks content/isi paragraph

Method: :GetContent()
Deskripsi: Ambil teks content saat ini

Method: :SetTitle(title)
Deskripsi: Ubah teks judul paragraph

Method: :GetTitle()
Deskripsi: Ambil teks judul saat ini

Method: :SetLocked(state)
Deskripsi: Kunci/buka elemen (true/false)

Method: :GetLocked()
Deskripsi: Cek apakah elemen sedang terkunci
```

# ➖ Divider & SubSection
```lua
Sec.Other = Tabs.Main:AddSection("SubSection & Divider")

Sec.Other:AddDivider()
Sec.Other:AddSubSection("Example Sub Section")
```

# Keybind
```lua
local MyKeybind = Section:AddKeybind({
    Title = "Toggle ESP",
    Content = "Tekan untuk toggle",  -- subtitle kecil di bawah title
    Value = "RightShift",            -- default key
    Callback = function(key)
    end
})
```

# 🔔 Notification
```lua
-- Basic
Notify("Ini isi pesan")

-- Lengkap
Notify(
    "Script berhasil diload!",  -- Content (isi pesan)
    5,                           -- Delay (berapa detik tampil)
    "Default",                   -- Color (nama warna atau Color3)
    "My Script",                 -- Title
    "Success",                   -- Description (teks berwarna di samping title)
    ""                           -- Icon (opsional)
)

Chloex:MakeNotify({ -- VelarisUI Or Chloex
    Title = "My Script",
    Description = "Success",       -- teks berwarna di samping title
    Content = "Script telah diload dengan sukses!",
    Color = "Default",             -- bisa "Default", "Red", "Green", dll
    Time = 0.5,                    -- durasi animasi masuk/keluar
    Delay = 5,                     -- berapa detik sebelum auto close
    Icon = ""                      -- icon opsional
})

```

# Dialog
```lua
Chloex:Dialog({
    Title = "Confirmation",
    Content = "Are you sure you want to continue?",
    Buttons = {
        {
            Name = "Yes",
            Callback = function()
                print("User selected Yes")
                -- put the action here
            end
        },
        {
            Name = "No",
            Callback = function()
                print("User selected No")
            end
        }
    }
})
```

# Full Example
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Gato290/ui/refs/heads/main/Example.lua"))()
```

VelarisUI
