-- GameServer.luau
-- Logika server Brainrot 3D: beli brainrot, duit per detik, steal,
-- lock base 30 detik dengan cooldown 60 detik, dan rebirth.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local BrainrotData = require(Shared:WaitForChild("BrainrotData"))

local CONFIG = {
	START_MONEY = 500,
	BUY_DISTANCE = 16,
	LOCK_SECONDS = 30,
	LOCK_COOLDOWN_SECONDS = 60,
	REBIRTH_COST = 100000,
	REBIRTH_MULTIPLIER = 1.25,
	STEAL_COOLDOWN = 8,
	MESSAGE_LIFETIME = 3,
}

local function ensureRemoteEvent(name)
	local existing = ReplicatedStorage:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = ReplicatedStorage
	return event
end

local BuyEvent = ensureRemoteEvent("BuyBrainrot")
local LockEvent = ensureRemoteEvent("LockBase")
local RebirthEvent = ensureRemoteEvent("Rebirth")
local UpdateEvent = ensureRemoteEvent("PlayerUpdate")
local StealEvent = ensureRemoteEvent("StealBrainrot")
local RequestUpdateEvent = ensureRemoteEvent("RequestUpdate")

local playerData = {}

local function createData()
	return {
		Money = CONFIG.START_MONEY,
		PerSecond = 0,
		Multiplier = 1,
		Brainrots = {},
		Locked = false,
		LockEnd = 0,
		CooldownEnd = 0,
		LastSteal = 0,
		LastMessage = "",
		LastMessageAt = 0,
	}
end

local function calcPerSecond(data)
	return BrainrotData.totalPerSecond(data.Brainrots, data.Multiplier)
end

local function sync(player, message)
	local data = playerData[player]
	if not data then
		return
	end
	if message and message ~= "" then
		data.LastMessage = message
		data.LastMessageAt = tick()
	end
	local visibleMessage = ""
	if data.LastMessage ~= "" and tick() - data.LastMessageAt < CONFIG.MESSAGE_LIFETIME then
		visibleMessage = data.LastMessage
	end
	data.PerSecond = calcPerSecond(data)
	UpdateEvent:FireClient(player, {
		Money = data.Money,
		PerSecond = data.PerSecond,
		Multiplier = data.Multiplier,
		Brainrots = data.Brainrots,
		BrainrotCount = #data.Brainrots,
		Locked = data.Locked,
		LockRemaining = math.max(0, math.ceil(data.LockEnd - tick())),
		CooldownRemaining = math.max(0, math.ceil(data.CooldownEnd - tick())),
		Message = visibleMessage,
	})
end

-- Duit masuk setiap detik berdasarkan total $/detik pemain.
task.spawn(function()
	while true do
		task.wait(1)
		for player, data in pairs(playerData) do
			if data.PerSecond > 0 then
				data.Money = data.Money + data.PerSecond
				sync(player, "")
			end
		end
	end
end)

-- Beli brainrot dari Part conveyor yang punya atribut Price/PerSecond/Rarity.
local function buyBrainrot(player, part)
	local data = playerData[player]
	if not data then
		return false
	end
	if not part or not part:IsA("BasePart") or not part.Parent then
		return false
	end
	local price = part:GetAttribute("Price")
	local perSecond = part:GetAttribute("PerSecond")
	local rarity = part:GetAttribute("Rarity")
	local brainrotName = part:GetAttribute("BrainrotName") or part.Name
	if not price or not perSecond or not rarity then
		return false
	end
	if data.Money < price then
		sync(player, "Duit kurang: butuh $" .. price)
		return false
	end
	local character = player.Character
	if not character then
		sync(player, "Karakter belum spawn")
		return false
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return false
	end
	if (hrp.Position - part.Position).Magnitude > CONFIG.BUY_DISTANCE then
		sync(player, "Terlalu jauh dari brainrot")
		return false
	end
	data.Money = data.Money - price
	table.insert(data.Brainrots, {
		Name = brainrotName,
		Rarity = rarity,
		Price = price,
		PerSecond = perSecond,
		Color = part.Color,
	})
	part:Destroy()
	sync(player, "Beli " .. brainrotName .. " (+$" .. perSecond .. "/s)")
	return true
end

-- Lock base: aktif 30 detik, cooldown 60 detik setelah lock berakhir.
local function lockBase(player)
	local data = playerData[player]
	if not data then
		return false
	end
	local now = tick()
	if data.Locked then
		sync(player, "Base sudah terkunci")
		return false
	end
	if now < data.CooldownEnd then
		sync(player, "Cooldown lock: " .. math.ceil(data.CooldownEnd - now) .. "s")
		return false
	end
	data.Locked = true
	data.LockEnd = now + CONFIG.LOCK_SECONDS
	data.CooldownEnd = data.LockEnd + CONFIG.LOCK_COOLDOWN_SECONDS
	sync(player, "Base terkunci 30 detik")
	task.delay(CONFIG.LOCK_SECONDS, function()
		local current = playerData[player]
		if current and current.Locked then
			current.Locked = false
			sync(player, "Lock selesai, cooldown 60s")
		end
	end)
	return true
end

-- Rebirth: butuh $100000, reset duit dan brainrot, multiplier naik 1.25x.
local function doRebirth(player)
	local data = playerData[player]
	if not data then
		return false
	end
	if data.Money < CONFIG.REBIRTH_COST then
		sync(player, "Rebirth butuh $100000")
		return false
	end
	data.Money = 0
	data.Multiplier = data.Multiplier * CONFIG.REBIRTH_MULTIPLIER
	data.Brainrots = {}
	data.Locked = false
	data.LockEnd = 0
	data.CooldownEnd = 0
	sync(player, string.format("Rebirth! Multiplier %.2fx", data.Multiplier))
	return true
end

-- Steal: curi satu brainrot dari pemain lain kalau base korban tidak terkunci.
local function stealBrainrot(thief, victimName, index)
	local thiefData = playerData[thief]
	local victim = Players:FindFirstChild(victimName)
	if not thiefData or not victim then
		return false
	end
	local victimData = playerData[victim]
	if not victimData then
		return false
	end
	local now = tick()
	if now < thiefData.LastSteal + CONFIG.STEAL_COOLDOWN then
		sync(thief, "Steal cooldown " .. math.ceil(thiefData.LastSteal + CONFIG.STEAL_COOLDOWN - now) .. "s")
		return false
	end
	if victimData.Locked then
		sync(thief, victim.Name .. " sedang lock base")
		return false
	end
	index = tonumber(index) or 1
	if index < 1 or index > #victimData.Brainrots then
		return false
	end
	local stolen = table.remove(victimData.Brainrots, index)
	table.insert(thiefData.Brainrots, stolen)
	thiefData.LastSteal = now
	sync(victim, thief.Name .. " mencuri " .. stolen.Name)
	sync(thief, "Curi " .. stolen.Name .. " dari " .. victim.Name)
	return true
end

BuyEvent.OnServerEvent:Connect(function(player, part)
	buyBrainrot(player, part)
end)

LockEvent.OnServerEvent:Connect(function(player)
	lockBase(player)
end)

RebirthEvent.OnServerEvent:Connect(function(player)
	doRebirth(player)
end)

StealEvent.OnServerEvent:Connect(function(player, victimName, index)
	stealBrainrot(player, victimName, index)
end)

RequestUpdateEvent.OnServerEvent:Connect(function(player)
	sync(player, "")
end)

Players.PlayerAdded:Connect(function(player)
	playerData[player] = createData()
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		sync(player, "Selamat datang di Brainrot 3D!")
	end)
	task.wait(0.2)
	sync(player, "")
end)

Players.PlayerRemoving:Connect(function(player)
	playerData[player] = nil
end)
