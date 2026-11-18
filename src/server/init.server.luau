-- Server init for Brainrot 3D game
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Catalog = require(ServerScriptService.Server.BrainrotCatalog)

-- RemoteEvents
local function getEvent(name)
	local e = ReplicatedStorage:FindFirstChild(name)
	if not e then
		e = Instance.new("RemoteEvent")
		e.Name = name
		e.Parent = ReplicatedStorage
	end
	return e
end

local BuyEvent = getEvent("BuyBrainrot")
local LockEvent = getEvent("LockBase")
local RebirthEvent = getEvent("Rebirth")
local UpdateEvent = getEvent("PlayerUpdate")
local StealEvent = getEvent("StealBrainrot")

local playerData = {}

local function createPlayerData(player)
	playerData[player] = {
		Money = 500,
		PerSecond = 0,
		Multiplier = 1,
		Brainrots = {},
		Locked = false,
		LockCooldown = 0,
		LockEnd = 0,
	}
end

local function removePlayerData(player)
	playerData[player] = nil
end

local function getTotalPerSecond(data)
	local total = 0
	for _, b in ipairs(data.Brainrots) do
		total = total + b.PerSecond
	end
	return total * data.Multiplier
end

local function syncPlayer(player)
	local data = playerData[player]
	if not data then return end
	data.PerSecond = getTotalPerSecond(data)
	UpdateEvent:FireClient(player, {
		Money = data.Money,
		PerSecond = data.PerSecond,
		Multiplier = data.Multiplier,
		Brainrots = data.Brainrots,
		Locked = data.Locked,
		LockCooldown = data.LockCooldown,
	})
end

local function addMoneyPerSecond()
	for player, data in pairs(playerData) do
		if data.PerSecond > 0 then
			local gain = data.PerSecond
			data.Money = data.Money + gain
			syncPlayer(player)
		end
	end
end

task.spawn(function()
	while true do
		task.wait(1)
		addMoneyPerSecond()
	end
end)

-- Brainrot spawner
local TweenService = game:GetService("TweenService")
local conveyor = Workspace:WaitForChild("Conveyor", 10) or Workspace
local function spawnBrainrot()
	local idx = math.random(1, #Catalog)
	local entry = Catalog[idx]
	local part = Instance.new("Part")
	part.Name = entry.Name
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(3,3,3)
	part.Color = entry.Color
	part.Material = Enum.Material.Neon
	local z = math.random(-2,2)
	part.CFrame = CFrame.new(-90, 2, z)
	part:SetAttribute("Price", entry.Price)
	part:SetAttribute("PerSecond", entry.PerSecond)
	part:SetAttribute("Rarity", entry.Rarity)
	part:SetAttribute("CatalogIndex", idx)
	part.Parent = Workspace
	-- move along conveyor
	local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Linear)
	local goal = {CFrame = CFrame.new(90, 2, z)}
	local tween = TweenService:Create(part, tweenInfo, goal)
	tween:Play()
	tween.Completed:Connect(function()
		if part and part.Parent then part:Destroy() end
	end)
end

task.spawn(function()
	while true do
		task.wait(math.random(3,6))
		spawnBrainrot()
	end
end)

-- Buy brainrot
local function buyBrainrot(player, targetPart)
	local data = playerData[player]
	if not data then return false end
	if not targetPart or not targetPart:IsA("BasePart") then return false end
	local price = targetPart:GetAttribute("Price")
	local perSec = targetPart:GetAttribute("PerSecond")
	if not price then return false end
	if data.Money < price then return false end
	-- distance check
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	if (hrp.Position - targetPart.Position).Magnitude > 15 then return false end
	data.Money = data.Money - price
	table.insert(data.Brainrots, {
		Name = targetPart.Name,
		Rarity = targetPart:GetAttribute("Rarity") or "Common",
		PerSecond = perSec,
		Price = price,
	})
	targetPart:Destroy()
	syncPlayer(player)
	return true
end

BuyEvent.OnServerEvent:Connect(function(player, part)
	buyBrainrot(player, part)
end)

-- Lock base
local function lockBase(player)
	local data = playerData[player]
	if not data then return end
	local now = tick()
	if data.LockCooldown > 0 then return false end
	if data.Locked then return false end
	data.Locked = true
	data.LockEnd = now + 30
	task.delay(30, function()
		if playerData[player] then
			playerData[player].Locked = false
			syncPlayer(player)
		end
	end)
	-- cooldown
	data.LockCooldown = 60
	task.delay(60, function()
		if playerData[player] then
			playerData[player].LockCooldown = 0
			syncPlayer(player)
		end
	end)
	syncPlayer(player)
	return true
end

LockEvent.OnServerEvent:Connect(function(player)
	lockBase(player)
end)

-- Rebirth
local function doRebirth(player)
	local data = playerData[player]
	if not data then return false end
	if data.Money < 100000 then return false end
	data.Money = 0
	data.Multiplier = data.Multiplier * 1.25
	data.Brainrots = {}
	data.PerSecond = 0
	syncPlayer(player)
	return true
end

RebirthEvent.OnServerEvent:Connect(function(player)
	doRebirth(player)
end)

-- Steal
local function stealBrainrot(thief, victimPlayer, index)
	local tData = playerData[thief]
	local vData = playerData[victimPlayer]
	if not tData or not vData then return false end
	if vData.Locked then return false end
	if index <1 or index > #vData.Brainrots then return false end
	local stolen = table.remove(vData.Brainrots, index)
	table.insert(tData.Brainrots, stolen)
	syncPlayer(victimPlayer)
	syncPlayer(thief)
	return true
end

StealEvent.OnServerEvent:Connect(function(player, victimName, index)
	local victim = Players:FindFirstChild(victimName)
	if victim then
		stealBrainrot(player, victim, index)
	end
end)

Players.PlayerAdded:Connect(function(player)
	createPlayerData(player)
	task.wait(1)
	syncPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	removePlayerData(player)
end)
