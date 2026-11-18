-- GameServer.luau
-- Handle buy brainrot, money per second, steal, lock, rebirth
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BrainrotData = require(ReplicatedStorage.Shared.BrainrotData)

local BuyEvent = Instance.new("RemoteEvent", ReplicatedStorage)
BuyEvent.Name = "BuyBrainrot"

local LockEvent = Instance.new("RemoteEvent", ReplicatedStorage)
LockEvent.Name = "LockBase"

local RebirthEvent = Instance.new("RemoteEvent", ReplicatedStorage)
RebirthEvent.Name = "Rebirth"

local UpdateEvent = Instance.new("RemoteEvent", ReplicatedStorage)
UpdateEvent.Name = "PlayerUpdate"

local StealEvent = Instance.new("RemoteEvent", ReplicatedStorage)
StealEvent.Name = "StealBrainrot"

local playerData = {}

local function createData()
    return {
        Money = 500,
        PerSecond = 0,
        Multiplier = 1,
        Brainrots = {},
        Locked = false,
        LockCooldown = 0,
        LockEnd = 0,
    }
end

local function calcPerSecond(data)
    local sum = 0
    for _, b in ipairs(data.Brainrots) do
        sum = sum + b.PerSecond
    end
    return sum * data.Multiplier
end

local function sync(player)
    local d = playerData[player]
    if not d then return end
    d.PerSecond = calcPerSecond(d)
    UpdateEvent:FireClient(player, {
        Money = d.Money,
        PerSecond = d.PerSecond,
        Multiplier = d.Multiplier,
        Brainrots = d.Brainrots,
        Locked = d.Locked,
        LockCooldown = d.LockCooldown > 0 and 1 or 0,
    })
end

-- Money per second loop
task.spawn(function()
    while true do
        task.wait(1)
        for player, d in pairs(playerData) do
            if d.PerSecond > 0 then
                d.Money = d.Money + d.PerSecond
                sync(player)
            end
        end
    end
end)

-- Buy brainrot
local function buyBrainrot(player, part)
    local d = playerData[player]
    if not d then return end
    local price = part:GetAttribute("Price")
    local perSec = part:GetAttribute("PerSecond")
    local rarity = part:GetAttribute("Rarity") or "Common"
    local name = part.Name
    if not price or d.Money < price then return false end
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or (hrp.Position - part.Position).Magnitude > 15 then return false end
    d.Money = d.Money - price
    table.insert(d.Brainrots, {Name=name, Rarity=rarity, Price=price, PerSecond=perSec})
    part:Destroy()
    sync(player)
    return true
end

BuyEvent.OnServerEvent:Connect(function(player, part)
    buyBrainrot(player, part)
end)

-- Lock base
local function lockBase(player)
    local d = playerData[player]
    if not d then return end
    local now = tick()
    if d.LockCooldown > 0 or d.Locked then return false end
    d.Locked = true
    d.LockEnd = now + 30
    task.delay(30, function()
        if playerData[player] then
            playerData[player].Locked = false
            sync(player)
        end
    end)
    d.LockCooldown = 60
    task.delay(60, function()
        if playerData[player] then
            playerData[player].LockCooldown = 0
            sync(player)
        end
    end)
    sync(player)
    return true
end

LockEvent.OnServerEvent:Connect(function(player)
    lockBase(player)
end)

-- Rebirth
local function doRebirth(player)
    local d = playerData[player]
    if not d then return false end
    if d.Money < 100000 then return false end
    d.Money = 0
    d.Multiplier = d.Multiplier * 1.25
    d.Brainrots = {}
    sync(player)
    return true
end

RebirthEvent.OnServerEvent:Connect(function(player)
    doRebirth(player)
end)

-- Steal
local function stealBrainrot(thief, victim, idx)
    local td = playerData[thief]
    local vd = playerData[victim]
    if not td or not vd then return false end
    if vd.Locked then return false end
    if idx <1 or idx > #vd.Brainrots then return false end
    local stolen = table.remove(vd.Brainrots, idx)
    table.insert(td.Brainrots, stolen)
    sync(victim)
    sync(thief)
    return true
end

StealEvent.OnServerEvent:Connect(function(player, victimName, idx)
    local victim = Players:FindFirstChild(victimName)
    if victim then stealBrainrot(player, victim, idx) end
end)

Players.PlayerAdded:Connect(function(player)
    playerData[player] = createData()
    task.wait(1)
    sync(player)
end)

Players.PlayerRemoving:Connect(function(player)
    playerData[player] = nil
end)
