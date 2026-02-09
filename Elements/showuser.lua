-- Elements/showuser.lua
-- Fungsi untuk membuat dan mengatur bagian user profile di UI

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Fungsi untuk mendapatkan thumbnail user
local function getUserThumbnail(userId, thumbnailType)
    local success, result = pcall(function()
        return Players:GetUserThumbnailAsync(userId, thumbnailType, Enum.ThumbnailSize.Size420x420)
    end)
    if success then
        return result
    end
    return "rbxassetid://0" -- Default jika gagal
end

-- Fungsi untuk membuat dan mengatur user profile
local function createUserProfile(parentFrame, showUser, uitransparent, color)
    if not showUser then return nil end
    
    local UserProfileContainer = Instance.new("Frame")
    UserProfileContainer.Name = "UserProfileContainer"
    UserProfileContainer.BackgroundTransparency = 1
    UserProfileContainer.BorderSizePixel = 0
    UserProfileContainer.Size = UDim2.new(1, 0, 1, -5)
    UserProfileContainer.Position = UDim2.new(0, 0, 0, 5)
    UserProfileContainer.Parent = parentFrame

    -- Avatar frame
    local AvatarFrame = Instance.new("Frame")
    AvatarFrame.Name = "AvatarFrame"
    AvatarFrame.AnchorPoint = Vector2.new(0, 0.5)
    AvatarFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    AvatarFrame.Size = UDim2.new(0, 32, 0, 32)
    AvatarFrame.Position = UDim2.new(0, 8, 0.5, 0)
    AvatarFrame.Parent = UserProfileContainer
    
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0) -- Lingkaran sempurna
    AvatarCorner.Parent = AvatarFrame
    
    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name = "AvatarImage"
    AvatarImage.AnchorPoint = Vector2.new(0.5, 0.5)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Size = UDim2.new(1, -4, 1, -4)
    AvatarImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    AvatarImage.Parent = AvatarFrame

    -- Status indicator
    local StatusIndicator = Instance.new("Frame")
    StatusIndicator.Name = "StatusIndicator"
    StatusIndicator.AnchorPoint = Vector2.new(1, 1)
    StatusIndicator.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    StatusIndicator.BorderColor3 = Color3.fromRGB(20, 20, 20)
    StatusIndicator.BorderSizePixel = 2
    StatusIndicator.Size = UDim2.new(0, 8, 0, 8)
    StatusIndicator.Position = UDim2.new(1, -2, 1, -2)
    StatusIndicator.Visible = false
    StatusIndicator.Parent = AvatarFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(1, 0)
    StatusCorner.Parent = StatusIndicator

    -- User info frame
    local UserInfoFrame = Instance.new("Frame")
    UserInfoFrame.Name = "UserInfoFrame"
    UserInfoFrame.AnchorPoint = Vector2.new(0, 0.5)
    UserInfoFrame.BackgroundTransparency = 1
    UserInfoFrame.Size = UDim2.new(1, -48, 0, 32)
    UserInfoFrame.Position = UDim2.new(0, 48, 0.5, 0)
    UserInfoFrame.Parent = UserProfileContainer
    
    local DisplayNameLabel = Instance.new("TextLabel")
    DisplayNameLabel.Name = "DisplayNameLabel"
    DisplayNameLabel.Font = Enum.Font.GothamBold
    DisplayNameLabel.Text = "Loading..."
    DisplayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DisplayNameLabel.TextSize = 12
    DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    DisplayNameLabel.TextYAlignment = Enum.TextYAlignment.Bottom
    DisplayNameLabel.BackgroundTransparency = 1
    DisplayNameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    DisplayNameLabel.Position = UDim2.new(0, 0, 0, 0)
    DisplayNameLabel.Parent = UserInfoFrame
    
    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.Font = Enum.Font.Gotham
    UsernameLabel.Text = "@username"
    UsernameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    UsernameLabel.TextSize = 10
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextYAlignment = Enum.TextYAlignment.Top
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    UsernameLabel.Position = UDim2.new(0, 0, 0.6, 0)
    UsernameLabel.Parent = UserInfoFrame

    -- Stats container (jika diperlukan)
    local StatsContainer = Instance.new("Frame")
    StatsContainer.Name = "StatsContainer"
    StatsContainer.AnchorPoint = Vector2.new(0, 0.5)
    StatsContainer.BackgroundTransparency = 1
    StatsContainer.Visible = false
    StatsContainer.Size = UDim2.new(1, -48, 0, 16)
    StatsContainer.Position = UDim2.new(0, 48, 0.5, 8)
    StatsContainer.Parent = UserProfileContainer

    -- Fungsi untuk update user data
    local function updateUserData()
        local localPlayer = Players.LocalPlayer
        local userId = localPlayer.UserId
        
        -- Update display name dan username
        DisplayNameLabel.Text = localPlayer.DisplayName
        UsernameLabel.Text = "@" .. localPlayer.Name
        
        -- Update avatar thumbnail
        local avatarUrl = getUserThumbnail(userId, Enum.ThumbnailType.HeadShot)
        AvatarImage.Image = avatarUrl
        
        -- Update status indicator berdasarkan friendship status
        local function updateFriendshipStatus()
            local friendStatus = localPlayer:GetFriendStatus(localPlayer)
            StatusIndicator.Visible = true
            
            if friendStatus == Enum.FriendStatus.Friend then
                StatusIndicator.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- Online
            elseif friendStatus == Enum.FriendStatus.NotFriend then
                StatusIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 0) -- Offline
            else
                StatusIndicator.BackgroundColor3 = Color3.fromRGB(150, 150, 150) -- Unknown
            end
        end
        
        -- Coba update friendship status
        pcall(updateFriendshipStatus)
        
        -- Update stats jika game memiliki leaderstats
        if localPlayer:FindFirstChild("leaderstats") then
            StatsContainer.Visible = true
            UserInfoFrame.Size = UDim2.new(1, -48, 0, 20)
            UserInfoFrame.Position = UDim2.new(0, 48, 0.5, -4)
            
            -- Clear existing stats
            for _, child in pairs(StatsContainer:GetChildren()) do
                if child.Name ~= "UIListLayout" then
                    child:Destroy()
                end
            end
            
            -- Add UIListLayout for stats
            local StatsLayout = Instance.new("UIListLayout")
            StatsLayout.FillDirection = Enum.FillDirection.Horizontal
            StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            StatsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            StatsLayout.Padding = UDim.new(0, 5)
            StatsLayout.Parent = StatsContainer
            
            -- Add stats
            for _, stat in pairs(localPlayer.leaderstats:GetChildren()) do
                if stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("StringValue") then
                    local StatFrame = Instance.new("Frame")
                    StatFrame.BackgroundTransparency = 1
                    StatFrame.Size = UDim2.new(0, 0, 1, 0)
                    StatFrame.Parent = StatsContainer
                    
                    local StatName = Instance.new("TextLabel")
                    StatName.Font = Enum.Font.Gotham
                    StatName.Text = stat.Name .. ": "
                    StatName.TextColor3 = Color3.fromRGB(150, 150, 150)
                    StatName.TextSize = 9
                    StatName.TextXAlignment = Enum.TextXAlignment.Left
                    StatName.BackgroundTransparency = 1
                    StatName.Size = UDim2.new(0, 0, 1, 0)
                    StatName.Parent = StatFrame
                    
                    local StatValue = Instance.new("TextLabel")
                    StatValue.Font = Enum.Font.GothamBold
                    StatValue.Text = tostring(stat.Value)
                    StatValue.TextColor3 = color or Color3.fromRGB(255, 255, 255)
                    StatValue.TextSize = 9
                    StatValue.TextXAlignment = Enum.TextXAlignment.Left
                    StatValue.BackgroundTransparency = 1
                    StatValue.Size = UDim2.new(0, 0, 1, 0)
                    StatValue.Position = UDim2.new(0, StatName.TextBounds.X, 0, 0)
                    StatValue.Parent = StatFrame
                    
                    StatFrame.Size = UDim2.new(0, StatName.TextBounds.X + StatValue.TextBounds.X, 1, 0)
                    
                    -- Update stat value changes
                    stat.Changed:Connect(function()
                        StatValue.Text = tostring(stat.Value)
                        StatFrame.Size = UDim2.new(0, StatName.TextBounds.X + StatValue.TextBounds.X, 1, 0)
                    end)
                end
            end
        end
    end

    -- Update user data secara asinkron
    spawn(updateUserData)

    -- Tambahkan listener untuk avatar changes
    Players.PlayerRemoving:Connect(function(player)
        if player == Players.LocalPlayer then
            -- Reset jika player keluar
            DisplayNameLabel.Text = "Player Left"
            UsernameLabel.Text = "@disconnected"
            AvatarImage.Image = "rbxassetid://0"
            StatusIndicator.Visible = false
        end
    end)

    -- Fungsi untuk refresh user data
    local function refreshUserData()
        updateUserData()
    end

    -- Tambahkan fungsi untuk mengubah avatar size
    local function setAvatarSize(size)
        if size and size > 0 then
            AvatarFrame.Size = UDim2.new(0, size, 0, size)
            AvatarImage.Size = UDim2.new(1, -4, 1, -4)
            StatusIndicator.Size = UDim2.new(0, math.max(6, size/5), 0, math.max(6, size/5))
            StatusIndicator.Position = UDim2.new(1, -2, 1, -2)
            
            UserInfoFrame.Position = UDim2.new(0, size + 16, 0.5, 0)
            StatsContainer.Position = UDim2.new(0, size + 16, 0.5, 8)
        end
    end

    -- Tambahkan fungsi untuk toggle stats visibility
    local function toggleStats(visible)
        StatsContainer.Visible = visible
        if visible then
            UserInfoFrame.Size = UDim2.new(1, -48, 0, 20)
            UserInfoFrame.Position = UDim2.new(0, 48, 0.5, -4)
        else
            UserInfoFrame.Size = UDim2.new(1, -48, 0, 32)
            UserInfoFrame.Position = UDim2.new(0, 48, 0.5, 0)
        end
    end

    -- Tambahkan fungsi untuk mengubah warna status indicator
    local function setStatusColor(color3)
        if color3 then
            StatusIndicator.BackgroundColor3 = color3
        end
    end

    -- Kembalikan kontrol functions
    return {
        Refresh = refreshUserData,
        SetAvatarSize = setAvatarSize,
        ToggleStats = toggleStats,
        SetStatusColor = setStatusColor,
        Container = UserProfileContainer,
        Avatar = AvatarImage,
        DisplayName = DisplayNameLabel,
        Username = UsernameLabel
    }
end

-- Fungsi untuk membuat user profile yang lebih simple (tanpa stats)
local function createSimpleUserProfile(parentFrame, showUser, uitransparent, color)
    if not showUser then return nil end
    
    local UserProfileContainer = Instance.new("Frame")
    UserProfileContainer.Name = "UserProfileContainer"
    UserProfileContainer.BackgroundTransparency = 1
    UserProfileContainer.BorderSizePixel = 0
    UserProfileContainer.Size = UDim2.new(1, 0, 1, -10)
    UserProfileContainer.Position = UDim2.new(0, 0, 0, 5)
    UserProfileContainer.Parent = parentFrame

    -- Avatar frame
    local AvatarFrame = Instance.new("Frame")
    AvatarFrame.Name = "AvatarFrame"
    AvatarFrame.AnchorPoint = Vector2.new(0, 0.5)
    AvatarFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    AvatarFrame.Size = UDim2.new(0, 30, 0, 30)
    AvatarFrame.Position = UDim2.new(0, 5, 0.5, 0)
    AvatarFrame.Parent = UserProfileContainer
    
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarFrame
    
    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name = "AvatarImage"
    AvatarImage.AnchorPoint = Vector2.new(0.5, 0.5)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Size = UDim2.new(1, -4, 1, -4)
    AvatarImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    AvatarImage.Parent = AvatarFrame

    -- User info
    local UserInfoFrame = Instance.new("Frame")
    UserInfoFrame.Name = "UserInfoFrame"
    UserInfoFrame.AnchorPoint = Vector2.new(0, 0.5)
    UserInfoFrame.BackgroundTransparency = 1
    UserInfoFrame.Size = UDim2.new(1, -40, 0, 30)
    UserInfoFrame.Position = UDim2.new(0, 40, 0.5, 0)
    UserInfoFrame.Parent = UserProfileContainer
    
    local DisplayNameLabel = Instance.new("TextLabel")
    DisplayNameLabel.Name = "DisplayNameLabel"
    DisplayNameLabel.Font = Enum.Font.GothamBold
    DisplayNameLabel.Text = "Loading..."
    DisplayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DisplayNameLabel.TextSize = 12
    DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    DisplayNameLabel.TextYAlignment = Enum.TextYAlignment.Center
    DisplayNameLabel.BackgroundTransparency = 1
    DisplayNameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    DisplayNameLabel.Position = UDim2.new(0, 0, 0, 0)
    DisplayNameLabel.Parent = UserInfoFrame
    
    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.Font = Enum.Font.Gotham
    UsernameLabel.Text = "@username"
    UsernameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    UsernameLabel.TextSize = 10
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextYAlignment = Enum.TextYAlignment.Center
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    UsernameLabel.Position = UDim2.new(0, 0, 0.6, 0)
    UsernameLabel.Parent = UserInfoFrame

    -- Update user data
    spawn(function()
        local localPlayer = Players.LocalPlayer
        local userId = localPlayer.UserId
        
        DisplayNameLabel.Text = localPlayer.DisplayName
        UsernameLabel.Text = "@" .. localPlayer.Name
        
        local avatarUrl = getUserThumbnail(userId, Enum.ThumbnailType.HeadShot)
        AvatarImage.Image = avatarUrl
    end)

    return {
        Container = UserProfileContainer,
        Avatar = AvatarImage,
        DisplayName = DisplayNameLabel,
        Username = UsernameLabel
    }
end

-- Export fungsi-fungsi
return {
    CreateUserProfile = createUserProfile,
    CreateSimpleUserProfile = createSimpleUserProfile,
    GetUserThumbnail = getUserThumbnail
}
