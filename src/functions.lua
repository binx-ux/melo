;(function()
local DISCORD_INVITE = "https://discord.gg/zHGKqd92Pz"
local DISCORD_CODE = "zHGKqd92Pz"
local DISCORD_CODE_LABEL = "discord.gg/zHGKqd92Pz"
local DISCORD_APP = "discord://-/invite/" .. DISCORD_CODE
local FORCE_DISCORD_JOIN = false
local Auth = {
    Enabled = false,
    ScriptId = "arsenal",
    Url = "",
    AnonKey = "",
    SaveFile = "",
}
function Auth.copyText(text)
    local ok = false
    pcall(function()
        if setclipboard then setclipboard(text) ok = true end
    end)
    if not ok then
        pcall(function()
            if toclipboard then toclipboard(text) ok = true end
        end)
    end
    if not ok then
        pcall(function()
            local g = getgenv and getgenv()
            if g and g.setclipboard then g.setclipboard(text) ok = true end
        end)
    end
    return ok
end
function Auth.openDiscordRpc()
    local function rpc(cmd)
        local res = Auth.httpRequest({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com",
            },
            Body = S.HttpService:JSONEncode({
                cmd = cmd,
                nonce = S.HttpService:GenerateGUID(false),
                args = { code = DISCORD_CODE },
            }),
        })
        if not res then return false end
        local code = res.StatusCode or res.status_code
        return code == 200 or code == 204 or code == nil
    end
    if rpc("INVITE_BROWSER") then return true end
    if rpc("INVITE") then return true end
    return false
end
function Auth.tryOpenUrl(url)
    if not url or url == "" then return false end
    local opened = false
    pcall(function()
        if typeof(openurl) == "function" then openurl(url); opened = true
        elseif typeof(OpenURL) == "function" then OpenURL(url); opened = true
        elseif typeof(OpenUrl) == "function" then OpenUrl(url); opened = true
        end
    end)
    if not opened then
        pcall(function()
            if syn and typeof(syn.open_url) == "function" then syn.open_url(url); opened = true end
        end)
    end
    if not opened then
        pcall(function()
            local g = getgenv and getgenv()
            if g and typeof(g.openurl) == "function" then g.openurl(url); opened = true end
        end)
    end
    if not opened then
        pcall(function()
            game:GetService("GuiService"):OpenBrowserWindow(url)
            opened = true
        end)
    end
    return opened
end
local function openDiscordServer(opts)
    opts = opts or {}
    local quiet = opts.quiet == true
    local opened = Auth.openDiscordRpc()
    if not opened then
        opened = Auth.tryOpenUrl(DISCORD_APP)
            or Auth.tryOpenUrl("discord://discord.com/invite/" .. DISCORD_CODE)
            or Auth.tryOpenUrl("discord://invite/" .. DISCORD_CODE)
    end
    if not opened then
        opened = Auth.tryOpenUrl(DISCORD_INVITE)
    end
    local copied = Auth.copyText(DISCORD_INVITE)
    if not quiet then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = MW.hub,
                Text = opened and "Opening Discord: join the server" or (copied and "Discord invite copied: paste in browser" or DISCORD_CODE_LABEL),
                Duration = 8,
            })
        end)
    end
    return opened, copied
end
local function forceDiscordJoin()
    if not FORCE_DISCORD_JOIN then return end
    local skip = false
    pcall(function()
        local g = getgenv and getgenv()
        if g and g.KYN_FROM_HUB then skip = true end
    end)
    if skip then return end

    openDiscordServer({ quiet = false })
    task.delay(2.2, function()
        if _G[MW_T.unloaded] then return end

        pcall(function()
            Auth.openDiscordRpc()
            Auth.tryOpenUrl(DISCORD_APP)
            Auth.tryOpenUrl(DISCORD_INVITE)
        end)
    end)
end
local UILib = {
    TFast = 0.18,
    TMed = 0.28,
    TSlow = 0.4,
    TStyle = Enum.EasingStyle.Quint,
    TDir = Enum.EasingDirection.Out,
    ActiveThemeRoot = nil,
    Kit = nil,
    MD = nil,
    V2 = nil,
    TraceDraw = nil,
    showFullHub = nil,
    showDrawingMenu = nil,
    _hubWindowLayer = nil,
}
function UILib.newScreenGui(name, displayOrder)
    local sg = Instance.new("ScreenGui")
    sg.Name = name; sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    if displayOrder then sg.DisplayOrder = displayOrder end
    sg.Parent = player:WaitForChild("PlayerGui")
    return sg
end
function UILib.setZ(obj, z)
    if obj and z then obj.ZIndex = z end
    return obj
end
function UILib.layer(parent, zIndex)
    local f = UILib.newFrame(parent, {
        Name = MW_T.layer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = zIndex or 1,
    })
    return f
end
function UILib.newFrame(parent, props)
    local f = Instance.new("Frame")
    for k,v in pairs(props or {}) do f[k] = v end
    f.Parent = parent; return f
end
function UILib.newLabel(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    for k,v in pairs(props or {}) do l[k] = v end
    l.Parent = parent; return l
end
function UILib.newButton(parent, props, callback)
    local b = Instance.new("TextButton")
    for k, v in pairs(props or {}) do
        local okSet = true
        if k == "BackgroundColor3" or k == "TextColor3" or k == "BorderColor3" or k == "PlaceholderColor3" then
            if typeof(v) ~= "Color3" then okSet = false end
        end
        if okSet then
            local ok = pcall(function() b[k] = v end)
            if not ok and (k == "BackgroundColor3") then
                b.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
            end
        end
    end
    if typeof(b.BackgroundColor3) ~= "Color3" then
        b.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
    end
    b.Parent = parent
    if callback then b.MouseButton1Click:Connect(callback) end
    return b
end
function UILib.newBox(parent, props)
    local b = Instance.new("TextBox")
    for k,v in pairs(props or {}) do b[k] = v end
    b.Parent = parent; return b
end
function UILib.corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, tonumber(radius) or 0)
    c.Parent = parent
    return c
end
function UILib.circle(parent)
    local c = parent:FindFirstChildOfClass("UICorner")
    if not c then
        c = Instance.new("UICorner")
        c.Parent = parent
    end
    c.CornerRadius = UDim.new(1, 0)
    return c
end
function UILib.stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    if typeof(color) ~= "Color3" then color = Color3.fromRGB(36, 38, 46) end
    s.Color = color; s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent; return s
end
function UILib.gradient(parent, c1, c2, rotation)
    if typeof(c1) ~= "Color3" then c1 = Color3.fromRGB(16, 18, 26) end
    if typeof(c2) ~= "Color3" then c2 = c1 end
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rotation or 90
    g.Parent = parent; return g
end
function UILib.shadow(parent, size, transparency)

    return nil
end
function UILib.tween(obj, time, props, style, dir)
    return S.TweenService:Create(obj, TweenInfo.new(
        time or UILib.TMed,
        style or UILib.TStyle,
        dir or UILib.TDir
    ), props)
end
function UILib.glowStroke(parent, color, thickness, pulseMin, pulseMax)
    local s = UILib.stroke(parent, color, thickness or 1.5, pulseMin or 0.3)
    if pulseMin and pulseMax then
        task.spawn(function()
            while parent and parent.Parent do
                local t1 = UILib.tween(s, 1.8, {Transparency = pulseMax}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                t1:Play(); t1.Completed:Wait()
                if not parent or not parent.Parent then break end
                local t2 = UILib.tween(s, 1.8, {Transparency = pulseMin}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                t2:Play(); t2.Completed:Wait()
            end
        end)
    end
    return s
end
local Icons = {}
function Icons.mount(parent, name, opts)
    opts = opts or {}
    local size = opts.size or 18
    local color = opts.color or Color3.fromRGB(180, 184, 190)
    local z = opts.zIndex or 20
    name = string.lower(tostring(name or ""))
    local holder = Instance.new("Frame")
    holder.Name = MW_T.next(10)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Size = UDim2.fromOffset(size, size)
    holder.ZIndex = z
    holder.Parent = parent
    local function strokeFrame(props)
        local f = Instance.new("Frame")
        f.BackgroundTransparency = props.fill and 0 or 1
        if props.fill then f.BackgroundColor3 = color end
        f.BorderSizePixel = 0
        f.AnchorPoint = props.anchor or Vector2.new(0.5, 0.5)
        f.Position = props.pos or UDim2.fromScale(0.5, 0.5)
        f.Size = props.size or UDim2.fromScale(0.5, 0.5)
        f.Rotation = props.rot or 0
        f.ZIndex = z + 1
        f.Parent = holder
        if props.corner then
            local c = Instance.new("UICorner")
            c.CornerRadius = props.corner
            c.Parent = f
        end
        if not props.fill then
            local st = Instance.new("UIStroke")
            st.Color = color
            st.Thickness = props.thick or 1.5
            st.Parent = f
        end
        return f
    end
    if name == "home" then

        strokeFrame({ pos = UDim2.fromScale(0.5, 0.34), size = UDim2.fromScale(0.62, 0.1), rot = 40, thick = 1.6 })
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.34), size = UDim2.fromScale(0.62, 0.1), rot = -40, thick = 1.6 })
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.68), size = UDim2.fromScale(0.52, 0.42), corner = UDim.new(0, 2), thick = 1.6 })
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.78), size = UDim2.fromScale(0.16, 0.22), fill = true, corner = UDim.new(0, 1) })
    elseif name == "eye" or name == "visibility" then
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.5), size = UDim2.fromScale(0.86, 0.5), corner = UDim.new(1, 0), thick = 1.55 })
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.5), size = UDim2.fromScale(0.28, 0.28), fill = true, corner = UDim.new(1, 0) })
    elseif name == "crosshair" or name == "target" then
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.5), size = UDim2.fromScale(0.62, 0.62), corner = UDim.new(1, 0), thick = 1.5 })
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.18), size = UDim2.fromScale(0.08, 0.18), fill = true, corner = UDim.new(0, 1) })
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.82), size = UDim2.fromScale(0.08, 0.18), fill = true, corner = UDim.new(0, 1) })
        strokeFrame({ pos = UDim2.fromScale(0.18, 0.5), size = UDim2.fromScale(0.18, 0.08), fill = true, corner = UDim.new(0, 1) })
        strokeFrame({ pos = UDim2.fromScale(0.82, 0.5), size = UDim2.fromScale(0.18, 0.08), fill = true, corner = UDim.new(0, 1) })
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.5), size = UDim2.fromScale(0.12, 0.12), fill = true, corner = UDim.new(1, 0) })
    elseif name == "volume" or name == "audio" then
        strokeFrame({ pos = UDim2.fromScale(0.32, 0.5), size = UDim2.fromScale(0.2, 0.28), fill = true, corner = UDim.new(0, 2) })
        strokeFrame({ pos = UDim2.fromScale(0.42, 0.5), size = UDim2.fromScale(0.14, 0.48), fill = true, corner = UDim.new(0, 2) })
        strokeFrame({ pos = UDim2.fromScale(0.68, 0.5), size = UDim2.fromScale(0.34, 0.34), corner = UDim.new(1, 0), thick = 1.45 })
        strokeFrame({ pos = UDim2.fromScale(0.78, 0.5), size = UDim2.fromScale(0.48, 0.48), corner = UDim.new(1, 0), thick = 1.35 })
    elseif name == "settings" or name == "cog" then
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.5), size = UDim2.fromScale(0.4, 0.4), corner = UDim.new(1, 0), thick = 1.55 })
        for i = 0, 5 do
            strokeFrame({ pos = UDim2.fromScale(0.5, 0.5), size = UDim2.fromScale(0.12, 0.78), rot = i * 60, fill = true, corner = UDim.new(0, 1) })
        end
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.5), size = UDim2.fromScale(0.18, 0.18), fill = true, corner = UDim.new(1, 0) })
    elseif name == "menu" or name == "general" then
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.28), size = UDim2.fromScale(0.68, 0.1), fill = true, corner = UDim.new(1, 0) })
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.5), size = UDim2.fromScale(0.68, 0.1), fill = true, corner = UDim.new(1, 0) })
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.72), size = UDim2.fromScale(0.68, 0.1), fill = true, corner = UDim.new(1, 0) })
    elseif name == "flag" or name == "report" then
        strokeFrame({ pos = UDim2.fromScale(0.3, 0.55), size = UDim2.fromScale(0.08, 0.7), fill = true, corner = UDim.new(0, 1) })
        strokeFrame({ pos = UDim2.fromScale(0.55, 0.36), size = UDim2.fromScale(0.42, 0.32), fill = true, corner = UDim.new(0, 2) })
    else
        strokeFrame({ pos = UDim2.fromScale(0.5, 0.5), size = UDim2.fromScale(0.55, 0.55), corner = UDim.new(1, 0), thick = 1.5 })
    end
    local api = {}
    function api:SetColor(c)
        color = c
        for _, d in ipairs(holder:GetDescendants()) do
            if d:IsA("UIStroke") then d.Color = c end
            if d:IsA("Frame") and d.BackgroundTransparency < 1 then d.BackgroundColor3 = c end
        end
    end
    setmetatable(api, {
        __index = function(_, k)
            local v = holder[k]
            if type(v) == "function" then
                return function(_, ...) return v(holder, ...) end
            end
            return v
        end,
        __newindex = function(_, k, v) holder[k] = v end,
    })
    return api
end
local Theme = {

        WindowBg=Color3.fromRGB(7,8,11),WindowBorder=Color3.fromRGB(36,38,46),
        SidebarBg=Color3.fromRGB(7,8,11),SidebarBorder=Color3.fromRGB(36,38,46),
        LogoText=Color3.fromRGB(125,211,252),LogoGlow=Color3.fromRGB(125,211,252),
        TabBg=Color3.fromRGB(12,13,18),TabBgHover=Color3.fromRGB(18,20,28),TabBgActive=Color3.fromRGB(16,18,26),
        TabText=Color3.fromRGB(125,128,134),TabTextActive=Color3.fromRGB(233,235,239),
        TabIcon=Color3.fromRGB(125,128,134),TabIconActive=Color3.fromRGB(125,211,252),
        TabIndicator=Color3.fromRGB(125,211,252),
        ContentBg=Color3.fromRGB(7,8,11),
        CardBg=Color3.fromRGB(12,13,18),CardBgHover=Color3.fromRGB(16,18,26),CardBorder=Color3.fromRGB(36,38,46),
        CardHeaderBg=Color3.fromRGB(12,13,18),CardHeaderBgEnd=Color3.fromRGB(12,13,18),CardHeaderText=Color3.fromRGB(125,211,252),
        ToggleOn=Color3.fromRGB(125,211,252),ToggleOnGlow=Color3.fromRGB(125,211,252),ToggleOff=Color3.fromRGB(12,13,18),ToggleKnob=Color3.fromRGB(7,8,11),
        SliderTrack=Color3.fromRGB(28,30,38),SliderFill=Color3.fromRGB(125,211,252),SliderFillEnd=Color3.fromRGB(94,234,212),SliderKnob=Color3.fromRGB(125,211,252),
        TextPrimary=Color3.fromRGB(233,235,239),TextSecondary=Color3.fromRGB(162,165,170),TextDim=Color3.fromRGB(125,128,134),TextAccent=Color3.fromRGB(125,211,252),
        EnumBg=Color3.fromRGB(16,18,26),EnumBgActive=Color3.fromRGB(24,28,38),EnumText=Color3.fromRGB(162,165,170),EnumTextActive=Color3.fromRGB(233,235,239),
        KeybindBg=Color3.fromRGB(16,18,26),KeybindText=Color3.fromRGB(125,211,252),KeybindBorder=Color3.fromRGB(36,38,46),
        InputBg=Color3.fromRGB(16,18,26),InputBorder=Color3.fromRGB(36,38,46),InputFocus=Color3.fromRGB(125,211,252),
        ButtonBg=Color3.fromRGB(16,18,26),ButtonBgHover=Color3.fromRGB(24,28,38),ButtonText=Color3.fromRGB(233,235,239),
        NotifBg=Color3.fromRGB(12,13,18),NotifBorder=Color3.fromRGB(36,38,46),NotifAccent=Color3.fromRGB(125,211,252),
        WarnColor=Color3.fromRGB(228,183,80),SuccessColor=Color3.fromRGB(35,208,145),ErrorColor=Color3.fromRGB(233,80,77),
        ESP_Close=Color3.fromRGB(255,255,255),ESP_Medium=Color3.fromRGB(233,235,239),ESP_Far=Color3.fromRGB(162,165,170),ESP_VeryFar=Color3.fromRGB(125,128,134),
        RadarBg=Color3.fromRGB(7,8,11),RadarBorder=Color3.fromRGB(125,211,252),
        DividerColor=Color3.fromRGB(36,38,46),
        ShadowColor=Color3.fromRGB(0,0,0),
        SubTabBg=Color3.fromRGB(7,8,11),SubTabActive=Color3.fromRGB(16,18,26),
}
local ThemeDefaults = {}
for k, v in pairs(Theme) do ThemeDefaults[k] = v end
function UILib.colorNear(a, b, tol)
    if typeof(a) ~= "Color3" or typeof(b) ~= "Color3" then return false end
    tol = tol or 0.04
    local dr, dg, db = a.R - b.R, a.G - b.G, a.B - b.B
    return (dr * dr + dg * dg + db * db) <= (tol * tol)
end
function UILib.rethemeTree(root, previousTheme)
    if not root or not root.Parent or type(previousTheme) ~= "table" then return end
    local orderedKeys = {
        "TextAccent", "ToggleOn", "ToggleOnGlow", "SliderFill", "SliderKnob", "TabIndicator", "TabIconActive",
        "LogoText", "LogoGlow", "NotifAccent", "RadarBorder", "InputFocus", "KeybindText", "EnumTextActive",
        "WindowBg", "ContentBg", "CardBg", "CardHeaderBg", "SidebarBg",
        "TabBg", "SubTabBg", "ToggleOff", "InputBg", "EnumBg", "KeybindBg", "ButtonBg",
        "TabBgActive", "SubTabActive", "EnumBgActive", "ButtonBgHover", "CardBgHover",
        "WindowBorder", "CardBorder", "SidebarBorder", "InputBorder", "KeybindBorder", "DividerColor",
        "TextPrimary", "TextSecondary", "TextDim", "TabText", "TabTextActive",
        "EnumText", "ButtonText", "WarnColor", "SuccessColor", "ErrorColor",
        "ESP_Close", "ESP_Medium", "ESP_Far", "ESP_VeryFar",
    }
    local oldAccent = previousTheme.TextAccent or previousTheme.ToggleOn
    local newAccent = Theme.TextAccent or Theme.ToggleOn
    local function replacement(color)
        if typeof(color) ~= "Color3" then return nil end
        if oldAccent and newAccent and UILib.colorNear(color, oldAccent, 0.06) then
            return newAccent
        end
        local bestKey, bestDist = nil, 0.045
        for _, key in ipairs(orderedKeys) do
            local old = previousTheme[key]
            local nextColor = Theme[key]
            if typeof(old) == "Color3" and typeof(nextColor) == "Color3" then
                local dr, dg, db = color.R - old.R, color.G - old.G, color.B - old.B
                local dist = dr * dr + dg * dg + db * db
                if dist <= bestDist then
                    bestDist = dist
                    bestKey = key
                end
            end
        end
        return bestKey and Theme[bestKey] or nil
    end
    local objects = root:GetDescendants()
    table.insert(objects, root)
    for _, object in ipairs(objects) do
        pcall(function()
            if object:IsA("GuiObject") then
                local bg = replacement(object.BackgroundColor3)
                if bg then object.BackgroundColor3 = bg end
            end
            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                local text = replacement(object.TextColor3)
                if text then object.TextColor3 = text end
                if object:IsA("TextBox") then
                    local placeholder = replacement(object.PlaceholderColor3)
                    if placeholder then object.PlaceholderColor3 = placeholder end
                end
            elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
                local image = replacement(object.ImageColor3)
                if image then object.ImageColor3 = image end
            elseif object:IsA("UIStroke") then
                local stroke = replacement(object.Color)
                if stroke then object.Color = stroke end
            elseif object:IsA("UIGradient") then
                local keypoints = object.Color.Keypoints
                local changed = false
                local nextPoints = table.create(#keypoints)
                for i, point in ipairs(keypoints) do
                    local color = replacement(point.Value)
                    nextPoints[i] = ColorSequenceKeypoint.new(point.Time, color or point.Value)
                    if color then changed = true end
                end
                if changed then object.Color = ColorSequence.new(nextPoints) end
            end
        end)
    end
end
function Auth.httpRequest(opts)
    local req = (syn and syn.request)
        or (http and http.request)
        or http_request
        or request
        or (fluxus and fluxus.request)
    if type(req) ~= "function" then
        return nil, "no_request"
    end
    local ok, res = pcall(req, opts)
    if not ok then return nil, tostring(res) end
    return res
end
function Auth.saveKey(_key)

end
function Auth.loadKey()
    return nil
end
local Cap = (function()
local Cap = {
    ready = false,
    fetching = false,
    fetchDone = false,
    matched = nil,
    title = nil,
    updateStatus = nil,
    detected = nil,
    uncPct = nil,
    suncPct = nil,
    failed = {},
    localOk = {},
    features = {
        http = true,
        filesystem = true,
        clipboard = true,
        drawing = true,
        hooks = true,
        getgc = true,
        gunmods = true,
    },
    reasons = {},
}
local CapFeatureNeeds = {
    http = { any = { "request", "http_request", "http.request", "syn.request" } },
    filesystem = { all = { "writefile", "readfile", "makefolder" } },
    clipboard = { any = { "setclipboard", "toclipboard" } },
    drawing = { any = { "Drawing.new" } },
    hooks = { any = { "hookmetamethod", "hookfunction" } },
    getgc = { any = { "getgc" } },
    gunmods = { any = { "writefile" } },
}
local CapFeatureLabels = {
    http = "Webhooks, server hop, remote scripts",
    filesystem = "Config save / load",
    clipboard = "Clipboard / Discord copy",
    drawing = "Drawing FOV circle",
    hooks = "Hook APIs (metamethod / hookfunction)",
    getgc = "GC scan APIs",
    gunmods = "Gun Mods (auto, recoil, spread, ammo, firerate)",
}
local function CapIsXenoOrSolara()
    local name = getExecutorName():lower()
    local title = tostring(Cap.title or ""):lower()
    local blob = name .. " " .. title
    return blob:find("xeno", 1, true) ~= nil or blob:find("solara", 1, true) ~= nil
end
local function CapResolve(name)
    if Cap.localOk[name] ~= nil then return Cap.localOk[name] end
    local cur = _G
    for part in string.gmatch(name, "[^%.]+") do
        if type(cur) ~= "table" and type(cur) ~= "userdata" then
            Cap.localOk[name] = false
            return false
        end
        local ok, nxt = pcall(function() return cur[part] end)
        if not ok or nxt == nil then

            if cur == _G then
                local ok2, g = pcall(function() return getfenv and getfenv(0)[part] or nil end)
                if ok2 and g ~= nil then nxt = g else Cap.localOk[name] = false; return false end
            else
                Cap.localOk[name] = false
                return false
            end
        end
        cur = nxt
    end
    local ok = type(cur) == "function" or (name == "Drawing.new" and type(Drawing) == "table")
    if name == "Drawing.new" then
        ok = type(Drawing) == "table" and type(Drawing.new) == "function"
    end
    Cap.localOk[name] = ok and true or false
    return Cap.localOk[name]
end
local function CapHasFailed(name)
    local n = tostring(name or ""):lower()
    if Cap.failed[n] then return true end

    local bare = n:match("([^%.]+)$")
    if bare and Cap.failed[bare] then return true end
    return false
end
local function CapFnOk(name)
    if Cap.localOk[name] == true then return true end
    if CapHasFailed(name) then return false end

    if Cap.fetchDone and Cap.matched then return true end
    if Cap.localOk[name] == nil then CapResolve(name) end
    return Cap.localOk[name] == true
end
function Cap.ok(feature)
    return Cap.features[feature] ~= false
end
function Cap.badge(feature)
    if Cap.ok(feature) then return nil end
    return Cap.reasons[feature] or "UNC"
end
function Cap.why(feature)
    return Cap.reasons[feature]
end
function Cap.recompute()
    for feature, spec in pairs(CapFeatureNeeds) do
        local ok = true
        local why = nil
        if feature == "gunmods" then
            ok = true
            why = nil
        elseif spec.any then
            ok = false
            for _, name in ipairs(spec.any) do
                if CapFnOk(name) then ok = true; break end
            end
            if not ok then why = "NO " .. string.upper(feature) end
        elseif spec.all then
            for _, name in ipairs(spec.all) do
                if not CapFnOk(name) then
                    ok = false
                    why = "NO " .. string.upper((name:match("([^%.]+)$") or name))
                    break
                end
            end
        end

        if feature == "drawing" and not ok then
            ok = true
            why = nil
        end
        Cap.features[feature] = ok
        Cap.reasons[feature] = why
    end

    if CapIsXenoOrSolara() then
        Cap.features.gunmods = false
        Cap.reasons.gunmods = "XENO/SOLARA"
    elseif not MW.isArsenal and not MW.isMiscGunTest then
        Cap.features.gunmods = false
        Cap.reasons.gunmods = "NON-ARSENAL"
    end
    Cap.ready = true
end
function Cap.lockedList()
    Cap.recompute()
    local order = { "gunmods", "http", "filesystem", "clipboard", "hooks", "getgc", "drawing" }
    local out = {}
    for _, id in ipairs(order) do
        if Cap.features[id] == false then
            table.insert(out, {
                id = id,
                label = CapFeatureLabels[id] or id,
                reason = Cap.reasons[id] or "UNC",
            })
        end
    end
    return out
end
function Cap.probeLocal()
    local function mark(name, fn)
        local ok, val = pcall(fn)
        Cap.localOk[name] = ok and val ~= nil and (type(val) == "function" or type(val) == "table")
    end
    mark("writefile", function() return writefile end)
    mark("readfile", function() return readfile end)
    mark("makefolder", function() return makefolder end)
    mark("isfile", function() return isfile end)
    mark("setclipboard", function() return setclipboard end)
    mark("toclipboard", function() return toclipboard end)
    mark("hookmetamethod", function() return hookmetamethod end)
    mark("hookfunction", function() return hookfunction end)
    mark("getgc", function() return getgc end)
    mark("request", function() return request end)
    mark("http_request", function() return http_request end)
    pcall(function()
        if Drawing and type(Drawing.new) == "function" then Cap.localOk["Drawing.new"] = true end
    end)
    pcall(function()
        if syn and type(syn.request) == "function" then Cap.localOk["syn.request"] = true end
    end)
    pcall(function()
        if http and type(http.request) == "function" then Cap.localOk["http.request"] = true end
    end)
    pcall(function()
        local req = (syn and syn.request) or (http and http.request) or http_request or request
        if type(req) == "function" then Cap.localOk["request"] = true end
    end)
    Cap.recompute()
end
function Cap.httpGet(url)
    local res = Auth.httpRequest({
        Url = url,
        Method = "GET",
        Headers = { ["User-Agent"] = "WEAO-3PService" },
    })
    if res then
        local body = res.Body or res.body
        if type(body) == "string" and body ~= "" then return body end
    end
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(body) == "string" and body ~= "" then return body end
    return nil
end
local function CapMatchExecutor(list)
    local exec = getExecutorName():lower()
    local best, bestScore = nil, 0
    for _, entry in ipairs(list) do
        local title = tostring(entry.title or "")
        local tl = title:lower()
        if tl ~= "" then
        local score = 0
        if exec:find(tl, 1, true) or tl:find(exec, 1, true) then
            score = #tl + 50
        else
            for token in string.gmatch(tl, "%w+") do
                if #token >= 3 and exec:find(token, 1, true) then
                    score = math.max(score, #token)
                end
            end
            for _, known in ipairs(SUPPORTED_EXECUTORS) do
                if exec:find(known, 1, true) and tl:find(known, 1, true) then
                    score = math.max(score, #known + 20)
                end
            end
        end
        if score > bestScore then
            bestScore = score
            best = entry
        end
        end
    end
    if bestScore < 3 then return nil end
    return best
end
function Cap.fetchWeao()
    if Cap.fetching or Cap.fetchDone then return end
    Cap.fetching = true
    local ok, err = pcall(function()

        local raw = Cap.httpGet("https://trace-host.vercel.app/api/weao/exploits")
        if not raw or raw == "" then error("weao proxy unreachable") end
        raw = tostring(raw):gsub("^%s+", ""):gsub("%s+$", "")
        if raw:sub(1, 1) ~= "{" and raw:sub(1, 1) ~= "[" then
            error("weao proxy non-json")
        end
        local decodeOk, wrapped = pcall(function()
            return S.HttpService:JSONDecode(raw)
        end)
        if not decodeOk then error("weao json decode failed") end
        local list = wrapped
        if type(wrapped) == "table" and wrapped.data ~= nil then
            list = wrapped.data
        end
        if type(list) ~= "table" then error("bad exploits payload") end
        local match = CapMatchExecutor(list)
        Cap.matched = match
        if match then
            Cap.title = match.title
            Cap.updateStatus = match.updateStatus
            Cap.detected = match.detected
            Cap.uncPct = match.uncPercentage
            Cap.suncPct = match.suncPercentage
        end
    end)
    if not ok then

        Cap.weaoError = tostring(err)
    end
    Cap.fetching = false
    Cap.fetchDone = true
    Cap.recompute()
end
function Cap.awaitWeao(timeout)
    Cap.probeLocal()
    if not Cap.fetching and not Cap.fetchDone then
        task.spawn(Cap.fetchWeao)
    end
    local t0 = tick()
    timeout = math.min(timeout or 0.4, 0.6)
    while not Cap.fetchDone and (tick() - t0) < timeout do
        task.wait(0.05)
    end
    Cap.recompute()
end
task.spawn(function()
    Cap.probeLocal()
    Cap.fetchWeao()
end)
function Cap.apply()
    Cap.recompute()
end
function Cap.disableUnsupportedSettings(cfg)
    Cap.recompute()
    if type(cfg) ~= "table" then return end
    if not Cap.ok("http") then
        if type(cfg.Webhook) == "table" then cfg.Webhook.Enabled = false end
        if type(cfg.Misc) == "table" then cfg.Misc.AutoHopUntilMatch = false end
    end
    if not Cap.ok("gunmods") and type(cfg.Combat) == "table" then
        cfg.Combat.FastReload = false
        cfg.Combat.FastFireRate = false
        cfg.Combat.AlwaysAuto = false
        cfg.Combat.NoSpread = false
        cfg.Combat.NoRecoil = false
        cfg.Combat.InfiniteAmmo = false
        cfg.Combat.WallBang = false
    end

    if not MW.allows("aim") then
        if type(cfg.Aimbot) == "table" then cfg.Aimbot.Enabled = false end
    end
    if not MW.allows("combat") then
        if type(cfg.Combat) == "table" then
            cfg.Combat.TriggerBot = false
            cfg.Combat.RageBot = false
            cfg.Combat.WallBang = false
        end
        if type(cfg.Misc) == "table" then cfg.Misc.AutoTPLoop = false end
        if type(cfg.Audio) == "table" then
            cfg.Audio.HitSoundsEnabled = false
            cfg.Audio.KillSoundsEnabled = false
        end
        if type(cfg.Visuals) == "table" then
            cfg.Visuals.GunWireframeEnabled = false
            cfg.Visuals.ViewmodelFOVEnabled = false
        end
    end
    if not MW.allows("trigger") and type(cfg.Combat) == "table" then
        cfg.Combat.TriggerBot = false
    end
    if not MW.allows("obby") and type(cfg.Misc) == "table" then
        cfg.Misc.AutoObby = false
    end
    if not MW.allows("brookhaven") and type(cfg.Movement) == "table" then
        cfg.Movement.VehicleSpeed = false
        cfg.Movement.LocalInvis = false
    end
    if not MW.allows("rage") and type(cfg.Combat) == "table" then
        cfg.Combat.RageBot = false
    end
    if not MW.allows("autoTp") and type(cfg.Misc) == "table" then
        cfg.Misc.AutoTPLoop = false
    end
    if not MW.allows("gunmods") and type(cfg.Combat) == "table" then
        cfg.Combat.FastReload = false
        cfg.Combat.FastFireRate = false
        cfg.Combat.AlwaysAuto = false
        cfg.Combat.NoSpread = false
        cfg.Combat.NoRecoil = false
        cfg.Combat.InfiniteAmmo = false
        cfg.Combat.WallBang = false
    end
    if MW.guard("hitbox") and type(cfg.Aimbot) == "table" then
        cfg.Aimbot.SilentHitbox = false
        cfg.Aimbot.AimMode = "Camera"
    end
    if MW.guard("pos") then
        if type(cfg.Movement) == "table" then
            if MW.allows("fly") == false then cfg.Movement.Fly = false end
            if MW.allows("speedHack") == false then cfg.Movement.SpeedEnabled = false end
            if MW.allows("clickTp") == false then cfg.Movement.ClickTP = false end
            cfg.Movement.InfiniteJump = false
            if MW.allows("speedHack") == false then cfg.Movement.BunnyHop = false end
        end
        if type(cfg.Misc) == "table" then
            cfg.Misc.AutoTPLoop = false
        end
        if type(cfg.Combat) == "table" then
            cfg.Combat.RageBot = false
        end
    end
end
function Cap.summaryLine()
    local bits = {}
    if Cap.title then
        table.insert(bits, Cap.title)
        if Cap.suncPct ~= nil then table.insert(bits, "sUNC " .. tostring(Cap.suncPct) .. "%") end
        if Cap.updateStatus == false then table.insert(bits, "outdated") end
        if Cap.detected == true then table.insert(bits, "detected") end
    else
        table.insert(bits, "WEAO unmatched")
    end
    if MW.mode and MW.mode ~= "Arsenal" then
        table.insert(bits, MW.mode .. " kit")
    end
    local locked = Cap.lockedList()
    if #locked > 0 then
        local ids = {}
        for _, row in ipairs(locked) do
            if not (row.id == "gunmods" and row.reason == "NON-ARSENAL") then
                table.insert(ids, row.id)
            end
        end
        if #ids > 0 then
            table.insert(bits, "locked: " .. table.concat(ids, ","))
        elseif MW.mode ~= "Arsenal" then
            table.insert(bits, "gunmods Arsenal-only")
        end
    end
    return table.concat(bits, " | ")
end
function Cap.weakReasons()
    Cap.recompute()
    local reasons = {}
    local sunc = tonumber(Cap.suncPct)
    if sunc ~= nil and sunc < 70 then
        table.insert(reasons, "sUNC score " .. tostring(sunc) .. "%: Melo 🍃 wants 70%+")
    end
    if Cap.updateStatus == false then
        table.insert(reasons, "WEAO marks this build outdated")
    end
    if CapIsXenoOrSolara() then
        table.insert(reasons, "Xeno / Solara: gun mods force-locked")
    end
    if not Cap.ok("hooks") and not Cap.ok("getgc") then
        table.insert(reasons, "Missing core UNC (hooks / getgc)")
    end
    if not Cap.matched then
        local missing = 0
        for _, name in ipairs({ "hookmetamethod", "getgc", "request", "writefile" }) do
            if Cap.localOk[name] == false then missing = missing + 1 end
        end
        if missing >= 2 then
            table.insert(reasons, "Local probe failed " .. tostring(missing) .. " core APIs")
        end
    end
    local locked = Cap.lockedList()
    local execLocked = 0
    for _, row in ipairs(locked) do
        if row.reason ~= "NON-ARSENAL" then execLocked = execLocked + 1 end
    end
    if execLocked > 0 and #reasons == 0 then
        table.insert(reasons, tostring(execLocked) .. " feature pack(s) locked")
    end
    return reasons
end
function Cap.isWeak()
    return #Cap.weakReasons() > 0
end
return Cap
end)()
function Auth.validate(_key)

    return true, nil
end
function Auth.errorText(code)
    local map = {
        empty_key = "Enter a key",
        invalid_key = "Invalid key",
        disabled = "Key disabled",
        expired = "Key expired",
        bound_other_user = "Key bound to another user",
        max_uses = "Key out of uses",
        request_failed = "Request failed (executor HTTP?)",
        no_request = "Executor has no HTTP request",
        bad_response = "Bad server response",
    }
    return map[code] or ("Failed: " .. tostring(code))
end
function Auth.showGate(onDone)
    if onDone then onDone() end
end
hexToColor3 = function(hex)
    hex = tostring(hex or ""):gsub("#", ""):gsub("%s+", "")
    if #hex ~= 6 then
        return Color3.fromRGB(125, 211, 252)
    end
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    if not r or not g or not b then
        return Color3.fromRGB(125, 211, 252)
    end
    return Color3.fromRGB(r, g, b)
end
normalizeHex = function(hex)
    local h = tostring(hex or ""):gsub("#", ""):gsub("%s+", ""):upper()
    if #h ~= 6 then return nil end
    if not tonumber(h, 16) then return nil end
    return h
end
color3ToHex = function(c)
    if typeof(c) ~= "Color3" then return "FFFFFF" end
    return string.format("%02X%02X%02X",
        math.floor(c.R * 255 + 0.5),
        math.floor(c.G * 255 + 0.5),
        math.floor(c.B * 255 + 0.5))
end
shiftColor = function(c, dr, dg, db)
    if typeof(c) ~= "Color3" then
        return Color3.fromRGB(125, 211, 252)
    end
    local function clamp01(n)
        if n < 0 then return 0 end
        if n > 1 then return 1 end
        return n
    end
    return Color3.new(
        clamp01(c.R + (dr or 0)),
        clamp01(c.G + (dg or 0)),
        clamp01(c.B + (db or 0))
    )
end
local function applyEspPalette()
    if not Settings or type(Settings.ESP) ~= "table" then return end
    local esp = Settings.ESP
    local link = esp.LinkToAccent ~= false
    local accent = hexToColor3(Settings.UI and Settings.UI.AccentHex or "6759B3")
    local function pick(key, fallbackCol)
        local h = normalizeHex(esp[key])
        if h then return hexToColor3(h) end
        return fallbackCol
    end
    if link then
        Theme.ESP_Close = accent
        Theme.ESP_Medium = shiftColor(accent, 0.08, 0.08, 0.1)
        Theme.ESP_Far = Color3.fromRGB(220, 222, 230)
        Theme.ESP_VeryFar = Color3.fromRGB(175, 178, 190)
    else
        Theme.ESP_Close = pick("CloseHex", accent)
        Theme.ESP_Medium = pick("MediumHex", shiftColor(accent, 0.08, 0.08, 0.1))
        Theme.ESP_Far = pick("FarHex", Color3.fromRGB(220, 222, 230))
        Theme.ESP_VeryFar = pick("VeryFarHex", Color3.fromRGB(175, 178, 190))
    end
    Theme.ESP_Box = pick("BoxHex", Theme.ESP_Close)
    Theme.ESP_Tracer = pick("TracerHex", Theme.ESP_Close)
    Theme.ESP_Skeleton = pick("SkeletonHex", Theme.ESP_Close)
    Theme.ESP_Chams = pick("ChamsHex", Theme.ESP_Close)
    Theme.ESP_Name = pick("NameHex", Theme.ESP_Close)
    local oh = normalizeHex(esp.OutlineHex)
    if oh then
        Theme.ESP_Outline = hexToColor3(oh)
        esp.OutlineColor = Theme.ESP_Outline
    else
        Theme.ESP_Outline = esp.OutlineColor or Color3.fromRGB(210, 210, 220)
    end
end
ensureUISettings = function()
    if not Settings then return end
    if type(Settings.UI) ~= "table" then
        Settings.UI = {
            AccentHex = "7DD3FC",
            BackgroundHex = "07080B",
            SurfaceHex = "0C0D12",
            ToggleHex = "7DD3FC",
            MenuScale = 1,
            ThemePreset = "Purple",
            Autosave = false,
            BlurMenu = true,
        }
    end

    do
        local ui = Settings.UI
        local acc = tostring(ui.AccentHex or ""):upper()
        local bg = tostring(ui.BackgroundHex or ""):upper()
        if (acc == "5AA0FF" or acc == "") and (bg == "0C0C0E" or bg == "") then
            ui.AccentHex = "7DD3FC"
            ui.BackgroundHex = "07080B"
            ui.SurfaceHex = "0C0D12"
            ui.ToggleHex = "7DD3FC"
        end
        if not ui.AccentHex or ui.AccentHex == "" then ui.AccentHex = "7DD3FC" end
        if not ui.BackgroundHex or ui.BackgroundHex == "" then ui.BackgroundHex = "07080B" end
        if not ui.SurfaceHex or ui.SurfaceHex == "" then ui.SurfaceHex = "0C0D12" end
        if not ui.ToggleHex or ui.ToggleHex == "" then ui.ToggleHex = "7DD3FC" end
        if ui.MenuScale == nil then ui.MenuScale = 1 end
        if ui.ThemePreset == nil or ui.ThemePreset == "" then ui.ThemePreset = "Purple" end
        if ui.Autosave == nil then ui.Autosave = false end
        if ui.BlurMenu == nil then ui.BlurMenu = true end
    end

    if SettingsDefaults then
        for cat, vals in pairs(SettingsDefaults) do
            if type(vals) == "table" then
                if type(Settings[cat]) ~= "table" then
                    Settings[cat] = {}
                end
                for k, def in pairs(vals) do
                    if Settings[cat][k] == nil then
                        Settings[cat][k] = def
                    end
                end
            end
        end
    end
    if type(Settings.Webhook) == "table" and type(Settings.Webhook.Hooks) ~= "table" then
        Settings.Webhook.Hooks = {}
    end
end
function UILib.clampRadarPoint(nx, ny, maxR)
    local dist = math.sqrt(nx * nx + ny * ny)
    if dist > maxR and dist > 0.001 then
        nx = nx / dist * maxR
        ny = ny / dist * maxR
    end
    return nx, ny
end
local themeCallbacks = {}
local themeHexFields = {}
local uiParticleSystems = {}
local function syncLegacyKeys()
    Theme.Background=Theme.ContentBg; Theme.BackgroundDark=Theme.SidebarBg; Theme.BackgroundLight=Theme.CardBg
    Theme.AccentPink=Theme.CardHeaderBg; Theme.AccentBright=Theme.TextAccent; Theme.AccentDark=Theme.TabBgActive
    Theme.Accent=Theme.TextAccent; Theme.Border=Theme.CardBorder; Theme.BorderLight=Theme.EnumBg
    Theme.TabActive=Theme.TabTextActive; Theme.TabInactive=Theme.TabText; Theme.TitleBar=Theme.SidebarBg
    Theme.CheckboxEnabled=Theme.ToggleOn; Theme.CheckboxDisabled=Theme.ToggleOff
    Theme.SliderBackground=Theme.SliderTrack
end
local function applyCustomTheme()
    if not Settings then return end
    ensureUISettings()
    local previousTheme = {}
    for key, value in pairs(Theme) do
        if typeof(value) == "Color3" then previousTheme[key] = value end
    end
    local accent = hexToColor3(Settings.UI.AccentHex)
    local bg = hexToColor3(Settings.UI.BackgroundHex)
    local surface = hexToColor3(Settings.UI.SurfaceHex)
    local toggle = hexToColor3(Settings.UI.ToggleHex)
    Theme.WindowBg = bg
    Theme.WindowBorder = shiftColor(bg, 0.12, 0.12, 0.14)
    Theme.SidebarBg = bg
    Theme.SidebarBorder = shiftColor(surface, 0.06, 0.06, 0.07)
    Theme.ContentBg = shiftColor(bg, -0.02, -0.02, -0.02)
    Theme.CardBg = surface
    Theme.CardBgHover = shiftColor(surface, 0.04, 0.04, 0.05)
    Theme.CardBorder = shiftColor(surface, 0.08, 0.08, 0.09)
    Theme.CardHeaderBg = surface
    Theme.CardHeaderBgEnd = surface
    Theme.TabBg = shiftColor(bg, 0.05, 0.05, 0.06)
    Theme.TabBgHover = shiftColor(surface, 0.06, 0.06, 0.07)
    Theme.TabBgActive = shiftColor(surface, 0.12, 0.12, 0.14)
    Theme.TabIndicator = accent
    Theme.TabIconActive = accent
    Theme.TabTextActive = Color3.fromRGB(240, 240, 245)
    Theme.LogoText = accent
    Theme.ToggleOn = toggle
    Theme.ToggleOnGlow = accent
    Theme.SliderFill = accent
    Theme.SliderFillEnd = shiftColor(accent, -0.2, -0.2, -0.22)
    Theme.SliderKnob = accent
    Theme.TextAccent = accent
    Theme.NotifAccent = accent
    Theme.LogoGlow = accent
    Theme.EnumBgActive = shiftColor(surface, 0.12, 0.12, 0.14)
    Theme.EnumTextActive = accent
    Theme.KeybindText = accent
    Theme.InputFocus = accent
    Theme.SubTabBg = shiftColor(surface, 0.04, 0.04, 0.05)
    Theme.SubTabActive = Theme.TabBgActive
    Theme.ButtonBg = Theme.TabBgActive
    Theme.ToggleOff = shiftColor(surface, -0.04, -0.04, -0.04)
    Theme.InputBg = shiftColor(bg, 0.02, 0.02, 0.02)
    Theme.InputBorder = shiftColor(surface, 0.06, 0.06, 0.07)
    Theme.KeybindBg = shiftColor(surface, 0.04, 0.04, 0.05)
    Theme.KeybindBorder = shiftColor(surface, 0.08, 0.08, 0.09)
    Theme.EnumBg = shiftColor(surface, 0.04, 0.04, 0.05)
    Theme.SliderTrack = shiftColor(surface, -0.02, -0.02, -0.02)
    Theme.DividerColor = shiftColor(surface, -0.02, -0.02, -0.02)
    Theme.RadarBg = bg
    Theme.RadarBorder = accent
    applyEspPalette()
    syncLegacyKeys()
    for _, cb in ipairs(themeCallbacks) do pcall(cb) end
    if UILib.ActiveThemeRoot and UILib.ActiveThemeRoot.Parent then
        UILib.rethemeTree(UILib.ActiveThemeRoot, previousTheme)
    end
    local accentCol = hexToColor3(Settings.UI.AccentHex)
    for _, sys in ipairs(uiParticleSystems) do pcall(function() sys.setAccent(accentCol) end) end
end
local function resetThemeDefaults()
    ensureUISettings()
    if Settings.UI then
        Settings.UI.AccentHex = "7DD3FC"
        Settings.UI.BackgroundHex = "07080B"
        Settings.UI.SurfaceHex = "0C0D12"
        Settings.UI.ToggleHex = "7DD3FC"
    end
    applyCustomTheme()
end
syncLegacyKeys()
local currentGameData = { name = "Arsenal", espEnabled = true }
local gameConfig = { espEnabled = true }
Settings = {
    ESP={Enabled=false,BoxStyle="2D",BoxEnabled=true,BoxFill=false,NameEnabled=true,HealthEnabled=false,HealthBar=true,HealthBased=true,DistanceEnabled=true,TracerEnabled=false,SkeletonEnabled=false,HeadDotEnabled=false,OffscreenArrows=false,ArrowShowPfp=true,SelfESP=false,VisibleCheck=false,RenderDistance=8000,TextBackground=false,RainbowOutline=false,RainbowColor=false,OutlineEnabled=false,OutlineColor=Color3.fromRGB(210,210,220),TracerOrigin="Bottom",TracerThickness=1,TracerTransparency=0.2,TracerRainbowColor=false,BoxThickness=2,BoxCornerLength=0.32,SkeletonThickness=1,Transparency=0,FontSize=13,Offset=0,ArrowSize=28,ArrowDistance=500,ChamsEnabled=false,ChamsFillTransparency=0.62,FilterMode="Enemies",GlowEnabled=false,GlowTransparency=0.72,ThrowableEnabled=false,ThrowableMaxDistance=250,WeaponLabels=false,ThrowableArcPreview=false,ThrowableArcPower=72,ThrowableArcLift=24,ThrowableArcSegments=22,AutoTeamDetect=true,CompactLabels=true,MaxNameChars=12,LabelFadeStart=140,LabelFadeEnd=320,LinkToAccent=true,CloseHex="FFFFFF",MediumHex="E9EBEF",FarHex="A2A5AA",VeryFarHex="7D8086",BoxHex="",TracerHex="",SkeletonHex="",ChamsHex="",OutlineHex="D2D2DC",NameHex=""},
    Aimbot={Enabled=false,Toggle=false,StickyAim=true,AimMode="Camera",SilentHitboxSize=6,LockPart="Head",Smoothness=0.15,SmoothProfile="Custom",FOVRadius=150,ShowFOV=true,FOVStyle="Circle",FOVDots=12,FOVDotSize=3,FOVSpinSpeed=1.2,FOVThickness=1.5,FOVOpacity=0.5,ShowSilentFOV=false,SilentFOVRadius=180,RequireLOS=false,Prediction=true,PredictionAmount=0.12,PredictionAccel=true,HitChance=100,Multipoint=true,SilentFOVOnly=true,SilentHitbox=false,MaxDistance=500,MultiTarget=false,TargetPriority="Crosshair",MultipointWeight=0.55},
    Crosshair={Enabled=false,Style="Cross",Size=10,Thickness=2,Gap=4,Segments=12,Color=Color3.fromRGB(255,255,255),OutlineEnabled=true,OutlineColor=Color3.fromRGB(0,0,0),OutlineThickness=1,CenterDot=false,CenterDotSize=4,Opacity=1.0,DynamicSpread=false,RainbowColor=false},
    Visuals={Fullbright=false,NoFog=false,CustomFOV=false,FOVAmount=70,ShowFPS=false,ShowVelocity=false,VSync=true,VSyncLock=true,VSyncLockMedium=50,VSyncLockLow=35,CustomBrightness=false,Brightness=2,CustomTime=false,ClockTime=12,CustomExposure=false,Exposure=0,ThirdPerson=false,ThirdPersonDistance=10,ViewmodelFOVEnabled=false,ViewmodelFOV=70,ViewmodelOffsetY=0,ViewmodelSwayReduce=false,GunWireframeEnabled=false,GunWireframeStyle="Wireframe",GunWireframeColorPreset="Accent",GunWireframePartTransparency=0.88,GunWireframeThickness=0.07},
    Movement={SpeedEnabled=false,Speed=16,SpeedMethod="WalkSpeed",JumpEnabled=false,JumpPower=50,BunnyHop=false,BunnyHopSpeed=30,Fly=false,FlySpeed=50,FlyMethod="CFrame",Noclip=false,InfiniteJump=false,ClickTP=false,VehicleSpeed=false,VehicleSpeedMul=2,LocalInvis=false},
    Combat={FastReload=false,FastFireRate=false,AlwaysAuto=false,NoSpread=false,NoRecoil=false,WallBang=false,InfiniteAmmo=false,TriggerBot=false,TriggerDelay=0.05,TriggerJitter=0,TriggerRequireLOS=false,TriggerHeadOnly=false,TriggerRequireADS=false,TriggerBurstCount=1,TriggerBurstGap=0.06,TriggerWeaponBlacklist="",RageBot=false,RageDelay=0.12,RageShoot=true,RageTPDistance=4,RageCycleMode="Nearest",RageShootBursts=6,GunProfile="Custom"},
    Misc={AntiAFK=false,AutoRejoin=false,AutoTPLoop=false,AutoTPLoopDelay=0.2,AutoTPTargetName="Nearest Enemy",AutoObby=false,AutoObbyDelay=0.35,AutoObbyLoop=false,ChatSpammer=false,ChatSpamMessage="Melo 🍃 on top",ChatSpamDelay=3,ChatSpamTeamOnly=false,StreamerMode=false,StreamerModePlus=false,ChatSpyEnabled=false,ChatSpyOnScreen=true,ChatSpyMaxLines=40,LobbyMinPlayers=1,LobbyMaxPlayers=12,AutoHopUntilMatch=false,LobbyAlertOnJoin=true,AntiCheatAlerts=true},
    Webhook={Enabled=false,Hooks={}},
    Audio={HitSoundsEnabled=false,KillSoundsEnabled=false,HitSoundId="911448825",KillSoundId="12222253",HitVolume=0.55,KillVolume=0.65,HitPitch=1,KillPitch=1,MusicEnabled=false,MusicId="",MusicVolume=0.35,MusicLoop=true,MusicPitch=1,MusicSpeed=1,MusicDistance=90,MusicBass=0,MusicTreble=0,Boombox=true},
    Radar={Enabled=false,Type="2D",Size=200,Range=300,Scale=0.88,ShowNames=true,ShowDistance=true,ShowOffRange=true,ShowAltitude=true,RotateWithCamera=true,EnemyColor=Color3.fromRGB(255,70,70),TeamColor=Color3.fromRGB(70,210,90),SelfColor=Color3.fromRGB(255,255,255)},
    Keybinds={
        ToggleGUI=Enum.KeyCode.RightControl,
        PanicKey=Enum.KeyCode.Delete,
        CycleTarget=Enum.KeyCode.Tab,
        ToggleTriggerBot=Enum.KeyCode.X,
        ToggleRageBot=Enum.KeyCode.Unknown,
        ToggleFly=Enum.KeyCode.F,
        ToggleAutoTP=Enum.KeyCode.T,
        ToggleNoclip=Enum.KeyCode.V,
        ClickTP=Enum.KeyCode.LeftAlt,
        ToggleAutoObby=Enum.KeyCode.Unknown,
    },
    MM2={
        NameESP=true,GunESP=true,PlayerChams=false,
        AutoFarm=false,FarmMode="Nearest",FarmDelay=0.22,AutoResetFullBag=false,
        AutoGrabGun=false,KillAura=false,AuraDistance=5,AutoKillAll=false,AutoEndRound=false,
        SilentAim=true,KillMurdererBlatant=false,AutoShootMurderer=false,
        ShootKey=Enum.KeyCode.Q,TargetName="None",LoopGoTo=false,
        AntiAFK=true,AntiFling=true,
    },
    PF={
        TeamFilter=true,WeaponLabels=true,ShowHealth=true,
        PreferHead=true,SoftNoRecoil=false,SoftNoSpread=false,
        AntiAFK=true,TeamColors=true,Skeleton=false,
        SilentAim=true,SilentMethod="FireRound",SilentFOV=220,SilentFOVOnly=true,
        ShowSilentFOV=true,HitChance=100,HeadChance=70,Predict=true,
    },
    HUD={
        Watermark=false,WatermarkPos="TopLeft",
        KeybindList=false,KeybindPos="Right",
        SpectatorList=false,SpectatorPos="TopRight",
        HitFeed=false,HitFeedMax=6,
        SessionStats=false,
        ShowPing=true,ShowFPS=true,ShowExecutor=true,
    },
    UI={AccentHex="6759B3",BackgroundHex="16161F",SurfaceHex="181925",ToggleHex="6759B3",MenuScale=1,ThemePreset="Purple",Autosave=false,BlurMenu=true},
}
local RADAR_TEMP_DISABLED = true
if RADAR_TEMP_DISABLED then Settings.Radar.Enabled = false end
do
    local snap = {}
    for cat, vals in pairs(Settings) do
        if type(vals) == "table" then
            local copy = {}
            for k, v in pairs(vals) do
                copy[k] = v
            end
            snap[cat] = copy
        end
    end
    SettingsDefaults = snap
end
ensureUISettings()
local PROFILE_DIR = "NOX_Hub/"
local currentProfileName = "Default"
local postLoadHooks = {}
local uiSyncFns = {}
local function registerPostLoad(fn) table.insert(postLoadHooks, fn) end
local function registerUiSync(fn) table.insert(uiSyncFns, fn) end
local function runUiSync() for _, fn in ipairs(uiSyncFns) do pcall(fn) end end
local function ensureDir() pcall(function() if not isfolder(PROFILE_DIR) then makefolder(PROFILE_DIR) end end) end
local function profilePath(n) return PROFILE_DIR..n..".json" end
local function listProfiles()
    local p={}; pcall(function() ensureDir(); for _,f in ipairs(listfiles(PROFILE_DIR)) do local n=f:match("([^/\\]+)%.json$"); if n then table.insert(p,n) end end end)
    if #p==0 then table.insert(p,"Default") end; return p
end
local function serC(c) return {_type="Color3",R=math.floor(c.R*255),G=math.floor(c.G*255),B=math.floor(c.B*255)} end
local function desC(t) return Color3.fromRGB(t.R,t.G,t.B) end
local function saveProfile(name)
    if not Cap.ok("filesystem") then
        return false, "filesystem unsupported"
    end
    ensureDir(); return pcall(function()
        local d={_meta={version="Arsenal",game="Arsenal",profile=name}}
        for cat,vals in pairs(Settings) do
            d[cat]={}
            for k,v in pairs(vals) do
                if typeof(v)=="boolean" or typeof(v)=="number" or typeof(v)=="string" then
                    d[cat][k]=v
                elseif typeof(v)=="Color3" then
                    d[cat][k]=serC(v)
                elseif typeof(v)=="EnumItem" then
                    d[cat][k]=v.Name
                elseif cat=="Webhook" and k=="Hooks" and type(v)=="table" then
                    d[cat][k]=v
                end
            end
        end
        writefile(profilePath(name),S.HttpService:JSONEncode(d))
    end)
end
local function loadProfile(name)
    local ok, err = pcall(function()
        local path=profilePath(name); if not isfile(path) then error("Not found: "..name) end
        local d=S.HttpService:JSONDecode(readfile(path))
        for cat,vals in pairs(d) do
            if cat~="_meta" and Settings[cat] then
                for k,v in pairs(vals) do
                    if cat=="Webhook" and k=="Hooks" and type(v)=="table" then
                        Settings.Webhook.Hooks = v
                    elseif Settings[cat][k]~=nil then
                        if type(v)=="table" and v._type=="Color3" then
                            Settings[cat][k]=desC(v)
                        elseif type(v)~="table" then
                            if typeof(Settings[cat][k])=="EnumItem" and type(v)=="string" then
                                Settings[cat][k]=Enum.KeyCode[v] or Enum.UserInputType[v] or Settings[cat][k]
                            else
                                Settings[cat][k]=v
                            end
                        end
                    end
                end
            end
        end
        ensureUISettings()
        currentProfileName=name
    end)
    if ok then
        for _, fn in ipairs(postLoadHooks) do pcall(fn) end
    end
    return ok, err
end
local function deleteProfile(name) pcall(function() if isfile(profilePath(name)) then delfile(profilePath(name)) end end) end
local allConnections = {}
local espObjects     = {}
local espBoundsCache = {}
local espLosCache    = {}
local VisPerf = {
    label = 0.35, distance = 0.45, overlay = 1 / 18, heavy = 0.28, los = 0.4, miscVis = 0.3, radar = 1 / 15,
    fastBounds = 120, skelMax = 900, farHeavy = 200, silentBaseIv = 0.35,
    lastOverlay = 0, lastHeavy = 0, lastMisc = 0, lastMatchMode = 0, lastThrowable = 0, lastRadar = 0,
    lastS = { Lighting = 0 }, offset = 0.05,
    fps = 60, fpsSamples = {}, camMoved = false, lastCamCF = nil, skipFarHeavy = false, lockTier = 0,
    lockChams = false, lockSkel = false, lockGlow = false, lockFill = false, lockTracers = false,
    lockArrows = false, lockBox3D = false, espRt = nil,
}
local espBillboardLayer = nil
local startupChangelogCache = nil
function UILib.sampleVisualFps(dt)
    if not dt or dt <= 0 then return end
    VisPerf.fpsSamples = VisPerf.fpsSamples or {}
    table.insert(VisPerf.fpsSamples, 1 / dt)
    if #VisPerf.fpsSamples > 24 then table.remove(VisPerf.fpsSamples, 1) end
    local sum = 0
    for _, v in ipairs(VisPerf.fpsSamples) do sum = sum + v end
    VisPerf.fps = sum / #VisPerf.fpsSamples
end
function UILib.noteCameraMotion(camCF)
    if not camCF then return end
    local last = VisPerf.lastCamCF
    if last then
        local lookDelta = (camCF.LookVector - last.LookVector).Magnitude
        local posDelta = (camCF.Position - last.Position).Magnitude
        VisPerf.camMoved = lookDelta > 0.0008 or posDelta > 0.04
    else
        VisPerf.camMoved = true
    end
    VisPerf.lastCamCF = camCF
end
function UILib.refreshVSyncLock()
    VisPerf.lockChams = false
    VisPerf.lockSkel = false
    VisPerf.lockGlow = false
    VisPerf.lockFill = false
    VisPerf.lockTracers = false
    VisPerf.lockArrows = false
    VisPerf.lockBox3D = false
    VisPerf.lockTier = 0
    if not Settings.Visuals.VSyncLock then return end
    local fps = VisPerf.fps or 60
    local low = Settings.Visuals.VSyncLockLow or 35
    local med = Settings.Visuals.VSyncLockMedium or 50
    if fps < low then
        VisPerf.lockTier = 2
        VisPerf.lockChams = true
        VisPerf.lockGlow = true
        VisPerf.lockFill = true
        VisPerf.lockTracers = true
        VisPerf.lockArrows = true
        VisPerf.lockBox3D = true
    elseif fps < med then
        VisPerf.lockTier = 1
        VisPerf.lockChams = true
        VisPerf.lockGlow = true
        VisPerf.lockFill = true
    end
end
function UILib.getVisualTickIntervals()
    if Settings.Visuals.VSync then
        local fps = math.clamp(VisPerf.fps or 60, 20, 240)
        local frame = 1 / fps
        return frame, math.max(frame * 2.5, 1 / 45), frame * 1.8, frame * 1.6, math.max(frame * 1.2, 1 / 30)
    end
    return VisPerf.overlay, VisPerf.heavy, VisPerf.miscVis, VisPerf.los, VisPerf.radar
end
function UILib.espBoundsInstant()
    return Settings.Visuals.VSync or VisPerf.camMoved
end
local ESP_BOUNDS_PARTS = {
    "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso",
    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
    "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg",
    "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot",
    "Left Arm", "Right Arm", "Left Leg", "Right Leg",
}
local overlayResetFn = nil
local destroyTargetHLFn = nil
local isUnloading    = false
local currentTarget  = nil
local isTracking     = false
local toggleTrackingActive = false
local rightMouseTracking   = nil
local flyBodyVelocity      = nil
local flyBodyGyro          = nil
local flyRenderConn        = nil
local isFlying             = false
local targetList           = {}
local targetIndex          = 1
local waitingForKey        = false
local keybindCapture       = nil
local keybindIgnoreUntil   = 0
local AIMBOT_HOLD_BIND     = Enum.UserInputType.MouseButton2
local guiMainFrame         = nil
local rigCache = {}
local function clearRigCache(userId) rigCache[userId] = nil end
local function detectRig(character)
    if not character then return nil end
    local data = {}
    data.root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart")
    data.humanoid = character:FindFirstChildOfClass("Humanoid")
    local hv = character:FindFirstChild("Health")
    if data.humanoid then
        data.getHealth    = function() return data.humanoid.Health end
        data.getMaxHealth = function() return data.humanoid.MaxHealth end
        data.isAlive      = function() return data.humanoid.Health > 0 end
    elseif hv and hv:IsA("ValueBase") then
        data.getHealth    = function() return hv.Value end
        data.getMaxHealth = function() return 100 end
        data.isAlive      = function() return hv.Value > 0 end
    else
        data.getHealth    = function() return 100 end
        data.getMaxHealth = function() return 100 end
        data.isAlive      = function() return character.Parent ~= nil end
    end
    if character:FindFirstChild("UpperTorso") then data.rigType = "R15"
    elseif character:FindFirstChild("Torso") then data.rigType = "R6"
    else data.rigType = "Custom" end
    local fallbacks = {Settings.Aimbot.LockPart,"HeadHB","Head","HumanoidRootPart","UpperTorso","Torso","hrp","Root"}
    data.lockPart = nil
    for _,name in ipairs(fallbacks) do local p = character:FindFirstChild(name); if p and p:IsA("BasePart") then data.lockPart = p; break end end
    if not data.lockPart then data.lockPart = character:FindFirstChildWhichIsA("BasePart") end
    if data.root then
        data.getVelocity = function()
            local ok,vel = pcall(function() return data.root.AssemblyLinearVelocity end)
            if ok and vel.Magnitude > 0 then return vel end
            local ok2,vel2 = pcall(function() return data.root.Velocity end)
            if ok2 then return vel2 end
            return Vector3.new(0,0,0)
        end
    else data.getVelocity = function() return Vector3.new(0,0,0) end end
    if data.rigType == "R15" then
        data.skelBones = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
    elseif data.rigType == "R6" then
        data.skelBones = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
    else
        data.skelBones = {}
        local seen = {}
        for _, d in ipairs(character:GetDescendants()) do
            if d:IsA("Motor6D") and d.Part0 and d.Part1 and d.Part0:IsA("BasePart") and d.Part1:IsA("BasePart") then
                local a, b = d.Part0.Name, d.Part1.Name
                local key = a < b and (a .. "|" .. b) or (b .. "|" .. a)
                if not seen[key] and a ~= "Handle" and b ~= "Handle" then
                    seen[key] = true
                    table.insert(data.skelBones, {a, b})
                end
            end
        end
        if #data.skelBones == 0 and data.root then
            local core = {"Head","HeadHB","Torso","UpperTorso","LowerTorso","Left Arm","Right Arm","Left Leg","Right Leg","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"}
            for _, name in ipairs(core) do
                local p = character:FindFirstChild(name)
                if p and p:IsA("BasePart") and p ~= data.root then
                    table.insert(data.skelBones, {data.root.Name, name})
                end
            end
        end
    end
    return data
end
local function getRig(target)
    if not target then return nil end
    if MW.isPF and MW.TracePF and MW.TracePF.getRig then
        local pfRig = MW.TracePF.getRig(target)
        if pfRig then return pfRig end
    end
    local uid = target.UserId; local char = target.Character
    if not char then rigCache[uid] = nil; return nil end
    if rigCache[uid] and rigCache[uid]._char ~= char then rigCache[uid] = nil end
    if not rigCache[uid] then local rd = detectRig(char); if rd then rd._char = char; rigCache[uid] = rd end end
    return rigCache[uid]
end
local function getWorldCharacter(plr)
    if not plr then return nil end
    if MW.isPF and MW.TracePF then
        if MW.TracePF.getRig then
            local rd = MW.TracePF.getRig(plr)
            if rd and rd._char then return rd._char end
        end
        if MW.TracePF.getModel then
            local m = MW.TracePF.getModel(plr)
            if m then return m end
        end
        return nil
    end
    return plr.Character
end
local function hasWorldBody(plr)
    if MW.isPF and MW.TracePF and MW.TracePF.getRig then
        local rd = MW.TracePF.getRig(plr)
        if rd and rd.root then return true end
        return false
    end
    return plr and plr.Character ~= nil
end
local notifScreenGui = nil
local notifLayerRef = nil
local function sendNotification(_title, _message, _duration) end
local function getArsenalFFA()
    local ok, ffa = pcall(function()
        local wkspc = game:GetService("ReplicatedStorage"):FindFirstChild("wkspc")
        return wkspc and wkspc:FindFirstChild("FFA")
    end)
    return ok and ffa and ffa:IsA("BoolValue") and ffa.Value
end
local function normalizeTeamId(v)
    if v == nil then return nil end
    local s = tostring(v)
    if s == "" or s == "nil" or s == "None" then return nil end
    return s
end
local function getPlayerTeamId(plr)
    if not plr then return nil end
    if MW.isPF then
        local ok, name = pcall(function()
            if plr.Team then return plr.Team.Name end
            return tostring(plr.TeamColor)
        end)
        local tid = ok and normalizeTeamId(name) or nil
        if tid then return tid end
    end

    local ok, fromRs = pcall(function()
        local folder = game:GetService("ReplicatedStorage"):FindFirstChild("Players")
        local pf = folder and folder:FindFirstChild(plr.Name)
        local status = pf and pf:FindFirstChild("Status")
        local team = status and status:FindFirstChild("Team")
        if team ~= nil then return team.Value end
        return nil
    end)
    local tid = ok and normalizeTeamId(fromRs) or nil
    if tid then return tid end
    local char = plr.Character
    if char then
        local tv = char:FindFirstChild("Team")
        if tv ~= nil then
            tid = normalizeTeamId(tv.Value)
            if tid then return tid end
        end
        local nrpbs = char:FindFirstChild("NRPBS")
        if nrpbs then
            local tc = nrpbs:FindFirstChild("TeamColor") or nrpbs:FindFirstChild("Color")
            if tc ~= nil then
                tid = normalizeTeamId(tc.Value)
                if tid then return tid end
            end
        end
    end
    if plr.Team then return normalizeTeamId(plr.Team.Name) end
    return nil
end
local function isSpectatorTeam(tid)
    if not tid then return false end
    local lower = string.lower(tid)
    return lower == "spectator" or lower == "spectators" or lower == "none"
end
local function isSameTeam(p1, p2)
    if not p1 or not p2 or p1 == p2 then return true end
    if MW.isArsenal and getArsenalFFA() then return false end
    if MW.isPF then
        local ok, same = pcall(function()
            if p1.Team ~= nil and p2.Team ~= nil then
                return p1.Team == p2.Team
            end
            return p1.TeamColor == p2.TeamColor
        end)
        if ok then return same end
    end
    local t1, t2 = getPlayerTeamId(p1), getPlayerTeamId(p2)

    if isSpectatorTeam(t1) or isSpectatorTeam(t2) then return true end
    if t1 and t2 then return t1 == t2 end
    if p1.Team and p2.Team then return p1.Team == p2.Team end

    if not MW.isArsenal then return false end
    return true
end
local AIM_SMOOTH_PROFILES = {
    Legit = { Smoothness = 0.08, PredictionAmount = 0.08, FOVRadius = 80 },
    Semi = { Smoothness = 0.18, PredictionAmount = 0.12, FOVRadius = 130 },
    Rage = { Smoothness = 0.55, PredictionAmount = 0.2, FOVRadius = 220 },
}
local lastDetectedMatchMode = nil
local matchModeStatusLbl = nil
local function getEffectiveFilterMode()
    if Settings.ESP and Settings.ESP.AutoTeamDetect and MW.isArsenal and getArsenalFFA() then
        return "Enemies"
    end
    return Settings.ESP and Settings.ESP.FilterMode or "Enemies"
end
local function getAimSmoothness()
    local profile = Settings.Aimbot and Settings.Aimbot.SmoothProfile
    if profile and profile ~= "Custom" and AIM_SMOOTH_PROFILES[profile] then
        return AIM_SMOOTH_PROFILES[profile].Smoothness
    end
    return Settings.Aimbot.Smoothness or 0.15
end
local function getAimPredictionAmount()
    local profile = Settings.Aimbot and Settings.Aimbot.SmoothProfile
    if profile and profile ~= "Custom" and AIM_SMOOTH_PROFILES[profile] then
        return AIM_SMOOTH_PROFILES[profile].PredictionAmount
    end
    return Settings.Aimbot.PredictionAmount or 0.12
end
local function applyMultipointCF(cf)
    if not Settings.Aimbot.Multipoint then return cf end
    if TracePack3 and TracePack3.pickMultipoint then
        local out = TracePack3.pickMultipoint(cf, Settings.Aimbot.MultipointWeight or 0.55)
        return out
    end
    return cf
end
local function getAimFOVRadius()
    local profile = Settings.Aimbot and Settings.Aimbot.SmoothProfile
    if profile and profile ~= "Custom" and AIM_SMOOTH_PROFILES[profile] then
        return AIM_SMOOTH_PROFILES[profile].FOVRadius
    end
    return Settings.Aimbot.FOVRadius or 150
end
local function applyAimSmoothProfile(name)
    Settings.Aimbot.SmoothProfile = name
    local preset = AIM_SMOOTH_PROFILES[name]
    if not preset then return end
    Settings.Aimbot.Smoothness = preset.Smoothness
    Settings.Aimbot.PredictionAmount = preset.PredictionAmount
    Settings.Aimbot.FOVRadius = preset.FOVRadius
end
local Pack = {
    Legit = {
        AimMode = "Camera", SmoothProfile = "Legit", StickyAim = true, RequireLOS = true,
        HitChance = 72, Multipoint = true, Prediction = true, PredictionAccel = false,
        SilentFOVOnly = true, ShowFOV = true,
        NoRecoil = false, NoSpread = false, FastFireRate = false, AlwaysAuto = false,
        TriggerBot = false, RageBot = false,
    },
    Semi = {
        AimMode = "Camera", SmoothProfile = "Semi", StickyAim = true, RequireLOS = true,
        HitChance = 90, Multipoint = true, Prediction = true, PredictionAccel = true,
        SilentFOVOnly = true, ShowFOV = true,
        NoRecoil = true, NoSpread = false, FastFireRate = false, AlwaysAuto = true,
        TriggerBot = false, RageBot = false,
    },
    Rage = {
        AimMode = "Camera", SmoothProfile = "Rage", StickyAim = true, RequireLOS = false,
        HitChance = 100, Multipoint = true, Prediction = true, PredictionAccel = true,
        SilentFOVOnly = false, ShowFOV = true,
        NoRecoil = true, NoSpread = true, FastFireRate = true, AlwaysAuto = true,
        TriggerBot = true, RageBot = false,
    },
}
function Pack.apply(name)
    local pack = Pack[name]
    if not pack then return false end
    ensureUISettings()
    applyAimSmoothProfile(pack.SmoothProfile)
    Settings.Aimbot.Enabled = true
    Settings.Aimbot.AimMode = "Camera"
    Settings.Aimbot.StickyAim = pack.StickyAim
    Settings.Aimbot.RequireLOS = pack.RequireLOS
    Settings.Aimbot.HitChance = pack.HitChance
    Settings.Aimbot.Multipoint = true
    Settings.Aimbot.Prediction = pack.Prediction
    Settings.Aimbot.PredictionAccel = true
    Settings.Aimbot.SilentFOVOnly = pack.SilentFOVOnly
    Settings.Aimbot.ShowFOV = pack.ShowFOV
    Settings.Combat.NoRecoil = pack.NoRecoil
    Settings.Combat.NoSpread = pack.NoSpread
    Settings.Combat.FastFireRate = pack.FastFireRate
    Settings.Combat.AlwaysAuto = pack.AlwaysAuto
    Settings.Combat.TriggerBot = pack.TriggerBot
    Settings.Combat.RageBot = pack.RageBot
    pcall(function() if SilentHB and SilentHB.refresh then SilentHB.refresh() end end)
    runUiSync()
    return true
end
function Pack.applyVisuals()
    ensureUISettings()
    Settings.ESP.Enabled = true
    Settings.ESP.BoxEnabled = true
    Settings.ESP.NameEnabled = true
    Settings.ESP.HealthBar = true
    Settings.ESP.DistanceEnabled = true
    Settings.ESP.TracerEnabled = false
    Settings.ESP.SkeletonEnabled = true
    runUiSync()
    return true
end
function Pack.applyMovement()
    ensureUISettings()
    Settings.Movement.SpeedEnabled = true
    Settings.Movement.Speed = 24
    Settings.Movement.Fly = false
    Settings.Movement.Noclip = false
    Settings.Movement.InfiniteJump = false
    runUiSync()
    return true
end
local function cleanCfgName(name)
    name = tostring(name or "")
    name = name:match("^%s*(.-)%s*$") or ""
    name = name:gsub("[\\/:*?\"<>|]", "")
    if #name > 32 then name = name:sub(1, 32) end
    return name
end
local function autoloadPath()
    return PROFILE_DIR .. "_autoload.txt"
end
local function readAutoloadName()
    local name = ""
    pcall(function()
        if isfile and isfile(autoloadPath()) then
            name = readfile(autoloadPath()) or ""
        end
    end)
    return cleanCfgName(name)
end
local function writeAutoloadName(name)
    if not Cap.ok("filesystem") then return false end
    ensureDir()
    return pcall(function()
        writefile(autoloadPath(), cleanCfgName(name or ""))
    end)
end
local function applyNamedConfig(name)
    name = cleanCfgName(name)
    if name == "" then return false, "empty" end
    if isfile and isfile(profilePath(name)) then
        return loadProfile(name)
    end
    if name == "Legit" or name == "Semi" or name == "Rage" then
        return Pack.apply(name) == true
    end
    if name == "Visuals" then
        return Pack.applyVisuals() == true
    end
    if name == "Movement" then
        return Pack.applyMovement() == true
    end
    return false, "missing"
end
local function refreshMatchModeDetect(forceNotify)
    if not Settings.ESP or not Settings.ESP.AutoTeamDetect then
        if matchModeStatusLbl then matchModeStatusLbl.Text = "Mode: Manual filter" end
        return
    end
    local mode
    if MW.isArsenal then
        mode = getArsenalFFA() and "FFA" or "Teams"
    else
        mode = (player.Team ~= nil) and "Teams" or "FFA"
    end
    local changed = mode ~= lastDetectedMatchMode
    if not forceNotify and not changed then return end
    lastDetectedMatchMode = mode
    if matchModeStatusLbl then
        if not MW.isArsenal then
            matchModeStatusLbl.Text = mode == "FFA" and "Mode: Universal FFA" or "Mode: Universal Teams"
        else
            matchModeStatusLbl.Text = mode == "FFA" and "Mode: FFA (auto)" or "Mode: Teams (auto)"
        end
    end
    if forceNotify or changed then
        sendNotification(MW.hub, mode == "FFA" and "FFA detected - all players are targets" or "Team mode - using your ESP filter", 3)
    end
end
local function hookMatchModeDetect()
    if not MW.isArsenal then return end
    pcall(function()
        local wkspc = game:GetService("ReplicatedStorage"):WaitForChild("wkspc", 20)
        if not wkspc then return end
        local ffa = wkspc:WaitForChild("FFA", 10)
        if ffa and ffa:IsA("BoolValue") then
            ffa.Changed:Connect(function()
                lastDetectedMatchMode = nil
                refreshMatchModeDetect(true)
            end)
        end
    end)
end
local function isValidRadarTarget(admin, target)
    if not target or target == admin then return false end
    local mode = getEffectiveFilterMode()
    if mode == "All" then return true end
    if mode == "Team" then return isSameTeam(admin, target) end
    return not isSameTeam(admin, target)
end
local streamerUiRefs = {}
local function isStreamerActive()
    return Settings.Misc and (Settings.Misc.StreamerMode or Settings.Misc.StreamerModePlus)
end
local function applyStreamerPrivacy()
    if not Settings.Misc then return end
    local plus = Settings.Misc.StreamerModePlus
    local hideNames = isStreamerActive()
    local r = streamerUiRefs
    if r.logoTitle then
        if plus then r.logoTitle.Text = "Private"
        elseif r.refreshLogoTitle then r.refreshLogoTitle() end
    end
    if r.logoSub then r.logoSub.Visible = false end
    if r.playerNameLbl then r.playerNameLbl.Text = hideNames and "Hidden" or player.DisplayName end
    if r.premBadge then r.premBadge.Visible = not plus end
    if r.updateFooterStatus then r.updateFooterStatus()
    elseif r.footerCenter then r.footerCenter.Text = MW.tagline end
    if r.updateServerInfo then r.updateServerInfo() end
end
local function getDisplayName(target)
    if not target then return "Player" end
    if Settings.Misc.StreamerModePlus then
        return "Player" .. string.format("%03d", target.UserId % 1000)
    end
    if Settings.Misc.StreamerMode then
        return "Player" .. string.sub(tostring(target.UserId), -3)
    end
    return target.DisplayName or target.Name
end
local function getPlayerWeaponName(plr)
    if not plr then return nil end
    if MW.isPF and MW.TracePF and MW.TracePF.getWeaponName then
        local w = MW.TracePF.getWeaponName(plr)
        if w and w ~= "" then return tostring(w) end
    end
    local char = getWorldCharacter(plr) or plr.Character
    if not char then return nil end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then return child.Name end
    end
    for _, d in ipairs(char:GetDescendants()) do
        if d.Name == "GunClient" or d.Name == "ACS_Client" then
            local tool = d.Parent
            if tool and tool ~= char then return tool.Name end
        end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("Handle", true) then
            local n = child.Name
            if n ~= "Head" and n ~= "HumanoidRootPart" and not n:find("Accessory", 1, true) then
                return n
            end
        end
    end
    local backpack = plr:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") then return child.Name end
        end
    end
    local ok, weapon = pcall(function()
        local data = plr:FindFirstChild("Data") or plr:FindFirstChild("Stats") or plr:FindFirstChild("leaderstats")
        if not data then
            local folder = game:GetService("ReplicatedStorage"):FindFirstChild("Players")
            local pf = folder and folder:FindFirstChild(plr.Name)
            data = pf and (pf:FindFirstChild("Data") or pf:FindFirstChild("Status") or pf:FindFirstChild("Stats"))
        end
        if not data then return nil end
        local w = data:FindFirstChild("Weapon") or data:FindFirstChild("Equipped") or data:FindFirstChild("Gun")
            or data:FindFirstChild("CurrentWeapon") or data:FindFirstChild("HeldItem")
        if w and (w:IsA("StringValue") or w:IsA("ObjectValue")) then
            return w:IsA("StringValue") and w.Value or (w.Value and w.Value.Name)
        end
        return nil
    end)
    if ok and weapon and weapon ~= "" then return tostring(weapon) end
    return nil
end
local function isValidESPTarget(admin,target)
    if target==admin then return Settings.ESP.SelfESP end
    local mode=getEffectiveFilterMode()
    if mode=="All" then return true elseif mode=="Team" then return isSameTeam(admin,target) else return not isSameTeam(admin,target) end
end
local function isValidTarget(admin,target) if target==admin then return false end; if isSameTeam(admin,target) then return false end; return true end
local _losRP = RaycastParams.new()
_losRP.FilterType = Enum.RaycastFilterType.Exclude
local _losCachedChar = nil
local WB
local function hasLOS(admin, target)

    local ac = getWorldCharacter(admin) or admin.Character
    local tc = getWorldCharacter(target)
    if not tc then return false end
    if not ac and not (MW.isPF and S.Workspace.CurrentCamera) then return false end
    local cam = S.Workspace.CurrentCamera
    local origin = cam and cam.CFrame.Position or nil
    if not origin then
        local ah = ac and (ac:FindFirstChild("Head") or ac:FindFirstChildWhichIsA("BasePart"))
        if not ah then return false end
        origin = ah.Position
    end
    local points = {}
    local rd = getRig(target)
    if rd then
        if rd.lockPart then points[#points + 1] = rd.lockPart.Position end
        if rd.root then points[#points + 1] = rd.root.Position end
        if type(rd.parts) == "table" then
            for _, p in pairs(rd.parts) do
                if typeof(p) == "Instance" and p:IsA("BasePart") then
                    points[#points + 1] = p.Position
                end
            end
        end
    end
    local names = { "HeadHB", "Head", "UpperTorso", "Torso", "HumanoidRootPart" }
    for i = 1, #names do
        local p = tc:FindFirstChild(names[i])
        if p and p:IsA("BasePart") then
            points[#points + 1] = p.Position
        end
    end
    if #points == 0 then
        if rd and rd.root then
            points[1] = rd.root.Position
        else
            return false
        end
    end
    local function softBlock(inst)
        if not inst or not inst:IsA("BasePart") then return false end
        if inst.Transparency >= 0.8 then return true end
        local mat = inst.Material
        if mat == Enum.Material.Glass or mat == Enum.Material.ForceField then return true end
        local n = string.lower(inst.Name)
        if string.find(n, "glass", 1, true) or string.find(n, "window", 1, true)
            or string.find(n, "pane", 1, true) or string.find(n, "rail", 1, true) then
            return true
        end

        if inst.CanCollide == false and inst.Transparency > 0.05 then return true end
        return false
    end
    local filter = {}
    if ac then filter[#filter + 1] = ac end
    if cam then filter[#filter + 1] = cam end
    local playersFolder = S.Workspace:FindFirstChild("Players")
    if MW.isPF and playersFolder then filter[#filter + 1] = playersFolder end
    local ignoreFolder = S.Workspace:FindFirstChild("Ignore")
    if MW.isPF and ignoreFolder then filter[#filter + 1] = ignoreFolder end
    _losRP.FilterDescendantsInstances = filter
    _losCachedChar = ac
    if WB then WB.bypass = true end
    local visible = false
    pcall(function()
        for i = 1, #points do
            local dest = points[i]
            local from = origin
            local hops = 0
            while hops < 8 do
                local dir = dest - from
                local mag = dir.Magnitude
                if mag < 0.08 then
                    visible = true
                    return
                end
                local hit = S.Workspace:Raycast(from, dir, _losRP)
                if not hit then
                    visible = true
                    return
                end
                local inst = hit.Instance
                local walk = inst
                while walk do
                    if walk == tc then
                        visible = true
                        return
                    end
                    walk = walk.Parent
                end
                if softBlock(inst) then
                    filter[#filter + 1] = inst
                    _losRP.FilterDescendantsInstances = filter
                    from = hit.Position + dir.Unit * 0.12
                    hops = hops + 1
                else
                    break
                end
            end
        end
    end)
    if WB then WB.bypass = false end
    return visible
end
local function isInFOV(target,fovRadius)
    local cam=S.Workspace.CurrentCamera; if not cam then return false end
    local rd=getRig(target)
    local char = getWorldCharacter(target)
    if not char and not (rd and rd.lockPart) then return false end
    local parts = {}
    if rd then
        if rd.parts and rd.parts.Head then parts[#parts+1] = rd.parts.Head end
        if rd.lockPart then parts[#parts+1] = rd.lockPart end
        if rd.root then parts[#parts+1] = rd.root end
    end
    if char then
        parts[#parts+1] = char:FindFirstChild("HeadHB")
        parts[#parts+1] = char:FindFirstChild("Head")
        parts[#parts+1] = char:FindFirstChild("UpperTorso")
        parts[#parts+1] = char:FindFirstChild("Torso")
        parts[#parts+1] = char:FindFirstChild("HumanoidRootPart")
    end
    local sc=cam.ViewportSize/2
    for i=1,#parts do
        local part=parts[i]
        if part and part:IsA("BasePart") then
            local sp,on=cam:WorldToViewportPoint(part.Position)
            if on and sp.Z>0 and (Vector2.new(sp.X,sp.Y)-sc).Magnitude<=fovRadius then
                return true
            end
        end
    end
    return false
end
local function bindName(bind)
    if typeof(bind) == "EnumItem" then
        if bind.EnumType == Enum.UserInputType then
            if bind == Enum.UserInputType.MouseButton1 then return "M1" end
            if bind == Enum.UserInputType.MouseButton2 then return "M2" end
            if bind == Enum.UserInputType.MouseButton3 then return "M3" end
        end
        return bind.Name
    end
    if type(bind) == "string" and bind ~= "" then return bind end
    return "None"
end
local function restoreEnumBind(val, fallback)
    if typeof(val) == "EnumItem" then return val end
    if type(val) == "string" and val ~= "" then
        return Enum.KeyCode[val] or Enum.UserInputType[val] or fallback
    end
    return fallback
end
local function inputMatchesBind(input, bind)
    bind = restoreEnumBind(bind, nil)
    if not bind or bind == Enum.KeyCode.Unknown then return false end
    if bind.EnumType == Enum.KeyCode then
        return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == bind
    end
    if bind.EnumType == Enum.UserInputType then
        return input.UserInputType == bind
    end
    return false
end
local function isPlayerScoped()
    local cam = S.Workspace.CurrentCamera
    if not cam then return false end
    if Settings.Visuals.CustomFOV and cam.FieldOfView >= (Settings.Visuals.FOVAmount - 1) then
        return false
    end
    return cam.FieldOfView < 52
end
local function refreshThemeHexFields()
    if not Settings.UI then return end
    for key, field in pairs(themeHexFields) do
        if field.box and field.prev and Settings.UI[key] then
            field.box.Text = "#" .. Settings.UI[key]
            field.prev.BackgroundColor3 = hexToColor3(Settings.UI[key])
        end
    end
end
local function getESPColor(dist)
    if dist < 90 then return Theme.ESP_Close or Theme.TextAccent
    elseif dist < 180 then return Theme.ESP_Medium or Theme.TextAccent
    elseif dist < 280 then return Theme.ESP_Far or Color3.fromRGB(220, 222, 230)
    else return Theme.ESP_VeryFar or Color3.fromRGB(190, 192, 202) end
end
local function getESPPartColor(hexKey, themeColor, dist, rainbow)
    if rainbow then return rainbow end
    local h = Settings.ESP and Settings.ESP[hexKey]
    if type(h) == "string" and normalizeHex(h) then
        return themeColor or getESPColor(dist)
    end
    return getESPColor(dist)
end
local function getHeadDotColor()
    return Theme.TextAccent or hexToColor3(Settings.UI and Settings.UI.AccentHex or "7DD3FC")
end
local function getHealthColor(pct)
    if pct > 0.6 then return Color3.fromRGB(92, 220, 120)
    elseif pct > 0.3 then return Color3.fromRGB(235, 185, 70)
    else return Color3.fromRGB(230, 78, 78) end
end
local function getESPLabelFade(dist)
    local a = Settings.ESP.LabelFadeStart or 140
    local b = Settings.ESP.LabelFadeEnd or 320
    if dist <= a then return 0 end
    if dist >= b then return 0.72 end
    return ((dist - a) / math.max(b - a, 1)) * 0.72
end
local function truncateESPName(name)
    local maxLen = math.max(4, math.floor(Settings.ESP.MaxNameChars or 12))
    name = tostring(name or "")
    if #name <= maxLen then return name end
    return string.sub(name, 1, maxLen - 1) .. "…"
end
local function buildESPMetaText(dist, hp, maxhp)
    local compact = Settings.ESP.CompactLabels ~= false
    local parts = {}
    if Settings.ESP.DistanceEnabled then
        table.insert(parts, compact and (math.floor(dist) .. "m") or string.format("[%dm]", math.floor(dist)))
    end
    if Settings.ESP.HealthEnabled then
        table.insert(parts, compact and (math.floor(hp) .. "hp") or string.format("%d HP", math.floor(hp)))
    end
    if #parts == 0 then return "" end
    return compact and table.concat(parts, " · ") or table.concat(parts, "  ")
end
local function buildTargetList()
    local cam=S.Workspace.CurrentCamera; if not cam then return end
    local myChar=getWorldCharacter(player) or player.Character
    local myRoot=myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar:FindFirstChildWhichIsA("BasePart"))
    if not myRoot then
        myRoot = { Position = cam.CFrame.Position }
    end
    targetList={}
    local fovR=getAimFOVRadius()
    local sc=cam.ViewportSize/2
    local aimMode = Settings.Aimbot.AimMode or "Camera"
    if aimMode == "Hybrid" then aimMode = "Silent" end
    local needLos = Settings.Aimbot.RequireLOS and aimMode ~= "Silent"
    if aimMode == "Silent" then
        if Settings.Aimbot.SilentFOVOnly == false then
            fovR = 1e9
        else
            fovR = tonumber(Settings.Aimbot.SilentFOVRadius) or fovR
        end
    end
    for _,t in ipairs(S.Players:GetPlayers()) do
        if isValidTarget(player,t) then
            local rd=getRig(t)
            if rd and rd.root and rd.isAlive() then
                local dist=(myRoot.Position-rd.root.Position).Magnitude
                if dist<=Settings.Aimbot.MaxDistance then
                    if not needLos or hasLOS(player,t) then

                        local wc = getWorldCharacter(t)
                        local bestScreen=nil
                        local probe={
                            rd.parts and rd.parts.Head,
                            wc and wc:FindFirstChild("HeadHB"),
                            wc and wc:FindFirstChild("Head"),
                            wc and wc:FindFirstChild("UpperTorso"),
                            rd.lockPart,
                            rd.root,
                        }
                        for i=1,#probe do
                            local lp=probe[i]
                            if lp and lp:IsA("BasePart") then
                                local sp,on=cam:WorldToViewportPoint(lp.Position)
                                if on and sp.Z>0 then
                                    local d=(Vector2.new(sp.X,sp.Y)-sc).Magnitude
                                    if d<=fovR and (not bestScreen or d<bestScreen) then
                                        bestScreen=d
                                    end
                                end
                            end
                        end
                        if bestScreen then
                            table.insert(targetList,{player=t,dist=dist,screenDist=bestScreen})
                        end
                    end
                end
            else
                local tc=t.Character; if tc then
                    local th=tc:FindFirstChild("HumanoidRootPart"); local hum=tc:FindFirstChild("Humanoid")
                    if th and hum and hum.Health>0 then
                        local dist=(myRoot.Position-th.Position).Magnitude
                        if dist<=Settings.Aimbot.MaxDistance then
                            if not needLos or hasLOS(player,t) then
                                local part=tc:FindFirstChild("HeadHB") or tc:FindFirstChild(Settings.Aimbot.LockPart) or tc:FindFirstChild("Head") or th
                                if part then local sp,on=cam:WorldToViewportPoint(part.Position); if on and sp.Z>0 then local d=(Vector2.new(sp.X,sp.Y)-sc).Magnitude; if d<=fovR then table.insert(targetList,{player=t,dist=dist,screenDist=d}) end end end
                            end
                        end
                    end
                end
            end
        end
    end
    local prio = Settings.Aimbot.TargetPriority or "Crosshair"
    table.sort(targetList, function(a, b)
        if prio == "Closest" then
            return a.dist < b.dist
        elseif prio == "LowestHP" then
            local ah = 100
            local bh = 100
            local ar = getRig(a.player)
            local br = getRig(b.player)
            if ar then ah = ar.getHealth() elseif a.player.Character then local h=a.player.Character:FindFirstChild("Humanoid"); if h then ah=h.Health end end
            if br then bh = br.getHealth() elseif b.player.Character then local h=b.player.Character:FindFirstChild("Humanoid"); if h then bh=h.Health end end
            if ah ~= bh then return ah < bh end
            return a.screenDist < b.screenDist
        elseif prio == "Threat" then

            local as = a.dist * 0.35 + a.screenDist
            local bs = b.dist * 0.35 + b.screenDist
            return as < bs
        end
        return a.screenDist < b.screenDist
    end)
end
local function cycleTarget() buildTargetList(); if #targetList==0 then currentTarget=nil; return end; targetIndex=targetIndex+1; if targetIndex>#targetList then targetIndex=1 end; currentTarget=targetList[targetIndex].player; sendNotification("Target","Locked: "..getDisplayName(currentTarget),1.5) end
local function getNearestTarget() buildTargetList(); if #targetList==0 then return nil end; targetIndex=1; return targetList[1].player end
local SilentRay
local SilentHB = {
    parts = { "RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart" },
    mpNames = { "HeadHB", "Head", "UpperTorso", "Torso", "HumanoidRootPart" },
    orig = {},
    appliedSize = {},
    velHist = {},
    running = false,
    lastTick = 0,
    tickIv = 0.35,
    hcPass = true,
    hcUntil = 0,
}
function SilentHB.shouldRun()
    return false
end
function SilentHB.passHitChance()
    local chance = tonumber(Settings.Aimbot.HitChance) or 100
    chance = math.clamp(chance, 1, 100)
    if chance >= 100 then return true end
    local now = tick()
    if now < (SilentHB.hcUntil or 0) then return SilentHB.hcPass end
    SilentHB.hcUntil = now + 0.12
    SilentHB.hcPass = (math.random(1, 100) <= chance)
    return SilentHB.hcPass
end
function SilentHB.pickPart(char)
    if not char then return nil end
    local cam = S.Workspace.CurrentCamera
    local prefer = Settings.Aimbot.LockPart
    local names = SilentHB.mpNames
    local best, bestScore = nil, -1e9
    local function consider(part)
        if not part or not part:IsA("BasePart") then return end
        local score = 1
        if prefer and part.Name == prefer then score = score + 40 end
        if part.Name == "HeadHB" or part.Name == "Head" then score = score + 12 end
        if cam then
            local sp, on = cam:WorldToViewportPoint(part.Position)
            if on and sp.Z > 0 then
                local sc = cam.ViewportSize * 0.5
                local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(sc.X, sc.Y)).Magnitude
                score = score + 25 - math.min(d * 0.04, 20)
            else
                score = score - 15
            end
        end
        if score > bestScore then bestScore = score; best = part end
    end
    if prefer then consider(char:FindFirstChild(prefer)) end
    for i = 1, #names do consider(char:FindFirstChild(names[i])) end
    return best
end
function SilentHB.recordVel(plr, vel)
    if not plr then return end
    local uid = plr.UserId
    local now = tick()
    local h = SilentHB.velHist[uid]
    if not h then
        SilentHB.velHist[uid] = { v = vel, t = now, a = Vector3.new() }
        return
    end
    local dt = now - (h.t or now)
    if dt > 0.01 and dt < 0.5 then
        h.a = (vel - h.v) / dt
    end
    h.v = vel
    h.t = now
end
function SilentHB.predictPos(target)
    local rd = getRig(target)
    local char = getWorldCharacter(target)
    if not char and not (rd and rd.lockPart) then return nil end
    local part = char and SilentHB.pickPart(char) or nil
    if not part then
        if not rd or not rd.lockPart then return nil end
        part = rd.lockPart
    end
    local pos = part.Position
    if not Settings.Aimbot.Prediction then return pos end
    local vel = (rd and rd.getVelocity and rd.getVelocity()) or Vector3.new()
    SilentHB.recordVel(target, vel)
    local lead = getAimPredictionAmount()
    local myRoot = player.Character and (player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChildWhichIsA("BasePart"))
    local cam = S.Workspace.CurrentCamera
    local myPos = myRoot and myRoot.Position or (cam and cam.CFrame.Position)
    if myPos then
        local dist = (myPos - pos).Magnitude
        lead = lead * (1 + math.clamp(dist / 350, 0, 0.85))
    end
    pos = pos + vel * lead
    do
        local h = SilentHB.velHist[target.UserId]
        if h and h.a then
            local am = h.a.Magnitude
            if am > 0.5 and am < 220 then
                pos = pos + h.a * (lead * lead * 0.5)
            end
        end
    end
    return pos
end
function SilentHB.restorePart(part)
    local o = SilentHB.orig[part]
    if o and part then
        pcall(function()
            if part.Parent then
                part.Size = o.Size
                part.Transparency = o.Transparency
                part.CanCollide = o.CanCollide
                if o.LocalTransparencyModifier ~= nil then
                    part.LocalTransparencyModifier = o.LocalTransparencyModifier
                end
            end
        end)
    end
    SilentHB.orig[part] = nil
    SilentHB.appliedSize[part] = nil
end
function SilentHB.restoreAll()
    local parts = {}
    for part in pairs(SilentHB.orig) do
        table.insert(parts, part)
    end
    for i = 1, #parts do
        SilentHB.restorePart(parts[i])
    end
    SilentHB.orig = {}
    SilentHB.appliedSize = {}
end
function SilentHB.inSilentScope(plr)
    if plr == currentTarget then return true end
    if Settings.Aimbot.SilentFOVOnly == false then return true end
    return isInFOV(plr, getAimFOVRadius())
end
function SilentHB.applyChar(plr, char)
    if not plr or not char then return end
    if MW.guard("hitbox") then return end
    if Settings.Aimbot.SilentHitbox ~= true then return end
    local softParts = { "HeadHB", "Head" }
    if not SilentHB.inSilentScope(plr) then
        for _, name in ipairs(softParts) do
            local part = char:FindFirstChild(name)
            if part then SilentHB.restorePart(part) end
        end
        return
    end
    local sz = tonumber(Settings.Aimbot.SilentHitboxSize) or 6
    sz = math.clamp(sz, 2, 12)
    local size = Vector3.new(sz, sz, sz)
    for _, name in ipairs(softParts) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            if not SilentHB.orig[part] then
                SilentHB.orig[part] = {
                    Size = part.Size,
                    Transparency = part.Transparency,
                    CanCollide = part.CanCollide,
                    LocalTransparencyModifier = part.LocalTransparencyModifier,
                }
            end
            local applied = SilentHB.appliedSize[part]
            if applied ~= sz then
                pcall(function()
                    part.Size = size
                    part.CanCollide = false
                    part.Massless = true
                    part.Transparency = 1
                    part.LocalTransparencyModifier = 1
                end)
                SilentHB.appliedSize[part] = sz
            end
        end
    end
end
function SilentHB.adaptInterval()
    local base = VisPerf.silentBaseIv or 0.35
    local fps = math.clamp(VisPerf.fps or 60, 20, 240)
    local pc = #S.Players:GetPlayers()
    local iv = base
    if fps < 40 then iv = iv * 1.45 elseif fps < 55 then iv = iv * 1.2 end
    if pc > 22 then iv = iv * 1.55 elseif pc > 14 then iv = iv * 1.25 end
    SilentHB.tickIv = math.clamp(iv, 0.08, 0.9)
    return SilentHB.tickIv
end
function SilentHB.tick()
    if MW.guard("hitbox") then
        if next(SilentHB.orig) ~= nil then SilentHB.restoreAll() end
        return
    end
    if not SilentHB.shouldRun() then
        if next(SilentHB.orig) ~= nil then SilentHB.restoreAll() end
        return
    end
    if Settings.Aimbot.SilentHitbox ~= true then
        if next(SilentHB.orig) ~= nil then SilentHB.restoreAll() end
        return
    end
    SilentHB.adaptInterval()
    local now = tick()
    if now - (SilentHB.lastTick or 0) < (SilentHB.tickIv or 0.35) then return end
    SilentHB.lastTick = now
    for _, plr in ipairs(S.Players:GetPlayers()) do
        if plr ~= player and isValidTarget(player, plr) then
            local char = plr.Character
            if char then SilentHB.applyChar(plr, char) end
        end
    end
end
function SilentHB.stop()
    SilentHB.running = false
    SilentHB.restoreAll()
end
function SilentHB.start()
    SilentHB.restoreAll()
    SilentHB.running = true
    if not SilentHB.tickConn then
        SilentHB.tickConn = S.RunService.Heartbeat:Connect(function()
            if isUnloading or _G[MW_T.unloaded] or not SilentHB.running then return end
            pcall(SilentHB.tick)
        end)
        table.insert(allConnections, SilentHB.tickConn)
    end
    if SilentRay and SilentRay.ensure then SilentRay.ensure() end
    if SilentRay and SilentRay.startLoop then SilentRay.startLoop() end
end
function SilentHB.refresh()
    if SilentHB.shouldRun() then
        SilentHB.start()
        if SilentRay and SilentRay.ensure then SilentRay.ensure() end
    else
        SilentHB.stop()
    end
end
SilentRay = SilentRay or {
    hooked = false,
    mouse = nil,
    loop = nil,
    busy = false,
    spoofs = 0,
    lastSpoofReset = 0,
    cache = { cf = nil, origin = nil, pos = nil, target = nil, part = nil, t = 0 },
}
function SilentRay.modeOn()
    return false
end
function SilentRay.active()
    return SilentRay.modeOn() and SilentRay.hooked == true and not SilentRay.busy
end
function SilentRay.isMouseObj(self)
    if self == nil then return false end
    if self == SilentRay.mouse then return true end
    local ok, cn = pcall(function() return self.ClassName end)
    return ok and cn == "Mouse"
end
function SilentRay.isWorkspace(self)
    return self == S.Workspace or self == workspace
end
function SilentRay.silentFov()
    if Settings.Aimbot.SilentFOVOnly == false then return 400 end
    return tonumber(Settings.Aimbot.SilentFOVRadius) or getAimFOVRadius() or 180
end
function SilentRay.pickHitPart(target)
    local char = target and target.Character
    if not char then return nil end
    local prefer = Settings.Aimbot.LockPart
    local names = { prefer, "HeadHB", "Head", "Hitbox", "UpperTorso", "HumanoidRootPart" }
    for i = 1, #names do
        local n = names[i]
        if n and n ~= "" then
            local p = char:FindFirstChild(n)
            if p and p:IsA("BasePart") then return p end
        end
    end
    return nil
end
function SilentRay.getClosestHitPart()
    local cam = S.Workspace.CurrentCamera
    if not cam then return nil end
    local mousePos
    do
        local okM, mp = pcall(function() return S.UserInputService:GetMouseLocation() end)
        if okM and typeof(mp) == "Vector2" then
            mousePos = mp
        else
            mousePos = cam.ViewportSize * 0.5
        end
    end
    local fov = SilentRay.silentFov()
    local bestPart, bestPlr, bestDist = nil, nil, fov
    local maxDist = tonumber(Settings.Aimbot.MaxDistance) or 500
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    for _, plr in ipairs(S.Players:GetPlayers()) do
        if isValidTarget(player, plr) then
            local char = plr.Character
            if char then
                local part = SilentRay.pickHitPart(plr)
                if part then
                    local okDist = true
                    if myRoot then
                        okDist = (myRoot.Position - part.Position).Magnitude <= maxDist
                    end
                    if okDist then
                        local sp, on = cam:WorldToViewportPoint(part.Position)
                        if on and sp.Z > 0 then
                            local d = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                            if d <= bestDist then
                                bestDist = d
                                bestPart = part
                                bestPlr = plr
                            end
                        end
                    end
                end
            end
        end
    end
    if bestPlr then currentTarget = bestPlr end
    return bestPart, bestPlr
end
function SilentRay.resolveShot()
    if SilentRay.busy then
        local c = SilentRay.cache
        if c and c.part then return c.part, c.pos, c.cf, c.origin, c.target end
        return nil
    end
    if not SilentRay.modeOn() then return nil end
    if not SilentHB.passHitChance() then return nil end
    SilentRay.busy = true
    local part, target, pos, cf, origin
    local ok = pcall(function()
        part, target = SilentRay.getClosestHitPart()
        if not part then return end
        pos = part.Position
        if Settings.Aimbot.Prediction and target then
            local predicted = SilentHB.predictPos(target)
            if predicted then pos = predicted end
        end
        cf = CFrame.new(pos)
        local cam = S.Workspace.CurrentCamera
        origin = cam and cam.CFrame.Position or pos
        local c = SilentRay.cache
        c.cf, c.origin, c.pos, c.target, c.part, c.t = cf, origin, pos, target, part, tick()
    end)
    SilentRay.busy = false
    if not ok or not part then return nil end
    return part, pos, cf, origin, target
end
function SilentRay.refreshTarget()
    local _, plr = SilentRay.getClosestHitPart()
    if plr then currentTarget = plr end
    return currentTarget
end
function SilentRay.updateCache()
    if not SilentRay.modeOn() then
        local c = SilentRay.cache
        c.cf, c.origin, c.pos, c.target, c.part, c.t = nil, nil, nil, nil, nil, 0
        return
    end
    SilentRay.resolveShot()
end
function SilentRay.getAimCached()
    local c = SilentRay.cache
    if not c or not c.part or not c.pos then return nil end
    if (tick() - (c.t or 0)) > 0.35 then return nil end
    return c.part, c.pos, c.cf, c.origin, c.target
end
function SilentRay.allowSpoof()
    local now = tick()
    if now - (SilentRay.lastSpoofReset or 0) > 2 then
        SilentRay.spoofs = 0
        SilentRay.lastSpoofReset = now
    end
    if (SilentRay.spoofs or 0) >= 120 then return false end
    SilentRay.spoofs = (SilentRay.spoofs or 0) + 1
    return true
end
function SilentRay.callerOk()
    if type(getcallingscript) ~= "function" then return true end
    local ok, scr = pcall(getcallingscript)
    if not ok or scr == nil then return true end
    local name = ""
    pcall(function() name = string.lower(tostring(scr.Name)) end)
    if name == "" then return true end

    if name == "playermodule" or name == "cameramodule" or name == "controlmodule" then return false end
    if string.find(name, "camera", 1, true) or string.find(name, "animate", 1, true) then return false end
    return true
end
function SilentRay.startLoop()
    if SilentRay.loop then return end
    SilentRay.loop = S.RunService.Heartbeat:Connect(function()
        if isUnloading or _G[MW_T.unloaded] then return end
        if SilentRay.modeOn() then
            if not SilentRay.hooked then pcall(SilentRay.ensure) end
            pcall(SilentRay.updateCache)
        else
            local c = SilentRay.cache
            c.cf = nil
            c.part = nil
        end
    end)
    table.insert(allConnections, SilentRay.loop)
end
function SilentRay.ensure()
    return false
end
function SilentRay._ensureDisabled()
    SilentRay.startLoop()
    if SilentRay.hooked then return true end
    if type(hookmetamethod) ~= "function" then return false end
    local okMouse, mouse = pcall(function() return player:GetMouse() end)
    if okMouse and mouse then SilentRay.mouse = mouse end
    local function safeCheckcaller()
        if type(checkcaller) ~= "function" then return false end
        local ok, v = pcall(checkcaller)
        return ok and v == true
    end
    local wrap = (WB and WB.wrap) or function(fn) return fn end
    local function dirTo(origin, dest, mag)
        local d = dest - origin
        if d.Magnitude < 0.001 then return Vector3.new(0, 0, -1) * (mag or 1000) end
        return d.Unit * (mag or 1000)
    end
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", wrap(function(self, key)
        if SilentRay.busy then return oldIndex(self, key) end
        if not safeCheckcaller() and SilentRay.active() and SilentRay.isMouseObj(self) then
            local k = key
            if k == "Hit" or k == "hit" then
                local part, pos, cf = SilentRay.getAimCached()
                if cf then return cf end
                if part then return part.CFrame end
            elseif k == "Target" or k == "target" then
                local part = SilentRay.getAimCached()
                if part then return part end
            elseif k == "UnitRay" or k == "unitRay" then
                local part, pos, cf, origin = SilentRay.getAimCached()
                if pos and origin then
                    return Ray.new(origin, dirTo(origin, pos, 1000))
                end
            end
        end
        return oldIndex(self, key)
    end))
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", wrap(function(...)
        local args = { ... }
        local self = args[1]
        if SilentRay.busy then
            return oldNamecall(unpack(args))
        end
        local method = (type(getnamecallmethod) == "function" and getnamecallmethod()) or ""
        local methodL = string.lower(tostring(method))
        if not safeCheckcaller() and SilentRay.active() and SilentRay.callerOk() and SilentRay.isWorkspace(self) then
            if methodL == "findpartonraywithignorelist"
                or methodL == "findpartonraywithwhitelist"
                or methodL == "findpartonray"
                or methodL == "raycast" then
                local part, pos = SilentRay.getAimCached()
                if part and pos and SilentRay.allowSpoof() then
                    if methodL == "raycast" then
                        if typeof(args[2]) == "Vector3" and typeof(args[3]) == "Vector3" then
                            local mag = args[3].Magnitude
                            if mag < 1 then mag = 1000 end
                            args[3] = dirTo(args[2], pos, mag)
                            return oldNamecall(unpack(args))
                        end
                    elseif typeof(args[2]) == "Ray" then
                        local o = args[2].Origin
                        local mag = args[2].Direction.Magnitude
                        if mag < 1 then mag = 1000 end
                        args[2] = Ray.new(o, dirTo(o, pos, mag))
                        return oldNamecall(unpack(args))
                    end
                end
            end
        end
        return oldNamecall(unpack(args))
    end))
    SilentRay.hooked = true
    pcall(SilentRay.updateCache)
    return true
end
local function getPredictedPos(target)
    return SilentHB.predictPos(target)
end
local function startAimbotTracking()
    if rightMouseTracking then rightMouseTracking:Disconnect(); rightMouseTracking=nil end
    isTracking=true; currentTarget=getNearestTarget()
    SilentHB.refresh()
    if SilentRay and SilentRay.ensure then SilentRay.ensure() end
    rightMouseTracking=S.RunService.RenderStepped:Connect(function()
        if isUnloading or _G[MW_T.unloaded] or not Settings.Aimbot.Enabled or not isTracking then return end
        local cam=S.Workspace.CurrentCamera; if not cam then return end
        Settings.Aimbot.AimMode = "Camera"
        local mode = "Camera"
        if not SilentHB.passHitChance() then return end
        local needNew=false
        if not currentTarget or not hasWorldBody(currentTarget) then needNew=true
        else
            local rd=getRig(currentTarget)
            if not rd or not rd.isAlive() then needNew=true
            elseif Settings.Aimbot.RequireLOS and not hasLOS(player,currentTarget) then needNew=true
            elseif not Settings.Aimbot.StickyAim and not isInFOV(currentTarget,getAimFOVRadius()) then needNew=true
            end
        end
        if needNew then currentTarget=getNearestTarget() end
        if currentTarget and hasWorldBody(currentTarget) then
            local pos=getPredictedPos(currentTarget)
            if pos then
                local smooth = getAimSmoothness()
                local cp=cam.CFrame.Position; local desired=CFrame.lookAt(cp,pos)
                local pitch=math.asin(math.clamp(desired.LookVector.Y,-1,1)); local maxP=math.rad(80)
                if math.abs(pitch)<maxP then cam.CFrame=cam.CFrame:Lerp(desired,smooth)
                else local cp2=math.clamp(pitch,-maxP,maxP); local lv=desired.LookVector; local yaw=math.atan2(-lv.X,-lv.Z); local cf=CFrame.new(cp)*CFrame.Angles(0,yaw,0)*CFrame.Angles(cp2,0,0); cam.CFrame=cam.CFrame:Lerp(cf,smooth) end
            end
        end
    end)
end
local function stopAimbotTracking()
    isTracking=false
    currentTarget=nil
    if rightMouseTracking then rightMouseTracking:Disconnect(); rightMouseTracking=nil end
    SilentHB.refresh()
end
local function simulateFirePress()
    if typeof(mouse1pressFn) == "function" then mouse1pressFn(); return true end
    local ok, vim = pcall(function() return game:GetService("VirtualInputManager") end)
    if ok and vim and typeof(vim.SendMouseButtonEvent) == "function" then
        local cam = S.Workspace.CurrentCamera
        local sz = cam and cam.ViewportSize or Vector2.new(960, 540)
        local cx, cy = math.floor(sz.X / 2), math.floor(sz.Y / 2)
        pcall(function() vim:SendMouseButtonEvent(cx, cy, 0, true, game, 1) end)
        return true
    end
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    pcall(function() vu:Button1Down(Vector2.new(0, 0)) end)
    return true
end
local function simulateFireRelease()
    if typeof(mouse1releaseFn) == "function" then mouse1releaseFn(); return true end
    local ok, vim = pcall(function() return game:GetService("VirtualInputManager") end)
    if ok and vim and typeof(vim.SendMouseButtonEvent) == "function" then
        local cam = S.Workspace.CurrentCamera
        local sz = cam and cam.ViewportSize or Vector2.new(960, 540)
        local cx, cy = math.floor(sz.X / 2), math.floor(sz.Y / 2)
        pcall(function() vim:SendMouseButtonEvent(cx, cy, 0, false, game, 1) end)
        return true
    end
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    pcall(function() vu:Button1Up(Vector2.new(0, 0)) end)
    return true
end
local function simulateFireClick(holdTime)
    if typeof(mouse1clickFn) == "function" then mouse1clickFn(); return true end
    simulateFirePress()
    task.wait(holdTime or 0.04)
    simulateFireRelease()
    return true
end
local function getCharacterFromPart(part)
    if not part then return nil, nil end
    local current = part
    while current and current ~= S.Workspace do
        if current:IsA("Model") then
            local hum = current:FindFirstChildOfClass("Humanoid")
            if hum then return current, hum end
        end
        current = current.Parent
    end
    return nil, nil
end
local function isTriggerEnemy(attacker, target)
    if not target or target == attacker then return false end
    if MW.isArsenal and getArsenalFFA() then return true end
    local myTeam, theirTeam = getPlayerTeamId(attacker), getPlayerTeamId(target)
    if myTeam and theirTeam and myTeam ~= "" and theirTeam ~= "" then
        return myTeam ~= theirTeam
    end
    return isValidTarget(attacker, target)
end
local function isProtected(target)
    if not target then return true end
    local tc = target.Character
    if not tc then return true end
    local h = tc:FindFirstChildOfClass("Humanoid") or tc:FindFirstChild("Humanoid")
    if not h then return true end
    for _, c in ipairs(tc:GetChildren()) do
        if c:IsA("ForceField") then return true end
    end
    if h:FindFirstChild("ForceField") then return true end
    if h.MaxHealth >= 999999 then return true end
    return false
end
local Trigger = { pressing = false, lastFire = 0, burstBusy = false }
function Trigger.stopFire()
    if Trigger.pressing then
        Trigger.pressing = false
        pcall(simulateFireRelease)
    end
    Trigger.burstBusy = false
end
function Trigger.isADS()
    if not Settings.Combat.TriggerRequireADS then return true end
    if S.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return true end
    if isPlayerScoped() then return true end
    local char = player.Character
    if not char then return false end
    local names = {"Aiming", "ADS", "Scoped", "IsAiming", "Zooming"}
    for _, n in ipairs(names) do
        local v = char:FindFirstChild(n, true)
        if v and v:IsA("BoolValue") and v.Value then return true end
    end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        for _, n in ipairs(names) do
            local v = tool:FindFirstChild(n, true)
            if v and v:IsA("BoolValue") and v.Value then return true end
        end
    end
    return false
end
function Trigger.isBlacklisted()
    if TraceExpand and TraceExpand.WeaponFilter and TraceExpand.WeaponFilter.isDenied then
        if TraceExpand.WeaponFilter.isDenied() then return true end
    end
    local raw = tostring(Settings.Combat.TriggerWeaponBlacklist or "")
    if raw == "" then return false end
    local weapon = getPlayerWeaponName(player)
    if not weapon then return false end
    local wl = string.lower(weapon)
    for token in string.gmatch(raw, "[^,;]+") do
        local t = string.lower((token:gsub("^%s+", ""):gsub("%s+$", "")))
        if t ~= "" and (wl == t or string.find(wl, t, 1, true)) then
            return true
        end
    end
    return false
end
function Trigger.resolve()
    local myChar = player.Character
    if not myChar then return nil end
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not myHum or myHum.Health <= 0 then return nil end
    if guiMainFrame and guiMainFrame.Visible then return nil end
    if not Trigger.isADS() then return nil end
    if Trigger.isBlacklisted() then return nil end
    local function validate(part)
        if not part then return nil end
        local char, hum = getCharacterFromPart(part)
        if not char or char == myChar or not hum or hum.Health <= 0 then return nil end
        local targetPlayer = S.Players:GetPlayerFromCharacter(char)
        if not targetPlayer or not isTriggerEnemy(player, targetPlayer) then return nil end
        if isProtected(targetPlayer) then return nil end
        if Settings.Combat.TriggerHeadOnly then
            local head = char:FindFirstChild("Head")
            if head then
                local p, onHead = part, false
                while p and p ~= char do
                    if p == head then onHead = true; break end
                    p = p.Parent
                end
                if not onHead then return nil end
            end
        end
        if Settings.Combat.TriggerRequireLOS and not hasLOS(player, targetPlayer) then return nil end
        return targetPlayer
    end
    local mouse = player:GetMouse()
    local fromMouse = validate(mouse.Target)
    if fromMouse then return fromMouse end
    local cam = S.Workspace.CurrentCamera
    if not cam then return nil end
    local vp = cam.ViewportSize
    local ray = cam:ViewportPointToRay(vp.X / 2, vp.Y / 2)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {myChar}
    local result = S.Workspace:Raycast(ray.Origin, ray.Direction * 1500, params)
    if result then return validate(result.Instance) end
    return nil
end
function Trigger.run()
    if not Settings.Combat.TriggerBot or isUnloading or _G[MW_T.unloaded] then
        Trigger.stopFire()
        Trigger.lastFire = 0
        return
    end
    local targetPlayer = Trigger.resolve()
    local delay = (TraceCombatEx and TraceCombatEx.triggerDelay and TraceCombatEx.triggerDelay()) or math.max(0.03, Settings.Combat.TriggerDelay or 0.05)
    local burst = math.max(1, math.floor(Settings.Combat.TriggerBurstCount or 1))
    local gap = math.max(0.02, Settings.Combat.TriggerBurstGap or 0.06)
    local now = tick()
    if not targetPlayer then
        Trigger.stopFire()
        return
    end
    if burst <= 1 then
        if not Trigger.pressing then
            if now - Trigger.lastFire >= delay then
                Trigger.pressing = true
                Trigger.lastFire = now
                pcall(simulateFirePress)
            end
        elseif now - Trigger.lastFire >= delay then
            Trigger.lastFire = now
            pcall(simulateFirePress)
        end
        return
    end
    if Trigger.pressing then
        Trigger.pressing = false
        pcall(simulateFireRelease)
    end
    if Trigger.burstBusy then return end
    if now - Trigger.lastFire < delay then return end
    Trigger.burstBusy = true
    Trigger.lastFire = now
    task.spawn(function()
        for i = 1, burst do
            if isUnloading or _G[MW_T.unloaded] or not Settings.Combat.TriggerBot then break end
            if not Trigger.resolve() then break end
            pcall(simulateFireClick, 0.035)
            if i < burst then task.wait(gap) end
        end
        Trigger.burstBusy = false
    end)
end
local function getESPBoxStyle()
    local mode = Settings.ESP.BoxStyle
    if not mode or mode == "" then
        mode = Settings.ESP.BoxEnabled and "Both" or "Off"
    end
    return mode
end
local function destroyESPData(d)
    if not d then return end
    if d.billboard then pcall(function() d.billboard:Destroy() end) end
    if d.boxHighlight then pcall(function() d.boxHighlight:Destroy() end) end
    if d.glowHighlight then pcall(function() d.glowHighlight:Destroy() end) end
    if d.box3DOutline then pcall(function() d.box3DOutline:Destroy() end) end
    if d.box3D then pcall(function() d.box3D:Destroy() end) end
end
local function purgeWorldESP()
    for _, p in ipairs(S.Players:GetPlayers()) do
        local tc = p.Character
        if tc then
            for _, obj in ipairs(tc:GetDescendants()) do
                if MW_T.owned[obj.Name] then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end
end
local function clearAllESP()
    for uid, d in pairs(espObjects) do
        destroyESPData(d)
        espObjects[uid] = nil
    end
    espBoundsCache = {}
    espLosCache = {}
    purgeWorldESP()
    if overlayResetFn then pcall(overlayResetFn) end
    if destroyTargetHLFn then pcall(destroyTargetHLFn) end
end
local function getCharacter2DBounds(char, cam, useFast)
    if not char or not cam then return nil end
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local any = false
    local function addPoint(wp)
        local sp = cam:WorldToViewportPoint(wp)
        if sp.Z > 0 then
            any = true
            minX = math.min(minX, sp.X)
            maxX = math.max(maxX, sp.X)
            minY = math.min(minY, sp.Y)
            maxY = math.max(maxY, sp.Y)
        end
    end
    if useFast then
        local head = char:FindFirstChild("Head")
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        if head and head:IsA("BasePart") then
            addPoint(head.Position + Vector3.new(0, head.Size.Y * 0.55, 0))
            addPoint(head.Position - Vector3.new(0, head.Size.Y * 0.35, 0))
        end
        if hrp and hrp:IsA("BasePart") then
            addPoint(hrp.Position + Vector3.new(0, hrp.Size.Y * 0.55, 0))
            addPoint(hrp.Position - Vector3.new(0, hrp.Size.Y * 0.55, 0))
        end
    else
        for _, partName in ipairs(ESP_BOUNDS_PARTS) do
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                local cf, size = part.CFrame, part.Size
                local hx, hy = size.X * 0.5, size.Y * 0.5
                addPoint(cf:PointToWorldSpace(Vector3.new(0, hy, 0)))
                addPoint(cf:PointToWorldSpace(Vector3.new(0, -hy, 0)))
                addPoint(cf:PointToWorldSpace(Vector3.new(hx, 0, 0)))
                addPoint(cf:PointToWorldSpace(Vector3.new(-hx, 0, 0)))
            end
        end
    end
    if not any then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                local cf, size = part.CFrame, part.Size
                local hy = size.Y * 0.5
                addPoint(cf:PointToWorldSpace(Vector3.new(0, hy, 0)))
                addPoint(cf:PointToWorldSpace(Vector3.new(0, -hy, 0)))
            end
        end
    end
    if not any then
        local ok, bbCF, bbSize = pcall(function() return char:GetBoundingBox() end)
        if ok and bbCF and bbSize then
            addPoint(bbCF:PointToWorldSpace(Vector3.new(0, bbSize.Y * 0.5, 0)))
            addPoint(bbCF:PointToWorldSpace(Vector3.new(0, -bbSize.Y * 0.5, 0)))
        end
    end
    if minX == math.huge then return nil end
    local pad = useFast and 4 or 3
    return minX - pad, minY - pad, maxX + pad, maxY + pad
end
local function smoothESPBounds(uid, minX, minY, maxX, maxY)
    if UILib.espBoundsInstant() then
        espBoundsCache[uid] = {minX = minX, minY = minY, maxX = maxX, maxY = maxY}
        return minX, minY, maxX, maxY
    end
    local cached = espBoundsCache[uid]
    if not cached then
        espBoundsCache[uid] = {minX = minX, minY = minY, maxX = maxX, maxY = maxY}
        return minX, minY, maxX, maxY
    end
    local blend = 0.42
    cached.minX = cached.minX + (minX - cached.minX) * blend
    cached.minY = cached.minY + (minY - cached.minY) * blend
    cached.maxX = cached.maxX + (maxX - cached.maxX) * blend
    cached.maxY = cached.maxY + (maxY - cached.maxY) * blend
    return cached.minX, cached.minY, cached.maxX, cached.maxY
end
local function getBillboardStudsOffset(char, hrp)
    if not char or not hrp then return Vector3.new(0, 2.2, 0) end
    local yOff = (Settings.ESP.Offset or 0) * 0.1
    local ok, bbCF, bbSize = pcall(function() return char:GetBoundingBox() end)
    if ok and bbCF and bbSize then
        local topWorld = bbCF:PointToWorldSpace(Vector3.new(0, bbSize.Y * 0.5 + 0.35, 0))
        local localOffset = hrp.CFrame:PointToObjectSpace(topWorld)
        return Vector3.new(0, localOffset.Y + yOff, 0)
    end
    return Vector3.new(0, 2.2 + yOff, 0)
end
local function resolveEspModel(char)
    if typeof(char) == "Instance" then return char end
    if type(char) == "table" then
        local m = rawget(char, "_model")
        if typeof(m) == "Instance" then return m end
        local torso = rawget(char, "Torso") or rawget(char, "HumanoidRootPart") or rawget(char, "Head")
        if typeof(torso) == "Instance" then return torso.Parent end
    end
    return nil
end
local function updateBox3D(data, char, col)
    if not data or not char then return end
    local model = resolveEspModel(char) or char
    local hrp = (type(char) == "table" and (char.HumanoidRootPart or char.Torso or char.Head))
        or (char.FindFirstChild and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")))
        or (typeof(model) == "Instance" and model:FindFirstChildWhichIsA("BasePart"))
    if not hrp then return end
    if typeof(model) == "Instance" then char = model end
    if not data.box3D then
        data.box3D = Instance.new("BoxHandleAdornment")
        data.box3D.Name = MW_T.box3d
        data.box3D.AlwaysOnTop = true
        data.box3D.ZIndex = 5
    end
    if not data.box3DOutline then
        data.box3DOutline = Instance.new("Highlight")
        data.box3DOutline.Name = MW_T.box3dOutline
        data.box3DOutline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    local ok, bbCF, bbSize = pcall(function()
        return char:GetBoundingBox()
    end)
    if ok and bbCF and bbSize then
        data.box3D.Adornee = hrp
        data.box3D.CFrame = hrp.CFrame:ToObjectSpace(bbCF)
        data.box3D.Size = bbSize
    else
        data.box3D.Adornee = hrp
        data.box3D.CFrame = CFrame.new()
        data.box3D.Size = char:GetExtentsSize()
    end
    data.box3D.Color3 = col
    data.box3D.Transparency = 0.84
    data.box3D.Visible = true
    data.box3D.Parent = char
    data.box3DOutline.Adornee = char
    data.box3DOutline.Parent = char
    data.box3DOutline.FillTransparency = 1
    data.box3DOutline.OutlineTransparency = 0
    data.box3DOutline.OutlineColor = col
    data.box3DOutline.Enabled = true
end
local function hideBox3D(data)
    if data and data.box3D then
        data.box3D.Visible = false
        pcall(function() data.box3D.Parent = nil end)
    end
    if data and data.box3DOutline then
        data.box3DOutline.Enabled = false
        pcall(function() data.box3DOutline.Parent = nil end)
    end
end
local function applyESPPlayerVisuals(d, target, tc, hp, maxhp, dist, col, mode)
    mode = mode or "all"
    local fontSize = Settings.ESP.FontSize or 11
    local subSize = math.max(9, fontSize - 2)
    local textBg = Settings.ESP.TextBackground
    local compact = Settings.ESP.CompactLabels ~= false
    local fade = getESPLabelFade(dist)
    local strokeTr = compact and 0.42 or 0.22
    if mode == "labels" or mode == "all" then
        if d.nameLabel then
            local showName = Settings.ESP.NameEnabled and fade < 0.7
            d.nameLabel.Visible = showName
            if showName then
                d.nameLabel.TextSize = fontSize
                d.nameLabel.Text = truncateESPName(getDisplayName(target))
                d.nameLabel.TextColor3 = col
                d.nameLabel.TextTransparency = fade
                d.nameLabel.TextStrokeTransparency = math.clamp(strokeTr + fade * 0.35, 0, 1)
                if textBg then
                    d.nameLabel.BackgroundTransparency = 0.45 + fade * 0.3
                    d.nameLabel.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
                else
                    d.nameLabel.BackgroundTransparency = 1
                end
            end
        end
        if d.metaLabel then
            local metaText = buildESPMetaText(dist, hp, maxhp)
            local showMeta = metaText ~= "" and fade < 0.55
            d.metaLabel.Visible = showMeta
            if showMeta then
                d.metaLabel.TextSize = subSize
                d.metaLabel.Text = metaText
                local showHpInMeta = Settings.ESP.HealthEnabled == true
                d.metaLabel.TextColor3 = showHpInMeta and getHealthColor(hp / math.max(maxhp, 1)) or shiftColor(col, -0.04, -0.04, -0.03)
                d.metaLabel.TextTransparency = math.clamp(fade + 0.08, 0, 1)
                d.metaLabel.TextStrokeTransparency = math.clamp(strokeTr + 0.08 + fade * 0.35, 0, 1)
                if textBg then
                    d.metaLabel.BackgroundTransparency = 0.5 + fade * 0.3
                    d.metaLabel.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
                else
                    d.metaLabel.BackgroundTransparency = 1
                end
            end
        end
        if d.weaponLabel then
            local wpnMax = tonumber(Settings.ESP.WeaponLabelDistance) or 450
            local weaponName = (Settings.ESP.WeaponLabels and dist <= wpnMax) and getPlayerWeaponName(target) or nil
            local showWeapon = weaponName ~= nil and weaponName ~= "" and fade < 0.72
            d.weaponLabel.Visible = showWeapon
            if showWeapon then
                d.weaponLabel.TextSize = subSize
                d.weaponLabel.Text = weaponName
                d.weaponLabel.TextColor3 = Theme.TextAccent or col
                d.weaponLabel.TextTransparency = math.clamp(fade + 0.12, 0, 1)
                d.weaponLabel.TextStrokeTransparency = math.clamp(strokeTr + 0.1 + fade * 0.35, 0, 1)
                if textBg then
                    d.weaponLabel.BackgroundTransparency = 0.5 + fade * 0.3
                    d.weaponLabel.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
                else
                    d.weaponLabel.BackgroundTransparency = 1
                end
            end
        end
        if d.distLabel then d.distLabel.Visible = false end
        if d.healthLabel then d.healthLabel.Visible = false end
    end
    if mode == "chams" or mode == "all" then
        local chamsOn = Settings.ESP.ChamsEnabled and not VisPerf.lockChams
        local outlineOn = Settings.ESP.OutlineEnabled and not VisPerf.lockChams
        local glowOn = Settings.ESP.GlowEnabled and not VisPerf.lockGlow
        local wantHL = chamsOn or outlineOn or glowOn
        if wantHL and tc then
            local adornInst = resolveEspModel(tc) or (typeof(tc) == "Instance" and tc) or nil
            if adornInst then
            if not d.boxHighlight or not d.boxHighlight.Parent then
                if d.boxHighlight then pcall(function() d.boxHighlight:Destroy() end) end
                local hl = Instance.new("Highlight")
                hl.Name = MW_T.box
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = player:FindFirstChild("PlayerGui") or adornInst
                d.boxHighlight = hl
            end
            local hl = d.boxHighlight
            hl.Adornee = adornInst
            local fillT = 1
            if chamsOn then
                fillT = math.clamp(tonumber(Settings.ESP.ChamsFillTransparency) or 0.62, 0.4, 0.85)
            elseif glowOn then
                fillT = math.clamp(tonumber(Settings.ESP.GlowTransparency) or 0.72, 0.55, 0.9)
            end
            local outlineT = 1
            if outlineOn or chamsOn then
                outlineT = outlineOn and 0.05 or 0.22
            elseif glowOn then
                outlineT = 0.35
            end
            local fillCol = col
            if glowOn and not chamsOn then
                fillCol = shiftColor(col, 0.15, 0.15, 0.18)
            end
            local outlineCol = (Settings.ESP.RainbowOutline and Color3.fromHSV((tick() % 5) / 5, 0.85, 1))
                or (Settings.ESP.OutlineColor)
                or Color3.fromRGB(245, 246, 250)
            hl.FillColor = fillCol
            hl.FillTransparency = fillT
            hl.OutlineColor = outlineCol
            hl.OutlineTransparency = outlineT
            hl.Enabled = true
            end
        elseif d.boxHighlight then
            d.boxHighlight.Enabled = false
            pcall(function() d.boxHighlight.Adornee = nil end)
        end

        if d.glowHighlight then
            pcall(function() d.glowHighlight:Destroy() end)
            d.glowHighlight = nil
        end
    end
end
local function hideESPVisuals(d)
    if not d then return end
    if d.billboard then d.billboard.Enabled = false end
    if d.boxHighlight then d.boxHighlight.Enabled = false; pcall(function() d.boxHighlight.Parent = nil end) end
    if d.glowHighlight then d.glowHighlight.Enabled = false; pcall(function() d.glowHighlight.Parent = nil end) end
    hideBox3D(d)
end
local function createESP(target)
    if espObjects[target.UserId] then return end
    if target == player and not Settings.ESP.SelfESP then return end
    local fontSize = Settings.ESP.FontSize or 11
    local subSize = math.max(9, fontSize - 2)
    local data = {}
    local bbH = fontSize + subSize + 8
    if Settings.ESP.WeaponLabels then bbH = bbH + subSize + 2 end
    local bb = Instance.new("BillboardGui")
    bb.Name = MW_T.esp
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 150, 0, bbH)
    bb.StudsOffset = Vector3.new(0, 2.15, 0)
    bb.LightInfluence = 0
    bb.MaxDistance = Settings.ESP.RenderDistance or 8000
    bb.ResetOnSpawn = false
    bb.ClipsDescendants = false
    local nl = UILib.newLabel(bb, {
        Name = MW_T.next(6),
        Size = UDim2.new(1, 0, 0, fontSize + 2),
        Position = UDim2.new(0, 0, 0, 0),
        Text = target.Name,
        TextColor3 = Color3.fromRGB(245, 246, 250),
        TextStrokeTransparency = 0.25,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = fontSize,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    local ml = UILib.newLabel(bb, {
        Name = MW_T.next(6),
        Size = UDim2.new(1, 0, 0, subSize + 2),
        Position = UDim2.new(0, 0, 0, fontSize + 2),
        Text = "0m",
        TextColor3 = Theme.ESP_Far,
        TextStrokeTransparency = 0.5,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = subSize,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    local wl = UILib.newLabel(bb, {
        Name = MW_T.next(6),
        Size = UDim2.new(1, 0, 0, subSize + 2),
        Position = UDim2.new(0, 0, 0, fontSize + subSize + 4),
        Text = "",
        TextColor3 = Theme.TextAccent,
        TextStrokeTransparency = 0.5,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = subSize,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false,
    })
    data.billboard = bb
    data.nameLabel = nl
    data.metaLabel = ml
    data.weaponLabel = wl
    data.distLabel = nil
    data.healthLabel = nil
    data.lastLabelAt = 0
    data.lastOffsetAt = 0
    data.lastName = ""
    data.lastMeta = ""
    data.lastWeapon = ""
    if espBillboardLayer then
        bb.Parent = espBillboardLayer
    end
    espObjects[target.UserId] = data
end
local function removeESP(target)
    local d = espObjects[target.UserId]
    if d then destroyESPData(d); espObjects[target.UserId] = nil end
    espBoundsCache[target.UserId] = nil
    espLosCache[target.UserId] = nil
end
local thumbCache = {}
local function getPlayerThumb(userId)
    if thumbCache[userId] and thumbCache[userId] ~= "" then return thumbCache[userId] end
    if not thumbCache[userId] then
        thumbCache[userId] = ""
        task.spawn(function()
            local ok, content = pcall(function()
                return S.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if ok and content and content ~= "" then thumbCache[userId] = content end
        end)
    end
    return thumbCache[userId]
end
local origFog=nil
local function enableNoFog()
    if not origFog then origFog={FogStart=S.Lighting.FogStart,FogEnd=S.Lighting.FogEnd,FogColor=S.Lighting.FogColor,Atm={}}; for _,e in ipairs(S.Lighting:GetChildren()) do if e:IsA("Atmosphere") then table.insert(origFog.Atm,{inst=e,Density=e.Density,Offset=e.Offset,Color=e.Color,Decay=e.Decay,Glare=e.Glare,Haze=e.Haze}) end end end
    S.Lighting.FogStart=100000; S.Lighting.FogEnd=100000; for _,e in ipairs(S.Lighting:GetChildren()) do if e:IsA("Atmosphere") then e.Density=0; e.Offset=0; e.Haze=0; e.Glare=0 end end
end
local function disableNoFog()
    if origFog then S.Lighting.FogStart=origFog.FogStart; S.Lighting.FogEnd=origFog.FogEnd; S.Lighting.FogColor=origFog.FogColor; for _,d in ipairs(origFog.Atm) do if d.inst and d.inst.Parent then d.inst.Density=d.Density; d.inst.Offset=d.Offset; d.inst.Color=d.Color; d.inst.Decay=d.Decay; d.inst.Glare=d.Glare; d.inst.Haze=d.Haze end end end
end
local origLighting = nil
local function captureOrigLighting()
    if not origLighting then
        origLighting = {Brightness=S.Lighting.Brightness, ClockTime=S.Lighting.ClockTime, ExposureCompensation=S.Lighting.ExposureCompensation}
    end
end
local function applyWorldLighting()
    captureOrigLighting()
    if Settings.Visuals.CustomBrightness then S.Lighting.Brightness = Settings.Visuals.Brightness
    elseif origLighting then S.Lighting.Brightness = origLighting.Brightness end
    if Settings.Visuals.CustomTime then S.Lighting.ClockTime = Settings.Visuals.ClockTime
    elseif origLighting then S.Lighting.ClockTime = origLighting.ClockTime end
    if Settings.Visuals.CustomExposure then S.Lighting.ExposureCompensation = Settings.Visuals.Exposure
    elseif origLighting then S.Lighting.ExposureCompensation = origLighting.ExposureCompensation end
end
local function restoreWorldLighting()
    if origLighting then
        S.Lighting.Brightness = origLighting.Brightness
        S.Lighting.ClockTime = origLighting.ClockTime
        S.Lighting.ExposureCompensation = origLighting.ExposureCompensation
    end
end
local gunOrig={FireRate={},ReloadTime={},EReloadTime={},Auto={},Spread={},Recoil={},Penetration={}}
local weaponCache={}; local weaponCacheBuilt=false
WB = {
    hooked = false,
    bypass = false,
    queryOrig = {},
    mapConns = {},
    names = {
        Penetration=true, Pierce=true, Piercing=true, WallPenetration=true,
        BulletPenetration=true, Pen=true, PenPower=true, CanPenetrate=true,
        Wallbang=true, WallBang=true,
    },
}
WB.paths = { weapons=nil, events=nil, playersFolder=nil, lastScan=0 }
WB.status = { weapons="pending", hooks="pending", lastMsg="" }
WB._weaponDescConn = nil
WB._lastReport = {}
function WB.report(feature, ok, msg)
    local key = tostring(feature or "")
    local state = ok and "ok" or "fail"
    local stamp = state .. "|" .. tostring(msg or "")
    if WB._lastReport[key] == stamp then return end
    WB._lastReport[key] = stamp
    if key == "Weapons" then WB.status.weapons = ok and "ok" or "missing"
    elseif key == "Hooks" then WB.status.hooks = ok and (msg == "map-only" and "map-only" or "ok") or "failed"
    end
    WB.status.lastMsg = tostring(msg or "")
    sendNotification(key, tostring(msg or (ok and "ok" or "failed")), 2.5)
end
function WB.scanPaths()
    local rs = game:GetService("ReplicatedStorage")
    WB.paths.lastScan = tick()
    local folderHints = {
        weapons = true, gundata = true, weapondata = true, guns = true,
        items = true, toolstorage = true, gunstorage = true, inventory = true,
        modules = true, remotes = true, events = true,
    }
    local valueHints = {
        reloadtime = true, ereloadtime = true, firerate = true, bfirerate = true,
        maxspread = true, spread = true, spreadcontrol = true, recoil = true,
        recoilcontrol = true, auto = true, autofire = true, automatic = true,
        autoshoot = true, autogun = true, penetration = true, pierce = true,
        piercing = true, ammo = true, ammocount = true, clipsize = true,
        magazinesize = true, damage = true, range = true,
    }
    local function scoreContainer(folder)
        if not folder then return 0 end
        local score = 0
        local ln = string.lower(folder.Name)
        if folderHints[ln] then score = score + 40 end
        if ln:find("weapon", 1, true) or ln:find("gun", 1, true) then score = score + 25 end
        if ln:find("item", 1, true) or ln:find("tool", 1, true) then score = score + 10 end
        local checked = 0
        local ok, descendants = pcall(function() return folder:GetDescendants() end)
        if ok and type(descendants) == "table" then
            for _, d in ipairs(descendants) do
                checked = checked + 1
                if checked > 500 then break end
                if d:IsA("ValueBase") and valueHints[string.lower(d.Name)] then
                    score = score + 3
                elseif d:IsA("Tool") then
                    score = score + 2
                end
            end
        end
        return score
    end
    local roots = { rs }
    pcall(function()
        table.insert(roots, game:GetService("ReplicatedFirst"))
    end)
    pcall(function()
        table.insert(roots, game:GetService("StarterPack"))
    end)
    pcall(function()
        table.insert(roots, game:GetService("StarterGui"))
    end)

    pcall(function()
        for _, name in ipairs({ "Weapons", "Guns", "Items", "Tools", "Ignore", "Ignored" }) do
            local f = S.Workspace:FindFirstChild(name)
            if f then table.insert(roots, f) end
        end
    end)
    local found, bestScore = nil, 0
    for _, root in ipairs(roots) do
        local childrenOk, children = pcall(function() return root:GetChildren() end)
        if childrenOk and type(children) == "table" then
            for _, ch in ipairs(children) do
                local s = scoreContainer(ch)
                if s > bestScore then bestScore = s; found = ch end
                local nestedOk, nested = pcall(function() return ch:GetChildren() end)
                if nestedOk and type(nested) == "table" then
                    for _, n in ipairs(nested) do
                        if n:IsA("Folder") or n:IsA("Configuration") or n:IsA("ModuleScript") or n:IsA("Model") then
                            local s2 = scoreContainer(n)
                            if s2 > bestScore then bestScore = s2; found = n end
                        end
                    end
                end
            end
        end
    end
    WB.paths.weapons = found
    local ev = rs:FindFirstChild("Events") or rs:FindFirstChild("events")
        or rs:FindFirstChild("Remotes") or rs:FindFirstChild("remotes")
    WB.paths.events = ev
    local pf = rs:FindFirstChild("Players") or rs:FindFirstChild("players")
        or rs:FindFirstChild("PlayerData") or rs:FindFirstChild("playerdata")
    WB.paths.playersFolder = pf

    WB.paths.map = S.Workspace:FindFirstChild("Map")
        or S.Workspace:FindFirstChild("map")
        or S.Workspace:FindFirstChild("Arena")
        or S.Workspace:FindFirstChild("World")
    WB.paths.ignore = S.Workspace:FindFirstChild("Ignore")
        or S.Workspace:FindFirstChild("Ignored")
        or S.Workspace:FindFirstChild("Debris")
        or S.Workspace:FindFirstChild("Effects")
    WB.paths.characters = {}
    for _, plr in ipairs(S.Players:GetPlayers()) do
        if plr.Character then
            table.insert(WB.paths.characters, plr.Character)
        end
    end
    WB.paths.tools = {}
    for _, plr in ipairs(S.Players:GetPlayers()) do
        local char = plr.Character
        if char then
            for _, ch in ipairs(char:GetChildren()) do
                if ch:IsA("Tool") then table.insert(WB.paths.tools, ch) end
            end
        end
        local backpack = plr:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, ch in ipairs(backpack:GetChildren()) do
                if ch:IsA("Tool") then table.insert(WB.paths.tools, ch) end
            end
        end
    end
    return found
end
function WB.resolveWeapons()
    if WB.paths.weapons and WB.paths.weapons.Parent then return WB.paths.weapons end
    return WB.scanPaths()
end
function WB.wrap(fn)
    if type(newcclosure) == "function" then
        local ok, wrapped = pcall(newcclosure, fn)
        if ok and type(wrapped) == "function" then return wrapped end
    end
    return fn
end
function WB.collectIgnore(base)
    local list = {}
    local seen = {}
    local function add(inst)
        if inst and not seen[inst] then
            seen[inst] = true
            table.insert(list, inst)
        end
    end
    if typeof(base) == "table" then
        for i = 1, #base do add(base[i]) end
        for _, v in pairs(base) do
            if typeof(v) == "Instance" then add(v) end
        end
    elseif typeof(base) == "Instance" then
        add(base)
    end
    for _, name in ipairs({
        "Map", "map", "Arena", "World", "Clips", "Spawns", "Debris",
        "RandomWeaponSpawns", "Ignored", "Ignore", "Effects", "FX",
        "Bullets", "Projectiles", "Thrown", "Vehicles", "Cars",
    }) do
        add(S.Workspace:FindFirstChild(name))
    end
    if WB.paths and WB.paths.map then add(WB.paths.map) end
    if WB.paths and WB.paths.ignore then add(WB.paths.ignore) end
    add(S.Workspace.Terrain)
    add(S.Workspace.CurrentCamera)
    local lpChar = player.Character
    if lpChar then add(lpChar) end
    for _, plr in ipairs(S.Players:GetPlayers()) do
        if plr ~= player and plr.Character then add(plr.Character) end
    end
    return list
end
function WB.setPartQuery(part, penetrate)
    if not part or not part:IsA("BasePart") then return end
    if penetrate then
        if WB.queryOrig[part] == nil then
            WB.queryOrig[part] = {
                CanQuery = part.CanQuery,
                CanCollide = part.CanCollide,
            }
        end
        pcall(function()
            part.CanQuery = false

            local clips = S.Workspace:FindFirstChild("Clips")
            if clips and part:IsDescendantOf(clips) then
                part.CanCollide = false
            end
        end)
    else
        local o = WB.queryOrig[part]
        if o then
            pcall(function()
                if part.Parent then
                    part.CanQuery = o.CanQuery
                    if o.CanCollide ~= nil then part.CanCollide = o.CanCollide end
                end
            end)
            WB.queryOrig[part] = nil
        end
    end
end
function WB.applyFolderQuery(folder, penetrate)
    if not folder then return end
    for _, d in ipairs(folder:GetDescendants()) do
        WB.setPartQuery(d, penetrate)
    end
end
function WB.clearMapQuery()
    for part in pairs(WB.queryOrig) do
        WB.setPartQuery(part, false)
    end
    WB.queryOrig = {}
    for i = 1, #WB.mapConns do
        pcall(function() WB.mapConns[i]:Disconnect() end)
    end
    WB.mapConns = {}
end
function WB.refreshMapQuery()
    WB.clearMapQuery()
    if not Settings.Combat.WallBang then return end
    local map = S.Workspace:FindFirstChild("Map")
    local clips = S.Workspace:FindFirstChild("Clips")
    WB.applyFolderQuery(map, true)
    WB.applyFolderQuery(clips, true)
    local function watch(folder)
        if not folder then return end
        table.insert(WB.mapConns, folder.DescendantAdded:Connect(function(d)
            if Settings.Combat.WallBang then WB.setPartQuery(d, true) end
        end))
    end
    watch(map)
    watch(clips)
    table.insert(WB.mapConns, S.Workspace.ChildAdded:Connect(function(ch)
        if not Settings.Combat.WallBang then return end
        if ch.Name == "Map" or ch.Name == "Clips" then
            task.defer(function()
                if Settings.Combat.WallBang then WB.refreshMapQuery() end
            end)
        end
    end))
end
local function applyGunMod(v)
    if MW.gunModsInTesting then return end
    if not Cap.ok("gunmods") then return end
    if not v or not v.Parent then return end
    local n = v.Name
    if Settings.Combat.FastReload and (n=="ReloadTime" or n=="EReloadTime") then local k=n=="ReloadTime" and "ReloadTime" or "EReloadTime"; if not gunOrig[k][v] then gunOrig[k][v]=v.Value end; v.Value=0.01 end
    if Settings.Combat.FastFireRate and (n=="FireRate" or n=="BFireRate") then if not gunOrig.FireRate[v] then gunOrig.FireRate[v]=v.Value end; v.Value=0.02 end
    if Settings.Combat.AlwaysAuto and (n=="Auto" or n=="AutoFire" or n=="Automatic" or n=="AutoShoot" or n=="AutoGun") then if not gunOrig.Auto[v] then gunOrig.Auto[v]=v.Value end; v.Value=true end
    if Settings.Combat.NoSpread and (n=="MaxSpread" or n=="Spread" or n=="SpreadControl") then if not gunOrig.Spread[v] then gunOrig.Spread[v]=v.Value end; v.Value=0 end
    if Settings.Combat.NoRecoil and (n=="RecoilControl" or n=="Recoil") then if not gunOrig.Recoil[v] then gunOrig.Recoil[v]=v.Value end; v.Value=0 end
end
local function buildWeaponCache()
    weaponCache={}
    local wp=WB.resolveWeapons()
    if not wp then

        local valueNames = {
            ReloadTime=true, EReloadTime=true, FireRate=true, BFireRate=true,
            Auto=true, AutoFire=true, Automatic=true, AutoShoot=true, AutoGun=true,
            MaxSpread=true, Spread=true, SpreadControl=true, RecoilControl=true, Recoil=true,
            Ammo=true, AmmoCount=true, ClipSize=true, MagazineSize=true,
        }
        for _, plr in ipairs(S.Players:GetPlayers()) do
            local bags = {}
            if plr.Character then table.insert(bags, plr.Character) end
            local bp = plr:FindFirstChildOfClass("Backpack")
            if bp then table.insert(bags, bp) end
            for _, bag in ipairs(bags) do
                local okBag, bagDesc = pcall(function() return bag:GetDescendants() end)
                if okBag and type(bagDesc) == "table" then
                    for _, d in ipairs(bagDesc) do
                        if d:IsA("ValueBase") and (valueNames[d.Name] or WB.names[d.Name]) then
                            table.insert(weaponCache, d)
                        end
                    end
                end
            end
        end
        weaponCacheBuilt = #weaponCache > 0
        WB.report("Weapons", weaponCacheBuilt, weaponCacheBuilt and "scanned tools/backpack" or "folder missing: gun mods offline")
        return
    end
    local okDesc, descendants = pcall(function() return wp:GetDescendants() end)
    if not okDesc or type(descendants) ~= "table" then
        WB.report("Weapons", false, "descendants failed")
        return
    end
    for _,v in pairs(descendants) do
        if v:IsA("ValueBase") then
            local n=v.Name
            if n=="ReloadTime" or n=="EReloadTime" or n=="FireRate" or n=="BFireRate"
                or n=="Auto" or n=="AutoFire" or n=="Automatic" or n=="AutoShoot" or n=="AutoGun"
                or n=="MaxSpread" or n=="Spread" or n=="SpreadControl" or n=="RecoilControl" or n=="Recoil"
                or n=="Ammo" or n=="AmmoCount" or n=="ClipSize" or n=="MagazineSize"
                or WB.names[n] then
                table.insert(weaponCache,v)
            end
        end
    end
    weaponCacheBuilt=true
    WB.report("Weapons", true, "resolved")
    if WB._weaponDescConn then pcall(function() WB._weaponDescConn:Disconnect() end); WB._weaponDescConn=nil end
    WB._weaponDescConn = wp.DescendantAdded:Connect(function(v)
        if v:IsA("ValueBase") then table.insert(weaponCache,v); applyGunMod(v) end
    end)
end
pcall(function()
    local wp = WB.resolveWeapons()
    if wp then
        if WB._weaponDescConn then pcall(function() WB._weaponDescConn:Disconnect() end) end
        WB._weaponDescConn = wp.DescendantAdded:Connect(function(v)
            if v:IsA("ValueBase") then table.insert(weaponCache,v); applyGunMod(v) end
        end)
    end
end)
local AcsGuns
AcsGuns = {
    orig = {},
    gcCache = {},
    gcAt = 0,
}
do
    local function isAcsTable(item)
        if type(item) ~= "table" then return false end
        return rawget(item, "ShootRate") ~= nil and rawget(item, "Ammo") ~= nil and rawget(item, "MinSpread") ~= nil
    end
    local function equippedToolNames()
        local names = {}
        local char = player.Character
        if char then
            for _, ch in ipairs(char:GetChildren()) do
                if ch:IsA("Tool") then names[ch.Name] = true end
            end
        end
        local bp = player:FindFirstChildOfClass("Backpack")
        if bp then
            for _, ch in ipairs(bp:GetChildren()) do
                if ch:IsA("Tool") then names[ch.Name] = true end
            end
        end
        return names
    end
    local function remember(item)
        if not item or AcsGuns.orig[item] then return end
        local snap = {
            ShootRate = item.ShootRate,
            MinSpread = item.MinSpread,
            MaxSpread = item.MaxSpread,
            AimInaccuracyStepAmount = item.AimInaccuracyStepAmount,
            MinRecoilPower = item.MinRecoilPower,
            MaxRecoilPower = item.MaxRecoilPower,
            RecoilPowerStepAmount = item.RecoilPowerStepAmount,
            AmmoInGun = item.AmmoInGun,
            MaxStoredAmmo = item.MaxStoredAmmo,
            Ammo = item.Ammo,
        }
        if type(item.camRecoil) == "table" then
            snap.camRecoil = {}
            for k, v in pairs(item.camRecoil) do
                if type(v) == "table" then snap.camRecoil[k] = {v[1], v[2]} end
            end
        end
        if type(item.gunRecoil) == "table" then
            snap.gunRecoil = {}
            for k, v in pairs(item.gunRecoil) do
                if type(v) == "table" then snap.gunRecoil[k] = {v[1], v[2]} end
            end
        end
        AcsGuns.orig[item] = snap
    end
    local function applyOne(item)
        if not item then return end
        remember(item)
        local snap = AcsGuns.orig[item]
        if Settings.Combat.NoSpread then
            item.MinSpread = 0
            item.MaxSpread = 0
            if item.AimInaccuracyStepAmount ~= nil then item.AimInaccuracyStepAmount = 0 end
        elseif snap then
            item.MinSpread = snap.MinSpread
            item.MaxSpread = snap.MaxSpread
            if snap.AimInaccuracyStepAmount ~= nil then item.AimInaccuracyStepAmount = snap.AimInaccuracyStepAmount end
        end
        if Settings.Combat.NoRecoil then
            item.MinRecoilPower = 0
            item.MaxRecoilPower = 0
            if item.RecoilPowerStepAmount ~= nil then item.RecoilPowerStepAmount = 0 end
            if type(item.camRecoil) == "table" then
                for k, v in pairs(item.camRecoil) do
                    if type(v) == "table" then item.camRecoil[k] = {0, 0} end
                end
            end
            if type(item.gunRecoil) == "table" then
                for k, v in pairs(item.gunRecoil) do
                    if type(v) == "table" then item.gunRecoil[k] = {0, 0} end
                end
            end
        elseif snap then
            item.MinRecoilPower = snap.MinRecoilPower
            item.MaxRecoilPower = snap.MaxRecoilPower
            if snap.RecoilPowerStepAmount ~= nil then item.RecoilPowerStepAmount = snap.RecoilPowerStepAmount end
            if snap.camRecoil and type(item.camRecoil) == "table" then
                for k, v in pairs(snap.camRecoil) do item.camRecoil[k] = {v[1], v[2]} end
            end
            if snap.gunRecoil and type(item.gunRecoil) == "table" then
                for k, v in pairs(snap.gunRecoil) do item.gunRecoil[k] = {v[1], v[2]} end
            end
        end
        if Settings.Combat.FastFireRate then
            local base = tonumber(snap and snap.ShootRate) or tonumber(item.ShootRate) or 600
            item.ShootRate = math.max(base * 1.35, base + 80)
        elseif snap and snap.ShootRate ~= nil then
            item.ShootRate = snap.ShootRate
        end
        if Settings.Combat.AlwaysAuto then
            if item.Mode ~= nil then item.Mode = "Auto" end
            if item.FireMode ~= nil then item.FireMode = "Auto" end
            if item.Automatic ~= nil then item.Automatic = true end
        end
        if Settings.Combat.InfiniteAmmo then
            local mag = tonumber(snap and snap.AmmoInGun) or tonumber(item.AmmoInGun) or tonumber(item.Ammo) or 30
            local stored = tonumber(snap and snap.MaxStoredAmmo) or tonumber(item.MaxStoredAmmo) or mag * 4
            item.Ammo = mag
            if item.AmmoInGun ~= nil then item.AmmoInGun = mag end
            if item.StoredAmmo ~= nil then item.StoredAmmo = math.min(stored, mag * 6) end
        end
    end
    local function collect()
        local tools = equippedToolNames()
        local out, seen = {}, {}
        local function add(item)
            if not item or seen[item] or not isAcsTable(item) then return end
            local gn = rawget(item, "gunName")
            if type(gn) == "string" and next(tools) ~= nil and not tools[gn] then return end
            seen[item] = true
            table.insert(out, item)
        end
        local now = tick()
        if getgc and (now - AcsGuns.gcAt) >= 2.5 then
            AcsGuns.gcAt = now
            AcsGuns.gcCache = {}
            local ok, list = pcall(function() return getgc(true) end)
            if ok and type(list) == "table" then
                for _, item in ipairs(list) do
                    if isAcsTable(item) then table.insert(AcsGuns.gcCache, item) end
                end
            end
        end
        for _, item in ipairs(AcsGuns.gcCache) do add(item) end
        return out
    end
    function AcsGuns.patch()
        if MW.gunModsInTesting then return end
        if not Cap.ok("gunmods") then return end
        local any = Settings.Combat.NoRecoil or Settings.Combat.NoSpread
            or Settings.Combat.FastFireRate or Settings.Combat.AlwaysAuto or Settings.Combat.InfiniteAmmo
        if not any then return end
        for _, item in ipairs(collect()) do
            pcall(applyOne, item)
        end
    end
    function AcsGuns.maintainAmmo()
        if MW.gunModsInTesting then return end
        if not Cap.ok("gunmods") or not Settings.Combat.InfiniteAmmo then return end
        for _, item in ipairs(collect()) do
            pcall(function()
                remember(item)
                local snap = AcsGuns.orig[item]
                local mag = tonumber(snap and snap.AmmoInGun) or tonumber(item.AmmoInGun) or tonumber(item.Ammo) or 30
                local stored = tonumber(snap and snap.MaxStoredAmmo) or tonumber(item.MaxStoredAmmo) or mag * 4
                item.Ammo = mag
                if item.AmmoInGun ~= nil then item.AmmoInGun = mag end
                if item.StoredAmmo ~= nil then item.StoredAmmo = math.min(stored, mag * 6) end
            end)
        end
    end
end
function UILib.mountGunModsTestingOverlay()
    if not MW.gunModsInTesting then return nil end
    if UILib._gunModsTestGui and UILib._gunModsTestGui.Parent then
        return UILib._gunModsTestGui
    end
    local pg = player:FindFirstChildOfClass("PlayerGui")
    if not pg then return nil end
    local sg = Instance.new("ScreenGui")
    sg.Name = MW_T.gui .. "_GunModsTest"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 80
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(sg)
        elseif protectgui then protectgui(sg) end
    end)
    sg.Parent = (gethui and gethui()) or pg
    local badge = Instance.new("Frame")
    badge.Name = "Badge"
    badge.AnchorPoint = Vector2.new(0.5, 0)
    badge.Position = UDim2.new(0.5, 0, 0, 12)
    badge.Size = UDim2.fromOffset(220, 34)
    badge.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    badge.BackgroundTransparency = 0.12
    badge.BorderSizePixel = 0
    badge.Parent = sg
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(220, 170, 60)
    stroke.Thickness = 1
    stroke.Parent = badge
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(220, 170, 60)
    bar.BorderSizePixel = 0
    bar.Parent = badge
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(14, 0)
    title.Size = UDim2.new(1, -18, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(245, 245, 245)
    title.Text = "GUN MODS  ·  IN TESTING"
    title.Parent = badge
    UILib._gunModsTestGui = sg
    table.insert(allConnections, sg.Destroying:Connect(function()
        if UILib._gunModsTestGui == sg then UILib._gunModsTestGui = nil end
    end))
    return sg
end
local function applyAllGunMods()
    if MW.gunModsInTesting then return end
    if not Cap.ok("gunmods") then return end
    if not weaponCacheBuilt then buildWeaponCache() end
    for _,v in ipairs(weaponCache) do if v and v.Parent then applyGunMod(v) end end
    if MW.isMiscGunTest and AcsGuns and AcsGuns.patch then
        pcall(AcsGuns.patch)
    end
end
local function restoreGunMod(cat)
    for obj, val in pairs(gunOrig[cat]) do
        pcall(function() if obj and obj.Parent then obj.Value = val end end)
    end
    gunOrig[cat] = {}
end
function WB.ensureHook()
    WB.status.hooks = "removed"
    return false
end
function WB.setEnabled(_on)
    Settings.Combat.WallBang = false
    pcall(function() restoreGunMod("Penetration") end)
    pcall(function() WB.clearMapQuery() end)
    return false
end
local infiniteAmmoCurseOwned = false
local function applyInfiniteAmmo()
    if MW.gunModsInTesting then return end
    if not Cap.ok("gunmods") then return end
    if not Settings.Combat.InfiniteAmmo or isUnloading or _G[MW_T.unloaded] then return end
    if MW.isMiscGunTest and AcsGuns and AcsGuns.maintainAmmo then
        pcall(AcsGuns.maintainAmmo)
    end
    pcall(function()
        local gui = player:FindFirstChild("PlayerGui")
        if gui then
            local a1 = gui:FindFirstChild("ammocount", true)
            local a2 = gui:FindFirstChild("ammocount2", true)
            if a1 and (a1:IsA("IntValue") or a1:IsA("NumberValue")) then a1.Value = 99 end
            if a2 and (a2:IsA("IntValue") or a2:IsA("NumberValue")) then a2.Value = 99 end
        end
        local wk = game:GetService("ReplicatedStorage"):FindFirstChild("wkspc")
        local curse = wk and wk:FindFirstChild("CurrentCurse")
        if curse and curse:IsA("StringValue") then
            if curse.Value ~= "Infinite Ammo" then curse.Value = "Infinite Ammo" end
            infiniteAmmoCurseOwned = true
        end
    end)
end
local function stopInfiniteAmmo()
    pcall(function()
        if not infiniteAmmoCurseOwned then return end
        local wk = game:GetService("ReplicatedStorage"):FindFirstChild("wkspc")
        local curse = wk and wk:FindFirstChild("CurrentCurse")
        if curse and curse:IsA("StringValue") and curse.Value == "Infinite Ammo" then
            curse.Value = ""
        end
        infiniteAmmoCurseOwned = false
    end)
end
local function startFly()
    if MW.allows("fly") == false then
        Settings.Movement.Fly = false
        pcall(function() if sendNotification then sendNotification("Fly", "Blocked on this game", 2) end end)
        return
    end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    isFlying = true
    if flyBodyVelocity then pcall(function() flyBodyVelocity:Destroy() end); flyBodyVelocity = nil end
    if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end); flyBodyGyro = nil end
    if flyRenderConn then flyRenderConn:Disconnect(); flyRenderConn = nil end
    local method = Settings.Movement.FlyMethod or "CFrame"
    if method == "BodyMovers" then
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Name = MW_T.flyVel
        flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flyBodyVelocity.Velocity = Vector3.zero
        flyBodyVelocity.Parent = hrp
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.Name = MW_T.flyGyr
        flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        flyBodyGyro.P = 10000
        flyBodyGyro.Parent = hrp
    end
    flyRenderConn = S.RunService.RenderStepped:Connect(function(dt)
        if isUnloading or _G[MW_T.unloaded] or not Settings.Movement.Fly or not isFlying then return end
        local c = player.Character
        if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChildOfClass("Humanoid")
        if not root or not h then return end
        local cam = S.Workspace.CurrentCamera
        if not cam then return end
        local spd = Settings.Movement.FlySpeed or 50
        local mode = Settings.Movement.FlyMethod or "CFrame"
        local dir = Vector3.new(0, 0, 0)
        local uis = S.UserInputService
        if uis:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        if dir.Magnitude > 0 then dir = dir.Unit end
        if mode == "Velocity" then
            h.PlatformStand = false
            root.AssemblyLinearVelocity = dir * spd
            root.AssemblyAngularVelocity = Vector3.zero
        elseif mode == "BodyMovers" then
            h.PlatformStand = true
            if not flyBodyVelocity or not flyBodyVelocity.Parent then
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.Name = MW_T.flyVel
                flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                flyBodyVelocity.Parent = root
            end
            if not flyBodyGyro or not flyBodyGyro.Parent then
                flyBodyGyro = Instance.new("BodyGyro")
                flyBodyGyro.Name = MW_T.flyGyr
                flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                flyBodyGyro.P = 10000
                flyBodyGyro.Parent = root
            end
            flyBodyVelocity.Velocity = dir * spd
            flyBodyGyro.CFrame = cam.CFrame
        else
            h.PlatformStand = true
            if dir.Magnitude > 0 then
                root.CFrame = root.CFrame + (dir * spd * dt)
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end
local function stopFly()
    isFlying = false
    if flyRenderConn then flyRenderConn:Disconnect(); flyRenderConn = nil end
    local char = player.Character
    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = false end
    end
    if flyBodyVelocity then pcall(function() flyBodyVelocity:Destroy() end); flyBodyVelocity = nil end
    if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end); flyBodyGyro = nil end
end
local UnivKit = {}
;(function()
    local noclipConn, noclipParts = nil, {}
    local infJumpConn, clickTpConn, vehicleConn = nil, nil, nil
    local localInvisParts = {}
    local autoObbyRunning = false
    local checkpointCache = {}
    local bhLocationCache = {}
    local function getHRP()
        local c = player.Character
        if not c then return nil end
        return c:FindFirstChild("HumanoidRootPart"), c:FindFirstChildOfClass("Humanoid"), c
    end
    local function stopNoclip()
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        for part, was in pairs(noclipParts) do
            pcall(function() if part and part.Parent then part.CanCollide = was end end)
        end
        noclipParts = {}
    end
    local function startNoclip()
        stopNoclip()
        Settings.Movement.Noclip = true
        noclipConn = S.RunService.Stepped:Connect(function()
            if isUnloading or _G[MW_T.unloaded] or not Settings.Movement.Noclip then return end
            local _, _, char = getHRP()
            if not char then return end
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("BasePart") then
                    if noclipParts[d] == nil then noclipParts[d] = d.CanCollide end
                    d.CanCollide = false
                end
            end
        end)
    end
    function UnivKit.setNoclip(on)
        Settings.Movement.Noclip = on and true or false
        if on then startNoclip() else stopNoclip() end
    end
    local function stopInfiniteJump()
        if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
    end
    function UnivKit.setInfiniteJump(on)
        if on and MW.guard("pos") then
            Settings.Movement.InfiniteJump = false
            pcall(function() if sendNotification then sendNotification("Inf Jump", "Blocked on this game (pos check)", 2) end end)
            return
        end
        Settings.Movement.InfiniteJump = on and true or false
        stopInfiniteJump()
        if not on then return end
        infJumpConn = S.UserInputService.JumpRequest:Connect(function()
            if isUnloading or _G[MW_T.unloaded] or not Settings.Movement.InfiniteJump then return end
            local _, hum = getHRP()
            if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
        end)
    end
    local function stopClickTP()
        if clickTpConn then clickTpConn:Disconnect(); clickTpConn = nil end
    end
    function UnivKit.setClickTP(on)
        if on and (MW.guard("pos") or MW.allows("clickTp") == false) then
            Settings.Movement.ClickTP = false
            pcall(function() if sendNotification then sendNotification("Click TP", "Blocked on this game (pos check)", 2) end end)
            return
        end
        Settings.Movement.ClickTP = on and true or false
        stopClickTP()
        if not on then return end
        clickTpConn = S.UserInputService.InputBegan:Connect(function(input, gp)
            if gp or isUnloading or _G[MW_T.unloaded] or not Settings.Movement.ClickTP then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            local kb = Settings.Keybinds.ClickTP
            if kb and kb ~= Enum.KeyCode.Unknown and not S.UserInputService:IsKeyDown(kb) then return end
            local hrp = select(1, getHRP())
            if not hrp then return end
            local mouse = player:GetMouse()
            if mouse and mouse.Hit then
                pcall(function() hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end)
            end
        end)
    end
    local function stopVehicleSpeed()
        if vehicleConn then vehicleConn:Disconnect(); vehicleConn = nil end
    end
    function UnivKit.setVehicleSpeed(on)
        Settings.Movement.VehicleSpeed = on and true or false
        stopVehicleSpeed()
        if not on then return end
        vehicleConn = S.RunService.Heartbeat:Connect(function()
            if isUnloading or _G[MW_T.unloaded] or not Settings.Movement.VehicleSpeed then return end
            local _, hum = getHRP()
            if not hum then return end
            local seat = hum.SeatPart
            if not seat then return end
            local mul = tonumber(Settings.Movement.VehicleSpeedMul) or 2
            local root = seat
            local model = seat:FindFirstAncestorOfClass("Model")
            if model then
                local prim = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
                if prim then root = prim end
            end
            pcall(function()
                local v = root.AssemblyLinearVelocity
                local flat = Vector3.new(v.X, 0, v.Z)
                if flat.Magnitude > 2 then
                    root.AssemblyLinearVelocity = flat.Unit * math.min(flat.Magnitude * mul, 220) + Vector3.new(0, v.Y, 0)
                end
            end)
        end)
    end
    local function clearLocalInvis()
        for part, t0 in pairs(localInvisParts) do
            pcall(function()
                if not part or not part.Parent then return end
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = t0
                elseif part:IsA("Decal") then
                    part.Transparency = t0
                end
            end)
        end
        localInvisParts = {}
    end
    function UnivKit.applyLocalInvis(on)
        Settings.Movement.LocalInvis = on and true or false
        clearLocalInvis()
        if not on then return end
        local _, _, char = getHRP()
        if not char then return end
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                localInvisParts[d] = d.LocalTransparencyModifier
                d.LocalTransparencyModifier = 1
            elseif d:IsA("Decal") then
                localInvisParts[d] = d.Transparency
                d.Transparency = 1
            end
        end
    end
    local function checkpointScore(name)
        local n = string.lower(tostring(name or ""))
        local num = tonumber(n:match("(%d+)"))
        if n:find("checkpoint", 1, true) or n:find("check_point", 1, true) or n:find("check point", 1, true) then
            return true, num or 0
        end
        if n:find("stage", 1, true) or n:match("^cp%d+") then return true, num or 0 end
        if n == "finish" or n == "goal" or n:find("finish", 1, true) == 1 or n:find("goal", 1, true) == 1 then
            return true, num or 9999
        end
        return false, 0
    end
    function UnivKit.scanCheckpoints()
        checkpointCache = {}
        local roots = { S.Workspace }
        for _, name in ipairs({"Checkpoints", "Stages", "Obby", "Map", "Course", "Level"}) do
            local f = S.Workspace:FindFirstChild(name)
            if f then table.insert(roots, f) end
        end
        local seen = {}
        local function consider(inst)
            if not inst or seen[inst] then return end
            local ok, num = checkpointScore(inst.Name)
            if not ok then return end
            local part = nil
            if inst:IsA("BasePart") then part = inst
            elseif inst:IsA("Model") then
                part = inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
            end
            if not part then return end
            seen[inst] = true
            table.insert(checkpointCache, { inst = inst, part = part, num = num, name = inst.Name, pos = part.Position })
        end
        for _, root in ipairs(roots) do
            consider(root)
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("BasePart") or d:IsA("Model") then consider(d) end
            end
        end
        table.sort(checkpointCache, function(a, b)
            if a.num ~= b.num then return a.num < b.num end
            if math.abs(a.pos.Y - b.pos.Y) > 2 then return a.pos.Y < b.pos.Y end
            return a.pos.Magnitude < b.pos.Magnitude
        end)
        return checkpointCache
    end
    local function tpToPart(part)
        local hrp = select(1, getHRP())
        if not hrp or not part then return false end
        return pcall(function()
            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 4, 0))
        end)
    end
    function UnivKit.stopAutoObby()
        autoObbyRunning = false
        Settings.Misc.AutoObby = false
    end
    function UnivKit.startAutoObby()
        if autoObbyRunning then return end
        Settings.Misc.AutoObby = true
        autoObbyRunning = true
        task.spawn(function()
            local list = UnivKit.scanCheckpoints()
            if #list == 0 then
                sendNotification("Auto Obby", "No checkpoints found", 3)
                UnivKit.stopAutoObby()
                return
            end
            sendNotification("Auto Obby", tostring(#list) .. " checkpoints", 2)
            local idx = 1
            while autoObbyRunning and Settings.Misc.AutoObby and not isUnloading and not _G[MW_T.unloaded] do
                if idx > #list then
                    if Settings.Misc.AutoObbyLoop then
                        idx = 1
                    else
                        sendNotification("Auto Obby", "Finished", 2)
                        UnivKit.stopAutoObby()
                        break
                    end
                end
                local entry = list[idx]
                if entry and entry.part and entry.part.Parent then tpToPart(entry.part) end
                idx = idx + 1
                task.wait(tonumber(Settings.Misc.AutoObbyDelay) or 0.35)
            end
            autoObbyRunning = false
        end)
    end
    function UnivKit.tpNextCheckpoint()
        local list = (#checkpointCache > 0) and checkpointCache or UnivKit.scanCheckpoints()
        if #list == 0 then sendNotification("Checkpoints", "None found", 2); return end
        local hrp = select(1, getHRP())
        if not hrp then return end
        local nearestIdx, nearestD = 1, math.huge
        for i, e in ipairs(list) do
            local d = (e.pos - hrp.Position).Magnitude
            if d < nearestD then nearestD, nearestIdx = d, i end
        end
        local target = list[math.min(nearestIdx + 1, #list)] or list[1]
        if tpToPart(target.part) then sendNotification("Checkpoint", target.name, 1.5) end
    end
    function UnivKit.tpToSpawn()
        local best = nil
        local ok, descendants = pcall(function() return S.Workspace:GetDescendants() end)
        if ok and type(descendants) == "table" then
            for _, d in ipairs(descendants) do
                if d:IsA("SpawnLocation") then best = d; break end
            end
        end
        if best then
            tpToPart(best)
            sendNotification("Spawn", "Teleported", 1.5)
        else
            pcall(function() player:LoadCharacter() end)
            sendNotification("Spawn", "Respawned", 1.5)
        end
    end
    UnivKit.BH_LOCATIONS = {
        "Airport", "Hospital", "School", "Mall", "Bank", "Police", "Motel",
        "Burger Barn", "Church", "Fire", "Gas", "Cafe", "Apartment",
        "Town Hall", "Park", "Beach", "Gym", "Museum", "Post Office",
    }
    local function resolveBrookhavenLocation(label)
        if bhLocationCache[label] and bhLocationCache[label].Parent then return bhLocationCache[label] end
        local needle = string.lower(label:gsub("%s+", ""))
        local best, bestScore = nil, 0
        local ok, descendants = pcall(function() return S.Workspace:GetDescendants() end)
        if not ok or type(descendants) ~= "table" then return nil end
        local scanned = 0
        for _, d in ipairs(descendants) do
            scanned = scanned + 1
            if scanned > 8000 then break end
            if d:IsA("BasePart") or d:IsA("Model") then
                local n = string.lower((d.Name or ""):gsub("%s+", ""))
                if n == needle or n:find(needle, 1, true) then
                    local score = (#n == #needle) and 3 or 1
                    if score > bestScore then
                        local part = d:IsA("BasePart") and d or (d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart", true))
                        if part then best, bestScore = part, score end
                    end
                end
            end
        end
        if best then bhLocationCache[label] = best end
        return best
    end
    function UnivKit.tpBrookhavenLocation(label)
        local part = resolveBrookhavenLocation(label)
        if part and tpToPart(part) then
            sendNotification("Brookhaven", "TP -> " .. label, 2)
            return true
        end
        sendNotification("Brookhaven", "Location not found: " .. label, 2)
        return false
    end
    function UnivKit.bringPlayerByName(name)
        local me = select(1, getHRP())
        if not me then return false end
        for _, plr in ipairs(S.Players:GetPlayers()) do
            if plr ~= player and (plr.DisplayName == name or plr.Name == name) then
                local th = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if th then
                    local ok = pcall(function() th.CFrame = me.CFrame * CFrame.new(0, 0, -3) end)
                    sendNotification("Bring", ok and ("Brought " .. name) or "Failed (ownership)", 2)
                    return ok
                end
            end
        end
        sendNotification("Bring", "Player not found", 2)
        return false
    end
    function UnivKit.tpToPlayerByName(name)
        local me = select(1, getHRP())
        if not me then return false end
        for _, plr in ipairs(S.Players:GetPlayers()) do
            if plr ~= player and (plr.DisplayName == name or plr.Name == name) then
                local th = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if th then
                    local ok = pcall(function() me.CFrame = th.CFrame * CFrame.new(0, 0, 3) end)
                    sendNotification("TP", ok and ("-> " .. name) or "Failed", 2)
                    return ok
                end
            end
        end
        sendNotification("TP", "Player not found", 2)
        return false
    end
    function UnivKit.forceSit(on)
        local _, hum = getHRP()
        if not hum then return end
        if on then pcall(function() hum.Sit = true end)
        else pcall(function() hum.Sit = false; hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
    function UnivKit.stopUniversalKits()
        stopNoclip(); UnivKit.setInfiniteJump(false); UnivKit.setClickTP(false); stopVehicleSpeed()
        clearLocalInvis(); UnivKit.stopAutoObby()
        Settings.Movement.Noclip = false
        Settings.Movement.InfiniteJump = false
        Settings.Movement.ClickTP = false
        Settings.Movement.VehicleSpeed = false
        Settings.Movement.LocalInvis = false
    end
end)()
local autoTPTarget=nil; local autoTPRunning=false
local function getNextTPTarget()
    local myChar=player.Character; if not myChar then return nil end; local myHRP=myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return nil end
    local name=Settings.Misc.AutoTPTargetName or "Nearest Enemy"
    local mode = name
    if mode ~= "Nearest Enemy" and mode ~= "Lowest HP" and mode ~= "Highest HP" and mode ~= "Furthest Enemy" then
        for _,t in ipairs(S.Players:GetPlayers()) do
            if t~=player and (t.DisplayName==name or t.Name==name) then
                local tc=t.Character
                if tc then
                    local th=tc:FindFirstChild("HumanoidRootPart")
                    local h=tc:FindFirstChild("Humanoid")
                    if th and h and h.Health>0 and not isProtected(t) then return t end
                end
            end
        end
        return nil
    end
    local best, bestScore = nil, nil
    for _,t in ipairs(S.Players:GetPlayers()) do
        if t~=player and isValidTarget(player,t) then
            local tc=t.Character
            if tc then
                local th=tc:FindFirstChild("HumanoidRootPart")
                local h=tc:FindFirstChild("Humanoid")
                if th and h and h.Health>0 and not isProtected(t) then
                    local d=(myHRP.Position-th.Position).Magnitude
                    local score
                    if mode == "Lowest HP" then score = h.Health
                    elseif mode == "Highest HP" then score = -h.Health
                    elseif mode == "Furthest Enemy" then score = -d
                    else score = d end
                    if not best or score < bestScore then
                        bestScore = score
                        best = t
                    end
                end
            end
        end
    end
    return best
end
local function startAutoTPLoop()
    if MW.guard("pos") or not MW.allows("autoTp") then
        Settings.Misc.AutoTPLoop = false
        pcall(function() if sendNotification then sendNotification("Auto TP", "Blocked on this game (pos check)", 2) end end)
        return
    end
    if autoTPRunning then return end; autoTPRunning=true
    task.spawn(function()
        while autoTPRunning and Settings.Misc.AutoTPLoop and not isUnloading and not _G[MW_T.unloaded] do
            local myChar=player.Character; local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHRP then autoTPTarget=getNextTPTarget(); if autoTPTarget then local tc=autoTPTarget.Character; if tc then local th=tc:FindFirstChild("HumanoidRootPart"); local h=tc:FindFirstChild("Humanoid"); if th and h and h.Health>0 then local tcf=th.CFrame; local look=CFrame.lookAt(tcf.Position+tcf.LookVector*2,tcf.Position); myHRP.CFrame=look; local cam=S.Workspace.CurrentCamera; if cam then cam.CFrame=CFrame.lookAt(myHRP.Position+Vector3.new(0,2,0),th.Position) end end end end end
            task.wait(Settings.Misc.AutoTPLoopDelay or 0.5)
        end
        autoTPTarget=nil; autoTPRunning=false
    end)
end
local function stopAutoTPLoop() Settings.Misc.AutoTPLoop=false; autoTPRunning=false; autoTPTarget=nil end
local FX = {
    session = { kills = 0, deaths = 0, wins = 0, started = tick() },
    lastKillAt = 0,
    lastWinAt = 0,
    lastAcAt = 0,
    lastLobbyAt = 0,
    hopBusy = false,
    acHooked = false,
}
function FX.normalizeWebhookUrl(url)
    url = tostring(url or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if url == "" then return nil end
    if not url:find("discord.com/api/webhooks", 1, true) and not url:find("discordapp.com/api/webhooks", 1, true) then
        return nil
    end
    return url
end
function FX.ensureHooks()
    ensureUISettings()
    if type(Settings.Webhook.Hooks) ~= "table" then Settings.Webhook.Hooks = {} end
end
function FX.addHook(url)
    FX.ensureHooks()
    url = FX.normalizeWebhookUrl(url)
    if not url then return false, "invalid" end
    for _, h in ipairs(Settings.Webhook.Hooks) do
        if h.Url == url then return false, "exists" end
    end
    table.insert(Settings.Webhook.Hooks, {
        Url = url,
        Kills = true,
        Wins = true,
        KD = true,
        Lobby = true,
        AntiCheat = true,
    })
    return true
end
function FX.removeHook(url)
    FX.ensureHooks()
    for i, h in ipairs(Settings.Webhook.Hooks) do
        if h.Url == url then
            table.remove(Settings.Webhook.Hooks, i)
            return true
        end
    end
    return false
end
function FX.sendPayload(payload, channel)
    FX.ensureHooks()
    local ch = tostring(channel or "")
    if not Cap.ok("http") then return 0 end
    if not Settings.Webhook.Enabled and ch ~= "Test" then return 0 end
    local hooks = Settings.Webhook.Hooks
    if #hooks == 0 then return 0 end
    local body = S.HttpService:JSONEncode(payload)
    local sent = 0
    for _, hook in ipairs(hooks) do
        local allow = true
        if ch == "Kills" then allow = hook.Kills == true
        elseif ch == "Wins" then allow = hook.Wins == true
        elseif ch == "KD" then allow = hook.KD == true
        elseif ch == "Lobby" then allow = hook.Lobby == true
        elseif ch == "AntiCheat" then allow = hook.AntiCheat == true
        elseif ch == "Test" then allow = true
        end
        if allow and hook.Url then
            local res = Auth.httpRequest({
                Url = hook.Url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = body,
            })
            local code = res and (res.StatusCode or res.status_code)
            if res and (code == 200 or code == 204) then
                sent = sent + 1
            end
        end
    end
    return sent
end
function FX.kdText()
    local k, d = FX.session.kills, FX.session.deaths
    local ratio = d <= 0 and k or (math.floor((k / d) * 100 + 0.5) / 100)
    return string.format("%d / %d (%.2f)", k, d, ratio)
end
function FX.embed(title, description, color)
    return {
        username = MW.hub,
        embeds = {{
            title = title,
            description = description,
            color = color or 5940479,
            footer = { text = MW.hub .. " v" .. MW.display .. " | " .. tostring(game.JobId):sub(1, 8) },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }},
    }
end
function FX.onKill(victimName, weapon)
    local now = tick()
    if now - FX.lastKillAt < 0.15 then return end
    FX.lastKillAt = now
    FX.session.kills = FX.session.kills + 1
    if TraceHUD and TraceHUD.pushFeed then TraceHUD.pushFeed('KILL', getDisplayName and getDisplayName(victim) or tostring(victim), nil) end
    if not Settings.Webhook.Enabled then return end
    local desc = string.format(
        "**Killer:** %s\n**Victim:** %s\n**Weapon:** %s\n**Session K/D:** %s\n**Players:** %d",
        player.Name,
        tostring(victimName or "?"),
        tostring(weapon or getPlayerWeaponName(player) or "Unknown"),
        FX.kdText(),
        #S.Players:GetPlayers()
    )
    FX.sendPayload(FX.embed("Kill", desc, 15158332), "Kills")
    FX.sendPayload(FX.embed("Session K/D", "**" .. FX.kdText() .. "**", 3447003), "KD")
end
function FX.onDeath()
    FX.session.deaths = FX.session.deaths + 1
    if Settings.Webhook.Enabled then
        FX.sendPayload(FX.embed("Death", "Session K/D: **" .. FX.kdText() .. "**", 10070709), "KD")
    end
end
function FX.onWin(detail)
    local now = tick()
    if now - FX.lastWinAt < 8 then return end
    FX.lastWinAt = now
    FX.session.wins = FX.session.wins + 1
    if not Settings.Webhook.Enabled then return end
    FX.sendPayload(FX.embed("Win", tostring(detail or "Round win") .. "\n**Session wins:** " .. FX.session.wins .. "\n**K/D:** " .. FX.kdText(), 5763719), "Wins")
end
function FX.onAntiCheat(reason)
    if Settings.Misc.AntiCheatAlerts == false then return end
    local now = tick()
    if now - FX.lastAcAt < 4 then return end
    FX.lastAcAt = now
    sendNotification("Anti-Cheat", tostring(reason or "Suspicious kick/error"), 6)
    if Settings.Webhook.Enabled then
        FX.sendPayload(FX.embed("Anti-Cheat Alert", "**Reason:** " .. tostring(reason or "unknown") .. "\n**Place:** " .. tostring(game.PlaceId) .. "\n**Job:** `" .. tostring(game.JobId) .. "`", 15105570), "AntiCheat")
    end
end
function FX.onLobby(detail)
    if Settings.Misc.LobbyAlertOnJoin == false then return end
    local now = tick()
    if now - FX.lastLobbyAt < 6 then return end
    FX.lastLobbyAt = now
    local n = #S.Players:GetPlayers()
    local msg = tostring(detail or "Lobby ready") .. string.format("\n**Players:** %d\n**Job:** `%s`", n, tostring(game.JobId))
    sendNotification("Lobby", n .. " players", 3)
    if Settings.Webhook.Enabled then
        FX.sendPayload(FX.embed("Lobby Alert", msg, 15844367), "Lobby")
    end
end
function FX.doServerHop(opts)
    opts = opts or {}
    if not Cap.ok("http") then
        sendNotification("Server Hop", "HTTP unsupported on this executor", 3)
        return
    end
    if FX.hopBusy then return end
    FX.hopBusy = true
    task.spawn(function()
        sendNotification("Server Hop", "Finding servers...", 3)
        local minP = opts.minPlayers or Settings.Misc.LobbyMinPlayers or 1
        local maxP = opts.maxPlayers or Settings.Misc.LobbyMaxPlayers or 12
        local cursor = ""
        local servers = {}
        for _ = 1, 4 do
            local url = "https://games.roblox.com/v1/games/"
                .. tostring(game.PlaceId)
                .. "/servers/Public?sortOrder=Asc&limit=100"
                .. (cursor ~= "" and ("&cursor=" .. cursor) or "")
            local res = Auth.httpRequest({ Url = url, Method = "GET" })
            if not res then break end
            local body = res.Body or res.body
            if type(body) ~= "string" then break end
            local decodeOk, data = pcall(function() return S.HttpService:JSONDecode(body) end)
            if not decodeOk or type(data) ~= "table" or type(data.data) ~= "table" then break end
            for _, s in ipairs(data.data) do
                local playing = s.playing or 0
                local maxPlayers = s.maxPlayers or 16
                if s.id and s.id ~= game.JobId and playing < maxPlayers and playing >= minP and playing <= maxP then
                    table.insert(servers, s)
                end
            end
            cursor = data.nextPageCursor or ""
            if cursor == "" or #servers >= 10 then break end
        end
        if #servers == 0 then
            sendNotification("Server Hop", "No match: random teleport", 3)
            pcall(function() S.TeleportService:Teleport(game.PlaceId, player) end)
            FX.hopBusy = false
            return
        end
        local pick = servers[math.random(1, #servers)]
        sendNotification("Server Hop", "Joining " .. tostring(pick.playing) .. " player server", 3)
        pcall(function()
            S.TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, player)
        end)
        FX.hopBusy = false
    end)
end
function FX.startLobbyFinder()
    if FX.hopBusy then return end
    task.spawn(function()
        local attempts = 0
        while Settings.Misc.AutoHopUntilMatch and not isUnloading and not _G[MW_T.unloaded] and attempts < 12 do
            attempts = attempts + 1
            local n = #S.Players:GetPlayers()
            local minP = Settings.Misc.LobbyMinPlayers or 1
            local maxP = Settings.Misc.LobbyMaxPlayers or 12
            if n >= minP and n <= maxP then
                FX.onLobby("Matched lobby filters")
                Settings.Misc.AutoHopUntilMatch = false
                return
            end
            FX.doServerHop({ minPlayers = minP, maxPlayers = maxP })
            task.wait(6)
        end
        Settings.Misc.AutoHopUntilMatch = false
    end)
end
function FX.hookAntiCheat()
    if FX.acHooked then return end
    FX.acHooked = true

    pcall(function()
        local gui = game:GetService("GuiService")
        local sig = gui.ErrorMessageChanged
        if typeof(sig) ~= "RBXScriptSignal" then return end
        table.insert(allConnections, sig:Connect(function(a, b)
            local msg = tostring(a or b or "")
            if msg == "" then return end
            local low = string.lower(msg)
            if low:find("exploit", 1, true) or low:find("cheat", 1, true) or low:find("banned", 1, true)
                or low:find("kicked", 1, true) or low:find("suspicious", 1, true) or low:find("disconnect", 1, true) then
                FX.onAntiCheat(msg)
            end
        end))
    end)
    pcall(function()
        table.insert(allConnections, S.Players.PlayerRemoving:Connect(function(p)
            if p ~= player then return end
            if Settings.Misc.AutoRejoin or Settings.Misc.AntiCheatAlerts ~= false then
                FX.onAntiCheat("LocalPlayer leaving / possible kick")
            end
        end))
    end)
    pcall(function()
        local humConn
        local function hookLocal(char)
            local hum = char:WaitForChild("Humanoid", 8)
            if not hum then return end
            if humConn then humConn:Disconnect() end
            humConn = hum.Died:Connect(function()
                FX.onDeath()
            end)
            table.insert(allConnections, humConn)
        end
        if player.Character then hookLocal(player.Character) end
        table.insert(allConnections, player.CharacterAdded:Connect(hookLocal))
    end)
    pcall(function()
        local ls = player:FindFirstChild("leaderstats")
        local function watchWins(folder)
            if not folder then return end
            local w = folder:FindFirstChild("Wins") or folder:FindFirstChild("Win") or folder:FindFirstChild("Streak")
            if w and (w:IsA("IntValue") or w:IsA("NumberValue")) then
                local last = w.Value
                table.insert(allConnections, w.Changed:Connect(function()
                    if w.Value > last then FX.onWin(w.Name .. " -> " .. tostring(w.Value)) end
                    last = w.Value
                end))
            end
        end
        if ls then watchWins(ls) end
        table.insert(allConnections, player.ChildAdded:Connect(function(c)
            if c.Name == "leaderstats" then watchWins(c) end
        end))
    end)
    task.defer(function()
        if Settings.Misc.LobbyAlertOnJoin ~= false then
            task.wait(2.5)
            FX.onLobby("Joined server")
        end
        if Settings.Misc.AutoHopUntilMatch then
            FX.startLobbyFinder()
        end
    end)
end
function FX.isLocalDead()
    local char = player.Character
    if not char then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health <= 0 end
    local nrpbs = char:FindFirstChild("NRPBS")
    local hv = nrpbs and (nrpbs:FindFirstChild("Health") or nrpbs:FindFirstChild("health"))
    if hv and typeof(hv.Value) == "number" then return hv.Value <= 0 end
    return false
end
function FX.resolveChatRemote()
    local rs = game:GetService("ReplicatedStorage")
    local folders = {
        rs:FindFirstChild("Events") or rs:FindFirstChild("events"),
        rs:FindFirstChild("Remotes") or rs:FindFirstChild("remotes"),
        rs:FindFirstChild("Networking") or rs:FindFirstChild("network"),
        rs,
    }
    local names = {"PlayerChatted", "PlayerChat", "Chat", "SendChat", "SayChat", "Chatted", "MessageSent", "SendMessage"}
    for _, events in ipairs(folders) do
        if events then
            for _, n in ipairs(names) do
                local rem = events:FindFirstChild(n, true)
                if rem and (rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction")) then
                    local arsenal = (events.Name == "Events" or events.Name == "events")
                    return rem, arsenal and "arsenal" or "generic"
                end
            end
            local checked = 0
            local ok, descendants = pcall(function() return events:GetDescendants() end)
            if ok and type(descendants) == "table" then
                for _, rem in ipairs(descendants) do
                    checked = checked + 1
                    if checked > 250 then break end
                    if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                        local ln = string.lower(rem.Name)
                        if ln:find("chat", 1, true) and not ln:find("mute", 1, true) and not ln:find("bubble", 1, true) then
                            return rem, "generic"
                        end
                    end
                end
            end
        end
    end
    local legacy = rs:FindFirstChild("DefaultChatSystemChatEvents")
    local say = legacy and legacy:FindFirstChild("SayMessageRequest")
    if say and say:IsA("RemoteEvent") then
        return say, "legacy"
    end
    return nil, nil
end
function FX.sendChat(msg, teamOnly)
    msg = tostring(msg or "")
    if msg == "" then return false end
    teamOnly = teamOnly == true
    local rem, kind = FX.resolveChatRemote()
    if rem and (kind == "arsenal" or kind == "generic") then
        local dead = FX.isLocalDead()
        local ok = pcall(function()
            if rem:IsA("RemoteFunction") then
                rem:InvokeServer(msg, teamOnly, false, dead)
            else
                rem:FireServer(msg, teamOnly, false, dead)
            end
        end)
        if ok then return true end
        ok = pcall(function()
            rem:FireServer(msg, teamOnly)
        end)
        if ok then return true end
        ok = pcall(function()
            rem:FireServer(msg)
        end)
        if ok then return true end
    end
    if rem and kind == "legacy" then
        return pcall(function()
            rem:FireServer(msg, teamOnly and "Team" or "All")
        end)
    end
    return pcall(function()
        local tcs = game:GetService("TextChatService")
        local ch = tcs and tcs:FindFirstChild("TextChannels")
        local g = ch and (ch:FindFirstChild("RBXGeneral") or ch:FindFirstChildWhichIsA("TextChannel"))
        if g then g:SendAsync(msg) end
    end)
end
local Throw = {}
;(function()
local THROWABLE_KEYWORDS = {"grenade", "knife", "frag", "molotov", "flash", "projectile", "throw", "bomb", "dynamite", "snowball", "slingshot"}
local throwableHighlights = {}
local throwableScanList = {}
local lastThrowableScan = 0
local function clearThrowableESP()
    for id, h in pairs(throwableHighlights) do
        pcall(function() h:Destroy() end)
        throwableHighlights[id] = nil
    end
end
local function isThrowableObject(obj)
    if not obj then return false end
    local nl = obj.Name:lower()
    for _, kw in ipairs(THROWABLE_KEYWORDS) do
        if nl:find(kw, 1, true) then return true end
    end
    return false
end
local function scanThrowables()
    throwableScanList = {}
    local ok, descendants = pcall(function() return S.Workspace:GetDescendants() end)
    if not ok or type(descendants) ~= "table" then return end
    local n = 0
    for _, obj in ipairs(descendants) do
        if n >= 120 then break end
        if obj:IsA("BasePart") then
            local model = obj:FindFirstAncestorOfClass("Model")
            if not (model and S.Players:GetPlayerFromCharacter(model)) then
                if isThrowableObject(obj) or (model and isThrowableObject(model)) then
                    table.insert(throwableScanList, obj)
                    n = n + 1
                end
            end
        end
    end
end
local function updateThrowableESP(myPos)
    if not Settings.ESP.ThrowableEnabled then
        clearThrowableESP()
        return
    end
    local now = tick()
    if now - (VisPerf.lastThrowable or 0) < 0.28 then return end
    VisPerf.lastThrowable = now
    if now - lastThrowableScan > 1.5 then
        lastThrowableScan = now
        scanThrowables()
    end
    local active = {}
    local maxDist = Settings.ESP.ThrowableMaxDistance or 250
    for _, part in ipairs(throwableScanList) do
        if part and part.Parent then
            local dist = (part.Position - myPos).Magnitude
            if dist <= maxDist then
                local id = part:GetFullName()
                active[id] = true
                if not throwableHighlights[id] then
                    local hl = Instance.new("Highlight")
                    hl.Name = MW_T.throw
                    hl.FillColor = Color3.fromRGB(255, 180, 40)
                    hl.OutlineColor = Color3.fromRGB(255, 220, 80)
                    hl.FillTransparency = 0.55
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    throwableHighlights[id] = hl
                end
                local hl = throwableHighlights[id]
                hl.Adornee = part
                hl.Parent = part
                hl.Enabled = true
            end
        end
    end
    for id, hl in pairs(throwableHighlights) do
        if not active[id] then
            pcall(function() hl:Destroy() end)
            throwableHighlights[id] = nil
        end
    end
end
local function isThrowableTool(tool)
    return tool and tool:IsA("Tool") and isThrowableObject(tool)
end
local arcFolder, arcPool = nil, {}
local _arcRP = RaycastParams.new()
_arcRP.FilterType = Enum.RaycastFilterType.Exclude
local function clearThrowableArcPreview()
    for _, part in ipairs(arcPool) do
        pcall(function() part.Transparency = 1 end)
    end
end
local function getArcMarker(i)
    if not arcFolder or not arcFolder.Parent then
        arcFolder = Instance.new("Folder")
        arcFolder.Name = MW_T.arc
        arcFolder.Parent = S.Workspace
    end
    if not arcPool[i] then
        local p = Instance.new("Part")
        p.Name = MW_T.arcPt
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.Material = Enum.Material.Neon
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(0.2, 0.2, 0.2)
        p.Parent = arcFolder
        arcPool[i] = p
    end
    return arcPool[i]
end
local function updateThrowableArcPreview()
    if not Settings.ESP.ThrowableArcPreview then
        clearThrowableArcPreview()
        return
    end
    local char = player.Character
    if not char then clearThrowableArcPreview(); return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or not isThrowableTool(tool) then clearThrowableArcPreview(); return end
    local cam = S.Workspace.CurrentCamera
    if not cam then return end
    local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
    local origin = hand and hand:IsA("BasePart") and (hand.Position + cam.CFrame.LookVector * 0.6) or (cam.CFrame.Position + cam.CFrame.LookVector * 2)
    local power = Settings.ESP.ThrowableArcPower or 72
    local lift = Settings.ESP.ThrowableArcLift or 24
    local segments = math.clamp(Settings.ESP.ThrowableArcSegments or 22, 8, 40)
    local vel = cam.CFrame.LookVector * power + Vector3.new(0, lift, 0)
    local gravity = Vector3.new(0, -S.Workspace.Gravity, 0)
    local dt = 0.045
    local filter = {char}
    if arcFolder then table.insert(filter, arcFolder) end
    _arcRP.FilterDescendantsInstances = filter
    local pos = origin
    local used = 0
    for step = 1, segments do
        local nextVel = vel + gravity * dt
        local nextPos = pos + vel * dt + gravity * (0.5 * dt * dt)
        local delta = nextPos - pos
        local hit = delta.Magnitude > 0.01 and S.Workspace:Raycast(pos, delta, _arcRP) or nil
        used = used + 1
        local marker = getArcMarker(used)
        marker.CFrame = CFrame.new(hit and hit.Position or nextPos)
        marker.Color = hit and Color3.fromRGB(255, 90, 70) or Color3.fromRGB(255, 205, 90)
        marker.Transparency = 0.12 + (step / segments) * 0.62
        marker.Size = Vector3.new(0.16 + (1 - step / segments) * 0.08, 0.16, 0.16)
        if hit then break end
        pos = nextPos
        vel = nextVel
    end
    for i = used + 1, #arcPool do
        pcall(function() arcPool[i].Transparency = 1 end)
    end
end
Throw.clearThrowableESP = clearThrowableESP
Throw.updateThrowableESP = updateThrowableESP
Throw.clearThrowableArcPreview = clearThrowableArcPreview
Throw.updateThrowableArcPreview = updateThrowableArcPreview
end)()
local origCameraType = nil
local autoRejoinBusy = false
local VisCam = {}
function VisCam.applyThirdPerson()
    local cam = S.Workspace.CurrentCamera
    local char = player.Character
    if not cam or not char then return end
    if rageRunning or Settings.Combat.RageBot then return end
    if Settings.Visuals.ThirdPerson and not isTracking then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if cam.CameraType ~= Enum.CameraType.Scriptable then
            origCameraType = cam.CameraType
            cam.CameraType = Enum.CameraType.Scriptable
        end
        local dist = Settings.Visuals.ThirdPersonDistance or 10
        local look = cam.CFrame.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude < 0.01 then flat = Vector3.new(0, 0, -1) else flat = flat.Unit end
        local camPos = hrp.Position - flat * dist + Vector3.new(0, 2.2, 0)
        cam.CFrame = CFrame.lookAt(camPos, hrp.Position + Vector3.new(0, 1.4, 0))
    elseif origCameraType and cam.CameraType == Enum.CameraType.Scriptable and not isTracking then
        cam.CameraType = origCameraType
        origCameraType = nil
    end
end
function VisCam.applyViewmodelSettings()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local yOff = (Settings.Visuals.ViewmodelOffsetY or 0) * 0.01
        hum.CameraOffset = Vector3.new(0, yOff, 0)
    end
end
function VisCam.applyViewmodelTweaks()
    local cam = S.Workspace.CurrentCamera
    local char = player.Character
    if not cam or not char or isPlayerScoped() then return end
    if Settings.Visuals.ViewmodelFOVEnabled and not Settings.Visuals.CustomFOV then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            cam.FieldOfView = Settings.Visuals.ViewmodelFOV or 70
        end
    end
end
local updateGunWireframe, clearGunWireframe
updateGunWireframe, clearGunWireframe = (function()
    local GUN_WIRE_COLORS = {
        Accent = function() return Theme.TextAccent or hexToColor3(Settings.UI and Settings.UI.AccentHex or "7DD3FC") end,
        Cyan = function() return Color3.fromRGB(0, 230, 255) end,
        Magenta = function() return Color3.fromRGB(255, 60, 220) end,
        Lime = function() return Color3.fromRGB(110, 255, 70) end,
        White = function() return Color3.fromRGB(248, 250, 255) end,
        Red = function() return Color3.fromRGB(255, 55, 55) end,
    }
    local gunWireOrig = {}
    local gunWireHighlights = {}
    local gunWireBoxes = {}
    local gunWireGlow = {}
    local gunWireFolder = nil
    local function getGunWireframeColor()
        local preset = Settings.Visuals.GunWireframeColorPreset or "Accent"
        local fn = GUN_WIRE_COLORS[preset]
        return fn and fn() or Color3.fromRGB(210, 210, 220)
    end
    local function shiftCol(c, mul, add)
        return Color3.new(
            math.clamp(c.R * mul + (add or 0), 0, 1),
            math.clamp(c.G * mul + (add or 0), 0, 1),
            math.clamp(c.B * mul + (add or 0), 0, 1)
        )
    end
    local function ensureWireFolder()
        if gunWireFolder and gunWireFolder.Parent then return gunWireFolder end
        local parent = nil
        pcall(function() parent = game:GetService("CoreGui") end)
        if not parent then parent = player:FindFirstChild("PlayerGui") end
        if not parent then parent = S.Workspace.CurrentCamera end
        gunWireFolder = Instance.new("Folder")
        gunWireFolder.Name = MW_T.gunWireBox
        gunWireFolder.Parent = parent
        return gunWireFolder
    end
    local function isLikelyWeaponModel(inst)
        if not inst or not inst.Parent then return false end
        if inst:IsA("Tool") then return true end
        if not inst:IsA("Model") then return false end
        if inst:FindFirstChildOfClass("Humanoid") then return false end
        if not inst:FindFirstChildWhichIsA("BasePart", true) then return false end
        local cam = S.Workspace.CurrentCamera
        if cam and (inst.Parent == cam or inst:IsDescendantOf(cam)) then return true end
        local nl = inst.Name:lower()
        return nl:find("arm", 1, true) or nl:find("hand", 1, true) or nl:find("view", 1, true)
            or nl:find("gun", 1, true) or nl:find("weapon", 1, true) or nl:find("vm", 1, true)
            or nl:find("fp", 1, true) or nl:find("first", 1, true) or nl:find("sleeve", 1, true)
    end
    local function collectWeaponModels()
        local out, seen = {}, {}
        local function add(root)
            if root and not seen[root] then
                seen[root] = true
                table.insert(out, root)
            end
        end
        local char = player.Character
        if char then
            for _, child in ipairs(char:GetChildren()) do
                if child:IsA("Tool") then add(child) end
            end
        end
        local cam = S.Workspace.CurrentCamera
        if cam then
            for _, child in ipairs(cam:GetChildren()) do
                if isLikelyWeaponModel(child) then add(child) end
            end
            local arms = cam:FindFirstChild("Arms") or cam:FindFirstChild("Viewmodel") or cam:FindFirstChild("FPS")
            if arms then add(arms) end
        end
        return out
    end
    local function restoreGunWirePart(part)
        local orig = gunWireOrig[part]
        if not orig then return end
        pcall(function()
            if part and part.Parent then
                part.Material = orig.Material
                part.Color = orig.Color
                part.Transparency = orig.Transparency
                part.Reflectance = orig.Reflectance or 0
                part.CastShadow = orig.CastShadow ~= false
                if orig.LocalTransparencyModifier ~= nil and part:IsA("BasePart") then
                    pcall(function() part.LocalTransparencyModifier = orig.LocalTransparencyModifier end)
                end
                if orig.TextureID ~= nil and part:IsA("MeshPart") then
                    part.TextureID = orig.TextureID
                end
            end
        end)
        gunWireOrig[part] = nil
        local box = gunWireBoxes[part]
        if box then pcall(function() box:Destroy() end); gunWireBoxes[part] = nil end
        local glow = gunWireGlow[part]
        if glow then pcall(function() glow:Destroy() end); gunWireGlow[part] = nil end
    end
    local function clear()
        for part in pairs(gunWireOrig) do
            restoreGunWirePart(part)
        end
        for part, box in pairs(gunWireBoxes) do
            pcall(function() box:Destroy() end)
            gunWireBoxes[part] = nil
        end
        for part, glow in pairs(gunWireGlow) do
            pcall(function() glow:Destroy() end)
            gunWireGlow[part] = nil
        end
        for _, hl in pairs(gunWireHighlights) do
            pcall(function() hl:Destroy() end)
        end
        gunWireHighlights = {}
        if gunWireFolder then
            pcall(function() gunWireFolder:Destroy() end)
            gunWireFolder = nil
        end
    end
    local function stashPart(part)
        if gunWireOrig[part] then return end
        local tex, ltm = nil, nil
        pcall(function()
            if part:IsA("MeshPart") then tex = part.TextureID end
        end)
        pcall(function() ltm = part.LocalTransparencyModifier end)
        gunWireOrig[part] = {
            Material = part.Material,
            Color = part.Color,
            Transparency = part.Transparency,
            Reflectance = part.Reflectance,
            CastShadow = part.CastShadow,
            TextureID = tex,
            LocalTransparencyModifier = ltm,
        }
    end
    local function makeWireAdornment(part, col, thickness, z, alwaysOnTop)
        local created = nil
        local okWire = pcall(function()
            local w = Instance.new("WireframeHandleAdornment")
            w.Name = MW_T.gunWire
            w.Adornee = part
            w.AlwaysOnTop = alwaysOnTop ~= false
            w.ZIndex = z or 10
            w.Color3 = col
            w.Transparency = 0
            pcall(function() w.Thickness = thickness or 0.06 end)
            w.Visible = true
            w.Parent = ensureWireFolder()
            created = w
        end)
        if okWire and created then return created end
        local box = Instance.new("SelectionBox")
        box.Name = MW_T.gunWire
        box.Adornee = part
        box.Color3 = col
        pcall(function() box.SurfaceColor3 = col end)
        box.LineThickness = math.clamp((thickness or 0.06) * 0.85, 0.02, 0.12)
        box.Transparency = 0
        box.SurfaceTransparency = 1
        box.Visible = true
        box.Parent = ensureWireFolder()
        return box
    end
    local function ensureWirePair(part, col, thickness)
        local core = gunWireBoxes[part]
        local glow = gunWireGlow[part]
        local thick = math.clamp(thickness or 0.07, 0.03, 0.16)
        if not core or not core.Parent then
            core = makeWireAdornment(part, col, thick, 12, true)
            gunWireBoxes[part] = core
        end
        if not glow or not glow.Parent then
            glow = makeWireAdornment(part, shiftCol(col, 0.55, 0.15), thick * 1.85, 8, true)
            if glow:IsA("WireframeHandleAdornment") then
                glow.Transparency = 0.45
            else
                glow.Transparency = 0.4
            end
            gunWireGlow[part] = glow
        end
        core.Adornee = part
        glow.Adornee = part
        if core:IsA("WireframeHandleAdornment") then
            core.Color3 = col
            core.Transparency = 0
            pcall(function() core.Thickness = thick end)
            core.AlwaysOnTop = true
            core.Visible = true
        else
            core.Color3 = col
            pcall(function() core.SurfaceColor3 = col end)
            core.LineThickness = math.clamp(thick * 0.85, 0.02, 0.12)
            core.Transparency = 0
            core.SurfaceTransparency = 1
            core.Visible = true
        end
        local glowCol = shiftCol(col, 0.65, 0.2)
        if glow:IsA("WireframeHandleAdornment") then
            glow.Color3 = glowCol
            glow.Transparency = 0.42
            pcall(function() glow.Thickness = thick * 1.9 end)
            glow.AlwaysOnTop = true
            glow.Visible = true
        else
            glow.Color3 = glowCol
            glow.LineThickness = math.clamp(thick * 1.4, 0.03, 0.14)
            glow.Transparency = 0.4
            glow.SurfaceTransparency = 1
            glow.Visible = true
        end
    end
    local function ensureRootHighlight(root, col, fillT, outlineT)
        local hl = gunWireHighlights[root]
        if not hl or not hl.Parent then
            hl = Instance.new("Highlight")
            hl.Name = MW_T.gunWire
            gunWireHighlights[root] = hl
        end
        hl.Adornee = root
        hl.Parent = root
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.OutlineColor = col
        hl.FillColor = shiftCol(col, 0.85, 0.05)
        hl.FillTransparency = fillT
        hl.OutlineTransparency = outlineT
        hl.Enabled = true
        return hl
    end
    local function shouldStylePart(part)
        if not part:IsA("BasePart") then return false end
        if part.Size.Magnitude < 0.08 then return false end
        local n = string.lower(part.Name)
        if n:find("humanoidrootpart", 1, true) then return false end
        local orig = gunWireOrig[part]
        local t = orig and orig.Transparency or part.Transparency
        return t < 0.98
    end
    local function applyGunWireframeToRoot(root)
        if not root or not root.Parent then return end
        local style = Settings.Visuals.GunWireframeStyle or "Wireframe"
        local col = getGunWireframeColor()
        local partAlpha = Settings.Visuals.GunWireframePartTransparency
        if partAlpha == nil then partAlpha = 0.88 end
        partAlpha = math.clamp(partAlpha, 0.05, 0.97)
        local thick = Settings.Visuals.GunWireframeThickness or 0.07
        if style == "Wireframe" then
            ensureRootHighlight(root, col, 0.92, 0.05)
        elseif style == "Outline" then
            ensureRootHighlight(root, col, 1, 0)
        elseif style == "Glass" then
            ensureRootHighlight(root, col, math.clamp(partAlpha, 0.55, 0.9), 0.2)
        else
            ensureRootHighlight(root, col, math.clamp(partAlpha * 0.4, 0.15, 0.65), 0)
        end
        local parts = root:GetDescendants()
        if root:IsA("BasePart") then table.insert(parts, root) end
        for _, part in ipairs(parts) do
            if shouldStylePart(part) then
                stashPart(part)
                if style == "Wireframe" then
                    part.Material = Enum.Material.ForceField
                    part.Color = shiftCol(col, 0.35, 0.05)
                    part.Transparency = math.clamp(partAlpha, 0.78, 0.96)
                    part.Reflectance = 0.05
                    part.CastShadow = false
                    pcall(function()
                        if part:IsA("MeshPart") then part.TextureID = "" end
                        part.LocalTransparencyModifier = 0
                    end)
                    ensureWirePair(part, col, thick)
                elseif style == "Outline" then
                    part.Material = Enum.Material.SmoothPlastic
                    part.Color = shiftCol(col, 0.25, 0.02)
                    part.Transparency = math.max(partAlpha, 0.9)
                    part.Reflectance = 0
                    part.CastShadow = false
                    pcall(function()
                        if part:IsA("MeshPart") then part.TextureID = "" end
                    end)
                    ensureWirePair(part, col, thick * 0.75)
                elseif style == "Glass" then
                    part.Material = Enum.Material.Glass
                    part.Color = col
                    part.Transparency = math.clamp(partAlpha, 0.4, 0.82)
                    part.Reflectance = 0.35
                    part.CastShadow = false
                    pcall(function()
                        if part:IsA("MeshPart") then part.TextureID = "" end
                    end)
                    ensureWirePair(part, Color3.new(1, 1, 1), thick * 0.55)
                else
                    part.Material = Enum.Material.Neon
                    part.Color = col
                    part.Transparency = math.clamp(partAlpha * 0.35, 0.02, 0.45)
                    part.Reflectance = 0
                    part.CastShadow = false
                    pcall(function()
                        if part:IsA("MeshPart") then part.TextureID = "" end
                    end)
                    ensureWirePair(part, shiftCol(col, 1.2, 0.1), thick * 1.15)
                end
            end
        end
    end
    local function update()
        if not Settings.Visuals.GunWireframeEnabled then
            clear()
            return
        end
        local activeRoots = {}
        local activeParts = {}
        for _, root in ipairs(collectWeaponModels()) do
            activeRoots[root] = true
            applyGunWireframeToRoot(root)
            for _, part in ipairs(root:GetDescendants()) do
                if part:IsA("BasePart") then activeParts[part] = true end
            end
            if root:IsA("BasePart") then activeParts[root] = true end
        end
        for root, hl in pairs(gunWireHighlights) do
            if not activeRoots[root] then
                pcall(function() hl:Destroy() end)
                gunWireHighlights[root] = nil
            end
        end
        for part in pairs(gunWireOrig) do
            if not activeParts[part] then
                restoreGunWirePart(part)
            end
        end
        for part, box in pairs(gunWireBoxes) do
            if not activeParts[part] then
                pcall(function() box:Destroy() end)
                gunWireBoxes[part] = nil
            end
        end
        for part, glow in pairs(gunWireGlow) do
            if not activeParts[part] then
                pcall(function() glow:Destroy() end)
                gunWireGlow[part] = nil
            end
        end
    end
    return update, clear
end)()
local function tryAutoRejoin(reason)
    if not Settings.Misc.AutoRejoin or autoRejoinBusy or isUnloading or _G[MW_T.unloaded] then return end
    autoRejoinBusy = true
    task.spawn(function()
        sendNotification("Auto Rejoin", reason or "Reconnecting...", 4)
        task.wait(2)
        pcall(function()
            S.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end)
        task.wait(8)
        pcall(function() S.TeleportService:Teleport(game.PlaceId, player) end)
        task.wait(5)
        autoRejoinBusy = false
    end)
end
local function setupAutoRejoin()
    table.insert(allConnections, S.TeleportService.TeleportInitFailed:Connect(function()
        tryAutoRejoin("Teleport failed, retrying")
    end))
    table.insert(allConnections, player.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Failed then
            tryAutoRejoin("Teleport failed")
        end
    end))
    table.insert(allConnections, player.AncestryChanged:Connect(function(_, parent)
        if not parent and Settings.Misc.AutoRejoin then
            tryAutoRejoin("Removed from game")
        end
    end))
end
local rageRunning = false
local startRageBot, stopRageBot
startRageBot, stopRageBot = (function()
local function getRageTargets()
    local list = {}
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position
    for _, t in ipairs(S.Players:GetPlayers()) do
        if t ~= player and isTriggerEnemy(player, t) and not isProtected(t) then
            local tc = t.Character
            if tc then
                local hum = tc:FindFirstChild("Humanoid")
                local hrp = tc:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    table.insert(list, t)
                end
            end
        end
    end
    if myPos then
        local enriched = {}
        for _, t in ipairs(list) do
            local tc = t.Character
            local hrp = tc and tc:FindFirstChild("HumanoidRootPart")
            local hum = tc and tc:FindFirstChild("Humanoid")
            table.insert(enriched, {
                player = t,
                dist = hrp and (hrp.Position - myPos).Magnitude or 1e9,
                hp = hum and hum.Health or 100,
            })
        end
        if TraceCombatEx and TraceCombatEx.sortRageTargets then
            TraceCombatEx.sortRageTargets(enriched)
        else
            table.sort(enriched, function(a, b) return a.dist < b.dist end)
        end
        list = {}
        for _, e in ipairs(enriched) do table.insert(list, e.player) end
    end
    return list
end
local function tpRageToTarget(target, dist)
    if MW.guard("pos") or not MW.allows("rage") then return false end
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local hum = myChar and myChar:FindFirstChild("Humanoid")
    local tc = target and target.Character
    local th = tc and tc:FindFirstChild("HumanoidRootPart")
    local head = tc and tc:FindFirstChild("Head")
    if not myHRP or not th then return false end
    local aimPos = head and head.Position or th.Position
    local backOffset = dist or Settings.Combat.RageTPDistance or 4
    local backPos = th.Position - th.CFrame.LookVector * backOffset
    local dest = CFrame.lookAt(backPos, aimPos)
    local ok = pcall(function()
        if myChar.PrimaryPart then
            myChar:PivotTo(dest)
        else
            myHRP.CFrame = dest
        end
        myHRP.AssemblyLinearVelocity = Vector3.zero
        myHRP.AssemblyAngularVelocity = Vector3.zero
        if hum then hum:ChangeState(Enum.HumanoidStateType.Running) end
    end)
    if not ok then return false end
    local cam = S.Workspace.CurrentCamera
    if cam then
        cam.CameraType = Enum.CameraType.Custom
        cam.CFrame = CFrame.lookAt(myHRP.Position + Vector3.new(0, 1.4, 0), aimPos)
    end
    return true
end
local function rageShootBurst(bursts)
    bursts = bursts or (Settings.Combat.RageShootBursts or 6)
    task.spawn(function()
        pcall(simulateFirePress)
        for _ = 1, bursts do
            if not rageRunning or not Settings.Combat.RageBot then break end
            local char = player.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then pcall(function() tool:Activate() end) end
            pcall(simulateFirePress)
            task.wait(0.07)
        end
        pcall(simulateFireRelease)
    end)
end
local function haltRageLoop()
    rageRunning = false
end
local function start()
    if MW.guard("pos") or not MW.allows("rage") then
        Settings.Combat.RageBot = false
        pcall(function() if sendNotification then sendNotification("Rage Bot", "Blocked on this game (pos check)", 2) end end)
        return
    end
    if rageRunning then return end
    rageRunning = true
    sendNotification("Rage Bot", "Active, teleporting targets", 2)
    task.spawn(function()
        local idx = 1
        while rageRunning and Settings.Combat.RageBot and not isUnloading and not _G[MW_T.unloaded] do
            local targets = getRageTargets()
            if #targets == 0 then
                task.wait(0.25)
                idx = 1
            else
                if idx > #targets then idx = 1 end
                local target = targets[idx]
                if tpRageToTarget(target) then
                    task.wait(0.05)
                    if Settings.Combat.RageShoot then rageShootBurst(6) end
                    task.wait(0.1)
                    local tc = target.Character
                    local hum = tc and tc:FindFirstChild("Humanoid")
                    if not hum or hum.Health <= 0 then
                        idx = idx + 1
                    end
                else
                    idx = idx + 1
                end
                task.wait(Settings.Combat.RageDelay or 0.12)
            end
        end
        haltRageLoop()
    end)
end
local function stop()
    haltRageLoop()
    Settings.Combat.RageBot = false
    pcall(simulateFireRelease)
end
return start, stop
end)()
