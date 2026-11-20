-- GameServer.luau -- mtr
-- Server Brainrot 3D METEOR: beli, income per detik, lock, rebirth, steal. -- mtr

local Players = game:GetService("Players") -- mtr
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- mtr

local Shared = ReplicatedStorage:WaitForChild("Shared") -- mtr
local BrainrotData = require(Shared:WaitForChild("BrainrotData")) -- mtr

local CONFIG = { -- mtr
	START_MONEY = 550, -- mtr
	BUY_DISTANCE = 16, -- mtr
	LOCK_SECONDS = 30, -- mtr
	LOCK_COOLDOWN_SECONDS = 60, -- mtr
	REBIRTH_COST = 100000, -- mtr
	REBIRTH_MULTIPLIER = 1.25, -- mtr
	STEAL_COOLDOWN = 8, -- mtr
	MESSAGE_LIFETIME = 3, -- mtr
} -- mtr

local function ensureRemoteEvent(name) -- mtr
	local existing = ReplicatedStorage:FindFirstChild(name) -- mtr
	if existing and existing:IsA("RemoteEvent") then -- mtr
		return existing -- mtr
	end -- mtr
	local event = Instance.new("RemoteEvent") -- mtr
	event.Name = name -- mtr
	event.Parent = ReplicatedStorage -- mtr
	return event -- mtr
end -- mtr

local BuyEvent = ensureRemoteEvent("BuyBrainrot") -- mtr
local LockEvent = ensureRemoteEvent("LockBase") -- mtr
local RebirthEvent = ensureRemoteEvent("Rebirth") -- mtr
local UpdateEvent = ensureRemoteEvent("PlayerUpdate") -- mtr
local StealEvent = ensureRemoteEvent("StealBrainrot") -- mtr
local RequestUpdateEvent = ensureRemoteEvent("RequestUpdate") -- mtr

local playerData = {} -- mtr

local function createData() -- mtr
	return { -- mtr
		Money = CONFIG.START_MONEY, -- mtr
		PerSecond = 0, -- mtr
		Multiplier = 1, -- mtr
		Brainrots = {}, -- mtr
		Locked = false, -- mtr
		LockEnd = 0, -- mtr
		CooldownEnd = 0, -- mtr
		LastSteal = 0, -- mtr
		LastMessage = "", -- mtr
		LastMessageAt = 0, -- mtr
	} -- mtr
end -- mtr

local function calcPerSecond(data) -- mtr
	return BrainrotData.totalPerSecond(data.Brainrots, data.Multiplier) -- mtr
end -- mtr

local function sync(player, message) -- mtr
	local data = playerData[player] -- mtr
	if not data then -- mtr
		return -- mtr
	end -- mtr
	if message and message ~= "" then -- mtr
		data.LastMessage = message -- mtr
		data.LastMessageAt = tick() -- mtr
	end -- mtr
	local visibleMessage = "" -- mtr
	if data.LastMessage ~= "" and tick() - data.LastMessageAt < CONFIG.MESSAGE_LIFETIME then -- mtr
		visibleMessage = data.LastMessage -- mtr
	end -- mtr
	data.PerSecond = calcPerSecond(data) -- mtr
	UpdateEvent:FireClient(player, { -- mtr
		Money = data.Money, -- mtr
		PerSecond = data.PerSecond, -- mtr
		Multiplier = data.Multiplier, -- mtr
		Brainrots = data.Brainrots, -- mtr
		BrainrotCount = #data.Brainrots, -- mtr
		Locked = data.Locked, -- mtr
		LockRemaining = math.max(0, math.ceil(data.LockEnd - tick())), -- mtr
		CooldownRemaining = math.max(0, math.ceil(data.CooldownEnd - tick())), -- mtr
		Message = visibleMessage, -- mtr
	}) -- mtr
end -- mtr

task.spawn(function() -- mtr
	while true do -- mtr
		task.wait(1) -- mtr
		for player, data in pairs(playerData) do -- mtr
			if data.PerSecond > 0 then -- mtr
				data.Money = data.Money + data.PerSecond -- mtr
				sync(player, "") -- mtr
			end -- mtr
		end -- mtr
	end -- mtr
end) -- mtr

local function buyBrainrot(player, part) -- mtr
	local data = playerData[player] -- mtr
	if not data then -- mtr
		return false -- mtr
	end -- mtr
	if not part or not part:IsA("BasePart") or not part.Parent then -- mtr
		return false -- mtr
	end -- mtr
	local price = part:GetAttribute("Price") -- mtr
	local perSecond = part:GetAttribute("PerSecond") -- mtr
	local rarity = part:GetAttribute("Rarity") -- mtr
	local brainrotName = part:GetAttribute("BrainrotName") or part.Name -- mtr
	if not price or not perSecond or not rarity then -- mtr
		return false -- mtr
	end -- mtr
	if data.Money < price then -- mtr
		sync(player, "Duit kurang: butuh $" .. price) -- mtr
		return false -- mtr
	end -- mtr
	local character = player.Character -- mtr
	if not character then -- mtr
		sync(player, "Karakter belum spawn") -- mtr
		return false -- mtr
	end -- mtr
	local hrp = character:FindFirstChild("HumanoidRootPart") -- mtr
	if not hrp then -- mtr
		return false -- mtr
	end -- mtr
	if (hrp.Position - part.Position).Magnitude > CONFIG.BUY_DISTANCE then -- mtr
		sync(player, "Terlalu jauh dari brainrot") -- mtr
		return false -- mtr
	end -- mtr
	data.Money = data.Money - price -- mtr
	table.insert(data.Brainrots, { -- mtr
		Name = brainrotName, -- mtr
		Rarity = rarity, -- mtr
		Price = price, -- mtr
		PerSecond = perSecond, -- mtr
		Color = part.Color, -- mtr
	}) -- mtr
	part:Destroy() -- mtr
	sync(player, "Beli " .. brainrotName .. " (+$" .. perSecond .. "/s)") -- mtr
	return true -- mtr
end -- mtr

local function lockBase(player) -- mtr
	local data = playerData[player] -- mtr
	if not data then -- mtr
		return false -- mtr
	end -- mtr
	local now = tick() -- mtr
	if data.Locked then -- mtr
		sync(player, "Base sudah terkunci") -- mtr
		return false -- mtr
	end -- mtr
	if now < data.CooldownEnd then -- mtr
		sync(player, "Cooldown lock: " .. math.ceil(data.CooldownEnd - now) .. "s") -- mtr
		return false -- mtr
	end -- mtr
	data.Locked = true -- mtr
	data.LockEnd = now + CONFIG.LOCK_SECONDS -- mtr
	data.CooldownEnd = data.LockEnd + CONFIG.LOCK_COOLDOWN_SECONDS -- mtr
	sync(player, "Base terkunci 30 detik") -- mtr
	task.delay(CONFIG.LOCK_SECONDS, function() -- mtr
		local current = playerData[player] -- mtr
		if current and current.Locked then -- mtr
			current.Locked = false -- mtr
			sync(player, "Lock selesai, cooldown 60s") -- mtr
		end -- mtr
	end) -- mtr
	return true -- mtr
end -- mtr

local function doRebirth(player) -- mtr
	local data = playerData[player] -- mtr
	if not data then -- mtr
		return false -- mtr
	end -- mtr
	if data.Money < CONFIG.REBIRTH_COST then -- mtr
		sync(player, "Rebirth butuh $100000") -- mtr
		return false -- mtr
	end -- mtr
	data.Money = 0 -- mtr
	data.Multiplier = data.Multiplier * CONFIG.REBIRTH_MULTIPLIER -- mtr
	data.Brainrots = {} -- mtr
	data.Locked = false -- mtr
	data.LockEnd = 0 -- mtr
	data.CooldownEnd = 0 -- mtr
	sync(player, string.format("Rebirth! Multiplier %.2fx", data.Multiplier)) -- mtr
	return true -- mtr
end -- mtr

local function stealBrainrot(thief, victimName, index) -- mtr
	local thiefData = playerData[thief] -- mtr
	local victim = Players:FindFirstChild(victimName) -- mtr
	if not thiefData or not victim then -- mtr
		return false -- mtr
	end -- mtr
	local victimData = playerData[victim] -- mtr
	if not victimData then -- mtr
		return false -- mtr
	end -- mtr
	local now = tick() -- mtr
	if now < thiefData.LastSteal + CONFIG.STEAL_COOLDOWN then -- mtr
		sync(thief, "Steal cooldown " .. math.ceil(thiefData.LastSteal + CONFIG.STEAL_COOLDOWN - now) .. "s") -- mtr
		return false -- mtr
	end -- mtr
	if victimData.Locked then -- mtr
		sync(thief, victim.Name .. " sedang lock base") -- mtr
		return false -- mtr
	end -- mtr
	index = tonumber(index) or 1 -- mtr
	if index < 1 or index > #victimData.Brainrots then -- mtr
		return false -- mtr
	end -- mtr
	local stolen = table.remove(victimData.Brainrots, index) -- mtr
	table.insert(thiefData.Brainrots, stolen) -- mtr
	thiefData.LastSteal = now -- mtr
	sync(victim, thief.Name .. " mencuri " .. stolen.Name) -- mtr
	sync(thief, "Curi " .. stolen.Name .. " dari " .. victim.Name) -- mtr
	return true -- mtr
end -- mtr

BuyEvent.OnServerEvent:Connect(function(player, part) -- mtr
	buyBrainrot(player, part) -- mtr
end) -- mtr

LockEvent.OnServerEvent:Connect(function(player) -- mtr
	lockBase(player) -- mtr
end) -- mtr

RebirthEvent.OnServerEvent:Connect(function(player) -- mtr
	doRebirth(player) -- mtr
end) -- mtr

StealEvent.OnServerEvent:Connect(function(player, victimName, index) -- mtr
	stealBrainrot(player, victimName, index) -- mtr
end) -- mtr

RequestUpdateEvent.OnServerEvent:Connect(function(player) -- mtr
	sync(player, "") -- mtr
end) -- mtr

Players.PlayerAdded:Connect(function(player) -- mtr
	playerData[player] = createData() -- mtr
	player.CharacterAdded:Connect(function(character) -- mtr
		task.wait(0.5) -- mtr
		sync(player, "Selamat datang di Brainrot 3D METEOR!") -- mtr
	end) -- mtr
	task.wait(0.2) -- mtr
	sync(player, "") -- mtr
end) -- mtr

Players.PlayerRemoving:Connect(function(player) -- mtr
	playerData[player] = nil -- mtr
end) -- mtr
-- recorded edit 19 Nov
-- witness 2026-11-20
-- witness2 2026-11-20
