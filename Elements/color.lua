local color = {

	-- Basic
	["Dark"] = Color3.fromRGB(20, 20, 25),
	["Light"] = Color3.fromRGB(230, 230, 230),

	-- Color Themes
	["Rose"] = Color3.fromRGB(199, 21, 133),
	["Plant"] = Color3.fromRGB(34, 139, 34),
	["Red"] = Color3.fromRGB(183, 28, 28),
	["Indigo"] = Color3.fromRGB(63, 81, 181),
	["Sky"] = Color3.fromRGB(0, 191, 255),
	["Violet"] = Color3.fromRGB(138, 43, 226),
	["Amber"] = Color3.fromRGB(255, 140, 0),
	["Emerald"] = Color3.fromRGB(0, 150, 100),
	["Midnight"] = Color3.fromRGB(25, 42, 86),
	["Crimson"] = Color3.fromRGB(220, 20, 60),

	-- Special
	["Monokai Pro"] = Color3.fromRGB(255, 143, 96),
	["Cotton Candy"] = Color3.fromRGB(255, 105, 180),
	["Mellow"] = Color3.fromRGB(90, 70, 50),

	-- Gradient Style (untuk UIGradient, bukan Color3 biasa)
	["Rainbow"] = {
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 165, 0)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 127, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 0, 255)),
		})
	}

}

return color
