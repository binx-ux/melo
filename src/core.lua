local MW = {
    version = "17",
    releaseBase = "",
    integrity = "nox_hub_v1",
    placeId = 286090429,
    places = {
        Arsenal = 286090429,
        Brookhaven = 4924922222,
        MM2 = 142823291,
        PhantomForces = 292439477,
        MiscGunTestX = 9157605735,
    },
    hub = "Melo 🍃",
    byline = "Script Hub",
    tagline = "Melo 🍃 | Script Hub",
    fullName = "Melo 🍃 | Script Hub",
}
local GameKits = {
    list = {},
    byPlace = {},
    active = nil,
}
function GameKits.register(kit)
    if type(kit) ~= "table" or not kit.id then return false end
    GameKits.list[kit.id] = kit
    local ids = kit.placeIds or {}
    for i = 1, #ids do
        GameKits.byPlace[tonumber(ids[i]) or 0] = kit
    end
    return true
end
function GameKits.get(placeId)
    placeId = tonumber(placeId) or game.PlaceId
    return GameKits.byPlace[placeId] or GameKits.list.universal
end
function GameKits.resolve()
    local kit = GameKits.get(game.PlaceId)
    GameKits.active = kit
    return kit
end
GameKits.register({
    id = "arsenal",
    placeIds = { MW.places.Arsenal },
    label = "Arsenal",
    summary = "Combat kit: gun mods when Cap allows",
    features = {
        aim = true, combat = true, gunmods = true, rage = true, trigger = true,
        gunProfiles = true, hitKillAudio = true, autoTp = true,
        obby = false, universalWorld = false, brookhaven = false, bhRp = false,
        mm2 = false, phantomforces = false,
    },
})
GameKits.register({
    id = "brookhaven",
    placeIds = { MW.places.Brookhaven },
    label = "Brookhaven",
    summary = "RP kit: movement, locations, vehicles",
    features = {
        aim = false, combat = false, gunmods = false, rage = false, trigger = false,
        gunProfiles = false, hitKillAudio = false, autoTp = false,
        obby = false, universalWorld = false, brookhaven = true, bhRp = true,
        mm2 = false, phantomforces = false,
    },
})
GameKits.register({
    id = "universal",
    placeIds = {},
    label = "Universal",
    summary = "Universal kit: movement, TP, Auto Obby, ESP",
    features = {
        aim = false, combat = false, gunmods = false, rage = false, trigger = false,
        gunProfiles = false, hitKillAudio = false, autoTp = false,
        obby = true, universalWorld = true, brookhaven = false, bhRp = false,
        mm2 = false, phantomforces = false,
    },
})
GameKits.register({
    id = "miscgintest",
    placeIds = { MW.places.MiscGunTestX },
    label = "MiscGunTest",
    summary = "ACS kit: Camera aim, ESP, fly/speed. Gun mods in testing. Hitbox/TP locked",
    features = {
        aim = true, combat = true, gunmods = true, rage = false, trigger = true,
        gunProfiles = false, hitKillAudio = true, autoTp = false,
        obby = false, universalWorld = false, brookhaven = false, bhRp = false,
        fly = true, noclip = false, clickTp = false, speedHack = true,
        mm2 = false, phantomforces = false,
    },
    guards = {
        hitbox = true,
        pos = true,
    },
    boot = function()
        pcall(function()
            if Settings and Settings.Aimbot then
                Settings.Aimbot.AimMode = "Camera"
                Settings.Aimbot.SilentHitbox = false
            end
            if Settings and Settings.Combat then
                Settings.Combat.RageBot = false
                Settings.Combat.WallBang = false
                Settings.Combat.FastReload = false
                Settings.Combat.FastFireRate = false
                Settings.Combat.AlwaysAuto = false
                Settings.Combat.NoSpread = false
                Settings.Combat.NoRecoil = false
                Settings.Combat.InfiniteAmmo = false
            end
            if Settings and Settings.Movement then
                Settings.Movement.Noclip = false
                Settings.Movement.ClickTP = false
                if not Settings.Movement.FlyMethod or Settings.Movement.FlyMethod == "" then
                    Settings.Movement.FlyMethod = "Velocity"
                end
                if not Settings.Movement.SpeedMethod or Settings.Movement.SpeedMethod == "" then
                    Settings.Movement.SpeedMethod = "WalkSpeed"
                end
            end
            if Settings and Settings.Misc then
                Settings.Misc.AutoTPLoop = false
            end
        end)
        pcall(function()
            if sendNotification then
                sendNotification("MiscGunTest", "Gun mods in testing. Fly/speed on. Hitbox/TP locked", 4)
            end
        end)
    end,
    teardown = function()
        pcall(function()
            if SilentHB and SilentHB.restoreAll then SilentHB.restoreAll() end
        end)
    end,
})
GameKits.register({
    id = "mm2",
    placeIds = { MW.places.MM2 },
    label = "MM2",
    summary = "Murder Mystery 2: role ESP, farm, sheriff shoot, kill aura",
    features = {
        aim = false, combat = false, gunmods = false, rage = false, trigger = false,
        gunProfiles = false, hitKillAudio = false, autoTp = false,
        obby = false, universalWorld = false, brookhaven = false, bhRp = false,
        fly = true, noclip = false, clickTp = false, speedHack = true,
        mm2 = true, phantomforces = false,
    },
    guards = { hitbox = false, pos = false },
    boot = function()
        task.spawn(function()
            local m = MW.TraceMM2
            if not m or not m.start then
                warn("[Melo 🍃] MM2 module missing")
                return
            end
            local ok, err = pcall(m.start)
            if not ok then
                warn("[Melo 🍃] MM2 start failed: " .. tostring(err))
            end
        end)
    end,
    teardown = function()
        pcall(function()
            local m = MW.TraceMM2
            if m and m.stop then m.stop() end
        end)
    end,
})
GameKits.register({
    id = "phantomforces",
    placeIds = { MW.places.PhantomForces },
    label = "Phantom Forces",
    summary = "PF kit: silent + camera aim, ESP on replicated bodies, team colors, soft gun mods",
    features = {
        aim = true, combat = false, gunmods = false, rage = false, trigger = true,
        gunProfiles = false, hitKillAudio = false, autoTp = false,
        obby = false, universalWorld = false, brookhaven = false, bhRp = false,
        fly = false, noclip = false, clickTp = false, speedHack = false,
        mm2 = false, phantomforces = true,
    },
    guards = { hitbox = true, pos = true },
    boot = function()
        task.spawn(function()
            local m = MW.TracePF
            if not m or not m.start then
                warn("[Melo 🍃] PF module missing")
                return
            end
            local ok, err = pcall(m.start)
            if not ok then
                warn("[Melo 🍃] PF start failed: " .. tostring(err))
            end
        end)
    end,
    teardown = function()
        pcall(function()
            local m = MW.TracePF
            if m and m.stop then m.stop() end
        end)
    end,
})
do
    local kit = GameKits.resolve()
    MW.isArsenal = kit.id == "arsenal"
    MW.isBrookhaven = kit.id == "brookhaven"
    MW.isMiscGunTest = kit.id == "miscgintest"
    MW.isMM2 = kit.id == "mm2"
    MW.isPF = kit.id == "phantomforces"
    MW.gunModsInTesting = kit.id == "miscgintest"
    MW.mode = kit.label or "Universal"
    MW.kitId = kit.id
    MW.GameKits = GameKits
end
MW.display = "1." .. MW.version .. " - " .. MW.mode
MW.versionUrl = "https://trace-host.vercel.app/version.txt"
MW.changelogUrl = "https://trace-host.vercel.app/changelog.json"
function MW.isUniversal()
    return MW.kitId == "universal" or MW.mode == "Universal"
end
local KIT_EXCLUSIVE = {
    mm2 = true,
    phantomforces = true,
    brookhaven = true,
    bhRp = true,
    arsenalCombat = true,
}
function MW.allows(feature)
    local kit = GameKits.active or GameKits.resolve()
    local feats = kit and kit.features
    if type(feats) == "table" and feats[feature] ~= nil then
        return feats[feature] == true
    end

    if KIT_EXCLUSIVE[feature] then
        return false
    end
    return true
end
function MW.isKit(id)
    return MW.kitId == id
end
function MW.guard(name)
    local kit = GameKits.active or GameKits.resolve()
    local g = kit and kit.guards
    return type(g) == "table" and g[name] == true
end
function MW.kitSummary()
    local kit = GameKits.active or GameKits.resolve()
    return (kit and kit.summary) or "Universal kit"
end
function MW.registerGameKit(kit)
    return GameKits.register(kit)
end
local MW_T = (function()
    local mix = 1
    local function ixor(a, b)
        a = math.floor(tonumber(a) or 0) % 2147483647
        b = math.floor(tonumber(b) or 0) % 2147483647
        if bit32 and bit32.bxor then
            return bit32.bxor(a, b) % 2147483647
        end
        local r, bitv = 0, 1
        for _ = 1, 31 do
            if (a % 2) ~= (b % 2) then r = r + bitv end
            a = math.floor(a / 2)
            b = math.floor(b / 2)
            bitv = bitv * 2
        end
        return r
    end
    local function absorb(v)
        v = math.floor(tonumber(v) or 0)
        if v < 0 then v = -v end
        mix = ixor(mix, (v * 2654435761) % 2147483647) % 2147483647
        mix = (mix * 1664525 + 1013904223) % 2147483647
        if mix == 0 then mix = 1 end
    end
    pcall(function()
        absorb(tick() * 1e9)
        absorb(os.clock() * 1e8)
        absorb(os.time())
        absorb(game.PlaceId)
        absorb(game.GameId)
        absorb(game.CreatorId)
        local jid = tostring(game.JobId or "")
        absorb(#jid)
        for i = 1, #jid do
            absorb(string.byte(jid, i) * (i * 31 + 7))
        end
    end)
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        if lp then
            absorb(lp.UserId)
            absorb(#tostring(lp.Name or ""))
            absorb(#tostring(lp.DisplayName or ""))
        end
    end)
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then
            absorb(cam.ViewportSize.X)
            absorb(cam.ViewportSize.Y)
            absorb(cam.FieldOfView * 100)
        end
    end)
    pcall(function()
        local g = game:GetService("HttpService"):GenerateGUID(false):gsub("%-", "")
        for i = 1, #g do
            absorb(string.byte(g, i) * (i + 19))
        end
        absorb(#g * 9973)
    end)
    pcall(function()
        absorb(#game:GetService("Players"):GetPlayers())
        absorb(workspace:GetPhysicalFPS() or 0)
    end)
    for _ = 1, 12 do
        absorb(math.random(1, 2147483646))
    end
    local function nextUInt()
        mix = (mix * 1664525 + 1013904223) % 2147483647
        if mix == 0 then mix = 1 end
        return mix
    end
    local ALPHA = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local ALNUM = ALPHA .. "0123456789"
    local function pick(pool)
        local i = (nextUInt() % #pool) + 1
        return pool:sub(i, i)
    end
    local function token(minLen, maxLen)
        minLen = minLen or 10
        maxLen = maxLen or (minLen + 6)
        local len = minLen + (nextUInt() % math.max(1, maxLen - minLen + 1))
        local ok, guid = pcall(function()
            return game:GetService("HttpService"):GenerateGUID(false):gsub("%-", "")
        end)
        local pool = ALNUM
        if ok and type(guid) == "string" and #guid >= 8 then
            pool = guid .. ALNUM .. tostring(nextUInt())
        end
        local out = pick(ALPHA)
        while #out < len do
            out = out .. pick(pool)
        end
        return out:sub(1, len)
    end
    local keys = {
        "hub", "cleanup", "unloaded", "unloadBusy", "gui", "loader", "auth", "block",
        "esp", "box", "box3d", "box3dOutline", "boxGlow", "lock", "throw", "arc", "arcPt",
        "gunWire", "gunWireBox", "flyVel", "flyGyr", "spdVel", "bhopVel", "layer", "notif",
        "panel", "previewVp", "previewFloor", "previewEsp", "previewModel", "previewOutline",
        "previewAttr", "audio", "music", "menuBlur", "floatScale", "topNav", "mainBg",
        "mainFrame", "topBar", "search", "mainTabs", "subTabs", "content", "footer",
        "cardBody", "headerDiv", "col1", "col2", "changelog", "crosshair", "fpsHud",
        "velHud", "wmHud", "radar", "audioApi", "dockApi", "radarApi", "chatSpyApi",
        "session", "bootSalt", "acFlag",
    }
    for i = #keys, 2, -1 do
        local j = (nextUInt() % i) + 1
        keys[i], keys[j] = keys[j], keys[i]
    end
    local t = {}
    for _, k in ipairs(keys) do
        t[k] = token(11, 18)
    end
    t.bootSalt = token(16, 24)
    t.next = token
    t.owned = {
        [t.esp] = true, [t.box] = true, [t.box3d] = true, [t.box3dOutline] = true,
        [t.boxGlow] = true, [t.lock] = true, [t.throw] = true, [t.arc] = true,
        [t.arcPt] = true, [t.gunWire] = true, [t.gunWireBox] = true,
        [t.flyVel] = true, [t.flyGyr] = true, [t.spdVel] = true, [t.bhopVel] = true,
        [t.menuBlur] = true, [t.audio] = true, [t.music] = true,
    }
    t.force = function()
        for _ = 1, 16 do
            absorb(math.random(1, 2147483646))
            absorb(tick() * 1e6)
            absorb(os.clock() * 1e7)
        end
        pcall(function()
            local g = game:GetService("HttpService"):GenerateGUID(false)
            for i = 1, #g do absorb(string.byte(g, i) * i) end
        end)
        t.bootSalt = token(18, 28)
        t.session = token(12, 20)
        t.acFlag = token(12, 18)
        return t.bootSalt
    end
    return t
end)()
if _G[MW_T.cleanup] then
    pcall(_G[MW_T.cleanup])
end
_G[MW_T.unloaded] = false
local TraceHUD, TraceConfig, TraceInfo, TraceCombatEx, TraceExpand
local TracePack3, TraceAnim, TracePalettes, TraceDocs
local TraceLoaderRailSilhouette
local applyThemePreset, applyGunProfile, applyHudLayout, applyStickyProfile, applyMenuScalePreset
local listGunProfiles, listThemePresets
local captureGunSlotA, captureGunSlotB, captureGunSlotC, captureGunSlotD
local TraceV2BindMD
local THEME_PRESETS, GUN_PROFILES, TRACE_HUD_LAYOUTS, STICKY_PROFILES, MENU_SCALES
local Settings, SettingsDefaults
local ensureUISettings, hexToColor3, shiftColor, normalizeHex, color3ToHex
local function getExecutorName()
    local name = "Unknown"
    pcall(function()
        if identifyexecutor then name = identifyexecutor()
        elseif getexecutorname then name = getexecutorname() end
    end)
    return name
end
local SUPPORTED_EXECUTORS = {"wave", "xeno", "potassium", "volt", "seliware", "velocity", "real", "solara"}
local function isSupportedExecutor()
    local name = getExecutorName():lower()
    for _, token in ipairs(SUPPORTED_EXECUTORS) do
        if name:find(token, 1, true) then return true end
    end
    return false
end
local function getSupportedExecutorLabel()
    return "WAVE, Xeno, Potassium, Volt, Seliware, Velocity, Real, or Solara"
end
local function showUnsupportedExecutorMessage(execName)
    local msg = "Your executor is not supported yet."
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = MW.hub,
            Text = msg .. " (" .. execName .. ")",
            Duration = 12,
        })
    end)
    local sg = Instance.new("ScreenGui")
    sg.Name = MW_T.block
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = player:WaitForChild("PlayerGui")
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 36)
    title.Position = UDim2.new(0, 0, 0.5, -42)
    title.BackgroundTransparency = 1
    title.Text = MW.hub
    title.TextColor3 = Color3.fromRGB(232, 232, 240)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextStrokeTransparency = 0.35
    title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    title.Parent = sg
    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(0.85, 0, 0, 70)
    body.AnchorPoint = Vector2.new(0.5, 0.5)
    body.Position = UDim2.new(0.5, 0, 0.5, 12)
    body.BackgroundTransparency = 1
    body.Text = msg .. "\nDetected: " .. execName .. "\n" .. getSupportedExecutorLabel() .. " required."
    body.TextColor3 = Color3.fromRGB(108, 99, 255)
    body.TextSize = 14
    body.Font = Enum.Font.Gotham
    body.TextWrapped = true
    body.TextStrokeTransparency = 0.45
    body.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    body.Parent = sg
end
local function checkIntegrity()
    local ok = true
    pcall(function()
        if not getfenv or not syn then return end
        local env = getfenv(0)
        if env._INTEGRITY and env._INTEGRITY ~= MW.integrity then ok = false end
    end)
    return ok
end
local S = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    TeleportService = game:GetService("TeleportService"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    HttpService = game:GetService("HttpService"),
    SoundService = game:GetService("SoundService"),
}
local player = S.Players.LocalPlayer or S.Players:WaitForChild("LocalPlayer", 8)
local mouse1pressFn    = mouse1press or mouse1down
local mouse1releaseFn  = mouse1release or mouse1up
local mouse1clickFn    = mouse1click
local currentPlaceId   = game.PlaceId
local TraceLog = (function()
    local FEEDBACK_URL = "https://trace-host.vercel.app/api/feedback"
    local t0 = tick()
    local errors = {}
    local sent = false
    local logConn = nil
    local function httpRequest(opts)
        local req = (syn and syn.request)
            or (http and http.request)
            or http_request
            or request
            or (fluxus and fluxus.request)
        if type(req) ~= "function" then return nil, "no_request" end
        local ok, res = pcall(req, opts)
        if not ok then return nil, tostring(res) end
        return res
    end
    local function pushError(msg)
        if type(msg) ~= "string" then msg = tostring(msg) end
        msg = (msg or ""):gsub("%s+", " "):sub(1, 450)
        if msg == "" then return end
        for _, e in ipairs(errors) do
            if e == msg then return end
        end
        if #errors >= 10 then return end
        table.insert(errors, msg)
    end
    pcall(function()
        logConn = game:GetService("LogService").MessageOut:Connect(function(message, messageType)
            if messageType == Enum.MessageType.MessageError then
                pushError(message)
            end
        end)
    end)
    local function disconnectLog()
        if logConn then
            pcall(function() logConn:Disconnect() end)
            logConn = nil
        end
    end
    local function send(status)
        if sent then return end
        sent = true
        disconnectLog()
        local elapsed = math.max(0, tick() - t0)
        local errText = (#errors > 0) and table.concat(errors, "\n") or "none"
        if #errText > 900 then errText = errText:sub(1, 900) .. "…" end
        local color = (status == "ok") and 5439485 or 15158332
        local execName = tostring(getExecutorName()):sub(1, 80)
        local placeId = tostring(game.PlaceId)
        local mode = MW.isArsenal and "Arsenal" or "Universal"
        local ver = tostring(MW.display or MW.version)
        task.spawn(function()
            pcall(function()
                local placeName = "?"
                pcall(function()
                    placeName = tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "?")
                end)
                local payload = {
                    embeds = {{
                        title = "Melo 🍃 execute",
                        color = color,
                        fields = {
                            { name = "Executor", value = "```" .. execName .. "```", inline = true },
                            { name = "PlaceId", value = "`" .. placeId .. "`", inline = true },
                            { name = "Load time", value = string.format("%.2fs", elapsed), inline = true },
                            { name = "Status", value = tostring(status or "unknown"), inline = true },
                            { name = "Mode", value = mode, inline = true },
                            { name = "Place", value = tostring(placeName):sub(1, 80), inline = true },
                            { name = "Errors", value = "```\n" .. errText .. "\n```", inline = false },
                        },
                        footer = { text = "Melo 🍃 open feedback · v" .. ver },
                    }},
                }
                local body = S.HttpService:JSONEncode(payload)
                httpRequest({
                    Url = FEEDBACK_URL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = body,
                })
            end)
        end)
    end
    return {
        pushError = pushError,
        send = send,
        markStart = function() t0 = tick() end,
    }
end)()
TraceLog.markStart()
do

    if MW.isArsenal then
        warn("[" .. MW.hub .. "] Arsenal mode: full combat kit")
    elseif MW.isBrookhaven then
        warn("[" .. MW.hub .. "] Brookhaven mode: RP kit (gun mods locked)")
    elseif MW.isMM2 then
        warn("[" .. MW.hub .. "] MM2 mode: Rift kit")
    elseif MW.isPF then
        warn("[" .. MW.hub .. "] Phantom Forces mode: silent + camera aim + ESP kit")
    elseif MW.isMiscGunTest then
        warn("[" .. MW.hub .. "] MiscGunTest mode: ACS kit (gun mods in testing)")
    else
        warn("[" .. MW.hub .. "] Universal mode: PlaceId " .. tostring(currentPlaceId) .. " (gun mods locked)")
    end
end
do
    if not isSupportedExecutor() then
        local execName = getExecutorName()
        showUnsupportedExecutorMessage(execName)
        warn("[" .. MW.hub .. "] " .. getSupportedExecutorLabel() .. " only - detected: " .. execName)
        TraceLog.pushError("unsupported executor: " .. tostring(execName))
        TraceLog.send("blocked")
        _G[MW_T.unloaded] = true
        error("[" .. MW.hub .. "] " .. getSupportedExecutorLabel() .. " only")
    end
end
