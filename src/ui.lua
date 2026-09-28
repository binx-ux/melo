UILib.MD = {
    AIMBOT_HOLD_BIND = AIMBOT_HOLD_BIND,
    Icons = Icons,
    FX = FX,
    _pendingWebhookUrl = "",
    RADAR_TEMP_DISABLED = RADAR_TEMP_DISABLED,
    applyAimSmoothProfile = applyAimSmoothProfile,
    applyConfigPack = Pack.apply,
    applyAllGunMods = applyAllGunMods,
    TraceMM2 = TraceMM2,
    TracePF = TracePF,
    applyCustomTheme = applyCustomTheme,
    applyInfiniteAmmo = applyInfiniteAmmo,
    applyStreamerPrivacy = applyStreamerPrivacy,
    applyViewmodelSettings = VisCam.applyViewmodelSettings,
    applyWorldLighting = applyWorldLighting,
    bindName = bindName,
    buildWeaponCache = buildWeaponCache,
    clearAllESP = clearAllESP,
    clearGunWireframe = clearGunWireframe,
    clearThrowableArcPreview = Throw.clearThrowableArcPreview,
    clearThrowableESP = Throw.clearThrowableESP,
    cycleTarget = cycleTarget,
    deleteProfile = deleteProfile,
    destroyESPData = destroyESPData,
    disableNoFog = disableNoFog,
    enableNoFog = enableNoFog,
    ensureUISettings = ensureUISettings,
    espBoundsCache = espBoundsCache,
    espObjects = espObjects,
    getDisplayName = getDisplayName,
    getExecutorName = getExecutorName,
    getSupportedExecutorLabel = getSupportedExecutorLabel,
    Cap = Cap,
    hexToColor3 = hexToColor3,
    normalizeHex = normalizeHex,
    color3ToHex = color3ToHex,
    applyEspPalette = applyEspPalette,
    openColorTable = function(focusEsp)
        if UILib.openColorTable then UILib.openColorTable(focusEsp) end
    end,
    GameKits = MW.GameKits,
    registerGameKit = MW.registerGameKit,
    guard = MW.guard,
    isMiscGunTest = function() return MW.isMiscGunTest == true end,
    inputMatchesBind = inputMatchesBind,
    isPlayerScoped = isPlayerScoped,
    listProfiles = listProfiles,
    loadProfile = loadProfile,
    openDiscordServer = openDiscordServer,
    refreshMatchModeDetect = refreshMatchModeDetect,
    refreshThemeHexFields = refreshThemeHexFields,
    registerUiSync = registerUiSync,
    runUiSync = runUiSync,
    resetThemeDefaults = resetThemeDefaults,
    restoreGunMod = restoreGunMod,
    rigCache = rigCache,
    runTriggerBot = Trigger.run,
    saveProfile = saveProfile,
    sendNotification = sendNotification,
    setupAutoRejoin = setupAutoRejoin,
    startAimbotTracking = startAimbotTracking,
    startAutoTPLoop = startAutoTPLoop,
    startFly = startFly,
    startRageBot = startRageBot,
    UnivKit = UnivKit,
    setNoclip = UnivKit.setNoclip,
    setInfiniteJump = UnivKit.setInfiniteJump,
    setClickTP = UnivKit.setClickTP,
    setVehicleSpeed = UnivKit.setVehicleSpeed,
    applyLocalInvis = UnivKit.applyLocalInvis,
    startAutoObby = UnivKit.startAutoObby,
    stopAutoObby = UnivKit.stopAutoObby,
    scanCheckpoints = UnivKit.scanCheckpoints,
    tpNextCheckpoint = UnivKit.tpNextCheckpoint,
    tpToSpawn = UnivKit.tpToSpawn,
    tpBrookhavenLocation = UnivKit.tpBrookhavenLocation,
    bringPlayerByName = UnivKit.bringPlayerByName,
    tpToPlayerByName = UnivKit.tpToPlayerByName,
    forceSit = UnivKit.forceSit,
    stopUniversalKits = UnivKit.stopUniversalKits,
    BH_LOCATIONS = UnivKit.BH_LOCATIONS,
    stopAimbotTracking = stopAimbotTracking,
    stopAutoTPLoop = stopAutoTPLoop,
    stopFly = stopFly,
    stopInfiniteAmmo = stopInfiniteAmmo,
    stopRageBot = stopRageBot,
    stopTriggerFire = Trigger.stopFire,
    streamerUiRefs = streamerUiRefs,
    themeCallbacks = themeCallbacks,
    themeHexFields = themeHexFields,
    updateGunWireframe = updateGunWireframe,
    weaponCache = weaponCache,
}
UILib.ColorPicker = UILib.ColorPicker or {}
do
    local CP = UILib.ColorPicker
    CP._active = nil
    local function clamp(v, a, b)
        if v < a then return a end
        if v > b then return b end
        return v
    end
    function CP.close()
        if CP._active then
            pcall(function()
                if CP._active.destroy then CP._active.destroy() end
            end)
            CP._active = nil
        end
    end
    function CP.open(opts)
        opts = opts or {}
        CP.close()
        local parent = opts.parent
        if not parent then return nil end
        local pickerSize = opts.pickerSize or 120
        local hueBarSize = opts.hueBarSize or 8
        local pad = opts.pad or 8
        local color = opts.color or Color3.fromRGB(255, 80, 80)
        local alpha = clamp(tonumber(opts.alpha) or 1, 0, 1)
        local h, s, v = color:ToHSV()
        local winW = pickerSize + hueBarSize + pad * 3
        local winH = pickerSize + hueBarSize + pad * 3
        local root = Instance.new("Frame")
        root.Name = "ColorPicker"
        root.Size = UDim2.fromOffset(winW, winH)
        root.BorderSizePixel = 0
        root.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        root.ZIndex = 200
        root.Parent = parent
        Instance.new("UICorner", root).CornerRadius = UDim.new(0, 4)
        local rootStroke = Instance.new("UIStroke")
        rootStroke.Color = Color3.fromRGB(70, 70, 78)
        rootStroke.Thickness = 1
        rootStroke.Parent = root
        local placedAt = Vector2.new(0, 0)
        if opts.anchor then
            local ax = opts.anchor.X
            local ay = opts.anchor.Y
            local cam = S.Workspace.CurrentCamera
            local vs = cam and cam.ViewportSize or Vector2.new(1920, 1080)
            if ax + winW > vs.X - 8 then ax = math.max(8, ax - winW - 4) end
            if ay + winH > vs.Y - 8 then ay = math.max(8, vs.Y - winH - 8) end
            placedAt = Vector2.new(ax, ay)
            root.Position = UDim2.fromOffset(ax, ay)
        else
            local cam = S.Workspace.CurrentCamera
            local vs = cam and cam.ViewportSize or Vector2.new(1920, 1080)
            placedAt = Vector2.new(math.floor(vs.X * 0.5 - winW * 0.5), math.floor(vs.Y * 0.5 - winH * 0.5))
            root.Position = UDim2.fromOffset(placedAt.X, placedAt.Y)
        end
        local rcPicker = Instance.new("Frame")
        rcPicker.Name = "SV"
        rcPicker.Size = UDim2.fromOffset(pickerSize, pickerSize)
        rcPicker.Position = UDim2.fromOffset(pad, pad)
        rcPicker.BorderSizePixel = 0
        rcPicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        rcPicker.ClipsDescendants = true
        rcPicker.ZIndex = 201
        rcPicker.Parent = root
        local svHue = Instance.new("UIGradient")
        svHue.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
        svHue.Rotation = 0
        svHue.Parent = rcPicker
        local svBlack = Instance.new("Frame")
        svBlack.Size = UDim2.fromScale(1, 1)
        svBlack.BackgroundColor3 = Color3.new(0, 0, 0)
        svBlack.BorderSizePixel = 0
        svBlack.ZIndex = 202
        svBlack.Parent = rcPicker
        local svShade = Instance.new("UIGradient")
        svShade.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        })
        svShade.Rotation = 90
        svShade.Parent = svBlack
        local svStroke = Instance.new("UIStroke")
        svStroke.Color = Color3.fromRGB(60, 60, 66)
        svStroke.Thickness = 1
        svStroke.Parent = rcPicker
        local rcHueBar = Instance.new("Frame")
        rcHueBar.Name = "Hue"
        rcHueBar.Size = UDim2.fromOffset(hueBarSize, pickerSize)
        rcHueBar.Position = UDim2.fromOffset(pad + pickerSize + pad, pad)
        rcHueBar.BorderSizePixel = 0
        rcHueBar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        rcHueBar.ClipsDescendants = true
        rcHueBar.ZIndex = 201
        rcHueBar.Parent = root
        local hueColors = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(255, 0, 0),
        }
        for i = 0, 5 do
            local seg = Instance.new("Frame")
            seg.Size = UDim2.new(1, 0, 1 / 6, 0)
            seg.Position = UDim2.new(0, 0, i / 6, 0)
            seg.BorderSizePixel = 0
            seg.BackgroundColor3 = Color3.new(1, 1, 1)
            seg.ZIndex = 202
            seg.Parent = rcHueBar
            local g = Instance.new("UIGradient")
            g.Color = ColorSequence.new(hueColors[i + 1], hueColors[i + 2])
            g.Rotation = 90
            g.Parent = seg
        end
        local hueStroke = Instance.new("UIStroke")
        hueStroke.Color = Color3.fromRGB(60, 60, 66)
        hueStroke.Thickness = 1
        hueStroke.Parent = rcHueBar
        local rcAlphaBar = Instance.new("Frame")
        rcAlphaBar.Name = "Alpha"
        rcAlphaBar.Size = UDim2.fromOffset(pickerSize, hueBarSize)
        rcAlphaBar.Position = UDim2.fromOffset(pad, pad + pickerSize + pad)
        rcAlphaBar.BorderSizePixel = 0
        rcAlphaBar.BackgroundColor3 = Color3.new(1, 1, 1)
        rcAlphaBar.ZIndex = 201
        rcAlphaBar.Parent = root
        local alphaGrad = Instance.new("UIGradient")
        alphaGrad.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(1, 1, 1))
        alphaGrad.Rotation = 0
        alphaGrad.Parent = rcAlphaBar
        local alphaStroke = Instance.new("UIStroke")
        alphaStroke.Color = Color3.fromRGB(60, 60, 66)
        alphaStroke.Thickness = 1
        alphaStroke.Parent = rcAlphaBar
        local function mkIndicator(sz)
            local f = Instance.new("Frame")
            f.Size = UDim2.fromOffset(sz, sz)
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.BackgroundTransparency = 1
            f.BorderSizePixel = 0
            f.ZIndex = 210
            f.Parent = root
            local st = Instance.new("UIStroke")
            st.Color = Color3.fromRGB(255, 255, 255)
            st.Transparency = 0.4
            st.Thickness = 1
            st.Parent = f
            return f
        end
        local ptPicker = mkIndicator(6)
        local ptHue = Instance.new("Frame")
        ptHue.Size = UDim2.fromOffset(hueBarSize + 4, 4)
        ptHue.AnchorPoint = Vector2.new(0.5, 0.5)
        ptHue.BackgroundTransparency = 1
        ptHue.BorderSizePixel = 0
        ptHue.ZIndex = 210
        ptHue.Parent = root
        local ptHueSt = Instance.new("UIStroke")
        ptHueSt.Color = Color3.fromRGB(255, 255, 255)
        ptHueSt.Transparency = 0.4
        ptHueSt.Thickness = 1
        ptHueSt.Parent = ptHue
        local ptAlpha = Instance.new("Frame")
        ptAlpha.Size = UDim2.fromOffset(4, hueBarSize + 4)
        ptAlpha.AnchorPoint = Vector2.new(0.5, 0.5)
        ptAlpha.BackgroundTransparency = 1
        ptAlpha.BorderSizePixel = 0
        ptAlpha.ZIndex = 210
        ptAlpha.Parent = root
        local ptAlphaSt = Instance.new("UIStroke")
        ptAlphaSt.Color = Color3.fromRGB(255, 255, 255)
        ptAlphaSt.Transparency = 0.4
        ptAlphaSt.Thickness = 1
        ptAlphaSt.Parent = ptAlpha
        local state = {
            h = h, s = s, v = v, a = alpha,
            drag = -1,
            owner = opts.owner,
            destroy = nil,
        }
        local function syncIndicators()
            local px = pad + clamp(state.s, 0, 1) * (pickerSize - 1)
            local py = pad + (1 - clamp(state.v, 0, 1)) * (pickerSize - 1)
            ptPicker.Position = UDim2.fromOffset(px, py)
            local hy = pad + clamp(state.h, 0, 1) * (pickerSize - 1)
            ptHue.Position = UDim2.fromOffset(pad + pickerSize + pad + hueBarSize * 0.5, hy)
            local ax = pad + clamp(state.a, 0, 1) * (pickerSize - 1)
            ptAlpha.Position = UDim2.fromOffset(ax, pad + pickerSize + pad + hueBarSize * 0.5)
        end
        local function refreshSVHue()
            svHue.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(state.h, 1, 1))
        end
        local function emit()
            local c3 = Color3.fromHSV(state.h, state.s, state.v)
            if opts.onChanged then
                pcall(opts.onChanged, c3, state.a)
            end
        end
        local conns = {}
        local uis = S.UserInputService
        local hueX0 = pad + pickerSize + pad
        local alphaY0 = pad + pickerSize + pad

        local function localMouse()
            local m = uis:GetMouseLocation()
            local lx = m.X - placedAt.X
            local ly = m.Y - placedAt.Y
            if lx >= -2 and lx <= winW + 2 and ly >= -2 and ly <= winH + 2 then
                return lx, ly
            end
            local ap = root.AbsolutePosition
            local inset = Vector2.new(0, 0)
            pcall(function() inset = game:GetService("GuiService"):GetGuiInset() end)
            local ax = m.X - ap.X
            local ay = m.Y - ap.Y
            if ax >= -2 and ax <= winW + 2 and ay >= -2 and ay <= winH + 2 then
                return ax, ay
            end
            local bx = m.X - inset.X - ap.X
            local by = m.Y - inset.Y - ap.Y
            if bx >= -2 and bx <= winW + 2 and by >= -2 and by <= winH + 2 then
                return bx, by
            end
            return lx, ly
        end
        local function hitZone(lx, ly)
            if lx >= pad and lx <= pad + pickerSize and ly >= pad and ly <= pad + pickerSize then
                return 0
            end
            if lx >= hueX0 and lx <= hueX0 + hueBarSize and ly >= pad and ly <= pad + pickerSize then
                return 1
            end
            if lx >= pad and lx <= pad + pickerSize and ly >= alphaY0 and ly <= alphaY0 + hueBarSize then
                return 2
            end
            if lx >= 0 and lx <= winW and ly >= 0 and ly <= winH then
                return -2
            end
            return -1
        end
        local function applyFromLocal(lx, ly)
            if state.drag == 0 then
                state.s = clamp((lx - pad) / math.max(pickerSize - 1, 1), 0, 1)
                state.v = 1 - clamp((ly - pad) / math.max(pickerSize - 1, 1), 0, 1)
            elseif state.drag == 1 then
                state.h = clamp((ly - pad) / math.max(pickerSize - 1, 1), 0, 1)
                refreshSVHue()
            elseif state.drag == 2 then
                state.a = clamp((lx - pad) / math.max(pickerSize - 1, 1), 0, 1)
            else
                return
            end
            syncIndicators()
            emit()
        end
        table.insert(conns, uis.InputBegan:Connect(function(input)
            if isUnloading or _G[MW_T.unloaded] then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local lx, ly = localMouse()
            local zone = hitZone(lx, ly)
            if zone >= 0 then
                state.drag = zone
                applyFromLocal(lx, ly)
            elseif zone == -1 then
                CP.close()
            end
        end))
        table.insert(conns, uis.InputChanged:Connect(function(input)
            if state.drag < 0 then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement
                and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local lx, ly = localMouse()
            applyFromLocal(lx, ly)
        end))
        table.insert(conns, uis.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                state.drag = -1
            end
        end))
        state.destroy = function()
            for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
            pcall(function() root:Destroy() end)
            if opts.onClose then pcall(opts.onClose) end
            if CP._active == state then CP._active = nil end
        end
        refreshSVHue()
        syncIndicators()
        CP._active = state
        return state
    end

    function CP.attachSwatch(swatch, opts)
        opts = opts or {}
        if not swatch then return end
        local btn = swatch
        if not swatch:IsA("GuiButton") then
            btn = Instance.new("TextButton")
            btn.Name = "PickerHit"
            btn.Size = UDim2.fromScale(1, 1)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = (swatch.ZIndex or 1) + 1
            btn.Parent = swatch
        end
        btn.MouseButton1Click:Connect(function()
            if CP._active and CP._active.owner == swatch then
                CP.close()
                return
            end
            CP.close()
            local col = opts.getColor and opts.getColor() or swatch.BackgroundColor3
            local a = opts.getAlpha and opts.getAlpha() or 1
            local abs = swatch.AbsolutePosition
            local asz = swatch.AbsoluteSize
            CP.open({
                parent = opts.parent or swatch:FindFirstAncestorOfClass("ScreenGui") or swatch.Parent,
                color = col,
                alpha = a,
                owner = swatch,
                anchor = Vector2.new(abs.X + asz.X + 4, abs.Y + asz.Y),
                onChanged = function(c3, alpha)
                    swatch.BackgroundColor3 = c3
                    if opts.onChanged then opts.onChanged(c3, alpha) end
                end,
            })
        end)
        return btn
    end
end
UILib.ColorTable = UILib.ColorTable or {}
do
    local CT = UILib.ColorTable
    CT.gui = nil
    CT.rows = {}
    local THEME_ROWS = {
        { key = "AccentHex", label = "Accent", bag = "UI" },
        { key = "BackgroundHex", label = "Background", bag = "UI" },
        { key = "SurfaceHex", label = "Surface", bag = "UI" },
        { key = "ToggleHex", label = "Toggle", bag = "UI" },
    }
    local ESP_ROWS = {
        { key = "CloseHex", label = "ESP Close", bag = "ESP" },
        { key = "MediumHex", label = "ESP Medium", bag = "ESP" },
        { key = "FarHex", label = "ESP Far", bag = "ESP" },
        { key = "VeryFarHex", label = "ESP Very Far", bag = "ESP" },
        { key = "BoxHex", label = "ESP Box", bag = "ESP" },
        { key = "TracerHex", label = "ESP Tracer", bag = "ESP" },
        { key = "SkeletonHex", label = "ESP Skeleton", bag = "ESP" },
        { key = "ChamsHex", label = "ESP Chams", bag = "ESP" },
        { key = "OutlineHex", label = "ESP Outline", bag = "ESP" },
        { key = "NameHex", label = "ESP Name", bag = "ESP" },
    }
    local function bagTable(bag)
        if bag == "UI" then
            ensureUISettings()
            return Settings.UI
        end
        Settings.ESP = Settings.ESP or {}
        return Settings.ESP
    end
    local function getHex(row)
        local b = bagTable(row.bag)
        local h = normalizeHex(b[row.key])
        if h then return h end
        if row.bag == "ESP" and row.key == "OutlineHex" and Settings.ESP.OutlineColor then
            return color3ToHex(Settings.ESP.OutlineColor)
        end
        if row.bag == "UI" then return "6759B3" end
        return "FFFFFF"
    end
    local function setHex(row, hex)
        local h = normalizeHex(hex)
        if not h then return false end
        local b = bagTable(row.bag)
        b[row.key] = h
        if row.bag == "ESP" then
            Settings.ESP.LinkToAccent = false
        else
            Settings.UI.ThemePreset = "Custom"
        end
        return true
    end
    function CT.close()
        if UILib.ColorPicker and UILib.ColorPicker.close then UILib.ColorPicker.close() end
        if CT.gui then pcall(function() CT.gui:Destroy() end) end
        CT.gui = nil
        CT.rows = {}
    end
    function CT.apply()
        for _, r in ipairs(CT.rows) do
            if r.box then
                setHex(r.def, r.box.Text)
                r.box.Text = "#" .. getHex(r.def)
                if r.swatch then r.swatch.BackgroundColor3 = hexToColor3(getHex(r.def)) end
            end
        end
        if applyCustomTheme then applyCustomTheme() end
        if applyEspPalette then applyEspPalette() end
        pcall(function()
            if UILib.TraceDraw and UILib.TraceDraw.syncFromSettings then
                UILib.TraceDraw.syncFromSettings()
            end
        end)
        if refreshThemeHexFields then refreshThemeHexFields() end
        if sendNotification then sendNotification("Color Table", "Applied", 1.5)
        elseif TD and TD.Notify then TD.Notify("Colors applied", 1.5) end
    end
    function CT.exportJSON()
        local out = { UI = {}, ESP = {}, LinkToAccent = Settings.ESP and Settings.ESP.LinkToAccent }
        for _, def in ipairs(THEME_ROWS) do out.UI[def.key] = getHex(def) end
        for _, def in ipairs(ESP_ROWS) do out.ESP[def.key] = getHex(def) end
        local ok, json = pcall(function()
            return game:GetService("HttpService"):JSONEncode(out)
        end)
        return ok and json or nil
    end
    function CT.importJSON(raw)
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(tostring(raw or ""))
        end)
        if not ok or type(data) ~= "table" then return false end
        if type(data.UI) == "table" then
            for k, v in pairs(data.UI) do
                local h = normalizeHex(v)
                if h then Settings.UI[k] = h end
            end
            Settings.UI.ThemePreset = "Custom"
        end
        if type(data.ESP) == "table" then
            for k, v in pairs(data.ESP) do
                local h = normalizeHex(v)
                if h then Settings.ESP[k] = h end
            end
            Settings.ESP.LinkToAccent = false
        end
        if data.LinkToAccent ~= nil then Settings.ESP.LinkToAccent = data.LinkToAccent == true end
        CT.apply()
        return true
    end
    function CT.open(focusEsp)
        CT.close()
        ensureUISettings()
        local pg = player:FindFirstChildOfClass("PlayerGui")
        if not pg then return end
        local sg = Instance.new("ScreenGui")
        sg.Name = MW_T.gui .. "_ColorTable"
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.DisplayOrder = 120
        sg.IgnoreGuiInset = true
        pcall(function()
            if syn and syn.protect_gui then syn.protect_gui(sg)
            elseif protectgui then protectgui(sg) end
        end)
        sg.Parent = (gethui and gethui()) or pg
        CT.gui = sg
        local accent = hexToColor3(Settings.UI.AccentHex or "6759B3")
        local bg = hexToColor3(Settings.UI.BackgroundHex or "16161F")
        local surface = hexToColor3(Settings.UI.SurfaceHex or "181925")
        local panel = Instance.new("Frame")
        panel.Size = UDim2.fromOffset(420, 520)
        panel.Position = UDim2.new(0.5, -210, 0.5, -260)
        panel.BackgroundColor3 = bg
        panel.BorderSizePixel = 0
        panel.Parent = sg
        Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke")
        stroke.Color = accent
        stroke.Thickness = 1
        stroke.Transparency = 0.45
        stroke.Parent = panel
        local accentBar = Instance.new("Frame")
        accentBar.Size = UDim2.new(0, 3, 1, -20)
        accentBar.Position = UDim2.new(0, 8, 0, 10)
        accentBar.BackgroundColor3 = accent
        accentBar.BorderSizePixel = 0
        accentBar.Parent = panel
        Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)
        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -50, 0, 28)
        title.Position = UDim2.fromOffset(20, 10)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 15
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = Color3.fromRGB(240, 240, 245)
        title.Text = "Color Table"
        title.Parent = panel
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.fromOffset(28, 28)
        closeBtn.Position = UDim2.new(1, -36, 0, 10)
        closeBtn.BackgroundColor3 = surface
        closeBtn.Text = "x"
        closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.BorderSizePixel = 0
        closeBtn.Parent = panel
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
        closeBtn.MouseButton1Click:Connect(CT.close)
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -28, 1, -110)
        scroll.Position = UDim2.fromOffset(18, 44)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = accent
        scroll.CanvasSize = UDim2.fromOffset(0, 0)
        scroll.Parent = panel
        local y = 0
        local function section(label)
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency = 1
            l.Size = UDim2.new(1, -8, 0, 20)
            l.Position = UDim2.fromOffset(0, y)
            l.Font = Enum.Font.GothamBold
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextColor3 = accent
            l.Text = label
            l.Parent = scroll
            y = y + 22
        end
        local function addRow(def)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -8, 0, 28)
            row.Position = UDim2.fromOffset(0, y)
            row.BackgroundColor3 = surface
            row.BorderSizePixel = 0
            row.Parent = scroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
            local lab = Instance.new("TextLabel")
            lab.BackgroundTransparency = 1
            lab.Size = UDim2.new(0.38, 0, 1, 0)
            lab.Position = UDim2.fromOffset(8, 0)
            lab.Font = Enum.Font.Gotham
            lab.TextSize = 11
            lab.TextXAlignment = Enum.TextXAlignment.Left
            lab.TextColor3 = Color3.fromRGB(190, 192, 202)
            lab.Text = def.label
            lab.Parent = row
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(0.42, -4, 0, 22)
            box.Position = UDim2.new(0.38, 0, 0.5, -11)
            box.BackgroundColor3 = bg
            box.BorderSizePixel = 0
            box.Font = Enum.Font.GothamBold
            box.TextSize = 11
            box.TextColor3 = accent
            box.ClearTextOnFocus = false
            box.Text = "#" .. getHex(def)
            box.Parent = row
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
            local sw = Instance.new("Frame")
            sw.Size = UDim2.fromOffset(18, 18)
            sw.Position = UDim2.new(1, -26, 0.5, -9)
            sw.BackgroundColor3 = hexToColor3(getHex(def))
            sw.BorderSizePixel = 0
            sw.Parent = row
            Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 4)
            local swStroke = Instance.new("UIStroke")
            swStroke.Color = Color3.fromRGB(90, 90, 100)
            swStroke.Thickness = 1
            swStroke.Parent = sw
            box.FocusLost:Connect(function()
                if setHex(def, box.Text) then
                    box.Text = "#" .. getHex(def)
                    sw.BackgroundColor3 = hexToColor3(getHex(def))
                else
                    box.Text = "#" .. getHex(def)
                end
            end)
            UILib.ColorPicker.attachSwatch(sw, {
                parent = sg,
                getColor = function()
                    return hexToColor3(getHex(def))
                end,
                onChanged = function(c3)
                    local hx = color3ToHex(c3)
                    setHex(def, hx)
                    box.Text = "#" .. hx
                    sw.BackgroundColor3 = c3
                end,
            })
            table.insert(CT.rows, { def = def, box = box, swatch = sw })
            y = y + 32
        end
        section("Theme")
        for _, def in ipairs(THEME_ROWS) do addRow(def) end
        section("ESP")
        for _, def in ipairs(ESP_ROWS) do addRow(def) end
        scroll.CanvasSize = UDim2.fromOffset(0, y + 8)
        if focusEsp then
            scroll.CanvasPosition = Vector2.new(0, 150)
        end
        local link = Instance.new("TextButton")
        link.Size = UDim2.new(1, -36, 0, 22)
        link.Position = UDim2.new(0, 18, 1, -58)
        link.BackgroundColor3 = surface
        link.BorderSizePixel = 0
        link.Font = Enum.Font.Gotham
        link.TextSize = 11
        link.TextColor3 = Color3.fromRGB(210, 212, 220)
        link.Text = (Settings.ESP.LinkToAccent ~= false) and "ESP linked to Accent (click to unlink)" or "ESP custom colors (click to link Accent)"
        link.Parent = panel
        Instance.new("UICorner", link).CornerRadius = UDim.new(0, 6)
        link.MouseButton1Click:Connect(function()
            Settings.ESP.LinkToAccent = not (Settings.ESP.LinkToAccent ~= false)
            link.Text = (Settings.ESP.LinkToAccent ~= false) and "ESP linked to Accent (click to unlink)" or "ESP custom colors (click to link Accent)"
            CT.apply()
        end)
        local function mkBtn(text, x, cb)
            local b = Instance.new("TextButton")
            b.Size = UDim2.fromOffset(90, 24)
            b.Position = UDim2.new(0, x, 1, -28)
            b.BackgroundColor3 = surface
            b.BorderSizePixel = 0
            b.Font = Enum.Font.GothamBold
            b.TextSize = 11
            b.TextColor3 = Color3.fromRGB(235, 235, 240)
            b.Text = text
            b.Parent = panel
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            b.MouseButton1Click:Connect(cb)
            return b
        end
        mkBtn("Apply", 18, CT.apply)
        mkBtn("Reset", 114, function()
            if resetThemeDefaults then resetThemeDefaults() end
            Settings.ESP.LinkToAccent = true
            Settings.ESP.CloseHex, Settings.ESP.MediumHex = "FFFFFF", "E9EBEF"
            Settings.ESP.FarHex, Settings.ESP.VeryFarHex = "A2A5AA", "7D8086"
            Settings.ESP.BoxHex, Settings.ESP.TracerHex, Settings.ESP.SkeletonHex = "", "", ""
            Settings.ESP.ChamsHex, Settings.ESP.NameHex = "", ""
            Settings.ESP.OutlineHex = "D2D2DC"
            CT.close()
            CT.open(focusEsp)
            CT.apply()
        end)
        mkBtn("Copy", 210, function()
            local json = CT.exportJSON()
            if json and setclipboard then
                pcall(setclipboard, json)
                if sendNotification then sendNotification("Color Table", "Copied", 1.5) end
            end
        end)
        mkBtn("Paste", 306, function()
            local raw = nil
            pcall(function()
                if getclipboard then raw = getclipboard() end
            end)
            if raw and CT.importJSON(raw) then
                CT.close(); CT.open(focusEsp)
            elseif sendNotification then
                sendNotification("Color Table", "Paste failed", 2)
            end
        end)
    end
    UILib.openColorTable = function(focusEsp) CT.open(focusEsp == true) end
    UILib.closeColorTable = CT.close
end
local TraceDraw = (function()
    local TD = {
        drawings = {},
        connections = {},
        open = true,
        hasInit = false,
        _setVisible = nil,
        _window = nil,
        theme = {
            Accent = Color3.fromRGB(103, 89, 179),
            Background = Color3.fromRGB(22, 22, 31),
            Border = Color3.fromRGB(0, 0, 0),
            Border1 = Color3.fromRGB(50, 50, 50),
            Border2 = Color3.fromRGB(24, 25, 37),
            Border3 = Color3.fromRGB(10, 10, 10),
            PrimaryText = Color3.fromRGB(235, 235, 235),
            GroupBg = Color3.fromRGB(22, 23, 34),
            SectionBg = Color3.fromRGB(18, 18, 26),
            OptionBg = Color3.fromRGB(28, 29, 40),
            OptionText1 = Color3.fromRGB(245, 245, 245),
            OptionText2 = Color3.fromRGB(195, 195, 195),
            OptionText3 = Color3.fromRGB(145, 145, 145),
            TabSel = Color3.fromRGB(245, 245, 245),
            TabUnsel = Color3.fromRGB(145, 145, 145),
        },
        z = { window = 1000, dropdown = 1200, notif = 1400 },
    }
    local UIS = S.UserInputService
    local RS = S.RunService
    local TS = S.TweenService
    local cam = S.Workspace.CurrentCamera
    local function hasDrawing()
        return type(Drawing) == "table" and type(Drawing.new) == "function"
    end
    local function conn(sig, fn)
        local c = sig:Connect(fn)
        table.insert(TD.connections, c)
        return c
    end
    local function destroyDrawing(obj)
        pcall(function()
            if obj and obj.Remove then obj:Remove() end
        end)
    end
    local function draw(class, props)
        if not hasDrawing() then return nil end
        local ok, obj = pcall(function() return Drawing.new(class) end)
        if not ok or not obj then return nil end
        for k, v in pairs(props or {}) do
            pcall(function() obj[k] = v end)
        end
        if class == "Square" then
            pcall(function() obj.Rounding = 8 end)
        end
        table.insert(TD.drawings, obj)
        return obj
    end
    local function mousePos()
        return UIS:GetMouseLocation()
    end
    local function over(pos, size, m)
        if not pos or not size then return false end
        m = m or mousePos()
        return m.X >= pos.X and m.Y >= pos.Y and m.X <= pos.X + size.X and m.Y <= pos.Y + size.Y
    end
    local function nestBorder(parentPos, parentSize, z)
        local b1 = draw("Square", {
            Size = Vector2.new(parentSize.X + 2, parentSize.Y + 2),
            Position = Vector2.new(parentPos.X - 1, parentPos.Y - 1),
            Color = TD.theme.Border1,
            Filled = true,
            Visible = true,
            ZIndex = z - 1,
        })
        local b2 = draw("Square", {
            Size = Vector2.new(parentSize.X + 4, parentSize.Y + 4),
            Position = Vector2.new(parentPos.X - 2, parentPos.Y - 2),
            Color = TD.theme.Border3,
            Filled = true,
            Visible = true,
            ZIndex = z - 2,
        })
        return b1, b2
    end
    function TD.Unload()
        waitingForKey = false
        pcall(function()
            if UILib.ColorPicker and UILib.ColorPicker.close then UILib.ColorPicker.close() end
            if TD._overlay then TD._overlay:Destroy(); TD._overlay = nil end
        end)
        for _, c in ipairs(TD.connections) do pcall(function() c:Disconnect() end) end
        TD.connections = {}
        for _, d in ipairs(TD.drawings) do destroyDrawing(d) end
        TD.drawings = {}
        TD.hasInit = false
        TD.open = false
        TD._window = nil
    end
    function TD.SetOpen(bool)
        TD.open = bool == true
        if TD._setVisible then TD._setVisible(TD.open) end
    end
    function TD.syncFromSettings()
        local ui = Settings and Settings.UI or {}
        local accent = hexToColor3(ui.AccentHex or ui.ToggleHex or "6759B3")
        local bg = hexToColor3(ui.BackgroundHex or "16161F")
        local surface = hexToColor3(ui.SurfaceHex or "181925")
        TD.theme.Accent = accent
        TD.theme.Background = bg
        TD.theme.SectionBg = bg
        TD.theme.GroupBg = surface
        TD.theme.OptionBg = Color3.new(
            math.clamp(surface.R * 1.12, 0, 1),
            math.clamp(surface.G * 1.12, 0, 1),
            math.clamp(surface.B * 1.12, 0, 1)
        )
        TD.theme.Border2 = surface
        TD.theme.TabSel = Color3.fromRGB(245, 245, 245)
        TD.theme.TabUnsel = Color3.fromRGB(145, 145, 145)
        local win = TD._window
        if win and win.objects then
            local o = win.objects
            if o.bg then o.bg.Color = TD.theme.Background end
            if o.accent then o.accent.Color = TD.theme.Accent end
            if o.group then o.group.Color = TD.theme.GroupBg end
            if o.mid then o.mid.Color = TD.theme.Border2 end
            if o.title then o.title.Color = TD.theme.PrimaryText end
            if win.layoutTabs then win:layoutTabs() end
            if win.layoutSections then

                for _, tab in ipairs(win.tabs or {}) do
                    for _, sec in ipairs(tab.sections or {}) do
                        if sec.bg then sec.bg.Color = TD.theme.SectionBg end
                        if sec.top1 then sec.top1.Color = TD.theme.Accent end
                        if sec.top2 then sec.top2.Color = TD.theme.Accent end
                        if sec.title then sec.title.Color = TD.theme.PrimaryText end
                    end
                end
                win:layoutSections()
            end
        end
    end
    function TD.Notify(msg, dur)
        msg = tostring(msg or "")
        dur = tonumber(dur) or 2.5
        if sendNotification then
            pcall(function() sendNotification(MW.hub, msg, dur) end)
            return
        end
        local z = TD.z.notif
        local t = draw("Text", {
            Text = msg,
            Size = 13,
            Font = 2,
            Color = TD.theme.PrimaryText,
            Outline = true,
            Position = Vector2.new(20, 80),
            Visible = true,
            ZIndex = z,
        })
        local bg = draw("Square", {
            Size = Vector2.new((t and t.TextBounds and t.TextBounds.X or 120) + 16, 20),
            Position = Vector2.new(14, 76),
            Color = TD.theme.Background,
            Filled = true,
            Visible = true,
            ZIndex = z - 1,
        })
        local accent = draw("Square", {
            Size = Vector2.new(4, 20),
            Position = Vector2.new(14, 76),
            Color = TD.theme.Accent,
            Filled = true,
            Visible = true,
            ZIndex = z,
        })
        task.delay(dur, function()
            destroyDrawing(t); destroyDrawing(bg); destroyDrawing(accent)
        end)
    end
    function TD.getOverlayGui()
        if TD._overlay and TD._overlay.Parent then return TD._overlay end
        local pg = player:FindFirstChildOfClass("PlayerGui")
        if not pg then return nil end
        local sg = Instance.new("ScreenGui")
        sg.Name = MW_T.gui .. "_TDOverlay"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.DisplayOrder = 100000
        pcall(function()
            if syn and syn.protect_gui then syn.protect_gui(sg)
            elseif protectgui then protectgui(sg) end
        end)
        sg.Parent = (gethui and gethui()) or pg
        TD._overlay = sg
        return sg
    end
    function TD.pickColor(opts)
        opts = opts or {}
        local host = TD.getOverlayGui()
        if not host or not UILib.ColorPicker then return end
        local m = mousePos()
        local col = Color3.fromRGB(255, 255, 255)
        if opts.getColor then
            local ok, c = pcall(opts.getColor)
            if ok and typeof(c) == "Color3" then col = c end
        elseif typeof(opts.color) == "Color3" then
            col = opts.color
        end
        local win = TD._window
        local vs = (cam and cam.ViewportSize) or Vector2.new(1920, 1080)
        local pickW, pickH = 152, 152

        local anchor
        if win and win.pos and win.size then
            anchor = Vector2.new(win.pos.X + win.size.X + 10, win.pos.Y + 40)
            if anchor.X + pickW > vs.X - 8 then
                anchor = Vector2.new(math.max(8, win.pos.X - pickW - 10), win.pos.Y + 40)
            end
            if anchor.Y + pickH > vs.Y - 8 then
                anchor = Vector2.new(anchor.X, math.max(8, vs.Y - pickH - 8))
            end
        else
            anchor = opts.anchor or Vector2.new(m.X + 12, m.Y + 12)
            if anchor.X + pickW > vs.X - 8 then
                anchor = Vector2.new(math.max(8, anchor.X - pickW - 12), anchor.Y)
            end
            if anchor.Y + pickH > vs.Y - 8 then
                anchor = Vector2.new(anchor.X, math.max(8, vs.Y - pickH - 8))
            end
        end
        UILib.ColorPicker.open({
            parent = host,
            color = col,
            alpha = opts.alpha or 1,
            owner = opts.owner or host,
            anchor = anchor,
            onChanged = function(c3, a)
                if opts.setColor then pcall(opts.setColor, c3, a) end
                if opts.onSwatch then pcall(opts.onSwatch, c3) end
            end,
        })
    end
    function TD.NewWindow(opts)
        opts = opts or {}
        local rawTitle = opts.title or ("Melo " .. tostring(MW.display or ""))
        local titleHead, titleTail = rawTitle:gsub("🍃", ""):match("^(Melo)%s*(.*)$")
        if not titleHead then
            titleHead = rawTitle:gsub("🍃", "")
            titleTail = ""
        end
        local size = opts.size or Vector2.new(560, 620)
        local pos = opts.position or Vector2.new(220, 120)
        local z = TD.z.window
        local win = {
            tabs = {},
            selected = nil,
            pos = pos,
            size = size,
            visible = true,
            objects = {},
            layoutTabs = function() end,
            layoutSections = function() end,
            AddTab = function() end,
            SetVisible = function() end,
        }
        local function place()
            local p, s = win.pos, win.size
            win.objects.bg.Position = p
            win.objects.bg.Size = s
            win.objects.mid.Position = Vector2.new(p.X - 5, p.Y - 20)
            win.objects.mid.Size = Vector2.new(s.X + 10, s.Y + 25)
            win.objects.title.Position = Vector2.new(p.X + 2, p.Y - 17)
            if win.objects.titleRest then
                local ox, oy = p.X + 40, p.Y - 6
                local function tri(part, a, b, c)
                    if not part then return end
                    pcall(function()
                        part.PointA = a
                        part.PointB = b
                        part.PointC = c
                    end)
                end
                local function stem(part, a, b)
                    if not part then return end
                    pcall(function() part.From = a end)
                    pcall(function() part.To = b end)
                    pcall(function() part.PointA = a end)
                    pcall(function() part.PointB = b end)
                end
                tri(win.objects.leafA, Vector2.new(ox, oy - 9), Vector2.new(ox - 7, oy + 2), Vector2.new(ox + 1, oy + 5))
                tri(win.objects.leafB, Vector2.new(ox, oy - 9), Vector2.new(ox + 6, oy + 1), Vector2.new(ox + 1, oy + 5))
                stem(win.objects.leafStem, Vector2.new(ox + 1, oy + 4), Vector2.new(ox - 3, oy + 9))
                local ox2 = ox + 8
                tri(win.objects.leafC, Vector2.new(ox2 + 1, oy - 7), Vector2.new(ox2 - 4, oy + 1), Vector2.new(ox2 + 1, oy + 4))
                tri(win.objects.leafD, Vector2.new(ox2 + 1, oy - 7), Vector2.new(ox2 + 6, oy), Vector2.new(ox2 + 1, oy + 4))
                stem(win.objects.leafStem2, Vector2.new(ox2 + 1, oy + 3), Vector2.new(ox2 - 1, oy + 8))
                local function dot(part, x, y)
                    if part then part.Position = Vector2.new(x, y) end
                end
                dot(win.objects.leafP1, ox, oy - 7)
                dot(win.objects.leafP2, ox - 1, oy - 2)
                dot(win.objects.leafP3, ox + 2, oy + 2)
                dot(win.objects.leafP4, ox2 + 2, oy - 5)
                dot(win.objects.leafP5, ox2 + 4, oy - 1)
                dot(win.objects.leafP6, ox2 + 1, oy + 2)
                win.objects.titleRest.Position = Vector2.new(p.X + 62, p.Y - 17)
            end
            win.objects.accent.Position = p
            win.objects.accent.Size = Vector2.new(s.X, 1)
            win.objects.group.Position = Vector2.new(p.X + 8, p.Y + 31)
            win.objects.group.Size = Vector2.new(s.X - 16, s.Y - 39)
            win.objects.col1.Position = Vector2.new(p.X + 18, p.Y + 58)
            win.objects.col1.Size = Vector2.new((s.X - 44) * 0.485, s.Y - 76)
            win.objects.col2.Position = Vector2.new(p.X + 18 + (s.X - 44) * 0.515, p.Y + 58)
            win.objects.col2.Size = Vector2.new((s.X - 44) * 0.485, s.Y - 76)
            if win.objects.b1 then
                win.objects.b1.Position = Vector2.new(p.X - 1, p.Y - 1)
                win.objects.b1.Size = Vector2.new(s.X + 2, s.Y + 2)
                win.objects.b2.Position = Vector2.new(p.X - 2, p.Y - 2)
                win.objects.b2.Size = Vector2.new(s.X + 4, s.Y + 4)
            end
            win:layoutTabs()
            win:layoutSections()
        end
        win.objects.mid = draw("Square", { Color = TD.theme.Border2, Filled = true, Visible = true, ZIndex = z - 3 })
        win.objects.b2 = draw("Square", { Color = TD.theme.Border3, Filled = true, Visible = true, ZIndex = z - 5 })
        win.objects.b1 = draw("Square", { Color = TD.theme.Border1, Filled = true, Visible = true, ZIndex = z - 4 })
        win.objects.bg = draw("Square", { Color = TD.theme.Background, Filled = true, Visible = true, ZIndex = z })
        win.objects.accent = draw("Square", { Color = TD.theme.Accent, Filled = true, Visible = true, ZIndex = z + 1 })
        win.objects.title = draw("Text", {
            Text = titleHead, Size = 13, Font = 2, Color = TD.theme.PrimaryText,
            Outline = true, Visible = true, ZIndex = z + 2,
        })
        if titleHead == "Melo" then
            local g1 = Color3.fromRGB(78, 168, 72)
            local g2 = Color3.fromRGB(112, 196, 88)
            win.objects.leafA = draw("Triangle", { Filled = true, Color = g1, Visible = true, ZIndex = z + 4 })
            win.objects.leafB = draw("Triangle", { Filled = true, Color = g2, Visible = true, ZIndex = z + 4 })
            win.objects.leafC = draw("Triangle", { Filled = true, Color = g2, Visible = true, ZIndex = z + 4 })
            win.objects.leafD = draw("Triangle", { Filled = true, Color = g1, Visible = true, ZIndex = z + 4 })
            win.objects.leafStem = draw("Line", { Thickness = 1.5, Color = Color3.fromRGB(54, 110, 48), Visible = true, ZIndex = z + 5 })
            win.objects.leafStem2 = draw("Line", { Thickness = 1.5, Color = Color3.fromRGB(54, 110, 48), Visible = true, ZIndex = z + 5 })
            if not win.objects.leafA then
                local function blob(r)
                    return draw("Circle", { Radius = r, NumSides = 16, Filled = true, Color = g1, Visible = true, ZIndex = z + 4 })
                end
                win.objects.leafP1 = blob(2)
                win.objects.leafP2 = blob(3.5)
                win.objects.leafP3 = blob(3)
                win.objects.leafP4 = blob(2)
                win.objects.leafP5 = blob(2)
                win.objects.leafP6 = blob(3)
            end
            win.objects.titleRest = draw("Text", {
                Text = titleTail, Size = 13, Font = 2, Color = TD.theme.PrimaryText,
                Outline = true, Visible = true, ZIndex = z + 2,
            })
        end
        win.objects.group = draw("Square", { Color = TD.theme.GroupBg, Filled = true, Visible = true, ZIndex = z + 5 })
        win.objects.col1 = draw("Square", { Color = TD.theme.Background, Filled = false, Transparency = 1, Visible = true, ZIndex = z + 6 })
        win.objects.col2 = draw("Square", { Color = TD.theme.Background, Filled = false, Transparency = 1, Visible = true, ZIndex = z + 6 })
        local dragging, dragStart, posStart = false, nil, nil
        conn(UIS.InputBegan, function(input, gpe)
            if gpe or not TD.open or not win.visible then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local m = mousePos()
                if over(Vector2.new(win.pos.X - 5, win.pos.Y - 20), Vector2.new(win.size.X + 10, 20), m) then
                    dragging = true
                    dragStart = m
                    posStart = win.pos
                end
            end
        end)
        conn(UIS.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        conn(UIS.InputChanged, function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local m = mousePos()
                win.pos = Vector2.new(posStart.X + (m.X - dragStart.X), posStart.Y + (m.Y - dragStart.Y))
                place()
            end
        end)
        function win:layoutTabs()
            local x = self.pos.X + 8
            local y = self.pos.Y + 8
            for _, tab in ipairs(self.tabs) do
                local w = math.max(58, (tab.label.TextBounds and tab.label.TextBounds.X or 40) + 20)
                tab.bg.Position = Vector2.new(x, y)
                tab.bg.Size = Vector2.new(w, 22)
                tab.label.Position = Vector2.new(x + w * 0.5, y + 4)
                tab.top.Position = Vector2.new(x, y)
                tab.top.Size = Vector2.new(w, 3)
                local sel = tab == self.selected
                tab.bg.Color = sel and TD.theme.GroupBg or TD.theme.Background
                tab.label.Color = sel and TD.theme.TabSel or TD.theme.TabUnsel
                tab.top.Color = sel and TD.theme.Accent or TD.theme.Background
                tab.bg.Visible = self.visible and TD.open
                tab.label.Visible = self.visible and TD.open
                tab.top.Visible = self.visible and TD.open
                x = x + w + 2
            end
        end
        function win:layoutSections()
            local colY = { 0, 0 }
            for _, tab in ipairs(self.tabs) do
                local showTab = (tab == self.selected) and self.visible and TD.open
                for _, sec in ipairs(tab.sections) do
                    local col = sec.side == 2 and 2 or 1
                    local holder = col == 1 and self.objects.col1 or self.objects.col2
                    local base = holder.Position
                    local width = holder.Size.X
                    local yOff = colY[col]
                    for _, opt in ipairs(sec.options) do
                        if opt.prepare then pcall(opt.prepare, width) end
                    end
                    local innerH = 18
                    for _, opt in ipairs(sec.options) do
                        if opt.enabled ~= false then innerH = innerH + (opt.height or 18) end
                    end
                    sec.bg.Size = Vector2.new(width, innerH)
                    sec.bg.Position = Vector2.new(base.X, base.Y + yOff)
                    if sec.outline then
                        sec.outline.Position = Vector2.new(base.X, base.Y + yOff)
                        sec.outline.Size = Vector2.new(width, innerH)
                        sec.outline.Color = TD.theme.Border1
                        sec.outline.Visible = showTab
                    end
                    sec.top1.Position = Vector2.new(base.X - 1, base.Y + yOff)
                    sec.top1.Size = Vector2.new(math.max(8, width * 0.04), 2)
                    sec.top2.Position = Vector2.new(base.X + width * 0.25, base.Y + yOff)
                    sec.top2.Size = Vector2.new(width * 0.75, 2)
                    sec.title.Position = Vector2.new(base.X + width * 0.05, base.Y + yOff - 7)
                    sec.bg.Color = TD.theme.SectionBg
                    sec.top1.Color = TD.theme.Accent
                    sec.top2.Color = TD.theme.Accent
                    sec.title.Color = TD.theme.PrimaryText
                    sec.bg.Visible = showTab
                    sec.top1.Visible = showTab
                    sec.top2.Visible = showTab
                    sec.title.Visible = showTab
                    local oy = 12
                    for _, opt in ipairs(sec.options) do
                        local oh = opt.height or 18
                        if opt.layout then
                            pcall(opt.layout, sec.bg.Position, width, oy, showTab and opt.enabled ~= false)
                        end
                        if opt.enabled ~= false then oy = oy + oh end
                    end
                    if showTab then colY[col] = colY[col] + innerH + 18 end
                end
            end
        end
        function win:AddTab(name)
            local tab = { name = name, sections = {}, bg = nil, label = nil, top = nil }
            tab.bg = draw("Square", { Color = TD.theme.Background, Filled = true, Visible = true, ZIndex = z + 7 })
            tab.top = draw("Square", { Color = TD.theme.Accent, Filled = true, Visible = true, ZIndex = z + 8 })
            tab.label = draw("Text", {
                Text = name, Size = 13, Font = 2, Color = TD.theme.TabUnsel,
                Outline = true, Center = true, Visible = true, ZIndex = z + 9,
            })
            conn(UIS.InputBegan, function(input)
                if not TD.open or not win.visible then return end
                if UILib.ColorPicker and UILib.ColorPicker._active then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local tp = tab.bg.Position
                    local ts = tab.bg.Size
                    if tp and ts and over(Vector2.new(tp.X - 2, tp.Y - 2), Vector2.new(ts.X + 4, ts.Y + 6)) then
                        win.selected = tab
                        win:layoutTabs()
                        win:layoutSections()
                    end
                end
            end)
            table.insert(self.tabs, tab)
            if not self.selected then self.selected = tab end
            function tab:AddSection(text, side)
                local sec = {
                    text = text,
                    side = side or 1,
                    options = {},
                    bg = draw("Square", { Color = TD.theme.SectionBg, Filled = true, Visible = true, ZIndex = z + 10 }),
                    outline = draw("Square", { Color = TD.theme.Border1, Filled = false, Thickness = 1, Visible = true, ZIndex = z + 11 }),
                    top1 = draw("Square", { Color = TD.theme.Accent, Filled = true, Visible = true, ZIndex = z + 12 }),
                    top2 = draw("Square", { Color = TD.theme.Accent, Filled = true, Visible = true, ZIndex = z + 11 }),
                    title = draw("Text", {
                        Text = text, Size = 13, Font = 2, Color = TD.theme.PrimaryText,
                        Outline = true, Visible = true, ZIndex = z + 12,
                    }),
                }
                table.insert(self.sections, sec)
                local function addOpt(opt)
                    table.insert(sec.options, opt)
                    return opt
                end
                function sec:AddToggle(data)
                    data = data or {}
                    local state = data.default == true
                    local hasColor = type(data.getColor) == "function"
                    local box = draw("Circle", { Radius = 7, NumSides = 24, Filled = true, Color = TD.theme.OptionBg, Visible = true, ZIndex = z + 13 })
                    local border = draw("Circle", { Radius = 8, NumSides = 24, Filled = false, Thickness = 1.4, Color = TD.theme.Border1, Visible = true, ZIndex = z + 14 })
                    local markInk = Color3.fromRGB(245, 245, 250)
                    local markA = draw("Line", { Thickness = 2, Color = markInk, Visible = false, ZIndex = z + 15 })
                    local markB = draw("Line", { Thickness = 2, Color = markInk, Visible = false, ZIndex = z + 15 })
                    local markDot
                    if not markA then
                        markDot = draw("Square", { Size = Vector2.new(6, 6), Color = markInk, Filled = true, Visible = false, ZIndex = z + 15 })
                    end
                    local function placeLine(line, a, b)
                        if not line then return end
                        pcall(function() line.From = a end)
                        pcall(function() line.To = b end)
                        pcall(function() line.PointA = a end)
                        pcall(function() line.PointB = b end)
                    end
                    local label = draw("Text", {
                        Text = data.text or "Toggle", Size = 13, Font = 2, Color = TD.theme.OptionText3,
                        Outline = true, Visible = true, ZIndex = z + 13,
                    })
                    local hitPos = Vector2.new(0, 0)
                    local swBorder, swatch, swPos, swSize, swHitPos, swHitSize
                    if hasColor then
                        swBorder = draw("Square", { Size = Vector2.new(22, 12), Color = Color3.fromRGB(220, 220, 225), Filled = true, Visible = true, ZIndex = z + 12 })
                        swatch = draw("Square", { Size = Vector2.new(20, 10), Color = Color3.fromRGB(255, 255, 255), Filled = true, Visible = true, ZIndex = z + 13 })
                        swPos = Vector2.new(0, 0)
                        swSize = Vector2.new(22, 12)
                        swHitPos = Vector2.new(0, 0)
                        swHitSize = Vector2.new(28, 16)
                        local ok, c = pcall(data.getColor)
                        if ok and typeof(c) == "Color3" then swatch.Color = c end
                    end
                    local shown = false
                    local function paint()
                        if box then box.Color = state and TD.theme.Accent or TD.theme.OptionBg end
                        if border then border.Color = state and TD.theme.Accent or TD.theme.Border1 end
                        label.Color = state and TD.theme.OptionText1 or TD.theme.OptionText3
                        local on = shown and state
                        if markA then markA.Visible = on end
                        if markB then markB.Visible = on end
                        if markDot then markDot.Visible = on end
                    end
                    paint()
                    local opt = {
                        height = 20,
                        enabled = true,
                        layout = function(origin, width, oy, vis)
                            local cx = origin.X + 14
                            local cy = origin.Y + oy + 10
                            shown = vis and true or false
                            if box then box.Position = Vector2.new(cx, cy) end
                            if border then border.Position = Vector2.new(cx, cy) end
                            placeLine(markA, Vector2.new(cx - 4, cy), Vector2.new(cx - 1, cy + 3))
                            placeLine(markB, Vector2.new(cx - 1, cy + 3), Vector2.new(cx + 4, cy - 4))
                            local on = vis and state
                            if markA then markA.Visible = on end
                            if markB then markB.Visible = on end
                            if markDot then
                                markDot.Position = Vector2.new(cx - 3, cy - 3)
                                markDot.Visible = on
                            end
                            hitPos = Vector2.new(cx - 8, cy - 8)
                            label.Position = Vector2.new(origin.X + 28, origin.Y + oy + 3)
                            if border then border.Visible = vis end
                            if box then box.Visible = vis end
                            label.Visible = vis
                            if hasColor then
                                swPos = Vector2.new(origin.X + width - 28, origin.Y + oy + 4)
                                swSize = Vector2.new(22, 12)
                                swHitPos = Vector2.new(swPos.X - 3, swPos.Y - 2)
                                swHitSize = Vector2.new(28, 16)
                                swBorder.Position = swPos
                                swatch.Position = Vector2.new(swPos.X + 1, swPos.Y + 1)
                                swBorder.Visible = vis
                                swatch.Visible = vis
                                local ok, c = pcall(data.getColor)
                                if ok and typeof(c) == "Color3" then swatch.Color = c end
                            end
                        end,
                    }
                    conn(UIS.InputBegan, function(input, gpe)
                        if not TD.open or not win.visible or win.selected ~= tab then return end
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                        if hasColor and over(swHitPos or swPos, swHitSize or swSize) then
                            TD.pickColor({
                                getColor = data.getColor,
                                setColor = data.setColor,
                                owner = swatch,
                                anchor = Vector2.new(swPos.X + swSize.X + 6, swPos.Y),
                                onSwatch = function(c3)
                                    if swatch then swatch.Color = c3 end
                                end,
                            })
                            return
                        end
                        local toggleW = math.max(80, (label.TextBounds and label.TextBounds.X or 60) + 28)
                        if hasColor then
                            toggleW = math.min(toggleW, (swPos.X - border.Position.X) - 4)
                        end
                        if over(hitPos, Vector2.new(math.max(40, toggleW), 16)) then
                            state = not state
                            paint()
                            if data.callback then pcall(data.callback, state) end
                        end
                    end)
                    return addOpt(opt)
                end
                function sec:AddColor(data)
                    data = data or {}
                    local label = draw("Text", {
                        Text = data.text or "Color", Size = 13, Font = 2, Color = TD.theme.OptionText2,
                        Outline = true, Visible = true, ZIndex = z + 13,
                    })
                    local swBorder = draw("Square", { Size = Vector2.new(22, 12), Color = Color3.fromRGB(220, 220, 225), Filled = true, Visible = true, ZIndex = z + 12 })
                    local swatch = draw("Square", { Size = Vector2.new(20, 10), Color = Color3.fromRGB(255, 255, 255), Filled = true, Visible = true, ZIndex = z + 13 })
                    local swPos = Vector2.new(0, 0)
                    local swSize = Vector2.new(22, 12)
                    local swHitPos = Vector2.new(0, 0)
                    local swHitSize = Vector2.new(28, 16)
                    if type(data.getColor) == "function" then
                        local ok, c = pcall(data.getColor)
                        if ok and typeof(c) == "Color3" then swatch.Color = c end
                    end
                    local opt = {
                        height = 20,
                        enabled = true,
                        layout = function(origin, width, oy, vis)
                            label.Position = Vector2.new(origin.X + 6, origin.Y + oy + 3)
                            swPos = Vector2.new(origin.X + width - 28, origin.Y + oy + 4)
                            swSize = Vector2.new(22, 12)
                            swHitPos = Vector2.new(swPos.X - 3, swPos.Y - 2)
                            swHitSize = Vector2.new(28, 16)
                            swBorder.Position = swPos
                            swatch.Position = Vector2.new(swPos.X + 1, swPos.Y + 1)
                            label.Visible = vis
                            swBorder.Visible = vis
                            swatch.Visible = vis
                            if type(data.getColor) == "function" then
                                local ok, c = pcall(data.getColor)
                                if ok and typeof(c) == "Color3" then swatch.Color = c end
                            end
                        end,
                    }
                    conn(UIS.InputBegan, function(input, gpe)
                        if not TD.open or not win.visible or win.selected ~= tab then return end
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and over(swHitPos, swHitSize) then
                            TD.pickColor({
                                getColor = data.getColor,
                                setColor = data.setColor,
                                owner = swatch,
                                anchor = Vector2.new(swPos.X + swSize.X + 6, swPos.Y),
                                onSwatch = function(c3)
                                    swatch.Color = c3
                                end,
                            })
                        end
                    end)
                    return addOpt(opt)
                end
                function sec:AddSlider(data)
                    data = data or {}
                    local minv = data.min or 0
                    local maxv = data.max or 100
                    local value = tonumber(data.default) or minv
                    local draggingS = false
                    local label = draw("Text", {
                        Text = (data.text or "Slider") .. ": " .. tostring(value),
                        Size = 13, Font = 2, Color = TD.theme.OptionText2,
                        Outline = true, Visible = true, ZIndex = z + 13,
                    })
                    local track = draw("Square", { Size = Vector2.new(100, 4), Color = TD.theme.OptionBg, Filled = true, Visible = true, ZIndex = z + 12 })
                    local fill = draw("Square", { Size = Vector2.new(40, 4), Color = TD.theme.Accent, Filled = true, Visible = true, ZIndex = z + 13 })
                    local knob = draw("Circle", { Radius = 5, NumSides = 24, Filled = true, Color = Color3.fromRGB(245, 245, 245), Visible = true, ZIndex = z + 14 })
                    local trackPos = Vector2.new(0, 0)
                    local trackW = 100
                    local function setValue(v, fire)
                        value = math.clamp(v, minv, maxv)
                        if data.increment then
                            local inc = data.increment
                            value = math.floor(value / inc + 0.5) * inc
                        end
                        local t = (maxv == minv) and 0 or ((value - minv) / (maxv - minv))
                        local fw = math.max(2, trackW * t)
                        fill.Size = Vector2.new(fw, 4)
                        fill.Position = trackPos
                        if knob then knob.Position = Vector2.new(trackPos.X + fw, trackPos.Y + 2) end
                        label.Text = (data.text or "Slider") .. ": " .. tostring(value) .. tostring(data.suffix or "")
                        if fire and data.callback then pcall(data.callback, value) end
                    end
                    local opt = {
                        height = 34,
                        enabled = true,
                        layout = function(origin, width, oy, vis)
                            trackW = width - 14
                            trackPos = Vector2.new(origin.X + 6, origin.Y + oy + 20)
                            label.Position = Vector2.new(origin.X + 6, origin.Y + oy + 2)
                            track.Position = trackPos
                            track.Size = Vector2.new(trackW, 4)
                            setValue(value, false)
                            label.Visible = vis; track.Visible = vis; fill.Visible = vis
                            if knob then knob.Visible = vis end
                        end,
                    }
                    conn(UIS.InputBegan, function(input, gpe)
                        if gpe or not TD.open or win.selected ~= tab then return end
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and over(trackPos, Vector2.new(trackW, 10)) then
                            draggingS = true
                            local m = mousePos()
                            local t = math.clamp((m.X - trackPos.X) / trackW, 0, 1)
                            setValue(minv + (maxv - minv) * t, true)
                        end
                    end)
                    conn(UIS.InputEnded, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingS = false end
                    end)
                    conn(UIS.InputChanged, function(input)
                        if draggingS and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local m = mousePos()
                            local t = math.clamp((m.X - trackPos.X) / trackW, 0, 1)
                            setValue(minv + (maxv - minv) * t, true)
                        end
                    end)
                    setValue(value, false)
                    return addOpt(opt)
                end
                function sec:AddButton(data)
                    data = data or {}
                    local bg = draw("Square", { Size = Vector2.new(100, 14), Color = TD.theme.OptionBg, Filled = true, Visible = true, ZIndex = z + 12 })
                    local border = draw("Square", { Size = Vector2.new(102, 16), Color = TD.theme.Border1, Filled = true, Visible = true, ZIndex = z + 11 })
                    local label = draw("Text", {
                        Text = data.text or "Button", Size = 13, Font = 2, Color = TD.theme.OptionText3,
                        Outline = true, Center = true, Visible = true, ZIndex = z + 13,
                    })
                    local opt = {
                        height = 26,
                        enabled = true,
                        layout = function(origin, width, oy, vis)
                            border.Position = Vector2.new(origin.X + 4, origin.Y + oy + 4)
                            border.Size = Vector2.new(width - 8, 18)
                            bg.Position = Vector2.new(origin.X + 5, origin.Y + oy + 5)
                            bg.Size = Vector2.new(width - 10, 16)
                            label.Position = Vector2.new(origin.X + width * 0.5, origin.Y + oy + 5)
                            border.Visible = vis; bg.Visible = vis; label.Visible = vis
                        end,
                    }
                    conn(UIS.InputBegan, function(input, gpe)
                        if gpe or not TD.open or win.selected ~= tab then return end
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and over(border.Position, border.Size) then
                            bg.Color = TD.theme.Accent
                            label.Color = TD.theme.OptionText1
                            if data.callback then pcall(data.callback) end
                            task.delay(0.12, function()
                                bg.Color = TD.theme.OptionBg
                                label.Color = TD.theme.OptionText3
                            end)
                        end
                    end)
                    return addOpt(opt)
                end
                function sec:AddText(data)
                    data = data or {}
                    local raw = tostring(data.text or "")
                    local label = draw("Text", {
                        Text = raw,
                        Size = 13,
                        Font = 2,
                        Color = data.accent and TD.theme.Accent or TD.theme.OptionText2,
                        Outline = true,
                        Visible = true,
                        ZIndex = z + 13,
                    })
                    return addOpt({
                        height = 16,
                        enabled = true,
                        layout = function(origin, width, oy, vis)
                            if not label or not origin then return end
                            local wnum = typeof(width) == "number" and width or tonumber(width) or 200
                            local maxChars = math.max(10, math.floor((wnum - 14) / 7))
                            local text = raw
                            if #text > maxChars then
                                text = string.sub(text, 1, math.max(1, maxChars - 3)) .. "..."
                            end
                            label.Text = text
                            label.Color = data.accent and TD.theme.Accent or TD.theme.OptionText2
                            label.Position = Vector2.new(origin.X + 6, origin.Y + oy + 1)
                            label.Visible = vis and true or false
                        end,
                    })
                end
                function sec:AddSeparator(data)
                    data = data or {}
                    local line = draw("Square", { Size = Vector2.new(80, 1), Color = TD.theme.OptionBg, Filled = true, Visible = true, ZIndex = z + 12 })
                    local label = draw("Text", {
                        Text = data.text or "", Size = 13, Font = 2, Color = TD.theme.OptionText2,
                        Outline = true, Center = true, Visible = true, ZIndex = z + 13,
                    })
                    return addOpt({
                        height = 16,
                        enabled = true,
                        layout = function(origin, width, oy, vis)
                            line.Position = Vector2.new(origin.X + 4, origin.Y + oy + 8)
                            line.Size = Vector2.new(width - 8, 1)
                            label.Position = Vector2.new(origin.X + width * 0.5, origin.Y + oy + 1)
                            line.Visible = vis; label.Visible = vis
                        end,
                    })
                end
                function sec:AddList(data)
                    data = data or {}
                    local values = data.values or {}
                    local idx = 1
                    for i, v in ipairs(values) do
                        if v == data.default then idx = i break end
                    end
                    local title = draw("Text", {
                        Text = tostring(data.text or "List"),
                        Size = 13, Font = 2, Color = TD.theme.OptionText2,
                        Outline = true, Visible = true, ZIndex = z + 13,
                    })
                    local bg = draw("Square", { Size = Vector2.new(100, 16), Color = TD.theme.OptionBg, Filled = true, Visible = true, ZIndex = z + 12 })
                    local valueLbl = draw("Text", {
                        Text = tostring(values[idx] or "none"),
                        Size = 13, Font = 2, Color = TD.theme.OptionText1,
                        Outline = true, Center = true, Visible = true, ZIndex = z + 13,
                    })
                    local hitPos, hitSize = Vector2.new(0, 0), Vector2.new(100, 16)
                    local opt = {
                        height = 36,
                        enabled = true,
                        layout = function(origin, width, oy, vis)
                            title.Position = Vector2.new(origin.X + 4, origin.Y + oy + 1)
                            hitPos = Vector2.new(origin.X + 4, origin.Y + oy + 16)
                            hitSize = Vector2.new(width - 8, 16)
                            bg.Position = hitPos
                            bg.Size = hitSize
                            valueLbl.Position = Vector2.new(hitPos.X + hitSize.X * 0.5, hitPos.Y + 1)
                            valueLbl.Text = tostring(values[idx] or "none")
                            title.Visible = vis; bg.Visible = vis; valueLbl.Visible = vis
                        end,
                    }
                    conn(UIS.InputBegan, function(input)
                        if not TD.open or not win.visible or win.selected ~= tab then return end
                        if UILib.ColorPicker and UILib.ColorPicker._active then return end
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and over(hitPos, hitSize) then
                            if #values == 0 then return end
                            idx = (idx % #values) + 1
                            valueLbl.Text = tostring(values[idx])
                            if data.callback then pcall(data.callback, values[idx]) end
                        end
                    end)
                    return addOpt(opt)
                end
                function sec:AddInput(data)
                    data = data or {}
                    local text = tostring(data.default or "")
                    local focused = false
                    local fieldBg = draw("Square", {
                        Size = Vector2.new(40, 16), Color = Color3.fromRGB(28, 29, 40),
                        Filled = true, Visible = true, ZIndex = z + 12,
                    })
                    local valueLbl = draw("Text", {
                        Text = text, Size = 13, Font = 2, Color = Color3.fromRGB(235, 235, 235),
                        Outline = false, Visible = true, ZIndex = z + 13,
                    })
                    local title = draw("Text", {
                        Text = tostring(data.text or "Input"),
                        Size = 13, Font = 2, Color = TD.theme.OptionText2,
                        Outline = true, Visible = true, ZIndex = z + 13,
                    })
                    local pasteLbl = draw("Text", {
                        Text = "Paste", Size = 12, Font = 2, Color = TD.theme.Accent,
                        Outline = true, Visible = true, ZIndex = z + 14,
                    })
                    local hitPos, hitSize = Vector2.new(0, 0), Vector2.new(40, 16)
                    local pastePos, pasteSize = Vector2.new(0, 0), Vector2.new(44, 16)
                    local boxApi = {}
                    local function render()
                        local shown = text
                        if #shown > 24 then shown = shown:sub(-24) end
                        if text == "" and not focused then
                            valueLbl.Text = tostring(data.placeholder or "click to type")
                            valueLbl.Color = Color3.fromRGB(130, 130, 140)
                        else
                            valueLbl.Text = shown .. (focused and "|" or "")
                            valueLbl.Color = Color3.fromRGB(235, 235, 235)
                        end
                        rawset(boxApi, "Text", text)
                    end
                    local function commit()
                        if data.callback then pcall(data.callback, text) end
                    end
                    local function pullClipboard()
                        local clip = ""
                        pcall(function()
                            if getclipboard then clip = getclipboard()
                            elseif Clipboard and Clipboard.get then clip = Clipboard.get() end
                        end)
                        clip = tostring(clip or "")
                        local id = clip:match("(%d%d%d+)") or clip:match("(%d+)") or clip:gsub("^%s+", ""):gsub("%s+$", "")
                        if id == "" then return end
                        text = id:sub(1, 48)
                        render()
                        commit()
                    end
                    local function setFocused(on)
                        focused = on and true or false
                        if focused then
                            TD.typing = true
                        elseif TD.typing then
                            TD.typing = false
                        end
                        render()
                    end
                    setmetatable(boxApi, {
                        __newindex = function(_, k, v)
                            if k == "Text" then
                                text = tostring(v or ""):sub(1, 48)
                                render()
                            end
                        end,
                        __index = function(_, k)
                            if k == "Text" then return text end
                        end,
                    })
                    render()
                    if data.onBox then pcall(data.onBox, boxApi) end
                    local opt = {
                        height = 36,
                        enabled = true,
                        layout = function(origin, width, oy, vis)
                            title.Position = Vector2.new(origin.X + 4, origin.Y + oy + 1)
                            local fieldW = math.max(40, width - 58)
                            hitPos = Vector2.new(origin.X + 4, origin.Y + oy + 16)
                            hitSize = Vector2.new(fieldW, 16)
                            pastePos = Vector2.new(origin.X + width - 46, origin.Y + oy + 16)
                            pasteSize = Vector2.new(42, 16)
                            if fieldBg then
                                fieldBg.Position = hitPos
                                fieldBg.Size = hitSize
                                fieldBg.Visible = vis
                            end
                            valueLbl.Position = Vector2.new(hitPos.X + 4, hitPos.Y + 1)
                            pasteLbl.Position = pastePos
                            title.Visible = vis
                            valueLbl.Visible = vis
                            pasteLbl.Visible = vis
                            if not vis and focused then setFocused(false) end
                        end,
                    }
                    local keyChar = {
                        Zero = "0", One = "1", Two = "2", Three = "3", Four = "4",
                        Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
                        Minus = "-", Space = " ",
                    }
                    conn(UIS.InputBegan, function(input)
                        if not TD.open or not win.visible or win.selected ~= tab then return end
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if over(pastePos, pasteSize) then
                                pullClipboard()
                                return
                            end
                            if over(hitPos, hitSize) then
                                setFocused(true)
                                return
                            end
                            if focused then
                                setFocused(false)
                                commit()
                            end
                            return
                        end
                        if not focused or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        local code = input.KeyCode
                        if code == Enum.KeyCode.Backspace then
                            text = text:sub(1, -2)
                            render()
                            return
                        end
                        if code == Enum.KeyCode.Return or code == Enum.KeyCode.Escape then
                            setFocused(false)
                            commit()
                            return
                        end
                        local ctrl = UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)
                        if ctrl and code == Enum.KeyCode.V then
                            pullClipboard()
                            return
                        end
                        if ctrl then return end
                        local ch
                        if UIS.GetStringForKeyCode then
                            local ok, s = pcall(function() return UIS:GetStringForKeyCode(code) end)
                            if ok and type(s) == "string" and #s == 1 then ch = s end
                        end
                        if not ch then
                            local name = code.Name
                            if keyChar[name] then
                                ch = keyChar[name]
                            elseif #name == 1 then
                                local shift = UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)
                                ch = shift and name or name:lower()
                            end
                        end
                        if ch and #text < 48 then
                            text = text .. ch
                            render()
                        end
                    end)
                    return addOpt(opt)
                end
                function sec:AddKeybind(data)
                    data = data or {}
                    local capturing = false
                    local key = restoreEnumBind(data.default, Enum.KeyCode.Unknown)
                    local function keyName(k)
                        k = restoreEnumBind(k, nil)
                        if not k or k == Enum.KeyCode.Unknown then return "None" end
                        if k.EnumType == Enum.UserInputType then
                            if k == Enum.UserInputType.MouseButton1 then return "M1" end
                            if k == Enum.UserInputType.MouseButton2 then return "M2" end
                            if k == Enum.UserInputType.MouseButton3 then return "M3" end
                        end
                        return tostring(k.Name or k)
                    end
                    local label = draw("Text", {
                        Text = (data.text or "Bind") .. ": " .. keyName(key),
                        Size = 13, Font = 2, Color = TD.theme.OptionText2,
                        Outline = true, Visible = true, ZIndex = z + 13,
                    })
                    local bg = draw("Square", { Size = Vector2.new(100, 14), Color = TD.theme.OptionBg, Filled = true, Visible = true, ZIndex = z + 12 })
                    local hitPos, hitSize = Vector2.new(0, 0), Vector2.new(100, 14)
                    local opt = {
                        height = 34,
                        enabled = true,
                        layout = function(origin, width, oy, vis)
                            label.Position = Vector2.new(origin.X + 4, origin.Y + oy + 1)
                            hitPos = Vector2.new(origin.X + 4, origin.Y + oy + 16)
                            hitSize = Vector2.new(width - 8, 14)
                            bg.Position = hitPos
                            bg.Size = hitSize
                            label.Visible = vis; bg.Visible = vis
                            if not capturing then
                                label.Text = (data.text or "Bind") .. ": " .. keyName(key)
                            end
                        end,
                    }
                    conn(UIS.InputBegan, function(input, gpe)
                        if not TD.open or not win.visible or win.selected ~= tab then return end
                        if capturing then
                            local bind
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                if input.KeyCode == Enum.KeyCode.Escape then
                                    bind = Enum.KeyCode.Unknown
                                else
                                    bind = input.KeyCode
                                end
                            elseif input.UserInputType == Enum.UserInputType.MouseButton1
                                or input.UserInputType == Enum.UserInputType.MouseButton2
                                or input.UserInputType == Enum.UserInputType.MouseButton3 then
                                if over(hitPos, hitSize) then return end
                                bind = input.UserInputType
                            end
                            if bind then
                                key = bind
                                capturing = false
                                waitingForKey = false
                                label.Text = (data.text or "Bind") .. ": " .. keyName(key)
                                label.Color = TD.theme.OptionText2
                                if data.callback then pcall(data.callback, key) end
                            end
                            return
                        end
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and over(hitPos, hitSize) then
                            capturing = true
                            waitingForKey = true
                            label.Text = (data.text or "Bind") .. ": ..."
                            label.Color = TD.theme.Accent
                        end
                    end)
                    return addOpt(opt)
                end
                return sec
            end
            return tab
        end
        function win:SetVisible(v)
            self.visible = v and true or false
            local show = self.visible and TD.open
            for _, o in pairs(self.objects) do
                if o and typeof(o) ~= "function" then pcall(function() o.Visible = show end) end
            end
            self:layoutTabs()
            self:layoutSections()
        end
        place()
        TD._window = win
        TD._setVisible = function(v) win:SetVisible(v) end
        return win
    end
    function TD.mountCmdBar(MD)
        MD = MD or {}
        local z = 2200
        local open = false
        local text = ""
        local pick = 1
        local shown = {}
        local rowHit = {}
        local barPos = Vector2.new(0, 0)
        local barSize = Vector2.new(440, 26)
        local bg = draw("Square", { Size = barSize, Color = Color3.fromRGB(16, 16, 22), Filled = true, Visible = false, ZIndex = z })
        local edge = draw("Square", { Size = Vector2.new(3, 26), Color = TD.theme.Accent, Filled = true, Visible = false, ZIndex = z + 1 })
        local prompt = draw("Text", { Text = ">", Size = 14, Font = 2, Color = TD.theme.Accent, Outline = false, Visible = false, ZIndex = z + 2 })
        local valueLbl = draw("Text", { Text = "", Size = 14, Font = 2, Color = Color3.fromRGB(235, 235, 235), Outline = false, Visible = false, ZIndex = z + 2 })
        local hist = {}
        local histAt = 0
        local draft = ""
        local rows = {}
        for i = 1, 9 do
            rows[i] = {
                bg = draw("Square", { Size = Vector2.new(440, 16), Color = Color3.fromRGB(22, 22, 30), Filled = true, Visible = false, ZIndex = z }),
                name = draw("Text", { Text = "", Size = 13, Font = 2, Color = TD.theme.Accent, Outline = false, Visible = false, ZIndex = z + 2 }),
                desc = draw("Text", { Text = "", Size = 13, Font = 2, Color = Color3.fromRGB(160, 160, 170), Outline = false, Visible = false, ZIndex = z + 2 }),
            }
        end
        local function rejoin()
            TD.Notify("Rejoining", 2)
            pcall(function() S.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end)
        end
        local function hop()
            if MD.FX and MD.FX.doServerHop then MD.FX.doServerHop()
            else TD.Notify("Server hop unavailable", 2) end
        end
        local function toggleFly()
            Settings.Movement.Fly = not Settings.Movement.Fly
            if Settings.Movement.Fly then
                if MD.startFly then MD.startFly() end
                TD.Notify("Fly on", 1.5)
            else
                if MD.stopFly then MD.stopFly() end
                TD.Notify("Fly off", 1.5)
            end
        end
        local function toggleNc()
            local on = not Settings.Movement.Noclip
            if MD.setNoclip then MD.setNoclip(on) end
            TD.Notify(on and "Noclip on" or "Noclip off", 1.5)
        end
        local function toggleEsp()
            Settings.ESP.Enabled = not Settings.ESP.Enabled
            if not Settings.ESP.Enabled and MD.clearAllESP then MD.clearAllESP() end
            TD.Notify(Settings.ESP.Enabled and "ESP on" or "ESP off", 1.5)
        end
        local function toggleAim()
            Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
            if not Settings.Aimbot.Enabled and MD.stopAimbotTracking then MD.stopAimbotTracking() end
            TD.Notify(Settings.Aimbot.Enabled and "Aim on" or "Aim off", 1.5)
        end
        local function panic()
            Settings.ESP.Enabled = false
            Settings.Aimbot.Enabled = false
            Settings.Combat.TriggerBot = false
            Settings.Combat.RageBot = false
            Settings.Movement.Fly = false
            Settings.Movement.Noclip = false
            if MD.stopAimbotTracking then MD.stopAimbotTracking() end
            if MD.stopFly then MD.stopFly() end
            if MD.stopRageBot then MD.stopRageBot() end
            if MD.setNoclip then MD.setNoclip(false) end
            if MD.clearAllESP then MD.clearAllESP() end
            TD.Notify("Panic", 2)
        end
        local function unload()
            if _G[MW_T.cleanup] then pcall(_G[MW_T.cleanup]) end
        end
        local list = {
            { name = "rj", keys = { "rj", "re", "rejoin" }, desc = "rejoin this server", run = rejoin },
            { name = "shop", keys = { "shop", "hop", "serverhop" }, desc = "server hop", run = hop },
            { name = "fly", keys = { "fly" }, desc = "toggle fly", run = toggleFly },
            { name = "nc", keys = { "nc", "noclip" }, desc = "toggle noclip", run = toggleNc },
            { name = "esp", keys = { "esp" }, desc = "toggle esp", run = toggleEsp },
            { name = "aim", keys = { "aim", "aimbot" }, desc = "toggle aimbot", run = toggleAim },
            { name = "panic", keys = { "panic" }, desc = "turn features off", run = panic },
            { name = "menu", keys = { "menu" }, desc = "toggle menu", run = function() TD.SetOpen(not TD.open) end },
            { name = "unload", keys = { "unload", "exit" }, desc = "unload script", run = unload },
            { name = "help", keys = { "help" }, desc = "show every command", keep = true },
        }
        local function tokenOf(raw)
            return (tostring(raw or ""):lower():match("^%s*(%S+)")) or ""
        end
        local function entryMatch(entry, token)
            if token == "" then return true end
            for _, k in ipairs(entry.keys) do
                if k:sub(1, #token) == token then return true end
            end
            return false
        end
        local function refresh()
            local vs = (S.Workspace.CurrentCamera and S.Workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)
            barPos = Vector2.new(math.floor(vs.X * 0.5 - barSize.X * 0.5), math.floor(vs.Y * 0.62))
            local vis = open
            if bg then
                bg.Position = barPos
                bg.Size = barSize
                bg.Visible = vis
            end
            if edge then
                edge.Position = barPos
                edge.Size = Vector2.new(3, barSize.Y)
                edge.Color = TD.theme.Accent
                edge.Visible = vis
            end
            if prompt then
                prompt.Position = Vector2.new(barPos.X + 10, barPos.Y + 5)
                prompt.Visible = vis
            end
            if valueLbl then
                local shownText = text
                if #shownText > 28 then shownText = shownText:sub(-28) end
                valueLbl.Text = shownText .. (vis and "|" or "")
                valueLbl.Position = Vector2.new(barPos.X + 24, barPos.Y + 5)
                valueLbl.Visible = vis
            end
            shown = {}
            local token = tokenOf(text)
            for _, entry in ipairs(list) do
                if entryMatch(entry, token) then
                    table.insert(shown, entry)
                    if #shown >= 9 then break end
                end
            end
            if pick > #shown then pick = math.max(1, #shown) end
            if pick < 1 then pick = 1 end
            for i = 1, 9 do
                local row = rows[i]
                local entry = shown[i]
                local y = barPos.Y + barSize.Y + 4 + (i - 1) * 18
                local on = vis and entry ~= nil
                rowHit[i] = { Vector2.new(barPos.X, y), Vector2.new(barSize.X, 16) }
                if row.bg then
                    row.bg.Position = Vector2.new(barPos.X, y)
                    row.bg.Size = Vector2.new(barSize.X, 16)
                    row.bg.Color = (i == pick and entry) and Color3.fromRGB(32, 32, 44) or Color3.fromRGB(18, 18, 26)
                    row.bg.Visible = on
                end
                if row.name then
                    row.name.Text = entry and entry.name or ""
                    row.name.Position = Vector2.new(barPos.X + 10, y + 1)
                    row.name.Color = (i == pick) and TD.theme.Accent or Color3.fromRGB(210, 210, 210)
                    row.name.Visible = on
                end
                if row.desc then
                    row.desc.Text = entry and entry.desc or ""
                    row.desc.Position = Vector2.new(barPos.X + 78, y + 1)
                    row.desc.Visible = on
                end
            end
        end
        local function setOpen(on)
            open = on and true or false
            TD.cmdOpen = open
            if open then
                text = ""
                pick = 1
                histAt = 0
            end
            refresh()
        end
        local function remember(s)
            s = tostring(s or "")
            if s == "" then return end
            if hist[#hist] == s then return end
            table.insert(hist, s)
            if #hist > 20 then table.remove(hist, 1) end
        end
        local function runEntry(entry)
            if not entry then
                TD.Notify("Unknown command", 1.5)
                return
            end
            if entry.keep then
                text = ""
                histAt = 0
                pick = 1
                refresh()
                return
            end
            remember(text ~= "" and text or entry.name)
            histAt = 0
            setOpen(false)
            pcall(entry.run)
        end
        local function runText()
            local token = tokenOf(text)
            if token == "" then
                if shown[pick] then runEntry(shown[pick]) end
                return
            end
            for _, entry in ipairs(list) do
                for _, k in ipairs(entry.keys) do
                    if k == token then
                        runEntry(entry)
                        return
                    end
                end
            end
            if shown[pick] then runEntry(shown[pick])
            elseif shown[1] then runEntry(shown[1])
            else TD.Notify("Unknown command", 1.5) end
        end
        local keys = {
            Zero = "0", One = "1", Two = "2", Three = "3", Four = "4",
            Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
            Minus = "-", Space = " ",
        }
        conn(UIS.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and open then
                if over(barPos, barSize) then return end
                for i = 1, #shown do
                    local hit = rowHit[i]
                    if hit and over(hit[1], hit[2]) then
                        runEntry(shown[i])
                        return
                    end
                end
                setOpen(false)
                return
            end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local code = input.KeyCode
            if code == Enum.KeyCode.Quote then
                if TD.typing and not open then return end
                setOpen(not open)
                return
            end
            if not open then return end
            if code == Enum.KeyCode.Escape then
                setOpen(false)
                return
            end
            if code == Enum.KeyCode.Return or code == Enum.KeyCode.KeypadEnter then
                runText()
                return
            end
            if code == Enum.KeyCode.Backspace then
                text = text:sub(1, -2)
                histAt = 0
                pick = 1
                refresh()
                return
            end
            if code == Enum.KeyCode.Up then
                if pick > 1 and histAt == 0 then
                    pick = pick - 1
                elseif #hist > 0 then
                    if histAt == 0 then
                        draft = text
                        histAt = #hist
                    elseif histAt > 1 then
                        histAt = histAt - 1
                    end
                    text = hist[histAt] or text
                    pick = 1
                end
                refresh()
                return
            end
            if code == Enum.KeyCode.Down then
                if histAt == 0 then
                    pick = math.min(#shown, pick + 1)
                elseif histAt < #hist then
                    histAt = histAt + 1
                    text = hist[histAt]
                    pick = 1
                else
                    histAt = 0
                    text = draft
                    pick = 1
                end
                refresh()
                return
            end
            local ch
            if UIS.GetStringForKeyCode then
                local ok, s = pcall(function() return UIS:GetStringForKeyCode(code) end)
                if ok and type(s) == "string" and #s == 1 and s ~= "'" then ch = s:lower() end
            end
            if not ch then
                local name = code.Name
                if keys[name] then ch = keys[name]
                elseif #name == 1 then ch = name:lower() end
            end
            if ch and #text < 24 then
                text = text .. ch
                histAt = 0
                pick = 1
                refresh()
            end
        end)
        TD._cmdRefresh = refresh
    end
    function TD.buildMenu(MD)
        if not hasDrawing() then
            TD.Notify("Drawing API missing: menu unavailable", 4)
            return nil
        end
        if TD.hasInit then TD.Unload() end
        TD.hasInit = true
        Settings.HUD.Watermark = false
        local win = TD.NewWindow({
            title = "Melo 🍃  ·  " .. tostring(MW.mode or "Universal") .. "  ·  pre alpha",
            size = Vector2.new(700, 760),
            position = Vector2.new(200, 70),
        })

        do
            local tab = win:AddTab("Home")
            local left = tab:AddSection("Session", 1)
            local execName = (MD and MD.getExecutorName and MD.getExecutorName()) or getExecutorName()
            left:AddText({ text = "Mode: " .. tostring(MW.mode), accent = true })
            left:AddText({ text = "Kit: " .. tostring(MW.kitId or MW.mode or "?") })
            left:AddText({ text = MW.kitSummary and MW.kitSummary() or "" })
            left:AddText({ text = "Executor: " .. tostring(execName) })
            left:AddText({ text = "PlaceId: " .. tostring(game.PlaceId) })
            left:AddText({
                text = "Players: " .. tostring(#S.Players:GetPlayers()) .. " / " .. tostring(S.Players.MaxPlayers),
            })
            if Cap and Cap.title then
                local weao = "WEAO: " .. tostring(Cap.title)
                if Cap.suncPct ~= nil then weao = weao .. " (" .. tostring(Cap.suncPct) .. "%)" end
                if Cap.updateStatus == false then weao = weao .. " outdated" end
                if Cap.detected == true then weao = weao .. " detected" end
                left:AddText({ text = weao })
            else
                left:AddText({ text = "WEAO: unmatched" })
            end
            if MW.allows("gunmods") then
                left:AddText({ text = "Gun mods: available" })
            elseif MW.allows("mm2") then
                left:AddText({ text = "MM2 kit: roles, farm, sheriff tools" })
            elseif MW.allows("phantomforces") then
                left:AddText({ text = "PF kit: silent aim, ESP, soft gun mods" })
            elseif MW.allows("brookhaven") then
                left:AddText({ text = "Brookhaven kit: RP / movement" })
            else
                left:AddText({ text = "Kit: " .. tostring(MW.mode) .. " settings only" })
            end
            left:AddToggle({ text = "Keybind List HUD", default = Settings.HUD.KeybindList == true, callback = function(e)
                Settings.HUD.KeybindList = e
            end })
            left:AddToggle({ text = "Nearby Strip HUD", default = Settings.HUD.SpectatorList == true, callback = function(e)
                Settings.HUD.SpectatorList = e
            end })
            local right = tab:AddSection("Quick", 2)
            right:AddText({ text = "RightControl: menu    ': commands" })
            right:AddButton({ text = "Unload Melo 🍃", callback = function()
                if _G[MW_T.cleanup] then pcall(_G[MW_T.cleanup]) end
            end })
            right:AddButton({ text = "Server Hop", callback = function()
                if MD.FX and MD.FX.doServerHop then MD.FX.doServerHop() end
            end })
            right:AddButton({ text = "Rejoin", callback = function()
                pcall(function() S.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end)
            end })
            if MW.allows("aim") and MW.allows("gunmods") then
                right:AddSeparator({ text = "Packs" })
                right:AddButton({ text = "Apply Legit Pack", callback = function()
                    if MD.applyConfigPack then MD.applyConfigPack("Legit") end
                    TD.Notify("Legit pack", 1.5)
                end })
                right:AddButton({ text = "Apply Semi Pack", callback = function()
                    if MD.applyConfigPack then MD.applyConfigPack("Semi") end
                    TD.Notify("Semi pack", 1.5)
                end })
                right:AddButton({ text = "Apply Rage Pack", callback = function()
                    if MD.applyConfigPack then MD.applyConfigPack("Rage") end
                    TD.Notify("Rage pack", 1.5)
                end })
            end
        end

        if MW.allows("mm2") then
            local tab = win:AddTab("MM2")
            local left = tab:AddSection("Roles / ESP", 1)
            left:AddToggle({ text = "Role Name ESP", default = Settings.MM2.NameESP ~= false, callback = function(e)
                Settings.MM2.NameESP = e
                if MD.TraceMM2 and MD.TraceMM2.refreshESP then MD.TraceMM2.refreshESP() end
            end })
            left:AddToggle({ text = "Player Chams", default = Settings.MM2.PlayerChams == true, callback = function(e)
                Settings.MM2.PlayerChams = e
                if MD.TraceMM2 then
                    if e then MD.TraceMM2.refreshChams() else MD.TraceMM2.clearChams() end
                end
            end })
            left:AddToggle({ text = "Gun Drop ESP", default = Settings.MM2.GunESP ~= false, callback = function(e)
                Settings.MM2.GunESP = e
                if MD.TraceMM2 then
                    if e then MD.TraceMM2.refreshGunEsp() else MD.TraceMM2.clearGunEsp() end
                end
            end })
            left:AddText({ text = "Red = Murderer / Blue = Sheriff" })
            left:AddToggle({ text = "Silent Aim", default = Settings.MM2.SilentAim ~= false, callback = function(e)
                Settings.MM2.SilentAim = e
            end })
            left:AddToggle({ text = "Auto Shoot Murderer", default = Settings.MM2.AutoShootMurderer == true, callback = function(e)
                Settings.MM2.AutoShootMurderer = e
            end })
            left:AddToggle({ text = "Kill Murderer Blatant", default = Settings.MM2.KillMurdererBlatant == true, callback = function(e)
                Settings.MM2.KillMurdererBlatant = e
            end })
            left:AddButton({ text = "Shoot Murderer Now", callback = function()
                if MD.TraceMM2 then MD.TraceMM2.shootMurderer(true) end
            end })
            left:AddKeybind({
                text = "Shoot Murderer Key",
                default = Settings.MM2.ShootKey or Enum.KeyCode.Q,
                callback = function(k)
                    Settings.MM2.ShootKey = k
                end,
            })
            local right = tab:AddSection("Combat / Farm", 2)
            right:AddToggle({ text = "Auto Farm Coins", default = Settings.MM2.AutoFarm == true, callback = function(e)
                Settings.MM2.AutoFarm = e
                if e and MD.TraceMM2 then MD.TraceMM2.farmLoop() end
            end })
            right:AddList({ text = "Farm Mode", values = {"Nearest","Randomize","Furthest","Safe Nearby"}, default = Settings.MM2.FarmMode or "Nearest", callback = function(v)
                Settings.MM2.FarmMode = v
            end })
            right:AddSlider({ text = "Farm Delay", min = 10, max = 100, default = math.floor((Settings.MM2.FarmDelay or 0.35) * 100), callback = function(v)
                Settings.MM2.FarmDelay = v / 100
            end })
            right:AddToggle({ text = "Auto Reset Full Bag", default = Settings.MM2.AutoResetFullBag == true, callback = function(e)
                Settings.MM2.AutoResetFullBag = e
            end })
            right:AddToggle({ text = "Auto Grab Gun (bring to you)", default = Settings.MM2.AutoGrabGun == true, callback = function(e)
                Settings.MM2.AutoGrabGun = e
            end })
            right:AddToggle({ text = "Kill Aura", default = Settings.MM2.KillAura == true, callback = function(e)
                Settings.MM2.KillAura = e
            end })
            right:AddSlider({ text = "Aura Distance", min = 1, max = 30, default = Settings.MM2.AuraDistance or 5, callback = function(v)
                Settings.MM2.AuraDistance = v
            end })
            right:AddToggle({ text = "Auto Kill All", default = Settings.MM2.AutoKillAll == true, callback = function(e)
                Settings.MM2.AutoKillAll = e
            end })
            right:AddToggle({ text = "Auto End Round", default = Settings.MM2.AutoEndRound == true, callback = function(e)
                Settings.MM2.AutoEndRound = e
            end })
            right:AddToggle({ text = "Anti AFK", default = Settings.MM2.AntiAFK ~= false, callback = function(e)
                Settings.MM2.AntiAFK = e
            end })
            right:AddToggle({ text = "Anti Fling", default = Settings.MM2.AntiFling ~= false, callback = function(e)
                Settings.MM2.AntiFling = e
            end })
        end
        if MW.allows("phantomforces") then
            local tab = win:AddTab("PF")
            local left = tab:AddSection("ESP / Aim", 1)
            left:AddText({ text = "Uses PF ReplicationInterface bodies (not Player.Character)" })
            left:AddToggle({ text = "ESP Enabled", default = Settings.ESP.Enabled == true, callback = function(e)
                Settings.ESP.Enabled = e
            end })
            left:AddToggle({ text = "Weapon Labels", default = Settings.PF.WeaponLabels ~= false, callback = function(e)
                Settings.PF.WeaponLabels = e
                Settings.ESP.WeaponLabels = e
            end })
            left:AddToggle({ text = "Show Health", default = Settings.PF.ShowHealth ~= false, callback = function(e)
                Settings.PF.ShowHealth = e
                Settings.ESP.HealthEnabled = e
            end })
            left:AddToggle({ text = "Team Colors", default = Settings.PF.TeamColors ~= false, callback = function(e)
                Settings.PF.TeamColors = e
            end })
            left:AddToggle({ text = "Skeleton", default = Settings.PF.Skeleton ~= false, callback = function(e)
                Settings.PF.Skeleton = e
                Settings.ESP.SkeletonEnabled = e
            end })
            left:AddToggle({ text = "Prefer Head Lock", default = Settings.PF.PreferHead ~= false, callback = function(e)
                Settings.PF.PreferHead = e
                if MD.TracePF then MD.TracePF.cache = {} end
            end })
            left:AddToggle({ text = "Camera Aimbot", default = Settings.Aimbot.Enabled == true, callback = function(e)
                Settings.Aimbot.Enabled = e
                Settings.Aimbot.AimMode = "Camera"
            end })
            left:AddToggle({ text = "Silent Aim", default = Settings.PF.SilentAim ~= false, callback = function(e)
                Settings.PF.SilentAim = e
                if e and MD.TracePF and MD.TracePF.reinstallSilent then
                    MD.TracePF.reinstallSilent()
                end
            end })
            left:AddList({ text = "Silent Method", values = {"FireRound","Network","Auto"}, default = Settings.PF.SilentMethod or "FireRound", callback = function(v)
                Settings.PF.SilentMethod = v
                if MD.TracePF and MD.TracePF.reinstallSilent then MD.TracePF.reinstallSilent() end
            end })
            left:AddSlider({ text = "Silent FOV", min = 40, max = 600, default = Settings.PF.SilentFOV or 220, callback = function(v)
                Settings.PF.SilentFOV = v
                Settings.Aimbot.SilentFOVRadius = v
            end })
            left:AddToggle({ text = "Silent FOV Only", default = Settings.PF.SilentFOVOnly ~= false, callback = function(e)
                Settings.PF.SilentFOVOnly = e
            end })
            left:AddToggle({ text = "Show Silent FOV", default = Settings.PF.ShowSilentFOV ~= false, callback = function(e)
                Settings.PF.ShowSilentFOV = e
                Settings.Aimbot.ShowSilentFOV = e
            end })
            left:AddSlider({ text = "Hit Chance", min = 1, max = 100, default = Settings.PF.HitChance or 100, callback = function(v)
                Settings.PF.HitChance = v
            end })
            left:AddSlider({ text = "Head Chance", min = 0, max = 100, default = Settings.PF.HeadChance or 70, callback = function(v)
                Settings.PF.HeadChance = v
            end })
            left:AddToggle({ text = "Predict Velocity", default = Settings.PF.Predict ~= false, callback = function(e)
                Settings.PF.Predict = e
            end })
            local right = tab:AddSection("Extras", 2)
            right:AddToggle({ text = "Soft No Recoil", default = Settings.PF.SoftNoRecoil == true, callback = function(e)
                Settings.PF.SoftNoRecoil = e
            end })
            right:AddToggle({ text = "Soft No Spread", default = Settings.PF.SoftNoSpread == true, callback = function(e)
                Settings.PF.SoftNoSpread = e
            end })
            right:AddToggle({ text = "Anti AFK", default = Settings.PF.AntiAFK ~= false, callback = function(e)
                Settings.PF.AntiAFK = e
            end })
            right:AddToggle({ text = "Team Filter", default = Settings.PF.TeamFilter ~= false, callback = function(e)
                Settings.PF.TeamFilter = e
            end })
            right:AddToggle({ text = "Trigger Bot", default = Settings.Combat.TriggerBot == true, callback = function(e)
                Settings.Combat.TriggerBot = e
            end })
            right:AddButton({ text = "Refresh PF Modules", callback = function()
                if MD.TracePF and MD.TracePF.refreshModules then
                    MD.TracePF.repl = nil
                    MD.TracePF.entries = nil
                    MD.TracePF.pfRequire = nil
                    MD.TracePF.network = nil
                    MD.TracePF.bulletObject = nil
                    MD.TracePF.firearmObject = nil
                    MD.TracePF.characterObject = nil
                    MD.TracePF.cache = {}
                    local ok = MD.TracePF.refreshModules()
                    local st = tostring(MD.TracePF.status or "?")
                    local sil = "?"
                    if MD.TracePF.reinstallSilent then
                        MD.TracePF.reinstallSilent()
                        sil = tostring(MD.TracePF.silentStatus or "?")
                    end
                    TD.Notify(ok and ("PF " .. st .. " / silent " .. sil) or ("PF waiting: " .. st), 2.5)
                end
            end })
            right:AddText({ text = "Spawn first. Hooks fireRound + newbullets" })
            right:AddText({ text = "Ghosts = orange / Phantoms = blue" })
        end

        do
            local tab = win:AddTab("Players")
            local names = {}
            local selected = nil
            local function refreshNames()
                for i = #names, 1, -1 do names[i] = nil end
                for _, plr in ipairs(S.Players:GetPlayers()) do
                    if plr ~= player then
                        table.insert(names, plr.DisplayName ~= plr.Name and (plr.DisplayName .. " @" .. plr.Name) or plr.Name)
                    end
                end
                if #names == 0 then table.insert(names, "(none)") end
                return names
            end
            refreshNames()
            local p1 = tab:AddSection("List", 1)
            p1:AddList({ text = "Target", values = names, default = names[1], callback = function(v)
                selected = v
            end })
            p1:AddButton({ text = "Refresh List", callback = function()
                refreshNames()
                TD.Notify("Players: " .. tostring(#names), 1.2)
            end })
            local function resolveSelected()
                if not selected or selected == "(none)" then return nil end
                local bare = selected:match("@(.+)$") or selected
                for _, plr in ipairs(S.Players:GetPlayers()) do
                    if plr.Name == bare or plr.DisplayName == selected or (plr.DisplayName .. " @" .. plr.Name) == selected then
                        return plr
                    end
                end
                return nil
            end
            local p2 = tab:AddSection("Actions", 2)
            p2:AddButton({ text = "Teleport", callback = function()
                local plr = resolveSelected()
                if not plr or not plr.Character then TD.Notify("Select a player", 1.5); return end
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local me = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and me then me.CFrame = hrp.CFrame * CFrame.new(0, 0, 3); TD.Notify("TP: " .. plr.Name, 1.5) end
            end })
            p2:AddButton({ text = "Spectate", callback = function()
                local plr = resolveSelected()
                if not plr then TD.Notify("Select a player", 1.5); return end
                local cam = S.Workspace.CurrentCamera
                if cam then cam.CameraSubject = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") or plr.Character end
                TD.Notify("Spectating " .. plr.Name, 1.5)
            end })
            p2:AddButton({ text = "Unspectate", callback = function()
                local cam = S.Workspace.CurrentCamera
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if cam and hum then cam.CameraSubject = hum end
            end })
            p2:AddToggle({ text = "Streamer Mode", default = Settings.Misc.StreamerMode, callback = function(e)
                Settings.Misc.StreamerMode = e
                if MD.applyStreamerPrivacy then MD.applyStreamerPrivacy() end
            end })
            p2:AddToggle({ text = "Streamer Mode++", default = Settings.Misc.StreamerModePlus, callback = function(e)
                Settings.Misc.StreamerModePlus = e
                if MD.applyStreamerPrivacy then MD.applyStreamerPrivacy() end
            end })
        end

        if MW.allows("aim") and not MW.allows("phantomforces") and not MW.allows("mm2") then
            local tab = win:AddTab("Aim")
            local a1 = tab:AddSection("Aimbot", 1)
            a1:AddToggle({ text = "Enabled", default = Settings.Aimbot.Enabled, callback = function(e)
                Settings.Aimbot.Enabled = e
                if SilentHB and SilentHB.refresh then SilentHB.refresh() end
                Settings.Aimbot.AimMode = "Camera"
            end })
            a1:AddList({ text = "Aim Mode", values = {"Camera"}, default = "Camera", callback = function(v)
                Settings.Aimbot.AimMode = "Camera"
                if SilentHB and SilentHB.refresh then SilentHB.refresh() end
                TD.Notify(MW.isPF and "Aim: Camera (PF silent is on PF tab)" or "Aim: Camera only (Silent locked)", 1.5)
            end })
            a1:AddText({ text = MW.isPF and "PF silent aim lives on the PF tab." or "Silent Aim is locked off (stability)." })
            a1:AddToggle({ text = "Sticky Aim", default = Settings.Aimbot.StickyAim, callback = function(e) Settings.Aimbot.StickyAim = e end })
            a1:AddToggle({ text = "Toggle Mode (RMB)", default = Settings.Aimbot.Toggle, callback = function(e) Settings.Aimbot.Toggle = e end })
            a1:AddToggle({ text = "Require LOS", default = Settings.Aimbot.RequireLOS, callback = function(e) Settings.Aimbot.RequireLOS = e end })
            a1:AddToggle({ text = "Prediction", default = Settings.Aimbot.Prediction, callback = function(e) Settings.Aimbot.Prediction = e end })
            a1:AddToggle({ text = "Multi-Target", default = Settings.Aimbot.MultiTarget, callback = function(e) Settings.Aimbot.MultiTarget = e end })
            a1:AddToggle({ text = "Show FOV", default = Settings.Aimbot.ShowFOV, callback = function(e) Settings.Aimbot.ShowFOV = e end })
            a1:AddList({ text = "FOV Style", values = {"Circle","Dots"}, default = Settings.Aimbot.FOVStyle or "Circle", callback = function(v)
                Settings.Aimbot.FOVStyle = v
            end })
            a1:AddSlider({ text = "Smoothness", min = 1, max = 100, default = math.floor((Settings.Aimbot.Smoothness or 0.2) * 100), callback = function(v)
                Settings.Aimbot.Smoothness = v / 100
            end })
            a1:AddSlider({ text = "FOV Radius", min = 50, max = 500, default = Settings.Aimbot.FOVRadius or 120, callback = function(v)
                Settings.Aimbot.FOVRadius = v
            end })
            a1:AddSlider({ text = "FOV Opacity", min = 10, max = 100, default = math.floor((Settings.Aimbot.FOVOpacity or 0.5) * 100), callback = function(v)
                Settings.Aimbot.FOVOpacity = v / 100
            end })
            a1:AddSlider({ text = "FOV Dots", min = 4, max = 32, default = Settings.Aimbot.FOVDots or 12, callback = function(v)
                Settings.Aimbot.FOVDots = v
            end })
            a1:AddSlider({ text = "Max Distance", min = 100, max = 1000, default = Settings.Aimbot.MaxDistance or 500, callback = function(v)
                Settings.Aimbot.MaxDistance = v
            end })
            a1:AddList({ text = "Priority", values = {"Closest","LowestHP","Crosshair","Threat"}, default = Settings.Aimbot.TargetPriority or "Crosshair", callback = function(v)
                Settings.Aimbot.TargetPriority = v
            end })
            a1:AddList({ text = "Lock Part", values = {"Head","HumanoidRootPart","UpperTorso","Torso"}, default = Settings.Aimbot.LockPart or "Head", callback = function(v)
                Settings.Aimbot.LockPart = v
            end })
            local a2 = tab:AddSection("Combat / Guns", 2)
            a2:AddToggle({ text = "Trigger Bot", default = Settings.Combat.TriggerBot, callback = function(e)
                Settings.Combat.TriggerBot = e
            end })
            a2:AddSlider({ text = "Trigger Delay ms", min = 50, max = 500, default = math.floor((Settings.Combat.TriggerDelay or 0.05) * 1000), callback = function(v)
                Settings.Combat.TriggerDelay = v / 1000
            end })
            a2:AddToggle({ text = "Trigger Head Only", default = Settings.Combat.TriggerHeadOnly, callback = function(e)
                Settings.Combat.TriggerHeadOnly = e
            end })
            a2:AddToggle({ text = "Trigger Require LOS", default = Settings.Combat.TriggerRequireLOS, callback = function(e)
                Settings.Combat.TriggerRequireLOS = e
            end })
            a2:AddToggle({ text = "Trigger ADS Only", default = Settings.Combat.TriggerRequireADS, callback = function(e)
                Settings.Combat.TriggerRequireADS = e
            end })
            if MW.allows("rage") then
            a2:AddToggle({ text = "Rage Bot", default = Settings.Combat.RageBot, callback = function(e)
                Settings.Combat.RageBot = e
                if e then if MD.stopAutoTPLoop then MD.stopAutoTPLoop() end; if MD.startRageBot then MD.startRageBot() end
                else if MD.stopRageBot then MD.stopRageBot() end end
            end })
            a2:AddSlider({ text = "Rage Delay ms", min = 50, max = 500, default = math.floor((Settings.Combat.RageDelay or 0.12) * 1000), callback = function(v)
                Settings.Combat.RageDelay = v / 1000
            end })
            a2:AddToggle({ text = "Rage Auto Shoot", default = Settings.Combat.RageShoot ~= false, callback = function(e)
                Settings.Combat.RageShoot = e
            end })
            end
            if MW.allows("gunmods") then
                a2:AddSeparator({ text = "Gun Mods" })
                if MW.gunModsInTesting then
                    a2:AddText({ text = "IN TESTING", accent = true })
                    a2:AddText({ text = "ACS gun mods not wired yet on this game." })
                else
                a2:AddToggle({ text = "Fast Reload", default = Settings.Combat.FastReload, callback = function(e)
                    Settings.Combat.FastReload = e; if MD.applyAllGunMods then MD.applyAllGunMods() end
                end })
                a2:AddToggle({ text = "Fast Fire Rate", default = Settings.Combat.FastFireRate, callback = function(e)
                    Settings.Combat.FastFireRate = e; if MD.applyAllGunMods then MD.applyAllGunMods() end
                end })
                a2:AddToggle({ text = "Always Auto", default = Settings.Combat.AlwaysAuto, callback = function(e)
                    Settings.Combat.AlwaysAuto = e; if MD.applyAllGunMods then MD.applyAllGunMods() end
                end })
                a2:AddToggle({ text = "No Spread", default = Settings.Combat.NoSpread, callback = function(e)
                    Settings.Combat.NoSpread = e; if MD.applyAllGunMods then MD.applyAllGunMods() end
                end })
                a2:AddToggle({ text = "No Recoil", default = Settings.Combat.NoRecoil, callback = function(e)
                    Settings.Combat.NoRecoil = e; if MD.applyAllGunMods then MD.applyAllGunMods() end
                end })
                a2:AddToggle({ text = "Infinite Ammo", default = Settings.Combat.InfiniteAmmo, callback = function(e)
                    Settings.Combat.InfiniteAmmo = e
                    if e then if MD.applyInfiniteAmmo then MD.applyInfiniteAmmo() end else if MD.stopInfiniteAmmo then MD.stopInfiniteAmmo() end end
                end })
                a2:AddList({ text = "Gun Profile", values = {"Custom","LegitLite","SemiComp","RagePack","Arena","Scout","SlotA","SlotB"}, default = Settings.Combat.GunProfile or "Custom", callback = function(v)
                    if MD.applyGunProfile then MD.applyGunProfile(v) end
                end })
                a2:AddButton({ text = "Capture Slot A", callback = function()
                    if MD.captureGunSlotA then MD.captureGunSlotA(); TD.Notify("Slot A saved", 1.2) end
                end })
                a2:AddButton({ text = "Capture Slot B", callback = function()
                    if MD.captureGunSlotB then MD.captureGunSlotB(); TD.Notify("Slot B saved", 1.2) end
                end })
                end
            end
        end

        do
            local tab = win:AddTab("ESP")
            local bump = function()
                VisPerf.lastOverlay = 0
                VisPerf.lastHeavy = 0
                VisPerf.lastMisc = 0
            end
            local e1 = tab:AddSection("Players", 1)
            e1:AddToggle({ text = "ESP Enabled", default = Settings.ESP.Enabled, callback = function(e)
                Settings.ESP.Enabled = e; bump()
            end })
            e1:AddList({ text = "Change Box Style", values = {"Off","2D","3D","Both","Corner"}, default = Settings.ESP.BoxStyle or "2D", callback = function(v)
                Settings.ESP.BoxStyle = v
                Settings.ESP.BoxEnabled = (v ~= "Off")
                bump()
            end })
            local function getEspCol(key, fallback)
                local h = normalizeHex(Settings.ESP and Settings.ESP[key])
                if h then return hexToColor3(h) end
                if typeof(fallback) == "Color3" then return fallback end
                return Color3.fromRGB(255, 255, 255)
            end
            local function setEspCol(key, c3)
                Settings.ESP = Settings.ESP or {}
                Settings.ESP[key] = color3ToHex(c3)
                Settings.ESP.LinkToAccent = false
                if applyEspPalette then applyEspPalette() end
                if applyCustomTheme then applyCustomTheme() end
                bump()
            end
            e1:AddColor({ text = "Box Color", getColor = function()
                return getEspCol("BoxHex", Theme.ESP_Box or Theme.ESP_Close)
            end, setColor = function(c) setEspCol("BoxHex", c) end })
            e1:AddToggle({ text = "Names", default = Settings.ESP.NameEnabled, callback = function(e)
                Settings.ESP.NameEnabled = e; bump()
            end, getColor = function()
                return getEspCol("NameHex", Theme.ESP_Name or Theme.ESP_Close)
            end, setColor = function(c) setEspCol("NameHex", c) end })
            e1:AddToggle({ text = "Health Bar", default = Settings.ESP.HealthBar, callback = function(e)
                Settings.ESP.HealthBar = e; bump()
            end })
            e1:AddToggle({ text = "Health Text", default = Settings.ESP.HealthEnabled, callback = function(e)
                Settings.ESP.HealthEnabled = e; bump()
            end })
            e1:AddToggle({ text = "Distance", default = Settings.ESP.DistanceEnabled, callback = function(e)
                Settings.ESP.DistanceEnabled = e; bump()
            end })
            e1:AddToggle({ text = "Tracers", default = Settings.ESP.TracerEnabled, callback = function(e)
                Settings.ESP.TracerEnabled = e; bump()
            end, getColor = function()
                return getEspCol("TracerHex", Theme.ESP_Tracer or Theme.ESP_Close)
            end, setColor = function(c) setEspCol("TracerHex", c) end })
            e1:AddList({ text = "Change Tracer Origin", values = {"Top","Mouse","Center","Bottom"}, default = Settings.ESP.TracerOrigin or "Bottom", callback = function(v)
                Settings.ESP.TracerOrigin = v; bump()
            end })
            e1:AddToggle({ text = "Skeleton", default = Settings.ESP.SkeletonEnabled, callback = function(e)
                Settings.ESP.SkeletonEnabled = e; bump()
            end, getColor = function()
                return getEspCol("SkeletonHex", Theme.ESP_Skeleton or Theme.ESP_Close)
            end, setColor = function(c) setEspCol("SkeletonHex", c) end })
            e1:AddToggle({ text = "Head Dot", default = Settings.ESP.HeadDotEnabled, callback = function(e)
                Settings.ESP.HeadDotEnabled = e; bump()
            end })
            e1:AddToggle({ text = "Weapon Labels", default = Settings.ESP.WeaponLabels, callback = function(e)
                Settings.ESP.WeaponLabels = e; bump()
            end })
            e1:AddToggle({ text = "Visible Check", default = Settings.ESP.VisibleCheck, callback = function(e)
                Settings.ESP.VisibleCheck = e; bump()
            end })
            local e2 = tab:AddSection("Style / Packs", 2)
            e2:AddToggle({ text = "Link ESP to Accent", default = Settings.ESP.LinkToAccent ~= false, callback = function(e)
                Settings.ESP.LinkToAccent = e
                if applyEspPalette then applyEspPalette() end
                if applyCustomTheme then applyCustomTheme() end
                bump()
            end })
            e2:AddText({ text = "Click white/color box to pick" })
            e2:AddToggle({ text = "Chams", default = Settings.ESP.ChamsEnabled, callback = function(e)
                Settings.ESP.ChamsEnabled = e; bump()
            end, getColor = function()
                return getEspCol("ChamsHex", Theme.ESP_Chams or Theme.ESP_Close)
            end, setColor = function(c) setEspCol("ChamsHex", c) end })
            e2:AddToggle({ text = "Glow", default = Settings.ESP.GlowEnabled, callback = function(e)
                Settings.ESP.GlowEnabled = e; bump()
            end })
            e2:AddToggle({ text = "Box Fill", default = Settings.ESP.BoxFill, callback = function(e)
                Settings.ESP.BoxFill = e; bump()
            end })
            e2:AddToggle({ text = "Offscreen Arrows", default = Settings.ESP.OffscreenArrows, callback = function(e)
                Settings.ESP.OffscreenArrows = e; bump()
            end })
            e2:AddToggle({ text = "Outline", default = Settings.ESP.OutlineEnabled, callback = function(e)
                Settings.ESP.OutlineEnabled = e; bump()
            end, getColor = function()
                return getEspCol("OutlineHex", Theme.ESP_Outline or Color3.fromRGB(210, 210, 220))
            end, setColor = function(c) setEspCol("OutlineHex", c) end })
            e2:AddColor({ text = "ESP Close", getColor = function()
                return getEspCol("CloseHex", Theme.ESP_Close)
            end, setColor = function(c) setEspCol("CloseHex", c) end })
            e2:AddColor({ text = "ESP Medium", getColor = function()
                return getEspCol("MediumHex", Theme.ESP_Medium)
            end, setColor = function(c) setEspCol("MediumHex", c) end })
            e2:AddColor({ text = "ESP Far", getColor = function()
                return getEspCol("FarHex", Theme.ESP_Far)
            end, setColor = function(c) setEspCol("FarHex", c) end })
            e2:AddSlider({ text = "Max Distance", min = 100, max = 8000, default = Settings.ESP.RenderDistance or 2000, callback = function(v)
                Settings.ESP.RenderDistance = v; Settings.ESP.MaxDistance = v; bump()
            end })
            e2:AddList({ text = "Filter", values = {"Enemies","Team","All"}, default = Settings.ESP.FilterMode or "Enemies", callback = function(v)
                Settings.ESP.FilterMode = v; bump()
            end })
            e2:AddButton({ text = "Pack: Full", callback = function()
                if MD.TracePack then MD.TracePack.applyESPStyle("Full") end; bump(); TD.Notify("ESP Full", 1.2)
            end })
            e2:AddButton({ text = "Pack: Minimal", callback = function()
                if MD.TracePack then MD.TracePack.applyESPStyle("Minimal") end; bump(); TD.Notify("ESP Minimal", 1.2)
            end })
            e2:AddButton({ text = "Pack: Arena", callback = function()
                if MD.TracePack then MD.TracePack.applyESPStyle("Arena") end; bump(); TD.Notify("ESP Arena", 1.2)
            end })
            if Settings.Radar and not RADAR_TEMP_DISABLED then
                e2:AddToggle({ text = "Radar", default = Settings.Radar.Enabled, callback = function(e) Settings.Radar.Enabled = e end })
            end
        end

        do
            local tab = win:AddTab("World")
            local m1 = tab:AddSection("Movement", 1)
            if MW.allows("speedHack") ~= false then
                m1:AddToggle({ text = "Speed Boost", default = Settings.Movement.SpeedEnabled, callback = function(e)
                    Settings.Movement.SpeedEnabled = e
                end })
                m1:AddSlider({ text = "Speed", min = 1, max = 300, default = Settings.Movement.Speed or 16, callback = function(v)
                    Settings.Movement.Speed = v
                end })
                m1:AddList({ text = "Speed Method", values = {"WalkSpeed","CFrame","Velocity"}, default = Settings.Movement.SpeedMethod or "WalkSpeed", callback = function(v)
                    Settings.Movement.SpeedMethod = v
                end })
            end
            if not MW.guard("pos") then
                m1:AddToggle({ text = "High Jump", default = Settings.Movement.JumpEnabled, callback = function(e)
                    Settings.Movement.JumpEnabled = e
                    local c = player.Character
                    if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower = e and (Settings.Movement.JumpPower or 50) or 50 end end
                end })
                m1:AddSlider({ text = "Jump Power", min = 50, max = 300, default = Settings.Movement.JumpPower or 50, callback = function(v)
                    Settings.Movement.JumpPower = v
                end })
                m1:AddToggle({ text = "Bunny Hop", default = Settings.Movement.BunnyHop, callback = function(e) Settings.Movement.BunnyHop = e end })
                m1:AddSlider({ text = "Bhop Speed", min = 1, max = 100, default = Settings.Movement.BunnyHopSpeed or 40, callback = function(v)
                    Settings.Movement.BunnyHopSpeed = v
                end })
            end
            if MW.allows("fly") ~= false then
                m1:AddToggle({ text = "Fly", default = Settings.Movement.Fly, callback = function(e)
                    Settings.Movement.Fly = e
                    if e then if MD.startFly then MD.startFly() end else if MD.stopFly then MD.stopFly() end end
                end })
                m1:AddList({ text = "Fly Method", values = {"CFrame","Velocity","BodyMovers"}, default = Settings.Movement.FlyMethod or "CFrame", callback = function(v)
                    Settings.Movement.FlyMethod = v
                    if Settings.Movement.Fly then if MD.stopFly then MD.stopFly() end; if MD.startFly then MD.startFly() end end
                end })
                m1:AddSlider({ text = "Fly Speed", min = 10, max = 200, default = Settings.Movement.FlySpeed or 50, callback = function(v)
                    Settings.Movement.FlySpeed = v
                end })
            end
            m1:AddToggle({ text = "Noclip", default = Settings.Movement.Noclip, callback = function(e)
                if MD.setNoclip then MD.setNoclip(e) end
            end })
            if MW.guard("pos") then
                m1:AddText({ text = "Click TP / Auto TP locked (pos AC)." })
            else
                m1:AddToggle({ text = "Infinite Jump", default = Settings.Movement.InfiniteJump, callback = function(e)
                    if MD.setInfiniteJump then MD.setInfiniteJump(e) end
                end })
                m1:AddToggle({ text = "Click TP", default = Settings.Movement.ClickTP, callback = function(e)
                    if MD.setClickTP then MD.setClickTP(e) end
                end })
                if MW.allows("autoTp") then
                    m1:AddToggle({ text = "Auto TP Loop", default = Settings.Misc.AutoTPLoop, callback = function(e)
                        Settings.Misc.AutoTPLoop = e
                        if e then if MD.startAutoTPLoop then MD.startAutoTPLoop() end else if MD.stopAutoTPLoop then MD.stopAutoTPLoop() end end
                    end })
                end
            end
            local m2 = tab:AddSection("Visuals / Misc", 2)
            m2:AddToggle({ text = "Crosshair", default = Settings.Crosshair.Enabled, callback = function(e)
                Settings.Crosshair.Enabled = e
            end })
            m2:AddList({ text = "Crosshair Style", values = {"Cross","Dot","Circle","X-Shape","Sniper","KV"}, default = Settings.Crosshair.Style or "Cross", callback = function(v)
                Settings.Crosshair.Style = v
            end })
            m2:AddToggle({ text = "Fullbright", default = Settings.Visuals.Fullbright, callback = function(e)
                Settings.Visuals.Fullbright = e
                if e then S.Lighting.Ambient = Color3.fromRGB(255,255,255); S.Lighting.Brightness = 2 end
                if MD.applyWorldLighting then MD.applyWorldLighting() end
            end })
            m2:AddToggle({ text = "No Fog", default = Settings.Visuals.NoFog, callback = function(e)
                Settings.Visuals.NoFog = e
                if e then if MD.enableNoFog then MD.enableNoFog() end else if MD.disableNoFog then MD.disableNoFog() end end
            end })
            m2:AddToggle({ text = "Custom FOV", default = Settings.Visuals.CustomFOV, callback = function(e)
                Settings.Visuals.CustomFOV = e
            end })
            m2:AddSlider({ text = "FOV", min = 30, max = 120, default = Settings.Visuals.FOVAmount or 70, callback = function(v)
                Settings.Visuals.FOVAmount = v
                if Settings.Visuals.CustomFOV and S.Workspace.CurrentCamera then
                    S.Workspace.CurrentCamera.FieldOfView = v
                end
            end })
            m2:AddToggle({ text = "Third Person", default = Settings.Visuals.ThirdPerson, callback = function(e)
                Settings.Visuals.ThirdPerson = e
            end })
            m2:AddSlider({ text = "TP Distance", min = 4, max = 20, default = Settings.Visuals.ThirdPersonDistance or 10, callback = function(v)
                Settings.Visuals.ThirdPersonDistance = v
            end })
            if MW.isArsenal then
                m2:AddToggle({ text = "Viewmodel FOV", default = Settings.Visuals.ViewmodelFOVEnabled, callback = function(e)
                    Settings.Visuals.ViewmodelFOVEnabled = e
                end })
                m2:AddToggle({ text = "Gun Wireframe", default = Settings.Visuals.GunWireframeEnabled, callback = function(e)
                    Settings.Visuals.GunWireframeEnabled = e
                    if e then if MD.updateGunWireframe then MD.updateGunWireframe() end else if MD.clearGunWireframe then MD.clearGunWireframe() end end
                end })
            end
            m2:AddToggle({ text = "Anti-AFK", default = Settings.Misc.AntiAFK, callback = function(e) Settings.Misc.AntiAFK = e end })
            m2:AddToggle({ text = "Auto Rejoin", default = Settings.Misc.AutoRejoin, callback = function(e) Settings.Misc.AutoRejoin = e end })
            m2:AddToggle({ text = "Streamer Mode", default = Settings.Misc.StreamerMode, callback = function(e)
                Settings.Misc.StreamerMode = e
                if MD.applyStreamerPrivacy then MD.applyStreamerPrivacy() end
            end })
            m2:AddButton({ text = "Server Hop", callback = function() if MD.FX and MD.FX.doServerHop then MD.FX.doServerHop() end end })
            m2:AddButton({ text = "Rejoin", callback = function()
                pcall(function() S.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end)
            end })
            if MW.allows("universalWorld") then
                local u = tab:AddSection("Universal", 1)
                u:AddToggle({ text = "Auto Obby", default = Settings.Misc.AutoObby, callback = function(e)
                    if e then if MD.startAutoObby then MD.startAutoObby() end else if MD.stopAutoObby then MD.stopAutoObby() end end
                end })
                u:AddButton({ text = "TP to Spawn", callback = function() if MD.tpToSpawn then MD.tpToSpawn() end end })
                u:AddButton({ text = "TP Next Checkpoint", callback = function() if MD.tpNextCheckpoint then MD.tpNextCheckpoint() end end })
            end
            if MW.allows("brookhaven") then
                local b = tab:AddSection("Brookhaven RP", 2)
                local locs = (MD and MD.BH_LOCATIONS) or {"Hospital","School","Mall","Airport","Bank","Police","Motel"}
                local sel = locs[1]
                b:AddList({ text = "Location", values = locs, default = sel, callback = function(v) sel = v end })
                b:AddButton({ text = "TP Location", callback = function()
                    if MD.tpBrookhavenLocation then MD.tpBrookhavenLocation(sel) end
                end })
                b:AddToggle({ text = "Vehicle Speed", default = Settings.Movement.VehicleSpeed, callback = function(e)
                    if MD.setVehicleSpeed then MD.setVehicleSpeed(e) end
                end })
                b:AddToggle({ text = "Local Invis", default = Settings.Movement.LocalInvis, callback = function(e)
                    if MD.applyLocalInvis then MD.applyLocalInvis(e) end
                end })
            end
        end

        do
            local tab = win:AddTab("Audio")
            local a = tab:AddSection("Hit / Kill", 1)
            a:AddToggle({ text = "Hit Sounds", default = Settings.Audio.HitSoundsEnabled, callback = function(e)
                Settings.Audio.HitSoundsEnabled = e
            end })
            a:AddSlider({ text = "Hit Volume", min = 0, max = 100, default = math.floor((Settings.Audio.HitVolume or 0.55) * 100), callback = function(v)
                Settings.Audio.HitVolume = v / 100
            end })
            a:AddSlider({ text = "Hit Pitch", min = 50, max = 200, default = math.floor((Settings.Audio.HitPitch or 1) * 100), callback = function(v)
                Settings.Audio.HitPitch = v / 100
            end })
            a:AddInput({ text = "Hit Sound ID", default = Settings.Audio.HitSoundId or "", placeholder = "audio id", callback = function(v)
                Settings.Audio.HitSoundId = v
            end })
            a:AddButton({ text = "Test Hit", callback = function()
                if _G[MW_T.audioApi] then _G[MW_T.audioApi].playHitSound() end
            end })
            a:AddToggle({ text = "Kill Sounds", default = Settings.Audio.KillSoundsEnabled, callback = function(e)
                Settings.Audio.KillSoundsEnabled = e
            end })
            a:AddSlider({ text = "Kill Volume", min = 0, max = 100, default = math.floor((Settings.Audio.KillVolume or 0.65) * 100), callback = function(v)
                Settings.Audio.KillVolume = v / 100
            end })
            a:AddSlider({ text = "Kill Pitch", min = 50, max = 200, default = math.floor((Settings.Audio.KillPitch or 1) * 100), callback = function(v)
                Settings.Audio.KillPitch = v / 100
            end })
            a:AddInput({ text = "Kill Sound ID", default = Settings.Audio.KillSoundId or "", placeholder = "audio id", callback = function(v)
                Settings.Audio.KillSoundId = v
            end })
            a:AddButton({ text = "Test Kill", callback = function()
                if _G[MW_T.audioApi] then _G[MW_T.audioApi].playKillSound() end
            end })
            local m = tab:AddSection("Boombox", 2)
            local function refreshMusic()
                if _G[MW_T.audioApi] then pcall(function() _G[MW_T.audioApi].refreshMusicPlayback() end) end
            end
            m:AddToggle({ text = "Play Music", default = Settings.Audio.MusicEnabled, callback = function(e)
                Settings.Audio.MusicEnabled = e
                refreshMusic()
            end })
            m:AddToggle({ text = "Boombox", default = Settings.Audio.Boombox ~= false, callback = function(e)
                Settings.Audio.Boombox = e
                refreshMusic()
            end })
            m:AddToggle({ text = "Loop", default = Settings.Audio.MusicLoop ~= false, callback = function(e)
                Settings.Audio.MusicLoop = e
                refreshMusic()
            end })
            m:AddInput({ text = "Music ID", default = Settings.Audio.MusicId or "", placeholder = "roblox audio id", callback = function(v)
                Settings.Audio.MusicId = v
                refreshMusic()
            end })
            m:AddSlider({ text = "Volume", min = 0, max = 100, default = math.floor((Settings.Audio.MusicVolume or 0.35) * 100), callback = function(v)
                Settings.Audio.MusicVolume = v / 100
                refreshMusic()
            end })
            m:AddSlider({ text = "Pitch", min = 50, max = 200, default = math.floor((Settings.Audio.MusicPitch or 1) * 100), callback = function(v)
                Settings.Audio.MusicPitch = v / 100
                refreshMusic()
            end })
            m:AddSlider({ text = "Speed", min = 50, max = 200, default = math.floor((Settings.Audio.MusicSpeed or 1) * 100), callback = function(v)
                Settings.Audio.MusicSpeed = v / 100
                refreshMusic()
            end })
            m:AddSlider({ text = "Hear Distance", min = 20, max = 300, default = Settings.Audio.MusicDistance or 90, callback = function(v)
                Settings.Audio.MusicDistance = v
                refreshMusic()
            end })
            m:AddSlider({ text = "Bass", min = 0, max = 10, default = Settings.Audio.MusicBass or 0, callback = function(v)
                Settings.Audio.MusicBass = v
                refreshMusic()
            end })
            m:AddSlider({ text = "Treble", min = 0, max = 10, default = Settings.Audio.MusicTreble or 0, callback = function(v)
                Settings.Audio.MusicTreble = v
                refreshMusic()
            end })
            m:AddText({ text = "Boombox plays in 3D from your character, with distance falloff." })
        end

        do
            local tab = win:AddTab("Binds")
            local b1 = tab:AddSection("Menu", 1)
            b1:AddKeybind({ text = "Toggle GUI", default = Settings.Keybinds.ToggleGUI, callback = function(k)
                Settings.Keybinds.ToggleGUI = k
            end })
            b1:AddKeybind({ text = "Panic", default = Settings.Keybinds.PanicKey, callback = function(k)
                Settings.Keybinds.PanicKey = k
            end })
            b1:AddToggle({ text = "Show Bind List", default = Settings.HUD.KeybindList == true, callback = function(e)
                Settings.HUD.KeybindList = e
            end })
            local b2 = tab:AddSection("Actions", 2)
            if MW.allows("aim") then
                b2:AddKeybind({ text = "Cycle Target", default = Settings.Keybinds.CycleTarget, callback = function(k)
                    Settings.Keybinds.CycleTarget = k
                end })
                b2:AddKeybind({ text = "Trigger Bot", default = Settings.Keybinds.ToggleTriggerBot, callback = function(k)
                    Settings.Keybinds.ToggleTriggerBot = k
                end })
                if MW.allows("rage") then
                    b2:AddKeybind({ text = "Rage Bot", default = Settings.Keybinds.ToggleRageBot, callback = function(k)
                        Settings.Keybinds.ToggleRageBot = k
                    end })
                end
            end
            b2:AddKeybind({ text = "Fly", default = Settings.Keybinds.ToggleFly, callback = function(k)
                Settings.Keybinds.ToggleFly = k
            end })
            b2:AddKeybind({ text = "Noclip", default = Settings.Keybinds.ToggleNoclip or Enum.KeyCode.V, callback = function(k)
                Settings.Keybinds.ToggleNoclip = k
            end })
            b2:AddKeybind({ text = "Click TP Hold", default = Settings.Keybinds.ClickTP or Enum.KeyCode.LeftAlt, callback = function(k)
                Settings.Keybinds.ClickTP = k
            end })
            if MW.allows("autoTp") then
                b2:AddKeybind({ text = "Auto TP", default = Settings.Keybinds.ToggleAutoTP, callback = function(k)
                    Settings.Keybinds.ToggleAutoTP = k
                end })
            end
            if MW.allows("obby") then
                b2:AddKeybind({ text = "Auto Obby", default = Settings.Keybinds.ToggleAutoObby or Enum.KeyCode.Unknown, callback = function(k)
                    Settings.Keybinds.ToggleAutoObby = k
                end })
            end
            b2:AddText({ text = "Click a bind, then press a key. Esc = None." })
        end

        do
            local tab = win:AddTab("Config")
            local typedName = readAutoloadName()
            if typedName == "" then typedName = "My Config" end
            local nameBox
            local autoOn = readAutoloadName() ~= ""
            local saved = {"Legit", "Semi", "Rage", "Visuals", "Movement"}
            local seen = { Legit = true, Semi = true, Rage = true, Visuals = true, Movement = true }
            pcall(function()
                for _, n in ipairs(listProfiles()) do
                    if n and n ~= "Default" and not seen[n] then
                        seen[n] = true
                        table.insert(saved, n)
                    end
                end
            end)
            local function currentName()
                if nameBox and nameBox.Text then
                    local n = cleanCfgName(nameBox.Text)
                    if n ~= "" then typedName = n end
                end
                return cleanCfgName(typedName)
            end
            local c1 = tab:AddSection("Configs", 1)
            c1:AddInput({
                text = "Name",
                default = typedName,
                placeholder = "config name",
                onBox = function(b) nameBox = b end,
                callback = function(v)
                    typedName = cleanCfgName(v)
                    if autoOn and typedName ~= "" then writeAutoloadName(typedName) end
                end,
            })
            c1:AddList({
                text = "Saved",
                values = saved,
                default = saved[1],
                callback = function(v)
                    typedName = v
                    if nameBox then nameBox.Text = v end
                    if autoOn then writeAutoloadName(v) end
                end,
            })
            c1:AddButton({ text = "Load", callback = function()
                local name = currentName()
                if name == "" then TD.Notify("Type a name", 1.5) return end
                local ok, err = applyNamedConfig(name)
                TD.Notify(ok and ("Loaded " .. name) or (err == "missing" and "No config named " .. name or "Load failed"), 2)
                if ok and _G[MW_T.audioApi] then pcall(function() _G[MW_T.audioApi].refreshMusicPlayback() end) end
            end })
            c1:AddButton({ text = "Save", callback = function()
                local name = currentName()
                if name == "" then TD.Notify("Type a name", 1.5) return end
                local ok, err = saveProfile(name)
                TD.Notify(ok and ("Saved " .. name) or tostring(err or "Save failed"), 2)
                if ok and autoOn then writeAutoloadName(name) end
            end })
            c1:AddButton({ text = "Delete", callback = function()
                local name = currentName()
                if name == "" then return end
                deleteProfile(name)
                if readAutoloadName() == name then writeAutoloadName("") end
                TD.Notify("Deleted " .. name, 1.5)
            end })
            c1:AddToggle({
                text = "Auto Load",
                default = autoOn,
                callback = function(e)
                    autoOn = e and true or false
                    if autoOn then
                        local name = currentName()
                        if name == "" then
                            autoOn = false
                            TD.Notify("Type a name first", 2)
                            return
                        end
                        writeAutoloadName(name)
                        TD.Notify("Auto load " .. name, 2)
                    else
                        writeAutoloadName("")
                        TD.Notify("Auto load off", 1.5)
                    end
                end,
            })
            c1:AddText({ text = "Type any name, then Save. Auto Load brings that config back next time you execute." })
            c1:AddButton({ text = "Unload", callback = function()
                if _G[MW_T.cleanup] then pcall(_G[MW_T.cleanup]) end
            end })
            local c2 = tab:AddSection("Theme", 2)
            local presets = (MD.listThemePresets and MD.listThemePresets()) or {"Purple","Informant","Ice","Graphite","BloodAmber","Mint","Steel","Crimson"}
            c2:AddList({ text = "Preset", values = presets, default = (Settings.UI and Settings.UI.ThemePreset) or "Purple", callback = function(v)
                if MD.applyThemePreset then MD.applyThemePreset(v) end
                TD.syncFromSettings()
                TD.Notify("Theme: " .. tostring(v), 1.5)
            end })
            local function getUiCol(key, fb)
                local h = normalizeHex(Settings.UI and Settings.UI[key])
                if h then return hexToColor3(h) end
                return fb or Color3.fromRGB(103, 89, 179)
            end
            local function setUiCol(key, c3)
                ensureUISettings()
                Settings.UI[key] = color3ToHex(c3)
                Settings.UI.ThemePreset = "Custom"
                if applyCustomTheme then applyCustomTheme() end
                TD.syncFromSettings()
            end
            c2:AddColor({ text = "Accent", getColor = function() return getUiCol("AccentHex", TD.theme.Accent) end, setColor = function(c) setUiCol("AccentHex", c) end })
            c2:AddColor({ text = "Background", getColor = function() return getUiCol("BackgroundHex", TD.theme.Background) end, setColor = function(c) setUiCol("BackgroundHex", c) end })
            c2:AddColor({ text = "Surface", getColor = function() return getUiCol("SurfaceHex", TD.theme.SectionBg) end, setColor = function(c) setUiCol("SurfaceHex", c) end })
            c2:AddColor({ text = "Toggle", getColor = function() return getUiCol("ToggleHex", TD.theme.Accent) end, setColor = function(c) setUiCol("ToggleHex", c) end })
            c2:AddText({ text = "Click the color box to open picker" })
            c2:AddButton({ text = "Server Hop", callback = function() if MD.FX and MD.FX.doServerHop then MD.FX.doServerHop() end end })
            c2:AddButton({ text = "Rejoin", callback = function()
                pcall(function() S.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end)
            end })
        end
        TD.syncFromSettings()
        table.insert(themeCallbacks, function()
            pcall(TD.syncFromSettings)
        end)
        win:layoutTabs()
        win:layoutSections()
        win:SetVisible(true)
        TD.mountCmdBar(MD)
        TD.Notify("Melo 🍃 ready", 2)
        return win
    end
    return TD
end)()
UILib.TraceDraw = TraceDraw
function UILib.buildMenuWindow(screenGui, windowLayer)
    local MD = UILib.MD
    local WIN_W, WIN_H   = 780, 560
    local RAIL_W         = 58
    local TOP_BAR_H      = 46
    local MAIN_TAB_H     = 0
    local SUB_TAB_H      = 0
    local SUB_TAB_GAP    = 0
    local FOOTER_H       = 22
    local CONTENT_PAD    = 10
    local CONTENT_W      = WIN_W - RAIL_W - CONTENT_PAD * 2
    local SINGLE_COLUMN  = false
    local CARD_W         = math.floor((CONTENT_W - CONTENT_PAD * 3) / 2)
    local ROW_H          = 26
    local CARD_HEADER_H  = 24
    local CONTENT_TOP    = TOP_BAR_H + 8
    local CONTENT_H      = WIN_H - CONTENT_TOP - FOOTER_H - 6

    local Z = {
        bg = 1,
        content = 10,
        page = 11,
        card = 12,
        cardUi = 13,
        footer = 20,
        rail = 30,
        railItem = 31,
        railIcon = 32,
        top = 40,
        topUi = 41,
        accent = 42,
    }
    local mainFrame = UILib.newFrame(windowLayer,{
        Name=MW_T.mainFrame,Size=UDim2.new(0,WIN_W,0,WIN_H),
        Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2),
        BackgroundColor3=Theme.WindowBg,BorderSizePixel=0,Active=true,Visible=true,
        BackgroundTransparency=1,ZIndex=Z.bg,ClipsDescendants=true
    })
    UILib.corner(mainFrame,14)
    guiMainFrame = mainFrame
    local mainGlow = UILib.stroke(mainFrame, Theme.WindowBorder, 1, 0.25)
    table.insert(MD.themeCallbacks, function() mainGlow.Color = Theme.WindowBorder end)
    UILib.shadow(mainFrame, 36, 0.72)
    local menuScale = Instance.new("UIScale")
    menuScale.Name = "TraceMenuScale"
    menuScale.Scale = tonumber(Settings.UI and Settings.UI.MenuScale) or 1
    menuScale.Parent = mainFrame
    table.insert(MD.themeCallbacks, function()
        menuScale.Scale = tonumber(Settings.UI and Settings.UI.MenuScale) or 1
    end)
    local menuBlur = nil
    pcall(function()
        if Settings.UI and Settings.UI.BlurMenu ~= false then
            menuBlur = Instance.new("BlurEffect")
            menuBlur.Name = MW_T.menuBlur
            menuBlur.Size = 0
            menuBlur.Parent = S.Lighting
            table.insert(MD.themeCallbacks, function() end)
        end
    end)
    local function setMenuBlur(on)
        if not menuBlur then return end
        UILib.tween(menuBlur, 0.22, {Size = on and 12 or 0}):Play()
    end
    local mainBg = UILib.newFrame(mainFrame, {
        Name = MW_T.mainBg,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.WindowBg,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = Z.bg,
    })
    UILib.corner(mainBg, 14)
    table.insert(MD.themeCallbacks, function()
        mainBg.BackgroundColor3 = Theme.WindowBg
    end)
    local topAccent = UILib.newFrame(mainFrame,{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,0),BackgroundColor3=Theme.TextAccent,BackgroundTransparency=0.35,BorderSizePixel=0,ZIndex=Z.accent})
    table.insert(MD.themeCallbacks,function()
        topAccent.BackgroundColor3 = Theme.TextAccent
    end)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Position = UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2+16)
    task.spawn(function()
        task.wait(0.05)
        UILib.tween(mainFrame, 0.35, {BackgroundTransparency = 0, Position = UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)}, Enum.EasingStyle.Quint):Play()
    end)
    local dragging,dragStart,startPos2=false,nil,nil
    local topBar = UILib.newFrame(mainFrame, {
        Name = MW_T.topBar,
        Size = UDim2.new(1, 0, 0, TOP_BAR_H),
        BackgroundTransparency = 0,
        BackgroundColor3 = Theme.WindowBg,
        BorderSizePixel = 0,
        ZIndex = Z.top,
    })
    table.insert(MD.themeCallbacks, function()
        topBar.BackgroundColor3 = Theme.WindowBg
    end)
    UILib.newFrame(topBar, {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Theme.CardBorder, BackgroundTransparency = 0.2, BorderSizePixel = 0})

    local avatarRing = UILib.newFrame(topBar, {
        Size = UDim2.new(0, 1, 0, 1),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 7,
    })
    local avatarStroke = UILib.stroke(avatarRing, Theme.TextAccent, 1, 1)
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Visible = false
    avatarImg.Parent = avatarRing
    local onlineDot = UILib.newFrame(topBar, {Size = UDim2.new(0, 1, 0, 1), BackgroundTransparency = 1, Visible = false, ZIndex = 1})
    local logoMark = UILib.newFrame(topBar, {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 14, 0.5, -8),
        BackgroundColor3 = Theme.TextAccent,
        BorderSizePixel = 0,
        ZIndex = Z.topUi,
    })
    UILib.corner(logoMark, 4)
    table.insert(MD.themeCallbacks, function() logoMark.BackgroundColor3 = Theme.TextAccent end)
    local logoTitle = UILib.newLabel(topBar, {Size = UDim2.new(0, 160, 0, 18), Position = UDim2.new(0, 38, 0, 6), Text = "Melo", RichText = true, TextColor3 = Theme.TextAccent, TextSize = 15, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = Z.topUi})
    local logoLeaf = UILib.newFrame(topBar, {Size = UDim2.fromOffset(10, 10), Position = UDim2.new(0, 84, 0, 10), BackgroundColor3 = Color3.fromRGB(118, 196, 92), BorderSizePixel = 0, ZIndex = Z.topUi})
    UILib.circle(logoLeaf)
    local logoSub = UILib.newLabel(topBar, {Size = UDim2.new(0, 220, 0, 14), Position = UDim2.new(0, 12, 0, 28), Text = "", TextTransparency = 1, Visible = false, ZIndex = 1})
    local playerNameLbl = UILib.newLabel(topBar, {Size = UDim2.new(0, 1, 0, 1), Text = player.DisplayName, TextTransparency = 1, Visible = false, ZIndex = 1})
    local premBadge = UILib.newFrame(topBar, {Size = UDim2.new(0, 1, 0, 1), BackgroundTransparency = 1, Visible = false, ZIndex = 1})
    local function refreshLogoTitle()
        local hex = Settings.UI and Settings.UI.AccentHex or "7DD3FC"
        logoTitle.Text = '<font color="#' .. hex .. '">Melo</font>'
    end
    refreshLogoTitle()
    table.insert(MD.themeCallbacks, function()
        logoSub.TextColor3 = Theme.TextDim
        playerNameLbl.TextColor3 = Theme.TextSecondary
        refreshLogoTitle()
        applyStreamerPrivacy()
    end)
    streamerUiRefs.logoTitle = logoTitle
    streamerUiRefs.logoSub = logoSub
    streamerUiRefs.playerNameLbl = playerNameLbl
    streamerUiRefs.premBadge = premBadge
    streamerUiRefs.refreshLogoTitle = refreshLogoTitle
    local serverPanel = UILib.newFrame(topBar, {
        Size = UDim2.new(0, 1, 0, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 1,
    })
    local serverPanelGrad = UILib.gradient(serverPanel, Theme.SubTabBg, Theme.SubTabBg, 0)
    local serverPanelStroke = UILib.stroke(serverPanel, Theme.TextAccent, 1, 1)
    local serverDot = UILib.newFrame(serverPanel, {Size = UDim2.new(0, 1, 0, 1), BackgroundTransparency = 1, Visible = false})
    local serverGameLbl = UILib.newLabel(serverPanel, {Size = UDim2.new(1, 0, 1, 0), Text = game.Name, TextTransparency = 1, Visible = false})
    local serverPlayersLbl = UILib.newLabel(serverPanel, {Size = UDim2.new(1, 0, 1, 0), Text = "", TextTransparency = 1, Visible = false})
    local serverJobLbl = UILib.newLabel(serverPanel, {Size = UDim2.new(1, 0, 1, 0), Text = "", TextTransparency = 1, Visible = false})
    table.insert(MD.themeCallbacks, function() end)
    local function updateServerInfo()
        local jobId = game.JobId
        local shortJob
        if Settings.Misc.StreamerModePlus then
            shortJob = "--------"
        else
            shortJob = (jobId and jobId ~= "") and jobId:sub(1, 8) or "Studio"
        end
        serverPlayersLbl.Text = #S.Players:GetPlayers() .. "/" .. S.Players.MaxPlayers .. " players"
        serverJobLbl.Text = "Job " .. shortJob
        serverGameLbl.Text = game.Name
    end
    updateServerInfo()
    streamerUiRefs.updateServerInfo = updateServerInfo
    table.insert(allConnections, S.Players.PlayerAdded:Connect(updateServerInfo))
    table.insert(allConnections, S.Players.PlayerRemoving:Connect(updateServerInfo))
    local searchBox = UILib.newBox(topBar, {
        Name = MW_T.search,
        Size = UDim2.new(0, 128, 0, 26),
        Position = UDim2.new(1, -206, 0.5, -13),
        BackgroundColor3 = Theme.InputBg,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Search...",
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.TextPrimary,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ClearTextOnFocus = false,
        ZIndex = Z.topUi,
    })
    UILib.corner(searchBox, 8)
    local searchPad = Instance.new("UIPadding")
    searchPad.PaddingLeft = UDim.new(0, 10)
    searchPad.PaddingRight = UDim.new(0, 8)
    searchPad.Parent = searchBox
    local searchStroke = UILib.stroke(searchBox, Theme.InputBorder, 1, 0.35)
    table.insert(MD.themeCallbacks, function()
        searchBox.BackgroundColor3 = Theme.InputBg
        searchStroke.Color = Theme.InputBorder
    end)
    local minMenuBtn = UILib.newButton(topBar, {
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -70, 0.5, -13),
        BackgroundColor3 = Theme.ButtonBg or Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        Text = "-",
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = Z.topUi,
    })
    UILib.corner(minMenuBtn, 8)
    local minMenuStroke = UILib.stroke(minMenuBtn, Theme.CardBorder, 1, 0.35)
    table.insert(MD.themeCallbacks, function()
        minMenuBtn.BackgroundColor3 = Theme.ButtonBg
        minMenuBtn.TextColor3 = Theme.TextSecondary
        minMenuStroke.Color = Theme.CardBorder
    end)
    local closeMenuBtn = UILib.newButton(topBar, {
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -38, 0.5, -13),
        BackgroundColor3 = Theme.ButtonBg or Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Theme.TextSecondary,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        ZIndex = Z.topUi,
    })
    UILib.corner(closeMenuBtn, 8)
    local closeMenuStroke = UILib.stroke(closeMenuBtn, Theme.CardBorder, 1, 0.35)
    table.insert(MD.themeCallbacks, function()
        closeMenuBtn.BackgroundColor3 = Theme.ButtonBg
        closeMenuBtn.TextColor3 = Theme.TextSecondary
        closeMenuStroke.Color = Theme.CardBorder
    end)
    local function requestUnload()
        local fn = _G[MW_T.cleanup]
        if type(fn) == "function" then
            pcall(fn)
            return
        end

        isUnloading = true
        _G[MW_T.unloaded] = true
        pcall(function()
            if guiMainFrame and guiMainFrame.Parent then guiMainFrame:Destroy() end
        end)
        pcall(function()
            local b = S.Lighting:FindFirstChild(MW_T.menuBlur)
            if b then b:Destroy() end
        end)
    end
    local function applyMenuSearch(query)
        query = string.lower(tostring(query or "")):gsub("^%s+", ""):gsub("%s+$", "")
        local firstMatchPage = nil
        for pageName, page in pairs(tabPages) do
            for _, child in ipairs(page:GetChildren()) do
                if child:IsA("Frame") and child:FindFirstChild(MW_T.cardBody) then
                    local blob = child:GetAttribute("SearchBlob") or ""
                    local match = query == "" or blob:find(query, 1, true) ~= nil
                    child.Visible = match
                    if match and not firstMatchPage then firstMatchPage = pageName end
                end
            end
            local maxY = pageMaxY(page)
            page.CanvasSize = UDim2.new(0, 0, 0, maxY)
        end
        if query ~= "" and firstMatchPage then
            for mainName, info in pairs(navStructure) do
                local inSubs = false
                for _, subName in ipairs(info.subs or {}) do
                    if subName == firstMatchPage then inSubs = true; break end
                end
                if info.page == firstMatchPage or inSubs then
                    switchMain(mainName)
                    break
                end
            end
            switchPage(firstMatchPage)
        end
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        applyMenuSearch(searchBox.Text)
    end)
    searchBox.Focused:Connect(function() UILib.tween(searchStroke, UILib.TFast, {Color = Theme.InputFocus or Theme.TextAccent, Transparency = 0}):Play() end)
    searchBox.FocusLost:Connect(function() UILib.tween(searchStroke, UILib.TFast, {Color = Theme.InputBorder, Transparency = 0.35}):Play() end)
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos2 = mainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    table.insert(allConnections, S.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos2.X.Scale, startPos2.X.Offset + d.X, startPos2.Y.Scale, startPos2.Y.Offset + d.Y)
        end
    end))
    local navStructure = {
        Home = {page = "Home", subs = {}},
        Combat = {page = "Aimbot", subs = {}},
        Visuals = {page = "ESP", subs = {"ESP"}},
        Player = {page = "General", subs = {"General", "Audio"}},
        Audio = {page = "Audio", subs = {}},
        Config = {page = "Settings", subs = {"Settings", "Report"}},
    }
    local tabPages = {}
    local tabBuilt = {}
    local tabBuilders = {}
    local restoreFloatPanels
    local activeMain = "Home"
    local activeTab = "Home"
    local homeSessionT0 = tick()
    local mainTabBtns = {}
    local subTabBtns = {}
    local SUB_TAB_META = {
        ESP = {icon = "eye", label = "ESP"},
        Radar = {icon = "radar", label = "Radar"},
        General = {icon = "menu", label = "Player"},
        Audio = {icon = "volume", label = "Audio"},
        Settings = {icon = "settings", label = "Settings"},
        Report = {icon = "flag", label = "Report"},
    }

    local leftRail = UILib.newFrame(mainFrame, {
        Name = "TraceRail",
        Size = UDim2.new(0, RAIL_W, 1, -TOP_BAR_H - 4),
        Position = UDim2.new(0, 0, 0, TOP_BAR_H),
        BackgroundColor3 = Theme.SidebarBg or Theme.WindowBg,
        BorderSizePixel = 0,
        ZIndex = Z.rail,
        ClipsDescendants = true,
    })
    UILib.corner(leftRail, 0)
    local railStroke = UILib.stroke(leftRail, Theme.CardBorder, 1, 0.35)
    table.insert(MD.themeCallbacks, function()
        leftRail.BackgroundColor3 = Theme.SidebarBg or Theme.WindowBg
        railStroke.Color = Theme.CardBorder
    end)

    local railAccent = UILib.newFrame(leftRail, {
        Name = "RailAccent",
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.TextAccent,
        BackgroundTransparency = 0.72,
        BorderSizePixel = 0,
        ZIndex = Z.railItem,
    })
    table.insert(MD.themeCallbacks, function() railAccent.BackgroundColor3 = Theme.TextAccent end)
    local railList = UILib.newFrame(leftRail, {
        Name = "RailList",
        Size = UDim2.new(1, -4, 1, -58),
        Position = UDim2.new(0, 0, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = Z.railItem,
    })
    local railLayout = Instance.new("UIListLayout")
    railLayout.FillDirection = Enum.FillDirection.Vertical
    railLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    railLayout.Padding = UDim.new(0, 4)
    railLayout.SortOrder = Enum.SortOrder.LayoutOrder
    railLayout.Parent = railList
    local railPad = Instance.new("UIPadding")
    railPad.PaddingTop = UDim.new(0, 8)
    railPad.PaddingLeft = UDim.new(0, 4)
    railPad.PaddingRight = UDim.new(0, 4)
    railPad.Parent = railList
    local railWord = UILib.newLabel(railList, {
        Size = UDim2.new(0, RAIL_W - 12, 0, 2),
        Text = "",
        TextTransparency = 1,
        BackgroundTransparency = 1,
        LayoutOrder = 0,
        Visible = false,
        ZIndex = 1,
    })
    table.insert(MD.themeCallbacks, function() end)
    local mainTabRow = UILib.newFrame(mainFrame, {
        Name = MW_T.mainTabs,
        Size = UDim2.new(1, -CONTENT_PAD * 2, 0, MAIN_TAB_H),
        Position = UDim2.new(0, CONTENT_PAD, 0, TOP_BAR_H + 2),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 18,
    })
    local mainTabLayout = Instance.new("UIListLayout")
    mainTabLayout.FillDirection = Enum.FillDirection.Horizontal
    mainTabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    mainTabLayout.Padding = UDim.new(0, 6)
    mainTabLayout.Parent = mainTabRow
    local subTabRow = UILib.newFrame(mainFrame, {
        Name = MW_T.subTabs,
        Size = UDim2.new(1, -CONTENT_PAD * 2, 0, SUB_TAB_H),
        Position = UDim2.new(0, CONTENT_PAD, 0, TOP_BAR_H + MAIN_TAB_H + 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 18,
    })
    local subTabLayout = Instance.new("UIListLayout")
    subTabLayout.FillDirection = Enum.FillDirection.Horizontal
    subTabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    subTabLayout.Padding = UDim.new(0, 5)
    subTabLayout.Parent = subTabRow
    local contentArea = UILib.newFrame(mainFrame, {
        Name = MW_T.content,
        Size = UDim2.new(1, -(RAIL_W + CONTENT_PAD * 2), 0, CONTENT_H),
        Position = UDim2.new(0, RAIL_W + CONTENT_PAD, 0, CONTENT_TOP),
        BackgroundColor3 = Theme.ContentBg,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = Z.content,
    })
    UILib.corner(contentArea, 12)
    local contentStroke = UILib.stroke(contentArea, Theme.CardBorder, 1, 0.55)
    table.insert(MD.themeCallbacks, function()
        contentArea.BackgroundColor3 = Theme.ContentBg
        contentStroke.Color = Theme.CardBorder
    end)
    local footerBar = UILib.newFrame(mainFrame, {
        Name = MW_T.footer,
        Size = UDim2.new(1, -CONTENT_PAD * 2, 0, FOOTER_H),
        Position = UDim2.new(0, CONTENT_PAD, 1, -FOOTER_H - 4),
        BackgroundColor3 = Theme.WindowBg,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = Z.footer,
    })
    UILib.corner(footerBar, 8)
    local footerStroke = UILib.stroke(footerBar, Theme.CardBorder, 1, 0.45)
    table.insert(MD.themeCallbacks, function()
        footerBar.BackgroundColor3 = Theme.WindowBg
        footerStroke.Color = Theme.CardBorder
    end)
    UILib.newFrame(footerBar, {Size = UDim2.new(0, 3, 0, 10), Position = UDim2.new(0, 10, 0.5, -5), BackgroundColor3 = Theme.TextAccent, BorderSizePixel = 0, Name = MW_T.next(8)})
    local footerLeft = UILib.newLabel(footerBar, {Size = UDim2.new(0.55, -8, 1, 0), Position = UDim2.new(0, 18, 0, 0), Text = "welcome back, " .. player.DisplayName, TextColor3 = Theme.TextDim, TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left})
    local footerCenter = UILib.newLabel(footerBar, {Size = UDim2.new(0.01, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), Text = "", TextTransparency = 1, Visible = false})
    local footerRight = UILib.newLabel(footerBar, {Size = UDim2.new(0.4, -12, 1, 0), Position = UDim2.new(0.6, 0, 0, 0), Text = "nox", TextColor3 = Theme.TextAccent, TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Right})
    table.insert(MD.themeCallbacks, function()
        footerRight.TextColor3 = Theme.TextAccent
        footerLeft.TextColor3 = Theme.TextDim
    end)
    local function updateFooterStatus()
        if Settings.Misc.StreamerModePlus then
            footerLeft.Text = "welcome back, player"
        else
            footerLeft.Text = "welcome back, " .. player.DisplayName
        end
        footerRight.Text = "[ roblox ]"
    end
    updateFooterStatus()
    streamerUiRefs.footerCenter = footerCenter
    streamerUiRefs.footerLeft = footerLeft
    streamerUiRefs.updateFooterStatus = updateFooterStatus
    task.spawn(function()
        while not isUnloading and not _G[MW_T.unloaded] do
            task.wait(30)
            updateFooterStatus()
        end
    end)
    local function switchPage(name)
        if isUnloading or _G[MW_T.unloaded] then return end
        activeTab = name
        if not tabBuilt[name] and tabBuilders[name] then tabBuilders[name](tabPages[name]); tabBuilt[name] = true end
        for n, pg in pairs(tabPages) do pg.Visible = n == name end
        for subName, ref in pairs(subTabBtns) do
            local on = subName == name
            ref.btn.BackgroundColor3 = on and Theme.SubTabActive or Theme.SubTabBg
            ref.label.TextColor3 = on and Theme.TextPrimary or Theme.TextDim
            if ref.icon and ref.icon.SetColor then ref.icon:SetColor(on and Theme.TextAccent or Theme.TextSecondary) end
            if ref.stroke then ref.stroke.Color = on and Theme.TextAccent or Theme.CardBorder; ref.stroke.Transparency = on and 0.35 or 0.65 end
            if ref.indicator then ref.indicator.Visible = on end
        end
    end
    local function updateContentLayout()

        mainTabRow.Visible = false
        subTabRow.Visible = false
        contentArea.Position = UDim2.new(0, RAIL_W + CONTENT_PAD, 0, CONTENT_TOP)
        contentArea.Size = UDim2.new(1, -(RAIL_W + CONTENT_PAD * 2), 0, WIN_H - CONTENT_TOP - FOOTER_H - 6)
        footerBar.Position = UDim2.new(0, RAIL_W + CONTENT_PAD, 1, -FOOTER_H - 4)
        footerBar.Size = UDim2.new(1, -(RAIL_W + CONTENT_PAD * 2), 0, FOOTER_H)
        if leftRail then
            leftRail.Size = UDim2.new(0, RAIL_W, 1, -TOP_BAR_H - 4)
            leftRail.Position = UDim2.new(0, 0, 0, TOP_BAR_H)
        end
    end
    local function refreshSubTabs(mainName)

        for _, c in ipairs(subTabRow:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        subTabBtns = {}
        subTabRow.Visible = false
        mainTabRow.Visible = false
        updateContentLayout()
        return
    end
    local function switchMain(mainName)
        if isUnloading or _G[MW_T.unloaded] then return end
        activeMain = mainName
        for name, ref in pairs(mainTabBtns) do
            local on = name == mainName
            ref.btn.BackgroundTransparency = 1
            ref.label.TextColor3 = on and Theme.TextAccent or Theme.TabText
            if ref.indicator then ref.indicator.Visible = on; ref.indicator.BackgroundColor3 = Theme.TextAccent end
            if ref.stroke then ref.stroke.Transparency = 1 end
        end
        local info = navStructure[mainName]
        refreshSubTabs(mainName)
        switchPage(info.page)
    end
    local mainOrder = 0
    for mainName in pairs(navStructure) do end
    local mainTabOrder = {"Combat", "Visuals", "Player"}
    local MAIN_TAB_LABELS = {
        Combat = "Aimbot",
        Visuals = "Visuals",
        Player = "Misc",
    }
    for i, mainName in ipairs(mainTabOrder) do
        local tabLabel = MAIN_TAB_LABELS[mainName] or mainName
        local w = math.max(64, #tabLabel * 7 + 16)
        local btn = UILib.newButton(mainTabRow, {
            Size = UDim2.new(0, w, 0, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            LayoutOrder = i,
            ZIndex = 7,
        })
        local tabStroke = UILib.stroke(btn, Theme.CardBorder, 1, 1)
        local tabInd = UILib.newFrame(btn, {Size = UDim2.new(1, 0, 0, 1), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0), BackgroundColor3 = Theme.TextAccent, BorderSizePixel = 0, Visible = mainName == activeMain, ZIndex = 8})
        local lbl = UILib.newLabel(btn, {Size = UDim2.new(1, 0, 1, 0), Text = tabLabel, TextColor3 = mainName == activeMain and Theme.TextAccent or Theme.TabText, TextSize = 13, Font = Enum.Font.Gotham})
        mainTabBtns[mainName] = {btn = btn, label = lbl, indicator = tabInd, stroke = tabStroke}
        btn.MouseButton1Click:Connect(function() switchMain(mainName) end)
    end

    local RAIL_ITEMS = {
        {id = "Home", label = "Home", icon = "home", page = "Home"},
    }
    if MW.allows("mm2") then
        table.insert(RAIL_ITEMS, {id = "Combat", label = "MM2", icon = "crosshair", page = "Aimbot"})
    elseif MW.allows("phantomforces") then
        table.insert(RAIL_ITEMS, {id = "Combat", label = "PF", icon = "crosshair", page = "Aimbot"})
    elseif MW.allows("aim") then
        table.insert(RAIL_ITEMS, {id = "Combat", label = "Aim", icon = "crosshair", page = "Aimbot"})
    end
    table.insert(RAIL_ITEMS, {id = "Visuals", label = "ESP", icon = "eye", page = "ESP"})
    table.insert(RAIL_ITEMS, {id = "Player", label = "World", icon = "menu", page = "General"})
    table.insert(RAIL_ITEMS, {id = "Audio", label = "Audio", icon = "volume", page = "Audio"})
    table.insert(RAIL_ITEMS, {id = "Config", label = "Config", icon = "settings", page = "Settings"})
    local railBtns = {}
    local function paintRail()
        for _, item in ipairs(RAIL_ITEMS) do
            local ref = railBtns[item.id]
            if ref then
                local on = false
                if item.id == "Home" then on = activeMain == "Home" or activeTab == "Home"
                elseif item.id == "Combat" then on = activeMain == "Combat"
                elseif item.id == "Visuals" then on = activeMain == "Visuals"
                elseif item.id == "Player" then on = activeMain == "Player" and activeTab ~= "Audio"
                elseif item.id == "Audio" then on = activeTab == "Audio"
                elseif item.id == "Config" then on = activeMain == "Config" or activeTab == "Settings" or activeTab == "Report"
                end
                ref.btn.BackgroundColor3 = on and (Theme.TabBgActive or Color3.fromRGB(16, 18, 26)) or Color3.fromRGB(0, 0, 0)
                ref.btn.BackgroundTransparency = on and 0.05 or 1
                ref.ind.BackgroundTransparency = on and 0 or 1
                if ref.stroke then
                    ref.stroke.Color = Theme.TextAccent
                    ref.stroke.Transparency = on and 0.7 or 1
                end
                pcall(function()
                    if ref.icon and ref.icon.SetColor then
                        ref.icon:SetColor(on and Theme.TextAccent or Theme.TextDim)
                    end
                end)
            end
        end
    end
    for i, item in ipairs(RAIL_ITEMS) do
        local btn = UILib.newButton(railList, {
            Size = UDim2.new(0, 44, 0, 44),
            BackgroundColor3 = Theme.TabBg or Color3.fromRGB(12, 13, 18),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = i,
            ZIndex = Z.railItem,
        })
        UILib.corner(btn, 11)
        local btnStroke = UILib.stroke(btn, Theme.TextAccent, 1, 1)
        local ind = UILib.newFrame(btn, {
            Size = UDim2.new(0, 3, 0, 20),
            Position = UDim2.new(0, 1, 0.5, -10),
            BackgroundColor3 = Theme.TextAccent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = Z.railIcon,
        })
        UILib.corner(ind, 2)
        local iconWrap = UILib.newFrame(btn, {
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(0.5, -11, 0.5, -11),
            BackgroundTransparency = 1,
            ZIndex = Z.railIcon,
        })
        local iconHolder = nil
        pcall(function()
            if MD.Icons and MD.Icons.mount then
                iconHolder = MD.Icons.mount(iconWrap, item.icon, {
                    size = 22,
                    color = Theme.TextSecondary,
                    zIndex = Z.railIcon,
                })
            end
        end)
        if not iconHolder then
            UILib.newLabel(iconWrap, {
                Size = UDim2.new(1, 0, 1, 0),
                Text = string.sub(item.label, 1, 1),
                TextColor3 = Theme.TextAccent,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                ZIndex = Z.railIcon,
            })
        end
        railBtns[item.id] = {btn = btn, ind = ind, icon = iconHolder, stroke = btnStroke}
        btn.MouseButton1Click:Connect(function()
            if item.id == "Audio" then
                activeMain = "Player"
                refreshSubTabs("Player")
                switchPage("Audio")
            elseif item.id == "Config" then
                activeMain = "Config"
                refreshSubTabs("Config")
                switchPage("Settings")
            else
                switchMain(item.id)
            end
            paintRail()
        end)
    end

    local railAvatarWrap = UILib.newFrame(leftRail, {
        Size = UDim2.new(0, 34, 0, 34),
        Position = UDim2.new(0.5, -17, 1, -44),
        BackgroundColor3 = Theme.CardBg,
        BorderSizePixel = 0,
        ZIndex = Z.railIcon,
    })
    UILib.circle(railAvatarWrap)
    UILib.stroke(railAvatarWrap, Theme.TextAccent, 1, 0.35)
    local railAvatarImg = Instance.new("ImageLabel")
    railAvatarImg.BackgroundTransparency = 1
    railAvatarImg.Size = UDim2.new(1, 0, 1, 0)
    railAvatarImg.ZIndex = Z.railIcon
    railAvatarImg.Parent = railAvatarWrap
    UILib.circle(railAvatarImg)
    task.spawn(function()
        local ok, url = pcall(function()
            return S.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        if ok and url then railAvatarImg.Image = url end
    end)
    table.insert(MD.themeCallbacks, paintRail)
    paintRail()
    local _switchMainPaint = switchMain
    switchMain = function(mainName)
        _switchMainPaint(mainName)
        paintRail()
    end
    mainTabRow.Visible = false
    subTabRow.Visible = false
    local function updateRailLayout()
        contentArea.Position = UDim2.new(0, RAIL_W + CONTENT_PAD, 0, CONTENT_TOP)
        contentArea.Size = UDim2.new(1, -(RAIL_W + CONTENT_PAD * 2), 0, WIN_H - CONTENT_TOP - FOOTER_H - 6)
        footerBar.Position = UDim2.new(0, RAIL_W + CONTENT_PAD, 1, -FOOTER_H - 4)
        footerBar.Size = UDim2.new(1, -(RAIL_W + CONTENT_PAD * 2), 0, FOOTER_H)
        leftRail.Size = UDim2.new(0, RAIL_W, 1, -TOP_BAR_H - 4)
        leftRail.Position = UDim2.new(0, 0, 0, TOP_BAR_H)
    end
    updateContentLayout()
    updateRailLayout()
    table.insert(MD.themeCallbacks, function()
        for name, ref in pairs(mainTabBtns) do
            local on = name == activeMain
            if ref.label then ref.label.TextColor3 = on and Theme.TextAccent or Theme.TabText end
            if ref.indicator then ref.indicator.BackgroundColor3 = Theme.TextAccent end
        end
        for name, ref in pairs(subTabBtns) do
            local on = name == activeTab
            if ref.btn then ref.btn.BackgroundColor3 = on and Theme.SubTabActive or Theme.SubTabBg end
            if ref.label then ref.label.TextColor3 = on and Theme.TextPrimary or Theme.TextDim end
            if ref.stroke then ref.stroke.Color = on and Theme.TextAccent or Theme.CardBorder end
            if ref.indicator then ref.indicator.BackgroundColor3 = Theme.TextAccent end
            if ref.icon and ref.icon.SetColor then ref.icon:SetColor(on and Theme.TextAccent or Theme.TextSecondary) end
        end
    end)
    local topNavDock, setMenuVisible, refreshTopNavDock = _G[MW_T.dockApi](
        windowLayer,
        mainFrame,
        switchMain,
        function() return activeMain end
    )
    if topNavDock then topNavDock.Visible = false end
    local _setMenuVisibleCore = setMenuVisible
    setMenuVisible = function(open)
        _setMenuVisibleCore(open)
        if topNavDock then topNavDock.Visible = false end
        pcall(setMenuBlur, open and true or false)
        if open and UILib.Kit and leftRail then
            UILib.Kit.openMenuMotion(mainFrame, leftRail)
        elseif (not open) and UILib.Kit then
            UILib.Kit.closeMenuMotion(mainFrame)
        end
    end
    local _switchMainCore = switchMain
    switchMain = function(mainName)
        _switchMainCore(mainName)
        if refreshTopNavDock then refreshTopNavDock() end
    end
    local function makeCard(parent, title, x, y, w, h_body)
        local wrapper = UILib.newFrame(parent,{Size=UDim2.new(0,w,0,CARD_HEADER_H+h_body),Position=UDim2.new(0,x,0,y),BackgroundColor3=Theme.CardBg,BorderSizePixel=0,ZIndex=10})
        local cardStroke = UILib.stroke(wrapper,Theme.CardBorder,1,0)
        local header = UILib.newFrame(wrapper,{Size=UDim2.new(1,0,0,CARD_HEADER_H),BackgroundColor3=Theme.CardHeaderBg,BorderSizePixel=0,ZIndex=11})
        UILib.newFrame(header,{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=Theme.DividerColor,BorderSizePixel=0,Name=MW_T.headerDiv,ZIndex=12})
        local titleLbl = UILib.newLabel(header,{Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,8,0,0),Text=title,TextColor3=Theme.TextAccent,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13})
        local body = UILib.newFrame(wrapper,{Name=MW_T.cardBody,Size=UDim2.new(1,0,0,h_body),Position=UDim2.new(0,0,0,CARD_HEADER_H),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,ZIndex=11})
        local bodyPad=Instance.new("UIPadding"); bodyPad.PaddingLeft=UDim.new(0,8); bodyPad.PaddingRight=UDim.new(0,8); bodyPad.PaddingTop=UDim.new(0,4); bodyPad.Parent=body
        table.insert(MD.themeCallbacks,function()
            wrapper.BackgroundColor3=Theme.CardBg
            cardStroke.Color = Theme.CardBorder
            header.BackgroundColor3 = Theme.CardHeaderBg
            titleLbl.TextColor3 = Theme.TextAccent
            local hd = header:FindFirstChild(MW_T.headerDiv)
            if hd then hd.BackgroundColor3 = Theme.DividerColor end
        end)
        return body, wrapper
    end
    local function addToggleRow(body, label, yOff, default, callback, locked, getState)
        local lockBadgeText = nil
        if type(locked) == "string" then
            lockBadgeText = locked
            locked = true
        elseif locked then
            lockBadgeText = "WIP"
        end
        local row = UILib.newFrame(body,{Size=UDim2.new(1,0,0,ROW_H),Position=UDim2.new(0,0,0,yOff),BackgroundTransparency=1,BorderSizePixel=0})
        local box = UILib.newFrame(row,{
            Size=UDim2.new(0,14,0,14),
            Position=UDim2.new(0,0,0.5,-7),
            BackgroundColor3=(not locked and default) and Theme.ToggleOn or Theme.ToggleOff,
            BorderSizePixel=0,
            ZIndex=2,
            BackgroundTransparency=locked and 0.45 or 0,
        })
        local boxStroke = UILib.stroke(box, (not locked and default) and Theme.ToggleOn or Theme.CardBorder, 1, locked and 0.35 or 0)
        local check = UILib.newFrame(box,{
            Size=UDim2.new(0,6,0,6),
            AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.new(0.5,0,0.5,0),
            BackgroundColor3=Color3.fromRGB(12,12,14),
            BackgroundTransparency=(not locked and default) and 0 or 1,
            BorderSizePixel=0,
            ZIndex=3,
        })
        local badgeW = lockBadgeText and math.clamp(#lockBadgeText * 6 + 10, 32, 88) or 0
        UILib.newLabel(row,{
            Size=UDim2.new(1, locked and -(24 + badgeW) or -22,1,0),
            Position=UDim2.new(0,22,0,0),
            Text=label,
            TextColor3=locked and Theme.TextDim or Theme.TextPrimary,
            TextSize=12,
            Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=2,
        })
        if locked then
            local badge = UILib.newFrame(row,{
                Size=UDim2.new(0,badgeW,0,14),
                Position=UDim2.new(1,-(badgeW + 2),0.5,-7),
                BackgroundColor3=Theme.WarnColor,
                BackgroundTransparency=0.72,
                BorderSizePixel=0,
                ZIndex=4,
            })
            UILib.corner(badge, 3)
            local badgeStroke = UILib.stroke(badge, Theme.WarnColor, 1, 0.35)
            UILib.newLabel(badge,{
                Size=UDim2.new(1,0,1,0),
                Text=lockBadgeText or "WIP",
                TextColor3=Theme.WarnColor,
                TextSize=8,
                Font=Enum.Font.GothamBold,
                ZIndex=5,
            })
            table.insert(MD.themeCallbacks, function()
                badge.BackgroundColor3 = Theme.WarnColor
                badgeStroke.Color = Theme.WarnColor
            end)
        end
        local enabled = (not locked) and default or false
        local function paint()
            if locked then
                box.BackgroundColor3 = Theme.ToggleOff
                boxStroke.Color = Theme.CardBorder
                check.BackgroundTransparency = 1
            else
                box.BackgroundColor3 = enabled and Theme.ToggleOn or Theme.ToggleOff
                boxStroke.Color = enabled and Theme.ToggleOn or Theme.CardBorder
                check.BackgroundTransparency = enabled and 0 or 1
            end
        end
        UILib.newButton(row,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=8},function()
            if isUnloading or _G[MW_T.unloaded] or waitingForKey then return end
            if locked then
                sendNotification(label, lockBadgeText or "WIP - coming soon", 2)
                return
            end
            enabled = not enabled
            paint()
            if callback then callback(enabled) end
        end)
        table.insert(MD.themeCallbacks,function()
            paint()
        end)
        local api = {
            setValue=function(v)
                if locked then return end
                enabled=v and true or false
                paint()
            end,
            getValue=function() return enabled end,
            row=row
        }
        if typeof(getState) == "function" then
            registerUiSync(function()
                api.setValue(getState() and true or false)
            end)
        end
        return api
    end
    local activeSlider = nil
    table.insert(allConnections,S.UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then activeSlider=nil end end))
    table.insert(allConnections,S.UserInputService.InputChanged:Connect(function(inp)
        if not activeSlider or inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
        if isUnloading or _G[MW_T.unloaded] then activeSlider=nil; return end
        local s=activeSlider
        local ok=pcall(function()
            if not s.track or not s.track.Parent then activeSlider=nil; return end
            local mx=player:GetMouse().X
            local rx=math.clamp((mx-s.track.AbsolutePosition.X)/math.max(s.track.AbsoluteSize.X,1),0,1)
            local cur; if s.max<=1 then cur=math.floor((s.min+rx*(s.max-s.min))*100)/100 else cur=math.floor(s.min+rx*(s.max-s.min)+0.5) end
            s.fill.Size=UDim2.new(rx,0,1,0)
            if s.knob then s.knob.Position=UDim2.new(rx,0,0.5,0) end
            if s.valLbl and s.valLbl.Parent then
                if s.max <= 1 then s.valLbl.Text = string.format("%.2f", cur)
                else s.valLbl.Text = tostring(cur) end
            end
            if s.callback then s.callback(cur) end
        end)
        if not ok then activeSlider=nil end
    end))
    local function addSliderRow(body, label, yOff, min, max, default, callback)
        local row = UILib.newFrame(body,{Size=UDim2.new(1,0,0,ROW_H+8),Position=UDim2.new(0,0,0,yOff),BackgroundTransparency=1,BorderSizePixel=0})
        UILib.newLabel(row,{Size=UDim2.new(0.62,0,0,14),Text=label,TextColor3=Theme.TextPrimary,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left})
        local disp = (max <= 1) and string.format("%.2f", default) or tostring(default)
        local valLbl=UILib.newLabel(row,{Size=UDim2.new(0.38,0,0,14),Position=UDim2.new(0.62,0,0,0),Text=disp,TextColor3=Theme.TextAccent,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Right})
        local track=UILib.newFrame(row,{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,18),BackgroundColor3=Theme.SliderTrack,BorderSizePixel=0})
        UILib.corner(track, 8)
        local fill=UILib.newFrame(track,{Size=UDim2.new((default-min)/math.max(max-min,0.0001),0,1,0),BackgroundColor3=Theme.SliderFill,BorderSizePixel=0})
        UILib.corner(fill, 8)
        local knob=UILib.newFrame(track,{Size=UDim2.fromOffset(12,12),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new((default-min)/math.max(max-min,0.0001),0,0.5,0),BackgroundColor3=Color3.fromRGB(245,245,245),BorderSizePixel=0,ZIndex=3})
        UILib.corner(knob, 12)
        UILib.newButton(row,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=8},nil).MouseButton1Down:Connect(function()
            if isUnloading or _G[MW_T.unloaded] then return end
            activeSlider={track=track,fill=fill,knob=knob,valLbl=valLbl,min=min,max=max,callback=callback}
        end)
        return row
    end
    local function addEnumRow(body, label, yOff, options, default, callback, getState)
        local ROW2 = ROW_H + 22
        local row = UILib.newFrame(body,{Size=UDim2.new(1,0,0,ROW2),Position=UDim2.new(0,0,0,yOff),BackgroundTransparency=1,BorderSizePixel=0})
        UILib.newLabel(row,{Size=UDim2.new(1,0,0,14),Text=label,TextColor3=Theme.TextPrimary,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left})
        local drop = UILib.newFrame(row,{
            Size=UDim2.new(1,0,0,20),
            Position=UDim2.new(0,0,0,16),
            BackgroundColor3=Theme.EnumBg,
            BorderSizePixel=0,
        })
        UILib.stroke(drop, Theme.CardBorder, 1, 0)
        local selected = default
        local selLbl = UILib.newLabel(drop,{
            Size=UDim2.new(1,-22,1,0),
            Position=UDim2.new(0,6,0,0),
            Text=tostring(selected),
            TextColor3=Theme.TextPrimary,
            TextSize=11,
            Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=2,
        })
        UILib.newLabel(drop,{
            Size=UDim2.new(0,16,1,0),
            Position=UDim2.new(1,-18,0,0),
            Text="▾",
            TextColor3=Theme.TextDim,
            TextSize=10,
            Font=Enum.Font.Gotham,
            ZIndex=2,
        })
        local idx = 1
        for i,opt in ipairs(options) do if opt==default then idx=i break end end
        local function setSelected(v)
            selected = v
            selLbl.Text = tostring(selected)
            for i,opt in ipairs(options) do if opt==selected then idx=i break end end
        end
        UILib.newButton(drop,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},function()
            if isUnloading or _G[MW_T.unloaded] or waitingForKey then return end
            idx = idx % #options + 1
            selected = options[idx]
            selLbl.Text = tostring(selected)
            if callback then callback(selected) end
        end)
        if typeof(getState) == "function" then
            registerUiSync(function()
                local v = getState()
                if v ~= nil then setSelected(v) end
            end)
        end
        return row
    end
    local function addKeybindProp(body, label, yOff, default, callback)
        local row = UILib.newFrame(body,{Size=UDim2.new(1,0,0,ROW_H),Position=UDim2.new(0,0,0,yOff),BackgroundTransparency=1,BorderSizePixel=0})
        UILib.newLabel(row,{Size=UDim2.new(1,-84,1,0),Text=label,TextColor3=Theme.TextPrimary,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left})
        local kbBtn=UILib.newButton(row,{Size=UDim2.new(0,72,0,18),Position=UDim2.new(1,-74,0.5,-9),BackgroundColor3=Theme.KeybindBg,BorderSizePixel=0,Text=MD.bindName(default),TextColor3=Theme.KeybindText,TextSize=10,Font=Enum.Font.Gotham})
        local kbStroke = UILib.stroke(kbBtn, Theme.KeybindBorder or Theme.CardBorder, 1, 0)
        local cur=default
        table.insert(MD.themeCallbacks, function()
            kbBtn.BackgroundColor3 = Theme.KeybindBg
            kbBtn.TextColor3 = Theme.KeybindText
            kbStroke.Color = Theme.KeybindBorder or Theme.CardBorder
        end)
        kbBtn.MouseButton1Click:Connect(function()
            if waitingForKey then return end
            keybindCapture = {
                btn = kbBtn,
                previous = cur,
                callback = function(bind)
                    cur = bind
                    if callback then callback(bind) end
                end,
            }
            kbBtn.Text = "..."
            kbBtn.TextColor3 = Color3.fromRGB(255,255,100)
            task.defer(function()
                if keybindCapture and keybindCapture.btn == kbBtn then
                    waitingForKey = true
                    keybindIgnoreUntil = tick() + 0.15
                end
            end)
        end)
        return row
    end
    local function addButtonRow(body, text, yOff, callback, color)
        if typeof(color) ~= "Color3" then color = nil end
        local bg = color or Theme.ButtonBg
        if typeof(bg) ~= "Color3" then bg = Color3.fromRGB(16, 18, 26) end
        local fg = Theme.ButtonText
        if typeof(fg) ~= "Color3" then fg = Color3.fromRGB(233, 235, 239) end
        local btn = UILib.newButton(body, {
            Size = UDim2.new(1, 0, 0, 24),
            Position = UDim2.new(0, 0, 0, yOff),
            BackgroundColor3 = bg,
            BorderSizePixel = 0,
            Text = tostring(text or ""),
            TextColor3 = fg,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
        }, callback)
        UILib.corner(btn, 6)
        if not color and typeof(Theme.ButtonBg) == "Color3" then
            local hover = Theme.ButtonBgHover
            if typeof(hover) ~= "Color3" then hover = bg end
            pcall(function() UILib.gradient(btn, bg, hover, 90) end)
        end
        btn.MouseEnter:Connect(function() UILib.tween(btn, UILib.TFast, {BackgroundTransparency = 0.15}):Play() end)
        btn.MouseLeave:Connect(function() UILib.tween(btn, UILib.TFast, {BackgroundTransparency = 0}):Play() end)
        return btn
    end
    local function addInfoRow(body, text, yOff, color)
        return UILib.newLabel(body,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,yOff),Text=text,TextColor3=color or Theme.TextDim,TextSize=9,Font=Enum.Font.SourceSansItalic,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
    end
    local function addInputRow(body, placeholder, yOff, default, callback)
        local box=UILib.newBox(body,{Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0,yOff),BackgroundColor3=Theme.InputBg,BorderSizePixel=0,Text=default or "",PlaceholderText=placeholder,PlaceholderColor3=Theme.TextDim,TextColor3=Theme.TextPrimary,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false})
        UILib.corner(box,5)
        local boxStroke = UILib.stroke(box, Theme.InputBorder, 1, 0.3)
        local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,8); pad.Parent=box

        box.Focused:Connect(function() UILib.tween(boxStroke,UILib.TFast,{Color=Theme.InputFocus or Theme.CardHeaderBg, Transparency=0}):Play() end)
        box.FocusLost:Connect(function() UILib.tween(boxStroke,UILib.TFast,{Color=Theme.InputBorder, Transparency=0.3}):Play(); if callback and box.Text~="" then callback(box.Text) end end)
        return box
    end
    local function addDivider(body, yOff)
        local div = UILib.newFrame(body,{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,yOff),BackgroundColor3=Theme.DividerColor or Theme.CardBorder,BorderSizePixel=0})
        UILib.gradient(div, Theme.DividerColor or Theme.CardBorder, Color3.fromRGB(0,0,0), 0)
    end
    local function makePage(name)
        local pg = Instance.new("ScrollingFrame")
        pg.Name=MW_T.next(11); pg.Size=UDim2.new(1,0,1,0)
        pg.BackgroundTransparency=1; pg.BorderSizePixel=0
        pg.ScrollBarThickness=3; pg.ScrollBarImageColor3=Theme.TextAccent
        pg.CanvasSize=UDim2.new(0,0,0,900); pg.ScrollingDirection=Enum.ScrollingDirection.Y
        pg.Visible=false; pg.ZIndex = Z.page; pg.Parent=contentArea
        return pg
    end
    local COL1_X = CONTENT_PAD
    local COL2_X = COL1_X + CARD_W + CONTENT_PAD
    local function col1Y(page) local n=page:FindFirstChild(MW_T.col1); if not n then n=Instance.new("NumberValue"); n.Name=MW_T.col1; n.Value=CONTENT_PAD + 4; n.Parent=page end; return n end
    local function col2Y(page) local n=page:FindFirstChild(MW_T.col2); if not n then n=Instance.new("NumberValue"); n.Name=MW_T.col2; n.Value=CONTENT_PAD + 4; n.Parent=page end; return n end
    local function pageMaxY(page) return math.max(col1Y(page).Value, col2Y(page).Value) + CONTENT_PAD end
    for _, name in ipairs({"Home", "General", "Aimbot", "ESP", "Audio", "Report", "Settings"}) do
        tabPages[name] = makePage(name)
        tabBuilt[name] = false
    end
    local function addCard(page, col, title, rows)
        if SINGLE_COLUMN then col = 1 end
        local h = 8
        for _,r in ipairs(rows) do
            if r[1]=="toggle"  then h=h+ROW_H+2
            elseif r[1]=="slider"  then h=h+ROW_H+12
            elseif r[1]=="enum"    then h=h+ROW_H+30
            elseif r[1]=="keybind" then h=h+ROW_H+2
            elseif r[1]=="button"  then h=h+28
            elseif r[1]=="info"    then h=h+18
            elseif r[1]=="divider" then h=h+8
            elseif r[1]=="input"   then h=h+28
            end
        end
        h = h + 6
        local x = col==1 and COL1_X or COL2_X
        local yVal = col==1 and col1Y(page) or col2Y(page)
        local body, wrapper = makeCard(page, title, x, yVal.Value, CARD_W, h)
        yVal.Value = yVal.Value + CARD_HEADER_H + h + CONTENT_PAD
        local ry = 0
        local rowById = {}
        local built = {}
        for _,r in ipairs(rows) do
            local rtype = r[1]
            local meta = r.meta
            local entry = nil
            if rtype=="toggle" then
                local userCb = r[4]
                local api = addToggleRow(body,r[2],ry,r[3],function(on)
                    if userCb then userCb(on) end
                    if meta and meta.reveal then
                        for _, id in ipairs(meta.reveal) do
                            local dep = rowById[id]
                            if dep then dep.Visible = on and true or false end
                        end
                    end
                end,r[5],r[6])
                entry = api and api.row
                ry=ry+ROW_H+2
            elseif rtype=="slider" then addSliderRow(body,r[2],ry,r[3],r[4],r[5],r[6]); ry=ry+ROW_H+12
            elseif rtype=="enum" then
                entry = addEnumRow(body,r[2],ry,r[3],r[4],r[5],r[6])
                ry=ry+ROW_H+30
            elseif rtype=="keybind" then addKeybindProp(body,r[2],ry,r[3],r[4]); ry=ry+ROW_H+2
            elseif rtype=="button" then
                local btnColor = r[4]
                local badge = nil
                if typeof(btnColor) ~= "Color3" then

                    if type(btnColor) == "string" then badge = btnColor end
                    btnColor = nil
                end
                local label = r[2]
                if badge then label = label .. "  [" .. badge .. "]" end
                addButtonRow(body, label, ry, r[3], btnColor)
                ry=ry+28
            elseif rtype=="info" then addInfoRow(body,r[2],ry,r[3]); ry=ry+18
            elseif rtype=="divider" then addDivider(body,ry+3); ry=ry+8
            elseif rtype=="input" then addInputRow(body,r[2],ry,r[3],r[4]); ry=ry+28
            end
            if meta and meta.id and entry then
                rowById[meta.id] = entry
                table.insert(built, {meta = meta, entry = entry, rtype = rtype, defaultOn = r[3]})
            end
        end
        for _, item in ipairs(built) do
            if item.meta.whenGet then
                item.entry.Visible = item.meta.whenGet() and true or false
            end
            if item.meta.reveal and item.rtype == "toggle" then
                local on = item.defaultOn and true or false
                if item.meta.whenGet then on = item.meta.whenGet() and true or false end
                for _, id in ipairs(item.meta.reveal) do
                    local dep = rowById[id]
                    if dep then dep.Visible = on and true or false end
                end
            end
        end
        local maxY = pageMaxY(page)
        page.CanvasSize = UDim2.new(0,0,0,maxY)
        local searchBlob = string.lower(title)
        for _, r in ipairs(rows) do
            if r[2] and type(r[2]) == "string" then searchBlob = searchBlob .. " " .. string.lower(r[2]) end
        end
        wrapper:SetAttribute("SearchBlob", searchBlob)
        return body, wrapper
    end
    local speedVel = nil
    tabBuilders["Home"] = function(page)
        local pad = 12
        local gap = 12
        local fullW = math.max(300, CONTENT_W - 8)
        local colGap = 12
        local leftW = math.floor((fullW - colGap) * 0.56)
        local rightW = fullW - colGap - leftW
        local function softGlow(parent, color)

            local g = UILib.newFrame(parent, {
                Size = UDim2.new(0, 3, 1, -16),
                Position = UDim2.new(0, 6, 0, 8),
                BackgroundColor3 = color,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
                ZIndex = Z.cardUi,
            })
            UILib.corner(g, 2)
            return g
        end
        local function card(parent, title, subtitle, x, y, w, h, glow)
            local f = UILib.newFrame(parent, {
                Size = UDim2.new(0, w, 0, h),
                Position = UDim2.new(0, x, 0, y),
                BackgroundColor3 = Theme.CardBg,
                BorderSizePixel = 0,
                ZIndex = Z.card,
                ClipsDescendants = true,
            })
            UILib.corner(f, 12)
            UILib.stroke(f, Theme.CardBorder, 1, 0.5)
            if glow then softGlow(f, glow) end
            local ttl = UILib.newLabel(f, {
                Size = UDim2.new(1, -28, 0, 20),
                Position = UDim2.new(0, 16, 0, 12),
                Text = title,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = Z.cardUi,
            })
            if subtitle and subtitle ~= "" then
                UILib.newLabel(f, {
                    Size = UDim2.new(1, -28, 0, math.max(16, h - 40)),
                    Position = UDim2.new(0, 16, 0, 32),
                    Text = subtitle,
                    TextColor3 = Theme.TextDim,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextWrapped = true,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = Z.cardUi,
                })
            end
            table.insert(MD.themeCallbacks, function()
                f.BackgroundColor3 = Theme.CardBg
                ttl.TextColor3 = Theme.TextPrimary
            end)
            return f
        end
        local function tile(parent, title, value, x, y, w, h)
            local f = UILib.newFrame(parent, {
                Size = UDim2.new(0, w, 0, h),
                Position = UDim2.new(0, x, 0, y),
                BackgroundColor3 = Color3.fromRGB(10, 11, 15),
                BorderSizePixel = 0,
                ZIndex = Z.cardUi,
            })
            UILib.corner(f, 8)
            UILib.stroke(f, Theme.CardBorder, 1, 0.75)
            UILib.newLabel(f, {
                Size = UDim2.new(1, -14, 0, 14),
                Position = UDim2.new(0, 10, 0, 7),
                Text = title,
                TextColor3 = Theme.TextDim,
                TextSize = 10,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = Z.cardUi + 1,
            })
            local v = UILib.newLabel(f, {
                Size = UDim2.new(1, -14, 0, 20),
                Position = UDim2.new(0, 10, 0, 22),
                Text = value,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = Z.cardUi + 1,
            })
            return v
        end

        local hello = UILib.newFrame(page, {
            Size = UDim2.new(0, fullW, 0, 76),
            Position = UDim2.new(0, pad, 0, pad),
            BackgroundColor3 = Theme.CardBg,
            BorderSizePixel = 0,
            ZIndex = Z.card,
            ClipsDescendants = true,
        })
        UILib.corner(hello, 12)
        UILib.stroke(hello, Theme.CardBorder, 1, 0.5)
        table.insert(MD.themeCallbacks, function() hello.BackgroundColor3 = Theme.CardBg end)
        local helloImg = Instance.new("ImageLabel")
        helloImg.Size = UDim2.fromOffset(50, 50)
        helloImg.Position = UDim2.new(0, 14, 0.5, -25)
        helloImg.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
        helloImg.BorderSizePixel = 0
        helloImg.ZIndex = Z.cardUi
        helloImg.Parent = hello
        UILib.corner(helloImg, 12)
        task.spawn(function()
            local ok, url = pcall(function()
                return S.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)
            if ok and url then helloImg.Image = url end
        end)
        local helloTitle = UILib.newLabel(hello, {
            Size = UDim2.new(1, -82, 0, 24),
            Position = UDim2.new(0, 76, 0, 16),
            Text = "Hello, " .. (player.DisplayName or player.Name),
            TextColor3 = Theme.TextPrimary,
            TextSize = 20,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = Z.cardUi,
        })
        UILib.newLabel(hello, {
            Size = UDim2.new(1, -82, 0, 18),
            Position = UDim2.new(0, 76, 0, 42),
            Text = (player.Name or "") .. "  ·  " .. (MW.mode or "Melo 🍃"),
            TextColor3 = Theme.TextDim,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = Z.cardUi,
        })
        local modeY = pad + 76 + gap
        local modeSub = ((MW.kitSummary and MW.kitSummary()) or "")
            .. "\nExecutor: " .. tostring(getExecutorName())
        local modeCard = card(page, "Mode: " .. tostring(MW.mode or "?"), modeSub, pad, modeY, fullW, 78, Color3.fromRGB(125, 211, 252))
        local y = modeY + 78 + gap
        local headerH = 52
        local tw = math.floor((leftW - 36) / 2)
        local th = 48
        local serverH = headerH + (th + 8) * 3 + 14
        local server = card(page, "Server", "Current session", pad, y, leftW, serverH, Color3.fromRGB(60, 190, 120))
        local playersLbl = tile(server, "Players", tostring(#S.Players:GetPlayers()) .. " playing", 12, headerH, tw, th)
        local maxLbl = tile(server, "Max Players", tostring(S.Players.MaxPlayers), 20 + tw, headerH, tw, th)
        local pingLbl = tile(server, "Latency", "-- ms", 12, headerH + th + 8, tw, th)
        tile(server, "Region", "N/A", 20 + tw, headerH + th + 8, tw, th)
        local timeLbl = tile(server, "In server", "00:00:00", 12, headerH + (th + 8) * 2, tw, th)
        local joinTile = tile(server, "Join Script", "Tap to copy", 20 + tw, headerH + (th + 8) * 2, tw, th)
        UILib.newButton(server, {
            Size = UDim2.new(0, tw, 0, th),
            Position = UDim2.new(0, 20 + tw, 0, headerH + (th + 8) * 2),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = Z.cardUi + 2,
        }, function()
            local scriptTxt = string.format(
                'game:GetService("TeleportService"):TeleportToPlaceInstance(%d,"%s")',
                game.PlaceId, tostring(game.JobId or "")
            )
            local ok = Auth.copyText(scriptTxt)
            joinTile.Text = ok and "Copied" or "Failed"
            MD.sendNotification("Join Script", ok and "Copied" or "Copy failed", 2)
        end)
        local execWeak = Cap.isWeak and Cap.isWeak()
        local execSub = execWeak and "Weak for Melo 🍃: some features locked."
            or (MW.isArsenal and "Looks supported for Melo 🍃."
            or ((MW.kitSummary and MW.kitSummary()) or "Kit active: gun mods Arsenal-only."))
        local execH = 96
        local exec = card(
            page,
            getExecutorName(),
            execSub,
            pad + leftW + colGap,
            y,
            rightW,
            execH,
            execWeak and Color3.fromRGB(210, 70, 70) or Color3.fromRGB(125, 211, 252)
        )
        local execDetail = UILib.newLabel(exec, {
            Size = UDim2.new(1, -28, 0, 34),
            Position = UDim2.new(0, 14, 0, 54),
            Text = Cap.summaryLine and Cap.summaryLine() or "",
            TextColor3 = Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = Z.cardUi,
        })
        local friendsH = 148
        local friendsY = y + execH + gap
        local friends = card(page, "Friends", "Roblox friends overview", pad + leftW + colGap, friendsY, rightW, friendsH, Color3.fromRGB(220, 170, 70))
        local ftw = math.floor((rightW - 36) / 2)
        local fth = 44
        local fIn = tile(friends, "In Server", "…", 12, 52, ftw, fth)
        local fOff = tile(friends, "Offline", "…", 20 + ftw, 52, ftw, fth)
        local fOn = tile(friends, "Online", "…", 12, 52 + fth + 8, ftw, fth)
        local fAll = tile(friends, "All", "…", 20 + ftw, 52 + fth + 8, ftw, fth)
        local bottomY = math.max(y + serverH, friendsY + friendsH) + gap
        local quickY = bottomY
        local quick = card(page, "Quick", "", pad, quickY, fullW, 70, nil)
        local unloadHomeBtn = UILib.newButton(quick, {
            Size = UDim2.new(0, 130, 0, 34),
            Position = UDim2.new(0, 14, 0, 26),
            BackgroundColor3 = Color3.fromRGB(42, 16, 18),
            BorderSizePixel = 0,
            Text = "Unload Melo 🍃",
            TextColor3 = Theme.ErrorColor,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            ZIndex = Z.cardUi + 2,
        }, function()
            requestUnload()
        end)
        UILib.corner(unloadHomeBtn, 9)
        UILib.stroke(unloadHomeBtn, Theme.ErrorColor, 1, 0.45)
        local function fmtTime(sec)
            sec = math.max(0, math.floor(sec))
            return string.format("%02d:%02d:%02d", math.floor(sec / 3600), math.floor((sec % 3600) / 60), sec % 60)
        end
        local function refreshHome()
            playersLbl.Text = tostring(#S.Players:GetPlayers()) .. " playing"
            maxLbl.Text = tostring(S.Players.MaxPlayers)
            local ping = nil
            pcall(function() ping = math.floor((player:GetNetworkPing() or 0) * 1000) end)
            pingLbl.Text = ping and (tostring(ping) .. " ms") or "-- ms"
            timeLbl.Text = fmtTime(tick() - (homeSessionT0 or tick()))
            execDetail.Text = Cap.summaryLine and Cap.summaryLine() or ""
        end
        refreshHome()
        table.insert(allConnections, S.Players.PlayerAdded:Connect(refreshHome))
        table.insert(allConnections, S.Players.PlayerRemoving:Connect(refreshHome))
        task.spawn(function()
            while page.Parent and not isUnloading and not _G[MW_T.unloaded] do
                refreshHome()
                task.wait(1)
            end
        end)
        task.spawn(function()
            local inServer, online, offline, total = 0, 0, 0, 0
            local ok = pcall(function()
                local pages = S.Players:GetFriendsAsync(player.UserId)
                while true do
                    for _, item in ipairs(pages:GetCurrentPage()) do
                        total = total + 1
                        local uid = item.Id or item.VisitorId
                        if uid and S.Players:GetPlayerByUserId(uid) then
                            inServer = inServer + 1
                        elseif item.IsOnline then
                            online = online + 1
                        else
                            offline = offline + 1
                        end
                    end
                    if pages.IsFinished then break end
                    pages:AdvanceToNextPageAsync()
                end
            end)
            if not ok then
                fIn.Text, fOn.Text, fOff.Text, fAll.Text = "n/a", "n/a", "n/a", "n/a"
            else
                fIn.Text = inServer > 0 and (tostring(inServer) .. " here") or "none"
                fOn.Text = tostring(online)
                fOff.Text = tostring(offline)
                fAll.Text = tostring(total)
            end
        end)
        page.CanvasSize = UDim2.new(0, 0, 0, quickY + 70 + pad + 16)
    end
    tabBuilders["General"] = function(page)
        addCard(page,1,"World Recipes",{
            {"button","Noon",function() if MD.TracePack then MD.TracePack.applyWorldRecipe("Noon") end end},
            {"button","Dusk",function() if MD.TracePack then MD.TracePack.applyWorldRecipe("Dusk") end end},
            {"button","Night",function() if MD.TracePack then MD.TracePack.applyWorldRecipe("Night") end end},
            {"button","Flat",function() if MD.TracePack then MD.TracePack.applyWorldRecipe("Flat") end end},
            {"button","Cinematic",function() if MD.TracePack then MD.TracePack.applyWorldRecipe("Cinematic") end end},
            {"button","Arena Bright",function() if MD.TracePack then MD.TracePack.applyWorldRecipe("ArenaBright") end end},
            {"info","Lighting recipes for Visuals: safe client-side only.",Theme.TextDim},
        })
        addCard(page,1,"HUD Overlay",{
            {"toggle","Watermark",Settings.HUD.Watermark ~= false,function(e) Settings.HUD.Watermark=e end},
            {"enum","Watermark Pos",{"TopLeft","TopRight","BottomLeft"},Settings.HUD.WatermarkPos or "TopLeft",function(v) Settings.HUD.WatermarkPos=v end},
            {"toggle","Keybind List",Settings.HUD.KeybindList == true,function(e) Settings.HUD.KeybindList=e end},
            {"enum","Keybind Pos",{"Right","Left","TopRight"},Settings.HUD.KeybindPos or "Right",function(v) Settings.HUD.KeybindPos=v end},
            {"toggle","Nearby Strip",Settings.HUD.SpectatorList == true,function(e) Settings.HUD.SpectatorList=e end},
            {"toggle","Show FPS",Settings.HUD.ShowFPS ~= false,function(e) Settings.HUD.ShowFPS=e end},
            {"toggle","Show Ping",Settings.HUD.ShowPing ~= false,function(e) Settings.HUD.ShowPing=e end},
            {"toggle","Show Executor",Settings.HUD.ShowExecutor ~= false,function(e) Settings.HUD.ShowExecutor=e end},
            {"enum","HUD Layout",{"Compact","Streamer","Arena","Minimal","CombatFocus","CornerStack"},"Compact",function(v) if MD.applyHudLayout then MD.applyHudLayout(v) end end},
            {"info","Overlays sit above the world. Hit feed panel removed.",Theme.TextDim},
        })
        if MW.allows("speedHack") ~= false then
        addCard(page,1,"Speed",{
                {"toggle","Speed Boost",Settings.Movement.SpeedEnabled,function(e)
                    Settings.Movement.SpeedEnabled=e
                    if not e then if speedVel then pcall(function() speedVel:Destroy() end); speedVel=nil end; local c=player.Character; if c then local h=c:FindFirstChild("Humanoid"); if h then h.WalkSpeed=16 end end end
                end},
                {"slider","Speed",1,300,Settings.Movement.Speed,function(v) Settings.Movement.Speed=v; if Settings.Movement.SpeedEnabled and Settings.Movement.SpeedMethod=="WalkSpeed" then local c=player.Character; if c then local h=c:FindFirstChild("Humanoid"); if h then h.WalkSpeed=v end end end end},
                {"enum","Method",{"Walk","CFrame","Vel"},"Walk",function(v) local m={Walk="WalkSpeed",CFrame="CFrame",Vel="Velocity"}; if speedVel then pcall(function() speedVel:Destroy() end); speedVel=nil end; local c=player.Character; if c then local h=c:FindFirstChild("Humanoid"); if h then h.WalkSpeed=16 end end; Settings.Movement.SpeedMethod=m[v] or "WalkSpeed" end},
            })
            addCard(page,1,"Jump & Bhop",{
                {"toggle","High Jump",Settings.Movement.JumpEnabled,function(e) Settings.Movement.JumpEnabled=e; local c=player.Character; if c then local h=c:FindFirstChild("Humanoid"); if h then h.JumpPower=e and Settings.Movement.JumpPower or 50 end end end},
                {"slider","Jump Power",50,300,Settings.Movement.JumpPower,function(v) Settings.Movement.JumpPower=v; if Settings.Movement.JumpEnabled then local c=player.Character; if c then local h=c:FindFirstChild("Humanoid"); if h then h.JumpPower=v end end end end},
                {"toggle","Bunny Hop",Settings.Movement.BunnyHop,function(e) Settings.Movement.BunnyHop=e end},
                {"slider","Bhop Speed",1,100,Settings.Movement.BunnyHopSpeed,function(v) Settings.Movement.BunnyHopSpeed=v end},
            })
        end
        if MW.allows("fly") ~= false then
            addCard(page,1,"Fly",{
                {"toggle","Enable Fly",Settings.Movement.Fly,function(e) Settings.Movement.Fly=e; if e then MD.startFly(); MD.sendNotification("Fly","On - F to toggle",2) else MD.stopFly(); MD.sendNotification("Fly","Off",2) end end},
                {"enum","Fly Method",{"CFrame","Velocity","BodyMovers"},Settings.Movement.FlyMethod or "CFrame",function(v)
                    Settings.Movement.FlyMethod=v
                    if Settings.Movement.Fly then MD.stopFly(); MD.startFly() end
                    MD.sendNotification("Fly Method",v,2)
                end},
                {"slider","Fly Speed",10,200,Settings.Movement.FlySpeed,function(v) Settings.Movement.FlySpeed=v end},
                {"info","CFrame = precise | Velocity = physics | BodyMovers = classic BV/BG",Theme.TextDim},
                {"info","F key = toggle fly while enabled",Theme.TextDim},
            })
        end
        addCard(page,1,"Movement Kit",{
            {"toggle","Noclip",Settings.Movement.Noclip == true,function(e) if MD.setNoclip then MD.setNoclip(e) end; MD.sendNotification("Noclip",e and "On" or "Off",2) end},
                {"toggle","Infinite Jump",Settings.Movement.InfiniteJump == true,function(e) if MD.setInfiniteJump then MD.setInfiniteJump(e) end; MD.sendNotification("Inf Jump",e and "On" or "Off",2) end},
                {"toggle","Click TP",Settings.Movement.ClickTP == true,function(e) if MD.setClickTP then MD.setClickTP(e) end; MD.sendNotification("Click TP",e and "Hold Alt + click" or "Off",2) end},
                {"info","Noclip = V | Click TP = hold Alt + LMB (rebind in Settings)",Theme.TextDim},
            })
            if MW.allows("autoTp") then
                local tpModes = {"Nearest Enemy","Lowest HP","Highest HP","Furthest Enemy"}
                for _, plr in ipairs(S.Players:GetPlayers()) do
                    if plr ~= player then table.insert(tpModes, plr.DisplayName) end
                end
                addCard(page,1,"Auto TP",{
                    {"info","Risky - may cause ban",Theme.WarnColor},
                    {"toggle","Auto TP Loop",Settings.Misc.AutoTPLoop,function(e) Settings.Misc.AutoTPLoop=e; if e then MD.startAutoTPLoop(); MD.sendNotification("Auto TP","On - "..tostring(Settings.Misc.AutoTPTargetName),2) else MD.stopAutoTPLoop(); MD.sendNotification("Auto TP","Off",2) end end},
                    {"enum","TP Target",tpModes,Settings.Misc.AutoTPTargetName or "Nearest Enemy",function(v) Settings.Misc.AutoTPTargetName=v; MD.sendNotification("TP Target",v,2) end},
                    {"slider","TP Delay (s)",0.05,2,Settings.Misc.AutoTPLoopDelay,function(v) Settings.Misc.AutoTPLoopDelay=v end},
                    {"info","Reopen General to refresh player list in TP Target.",Theme.TextDim},
                })
            end
            if MW.allows("universalWorld") then
                local cpCount = 0
                pcall(function()
                    if MD.scanCheckpoints then cpCount = #MD.scanCheckpoints() end
                end)
                addCard(page,1,"Universal World",{
                    {"info","Mode: "..tostring(MW.mode)..": checkpoints, spawn, Auto Obby",Theme.TextAccent},
                    {"info","Checkpoints found: "..tostring(cpCount),Theme.TextDim},
                    {"toggle","Auto Obby",Settings.Misc.AutoObby == true,function(e)
                        if e then
                            if MD.startAutoObby then MD.startAutoObby() end
                        elseif MD.stopAutoObby then
                            MD.stopAutoObby()
                        end
                        MD.sendNotification("Auto Obby",e and "On" or "Off",2)
                    end},
                    {"slider","Obby Delay (s)",0.1,2,Settings.Misc.AutoObbyDelay or 0.35,function(v) Settings.Misc.AutoObbyDelay=v end},
                    {"toggle","Loop Obby",Settings.Misc.AutoObbyLoop == true,function(e) Settings.Misc.AutoObbyLoop=e end},
                    {"button","Rescan Checkpoints",function()
                        local n = 0
                        pcall(function() n = #MD.scanCheckpoints() end)
                        MD.sendNotification("Checkpoints", tostring(n).." found", 2)
                    end},
                    {"button","TP Next Checkpoint",function() if MD.tpNextCheckpoint then MD.tpNextCheckpoint() end end},
                    {"button","TP to Spawn",function() if MD.tpToSpawn then MD.tpToSpawn() end end},
                })
            end
            if MW.allows("brookhaven") then
                local locs = MD.BH_LOCATIONS or {"Hospital","School","Mall","Airport","Bank","Police","Motel"}
                local locNames = {}
                for _, n in ipairs(locs) do table.insert(locNames, n) end
                local plrNames = {"(none)"}
                for _, plr in ipairs(S.Players:GetPlayers()) do
                    if plr ~= player then table.insert(plrNames, plr.DisplayName) end
                end
                local selLoc = locNames[1] or "Hospital"
                local selPlr = plrNames[1]
                addCard(page,1,"Brookhaven RP",{
                    {"info","RP kit: client/HRP safe. Local invis is client-only.",Theme.TextAccent},
                    {"enum","Location",locNames,selLoc,function(v) selLoc=v end},
                    {"button","TP to Location",function() if MD.tpBrookhavenLocation then MD.tpBrookhavenLocation(selLoc) end end},
                    {"enum","Player",plrNames,selPlr,function(v) selPlr=v end},
                    {"button","TP to Player",function() if selPlr~="(none)" and MD.tpToPlayerByName then MD.tpToPlayerByName(selPlr) end end},
                    {"button","Bring Player",function() if selPlr~="(none)" and MD.bringPlayerByName then MD.bringPlayerByName(selPlr) end end},
                    {"toggle","Vehicle Speed",Settings.Movement.VehicleSpeed == true,function(e) if MD.setVehicleSpeed then MD.setVehicleSpeed(e) end; MD.sendNotification("Vehicle Speed",e and "On" or "Off",2) end},
                    {"slider","Vehicle Mul",1,5,Settings.Movement.VehicleSpeedMul or 2,function(v) Settings.Movement.VehicleSpeedMul=v end},
                    {"toggle","Local Invis",Settings.Movement.LocalInvis == true,function(e) if MD.applyLocalInvis then MD.applyLocalInvis(e) end; MD.sendNotification("Local Invis",e and "On (client)" or "Off",2) end},
                    {"button","Sit",function() if MD.forceSit then MD.forceSit(true) end end},
                    {"button","Unsit",function() if MD.forceSit then MD.forceSit(false) end end},
                    {"info","Reopen General to refresh player list.",Theme.TextDim},
                })
            end
        addCard(page,2,"Visuals",{
            {"toggle","Fullbright",Settings.Visuals.Fullbright,function(e) Settings.Visuals.Fullbright=e; if e then S.Lighting.Ambient=Color3.fromRGB(255,255,255); S.Lighting.Brightness=2; S.Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255) else S.Lighting.Ambient=Color3.fromRGB(127,127,127); S.Lighting.Brightness=1; S.Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127); MD.applyWorldLighting() end end},
            {"toggle","No Fog",Settings.Visuals.NoFog,function(e) Settings.Visuals.NoFog=e; if e then MD.enableNoFog() else MD.disableNoFog() end end},
            {"toggle","Custom FOV",Settings.Visuals.CustomFOV,function(e) Settings.Visuals.CustomFOV=e; local cam=S.Workspace.CurrentCamera; if cam then cam.FieldOfView=e and Settings.Visuals.FOVAmount or 70 end end},
            {"slider","FOV Amount",30,300,Settings.Visuals.FOVAmount,function(v) Settings.Visuals.FOVAmount=v; if Settings.Visuals.CustomFOV then local cam=S.Workspace.CurrentCamera; if cam then cam.FieldOfView=v end end end},
            {"toggle","Show FPS",Settings.Visuals.ShowFPS,function(e) Settings.Visuals.ShowFPS=e end},
            {"toggle","Show Velocity",Settings.Visuals.ShowVelocity,function(e) Settings.Visuals.ShowVelocity=e end},
            {"toggle","Visual VSync",Settings.Visuals.VSync,function(e) Settings.Visuals.VSync=e; for k in pairs(MD.espBoundsCache) do MD.espBoundsCache[k]=nil end; MD.sendNotification("Visual VSync",e and "ESP syncs to your FPS" or "Fixed visual rate",2) end},
            {"toggle","VSync Lock",Settings.Visuals.VSyncLock,function(e) Settings.Visuals.VSyncLock=e; MD.sendNotification("VSync Lock",e and "Auto-disables heavy visuals when FPS drops" or "Off",2) end},
            {"slider","Lock Medium FPS",30,70,Settings.Visuals.VSyncLockMedium or 50,function(v) Settings.Visuals.VSyncLockMedium=v end},
            {"slider","Lock Low FPS",20,50,Settings.Visuals.VSyncLockLow or 35,function(v) Settings.Visuals.VSyncLockLow=v end},
            {"info","VSync Lock pauses chams, skeleton, glow, and more when FPS is low.",Theme.TextDim},
        })
        addCard(page,2,"World S.Lighting",{
            {"toggle","Custom Brightness",Settings.Visuals.CustomBrightness,function(e) Settings.Visuals.CustomBrightness=e; MD.applyWorldLighting() end},
            {"slider","Brightness",0,500,math.floor(Settings.Visuals.Brightness*100),function(v) Settings.Visuals.Brightness=v/100; if Settings.Visuals.CustomBrightness then S.Lighting.Brightness=Settings.Visuals.Brightness end end},
            {"toggle","Custom Time",Settings.Visuals.CustomTime,function(e) Settings.Visuals.CustomTime=e; MD.applyWorldLighting() end},
            {"slider","Clock Time",0,2400,math.floor(Settings.Visuals.ClockTime*100),function(v) Settings.Visuals.ClockTime=v/100; if Settings.Visuals.CustomTime then S.Lighting.ClockTime=Settings.Visuals.ClockTime end end},
            {"toggle","Custom Exposure",Settings.Visuals.CustomExposure,function(e) Settings.Visuals.CustomExposure=e; MD.applyWorldLighting() end},
            {"slider","Exposure",-500,500,math.floor(Settings.Visuals.Exposure*100),function(v) Settings.Visuals.Exposure=v/100; if Settings.Visuals.CustomExposure then S.Lighting.ExposureCompensation=Settings.Visuals.Exposure end end},
        })
        addCard(page,1,"Third Person",{
            {"toggle","Enable Third Person",Settings.Visuals.ThirdPerson,function(e) Settings.Visuals.ThirdPerson=e; if not e then local cam=S.Workspace.CurrentCamera; if cam and origCameraType then cam.CameraType=origCameraType; origCameraType=nil end end; MD.sendNotification("Third Person",e and "On" or "Off",2) end},
            {"slider","Camera Distance",4,20,Settings.Visuals.ThirdPersonDistance or 10,function(v) Settings.Visuals.ThirdPersonDistance=v end},
            {"info","Disabled while aimbot is tracking.",Theme.TextDim},
        })
        if MW.allows("gunmods") then
        addCard(page,2,"Viewmodel",{
            {"toggle","Viewmodel FOV",Settings.Visuals.ViewmodelFOVEnabled,function(e) Settings.Visuals.ViewmodelFOVEnabled=e end},
            {"slider","VM FOV",40,120,Settings.Visuals.ViewmodelFOV or 70,function(v) Settings.Visuals.ViewmodelFOV=v end},
            {"slider","VM Offset Y",-50,50,Settings.Visuals.ViewmodelOffsetY or 0,function(v) Settings.Visuals.ViewmodelOffsetY=v; MD.applyViewmodelSettings() end},
            {"toggle","Reduce Sway",Settings.Visuals.ViewmodelSwayReduce,function(e) Settings.Visuals.ViewmodelSwayReduce=e; MD.applyViewmodelSettings() end},
        })
        addCard(page,1,"Gun Wireframe",{
            {"info","Edge wires + glow on your gun / viewmodel.",Theme.TextDim},
            {"toggle","Enabled",Settings.Visuals.GunWireframeEnabled,function(e) Settings.Visuals.GunWireframeEnabled=e; if not e then MD.clearGunWireframe() else MD.updateGunWireframe() end; MD.sendNotification("Gun Wireframe",e and "On" or "Off",2) end},
            {"enum","Style",{"Wireframe","Outline","Glass","Neon"},Settings.Visuals.GunWireframeStyle or "Wireframe",function(v) Settings.Visuals.GunWireframeStyle=v; MD.clearGunWireframe(); MD.updateGunWireframe() end},
            {"enum","Color",{"Accent","Cyan","Magenta","Lime","White","Red"},Settings.Visuals.GunWireframeColorPreset or "Accent",function(v) Settings.Visuals.GunWireframeColorPreset=v; MD.updateGunWireframe() end},
            {"slider","Line Thickness",3,16,math.floor((Settings.Visuals.GunWireframeThickness or 0.07)*100),function(v) Settings.Visuals.GunWireframeThickness=v/100; MD.updateGunWireframe() end},
            {"slider","Shell Fade",50,95,math.floor((Settings.Visuals.GunWireframePartTransparency or 0.88)*100),function(v) Settings.Visuals.GunWireframePartTransparency=v/100; MD.updateGunWireframe() end},
        })
        if MW.gunModsInTesting then
            addCard(page,2,"Gun Mods",{
                {"info","IN TESTING",Theme.WarnColor or Theme.TextAccent},
                {"info","ACS gun mods are not wired yet on MiscGunTest.",Theme.TextDim},
            })
        else
        addCard(page,2,"Gun Mods",{
            {"info","Hooks ReplicatedStorage.Weapons + ammo values (Arsenal)",Theme.TextDim},
            {"toggle","Fast Reload",Settings.Combat.FastReload,function(e) Settings.Combat.FastReload=e; if e then MD.applyAllGunMods() else MD.restoreGunMod("ReloadTime"); MD.restoreGunMod("EReloadTime") end end, Cap.badge("gunmods")},
            {"toggle","Fast Fire Rate",Settings.Combat.FastFireRate,function(e) Settings.Combat.FastFireRate=e; if e then MD.applyAllGunMods() else MD.restoreGunMod("FireRate") end end, Cap.badge("gunmods")},
            {"toggle","Always Auto",Settings.Combat.AlwaysAuto,function(e) Settings.Combat.AlwaysAuto=e; if e then MD.applyAllGunMods() else MD.restoreGunMod("Auto") end end, Cap.badge("gunmods")},
            {"toggle","No Spread",Settings.Combat.NoSpread,function(e) Settings.Combat.NoSpread=e; if e then MD.applyAllGunMods() else MD.restoreGunMod("Spread") end end, Cap.badge("gunmods")},
            {"toggle","No Recoil",Settings.Combat.NoRecoil,function(e) Settings.Combat.NoRecoil=e; if e then MD.applyAllGunMods() else MD.restoreGunMod("Recoil") end end, Cap.badge("gunmods"),function() return Settings.Combat.NoRecoil end},
            {"toggle","Infinite Ammo",Settings.Combat.InfiniteAmmo,function(e)
                Settings.Combat.InfiniteAmmo=e
                if e then MD.applyInfiniteAmmo(); MD.sendNotification("Infinite Ammo","On",2)
                else MD.stopInfiniteAmmo(); MD.sendNotification("Infinite Ammo","Off",2) end
            end, Cap.badge("gunmods"),function() return Settings.Combat.InfiniteAmmo end},
        })
        end
        end
        addCard(page,2,"Misc",{
            {"toggle","Anti-AFK",Settings.Misc.AntiAFK,function(e) Settings.Misc.AntiAFK=e end},
            {"toggle","Auto Rejoin",Settings.Misc.AutoRejoin,function(e) Settings.Misc.AutoRejoin=e; MD.sendNotification("Auto Rejoin",e and "On, reconnects on kick/fail" or "Off",2) end},
            {"toggle","Streamer Mode",Settings.Misc.StreamerMode,function(e) Settings.Misc.StreamerMode=e; MD.applyStreamerPrivacy(); MD.sendNotification("Streamer Mode",e and "Names hidden" or "Off",2) end},
            {"toggle","Streamer Mode++",Settings.Misc.StreamerModePlus,function(e) Settings.Misc.StreamerModePlus=e; MD.applyStreamerPrivacy(); MD.sendNotification("Streamer Mode++",e and "Full privacy on" or "Off",2) end},
            {"toggle","Chat Spammer",Settings.Misc.ChatSpammer,function(e) Settings.Misc.ChatSpammer=e end},
            {"input","Spam Message",Settings.Misc.ChatSpamMessage or "Melo 🍃 on top",function(v) Settings.Misc.ChatSpamMessage=v end},
            {"toggle","Team Chat Only",Settings.Misc.ChatSpamTeamOnly == true,function(e) Settings.Misc.ChatSpamTeamOnly=e end},
            {"slider","Spam Delay (s)",0.5,10,Settings.Misc.ChatSpamDelay,function(v) Settings.Misc.ChatSpamDelay=v end},
            {"info","Uses game chat remotes / TextChat when available.",Theme.TextDim},
        })
        addCard(page,2,"Server",{
            {"button","Rejoin Server",function() pcall(function() S.TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,player) end) end},
            {"button","Server Hop",function() MD.FX.doServerHop() end},
            {"slider","Lobby Min Players",0,20,Settings.Misc.LobbyMinPlayers or 1,function(v) Settings.Misc.LobbyMinPlayers=v end},
            {"slider","Lobby Max Players",1,30,Settings.Misc.LobbyMaxPlayers or 12,function(v) Settings.Misc.LobbyMaxPlayers=v end},
            {"toggle","Auto Hop Until Match",Settings.Misc.AutoHopUntilMatch,function(e)
                Settings.Misc.AutoHopUntilMatch=e
                if e then MD.FX.startLobbyFinder(); MD.sendNotification("Lobby Finder","Hopping until player count matches",3)
                else MD.sendNotification("Lobby Finder","Off",2) end
            end, Cap.badge("http")},
            {"toggle","Lobby Alerts",Settings.Misc.LobbyAlertOnJoin ~= false,function(e) Settings.Misc.LobbyAlertOnJoin=e end},
            {"toggle","Anti-Cheat Alerts",Settings.Misc.AntiCheatAlerts ~= false,function(e) Settings.Misc.AntiCheatAlerts=e end},
        })
        addCard(page,2,"Webhooks",{
            {"toggle","Enable Webhooks",Settings.Webhook.Enabled,function(e) Settings.Webhook.Enabled=e; MD.sendNotification("Webhooks",e and "On" or "Off",2) end, Cap.badge("http")},
            {"input","Webhook URL","",function(v) MD._pendingWebhookUrl = v end},
            {"button","Add Webhook",function()
                local ok, err = MD.FX.addHook(MD._pendingWebhookUrl or "")
                if ok then MD.sendNotification("Webhook","Added ("..#Settings.Webhook.Hooks..")",2)
                else MD.sendNotification("Webhook", err == "exists" and "Already added" or "Invalid Discord webhook URL",3) end
            end},
            {"button","Remove Last",function()
                MD.FX.ensureHooks()
                local n = #Settings.Webhook.Hooks
                if n == 0 then MD.sendNotification("Webhook","None to remove",2); return end
                table.remove(Settings.Webhook.Hooks, n)
                MD.sendNotification("Webhook","Removed: "..#Settings.Webhook.Hooks.." left",2)
            end},
            {"button","Test Webhooks",function()
                Settings.Webhook.Enabled = true
                local sent = MD.FX.sendPayload(MD.FX.embed("Melo 🍃 webhook test","Routing bridge live for **"..player.Name.."**",5814783),"Test")
                MD.sendNotification("Webhook", sent > 0 and ("OK: "..sent.." sent") or "Failed / no hooks",3)
            end},
            {"button","Post Session K/D",function()
                Settings.Webhook.Enabled = true
                MD.FX.sendPayload(MD.FX.embed("Session K/D","**"..MD.FX.kdText().."**\nWins: "..MD.FX.session.wins,3447003),"KD")
                MD.sendNotification("Webhook","K/D posted",2)
            end},
            {"toggle","Route Kills",true,function(e) MD.FX.ensureHooks(); for _,h in ipairs(Settings.Webhook.Hooks) do h.Kills=e end end},
            {"toggle","Route Wins",true,function(e) MD.FX.ensureHooks(); for _,h in ipairs(Settings.Webhook.Hooks) do h.Wins=e end end},
            {"toggle","Route KD",true,function(e) MD.FX.ensureHooks(); for _,h in ipairs(Settings.Webhook.Hooks) do h.KD=e end end},
            {"toggle","Route Lobby",true,function(e) MD.FX.ensureHooks(); for _,h in ipairs(Settings.Webhook.Hooks) do h.Lobby=e end end},
            {"toggle","Route AntiCheat",true,function(e) MD.FX.ensureHooks(); for _,h in ipairs(Settings.Webhook.Hooks) do h.AntiCheat=e end end},
            {"info","Paste Discord webhook URL, focus out, then Add. Route toggles apply to all hooks.",Theme.TextDim},
        })
    end
    tabBuilders["Aimbot"] = function(page)

        if MW.allows("mm2") then
            addCard(page,1,"Murder Mystery 2",{
                {"info","Role ESP, farm, sheriff tools. Other game kits hidden.",Theme.TextDim},
                {"toggle","Role Name ESP",Settings.MM2.NameESP ~= false,function(e)
                    Settings.MM2.NameESP=e
                    if MD.TraceMM2 and MD.TraceMM2.refreshESP then MD.TraceMM2.refreshESP() end
                end,nil,function() return Settings.MM2.NameESP ~= false end},
                {"toggle","Player Chams",Settings.MM2.PlayerChams == true,function(e)
                    Settings.MM2.PlayerChams=e
                    if MD.TraceMM2 then if e then MD.TraceMM2.refreshChams() else MD.TraceMM2.clearChams() end end
                end},
                {"toggle","Gun Drop ESP",Settings.MM2.GunESP ~= false,function(e)
                    Settings.MM2.GunESP=e
                    if MD.TraceMM2 then if e then MD.TraceMM2.refreshGunEsp() else MD.TraceMM2.clearGunEsp() end end
                end,nil,function() return Settings.MM2.GunESP ~= false end},
                {"toggle","Silent Aim",Settings.MM2.SilentAim ~= false,function(e) Settings.MM2.SilentAim=e end,nil,function() return Settings.MM2.SilentAim ~= false end},
                {"toggle","Auto Shoot Murderer",Settings.MM2.AutoShootMurderer == true,function(e) Settings.MM2.AutoShootMurderer=e end},
                {"toggle","Kill Murderer Blatant",Settings.MM2.KillMurdererBlatant == true,function(e) Settings.MM2.KillMurdererBlatant=e end},
                {"button","Shoot Murderer Now",function() if MD.TraceMM2 then MD.TraceMM2.shootMurderer(true) end end},
            })
            addCard(page,2,"Farm / Combat",{
                {"toggle","Auto Farm Coins",Settings.MM2.AutoFarm == true,function(e)
                    Settings.MM2.AutoFarm=e
                    if e and MD.TraceMM2 then MD.TraceMM2.farmLoop() end
                end},
                {"enum","Farm Mode",{"Nearest","Randomize","Furthest","Safe Nearby"},Settings.MM2.FarmMode or "Nearest",function(v) Settings.MM2.FarmMode=v end},
                {"slider","Farm Delay",10,100,math.floor((Settings.MM2.FarmDelay or 0.35)*100),function(v) Settings.MM2.FarmDelay=v/100 end},
                {"toggle","Kill Aura",Settings.MM2.KillAura == true,function(e) Settings.MM2.KillAura=e end},
                {"slider","Aura Distance",1,30,Settings.MM2.AuraDistance or 5,function(v) Settings.MM2.AuraDistance=v end},
                {"toggle","Auto Kill All",Settings.MM2.AutoKillAll == true,function(e) Settings.MM2.AutoKillAll=e end},
                {"toggle","Anti AFK",Settings.MM2.AntiAFK ~= false,function(e) Settings.MM2.AntiAFK=e end,nil,function() return Settings.MM2.AntiAFK ~= false end},
                {"toggle","Anti Fling",Settings.MM2.AntiFling ~= false,function(e) Settings.MM2.AntiFling=e end,nil,function() return Settings.MM2.AntiFling ~= false end},
            })
            page.CanvasSize=UDim2.new(0,0,0,pageMaxY(page))
            return
        end
        if not MW.allows("aim") then
            addCard(page,1,"Combat",{
                {"info","Aim kit not enabled here. Mode: "..tostring(MW.mode),Theme.TextDim},
            })
            page.CanvasSize=UDim2.new(0,0,0,pageMaxY(page))
            return
        end

        if MW.allows("phantomforces") then
            addCard(page,1,"Phantom Forces",{
                {"info","Ghosts orange / Phantoms blue. Only PF settings on this kit.",Theme.TextDim},
                {"toggle","Silent Aim",Settings.PF.SilentAim ~= false,function(e)
                    Settings.PF.SilentAim=e
                    if e and MD.TracePF and MD.TracePF.reinstallSilent then MD.TracePF.reinstallSilent() end
                end,nil,function() return Settings.PF.SilentAim ~= false end},
                {"enum","Silent Method",{"FireRound","Network","Auto"},Settings.PF.SilentMethod or "FireRound",function(v)
                    Settings.PF.SilentMethod=v
                    if MD.TracePF and MD.TracePF.reinstallSilent then MD.TracePF.reinstallSilent() end
                end},
                {"slider","Silent FOV",40,600,Settings.PF.SilentFOV or 220,function(v)
                    Settings.PF.SilentFOV=v; Settings.Aimbot.SilentFOVRadius=v
                end},
                {"toggle","Silent FOV Only",Settings.PF.SilentFOVOnly ~= false,function(e) Settings.PF.SilentFOVOnly=e end,nil,function() return Settings.PF.SilentFOVOnly ~= false end},
                {"slider","Hit Chance",1,100,Settings.PF.HitChance or 100,function(v) Settings.PF.HitChance=v end},
                {"slider","Head Chance",0,100,Settings.PF.HeadChance or 70,function(v) Settings.PF.HeadChance=v end},
                {"toggle","Predict Velocity",Settings.PF.Predict ~= false,function(e) Settings.PF.Predict=e end,nil,function() return Settings.PF.Predict ~= false end},
                {"toggle","Team Colors",Settings.PF.TeamColors ~= false,function(e) Settings.PF.TeamColors=e end,nil,function() return Settings.PF.TeamColors ~= false end},
                {"toggle","Soft No Recoil",Settings.PF.SoftNoRecoil == true,function(e) Settings.PF.SoftNoRecoil=e end},
                {"toggle","Soft No Spread",Settings.PF.SoftNoSpread == true,function(e) Settings.PF.SoftNoSpread=e end},
                {"toggle","Weapon Labels",Settings.PF.WeaponLabels ~= false,function(e) Settings.PF.WeaponLabels=e; Settings.ESP.WeaponLabels=e end},
                {"button","Refresh / Rehook Silent",function()
                    if not MD.TracePF then return end
                    MD.TracePF.repl=nil; MD.TracePF.entries=nil; MD.TracePF.pfRequire=nil
                    MD.TracePF.network=nil; MD.TracePF.bulletObject=nil
                    MD.TracePF.firearmObject=nil; MD.TracePF.characterObject=nil
                    MD.TracePF.cache={}
                    MD.TracePF.refreshModules()
                    if MD.TracePF.reinstallSilent then MD.TracePF.reinstallSilent() end
                    MD.sendNotification("PF", tostring(MD.TracePF.status).." / silent "..tostring(MD.TracePF.silentStatus), 3)
                end},
            })
            addCard(page,1,"Camera Aim",{
                {"toggle","Enabled",Settings.Aimbot.Enabled,function(e) Settings.Aimbot.Enabled=e; Settings.Aimbot.AimMode="Camera"; SilentHB.refresh() end,nil,function() return Settings.Aimbot.Enabled end},
                {"toggle","Sticky Aim",Settings.Aimbot.StickyAim,function(e) Settings.Aimbot.StickyAim=e end,nil,function() return Settings.Aimbot.StickyAim end},
                {"toggle","Toggle Mode (RMB)",Settings.Aimbot.Toggle,function(e) Settings.Aimbot.Toggle=e end,nil,function() return Settings.Aimbot.Toggle end},
                {"toggle","Require LOS",Settings.Aimbot.RequireLOS,function(e) Settings.Aimbot.RequireLOS=e end,nil,function() return Settings.Aimbot.RequireLOS end},
                {"toggle","Prediction",Settings.Aimbot.Prediction,function(e) Settings.Aimbot.Prediction=e end,nil,function() return Settings.Aimbot.Prediction end},
                {"slider","Smoothness",1,100,math.floor(Settings.Aimbot.Smoothness*100),function(v) Settings.Aimbot.Smoothness=v/100 end},
                {"slider","Max Distance",100,1000,Settings.Aimbot.MaxDistance,function(v) Settings.Aimbot.MaxDistance=v end},
                {"enum","Lock Part",{"Head","Torso"},Settings.PF.PreferHead ~= false and "Head" or "Torso",function(v)
                    Settings.Aimbot.LockPart=v
                    Settings.PF.PreferHead=(v=="Head")
                    if MD.TracePF then MD.TracePF.cache={} end
                end},
            })
            addCard(page,2,"FOV / Trigger",{
                {"toggle","Show FOV",Settings.Aimbot.ShowFOV,function(e) Settings.Aimbot.ShowFOV=e end},
                {"slider","FOV Radius",50,500,Settings.Aimbot.FOVRadius,function(v) Settings.Aimbot.FOVRadius=v end},
                {"toggle","Show Silent FOV",Settings.PF.ShowSilentFOV ~= false,function(e) Settings.PF.ShowSilentFOV=e; Settings.Aimbot.ShowSilentFOV=e end,nil,function() return Settings.PF.ShowSilentFOV ~= false end},
                {"toggle","Trigger Bot",Settings.Combat.TriggerBot,function(e) Settings.Combat.TriggerBot=e end},
                {"slider","Trigger Delay ms",50,500,math.floor((Settings.Combat.TriggerDelay or 0.05)*1000),function(v) Settings.Combat.TriggerDelay=v/1000 end},
            })
            page.CanvasSize=UDim2.new(0,0,0,pageMaxY(page))
            return
        end
        if MW.guard("hitbox") then
            addCard(page,1,"Game AC",{
                {"info","MiscGunTest: Hitbox expand locked. Gun mods IN TESTING. Fly/speed on. TP/noclip blocked.",Theme.TextDim},
            })
        elseif MW.guard("pos") then
            addCard(page,1,"Game AC",{
                {"info","Pos AC active on this kit. Some movement exploits stay blocked.",Theme.TextDim},
            })
        end
        addCard(page,1,"Aimbot",{
            {"toggle","Enabled",Settings.Aimbot.Enabled,function(e) Settings.Aimbot.Enabled=e; Settings.Aimbot.AimMode="Camera"; SilentHB.refresh(); MD.sendNotification("Aimbot",e and "On" or "Off",2) end,nil,function() return Settings.Aimbot.Enabled end},
            {"enum","Aim Mode",{"Camera"},"Camera",function(v) Settings.Aimbot.AimMode="Camera"; SilentHB.refresh(); MD.sendNotification("Aim Mode", MW.isPF and "Camera (PF silent is separate)" or "Camera only (Silent locked)",2) end,function() return "Camera" end},
            {"info", MW.isPF and "PF silent aim is under Phantom Forces card (not Arsenal Aim Mode)" or "Silent Aim locked off for stability",Theme.TextDim},
            {"toggle","Toggle Mode (RMB)",Settings.Aimbot.Toggle,function(e) Settings.Aimbot.Toggle=e end,nil,function() return Settings.Aimbot.Toggle end},
            {"toggle","Require LOS",Settings.Aimbot.RequireLOS,function(e) Settings.Aimbot.RequireLOS=e end,nil,function() return Settings.Aimbot.RequireLOS end},
            {"toggle","Prediction",Settings.Aimbot.Prediction,function(e) Settings.Aimbot.Prediction=e end,nil,function() return Settings.Aimbot.Prediction end},
            {"toggle","Multi-Target Cycle",Settings.Aimbot.MultiTarget,function(e) Settings.Aimbot.MultiTarget=e end,nil,function() return Settings.Aimbot.MultiTarget end},
            {"toggle","Sticky Aim",Settings.Aimbot.StickyAim,function(e) Settings.Aimbot.StickyAim=e; MD.sendNotification("Sticky Aim",e and "On" or "Off",2) end,nil,function() return Settings.Aimbot.StickyAim end},
            {"info", MW.isPF and "Camera aim snaps view. Silent redirects bullets without snap." or "Aim Mode locked to Camera (Silent disabled)",Theme.TextDim},
        })
        addCard(page,1,"Aim Config",{
            {"enum","Smooth Profile",{"Legit","Semi","Rage","Custom"},Settings.Aimbot.SmoothProfile or "Custom",function(v) MD.applyAimSmoothProfile(v); MD.sendNotification("Aim Profile",v.." applied",2) end},
            {"button","Apply Legit Pack",function() if MD.applyConfigPack("Legit") then MD.sendNotification("Config Pack","Legit applied",3) end end},
            {"button","Apply Semi Pack",function() if MD.applyConfigPack("Semi") then MD.sendNotification("Config Pack","Semi applied",3) end end},
            {"button","Apply Rage Pack",function() if MD.applyConfigPack("Rage") then MD.sendNotification("Config Pack","Rage applied",3) end end},
            {"slider","Smoothness",1,100,math.floor(Settings.Aimbot.Smoothness*100),function(v) Settings.Aimbot.SmoothProfile="Custom"; Settings.Aimbot.Smoothness=v/100 end},
            {"slider","Prediction Amt",1,30,math.floor(Settings.Aimbot.PredictionAmount*100),function(v) Settings.Aimbot.SmoothProfile="Custom"; Settings.Aimbot.PredictionAmount=v/100 end},
            {"slider","Max Distance",100,1000,Settings.Aimbot.MaxDistance,function(v) Settings.Aimbot.MaxDistance=v end},
            {"enum","Lock Part",{"Head","HRP","UTorso","Torso"},"Head",function(v) local m={Head="Head",HRP="HumanoidRootPart",UTorso="UpperTorso",Torso="Torso"}; Settings.Aimbot.LockPart=m[v] or "Head"; for uid,_ in pairs(MD.rigCache) do MD.rigCache[uid]=nil end end},
            {"info","Packs set aim + gun mods. Smooth Profile only changes FOV/smooth/pred.",Theme.TextDim},
        })
        addCard(page,2,"FOV",{
            {"toggle","Show FOV Circle",Settings.Aimbot.ShowFOV,function(e) Settings.Aimbot.ShowFOV=e end},
            {"enum","FOV Style",{"Circle","Dots"},Settings.Aimbot.FOVStyle or "Circle",function(v) Settings.Aimbot.FOVStyle=v end},
            {"slider","FOV Radius",50,500,Settings.Aimbot.FOVRadius,function(v) Settings.Aimbot.SmoothProfile="Custom"; Settings.Aimbot.FOVRadius=v end},
            {"slider","FOV Opacity",0,100,math.floor(Settings.Aimbot.FOVOpacity*100),function(v) Settings.Aimbot.FOVOpacity=v/100 end},
            {"slider","FOV Dots",4,32,Settings.Aimbot.FOVDots or 12,function(v) Settings.Aimbot.FOVDots=v end},
        })
        addCard(page,1,"Target Priority",{
            {"enum","Priority",{"Closest","LowestHP","Crosshair","Threat"},Settings.Aimbot.TargetPriority or "Crosshair",function(v) Settings.Aimbot.TargetPriority=v; MD.sendNotification("Priority",v,1.5) end},
            {"slider","Multipoint Weight",5,100,math.floor((Settings.Aimbot.MultipointWeight or 0.55)*100),function(v) Settings.Aimbot.MultipointWeight=v/100 end},
            {"enum","Sticky Profile",{"Glue","Soft","Flick","HybridHold","Release"},"HybridHold",function(v) if MD.applyStickyProfile then MD.applyStickyProfile(v) end; MD.sendNotification("Sticky",v,1.5) end},
            {"info","Closest=world | LowestHP=health | Crosshair=screen | Threat=mix",Theme.TextDim},
        })
        if MW.allows("gunmods") then
        addCard(page,2,"Gun Profiles",{
            {"enum","Profile",{"Custom","LegitLite","SemiComp","RagePack","Arena","Scout","SlotA","SlotB"},Settings.Combat.GunProfile or "Custom",function(v) local ok,err=MD.applyGunProfile and MD.applyGunProfile(v); MD.sendNotification("Gun Profile", ok~=false and v or tostring(err or "locked"),2) end},
            {"button","Capture Slot A",function() if not Cap.ok("gunmods") then MD.sendNotification("Gun Profile", Cap.badge("gunmods") or "locked",2); return end; if MD.captureGunSlotA then MD.captureGunSlotA(); MD.sendNotification("Gun Profile","Slot A saved",2) end end},
            {"button","Capture Slot B",function() if not Cap.ok("gunmods") then MD.sendNotification("Gun Profile", Cap.badge("gunmods") or "locked",2); return end; if MD.captureGunSlotB then MD.captureGunSlotB(); MD.sendNotification("Gun Profile","Slot B saved",2) end end},
            {"info","Named packs flip Cap-gated gun mods. Custom leaves current values.",Theme.TextDim},
        })
        end
        addCard(page,2,"Trigger Bot",{
            {"toggle","Enabled",Settings.Combat.TriggerBot,function(e) Settings.Combat.TriggerBot=e; MD.sendNotification("Trigger Bot",e and "On" or "Off",2) end},
            {"slider","Delay (ms)",50,500,math.floor((Settings.Combat.TriggerDelay or 0.2)*1000),function(v) Settings.Combat.TriggerDelay=v/1000 end},
            {"slider","Delay Jitter",0,100,math.floor((Settings.Combat.TriggerJitter or 0)*100),function(v) Settings.Combat.TriggerJitter=v/100 end},
            {"toggle","Require LOS",Settings.Combat.TriggerRequireLOS,function(e) Settings.Combat.TriggerRequireLOS=e end},
            {"toggle","Head Only",Settings.Combat.TriggerHeadOnly,function(e) Settings.Combat.TriggerHeadOnly=e end},
            {"toggle","ADS Only",Settings.Combat.TriggerRequireADS,function(e) Settings.Combat.TriggerRequireADS=e; MD.sendNotification("Trigger ADS",e and "On" or "Off",2) end},
            {"slider","Burst Count",1,8,Settings.Combat.TriggerBurstCount or 1,function(v) Settings.Combat.TriggerBurstCount=v end},
            {"slider","Burst Gap (ms)",20,250,math.floor((Settings.Combat.TriggerBurstGap or 0.06)*1000),function(v) Settings.Combat.TriggerBurstGap=v/1000 end},
            {"input","Weapon Blacklist",Settings.Combat.TriggerWeaponBlacklist or "",function(v) Settings.Combat.TriggerWeaponBlacklist=v end},
            {"info","ADS = Mouse2 / scoped FOV. Blacklist = comma-separated weapon names. Burst>1 uses clicks.",Theme.TextDim},
        })
        if MW.allows("rage") then
        addCard(page,1,"Rage Bot",{
            {"info","Risky, teleports and shoots all enemies.",Theme.WarnColor},
            {"toggle","Enabled",Settings.Combat.RageBot,function(e)
                Settings.Combat.RageBot=e
                if e then MD.stopAutoTPLoop(); rageRunning=false; MD.startRageBot(); MD.sendNotification("Rage Bot","On",2)
                else MD.stopRageBot(); MD.sendNotification("Rage Bot","Off",2) end
            end},
            {"slider","Cycle Delay (ms)",50,500,math.floor((Settings.Combat.RageDelay or 0.12)*1000),function(v) Settings.Combat.RageDelay=v/1000 end},
            {"slider","TP Distance",2,8,Settings.Combat.RageTPDistance or 4,function(v) Settings.Combat.RageTPDistance=v end},
            {"toggle","Auto Shoot",Settings.Combat.RageShoot,function(e) Settings.Combat.RageShoot=e end},
            {"enum","Cycle Mode",{"Nearest","LowestHP","Furthest"},Settings.Combat.RageCycleMode or "Nearest",function(v) Settings.Combat.RageCycleMode=v end},
            {"slider","Shoot Bursts",1,20,Settings.Combat.RageShootBursts or 6,function(v) Settings.Combat.RageShootBursts=v end},
        })
        end
    end
    tabBuilders["ESP"] = function(page)
        addCard(page,2,"ESP Colors",{
            {"toggle","Link ESP to Accent",Settings.ESP.LinkToAccent ~= false,function(e) Settings.ESP.LinkToAccent=e; if applyEspPalette then applyEspPalette() end; if applyCustomTheme then applyCustomTheme() end end},
            {"button","Open Color Table",function() if UILib.openColorTable then UILib.openColorTable(true) end end},
            {"info","Edit ESP hex rows in the Color Table. Unlink Accent for custom distance colors.",Theme.TextDim},
        })
        addCard(page,2,"ESP Style Packs",{
            {"button","Apply Clean",function() if MD.TracePack then MD.TracePack.applyESPStyle("Clean") end; MD.sendNotification("ESP","Clean",1.5) end},
            {"button","Apply Full",function() if MD.TracePack then MD.TracePack.applyESPStyle("Full") end; MD.sendNotification("ESP","Full",1.5) end},
            {"button","Apply Ghost",function() if MD.TracePack then MD.TracePack.applyESPStyle("Ghost") end; MD.sendNotification("ESP","Ghost",1.5) end},
            {"button","Apply Arena",function() if MD.TracePack then MD.TracePack.applyESPStyle("Arena") end; MD.sendNotification("ESP","Arena",1.5) end},
            {"button","Apply Minimal",function() if MD.TracePack then MD.TracePack.applyESPStyle("Minimal") end; MD.sendNotification("ESP","Minimal",1.5) end},
            {"button","Apply Scout",function() if MD.TracePack then MD.TracePack.applyESPStyle("Scout") end; MD.sendNotification("ESP","Scout",1.5) end},
            {"info","Style packs flip common ESP toggles in one click.",Theme.TextDim},
        })
        local function bumpESPDraw()
            VisPerf.lastOverlay = 0
            VisPerf.lastHeavy = 0
            VisPerf.lastMisc = 0
        end
        local function ensureESPMaster()
            if not Settings.ESP.Enabled then
                Settings.ESP.Enabled = true
                if MD.runUiSync then MD.runUiSync() end
            end
            bumpESPDraw()
        end
        local function setArcStrength(v)
            local m = {
                Low = {48, 16, 16},
                Normal = {72, 24, 22},
                High = {96, 32, 28},
                Max = {120, 48, 36},
            }
            local p = m[v] or m.Normal
            Settings.ESP.ThrowableArcPower = p[1]
            Settings.ESP.ThrowableArcLift = p[2]
            Settings.ESP.ThrowableArcSegments = p[3]
            Settings.ESP.ArcStrength = v
            bumpESPDraw()
        end
        local function getArcStrength()
            if Settings.ESP.ArcStrength then return Settings.ESP.ArcStrength end
            local p = Settings.ESP.ThrowableArcPower or 72
            if p <= 55 then return "Low" elseif p <= 80 then return "Normal" elseif p <= 105 then return "High" else return "Max" end
        end
        local function setArrowRange(v)
            local m = {Near=200, Mid=500, Far=1000}
            Settings.ESP.ArrowDistance = m[v] or 500
            Settings.ESP.ArrowRangePreset = v
            bumpESPDraw()
        end
        local function getArrowRange()
            if Settings.ESP.ArrowRangePreset then return Settings.ESP.ArrowRangePreset end
            local d = Settings.ESP.ArrowDistance or 500
            if d <= 250 then return "Near" elseif d <= 650 then return "Mid" else return "Far" end
        end
        local function setThrowRange(v)
            local m = {Near=120, Mid=250, Far=450}
            Settings.ESP.ThrowableMaxDistance = m[v] or 250
            Settings.ESP.ThrowRangePreset = v
            bumpESPDraw()
        end
        local function getThrowRange()
            if Settings.ESP.ThrowRangePreset then return Settings.ESP.ThrowRangePreset end
            local d = Settings.ESP.ThrowableMaxDistance or 250
            if d <= 160 then return "Near" elseif d <= 320 then return "Mid" else return "Far" end
        end
        addCard(page,1,"ESP",{
                {"toggle","Enabled",Settings.ESP.Enabled,function(e) Settings.ESP.Enabled=e; bumpESPDraw(); if not e then MD.clearAllESP() end; MD.sendNotification("ESP",e and "On" or "Off",2) end,nil,function() return Settings.ESP.Enabled end},
                {"toggle","Self ESP",Settings.ESP.SelfESP,function(e) Settings.ESP.SelfESP=e; bumpESPDraw() end,nil,function() return Settings.ESP.SelfESP end},
                {"toggle","Visible Check",Settings.ESP.VisibleCheck,function(e) Settings.ESP.VisibleCheck=e; bumpESPDraw() end,nil,function() return Settings.ESP.VisibleCheck end},
                {"slider","Render Distance",500,10000,Settings.ESP.RenderDistance,function(v) Settings.ESP.RenderDistance=v end},
                {"enum","Box Style",{"Off","2D","3D","Both"},Settings.ESP.BoxStyle or "2D",function(v) Settings.ESP.BoxStyle=v; Settings.ESP.BoxEnabled=(v~="Off"); bumpESPDraw(); if v=="Off" then MD.clearAllESP() end end,function() return Settings.ESP.BoxStyle or "2D" end},
                {"toggle","Names",Settings.ESP.NameEnabled,function(e) Settings.ESP.NameEnabled=e; bumpESPDraw() end,nil,function() return Settings.ESP.NameEnabled end},
                {"toggle","Distance",Settings.ESP.DistanceEnabled,function(e) Settings.ESP.DistanceEnabled=e; bumpESPDraw() end,nil,function() return Settings.ESP.DistanceEnabled end},
                {"toggle","Health Bar",Settings.ESP.HealthBar,function(e) Settings.ESP.HealthBar=e; bumpESPDraw() end,nil,function() return Settings.ESP.HealthBar end},
                {"toggle","Chams",Settings.ESP.ChamsEnabled,function(e) Settings.ESP.ChamsEnabled=e; bumpESPDraw(); MD.sendNotification("Chams",e and "On" or "Off",2) end,nil,function() return Settings.ESP.ChamsEnabled end},
                {"toggle","Outline",Settings.ESP.OutlineEnabled,function(e) Settings.ESP.OutlineEnabled=e; bumpESPDraw() end,nil,function() return Settings.ESP.OutlineEnabled end},
                {"toggle","Auto FFA / Team Detect",Settings.ESP.AutoTeamDetect,function(e) Settings.ESP.AutoTeamDetect=e; lastDetectedMatchMode=nil; MD.refreshMatchModeDetect(true); MD.sendNotification("Auto Detect",e and "On" or "Off",2) end,nil,function() return Settings.ESP.AutoTeamDetect end},
                {"enum","Team Filter",{"Enemy","Team","All"},"Enemy",function(v) local m={Enemy="Enemies",Team="Team",All="All"}; Settings.ESP.FilterMode=m[v] or "Enemies"; bumpESPDraw() end},
            })
            addCard(page,2,"Extras",{
                {"toggle","Tracers",Settings.ESP.TracerEnabled,function(e)
                    Settings.ESP.TracerEnabled=e
                    if e then ensureESPMaster() else bumpESPDraw() end
                end,nil,function() return Settings.ESP.TracerEnabled end},
                {"enum","Tracer Origin",{"Top","Mouse","Center","Bottom"},Settings.ESP.TracerOrigin or "Bottom",function(v) Settings.ESP.TracerOrigin=v; bumpESPDraw() end,function() return Settings.ESP.TracerOrigin or "Bottom" end},
                {"toggle","Skeleton",Settings.ESP.SkeletonEnabled,function(e)
                    Settings.ESP.SkeletonEnabled=e
                    if e then ensureESPMaster() else bumpESPDraw() end
                end,nil,function() return Settings.ESP.SkeletonEnabled end},
                {"toggle","Head Dot",Settings.ESP.HeadDotEnabled,function(e)
                    Settings.ESP.HeadDotEnabled=e
                    if e then ensureESPMaster() else bumpESPDraw() end
                end,nil,function() return Settings.ESP.HeadDotEnabled end},
                {"toggle","Offscreen Arrows",Settings.ESP.OffscreenArrows,function(e)
                    Settings.ESP.OffscreenArrows=e
                    if e then ensureESPMaster() else bumpESPDraw() end
                end,nil,function() return Settings.ESP.OffscreenArrows end},
                {"enum","Arrow Range",{"Near","Mid","Far"},getArrowRange(),function(v) setArrowRange(v) end,function() return getArrowRange() end},
                {"toggle","Throwable ESP",Settings.ESP.ThrowableEnabled,function(e)
                    Settings.ESP.ThrowableEnabled=e
                    bumpESPDraw()
                    if not e then MD.clearThrowableESP() end
                    MD.sendNotification("Throwable ESP",e and "On" or "Off",2)
                end,nil,function() return Settings.ESP.ThrowableEnabled end},
                {"enum","Throw Range",{"Near","Mid","Far"},getThrowRange(),function(v) setThrowRange(v) end,function() return getThrowRange() end},
                {"toggle","Throw Arc Preview",Settings.ESP.ThrowableArcPreview,function(e)
                    Settings.ESP.ThrowableArcPreview=e
                    bumpESPDraw()
                    if e and not Settings.ESP.ArcStrength then setArcStrength("Normal") end
                    if not e then MD.clearThrowableArcPreview() end
                end,nil,function() return Settings.ESP.ThrowableArcPreview end},
                {"enum","Arc Strength",{"Low","Normal","High","Max"},getArcStrength(),function(v) setArcStrength(v) end,function() return getArcStrength() end},
            })
    end

    tabBuilders["Radar"] = function(page)

    end

    local chatSpyGui = Instance.new("Frame")
    chatSpyGui.Name = MW_T.next(8)
    chatSpyGui.Size = UDim2.new(0, 280, 0, 160)
    chatSpyGui.Position = UDim2.new(0, 14, 0, 120)
    chatSpyGui.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    chatSpyGui.BackgroundTransparency = 0.18
    chatSpyGui.BorderSizePixel = 0
    chatSpyGui.Visible = false
    chatSpyGui.ZIndex = 20
    chatSpyGui.Parent = overlayLayer
    UILib.corner(chatSpyGui, 8)
    UILib.stroke(chatSpyGui, Theme.TextAccent, 1, 0.45)
    local chatSpyTitle = UILib.newLabel(chatSpyGui, {
        Size = UDim2.new(1, -12, 0, 18),
        Position = UDim2.new(0, 8, 0, 4),
        Text = "Chat Spy",
        TextColor3 = Theme.TextAccent,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 21,
    })
    local chatSpyList = Instance.new("ScrollingFrame")
    chatSpyList.Size = UDim2.new(1, -12, 1, -28)
    chatSpyList.Position = UDim2.new(0, 6, 0, 24)
    chatSpyList.BackgroundTransparency = 1
    chatSpyList.BorderSizePixel = 0
    chatSpyList.ScrollBarThickness = 3
    chatSpyList.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatSpyList.ZIndex = 21
    chatSpyList.Parent = chatSpyGui
    local chatSpyLayout = Instance.new("UIListLayout")
    chatSpyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    chatSpyLayout.Padding = UDim.new(0, 2)
    chatSpyLayout.Parent = chatSpyList
    local chatSpyLines = {}
    local function refreshChatSpyVisible()
        ensureUISettings()
        chatSpyGui.Visible = Settings.Misc.ChatSpyEnabled and Settings.Misc.ChatSpyOnScreen
    end
    local function pushChatSpyLine(name, msg)
        ensureUISettings()
        if not Settings.Misc.ChatSpyEnabled then return end
        local line = string.format("[%s] %s", tostring(name), tostring(msg))
        print("[CS] " .. line)
        if not Settings.Misc.ChatSpyOnScreen then return end
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -4, 0, 28)
        lbl.BackgroundTransparency = 1
        lbl.Text = line
        lbl.TextColor3 = Theme.TextSecondary
        lbl.TextSize = 10
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.TextWrapped = true
        lbl.ZIndex = 22
        lbl.Parent = chatSpyList
        table.insert(chatSpyLines, lbl)
        local maxLines = Settings.Misc.ChatSpyMaxLines or 40
        while #chatSpyLines > maxLines do
            local old = table.remove(chatSpyLines, 1)
            pcall(function() old:Destroy() end)
        end
        task.defer(function()
            chatSpyList.CanvasSize = UDim2.new(0, 0, 0, chatSpyLayout.AbsoluteContentSize.Y + 4)
            chatSpyList.CanvasPosition = Vector2.new(0, math.max(0, chatSpyList.CanvasSize.Y.Offset - chatSpyList.AbsoluteSize.Y))
        end)
        refreshChatSpyVisible()
    end
    refreshChatSpyVisible()
    _G[MW_T.chatSpyApi] = { refresh = refreshChatSpyVisible }
    tabBuilders["Report"] = function(page)
        addCard(page,1,"Chat Spy",{
            {"toggle","Enable Chat Spy",Settings.Misc.ChatSpyEnabled,function(e)
                Settings.Misc.ChatSpyEnabled=e
                refreshChatSpyVisible()
                sendNotification("Chat Spy",e and "Listening" or "Disabled",2)
            end,nil,function() return Settings.Misc.ChatSpyEnabled end},
            {"toggle","On-Screen Log",Settings.Misc.ChatSpyOnScreen,function(e)
                Settings.Misc.ChatSpyOnScreen=e
                refreshChatSpyVisible()
            end,nil,function() return Settings.Misc.ChatSpyOnScreen end},
            {"slider","Max Lines",10,80,Settings.Misc.ChatSpyMaxLines or 40,function(v) Settings.Misc.ChatSpyMaxLines=v end},
            {"info","Saved in configs. Logs to the on-screen panel + F9 console.",Theme.TextDim},
        })
        page.CanvasSize=UDim2.new(0,0,0,pageMaxY(page))
    end
    tabBuilders["Audio"] = function(page)
        ensureUISettings()
        if MW.allows("hitKillAudio") then
        addCard(page,1,"Sound Presets",{
            {"button","Hit: Classic",function() if TraceExpand then TraceExpand.applyHitSoundPreset("ClassicHit") end end},
            {"button","Hit: Metal",function() if TraceExpand then TraceExpand.applyHitSoundPreset("Metal") end end},
            {"button","Hit: Laser",function() if TraceExpand then TraceExpand.applyHitSoundPreset("Laser") end end},
            {"button","Kill: Heavy",function() if TraceExpand then TraceExpand.applyKillSoundPreset("Heavy") end end},
            {"button","Kill: Soft",function() if TraceExpand then TraceExpand.applyKillSoundPreset("Soft") end end},
            {"info","Presets write Audio IDs; test with buttons above.",Theme.TextDim},
        })
        addCard(page,1,"Hit & Kill Sounds",{
            {"toggle","Hit Sounds",Settings.Audio.HitSoundsEnabled,function(e) Settings.Audio.HitSoundsEnabled=e; MD.sendNotification("Hit Sounds",e and "On" or "Off",2) end},
            {"input","Hit Sound ID",Settings.Audio.HitSoundId or "",function(v) Settings.Audio.HitSoundId=v end},
            {"slider","Hit Volume",0,100,math.floor((Settings.Audio.HitVolume or 0.55)*100),function(v) Settings.Audio.HitVolume=v/100 end},
            {"button","Test Hit Sound",function() _G[MW_T.audioApi].playMwSound(Settings.Audio.HitSoundId, Settings.Audio.HitVolume) end},
            {"divider"},
            {"toggle","Kill Sounds",Settings.Audio.KillSoundsEnabled,function(e) Settings.Audio.KillSoundsEnabled=e; MD.sendNotification("Kill Sounds",e and "On" or "Off",2) end},
            {"input","Kill Sound ID",Settings.Audio.KillSoundId or "",function(v) Settings.Audio.KillSoundId=v end},
            {"slider","Kill Volume",0,100,math.floor((Settings.Audio.KillVolume or 0.65)*100),function(v) Settings.Audio.KillVolume=v/100 end},
            {"button","Test Kill Sound",function() _G[MW_T.audioApi].playMwSound(Settings.Audio.KillSoundId, Settings.Audio.KillVolume) end},
            {"info","Uses creator tags + recent fire / aim lock. Paste any Roblox audio ID.",Theme.TextDim},
        })
        end
        addCard(page,2,"Music Player",{
            {"toggle","Enable Music",Settings.Audio.MusicEnabled,function(e) Settings.Audio.MusicEnabled=e; _G[MW_T.audioApi].refreshMusicPlayback(); MD.sendNotification("Music",e and "Playing" or "Off",2) end},
            {"input","Music Asset ID",Settings.Audio.MusicId or "",function(v) Settings.Audio.MusicId=v; _G[MW_T.audioApi].refreshMusicPlayback() end},
            {"slider","Music Volume",0,100,math.floor((Settings.Audio.MusicVolume or 0.35)*100),function(v) Settings.Audio.MusicVolume=v/100; _G[MW_T.audioApi].refreshMusicPlayback() end},
            {"slider","Pitch",50,200,math.floor((Settings.Audio.MusicPitch or 1)*100),function(v) Settings.Audio.MusicPitch=v/100; _G[MW_T.audioApi].refreshMusicPlayback() end},
            {"slider","Speed",50,200,math.floor((Settings.Audio.MusicSpeed or 1)*100),function(v) Settings.Audio.MusicSpeed=v/100; _G[MW_T.audioApi].refreshMusicPlayback() end},
            {"slider","Hear Distance",20,300,Settings.Audio.MusicDistance or 90,function(v) Settings.Audio.MusicDistance=v; _G[MW_T.audioApi].refreshMusicPlayback() end},
            {"slider","Bass",0,10,Settings.Audio.MusicBass or 0,function(v) Settings.Audio.MusicBass=v; _G[MW_T.audioApi].refreshMusicPlayback() end},
            {"slider","Treble",0,10,Settings.Audio.MusicTreble or 0,function(v) Settings.Audio.MusicTreble=v; _G[MW_T.audioApi].refreshMusicPlayback() end},
            {"toggle","Boombox",Settings.Audio.Boombox ~= false,function(e) Settings.Audio.Boombox=e; _G[MW_T.audioApi].refreshMusicPlayback() end},
            {"toggle","Loop Music",Settings.Audio.MusicLoop,function(e) Settings.Audio.MusicLoop=e; _G[MW_T.audioApi].refreshMusicPlayback() end},
            {"button","Play / Resume",function() Settings.Audio.MusicEnabled=true; _G[MW_T.audioApi].refreshMusicPlayback(); MD.sendNotification("Music","Playing",1.5) end},
            {"button","Pause Music",function() _G[MW_T.audioApi].pauseMusic(); MD.sendNotification("Music","Paused",1.5) end},
            {"button","Stop Music",function() Settings.Audio.MusicEnabled=false; _G[MW_T.audioApi].refreshMusicPlayback(); MD.sendNotification("Music","Stopped",1.5) end},
            {"info","Boombox plays in 3D from your character. Paste a Roblox audio ID.",Theme.TextDim},
        })
        page.CanvasSize=UDim2.new(0,0,0,pageMaxY(page))
    end
    local currentToggleKey=Settings.Keybinds.ToggleGUI
    tabBuilders["Settings"] = function(page)
        ensureUISettings()
        local kbRows = {
            {"keybind","Toggle GUI",Settings.Keybinds.ToggleGUI,function(v) currentToggleKey=v; Settings.Keybinds.ToggleGUI=v end},
            {"keybind","Panic Key",Settings.Keybinds.PanicKey,function(v) Settings.Keybinds.PanicKey=v end},
        }
        if MW.allows("aim") then
            table.insert(kbRows, {"keybind","Cycle Target",Settings.Keybinds.CycleTarget,function(v) Settings.Keybinds.CycleTarget=v end})
            table.insert(kbRows, {"keybind","Trigger Bot",Settings.Keybinds.ToggleTriggerBot,function(v) Settings.Keybinds.ToggleTriggerBot=v end})
            table.insert(kbRows, {"keybind","Rage Bot",Settings.Keybinds.ToggleRageBot,function(v) Settings.Keybinds.ToggleRageBot=v end})
        end
        table.insert(kbRows, {"keybind","Toggle Fly",Settings.Keybinds.ToggleFly,function(v) Settings.Keybinds.ToggleFly=v end})
        if MW.allows("autoTp") then
            table.insert(kbRows, {"keybind","Auto TP",Settings.Keybinds.ToggleAutoTP,function(v) Settings.Keybinds.ToggleAutoTP=v end})
        end
        table.insert(kbRows, {"keybind","Noclip",Settings.Keybinds.ToggleNoclip or Enum.KeyCode.V,function(v) Settings.Keybinds.ToggleNoclip=v end})
        table.insert(kbRows, {"keybind","Click TP Hold",Settings.Keybinds.ClickTP or Enum.KeyCode.LeftAlt,function(v) Settings.Keybinds.ClickTP=v end})
        if MW.allows("obby") then
            table.insert(kbRows, {"keybind","Auto Obby",Settings.Keybinds.ToggleAutoObby or Enum.KeyCode.Unknown,function(v) Settings.Keybinds.ToggleAutoObby=v end})
        end
        table.insert(kbRows, {"info","Click a bind, then press any key or mouse button. Esc cancels.",Theme.TextDim})
        addCard(page,1,"Keybinds", kbRows)
        addCard(page,1,"Other Scripts",{
            {"button","Copy Infinite Yield",function()
                local line = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()'
                local ok = Auth.copyText(line)
                MD.sendNotification("Script", ok and "IY loadstring copied" or "Copy failed", 3)
            end},
            {"button","Copy Nameless Admin",function()
                local line = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))()'
                local ok = Auth.copyText(line)
                MD.sendNotification("Script", ok and "Admin loadstring copied" or "Copy failed", 3)
            end},
            {"info","Copies loadstrings to clipboard: paste in your executor yourself.",Theme.TextDim},
            {"info", Cap.ok("http") and "Loads remote scripts via HttpGet." or "HTTP locked by WEAO/UNC for this executor.", Theme.TextDim},
        })
        addCard(page,2,"Theme Studio",{
            {"enum","Preset",{"Purple","Informant","Ice","Graphite","BloodAmber","Mint","Steel","Crimson"},Settings.UI.ThemePreset or "Purple",function(v) if MD.applyThemePreset then MD.applyThemePreset(v) end; MD.sendNotification("Theme",v,1.5) end},
            {"enum","Menu Scale",{"Compact","Normal","Large"},"Normal",function(v) if MD.applyMenuScalePreset then MD.applyMenuScalePreset(v) end end},
            {"toggle","Menu Blur",Settings.UI.BlurMenu ~= false,function(e) Settings.UI.BlurMenu=e end},
            {"button","Open Color Table",function() if UILib.openColorTable then UILib.openColorTable(false) end end},
            {"info","Color Table edits theme + ESP hex. Presets stamp a full palette.",Theme.TextDim},
        })
        addCard(page,2,"Config Tools",{
            {"toggle","Autosave",Settings.UI.Autosave == true,function(e) if MD.TraceConfig then MD.TraceConfig.setAutosave(e) end end, Cap.badge("filesystem")},
            {"button","Export JSON: Clipboard",function()
                local ok, err = MD.TraceConfig and MD.TraceConfig.copyExport(currentProfileName)
                MD.sendNotification("Config", ok and "Copied JSON" or tostring(err or "failed"), 2)
            end, Cap.badge("clipboard")},
            {"button","Duplicate Active",function()
                local dst = tostring(currentProfileName or "cfg") .. "_copy"
                local ok, err = MD.TraceConfig and MD.TraceConfig.duplicateProfile(currentProfileName or "Default", dst)
                MD.sendNotification("Config", ok and ("Duplicated: "..dst) or tostring(err or "failed"), 2)
            end, Cap.badge("filesystem")},
            {"info","Rename via duplicate + remove in Configs panel. Export is Settings snapshot JSON.",Theme.TextDim},
        })
        addCard(page,1,"Script Info",{
            {"info", (MD.TraceInfo and MD.TraceInfo.summary()) or ("Melo 🍃 "..tostring(MW.display)), Theme.TextAccent},
            {"info", "Mode: "..((MD.TraceInfo and MD.TraceInfo.modeLabel()) or tostring(MW.mode)), Theme.TextSecondary},
            {"info", "PlaceId: "..tostring(game.PlaceId), Theme.TextDim},
            {"button","Show Cap Locks",function()
                local lines = MD.TraceInfo and MD.TraceInfo.capLines() or {}
                MD.sendNotification("Cap", table.concat(lines, " | "), 4)
            end},
            {"button","Unload Melo 🍃",function() if _G[MW_T.cleanup] then pcall(_G[MW_T.cleanup]) end end},
            {"info", MW.isArsenal and "Combat + gun mods available on this place." or ("Showing "..tostring(MW.mode).." kit only: combat / gun mods stay Arsenal-only."), Theme.TextDim},
            {"info", (MD.LockAssert and MD.LockAssert.summary()) or "Cap gunmods status unknown", Theme.TextSecondary},
        })
        addCard(page,1,"Panels",{
            {"info","Use x on a float header to close that panel only.",Theme.TextDim},
            {"info","Theme colors live under Settings. ESP Preview / top header removed.",Theme.TextDim},
            {"button","Restore Panels",function()
                if type(restoreFloatPanels) == "function" then restoreFloatPanels()
                else MD.sendNotification("Panels","Not ready",1.5) end
            end},
        })
        local themeY = col1Y(page).Value
        local themeBody = select(1, makeCard(page, "Theme Colors", COL1_X, themeY, CARD_W, 228))
        col1Y(page).Value = themeY + CARD_HEADER_H + 232 + CONTENT_PAD
        addInfoRow(themeBody, "Presets (click swatch)", 0, Theme.TextDim)
        local presetHex = {"F0F0F5", "C8A2FF", "5CE1E6", "3DFF8A", "FF5C5C", "FFD966"}
        for i, hex in ipairs(presetHex) do
            local sw = UILib.newButton(themeBody, {
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(0, (i - 1) * 28, 0, 18),
                BackgroundColor3 = MD.hexToColor3(hex),
                BorderSizePixel = 0,
                Text = "",
            }, function()
                Settings.UI.AccentHex = hex
                Settings.UI.ToggleHex = hex
                applyCustomTheme()
                refreshThemeHexFields()
                sendNotification("Theme", "Preset applied", 1.5)
            end)
            UILib.corner(sw, 5)
            UILib.stroke(sw, Theme.CardBorder, 1, 0.4)
        end
        local hexFields = {}
        local function addHexField(label, y, settingKey)
            UILib.newLabel(themeBody, {
                Size = UDim2.new(0.42, 0, 0, 14),
                Position = UDim2.new(0, 0, 0, y),
                Text = label,
                TextColor3 = Theme.TextSecondary,
                TextSize = 10,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            local prev = UILib.newFrame(themeBody, {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(1, -18, 0, y - 2),
                BackgroundColor3 = MD.hexToColor3(Settings.UI[settingKey]),
                BorderSizePixel = 0,
            })
            UILib.corner(prev, 4)
            UILib.stroke(prev, Theme.CardBorder, 1, 0.35)
            local box = UILib.newBox(themeBody, {
                Size = UDim2.new(0.54, -24, 0, 22),
                Position = UDim2.new(0.44, 0, 0, y - 4),
                BackgroundColor3 = Theme.InputBg,
                BorderSizePixel = 0,
                Text = "#" .. (Settings.UI[settingKey] or "FFFFFF"),
                TextColor3 = Theme.TextAccent,
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                ClearTextOnFocus = false,
            })
            UILib.corner(box, 5)
            UILib.stroke(box, Theme.InputBorder, 1, 0.3)
            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 6)
            pad.Parent = box
            local function commitHex()
                ensureUISettings()
                local t = box.Text:gsub("#", ""):upper():gsub("[^0-9A-F]", "")
                if #t == 6 then
                    Settings.UI[settingKey] = t
                    prev.BackgroundColor3 = MD.hexToColor3(t)
                    applyCustomTheme()
                    refreshThemeHexFields()
                end
                box.Text = "#" .. Settings.UI[settingKey]
            end
            box.FocusLost:Connect(commitHex)
            hexFields[settingKey] = {box = box, prev = prev, commit = commitHex}
            themeHexFields[settingKey] = hexFields[settingKey]
        end
        addHexField("Accent", 52, "AccentHex")
        addHexField("Background", 80, "BackgroundHex")
        addHexField("Surface / Cards", 108, "SurfaceHex")
        addHexField("Toggle On", 136, "ToggleHex")
        addButtonRow(themeBody, "Apply Colors", 168, function()
            for _, field in pairs(hexFields) do field.commit() end
            applyCustomTheme()
            refreshThemeHexFields()
            sendNotification("Theme", "Colors applied", 2)
        end, Theme.ButtonBg)
        addButtonRow(themeBody, "Reset Default", 196, function()
            resetThemeDefaults()
            refreshThemeHexFields()
            sendNotification("Theme", "Reset to default", 2)
        end, Theme.EnumBg)
        addCard(page,2,"Script Info",{
            {"info","Melo 🍃 "..MW.display,Theme.TextAccent},
            {"info", tostring(MW.mode)..": PlaceId "..tostring(game.PlaceId)..(MW.isArsenal and "" or " (gun mods Arsenal-only)"), Theme.TextDim},
            {"info", (MW.kitSummary and MW.kitSummary()) or "", Theme.TextSecondary},
            {"info", MD.getSupportedExecutorLabel() .. " required", Theme.TextDim},
            {"info","Executor: "..getExecutorName(),Theme.TextDim},
            {"info","WEAO: "..Cap.summaryLine(),Theme.TextDim},
            {"button","Unload Script",function()
                if _G[MW_T.cleanup] then pcall(_G[MW_T.cleanup]) end
            end,Theme.ErrorColor},
        })
        page.CanvasSize=UDim2.new(0,0,0,pageMaxY(page))
    end
    subTabRow.Visible = false
    updateContentLayout()
    switchMain("Home")
    local chFrame=UILib.newFrame(overlayLayer,{Name=MW_T.crosshair,Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,Visible=false,ZIndex=5})
    local chL={}; for i=1,24 do local l=Instance.new("Frame"); l.BackgroundColor3=Color3.new(1,1,1); l.BorderSizePixel=0; l.AnchorPoint=Vector2.new(0.5,0.5); l.Visible=false; l.Parent=chFrame; chL[i]=l end
    local chO={}; for i=1,24 do local l=Instance.new("Frame"); l.BackgroundColor3=Color3.new(0,0,0); l.BorderSizePixel=0; l.AnchorPoint=Vector2.new(0.5,0.5); l.Visible=false; l.ZIndex=0; l.Parent=chFrame; chO[i]=l end
    local chDot=UILib.newFrame(chFrame,{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Visible=false}); UILib.corner(chDot,100)
    local chODot=UILib.newFrame(chFrame,{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Visible=false,ZIndex=0}); UILib.corner(chODot,100)
    local chCirc=UILib.newFrame(chFrame,{BackgroundTransparency=1,BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Visible=false}); UILib.corner(chCirc,100)
    local chCS=UILib.stroke(chCirc,Color3.new(1,1,1),2)
    local function setL(i,cx,cy,w,h,col,op) local l=chL[i]; if not l then return end; l.Size=UDim2.new(0,w,0,h); l.Position=UDim2.new(0,cx,0,cy); l.BackgroundColor3=col; l.BackgroundTransparency=1-op; l.Visible=true end
    local function setOL(i,cx,cy,w,h,col,tk,op) local l=chO[i]; if not l then return end; l.Size=UDim2.new(0,w+tk*2,0,h+tk*2); l.Position=UDim2.new(0,cx,0,cy); l.BackgroundColor3=col; l.BackgroundTransparency=1-op; l.Visible=true end
    local function updateCrosshair()
        local s=Settings.Crosshair; chFrame.Visible=s.Enabled; if not s.Enabled then return end
        for i=1,24 do if chL[i] then chL[i].Visible=false end; if chO[i] then chO[i].Visible=false end end; chDot.Visible=false; chODot.Visible=false; chCirc.Visible=false
        local col=s.RainbowColor and Color3.fromHSV(tick()%3/3,1,1) or s.Color; local oc=s.OutlineColor; local op=s.Opacity
        local t,sz,gap=s.Thickness,s.Size,s.Gap; local tk=s.OutlineThickness; local dg=gap
        if s.DynamicSpread then local c=player.Character; if c then local hrp=c:FindFirstChild("HumanoidRootPart"); if hrp then local v=Vector3.new(hrp.AssemblyLinearVelocity.X,0,hrp.AssemblyLinearVelocity.Z).Magnitude; dg=gap+math.floor(v*0.15) end end end
        local cam=S.Workspace.CurrentCamera; local vs=cam and cam.ViewportSize or Vector2.new(800,600)
        local asx=chFrame.AbsoluteSize.X>0 and chFrame.AbsoluteSize.X or vs.X; local asy=chFrame.AbsoluteSize.Y>0 and chFrame.AbsoluteSize.Y or vs.Y
        local cx=asx/2; local cy=asy/2
        if s.Style=="Cross" or s.Style=="T-Shape" then
            if s.Style~="T-Shape" then if s.OutlineEnabled then setOL(1,cx,cy-(dg+sz/2),t,sz,oc,tk,op) end; setL(1,cx,cy-(dg+sz/2),t,sz,col,op) end
            if s.OutlineEnabled then setOL(2,cx,cy+(dg+sz/2),t,sz,oc,tk,op) end; setL(2,cx,cy+(dg+sz/2),t,sz,col,op)
            if s.OutlineEnabled then setOL(3,cx-(dg+sz/2),cy,sz,t,oc,tk,op) end; setL(3,cx-(dg+sz/2),cy,sz,t,col,op)
            if s.OutlineEnabled then setOL(4,cx+(dg+sz/2),cy,sz,t,oc,tk,op) end; setL(4,cx+(dg+sz/2),cy,sz,t,col,op)
            if s.CenterDot then local ds=s.CenterDotSize; if s.OutlineEnabled then chODot.Size=UDim2.new(0,ds+tk*2,0,ds+tk*2); chODot.BackgroundColor3=oc; chODot.BackgroundTransparency=1-op; chODot.Visible=true end; chDot.Size=UDim2.new(0,ds,0,ds); chDot.BackgroundColor3=col; chDot.BackgroundTransparency=1-op; chDot.Visible=true end
        elseif s.Style=="X-Shape" then
            for i,rot in ipairs({45,-45}) do local li=chL[i]; local oi=chO[i]; if s.OutlineEnabled then oi.Size=UDim2.new(0,t+tk*2,0,sz*2+dg*2+tk*2); oi.Position=UDim2.new(0,cx,0,cy); oi.Rotation=rot; oi.BackgroundColor3=oc; oi.BackgroundTransparency=1-op; oi.Visible=true end; li.Size=UDim2.new(0,t,0,sz*2+dg*2); li.Position=UDim2.new(0,cx,0,cy); li.Rotation=rot; li.BackgroundColor3=col; li.BackgroundTransparency=1-op; li.Visible=true end
        elseif s.Style=="Dot" then
            local ds=s.Size; if s.OutlineEnabled then chODot.Size=UDim2.new(0,ds+tk*2,0,ds+tk*2); chODot.BackgroundColor3=oc; chODot.BackgroundTransparency=1-op; chODot.Visible=true end; chDot.Size=UDim2.new(0,ds,0,ds); chDot.BackgroundColor3=col; chDot.BackgroundTransparency=1-op; chDot.Visible=true
        elseif s.Style=="Circle" then
            local segs=math.clamp(s.Segments or 12,4,24); local rad=sz
            for i=1,segs do
                local ang=(i/segs)*math.pi*2-math.pi/2
                local px=cx+math.cos(ang)*rad; local py=cy+math.sin(ang)*rad
                local segLen=math.max(3,(2*math.pi*rad/segs)*0.55); local rot=math.deg(ang)+90
                if s.OutlineEnabled then setOL(i,px,py,segLen,t,oc,tk,op); chO[i].Rotation=rot end
                setL(i,px,py,segLen,t,col,op); chL[i].Rotation=rot
            end
            if s.CenterDot then local ds=s.CenterDotSize; chDot.Size=UDim2.new(0,ds,0,ds); chDot.BackgroundColor3=col; chDot.BackgroundTransparency=1-op; chDot.Visible=true end
        elseif s.Style=="Sniper" then
            local halfW=vs.X/2; local halfH=vs.Y/2
            if s.OutlineEnabled then setOL(1,cx,cy-(dg/2+halfH/2),t,halfH-dg/2,oc,tk,op*0.7) end; setL(1,cx,cy-(dg/2+halfH/2),t,halfH-dg/2,col,op*0.7)
            if s.OutlineEnabled then setOL(2,cx,cy+(dg/2+halfH/2),t,halfH-dg/2,oc,tk,op*0.7) end; setL(2,cx,cy+(dg/2+halfH/2),t,halfH-dg/2,col,op*0.7)
            if s.OutlineEnabled then setOL(3,cx-(dg/2+halfW/2),cy,halfW-dg/2,t,oc,tk,op*0.7) end; setL(3,cx-(dg/2+halfW/2),cy,halfW-dg/2,t,col,op*0.7)
            if s.OutlineEnabled then setOL(4,cx+(dg/2+halfW/2),cy,halfW-dg/2,t,oc,tk,op*0.7) end; setL(4,cx+(dg/2+halfW/2),cy,halfW-dg/2,t,col,op*0.7)
            local ds=s.CenterDotSize; chDot.Size=UDim2.new(0,ds,0,ds); chDot.BackgroundColor3=col; chDot.BackgroundTransparency=1-op; chDot.Visible=true
        elseif s.Style=="KV" then
            for i,ang in ipairs({-35,35}) do local arm=chL[i]; local aOut=chO[i]; if s.OutlineEnabled then aOut.Size=UDim2.new(0,t+tk*2,0,sz+tk*2); aOut.Position=UDim2.new(0,cx,0,cy); aOut.Rotation=ang; aOut.BackgroundColor3=oc; aOut.BackgroundTransparency=1-op; aOut.AnchorPoint=Vector2.new(0.5,0); aOut.Visible=true end; arm.Size=UDim2.new(0,t,0,sz); arm.Position=UDim2.new(0,cx,0,cy); arm.Rotation=ang; arm.BackgroundColor3=col; arm.BackgroundTransparency=1-op; arm.AnchorPoint=Vector2.new(0.5,0); arm.Visible=true end
            if s.OutlineEnabled then setOL(3,cx,cy,sz*2,t,oc,tk,op) end; setL(3,cx,cy,sz*2,t,col,op)
        end
    end
    table.insert(allConnections,S.RunService.RenderStepped:Connect(function()
        if isUnloading or _G[MW_T.unloaded] then return end
        pcall(updateCrosshair)
        if MD.runTriggerBot then pcall(MD.runTriggerBot) end
    end))
    table.insert(allConnections,S.RunService.Heartbeat:Connect(function(dt)
        if isUnloading or _G[MW_T.unloaded] then if speedVel then pcall(function() speedVel:Destroy() end); speedVel=nil end; return end
        if not Settings.Movement.SpeedEnabled then if speedVel then pcall(function() speedVel:Destroy() end); speedVel=nil end; return end
        if MW.allows("speedHack") == false then return end
        local char=player.Character; if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChild("Humanoid"); if not hrp or not hum then return end
        local method=Settings.Movement.SpeedMethod; local spd=Settings.Movement.Speed
        if method=="WalkSpeed" then if speedVel then pcall(function() speedVel:Destroy() end); speedVel=nil end; hum.WalkSpeed=spd; return end
        local md=hum.MoveDirection; if md.Magnitude<0.1 then if speedVel then pcall(function() speedVel:Destroy() end); speedVel=nil end; return end
        if method=="CFrame" then if speedVel then pcall(function() speedVel:Destroy() end); speedVel=nil end; hum.WalkSpeed=16; local wm=md*spd*dt; hrp.CFrame=hrp.CFrame+Vector3.new(wm.X,0,wm.Z)
        elseif method=="Velocity" then hum.WalkSpeed=16; if not speedVel or speedVel.Parent~=hrp then if speedVel then pcall(function() speedVel:Destroy() end) end; speedVel=Instance.new("BodyVelocity"); speedVel.Name=MW_T.spdVel; speedVel.MaxForce=Vector3.new(100000,0,100000); speedVel.P=10000; speedVel.Parent=hrp end; speedVel.Velocity=md*spd end
    end))
    local bhopVel=nil; local lastJump=0; local curBhop=0

    local HB = {
        panels = {},
        panelOpen = {},
        buttons = {},
        hubOpen = mainFrame.Visible,
        keepBar = false,
        titleOf = {},
        frame = { Visible = false },
        refresh = function() end,
    }

    local fpsFrame=UILib.newFrame(screenGui,{Name=MW_T.fpsHud,Size=UDim2.new(0,110,0,24),Position=UDim2.new(1,-118,0,10),BackgroundColor3=Theme.CardBg,BackgroundTransparency=0.15,BorderSizePixel=0,Visible=false}); UILib.corner(fpsFrame,6); UILib.stroke(fpsFrame,Theme.CardBorder,1,0.5)
    local fpsLbl=UILib.newLabel(fpsFrame,{Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,6,0,0),Text="FPS: 0",TextColor3=Theme.TextAccent,TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
    local velLbl=UILib.newLabel(screenGui,{Name=MW_T.velHud,Size=UDim2.new(0,160,0,18),Position=UDim2.new(0.5,40,0.5,26),Text="0.0 studs/s",TextColor3=Theme.CardHeaderBg,TextSize=12,Font=Enum.Font.GothamBold,TextStrokeTransparency=0.5,TextStrokeColor3=Color3.fromRGB(0,0,0),Visible=false})
    local lastFpsTick=math.floor(tick()); local fc=0; local cfps=0
    table.insert(allConnections,S.RunService.RenderStepped:Connect(function(dt)
        if isUnloading or _G[MW_T.unloaded] then return end
        if Settings.Visuals.CustomFOV and not MD.isPlayerScoped() then
            local cam=S.Workspace.CurrentCamera
            if cam and math.abs(cam.FieldOfView - Settings.Visuals.FOVAmount) > 0.5 then
                cam.FieldOfView=Settings.Visuals.FOVAmount
            end
        end
        if Settings.Visuals.CustomBrightness or Settings.Visuals.CustomTime or Settings.Visuals.CustomExposure then
            if (tick() - (VisPerf.lastS.Lighting or 0)) >= 0.12 then
                VisPerf.lastS.Lighting = tick()
                applyWorldLighting()
            end
        end
        if Settings.Movement.BunnyHop then
            local char=player.Character; if char then local hum=char:FindFirstChild("Humanoid"); local hrp=char:FindFirstChild("HumanoidRootPart")
                if hum and hrp then
                    local holdSp=S.UserInputService:IsKeyDown(Enum.KeyCode.Space); local grounded=hum:GetState()~=Enum.HumanoidStateType.Jumping and hum:GetState()~=Enum.HumanoidStateType.Freefall
                    local tbs=16+(Settings.Movement.BunnyHopSpeed/100)*64
                    if holdSp then
                        if grounded then hum:ChangeState(Enum.HumanoidStateType.Jumping); lastJump=tick() end
                        if not grounded then local cam=S.Workspace.CurrentCamera; if cam then local fd=Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z).Unit; curBhop=curBhop+(tbs-curBhop)*math.min(dt*5,1); if not bhopVel or bhopVel.Parent~=hrp then if bhopVel then bhopVel:Destroy() end; bhopVel=Instance.new("BodyVelocity"); bhopVel.Name=MW_T.bhopVel; bhopVel.MaxForce=Vector3.new(8000,0,8000); bhopVel.P=1000; bhopVel.Parent=hrp end; bhopVel.Velocity=fd*curBhop end
                        else if bhopVel and (tick()-lastJump)>0.08 then bhopVel:Destroy(); bhopVel=nil end; curBhop=curBhop*0.85 end
                    else if bhopVel then bhopVel:Destroy(); bhopVel=nil end; curBhop=0 end
                end
            end
        else if bhopVel then bhopVel:Destroy(); bhopVel=nil end; curBhop=0 end
        fpsFrame.Visible=Settings.Visuals.ShowFPS; velLbl.Visible=Settings.Visuals.ShowVelocity
        if Settings.Visuals.ShowFPS then
            fc=fc+1
            local curSec=math.floor(tick())
            if curSec~=lastFpsTick then
                cfps=fc
                fc=0
                lastFpsTick=curSec
            end
            local lockTxt = ""
            if Settings.Visuals.VSyncLock and VisPerf.lockTier and VisPerf.lockTier > 0 then
                lockTxt = VisPerf.lockTier == 2 and " | Lock: Low" or " | Lock: Med"
            end
            fpsLbl.Text="FPS: "..tostring(cfps)..lockTxt
        end
        if Settings.Visuals.ShowVelocity then local c=player.Character; if c then local hrp=c:FindFirstChild("HumanoidRootPart"); if hrp then local v=hrp.AssemblyLinearVelocity; velLbl.Text=string.format("%.1f studs/s",Vector3.new(v.X,0,v.Z).Magnitude) end end end
    end))

    local vu=game:GetService("VirtualUser")
    table.insert(allConnections,player.Idled:Connect(function() if Settings.Misc.AntiAFK then vu:CaptureController(); vu:ClickButton2(Vector2.new()) end end))

    local lastGunCheck=0; local lastSpam=0; local lastInfiniteAmmo=0
    table.insert(allConnections,S.RunService.Heartbeat:Connect(function()
        if isUnloading or _G[MW_T.unloaded] then return end
        local now=tick()
        if now-lastGunCheck>=2 then lastGunCheck=now
            if not MW.gunModsInTesting then
            local any=Cap.ok("gunmods") and (Settings.Combat.FastReload or Settings.Combat.FastFireRate or Settings.Combat.AlwaysAuto or Settings.Combat.NoSpread or Settings.Combat.NoRecoil)
            if any then if not weaponCacheBuilt then MD.buildWeaponCache() end; for _,v in ipairs(MD.weaponCache) do if v and v.Parent then local n=v.Name; if Settings.Combat.FastReload and (n=="ReloadTime" or n=="EReloadTime") and v.Value~=0.01 then v.Value=0.01 elseif Settings.Combat.FastFireRate and (n=="FireRate" or n=="BFireRate") and v.Value~=0.02 then v.Value=0.02 elseif Settings.Combat.AlwaysAuto and (n=="Auto" or n=="AutoFire" or n=="Automatic" or n=="AutoShoot" or n=="AutoGun") and v.Value~=true then v.Value=true elseif Settings.Combat.NoSpread and (n=="MaxSpread" or n=="Spread" or n=="SpreadControl") and v.Value~=0 then v.Value=0 elseif Settings.Combat.NoRecoil and (n=="RecoilControl" or n=="Recoil") and v.Value~=0 then v.Value=0 end end end end
            if MW.isMiscGunTest and Cap.ok("gunmods") and AcsGuns and AcsGuns.patch then pcall(AcsGuns.patch) end
            end
        end
        if not MW.gunModsInTesting and Cap.ok("gunmods") and Settings.Combat.InfiniteAmmo and now-lastInfiniteAmmo>=0.08 then
            lastInfiniteAmmo=now
            applyInfiniteAmmo()
        end
        if not Settings.Movement.Fly and isFlying then MD.stopFly() end
        if Settings.Misc.ChatSpammer and now-lastSpam>=Settings.Misc.ChatSpamDelay then lastSpam=now
            local msg=Settings.Misc.ChatSpamMessage
            if msg and msg~="" then MD.FX.sendChat(msg, Settings.Misc.ChatSpamTeamOnly == true) end
        end
    end))

    pcall(function()
        local tcs=game:GetService("TextChatService"); if tcs then
            local function hook(ch) if ch:IsA("TextChannel") then ch.MessageReceived:Connect(function(mo) if not Settings.Misc.ChatSpyEnabled then return end; local src=mo.TextSource; if not src then return end; local sp=S.Players:GetPlayerByUserId(src.UserId); if not sp then return end; pushChatSpyLine(MD.getDisplayName(sp), mo.Text) end) end end
            for _,c in ipairs(tcs:GetDescendants()) do hook(c) end; tcs.DescendantAdded:Connect(hook)
        end
    end)

    pcall(function()
        local rem = select(1, MD.FX.resolveChatRemote())
        if not rem or not rem:IsA("RemoteEvent") then return end
        table.insert(allConnections, rem.OnClientEvent:Connect(function(...)
            if not Settings.Misc.ChatSpyEnabled then return end
            local args = {...}
            local speaker, message
            for _, a in ipairs(args) do
                if typeof(a) == "Instance" and a:IsA("Player") then speaker = a
                elseif typeof(a) == "string" and #a > 0 then
                    if not message then message = a
                    elseif not speaker then
                        local pl = S.Players:FindFirstChild(a)
                        if pl then speaker = pl else message = a end
                    end
                elseif typeof(a) == "table" then
                    if typeof(a.Message) == "string" then message = a.Message end
                    if typeof(a.Text) == "string" then message = a.Text end
                    if typeof(a.From) == "string" then speaker = S.Players:FindFirstChild(a.From) end
                    if typeof(a.Player) == "Instance" and a.Player:IsA("Player") then speaker = a.Player end
                    if typeof(a.Speaker) == "string" then speaker = S.Players:FindFirstChild(a.Speaker) end
                end
            end
            if message and message ~= "" then
                pushChatSpyLine(speaker and MD.getDisplayName(speaker) or "?", message)
            end
        end))
    end)
    for _,p in ipairs(S.Players:GetPlayers()) do if p~=player then pcall(function() p.Chatted:Connect(function(msg) if Settings.Misc.ChatSpyEnabled then pushChatSpyLine(MD.getDisplayName(p), msg) end end) end) end end
    table.insert(allConnections,S.Players.PlayerAdded:Connect(function(p) pcall(function() p.Chatted:Connect(function(msg) if Settings.Misc.ChatSpyEnabled then pushChatSpyLine(MD.getDisplayName(p), msg) end end) end) end))
    table.insert(allConnections, S.UserInputService.InputBegan:Connect(function(input, gp)
        if isUnloading or _G[MW_T.unloaded] then return end
        if waitingForKey then
            if keybindCapture then
            if tick() < keybindIgnoreUntil then return end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
                keybindCapture.btn.Text = MD.bindName(keybindCapture.previous)
                keybindCapture.btn.TextColor3 = Theme.KeybindText
                waitingForKey = false
                keybindCapture = nil
                return
            end
            if gp and input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local bind = nil
            if input.UserInputType == Enum.UserInputType.Keyboard then
                bind = input.KeyCode
            elseif input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.MouseButton2
                or input.UserInputType == Enum.UserInputType.MouseButton3 then
                bind = input.UserInputType
            end
            if not bind or bind == Enum.KeyCode.Unknown then return end
            local cap = keybindCapture
            cap.btn.Text = MD.bindName(bind)
            cap.btn.TextColor3 = Theme.KeybindText
            waitingForKey = false
            keybindCapture = nil
            if cap.callback then cap.callback(bind) end
            end
            return
        end
    end))
    table.insert(allConnections,S.UserInputService.InputBegan:Connect(function(input,gp)
        if isUnloading or _G[MW_T.unloaded] then return end
        if waitingForKey then return end
        if UILib.TraceDraw and (UILib.TraceDraw.typing or UILib.TraceDraw.cmdOpen) then return end
        if MD.inputMatchesBind(input, Settings.Keybinds.ToggleGUI) then
            if UILib.TraceDraw and UILib.TraceDraw.SetOpen then
                local open = not UILib.TraceDraw.open
                UILib.TraceDraw.SetOpen(open)
                pcall(function() setMenuVisible(false) end)
                pcall(function()
                    if UILib._hubWindowLayer then UILib._hubWindowLayer.Visible = false end
                end)
            elseif mainFrame.Visible then
                setMenuVisible(false)
            else
                setMenuVisible(true)
            end
            return
        end
        if gp then return end
        if MD.inputMatchesBind(input, Settings.Keybinds.PanicKey) then
            Settings.ESP.Enabled=false; Settings.Aimbot.Enabled=false; Settings.Crosshair.Enabled=false; Settings.Radar.Enabled=false
            Settings.Combat.TriggerBot=false
            Settings.Combat.RageBot=false
            Settings.Combat.InfiniteAmmo=false; MD.stopInfiniteAmmo()
            Settings.ESP.ThrowableEnabled=false
            Settings.ESP.ThrowableArcPreview=false
            Settings.Visuals.ThirdPerson=false
            Trigger.stopFire()
            stopRageBot(); MD.stopAutoTPLoop()
            Settings.Movement.SpeedEnabled=false; Settings.Movement.Fly=false
            if MD.stopUniversalKits then MD.stopUniversalKits() end
            stopAimbotTracking(); MD.stopFly(); MD.clearAllESP(); MD.clearThrowableESP(); MD.clearThrowableArcPreview(); MD.clearGunWireframe()
            local cam=S.Workspace.CurrentCamera; if cam and origCameraType then cam.CameraType=origCameraType; origCameraType=nil end
            if speedVel then pcall(function() speedVel:Destroy() end); speedVel=nil end
            local c=player.Character; if c then local h=c:FindFirstChild("Humanoid"); if h then h.WalkSpeed=16; h.JumpPower=50 end end
            mainFrame.Visible=false; if topNavDock then topNavDock.Visible=false end
            pcall(function() if UILib.TraceDraw and UILib.TraceDraw.SetOpen then UILib.TraceDraw.SetOpen(false) end end)
            MD.sendNotification("PANIC","All features disabled",3)
        end
        if MD.inputMatchesBind(input, MD.AIMBOT_HOLD_BIND) then
            if MW.allows("aim") and Settings.Aimbot.Enabled then
                if Settings.Aimbot.Toggle then
                    if toggleTrackingActive then toggleTrackingActive=false; MD.stopAimbotTracking()
                    else toggleTrackingActive=true; MD.startAimbotTracking() end
                else MD.startAimbotTracking() end
            end
        end
        if MD.inputMatchesBind(input, Settings.Keybinds.CycleTarget) then
            if MW.allows("aim") then cycleTarget() end
        end
        if MD.inputMatchesBind(input, Settings.Keybinds.ToggleTriggerBot) then
            if MW.allows("trigger") then
                Settings.Combat.TriggerBot = not Settings.Combat.TriggerBot
                sendNotification("Trigger Bot", Settings.Combat.TriggerBot and "On" or "Off", 2)
            end
        end
        if MD.inputMatchesBind(input, Settings.Keybinds.ToggleRageBot) then
            if MW.allows("rage") then
                Settings.Combat.RageBot = not Settings.Combat.RageBot
                if Settings.Combat.RageBot then MD.stopAutoTPLoop(); rageRunning=false; MD.startRageBot(); MD.sendNotification("Rage Bot", "On", 2)
                else MD.stopRageBot(); MD.sendNotification("Rage Bot", "Off", 2) end
            end
        end
        if MD.inputMatchesBind(input, Settings.Keybinds.ToggleFly) then
            Settings.Movement.Fly = not Settings.Movement.Fly
            if Settings.Movement.Fly then MD.startFly(); MD.sendNotification("Fly", "On", 2)
            else MD.stopFly(); MD.sendNotification("Fly", "Off", 2) end
        end
        if MD.inputMatchesBind(input, Settings.Keybinds.ToggleAutoTP) then
            if MW.allows("autoTp") then
                Settings.Misc.AutoTPLoop = not Settings.Misc.AutoTPLoop
                if Settings.Misc.AutoTPLoop then MD.startAutoTPLoop(); MD.sendNotification("Auto TP", "On", 2)
                else MD.stopAutoTPLoop(); MD.sendNotification("Auto TP", "Off", 2) end
            end
        end
        if MD.inputMatchesBind(input, Settings.Keybinds.ToggleNoclip) then
            local on = not Settings.Movement.Noclip
            if MD.setNoclip then MD.setNoclip(on) end
            MD.sendNotification("Noclip", on and "On" or "Off", 2)
        end
        if MD.inputMatchesBind(input, Settings.Keybinds.ToggleAutoObby) then
            if MW.allows("obby") then
            if Settings.Misc.AutoObby then
                if MD.stopAutoObby then MD.stopAutoObby() end
                MD.sendNotification("Auto Obby", "Off", 2)
            else
                if MD.startAutoObby then MD.startAutoObby() end
                MD.sendNotification("Auto Obby", "On", 2)
            end
            end
        end
    end))
    table.insert(allConnections,S.UserInputService.InputEnded:Connect(function(input)
        if isUnloading or _G[MW_T.unloaded] then return end
        if MD.inputMatchesBind(input, MD.AIMBOT_HOLD_BIND) then
            if MW.allows("aim") and Settings.Aimbot.Enabled and not Settings.Aimbot.Toggle then MD.stopAimbotTracking() end
        end
    end))
    setupAutoRejoin()
    _G[MW_T.audioApi].setup()
    table.insert(allConnections, player.CharacterAdded:Connect(function(char)
        task.defer(MD.applyViewmodelSettings)
        task.defer(MD.updateGunWireframe)
        if Settings.Movement.Fly then task.defer(MD.startFly) end
        if Settings.Movement.Noclip and MD.setNoclip then task.defer(function() MD.setNoclip(true) end) end
        if Settings.Movement.InfiniteJump and MD.setInfiniteJump then task.defer(function() MD.setInfiniteJump(true) end) end
        if Settings.Movement.ClickTP and MD.setClickTP then task.defer(function() MD.setClickTP(true) end) end
        if Settings.Movement.VehicleSpeed and MD.setVehicleSpeed then task.defer(function() MD.setVehicleSpeed(true) end) end
        if Settings.Movement.LocalInvis and MD.applyLocalInvis then task.defer(function() MD.applyLocalInvis(true) end) end
        table.insert(allConnections, char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then task.defer(MD.updateGunWireframe) end
        end))
    end))

    local floatWins = {}
    local floatClosed = {}
    restoreFloatPanels = function()
        for _, w in ipairs(floatWins) do
            floatClosed[w] = nil
            if mainFrame.Visible then
                w.Visible = true
                w.BackgroundTransparency = 0
            end
        end
        HB.refresh()
        sendNotification("Panels", "Restored", 1.5)
    end
    ;(function()
        local function makeFloat(titleText, w, h, pos)
            local win = UILib.newFrame(windowLayer, {
                Name = MW_T.next(12),
                Size = UDim2.new(0, w, 0, h),
                Position = pos,
                BackgroundColor3 = Theme.WindowBg,
                BorderSizePixel = 0,
                Active = true,
                Visible = false,
                ZIndex = 80,
                ClipsDescendants = false,
            })
            local st = UILib.stroke(win, Theme.WindowBorder, 1, 0)
            local winScale = Instance.new("UIScale")
            winScale.Name = MW_T.floatScale
            winScale.Scale = 1
            winScale.Parent = win
            local bar = UILib.newFrame(win, {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Theme.WindowBg,
                BorderSizePixel = 0,
                ZIndex = 81,
            })
            local titleLbl = UILib.newLabel(bar, {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                Text = titleText,
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 82,
            })
            local closeBtn = UILib.newButton(bar, {
                Size = UDim2.new(0, 26, 0, 22),
                Position = UDim2.new(1, -28, 0, 2),
                BackgroundColor3 = Theme.ButtonBg or Color3.fromRGB(28, 28, 34),
                BorderSizePixel = 0,
                Text = "x",
                TextColor3 = Theme.TextPrimary,
                TextSize = 16,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = true,
                ZIndex = 84,
            })
            local closeStroke = UILib.stroke(closeBtn, Theme.CardBorder, 1, 0)
            closeBtn.MouseButton1Click:Connect(function()
                floatClosed[win] = true
                HB.panelOpen[win] = nil
                win.Visible = false
                HB.refresh()
            end)
            local barLine = UILib.newFrame(bar, {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = Theme.DividerColor,
                BorderSizePixel = 0,
                ZIndex = 82,
            })
            local body = UILib.newFrame(win, {
                Size = UDim2.new(1, -12, 1, -34),
                Position = UDim2.new(0, 6, 0, 28),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 81,
                ClipsDescendants = false,
                Active = true,
            })
            local drag, d0, p0 = false, nil, nil
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then

                    local ap, asz = closeBtn.AbsolutePosition, closeBtn.AbsoluteSize
                    local m = input.Position
                    if m.X >= ap.X and m.Y >= ap.Y and m.X <= ap.X + asz.X and m.Y <= ap.Y + asz.Y then
                        return
                    end
                    drag = true; d0 = input.Position; p0 = win.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then drag = false end
                    end)
                end
            end)
            table.insert(allConnections, S.UserInputService.InputChanged:Connect(function(input)
                if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local d = input.Position - d0
                    win.Position = UDim2.new(p0.X.Scale, p0.X.Offset + d.X, p0.Y.Scale, p0.Y.Offset + d.Y)
                end
            end))
            table.insert(MD.themeCallbacks, function()
                win.BackgroundColor3 = Theme.WindowBg
                bar.BackgroundColor3 = Theme.WindowBg
                st.Color = Theme.WindowBorder
                titleLbl.TextColor3 = Theme.TextPrimary
                barLine.BackgroundColor3 = Theme.DividerColor
                closeBtn.BackgroundColor3 = Theme.ButtonBg
                closeBtn.TextColor3 = Theme.TextPrimary
                closeStroke.Color = Theme.CardBorder
            end)
            table.insert(floatWins, win)
            floatClosed[win] = true
            HB.panelOpen[win] = nil
            HB.panels[titleText] = win
            HB.refresh()
            return win, body
        end
        local function flatBtn(parent, text, xScale, xOff, wScale, cb)
            local b = UILib.newButton(parent, {
                Size = UDim2.new(wScale, -2, 0, 24),
                Position = UDim2.new(xScale, xOff, 0, 0),
                BackgroundColor3 = Theme.ButtonBg,
                BorderSizePixel = 0,
                Text = text,
                TextColor3 = Theme.TextPrimary,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                AutoButtonColor = true,
                Active = true,
                ZIndex = 95,
            }, cb)
            local bs = UILib.stroke(b, Theme.CardBorder, 1, 0)
            table.insert(MD.themeCallbacks, function()
                b.BackgroundColor3 = Theme.ButtonBg
                b.TextColor3 = Theme.TextPrimary
                bs.Color = Theme.CardBorder
            end)
            return b
        end

        do
            local _, body = makeFloat("Configs", 210, 300, UDim2.new(0.5, WIN_W/2 + 14, 0.5, -WIN_H/2))
            local list = Instance.new("ScrollingFrame")
            list.Size = UDim2.new(1, 0, 1, -36)
            list.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
            list.BorderSizePixel = 0
            list.ScrollBarThickness = 2
            list.ScrollBarImageColor3 = Theme.TextAccent
            list.CanvasSize = UDim2.new(0, 0, 0, 0)
            list.ZIndex = 32
            list.Parent = body
            UILib.stroke(list, Theme.CardBorder, 1, 0)
            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 0)
            layout.Parent = list
            local selected = currentProfileName or "Default"
            local function refreshList()
                for _, c in ipairs(list:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                local profiles = MD.listProfiles()
                for i, name in ipairs(profiles) do
                    local btn = UILib.newButton(list, {
                        Size = UDim2.new(1, 0, 0, 22),
                        BackgroundColor3 = name == selected and Color3.fromRGB(20, 28, 40) or Color3.fromRGB(8, 8, 10),
                        BorderSizePixel = 0,
                        Text = "  " .. name,
                        TextColor3 = name == selected and Theme.TextAccent or Theme.TextSecondary,
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        LayoutOrder = i,
                        ZIndex = 33,
                    })
                    btn.MouseButton1Click:Connect(function()
                        selected = name
                        refreshList()
                    end)
                end
                list.CanvasSize = UDim2.new(0, 0, 0, #profiles * 22)
            end
            refreshList()
            local btnRow = UILib.newFrame(body, {
                Size = UDim2.new(1, 0, 0, 28),
                Position = UDim2.new(0, 0, 1, -28),
                BackgroundTransparency = 1,
                ZIndex = 32,
            })
            flatBtn(btnRow, "Load", 0, 0, 0.25, function()
                if MD.loadProfile(selected) then
                    sendNotification("Configs", "Loaded " .. selected, 2)
                else
                    sendNotification("Configs", "Load failed", 2)
                end
            end)
            flatBtn(btnRow, "Save", 0.25, 0, 0.25, function()
                saveProfile(selected); refreshList(); MD.sendNotification("Configs", "Saved " .. selected, 2)
            end)
            flatBtn(btnRow, "Create", 0.5, 0, 0.25, function()
                local name = "cfg_" .. tostring(math.random(1000, 9999))
                saveProfile(name); selected = name; currentProfileName = name; refreshList()
                sendNotification("Configs", "Created " .. name, 2)
            end)
            flatBtn(btnRow, "Remove", 0.75, 0, 0.25, function()
                if selected == "Default" then MD.sendNotification("Configs", "Can't remove Default", 2); return end
                deleteProfile(selected); selected = "Default"; refreshList(); MD.sendNotification("Configs", "Removed", 2)
            end)
        end

        do
            local _, body = makeFloat("Player List", 240, 280, UDim2.new(0.5, -WIN_W/2 - 254, 0.5, -WIN_H/2 + 40))
            local search = UILib.newBox(body, {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = Theme.InputBg, BorderSizePixel = 0,
                PlaceholderText = "Search...", PlaceholderColor3 = Theme.TextDim,
                Text = "", TextColor3 = Theme.TextPrimary, TextSize = 11, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                ClearTextOnFocus = false, ZIndex = 32,
            })
            UILib.corner(search, 6)
            local searchPad = Instance.new("UIPadding")
            searchPad.PaddingLeft = UDim.new(0, 8)
            searchPad.Parent = search
            UILib.stroke(search, Theme.CardBorder, 1, 0.35)
            local list = Instance.new("ScrollingFrame")
            list.Size = UDim2.new(1, 0, 1, -60)
            list.Position = UDim2.new(0, 0, 0, 28)
            list.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
            list.BorderSizePixel = 0
            list.ScrollBarThickness = 2
            list.CanvasSize = UDim2.new(0, 0, 0, 0)
            list.ZIndex = 32
            list.Parent = body
            UILib.stroke(list, Theme.CardBorder, 1, 0)
            local layout = Instance.new("UIListLayout")
            layout.Parent = list
            local selectedPlr = nil
            local empty = UILib.newLabel(list, {
                Size = UDim2.new(1, 0, 0, 40),
                Text = "No players",
                TextColor3 = Theme.TextDim,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                ZIndex = 33,
            })
            local function refreshPlayers(filter)
                for _, c in ipairs(list:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                filter = string.lower(tostring(filter or ""))
                local count = 0
                for _, plr in ipairs(S.Players:GetPlayers()) do
                    if plr ~= player then
                        local name = plr.DisplayName or plr.Name
                        if filter == "" or string.find(string.lower(name), filter, 1, true) then
                            count = count + 1
                            local btn = UILib.newButton(list, {
                                Size = UDim2.new(1, 0, 0, 22),
                                BackgroundColor3 = (selectedPlr == plr) and Color3.fromRGB(20, 28, 40) or Color3.fromRGB(8, 8, 10),
                                BorderSizePixel = 0,
                                Text = "  " .. name,
                                TextColor3 = (selectedPlr == plr) and Theme.TextAccent or Theme.TextSecondary,
                                TextSize = 11,
                                Font = Enum.Font.Gotham,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                LayoutOrder = count,
                                ZIndex = 33,
                            })
                            btn.MouseButton1Click:Connect(function()
                                selectedPlr = plr
                                refreshPlayers(search.Text)
                            end)
                        end
                    end
                end
                empty.Visible = count == 0
                list.CanvasSize = UDim2.new(0, 0, 0, math.max(40, count * 22))
            end
            refreshPlayers("")
            search:GetPropertyChangedSignal("Text"):Connect(function() refreshPlayers(search.Text) end)
            table.insert(allConnections, S.Players.PlayerAdded:Connect(function() refreshPlayers(search.Text) end))
            table.insert(allConnections, S.Players.PlayerRemoving:Connect(function()
                if selectedPlr and not selectedPlr.Parent then selectedPlr = nil end
                refreshPlayers(search.Text)
            end))
            local actions = UILib.newFrame(body, {
                Size = UDim2.new(1, 0, 0, 26),
                Position = UDim2.new(0, 0, 1, -26),
                BackgroundTransparency = 1,
                ZIndex = 32,
            })
            flatBtn(actions, "Teleport", 0, 0, 0.34, function()
                if not selectedPlr or not selectedPlr.Character then
                    sendNotification("Player List", "Select a player", 2); return
                end
                local hrp = selectedPlr.Character:FindFirstChild("HumanoidRootPart")
                local mine = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and mine then mine.CFrame = hrp.CFrame * CFrame.new(0, 0, 3) end
            end)
            flatBtn(actions, "Spectate", 0.34, 0, 0.33, function()
                if not selectedPlr then MD.sendNotification("Player List", "Select a player", 2); return end
                pcall(function()
                    S.Workspace.CurrentCamera.CameraSubject = selectedPlr.Character and selectedPlr.Character:FindFirstChildOfClass("Humanoid") or selectedPlr.Character
                end)
            end)
            flatBtn(actions, "None", 0.67, 0, 0.33, function()
                selectedPlr = nil
                pcall(function()
                    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then S.Workspace.CurrentCamera.CameraSubject = hum end
                end)
                refreshPlayers(search.Text)
            end)
        end

    end)()
    local _setVis = setMenuVisible
    local menuAnimToken = 0
    local floatTweens = {}
    local function playFloatTween(object, duration, properties, style, direction)
        local old = floatTweens[object]
        if old then pcall(function() old:Cancel() end) end
        local tween = UILib.tween(object, duration, properties, style, direction)
        floatTweens[object] = tween
        tween:Play()
    end
    setMenuVisible = function(open)
        menuAnimToken = menuAnimToken + 1
        local token = menuAnimToken
        _setVis(open)
        if topNavDock then topNavDock.Visible = false end
        HB.hubOpen = open
        if not open and not HB.keepBar then HB.panelOpen = {} end
        HB.frame.Visible = open or HB.keepBar
        HB.refresh()
        for i, w in ipairs(floatWins) do
            local sc = w:FindFirstChild(MW_T.floatScale)
            if not sc then
                sc = Instance.new("UIScale")
                sc.Name = MW_T.floatScale
                sc.Scale = 1
                sc.Parent = w
            end
            if open then
                if floatClosed[w] then
                    w.Visible = false
                else
                    w.Visible = true
                    sc.Scale = 0.965
                    w.BackgroundTransparency = 0.62
                    task.delay(0.025 * (i - 1), function()
                        if token ~= menuAnimToken then return end
                        if floatClosed[w] then return end
                        playFloatTween(sc, 0.44, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                        playFloatTween(w, 0.4, {BackgroundTransparency = 0}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                    end)
                end
            else
                local reverseIndex = #floatWins - i
                task.delay(reverseIndex * 0.015, function()
                    if token ~= menuAnimToken then return end
                    playFloatTween(sc, 0.38, {Scale = 0.965}, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
                    playFloatTween(w, 0.34, {BackgroundTransparency = 0.68}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                end)
                task.delay(0.4 + reverseIndex * 0.015, function()
                    if token ~= menuAnimToken then return end
                    sc.Scale = 1
                    w.BackgroundTransparency = 0

                    if HB.panelOpen[w] then return end
                    w.Visible = false
                end)
            end
        end
    end
    HB.isPanelOpen = function(win)
        if HB.panelOpen[win] then return true end
        return HB.hubOpen and not floatClosed[win]
    end
    HB.togglePanel = function(title)
        local win = HB.panels[title]
        if not win then
            sendNotification("Panels", title .. " not loaded", 2)
            return
        end
        if HB.isPanelOpen(win) then
            floatClosed[win] = true
            HB.panelOpen[win] = nil
            win.Visible = false
        else
            floatClosed[win] = nil
            HB.panelOpen[win] = true
            local sc = win:FindFirstChild(MW_T.floatScale)
            if sc then sc.Scale = 1 end
            win.BackgroundTransparency = 0
            win.Visible = true
        end
        HB.refresh()
    end
    HB.hubToggle = function()
        local open = not HB.hubOpen
        HB.keepBar = true
        if not open then HB.panelOpen = {} end
        setMenuVisible(open)
        HB.keepBar = false
    end
    HB.closeAll = function()
        setMenuVisible(false)
    end
    closeMenuBtn.MouseButton1Click:Connect(function()
        setMenuVisible(false)
    end)
    minMenuBtn.MouseButton1Click:Connect(function()
        setMenuVisible(false)
    end)
    MD.setMenuVisible = setMenuVisible
    MD.mainFrame = mainFrame
end
(function()
UILib.Kit = (function()
    local Kit = {}
    Kit.version = 2
    Kit.Motion = { Fast = 0.12, Med = 0.18, Slow = 0.28, Rail = 0.22 }
    function Kit.hover(btn, idle, hover)
        btn.MouseEnter:Connect(function()
            UILib.tween(btn, Kit.Motion.Fast, {BackgroundColor3 = hover}):Play()
        end)
        btn.MouseLeave:Connect(function()
            UILib.tween(btn, Kit.Motion.Fast, {BackgroundColor3 = idle}):Play()
        end)
    end
    function Kit.focusRing(parent, color)
        local s = UILib.stroke(parent, color or Theme.TextAccent, 1, 0.55)
        return s
    end
    function Kit.badge(parent, text, color)
        local b = UILib.newLabel(parent, {
            Size = UDim2.fromOffset(math.max(36, #tostring(text)*6+10), 16),
            BackgroundColor3 = color or Theme.TextAccent,
            BackgroundTransparency = 0.75,
            Text = tostring(text),
            TextColor3 = Theme.TextAccent,
            TextSize = 9,
            Font = Enum.Font.GothamBold,
            ZIndex = (parent.ZIndex or 1) + 2,
        })
        UILib.corner(b, 4)
        return b
    end
    function Kit.divider(parent, y)
        return UILib.newFrame(parent, {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, y),
            BackgroundColor3 = Theme.DividerColor or Theme.CardBorder,
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
        })
    end
    function Kit.section(parent, title, y, w)
        local hdr = UILib.newLabel(parent, {
            Size = UDim2.new(0, w or 200, 0, 18),
            Position = UDim2.new(0, 0, 0, y),
            Text = string.upper(tostring(title)),
            TextColor3 = Theme.TextAccent,
            TextSize = 10,
            Font = Enum.Font.GothamBlack,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        return hdr
    end
    function Kit.info(parent, text, y)
        return UILib.newLabel(parent, {
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 0, 0, y),
            Text = tostring(text),
            TextColor3 = Theme.TextDim,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        })
    end
    function Kit.searchFilter(query, blob)
        query = string.lower(tostring(query or ''))
        if query == '' then return true end
        return string.find(string.lower(tostring(blob or '')), query, 1, true) ~= nil
    end
    function Kit.scaleMenu(frame, scale)
        local us = frame:FindFirstChild('TraceMenuScale')
        if not us then
            us = Instance.new('UIScale')
            us.Name = 'TraceMenuScale'
            us.Parent = frame
        end
        us.Scale = tonumber(scale) or 1
        return us
    end
    function Kit.colorField(parent, label, y, getHex, setHex)
        UILib.newLabel(parent, {Size=UDim2.new(0.4,0,0,14), Position=UDim2.new(0,0,0,y), Text=label, TextColor3=Theme.TextSecondary, TextSize=10, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left})
        local box = UILib.newBox(parent, {Size=UDim2.new(0.5,-22,0,22), Position=UDim2.new(0.42,0,0,y-4), BackgroundColor3=Theme.InputBg, BorderSizePixel=0, Text='#'..tostring(getHex() or 'FFFFFF'), TextColor3=Theme.TextAccent, TextSize=10, Font=Enum.Font.GothamBold, ClearTextOnFocus=false})
        UILib.corner(box, 5)
        local prev = UILib.newFrame(parent, {Size=UDim2.fromOffset(18,18), Position=UDim2.new(1,-18,0,y-2), BackgroundColor3=hexToColor3(getHex()), BorderSizePixel=0})
        UILib.corner(prev, 4)
        box.FocusLost:Connect(function()
            local h = string.gsub(box.Text or '', '#', '')
            if #h == 6 then setHex(string.upper(h)); prev.BackgroundColor3 = hexToColor3(h); if applyCustomTheme then applyCustomTheme() end end
        end)
        return box, prev
    end
    function Kit.clamp01(v) return math.clamp(tonumber(v) or 0, 0, 1) end
    function Kit.clamp(v, lo, hi) return math.clamp(tonumber(v) or lo, lo, hi) end
    function Kit.lerp(a, b, t) return a + (b - a) * t end
    function Kit.hexOk(v) local h=tostring(v or ''):gsub('#',''); return #h==6 end
    function Kit.fmtFps(v) return string.format('%d fps', math.floor(tonumber(v) or 0)) end
    function Kit.fmtPing(v) return string.format('%d ms', math.floor(tonumber(v) or 0)) end
    function Kit.shortName(v, n) n=n or 12; local s=tostring(v or ''); if #s>n then return string.sub(s,1,n-1)..'…' end; return s end
    function Kit.boolOn(v) return v and 'ON' or 'OFF' end
    function Kit.keyName(v) if typeof(v)=='EnumItem' then return v.Name end; return tostring(v or 'None') end
    function Kit.hudChrome(parent, name, w, h, pos)
        local f = UILib.newFrame(parent, {Name=name, Size=UDim2.fromOffset(w,h), Position=pos, BackgroundColor3=Theme.WindowBg or Color3.fromRGB(7,8,11), BackgroundTransparency=0.18, BorderSizePixel=0, ZIndex=40})
        UILib.corner(f, 6)
        local st = UILib.stroke(f, Theme.TextAccent, 1, 0.7)
        table.insert(themeCallbacks, function() f.BackgroundColor3 = Theme.WindowBg or f.BackgroundColor3; st.Color = Theme.TextAccent end)
        return f
    end
    function Kit.openMenuMotion(mainFrame, rail)
        local sc = mainFrame:FindFirstChild('TraceMenuScale')
        local targetScale = tonumber(Settings.UI and Settings.UI.MenuScale) or 1
        if sc then sc.Scale = math.max(0.9, targetScale * 0.96) end
        mainFrame.BackgroundTransparency = 0
        if rail then

            rail.Position = UDim2.new(0, 0, 0, rail.Position.Y.Offset)
            rail.Visible = true
        end
        if sc then UILib.tween(sc, Kit.Motion.Slow, {Scale = targetScale}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play() end
    end
    function Kit.closeMenuMotion(mainFrame)
        local sc = mainFrame:FindFirstChild('TraceMenuScale')
        if sc then UILib.tween(sc, Kit.Motion.Med, {Scale = 0.94}, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play() end
    end
    return Kit
end)()
THEME_PRESETS = {
    Purple = {
        AccentHex = "6759B3",
        BackgroundHex = "16161F",
        SurfaceHex = "181925",
        ToggleHex = "7C6BCF",
        Label = "Purple",
        Role0 = "6759B3",
        Role1 = "6759B3",
        Role2 = "6759B3",
        Role3 = "6759B3",
        Role4 = "6759B3",
        Role5 = "6759B3",
        Role6 = "6759B3",
        Role7 = "6759B3",
        Role8 = "6759B3",
        Role9 = "6759B3",
        Role10 = "6759B3",
        Role11 = "6759B3",
    },
    Informant = {
        AccentHex = "6759B3",
        BackgroundHex = "16161F",
        SurfaceHex = "181925",
        ToggleHex = "7C6BCF",
        Label = "Informant",
        Role0 = "6759B3",
        Role1 = "6759B3",
        Role2 = "6759B3",
        Role3 = "6759B3",
        Role4 = "6759B3",
        Role5 = "6759B3",
        Role6 = "6759B3",
        Role7 = "6759B3",
        Role8 = "6759B3",
        Role9 = "6759B3",
        Role10 = "6759B3",
        Role11 = "6759B3",
    },
    Ice = {
        AccentHex = "7DD3FC",
        BackgroundHex = "07080B",
        SurfaceHex = "0C0D12",
        ToggleHex = "7DD3FC",
        Label = "Ice",
        Role0 = "7DD3FC",
        Role1 = "7DD3FC",
        Role2 = "7DD3FC",
        Role3 = "7DD3FC",
        Role4 = "7DD3FC",
        Role5 = "7DD3FC",
        Role6 = "7DD3FC",
        Role7 = "7DD3FC",
        Role8 = "7DD3FC",
        Role9 = "7DD3FC",
        Role10 = "7DD3FC",
        Role11 = "7DD3FC",
    },
    Graphite = {
        AccentHex = "A8B0BC",
        BackgroundHex = "0A0B0E",
        SurfaceHex = "12141A",
        ToggleHex = "C5CCD6",
        Label = "Graphite",
        Role0 = "A8B0BC",
        Role1 = "A8B0BC",
        Role2 = "A8B0BC",
        Role3 = "A8B0BC",
        Role4 = "A8B0BC",
        Role5 = "A8B0BC",
        Role6 = "A8B0BC",
        Role7 = "A8B0BC",
        Role8 = "A8B0BC",
        Role9 = "A8B0BC",
        Role10 = "A8B0BC",
        Role11 = "A8B0BC",
    },
    BloodAmber = {
        AccentHex = "E8A04A",
        BackgroundHex = "0C0908",
        SurfaceHex = "16100C",
        ToggleHex = "F0B35C",
        Label = "BloodAmber",
        Role0 = "E8A04A",
        Role1 = "E8A04A",
        Role2 = "E8A04A",
        Role3 = "E8A04A",
        Role4 = "E8A04A",
        Role5 = "E8A04A",
        Role6 = "E8A04A",
        Role7 = "E8A04A",
        Role8 = "E8A04A",
        Role9 = "E8A04A",
        Role10 = "E8A04A",
        Role11 = "E8A04A",
    },
    Mint = {
        AccentHex = "6EE7B7",
        BackgroundHex = "070B0A",
        SurfaceHex = "0C1210",
        ToggleHex = "6EE7B7",
        Label = "Mint",
        Role0 = "6EE7B7",
        Role1 = "6EE7B7",
        Role2 = "6EE7B7",
        Role3 = "6EE7B7",
        Role4 = "6EE7B7",
        Role5 = "6EE7B7",
        Role6 = "6EE7B7",
        Role7 = "6EE7B7",
        Role8 = "6EE7B7",
        Role9 = "6EE7B7",
        Role10 = "6EE7B7",
        Role11 = "6EE7B7",
    },
    Steel = {
        AccentHex = "94A3B8",
        BackgroundHex = "08090C",
        SurfaceHex = "10131A",
        ToggleHex = "CBD5E1",
        Label = "Steel",
        Role0 = "94A3B8",
        Role1 = "94A3B8",
        Role2 = "94A3B8",
        Role3 = "94A3B8",
        Role4 = "94A3B8",
        Role5 = "94A3B8",
        Role6 = "94A3B8",
        Role7 = "94A3B8",
        Role8 = "94A3B8",
        Role9 = "94A3B8",
        Role10 = "94A3B8",
        Role11 = "94A3B8",
    },
    Crimson = {
        AccentHex = "F87171",
        BackgroundHex = "0B0708",
        SurfaceHex = "140C0E",
        ToggleHex = "FCA5A5",
        Label = "Crimson",
        Role0 = "F87171",
        Role1 = "F87171",
        Role2 = "F87171",
        Role3 = "F87171",
        Role4 = "F87171",
        Role5 = "F87171",
        Role6 = "F87171",
        Role7 = "F87171",
        Role8 = "F87171",
        Role9 = "F87171",
        Role10 = "F87171",
        Role11 = "F87171",
    },
}
listThemePresets = function()
    local names = {}
    for k in pairs(THEME_PRESETS) do table.insert(names, k) end
    table.sort(names)
    return names
end
applyThemePreset = function(name)
    local p = THEME_PRESETS[name]
    if not p then return false end
    Settings.UI = Settings.UI or {}
    Settings.UI.ThemePreset = name
    Settings.UI.AccentHex = p.AccentHex
    Settings.UI.BackgroundHex = p.BackgroundHex
    Settings.UI.SurfaceHex = p.SurfaceHex
    Settings.UI.ToggleHex = p.ToggleHex
    Settings.ESP = Settings.ESP or {}

    if Settings.ESP.LinkToAccent ~= false then
        Settings.ESP.CloseHex = p.AccentHex
        Settings.ESP.MediumHex = p.ToggleHex or p.AccentHex
        Settings.ESP.FarHex = "DCDDE6"
        Settings.ESP.VeryFarHex = "AFB2BE"
        Settings.ESP.OutlineHex = "D2D2DC"
    end
    if applyCustomTheme then applyCustomTheme() end
    if applyEspPalette then applyEspPalette() end
    if refreshThemeHexFields then refreshThemeHexFields() end
    pcall(function()
        if UILib.TraceDraw and UILib.TraceDraw.syncFromSettings then
            UILib.TraceDraw.syncFromSettings()
        end
    end)
    return true
end
local function preview_Ice(parent, x, y)
    local f = Instance.new('Frame')
    f.Size = UDim2.fromOffset(48, 28)
    f.Position = UDim2.fromOffset(x, y)
    f.BackgroundColor3 = hexToColor3('07080B')
    f.BorderSizePixel = 0
    f.Parent = parent
    local a = Instance.new('Frame')
    a.Size = UDim2.new(0, 10, 1, 0)
    a.BackgroundColor3 = hexToColor3('7DD3FC')
    a.BorderSizePixel = 0
    a.Parent = f
    local s = Instance.new('Frame')
    s.Size = UDim2.new(0, 14, 0, 14)
    s.Position = UDim2.new(1, -18, 0.5, -7)
    s.BackgroundColor3 = hexToColor3('0C0D12')
    s.BorderSizePixel = 0
    s.Parent = f
    return f
end
local function preview_Graphite(parent, x, y)
    local f = Instance.new('Frame')
    f.Size = UDim2.fromOffset(48, 28)
    f.Position = UDim2.fromOffset(x, y)
    f.BackgroundColor3 = hexToColor3('0A0B0E')
    f.BorderSizePixel = 0
    f.Parent = parent
    local a = Instance.new('Frame')
    a.Size = UDim2.new(0, 10, 1, 0)
    a.BackgroundColor3 = hexToColor3('A8B0BC')
    a.BorderSizePixel = 0
    a.Parent = f
    local s = Instance.new('Frame')
    s.Size = UDim2.new(0, 14, 0, 14)
    s.Position = UDim2.new(1, -18, 0.5, -7)
    s.BackgroundColor3 = hexToColor3('12141A')
    s.BorderSizePixel = 0
    s.Parent = f
    return f
end
local function preview_BloodAmber(parent, x, y)
    local f = Instance.new('Frame')
    f.Size = UDim2.fromOffset(48, 28)
    f.Position = UDim2.fromOffset(x, y)
    f.BackgroundColor3 = hexToColor3('0C0908')
    f.BorderSizePixel = 0
    f.Parent = parent
    local a = Instance.new('Frame')
    a.Size = UDim2.new(0, 10, 1, 0)
    a.BackgroundColor3 = hexToColor3('E8A04A')
    a.BorderSizePixel = 0
    a.Parent = f
    local s = Instance.new('Frame')
    s.Size = UDim2.new(0, 14, 0, 14)
    s.Position = UDim2.new(1, -18, 0.5, -7)
    s.BackgroundColor3 = hexToColor3('16100C')
    s.BorderSizePixel = 0
    s.Parent = f
    return f
end
local function preview_Mint(parent, x, y)
    local f = Instance.new('Frame')
    f.Size = UDim2.fromOffset(48, 28)
    f.Position = UDim2.fromOffset(x, y)
    f.BackgroundColor3 = hexToColor3('070B0A')
    f.BorderSizePixel = 0
    f.Parent = parent
    local a = Instance.new('Frame')
    a.Size = UDim2.new(0, 10, 1, 0)
    a.BackgroundColor3 = hexToColor3('6EE7B7')
    a.BorderSizePixel = 0
    a.Parent = f
    local s = Instance.new('Frame')
    s.Size = UDim2.new(0, 14, 0, 14)
    s.Position = UDim2.new(1, -18, 0.5, -7)
    s.BackgroundColor3 = hexToColor3('0C1210')
    s.BorderSizePixel = 0
    s.Parent = f
    return f
end
local function preview_Steel(parent, x, y)
    local f = Instance.new('Frame')
    f.Size = UDim2.fromOffset(48, 28)
    f.Position = UDim2.fromOffset(x, y)
    f.BackgroundColor3 = hexToColor3('08090C')
    f.BorderSizePixel = 0
    f.Parent = parent
    local a = Instance.new('Frame')
    a.Size = UDim2.new(0, 10, 1, 0)
    a.BackgroundColor3 = hexToColor3('94A3B8')
    a.BorderSizePixel = 0
    a.Parent = f
    local s = Instance.new('Frame')
    s.Size = UDim2.new(0, 14, 0, 14)
    s.Position = UDim2.new(1, -18, 0.5, -7)
    s.BackgroundColor3 = hexToColor3('10131A')
    s.BorderSizePixel = 0
    s.Parent = f
    return f
end
local function preview_Crimson(parent, x, y)
    local f = Instance.new('Frame')
    f.Size = UDim2.fromOffset(48, 28)
    f.Position = UDim2.fromOffset(x, y)
    f.BackgroundColor3 = hexToColor3('0B0708')
    f.BorderSizePixel = 0
    f.Parent = parent
    local a = Instance.new('Frame')
    a.Size = UDim2.new(0, 10, 1, 0)
    a.BackgroundColor3 = hexToColor3('F87171')
    a.BorderSizePixel = 0
    a.Parent = f
    local s = Instance.new('Frame')
    s.Size = UDim2.new(0, 14, 0, 14)
    s.Position = UDim2.new(1, -18, 0.5, -7)
    s.BackgroundColor3 = hexToColor3('140C0E')
    s.BorderSizePixel = 0
    s.Parent = f
    return f
end
GUN_PROFILES = {
    Custom = false,
    LegitLite = {FastReload=false,FastFireRate=false,AlwaysAuto=false,NoSpread=false,NoRecoil=false,InfiniteAmmo=false},
    SemiComp = {FastReload=true,FastFireRate=false,AlwaysAuto=false,NoSpread=true,NoRecoil=false,InfiniteAmmo=false},
    RagePack = {FastReload=true,FastFireRate=true,AlwaysAuto=true,NoSpread=true,NoRecoil=true,InfiniteAmmo=true},
    Arena = {FastReload=true,FastFireRate=true,AlwaysAuto=true,NoSpread=true,NoRecoil=false,InfiniteAmmo=false},
    Scout = {FastReload=false,FastFireRate=false,AlwaysAuto=false,NoSpread=true,NoRecoil=true,InfiniteAmmo=false},
    SlotA = {FastReload=true,FastFireRate=false,AlwaysAuto=true,NoSpread=false,NoRecoil=false,InfiniteAmmo=false},
    SlotB = {FastReload=true,FastFireRate=true,AlwaysAuto=false,NoSpread=true,NoRecoil=true,InfiniteAmmo=false},
}
listGunProfiles = function()
    return {'Custom','LegitLite','SemiComp','RagePack','Arena','Scout','SlotA','SlotB'}
end
applyGunProfile = function(name)
    if not Cap.ok('gunmods') then return false, 'locked' end
    Settings.Combat.GunProfile = name
    local p = GUN_PROFILES[name]
    if not p then return true end
    for k, v in pairs(p) do Settings.Combat[k] = v end
    if applyAllGunMods then applyAllGunMods() end
    if not Settings.Combat.InfiniteAmmo and stopInfiniteAmmo then stopInfiniteAmmo() end
    if Settings.Combat.InfiniteAmmo and applyInfiniteAmmo then applyInfiniteAmmo() end
    return true
end
captureGunSlotA = function()
    local snap = {
        FastReload = Settings.Combat.FastReload and true or false,
        FastFireRate = Settings.Combat.FastFireRate and true or false,
        AlwaysAuto = Settings.Combat.AlwaysAuto and true or false,
        NoSpread = Settings.Combat.NoSpread and true or false,
        NoRecoil = Settings.Combat.NoRecoil and true or false,
        InfiniteAmmo = Settings.Combat.InfiniteAmmo and true or false,
    }
    GUN_PROFILES.SlotA = snap
    Settings.Combat.GunProfile = 'SlotA'
    return true
end
captureGunSlotB = function()
    local snap = {
        FastReload = Settings.Combat.FastReload and true or false,
        FastFireRate = Settings.Combat.FastFireRate and true or false,
        AlwaysAuto = Settings.Combat.AlwaysAuto and true or false,
        NoSpread = Settings.Combat.NoSpread and true or false,
        NoRecoil = Settings.Combat.NoRecoil and true or false,
        InfiniteAmmo = Settings.Combat.InfiniteAmmo and true or false,
    }
    GUN_PROFILES.SlotB = snap
    Settings.Combat.GunProfile = 'SlotB'
    return true
end
captureGunSlotC = function()
    local snap = {
        FastReload = Settings.Combat.FastReload and true or false,
        FastFireRate = Settings.Combat.FastFireRate and true or false,
        AlwaysAuto = Settings.Combat.AlwaysAuto and true or false,
        NoSpread = Settings.Combat.NoSpread and true or false,
        NoRecoil = Settings.Combat.NoRecoil and true or false,
        InfiniteAmmo = Settings.Combat.InfiniteAmmo and true or false,
    }
    GUN_PROFILES.SlotC = snap
    Settings.Combat.GunProfile = 'SlotC'
    return true
end
captureGunSlotD = function()
    local snap = {
        FastReload = Settings.Combat.FastReload and true or false,
        FastFireRate = Settings.Combat.FastFireRate and true or false,
        AlwaysAuto = Settings.Combat.AlwaysAuto and true or false,
        NoSpread = Settings.Combat.NoSpread and true or false,
        NoRecoil = Settings.Combat.NoRecoil and true or false,
        InfiniteAmmo = Settings.Combat.InfiniteAmmo and true or false,
    }
    GUN_PROFILES.SlotD = snap
    Settings.Combat.GunProfile = 'SlotD'
    return true
end
TraceHUD = (function()
    local HUD = {entries={}, feed={}, specs={}, binds={}, fps=0, ping=0, last=0}
    local root, watermark, bindList, specList, hitFeed, statsLbl
    local started = false
    local function posFor(kind)
        local map = {
            TopLeft = UDim2.new(0, 12, 0, 10),
            TopRight = UDim2.new(1, -220, 0, 10),
            Right = UDim2.new(1, -200, 0.35, 0),
            Left = UDim2.new(0, 12, 0.35, 0),
            BottomLeft = UDim2.new(0, 12, 1, -120),
        }
        return map[kind] or map.TopLeft
    end
    function HUD.mount(screenGui)
        if root and root.Parent then return root end
        root = UILib.newFrame(screenGui, {Name='TraceHUD', Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ZIndex=35})

        watermark = UILib.Kit.hudChrome(root, 'Watermark', 420, 26, posFor(Settings.HUD and Settings.HUD.WatermarkPos or 'TopLeft'))
        local wmLbl = UILib.newLabel(watermark, {Size=UDim2.new(1,-12,1,0), Position=UDim2.new(0,10,0,0), Text='Melo 🍃', TextColor3=Theme.TextAccent, TextSize=11, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=41})
        HUD._wmLbl = wmLbl
        bindList = UILib.Kit.hudChrome(root, 'Keybinds', 180, 140, posFor(Settings.HUD and Settings.HUD.KeybindPos or 'Right'))
        bindList.Visible = false
        UILib.newLabel(bindList, {Size=UDim2.new(1,-8,0,16), Position=UDim2.new(0,6,0,4), Text='BINDS', TextColor3=Theme.TextAccent, TextSize=10, Font=Enum.Font.GothamBlack, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=41})
        HUD._bindBody = UILib.newLabel(bindList, {Size=UDim2.new(1,-10,1,-22), Position=UDim2.new(0,6,0,20), Text='', TextColor3=Theme.TextSecondary, TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, ZIndex=41})
        specList = UILib.Kit.hudChrome(root, 'Spectators', 220, 168, posFor(Settings.HUD and Settings.HUD.SpectatorPos or 'TopRight'))
        specList.Visible = false
        local specAccent = Instance.new('Frame')
        specAccent.Size = UDim2.new(0, 3, 1, -10)
        specAccent.Position = UDim2.new(0, 4, 0, 5)
        specAccent.BackgroundColor3 = Theme.TextAccent
        specAccent.BorderSizePixel = 0
        specAccent.ZIndex = 42
        specAccent.Parent = specList
        Instance.new('UICorner', specAccent).CornerRadius = UDim.new(0, 2)
        HUD._specAccent = specAccent
        UILib.newLabel(specList, {Size=UDim2.new(1,-18,0,16), Position=UDim2.new(0,12,0,5), Text='NEARBY', TextColor3=Theme.TextAccent, TextSize=11, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=41})
        HUD._specBody = UILib.newLabel(specList, {Size=UDim2.new(1,-18,1,-28), Position=UDim2.new(0,12,0,24), Text='', TextColor3=Theme.TextSecondary, TextSize=12, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, TextStrokeTransparency=0.55, ZIndex=41})
        hitFeed = nil
        HUD._feedBody = nil
        statsLbl = nil
        table.insert(themeCallbacks, function()
            if HUD._wmLbl then HUD._wmLbl.TextColor3 = Theme.TextAccent end
            if HUD._specAccent then HUD._specAccent.BackgroundColor3 = Theme.TextAccent end
        end)
        return root
    end
    function HUD.pushFeed(kind, name, detail)

        table.insert(HUD.feed, 1, string.format('[%s] %s', tostring(kind), tostring(name or '?')))
        while #HUD.feed > 6 do table.remove(HUD.feed) end
    end
    function HUD.destroy()
        started = false
        if root then pcall(function() root:Destroy() end) end
        root = nil
    end
    local function collectBinds()
        local kb = Settings.Keybinds or {}
        local rows = {}
        local order = {'ToggleGUI','PanicKey'}
        if MW.allows("aim") then
            table.insert(order, 'CycleTarget')
            table.insert(order, 'ToggleTriggerBot')
            table.insert(order, 'ToggleRageBot')
        end
        table.insert(order, 'ToggleFly')
        if MW.allows("autoTp") then table.insert(order, 'ToggleAutoTP') end
        table.insert(order, 'ToggleNoclip')
        table.insert(order, 'ClickTP')
        if MW.allows("obby") then table.insert(order, 'ToggleAutoObby') end
        for _, k in ipairs(order) do
            local v = kb[k]
            if v and v ~= Enum.KeyCode.Unknown then
                table.insert(rows, string.format('%s  %s', UILib.Kit.keyName(v), k:gsub('Toggle','')))
            end
        end
        return table.concat(rows, '\n')
    end
    local function collectNearby()
        local myChar = player.Character
        local myHRP = myChar and myChar:FindFirstChild('HumanoidRootPart')
        if not myHRP then return 'no character' end
        local rows = {}
        for _, plr in ipairs(S.Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local hrp = plr.Character:FindFirstChild('HumanoidRootPart')
                local hum = plr.Character:FindFirstChildOfClass('Humanoid')
                if hrp and hum and hum.Health > 0 then
                    local d = (hrp.Position - myHRP.Position).Magnitude
                    if d < 120 then
                        local team = (isSameTeam and isSameTeam(player, plr)) and 'T' or 'E'
                        table.insert(rows, {
                            d = d,
                            n = getDisplayName and getDisplayName(plr) or plr.DisplayName,
                            hp = math.floor(hum.Health),
                            team = team,
                        })
                    end
                end
            end
        end
        table.sort(rows, function(a,b) return a.d < b.d end)
        local out = {}
        for i = 1, math.min(8, #rows) do
            local r = rows[i]
            table.insert(out, string.format('%s  %s  %dhp  %.0fm', r.team, UILib.Kit.shortName(r.n, 12), r.hp, r.d))
        end
        if #out == 0 then return 'clear' end
        return table.concat(out, '\n')
    end
    function HUD.tick(dt)
        if not root or not Settings.HUD then return end
        HUD.last = HUD.last + (dt or 0)
        HUD.fps = UILib.sampleVisualFps and UILib.sampleVisualFps(dt) or HUD.fps
        if HUD.last < 0.2 then return end
        HUD.last = 0
        pcall(function()
            local ok, ping = pcall(function() return math.floor(player:GetNetworkPing()*1000) end)
            if ok then HUD.ping = ping end
        end)
        local showWm = false
        if watermark then watermark.Visible = false end
        if showWm and HUD._wmLbl then
            local bits = {'Melo 🍃', 'v'..tostring(MW.version)}
            if Settings.HUD.ShowExecutor ~= false then table.insert(bits, getExecutorName and getExecutorName() or 'exec') end
            if Settings.HUD.ShowFPS ~= false then table.insert(bits, UILib.Kit.fmtFps(HUD.fps)) end
            if Settings.HUD.ShowPing ~= false then table.insert(bits, UILib.Kit.fmtPing(HUD.ping)) end
            table.insert(bits, MW.isArsenal and 'Arsenal' or 'Universal')
            HUD._wmLbl.Text = table.concat(bits, '  ·  ')
            watermark.Position = posFor(Settings.HUD.WatermarkPos or 'TopLeft')
        end
        bindList.Visible = Settings.HUD.KeybindList == true
        if bindList.Visible then
            bindList.Position = posFor(Settings.HUD.KeybindPos or 'Right')
            HUD._bindBody.Text = collectBinds()
        end
        specList.Visible = Settings.HUD.SpectatorList == true
        if specList.Visible then
            specList.Position = posFor(Settings.HUD.SpectatorPos or 'TopRight')
            HUD._specBody.Text = collectNearby()
        end
        if statsLbl then
            statsLbl.Visible = false
        end
    end
    function HUD.start(screenGui)
        HUD.mount(screenGui)
        if started then return end
        started = true
        table.insert(allConnections, S.RunService.RenderStepped:Connect(function(dt)
            if isUnloading or _G[MW_T.unloaded] then return end
            HUD.tick(dt)
        end))
    end
    return HUD
end)()
TraceConfig = (function()
    local C = {}
    function C.exportJSON(name)
        if not Cap.ok('filesystem') and not Cap.ok('clipboard') then return nil, 'locked' end
        local ok, data = pcall(function()
            if listProfiles and loadProfile then

                return game:GetService('HttpService'):JSONEncode({
                    name = name or 'export',
                    version = MW.version,
                    place = game.PlaceId,
                    aim = Settings.Aimbot,
                    combat = Settings.Combat,
                    esp = Settings.ESP,
                    ui = Settings.UI,
                    hud = Settings.HUD,
                    keybinds = Settings.Keybinds,
                    visuals = Settings.Visuals,
                    misc = Settings.Misc,
                    audio = Settings.Audio,
                })
            end
            return nil
        end)
        if not ok then return nil, tostring(data) end
        return data
    end
    function C.copyExport(name)
        local data, err = C.exportJSON(name)
        if not data then return false, err end
        if setclipboard and Cap.ok('clipboard') then
            pcall(setclipboard, data)
            return true
        end
        return false, 'no clipboard'
    end
    function C.duplicateProfile(src, dst)
        if not Cap.ok('filesystem') then return false, 'locked' end
        if not loadProfile or not saveProfile then return false, 'api' end
        if not loadProfile(src) then return false, 'load' end
        saveProfile(dst)
        return true
    end
    function C.renameProfile(src, dst)
        local ok, err = C.duplicateProfile(src, dst)
        if not ok then return false, err end
        if src ~= 'Default' and deleteProfile then deleteProfile(src) end
        return true
    end
    function C.setAutosave(on)
        Settings.UI.Autosave = on and true or false
    end
    function C.maybeAutosave()
        if Settings.UI and Settings.UI.Autosave and saveProfile then
            pcall(saveProfile, currentProfileName or 'Default')
        end
    end
    return C
end)()
TraceInfo = (function()
    local I = {}
    function I.modeLabel()
        return MW.mode or (MW.isArsenal and 'Arsenal' or 'Universal')
    end
    function I.kitSummary()
        return MW.kitSummary and MW.kitSummary() or ''
    end
    function I.capLines()
        local feats = {'http','filesystem','clipboard','drawing','hooks','getgc','gunmods'}
        local out = {}
        for _, f in ipairs(feats) do
            local ok = Cap.ok(f)
            local why = Cap.why and Cap.why(f) or nil
            table.insert(out, string.format('%s: %s%s', f, ok and 'ok' or 'LOCK', why and (' ('..tostring(why)..')') or ''))
        end
        return out
    end
    function I.summary()
        return string.format('Melo 🍃 %s · %s · Place %s · Exec %s', tostring(MW.display), I.modeLabel(), tostring(game.PlaceId), tostring(getExecutorName and getExecutorName() or '?'))
    end
    return I
end)()
TraceCombatEx = (function()
    local X = {}
    X.priorities = {'Closest','LowestHP','Crosshair','Threat'}
    function X.setPriority(v)
        if table.find(X.priorities, v) then Settings.Aimbot.TargetPriority = v; return true end
        return false
    end
    function X.triggerDelay()
        local base = math.max(0.03, Settings.Combat.TriggerDelay or 0.05)
        local j = tonumber(Settings.Combat.TriggerJitter) or 0
        if j <= 0 then return base end
        local span = base * math.clamp(j, 0, 1)
        return math.max(0.03, base + (math.random() * 2 - 1) * span)
    end
    function X.rageCadence()
        local bursts = math.clamp(tonumber(Settings.Combat.RageShootBursts) or 6, 1, 20)
        local delay = math.max(0.04, Settings.Combat.RageDelay or 0.12)
        return bursts, delay
    end
    function X.multipointWeight()
        return math.clamp(tonumber(Settings.Aimbot.MultipointWeight) or 0.55, 0.05, 1)
    end
    function X.sortRageTargets(list)
        local mode = Settings.Combat.RageCycleMode or 'Nearest'
        table.sort(list, function(a, b)
            if mode == 'LowestHP' then
                return (a.hp or 100) < (b.hp or 100)
            elseif mode == 'Furthest' then
                return (a.dist or 0) > (b.dist or 0)
            end
            return (a.dist or 0) < (b.dist or 0)
        end)
        return list
    end
    return X
end)()
TraceLoaderRailSilhouette = function(parent, accent)

    return nil
end
TRACE_HUD_LAYOUTS = {
    Compact = { WatermarkPos='TopLeft', KeybindPos='Right', SpectatorPos='TopRight' },
    Streamer = { WatermarkPos='BottomLeft', KeybindPos='Left', SpectatorPos='TopRight' },
    Arena = { WatermarkPos='TopLeft', KeybindPos='Right', SpectatorPos='Left' },
    Minimal = { WatermarkPos='TopLeft', KeybindPos='Right', SpectatorPos='TopRight' },
    CombatFocus = { WatermarkPos='TopRight', KeybindPos='Left', SpectatorPos='BottomLeft' },
    CornerStack = { WatermarkPos='TopLeft', KeybindPos='TopRight', SpectatorPos='Right' },
}
applyHudLayout = function(name)
    local L = TRACE_HUD_LAYOUTS[name]
    if not L then return false end
    Settings.HUD = Settings.HUD or {}
    for k,v in pairs(L) do Settings.HUD[k]=v end
    return true
end
STICKY_PROFILES = {
    Glue = { StickyAim=true, Multipoint=true, MultipointWeight=0.75 },
    Soft = { StickyAim=true, Multipoint=false, MultipointWeight=0.4 },
    Flick = { StickyAim=false, Multipoint=true, MultipointWeight=0.6 },
    HybridHold = { StickyAim=true, Multipoint=true, MultipointWeight=0.55 },
    Release = { StickyAim=false, Multipoint=false, MultipointWeight=0.35 },
}
applyStickyProfile = function(name)
    local p = STICKY_PROFILES[name]
    if not p then return false end
    for k,v in pairs(p) do Settings.Aimbot[k]=v end
    return true
end
MENU_SCALES = { Compact = 0.85, Normal = 1.0, Large = 1.15 }
applyMenuScalePreset = function(name)
    local s = MENU_SCALES[name]
    if not s then return false end
    Settings.UI.MenuScale = s
    if guiMainFrame and UILib.Kit then UILib.Kit.scaleMenu(guiMainFrame, s) end
    return true
end
local THEME_ROLE_KEYS = {
    "Accent",
    "Background",
    "Surface",
    "Toggle",
    "Warn",
    "Success",
    "Danger",
    "Muted",
    "Border",
    "Card",
    "Rail",
    "Text",
}
local themeRoleSwatch = {}
for __i = 0, 39 do
    themeRoleSwatch[__i] = function(parent, color, x, y)
        local f = Instance.new('Frame')
        f.Size = UDim2.fromOffset(16, 16)
        f.Position = UDim2.fromOffset(x, y)
        f.BackgroundColor3 = color
        f.BorderSizePixel = 0
        f.Parent = parent
        local c = Instance.new('UICorner'); c.CornerRadius = UDim.new(0, 3); c.Parent = f
        return f
    end
end
local function themeRoleSwatchAt(i, parent, color, x, y)
    local fn = themeRoleSwatch[i]
    if fn then return fn(parent, color, x, y) end
end
TraceV2BindMD = function(MD)
    if not MD then return end
    MD.TraceHUD = TraceHUD
    MD.TraceConfig = TraceConfig
    MD.TraceInfo = TraceInfo
    MD.TraceCombatEx = TraceCombatEx
    MD.applyThemePreset = applyThemePreset
    MD.applyGunProfile = applyGunProfile
    MD.applyHudLayout = applyHudLayout
    MD.applyStickyProfile = applyStickyProfile
    MD.applyMenuScalePreset = applyMenuScalePreset
    MD.listGunProfiles = listGunProfiles
    MD.listThemePresets = listThemePresets
    MD.captureGunSlotA = captureGunSlotA
    MD.captureGunSlotB = captureGunSlotB
    MD.captureGunSlotC = captureGunSlotC
    MD.captureGunSlotD = captureGunSlotD
end
TraceExpand = (function()
    local E = { version = 2 }
    E.Session = {
        started = os.clock(),
        shots = 0, hits = 0, headshots = 0,
        locks = 0, triggerFires = 0, rageCycles = 0,
        hops = 0, profilesLoaded = 0,
        lastTarget = nil,
    }
    function E.Session.noteShot() E.Session.shots = E.Session.shots + 1 end
    function E.Session.noteHit(head)
        E.Session.hits = E.Session.hits + 1
        if head then E.Session.headshots = E.Session.headshots + 1 end
        if TraceHUD and TraceHUD.pushFeed then TraceHUD.pushFeed('HIT', head and 'HS' or 'Bodyshot') end
    end
    function E.Session.noteLock(name)
        E.Session.locks = E.Session.locks + 1
        E.Session.lastTarget = name
    end
    function E.Session.uptime()
        return math.floor(os.clock() - E.Session.started)
    end
    function E.Session.accuracy()
        if E.Session.shots <= 0 then return 0 end
        return math.floor((E.Session.hits / E.Session.shots) * 100)
    end
    function E.Session.summary()
        return string.format('up %ds · acc %d%% · locks %d · trig %d', E.Session.uptime(), E.Session.accuracy(), E.Session.locks, E.Session.triggerFires)
    end
    E.HitMarkers = { pool = {}, active = {}, max = 12 }
    function E.HitMarkers.mount(parent)
        E.HitMarkers.root = UILib.newFrame(parent, {Name='HitMarkers', Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ZIndex=45})
        for i = 1, E.HitMarkers.max do
            local m = UILib.newLabel(E.HitMarkers.root, {Size=UDim2.fromOffset(24,24), AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), Text='+', TextColor3=Theme.TextAccent, TextSize=18, Font=Enum.Font.GothamBlack, BackgroundTransparency=1, Visible=false, ZIndex=46})
            E.HitMarkers.pool[i] = m
        end
    end
    function E.HitMarkers.spawn(sx, sy, head)
        if not E.HitMarkers.root then return end
        local m
        for i = 1, E.HitMarkers.max do
            if not E.HitMarkers.pool[i].Visible then m = E.HitMarkers.pool[i]; break end
        end
        if not m then m = E.HitMarkers.pool[1] end
        m.Text = head and '✕' or '+'
        m.TextColor3 = head and Color3.fromRGB(255, 180, 90) or Theme.TextAccent
        m.Position = UDim2.fromOffset(sx, sy)
        m.TextTransparency = 0
        m.Visible = true
        UILib.tween(m, 0.35, {TextTransparency = 1, Position = UDim2.fromOffset(sx, sy - 28)}):Play()
        task.delay(0.38, function() m.Visible = false end)
    end
    E.WeaponFilter = {}
    function E.WeaponFilter.parse(listStr)
        local out = {}
        for part in string.gmatch(tostring(listStr or ''), '[^,]+') do
            local n = string.lower(string.gsub(part, '^%s*(.-)%s*$', '%1'))
            if n ~= '' then out[n] = true end
        end
        return out
    end
    function E.WeaponFilter.currentToolName()
        local char = player.Character
        local tool = char and char:FindFirstChildOfClass('Tool')
        return tool and string.lower(tool.Name) or nil
    end
    function E.WeaponFilter.isDenied()
        local name = E.WeaponFilter.currentToolName()
        if not name then return false end
        local deny = E.WeaponFilter.parse(Settings.Combat.TriggerWeaponBlacklist)
        return deny[name] == true
    end
    function E.WeaponFilter.describe()
        local deny = E.WeaponFilter.parse(Settings.Combat.TriggerWeaponBlacklist)
        local n = 0; for _ in pairs(deny) do n = n + 1 end
        return n .. ' denied'
    end
    E.WeaponCatalog = {
        "AK-47",
        "M4A1",
        "SPAS-12",
        "Desert Eagle",
        "Glock",
        "AWP",
        "Scout",
        "MP5",
        "P90",
        "UMP",
        "Famas",
        "Galil",
        "AUG",
        "SG553",
        "MAC-10",
        "Tec-9",
        "CZ75",
        "R8",
        "Negev",
        "M249",
        "Nova",
        "XM1014",
        "MAG-7",
        "Sawed-Off",
        "SSG08",
        "SCAR-20",
        "G3SG1",
        "PP-Bizon",
        "MP7",
        "MP9",
        "Dual Berettas",
        "Five-SeveN",
        "P250",
        "USP-S",
        "P2000",
        "Revolver",
        "Knife",
        "Handgun",
        "Rifle",
        "SMG",
        "Minigun",
        "RPG",
        "Flamethrower",
        "Crossbow",
        "Bow",
        "Laser Rifle",
        "Plasma",
        "Tactical Shotgun",
        "Burst Rifle",
        "Sniper",
    }
    function E.WeaponFilter.suggest(prefix)
        prefix = string.lower(tostring(prefix or ''))
        local hits = {}
        for _, n in ipairs(E.WeaponCatalog) do
            if prefix == '' or string.find(string.lower(n), prefix, 1, true) then
                table.insert(hits, n)
                if #hits >= 8 then break end
            end
        end
        return hits
    end
    E.Motion = {
        Quad_In = { style = Enum.EasingStyle.Quad, dir = Enum.EasingDirection.In },
        Quad_Out = { style = Enum.EasingStyle.Quad, dir = Enum.EasingDirection.Out },
        Quad_InOut = { style = Enum.EasingStyle.Quad, dir = Enum.EasingDirection.InOut },
        Quint_In = { style = Enum.EasingStyle.Quint, dir = Enum.EasingDirection.In },
        Quint_Out = { style = Enum.EasingStyle.Quint, dir = Enum.EasingDirection.Out },
        Quint_InOut = { style = Enum.EasingStyle.Quint, dir = Enum.EasingDirection.InOut },
        Cubic_In = { style = Enum.EasingStyle.Cubic, dir = Enum.EasingDirection.In },
        Cubic_Out = { style = Enum.EasingStyle.Cubic, dir = Enum.EasingDirection.Out },
        Cubic_InOut = { style = Enum.EasingStyle.Cubic, dir = Enum.EasingDirection.InOut },
        Sine_In = { style = Enum.EasingStyle.Sine, dir = Enum.EasingDirection.In },
        Sine_Out = { style = Enum.EasingStyle.Sine, dir = Enum.EasingDirection.Out },
        Sine_InOut = { style = Enum.EasingStyle.Sine, dir = Enum.EasingDirection.InOut },
        Back_In = { style = Enum.EasingStyle.Back, dir = Enum.EasingDirection.In },
        Back_Out = { style = Enum.EasingStyle.Back, dir = Enum.EasingDirection.Out },
        Back_InOut = { style = Enum.EasingStyle.Back, dir = Enum.EasingDirection.InOut },
        Bounce_In = { style = Enum.EasingStyle.Bounce, dir = Enum.EasingDirection.In },
        Bounce_Out = { style = Enum.EasingStyle.Bounce, dir = Enum.EasingDirection.Out },
        Bounce_InOut = { style = Enum.EasingStyle.Bounce, dir = Enum.EasingDirection.InOut },
        Elastic_In = { style = Enum.EasingStyle.Elastic, dir = Enum.EasingDirection.In },
        Elastic_Out = { style = Enum.EasingStyle.Elastic, dir = Enum.EasingDirection.Out },
        Elastic_InOut = { style = Enum.EasingStyle.Elastic, dir = Enum.EasingDirection.InOut },
        Circular_In = { style = Enum.EasingStyle.Circular, dir = Enum.EasingDirection.In },
        Circular_Out = { style = Enum.EasingStyle.Circular, dir = Enum.EasingDirection.Out },
        Circular_InOut = { style = Enum.EasingStyle.Circular, dir = Enum.EasingDirection.InOut },
        Exponential_In = { style = Enum.EasingStyle.Exponential, dir = Enum.EasingDirection.In },
        Exponential_Out = { style = Enum.EasingStyle.Exponential, dir = Enum.EasingDirection.Out },
        Exponential_InOut = { style = Enum.EasingStyle.Exponential, dir = Enum.EasingDirection.InOut },
        Linear_In = { style = Enum.EasingStyle.Linear, dir = Enum.EasingDirection.In },
        Linear_Out = { style = Enum.EasingStyle.Linear, dir = Enum.EasingDirection.Out },
        Linear_InOut = { style = Enum.EasingStyle.Linear, dir = Enum.EasingDirection.InOut },
    }
    function E.Motion.play(obj, key, t, props)
        local m = E.Motion[key] or E.Motion.Quint_Out
        return UILib.tween(obj, t or 0.22, props, m.style, m.dir)
    end
    E.Schema = {}
    E.Schema.AimbotKeys = {
        "Enabled",
        "Toggle",
        "StickyAim",
        "AimMode",
        "SilentHitboxSize",
        "SilentHitbox",
        "SilentFOVOnly",
        "LockPart",
        "Smoothness",
        "SmoothProfile",
        "FOVRadius",
        "ShowFOV",
        "FOVOpacity",
        "ShowSilentFOV",
        "SilentFOVRadius",
        "RequireLOS",
        "Prediction",
        "PredictionAmount",
        "PredictionAccel",
        "HitChance",
        "Multipoint",
        "MaxDistance",
        "MultiTarget",
        "TargetPriority",
        "MultipointWeight",
    }
    E.Schema.CombatKeys = {
        "FastReload",
        "FastFireRate",
        "AlwaysAuto",
        "NoSpread",
        "NoRecoil",
        "InfiniteAmmo",
        "TriggerBot",
        "TriggerDelay",
        "TriggerJitter",
        "TriggerRequireLOS",
        "TriggerHeadOnly",
        "TriggerRequireADS",
        "TriggerBurstCount",
        "TriggerBurstGap",
        "TriggerWeaponBlacklist",
        "RageBot",
        "RageDelay",
        "RageShoot",
        "RageTPDistance",
        "RageCycleMode",
        "RageShootBursts",
        "GunProfile",
    }
    E.Schema.HUDKeys = {
        "Watermark",
        "WatermarkPos",
        "KeybindList",
        "KeybindPos",
        "SpectatorList",
        "SpectatorPos",
        "HitFeed",
        "HitFeedMax",
        "SessionStats",
        "ShowPing",
        "ShowFPS",
        "ShowExecutor",
    }
    function E.Schema.validateSection(section, keys)
        section = section or {}
        local missing = {}
        for _, k in ipairs(keys) do
            if section[k] == nil then table.insert(missing, k) end
        end
        return missing
    end
    function E.Schema.report()
        return {
            aim = E.Schema.validateSection(Settings.Aimbot, E.Schema.AimbotKeys),
            combat = E.Schema.validateSection(Settings.Combat, E.Schema.CombatKeys),
            hud = E.Schema.validateSection(Settings.HUD, E.Schema.HUDKeys),
        }
    end
    E.Tips = {
        "RightCtrl toggles the Melo 🍃 hub.",
        "Rail Aim page holds aimbot, FOV, trigger, and rage.",
        "Gun mods stay Cap-locked on Xeno, Solara, and non-Arsenal.",
        "Theme Studio presets keep Melo 🍃 ice-cyan brand by default.",
        "HUD watermark can show FPS, ping, and executor name.",
        "Export JSON copies a Settings snapshot to clipboard when Cap allows.",
        "Silent FOV ring is optional: enable Show Silent FOV under Aim.",
        "Target Priority Threat mixes distance with crosshair score.",
        "Autosave writes the active profile after changes when enabled.",
        "Unload cleans menu blur, HUD overlays, and ESP pools.",
        "Universal mode keeps ESP/aim; Arsenal unlocks gunmod hooks.",
        "Sticky profiles tweak Multipoint weight without resetting FOV packs.",
        "Menu Scale Compact/Normal/Large uses UIScale on the hub frame.",
        "Hit feed listens to session kill hooks when available.",
        "Config duplicate creates name_copy beside the active profile.",
        "Panic key disables combat features without full unload.",
        "Nearby strip lists players within 80 studs for awareness.",
        "Rage Cycle Mode can prefer lowest HP targets.",
        "Trigger jitter randomizes delay to reduce cadence patterns.",
        "Script Info lists PlaceId mode and Cap lock reasons.",
    }
    function E.Tips.random()
        return E.Tips[math.random(1, #E.Tips)]
    end
    E.Color = {}
    function E.Color.lighten(c, amt)
        return Color3.new(math.clamp(c.R + amt, 0, 1), math.clamp(c.G + amt, 0, 1), math.clamp(c.B + amt, 0, 1))
    end
    E.Layouts = {}
    E.Layouts.Recipe1 = {
        id = 1,
        rail = 76,
        winW = 708,
        winH = 510,
        cardGap = 9,
        accentAlpha = 0.37,
    }
    E.Layouts.Recipe2 = {
        id = 2,
        rail = 80,
        winW = 716,
        winH = 520,
        cardGap = 10,
        accentAlpha = 0.38999999999999996,
    }
    E.Layouts.Recipe3 = {
        id = 3,
        rail = 84,
        winW = 724,
        winH = 530,
        cardGap = 11,
        accentAlpha = 0.41,
    }
    E.Layouts.Recipe4 = {
        id = 4,
        rail = 88,
        winW = 732,
        winH = 540,
        cardGap = 8,
        accentAlpha = 0.43,
    }
    E.Layouts.Recipe5 = {
        id = 5,
        rail = 72,
        winW = 740,
        winH = 550,
        cardGap = 9,
        accentAlpha = 0.44999999999999996,
    }
    E.Layouts.Recipe6 = {
        id = 6,
        rail = 76,
        winW = 748,
        winH = 500,
        cardGap = 10,
        accentAlpha = 0.47,
    }
    E.Layouts.Recipe7 = {
        id = 7,
        rail = 80,
        winW = 700,
        winH = 510,
        cardGap = 11,
        accentAlpha = 0.49,
    }
    E.Layouts.Recipe8 = {
        id = 8,
        rail = 84,
        winW = 708,
        winH = 520,
        cardGap = 8,
        accentAlpha = 0.51,
    }
    E.Layouts.Recipe9 = {
        id = 9,
        rail = 88,
        winW = 716,
        winH = 530,
        cardGap = 9,
        accentAlpha = 0.53,
    }
    E.Layouts.Recipe10 = {
        id = 10,
        rail = 72,
        winW = 724,
        winH = 540,
        cardGap = 10,
        accentAlpha = 0.35,
    }
    E.Layouts.Recipe11 = {
        id = 11,
        rail = 76,
        winW = 732,
        winH = 550,
        cardGap = 11,
        accentAlpha = 0.37,
    }
    E.Layouts.Recipe12 = {
        id = 12,
        rail = 80,
        winW = 740,
        winH = 500,
        cardGap = 8,
        accentAlpha = 0.38999999999999996,
    }
    E.Layouts.Recipe13 = {
        id = 13,
        rail = 84,
        winW = 748,
        winH = 510,
        cardGap = 9,
        accentAlpha = 0.41,
    }
    E.Layouts.Recipe14 = {
        id = 14,
        rail = 88,
        winW = 700,
        winH = 520,
        cardGap = 10,
        accentAlpha = 0.43,
    }
    E.Layouts.Recipe15 = {
        id = 15,
        rail = 72,
        winW = 708,
        winH = 530,
        cardGap = 11,
        accentAlpha = 0.44999999999999996,
    }
    E.Layouts.Recipe16 = {
        id = 16,
        rail = 76,
        winW = 716,
        winH = 540,
        cardGap = 8,
        accentAlpha = 0.47,
    }
    E.Layouts.Recipe17 = {
        id = 17,
        rail = 80,
        winW = 724,
        winH = 550,
        cardGap = 9,
        accentAlpha = 0.49,
    }
    E.Layouts.Recipe18 = {
        id = 18,
        rail = 84,
        winW = 732,
        winH = 500,
        cardGap = 10,
        accentAlpha = 0.51,
    }
    E.Layouts.Recipe19 = {
        id = 19,
        rail = 88,
        winW = 740,
        winH = 510,
        cardGap = 11,
        accentAlpha = 0.53,
    }
    E.Layouts.Recipe20 = {
        id = 20,
        rail = 72,
        winW = 748,
        winH = 520,
        cardGap = 8,
        accentAlpha = 0.35,
    }
    E.Layouts.Recipe21 = {
        id = 21,
        rail = 76,
        winW = 700,
        winH = 530,
        cardGap = 9,
        accentAlpha = 0.37,
    }
    E.Layouts.Recipe22 = {
        id = 22,
        rail = 80,
        winW = 708,
        winH = 540,
        cardGap = 10,
        accentAlpha = 0.38999999999999996,
    }
    E.Layouts.Recipe23 = {
        id = 23,
        rail = 84,
        winW = 716,
        winH = 550,
        cardGap = 11,
        accentAlpha = 0.41,
    }
    E.Layouts.Recipe24 = {
        id = 24,
        rail = 88,
        winW = 724,
        winH = 500,
        cardGap = 8,
        accentAlpha = 0.43,
    }
    E.Layouts.Recipe25 = {
        id = 25,
        rail = 72,
        winW = 732,
        winH = 510,
        cardGap = 9,
        accentAlpha = 0.44999999999999996,
    }
    E.Layouts.Recipe26 = {
        id = 26,
        rail = 76,
        winW = 740,
        winH = 520,
        cardGap = 10,
        accentAlpha = 0.47,
    }
    E.Layouts.Recipe27 = {
        id = 27,
        rail = 80,
        winW = 748,
        winH = 530,
        cardGap = 11,
        accentAlpha = 0.49,
    }
    E.Layouts.Recipe28 = {
        id = 28,
        rail = 84,
        winW = 700,
        winH = 540,
        cardGap = 8,
        accentAlpha = 0.51,
    }
    E.Layouts.Recipe29 = {
        id = 29,
        rail = 88,
        winW = 708,
        winH = 550,
        cardGap = 9,
        accentAlpha = 0.53,
    }
    E.Layouts.Recipe30 = {
        id = 30,
        rail = 72,
        winW = 716,
        winH = 500,
        cardGap = 10,
        accentAlpha = 0.35,
    }
    E.Layouts.Recipe31 = {
        id = 31,
        rail = 76,
        winW = 724,
        winH = 510,
        cardGap = 11,
        accentAlpha = 0.37,
    }
    E.Layouts.Recipe32 = {
        id = 32,
        rail = 80,
        winW = 732,
        winH = 520,
        cardGap = 8,
        accentAlpha = 0.38999999999999996,
    }
    E.Layouts.Recipe33 = {
        id = 33,
        rail = 84,
        winW = 740,
        winH = 530,
        cardGap = 9,
        accentAlpha = 0.41,
    }
    E.Layouts.Recipe34 = {
        id = 34,
        rail = 88,
        winW = 748,
        winH = 540,
        cardGap = 10,
        accentAlpha = 0.43,
    }
    E.Layouts.Recipe35 = {
        id = 35,
        rail = 72,
        winW = 700,
        winH = 550,
        cardGap = 11,
        accentAlpha = 0.44999999999999996,
    }
    E.Layouts.Recipe36 = {
        id = 36,
        rail = 76,
        winW = 708,
        winH = 500,
        cardGap = 8,
        accentAlpha = 0.47,
    }
    E.Layouts.Recipe37 = {
        id = 37,
        rail = 80,
        winW = 716,
        winH = 510,
        cardGap = 9,
        accentAlpha = 0.49,
    }
    E.Layouts.Recipe38 = {
        id = 38,
        rail = 84,
        winW = 724,
        winH = 520,
        cardGap = 10,
        accentAlpha = 0.51,
    }
    E.Layouts.Recipe39 = {
        id = 39,
        rail = 88,
        winW = 732,
        winH = 530,
        cardGap = 11,
        accentAlpha = 0.53,
    }
    E.Layouts.Recipe40 = {
        id = 40,
        rail = 72,
        winW = 740,
        winH = 540,
        cardGap = 8,
        accentAlpha = 0.35,
    }
    E.Layouts.Recipe41 = {
        id = 41,
        rail = 76,
        winW = 748,
        winH = 550,
        cardGap = 9,
        accentAlpha = 0.37,
    }
    E.Layouts.Recipe42 = {
        id = 42,
        rail = 80,
        winW = 700,
        winH = 500,
        cardGap = 10,
        accentAlpha = 0.38999999999999996,
    }
    E.Layouts.Recipe43 = {
        id = 43,
        rail = 84,
        winW = 708,
        winH = 510,
        cardGap = 11,
        accentAlpha = 0.41,
    }
    E.Layouts.Recipe44 = {
        id = 44,
        rail = 88,
        winW = 716,
        winH = 520,
        cardGap = 8,
        accentAlpha = 0.43,
    }
    E.Layouts.Recipe45 = {
        id = 45,
        rail = 72,
        winW = 724,
        winH = 530,
        cardGap = 9,
        accentAlpha = 0.44999999999999996,
    }
    E.Layouts.Recipe46 = {
        id = 46,
        rail = 76,
        winW = 732,
        winH = 540,
        cardGap = 10,
        accentAlpha = 0.47,
    }
    E.Layouts.Recipe47 = {
        id = 47,
        rail = 80,
        winW = 740,
        winH = 550,
        cardGap = 11,
        accentAlpha = 0.49,
    }
    E.Layouts.Recipe48 = {
        id = 48,
        rail = 84,
        winW = 748,
        winH = 500,
        cardGap = 8,
        accentAlpha = 0.51,
    }
    E.Layouts.Recipe49 = {
        id = 49,
        rail = 88,
        winW = 700,
        winH = 510,
        cardGap = 9,
        accentAlpha = 0.53,
    }
    E.Layouts.Recipe50 = {
        id = 50,
        rail = 72,
        winW = 708,
        winH = 520,
        cardGap = 10,
        accentAlpha = 0.35,
    }
    E.Layouts.Recipe51 = {
        id = 51,
        rail = 76,
        winW = 716,
        winH = 530,
        cardGap = 11,
        accentAlpha = 0.37,
    }
    E.Layouts.Recipe52 = {
        id = 52,
        rail = 80,
        winW = 724,
        winH = 540,
        cardGap = 8,
        accentAlpha = 0.38999999999999996,
    }
    E.Layouts.Recipe53 = {
        id = 53,
        rail = 84,
        winW = 732,
        winH = 550,
        cardGap = 9,
        accentAlpha = 0.41,
    }
    E.Layouts.Recipe54 = {
        id = 54,
        rail = 88,
        winW = 740,
        winH = 500,
        cardGap = 10,
        accentAlpha = 0.43,
    }
    E.Layouts.Recipe55 = {
        id = 55,
        rail = 72,
        winW = 748,
        winH = 510,
        cardGap = 11,
        accentAlpha = 0.44999999999999996,
    }
    E.Layouts.Recipe56 = {
        id = 56,
        rail = 76,
        winW = 700,
        winH = 520,
        cardGap = 8,
        accentAlpha = 0.47,
    }
    E.Layouts.Recipe57 = {
        id = 57,
        rail = 80,
        winW = 708,
        winH = 530,
        cardGap = 9,
        accentAlpha = 0.49,
    }
    E.Layouts.Recipe58 = {
        id = 58,
        rail = 84,
        winW = 716,
        winH = 540,
        cardGap = 10,
        accentAlpha = 0.51,
    }
    E.Layouts.Recipe59 = {
        id = 59,
        rail = 88,
        winW = 724,
        winH = 550,
        cardGap = 11,
        accentAlpha = 0.53,
    }
    E.Layouts.Recipe60 = {
        id = 60,
        rail = 72,
        winW = 732,
        winH = 500,
        cardGap = 8,
        accentAlpha = 0.35,
    }
    E.Layouts.Recipe61 = {
        id = 61,
        rail = 76,
        winW = 740,
        winH = 510,
        cardGap = 9,
        accentAlpha = 0.37,
    }
    E.Layouts.Recipe62 = {
        id = 62,
        rail = 80,
        winW = 748,
        winH = 520,
        cardGap = 10,
        accentAlpha = 0.38999999999999996,
    }
    E.Layouts.Recipe63 = {
        id = 63,
        rail = 84,
        winW = 700,
        winH = 530,
        cardGap = 11,
        accentAlpha = 0.41,
    }
    E.Layouts.Recipe64 = {
        id = 64,
        rail = 88,
        winW = 708,
        winH = 540,
        cardGap = 8,
        accentAlpha = 0.43,
    }
    E.Layouts.Recipe65 = {
        id = 65,
        rail = 72,
        winW = 716,
        winH = 550,
        cardGap = 9,
        accentAlpha = 0.44999999999999996,
    }
    E.Layouts.Recipe66 = {
        id = 66,
        rail = 76,
        winW = 724,
        winH = 500,
        cardGap = 10,
        accentAlpha = 0.47,
    }
    E.Layouts.Recipe67 = {
        id = 67,
        rail = 80,
        winW = 732,
        winH = 510,
        cardGap = 11,
        accentAlpha = 0.49,
    }
    E.Layouts.Recipe68 = {
        id = 68,
        rail = 84,
        winW = 740,
        winH = 520,
        cardGap = 8,
        accentAlpha = 0.51,
    }
    E.Layouts.Recipe69 = {
        id = 69,
        rail = 88,
        winW = 748,
        winH = 530,
        cardGap = 9,
        accentAlpha = 0.53,
    }
    E.Layouts.Recipe70 = {
        id = 70,
        rail = 72,
        winW = 700,
        winH = 540,
        cardGap = 10,
        accentAlpha = 0.35,
    }
    E.Layouts.Recipe71 = {
        id = 71,
        rail = 76,
        winW = 708,
        winH = 550,
        cardGap = 11,
        accentAlpha = 0.37,
    }
    E.Layouts.Recipe72 = {
        id = 72,
        rail = 80,
        winW = 716,
        winH = 500,
        cardGap = 8,
        accentAlpha = 0.38999999999999996,
    }
    E.Layouts.Recipe73 = {
        id = 73,
        rail = 84,
        winW = 724,
        winH = 510,
        cardGap = 9,
        accentAlpha = 0.41,
    }
    E.Layouts.Recipe74 = {
        id = 74,
        rail = 88,
        winW = 732,
        winH = 520,
        cardGap = 10,
        accentAlpha = 0.43,
    }
    E.Layouts.Recipe75 = {
        id = 75,
        rail = 72,
        winW = 740,
        winH = 530,
        cardGap = 11,
        accentAlpha = 0.44999999999999996,
    }
    E.Layouts.Recipe76 = {
        id = 76,
        rail = 76,
        winW = 748,
        winH = 540,
        cardGap = 8,
        accentAlpha = 0.47,
    }
    E.Layouts.Recipe77 = {
        id = 77,
        rail = 80,
        winW = 700,
        winH = 550,
        cardGap = 9,
        accentAlpha = 0.49,
    }
    E.Layouts.Recipe78 = {
        id = 78,
        rail = 84,
        winW = 708,
        winH = 500,
        cardGap = 10,
        accentAlpha = 0.51,
    }
    E.Layouts.Recipe79 = {
        id = 79,
        rail = 88,
        winW = 716,
        winH = 510,
        cardGap = 11,
        accentAlpha = 0.53,
    }
    E.Layouts.Recipe80 = {
        id = 80,
        rail = 72,
        winW = 724,
        winH = 520,
        cardGap = 8,
        accentAlpha = 0.35,
    }
    function E.Layouts.get(id)
        return E.Layouts['Recipe' .. tostring(id)]
    end
    E.BindLabels = {
        ToggleGUI = "Menu",
        PanicKey = "Panic",
        CycleTarget = "Cycle",
        ToggleTriggerBot = "Trigger",
        ToggleRageBot = "Rage",
        ToggleFly = "Fly",
        ToggleNoclip = "Noclip",
        ClickTP = "Click TP",
        ToggleAutoObby = "Auto Obby",
        ToggleAutoTP = "AutoTP",
    }
    function E.BindLabels.formatAll()
        local rows = {}
        for k, label in pairs(E.BindLabels) do
            if k ~= 'formatAll' then
                local v = Settings.Keybinds and Settings.Keybinds[k]
                if v and v ~= Enum.KeyCode.Unknown then
                    table.insert(rows, label .. ': ' .. v.Name)
                end
            end
        end
        table.sort(rows)
        return rows
    end
    E.Spectators = {}
    function E.Spectators.estimate()
        local out = {}
        local myChar = player.Character
        local myHead = myChar and myChar:FindFirstChild('Head')
        if not myHead then return out end
        for _, plr in ipairs(S.Players:GetPlayers()) do
            if plr ~= player then
                local tid = getPlayerTeamId and getPlayerTeamId(plr)
                if isSpectatorTeam and isSpectatorTeam(tid) then
                    table.insert(out, getDisplayName and getDisplayName(plr) or plr.Name)
                else
                    local cam = S.Workspace.CurrentCamera

                    local hum = plr.Character and plr.Character:FindFirstChildOfClass('Humanoid')
                    if hum and hum.Health <= 0 then
                        table.insert(out, (getDisplayName and getDisplayName(plr) or plr.Name) .. ' (dead)')
                    end
                end
            end
        end
        return out
    end
    function E.boot(screenGui)
        if screenGui then E.HitMarkers.mount(screenGui) end
        return true
    end
    return E
end)()
TraceExpand.Color.darken = function(c, amt)
    return Color3.new(math.clamp(c.R - amt, 0, 1), math.clamp(c.G - amt, 0, 1), math.clamp(c.B - amt, 0, 1))
end
TraceExpand.Color.mix = function(a, b, t)
    t = math.clamp(t or 0.5, 0, 1)
    return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end
TraceExpand.AimCurves = {}
TraceExpand.AimCurves.C0 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C1 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C2 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C3 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C4 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C5 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C6 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C7 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C8 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C9 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C10 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C11 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C12 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C13 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C14 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C15 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C16 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C17 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C18 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C19 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C20 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C21 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C22 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C23 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C24 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C25 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C26 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C27 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C28 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C29 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C30 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C31 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C32 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C33 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C34 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C35 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C36 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C37 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C38 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C39 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C40 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C41 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C42 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C43 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C44 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C45 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C46 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C47 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C48 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C49 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C50 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C51 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C52 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C53 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C54 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C55 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C56 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.AimCurves.C57 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t
end
TraceExpand.AimCurves.C58 = function(t)
    t = math.clamp(t, 0, 1)
    return 1 - (1 - t) * (1 - t)
end
TraceExpand.AimCurves.C59 = function(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
TraceExpand.FOVStyles = {
    Thin = { thickness = 1.0, sides = 48, filled = false },
    Bold = { thickness = 2.2, sides = 64, filled = false },
    Soft = { thickness = 1.5, sides = 32, filled = false },
    Precise = { thickness = 1.2, sides = 96, filled = false },
    Arena = { thickness = 1.8, sides = 72, filled = false },
    Ghost = { thickness = 1.0, sides = 40, filled = false },
}
function TraceExpand.applyFOVStyle(name)
    return TraceExpand.FOVStyles[name]
end
TraceExpand.Migrate = {}
TraceExpand.Migrate.v1 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 1
    return settings
end
TraceExpand.Migrate.v2 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 2
    return settings
end
TraceExpand.Migrate.v3 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 3
    return settings
end
TraceExpand.Migrate.v4 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 4
    return settings
end
TraceExpand.Migrate.v5 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 5
    return settings
end
TraceExpand.Migrate.v6 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 6
    return settings
end
TraceExpand.Migrate.v7 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 7
    return settings
end
TraceExpand.Migrate.v8 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 8
    return settings
end
TraceExpand.Migrate.v9 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 9
    return settings
end
TraceExpand.Migrate.v10 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 10
    return settings
end
TraceExpand.Migrate.v11 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 11
    return settings
end
TraceExpand.Migrate.v12 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 12
    return settings
end
TraceExpand.Migrate.v13 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 13
    return settings
end
TraceExpand.Migrate.v14 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 14
    return settings
end
TraceExpand.Migrate.v15 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 15
    return settings
end
TraceExpand.Migrate.v16 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 16
    return settings
end
TraceExpand.Migrate.v17 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 17
    return settings
end
TraceExpand.Migrate.v18 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 18
    return settings
end
TraceExpand.Migrate.v19 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 19
    return settings
end
TraceExpand.Migrate.v20 = function(settings)
    settings = settings or Settings
    settings.UI = settings.UI or {}
    settings.HUD = settings.HUD or {}
    settings.UI._migrated = 20
    return settings
end
function TraceExpand.Migrate.run(settings)
    local s = settings or Settings
    local v = (s.UI and s.UI._migrated) or 0
    for i = v + 1, 20 do
        local fn = TraceExpand.Migrate['v' .. i]
        if fn then fn(s) end
    end
    return s
end
TraceExpand.SearchIndex = {
    Aimbot = {
        "aimbot",
        "silent",
        "fov",
        "trigger",
        "rage",
        "priority",
        "gun profile",
        "sticky",
    },
    ESP = {
        "esp",
        "box",
        "chams",
        "skeleton",
        "tracer",
        "arrow",
        "health",
    },
    General = {
        "speed",
        "fly",
        "hud",
        "visuals",
        "gun mods",
        "server",
        "webhook",
        "third person",
    },
    Audio = {
        "hit sound",
        "kill sound",
        "music",
    },
    Settings = {
        "keybind",
        "theme",
        "config",
        "scale",
        "script info",
        "cap",
    },
    Report = {
        "chat spy",
    },
}
function TraceExpand.SearchIndex.match(page, query)
    query = string.lower(tostring(query or ''))
    if query == '' then return true end
    local keys = TraceExpand.SearchIndex[page] or {}
    for _, k in ipairs(keys) do
        if string.find(k, query, 1, true) then return true end
    end
    return string.find(string.lower(page), query, 1, true) ~= nil
end
function TraceExpand.capPanelText()
    local lines = TraceInfo and TraceInfo.capLines and TraceInfo.capLines() or {}
    table.insert(lines, 1, TraceInfo and TraceInfo.summary() or 'Melo 🍃')
    table.insert(lines, TraceExpand.Tips.random())
    return table.concat(lines, '\n')
end
TraceExpand.CardMetrics = {}
TraceExpand.CardMetrics.toggle = 28
TraceExpand.CardMetrics.slider = 38
TraceExpand.CardMetrics.enum = 56
TraceExpand.CardMetrics.keybind = 28
TraceExpand.CardMetrics.button = 28
TraceExpand.CardMetrics.info = 18
TraceExpand.CardMetrics.divider = 8
TraceExpand.CardMetrics.input = 28
function TraceExpand.estimateCardHeight(rows)
    local h = 6
    for _, r in ipairs(rows or {}) do
        h = h + (TraceExpand.CardMetrics[r[1]] or 24)
    end
    return h
end
TraceExpand.SoundPresets = {
    ClassicHit = "911448825",
    Metal = "12222253",
    Click = "12221967",
    Beep = "131961136",
    Punch = "138083970",
    Laser = "6026984224",
    Soft = "9114224688",
    Heavy = "9113849415",
}
function TraceExpand.applyHitSoundPreset(name)
    local id = TraceExpand.SoundPresets[name]
    if not id then return false end
    Settings.Audio.HitSoundId = id
    return true
end
function TraceExpand.applyKillSoundPreset(name)
    local id = TraceExpand.SoundPresets[name]
    if not id then return false end
    Settings.Audio.KillSoundId = id
    return true
end
TraceExpand.RailMeta = {
    Combat = {
        title = MW.allows("mm2") and "MM2" or (MW.allows("phantomforces") and "PF" or "Aim"),
        blurb = MW.allows("mm2") and "Roles, farm, sheriff tools"
            or (MW.allows("phantomforces") and "Silent aim, camera aim, PF extras"
            or "Aimbot, FOV, trigger, rage"),
    },
    Visuals = { title = "Visuals", blurb = "ESP and world overlays" },
    Player = {
        title = "World",
        blurb = MW.isArsenal and "Movement, HUD, gun mods, misc"
            or (MW.isBrookhaven and "Movement, Brookhaven RP, misc"
            or (MW.allows("phantomforces") and "HUD, lighting, misc (movement locked)"
            or (MW.allows("mm2") and "HUD, lighting, misc"
            or "Movement, Auto Obby, misc"))),
    },
    Audio = {
        title = "Audio",
        blurb = MW.allows("hitKillAudio") and "Hit, kill, music" or "Music player",
    },
    Config = { title = "Config", blurb = "Binds, theme, profiles, Cap" },
}
(function()
    if not UILib.Kit then return end
    function UILib.Kit.pageTitle(parent, title, blurb)
        local t = UILib.newLabel(parent, {Size=UDim2.new(1,-8,0,20), Position=UDim2.new(0,4,0,4), Text=tostring(title), TextColor3=Theme.TextAccent, TextSize=14, Font=Enum.Font.GothamBlack, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12})
        local b = UILib.newLabel(parent, {Size=UDim2.new(1,-8,0,16), Position=UDim2.new(0,4,0,24), Text=tostring(blurb or ''), TextColor3=Theme.TextDim, TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12})
        return t, b
    end
    function UILib.Kit.lockedOverlay(row, reason)
        local f = UILib.newFrame(row, {Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0.55, ZIndex=(row.ZIndex or 1)+5})
        UILib.newLabel(f, {Size=UDim2.new(1,-8,1,0), Position=UDim2.new(0,4,0,0), Text=tostring(reason or 'LOCKED'), TextColor3=Theme.WarnColor or Theme.TextAccent, TextSize=10, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right})
        return f
    end
    function UILib.Kit.pulseAccent_0(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 8 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_1(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 9 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_2(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 10 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_3(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 11 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_4(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 12 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_5(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 8 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_6(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 9 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_7(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 10 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_8(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 11 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_9(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 12 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_10(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 8 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_11(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 9 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_12(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 10 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_13(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 11 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_14(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 12 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_15(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 8 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_16(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 9 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_17(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 10 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_18(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 11 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_19(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 12 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_20(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 8 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_21(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 9 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_22(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 10 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_23(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 11 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_24(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 12 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_25(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 8 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_26(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 9 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_27(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 10 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_28(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 11 then break end
            end
        end)
    end
    function UILib.Kit.pulseAccent_29(stroke, lo, hi)
        lo = lo or 0.35; hi = hi or 0.75
        task.spawn(function()
            local t0 = os.clock()
            while stroke and stroke.Parent and not _G[MW_T.unloaded] do
                local u = (math.sin(os.clock() * 2.2) + 1) * 0.5
                stroke.Transparency = lo + (hi - lo) * u
                task.wait(0.05)
                if os.clock() - t0 > 12 then break end
            end
        end)
    end
end)()
local _bindMD = TraceV2BindMD
TraceV2BindMD = function(MD)
    if _bindMD then _bindMD(MD) end
    if not MD then return end
    MD.TraceExpand = TraceExpand
    pcall(function() TraceExpand.Migrate.run(Settings) end)
end
(function()
    local Pack = {}
    Pack.ESPStyles = {
        Clean = {BoxStyle='2D', BoxEnabled=true, HealthBar=true, NameEnabled=true, SkeletonEnabled=false, ChamsEnabled=false, TracerEnabled=false},
        Full = {BoxStyle='2D', BoxEnabled=true, HealthBar=true, NameEnabled=true, SkeletonEnabled=true, ChamsEnabled=true, TracerEnabled=true},
        Ghost = {BoxStyle='Corner', BoxEnabled=true, HealthBar=false, NameEnabled=true, SkeletonEnabled=false, ChamsEnabled=true, TracerEnabled=false},
        Arena = {BoxStyle='2D', BoxEnabled=true, HealthBar=true, NameEnabled=true, SkeletonEnabled=false, ChamsEnabled=false, TracerEnabled=true, OffscreenArrows=true},
        Minimal = {BoxStyle='Corner', BoxEnabled=true, HealthBar=true, NameEnabled=false, SkeletonEnabled=false, ChamsEnabled=false, TracerEnabled=false},
        Scout = {BoxStyle='2D', BoxEnabled=true, HealthBar=true, NameEnabled=true, DistanceEnabled=true, SkeletonEnabled=false, WeaponLabels=true},
    }
    function Pack.applyESPStyle(name)
        local p = Pack.ESPStyles[name]
        if not p then return false end
        for k, v in pairs(p) do Settings.ESP[k] = v end
        Settings.ESP.Enabled = true
        return true
    end
    Pack.WorldRecipes = {
        Noon = {CustomBrightness=true, Brightness=2.2, CustomTime=true, ClockTime=12, CustomExposure=true, Exposure=0},
        Dusk = {CustomBrightness=true, Brightness=1.2, CustomTime=true, ClockTime=18.5, CustomExposure=true, Exposure=-0.2},
        Night = {CustomBrightness=true, Brightness=0.6, CustomTime=true, ClockTime=0, CustomExposure=true, Exposure=0.4},
        Flat = {Fullbright=true, NoFog=true, CustomBrightness=true, Brightness=3},
        Cinematic = {CustomBrightness=true, Brightness=1.4, CustomTime=true, ClockTime=16, CustomExposure=true, Exposure=-0.35},
        ArenaBright = {Fullbright=true, NoFog=true, CustomFOV=true, FOVAmount=90},
    }
    function Pack.applyWorldRecipe(name)
        local p = Pack.WorldRecipes[name]
        if not p then return false end
        for k, v in pairs(p) do
            if Settings.Visuals[k] ~= nil or true then Settings.Visuals[k] = v end
        end
        if applyWorldLighting then applyWorldLighting() end
        return true
    end
    Pack.Notify = {}
    function Pack.Notify.route(kind, title, body)
        if TraceHUD and TraceHUD.pushFeed and (kind == 'hit' or kind == 'kill' or kind == 'info') then
            TraceHUD.pushFeed(string.upper(kind), title, body)
        end

        return true
    end
    Pack.Places = {
        Arsenal = 286090429,
        Brookhaven = 4924922222,
        MM2 = 142823291,
    }
    function Pack.Places.hint()
        if game.PlaceId == Pack.Places.Arsenal then return 'Arsenal: gunmods unlocked when Cap allows' end
        if game.PlaceId == Pack.Places.Brookhaven then return 'Brookhaven: RP kit (locations, vehicles, movement)' end
        if game.PlaceId == Pack.Places.MM2 then return 'MM2: Rift kit wired into Melo 🍃' end
        return 'Universal: movement, Auto Obby, ESP; gunmods Arsenal-only'
    end
    Pack.CardRecipes = {}
    Pack.CardRecipes.Aimbot = { rows = 12, col = 1, order = 0 }
    Pack.CardRecipes.AimConfig = { rows = 10, col = 2, order = 1 }
    Pack.CardRecipes.FOV = { rows = 6, col = 1, order = 2 }
    Pack.CardRecipes.Trigger = { rows = 10, col = 2, order = 3 }
    Pack.CardRecipes.Rage = { rows = 8, col = 1, order = 4 }
    Pack.CardRecipes.TargetPriority = { rows = 5, col = 2, order = 5 }
    Pack.CardRecipes.GunProfiles = { rows = 5, col = 1, order = 6 }
    Pack.CardRecipes.ESP = { rows = 16, col = 2, order = 7 }
    Pack.CardRecipes.HUD = { rows = 14, col = 1, order = 8 }
    Pack.CardRecipes.Speed = { rows = 8, col = 2, order = 9 }
    Pack.CardRecipes.Fly = { rows = 6, col = 1, order = 10 }
    Pack.CardRecipes.ThemeStudio = { rows = 5, col = 2, order = 11 }
    Pack.CardRecipes.ConfigTools = { rows = 5, col = 1, order = 12 }
    Pack.CardRecipes.ScriptInfo = { rows = 7, col = 2, order = 13 }
    Pack.CardRecipes.Keybinds = { rows = 9, col = 1, order = 14 }
    Pack.CardRecipes.AudioHit = { rows = 10, col = 2, order = 15 }
    Pack.CardRecipes.Music = { rows = 8, col = 1, order = 16 }
    Pack.CardRecipes.Webhooks = { rows = 12, col = 2, order = 17 }
    Pack.CardRecipes.Server = { rows = 8, col = 1, order = 18 }
    Pack.CardRecipes.GunMods = { rows = 8, col = 2, order = 19 }
    function Pack.CardRecipes.sorted()
        local list = {}
        for name, meta in pairs(Pack.CardRecipes) do
            if type(meta) == 'table' and meta.order then table.insert(list, {name=name, meta=meta}) end
        end
        table.sort(list, function(a,b) return a.meta.order < b.meta.order end)
        return list
    end
    Pack.Chords = {}
    Pack.Chords.Slot0 = { id = 0, label = 'Chord0', armed = false }
    Pack.Chords.Slot1 = { id = 1, label = 'Chord1', armed = false }
    Pack.Chords.Slot2 = { id = 2, label = 'Chord2', armed = false }
    Pack.Chords.Slot3 = { id = 3, label = 'Chord3', armed = false }
    Pack.Chords.Slot4 = { id = 4, label = 'Chord4', armed = false }
    Pack.Chords.Slot5 = { id = 5, label = 'Chord5', armed = false }
    Pack.Chords.Slot6 = { id = 6, label = 'Chord6', armed = false }
    Pack.Chords.Slot7 = { id = 7, label = 'Chord7', armed = false }
    Pack.Chords.Slot8 = { id = 8, label = 'Chord8', armed = false }
    Pack.Chords.Slot9 = { id = 9, label = 'Chord9', armed = false }
    Pack.Chords.Slot10 = { id = 10, label = 'Chord10', armed = false }
    Pack.Chords.Slot11 = { id = 11, label = 'Chord11', armed = false }
    Pack.Chords.Slot12 = { id = 12, label = 'Chord12', armed = false }
    Pack.Chords.Slot13 = { id = 13, label = 'Chord13', armed = false }
    Pack.Chords.Slot14 = { id = 14, label = 'Chord14', armed = false }
    Pack.Chords.Slot15 = { id = 15, label = 'Chord15', armed = false }
    Pack.Chords.Slot16 = { id = 16, label = 'Chord16', armed = false }
    Pack.Chords.Slot17 = { id = 17, label = 'Chord17', armed = false }
    Pack.Chords.Slot18 = { id = 18, label = 'Chord18', armed = false }
    Pack.Chords.Slot19 = { id = 19, label = 'Chord19', armed = false }
    Pack.Chords.Slot20 = { id = 20, label = 'Chord20', armed = false }
    Pack.Chords.Slot21 = { id = 21, label = 'Chord21', armed = false }
    Pack.Chords.Slot22 = { id = 22, label = 'Chord22', armed = false }
    Pack.Chords.Slot23 = { id = 23, label = 'Chord23', armed = false }
    Pack.Chords.Slot24 = { id = 24, label = 'Chord24', armed = false }
    Pack.Chords.Slot25 = { id = 25, label = 'Chord25', armed = false }
    Pack.Chords.Slot26 = { id = 26, label = 'Chord26', armed = false }
    Pack.Chords.Slot27 = { id = 27, label = 'Chord27', armed = false }
    Pack.Chords.Slot28 = { id = 28, label = 'Chord28', armed = false }
    Pack.Chords.Slot29 = { id = 29, label = 'Chord29', armed = false }
    Pack.Chords.Slot30 = { id = 30, label = 'Chord30', armed = false }
    Pack.Chords.Slot31 = { id = 31, label = 'Chord31', armed = false }
    Pack.Chords.Slot32 = { id = 32, label = 'Chord32', armed = false }
    Pack.Chords.Slot33 = { id = 33, label = 'Chord33', armed = false }
    Pack.Chords.Slot34 = { id = 34, label = 'Chord34', armed = false }
    Pack.Chords.Slot35 = { id = 35, label = 'Chord35', armed = false }
    Pack.Chords.Slot36 = { id = 36, label = 'Chord36', armed = false }
    Pack.Chords.Slot37 = { id = 37, label = 'Chord37', armed = false }
    Pack.Chords.Slot38 = { id = 38, label = 'Chord38', armed = false }
    Pack.Chords.Slot39 = { id = 39, label = 'Chord39', armed = false }
    Pack.Chords.Slot40 = { id = 40, label = 'Chord40', armed = false }
    Pack.Chords.Slot41 = { id = 41, label = 'Chord41', armed = false }
    Pack.Chords.Slot42 = { id = 42, label = 'Chord42', armed = false }
    Pack.Chords.Slot43 = { id = 43, label = 'Chord43', armed = false }
    Pack.Chords.Slot44 = { id = 44, label = 'Chord44', armed = false }
    Pack.Chords.Slot45 = { id = 45, label = 'Chord45', armed = false }
    Pack.Chords.Slot46 = { id = 46, label = 'Chord46', armed = false }
    Pack.Chords.Slot47 = { id = 47, label = 'Chord47', armed = false }
    Pack.Chords.Slot48 = { id = 48, label = 'Chord48', armed = false }
    Pack.Chords.Slot49 = { id = 49, label = 'Chord49', armed = false }
    Pack.Chords.Slot50 = { id = 50, label = 'Chord50', armed = false }
    Pack.Chords.Slot51 = { id = 51, label = 'Chord51', armed = false }
    Pack.Chords.Slot52 = { id = 52, label = 'Chord52', armed = false }
    Pack.Chords.Slot53 = { id = 53, label = 'Chord53', armed = false }
    Pack.Chords.Slot54 = { id = 54, label = 'Chord54', armed = false }
    Pack.Chords.Slot55 = { id = 55, label = 'Chord55', armed = false }
    Pack.Chords.Slot56 = { id = 56, label = 'Chord56', armed = false }
    Pack.Chords.Slot57 = { id = 57, label = 'Chord57', armed = false }
    Pack.Chords.Slot58 = { id = 58, label = 'Chord58', armed = false }
    Pack.Chords.Slot59 = { id = 59, label = 'Chord59', armed = false }
    Pack.Chords.Slot60 = { id = 60, label = 'Chord60', armed = false }
    Pack.Chords.Slot61 = { id = 61, label = 'Chord61', armed = false }
    Pack.Chords.Slot62 = { id = 62, label = 'Chord62', armed = false }
    Pack.Chords.Slot63 = { id = 63, label = 'Chord63', armed = false }
    Pack.Chords.Slot64 = { id = 64, label = 'Chord64', armed = false }
    Pack.Chords.Slot65 = { id = 65, label = 'Chord65', armed = false }
    Pack.Chords.Slot66 = { id = 66, label = 'Chord66', armed = false }
    Pack.Chords.Slot67 = { id = 67, label = 'Chord67', armed = false }
    Pack.Chords.Slot68 = { id = 68, label = 'Chord68', armed = false }
    Pack.Chords.Slot69 = { id = 69, label = 'Chord69', armed = false }
    Pack.Chords.Slot70 = { id = 70, label = 'Chord70', armed = false }
    Pack.Chords.Slot71 = { id = 71, label = 'Chord71', armed = false }
    Pack.Chords.Slot72 = { id = 72, label = 'Chord72', armed = false }
    Pack.Chords.Slot73 = { id = 73, label = 'Chord73', armed = false }
    Pack.Chords.Slot74 = { id = 74, label = 'Chord74', armed = false }
    Pack.Chords.Slot75 = { id = 75, label = 'Chord75', armed = false }
    Pack.Chords.Slot76 = { id = 76, label = 'Chord76', armed = false }
    Pack.Chords.Slot77 = { id = 77, label = 'Chord77', armed = false }
    Pack.Chords.Slot78 = { id = 78, label = 'Chord78', armed = false }
    Pack.Chords.Slot79 = { id = 79, label = 'Chord79', armed = false }
    Pack.Chords.Slot80 = { id = 80, label = 'Chord80', armed = false }
    Pack.Chords.Slot81 = { id = 81, label = 'Chord81', armed = false }
    Pack.Chords.Slot82 = { id = 82, label = 'Chord82', armed = false }
    Pack.Chords.Slot83 = { id = 83, label = 'Chord83', armed = false }
    Pack.Chords.Slot84 = { id = 84, label = 'Chord84', armed = false }
    Pack.Chords.Slot85 = { id = 85, label = 'Chord85', armed = false }
    Pack.Chords.Slot86 = { id = 86, label = 'Chord86', armed = false }
    Pack.Chords.Slot87 = { id = 87, label = 'Chord87', armed = false }
    Pack.Chords.Slot88 = { id = 88, label = 'Chord88', armed = false }
    Pack.Chords.Slot89 = { id = 89, label = 'Chord89', armed = false }
    Pack.Chords.Slot90 = { id = 90, label = 'Chord90', armed = false }
    Pack.Chords.Slot91 = { id = 91, label = 'Chord91', armed = false }
    Pack.Chords.Slot92 = { id = 92, label = 'Chord92', armed = false }
    Pack.Chords.Slot93 = { id = 93, label = 'Chord93', armed = false }
    Pack.Chords.Slot94 = { id = 94, label = 'Chord94', armed = false }
    Pack.Chords.Slot95 = { id = 95, label = 'Chord95', armed = false }
    Pack.Chords.Slot96 = { id = 96, label = 'Chord96', armed = false }
    Pack.Chords.Slot97 = { id = 97, label = 'Chord97', armed = false }
    Pack.Chords.Slot98 = { id = 98, label = 'Chord98', armed = false }
    Pack.Chords.Slot99 = { id = 99, label = 'Chord99', armed = false }
    function Pack.Chords.arm(id)
        local s = Pack.Chords['Slot' .. tostring(id)]
        if s then s.armed = true end
    end
    function Pack.Chords.disarmAll()
        for i = 0, 99 do
            local s = Pack.Chords['Slot' .. i]
            if s then s.armed = false end
        end
    end
    Pack.SensCurves = {}
    Pack.SensCurves.P0 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.5
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P1 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.55
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P2 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.6
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P3 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.65
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P4 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.7
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P5 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.75
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P6 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.8
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P7 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.8500000000000001
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P8 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.9
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P9 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.95
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P10 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.0
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P11 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.05
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P12 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.1
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P13 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.15
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P14 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.2000000000000002
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P15 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.25
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P16 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.3
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P17 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.35
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P18 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.4
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P19 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.4500000000000002
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P20 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.5
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P21 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.55
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P22 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.6
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P23 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.65
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P24 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.7
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P25 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.75
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P26 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.8
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P27 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.8500000000000001
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P28 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.9
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P29 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.95
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P30 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.0
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P31 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.05
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P32 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.1
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P33 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.15
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P34 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.2000000000000002
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P35 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.25
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P36 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.3
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P37 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.35
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P38 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.4
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P39 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.4500000000000002
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P40 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.5
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P41 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.55
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P42 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.6
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P43 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.65
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P44 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.7
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P45 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.75
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P46 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.8
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P47 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.8500000000000001
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P48 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.9
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P49 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.95
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P50 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.0
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P51 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.05
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P52 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.1
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P53 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.15
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P54 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.2000000000000002
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P55 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.25
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P56 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.3
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P57 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.35
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P58 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.4
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P59 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.4500000000000002
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P60 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.5
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P61 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.55
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P62 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.6
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P63 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.65
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P64 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.7
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P65 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.75
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P66 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.8
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P67 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.8500000000000001
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P68 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.9
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P69 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 0.95
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P70 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.0
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P71 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.05
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P72 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.1
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P73 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.15
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P74 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.2000000000000002
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P75 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.25
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P76 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.3
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P77 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.35
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P78 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.4
        return 1 - math.exp(-k * x)
    end
    Pack.SensCurves.P79 = function(x)
        x = math.clamp(x, 0, 1)
        local k = 1.4500000000000002
        return 1 - math.exp(-k * x)
    end
    if TraceExpand then TraceExpand.Pack = Pack end
    local prev = TraceV2BindMD
    TraceV2BindMD = function(MD)
        if prev then prev(MD) end
        if MD then MD.TracePack = Pack end
    end
end)()
UILib.V2 = (function()
    local V = { ver = 2 }
    function V.toggle(parent, label, y, initial, cb, badge)

        local row = UILib.newFrame(parent, {Size=UDim2.new(1,0,0,26), Position=UDim2.new(0,0,0,y), BackgroundTransparency=1})
        UILib.newLabel(row, {Size=UDim2.new(0.7,0,1,0), Text=label, TextColor3=Theme.TextPrimary, TextSize=12, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left})
        if badge then UILib.Kit.badge(row, badge, Theme.WarnColor) end
        return row
    end
    function V.slider(parent, label, y, lo, hi, val)
        local row = UILib.newFrame(parent, {Size=UDim2.new(1,0,0,36), Position=UDim2.new(0,0,0,y), BackgroundTransparency=1})
        UILib.newLabel(row, {Size=UDim2.new(1,0,0,14), Text=label..'  '..tostring(val), TextColor3=Theme.TextSecondary, TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left})
        return row
    end
    function V.dropdown(parent, label, y, options, current)
        local row = UILib.newFrame(parent, {Size=UDim2.new(1,0,0,48), Position=UDim2.new(0,0,0,y), BackgroundTransparency=1})
        UILib.newLabel(row, {Size=UDim2.new(1,0,0,14), Text=label, TextColor3=Theme.TextSecondary, TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left})
        UILib.newLabel(row, {Size=UDim2.new(1,0,0,18), Position=UDim2.new(0,0,0,16), Text=tostring(current), TextColor3=Theme.TextAccent, TextSize=12, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left})
        return row
    end
    function V.keybind(parent, label, y, key)
        local row = UILib.newFrame(parent, {Size=UDim2.new(1,0,0,26), Position=UDim2.new(0,0,0,y), BackgroundTransparency=1})
        UILib.newLabel(row, {Size=UDim2.new(0.55,0,1,0), Text=label, TextColor3=Theme.TextPrimary, TextSize=12, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left})
        UILib.newLabel(row, {Size=UDim2.new(0.4,0,1,0), Position=UDim2.new(0.6,0,0,0), Text=UILib.Kit.keyName(key), TextColor3=Theme.TextAccent, TextSize=11, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right})
        return row
    end
    function V.color(parent, label, y, hex)
        return UILib.Kit.colorField(parent, label, y, function() return hex end, function(h) hex = h end)
    end
    function V.search(parent, placeholder, onChange)
        local box = UILib.newBox(parent, {Size=UDim2.new(1,0,0,24), BackgroundColor3=Theme.InputBg, BorderSizePixel=0, PlaceholderText=placeholder or 'Search', Text='', TextColor3=Theme.TextPrimary, TextSize=11, Font=Enum.Font.Gotham, ClearTextOnFocus=false})
        UILib.corner(box, 4)
        if onChange then box:GetPropertyChangedSignal('Text'):Connect(function() onChange(box.Text) end) end
        return box
    end
    V.token_0 = function()
        return { pad = 6, radius = 3, z = 10 }
    end
    V.token_1 = function()
        return { pad = 7, radius = 4, z = 11 }
    end
    V.token_2 = function()
        return { pad = 8, radius = 5, z = 12 }
    end
    V.token_3 = function()
        return { pad = 9, radius = 6, z = 13 }
    end
    V.token_4 = function()
        return { pad = 10, radius = 7, z = 14 }
    end
    V.token_5 = function()
        return { pad = 11, radius = 3, z = 15 }
    end
    V.token_6 = function()
        return { pad = 12, radius = 4, z = 16 }
    end
    V.token_7 = function()
        return { pad = 13, radius = 5, z = 17 }
    end
    V.token_8 = function()
        return { pad = 6, radius = 6, z = 18 }
    end
    V.token_9 = function()
        return { pad = 7, radius = 7, z = 19 }
    end
    V.token_10 = function()
        return { pad = 8, radius = 3, z = 20 }
    end
    V.token_11 = function()
        return { pad = 9, radius = 4, z = 21 }
    end
    V.token_12 = function()
        return { pad = 10, radius = 5, z = 22 }
    end
    V.token_13 = function()
        return { pad = 11, radius = 6, z = 23 }
    end
    V.token_14 = function()
        return { pad = 12, radius = 7, z = 24 }
    end
    V.token_15 = function()
        return { pad = 13, radius = 3, z = 25 }
    end
    V.token_16 = function()
        return { pad = 6, radius = 4, z = 26 }
    end
    V.token_17 = function()
        return { pad = 7, radius = 5, z = 27 }
    end
    V.token_18 = function()
        return { pad = 8, radius = 6, z = 28 }
    end
    V.token_19 = function()
        return { pad = 9, radius = 7, z = 29 }
    end
    V.token_20 = function()
        return { pad = 10, radius = 3, z = 10 }
    end
    V.token_21 = function()
        return { pad = 11, radius = 4, z = 11 }
    end
    V.token_22 = function()
        return { pad = 12, radius = 5, z = 12 }
    end
    V.token_23 = function()
        return { pad = 13, radius = 6, z = 13 }
    end
    V.token_24 = function()
        return { pad = 6, radius = 7, z = 14 }
    end
    V.token_25 = function()
        return { pad = 7, radius = 3, z = 15 }
    end
    V.token_26 = function()
        return { pad = 8, radius = 4, z = 16 }
    end
    V.token_27 = function()
        return { pad = 9, radius = 5, z = 17 }
    end
    V.token_28 = function()
        return { pad = 10, radius = 6, z = 18 }
    end
    V.token_29 = function()
        return { pad = 11, radius = 7, z = 19 }
    end
    V.token_30 = function()
        return { pad = 12, radius = 3, z = 20 }
    end
    V.token_31 = function()
        return { pad = 13, radius = 4, z = 21 }
    end
    V.token_32 = function()
        return { pad = 6, radius = 5, z = 22 }
    end
    V.token_33 = function()
        return { pad = 7, radius = 6, z = 23 }
    end
    V.token_34 = function()
        return { pad = 8, radius = 7, z = 24 }
    end
    V.token_35 = function()
        return { pad = 9, radius = 3, z = 25 }
    end
    V.token_36 = function()
        return { pad = 10, radius = 4, z = 26 }
    end
    V.token_37 = function()
        return { pad = 11, radius = 5, z = 27 }
    end
    V.token_38 = function()
        return { pad = 12, radius = 6, z = 28 }
    end
    V.token_39 = function()
        return { pad = 13, radius = 7, z = 29 }
    end
    V.token_40 = function()
        return { pad = 6, radius = 3, z = 10 }
    end
    V.token_41 = function()
        return { pad = 7, radius = 4, z = 11 }
    end
    V.token_42 = function()
        return { pad = 8, radius = 5, z = 12 }
    end
    V.token_43 = function()
        return { pad = 9, radius = 6, z = 13 }
    end
    V.token_44 = function()
        return { pad = 10, radius = 7, z = 14 }
    end
    V.token_45 = function()
        return { pad = 11, radius = 3, z = 15 }
    end
    V.token_46 = function()
        return { pad = 12, radius = 4, z = 16 }
    end
    V.token_47 = function()
        return { pad = 13, radius = 5, z = 17 }
    end
    V.token_48 = function()
        return { pad = 6, radius = 6, z = 18 }
    end
    V.token_49 = function()
        return { pad = 7, radius = 7, z = 19 }
    end
    V.token_50 = function()
        return { pad = 8, radius = 3, z = 20 }
    end
    V.token_51 = function()
        return { pad = 9, radius = 4, z = 21 }
    end
    V.token_52 = function()
        return { pad = 10, radius = 5, z = 22 }
    end
    V.token_53 = function()
        return { pad = 11, radius = 6, z = 23 }
    end
    V.token_54 = function()
        return { pad = 12, radius = 7, z = 24 }
    end
    V.token_55 = function()
        return { pad = 13, radius = 3, z = 25 }
    end
    V.token_56 = function()
        return { pad = 6, radius = 4, z = 26 }
    end
    V.token_57 = function()
        return { pad = 7, radius = 5, z = 27 }
    end
    V.token_58 = function()
        return { pad = 8, radius = 6, z = 28 }
    end
    V.token_59 = function()
        return { pad = 9, radius = 7, z = 29 }
    end
    V.token_60 = function()
        return { pad = 10, radius = 3, z = 10 }
    end
    V.token_61 = function()
        return { pad = 11, radius = 4, z = 11 }
    end
    V.token_62 = function()
        return { pad = 12, radius = 5, z = 12 }
    end
    V.token_63 = function()
        return { pad = 13, radius = 6, z = 13 }
    end
    V.token_64 = function()
        return { pad = 6, radius = 7, z = 14 }
    end
    V.token_65 = function()
        return { pad = 7, radius = 3, z = 15 }
    end
    V.token_66 = function()
        return { pad = 8, radius = 4, z = 16 }
    end
    V.token_67 = function()
        return { pad = 9, radius = 5, z = 17 }
    end
    V.token_68 = function()
        return { pad = 10, radius = 6, z = 18 }
    end
    V.token_69 = function()
        return { pad = 11, radius = 7, z = 19 }
    end
    V.token_70 = function()
        return { pad = 12, radius = 3, z = 20 }
    end
    V.token_71 = function()
        return { pad = 13, radius = 4, z = 21 }
    end
    V.token_72 = function()
        return { pad = 6, radius = 5, z = 22 }
    end
    V.token_73 = function()
        return { pad = 7, radius = 6, z = 23 }
    end
    V.token_74 = function()
        return { pad = 8, radius = 7, z = 24 }
    end
    V.token_75 = function()
        return { pad = 9, radius = 3, z = 25 }
    end
    V.token_76 = function()
        return { pad = 10, radius = 4, z = 26 }
    end
    V.token_77 = function()
        return { pad = 11, radius = 5, z = 27 }
    end
    V.token_78 = function()
        return { pad = 12, radius = 6, z = 28 }
    end
    V.token_79 = function()
        return { pad = 13, radius = 7, z = 29 }
    end
    V.token_80 = function()
        return { pad = 6, radius = 3, z = 10 }
    end
    V.token_81 = function()
        return { pad = 7, radius = 4, z = 11 }
    end
    V.token_82 = function()
        return { pad = 8, radius = 5, z = 12 }
    end
    V.token_83 = function()
        return { pad = 9, radius = 6, z = 13 }
    end
    V.token_84 = function()
        return { pad = 10, radius = 7, z = 14 }
    end
    V.token_85 = function()
        return { pad = 11, radius = 3, z = 15 }
    end
    V.token_86 = function()
        return { pad = 12, radius = 4, z = 16 }
    end
    V.token_87 = function()
        return { pad = 13, radius = 5, z = 17 }
    end
    V.token_88 = function()
        return { pad = 6, radius = 6, z = 18 }
    end
    V.token_89 = function()
        return { pad = 7, radius = 7, z = 19 }
    end
    V.token_90 = function()
        return { pad = 8, radius = 3, z = 20 }
    end
    V.token_91 = function()
        return { pad = 9, radius = 4, z = 21 }
    end
    V.token_92 = function()
        return { pad = 10, radius = 5, z = 22 }
    end
    V.token_93 = function()
        return { pad = 11, radius = 6, z = 23 }
    end
    V.token_94 = function()
        return { pad = 12, radius = 7, z = 24 }
    end
    V.token_95 = function()
        return { pad = 13, radius = 3, z = 25 }
    end
    V.token_96 = function()
        return { pad = 6, radius = 4, z = 26 }
    end
    V.token_97 = function()
        return { pad = 7, radius = 5, z = 27 }
    end
    V.token_98 = function()
        return { pad = 8, radius = 6, z = 28 }
    end
    V.token_99 = function()
        return { pad = 9, radius = 7, z = 29 }
    end
    V.token_100 = function()
        return { pad = 10, radius = 3, z = 10 }
    end
    V.token_101 = function()
        return { pad = 11, radius = 4, z = 11 }
    end
    V.token_102 = function()
        return { pad = 12, radius = 5, z = 12 }
    end
    V.token_103 = function()
        return { pad = 13, radius = 6, z = 13 }
    end
    V.token_104 = function()
        return { pad = 6, radius = 7, z = 14 }
    end
    V.token_105 = function()
        return { pad = 7, radius = 3, z = 15 }
    end
    V.token_106 = function()
        return { pad = 8, radius = 4, z = 16 }
    end
    V.token_107 = function()
        return { pad = 9, radius = 5, z = 17 }
    end
    V.token_108 = function()
        return { pad = 10, radius = 6, z = 18 }
    end
    V.token_109 = function()
        return { pad = 11, radius = 7, z = 19 }
    end
    V.token_110 = function()
        return { pad = 12, radius = 3, z = 20 }
    end
    V.token_111 = function()
        return { pad = 13, radius = 4, z = 21 }
    end
    V.token_112 = function()
        return { pad = 6, radius = 5, z = 22 }
    end
    V.token_113 = function()
        return { pad = 7, radius = 6, z = 23 }
    end
    V.token_114 = function()
        return { pad = 8, radius = 7, z = 24 }
    end
    V.token_115 = function()
        return { pad = 9, radius = 3, z = 25 }
    end
    V.token_116 = function()
        return { pad = 10, radius = 4, z = 26 }
    end
    V.token_117 = function()
        return { pad = 11, radius = 5, z = 27 }
    end
    V.token_118 = function()
        return { pad = 12, radius = 6, z = 28 }
    end
    V.token_119 = function()
        return { pad = 13, radius = 7, z = 29 }
    end
    return V
end)();
(function()

    local prevStart = startAimbotTracking
    if type(prevStart) == 'function' then
        startAimbotTracking = function(...)
            if TraceExpand and TraceExpand.Session then TraceExpand.Session.noteLock('aim') end
            return prevStart(...)
        end
    end
end)()
TracePalettes = (function()
    local P = {}
    P.Ice = {'7DD3FC','38BDF8','0EA5E9','0284C7','0369A1','07080B','0C0D12','111827','E2E8F0','94A3B8'}
    P.Graphite = {'A8B0BC','C5CCD6','64748B','475569','334155','0A0B0E','12141A','1E293B','E2E8F0','94A3B8'}
    P.BloodAmber = {'E8A04A','F0B35C','D97706','B45309','92400E','0C0908','16100C','1C1410','F5E6D3','D6B895'}
    P.Mint = {'6EE7B7','34D399','10B981','059669','047857','070B0A','0C1210','10201A','ECFDF5','A7F3D0'}
    P.Steel = {'94A3B8','CBD5E1','64748B','475569','1E293B','08090C','10131A','0F172A','F8FAFC','E2E8F0'}
    P.Crimson = {'F87171','FCA5A5','EF4444','DC2626','B91C1C','0B0708','140C0E','1F1214','FEE2E2','FECACA'}
    function P.get(name) return P[name] end
    function P.swatches(parent, name, x0, y0)
        local list = P[name] or P.Ice
        local frames = {}
        for i, hex in ipairs(list) do
            local f = Instance.new('Frame')
            f.Size = UDim2.fromOffset(14, 14)
            f.Position = UDim2.fromOffset(x0 + (i-1)*16, y0)
            f.BackgroundColor3 = hexToColor3(hex)
            f.BorderSizePixel = 0
            f.Parent = parent
            local c = Instance.new('UICorner'); c.CornerRadius = UDim.new(0, 3); c.Parent = f
            table.insert(frames, f)
        end
        return frames
    end
    function P.ice_0() return P.Ice[(0 % #P.Ice) + 1] end
    function P.ice_1() return P.Ice[(1 % #P.Ice) + 1] end
    function P.ice_2() return P.Ice[(2 % #P.Ice) + 1] end
    function P.ice_3() return P.Ice[(3 % #P.Ice) + 1] end
    function P.ice_4() return P.Ice[(4 % #P.Ice) + 1] end
    function P.ice_5() return P.Ice[(5 % #P.Ice) + 1] end
    function P.ice_6() return P.Ice[(6 % #P.Ice) + 1] end
    function P.ice_7() return P.Ice[(7 % #P.Ice) + 1] end
    function P.ice_8() return P.Ice[(8 % #P.Ice) + 1] end
    function P.ice_9() return P.Ice[(9 % #P.Ice) + 1] end
    function P.ice_10() return P.Ice[(10 % #P.Ice) + 1] end
    function P.ice_11() return P.Ice[(11 % #P.Ice) + 1] end
    function P.ice_12() return P.Ice[(12 % #P.Ice) + 1] end
    function P.ice_13() return P.Ice[(13 % #P.Ice) + 1] end
    function P.ice_14() return P.Ice[(14 % #P.Ice) + 1] end
    function P.ice_15() return P.Ice[(15 % #P.Ice) + 1] end
    function P.ice_16() return P.Ice[(16 % #P.Ice) + 1] end
    function P.ice_17() return P.Ice[(17 % #P.Ice) + 1] end
    function P.ice_18() return P.Ice[(18 % #P.Ice) + 1] end
    function P.ice_19() return P.Ice[(19 % #P.Ice) + 1] end
    function P.ice_20() return P.Ice[(20 % #P.Ice) + 1] end
    function P.ice_21() return P.Ice[(21 % #P.Ice) + 1] end
    function P.ice_22() return P.Ice[(22 % #P.Ice) + 1] end
    function P.ice_23() return P.Ice[(23 % #P.Ice) + 1] end
    function P.ice_24() return P.Ice[(24 % #P.Ice) + 1] end
    function P.ice_25() return P.Ice[(25 % #P.Ice) + 1] end
    function P.ice_26() return P.Ice[(26 % #P.Ice) + 1] end
    function P.ice_27() return P.Ice[(27 % #P.Ice) + 1] end
    function P.ice_28() return P.Ice[(28 % #P.Ice) + 1] end
    function P.ice_29() return P.Ice[(29 % #P.Ice) + 1] end
    function P.ice_30() return P.Ice[(30 % #P.Ice) + 1] end
    function P.ice_31() return P.Ice[(31 % #P.Ice) + 1] end
    function P.ice_32() return P.Ice[(32 % #P.Ice) + 1] end
    function P.ice_33() return P.Ice[(33 % #P.Ice) + 1] end
    function P.ice_34() return P.Ice[(34 % #P.Ice) + 1] end
    function P.ice_35() return P.Ice[(35 % #P.Ice) + 1] end
    function P.ice_36() return P.Ice[(36 % #P.Ice) + 1] end
    function P.ice_37() return P.Ice[(37 % #P.Ice) + 1] end
    function P.ice_38() return P.Ice[(38 % #P.Ice) + 1] end
    function P.ice_39() return P.Ice[(39 % #P.Ice) + 1] end
    function P.ice_40() return P.Ice[(40 % #P.Ice) + 1] end
    function P.ice_41() return P.Ice[(41 % #P.Ice) + 1] end
    function P.ice_42() return P.Ice[(42 % #P.Ice) + 1] end
    function P.ice_43() return P.Ice[(43 % #P.Ice) + 1] end
    function P.ice_44() return P.Ice[(44 % #P.Ice) + 1] end
    function P.ice_45() return P.Ice[(45 % #P.Ice) + 1] end
    function P.ice_46() return P.Ice[(46 % #P.Ice) + 1] end
    function P.ice_47() return P.Ice[(47 % #P.Ice) + 1] end
    function P.ice_48() return P.Ice[(48 % #P.Ice) + 1] end
    function P.ice_49() return P.Ice[(49 % #P.Ice) + 1] end
    function P.ice_50() return P.Ice[(50 % #P.Ice) + 1] end
    function P.ice_51() return P.Ice[(51 % #P.Ice) + 1] end
    function P.ice_52() return P.Ice[(52 % #P.Ice) + 1] end
    function P.ice_53() return P.Ice[(53 % #P.Ice) + 1] end
    function P.ice_54() return P.Ice[(54 % #P.Ice) + 1] end
    function P.ice_55() return P.Ice[(55 % #P.Ice) + 1] end
    function P.ice_56() return P.Ice[(56 % #P.Ice) + 1] end
    function P.ice_57() return P.Ice[(57 % #P.Ice) + 1] end
    function P.ice_58() return P.Ice[(58 % #P.Ice) + 1] end
    function P.ice_59() return P.Ice[(59 % #P.Ice) + 1] end
    return P
end)()
TraceDocs = (function()
    local D = {}
    D.aim_mode = "Camera moves view; Silent redirects bullets (no camera move)."
    D.priority = "Crosshair scores screen distance; Threat mixes range + crosshair."
    D.gun_profile = "Applies Cap-gated gun mod flags. Locked on weak executors / non-Arsenal."
    D.hud_feed = "Hit/kill feed is HUD-only; classic toasts stay muted."
    D.theme = "Ice is Melo 🍃 brand. Other presets avoid purple/cream AI defaults."
    D.cap = "WEAO + UNC probe. Gunmods force-lock on Xeno/Solara and non-Arsenal."
    D.scale = "Menu Scale uses UIScale on the hub root frame."
    D.blur = "Soft Lighting BlurEffect while the hub is open; destroyed on unload."
    D.silent_fov = "Optional second ring for silent aim FOV visualization."
    D.autosave = "Writes the active profile when enabled and Cap filesystem allows."
    function D.get(k) return D[k] or '' end
    D.FAQ = {
        {q="What is Melo 🍃?", a="Arsenal-first hub with Universal ESP/aim fallback."},
        {q="How do I open the menu?", a="RightCtrl by default: rebind in Config."},
        {q="Why are gun mods locked?", a="Gun mods are Arsenal-only (or Cap-locked on weak executors). Universal/Brookhaven use the movement kit instead."},
        {q="Where is Config?", a="Left rail: Config."},
        {q="Where is Audio?", a="Left rail: Audio."},
        {q="How do I unload?", a="Unload button on the title bar or Script Info."},
        {q="Does Universal include gunmods?", a="No: intentionally Cap-locked."},
        {q="What is Threat priority?", a="Closer + more on-screen enemies rank higher."},
        {q="Can I export configs?", a="Yes: Config Tools: Export JSON when clipboard Cap is ok."},
        {q="Is crosshair available?", a="Removed on purpose; FOV rings cover aim feedback."},
    }
    return D
end)()
TracePack3 = (function()
    local P3 = { ver = 3 }

    P3.MultiOffsets = {
        Head = {0, 0.15, 0},
        Upper = {0, 0.05, 0},
        Torso = {0, 0, 0},
        Left = {-0.35, 0, 0},
        Right = {0.35, 0, 0},
        Lower = {0, -0.4, 0},
    }
    function P3.pickMultipoint(baseCF, weight)
        weight = math.clamp(tonumber(weight) or 0.55, 0.05, 1)
        local names = {'Head','Upper','Torso','Left','Right','Lower'}
        local pick = names[math.random(1, #names)]
        local o = P3.MultiOffsets[pick] or {0,0,0}
        local ox = o[1] * weight
        local oy = o[2] * weight
        local oz = o[3] * weight
        return baseCF * CFrame.new(ox, oy, oz), pick
    end
    P3.HubChrome = {}
    function P3.HubChrome.mountPageHeader(page, railId)
        local meta = TraceExpand and TraceExpand.RailMeta and TraceExpand.RailMeta[railId]
        if not meta or not UILib.Kit or not UILib.Kit.pageTitle then return end
        return UILib.Kit.pageTitle(page, meta.title, meta.blurb)
    end
    P3.ProfileBrowser = {}
    function P3.ProfileBrowser.filter(list, query)
        query = string.lower(tostring(query or ''))
        if query == '' then return list end
        local out = {}
        for _, name in ipairs(list or {}) do
            if string.find(string.lower(name), query, 1, true) then table.insert(out, name) end
        end
        return out
    end
    function P3.ProfileBrowser.suggestName(base)
        base = tostring(base or 'cfg')
        return base .. '_' .. tostring(os.time() % 100000)
    end
    P3.AssistSample_0 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.15
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_1 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.16
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_2 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.16999999999999998
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_3 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.18
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_4 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.19
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_5 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.2
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_6 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.21
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_7 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.22
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_8 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.22999999999999998
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_9 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.24
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_10 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.25
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_11 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.26
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_12 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.27
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_13 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.28
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_14 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.29000000000000004
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_15 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.3
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_16 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.31
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_17 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.32
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_18 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.32999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_19 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.33999999999999997
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_20 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.35
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_21 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.36
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_22 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.37
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_23 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.38
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_24 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.39
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_25 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.4
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_26 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.41000000000000003
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_27 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.42000000000000004
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_28 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.43000000000000005
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_29 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.43999999999999995
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_30 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.44999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_31 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.45999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_32 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.47
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_33 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.48
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_34 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.49
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_35 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.5
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_36 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.51
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_37 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.52
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_38 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.53
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_39 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.54
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_40 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.15
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_41 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.16
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_42 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.16999999999999998
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_43 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.18
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_44 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.19
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_45 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.2
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_46 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.21
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_47 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.22
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_48 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.22999999999999998
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_49 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.24
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_50 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.25
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_51 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.26
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_52 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.27
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_53 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.28
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_54 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.29000000000000004
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_55 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.3
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_56 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.31
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_57 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.32
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_58 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.32999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_59 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.33999999999999997
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_60 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.35
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_61 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.36
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_62 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.37
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_63 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.38
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_64 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.39
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_65 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.4
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_66 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.41000000000000003
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_67 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.42000000000000004
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_68 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.43000000000000005
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_69 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.43999999999999995
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_70 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.44999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_71 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.45999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_72 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.47
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_73 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.48
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_74 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.49
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_75 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.5
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_76 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.51
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_77 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.52
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_78 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.53
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_79 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.54
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_80 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.15
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_81 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.16
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_82 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.16999999999999998
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_83 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.18
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_84 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.19
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_85 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.2
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_86 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.21
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_87 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.22
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_88 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.22999999999999998
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_89 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.24
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_90 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.25
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_91 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.26
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_92 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.27
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_93 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.28
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_94 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.29000000000000004
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_95 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.3
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_96 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.31
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_97 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.32
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_98 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.32999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_99 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.33999999999999997
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_100 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.35
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_101 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.36
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_102 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.37
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_103 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.38
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_104 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.39
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_105 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.4
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_106 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.41000000000000003
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_107 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.42000000000000004
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_108 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.43000000000000005
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_109 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.43999999999999995
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_110 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.44999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_111 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.45999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_112 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.47
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_113 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.48
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_114 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.49
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_115 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.5
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_116 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.51
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_117 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.52
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_118 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.53
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_119 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.54
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_120 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.15
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_121 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.16
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_122 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.16999999999999998
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_123 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.18
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_124 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.19
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_125 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.2
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_126 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.21
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_127 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.22
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_128 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.22999999999999998
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_129 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.24
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_130 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.25
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_131 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.26
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_132 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.27
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_133 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.28
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_134 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.29000000000000004
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_135 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.3
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_136 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.31
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_137 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.32
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_138 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.32999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_139 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.33999999999999997
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_140 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.35
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_141 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.36
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_142 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.37
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_143 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.38
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_144 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.39
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_145 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.4
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_146 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.41000000000000003
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_147 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.42000000000000004
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_148 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.43000000000000005
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_149 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.43999999999999995
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_150 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.44999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_151 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.45999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_152 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.47
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_153 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.48
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_154 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.49
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_155 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.5
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_156 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.51
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_157 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.52
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_158 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.53
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_159 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.54
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_160 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.15
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_161 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.16
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_162 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.16999999999999998
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_163 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.18
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_164 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.19
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_165 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.2
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_166 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.21
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_167 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.22
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_168 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.22999999999999998
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_169 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.24
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_170 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.25
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_171 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.26
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_172 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.27
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_173 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.28
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_174 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.29000000000000004
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_175 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.3
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_176 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.31
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_177 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.32
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_178 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.32999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_179 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.33999999999999997
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_180 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.35
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_181 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.36
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_182 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.37
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_183 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.38
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_184 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.39
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_185 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.4
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_186 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.41000000000000003
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_187 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.42000000000000004
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_188 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.43000000000000005
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_189 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.43999999999999995
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_190 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.44999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_191 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.45999999999999996
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_192 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.47
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_193 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.48
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_194 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.49
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_195 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.5
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_196 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.51
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_197 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.52
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_198 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.53
        return err * math.exp(-k * (dt * 60))
    end
    P3.AssistSample_199 = function(dt, err)
        dt = math.clamp(dt or 0.016, 0.001, 0.1)
        err = tonumber(err) or 0
        local k = 0.54
        return err * math.exp(-k * (dt * 60))
    end
    P3.RuntimeProbe = {}
    function P3.RuntimeProbe.snapshot()
        return {
            placeId = game.PlaceId,
            jobId = game.JobId,
            arsenal = MW.isArsenal and true or false,
            version = MW.version,
            fps = (TraceHUD and TraceHUD.fps) or 0,
            ping = (TraceHUD and TraceHUD.ping) or 0,
            uptime = TraceExpand and TraceExpand.Session and TraceExpand.Session.uptime() or 0,
            caps = TraceInfo and TraceInfo.capLines and TraceInfo.capLines() or {},
        }
    end
    function P3.RuntimeProbe.line()
        local s = P3.RuntimeProbe.snapshot()
        return string.format('Melo 🍃 %s · %s · fps %d · ping %d · up %ds', tostring(s.version), s.arsenal and 'Arsenal' or 'Universal', s.fps, s.ping, s.uptime)
    end
    P3.CapEssays = {
        http = "HTTP powers WEAO, webhooks, server hop listings, and remote script loaders.",
        filesystem = "Filesystem stores Melo 🍃 profiles under the NOX_Hub folder when available.",
        clipboard = "Clipboard export copies JSON snapshots for sharing configs off-device.",
        drawing = "Drawing API prefers native FOV circles; ScreenGui rings are the fallback.",
        hooks = "Hooks enable deeper silent/gun integrations when the executor exposes them.",
        getgc = "getgc helps locate remotes/values on Universal places with weaker static paths.",
        gunmods = "Gunmods mutate Arsenal weapon values and stay locked on weak/non-Arsenal runs.",
    }
    function P3.CapEssays.forFeature(f)
        return P3.CapEssays[f] or ''
    end
    P3.HubState = { open = true, lastToggle = 0 }
    function P3.HubState.noteToggle(open)
        P3.HubState.open = open and true or false
        P3.HubState.lastToggle = os.clock()
        if setMenuBlur then pcall(setMenuBlur, P3.HubState.open) end
    end
    P3.PageSeeds = {}
    P3.PageSeeds.Aimbot_0 = { page = "Aimbot", seed = 0, weight = 0.2 }
    P3.PageSeeds.Aimbot_1 = { page = "Aimbot", seed = 1, weight = 0.25 }
    P3.PageSeeds.Aimbot_2 = { page = "Aimbot", seed = 2, weight = 0.30000000000000004 }
    P3.PageSeeds.Aimbot_3 = { page = "Aimbot", seed = 3, weight = 0.35000000000000003 }
    P3.PageSeeds.Aimbot_4 = { page = "Aimbot", seed = 4, weight = 0.4 }
    P3.PageSeeds.Aimbot_5 = { page = "Aimbot", seed = 5, weight = 0.45 }
    P3.PageSeeds.Aimbot_6 = { page = "Aimbot", seed = 6, weight = 0.5 }
    P3.PageSeeds.Aimbot_7 = { page = "Aimbot", seed = 7, weight = 0.55 }
    P3.PageSeeds.Aimbot_8 = { page = "Aimbot", seed = 8, weight = 0.6000000000000001 }
    P3.PageSeeds.Aimbot_9 = { page = "Aimbot", seed = 9, weight = 0.65 }
    P3.PageSeeds.Aimbot_10 = { page = "Aimbot", seed = 10, weight = 0.2 }
    P3.PageSeeds.Aimbot_11 = { page = "Aimbot", seed = 11, weight = 0.25 }
    P3.PageSeeds.Aimbot_12 = { page = "Aimbot", seed = 12, weight = 0.30000000000000004 }
    P3.PageSeeds.Aimbot_13 = { page = "Aimbot", seed = 13, weight = 0.35000000000000003 }
    P3.PageSeeds.Aimbot_14 = { page = "Aimbot", seed = 14, weight = 0.4 }
    P3.PageSeeds.Aimbot_15 = { page = "Aimbot", seed = 15, weight = 0.45 }
    P3.PageSeeds.Aimbot_16 = { page = "Aimbot", seed = 16, weight = 0.5 }
    P3.PageSeeds.Aimbot_17 = { page = "Aimbot", seed = 17, weight = 0.55 }
    P3.PageSeeds.Aimbot_18 = { page = "Aimbot", seed = 18, weight = 0.6000000000000001 }
    P3.PageSeeds.Aimbot_19 = { page = "Aimbot", seed = 19, weight = 0.65 }
    P3.PageSeeds.Aimbot_20 = { page = "Aimbot", seed = 20, weight = 0.2 }
    P3.PageSeeds.Aimbot_21 = { page = "Aimbot", seed = 21, weight = 0.25 }
    P3.PageSeeds.Aimbot_22 = { page = "Aimbot", seed = 22, weight = 0.30000000000000004 }
    P3.PageSeeds.Aimbot_23 = { page = "Aimbot", seed = 23, weight = 0.35000000000000003 }
    P3.PageSeeds.Aimbot_24 = { page = "Aimbot", seed = 24, weight = 0.4 }
    P3.PageSeeds.Aimbot_25 = { page = "Aimbot", seed = 25, weight = 0.45 }
    P3.PageSeeds.Aimbot_26 = { page = "Aimbot", seed = 26, weight = 0.5 }
    P3.PageSeeds.Aimbot_27 = { page = "Aimbot", seed = 27, weight = 0.55 }
    P3.PageSeeds.Aimbot_28 = { page = "Aimbot", seed = 28, weight = 0.6000000000000001 }
    P3.PageSeeds.Aimbot_29 = { page = "Aimbot", seed = 29, weight = 0.65 }
    P3.PageSeeds.Aimbot_30 = { page = "Aimbot", seed = 30, weight = 0.2 }
    P3.PageSeeds.Aimbot_31 = { page = "Aimbot", seed = 31, weight = 0.25 }
    P3.PageSeeds.Aimbot_32 = { page = "Aimbot", seed = 32, weight = 0.30000000000000004 }
    P3.PageSeeds.Aimbot_33 = { page = "Aimbot", seed = 33, weight = 0.35000000000000003 }
    P3.PageSeeds.Aimbot_34 = { page = "Aimbot", seed = 34, weight = 0.4 }
    P3.PageSeeds.Aimbot_35 = { page = "Aimbot", seed = 35, weight = 0.45 }
    P3.PageSeeds.Aimbot_36 = { page = "Aimbot", seed = 36, weight = 0.5 }
    P3.PageSeeds.Aimbot_37 = { page = "Aimbot", seed = 37, weight = 0.55 }
    P3.PageSeeds.Aimbot_38 = { page = "Aimbot", seed = 38, weight = 0.6000000000000001 }
    P3.PageSeeds.Aimbot_39 = { page = "Aimbot", seed = 39, weight = 0.65 }
    P3.PageSeeds.ESP_0 = { page = "ESP", seed = 0, weight = 0.2 }
    P3.PageSeeds.ESP_1 = { page = "ESP", seed = 1, weight = 0.25 }
    P3.PageSeeds.ESP_2 = { page = "ESP", seed = 2, weight = 0.30000000000000004 }
    P3.PageSeeds.ESP_3 = { page = "ESP", seed = 3, weight = 0.35000000000000003 }
    P3.PageSeeds.ESP_4 = { page = "ESP", seed = 4, weight = 0.4 }
    P3.PageSeeds.ESP_5 = { page = "ESP", seed = 5, weight = 0.45 }
    P3.PageSeeds.ESP_6 = { page = "ESP", seed = 6, weight = 0.5 }
    P3.PageSeeds.ESP_7 = { page = "ESP", seed = 7, weight = 0.55 }
    P3.PageSeeds.ESP_8 = { page = "ESP", seed = 8, weight = 0.6000000000000001 }
    P3.PageSeeds.ESP_9 = { page = "ESP", seed = 9, weight = 0.65 }
    P3.PageSeeds.ESP_10 = { page = "ESP", seed = 10, weight = 0.2 }
    P3.PageSeeds.ESP_11 = { page = "ESP", seed = 11, weight = 0.25 }
    P3.PageSeeds.ESP_12 = { page = "ESP", seed = 12, weight = 0.30000000000000004 }
    P3.PageSeeds.ESP_13 = { page = "ESP", seed = 13, weight = 0.35000000000000003 }
    P3.PageSeeds.ESP_14 = { page = "ESP", seed = 14, weight = 0.4 }
    P3.PageSeeds.ESP_15 = { page = "ESP", seed = 15, weight = 0.45 }
    P3.PageSeeds.ESP_16 = { page = "ESP", seed = 16, weight = 0.5 }
    P3.PageSeeds.ESP_17 = { page = "ESP", seed = 17, weight = 0.55 }
    P3.PageSeeds.ESP_18 = { page = "ESP", seed = 18, weight = 0.6000000000000001 }
    P3.PageSeeds.ESP_19 = { page = "ESP", seed = 19, weight = 0.65 }
    P3.PageSeeds.ESP_20 = { page = "ESP", seed = 20, weight = 0.2 }
    P3.PageSeeds.ESP_21 = { page = "ESP", seed = 21, weight = 0.25 }
    P3.PageSeeds.ESP_22 = { page = "ESP", seed = 22, weight = 0.30000000000000004 }
    P3.PageSeeds.ESP_23 = { page = "ESP", seed = 23, weight = 0.35000000000000003 }
    P3.PageSeeds.ESP_24 = { page = "ESP", seed = 24, weight = 0.4 }
    P3.PageSeeds.ESP_25 = { page = "ESP", seed = 25, weight = 0.45 }
    P3.PageSeeds.ESP_26 = { page = "ESP", seed = 26, weight = 0.5 }
    P3.PageSeeds.ESP_27 = { page = "ESP", seed = 27, weight = 0.55 }
    P3.PageSeeds.ESP_28 = { page = "ESP", seed = 28, weight = 0.6000000000000001 }
    P3.PageSeeds.ESP_29 = { page = "ESP", seed = 29, weight = 0.65 }
    P3.PageSeeds.ESP_30 = { page = "ESP", seed = 30, weight = 0.2 }
    P3.PageSeeds.ESP_31 = { page = "ESP", seed = 31, weight = 0.25 }
    P3.PageSeeds.ESP_32 = { page = "ESP", seed = 32, weight = 0.30000000000000004 }
    P3.PageSeeds.ESP_33 = { page = "ESP", seed = 33, weight = 0.35000000000000003 }
    P3.PageSeeds.ESP_34 = { page = "ESP", seed = 34, weight = 0.4 }
    P3.PageSeeds.ESP_35 = { page = "ESP", seed = 35, weight = 0.45 }
    P3.PageSeeds.ESP_36 = { page = "ESP", seed = 36, weight = 0.5 }
    P3.PageSeeds.ESP_37 = { page = "ESP", seed = 37, weight = 0.55 }
    P3.PageSeeds.ESP_38 = { page = "ESP", seed = 38, weight = 0.6000000000000001 }
    P3.PageSeeds.ESP_39 = { page = "ESP", seed = 39, weight = 0.65 }
    P3.PageSeeds.General_0 = { page = "General", seed = 0, weight = 0.2 }
    P3.PageSeeds.General_1 = { page = "General", seed = 1, weight = 0.25 }
    P3.PageSeeds.General_2 = { page = "General", seed = 2, weight = 0.30000000000000004 }
    P3.PageSeeds.General_3 = { page = "General", seed = 3, weight = 0.35000000000000003 }
    P3.PageSeeds.General_4 = { page = "General", seed = 4, weight = 0.4 }
    P3.PageSeeds.General_5 = { page = "General", seed = 5, weight = 0.45 }
    P3.PageSeeds.General_6 = { page = "General", seed = 6, weight = 0.5 }
    P3.PageSeeds.General_7 = { page = "General", seed = 7, weight = 0.55 }
    P3.PageSeeds.General_8 = { page = "General", seed = 8, weight = 0.6000000000000001 }
    P3.PageSeeds.General_9 = { page = "General", seed = 9, weight = 0.65 }
    P3.PageSeeds.General_10 = { page = "General", seed = 10, weight = 0.2 }
    P3.PageSeeds.General_11 = { page = "General", seed = 11, weight = 0.25 }
    P3.PageSeeds.General_12 = { page = "General", seed = 12, weight = 0.30000000000000004 }
    P3.PageSeeds.General_13 = { page = "General", seed = 13, weight = 0.35000000000000003 }
    P3.PageSeeds.General_14 = { page = "General", seed = 14, weight = 0.4 }
    P3.PageSeeds.General_15 = { page = "General", seed = 15, weight = 0.45 }
    P3.PageSeeds.General_16 = { page = "General", seed = 16, weight = 0.5 }
    P3.PageSeeds.General_17 = { page = "General", seed = 17, weight = 0.55 }
    P3.PageSeeds.General_18 = { page = "General", seed = 18, weight = 0.6000000000000001 }
    P3.PageSeeds.General_19 = { page = "General", seed = 19, weight = 0.65 }
    P3.PageSeeds.General_20 = { page = "General", seed = 20, weight = 0.2 }
    P3.PageSeeds.General_21 = { page = "General", seed = 21, weight = 0.25 }
    P3.PageSeeds.General_22 = { page = "General", seed = 22, weight = 0.30000000000000004 }
    P3.PageSeeds.General_23 = { page = "General", seed = 23, weight = 0.35000000000000003 }
    P3.PageSeeds.General_24 = { page = "General", seed = 24, weight = 0.4 }
    P3.PageSeeds.General_25 = { page = "General", seed = 25, weight = 0.45 }
    P3.PageSeeds.General_26 = { page = "General", seed = 26, weight = 0.5 }
    P3.PageSeeds.General_27 = { page = "General", seed = 27, weight = 0.55 }
    P3.PageSeeds.General_28 = { page = "General", seed = 28, weight = 0.6000000000000001 }
    P3.PageSeeds.General_29 = { page = "General", seed = 29, weight = 0.65 }
    P3.PageSeeds.General_30 = { page = "General", seed = 30, weight = 0.2 }
    P3.PageSeeds.General_31 = { page = "General", seed = 31, weight = 0.25 }
    P3.PageSeeds.General_32 = { page = "General", seed = 32, weight = 0.30000000000000004 }
    P3.PageSeeds.General_33 = { page = "General", seed = 33, weight = 0.35000000000000003 }
    P3.PageSeeds.General_34 = { page = "General", seed = 34, weight = 0.4 }
    P3.PageSeeds.General_35 = { page = "General", seed = 35, weight = 0.45 }
    P3.PageSeeds.General_36 = { page = "General", seed = 36, weight = 0.5 }
    P3.PageSeeds.General_37 = { page = "General", seed = 37, weight = 0.55 }
    P3.PageSeeds.General_38 = { page = "General", seed = 38, weight = 0.6000000000000001 }
    P3.PageSeeds.General_39 = { page = "General", seed = 39, weight = 0.65 }
    P3.PageSeeds.Audio_0 = { page = "Audio", seed = 0, weight = 0.2 }
    P3.PageSeeds.Audio_1 = { page = "Audio", seed = 1, weight = 0.25 }
    P3.PageSeeds.Audio_2 = { page = "Audio", seed = 2, weight = 0.30000000000000004 }
    P3.PageSeeds.Audio_3 = { page = "Audio", seed = 3, weight = 0.35000000000000003 }
    P3.PageSeeds.Audio_4 = { page = "Audio", seed = 4, weight = 0.4 }
    P3.PageSeeds.Audio_5 = { page = "Audio", seed = 5, weight = 0.45 }
    P3.PageSeeds.Audio_6 = { page = "Audio", seed = 6, weight = 0.5 }
    P3.PageSeeds.Audio_7 = { page = "Audio", seed = 7, weight = 0.55 }
    P3.PageSeeds.Audio_8 = { page = "Audio", seed = 8, weight = 0.6000000000000001 }
    P3.PageSeeds.Audio_9 = { page = "Audio", seed = 9, weight = 0.65 }
    P3.PageSeeds.Audio_10 = { page = "Audio", seed = 10, weight = 0.2 }
    P3.PageSeeds.Audio_11 = { page = "Audio", seed = 11, weight = 0.25 }
    P3.PageSeeds.Audio_12 = { page = "Audio", seed = 12, weight = 0.30000000000000004 }
    P3.PageSeeds.Audio_13 = { page = "Audio", seed = 13, weight = 0.35000000000000003 }
    P3.PageSeeds.Audio_14 = { page = "Audio", seed = 14, weight = 0.4 }
    P3.PageSeeds.Audio_15 = { page = "Audio", seed = 15, weight = 0.45 }
    P3.PageSeeds.Audio_16 = { page = "Audio", seed = 16, weight = 0.5 }
    P3.PageSeeds.Audio_17 = { page = "Audio", seed = 17, weight = 0.55 }
    P3.PageSeeds.Audio_18 = { page = "Audio", seed = 18, weight = 0.6000000000000001 }
    P3.PageSeeds.Audio_19 = { page = "Audio", seed = 19, weight = 0.65 }
    P3.PageSeeds.Audio_20 = { page = "Audio", seed = 20, weight = 0.2 }
    P3.PageSeeds.Audio_21 = { page = "Audio", seed = 21, weight = 0.25 }
    P3.PageSeeds.Audio_22 = { page = "Audio", seed = 22, weight = 0.30000000000000004 }
    P3.PageSeeds.Audio_23 = { page = "Audio", seed = 23, weight = 0.35000000000000003 }
    P3.PageSeeds.Audio_24 = { page = "Audio", seed = 24, weight = 0.4 }
    P3.PageSeeds.Audio_25 = { page = "Audio", seed = 25, weight = 0.45 }
    P3.PageSeeds.Audio_26 = { page = "Audio", seed = 26, weight = 0.5 }
    P3.PageSeeds.Audio_27 = { page = "Audio", seed = 27, weight = 0.55 }
    P3.PageSeeds.Audio_28 = { page = "Audio", seed = 28, weight = 0.6000000000000001 }
    P3.PageSeeds.Audio_29 = { page = "Audio", seed = 29, weight = 0.65 }
    P3.PageSeeds.Audio_30 = { page = "Audio", seed = 30, weight = 0.2 }
    P3.PageSeeds.Audio_31 = { page = "Audio", seed = 31, weight = 0.25 }
    P3.PageSeeds.Audio_32 = { page = "Audio", seed = 32, weight = 0.30000000000000004 }
    P3.PageSeeds.Audio_33 = { page = "Audio", seed = 33, weight = 0.35000000000000003 }
    P3.PageSeeds.Audio_34 = { page = "Audio", seed = 34, weight = 0.4 }
    P3.PageSeeds.Audio_35 = { page = "Audio", seed = 35, weight = 0.45 }
    P3.PageSeeds.Audio_36 = { page = "Audio", seed = 36, weight = 0.5 }
    P3.PageSeeds.Audio_37 = { page = "Audio", seed = 37, weight = 0.55 }
    P3.PageSeeds.Audio_38 = { page = "Audio", seed = 38, weight = 0.6000000000000001 }
    P3.PageSeeds.Audio_39 = { page = "Audio", seed = 39, weight = 0.65 }
    P3.PageSeeds.Settings_0 = { page = "Settings", seed = 0, weight = 0.2 }
    P3.PageSeeds.Settings_1 = { page = "Settings", seed = 1, weight = 0.25 }
    P3.PageSeeds.Settings_2 = { page = "Settings", seed = 2, weight = 0.30000000000000004 }
    P3.PageSeeds.Settings_3 = { page = "Settings", seed = 3, weight = 0.35000000000000003 }
    P3.PageSeeds.Settings_4 = { page = "Settings", seed = 4, weight = 0.4 }
    P3.PageSeeds.Settings_5 = { page = "Settings", seed = 5, weight = 0.45 }
    P3.PageSeeds.Settings_6 = { page = "Settings", seed = 6, weight = 0.5 }
    P3.PageSeeds.Settings_7 = { page = "Settings", seed = 7, weight = 0.55 }
    P3.PageSeeds.Settings_8 = { page = "Settings", seed = 8, weight = 0.6000000000000001 }
    P3.PageSeeds.Settings_9 = { page = "Settings", seed = 9, weight = 0.65 }
    P3.PageSeeds.Settings_10 = { page = "Settings", seed = 10, weight = 0.2 }
    P3.PageSeeds.Settings_11 = { page = "Settings", seed = 11, weight = 0.25 }
    P3.PageSeeds.Settings_12 = { page = "Settings", seed = 12, weight = 0.30000000000000004 }
    P3.PageSeeds.Settings_13 = { page = "Settings", seed = 13, weight = 0.35000000000000003 }
    P3.PageSeeds.Settings_14 = { page = "Settings", seed = 14, weight = 0.4 }
    P3.PageSeeds.Settings_15 = { page = "Settings", seed = 15, weight = 0.45 }
    P3.PageSeeds.Settings_16 = { page = "Settings", seed = 16, weight = 0.5 }
    P3.PageSeeds.Settings_17 = { page = "Settings", seed = 17, weight = 0.55 }
    P3.PageSeeds.Settings_18 = { page = "Settings", seed = 18, weight = 0.6000000000000001 }
    P3.PageSeeds.Settings_19 = { page = "Settings", seed = 19, weight = 0.65 }
    P3.PageSeeds.Settings_20 = { page = "Settings", seed = 20, weight = 0.2 }
    P3.PageSeeds.Settings_21 = { page = "Settings", seed = 21, weight = 0.25 }
    P3.PageSeeds.Settings_22 = { page = "Settings", seed = 22, weight = 0.30000000000000004 }
    P3.PageSeeds.Settings_23 = { page = "Settings", seed = 23, weight = 0.35000000000000003 }
    P3.PageSeeds.Settings_24 = { page = "Settings", seed = 24, weight = 0.4 }
    P3.PageSeeds.Settings_25 = { page = "Settings", seed = 25, weight = 0.45 }
    P3.PageSeeds.Settings_26 = { page = "Settings", seed = 26, weight = 0.5 }
    P3.PageSeeds.Settings_27 = { page = "Settings", seed = 27, weight = 0.55 }
    P3.PageSeeds.Settings_28 = { page = "Settings", seed = 28, weight = 0.6000000000000001 }
    P3.PageSeeds.Settings_29 = { page = "Settings", seed = 29, weight = 0.65 }
    P3.PageSeeds.Settings_30 = { page = "Settings", seed = 30, weight = 0.2 }
    P3.PageSeeds.Settings_31 = { page = "Settings", seed = 31, weight = 0.25 }
    P3.PageSeeds.Settings_32 = { page = "Settings", seed = 32, weight = 0.30000000000000004 }
    P3.PageSeeds.Settings_33 = { page = "Settings", seed = 33, weight = 0.35000000000000003 }
    P3.PageSeeds.Settings_34 = { page = "Settings", seed = 34, weight = 0.4 }
    P3.PageSeeds.Settings_35 = { page = "Settings", seed = 35, weight = 0.45 }
    P3.PageSeeds.Settings_36 = { page = "Settings", seed = 36, weight = 0.5 }
    P3.PageSeeds.Settings_37 = { page = "Settings", seed = 37, weight = 0.55 }
    P3.PageSeeds.Settings_38 = { page = "Settings", seed = 38, weight = 0.6000000000000001 }
    P3.PageSeeds.Settings_39 = { page = "Settings", seed = 39, weight = 0.65 }
    P3.PageSeeds.Report_0 = { page = "Report", seed = 0, weight = 0.2 }
    P3.PageSeeds.Report_1 = { page = "Report", seed = 1, weight = 0.25 }
    P3.PageSeeds.Report_2 = { page = "Report", seed = 2, weight = 0.30000000000000004 }
    P3.PageSeeds.Report_3 = { page = "Report", seed = 3, weight = 0.35000000000000003 }
    P3.PageSeeds.Report_4 = { page = "Report", seed = 4, weight = 0.4 }
    P3.PageSeeds.Report_5 = { page = "Report", seed = 5, weight = 0.45 }
    P3.PageSeeds.Report_6 = { page = "Report", seed = 6, weight = 0.5 }
    P3.PageSeeds.Report_7 = { page = "Report", seed = 7, weight = 0.55 }
    P3.PageSeeds.Report_8 = { page = "Report", seed = 8, weight = 0.6000000000000001 }
    P3.PageSeeds.Report_9 = { page = "Report", seed = 9, weight = 0.65 }
    P3.PageSeeds.Report_10 = { page = "Report", seed = 10, weight = 0.2 }
    P3.PageSeeds.Report_11 = { page = "Report", seed = 11, weight = 0.25 }
    P3.PageSeeds.Report_12 = { page = "Report", seed = 12, weight = 0.30000000000000004 }
    P3.PageSeeds.Report_13 = { page = "Report", seed = 13, weight = 0.35000000000000003 }
    P3.PageSeeds.Report_14 = { page = "Report", seed = 14, weight = 0.4 }
    P3.PageSeeds.Report_15 = { page = "Report", seed = 15, weight = 0.45 }
    P3.PageSeeds.Report_16 = { page = "Report", seed = 16, weight = 0.5 }
    P3.PageSeeds.Report_17 = { page = "Report", seed = 17, weight = 0.55 }
    P3.PageSeeds.Report_18 = { page = "Report", seed = 18, weight = 0.6000000000000001 }
    P3.PageSeeds.Report_19 = { page = "Report", seed = 19, weight = 0.65 }
    P3.PageSeeds.Report_20 = { page = "Report", seed = 20, weight = 0.2 }
    P3.PageSeeds.Report_21 = { page = "Report", seed = 21, weight = 0.25 }
    P3.PageSeeds.Report_22 = { page = "Report", seed = 22, weight = 0.30000000000000004 }
    P3.PageSeeds.Report_23 = { page = "Report", seed = 23, weight = 0.35000000000000003 }
    P3.PageSeeds.Report_24 = { page = "Report", seed = 24, weight = 0.4 }
    P3.PageSeeds.Report_25 = { page = "Report", seed = 25, weight = 0.45 }
    P3.PageSeeds.Report_26 = { page = "Report", seed = 26, weight = 0.5 }
    P3.PageSeeds.Report_27 = { page = "Report", seed = 27, weight = 0.55 }
    P3.PageSeeds.Report_28 = { page = "Report", seed = 28, weight = 0.6000000000000001 }
    P3.PageSeeds.Report_29 = { page = "Report", seed = 29, weight = 0.65 }
    P3.PageSeeds.Report_30 = { page = "Report", seed = 30, weight = 0.2 }
    P3.PageSeeds.Report_31 = { page = "Report", seed = 31, weight = 0.25 }
    P3.PageSeeds.Report_32 = { page = "Report", seed = 32, weight = 0.30000000000000004 }
    P3.PageSeeds.Report_33 = { page = "Report", seed = 33, weight = 0.35000000000000003 }
    P3.PageSeeds.Report_34 = { page = "Report", seed = 34, weight = 0.4 }
    P3.PageSeeds.Report_35 = { page = "Report", seed = 35, weight = 0.45 }
    P3.PageSeeds.Report_36 = { page = "Report", seed = 36, weight = 0.5 }
    P3.PageSeeds.Report_37 = { page = "Report", seed = 37, weight = 0.55 }
    P3.PageSeeds.Report_38 = { page = "Report", seed = 38, weight = 0.6000000000000001 }
    P3.PageSeeds.Report_39 = { page = "Report", seed = 39, weight = 0.65 }
    function P3.PageSeeds.list(page)
        local out = {}
        for k, v in pairs(P3.PageSeeds) do
            if type(v) == 'table' and v.page == page then table.insert(out, v) end
        end
        return out
    end
    return P3
end)();
(function()
    local prev = TraceV2BindMD
    TraceV2BindMD = function(MD)
        if prev then prev(MD) end
        if MD then MD.TracePack3 = TracePack3 end
    end
end)()
TraceAnim = (function()
    local A = {}
    A.RailIn = { t = 0.22, style = Enum.EasingStyle.Quint, dir = Enum.EasingDirection.Out }
    A.RailOut = { t = 0.18, style = Enum.EasingStyle.Quad, dir = Enum.EasingDirection.Out }
    A.CardIn = { t = 0.2, style = Enum.EasingStyle.Cubic, dir = Enum.EasingDirection.Out }
    A.CardOut = { t = 0.15, style = Enum.EasingStyle.Quad, dir = Enum.EasingDirection.Out }
    A.FadeIn = { t = 0.16, style = Enum.EasingStyle.Sine, dir = Enum.EasingDirection.Out }
    A.FadeOut = { t = 0.12, style = Enum.EasingStyle.Sine, dir = Enum.EasingDirection.Out }
    A.Punch = { t = 0.28, style = Enum.EasingStyle.Back, dir = Enum.EasingDirection.Out }
    A.Soft = { t = 0.3, style = Enum.EasingStyle.Exponential, dir = Enum.EasingDirection.Out }
    function A.play(obj, name, props)
        local p = A[name] or A.FadeIn
        return UILib.tween(obj, p.t, props, p.style, p.dir)
    end
    function A.micro_0(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_1(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_2(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_3(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_4(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_5(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_6(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_7(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_8(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_9(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_10(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_11(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_12(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_13(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_14(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_15(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_16(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_17(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_18(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_19(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_20(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_21(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_22(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_23(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_24(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_25(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_26(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_27(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_28(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_29(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_30(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_31(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_32(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_33(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_34(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_35(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_36(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_37(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_38(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_39(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_40(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_41(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_42(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_43(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_44(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_45(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_46(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_47(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_48(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_49(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_50(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_51(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_52(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_53(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_54(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_55(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_56(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_57(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_58(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_59(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_60(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_61(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_62(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_63(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_64(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_65(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_66(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_67(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_68(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_69(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_70(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_71(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_72(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_73(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_74(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_75(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_76(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_77(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_78(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_79(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_80(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_81(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_82(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_83(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_84(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_85(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_86(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_87(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_88(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_89(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_90(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_91(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_92(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_93(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_94(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_95(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.96
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_96(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.965
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_97(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.97
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_98(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.975
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function A.micro_99(obj)
        if not obj then return end
        local sc = obj:FindFirstChildOfClass('UIScale')
        if not sc then sc = Instance.new('UIScale'); sc.Parent = obj end
        sc.Scale = 0.98
        UILib.tween(sc, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    return A
end)();
(function()
    local LockAssert = {}
    function LockAssert.gunmodsExpected()
        local name = string.lower(tostring(getExecutorName and getExecutorName() or ''))
        if string.find(name, 'xeno', 1, true) or string.find(name, 'solara', 1, true) then
            return false, 'XENO/SOLARA'
        end
        if not MW.isArsenal then return false, 'NON-ARSENAL' end
        return Cap.ok('gunmods'), Cap.why and Cap.why('gunmods') or nil
    end
    function LockAssert.summary()
        local ok, why = LockAssert.gunmodsExpected()
        return ok and 'gunmods OK' or ('gunmods LOCKED: ' .. tostring(why or 'Cap'))
    end
    if TraceExpand then TraceExpand.LockAssert = LockAssert end
    local prev = TraceV2BindMD
    TraceV2BindMD = function(MD)
        if prev then prev(MD) end
        if MD then MD.LockAssert = LockAssert end
    end
end)()
TraceUnloadChecklist = (function()
    local C = {
        'menu blur', 'HUD root', 'FOV drawings', 'ESP pools', 'gun wireframe',
        'audio', 'connections', 'screen gui', 'rage/trigger', 'infinite ammo',
    }
    function C.lines() return C end
    C.step_0 = function()
        return 'unload-step-0'
    end
    C.step_1 = function()
        return 'unload-step-1'
    end
    C.step_2 = function()
        return 'unload-step-2'
    end
    C.step_3 = function()
        return 'unload-step-3'
    end
    C.step_4 = function()
        return 'unload-step-4'
    end
    C.step_5 = function()
        return 'unload-step-5'
    end
    C.step_6 = function()
        return 'unload-step-6'
    end
    C.step_7 = function()
        return 'unload-step-7'
    end
    C.step_8 = function()
        return 'unload-step-8'
    end
    C.step_9 = function()
        return 'unload-step-9'
    end
    C.step_10 = function()
        return 'unload-step-10'
    end
    C.step_11 = function()
        return 'unload-step-11'
    end
    C.step_12 = function()
        return 'unload-step-12'
    end
    C.step_13 = function()
        return 'unload-step-13'
    end
    C.step_14 = function()
        return 'unload-step-14'
    end
    C.step_15 = function()
        return 'unload-step-15'
    end
    C.step_16 = function()
        return 'unload-step-16'
    end
    C.step_17 = function()
        return 'unload-step-17'
    end
    C.step_18 = function()
        return 'unload-step-18'
    end
    C.step_19 = function()
        return 'unload-step-19'
    end
    C.step_20 = function()
        return 'unload-step-20'
    end
    C.step_21 = function()
        return 'unload-step-21'
    end
    C.step_22 = function()
        return 'unload-step-22'
    end
    C.step_23 = function()
        return 'unload-step-23'
    end
    C.step_24 = function()
        return 'unload-step-24'
    end
    C.step_25 = function()
        return 'unload-step-25'
    end
    C.step_26 = function()
        return 'unload-step-26'
    end
    C.step_27 = function()
        return 'unload-step-27'
    end
    C.step_28 = function()
        return 'unload-step-28'
    end
    C.step_29 = function()
        return 'unload-step-29'
    end
    C.step_30 = function()
        return 'unload-step-30'
    end
    C.step_31 = function()
        return 'unload-step-31'
    end
    C.step_32 = function()
        return 'unload-step-32'
    end
    C.step_33 = function()
        return 'unload-step-33'
    end
    C.step_34 = function()
        return 'unload-step-34'
    end
    C.step_35 = function()
        return 'unload-step-35'
    end
    C.step_36 = function()
        return 'unload-step-36'
    end
    C.step_37 = function()
        return 'unload-step-37'
    end
    C.step_38 = function()
        return 'unload-step-38'
    end
    C.step_39 = function()
        return 'unload-step-39'
    end
    C.step_40 = function()
        return 'unload-step-40'
    end
    C.step_41 = function()
        return 'unload-step-41'
    end
    C.step_42 = function()
        return 'unload-step-42'
    end
    C.step_43 = function()
        return 'unload-step-43'
    end
    C.step_44 = function()
        return 'unload-step-44'
    end
    C.step_45 = function()
        return 'unload-step-45'
    end
    C.step_46 = function()
        return 'unload-step-46'
    end
    C.step_47 = function()
        return 'unload-step-47'
    end
    C.step_48 = function()
        return 'unload-step-48'
    end
    C.step_49 = function()
        return 'unload-step-49'
    end
    C.step_50 = function()
        return 'unload-step-50'
    end
    C.step_51 = function()
        return 'unload-step-51'
    end
    C.step_52 = function()
        return 'unload-step-52'
    end
    C.step_53 = function()
        return 'unload-step-53'
    end
    C.step_54 = function()
        return 'unload-step-54'
    end
    C.step_55 = function()
        return 'unload-step-55'
    end
    C.step_56 = function()
        return 'unload-step-56'
    end
    C.step_57 = function()
        return 'unload-step-57'
    end
    C.step_58 = function()
        return 'unload-step-58'
    end
    C.step_59 = function()
        return 'unload-step-59'
    end
    C.step_60 = function()
        return 'unload-step-60'
    end
    C.step_61 = function()
        return 'unload-step-61'
    end
    C.step_62 = function()
        return 'unload-step-62'
    end
    C.step_63 = function()
        return 'unload-step-63'
    end
    C.step_64 = function()
        return 'unload-step-64'
    end
    C.step_65 = function()
        return 'unload-step-65'
    end
    C.step_66 = function()
        return 'unload-step-66'
    end
    C.step_67 = function()
        return 'unload-step-67'
    end
    C.step_68 = function()
        return 'unload-step-68'
    end
    C.step_69 = function()
        return 'unload-step-69'
    end
    C.step_70 = function()
        return 'unload-step-70'
    end
    C.step_71 = function()
        return 'unload-step-71'
    end
    C.step_72 = function()
        return 'unload-step-72'
    end
    C.step_73 = function()
        return 'unload-step-73'
    end
    C.step_74 = function()
        return 'unload-step-74'
    end
    C.step_75 = function()
        return 'unload-step-75'
    end
    C.step_76 = function()
        return 'unload-step-76'
    end
    C.step_77 = function()
        return 'unload-step-77'
    end
    C.step_78 = function()
        return 'unload-step-78'
    end
    C.step_79 = function()
        return 'unload-step-79'
    end
    return C
end)()
TraceBindMatrix = (function()
    local M = {}
    M.ToggleGUI_0 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_1 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_2 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_3 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_4 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_5 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_6 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_7 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_8 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_9 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_10 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_11 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_12 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_13 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_14 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_15 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_16 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_17 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_18 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_19 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_20 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_21 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_22 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_23 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleGUI_24 = function(v)
        return 'ToggleGUI:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_0 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_1 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_2 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_3 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_4 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_5 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_6 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_7 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_8 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_9 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_10 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_11 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_12 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_13 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_14 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_15 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_16 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_17 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_18 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_19 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_20 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_21 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_22 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_23 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.PanicKey_24 = function(v)
        return 'PanicKey:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_0 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_1 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_2 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_3 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_4 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_5 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_6 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_7 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_8 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_9 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_10 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_11 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_12 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_13 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_14 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_15 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_16 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_17 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_18 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_19 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_20 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_21 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_22 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_23 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.CycleTarget_24 = function(v)
        return 'CycleTarget:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_0 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_1 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_2 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_3 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_4 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_5 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_6 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_7 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_8 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_9 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_10 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_11 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_12 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_13 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_14 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_15 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_16 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_17 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_18 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_19 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_20 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_21 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_22 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_23 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleTriggerBot_24 = function(v)
        return 'ToggleTriggerBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_0 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_1 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_2 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_3 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_4 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_5 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_6 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_7 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_8 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_9 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_10 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_11 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_12 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_13 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_14 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_15 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_16 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_17 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_18 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_19 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_20 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_21 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_22 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_23 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleRageBot_24 = function(v)
        return 'ToggleRageBot:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_0 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_1 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_2 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_3 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_4 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_5 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_6 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_7 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_8 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_9 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_10 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_11 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_12 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_13 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_14 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_15 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_16 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_17 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_18 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_19 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_20 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_21 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_22 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_23 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleFly_24 = function(v)
        return 'ToggleFly:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_0 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_1 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_2 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_3 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_4 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_5 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_6 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_7 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_8 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_9 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_10 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_11 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_12 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_13 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_14 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_15 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_16 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_17 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_18 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_19 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_20 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_21 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_22 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_23 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    M.ToggleAutoTP_24 = function(v)
        return 'ToggleAutoTP:' .. tostring(v and v.Name or 'None')
    end
    function M.render()
        local rows = {}
        local kb = Settings.Keybinds or {}
        for _, k in ipairs({'ToggleGUI','PanicKey','CycleTarget','ToggleTriggerBot','ToggleRageBot','ToggleFly','ToggleAutoTP','ToggleNoclip','ClickTP','ToggleAutoObby'}) do
            local v = kb[k]
            table.insert(rows, k .. ' = ' .. tostring(v and v.Name or 'None'))
        end
        return rows
    end
    return M
end)();
end)()
