-- Elements/showuser.lua
-- Fungsi untuk membuat dan mengatur bagian user profile di UI

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Cache untuk thumbnail agar tidak perlu request berulang
local ThumbnailCache = {}
local DEFAULT_THUMBNAIL = "rbxassetid://0"

-- Fungsi untuk mendapatkan thumbnail user dengan caching
local function getUserThumbnail(userId, thumbnailType, size)
    local cacheKey = userId .. "_" .. tostring(thumbnailType) .. "_" .. tostring(size)
    
    -- Cek cache dulu
    if ThumbnailCache[cacheKey] then
        return ThumbnailCache[cacheKey]
    end
    
    -- Jika tidak ada di cache, request baru
    local success, result = pcall(function()
        local thumbnailSize = size or Enum.ThumbnailSize.Size420x420
        return Players:GetUserThumbnailAsync(userId, thumbnailType, thumbnailSize)
    end)
    
    if success and result ~= DEFAULT_THUMBNAIL then
        ThumbnailCache[cacheKey] = result
        return result
    end
    
    return DEFAULT_THUMBNAIL
end

-- Class untuk mengelola user profile
local UserProfile = {}
UserProfile.__index = UserProfile

function UserProfile.new(parentFrame, config)
    config = config or {}
    local showUser = config.showUser or false
    local showStats = config.showStats or false
    local avatarSize = config.avatarSize or 32
    local statusIndicator = config.statusIndicator or false
    local textColor = config.textColor or Color3.fromRGB(255, 255, 255)
    local secondaryColor = config.secondaryColor or Color3.fromRGB(180, 180, 180)
    local backgroundColor = config.backgroundColor or Color3.fromRGB(40, 40, 40)
    
    if not showUser then return nil end
    
    local self = setmetatable({}, UserProfile)
    
    self._config = config
    self._connections = {}
    self._stats = {}
    self._isDestroyed = false
    
    -- Container utama
    self.Container = Instance.new("Frame")
    self.Container.Name = "UserProfileContainer"
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.Size = UDim2.new(1, 0, 1, -5)
    self.Container.Position = UDim2.new(0, 0, 0, 5)
    self.Container.Parent = parentFrame
    
    -- Avatar frame dengan efek hover
    self.AvatarFrame = Instance.new("ImageButton")
    self.AvatarFrame.Name = "AvatarFrame"
    self.AvatarFrame.AnchorPoint = Vector2.new(0, 0.5)
    self.AvatarFrame.BackgroundColor3 = backgroundColor
    self.AvatarFrame.Size = UDim2.new(0, avatarSize, 0, avatarSize)
    self.AvatarFrame.Position = UDim2.new(0, 8, 0.5, 0)
    self.AvatarFrame.AutoButtonColor = false
    self.AvatarFrame.Parent = self.Container
    
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = self.AvatarFrame
    
    -- Border untuk avatar
    local AvatarBorder = Instance.new("UIStroke")
    AvatarBorder.Color = Color3.fromRGB(60, 60, 60)
    AvatarBorder.Thickness = 2
    AvatarBorder.Parent = self.AvatarFrame
    
    self.AvatarImage = Instance.new("ImageLabel")
    self.AvatarImage.Name = "AvatarImage"
    self.AvatarImage.AnchorPoint = Vector2.new(0.5, 0.5)
    self.AvatarImage.BackgroundTransparency = 1
    self.AvatarImage.Size = UDim2.new(1, -4, 1, -4)
    self.AvatarImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.AvatarImage.Parent = self.AvatarFrame
    
    local AvatarImageCorner = Instance.new("UICorner")
    AvatarImageCorner.CornerRadius = UDim.new(1, 0)
    AvatarImageCorner.Parent = self.AvatarImage
    
    -- Status indicator
    if statusIndicator then
        self.StatusIndicator = Instance.new("Frame")
        self.StatusIndicator.Name = "StatusIndicator"
        self.StatusIndicator.AnchorPoint = Vector2.new(1, 1)
        self.StatusIndicator.BackgroundColor3 = Color3.fromRGB(76, 175, 80) -- Green
        self.StatusIndicator.BorderColor3 = Color3.fromRGB(20, 20, 20)
        self.StatusIndicator.BorderSizePixel = 2
        self.StatusIndicator.Size = UDim2.new(0, math.max(8, avatarSize/5), 0, math.max(8, avatarSize/5))
        self.StatusIndicator.Position = UDim2.new(1, -2, 1, -2)
        
        local StatusCorner = Instance.new("UICorner")
        StatusCorner.CornerRadius = UDim.new(1, 0)
        StatusCorner.Parent = self.StatusIndicator
        
        self.StatusIndicator.Parent = self.AvatarFrame
    end
    
    -- User info frame
    self.UserInfoFrame = Instance.new("Frame")
    self.UserInfoFrame.Name = "UserInfoFrame"
    self.UserInfoFrame.AnchorPoint = Vector2.new(0, 0.5)
    self.UserInfoFrame.BackgroundTransparency = 1
    self.UserInfoFrame.Size = UDim2.new(1, -(avatarSize + 16), 0, showStats and 20 or 32)
    self.UserInfoFrame.Position = UDim2.new(0, avatarSize + 16, 0.5, showStats and -4 or 0)
    self.UserInfoFrame.Parent = self.Container
    
    -- Display name
    self.DisplayNameLabel = Instance.new("TextLabel")
    self.DisplayNameLabel.Name = "DisplayNameLabel"
    self.DisplayNameLabel.Font = Enum.Font.GothamBold
    self.DisplayNameLabel.Text = "Loading..."
    self.DisplayNameLabel.TextColor3 = textColor
    self.DisplayNameLabel.TextSize = 12
    self.DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.DisplayNameLabel.TextYAlignment = Enum.TextYAlignment.Bottom
    self.DisplayNameLabel.BackgroundTransparency = 1
    self.DisplayNameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    self.DisplayNameLabel.Position = UDim2.new(0, 0, 0, 0)
    self.DisplayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    self.DisplayNameLabel.Parent = self.UserInfoFrame
    
    -- Username
    self.UsernameLabel = Instance.new("TextLabel")
    self.UsernameLabel.Name = "UsernameLabel"
    self.UsernameLabel.Font = Enum.Font.Gotham
    self.UsernameLabel.Text = "@username"
    self.UsernameLabel.TextColor3 = secondaryColor
    self.UsernameLabel.TextSize = 10
    self.UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.UsernameLabel.TextYAlignment = Enum.TextYAlignment.Top
    self.UsernameLabel.BackgroundTransparency = 1
    self.UsernameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    self.UsernameLabel.Position = UDim2.new(0, 0, 0.6, 0)
    self.UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    self.UsernameLabel.Parent = self.UserInfoFrame
    
    -- Stats container
    if showStats then
        self.StatsContainer = Instance.new("Frame")
        self.StatsContainer.Name = "StatsContainer"
        self.StatsContainer.AnchorPoint = Vector2.new(0, 0.5)
        self.StatsContainer.BackgroundTransparency = 1
        self.StatsContainer.Size = UDim2.new(1, -(avatarSize + 16), 0, 16)
        self.StatsContainer.Position = UDim2.new(0, avatarSize + 16, 0.5, 8)
        self.StatsContainer.Parent = self.Container
        
        local StatsLayout = Instance.new("UIListLayout")
        StatsLayout.FillDirection = Enum.FillDirection.Horizontal
        StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        StatsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        StatsLayout.Padding = UDim.new(0, 8)
        StatsLayout.Parent = self.StatsContainer
    end
    
    -- Animasi hover untuk avatar
    self:_setupHoverEffects()
    
    -- Load data user
    self:_loadUserData()
    
    return self
end

function UserProfile:_setupHoverEffects()
    table.insert(self._connections, self.AvatarFrame.MouseEnter:Connect(function()
        if self._isDestroyed then return end
        self:_tweenAvatarScale(1.05)
    end))
    
    table.insert(self._connections, self.AvatarFrame.MouseLeave:Connect(function()
        if self._isDestroyed then return end
        self:_tweenAvatarScale(1)
    end))
    
    table.insert(self._connections, self.AvatarFrame.MouseButton1Click:Connect(function()
        if self._isDestroyed then return end
        self:_onAvatarClicked()
    end))
end

function UserProfile:_tweenAvatarScale(scale)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(self.AvatarFrame, tweenInfo, {
        Size = UDim2.new(0, self._config.avatarSize * scale, 0, self._config.avatarSize * scale)
    })
    tween:Play()
end

function UserProfile:_onAvatarClicked()
    local localPlayer = Players.LocalPlayer
    if localPlayer then
        -- Buka profile player di browser
        local userId = tostring(localPlayer.UserId)
        local profileUrl = "https://www.roblox.com/users/" .. userId .. "/profile"
        
        pcall(function()
            game:GetService("GuiService"):OpenBrowserWindow(profileUrl)
        end)
    end
end

function UserProfile:_loadUserData()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        -- Coba lagi nanti jika player belum tersedia
        delay(1, function()
            if not self._isDestroyed then
                self:_loadUserData()
            end
        end)
        return
    end
    
    -- Update display name dan username
    self.DisplayNameLabel.Text = localPlayer.DisplayName
    self.UsernameLabel.Text = "@" .. localPlayer.Name
    
    -- Update avatar
    self:UpdateAvatar()
    
    -- Setup status indicator
    if self.StatusIndicator then
        self:_updateUserStatus()
    end
    
    -- Setup stats
    if self.StatsContainer then
        self:_setupStats()
    end
    
    -- Listen untuk perubahan
    self:_setupListeners()
end

function UserProfile:_setupListeners()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    
    -- Listen untuk perubahan leaderstats
    local leaderstats = localPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in pairs(leaderstats:GetChildren()) do
            if stat:IsA("ValueBase") then
                table.insert(self._connections, stat.Changed:Connect(function()
                    if not self._isDestroyed then
                        self:_updateStat(stat.Name, stat.Value)
                    end
                end))
            end
        end
    end
    
    -- Listen untuk player leaving
    table.insert(self._connections, Players.PlayerRemoving:Connect(function(player)
        if player == localPlayer then
            self:Destroy()
        end
    end))
end

function UserProfile:_setupStats()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    
    local leaderstats = localPlayer:FindFirstChild("leaderstats")
    if not leaderstats then return end
    
    -- Clear existing stats UI
    for _, child in pairs(self.StatsContainer:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    
    -- Create stats UI
    for _, stat in pairs(leaderstats:GetChildren()) do
        if stat:IsA("ValueBase") then
            self:_createStatUI(stat.Name, stat.Value)
            self._stats[stat.Name] = stat.Value
        end
    end
end

function UserProfile:_createStatUI(statName, statValue)
    local StatFrame = Instance.new("Frame")
    StatFrame.BackgroundTransparency = 1
    StatFrame.Size = UDim2.new(0, 0, 1, 0)
    StatFrame.LayoutOrder = #self.StatsContainer:GetChildren()
    StatFrame.Parent = self.StatsContainer
    
    local StatIcon = Instance.new("TextLabel")
    StatIcon.Font = Enum.Font.GothamBold
    StatIcon.Text = "•"
    StatIcon.TextColor3 = self._config.textColor
    StatIcon.TextSize = 10
    StatIcon.TextXAlignment = Enum.TextXAlignment.Left
    StatIcon.BackgroundTransparency = 1
    StatIcon.Size = UDim2.new(0, 10, 1, 0)
    StatIcon.Parent = StatFrame
    
    local StatNameLabel = Instance.new("TextLabel")
    StatNameLabel.Font = Enum.Font.Gotham
    StatNameLabel.Text = statName .. ": "
    StatNameLabel.TextColor3 = self._config.secondaryColor
    StatNameLabel.TextSize = 9
    StatNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatNameLabel.BackgroundTransparency = 1
    StatNameLabel.Size = UDim2.new(0, 0, 1, 0)
    StatNameLabel.Position = UDim2.new(0, 12, 0, 0)
    StatNameLabel.Parent = StatFrame
    
    local StatValueLabel = Instance.new("TextLabel")
    StatValueLabel.Font = Enum.Font.GothamBold
    StatValueLabel.Text = tostring(statValue)
    StatValueLabel.TextColor3 = self._config.textColor
    StatValueLabel.TextSize = 9
    StatValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatValueLabel.BackgroundTransparency = 1
    StatValueLabel.Size = UDim2.new(0, 0, 1, 0)
    StatValueLabel.Parent = StatFrame
    
    -- Update size setelah text di-render
    task.defer(function()
        if self._isDestroyed then return end
        
        local nameWidth = StatNameLabel.TextBounds.X
        local valueWidth = StatValueLabel.TextBounds.X
        
        StatValueLabel.Position = UDim2.new(0, 12 + nameWidth, 0, 0)
        StatValueLabel.Size = UDim2.new(0, valueWidth, 1, 0)
        StatFrame.Size = UDim2.new(0, 12 + nameWidth + valueWidth, 1, 0)
    end)
end

function UserProfile:_updateStat(statName, value)
    if self._stats[statName] == value then return end
    self._stats[statName] = value
    
    -- Cari dan update UI stat
    for _, child in pairs(self.StatsContainer:GetChildren()) do
        if not child:IsA("UIListLayout") then
            local statNameLabel = child:FindFirstChildWhichIsA("TextLabel", true)
            if statNameLabel and string.find(statNameLabel.Text, statName) then
                local statValueLabel = statNameLabel.Parent:FindFirstChildWhichIsA("TextLabel", {Name = ""})
                if statValueLabel then
                    statValueLabel.Text = tostring(value)
                    
                    -- Update size
                    task.defer(function()
                        if self._isDestroyed then return end
                        
                        local nameWidth = statNameLabel.TextBounds.X
                        local valueWidth = statValueLabel.TextBounds.X
                        
                        statValueLabel.Size = UDim2.new(0, valueWidth, 1, 0)
                        child.Size = UDim2.new(0, 12 + nameWidth + valueWidth, 1, 0)
                    end)
                end
                break
            end
        end
    end
end

function UserProfile:_updateUserStatus()
    if not self.StatusIndicator then return end
    
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    
    -- Cek status berdasarkan berbagai faktor
    local function determineStatus()
        -- Default: online
        local status = "online"
        local color = Color3.fromRGB(76, 175, 80) -- Green
        
        -- Cek jika game memiliki sistem friendship
        pcall(function()
            local friendStatus = localPlayer:GetFriendStatus(localPlayer)
            if friendStatus == Enum.FriendStatus.NotFriend then
                status = "offline"
                color = Color3.fromRGB(158, 158, 158) -- Gray
            elseif friendStatus == Enum.FriendStatus.Unknown then
                status = "away"
                color = Color3.fromRGB(255, 193, 7) -- Amber
            end
        end)
        
        return status, color
    end
    
    local status, color = determineStatus()
    self.StatusIndicator.BackgroundColor3 = color
    
    -- Update secara berkala
    table.insert(self._connections, RunService.Heartbeat:Connect(function()
        if self._isDestroyed then return end
        local newStatus, newColor = determineStatus()
        if self.StatusIndicator.BackgroundColor3 ~= newColor then
            self.StatusIndicator.BackgroundColor3 = newColor
        end
    end))
end

-- Public methods
function UserProfile:UpdateAvatar()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    
    local userId = localPlayer.UserId
    local avatarUrl = getUserThumbnail(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    self.AvatarImage.Image = avatarUrl
end

function UserProfile:SetAvatarSize(size)
    if self._isDestroyed then return end
    
    self._config.avatarSize = size
    self.AvatarFrame.Size = UDim2.new(0, size, 0, size)
    
    if self.StatusIndicator then
        self.StatusIndicator.Size = UDim2.new(0, math.max(8, size/5), 0, math.max(8, size/5))
    end
    
    self.UserInfoFrame.Position = UDim2.new(0, size + 16, 0.5, self._config.showStats and -4 or 0)
    
    if self.StatsContainer then
        self.StatsContainer.Position = UDim2.new(0, size + 16, 0.5, 8)
    end
end

function UserProfile:SetColors(primary, secondary, background)
    if self._isDestroyed then return end
    
    if primary then
        self._config.textColor = primary
        self.DisplayNameLabel.TextColor3 = primary
    end
    
    if secondary then
        self._config.secondaryColor = secondary
        self.UsernameLabel.TextColor3 = secondary
    end
    
    if background then
        self._config.backgroundColor = background
        self.AvatarFrame.BackgroundColor3 = background
    end
end

function UserProfile:ToggleStats(show)
    if self._isDestroyed or not self.StatsContainer then return end
    
    self._config.showStats = show
    self.StatsContainer.Visible = show
    
    if show then
        self.UserInfoFrame.Size = UDim2.new(1, -(self._config.avatarSize + 16), 0, 20)
        self.UserInfoFrame.Position = UDim2.new(0, self._config.avatarSize + 16, 0.5, -4)
    else
        self.UserInfoFrame.Size = UDim2.new(1, -(self._config.avatarSize + 16), 0, 32)
        self.UserInfoFrame.Position = UDim2.new(0, self._config.avatarSize + 16, 0.5, 0)
    end
end

function UserProfile:Refresh()
    if self._isDestroyed then return end
    
    self:_loadUserData()
end

function UserProfile:Destroy()
    if self._isDestroyed then return end
    
    self._isDestroyed = true
    
    -- Putuskan semua koneksi
    for _, connection in ipairs(self._connections) do
        connection:Disconnect()
    end
    
    -- Hapus instance
    if self.Container and self.Container.Parent then
        self.Container:Destroy()
    end
    
    -- Clear references
    setmetatable(self, nil)
    for k in pairs(self) do
        self[k] = nil
    end
end

-- Fungsi factory untuk membuat user profile
local function createUserProfile(parentFrame, config)
    return UserProfile.new(parentFrame, config)
end

-- Simple version (legacy support)
local function createSimpleUserProfile(parentFrame, showUser, uitransparent, color)
    if not showUser then return nil end
    
    local config = {
        showUser = true,
        showStats = false,
        avatarSize = 30,
        statusIndicator = false,
        textColor = color or Color3.fromRGB(255, 255, 255)
    }
    
    return UserProfile.new(parentFrame, config)
end

-- Export
return {
    CreateUserProfile = createUserProfile,
    CreateSimpleUserProfile = createSimpleUserProfile,
    GetUserThumbnail = getUserThumbnail,
    
    -- New OOP interface
    UserProfile = UserProfile,
    
    -- Utility functions
    ClearThumbnailCache = function()
        ThumbnailCache = {}
    end
}
