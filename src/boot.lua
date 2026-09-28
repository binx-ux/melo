function UILib.createGUI()
    pcall(function()
        local autoName = readAutoloadName()
        if autoName ~= "" then
            applyNamedConfig(autoName)
        end
    end)
    local loader
    pcall(function()
        local pg = player and player:FindFirstChildOfClass("PlayerGui")
        if not pg then return end
        for _, child in ipairs(pg:GetChildren()) do
            if child:IsA("ScreenGui") then
                local n = tostring(child.Name)
                if n == tostring(MW_T.loader) or n:find("RailPreview", 1, true) then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end)
    pcall(function() UILib.showExperimentalNotice() end)
    pcall(function() UILib.showStarterPrompt() end)
    if _G[MW_T.unloaded] then return end
    pcall(function() loader = UILib.showLoader() end)
    local function step(pct, label)
        if loader and loader.set then pcall(loader.set, pct, label) end
        pcall(function() game:GetService("RunService").Heartbeat:Wait() end)
        task.wait(0.55)
    end

    step(4, "starting")
    pcall(function()
        game:GetService("RunService").RenderStepped:Wait()
        game:GetService("RunService").Heartbeat:Wait()
    end)

    step(16, "fingerprint")
    pcall(function()
        if MW_T.force then MW_T.force() end
    end)

    step(34, "executor check")
    Cap.awaitWeao(0.85)
    Cap.disableUnsupportedSettings(Settings)

    step(52, "remotes")
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        rs:FindFirstChild("Remotes")
        rs:FindFirstChild("Weapons")
        rs:FindFirstChild("ClientServices")
        rs:FindFirstChild("Modules")
        if MW.isMM2 then
            local rem = rs:FindFirstChild("Remotes")
            local gp = rem and rem:FindFirstChild("Gameplay")
            if gp then
                gp:FindFirstChild("GetCurrentPlayerData")
                gp:FindFirstChild("EliminatePlayer")
                gp:FindFirstChild("GetCoin")
            end
        end
        if MW.isPF then
            S.Workspace:FindFirstChild("Players")
            S.Workspace:FindFirstChild("Ignore")
            rs:FindFirstChild("Character")
            pcall(function()
                if MW.TracePF and MW.TracePF.refreshModules then
                    MW.TracePF.refreshModules()
                end
            end)
        end
    end)

    step(64, "checks")
    if Cap.isWeak() then
        if loader and loader.close then pcall(loader.close) end
        loader = nil
        local keepGoing = true
        local okWeak, res = pcall(UILib.showWeakExecutorScreen)
        if okWeak then keepGoing = res end
        if not keepGoing then
            _G[MW_T.unloaded] = true
            error("[" .. MW.hub .. "] Unloaded: weak executor")
        end
    end

    step(72, "checks")
    pcall(function()
        Cap.recompute()
        Cap.apply()
    end)

    step(78, "building menu")

    local screenGui = UILib.newScreenGui(MW_T.gui, 20)
    screenGui.DisplayOrder = 20
    UILib.ActiveThemeRoot = screenGui
    notifScreenGui = screenGui

    local overlayLayer = UILib.layer(screenGui, 1)
    espBillboardLayer = UILib.newFrame(overlayLayer, {
        Name = MW_T.next(8),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 0,
    })
    local windowLayer = UILib.layer(screenGui, 15)
    local notifLayer = UILib.layer(screenGui, 50)
    notifLayerRef = notifLayer

    UILib.setupWorldOverlays(overlayLayer)
    TraceV2BindMD(UILib.MD)
    pcall(function()
        if UILib.mountGunModsTestingOverlay then UILib.mountGunModsTestingOverlay() end
    end)
    -- Keep buildMenuWindow for loops/keybinds; hide ScreenGui chrome when Drawing menu mounts
    UILib.buildMenuWindow(screenGui, windowLayer)
    step(90, "drawing menu")
    local usedDraw = false
    local drawErr = nil
    local okDraw, drawRes = pcall(function()
        if UILib.TraceDraw and UILib.TraceDraw.buildMenu then
            return UILib.TraceDraw.buildMenu(UILib.MD)
        end
        return nil
    end)
    if okDraw and drawRes then
        usedDraw = true
    elseif not okDraw then
        drawErr = drawRes
        warn("[Trace] Drawing menu failed: " .. tostring(drawErr))
    end
    if usedDraw or (UILib.TraceDraw and UILib.TraceDraw._window) then
        usedDraw = true
        -- Drawing is primary UI. ScreenGui hub stays built (loops/keybinds) but hidden.
        pcall(function()
            UILib._hubWindowLayer = windowLayer
            windowLayer.Visible = false
            for _, child in ipairs(windowLayer:GetChildren()) do
                pcall(function()
                    child.Visible = false
                end)
            end
            if UILib.MD and UILib.MD.mainFrame then
                UILib.MD.mainFrame.Visible = false
            end
            if UILib.MD and UILib.MD.setMenuVisible then
                pcall(UILib.MD.setMenuVisible, false)
            end
            if UILib.TraceDraw and UILib.TraceDraw.SetOpen then
                UILib.TraceDraw.SetOpen(true)
            end
            UILib.showDrawingMenu = function()
                pcall(function()
                    if UILib.MD and UILib.MD.setMenuVisible then
                        UILib.MD.setMenuVisible(false)
                    end
                    if UILib.MD and UILib.MD.mainFrame then
                        UILib.MD.mainFrame.Visible = false
                    end
                    windowLayer.Visible = false
                    for _, child in ipairs(windowLayer:GetChildren()) do
                        pcall(function() child.Visible = false end)
                    end
                    if UILib.TraceDraw and UILib.TraceDraw.SetOpen then
                        UILib.TraceDraw.SetOpen(true)
                    end
                end)
            end
            UILib.showFullHub = function()
                -- kept for emergency only; not exposed in Drawing menu
                pcall(function()
                    if UILib.TraceDraw and UILib.TraceDraw.SetOpen then
                        UILib.TraceDraw.SetOpen(false)
                    end
                    windowLayer.Visible = true
                    for _, child in ipairs(windowLayer:GetChildren()) do
                        pcall(function() child.Visible = true end)
                    end
                    if UILib.MD and UILib.MD.mainFrame then
                        UILib.MD.mainFrame.Visible = true
                    end
                    if UILib.MD and UILib.MD.setMenuVisible then
                        UILib.MD.setMenuVisible(true)
                    end
                end)
            end
        end)
        -- hide again next frame in case something re-opens hub during boot
        task.defer(function()
            if isUnloading or _G[MW_T.unloaded] then return end
            if UILib.showDrawingMenu then UILib.showDrawingMenu() end
        end)
    end
    step(100, "ready")
    if loader and loader.close then pcall(loader.close) end
    loader = nil
    task.defer(function()
        if isUnloading or _G[MW_T.unloaded] then return end
        pcall(function() if TraceHUD then TraceHUD.start(screenGui) end end)
        pcall(function() if TraceExpand and TraceExpand.boot then TraceExpand.boot(screenGui) end end)
        pcall(function()
            local kit = MW.GameKits and (MW.GameKits.active or MW.GameKits.resolve())
            if kit and type(kit.boot) == "function" then kit.boot() end
        end)
    end)

    registerPostLoad(function()
        ensureUISettings()
        applyCustomTheme()
        pcall(function()
            local kit = MW.GameKits and MW.GameKits.active
            if kit and type(kit.boot) == "function" then kit.boot() end
        end)
        refreshThemeHexFields()
        applyWorldLighting()
        applyStreamerPrivacy()
        runUiSync()
        pcall(function()
            for cat, _ in pairs(gunOrig) do restoreGunMod(cat) end
        end)
        applyAllGunMods()
        pcall(function()
            Settings.Aimbot.AimMode = "Camera"
            if SilentHB and SilentHB.stop then SilentHB.stop() end
        end)
        Settings.Combat.WallBang = false
        if Settings.Combat.InfiniteAmmo then applyInfiniteAmmo() else stopInfiniteAmmo() end
        if Settings.Movement.Fly then startFly() else stopFly() end
        if Settings.Combat.RageBot then startRageBot() else stopRageBot() end
        if Settings.Misc.AutoTPLoop then startAutoTPLoop() else stopAutoTPLoop() end
        if Settings.Visuals.NoFog then enableNoFog() else disableNoFog() end
        if Settings.Visuals.Fullbright then
            S.Lighting.Ambient = Color3.fromRGB(255,255,255)
            S.Lighting.Brightness = 2
            S.Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        end
        local cam = S.Workspace.CurrentCamera
        if cam and Settings.Visuals.CustomFOV then cam.FieldOfView = Settings.Visuals.FOVAmount end
        if _G[MW_T.audioApi] then pcall(function() _G[MW_T.audioApi].refreshMusicPlayback() end) end
        if _G[MW_T.radarApi] then
            pcall(function()
                if RADAR_TEMP_DISABLED then Settings.Radar.Enabled = false end
                _G[MW_T.radarApi].applyStyle()
                _G[MW_T.radarApi].setVisible(Settings.Radar.Enabled and not RADAR_TEMP_DISABLED)
            end)
        end
        if _G[MW_T.chatSpyApi] then pcall(function() _G[MW_T.chatSpyApi].refresh() end) end
        SilentHB.refresh()
        task.defer(function()
            pcall(function()
                WB.scanPaths()
                if WB.paths.weapons then WB.report("Weapons", true, "resolved")
                else WB.report("Weapons", false, MW.isArsenal and "folder missing: gun mods offline" or "universal scan: no weapons folder") end
            end)
        end)
        task.spawn(function()
            while not isUnloading and not _G[MW_T.unloaded] do
                pcall(function() WB.scanPaths() end)
                task.wait(6)
            end
        end)
        pcall(function()
            table.insert(allConnections, S.Players.PlayerAdded:Connect(function()
                task.defer(function() pcall(WB.scanPaths) end)
            end))
            table.insert(allConnections, player.CharacterAdded:Connect(function()
                task.defer(function() pcall(WB.scanPaths) end)
            end))
        end)
    end)

    applyStreamerPrivacy()
    return screenGui
end

do
    local ok, guiOrErr = xpcall(function()
        return UILib.createGUI()
    end, function(err)
        local tb = ""
        pcall(function() tb = debug.traceback("", 2) end)
        return tostring(err) .. (tb ~= "" and ("\n" .. tb) or "")
    end)

    if not ok then
        TraceLog.pushError(guiOrErr)
        TraceLog.send("error")
        error("[" .. MW.hub .. "] load failed")
    end

    local gui = guiOrErr
    ensureUISettings()
    pcall(applyCustomTheme)
    pcall(function() FX.hookAntiCheat() end)

    _G[MW_T.cleanup] = function()
        if _G[MW_T.unloadBusy] then return end
        _G[MW_T.unloadBusy] = true
        isUnloading = true
        _G[MW_T.unloaded] = true
        pcall(function()
            if UILib.TraceDraw and UILib.TraceDraw.Unload then UILib.TraceDraw.Unload() end
        end)
        pcall(function()
            if UILib._gunModsTestGui then UILib._gunModsTestGui:Destroy(); UILib._gunModsTestGui = nil end
        end)
        pcall(function()
            local b = S.Lighting:FindFirstChild(MW_T.menuBlur)
            if b then b:Destroy() end
        end)
        if TraceHUD and TraceHUD.destroy then pcall(TraceHUD.destroy) end

        -- Hide hub immediately, then play reverse TRACE outro
        pcall(function()
            if gui and gui.Parent then gui.Enabled = false end
        end)
        pcall(function()
            UILib.showUnloader()
        end)

        Settings.ESP.Enabled = false
        Settings.Combat.FastReload = false; Settings.Combat.FastFireRate = false
        Settings.Combat.AlwaysAuto = false; Settings.Combat.NoSpread = false; Settings.Combat.NoRecoil = false
        Settings.Combat.WallBang = false
        Settings.Combat.InfiniteAmmo = false; stopInfiniteAmmo()
        stopAutoTPLoop(); stopFly(); pcall(function() UnivKit.stopUniversalKits() end); stopAimbotTracking(); SilentHB.stop(); stopRageBot(); Trigger.stopFire()
        pcall(function()
            local kit = MW.GameKits and MW.GameKits.active
            if kit and type(kit.teardown) == "function" then kit.teardown() end
        end)
        pcall(function() Settings.Combat.WallBang = false; WB.clearMapQuery() end)
        clearAllESP(); Throw.clearThrowableESP(); Throw.clearThrowableArcPreview(); clearGunWireframe()
        pcall(function() if arcFolder then arcFolder:Destroy() end end)
        pcall(function() for _, e in pairs(gunOrig) do for obj, v in pairs(e) do pcall(function() if obj and obj.Parent then obj.Value = v end end) end end end)
        pcall(function() disableNoFog() end)
        pcall(function() restoreWorldLighting() end)
        pcall(function() local c = player.Character; if c then local h = c:FindFirstChild("Humanoid"); if h then h.WalkSpeed = 16; h.JumpPower = 50; h.PlatformStand = false end end end)
        if _G[MW_T.audioApi] then _G[MW_T.audioApi].cleanup() end
        _G[MW_T.audioApi] = nil
        _G[MW_T.dockApi] = nil
        _G[MW_T.radarApi] = nil
        _G[MW_T.chatSpyApi] = nil
        pcall(function() for _, conn in ipairs(allConnections) do pcall(function() conn:Disconnect() end) end end)
        pcall(function() if gui and gui.Parent then gui:Destroy() end end)
        UILib.ActiveThemeRoot = nil
        notifScreenGui = nil; notifLayerRef = nil; overlayResetFn = nil; destroyTargetHLFn = nil
        _G[MW_T.cleanup] = nil
        _G[MW_T.unloadBusy] = nil
    end

    if not checkIntegrity() then
        TraceLog.pushError("integrity warning")
        task.delay(2,function() sendNotification("Warning","Tampered script detected",8) end)
    end

    TraceLog.send("ok")
    task.delay(1,function() sendNotification(MW.hub,"Loaded | "..getExecutorName().." | RightCtrl = toggle",4) end)
    hookMatchModeDetect()
    task.defer(function() refreshMatchModeDetect(false) end)

    task.delay(8, function()
        local function parseChangelogPayload(raw)
            local ok, data = pcall(function() return S.HttpService:JSONDecode(raw) end)
            if not ok or type(data) ~= "table" then return nil end
            return data
        end

        local function fetchUpdateChangelog()
            if not MW.changelogUrl or MW.changelogUrl == "" then return nil end
            local ok, raw = pcall(function() return game:HttpGet(MW.changelogUrl) end)
            if not ok or not raw or raw == "" then return nil end
            return parseChangelogPayload(raw)
        end

        local function formatChangelogNotice(remoteNum, data)
            local msg = "v1." .. string.format("%03d", remoteNum) .. " is available. You have " .. MW.display
            if data then
                if type(data.title) == "string" and data.title ~= "" then
                    msg = data.title .. "\n" .. msg
                end
                if type(data.lines) == "table" and #data.lines > 0 then
                    local parts = {}
                    for _, line in ipairs(data.lines) do
                        if type(line) == "string" and line ~= "" then
                            table.insert(parts, "- " .. line)
                        end
                    end
                    if #parts > 0 then
                        msg = msg .. "\n" .. table.concat(parts, "\n")
                    end
                end
            end
            return msg
        end

        if not MW.versionUrl or MW.versionUrl == "" then return end
        local localNum = tonumber(MW.version)
        if not localNum then return end
        local ok, res = pcall(function() return game:HttpGet(MW.versionUrl) end)
        if not ok or not res or res == "" then return end
        local remoteNum = tonumber(res:match("^%s*(%d+)"))
        if not remoteNum then return end
        if remoteNum > localNum then
            sendNotification("Update Available", formatChangelogNotice(remoteNum, fetchUpdateChangelog()), 14)
        end
    end)
end

end)()
