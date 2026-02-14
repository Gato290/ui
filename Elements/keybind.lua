-- keybind.lua V1.3.0
-- Module untuk menangani fungsionalitas Keybind
-- Support PC, Laptop, dan Mobile dengan keyboard

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local KeybindModule = {}
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================================
-- CONSTANTS & CONFIGURATION
-- ============================================================================

local DEFAULT_CONFIG = {
	TITLE = "Keybind",
	KEY = "V",
	BUTTON_WIDTH = 90,
	BUTTON_HEIGHT = 22,
	FRAME_HEIGHT = 30,
	CORNER_RADIUS = 4,
	FONT = Enum.Font.GothamBold,
	TEXT_SIZE = {
		TITLE = 13,
		BUTTON = 11,
		HINT = 10
	},
	COLORS = {
		FRAME_BG = Color3.fromRGB(255, 255, 255),
		FRAME_TRANSPARENCY = 0.935,
		BUTTON_BG = Color3.fromRGB(40, 40, 40),
		BUTTON_BINDING_BG = Color3.fromRGB(60, 40, 40),
		TITLE_TEXT = Color3.fromRGB(230, 230, 230),
		BUTTON_TEXT = Color3.fromRGB(255, 255, 255),
		CIRCLE = Color3.fromRGB(80, 80, 80),
		HINT_TEXT = Color3.fromRGB(150, 150, 150)
	},
	CIRCLE_IMAGE = "rbxassetid://266543268",
	ANIMATION_TIME = 0.5,
	
	-- Daftar key yang didukung
	SUPPORTED_KEYS = {
		-- Mouse buttons
		"LMB", "RMB", "MMB",
		-- Keyboard - Letters
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		-- Keyboard - Numbers
		"Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
		-- Function keys
		"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
		-- Control keys
		"Return", "Backspace", "Tab", "Space", "Shift", "Ctrl", "Alt",
		"LeftShift", "RightShift", "LeftControl", "RightControl", "LeftAlt", "RightAlt",
		"CapsLock", "Escape", "Insert", "Delete", "Home", "End", "PageUp", "PageDown",
		-- Arrow keys
		"Up", "Down", "Left", "Right"
	}
}

-- ============================================================================
-- DETECT DEVICE TYPE
-- ============================================================================

local function isMobile()
	return UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled
end

local function hasKeyboard()
	return UserInputService.KeyboardEnabled
end

local function hasMouse()
	return UserInputService.MouseEnabled
end

-- ============================================================================
-- INPUT UTILITY FUNCTIONS
-- ============================================================================

-- Konversi input ke string key yang konsisten
local function getKeyString(input)
	-- Handle keyboard input
	if input.UserInputType == Enum.UserInputType.Keyboard then
		return input.KeyCode.Name
	end
	
	-- Handle mouse input
	local MOUSE_BUTTON_MAP = {
		[Enum.UserInputType.MouseButton1] = "LMB",
		[Enum.UserInputType.MouseButton2] = "RMB",
		[Enum.UserInputType.MouseButton3] = "MMB"
	}
	
	if MOUSE_BUTTON_MAP[input.UserInputType] then
		return MOUSE_BUTTON_MAP[input.UserInputType]
	end
	
	-- Handle touch input (untuk mobile on-screen keyboard)
	if input.UserInputType == Enum.UserInputType.Touch then
		-- Touch biasanya digunakan untuk UI, bukan untuk keybind
		return ""
	end
	
	return ""
end

-- Handle key press dari berbagai device
local function setupKeyListener(callback, isBindingMode)
	local connection
	
	if isBindingMode then
		-- Mode binding: tangkap semua input termasuk yang diproses game
		connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			-- Di mode binding, kita tetap tangkap meskipun gameProcessed = true
			local key = getKeyString(input)
			if key ~= "" then
				callback(key, input)
			end
		end)
	else
		-- Mode normal: hanya tangkap input yang tidak diproses game
		connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			local key = getKeyString(input)
			if key ~= "" then
				callback(key)
			end
		end)
	end
	
	return connection
end

-- Validasi apakah key didukung
local function isKeySupported(key)
	for _, supportedKey in ipairs(DEFAULT_CONFIG.SUPPORTED_KEYS) do
		if supportedKey == key then
			return true
		end
	end
	return false
end

-- Format nama key agar lebih user-friendly
function KeybindModule.FormatKeyName(key)
	local FORMATTED_KEYS = {
		LMB = "Left Mouse",
		RMB = "Right Mouse",
		MMB = "Middle Mouse",
		Return = "Enter",
		Backspace = "Bksp",
		Space = "Space",
		Shift = "Shift",
		Ctrl = "Ctrl",
		Alt = "Alt",
		LeftShift = "L-Shift",
		RightShift = "R-Shift",
		LeftControl = "L-Ctrl",
		RightControl = "R-Ctrl",
		LeftAlt = "L-Alt",
		RightAlt = "R-Alt",
		CapsLock = "Caps",
		Escape = "Esc",
		Insert = "Ins",
		Delete = "Del",
		PageUp = "PgUp",
		PageDown = "PgDn",
		Zero = "0",
		One = "1",
		Two = "2",
		Three = "3",
		Four = "4",
		Five = "5",
		Six = "6",
		Seven = "7",
		Eight = "8",
		Nine = "9"
	}
	
	if FORMATTED_KEYS[key] then
		return FORMATTED_KEYS[key]
	end
	
	if key:match("^Mouse") then
		return key:gsub("Button", " Mouse")
	end
	
	if #key == 1 then
		return key:upper()
	end
	
	return key:sub(1, 1):upper() .. key:sub(2):lower()
end

-- ============================================================================
-- UI EFFECT FUNCTIONS
-- ============================================================================

-- Membuat efek circle click pada button
local function createClickEffect(button, x, y)
	task.spawn(function()
		button.ClipsDescendants = true
		
		local circle = Instance.new("ImageLabel")
		circle.Image = DEFAULT_CONFIG.CIRCLE_IMAGE
		circle.ImageColor3 = DEFAULT_CONFIG.COLORS.CIRCLE
		circle.ImageTransparency = 0.9
		circle.BackgroundColor3 = DEFAULT_CONFIG.COLORS.BUTTON_TEXT
		circle.BackgroundTransparency = 1
		circle.ZIndex = 10
		circle.Name = "Circle"
		circle.Parent = button
		
		local relativeX = x - circle.AbsolutePosition.X
		local relativeY = y - circle.AbsolutePosition.Y
		circle.Position = UDim2.new(0, relativeX, 0, relativeY)
		
		local maxDimension = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y)
		local circleSize = maxDimension * 1.5
		
		local tweenInfo = TweenInfo.new(
			DEFAULT_CONFIG.ANIMATION_TIME,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
		
		local sizeGoal = UDim2.new(0, circleSize, 0, circleSize)
		local positionGoal = UDim2.new(0.5, -circleSize / 2, 0.5, -circleSize / 2)
		
		local sizeTween = TweenService:Create(circle, tweenInfo, { Size = sizeGoal })
		local posTween = TweenService:Create(circle, tweenInfo, { Position = positionGoal })
		
		sizeTween:Play()
		posTween:Play()
		
		-- Fade out animation
		for transparency = circle.ImageTransparency, 1, 0.1 do
			circle.ImageTransparency = transparency
			task.wait(DEFAULT_CONFIG.ANIMATION_TIME / 10)
		end
		
		circle:Destroy()
	end)
end

-- ============================================================================
-- UI COMPONENT CREATION
-- ============================================================================

-- Membuat frame keybind
local function createKeybindFrame(parent, title, layoutOrder)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = DEFAULT_CONFIG.COLORS.FRAME_BG
	frame.BackgroundTransparency = DEFAULT_CONFIG.COLORS.FRAME_TRANSPARENCY
	frame.BorderSizePixel = 0
	frame.Size = UDim2.new(1, 0, 0, DEFAULT_CONFIG.FRAME_HEIGHT)
	frame.LayoutOrder = layoutOrder
	frame.Name = "KeybindFrame_" .. title:gsub("%s+", "_")
	frame.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, DEFAULT_CONFIG.CORNER_RADIUS)
	corner.Parent = frame
	
	return frame
end

-- Membuat title label
local function createTitleLabel(parent, title)
	local label = Instance.new("TextLabel")
	label.Font = DEFAULT_CONFIG.FONT
	label.Text = title
	label.TextColor3 = DEFAULT_CONFIG.COLORS.TITLE_TEXT
	label.TextSize = DEFAULT_CONFIG.TEXT_SIZE.TITLE
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 10, 0, 0)
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Name = "KeybindTitle"
	label.Parent = parent
	
	return label
end

-- Membuat button keybind
local function createKeybindButton(parent, initialText)
	local button = Instance.new("TextButton")
	button.Font = DEFAULT_CONFIG.FONT
	button.Text = KeybindModule.FormatKeyName(initialText)
	button.TextColor3 = DEFAULT_CONFIG.COLORS.BUTTON_TEXT
	button.TextSize = DEFAULT_CONFIG.TEXT_SIZE.BUTTON
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.BackgroundColor3 = DEFAULT_CONFIG.COLORS.BUTTON_BG
	button.BorderSizePixel = 0
	button.Position = UDim2.new(1, -10, 0.5, 0)
	button.Size = UDim2.new(0, DEFAULT_CONFIG.BUTTON_WIDTH, 0, DEFAULT_CONFIG.BUTTON_HEIGHT)
	button.Name = "KeybindButton"
	button.Parent = parent
	button.AutoButtonColor = false
	button.SelectedObject = button
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, DEFAULT_CONFIG.CORNER_RADIUS)
	corner.Parent = button
	
	return button
end

-- Membuat hint label
local function createHintLabel(parent, text)
	local hint = Instance.new("TextLabel")
	hint.Font = DEFAULT_CONFIG.FONT
	hint.Text = text
	hint.TextColor3 = DEFAULT_CONFIG.COLORS.HINT_TEXT
	hint.TextSize = DEFAULT_CONFIG.TEXT_SIZE.HINT
	hint.TextXAlignment = Enum.TextXAlignment.Right
	hint.BackgroundTransparency = 1
	hint.Position = UDim2.new(0.6, 10, 0, 0)
	hint.Size = UDim2.new(0.3, -20, 1, 0)
	hint.Visible = false
	hint.Name = "KeybindHint"
	hint.Parent = parent
	
	return hint
end

-- ============================================================================
-- MAIN KEYBIND FUNCTIONS
-- ============================================================================

-- Membuat keybind UI element
function KeybindModule.CreateKeybind(parent, config, countItem, updateCallback)
	-- Normalisasi konfigurasi
	config = config or {}
	local title = config.Title or DEFAULT_CONFIG.TITLE
	local currentKey = config.Value or DEFAULT_CONFIG.KEY
	local callback = config.Callback or function() end
	
	local isBinding = false
	local connection = nil
	local globalConnection = nil
	local hintVisible = false
	
	-- Validasi initial key
	if not isKeySupported(currentKey) then
		warn(string.format("[Keybind] Key '%s' tidak didukung, menggunakan default '%s'", currentKey, DEFAULT_CONFIG.KEY))
		currentKey = DEFAULT_CONFIG.KEY
	end
	
	-- Load dari config jika ada
	if config.SaveKey and config.ConfigData and config.ConfigData[title] then
		local savedKey = config.ConfigData[title]
		if isKeySupported(savedKey) then
			currentKey = savedKey
		else
			warn(string.format("[Keybind] Saved key '%s' tidak didukung, menggunakan default", savedKey))
		end
	end
	
	-- Buat UI elements
	local frame = createKeybindFrame(parent, title, countItem)
	local titleLabel = createTitleLabel(frame, title)
	local button = createKeybindButton(frame, currentKey)
	local hintLabel = createHintLabel(frame, "Click to change key")
	
	-- ========================================================================
	-- INTERNAL FUNCTIONS
	-- ========================================================================
	
	local function saveToConfig(key)
		if config.SaveKey and config.ConfigData and config.SaveFunction then
			config.ConfigData[title] = key
			config.SaveFunction()
		end
	end
	
	local function updateDisplay(key)
		currentKey = key
		button.Text = KeybindModule.FormatKeyName(key)
		button.BackgroundColor3 = DEFAULT_CONFIG.COLORS.BUTTON_BG
		saveToConfig(key)
		
		if hintVisible then
			hintLabel.Visible = false
			hintVisible = false
		end
	end
	
	local function stopBinding()
		if isBinding then
			isBinding = false
			if connection then
				connection:Disconnect()
				connection = nil
			end
			button.BackgroundColor3 = DEFAULT_CONFIG.COLORS.BUTTON_BG
			button.Text = KeybindModule.FormatKeyName(currentKey)
			
			if hintVisible then
				hintLabel.Visible = false
				hintVisible = false
			end
			
			-- Kembalikan fokus ke game
			UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None
		end
	end
	
	local function onBindingKeyPressed(key, input)
		if key ~= "" and key ~= "Unknown" then
			if isKeySupported(key) then
				updateDisplay(key)
				stopBinding()
				
				-- Beri feedback suara (opsional)
				if hasKeyboard() then
					-- Bisa tambahkan feedback suara atau getar
				end
			else
				-- Key tidak didukung
				button.Text = "Invalid!"
				hintLabel.Text = "Key not supported!"
				task.wait(0.5)
				button.Text = "..."
			end
		end
	end
	
	local function startBinding()
		if isBinding then return end
		
		isBinding = true
		button.Text = "..."
		button.BackgroundColor3 = DEFAULT_CONFIG.COLORS.BUTTON_BINDING_BG
		createClickEffect(button, Mouse.X, Mouse.Y)
		
		-- Tampilkan hint sesuai device
		if isMobile() then
			hintLabel.Text = "Use keyboard or tap here"
		else
			hintLabel.Text = "Press any supported key"
		end
		hintLabel.Visible = true
		hintVisible = true
		
		-- Untuk mobile, pastikan keyboard muncul jika perlu
		if isMobile() and hasKeyboard() then
			-- Trigger keyboard muncul (jika diperlukan)
			UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceShow
		end
		
		-- Setup listener untuk mode binding
		if connection then
			connection:Disconnect()
		end
		connection = setupKeyListener(onBindingKeyPressed, true)
	end
	
	-- ========================================================================
	-- EVENT HANDLERS
	-- ========================================================================
	
	-- Handle button click untuk memulai binding
	button.Activated:Connect(function()
		startBinding()
	end)
	
	-- Handle touch untuk mobile
	button.TouchTap:Connect(function()
		startBinding()
	end)
	
	-- Handle mouse enter/leave untuk hint
	button.MouseEnter:Connect(function()
		if not isBinding then
			if isMobile() then
				hintLabel.Text = "Tap to change key"
			else
				hintLabel.Text = "Click to change key"
			end
			hintLabel.Visible = true
			hintVisible = true
		end
	end)
	
	button.MouseLeave:Connect(function()
		if not isBinding then
			hintLabel.Visible = false
			hintVisible = false
		end
	end)
	
	-- Handle focus loss (jika user klik di luar)
	UserInputService.InputBegan:Connect(function(input)
		if isBinding then
			if input.UserInputType == Enum.UserInputType.MouseButton1 or 
			   input.UserInputType == Enum.UserInputType.Touch then
				-- Cek apakah klik di luar button
				local pos = Vector2.new(input.Position.X, input.Position.Y)
				local absPos = button.AbsolutePosition
				local absSize = button.AbsoluteSize
				
				if pos.X < absPos.X or pos.X > absPos.X + absSize.X or
				   pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
					stopBinding()
				end
			end
		end
	end)
	
	-- Listener global untuk mode normal
	globalConnection = setupKeyListener(function(key)
		if not isBinding and key == currentKey then
			local success, err = pcall(callback, currentKey)
			if not success then
				warn(string.format("[Keybind] Error in callback for '%s': %s", title, err))
			end
		end
	end, false)
	
	-- ========================================================================
	-- PUBLIC API
	-- ========================================================================
	
	local keybindFunctions = {}
	
	function keybindFunctions:Destroy()
		if globalConnection then
			globalConnection:Disconnect()
		end
		stopBinding()
		frame:Destroy()
	end
	
	function keybindFunctions:Set(key)
		if key and type(key) == "string" then
			if isKeySupported(key) then
				updateDisplay(key)
			else
				warn(string.format("[Keybind] Cannot set to '%s' - key not supported", key))
			end
		end
		return self
	end
	
	function keybindFunctions:Get()
		return currentKey
	end
	
	function keybindFunctions:SetCallback(newCallback)
		if newCallback and type(newCallback) == "function" then
			callback = newCallback
		end
		return self
	end
	
	function keybindFunctions:SetTitle(newTitle)
		if newTitle then
			title = newTitle
			titleLabel.Text = newTitle
			frame.Name = "KeybindFrame_" .. newTitle:gsub("%s+", "_")
		end
		return self
	end
	
	function keybindFunctions:SetEnabled(enabled)
		if enabled then
			if not globalConnection then
				globalConnection = setupKeyListener(function(key)
					if not isBinding and key == currentKey then
						pcall(callback, currentKey)
					end
				end, false)
			end
		else
			if globalConnection then
				globalConnection:Disconnect()
				globalConnection = nil
			end
		end
		return self
	end
	
	function keybindFunctions:GetSupportedKeys()
		return DEFAULT_CONFIG.SUPPORTED_KEYS
	end
	
	function keybindFunctions:StartBinding()
		startBinding()
		return self
	end
	
	function keybindFunctions:IsBinding()
		return isBinding
	end
	
	function keybindFunctions:StopBinding()
		stopBinding()
		return self
	end
	
	if updateCallback then
		updateCallback()
	end
	
	return keybindFunctions
end

-- Membuat standalone keybind
function KeybindModule.CreateStandaloneKeybind(config)
	config = config or {}
	local currentKey = config.Key or DEFAULT_CONFIG.KEY
	local callback = config.Callback or function() end
	local name = config.Name or "StandaloneKeybind"
	
	if not isKeySupported(currentKey) then
		warn(string.format("[StandaloneKeybind] Key '%s' tidak didukung, menggunakan default '%s'", currentKey, DEFAULT_CONFIG.KEY))
		currentKey = DEFAULT_CONFIG.KEY
	end
	
	local isEnabled = true
	local standaloneFunctions = {}
	
	local connection = setupKeyListener(function(key)
		if isEnabled and key == currentKey then
			local success, err = pcall(callback, currentKey)
			if not success then
				warn(string.format("[StandaloneKeybind] Error in callback for '%s': %s", name, err))
			end
		end
	end, false)
	
	function standaloneFunctions:SetKey(key)
		if key and type(key) == "string" then
			if isKeySupported(key) then
				currentKey = key
			else
				warn(string.format("[StandaloneKeybind] Cannot set to '%s' - key not supported", key))
			end
		end
		return self
	end
	
	function standaloneFunctions:GetKey()
		return currentKey
	end
	
	function standaloneFunctions:SetCallback(newCallback)
		if newCallback and type(newCallback) == "function" then
			callback = newCallback
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
	
	function standaloneFunctions:GetSupportedKeys()
		return DEFAULT_CONFIG.SUPPORTED_KEYS
	end
	
	function standaloneFunctions:Destroy()
		if connection then
			connection:Disconnect()
		end
	end
	
	return standaloneFunctions
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

function KeybindModule.GetSupportedKeys()
	return DEFAULT_CONFIG.SUPPORTED_KEYS
end

function KeybindModule.AddSupportedKey(key)
	if key and type(key) == "string" then
		if not isKeySupported(key) then
			table.insert(DEFAULT_CONFIG.SUPPORTED_KEYS, key)
			return true
		end
	end
	return false
end

function KeybindModule.IsMobile()
	return isMobile()
end

function KeybindModule.HasKeyboard()
	return hasKeyboard()
end

return KeybindModule
