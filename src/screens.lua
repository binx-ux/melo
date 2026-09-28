function UILib.createFallingParticles(parent, opts)
    opts = opts or {}
    local accent = opts.accent or hexToColor3(Settings.UI and Settings.UI.AccentHex or "7DD3FC")
    local count = opts.count or 40
    local zIndex = opts.zIndex or 1
    local needsVisible = opts.needsVisible
    local layer = UILib.newFrame(parent, {
        Name = MW_T.next(10),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        BorderSizePixel = 0,
        ZIndex = zIndex,
    })
    local particles = {}
    for i = 1, count do
        local sz = math.random(2, 5)
        local p = Instance.new("Frame")
        p.Size = UDim2.new(0, sz, 0, sz)
        p.Position = UDim2.new(math.random(), 0, math.random() * -0.2, 0)
        p.BackgroundColor3 = accent
        p.BackgroundTransparency = math.random(40, 78) / 100
        p.BorderSizePixel = 0
        p.ZIndex = zIndex
        p.Parent = layer
        UILib.corner(p, 100)
        particles[i] = {
            frame = p,
            speed = math.random(16, 48) / 100,
            drift = (math.random() - 0.5) * 0.012,
            x = p.Position.X.Scale,
            y = p.Position.Y.Scale,
        }
    end
    local alive = true
    local conn = S.RunService.RenderStepped:Connect(function(dt)
        if not alive or not layer.Parent then return end
        if needsVisible and not needsVisible() then return end
        for _, data in ipairs(particles) do
            data.y = data.y + data.speed * dt
            data.x = data.x + data.drift * dt
            if data.y > 1.08 then
                data.y = math.random() * -0.12
                data.x = math.random()
                data.frame.BackgroundTransparency = math.random(40, 78) / 100
            end
            data.frame.Position = UDim2.new(data.x, 0, data.y, 0)
        end
    end)
    table.insert(allConnections, conn)
    local sys = {
        layer = layer,
        conn = conn,
        setAccent = function(c)
            for _, data in ipairs(particles) do
                data.frame.BackgroundColor3 = c
            end
        end,
        destroy = function()
            alive = false
            pcall(function() conn:Disconnect() end)
            pcall(function() layer:Destroy() end)
        end,
    }
    table.insert(uiParticleSystems, sys)
    return sys
end
function UILib.fetchReleaseChangelog()
    if not MW.changelogUrl or MW.changelogUrl == "" then return nil end
    local ok, raw = pcall(function() return game:HttpGet(MW.changelogUrl) end)
    if not ok or not raw or raw == "" then return nil end
    local ok2, data = pcall(function() return S.HttpService:JSONDecode(raw) end)
    if ok2 and type(data) == "table" then return data end
    return nil
end
function UILib.getBuiltinChangelog()
    return {
        display = "v0",
        title = "Melo 🍃",
        lines = {
            "Better UI",
            "New gun mod",
            "Working on wireframe - still open to use",
        },
    }
end
;(function()
    local AudioSys = {}
    local folder, musicSound, lastFire, lastHit, charConns = nil, nil, 0, {}, {}
    local function normalizeSoundId(raw)
        if raw == nil then return nil end
        local s = tostring(raw)
        if s == "" or s == "0" then return nil end
        if s:find("rbxassetid://", 1, true) then return s end
        local id = s:match("(%d+)")
        if not id or id == "0" then return nil end
        return "rbxassetid://" .. id
    end
    function AudioSys.playMwSound(soundId, volume)
        ensureUISettings()
        local sid = normalizeSoundId(soundId)
        if not sid then return end
        if not folder or not folder.Parent then
            folder = Instance.new("Folder")
            folder.Name = MW_T.audio
            folder.Parent = S.SoundService
        end
        local s = Instance.new("Sound")
        s.SoundId = sid
        s.Volume = math.clamp(tonumber(volume) or 0.5, 0, 2)
        s.PlaybackSpeed = math.clamp(tonumber(Settings.Audio.HitPitch) or 1, 0.5, 2)
        s.Parent = folder
        s:Play()
        s.Ended:Connect(function()
            pcall(function() s:Destroy() end)
        end)
    end
    function AudioSys.playHitSound()
        ensureUISettings()
        if not Settings.Audio.HitSoundsEnabled then return end
        AudioSys.playMwSound(Settings.Audio.HitSoundId, Settings.Audio.HitVolume)
    end
    function AudioSys.playKillSound()
        ensureUISettings()
        if not Settings.Audio.KillSoundsEnabled then return end
        local prev = Settings.Audio.HitPitch
        Settings.Audio.HitPitch = Settings.Audio.KillPitch or 1
        AudioSys.playMwSound(Settings.Audio.KillSoundId, Settings.Audio.KillVolume)
        Settings.Audio.HitPitch = prev
    end
    local function tuneMusic(s)
        s.Volume = math.clamp(tonumber(Settings.Audio.MusicVolume) or 0.35, 0, 2)
        s.PlaybackSpeed = math.clamp(tonumber(Settings.Audio.MusicSpeed) or 1, 0.5, 2)
        s.Looped = Settings.Audio.MusicLoop ~= false
        local pitch = s:FindFirstChild("MeloPitch")
        if not pitch then
            pitch = Instance.new("PitchShiftSoundEffect")
            pitch.Name = "MeloPitch"
            pitch.Parent = s
        end
        pitch.Octave = math.clamp(tonumber(Settings.Audio.MusicPitch) or 1, 0.5, 2)
        local eq = s:FindFirstChild("MeloEQ")
        if not eq then
            eq = Instance.new("EqualizerSoundEffect")
            eq.Name = "MeloEQ"
            eq.Parent = s
        end
        eq.LowGain = math.clamp(tonumber(Settings.Audio.MusicBass) or 0, -20, 10)
        eq.HighGain = math.clamp(tonumber(Settings.Audio.MusicTreble) or 0, -20, 10)
        eq.MidGain = 0
    end
    local function boomboxParent()
        if Settings.Audio.Boombox == false then return nil end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        return hrp
    end
    function AudioSys.refreshMusicPlayback()
        ensureUISettings()
        if not musicSound or not musicSound.Parent then
            musicSound = Instance.new("Sound")
            musicSound.Name = "MeloMusic"
            musicSound.Looped = true
        end
        local host = boomboxParent()
        if host then
            musicSound.Parent = host
            musicSound.RollOffMode = Enum.RollOffMode.InverseTapered
            musicSound.RollOffMinDistance = 8
            musicSound.RollOffMaxDistance = math.clamp(tonumber(Settings.Audio.MusicDistance) or 90, 15, 400)
            musicSound.EmitterSize = 14
        else
            if not folder or not folder.Parent then
                folder = Instance.new("Folder")
                folder.Name = MW_T.audio
                folder.Parent = S.SoundService
            end
            musicSound.Parent = folder
        end
        tuneMusic(musicSound)
        local sid = normalizeSoundId(Settings.Audio.MusicId)
        if Settings.Audio.MusicEnabled and sid then
            if musicSound.SoundId ~= sid then musicSound.SoundId = sid end
            if not musicSound.IsPlaying then pcall(function() musicSound:Play() end) end
        else
            pcall(function() musicSound:Stop() end)
        end
    end
    function AudioSys.pauseMusic()
        if musicSound then pcall(function() musicSound:Pause() end) end
    end
    local function clearCharConns(plr)
        local pack = charConns[plr]
        if not pack then return end
        for _, c in ipairs(pack) do pcall(function() c:Disconnect() end) end
        charConns[plr] = nil
    end
    local function getCreatorPlayer(hum, char)
        local containers = { hum, char }
        for i = 1, #containers do
            local container = containers[i]
            if container then
                local tag = container:FindFirstChild("creator") or container:FindFirstChild("Creator")
                    or container:FindFirstChild("creatorTag") or container:FindFirstChild("KillCredit")
                if tag then
                    local v = tag.Value
                    if typeof(v) == "Instance" then
                        if v:IsA("Player") then return v end
                        if v:IsA("Model") then
                            local p = S.Players:GetPlayerFromCharacter(v)
                            if p then return p end
                        end
                    end
                end
            end
        end
        return nil
    end
    local function creditLooksLikeUs(plr)
        if currentTarget == plr then return true end
        if isTracking and currentTarget == plr then return true end
        if tick() - lastFire <= 1.6 then return true end
        return false
    end
    local function hookCharacter(plr, char)
        if plr == player then return end
        clearCharConns(plr)
        local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
        if not hum then return end
        local conns = {}
        local lastHp = hum.Health
        table.insert(conns, hum.HealthChanged:Connect(function(newHp)
            if isUnloading or _G[MW_T.unloaded] then return end
            ensureUISettings()
            local oldHp = lastHp
            lastHp = newHp
            if newHp >= oldHp then return end
            if not isValidTarget(player, plr) then return end
            local creator = getCreatorPlayer(hum, char)
            local ours = (creator == player) or creditLooksLikeUs(plr)
            if not ours then return end
            local now = tick()
            if now - (lastHit[plr.UserId] or 0) < 0.1 then return end
            lastHit[plr.UserId] = now
            if Settings.Audio.HitSoundsEnabled then AudioSys.playHitSound() end
        end))
        table.insert(conns, hum.Died:Connect(function()
            if isUnloading or _G[MW_T.unloaded] then return end
            ensureUISettings()
            local creator = getCreatorPlayer(hum, char)
            local recentHit = tick() - (lastHit[plr.UserId] or 0) <= 5
            if creator == player or (recentHit and creditLooksLikeUs(plr)) then
                if Settings.Audio.KillSoundsEnabled then AudioSys.playKillSound() end
                pcall(function() FX.onKill(getDisplayName(plr), getPlayerWeaponName(player)) end)
            end
            lastHit[plr.UserId] = nil
        end))
        charConns[plr] = conns
    end
    function AudioSys.setup()
        ensureUISettings()
        folder = Instance.new("Folder")
        folder.Name = MW_T.audio
        folder.Parent = S.SoundService
        musicSound = Instance.new("Sound")
        musicSound.Name = MW_T.music
        musicSound.Looped = true
        musicSound.Parent = folder
        table.insert(allConnections, player.CharacterAdded:Connect(function()
            task.defer(function()
                if not isUnloading and not _G[MW_T.unloaded] then
                    AudioSys.refreshMusicPlayback()
                end
            end)
        end))
        table.insert(allConnections, S.UserInputService.InputBegan:Connect(function(input, gp)
            if isUnloading or _G[MW_T.unloaded] or gp then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then lastFire = tick() end
        end))
        local function trackPlayer(plr)
            if plr == player then return end
            if plr.Character then hookCharacter(plr, plr.Character) end
            table.insert(allConnections, plr.CharacterAdded:Connect(function(c) hookCharacter(plr, c) end))
        end
        for _, plr in ipairs(S.Players:GetPlayers()) do trackPlayer(plr) end
        table.insert(allConnections, S.Players.PlayerAdded:Connect(trackPlayer))
        table.insert(allConnections, S.Players.PlayerRemoving:Connect(function(plr)
            clearCharConns(plr)
            lastHit[plr.UserId] = nil
        end))
    end
    function AudioSys.cleanup()
        pcall(function() if musicSound then musicSound:Stop() end end)
        pcall(function() if folder then folder:Destroy() end end)
        musicSound, folder = nil, nil
    end
    _G[MW_T.audioApi] = AudioSys
    _G[MW_T.dockApi] = function(windowLayer, mainFrame, switchMainFn, getActiveMain)

    pcall(function()
        local old = windowLayer:FindFirstChild(MW_T.topNav)
        if old then old:Destroy() end
    end)
    local function ensureScale(obj, name)
        local s = obj:FindFirstChild(name)
        if not s then
            s = Instance.new("UIScale")
            s.Name = name
            s.Scale = 1
            s.Parent = obj
        end
        return s
    end
    local menuVisToken = 0
    local menuHomePos = mainFrame.Position
    local activeMenuTweens = {}
    local function playMenuTween(object, duration, properties, style, direction)
        local old = activeMenuTweens[object]
        if old then pcall(function() old:Cancel() end) end
        local tween = UILib.tween(object, duration, properties, style, direction)
        activeMenuTweens[object] = tween
        tween:Play()
        return tween
    end
    local function setMenuVisible(open)
        menuVisToken = menuVisToken + 1
        local token = menuVisToken
        local mScale = ensureScale(mainFrame, "MenuScale")
        local mainBg = mainFrame:FindFirstChild(MW_T.mainBg) or mainFrame:FindFirstChildWhichIsA("Frame")
        if open then
            mainFrame.Visible = true
            mScale.Scale = math.min(mScale.Scale, 0.972)
            mainFrame.Position = menuHomePos + UDim2.new(0, 0, 0, 10)
            if mainBg then mainBg.BackgroundTransparency = math.max(mainBg.BackgroundTransparency, 0.48) end
            playMenuTween(mScale, 0.46, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            playMenuTween(mainFrame, 0.46, {Position = menuHomePos}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            if mainBg then
                playMenuTween(mainBg, 0.42, {BackgroundTransparency = 0}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            end
        else
            local closePos = menuHomePos + UDim2.new(0, 0, 0, 12)
            playMenuTween(mScale, 0.42, {Scale = 0.965}, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
            playMenuTween(mainFrame, 0.42, {Position = closePos}, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
            if mainBg then
                playMenuTween(mainBg, 0.38, {BackgroundTransparency = 0.72}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            end
            task.delay(0.43, function()
                if token ~= menuVisToken then return end
                mainFrame.Visible = false
                mScale.Scale = 1
                mainFrame.Position = menuHomePos
                if mainBg then mainBg.BackgroundTransparency = 0 end
            end)
        end
    end
    local function refreshDock() end
    return nil, setMenuVisible, refreshDock
    end
end)()
function UILib.showWeakExecutorScreen()
    local reasons = Cap.weakReasons()
    local execName = getExecutorName()
    local accent = hexToColor3(Settings.UI and Settings.UI.AccentHex or "7DD3FC")
    local warnCol = Color3.fromRGB(255, 176, 72)
    local gui = UILib.newScreenGui(MW_T.next(10), 270)
    local root = UILib.newFrame(gui, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1,
        Active = true,
    })
    local card = UILib.newFrame(root, {
        Size = UDim2.new(0, 420, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 18),
        BackgroundColor3 = Color3.fromRGB(12, 13, 18),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    UILib.corner(card, 14)
    local cardStroke = UILib.stroke(card, warnCol, 1, 0.35)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 22)
    pad.PaddingBottom = UDim.new(0, 22)
    pad.PaddingLeft = UDim.new(0, 22)
    pad.PaddingRight = UDim.new(0, 22)
    pad.Parent = card
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = card
    local scale = Instance.new("UIScale")
    scale.Scale = 0.92
    scale.Parent = card
    UILib.newLabel(card, {
        Size = UDim2.new(1, 0, 0, 18),
        Text = MW.hub,
        TextColor3 = accent,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        ZIndex = 3,
    })
    UILib.newLabel(card, {
        Size = UDim2.new(1, 0, 0, 28),
        Text = "Weak executor detected",
        TextColor3 = Color3.fromRGB(245, 245, 250),
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        ZIndex = 3,
    })
    UILib.newLabel(card, {
        Size = UDim2.new(1, 0, 0, 36),
        Text = "Detected: " .. tostring(execName)
            .. (Cap.title and ("  ·  WEAO: " .. tostring(Cap.title)) or "")
            .. (Cap.suncPct ~= nil and ("  ·  sUNC " .. tostring(Cap.suncPct) .. "%") or ""),
        TextColor3 = Color3.fromRGB(160, 164, 176),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        ZIndex = 3,
    })
    UILib.newLabel(card, {
        Size = UDim2.new(1, 0, 0, 16),
        Text = "Why this is flagged",
        TextColor3 = Color3.fromRGB(230, 232, 240),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 4,
        ZIndex = 3,
    })
    local reasonBox = UILib.newFrame(card, {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(18, 19, 26),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        LayoutOrder = 5,
        ZIndex = 3,
    })
    UILib.corner(reasonBox, 8)
    local rPad = Instance.new("UIPadding")
    rPad.PaddingTop = UDim.new(0, 10)
    rPad.PaddingBottom = UDim.new(0, 10)
    rPad.PaddingLeft = UDim.new(0, 12)
    rPad.PaddingRight = UDim.new(0, 12)
    rPad.Parent = reasonBox
    local rLayout = Instance.new("UIListLayout")
    rLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rLayout.Padding = UDim.new(0, 6)
    rLayout.Parent = reasonBox
    for i, reason in ipairs(reasons) do
        UILib.newLabel(reasonBox, {
            Size = UDim2.new(1, 0, 0, 16),
            Text = "•  " .. tostring(reason),
            TextColor3 = warnCol,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = i,
            ZIndex = 4,
        })
    end
    if #reasons == 0 then
        UILib.newLabel(reasonBox, {
            Size = UDim2.new(1, 0, 0, 16),
            Text = "•  Capability gaps detected for this build",
            TextColor3 = warnCol,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
            ZIndex = 4,
        })
    end
    local locked = Cap.lockedList()
    UILib.newLabel(card, {
        Size = UDim2.new(1, 0, 0, 16),
        Text = "Locked on this executor",
        TextColor3 = Color3.fromRGB(230, 232, 240),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 6,
        ZIndex = 3,
    })
    local lockBox = UILib.newFrame(card, {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(22, 14, 16),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        LayoutOrder = 7,
        ZIndex = 3,
    })
    UILib.corner(lockBox, 8)
    local lPad = Instance.new("UIPadding")
    lPad.PaddingTop = UDim.new(0, 10)
    lPad.PaddingBottom = UDim.new(0, 10)
    lPad.PaddingLeft = UDim.new(0, 12)
    lPad.PaddingRight = UDim.new(0, 12)
    lPad.Parent = lockBox
    local lLayout = Instance.new("UIListLayout")
    lLayout.SortOrder = Enum.SortOrder.LayoutOrder
    lLayout.Padding = UDim.new(0, 6)
    lLayout.Parent = lockBox
    local lockCol = Color3.fromRGB(255, 110, 110)
    if #locked == 0 then
        UILib.newLabel(lockBox, {
            Size = UDim2.new(1, 0, 0, 16),
            Text = "•  Nothing hard-locked (still treated as weak)",
            TextColor3 = Color3.fromRGB(160, 164, 176),
            TextSize = 12,
            Font = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
            ZIndex = 4,
        })
    else
        for i, row in ipairs(locked) do
            UILib.newLabel(lockBox, {
                Size = UDim2.new(1, 0, 0, 32),
                Text = "•  " .. tostring(row.label) .. "\n    [" .. tostring(row.reason) .. "]",
                TextColor3 = lockCol,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                LayoutOrder = i,
                ZIndex = 4,
            })
        end
    end
    UILib.newLabel(card, {
        Size = UDim2.new(1, 0, 0, 32),
        Text = "Locked items stay off in the menu. Switch executors for full Melo 🍃.",
        TextColor3 = Color3.fromRGB(140, 144, 158),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 8,
        ZIndex = 3,
    })
    local row = UILib.newFrame(card, {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = 9,
        ZIndex = 3,
    })
    local continueBtn = UILib.newButton(row, {
        Size = UDim2.new(0.58, -4, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Text = "Continue anyway",
        TextColor3 = Color3.fromRGB(8, 10, 14),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        ZIndex = 4,
    })
    UILib.corner(continueBtn, 8)
    local unloadBtn = UILib.newButton(row, {
        Size = UDim2.new(0.42, -4, 1, 0),
        Position = UDim2.new(0.58, 4, 0, 0),
        BackgroundColor3 = Color3.fromRGB(28, 30, 38),
        BorderSizePixel = 0,
        Text = "Unload",
        TextColor3 = Color3.fromRGB(230, 232, 240),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        ZIndex = 4,
    })
    UILib.corner(unloadBtn, 8)
    UILib.stroke(unloadBtn, Color3.fromRGB(60, 64, 76), 1, 0.2)
    UILib.tween(root, 0.28, { BackgroundTransparency = 0.28 }):Play()
    UILib.tween(card, 0.32, { BackgroundTransparency = 0 }, Enum.EasingStyle.Cubic):Play()
    UILib.tween(scale, 0.32, { Scale = 1 }, Enum.EasingStyle.Cubic):Play()
    local decision = nil
    local weakScreenT0 = tick()
    continueBtn.MouseButton1Click:Connect(function()
        decision = true
    end)
    unloadBtn.MouseButton1Click:Connect(function()
        decision = false
    end)
    while decision == nil and not _G[MW_T.unloaded] do
        task.wait(0.05)

        if (tick() - weakScreenT0) > 4.5 then
            decision = true
        end
    end
    UILib.tween(root, 0.2, { BackgroundTransparency = 1 }):Play()
    UILib.tween(card, 0.2, { BackgroundTransparency = 1 }):Play()
    task.wait(0.12)
    pcall(function() gui:Destroy() end)
    return decision == true
end
function UILib.showExperimentalNotice()
    local seen = false
    pcall(function()
        if isfile and isfile(PROFILE_DIR .. "_notice.txt") then seen = true end
    end)
    if seen then return end
    local gui = UILib.newScreenGui(MW_T.next(11), 240)
    local accent = Color3.fromRGB(103, 89, 179)
    local card = UILib.newFrame(gui, {
        Size = UDim2.fromOffset(420, 196),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(16, 16, 22),
        BorderSizePixel = 0,
        ZIndex = 10,
    })
    UILib.corner(card, 10)
    UILib.stroke(card, Color3.fromRGB(48, 48, 58), 1, 0)
    local bar = UILib.newFrame(card, {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 11,
    })
    UILib.corner(bar, 2)
    UILib.newLabel(card, {
        Text = "Melo",
        Size = UDim2.new(1, -28, 0, 22),
        Position = UDim2.new(0, 14, 0, 14),
        TextColor3 = Color3.fromRGB(245, 245, 245),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 12,
    })
    local noticeLeaf = UILib.newFrame(card, {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.fromOffset(64, 20),
        BackgroundColor3 = Color3.fromRGB(118, 196, 92),
        BorderSizePixel = 0,
        ZIndex = 13,
    })
    UILib.circle(noticeLeaf)
    UILib.newLabel(card, {
        Text = "Melo is a very experimental script with over 27k lines of code. Things will feel slow if your executor is weak or new. This has been tested on Real.",
        Size = UDim2.new(1, -28, 0, 78),
        Position = UDim2.new(0, 14, 0, 42),
        TextColor3 = Color3.fromRGB(176, 176, 188),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        BackgroundTransparency = 1,
        ZIndex = 12,
    })
    local continueBtn = UILib.newButton(card, {
        Size = UDim2.new(1, -28, 0, 32),
        Position = UDim2.new(0, 14, 1, -46),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Text = "Continue",
        TextColor3 = Color3.fromRGB(245, 245, 245),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        ZIndex = 13,
    })
    UILib.corner(continueBtn, 6)
    local done = false
    continueBtn.MouseButton1Click:Connect(function()
        done = true
        pcall(function()
            if not Cap.ok("filesystem") then return end
            ensureDir()
            writefile(PROFILE_DIR .. "_notice.txt", "1")
        end)
    end)
    while not done and not _G[MW_T.unloaded] do
        task.wait(0.05)
    end
    pcall(function() gui:Destroy() end)
end
function UILib.showStarterPrompt()
    if readAutoloadName() ~= "" then
        pcall(function()
            if not Cap.ok("filesystem") then return end
            if isfile and isfile(PROFILE_DIR .. "_starter.txt") then return end
            ensureDir()
            writefile(PROFILE_DIR .. "_starter.txt", "skip")
        end)
        return
    end
    local seen = false
    pcall(function()
        if isfile and isfile(PROFILE_DIR .. "_starter.txt") then seen = true end
    end)
    if seen then return end
    local gui = UILib.newScreenGui(MW_T.next(12), 245)
    local accent = Color3.fromRGB(103, 89, 179)
    local card = UILib.newFrame(gui, {
        Size = UDim2.fromOffset(420, 168),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(16, 16, 22),
        BorderSizePixel = 0,
        ZIndex = 10,
    })
    UILib.corner(card, 10)
    UILib.stroke(card, Color3.fromRGB(48, 48, 58), 1, 0)
    UILib.newLabel(card, {
        Text = "Starter config",
        Size = UDim2.new(1, -28, 0, 22),
        Position = UDim2.new(0, 14, 0, 14),
        TextColor3 = Color3.fromRGB(245, 245, 245),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 12,
    })
    UILib.newLabel(card, {
        Text = "Load Legit for this first run? It turns on a softer aim setup and auto loads next time. Skip keeps the current defaults.",
        Size = UDim2.new(1, -28, 0, 52),
        Position = UDim2.new(0, 14, 0, 42),
        TextColor3 = Color3.fromRGB(176, 176, 188),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        BackgroundTransparency = 1,
        ZIndex = 12,
    })
    local legitBtn = UILib.newButton(card, {
        Size = UDim2.fromOffset(186, 32),
        Position = UDim2.new(0, 14, 1, -46),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Text = "Use Legit",
        TextColor3 = Color3.fromRGB(245, 245, 245),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        ZIndex = 13,
    })
    UILib.corner(legitBtn, 6)
    local skipBtn = UILib.newButton(card, {
        Size = UDim2.fromOffset(186, 32),
        Position = UDim2.new(1, -200, 1, -46),
        BackgroundColor3 = Color3.fromRGB(32, 32, 42),
        BorderSizePixel = 0,
        Text = "Skip",
        TextColor3 = Color3.fromRGB(210, 210, 210),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        ZIndex = 13,
    })
    UILib.corner(skipBtn, 6)
    local choice = nil
    legitBtn.MouseButton1Click:Connect(function() choice = "legit" end)
    skipBtn.MouseButton1Click:Connect(function() choice = "skip" end)
    while choice == nil and not _G[MW_T.unloaded] do
        task.wait(0.05)
    end
    if choice == "legit" then
        pcall(function()
            applyNamedConfig("Legit")
            writeAutoloadName("Legit")
        end)
    end
    pcall(function()
        if Cap.ok("filesystem") then
            ensureDir()
            writefile(PROFILE_DIR .. "_starter.txt", choice or "skip")
        end
    end)
    pcall(function() gui:Destroy() end)
end
function UILib.showLoader()
    local gui = UILib.newScreenGui(MW_T.loader, 250)
    local accent = Color3.fromRGB(103, 89, 179)
    local panel = UILib.newFrame(gui, {
        Size = UDim2.fromOffset(360, 118),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(16, 16, 22),
        BorderSizePixel = 0,
        ZIndex = 10,
    })
    UILib.corner(panel, 10)
    UILib.stroke(panel, Color3.fromRGB(48, 48, 58), 1, 0)
    local accentBar = UILib.newFrame(panel, {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 11,
    })
    local title = UILib.newLabel(panel, {
        Text = "Melo",
        Size = UDim2.new(1, -24, 0, 22),
        Position = UDim2.new(0, 12, 0, 12),
        TextColor3 = Color3.fromRGB(245, 245, 245),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 12,
    })
    local loadLeaf = UILib.newFrame(panel, {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.fromOffset(62, 18),
        BackgroundColor3 = Color3.fromRGB(118, 196, 92),
        BorderSizePixel = 0,
        ZIndex = 13,
    })
    UILib.circle(loadLeaf)
    local sub = UILib.newLabel(panel, {
        Text = "loading",
        Size = UDim2.new(1, -70, 0, 16),
        Position = UDim2.new(0, 12, 0, 36),
        TextColor3 = Color3.fromRGB(150, 150, 162),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 12,
    })
    local status = UILib.newLabel(panel, {
        Text = "0%",
        Size = UDim2.new(0, 48, 0, 16),
        Position = UDim2.new(1, -60, 0, 36),
        TextColor3 = Color3.fromRGB(210, 210, 220),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        ZIndex = 12,
    })
    local barBg = UILib.newFrame(panel, {
        Size = UDim2.new(1, -24, 0, 4),
        Position = UDim2.new(0, 12, 1, -18),
        BackgroundColor3 = Color3.fromRGB(32, 32, 40),
        BorderSizePixel = 0,
        ZIndex = 12,
    })
    UILib.corner(barBg, 2)
    local bar = UILib.newFrame(barBg, {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 13,
    })
    UILib.corner(bar, 2)
    local closed = false
    local api = {}
    function api.set(pct, label)
        if closed or not status.Parent then return end
        pct = math.clamp(tonumber(pct) or 0, 0, 100)
        status.Text = string.format("%d%%", pct)
        if label and label ~= "" then sub.Text = tostring(label) end
        UILib.tween(bar, 0.18, { Size = UDim2.new(pct / 100, 0, 1, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
    end
    function api.close()
        if closed then return end
        closed = true
        pcall(function()
            UILib.tween(panel, 0.15, { BackgroundTransparency = 1 }):Play()
            UILib.tween(title, 0.15, { TextTransparency = 1 }):Play()
            UILib.tween(sub, 0.15, { TextTransparency = 1 }):Play()
            UILib.tween(status, 0.15, { TextTransparency = 1 }):Play()
        end)
        task.wait(0.16)
        pcall(function() gui:Destroy() end)
        pcall(function()
            local pg = player:FindFirstChildOfClass("PlayerGui")
            if not pg then return end
            for _, child in ipairs(pg:GetChildren()) do
                if child:IsA("ScreenGui") and tostring(child.Name) == tostring(MW_T.loader) then
                    pcall(function() child:Destroy() end)
                end
            end
        end)
    end
    api.set(0, "starting")
    return api
end
function UILib.showUnloader()
    local gui = UILib.newScreenGui(MW_T.next(10), 260)
    local accent = Color3.fromRGB(103, 89, 179)
    local root = UILib.newFrame(gui, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    local label = UILib.newLabel(root, {
        Text = "Melo 🍃",
        Size = UDim2.fromOffset(200, 28),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        TextColor3 = accent,
        TextSize = 22,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Center,
        BackgroundTransparency = 1,
        TextTransparency = 1,
        ZIndex = 5,
    })
    UILib.tween(root, 0.12, { BackgroundTransparency = 0.55 }):Play()
    UILib.tween(label, 0.12, { TextTransparency = 0 }):Play()
    task.wait(0.35)
    UILib.tween(root, 0.18, { BackgroundTransparency = 1 }):Play()
    UILib.tween(label, 0.18, { TextTransparency = 1 }):Play()
    task.wait(0.2)
    pcall(function() gui:Destroy() end)
end
function UILib.showStartupChangelog(hostGui)
    local data = UILib.getBuiltinChangelog()
    if not data then return end
    local accent = hexToColor3(Settings.UI and Settings.UI.AccentHex or "7DD3FC")
    local lines = type(data.lines) == "table" and data.lines or {}
    if #lines == 0 and not data.title then return end
    local overlay = UILib.newFrame(hostGui, {
        Name = MW_T.changelog,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 120,
        Active = true,
    })
    local cardH = 140 + math.min(#lines, 8) * 22 + 54
    local card = UILib.newFrame(overlay, {
        Size = UDim2.new(0, 400, 0, cardH),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.52, 0),
        BackgroundColor3 = Theme.CardBg,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 121,
    })
    UILib.stroke(card, Theme.CardBorder, 1)
    local cardScale = Instance.new("UIScale")
    cardScale.Scale = 0.86
    cardScale.Parent = card
    local badge = UILib.newLabel(card, {
        Size = UDim2.new(0, 56, 0, 20),
        Position = UDim2.new(0, 14, 0, 14),
        Text = data.display or "pre alpha",
        TextColor3 = Theme.TextAccent,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        BackgroundColor3 = Theme.CardHeaderBg,
        BackgroundTransparency = 0.2,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTransparency = 1,
        ZIndex = 122,
    })
    local title = UILib.newLabel(card, {
        Size = UDim2.new(1, -90, 0, 24),
        Position = UDim2.new(0, 78, 0, 12),
        Text = data.title or ("Melo 🍃 " .. MW.display),
        TextColor3 = Theme.TextPrimary,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextTransparency = 1,
        ZIndex = 122,
    })
    local whats = UILib.newLabel(card, {
        Size = UDim2.new(1, -28, 0, 16),
        Position = UDim2.new(0, 14, 0, 40),
        Text = "What's new",
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
        ZIndex = 122,
    })
    local lineLabels = {}
    local y = 60
    for i, line in ipairs(lines) do
        if i > 8 then break end
        local bullet = UILib.newFrame(card, {
            Size = UDim2.new(0, 4, 0, 4),
            Position = UDim2.new(0, 16, 0, y + 7),
            BackgroundColor3 = accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 122,
        })
        local lbl = UILib.newLabel(card, {
            Size = UDim2.new(1, -36, 0, 20),
            Position = UDim2.new(0, 26, 0, y),
            Text = tostring(line),
            TextColor3 = Theme.TextSecondary,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextTransparency = 1,
            ZIndex = 122,
        })
        table.insert(lineLabels, {bullet = bullet, lbl = lbl})
        y = y + 22
    end
    local continueBtn = UILib.newButton(card, {
        Size = UDim2.new(1, -28, 0, 34),
        Position = UDim2.new(0, 14, 1, -44),
        Text = "Continue",
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        BackgroundColor3 = accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextTransparency = 1,
        ZIndex = 123,
    })
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        UILib.tween(overlay, 0.22, {BackgroundTransparency = 1}):Play()
        UILib.tween(cardScale, 0.24, {Scale = 0.9}, Enum.EasingStyle.Quint, Enum.EasingDirection.In):Play()
        UILib.tween(card, 0.24, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.54, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In):Play()
        task.delay(0.26, function()
            pcall(function() overlay:Destroy() end)
        end)
    end
    continueBtn.MouseButton1Click:Connect(dismiss)
    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            local ap, asz = card.AbsolutePosition, card.AbsoluteSize
            if pos.X < ap.X or pos.Y < ap.Y or pos.X > ap.X + asz.X or pos.Y > ap.Y + asz.Y then
                dismiss()
            end
        end
    end)
    UILib.tween(overlay, 0.28, {BackgroundTransparency = 0.42}):Play()
    UILib.tween(card, 0.36, {BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    UILib.tween(cardScale, 0.36, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    task.delay(0.08, function()
        UILib.tween(badge, 0.22, {TextTransparency = 0}):Play()
        UILib.tween(title, 0.22, {TextTransparency = 0}):Play()
        UILib.tween(whats, 0.22, {TextTransparency = 0}):Play()
        UILib.tween(continueBtn, 0.24, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        for i, entry in ipairs(lineLabels) do
            task.delay(0.03 * i, function()
                UILib.tween(entry.bullet, 0.18, {BackgroundTransparency = 0}):Play()
                UILib.tween(entry.lbl, 0.18, {TextTransparency = 0}):Play()
            end)
        end
    end)
    task.delay(14, dismiss)
    while not dismissed do task.wait(0.03) end
end
function UILib.createFOVRenderer(screenGui)
    local fovDrawing = nil
    local fovDots = {}
    local fovGui = nil
    local fovStroke = nil
    local useDrawing = false
    local maxDots = 32
    local fovWhite = Color3.fromRGB(255, 255, 255)
    local spinAngle = 0
    local lastSpinT = tick()
    pcall(function()
        if Drawing and Drawing.new then
            fovDrawing = Drawing.new("Circle")
            fovDrawing.Thickness = 1.5
            fovDrawing.Filled = false
            fovDrawing.NumSides = 64
            fovDrawing.Visible = false
            fovDrawing.Color = fovWhite
            fovDrawing.Transparency = 0.5
            for i = 1, maxDots do
                local d = Drawing.new("Circle")
                d.Filled = true
                d.NumSides = 12
                d.Radius = 2.5
                d.Visible = false
                d.Color = fovWhite
                d.Transparency = 0.25
                fovDots[i] = d
            end
            useDrawing = true
        end
    end)
    if not useDrawing then
        fovGui = UILib.newFrame(screenGui, {
            Name = "fc",
            Size = UDim2.new(0, 300, 0, 300),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 6,
        })
        local aspect = Instance.new("UIAspectRatioConstraint")
        aspect.AspectRatio = 1
        aspect.Parent = fovGui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = fovGui
        fovStroke = Instance.new("UIStroke")
        fovStroke.Color = fovWhite
        fovStroke.Thickness = 1.5
        fovStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        fovStroke.Parent = fovGui
        for i = 1, maxDots do
            local d = Instance.new("Frame")
            d.Name = "dot" .. i
            d.AnchorPoint = Vector2.new(0.5, 0.5)
            d.Size = UDim2.fromOffset(5, 5)
            d.BackgroundColor3 = fovWhite
            d.BorderSizePixel = 0
            d.Visible = false
            d.ZIndex = 7
            d.Parent = screenGui
            Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
            fovDots[i] = d
        end
    end
    local silentDrawing, silentGui, silentStroke = nil, nil, nil
    pcall(function()
        if useDrawing and Drawing and Drawing.new then
            silentDrawing = Drawing.new("Circle")
            silentDrawing.Thickness = 1.2
            silentDrawing.Filled = false
            silentDrawing.NumSides = 48
            silentDrawing.Visible = false
            silentDrawing.Color = fovWhite
            silentDrawing.Transparency = 0.65
        end
    end)
    if not useDrawing then
        silentGui = UILib.newFrame(screenGui, {
            Name = "fcSilent",
            Size = UDim2.new(0, 180, 0, 180),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 6,
        })
        local aspect2 = Instance.new("UIAspectRatioConstraint")
        aspect2.AspectRatio = 1
        aspect2.Parent = silentGui
        local corner2 = Instance.new("UICorner")
        corner2.CornerRadius = UDim.new(0.5, 0)
        corner2.Parent = silentGui
        silentStroke = Instance.new("UIStroke")
        silentStroke.Color = fovWhite
        silentStroke.Thickness = 1.2
        silentStroke.Transparency = 0.45
        silentStroke.Parent = silentGui
    end
    local function hideDots()
        for i = 1, #fovDots do
            local d = fovDots[i]
            if d then
                d.Visible = false
            end
        end
    end
    local function stepSpin()
        local now = tick()
        local dt = math.clamp(now - lastSpinT, 0, 0.05)
        lastSpinT = now

        spinAngle = spinAngle + dt * 0.28 * math.pi * 2
        if spinAngle > math.pi * 2 then spinAngle = spinAngle % (math.pi * 2) end
        return spinAngle
    end
    return function(radius, visible, opacity, silentRadius, silentVisible)
        opacity = opacity or 0.5
        local style = (Settings.Aimbot and Settings.Aimbot.FOVStyle) or "Circle"
        local cam = S.Workspace.CurrentCamera
        local center = cam and (cam.ViewportSize / 2) or Vector2.new(0, 0)
        local thick = 1.5
        local dotN = math.clamp(math.floor(tonumber(Settings.Aimbot and Settings.Aimbot.FOVDots) or 12), 4, maxDots)
        local dotSz = 2.5
        local spin = stepSpin()
        if useDrawing and fovDrawing then
            fovDrawing.Color = fovWhite
            if not cam or not visible then
                fovDrawing.Visible = false
                hideDots()
            elseif style == "Dots" then
                fovDrawing.Visible = false
                for i = 1, maxDots do
                    local d = fovDots[i]
                    if not d then break end
                    if i <= dotN then
                        local ang = spin + (i - 1) * ((math.pi * 2) / dotN)
                        d.Position = Vector2.new(center.X + math.cos(ang) * radius, center.Y + math.sin(ang) * radius)
                        d.Radius = dotSz
                        d.Color = fovWhite
                        d.Transparency = 1 - opacity
                        d.Visible = true
                    else
                        d.Visible = false
                    end
                end
            else
                hideDots()
                fovDrawing.Position = center
                fovDrawing.Radius = radius
                fovDrawing.Thickness = thick
                fovDrawing.Visible = true
                fovDrawing.Transparency = 1 - opacity
            end
            if silentDrawing then
                silentDrawing.Color = fovWhite
                silentDrawing.Position = center
                silentDrawing.Radius = silentRadius or (radius * 0.6)
                silentDrawing.Visible = (silentVisible and true or false) and style ~= "Dots"
                silentDrawing.Transparency = 1 - math.clamp(opacity * 0.75, 0.2, 0.9)
            end
        elseif fovGui then
            if fovStroke then fovStroke.Color = fovWhite end
            if not visible then
                fovGui.Visible = false
                hideDots()
            elseif style == "Dots" then
                fovGui.Visible = false
                for i = 1, maxDots do
                    local d = fovDots[i]
                    if not d then break end
                    if i <= dotN then
                        local ang = spin + (i - 1) * ((math.pi * 2) / dotN)
                        d.Position = UDim2.fromOffset(center.X + math.cos(ang) * radius, center.Y + math.sin(ang) * radius)
                        d.Size = UDim2.fromOffset(5, 5)
                        d.BackgroundColor3 = fovWhite
                        d.BackgroundTransparency = 1 - opacity
                        d.Visible = true
                    else
                        d.Visible = false
                    end
                end
            else
                hideDots()
                local diameter = radius * 2
                fovGui.Size = UDim2.new(0, diameter, 0, diameter)
                fovGui.Visible = true
                if fovStroke then
                    fovStroke.Thickness = thick
                    fovStroke.Transparency = 1 - opacity
                end
            end
            if silentGui then
                if silentStroke then silentStroke.Color = fovWhite end
                silentGui.Visible = (silentVisible and true or false) and style ~= "Dots"
                if silentVisible and style ~= "Dots" then
                    local sd = (silentRadius or (radius * 0.6)) * 2
                    silentGui.Size = UDim2.new(0, sd, 0, sd)
                end
            end
        end
    end
end
function UILib.mountESPPreview(makeFloat, winW, winH)
    return nil
end
function UILib.setupWorldOverlays(overlayLayer)
    local updateFOV = UILib.createFOVRenderer(overlayLayer)
    local tracerCont = UILib.newFrame(overlayLayer, {Name = MW_T.next(8), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 1})
    local TPOOL = 24; local tPool = {}; local tIdx = 0
    for i = 1, TPOOL do local l = Instance.new("Frame"); l.BackgroundColor3 = Color3.new(1, 1, 1); l.BorderSizePixel = 0; l.AnchorPoint = Vector2.new(0.5, 0.5); l.Visible = false; l.ZIndex = 2; l.Parent = tracerCont; tPool[i] = l end
    local function resetTracers() for i = 1, tIdx do tPool[i].Visible = false end; tIdx = 0 end
    local function getTracerLine() tIdx = tIdx + 1; if tIdx > TPOOL then tIdx = TPOOL; return nil end; return tPool[tIdx] end
    local skelCont = UILib.newFrame(overlayLayer, {Name = MW_T.next(8), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 1})
    local SPOOL = 420; local sPool = {}; local sIdx = 0
    for i = 1, SPOOL do local l = Instance.new("Frame"); l.BackgroundColor3 = Color3.new(1, 1, 1); l.BorderSizePixel = 0; l.AnchorPoint = Vector2.new(0.5, 0.5); l.Visible = false; l.ZIndex = 2; l.Parent = skelCont; sPool[i] = l end
    local function resetSkel() for i = 1, sIdx do sPool[i].Visible = false end; sIdx = 0 end
    local function getSkelLine() sIdx = sIdx + 1; if sIdx > SPOOL then return nil end; return sPool[sIdx] end
    local box2DCont = UILib.newFrame(overlayLayer, {Name = MW_T.next(8), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 2})
    local BPOOL = 192; local bPool = {}; local bIdx = 0
    for i = 1, BPOOL do
        local l = Instance.new("Frame"); l.BackgroundColor3 = Color3.new(1, 1, 1); l.BorderSizePixel = 0
        l.AnchorPoint = Vector2.new(0.5, 0.5); l.Visible = false; l.ZIndex = 3; l.Parent = box2DCont; bPool[i] = l
    end
    local function resetBox2D() for i = 1, bIdx do bPool[i].Visible = false end; bIdx = 0 end
    local function getBox2DLine() bIdx = bIdx + 1; if bIdx > BPOOL then bIdx = BPOOL; return nil end; return bPool[bIdx] end
    local function drawBox2DLine(x1, y1, x2, y2, col, thick, tr)
        local line = getBox2DLine(); if not line then return end
        local a, b = Vector2.new(x1, y1), Vector2.new(x2, y2)
        local ld = (b - a).Magnitude; local ctr = (a + b) / 2
        local ang = math.atan2(b.Y - a.Y, b.X - a.X)
        line.Size = UDim2.new(0, ld, 0, thick); line.Position = UDim2.new(0, ctr.X, 0, ctr.Y)
        line.Rotation = math.deg(ang); line.BackgroundColor3 = col
        line.BackgroundTransparency = tr or 0
        line.Visible = true
    end
    local function drawCornerBox2D(minX, minY, maxX, maxY, col, thick, cornerFrac, tr)
        local w, h = maxX - minX, maxY - minY
        local cl = math.max(7, math.min(w, h) * (cornerFrac or 0.28))
        drawBox2DLine(minX, minY, minX + cl, minY, col, thick, tr)
        drawBox2DLine(minX, minY, minX, minY + cl, col, thick, tr)
        drawBox2DLine(maxX, minY, maxX - cl, minY, col, thick, tr)
        drawBox2DLine(maxX, minY, maxX, minY + cl, col, thick, tr)
        drawBox2DLine(minX, maxY, minX + cl, maxY, col, thick, tr)
        drawBox2DLine(minX, maxY, minX, maxY - cl, col, thick, tr)
        drawBox2DLine(maxX, maxY, maxX - cl, maxY, col, thick, tr)
        drawBox2DLine(maxX, maxY, maxX, maxY - cl, col, thick, tr)
    end
    local function drawFullBox2D(minX, minY, maxX, maxY, col, thick, tr)
        drawBox2DLine(minX, minY, maxX, minY, col, thick, tr)
        drawBox2DLine(maxX, minY, maxX, maxY, col, thick, tr)
        drawBox2DLine(maxX, maxY, minX, maxY, col, thick, tr)
        drawBox2DLine(minX, maxY, minX, minY, col, thick, tr)
    end
    local fill2DCont = UILib.newFrame(overlayLayer, {Name = MW_T.next(8), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 1})
    local FPOOL = 24; local fPool = {}; local fIdx = 0
    for i = 1, FPOOL do
        local f = Instance.new("Frame"); f.BorderSizePixel = 0; f.Visible = false; f.ZIndex = 1; f.Parent = fill2DCont; fPool[i] = f
    end
    local function resetBoxFill() for i = 1, fIdx do fPool[i].Visible = false end; fIdx = 0 end
    local function drawBoxFill2D(minX, minY, maxX, maxY, col, tr)
        fIdx = fIdx + 1; if fIdx > FPOOL then fIdx = FPOOL; return end
        local f = fPool[fIdx]; f.Size = UDim2.new(0, maxX - minX, 0, maxY - minY); f.Position = UDim2.new(0, minX, 0, minY)
        f.BackgroundColor3 = col; f.BackgroundTransparency = tr or 0.75; f.Visible = true
    end
    local hpBarCont = UILib.newFrame(overlayLayer, {Name = MW_T.next(8), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 2})
    local HPOOL = 40; local hPool = {}; local hIdx = 0
    for i = 1, HPOOL do
        local bg = Instance.new("Frame"); bg.BorderSizePixel = 0; bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20); bg.BackgroundTransparency = 0.35; bg.Visible = false; bg.ZIndex = 2; bg.Parent = hpBarCont
        local fill = Instance.new("Frame"); fill.BorderSizePixel = 0; fill.AnchorPoint = Vector2.new(0, 1); fill.Position = UDim2.new(0, 0, 1, 0); fill.Parent = bg
        hPool[i] = {bg = bg, fill = fill}
    end
    local function resetHealthBars() for i = 1, hIdx do hPool[i].bg.Visible = false end; hIdx = 0 end
    local function drawHealthBar2D(minX, minY, maxX, maxY, hp, maxhp, fade)
        hIdx = hIdx + 1; if hIdx > HPOOL then hIdx = HPOOL; return end
        local bar = hPool[hIdx]; local h = math.max(8, maxY - minY); local w = 3
        bar.bg.Size = UDim2.new(0, w, 0, h); bar.bg.Position = UDim2.new(0, minX - w - 5, 0, minY)
        bar.bg.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
        bar.bg.BackgroundTransparency = 0.25 + (fade or 0) * 0.35
        bar.bg.Visible = true
        local pct = math.clamp(hp / math.max(maxhp, 1), 0, 1)
        local col = Settings.ESP.HealthBased and getHealthColor(pct) or getHeadDotColor()
        bar.fill.Size = UDim2.new(1, 0, pct, 0); bar.fill.BackgroundColor3 = col
        bar.fill.BackgroundTransparency = 0.02 + (fade or 0) * 0.25
    end
    local dotCont = UILib.newFrame(overlayLayer, {Name = MW_T.next(8), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 3})
    local DPOOL = 24; local dPool = {}; local dIdx = 0
    for i = 1, DPOOL do
        local d = Instance.new("Frame"); d.Size = UDim2.new(0, 6, 0, 6); d.AnchorPoint = Vector2.new(0.5, 0.5); d.BorderSizePixel = 0; d.Visible = false; d.ZIndex = 3; d.Parent = dotCont
        UILib.circle(d)
        local ds = UILib.stroke(d, Color3.fromRGB(0, 0, 0), 1, 0.35)
        dPool[i] = {frame = d, stroke = ds}
    end
    local function resetHeadDots() for i = 1, dIdx do dPool[i].frame.Visible = false end; dIdx = 0 end
    local function drawHeadDot(x, y, col, sz)
        dIdx = dIdx + 1; if dIdx > DPOOL then dIdx = DPOOL; return end
        local entry = dPool[dIdx]
        local d = entry.frame
        local s = math.max(4, sz or 6)
        d.Size = UDim2.new(0, s, 0, s); d.Position = UDim2.new(0, x, 0, y)
        d.BackgroundColor3 = col; d.BackgroundTransparency = 0.05; d.Visible = true
        if entry.stroke then entry.stroke.Color = Color3.fromRGB(0, 0, 0) end
    end
    local arrowCont = UILib.newFrame(overlayLayer, {Name = MW_T.next(8), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 3})
    local APOOL = 16; local aPool = {}
    for i = 1, APOOL do
        local c = UILib.newFrame(arrowCont, {
            Size = UDim2.new(0, 52, 0, 64),
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Visible = false,
            ZIndex = 4,
        })
        local ring = UILib.newFrame(c, {
            Size = UDim2.new(0, 40, 0, 40),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.42, 0),
            BackgroundColor3 = Theme.CardBg,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            ZIndex = 2,
        })
        ring.ClipsDescendants = true
        UILib.circle(ring)
        local ringStroke = UILib.stroke(ring, Theme.TextAccent, 2, 0.05)
        local pfp = Instance.new("ImageLabel")
        pfp.Name = MW_T.next(8)
        pfp.Size = UDim2.new(1, -4, 1, -4)
        pfp.Position = UDim2.new(0.5, 0, 0.5, 0)
        pfp.AnchorPoint = Vector2.new(0.5, 0.5)
        pfp.BackgroundTransparency = 1
        pfp.ScaleType = Enum.ScaleType.Crop
        pfp.ZIndex = 3
        pfp.Parent = ring
        UILib.circle(pfp)
        local tip = UILib.newFrame(c, {
            Size = UDim2.new(0, 9, 0, 9),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.12, 0),
            BackgroundColor3 = Theme.TextAccent,
            BorderSizePixel = 0,
            Rotation = 45,
            ZIndex = 5,
        })
        local dl = UILib.newLabel(c, {
            Size = UDim2.new(1, 0, 0, 12),
            Position = UDim2.new(0, 0, 1, -11),
            Text = "",
            TextSize = 9,
            Font = Enum.Font.GothamBold,
            TextStrokeTransparency = 0.35,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 6,
        })
        aPool[i] = {
            container = c,
            ring = ring,
            ringStroke = ringStroke,
            pfp = pfp,
            tip = tip,
            distLabel = dl,
            lastUserId = nil,
            inUse = false,
        }
    end
    local aActiveCount = 0
    local function resetArrows()
        for i = 1, aActiveCount do
            aPool[i].container.Visible = false
            aPool[i].inUse = false
            aPool[i].lastUserId = nil
        end
        aActiveCount = 0
    end
    local function getArrow()
        aActiveCount = aActiveCount + 1
        if aActiveCount > APOOL then aActiveCount = APOOL; return nil end
        local ad = aPool[aActiveCount]
        ad.container.Visible = true
        ad.inUse = true
        return ad
    end
    local function updateOffscreenArrow(ad, target, col, ang, ax, ay, dist)
        local sz = math.max(22, Settings.ESP.ArrowSize or 28)
        local showPfp = (Settings.ESP.ArrowShowPfp ~= false) and not isStreamerActive()
        local ringSize = sz + 10
        ad.container.Size = UDim2.new(0, ringSize + 18, 0, ringSize + 26)
        ad.container.Position = UDim2.new(0, ax, 0, ay)
        ad.ring.Size = UDim2.new(0, ringSize, 0, ringSize)
        ad.ring.Position = UDim2.new(0.5, 0, 0.42, 0)
        ad.ring.BackgroundColor3 = Theme.CardBg or Color3.fromRGB(12, 12, 14)
        ad.ringStroke.Color = col
        ad.ringStroke.Thickness = 2
        if showPfp then
            ad.pfp.Visible = true
            if ad.lastUserId ~= target.UserId then
                ad.lastUserId = target.UserId
                ad.pfp.Image = ""
            end
            if ad.pfp.Image == "" then
                local thumb = getPlayerThumb(target.UserId)
                if thumb ~= "" then ad.pfp.Image = thumb end
            end
        else
            ad.pfp.Visible = false
            ad.ring.BackgroundColor3 = col
            ad.ring.BackgroundTransparency = 0.25
        end
        if showPfp then ad.ring.BackgroundTransparency = 0.08 end
        local tipR = ringSize * 0.5 + 5
        ad.tip.BackgroundColor3 = col
        ad.tip.Position = UDim2.new(0.5, math.sin(ang) * tipR, 0.42, -math.cos(ang) * tipR)
        ad.tip.Rotation = 45
        ad.tip.Visible = true
        ad.distLabel.Text = math.floor(dist) .. "m"
        ad.distLabel.TextColor3 = col
    end
    overlayResetFn = function()
        resetTracers(); resetSkel(); resetArrows(); resetBox2D(); resetBoxFill(); resetHealthBars(); resetHeadDots()
    end
    local radarCorner = nil
    local radarStroke = nil
    local radarBgGrad = nil
    local radarRingStrokes = {}
    local function applyRadarStyle()
        if not radarGui then return end
        if Settings.Radar.Type == "3D" then
            if radarCorner then radarCorner.CornerRadius = UDim.new(0, 10) end
            radarGui.BackgroundTransparency = 1
            if radarBg then
                pcall(function()
                    local c = radarBg:FindFirstChildOfClass("UICorner")
                    if c then c.CornerRadius = UDim.new(0, 10) end
                end)
            end

            for i, rs in ipairs(radarRingStrokes) do
                rs.Transparency = 0.72 - i * 0.04
            end
        else
            if radarCorner then radarCorner.CornerRadius = UDim.new(1, 0) end
            radarGui.BackgroundTransparency = 1
            if radarBg then
                pcall(function()
                    local c = radarBg:FindFirstChildOfClass("UICorner")
                    if c then c.CornerRadius = UDim.new(1, 0) end
                end)
            end
            for i, rs in ipairs(radarRingStrokes) do
                rs.Transparency = 0.82 - i * 0.06
            end
        end
    end
    local radarSize = Settings.Radar.Size
    local radarGui = UILib.newFrame(overlayLayer, {
        Name = MW_T.radar,
        Size = UDim2.new(0, radarSize, 0, radarSize),
        Position = UDim2.new(0, 14, 1, -radarSize - 14),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 4,
    })
    radarCorner = UILib.corner(radarGui, 100)
    radarStroke = UILib.stroke(radarGui, Theme.RadarBorder, 2, 0.12)
    UILib.shadow(radarGui, 16, 0.55)
    local radarBg = UILib.newFrame(radarGui, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    UILib.corner(radarBg, 100)
    radarBgGrad = UILib.gradient(radarBg, Theme.RadarBg, shiftColor(Theme.RadarBg, -0.04, -0.04, -0.05), 135)
    radarBgGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.08),
        NumberSequenceKeypoint.new(1, 0.22),
    })
    for i, scale in ipairs({0.34, 0.66, 0.94}) do
        local ring = UILib.newFrame(radarGui, {
            Size = UDim2.new(scale, 0, scale, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 2,
        })
        UILib.corner(ring, 100)
        local ringStroke = UILib.stroke(ring, Color3.fromRGB(255, 255, 255), 1, 0.82 - i * 0.06)
        radarRingStrokes[i] = ringStroke
    end
    local function makeCrossLine(w, h, x, y, rot)
        local line = UILib.newFrame(radarGui, {
            Size = UDim2.new(0, w, 0, h),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, x, 0.5, y),
            Rotation = rot or 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.88,
            BorderSizePixel = 0,
            ZIndex = 2,
        })
        return line
    end
    makeCrossLine(radarSize - 12, 1, 0, 0, 0)
    makeCrossLine(1, radarSize - 12, 0, 0, 0)
    local northLbl = UILib.newLabel(radarGui, {
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 8),
        Text = "N",
        TextColor3 = Theme.TextAccent,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        ZIndex = 3,
        Name = MW_T.next(8),
    })
    local selfDot = UILib.newFrame(radarGui, {
        Size = UDim2.new(0, 8, 0, 8),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Settings.Radar.SelfColor,
        BorderSizePixel = 0,
        ZIndex = 5,
    })
    UILib.corner(selfDot, 100)
    UILib.stroke(selfDot, Theme.TextAccent, 1, 0.35)
    local selfHeading = UILib.newFrame(radarGui, {
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5,
        Name = MW_T.next(8),
    })
    UILib.newLabel(selfHeading, {
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 0, -6),
        Text = "?",
        TextColor3 = Settings.Radar.SelfColor,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
    })
    table.insert(themeCallbacks, function()
        if radarStroke then radarStroke.Color = Theme.RadarBorder end
        if radarBgGrad then
            radarBgGrad.Color = ColorSequence.new(Theme.RadarBg, shiftColor(Theme.RadarBg, -0.04, -0.04, -0.05))
        end
        for _, rs in ipairs(radarRingStrokes) do
            rs.Color = shiftColor(Theme.TextAccent, -0.15, -0.15, -0.15)
        end
        northLbl.TextColor3 = Theme.TextAccent
    end)
    applyRadarStyle()
    local radarDots = {}
    local radarNameLabels = {}
    local radarDotGlows = {}
    local radarAltLabels = {}
    local function setRadarVisible(on)
        if not radarGui then return end
        radarGui.Visible = on
        if not on then
            for _, dot in pairs(radarDots) do dot.Visible = false end
            for _, lbl in pairs(radarNameLabels) do lbl.Visible = false end
            for _, lbl in pairs(radarAltLabels) do lbl.Visible = false end
        end
    end
    _G[MW_T.radarApi] = { setVisible = setRadarVisible, applyStyle = applyRadarStyle }

    VisPerf.espRt = {
        updateFOV = updateFOV,
        resetTracers = resetTracers,
        resetSkel = resetSkel,
        resetArrows = resetArrows,
        resetBox2D = resetBox2D,
        resetBoxFill = resetBoxFill,
        resetHealthBars = resetHealthBars,
        resetHeadDots = resetHeadDots,
        getTracerLine = getTracerLine,
        getSkelLine = getSkelLine,
        getArrow = getArrow,
        updateOffscreenArrow = updateOffscreenArrow,
        drawBoxFill2D = drawBoxFill2D,
        drawCornerBox2D = drawCornerBox2D,
        drawHealthBar2D = drawHealthBar2D,
        drawHeadDot = drawHeadDot,
        setRadarVisible = setRadarVisible,
        radarDots = radarDots,
        radarDotGlows = radarDotGlows,
        radarNameLabels = radarNameLabels,
        radarAltLabels = radarAltLabels,
        selfHeading = selfHeading,
        northLbl = northLbl,
        radarGui = radarGui,
        lastEspOn = false,
        targetHL = nil,
    }
    destroyTargetHLFn = function()
        local rt = VisPerf.espRt
        if rt and rt.targetHL then pcall(function() rt.targetHL:Destroy() end); rt.targetHL = nil end
    end
    table.insert(allConnections,S.RunService.RenderStepped:Connect(function(dt)
        local rt = VisPerf.espRt
        local updateFOV, resetTracers, resetSkel, resetArrows = rt.updateFOV, rt.resetTracers, rt.resetSkel, rt.resetArrows
        local resetBox2D, resetBoxFill, resetHealthBars, resetHeadDots = rt.resetBox2D, rt.resetBoxFill, rt.resetHealthBars, rt.resetHeadDots
        local getTracerLine, getSkelLine, getArrow, updateOffscreenArrow = rt.getTracerLine, rt.getSkelLine, rt.getArrow, rt.updateOffscreenArrow
        local drawBoxFill2D, drawCornerBox2D, drawHealthBar2D, drawHeadDot = rt.drawBoxFill2D, rt.drawCornerBox2D, rt.drawHealthBar2D, rt.drawHeadDot
        local setRadarVisible = rt.setRadarVisible
        local radarDots, radarDotGlows = rt.radarDots, rt.radarDotGlows
        local radarNameLabels, radarAltLabels = rt.radarNameLabels, rt.radarAltLabels
        local selfHeading, northLbl, radarGui = rt.selfHeading, rt.northLbl, rt.radarGui
        if isUnloading or _G[MW_T.unloaded] then return end
        UILib.sampleVisualFps(dt)
        UILib.refreshVSyncLock()
        local espOn=Settings.ESP.Enabled
        local tracerOn=espOn and Settings.ESP.TracerEnabled and not VisPerf.lockTracers
        local skelOn=espOn and Settings.ESP.SkeletonEnabled
        local headDotOn=espOn and Settings.ESP.HeadDotEnabled
        local arrowOn=espOn and Settings.ESP.OffscreenArrows and not VisPerf.lockArrows
        local radarOn = Settings.Radar.Enabled and not RADAR_TEMP_DISABLED
        if not radarOn then setRadarVisible(false) end
        local boxStyle=getESPBoxStyle()
        local box2DOn=espOn and (boxStyle=="2D" or boxStyle=="Both" or boxStyle=="Corner")
        local box3DOn=espOn and (boxStyle=="3D" or boxStyle=="Both") and not VisPerf.lockBox3D
        local fovOn=Settings.Aimbot.Enabled and Settings.Aimbot.ShowFOV
        local silentOn = Settings.Aimbot.ShowSilentFOV and (
            Settings.Aimbot.Enabled
            or (MW.isPF and Settings.PF and Settings.PF.SilentAim ~= false)
        )
        local silentR = (MW.isPF and Settings.PF and Settings.PF.SilentFOV) or Settings.Aimbot.SilentFOVRadius or 90
        updateFOV(getAimFOVRadius(), fovOn, Settings.Aimbot.FOVOpacity, silentR, silentOn)
        if currentTarget and currentTarget.Character and isTracking and Settings.Aimbot.Enabled then
            if not rt.targetHL then rt.targetHL=Instance.new("Highlight"); rt.targetHL.Name=MW_T.lock; rt.targetHL.FillColor=Theme.CardHeaderBg; rt.targetHL.FillTransparency=0.7; rt.targetHL.OutlineColor=Theme.TextAccent; rt.targetHL.OutlineTransparency=0; rt.targetHL.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop end
            rt.targetHL.Parent=currentTarget.Character
        else destroyTargetHLFn() end
        if not espOn then
            if rt.lastEspOn then clearAllESP() end
            rt.lastEspOn=false
            resetTracers(); resetSkel(); resetArrows(); resetBox2D(); resetBoxFill(); resetHealthBars(); resetHeadDots()
            VisPerf.lastOverlay = 0
            VisPerf.lastHeavy = 0
            local needWorldVis = radarOn or Settings.ESP.ThrowableEnabled or Settings.ESP.ThrowableArcPreview
                or Settings.Visuals.ThirdPerson or Settings.Visuals.GunWireframeEnabled or Settings.Visuals.ViewmodelFOVEnabled
            if not needWorldVis then return end
        else
            rt.lastEspOn=true
        end
        local cam=S.Workspace.CurrentCamera; if not cam then return end
        local myChar=getWorldCharacter(player) or player.Character
        local myHRP=myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar:FindFirstChildWhichIsA("BasePart"))
        local myPos = (myHRP and myHRP.Position) or cam.CFrame.Position
        if not myPos then return end
        local camCF=cam.CFrame; UILib.noteCameraMotion(camCF)
        local ss=cam.ViewportSize; local allPlayers=S.Players:GetPlayers()
        local espNow = tick()
        local overlayIv, heavyIv, miscIv, losIv, radarIv = UILib.getVisualTickIntervals()
        local pcCount = #allPlayers
        if pcCount > 22 then
            overlayIv = overlayIv * 2.1
            heavyIv = heavyIv * 2.0
        elseif pcCount > 14 then
            overlayIv = overlayIv * 1.55
            heavyIv = heavyIv * 1.5
        elseif pcCount > 8 then
            overlayIv = overlayIv * 1.2
            heavyIv = heavyIv * 1.15
        end
        local fpsNow = VisPerf.fps or 60
        if fpsNow < 40 then
            overlayIv = overlayIv * 1.6
            heavyIv = heavyIv * 1.7
        elseif fpsNow < 55 then
            overlayIv = overlayIv * 1.25
            heavyIv = heavyIv * 1.3
        end
        local doOverlay = Settings.Visuals.VSync or ((espNow - VisPerf.lastOverlay) >= overlayIv)
        local doHeavy = (espNow - VisPerf.lastHeavy) >= heavyIv
        local doRadar = radarOn and ((espNow - (VisPerf.lastRadar or 0)) >= radarIv)
        if doOverlay then VisPerf.lastOverlay = espNow end
        if doHeavy then VisPerf.lastHeavy = espNow end
        if doRadar then VisPerf.lastRadar = espNow end
        local needsOverlay = espOn and (box2DOn or tracerOn or skelOn or headDotOn or arrowOn or Settings.ESP.HealthBar)
        if needsOverlay and doOverlay then
            resetTracers(); resetSkel(); resetArrows(); resetBox2D(); resetBoxFill(); resetHealthBars(); resetHeadDots()
        end
        local tracerSP
        if tracerOn then
            local origin = Settings.ESP.TracerOrigin or "Bottom"
            if origin == "Top" then
                tracerSP = Vector2.new(ss.X / 2, 2)
            elseif origin == "Center" then
                tracerSP = Vector2.new(ss.X / 2, ss.Y / 2)
            elseif origin == "Mouse" then
                local m = S.UserInputService:GetMouseLocation()
                local inset = Vector2.new(0, 0)
                pcall(function() inset = game:GetService("GuiService"):GetGuiInset() end)
                tracerSP = Vector2.new(m.X - inset.X, m.Y - inset.Y)
            else
                tracerSP = Vector2.new(ss.X / 2, ss.Y)
            end
        end
        local camYaw,rh,radarScale,radarRange
        if radarOn then
            setRadarVisible(true)
            camYaw = Settings.Radar.RotateWithCamera and math.atan2(-camCF.LookVector.X, -camCF.LookVector.Z) or 0
            rh = Settings.Radar.Size / 2
            radarScale = Settings.Radar.Scale
            radarRange = Settings.Radar.Range
            local maxR = rh * 0.9 * radarScale
            selfHeading.Rotation = Settings.Radar.RotateWithCamera and math.deg(-camYaw) or 0
            northLbl.Visible = Settings.Radar.RotateWithCamera
            if Settings.Radar.RotateWithCamera then
                northLbl.Rotation = math.deg(-camYaw)
            else
                northLbl.Rotation = 0
            end
            if doRadar then
                local activeIds = {}
                for _, t in ipairs(allPlayers) do activeIds[t.UserId] = true end
                for uid, dot in pairs(radarDots) do
                    if not activeIds[uid] then
                        dot:Destroy()
                        radarDots[uid] = nil
                        radarDotGlows[uid] = nil
                        if radarNameLabels[uid] then radarNameLabels[uid]:Destroy(); radarNameLabels[uid] = nil end
                        if radarAltLabels[uid] then radarAltLabels[uid]:Destroy(); radarAltLabels[uid] = nil end
                    end
                end
            end
        else
            setRadarVisible(false)
        end
        local rainbowCol=(espOn and Settings.ESP.RainbowColor) and Color3.fromHSV(tick()%5/5,1,1) or nil
        local espActiveThisFrame = {}
        local function hasLOSCached(targetPlayer)
            if not Settings.ESP.VisibleCheck then return true end
            local uid = targetPlayer.UserId
            local cached = espLosCache[uid]
            if cached and (espNow - cached.t) < losIv then
                return cached.ok
            end
            local ok = hasLOS(player, targetPlayer)
            espLosCache[uid] = { t = espNow, ok = ok }
            return ok
        end
        for _,target in ipairs(allPlayers) do
          repeat
            local isSelf = target == player
            if isSelf then
                if not espOn or not Settings.ESP.SelfESP then break end
            end
            local rd, tc, tRoot
            if MW.isPF and MW.TracePF and MW.TracePF.getRig then
                rd = MW.TracePF.getRig(target)
                if rd then
                    tc = rd._char
                    tRoot = rd.root
                end
            else
                tc = getWorldCharacter(target)
                rd = getRig(target)
                tRoot = rd and rd.root or (tc and (tc:FindFirstChild("HumanoidRootPart") or tc:FindFirstChild("Torso") or tc:FindFirstChildWhichIsA("BasePart")))
            end
            if not tc or not tRoot then if espObjects[target.UserId] then removeESP(target) end; break end
            local thead = (rd and rd.parts and rd.parts.Head) or (type(tc) == "table" and tc.Head) or (tc.FindFirstChild and tc:FindFirstChild("Head"))
            local hrpPart = (type(tc) == "table" and tc.HumanoidRootPart) or (tc.FindFirstChild and tc:FindFirstChild("HumanoidRootPart")) or tRoot
            local adornee = thead or hrpPart or tRoot
            local hp,maxhp,alive
            if rd then hp=rd.getHealth(); maxhp=rd.getMaxHealth(); alive=rd.isAlive()
            else local thum=tc:FindFirstChild("Humanoid"); if not thum then if espObjects[target.UserId] then removeESP(target) end; break end; hp=thum.Health; maxhp=thum.MaxHealth; alive=thum.Health>0 end
            if not alive then if espObjects[target.UserId] then removeESP(target) end; break end
            local tPos=tRoot.Position; local dist=(myPos-tPos).Magnitude; local col=rainbowCol or getESPColor(dist)
            local boxCol=getESPPartColor("BoxHex", Theme.ESP_Box, dist, rainbowCol)
            local tracerCol=getESPPartColor("TracerHex", Theme.ESP_Tracer, dist, rainbowCol)
            local skelPartCol=getESPPartColor("SkeletonHex", Theme.ESP_Skeleton, dist, rainbowCol)
            local chamsCol=getESPPartColor("ChamsHex", Theme.ESP_Chams, dist, rainbowCol)
            local nameCol=getESPPartColor("NameHex", Theme.ESP_Name, dist, rainbowCol)
            if MW.isPF and Settings.PF and Settings.PF.TeamColors ~= false and not rainbowCol then
                local teamCol = MW.TracePF and MW.TracePF.getTeamColor and MW.TracePF.getTeamColor(target)
                if teamCol then
                    col = teamCol
                    boxCol = teamCol
                    tracerCol = teamCol
                    skelPartCol = teamCol
                    chamsCol = teamCol
                    nameCol = teamCol
                end
            end
            local skipFarHeavy = dist > (VisPerf.farHeavy or 240)
            VisPerf.skipFarHeavy = skipFarHeavy
            if espOn and dist > Settings.ESP.RenderDistance then
                if espObjects[target.UserId] then hideESPVisuals(espObjects[target.UserId]) end
                break
            end
            if espOn and Settings.ESP.VisibleCheck and not isSelf and not hasLOSCached(target) then
                if espObjects[target.UserId] then hideESPVisuals(espObjects[target.UserId]) end
                break
            end
            if radarOn and doRadar and isValidRadarTarget(player, target) then
                local rel = tPos - myPos
                local flatDist = Vector3.new(rel.X, 0, rel.Z).Magnitude
                local heightDiff = rel.Y
                local is3D = Settings.Radar.Type == "3D"
                local rangeDist = is3D and math.max(flatDist, math.abs(heightDiff) * 0.55) or flatDist
                local inRange = rangeDist <= radarRange
                local showBlip = inRange or (Settings.Radar.ShowOffRange and rangeDist <= radarRange * 1.75)
                if showBlip then
                    local ang
                    if Settings.Radar.RotateWithCamera then
                        ang = math.atan2(rel.X, rel.Z) - camYaw
                    else
                        ang = math.atan2(rel.X, rel.Z)
                    end
                    local distNorm = inRange and (flatDist / math.max(radarRange, 1)) or 1
                    if is3D then

                        local heightNorm = math.clamp(heightDiff / math.max(radarRange * 0.55, 1), -1.15, 1.15)
                        distNorm = distNorm * (1 - math.clamp(math.abs(heightNorm) * 0.18, 0, 0.35))
                        local nx = math.sin(ang) * distNorm * rh * radarScale
                        local ny = -math.cos(ang) * distNorm * rh * radarScale - heightNorm * (rh * 0.38)
                        nx, ny = UILib.clampRadarPoint(nx, ny, rh * 0.92 * radarScale)
                        local px = rh + nx
                        local py = rh + ny
                        local isTeam = isSameTeam(player, target)
                        local dotCol = isTeam and Settings.Radar.TeamColor or Settings.Radar.EnemyColor
                        if not inRange then
                            dotCol = shiftColor(dotCol, -0.12, -0.12, -0.1)
                        end
                        if not radarDots[target.UserId] then
                            local dot = UILib.newFrame(radarGui, {
                                Size = UDim2.new(0, 6, 0, 6),
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BorderSizePixel = 0,
                                ZIndex = 6,
                            })
                            UILib.corner(dot, 2)
                            local glow = UILib.stroke(dot, dotCol, 2, 0.55)
                            radarDots[target.UserId] = dot
                            radarDotGlows[target.UserId] = glow
                        end
                        local dot = radarDots[target.UserId]
                        local glow = radarDotGlows[target.UserId]
                        dot.Visible = true
                        local depthScale = math.clamp(1.2 - (flatDist / math.max(radarRange, 1)) * 0.5 + heightNorm * 0.12, 0.55, 1.45)
                        local dotSize = math.max(4, math.floor((heightDiff > 6 and 7 or 6) * depthScale))

                        pcall(function()
                            local c = dot:FindFirstChildOfClass("UICorner")
                            if c then c.CornerRadius = UDim.new(0, math.abs(heightDiff) > 8 and 2 or 100) end
                        end)
                        dot.Size = UDim2.new(0, dotSize, 0, dotSize)
                        dot.BackgroundColor3 = dotCol
                        dot.BackgroundTransparency = inRange and 0 or 0.35
                        dot.Position = UDim2.new(0, px, 0, py)
                        if glow then glow.Color = dotCol; glow.Transparency = inRange and 0.45 or 0.7 end
                        if Settings.Radar.ShowAltitude ~= false then
                            if not radarAltLabels[target.UserId] then
                                local alt = UILib.newLabel(radarGui, {
                                    Size = UDim2.new(0, 10, 0, 10),
                                    BackgroundTransparency = 1,
                                    TextSize = 9,
                                    Font = Enum.Font.GothamBold,
                                    TextStrokeTransparency = 0.2,
                                    TextStrokeColor3 = Color3.new(0, 0, 0),
                                    ZIndex = 8,
                                    TextXAlignment = Enum.TextXAlignment.Center,
                                })
                                radarAltLabels[target.UserId] = alt
                            end
                            local alt = radarAltLabels[target.UserId]
                            if math.abs(heightDiff) > 4 then
                                alt.Text = heightDiff > 0 and "^" or "v"
                                alt.TextColor3 = dotCol
                                alt.Position = UDim2.new(0, px - 5, 0, py - dotSize - 8)
                                alt.Visible = true
                            else
                                alt.Visible = false
                            end
                        elseif radarAltLabels[target.UserId] then
                            radarAltLabels[target.UserId].Visible = false
                        end
                        if Settings.Radar.ShowNames or Settings.Radar.ShowDistance then
                            if not radarNameLabels[target.UserId] then
                                local lbl = UILib.newLabel(radarGui, {
                                    Size = UDim2.new(0, 56, 0, 11),
                                    BackgroundTransparency = 1,
                                    TextSize = 8,
                                    Font = Enum.Font.GothamBold,
                                    TextStrokeTransparency = 0.25,
                                    TextStrokeColor3 = Color3.new(0, 0, 0),
                                    ZIndex = 7,
                                    TextXAlignment = Enum.TextXAlignment.Center,
                                })
                                radarNameLabels[target.UserId] = lbl
                            end
                            local lbl = radarNameLabels[target.UserId]
                            local nameTxt = Settings.Radar.ShowNames and getDisplayName(target):sub(1, 10) or ""
                            local distTxt = Settings.Radar.ShowDistance and (math.floor(flatDist) .. "m") or ""
                            if Settings.Radar.ShowAltitude ~= false and math.abs(heightDiff) > 4 then
                                distTxt = distTxt ~= "" and (distTxt .. " " .. (heightDiff > 0 and "+" or "") .. math.floor(heightDiff)) or ((heightDiff > 0 and "+" or "") .. math.floor(heightDiff))
                            end
                            lbl.Text = Settings.Radar.ShowNames and Settings.Radar.ShowDistance and (nameTxt .. "\n" .. distTxt) or (nameTxt ~= "" and nameTxt or distTxt)
                            lbl.TextColor3 = dotCol
                            lbl.TextTransparency = inRange and 0 or 0.25
                            lbl.Position = UDim2.new(0, px - 28, 0, py + dotSize + 1)
                            lbl.Visible = lbl.Text ~= ""
                        elseif radarNameLabels[target.UserId] then
                            radarNameLabels[target.UserId].Visible = false
                        end
                    else
                    local nx = math.sin(ang) * distNorm * rh * radarScale
                    local ny = -math.cos(ang) * distNorm * rh * radarScale
                    nx, ny = UILib.clampRadarPoint(nx, ny, rh * 0.9 * radarScale)
                    local px = rh + nx
                    local py = rh + ny
                    local isTeam = isSameTeam(player, target)
                    local dotCol = isTeam and Settings.Radar.TeamColor or Settings.Radar.EnemyColor
                    if not inRange then
                        dotCol = shiftColor(dotCol, -0.12, -0.12, -0.1)
                    end
                    if not radarDots[target.UserId] then
                        local dot = UILib.newFrame(radarGui, {
                            Size = UDim2.new(0, 6, 0, 6),
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BorderSizePixel = 0,
                            ZIndex = 6,
                        })
                        UILib.corner(dot, 100)
                        local glow = UILib.stroke(dot, dotCol, 2, 0.55)
                        radarDots[target.UserId] = dot
                        radarDotGlows[target.UserId] = glow
                    end
                    local dot = radarDots[target.UserId]
                    local glow = radarDotGlows[target.UserId]
                    dot.Visible = true
                    local dotScale = inRange and math.clamp(1.25 - (flatDist / radarRange) * 0.45, 0.75, 1.35) or 0.65
                    local dotSize = math.max(4, math.floor(6 * dotScale))
                    pcall(function()
                        local c = dot:FindFirstChildOfClass("UICorner")
                        if c then c.CornerRadius = UDim.new(1, 0) end
                    end)
                    dot.Size = UDim2.new(0, dotSize, 0, dotSize)
                    dot.BackgroundColor3 = dotCol
                    dot.BackgroundTransparency = inRange and 0 or 0.35
                    dot.Position = UDim2.new(0, px, 0, py)
                    if glow then glow.Color = dotCol; glow.Transparency = inRange and 0.45 or 0.7 end
                    if radarAltLabels[target.UserId] then radarAltLabels[target.UserId].Visible = false end
                    if Settings.Radar.ShowNames or Settings.Radar.ShowDistance then
                        if not radarNameLabels[target.UserId] then
                            local lbl = UILib.newLabel(radarGui, {
                                Size = UDim2.new(0, 56, 0, 11),
                                BackgroundTransparency = 1,
                                TextSize = 8,
                                Font = Enum.Font.GothamBold,
                                TextStrokeTransparency = 0.25,
                                TextStrokeColor3 = Color3.new(0, 0, 0),
                                ZIndex = 7,
                                TextXAlignment = Enum.TextXAlignment.Center,
                            })
                            radarNameLabels[target.UserId] = lbl
                        end
                        local lbl = radarNameLabels[target.UserId]
                        local nameTxt = Settings.Radar.ShowNames and getDisplayName(target):sub(1, 10) or ""
                        local distTxt = Settings.Radar.ShowDistance and (math.floor(flatDist) .. "m") or ""
                        lbl.Text = Settings.Radar.ShowNames and Settings.Radar.ShowDistance and (nameTxt .. "\n" .. distTxt) or (nameTxt ~= "" and nameTxt or distTxt)
                        lbl.TextColor3 = dotCol
                        lbl.TextTransparency = inRange and 0 or 0.25
                        lbl.Position = UDim2.new(0, px - 28, 0, py + dotSize + 1)
                        lbl.Visible = lbl.Text ~= ""
                    elseif radarNameLabels[target.UserId] then
                        radarNameLabels[target.UserId].Visible = false
                    end
                    end
                else
                    if radarDots[target.UserId] then radarDots[target.UserId].Visible = false end
                    if radarNameLabels[target.UserId] then radarNameLabels[target.UserId].Visible = false end
                    if radarAltLabels[target.UserId] then radarAltLabels[target.UserId].Visible = false end
                end
            elseif radarOn then
                if radarDots[target.UserId] then radarDots[target.UserId].Visible = false end
                if radarNameLabels[target.UserId] then radarNameLabels[target.UserId].Visible = false end
                if radarAltLabels[target.UserId] then radarAltLabels[target.UserId].Visible = false end
            end
            if not espOn then break end
            local isESPTarget=isValidESPTarget(player,target)
            if not isESPTarget then if espObjects[target.UserId] then removeESP(target) end; break end
            espActiveThisFrame[target.UserId] = true

            local refreshLabels = doHeavy or (not skipFarHeavy and (doOverlay or VisPerf.camMoved))
            if adornee and (refreshLabels or doHeavy) then
                if not espObjects[target.UserId] then createESP(target) end
                local d=espObjects[target.UserId]
                if d and d.billboard then
                    local adornOk = adornee and (typeof(adornee) ~= "Instance" or adornee.Parent)
                    if adornOk then
                        if espBillboardLayer then d.billboard.Parent = espBillboardLayer end
                        if doHeavy or VisPerf.camMoved or (espNow - (d.lastAdorneeAt or 0) >= 0.12) then
                            d.lastAdorneeAt = espNow
                            d.billboard.Adornee=adornee
                        end
                        if Settings.Visuals.VSync or VisPerf.camMoved or (espNow - (d.lastOffsetAt or 0) >= VisPerf.offset) then
                            d.lastOffsetAt = espNow
                            d.billboard.StudsOffset = getBillboardStudsOffset(tc, hrpPart or adornee)
                        end
                        d.billboard.MaxDistance=Settings.ESP.RenderDistance or 8000
                        d.billboard.Enabled=true
                        if refreshLabels then
                            local nextMeta = buildESPMetaText(dist, hp, maxhp)
                            local nextName = truncateESPName(getDisplayName(target))
                            local wpnMax = tonumber(Settings.ESP.WeaponLabelDistance) or 450
                            local nextWeapon = (Settings.ESP.WeaponLabels and dist <= wpnMax) and (getPlayerWeaponName(target) or "") or ""
                            local labelsDirty = nextName ~= d.lastName or nextMeta ~= d.lastMeta or nextWeapon ~= (d.lastWeapon or "")
                                or espNow - (d.lastLabelAt or 0) >= VisPerf.label
                            if labelsDirty then
                                d.lastLabelAt = espNow
                                d.lastName = nextName
                                d.lastMeta = nextMeta
                                d.lastWeapon = nextWeapon
                                applyESPPlayerVisuals(d, target, tc, hp, maxhp, dist, nameCol, "labels")
                            end
                        end
                    else
                        hideESPVisuals(d)
                        break
                    end

                    if doHeavy and not skipFarHeavy then
                        applyESPPlayerVisuals(d, target, tc, hp, maxhp, dist, chamsCol, "chams")
                        if box3DOn then updateBox3D(d, tc, boxCol) else hideBox3D(d) end
                    elseif doHeavy and skipFarHeavy and d.boxHighlight then
                        d.boxHighlight.Enabled = false
                    end
                end
            end
            if needsOverlay and doOverlay then
                local hrpSP, hrpOn = cam:WorldToViewportPoint(tPos)
                local hrpV2 = hrpOn and hrpSP.Z > 0 and Vector2.new(hrpSP.X, hrpSP.Y) or nil
                if box2DOn or (Settings.ESP.HealthBar and not VisPerf.lockFill) then
                    local minX, minY, maxX, maxY = getCharacter2DBounds(tc, cam, dist > VisPerf.fastBounds)
                    if minX and hrpOn and hrpSP.Z > 0 then
                        minX, minY, maxX, maxY = smoothESPBounds(target.UserId, minX, minY, maxX, maxY)
                        local outlineCol = (Settings.ESP.RainbowOutline and Color3.fromHSV(tick()%5/5,1,1)) or boxCol
                        local thick = Settings.ESP.BoxThickness or 1
                        local boxFade = getESPLabelFade(dist) * 0.55
                        if box2DOn then
                            local fillTr = math.clamp(0.78 + boxFade * 0.15, 0.7, 0.92)
                            if Settings.ESP.BoxFill and not VisPerf.lockFill then
                                drawBoxFill2D(minX, minY, maxX, maxY, outlineCol, fillTr)
                            end
                            local useCorner = (boxStyle == "Corner")
                            local tMain = math.max(1, thick)
                            local tOut = tMain + 2
                            local outFade = math.clamp(boxFade + 0.05, 0, 0.85)
                            local drawOutline = dist <= 260
                            if useCorner then
                                if drawOutline then
                                    drawCornerBox2D(minX, minY, maxX, maxY, Color3.fromRGB(0, 0, 0), tOut, Settings.ESP.BoxCornerLength or 0.32, outFade)
                                end
                                drawCornerBox2D(minX, minY, maxX, maxY, outlineCol, tMain, Settings.ESP.BoxCornerLength or 0.32, boxFade)
                            else
                                if drawOutline then
                                    drawFullBox2D(minX, minY, maxX, maxY, Color3.fromRGB(0, 0, 0), tOut, outFade)
                                end
                                drawFullBox2D(minX, minY, maxX, maxY, outlineCol, tMain, boxFade)
                            end
                        end
                        if Settings.ESP.HealthBar and boxFade < 0.6 then drawHealthBar2D(minX, minY, maxX, maxY, hp, maxhp, boxFade) end
                    end
                end
                if headDotOn and thead then
                    local hs, hon = cam:WorldToViewportPoint(thead.Position + Vector3.new(0, 0.35, 0))
                    if hon and hs.Z > 0 then
                        local dotSz = math.clamp(8 - dist / 80, 4, 8)
                        drawHeadDot(hs.X, hs.Y, rainbowCol or getHeadDotColor(), dotSz)
                    end
                end
                if tracerOn and hrpV2 then
                    local line=getTracerLine()
                    if line then
                        local thick=math.max(1, Settings.ESP.TracerThickness or 1)
                        local tr=math.clamp((Settings.ESP.TracerTransparency or 0.15) + getESPLabelFade(dist) * 0.35, 0, 0.85)
                        local ld=(hrpV2-tracerSP).Magnitude
                        local center=(tracerSP+hrpV2)/2
                        local angle=math.atan2(hrpV2.Y-tracerSP.Y,hrpV2.X-tracerSP.X)
                        line.Size=UDim2.new(0,ld,0,thick)
                        line.Position=UDim2.new(0,center.X,0,center.Y)
                        line.Rotation=math.deg(angle)
                        line.BackgroundColor3=Settings.ESP.TracerRainbowColor and Color3.fromHSV(tick()%5/5,1,1) or tracerCol
                        line.BackgroundTransparency=tr
                        line.Visible=true
                    end
                end
                if arrowOn and dist <= Settings.ESP.ArrowDistance then
                    if not hrpOn or hrpSP.Z < 0 then
                        local ad = getArrow()
                        if ad then
                            local pad = 70
                            local rx = ss.X / 2 - pad
                            local ry = ss.Y / 2 - pad
                            local sc2 = Vector2.new(ss.X / 2, ss.Y / 2)
                            local dir = tPos - camCF.Position
                            local flat = Vector3.new(dir.X, 0, dir.Z)
                            if flat.Magnitude < 0.001 then flat = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z) end
                            local fd = flat.Unit
                            local cl = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
                            if cl.Magnitude < 0.001 then cl = Vector3.new(0, 0, -1) else cl = cl.Unit end
                            local cr = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
                            if cr.Magnitude < 0.001 then cr = Vector3.new(1, 0, 0) else cr = cr.Unit end
                            local ang = math.atan2(fd:Dot(cr), fd:Dot(cl))
                            local ax = math.clamp(sc2.X + math.sin(ang) * rx, pad, ss.X - pad)
                            local ay = math.clamp(sc2.Y - math.cos(ang) * ry, pad, ss.Y - pad)
                            updateOffscreenArrow(ad, target, col, ang, ax, ay, dist)
                        end
                    end
                end
                if skelOn and dist <= (VisPerf.skelMax or 900) then
                    local skelCol=skelPartCol
                    local function partByName(name)
                        if rd and rd.parts then
                            local p = rd.parts[name]
                            if p and typeof(p) == "Instance" and p:IsA("BasePart") then return p end
                        end
                        local p = tc:FindFirstChild(name)
                        if p and p:IsA("BasePart") then return p end
                        return nil
                    end
                    local conns = rd and rd.skelBones
                    local valid = false
                    if conns then
                        for _, c in ipairs(conns) do
                            if partByName(c[1]) and partByName(c[2]) then valid = true break end
                        end
                    end
                    if not valid then
                        conns = {}
                        local seen = {}
                        for _, d in ipairs(tc:GetDescendants()) do
                            if d:IsA("Motor6D") and d.Part0 and d.Part1 and d.Part0:IsA("BasePart") and d.Part1:IsA("BasePart") then
                                local a, b = d.Part0, d.Part1
                                if a.Parent == tc or b.Parent == tc then
                                    local key = tostring(a) .. "|" .. tostring(b)
                                    if not seen[key] and a.Name ~= "Handle" and b.Name ~= "Handle" then
                                        seen[key] = true
                                        table.insert(conns, {a, b, true})
                                    end
                                end
                            end
                        end
                        if #conns == 0 then
                            if tc:FindFirstChild("UpperTorso") then
                                conns = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
                            else
                                conns = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
                            end
                        end
                    end
                    local thick=math.max(1, Settings.ESP.SkeletonThickness or 2)
                    for _,c in ipairs(conns) do
                        local p1, p2
                        if c[3] then
                            p1, p2 = c[1], c[2]
                        else
                            p1, p2 = partByName(c[1]), partByName(c[2])
                        end
                        if p1 and p2 then
                            local s1=cam:WorldToViewportPoint(p1.Position)
                            local s2=cam:WorldToViewportPoint(p2.Position)
                            if s1.Z>0 and s2.Z>0 then
                                local line=getSkelLine()
                                if not line then break end
                                local a=Vector2.new(s1.X,s1.Y)
                                local b=Vector2.new(s2.X,s2.Y)
                                local ld=(b-a).Magnitude
                                if ld > 1.5 and ld < 520 then
                                    line.Size=UDim2.new(0,ld,0,thick)
                                    line.Position=UDim2.new(0,(a.X+b.X)/2,0,(a.Y+b.Y)/2)
                                    line.Rotation=math.deg(math.atan2(b.Y-a.Y,b.X-a.X))
                                    line.BackgroundColor3=skelCol
                                    line.BackgroundTransparency=0.05
                                    line.Visible=true
                                end
                            end
                        end
                    end
                end
            end
          until true
        end
        for uid, d in pairs(espObjects) do
            if not espActiveThisFrame[uid] then hideESPVisuals(d) end
        end
        if Settings.ESP.AutoTeamDetect and (espNow - (VisPerf.lastMatchMode or 0)) >= 2 then
            VisPerf.lastMatchMode = espNow
            refreshMatchModeDetect(false)
        end
        if (espNow - VisPerf.lastMisc) >= miscIv then
            VisPerf.lastMisc = espNow
            if Settings.ESP.ThrowableEnabled then Throw.updateThrowableESP(myPos) end
            if Settings.ESP.ThrowableArcPreview then Throw.updateThrowableArcPreview() end
            if Settings.Visuals.ThirdPerson then VisCam.applyThirdPerson() end
            if Settings.Visuals.ViewmodelFOVEnabled or Settings.Visuals.GunWireframeEnabled then
                VisCam.applyViewmodelTweaks()
                if Settings.Visuals.GunWireframeEnabled then updateGunWireframe() end
            end
        end
    end))
    table.insert(allConnections, S.Players.PlayerRemoving:Connect(function(t)
        clearRigCache(t.UserId)
        if espObjects[t.UserId] then removeESP(t) end
        if radarDots[t.UserId] then radarDots[t.UserId]:Destroy(); radarDots[t.UserId] = nil; radarDotGlows[t.UserId] = nil end
        if radarNameLabels[t.UserId] then radarNameLabels[t.UserId]:Destroy(); radarNameLabels[t.UserId] = nil end
        if radarAltLabels[t.UserId] then radarAltLabels[t.UserId]:Destroy(); radarAltLabels[t.UserId] = nil end
        if radarNameLabels[t.UserId] then radarNameLabels[t.UserId]:Destroy(); radarNameLabels[t.UserId] = nil end
    end))
    local function onPlayerCharRefresh(p)
        clearRigCache(p.UserId)
        espBoundsCache[p.UserId] = nil
        espLosCache[p.UserId] = nil
        if espObjects[p.UserId] then removeESP(p) end
    end
    table.insert(allConnections,S.Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() onPlayerCharRefresh(p) end) end))
    for _,p in ipairs(S.Players:GetPlayers()) do p.CharacterAdded:Connect(function() onPlayerCharRefresh(p) end) end
end
