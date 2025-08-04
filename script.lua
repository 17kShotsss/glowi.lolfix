    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    local Workspace = game:GetService("Workspace")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer

    -- Audio assets
    local SOUND_LOADING = 88064123988424
    local SOUND_BUTTON = 9083627113
    local SOUND_TYPE = 9120300060
    local SOUND_TARGET_SET = 18908611063
    local SOUND_FLING = 6586979979

    -- Helper to play a sound
    local function playSound(id, parent, volume)
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://"..tostring(id)
        s.Volume = volume or 1
        s.Parent = parent or Workspace
        s:Play()
        s.Ended:Connect(function() s:Destroy() end)
        return s
    end

    -- UI helpers
    local function createButton(parent, text, pos, size, color)
        local btn = Instance.new("TextButton")
        btn.Size = size or UDim2.new(0, 120, 0, 32)
        btn.Position = pos
        btn.BackgroundColor3 = color or Color3.fromRGB(45, 48, 65) -- Cleaner default background
        btn.Text = text
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.AutoButtonColor = false -- Disable default color changes to allow custom tweens
        btn.Parent = parent
        local uic = Instance.new("UICorner", btn)
        uic.CornerRadius = UDim.new(0, 8)
        -- Button click effect
        btn.MouseButton1Click:Connect(function()
            playSound(SOUND_BUTTON, btn, 0.7)
            TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(70, 100, 180)}):Play() -- More harmonious click color
            task.wait(0.09)
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color or Color3.fromRGB(45, 48, 65)}):Play() -- Return to new default
            -- Button pulse animation
            TweenService:Create(btn, TweenInfo.new(0.08), {Size = btn.Size + UDim2.new(0, 8, 0, 4)}):Play()
            wait(0.09)
            TweenService:Create(btn, TweenInfo.new(0.15), {Size = size or UDim2.new(0, 120, 0, 32)}):Play()
        end)
        return btn
    end

    local function createLabel(parent, text, pos, size, align, color)
        local lbl = Instance.new("TextLabel")
        lbl.Size = size or UDim2.new(1, 0, 0, 32)
        lbl.Position = pos or UDim2.new(0,0,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color or Color3.new(1,1,1)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 18
        lbl.TextXAlignment = align or Enum.TextXAlignment.Left
        lbl.Parent = parent
        return lbl
    end

    -- Modern color palette
    local COLOR_BG = Color3.fromRGB(22, 24, 36)
    local COLOR_PANEL = Color3.fromRGB(32, 34, 48)
    local COLOR_ACCENT = Color3.fromRGB(120, 90, 255) -- purple accent
    local COLOR_ACCENT2 = Color3.fromRGB(80, 220, 220) -- teal accent
    local COLOR_BTN = Color3.fromRGB(38, 40, 60)
    local COLOR_BTN_HOVER = Color3.fromRGB(80, 120, 255)
    local COLOR_BTN_TEXT = Color3.fromRGB(230, 240, 255)
    local COLOR_STATUS = Color3.fromRGB(180,255,180)

    -- Main GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "Fling GUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main frame (Windows 11/Fluent style)
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 540, 0, 340)
    frame.Position = UDim2.new(0.5, -270, 0.5, -170)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0
    frame.Active = true
    frame.Draggable = true
    local uic = Instance.new("UICorner", frame)
    uic.CornerRadius = UDim.new(0, 18)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Thickness = 2.5
    stroke.Transparency = 0

    -- Sidebar (left panel, fully visible, no overlay)
    local sidebar = Instance.new("Frame", frame)
    sidebar.Size = UDim2.new(0, 150, 1, 0)
    sidebar.Position = UDim2.new(0, 0, 0, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
    sidebar.BackgroundTransparency = 0
    sidebar.ZIndex = 2
    local sidebarUIC = Instance.new("UICorner", sidebar)
    sidebarUIC.CornerRadius = UDim.new(0, 18)
    local sidebarStroke = Instance.new("UIStroke", sidebar)
    sidebarStroke.Color = Color3.fromRGB(255,255,255)
    sidebarStroke.Thickness = 1.5
    sidebarStroke.Transparency = 0.2

    -- Sidebar: Avatar (centered vertically, a bit up, then display name, then username)
    local sidebarHeight = sidebar.AbsoluteSize.Y
    local avatarSize = 80
    local avatarY = math.floor(sidebarHeight * 0.22)
    local sidebarAvatar = Instance.new("ImageLabel", sidebar)
    sidebarAvatar.Size = UDim2.new(0, avatarSize, 0, avatarSize)
    sidebarAvatar.Position = UDim2.new(0.5, -avatarSize/2, 0, avatarY)
    sidebarAvatar.BackgroundTransparency = 1
    sidebarAvatar.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png", LocalPlayer.UserId)
    sidebarAvatar.ScaleType = Enum.ScaleType.Fit
    sidebarAvatar.ClipsDescendants = true
    sidebarAvatar.ZIndex = 2
    local avatarUIC = Instance.new("UICorner", sidebarAvatar)
    avatarUIC.CornerRadius = UDim.new(1, 0)
    if sidebarAvatar:FindFirstChildOfClass("UIStroke") then
        sidebarAvatar:FindFirstChildOfClass("UIStroke"):Destroy()
    end

    -- Sidebar: Display Name (under avatar)
    local displayNameLabel = Instance.new("TextLabel", sidebar)
    displayNameLabel.Size = UDim2.new(1, -16, 0, 26)
    displayNameLabel.Position = UDim2.new(0, 8, 0, avatarY + avatarSize + 10)
    displayNameLabel.BackgroundTransparency = 1
    displayNameLabel.Text = LocalPlayer.DisplayName -- Always show DisplayName
    displayNameLabel.Font = Enum.Font.GothamBold
    displayNameLabel.TextColor3 = Color3.fromRGB(255,255,255)
    displayNameLabel.TextSize = 18
    displayNameLabel.TextXAlignment = Enum.TextXAlignment.Center
    displayNameLabel.TextWrapped = true
    displayNameLabel.TextScaled = true
    displayNameLabel.ClipsDescendants = true
    displayNameLabel.ZIndex = 2

    -- Sidebar: Username (under display name)
    local usernameLabel = Instance.new("TextLabel", sidebar)
    usernameLabel.Size = UDim2.new(1, -16, 0, 18)
    usernameLabel.Position = UDim2.new(0, 8, 0, avatarY + avatarSize + 38)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "@" .. LocalPlayer.Name
    usernameLabel.Font = Enum.Font.GothamBold
    usernameLabel.TextColor3 = Color3.fromRGB(200,200,200)
    usernameLabel.TextSize = 14
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Center
    usernameLabel.TextWrapped = true
    usernameLabel.ClipsDescendants = true
    usernameLabel.ZIndex = 2

    -- Remove game name label if present
    for _, child in ipairs(sidebar:GetChildren()) do
        if child:IsA("TextLabel") and child ~= displayNameLabel and child ~= usernameLabel then
            child:Destroy()
        end
    end

    -- Main content area
    local contentX = 158

    -- Executor name for title
    local execName = "Unknown"
    if typeof(identifyexecutor) == "function" then
        local ok, res = pcall(identifyexecutor)
        if ok and type(res) == "string" then
            execName = res
        end
    end

    -- Title with executor (organized, more readable)
    local title = createLabel(frame, "Fling GUI | " .. execName, UDim2.new(0, contentX, 0, 0), UDim2.new(1, -contentX, 0, 36), Enum.TextXAlignment.Center)
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBlack

    -- Target box (centered more to the right)
    local searchBox = Instance.new("TextBox", frame)
    searchBox.PlaceholderText = "Target (partial name)"
    searchBox.Size = UDim2.new(0, 260, 0, 38)
    searchBox.Position = UDim2.new(0, contentX + 60, 0, 54)
    searchBox.BackgroundColor3 = Color3.fromRGB(40,40,50)
    searchBox.TextColor3 = Color3.fromRGB(255,255,255)
    searchBox.Font = Enum.Font.GothamBold -- bold
    searchBox.TextSize = 18
    searchBox.Text = ""
    searchBox.ClearTextOnFocus = false
    local uic2 = Instance.new("UICorner", searchBox)
    uic2.CornerRadius = UDim.new(0, 10)
    -- Remove outline from target box
    if searchBox:FindFirstChildOfClass("UIStroke") then
        searchBox:FindFirstChildOfClass("UIStroke"):Destroy()
    end

    -- Helper to create simple modern buttons (no icons)
    local function createSimpleButton(parent, text, pos, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 160, 0, 42)
        btn.Position = pos
        btn.BackgroundColor3 = color or Color3.fromRGB(45, 48, 65)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18 -- Adjusted to ensure longer texts fit cleanly
        btn.AutoButtonColor = false
        btn.Parent = parent
        btn.ZIndex = 2
        local uic = Instance.new("UICorner", btn)
        uic.CornerRadius = UDim.new(0, 10)
        -- Remove UIStroke (no outline for button text or button)
        for _, child in ipairs(btn:GetChildren()) do
            if child:IsA("UIStroke") then child:Destroy() end
        end
        -- Hover animation: dark overlay, not gray
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = (color or Color3.fromRGB(45, 48, 65)):Lerp(Color3.fromRGB(20,20,25), 0.25)}):Play() -- Slightly darker, more subtle hover
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = color or Color3.fromRGB(45, 48, 65)}):Play() -- Return to new default
        end)
        return btn
    end

    -- Button layout (organized, more vertical spacing)
    local yBtn = 110 -- Moved up to fill space from removed status label
    local btnGap = 54 -- Keep the gap consistent
    local startBtn = createSimpleButton(frame, "Start Flinging", UDim2.new(0, contentX + 20, 0, yBtn), Color3.fromRGB(70, 180, 100)) -- Emerald Green
    local stopBtn = createSimpleButton(frame, "Stop Flinging", UDim2.new(0, contentX + 200, 0, yBtn), Color3.fromRGB(200, 80, 80)) -- Softer Red
    local tpBtn = createSimpleButton(frame, "Teleport to Target", UDim2.new(0, contentX + 20, 0, yBtn+btnGap), Color3.fromRGB(80, 120, 200)) -- Sophisticated Blue
    local viewBtn = createSimpleButton(frame, "Viewing : No", UDim2.new(0, contentX + 200, 0, yBtn+btnGap), Color3.fromRGB(80, 180, 180)) -- Softer Teal

    -- Credits Button (bottom right, more readable)
    local creditsBtn = createSimpleButton(frame, "Credits", UDim2.new(0, 269, 0, yBtn + btnGap + 62), Color3.fromRGB(100, 140, 255)) -- Vibrant Blue-Purple Accent

    -- Redesigned credits modal
    local creditsModal = Instance.new("Frame", gui)
    creditsModal.BackgroundColor3 = Color3.fromRGB(24, 26, 38)
    creditsModal.Size = UDim2.new(0, 360, 0, 220)
    creditsModal.Position = UDim2.new(0.5, -180, 0.5, -110)
    for _, child in ipairs(creditsModal:GetChildren()) do child:Destroy() end
    local creditsUIC = Instance.new("UICorner", creditsModal)
    creditsUIC.CornerRadius = UDim.new(0, 16)

    local creditsTitle = Instance.new("TextLabel", creditsModal)
    creditsTitle.Size = UDim2.new(1, 0, 0, 48)
    creditsTitle.Position = UDim2.new(0, 0, 0, 18)
    creditsTitle.BackgroundTransparency = 1
    creditsTitle.Text = "Fling GUI Credits"
    creditsTitle.Font = Enum.Font.GothamBlack
    creditsTitle.TextColor3 = Color3.new(1,1,1)
    creditsTitle.TextSize = 30
    creditsTitle.TextWrapped = true
    creditsTitle.TextYAlignment = Enum.TextYAlignment.Top
    creditsTitle.TextXAlignment = Enum.TextXAlignment.Center

    local discordLabel = Instance.new("TextLabel", creditsModal)
    discordLabel.Size = UDim2.new(1, 0, 0, 28)
    discordLabel.Position = UDim2.new(0, 0, 0, 70)
    discordLabel.BackgroundTransparency = 1
    discordLabel.Text = "Discord: sandernl10"
    discordLabel.Font = Enum.Font.GothamMedium
    discordLabel.TextColor3 = Color3.fromRGB(200,220,255)
    discordLabel.TextSize = 20
    discordLabel.TextXAlignment = Enum.TextXAlignment.Center
    discordLabel.TextYAlignment = Enum.TextYAlignment.Center

    local discordBtn = Instance.new("TextButton", creditsModal)
    discordBtn.Size = UDim2.new(0.8, 0, 0, 44)
    discordBtn.Position = UDim2.new(0.1, 0, 0, 120)
    discordBtn.BackgroundColor3 = Color3.fromRGB(100, 140, 255) -- Consistent with new Credits button color
    discordBtn.Text = "Discord Server"
    discordBtn.TextColor3 = Color3.new(1,1,1)
    discordBtn.Font = Enum.Font.GothamBlack
    discordBtn.TextSize = 22
    discordBtn.TextWrapped = true
    discordBtn.TextXAlignment = Enum.TextXAlignment.Center
    discordBtn.TextYAlignment = Enum.TextYAlignment.Center
    discordBtn.AutoButtonColor = true
    local btnUIC = Instance.new("UICorner", discordBtn)
    btnUIC.CornerRadius = UDim.new(0, 10)
    discordBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/QX7NankpRn")
        if not creditsModal:FindFirstChild("notifLabel") then
            local notifLabel = Instance.new("TextLabel", creditsModal)
            notifLabel.Name = "notifLabel"
            notifLabel.Size = UDim2.new(1, 0, 0, 28)
            notifLabel.Position = UDim2.new(0, 0, 1, -34)
            notifLabel.BackgroundTransparency = 0.3
            notifLabel.BackgroundColor3 = Color3.fromRGB(40, 60, 100)
            notifLabel.Text = "Copied Discord invite to clipboard!"
            notifLabel.Font = Enum.Font.GothamMedium
            notifLabel.TextColor3 = Color3.fromRGB(180,220,255)
            notifLabel.TextSize = 18
            notifLabel.TextXAlignment = Enum.TextXAlignment.Center
            notifLabel.TextYAlignment = Enum.TextYAlignment.Center
            notifLabel.Visible = true
            local notifUIC = Instance.new("UICorner", notifLabel)
            notifUIC.CornerRadius = UDim.new(0, 8)
            task.spawn(function()
                wait(3)
                notifLabel:Destroy()
            end)
        end
    end)

    -- Remove outline on the right side of the sidebar
    for _, child in ipairs(sidebar:GetChildren()) do
        if child:IsA("UIStroke") then
            child:Destroy()
        end
    end
    if sidebar:FindFirstChildOfClass("UIStroke") then
        sidebar:FindFirstChildOfClass("UIStroke"):Destroy()
    end

    -- Make credits modal hidden by default
    creditsModal.Visible = false

    -- Credits button toggles the modal
    local creditsOpen = false
    creditsBtn.MouseButton1Click:Connect(function()
        creditsOpen = not creditsOpen
        creditsModal.Visible = creditsOpen
    end)

    -- State
    local d = LocalPlayer
    local e = false -- rageActive
    local f = nil   -- targetPlayer
    local g = 0.5   -- prediction
    local h = 10000 -- fling force
    local i = false -- viewing

    -- Advanced dynamic prediction state
    local lastPred = 0.25
    local lastTargetPos = nil
    local lastTargetVel = nil
    local lastUpdate = tick()

    -- Advanced Prediction Calculation (ping, fps, target velocity, acceleration, latency smoothing)
    local function getAdvancedPrediction(target)
        local ping = 50
        local stats = Stats
        local network = stats:FindFirstChild("Network")
        if network then
            local pingStat = network:FindFirstChild("Ping")
            if pingStat then
                ping = tonumber(pingStat:GetValueString():match("%d+")) or 50
            end
        end
        local fps = math.clamp(Workspace:GetRealPhysicsFPS(), 10, 240)
        local latency = math.clamp(ping / 1000, 0.01, 0.5)

        local tRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if not tRoot then return 0.2 end

        local now = tick()
        local dt = now - (lastUpdate or now)
        lastUpdate = now

        local pos = tRoot.Position
        local vel = tRoot.Velocity
        local acc = Vector3.zero
        if lastTargetPos and lastTargetVel and dt > 0 then
            acc = (vel - lastTargetVel) / dt
        end
        lastTargetPos = pos
        lastTargetVel = vel

        local base = 0.18 + latency * 2 + (1 / fps) * 2
        if vel.Magnitude > 40 then base = base + 0.18 end
        if vel.Magnitude > 80 then base = base + 0.28 end
        if math.abs(vel.Y) > 30 then base = base + 0.12 end
        if acc.Magnitude > 10 then base = base + 0.08 end

        lastPred = lastPred + (base - lastPred) * 0.25
        return math.clamp(lastPred, 0.18, 1.7)
    end
    -- Fling logic (advanced prediction, safe, only flings if prediction is valid and not in void)
    local wasFlung = false
    local respawnConn = nil

    local function isValidPosition(pos)
        return pos.Y > -100 and pos.Y < 1e5 and math.abs(pos.X) < 1e5 and math.abs(pos.Z) < 1e5
    end

    -- Player Resolver
    local function resolvePlayer(input)
        input = input:lower()
        local best, bestScore = nil, 0
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= d then
                local name = plr.Name:lower()
                local display = plr.DisplayName:lower()
                local score = 0
                if name:find(input, 1, true) then score = score + 2 end
                if display:find(input, 1, true) then score = score + 1 end
                if score > bestScore then
                    best = plr
                    bestScore = score
                end
            end
        end
        return best
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        playSound(SOUND_TYPE, searchBox, 0.5)
    end)

    searchBox.FocusLost:Connect(function(af)
        if af then
            local plr = resolvePlayer(searchBox.Text)
            if plr then
                searchBox.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
                f = plr
                playSound(SOUND_TARGET_SET, frame, 0.8)
            else
                f = nil
            end
        end
    end)

    startBtn.MouseButton1Click:Connect(function()
        if f then
            e = true
            local char = d.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = false end
            end
            playSound(SOUND_BUTTON, frame, 0.7)
        end
    end)

    stopBtn.MouseButton1Click:Connect(function()
        e = false
        playSound(SOUND_BUTTON, frame, 0.7)
        local char = d.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0
            end
        end
    end)

    tpBtn.MouseButton1Click:Connect(function()
        if f and f.Character and f.Character:FindFirstChild("HumanoidRootPart") then
            local target = f.Character.HumanoidRootPart
            if d.Character then
                d.Character:SetPrimaryPartCFrame(target.CFrame)
            end
            playSound(SOUND_BUTTON, frame, 0.7)
        end
    end)

    viewBtn.MouseButton1Click:Connect(function()
        i = not i
        viewBtn.Text = "Viewing : " .. (i and "Yes" or "No")
        if i and f and f.Character and f.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = f.Character.Humanoid
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        else
            workspace.CurrentCamera.CameraSubject = d.Character and d.Character:FindFirstChildOfClass("Humanoid") or workspace.CurrentCamera.CameraSubject
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end
        playSound(SOUND_BUTTON, frame, 0.7)
    end)

    RunService.Heartbeat:Connect(function()
        local char = d.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not e or not root or not f or not f.Character or not f.Character:FindFirstChild("HumanoidRootPart") then
            wasFlung = false
            return
        end

        local targetRoot = f.Character.HumanoidRootPart
        g = getAdvancedPrediction(f)
        local predicted = targetRoot.Position + (targetRoot.Velocity * g)
        if lastTargetVel then
            local acc = (targetRoot.Velocity - lastTargetVel) / math.max((tick() - (lastUpdate or tick())), 0.01)
            predicted = predicted + (acc * 0.5 * g * g)
        end

        if not wasFlung and isValidPosition(predicted) then
            root.CFrame = CFrame.new(predicted + Vector3.new(0, 1.5, 0))
            root.Velocity = (targetRoot.Velocity * 50) + Vector3.new(0, h, 0)
            root.RotVelocity = Vector3.new(3e5, 3e5, 3e5)
        end

        if targetRoot.Velocity.Magnitude > 120 then
            if not wasFlung then
                playSound(SOUND_FLING, frame, 1)
                wasFlung = true
                if respawnConn then respawnConn:Disconnect() end
                respawnConn = f.CharacterAdded:Connect(function()
                    wasFlung = false
                    lastTargetPos = nil
                    lastTargetVel = nil
                end)
            end
        end
    end)

    -- Anti-fling script (runs every frame for smoothness)
    local function enforceSelfCollision()
        local function apply()
            local char = LocalPlayer.Character
            if not char then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    part.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5) -- Clamped density to acceptable range (max 100)
                end
            end
        end
        LocalPlayer.CharacterAdded:Connect(apply)
        if LocalPlayer.Character then apply() end
    end
    enforceSelfCollision()

    -- Smooth anti-fling: enforce every frame for all other players
    RunService.Stepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Velocity = Vector3.zero
                        part.RotVelocity = Vector3.zero
                    end
                end
            end
        end
    end)