-- Trace MM2 (PlaceId 142823291)
-- Own IIFE for Luau local limit
local TraceMM2 = (function()
local TraceMM2 = {
    running = false,
    conns = {},
    roleCache = {},
    draw = {},
    chams = {},
    gunEsp = {},
    remotes = {},
    crc = nil,
    farmBusy = false,
    farmingActive = false,
    farmNoclip = {},
    lastSafeCF = nil,
    lastSafeT = 0,
    shootBusy = false,
    combatActive = false,
    namecallHooked = false,
    oldNamecall = nil,
    mouseHooked = false,
    last = { roles = 0, esp = 0, gun = 0, grab = 0, combat = 0, afk = 0, killAura = 0, autoKill = 0, autoEnd = 0, blatant = 0 },
}

local RS = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")
local Players = S.Players
local Workspace = S.Workspace
local RunService = S.RunService
local UIS = S.UserInputService
local Cam = Workspace.CurrentCamera

local function cfg()
    return Settings and Settings.MM2
end

local function addConn(c)
    if c then TraceMM2.conns[#TraceMM2.conns + 1] = c end
    return c
end

local function hrpOf(plr)
    local c = plr and plr.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function myHRP()
    return hrpOf(player)
end

local function myHum()
    local c = player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function roleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 70, 80) end
    if role == "Sheriff" or role == "Hero" then return Color3.fromRGB(70, 140, 255) end
    if role == "Unknown" then return Color3.fromRGB(160, 160, 170) end
    return Color3.fromRGB(235, 235, 240)
end

local function fireTouch(a, b)
    if typeof(firetouchinterest) ~= "function" or not a or not b then return end
    pcall(firetouchinterest, a, b, 0)
    pcall(firetouchinterest, a, b, 1)
    pcall(firetouchinterest, b, a, 0)
    pcall(firetouchinterest, b, a, 1)
end

local function find(parent, name)
    return parent and parent:FindFirstChild(name) or nil
end

function TraceMM2.refreshRemotes()
    local remotes = find(RS, "Remotes")
    local gameplay = find(remotes, "Gameplay")
    local extras = find(remotes, "Extras")
    local cs = find(RS, "ClientServices")
    local ws = find(cs, "WeaponService")
    local we = find(RS, "WeaponEvents")
    TraceMM2.remotes = {
        GetCurrentPlayerData = find(gameplay, "GetCurrentPlayerData"),
        PlayerDataChanged = find(gameplay, "PlayerDataChanged"),
        Fade = find(gameplay, "Fade") or find(RS, "Fade"),
        RoleSelect = find(gameplay, "RoleSelect") or find(RS, "RoleSelect"),
        RoundEndFade = find(gameplay, "RoundEndFade"),
        RoundStart = find(gameplay, "RoundStart"),
        CoinsStarted = find(gameplay, "CoinsStarted"),
        GetCoin = find(gameplay, "GetCoin"),
        CoinCollected = find(gameplay, "CoinCollected"),
        GiveWeapon = find(gameplay, "GiveWeapon"),
        EliminatePlayer = find(gameplay, "EliminatePlayer"),
        GetPlayerData = find(extras, "GetPlayerData") or find(RS, "GetPlayerData"),
        GunFired = find(ws, "GunFired"),
        GunBeam = find(we, "GunBeam"),
    }
    if not TraceMM2.crc then
        local modules = find(RS, "Modules")
        local mod = find(modules, "CurrentRoundClient")
        if mod then
            local ok, res = pcall(require, mod)
            if ok then TraceMM2.crc = res end
        end
    end
    if not TraceMM2.WeaponService and cs then
        local wsm = find(cs, "WeaponService")
        if wsm and wsm:IsA("ModuleScript") then
            local ok, res = pcall(require, wsm)
            if ok then TraceMM2.WeaponService = res end
        end
    end
end

function TraceMM2.applyRoleData(data)
    if type(data) ~= "table" then return end
    for name, info in pairs(data) do
        local key = tostring(name)
        if type(info) == "table" then
            TraceMM2.roleCache[key] = {
                Role = info.Role or "Innocent",
                Dead = info.Dead == true,
                Knife = info.Knife,
                Gun = info.Gun,
            }
        elseif type(info) == "string" then
            TraceMM2.roleCache[key] = { Role = info, Dead = false }
        end
    end
end

function TraceMM2.refreshRoles()
    TraceMM2.refreshRemotes()
    local data
    local crc = TraceMM2.crc
    if crc then
        if type(crc.GetLatestPlayerData) == "function" then
            local ok, res = pcall(crc.GetLatestPlayerData, crc)
            if ok and type(res) == "table" and next(res) then data = res end
        end
        if not data and type(crc.PlayerData) == "table" and next(crc.PlayerData) then
            data = crc.PlayerData
        end
    end
    if not data then
        local r = TraceMM2.remotes.GetCurrentPlayerData
        if r then
            local ok, res = pcall(function() return r:InvokeServer() end)
            if ok and type(res) == "table" then data = res end
        end
    end
    if not data then
        local r2 = TraceMM2.remotes.GetPlayerData
        if r2 then
            local ok, res = pcall(function()
                if r2:IsA("RemoteFunction") then return r2:InvokeServer() end
                if r2:IsA("BindableFunction") then return r2:Invoke() end
            end)
            if ok and type(res) == "table" then data = res end
        end
    end
    if data then
        TraceMM2.applyRoleData(data)
        if crc then pcall(function() crc.PlayerData = data end) end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local role
            for _, bag in ipairs({ plr.Character, plr:FindFirstChildOfClass("Backpack") }) do
                if bag then
                    for _, t in ipairs(bag:GetChildren()) do
                        if t:IsA("Tool") then
                            local n = string.lower(t.Name)
                            if string.find(n, "gun", 1, true) then role = "Sheriff"
                            elseif string.find(n, "knife", 1, true) then role = "Murderer" end
                        end
                    end
                end
            end
            if role then
                local e = TraceMM2.roleCache[plr.Name] or {}
                if not e.Role or e.Role == "Innocent" or e.Role == "Unknown" then
                    e.Role = role
                    TraceMM2.roleCache[plr.Name] = e
                end
            end
        end
    end
end

function TraceMM2.getRole(plr)
    if not plr then return "Innocent" end
    local crc = TraceMM2.crc
    if crc and type(crc.PlayerData) == "table" then
        local live = crc.PlayerData[plr.Name]
        if type(live) == "table" and live.Role then return live.Role end
    end
    local e = TraceMM2.roleCache[plr.Name]
    return (e and e.Role) or "Innocent"
end

function TraceMM2.isDead(plr)
    local crc = TraceMM2.crc
    if crc and type(crc.PlayerData) == "table" then
        local live = crc.PlayerData[plr.Name]
        if type(live) == "table" and live.Dead ~= nil then return live.Dead == true end
    end
    local e = TraceMM2.roleCache[plr.Name]
    return e and e.Dead == true
end

function TraceMM2.canTarget(plr)
    if not plr or plr == player then return false end
    if TraceMM2.isDead(plr) then return false end
    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return false end
    return hrpOf(plr) ~= nil
end

local function ensureDraw(plr)
    if plr == player then return nil end
    local char = plr.Character
    local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
    if not head then
        TraceMM2.destroyDraw(plr)
        return nil
    end
    local pack = TraceMM2.draw[plr]
    if pack and pack.bb and pack.bb.Parent and pack.bb.Adornee == head then
        return pack
    end
    if pack then TraceMM2.destroyDraw(plr) end
    local bb = Instance.new("BillboardGui")
    bb.Name = "TraceMM2RoleESP"
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 220, 0, 42)
    bb.StudsOffset = Vector3.new(0, 2.85, 0)
    bb.MaxDistance = 650
    bb.Adornee = head
    bb.Parent = head
    local holder = Instance.new("Frame")
    holder.Name = "Holder"
    holder.Size = UDim2.new(1, 0, 1, 0)
    holder.BackgroundTransparency = 1
    holder.Parent = bb
    local name = Instance.new("TextLabel")
    name.Name = "Name"
    name.BackgroundTransparency = 1
    name.Size = UDim2.new(1, 0, 0, 24)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 18
    name.TextStrokeTransparency = 0.35
    name.TextStrokeColor3 = Color3.new(0, 0, 0)
    name.Text = plr.DisplayName
    name.Parent = holder
    local role = Instance.new("TextLabel")
    role.Name = "Role"
    role.BackgroundTransparency = 1
    role.Size = UDim2.new(1, 0, 0, 16)
    role.Position = UDim2.new(0, 0, 0, 22)
    role.Font = Enum.Font.GothamMedium
    role.TextSize = 12
    role.TextStrokeTransparency = 0.45
    role.TextStrokeColor3 = Color3.new(0, 0, 0)
    role.Text = ""
    role.Parent = holder
    pack = { bb = bb, name = name, role = role }
    TraceMM2.draw[plr] = pack
    return pack
end

function TraceMM2.destroyDraw(plr)
    local pack = TraceMM2.draw[plr]
    if not pack then return end
    pcall(function() if pack.bb then pack.bb:Destroy() end end)
    TraceMM2.draw[plr] = nil
end

function TraceMM2.refreshESP()
    local c = cfg()
    local on = c and c.NameESP
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player or not on then
            TraceMM2.destroyDraw(plr)
        else
            local pack = ensureDraw(plr)
            if pack then
                local role = TraceMM2.getRole(plr)
                local dead = TraceMM2.isDead(plr)
                local col = roleColor(role)
                if dead then col = Color3.fromRGB(90, 90, 100) end
                pack.name.TextColor3 = col
                pack.name.Text = plr.DisplayName
                pack.role.TextColor3 = col
                pack.role.Text = dead and "DEAD" or string.upper(role)
            end
        end
    end
    for plr in pairs(TraceMM2.draw) do
        if not plr.Parent then TraceMM2.destroyDraw(plr) end
    end
end

function TraceMM2.clearChams()
    for plr, hl in pairs(TraceMM2.chams) do
        pcall(function() if hl then hl:Destroy() end end)
        TraceMM2.chams[plr] = nil
    end
end

function TraceMM2.refreshChams()
    local c = cfg()
    if not c or not c.PlayerChams then
        TraceMM2.clearChams()
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local col = roleColor(TraceMM2.getRole(plr))
            local hl = TraceMM2.chams[plr]
            if hl and hl.Parent and hl.Adornee == plr.Character then
                hl.FillColor = col
                hl.OutlineColor = col
            else
                if hl then pcall(function() hl:Destroy() end) end
                local ok, created = pcall(function()
                    local h = Instance.new("Highlight")
                    h.Adornee = plr.Character
                    h.FillColor = col
                    h.OutlineColor = col
                    h.FillTransparency = 0.55
                    h.OutlineTransparency = 0.2
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = plr.Character
                    return h
                end)
                if ok then TraceMM2.chams[plr] = created end
            end
        end
    end
end

function TraceMM2.clearGunEsp()
    for part, pack in pairs(TraceMM2.gunEsp) do
        pcall(function()
            if pack.hl then pack.hl:Destroy() end
            if pack.box then pack.box:Destroy() end
        end)
        TraceMM2.gunEsp[part] = nil
    end
end

function TraceMM2.refreshGunEsp()
    local c = cfg()
    if not c or not c.GunESP then
        TraceMM2.clearGunEsp()
        return
    end
    local drop = Workspace:FindFirstChild("GunDrop")
    local part = drop and (drop:IsA("BasePart") and drop or drop:FindFirstChildWhichIsA("BasePart", true))
    if not part then
        TraceMM2.clearGunEsp()
        return
    end
    if not TraceMM2.gunEsp[part] then
        local pack = {}
        pcall(function()
            local hl = Instance.new("Highlight")
            hl.Adornee = part
            hl.FillColor = Color3.fromRGB(255, 215, 70)
            hl.OutlineColor = Color3.fromRGB(255, 240, 160)
            hl.FillTransparency = 0.4
            hl.Parent = part
            pack.hl = hl
        end)
        TraceMM2.gunEsp[part] = pack
    end
    for p in pairs(TraceMM2.gunEsp) do
        if p ~= part or not p.Parent then
            local pack = TraceMM2.gunEsp[p]
            pcall(function() if pack.hl then pack.hl:Destroy() end end)
            TraceMM2.gunEsp[p] = nil
        end
    end
end

function TraceMM2.setFarmNoclip(on)
    local char = player.Character
    if not char then return end
    if on then
        TraceMM2.farmNoclip = {}
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                TraceMM2.farmNoclip[d] = d.CanCollide
                d.CanCollide = false
            end
        end
    else
        for part, was in pairs(TraceMM2.farmNoclip) do
            if part and part.Parent then part.CanCollide = was end
        end
        TraceMM2.farmNoclip = {}
    end
end

local function listCoins()
    local out = {}
    local container = Workspace:FindFirstChild("CoinContainer", true)
    local function add(coin)
        if not coin or not coin:IsA("BasePart") then return end
        if coin.Name ~= "Coin_Server" then return end
        local collected = coin:GetAttribute("Collected")
        if collected == true or collected == "true" then return end
        local visual = coin:FindFirstChild("CoinVisual")
        if visual then
            local vc = visual:GetAttribute("Collected")
            if vc == true or vc == "true" then return end
        end
        out[#out + 1] = coin
    end
    if container then
        for _, child in ipairs(container:GetDescendants()) do
            if child.Name == "Coin_Server" then add(child) end
        end
    end
    if #out == 0 then
        pcall(function()
            for _, visual in ipairs(game:GetService("CollectionService"):GetTagged("CoinVisual")) do
                if visual and visual.Parent and visual.Parent.Name == "Coin_Server" then
                    add(visual.Parent)
                end
            end
        end)
    end
    if #out == 0 then
        for _, inst in ipairs(Workspace:GetDescendants()) do
            if inst.Name == "Coin_Server" then add(inst) end
        end
    end
    return out
end

local function pickCoin(fromPos)
    local coins = listCoins()
    if #coins == 0 then return nil end
    local mode = (cfg() and cfg().FarmMode) or "Nearest"
    if mode == "Randomize" then return coins[math.random(1, #coins)] end
    local best, bestDist
    for _, coin in ipairs(coins) do
        local d = (coin.Position - fromPos).Magnitude
        local better = mode == "Furthest" and (not bestDist or d > bestDist)
            or mode ~= "Furthest" and (not bestDist or d < bestDist)
        if mode == "Safe Nearby" then
            better = d <= 90 and (not bestDist or d < bestDist)
        end
        if better then best, bestDist = coin, d end
    end
    return best or coins[1]
end

local function fireGetCoin(coin)
    local getCoin = TraceMM2.remotes.GetCoin
    if not getCoin then return end
    local visual = coin:FindFirstChild("CoinVisual")
    local id = coin:GetAttribute("CoinID") or (visual and visual:GetAttribute("CoinID"))
    if id ~= nil then pcall(function() getCoin:FireServer(id) end) end
    pcall(function() getCoin:FireServer(coin) end)
    pcall(function() getCoin:FireServer(coin.Position) end)
end

function TraceMM2.collectCoin(coin)
    local root = myHRP()
    if not root or not coin then return end
    TraceMM2.farmingActive = true
    TraceMM2.setFarmNoclip(true)
    local visual = coin:FindFirstChild("CoinVisual")
    local touchPos = coin.Position + Vector3.new(0, 1.5, 0)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    root.CFrame = CFrame.new(touchPos)
    RunService.Heartbeat:Wait()
    root = myHRP()
    if not root or not coin.Parent then
        if not (cfg() and cfg().AutoFarm) then
            TraceMM2.setFarmNoclip(false)
            TraceMM2.farmingActive = false
        end
        return
    end
    local t0 = tick()
    while TraceMM2.running and cfg() and cfg().AutoFarm and coin.Parent and coin.Name == "Coin_Server" and (tick() - t0) < 1.2 do
        root = myHRP()
        if not root then break end
        local collected = coin:GetAttribute("Collected")
        if collected == true or collected == "true" then break end
        if visual then
            local vc = visual:GetAttribute("Collected")
            if vc == true or vc == "true" then break end
        end
        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = CFrame.new(coin.Position + Vector3.new(0, 1.5, 0))
        fireTouch(root, coin)
        if visual and visual:IsA("BasePart") then fireTouch(root, visual) end
        local ti = coin:FindFirstChildWhichIsA("TouchTransmitter")
        if ti and ti.Parent and ti.Parent:IsA("BasePart") then fireTouch(root, ti.Parent) end
        fireGetCoin(coin)
        RunService.Stepped:Wait()
    end
    if not (cfg() and cfg().AutoFarm) then
        TraceMM2.setFarmNoclip(false)
        TraceMM2.farmingActive = false
    end
end

function TraceMM2.farmLoop()
    if TraceMM2.farmBusy then return end
    TraceMM2.farmBusy = true
    task.spawn(function()
        while TraceMM2.running and cfg() and cfg().AutoFarm and not isUnloading and not _G[MW_T.unloaded] do
            TraceMM2.refreshRemotes()
            local root = myHRP()
            if root then
                TraceMM2.setFarmNoclip(true)
                TraceMM2.farmingActive = true
                local coin = pickCoin(root.Position)
                if coin then
                    pcall(TraceMM2.collectCoin, coin)
                    task.wait(math.max((cfg() and cfg().FarmDelay) or 0.2, 0.1))
                else
                    task.wait(0.35)
                end
            else
                task.wait(0.3)
            end
        end
        TraceMM2.setFarmNoclip(false)
        TraceMM2.farmingActive = false
        TraceMM2.farmBusy = false
    end)
end

function TraceMM2.tickGrabGun()
    local c = cfg()
    if not c or not c.AutoGrabGun then return end
    if tick() - TraceMM2.last.grab < 0.25 then return end
    TraceMM2.last.grab = tick()
    local root = myHRP()
    local drop = Workspace:FindFirstChild("GunDrop")
    local part = drop and (drop:IsA("BasePart") and drop or drop:FindFirstChildWhichIsA("BasePart", true))
    if not root or not part then return end
    local cf = root.CFrame * CFrame.new(0, 1, -2)
    pcall(function()
        part.CFrame = cf
        part.AssemblyLinearVelocity = Vector3.zero
    end)
    fireTouch(root, part)
    local gw = TraceMM2.remotes.GiveWeapon
    if gw then
        pcall(function() gw:FireServer() end)
        pcall(function() gw:FireServer(part) end)
    end
end

function TraceMM2.getMurdererRoot()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and TraceMM2.getRole(plr) == "Murderer" and TraceMM2.canTarget(plr) then
            local r = hrpOf(plr)
            if r then return r, plr end
        end
    end
end

function TraceMM2.silentAimCFrame()
    local tRoot = select(1, TraceMM2.getMurdererRoot())
    if not tRoot then
        local best, bestDist
        local root = myHRP()
        if not root then return nil end
        for _, plr in ipairs(Players:GetPlayers()) do
            if TraceMM2.canTarget(plr) then
                local r = hrpOf(plr)
                if r then
                    local d = (r.Position - root.Position).Magnitude
                    if not bestDist or d < bestDist then best, bestDist = r, d end
                end
            end
        end
        tRoot = best
    end
    if not tRoot then return nil end
    local vel = tRoot.AssemblyLinearVelocity
    return CFrame.new(tRoot.Position + Vector3.new(vel.X * 0.12, 0, vel.Z * 0.12))
end

function TraceMM2.invokeEliminate(plr)
    local elim = TraceMM2.remotes.EliminatePlayer
    if not elim or not plr then return false end
    local ok1 = pcall(function() elim:InvokeServer(plr) end)
    local ok2 = pcall(function() elim:InvokeServer(plr.Name) end)
    local ok3 = pcall(function() elim:InvokeServer(plr.UserId) end)
    return ok1 or ok2 or ok3
end

function TraceMM2.equipKnife()
    local char = player.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and string.find(string.lower(t.Name), "knife", 1, true) then
                return t
            end
        end
    end
    local bag = player:FindFirstChildOfClass("Backpack")
    local hum = myHum()
    if not bag or not hum then return nil end
    for _, t in ipairs(bag:GetChildren()) do
        if t:IsA("Tool") and string.find(string.lower(t.Name), "knife", 1, true) then
            pcall(function() hum:EquipTool(t) end)
            return t
        end
    end
    return nil
end

function TraceMM2.tryKnifeHit(plr)
    local root = myHRP()
    local tRoot = hrpOf(plr)
    if not root or not tRoot then return false end
    local knife = TraceMM2.equipKnife()
    if not knife then return false end
    TraceMM2.combatActive = true
    local old = root.CFrame
    root.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 0.4, 1.2), tRoot.Position)
    pcall(function() knife:Activate() end)
    local handle = knife:FindFirstChild("Handle") or knife:FindFirstChildWhichIsA("BasePart")
    if handle then
        fireTouch(handle, tRoot)
        fireTouch(tRoot, handle)
    end
    pcall(function()
        VU:CaptureController()
        VU:ClickButton1(Vector2.new())
    end)
    task.wait(0.03)
    if root.Parent then root.CFrame = old end
    TraceMM2.combatActive = false
    return true
end

function TraceMM2.shootMurderer(manual)
    if TraceMM2.shootBusy then return end
    TraceMM2.refreshRemotes()
    local role = TraceMM2.getRole(player)
    local hasGun = false
    for _, bag in ipairs({ player.Character, player:FindFirstChildOfClass("Backpack") }) do
        if bag then
            for _, t in ipairs(bag:GetChildren()) do
                if t:IsA("Tool") and string.find(string.lower(t.Name), "gun", 1, true) then hasGun = true end
            end
        end
    end
    if not (role == "Sheriff" or role == "Hero" or hasGun) then return end
    local root = myHRP()
    local target, plr = TraceMM2.getMurdererRoot()
    if not root or not target then return end
    if (target.Position - root.Position).Magnitude > 220 and not manual then return end
    TraceMM2.shootBusy = true
    TraceMM2.combatActive = true
    local gun
    local hum = myHum()
    if player.Character then
        for _, t in ipairs(player.Character:GetChildren()) do
            if t:IsA("Tool") and string.find(string.lower(t.Name), "gun", 1, true) then gun = t end
        end
    end
    if not gun then
        local bag = player:FindFirstChildOfClass("Backpack")
        if bag and hum then
            for _, t in ipairs(bag:GetChildren()) do
                if t:IsA("Tool") and string.find(string.lower(t.Name), "gun", 1, true) then
                    pcall(function() hum:EquipTool(t) end)
                    gun = t
                    break
                end
            end
            task.wait(0.05)
            root = myHRP() or root
        end
    end
    local hitCF = TraceMM2.silentAimCFrame() or CFrame.new(target.Position)
    local originCF = root.CFrame
    local att = root:FindFirstChild("GunRaycastAttachment")
    if att then originCF = att.WorldCFrame end
    pcall(function()
        root.CFrame = CFrame.lookAt(
            root.Position,
            Vector3.new(target.Position.X, root.Position.Y, target.Position.Z)
        )
    end)
    local gf = TraceMM2.remotes.GunFired
    if gf then
        pcall(function() gf:FireServer(hitCF) end)
        pcall(function() gf:FireServer(target.Position) end)
        pcall(function() gf:FireServer(hitCF, target) end)
        pcall(function() gf:FireServer(target.Position, target) end)
    end
    local gb = TraceMM2.remotes.GunBeam
    if gb then
        pcall(function() gb:FireServer(hitCF) end)
        pcall(function() gb:FireServer(root.Position, target.Position) end)
    end
    if gun then
        local shoot = gun:FindFirstChild("Shoot") or gun:FindFirstChild("Shoot", true)
        if shoot and shoot:IsA("RemoteEvent") then
            pcall(function() shoot:FireServer(originCF, hitCF) end)
            pcall(function() shoot:FireServer(originCF, hitCF.Position) end)
        end
        pcall(function() gun:Activate() end)
    end
    pcall(function()
        VU:CaptureController()
        VU:ClickButton1(Vector2.new())
    end)
    TraceMM2.invokeEliminate(plr)
    task.delay(0.25, function()
        TraceMM2.shootBusy = false
        TraceMM2.combatActive = false
    end)
end

function TraceMM2.tickKillAura()
    local c = cfg()
    if not c or not c.KillAura then return end
    if tick() - TraceMM2.last.killAura < 0.16 then return end
    TraceMM2.last.killAura = tick()
    if TraceMM2.getRole(player) ~= "Murderer" then return end
    local root = myHRP()
    if not root then return end
    local radius = math.max(1, tonumber(c.AuraDistance) or 5)
    for _, plr in ipairs(Players:GetPlayers()) do
        if TraceMM2.canTarget(plr) then
            local tRoot = hrpOf(plr)
            if tRoot and (tRoot.Position - root.Position).Magnitude <= radius then
                if not TraceMM2.invokeEliminate(plr) then
                    task.spawn(TraceMM2.tryKnifeHit, plr)
                end
            end
        end
    end
end

function TraceMM2.tickAntiFling()
    local c = cfg()
    if not c or not c.AntiFling then return end
    if TraceMM2.farmingActive or TraceMM2.combatActive or TraceMM2.shootBusy then return end
    local root = myHRP()
    if not root then return end
    local mag = root.AssemblyLinearVelocity.Magnitude
    if mag < 65 then
        TraceMM2.lastSafeCF = root.CFrame
        TraceMM2.lastSafeT = tick()
        return
    end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    if TraceMM2.lastSafeCF and (tick() - TraceMM2.lastSafeT) < 3 then
        root.CFrame = TraceMM2.lastSafeCF
    end
end

function TraceMM2.installSilentAim()
    TraceMM2.refreshRemotes()
    if not TraceMM2.mouseHooked and TraceMM2.WeaponService and type(TraceMM2.WeaponService.GetMouseTargetCFrame) == "function" then
        TraceMM2.mouseHooked = true
        local ws = TraceMM2.WeaponService
        local oldGet = ws.GetMouseTargetCFrame
        ws.GetMouseTargetCFrame = function(self, ...)
            local c = cfg()
            if c and c.SilentAim then
                local role = TraceMM2.getRole(player)
                if role == "Sheriff" or role == "Hero" then
                    local aim = TraceMM2.silentAimCFrame()
                    if aim then return aim end
                end
            end
            return oldGet(self, ...)
        end
    end
    if TraceMM2.namecallHooked or not hookmetamethod or not getnamecallmethod then return end
    TraceMM2.namecallHooked = true
    TraceMM2.oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = { ... }
        local isCaller = checkcaller and checkcaller() or false
        local c = cfg()
        if not isCaller and c and c.SilentAim and method == "FireServer" and typeof(self) == "Instance" then
            local role = TraceMM2.getRole(player)
            if role == "Sheriff" or role == "Hero" then
                local aim = TraceMM2.silentAimCFrame()
                if aim then
                    local n = self.Name
                    if n == "Shoot" and #args >= 2 then
                        args[2] = typeof(args[2]) == "Vector3" and aim.Position or aim
                        return TraceMM2.oldNamecall(self, unpack(args))
                    end
                    if n == "GunFired" or n == "GunBeam" or self == TraceMM2.remotes.GunFired or self == TraceMM2.remotes.GunBeam then
                        for i, arg in ipairs(args) do
                            if typeof(arg) == "Vector3" then
                                args[i] = aim.Position
                            elseif typeof(arg) == "CFrame" then
                                args[i] = aim
                            elseif typeof(arg) == "Instance" and arg:IsA("BasePart") then
                                local tRoot = select(1, TraceMM2.getMurdererRoot())
                                if tRoot then args[i] = tRoot end
                            end
                        end
                        return TraceMM2.oldNamecall(self, unpack(args))
                    end
                end
            end
        end
        return TraceMM2.oldNamecall(self, ...)
    end)
end

function TraceMM2.bindEvents()
    TraceMM2.refreshRemotes()
    local function onRoles(data)
        if type(data) == "table" then TraceMM2.applyRoleData(data) else TraceMM2.refreshRoles() end
    end
    local pdc = TraceMM2.remotes.PlayerDataChanged
    if pdc then addConn(pdc.OnClientEvent:Connect(onRoles)) end
    local fade = TraceMM2.remotes.Fade
    if fade then addConn(fade.OnClientEvent:Connect(onRoles)) end
    local rs = TraceMM2.remotes.RoleSelect
    if rs then
        addConn(rs.OnClientEvent:Connect(function(role)
            if type(role) == "string" then
                TraceMM2.roleCache[player.Name] = TraceMM2.roleCache[player.Name] or {}
                TraceMM2.roleCache[player.Name].Role = role
            end
        end))
    end
    local ref = TraceMM2.remotes.RoundEndFade
    if ref then
        addConn(ref.OnClientEvent:Connect(function()
            for _, e in pairs(TraceMM2.roleCache) do e.Role = "Unknown" end
            task.spawn(function()
                for _ = 1, 10 do
                    task.wait(0.4)
                    TraceMM2.refreshRoles()
                end
            end)
        end))
    end
    local roundStart = TraceMM2.remotes.RoundStart
    if roundStart then
        addConn(roundStart.OnClientEvent:Connect(function()
            task.spawn(function()
                for _ = 1, 10 do
                    task.wait(0.35)
                    TraceMM2.refreshRoles()
                end
            end)
        end))
    end
    local crc = TraceMM2.crc
    if crc and crc.PlayerDataChanged and crc.PlayerDataChanged.Event then
        addConn(crc.PlayerDataChanged.Event:Connect(function()
            if type(crc.PlayerData) == "table" then TraceMM2.applyRoleData(crc.PlayerData) end
        end))
    end
    addConn(Players.PlayerRemoving:Connect(function(plr)
        TraceMM2.destroyDraw(plr)
        local hl = TraceMM2.chams[plr]
        if hl then pcall(function() hl:Destroy() end); TraceMM2.chams[plr] = nil end
    end))
end

function TraceMM2.tick(dt)
    if not TraceMM2.running then return end
    if not (MW.isMM2 or (game.PlaceId == (MW.places and MW.places.MM2))) then return end
    local c = cfg()
    if not c then return end
    local now = tick()
    TraceMM2.tickAntiFling()

    if now - TraceMM2.last.roles >= 0.5 then
        TraceMM2.last.roles = now
        pcall(TraceMM2.refreshRoles)
    end
    -- ESP every frame for smooth Drawing
    pcall(TraceMM2.refreshESP)
    if now - TraceMM2.last.gun >= 0.4 then
        TraceMM2.last.gun = now
        if c.PlayerChams then pcall(TraceMM2.refreshChams) else TraceMM2.clearChams() end
        if c.GunESP then pcall(TraceMM2.refreshGunEsp) else TraceMM2.clearGunEsp() end
    end

    TraceMM2.last.combat = (TraceMM2.last.combat or 0) + (dt or 0.016)
    if TraceMM2.last.combat >= 0.25 then
        TraceMM2.last.combat = 0
        TraceMM2.tickGrabGun()
        TraceMM2.tickKillAura()
        if c.AutoShootMurderer then TraceMM2.shootMurderer(false) end
        if c.AutoKillAll and TraceMM2.getRole(player) == "Murderer" then
            if now - TraceMM2.last.autoKill >= 0.45 then
                TraceMM2.last.autoKill = now
                for _, plr in ipairs(Players:GetPlayers()) do
                    if TraceMM2.canTarget(plr) then
                        if not TraceMM2.invokeEliminate(plr) then
                            task.spawn(TraceMM2.tryKnifeHit, plr)
                        end
                    end
                end
            end
        end
        if c.AutoEndRound and now - TraceMM2.last.autoEnd >= 0.55 then
            TraceMM2.last.autoEnd = now
            local role = TraceMM2.getRole(player)
            if role == "Murderer" then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if TraceMM2.canTarget(plr) then
                        if not TraceMM2.invokeEliminate(plr) then
                            task.spawn(TraceMM2.tryKnifeHit, plr)
                        end
                    end
                end
            elseif role == "Sheriff" or role == "Hero" then
                local _, m = TraceMM2.getMurdererRoot()
                if m then TraceMM2.shootMurderer(true) end
            end
        end
        if c.KillMurdererBlatant then
            local _, m = TraceMM2.getMurdererRoot()
            local root = myHRP()
            if m and root then
                local t = hrpOf(m)
                if t then
                    root.CFrame = CFrame.new(t.Position + Vector3.new(0, 1, 3), t.Position)
                    TraceMM2.shootMurderer(true)
                end
            end
        end
    end

    if c.AutoFarm and not TraceMM2.farmBusy then
        TraceMM2.farmLoop()
    end
    if c.AntiAFK and now - TraceMM2.last.afk >= 55 then
        TraceMM2.last.afk = now
        pcall(function() VU:CaptureController(); VU:ClickButton2(Vector2.new()) end)
    end
end

function TraceMM2.start()
    if TraceMM2.running then return end
    TraceMM2.running = true
    Settings.MM2 = Settings.MM2 or {}
    addConn(RunService.Heartbeat:Connect(function(dt)
        if isUnloading or _G[MW_T.unloaded] then return end
        pcall(TraceMM2.tick, dt)
    end))
    addConn(UIS.InputBegan:Connect(function(input, gp)
        if waitingForKey or gp or not TraceMM2.running then return end
        local shootKey = restoreEnumBind(cfg() and cfg().ShootKey, Enum.KeyCode.Q)
        if inputMatchesBind(input, shootKey) then
            TraceMM2.shootMurderer(true)
        end
    end))
    task.spawn(function()
        TraceMM2.refreshRemotes()
        TraceMM2.bindEvents()
        TraceMM2.refreshRoles()
        pcall(TraceMM2.installSilentAim)
        pcall(function()
            if sendNotification then sendNotification("MM2", "Kit running", 3) end
        end)
        warn("[Melo 🍃] MM2 kit started")
    end)
end

function TraceMM2.stop()
    TraceMM2.running = false
    if Settings.MM2 then Settings.MM2.AutoFarm = false end
    TraceMM2.setFarmNoclip(false)
    TraceMM2.farmingActive = false
    TraceMM2.farmBusy = false
    for _, c in ipairs(TraceMM2.conns) do pcall(function() c:Disconnect() end) end
    TraceMM2.conns = {}
    for plr in pairs(TraceMM2.draw) do TraceMM2.destroyDraw(plr) end
    TraceMM2.clearGunEsp()
    TraceMM2.clearChams()
end

return TraceMM2
end)()
MW.TraceMM2 = TraceMM2

-- Phantom Forces (PlaceId 292439477)
-- Resolve via getrenv.shared / ClientLoader / getgc require.
-- Bodies live on entry._thirdPersonObject (_characterHash / _torso), not Player.Character.
local TracePF = (function()
local TracePF = {
    running = false,
    conns = {},
    pfRequire = nil,
    repl = nil,
    entries = nil,
    network = nil,
    bulletObject = nil,
    firearmObject = nil,
    characterObject = nil,
    publicSettings = nil,
    lastSoft = 0,
    lastAfk = 0,
    lastResolve = 0,
    lastSilentTry = 0,
    lastAim = 0,
    resolveTries = 0,
    cache = {},
    status = "boot",
    silentStatus = "off",
    silentHooks = {
        network = false,
        bullet = false,
        fireRound = false,
        getRootPart = false,
    },
    _old = {},
    _spoofing = false,
    _inFire = false,
    _oldOffsets = {},
    _roll = { miss = 1, head = 1, next = 0 },
    _aim = { pos = nil, vel = nil, entry = nil },
    _softGuns = {},
    _softScanAt = 0,
}

local Players = S.Players
local RunService = S.RunService
local VU = game:GetService("VirtualUser")
local LocalPlayer = player
local ZERO = Vector3.new(0, 0, 0)
local DOT = ZERO.Dot

local function cfg()
    return Settings and Settings.PF
end

local function addConn(c)
    if c then TracePF.conns[#TracePF.conns + 1] = c end
    return c
end

local function wrap(fn)
    if type(newcclosure) == "function" then
        local ok, w = pcall(newcclosure, fn)
        if ok and type(w) == "function" then return w end
    end
    return fn
end

local function dbgGetInfo(fn, level)
    if type(debug) ~= "table" or type(debug.getinfo) ~= "function" then return nil end
    local ok, info = pcall(debug.getinfo, fn or level, level and "n" or nil)
    if ok then return info end
    if level then
        ok, info = pcall(debug.getinfo, level, "n")
        if ok then return info end
    end
    return nil
end

local function dbgGetUpvalue(fn, idx)
    if type(debug) ~= "table" then return nil end
    if type(debug.getupvalue) == "function" then
        local ok, a, b = pcall(debug.getupvalue, fn, idx)
        if ok then
            if b ~= nil then return b end
            return a
        end
    end
    if type(debug.getupvalues) == "function" then
        local ok, ups = pcall(debug.getupvalues, fn)
        if ok and type(ups) == "table" then return ups[idx] end
    end
    return nil
end

local function cloneFn(fn)
    if type(fn) ~= "function" then return fn end
    if type(clonefunction) == "function" then
        local ok, c = pcall(clonefunction, fn)
        if ok and type(c) == "function" then return c end
    end
    return fn
end

local function findPfRequire()
    pcall(function()
        if type(getrenv) == "function" then
            local sharedTbl = rawget(getrenv(), "shared")
            if type(sharedTbl) == "table" then
                local req = rawget(sharedTbl, "require")
                if type(req) == "function" then
                    TracePF.pfRequire = req
                end
            end
        end
    end)
    if TracePF.pfRequire then return TracePF.pfRequire end

    pcall(function()
        if type(getnilinstances) ~= "function" or type(getsenv) ~= "function" then return end
        local list = getnilinstances()
        for i = 1, #list do
            local inst = list[i]
            if typeof(inst) == "Instance" and inst.Name == "ClientLoader" then
                local env = getsenv(inst)
                if type(env) == "table" and type(env.shared) == "table" and type(env.shared.require) == "function" then
                    TracePF.pfRequire = env.shared.require
                    return
                end
            end
        end
    end)
    if TracePF.pfRequire then return TracePF.pfRequire end

    pcall(function()
        if type(getgc) ~= "function" then return end
        local list = getgc(false)
        for i = 1, #list do
            local v = list[i]
            if type(v) == "function" then
                local info = dbgGetInfo(v)
                if info and info.name == "require" then
                    local isLc = true
                    if type(islclosure) == "function" then
                        local ok, res = pcall(islclosure, v)
                        isLc = ok and res == true
                    end
                    if isLc then
                        TracePF.pfRequire = v
                        return
                    end
                end
            end
        end
    end)
    return TracePF.pfRequire
end

local function requirePf(name)
    local req = TracePF.pfRequire or findPfRequire()
    if type(req) ~= "function" then return nil end
    local ok, mod = pcall(req, name)
    if ok and type(mod) == "table" then return mod end
    return nil
end

local function findReplFromGc()
    if type(getgc) ~= "function" then return nil end
    local ok, list = pcall(getgc, true)
    if not ok or type(list) ~= "table" then return nil end
    for i = 1, #list do
        local v = list[i]
        if type(v) == "table"
            and type(rawget(v, "getEntry")) == "function"
            and type(rawget(v, "operateOnAllEntries")) == "function"
            and (type(rawget(v, "addEntry")) == "function" or type(rawget(v, "setHighMs")) == "function") then
            return v
        end
    end
    return nil
end

local function findModuleFromGc(pred)
    if type(getgc) ~= "function" then return nil end
    local ok, list = pcall(getgc, true)
    if not ok or type(list) ~= "table" then return nil end
    for i = 1, #list do
        local v = list[i]
        if type(v) == "table" and pred(v) then return v end
    end
    return nil
end

local function pullEntriesTable(repl)
    if type(repl) ~= "table" then return nil end
    local function looksLikeEntries(t)
        if type(t) ~= "table" then return false end
        local n = 0
        for k, v in pairs(t) do
            n = n + 1
            if typeof(k) == "Instance" and k:IsA("Player") and type(v) == "table" then
                return true
            end
            if n >= 12 then break end
        end
        return false
    end
    local function fromFn(fn)
        if type(fn) ~= "function" then return nil end
        for i = 1, 8 do
            local ups = dbgGetUpvalue(fn, i)
            if looksLikeEntries(ups) then return ups end
        end
        return nil
    end
    local ups = fromFn(rawget(repl, "getEntry")) or fromFn(rawget(repl, "addEntry")) or fromFn(rawget(repl, "operateOnAllEntries"))
    if ups then return ups end
    pcall(function()
        local req = TracePF.pfRequire
        if type(req) ~= "function" then return end
        local cacheRoot = dbgGetUpvalue(req, 1)
        if type(cacheRoot) == "table" and type(cacheRoot._cache) == "table" then
            local pack = rawget(cacheRoot._cache, "ReplicationInterface")
            if type(pack) == "table" and type(pack.module) == "table" then
                TracePF.repl = pack.module
                ups = fromFn(rawget(pack.module, "getEntry"))
            end
        end
    end)
    return ups
end

local function cacheExtraModules()
    if not TracePF.network then
        TracePF.network = requirePf("NetworkClient") or findModuleFromGc(function(v)
            return type(rawget(v, "send")) == "function" and type(rawget(v, "receive")) == "function"
        end)
    end
    if not TracePF.bulletObject then
        TracePF.bulletObject = requirePf("BulletObject") or findModuleFromGc(function(v)
            return type(rawget(v, "new")) == "function" and type(rawget(v, "step")) == "function"
        end)
    end
    if not TracePF.firearmObject then
        TracePF.firearmObject = requirePf("FirearmObject") or findModuleFromGc(function(v)
            return type(rawget(v, "fireRound")) == "function" and type(rawget(v, "shoot")) == "function"
        end)
    end
    if not TracePF.characterObject then
        TracePF.characterObject = requirePf("CharacterObject") or findModuleFromGc(function(v)
            return type(rawget(v, "getRootPart")) == "function" and type(rawget(v, "getTorso")) == "function"
        end)
    end
    if not TracePF.publicSettings then
        TracePF.publicSettings = requirePf("PublicSettings")
    end
end

function TracePF.refreshModules(force)
    if TracePF.repl and not force then
        if not TracePF.entries then
            TracePF.entries = pullEntriesTable(TracePF.repl)
        end
        if TracePF.repl and TracePF.entries then
            TracePF.status = "ready"
        else
            TracePF.status = "repl-no-entries"
        end
        return true
    end
    local now = tick()
    if not force and (now - (TracePF.lastResolve or 0)) < 0.75 and TracePF.status ~= "boot" then
        return TracePF.repl ~= nil
    end
    TracePF.lastResolve = now
    findPfRequire()
    if not TracePF.repl then
        TracePF.repl = requirePf("ReplicationInterface") or findReplFromGc()
    end
    if TracePF.repl and not TracePF.entries then
        TracePF.entries = pullEntriesTable(TracePF.repl)
    end
    if force or not TracePF.firearmObject or not TracePF.characterObject then
        cacheExtraModules()
    end
    if TracePF.repl and TracePF.entries then
        TracePF.status = "ready"
        return true
    end
    if TracePF.repl then
        TracePF.status = "repl-no-entries"
        return true
    end
    TracePF.status = "waiting"
    return false
end

local function entryOf(plr)
    if not plr then return nil end
    if type(TracePF.entries) == "table" then
        local e = rawget(TracePF.entries, plr)
        if e then return e end
    end
    if TracePF.repl and type(TracePF.repl.getEntry) == "function" then
        local ok, entry = pcall(TracePF.repl.getEntry, plr)
        if ok and entry then return entry end
        ok, entry = pcall(function() return TracePF.repl.getEntry(plr) end)
        if ok and entry then return entry end
    end
    return nil
end

local function isEnemyPlayer(plr)
    if not plr or plr == LocalPlayer then return false end
    local c = cfg()
    if c and c.TeamFilter == false then return true end
    local ok, same = pcall(function()
        if plr.Team and LocalPlayer.Team then
            return plr.Team == LocalPlayer.Team
        end
        return plr.TeamColor == LocalPlayer.TeamColor
    end)
    if ok and same then return false end
    return true
end

local function aliveEntry(entry)
    if type(entry) ~= "table" then return false end
    if rawget(entry, "_alive") == true then return true end
    local ok, alive = pcall(function()
        if type(entry.isAlive) == "function" then
            return entry:isAlive()
        end
        return false
    end)
    return ok and alive == true
end

local function getTpo(entry)
    if type(entry) ~= "table" then return nil end
    local tpo = rawget(entry, "_thirdPersonObject")
    if tpo then return tpo end
    local ok, res = pcall(function()
        if type(entry.getThirdPersonObject) == "function" then
            return entry:getThirdPersonObject()
        end
    end)
    if ok then return res end
    return nil
end

local function getHash(tpo)
    if type(tpo) ~= "table" then return nil end
    local hash = rawget(tpo, "_characterModelHash") or rawget(tpo, "_characterHash") or rawget(tpo, "_character")
    if type(hash) == "table" and (hash.Head or hash.Torso or hash.head or hash.torso) then
        return hash
    end
    local ok, res = pcall(function()
        if type(tpo.getCharacterHash) == "function" then
            return tpo:getCharacterHash()
        end
    end)
    if ok and type(res) == "table" then return res end
    return nil
end

local function partFromHash(hash, name)
    if type(hash) ~= "table" then return nil end
    local p = hash[name] or hash[string.lower(name)] or hash[string.upper(name)]
    if typeof(p) == "Instance" and p:IsA("BasePart") then return p end
    return nil
end

local function makeCharProxy(hash, model)
    local proxy = {
        Head = partFromHash(hash, "Head"),
        Torso = partFromHash(hash, "Torso"),
        ["Left Arm"] = partFromHash(hash, "Left Arm"),
        ["Right Arm"] = partFromHash(hash, "Right Arm"),
        ["Left Leg"] = partFromHash(hash, "Left Leg"),
        ["Right Leg"] = partFromHash(hash, "Right Leg"),
        HumanoidRootPart = partFromHash(hash, "Torso"),
        _model = model,
    }
    local mt = {
        __index = function(self, k)
            if k == "Parent" then return model and model.Parent end
            if k == "Name" then return model and model.Name or "PFChar" end
            if k == "FindFirstChild" then
                return function(_, name)
                    return rawget(self, name) or partFromHash(hash, name)
                end
            end
            if k == "FindFirstChildWhichIsA" then
                return function(_, className)
                    for _, v in pairs(self) do
                        if typeof(v) == "Instance" and v:IsA(className) then return v end
                    end
                end
            end
            if k == "FindFirstChildOfClass" then
                return function() return nil end
            end
            if k == "GetChildren" then
                return function()
                    local out = {}
                    for key, v in pairs(self) do
                        if typeof(v) == "Instance" then out[#out + 1] = v end
                    end
                    return out
                end
            end
            if k == "GetDescendants" then
                return function()
                    if model then return model:GetDescendants() end
                    return {}
                end
            end
            if k == "GetBoundingBox" then
                return function()
                    if model then return model:GetBoundingBox() end
                    local torso = rawget(self, "Torso")
                    if torso then return torso.CFrame, torso.Size end
                    return CFrame.new(), Vector3.new(2, 2, 1)
                end
            end
            if k == "IsA" then
                return function(_, className)
                    return className == "Model" or className == "Instance"
                end
            end
            if k == "IsDescendantOf" then
                return function(_, inst)
                    return model and model:IsDescendantOf(inst)
                end
            end
            return rawget(self, k)
        end,
    }
    return setmetatable(proxy, mt)
end

function TracePF.getEntry(plr)
    if not TracePF.repl then TracePF.refreshModules() end
    return entryOf(plr)
end

function TracePF.getModel(plr)
    if not TracePF.repl then TracePF.refreshModules() end
    local entry = entryOf(plr)
    if not aliveEntry(entry) then return nil end
    local tpo = getTpo(entry)
    local hash = getHash(tpo)
    local model = nil
    pcall(function()
        model = rawget(tpo, "_characterModel")
        if not model and type(tpo.getCharacterModel) == "function" then
            model = tpo:getCharacterModel()
        end
    end)
    if hash then
        return makeCharProxy(hash, model)
    end
    return model
end

function TracePF.getWeaponName(plr)
    local entry = entryOf(plr)
    if not entry then return nil end
    local ok, name = pcall(function()
        local tpo = getTpo(entry)
        if tpo then
            local w = rawget(tpo, "_weaponname") or rawget(tpo, "_weaponName")
            if w and w ~= "" then return tostring(w) end
        end
        local wobj = nil
        if type(entry.getWeaponObject) == "function" then
            wobj = entry:getWeaponObject()
        end
        if type(wobj) == "table" then
            return wobj.weaponName
        end
        return nil
    end)
    if ok and name and name ~= "" then return tostring(name) end
    return nil
end

function TracePF.getTeamColor(plr)
    if not plr then return nil end
    local ok, name = pcall(function()
        return plr.Team and plr.Team.Name
    end)
    if not ok or not name then return nil end
    local lower = string.lower(tostring(name))
    if lower:find("ghost", 1, true) then
        return Color3.fromRGB(255, 140, 60)
    end
    if lower:find("phantom", 1, true) then
        return Color3.fromRGB(70, 150, 255)
    end
    return nil
end

function TracePF.getPlayerFromPart(part)
    if not part then return nil end
    TracePF.refreshModules()
    if TracePF.repl and type(TracePF.repl.getPlayerFromBodyPart) == "function" then
        local ok, plr = pcall(TracePF.repl.getPlayerFromBodyPart, part)
        if ok and plr then return plr end
    end
    if type(TracePF.entries) == "table" then
        for plr, entry in pairs(TracePF.entries) do
            local tpo = getTpo(entry)
            local model = tpo and rawget(tpo, "_characterModel")
            if model and part:IsDescendantOf(model) then
                return plr
            end
        end
    end
    return nil
end

function TracePF.getRig(plr)
    if not plr or plr == LocalPlayer then return nil end
    if not TracePF.repl then TracePF.refreshModules() end
    local entry = entryOf(plr)
    if not entry then
        -- getEntry path without upvalue table
        if TracePF.repl and type(TracePF.repl.getEntry) == "function" then
            local ok, e = pcall(TracePF.repl.getEntry, plr)
            if ok then entry = e end
        end
    end
    if not aliveEntry(entry) then
        TracePF.cache[plr] = nil
        return nil
    end
    local cached = TracePF.cache[plr]
    if cached and cached._entry == entry and cached.root and cached.root.Parent then
        -- cheap refresh of lock part preference
        return cached
    end

    local tpo = getTpo(entry)
    if not tpo then return nil end
    local hash = getHash(tpo)
    local model = rawget(tpo, "_characterModel")
    local torso = partFromHash(hash, "Torso") or rawget(tpo, "_torso")
    local head = partFromHash(hash, "Head") or rawget(tpo, "_head")
    local root = torso
    pcall(function()
        if type(tpo.getRootPart) == "function" then
            root = tpo:getRootPart() or root
        end
    end)
    if not root and not head then return nil end
    root = root or head
    local preferHead = not cfg() or cfg().PreferHead ~= false
    local lock = (preferHead and head) or torso or root

    local normHash = {
        Head = head,
        Torso = torso,
        ["Left Arm"] = partFromHash(hash, "Left Arm"),
        ["Right Arm"] = partFromHash(hash, "Right Arm"),
        ["Left Leg"] = partFromHash(hash, "Left Leg"),
        ["Right Leg"] = partFromHash(hash, "Right Leg"),
    }

    local data = {
        _char = makeCharProxy(normHash, model),
        _entry = entry,
        parts = normHash,
        root = root,
        lockPart = lock,
        humanoid = nil,
        rigType = "R6",
        skelBones = {
            {"Head", "Torso"},
            {"Torso", "Left Arm"},
            {"Torso", "Right Arm"},
            {"Torso", "Left Leg"},
            {"Torso", "Right Leg"},
        },
    }
    data.getHealth = function()
        local h = 100
        pcall(function()
            if type(entry.getHealth) == "function" then
                h = select(1, entry:getHealth())
            else
                local hs = rawget(entry, "_healthstate")
                if type(hs) == "table" then
                    h = hs.health0 or 100
                end
            end
        end)
        return tonumber(h) or 100
    end
    data.getMaxHealth = function()
        local m = 100
        pcall(function()
            if type(entry.getHealth) == "function" then
                m = select(2, entry:getHealth()) or 100
            else
                local hs = rawget(entry, "_healthstate")
                if type(hs) == "table" then
                    m = hs.maxhealth or 100
                end
            end
        end)
        return tonumber(m) or 100
    end
    data.isAlive = function()
        return aliveEntry(entry)
    end
    data.getVelocity = function()
        local v = Vector3.new()
        pcall(function()
            local spring = rawget(entry, "_velspring")
            if type(spring) == "table" and spring.t then
                v = spring.t
                return
            end
            if type(spring) == "table" and spring.p then
                v = spring.p
                return
            end
            if root then
                local ok2, vel = pcall(function() return root.AssemblyLinearVelocity end)
                if ok2 then v = vel end
            end
        end)
        return v
    end
    TracePF.cache[plr] = data
    return data
end

function TracePF.operate(fn)
    TracePF.refreshModules()
    if TracePF.repl and type(TracePF.repl.operateOnAllEntries) == "function" then
        pcall(TracePF.repl.operateOnAllEntries, fn)
        return
    end
    if type(TracePF.entries) == "table" then
        for plr, entry in pairs(TracePF.entries) do
            pcall(fn, plr, entry)
        end
    end
end

local function silentFovRadius()
    local c = cfg()
    if not c or c.SilentFOVOnly == false then return 1e9 end
    return tonumber(c.SilentFOV) or tonumber(Settings.Aimbot and Settings.Aimbot.SilentFOVRadius) or 220
end

local function rollSilent()
    local now = tick()
    if now >= TracePF._roll.next then
        TracePF._roll.next = now + 0.1
        TracePF._roll.miss = math.random(1, 100)
        TracePF._roll.head = math.random(1, 100)
    end
end

local function wantHead()
    local c = cfg()
    local headChance = tonumber(c and c.HeadChance) or 70
    return TracePF._roll.head <= headChance
end

local function passHitChance()
    local c = cfg()
    local hit = tonumber(c and c.HitChance) or 100
    return TracePF._roll.miss <= hit
end

local function trajectory(origin, accel, target, speed, enemyVel)
    local f = -accel
    local ld = target - origin
    local a = DOT(f, f)
    if a <= 1e-6 then
        local dir = ld.Unit
        return dir * speed + (enemyVel or ZERO), ld.Magnitude / math.max(speed, 1)
    end
    local b = 4 * DOT(ld, ld)
    local k = (4 * (DOT(f, ld) + speed * speed)) / (2 * a)
    local disc = k * k - b / a
    if disc < 0 then
        local dir = ld.Unit
        return dir * speed + (enemyVel or ZERO), ld.Magnitude / math.max(speed, 1)
    end
    local v = disc ^ 0.5
    local t = k - v
    local t0 = k + v
    if t < 0 then t = t0 end
    t = t ^ 0.5
    return f * t / 2 + (enemyVel or ZERO) + ld / t, t
end

local function getBulletAccel()
    local ps = TracePF.publicSettings
    if type(ps) == "table" and typeof(ps.bulletAcceleration) == "Vector3" then
        return ps.bulletAcceleration
    end
    return Vector3.new(0, -196.2, 0)
end

local function updateAimCache()
    local c = cfg()
    if not c or c.SilentAim == false then
        TracePF._aim.pos = nil
        return
    end
    rollSilent()
    local cam = S.Workspace.CurrentCamera
    if not cam then
        TracePF._aim.pos = nil
        return
    end
    local center = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5)
    local fov = silentFovRadius()
    local partName = "Torso"
    if c.PreferHead ~= false and wantHead() then
        partName = "Head"
    end
    local bestDist, bestPos, bestEntry, bestVel = fov, nil, nil, ZERO

    local function consider(plr, entry)
        if not isEnemyPlayer(plr) or not aliveEntry(entry) then return end
        local tpo = getTpo(entry)
        if not tpo then return end
        local hash = getHash(tpo)
        local part = partFromHash(hash, partName)
            or (partName == "Head" and rawget(tpo, "_head"))
            or rawget(tpo, "_torso")
            or partFromHash(hash, "Torso")
        if not part then return end
        local sp, on = cam:WorldToViewportPoint(part.Position)
        if not on or sp.Z <= 0 then return end
        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if d < bestDist then
            bestDist = d
            bestPos = part.Position
            bestEntry = entry
            local spring = rawget(entry, "_velspring")
            if type(spring) == "table" then
                bestVel = spring.t or spring.p or ZERO
            else
                bestVel = ZERO
            end
        end
    end

    if TracePF.repl and type(TracePF.repl.operateOnAllEntries) == "function" then
        pcall(TracePF.repl.operateOnAllEntries, consider)
    elseif type(TracePF.entries) == "table" then
        local any = false
        for plr, entry in pairs(TracePF.entries) do
            any = true
            consider(plr, entry)
        end
        if not any then
            for _, plr in ipairs(Players:GetPlayers()) do
                local entry = entryOf(plr)
                if entry then consider(plr, entry) end
            end
        end
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            local entry = entryOf(plr)
            if entry then consider(plr, entry) end
        end
    end

    if c.Predict == false then bestVel = ZERO end
    TracePF._aim.pos = bestPos
    TracePF._aim.vel = bestVel
    TracePF._aim.entry = bestEntry
end

local function getClosestSilent()
    local aim = TracePF._aim
    if aim and aim.pos then
        return aim.pos, aim.entry, nil, nil, aim.vel or ZERO
    end
    return nil
end

local function installSilentAim()
    local c = cfg()
    if not c or c.SilentAim == false then
        TracePF.silentStatus = "disabled"
        return false
    end
    TracePF.refreshModules(true)
    cacheExtraModules()
    rollSilent()

    local method = tostring(c.SilentMethod or "FireRound")
    local wantNet = method == "Network" or method == "Auto"
    local wantFire = method == "FireRound" or method == "Auto" or method == nil

    -- FireRound path: flag + cached aim (no debug.getinfo, no per-bullet scans)
    if wantFire and TracePF.characterObject and not TracePF.silentHooks.getRootPart then
        local co = TracePF.characterObject
        local oldGet = cloneFn(co.getRootPart)
        TracePF._old.getRootPart = oldGet
        co.getRootPart = wrap(function(self)
            if TracePF._inFire and cfg() and cfg().SilentAim ~= false then
                local actual = oldGet(self)
                local pos = TracePF._aim and TracePF._aim.pos
                if pos and actual and actual.Position then
                    TracePF._spoofing = true
                    return { CFrame = CFrame.new(actual.Position, pos) }
                end
                TracePF._spoofing = false
            end
            return oldGet(self)
        end)
        TracePF.silentHooks.getRootPart = true
    end

    if wantFire and TracePF.firearmObject and not TracePF.silentHooks.fireRound then
        local fo = TracePF.firearmObject
        local oldFire = cloneFn(fo.fireRound)
        TracePF._old.fireRound = oldFire
        fo.fireRound = wrap(function(self, ...)
            TracePF._inFire = true
            rollSilent()
            local canHit = passHitChance()
            TracePF._spoofing = canHit and TracePF._aim and TracePF._aim.pos ~= nil
            local bag = TracePF._oldOffsets[self]
            if not bag then
                bag = {}
                TracePF._oldOffsets[self] = bag
            end
            bag._barrelOffset = self._barrelOffset
            bag._mainC0 = self._mainC0
            if TracePF._spoofing then
                self._barrelOffset = CFrame.new()
                self._mainC0 = CFrame.new()
            end
            local r1, r2, r3, r4, r5 = oldFire(self, ...)
            if bag._barrelOffset ~= nil then
                self._barrelOffset = bag._barrelOffset
                self._mainC0 = bag._mainC0
            end
            TracePF._inFire = false
            TracePF._spoofing = false
            return r1, r2, r3, r4, r5
        end)
        TracePF.silentHooks.fireRound = true
    end

    -- Network path only when selected (or Auto and fire hooks failed)
    if wantNet and (method == "Network" or not TracePF.silentHooks.fireRound) and TracePF.network and not TracePF.silentHooks.network then
        local net = TracePF.network
        local oldSend = cloneFn(net.send)
        TracePF._old.networkSend = oldSend
        local ok = pcall(function()
            if type(hookfunction) == "function" then
                hookfunction(net.send, wrap(function(self, name, ...)
                    if name == "newbullets" and cfg() and cfg().SilentAim ~= false then
                        local pos, _, _, _, evel = getClosestSilent()
                        if pos then
                            local a, data, t, b = ...
                            if type(data) == "table" and type(data.bullets) == "table" and data.bullets[1] then
                                local speed = data.bullets[1][1]
                                speed = typeof(speed) == "Vector3" and speed.Magnitude or 1000
                                local firepos = data.firepos
                                if typeof(firepos) == "Vector3" then
                                    local vel = select(1, trajectory(firepos, getBulletAccel(), pos, speed, evel or ZERO))
                                    for i = 1, #data.bullets do
                                        data.bullets[i][1] = vel
                                    end
                                    return oldSend(self, name, a, data, t, b)
                                end
                            end
                        end
                    end
                    return oldSend(self, name, ...)
                end))
            else
                net.send = wrap(function(self, name, ...)
                    if name == "newbullets" and cfg() and cfg().SilentAim ~= false then
                        local pos, _, _, _, evel = getClosestSilent()
                        if pos then
                            local a, data, t, b = ...
                            if type(data) == "table" and type(data.bullets) == "table" and data.bullets[1] then
                                local speed = data.bullets[1][1]
                                speed = typeof(speed) == "Vector3" and speed.Magnitude or 1000
                                local firepos = data.firepos
                                if typeof(firepos) == "Vector3" then
                                    local vel = select(1, trajectory(firepos, getBulletAccel(), pos, speed, evel or ZERO))
                                    for i = 1, #data.bullets do
                                        data.bullets[i][1] = vel
                                    end
                                    return oldSend(self, name, a, data, t, b)
                                end
                            end
                        end
                    end
                    return oldSend(self, name, ...)
                end)
            end
        end)
        TracePF.silentHooks.network = ok
    end

    -- Skip BulletObject.new hook by default (double work + lag on every pellet)
    TracePF.silentHooks.bullet = false

    local bits = {}
    if TracePF.silentHooks.network then bits[#bits + 1] = "net" end
    if TracePF.silentHooks.getRootPart then bits[#bits + 1] = "root" end
    if TracePF.silentHooks.fireRound then bits[#bits + 1] = "fire" end
    if #bits == 0 then
        TracePF.silentStatus = "waiting-modules"
        return false
    end
    TracePF.silentStatus = table.concat(bits, "+")
    return true
end

local function softGunMods()
    local c = cfg()
    if not c or (not c.SoftNoRecoil and not c.SoftNoSpread) then return end
    local now = tick()
    if now - (TracePF._softScanAt or 0) > 2.5 or #TracePF._softGuns == 0 then
        TracePF._softScanAt = now
        TracePF._softGuns = {}
        if type(getgc) ~= "function" then return end
        local ok, list = pcall(getgc, true)
        if not ok or type(list) ~= "table" then return end
        for i = 1, #list do
            local obj = list[i]
            if type(obj) == "table" and (obj._spreadSpring or obj._translationSprings or obj._rotationSprings) then
                TracePF._softGuns[#TracePF._softGuns + 1] = obj
                if #TracePF._softGuns >= 8 then break end
            end
        end
    end
    for i = 1, #TracePF._softGuns do
        local obj = TracePF._softGuns[i]
        if type(obj) == "table" then
            if c.SoftNoSpread and obj._spreadSpring then
                pcall(function()
                    local s = obj._spreadSpring
                    if s.p then s.p = Vector3.new() end
                    if s.t then s.t = Vector3.new() end
                    if s.v then s.v = Vector3.new() end
                end)
            end
            if c.SoftNoRecoil then
                pcall(function()
                    local tr = obj._translationSprings
                    local rr = obj._rotationSprings
                    if tr and tr.reset then tr:reset() end
                    if rr and rr.reset then rr:reset() end
                end)
            end
        end
    end
end

function TracePF.tick()
    if not TracePF.running then return end
    if not (MW.isPF or game.PlaceId == (MW.places and MW.places.PhantomForces)) then return end
    local now = tick()
    if not TracePF.repl and now - (TracePF.lastResolve or 0) >= 1 then
        TracePF.resolveTries = TracePF.resolveTries + 1
        TracePF.refreshModules(true)
        if TracePF.repl then
            warn("[Melo 🍃] PF modules ready (" .. tostring(TracePF.status) .. ")")
        elseif TracePF.resolveTries == 8 then
            warn("[Melo 🍃] PF still waiting for ReplicationInterface. Spawn into a round.")
        end
    elseif TracePF.repl and not TracePF.entries and now - (TracePF.lastResolve or 0) >= 1.5 then
        TracePF.refreshModules(true)
    end
    local c = cfg()
    if c and c.SilentAim ~= false then
        if now - (TracePF.lastAim or 0) >= 0.03 then
            TracePF.lastAim = now
            pcall(updateAimCache)
        end
        if now - TracePF.lastSilentTry >= 2 then
            TracePF.lastSilentTry = now
            if TracePF.silentStatus == "waiting-modules" or TracePF.silentStatus == "off" or TracePF.silentStatus == "boot" or TracePF.silentStatus == "disabled" then
                pcall(installSilentAim)
            elseif not (TracePF.silentHooks.fireRound or TracePF.silentHooks.network) then
                pcall(installSilentAim)
            end
        end
    end
    if c and (c.SoftNoRecoil or c.SoftNoSpread) and now - TracePF.lastSoft >= 0.25 then
        TracePF.lastSoft = now
        pcall(softGunMods)
    end
    if c and c.AntiAFK ~= false and now - TracePF.lastAfk >= 55 then
        TracePF.lastAfk = now
        pcall(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end
end

function TracePF.start()
    if TracePF.running then return end
    TracePF.running = true
    Settings.PF = Settings.PF or {}
    Settings.ESP = Settings.ESP or {}
    Settings.Aimbot = Settings.Aimbot or {}
    Settings.ESP.Enabled = true
    Settings.ESP.BoxEnabled = true
    if Settings.ESP.BoxStyle == "Off" then Settings.ESP.BoxStyle = "2D" end
    Settings.ESP.NameEnabled = true
    Settings.ESP.FilterMode = "Enemies"
    Settings.ESP.WeaponLabels = Settings.PF.WeaponLabels ~= false
    Settings.ESP.HealthEnabled = Settings.PF.ShowHealth ~= false
    if Settings.PF.Skeleton == true then
        Settings.ESP.SkeletonEnabled = true
    end
    Settings.Aimbot.AimMode = "Camera"
    Settings.Aimbot.Enabled = true
    if Settings.PF.SilentAim ~= false then
        Settings.Aimbot.ShowSilentFOV = Settings.PF.ShowSilentFOV ~= false
        if Settings.PF.SilentFOV then
            Settings.Aimbot.SilentFOVRadius = Settings.PF.SilentFOV
        end
    end
    TracePF.refreshModules()
    pcall(installSilentAim)
    addConn(RunService.Heartbeat:Connect(function()
        pcall(TracePF.tick)
    end))
    addConn(Players.PlayerRemoving:Connect(function(plr)
        TracePF.cache[plr] = nil
    end))
    local msg = "PF kit: " .. tostring(TracePF.status) .. " / silent " .. tostring(TracePF.silentStatus)
    warn("[Melo 🍃] " .. msg)
    if sendNotification then
        sendNotification("Melo 🍃", msg, 4)
    end
end

function TracePF.stop()
    TracePF.running = false
    for _, c in ipairs(TracePF.conns) do pcall(function() c:Disconnect() end) end
    TracePF.conns = {}
    TracePF.cache = {}
end

function TracePF.reinstallSilent()
    TracePF.silentHooks.network = false
    TracePF.silentHooks.bullet = false
    TracePF.silentHooks.fireRound = false
    TracePF.silentHooks.getRootPart = false
    TracePF.silentStatus = "off"
    TracePF.network = nil
    TracePF.bulletObject = nil
    TracePF.firearmObject = nil
    TracePF.characterObject = nil
    TracePF.publicSettings = nil
    return installSilentAim()
end

TracePF.isEnemyPlayer = isEnemyPlayer
TracePF.installSilentAim = installSilentAim
TracePF.getClosestSilent = getClosestSilent
return TracePF
end)()
MW.TracePF = TracePF

