-- World.server.luau -- mtr
-- Membangun dunia 3D Brainrot 3D METEOR dari Part di Workspace. -- mtr
-- Semua elemen dunia adalah geometri 3D, bukan Frame di ScreenGui. -- mtr

local Workspace = game:GetService("Workspace") -- mtr
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- mtr
local TweenService = game:GetService("TweenService") -- mtr

local Shared = ReplicatedStorage:WaitForChild("Shared") -- mtr
local BrainrotData = require(Shared:WaitForChild("BrainrotData")) -- mtr

local worldFolder = Instance.new("Folder") -- mtr
worldFolder.Name = "BrainrotWorld" -- mtr
worldFolder.Parent = Workspace -- mtr

local function makePart(name, size, cframe, color, material, transparency, shape) -- mtr
	local part = Instance.new("Part") -- mtr
	part.Name = name -- mtr
	part.Size = size -- mtr
	part.CFrame = cframe -- mtr
	part.Color = color -- mtr
	part.Material = material or Enum.Material.SmoothPlastic -- mtr
	part.Transparency = transparency or 0 -- mtr
	part.Shape = shape or Enum.PartType.Block -- mtr
	part.Anchored = true -- mtr
	part.CanCollide = true -- mtr
	part.TopSurface = Enum.SurfaceType.Smooth -- mtr
	part.BottomSurface = Enum.SurfaceType.Smooth -- mtr
	part.Parent = worldFolder -- mtr
	return part -- mtr
end -- mtr

local function makeDecor(name, size, cframe, color, material, transparency, shape) -- mtr
	local part = makePart(name, size, cframe, color, material, transparency, shape) -- mtr
	part.CanCollide = false -- mtr
	return part -- mtr
end -- mtr

local function makeBillboard(adornee, text, width, height, offset) -- mtr
	local billboard = Instance.new("BillboardGui") -- mtr
	billboard.Name = "Label_" .. adornee.Name -- mtr
	billboard.Size = UDim2.new(0, width, 0, height) -- mtr
	billboard.StudsOffset = Vector3.new(0, offset, 0) -- mtr
	billboard.AlwaysOnTop = true -- mtr
	billboard.MaxDistance = 140 -- mtr
	billboard.Parent = adornee -- mtr
	local label = Instance.new("TextLabel") -- mtr
	label.Size = UDim2.new(1, 0, 1, 0) -- mtr
	label.BackgroundTransparency = 1 -- mtr
	label.Text = text -- mtr
	label.TextColor3 = Color3.fromRGB(255, 255, 255) -- mtr
	label.TextScaled = true -- mtr
	label.Font = Enum.Font.GothamBlack -- mtr
	label.TextStrokeTransparency = 0.35 -- mtr
	label.Parent = billboard -- mtr
	return billboard -- mtr
end -- mtr

local baseplate = makePart("Baseplate", Vector3.new(600, 4, 600), CFrame.new(0, -2, 0), Color3.fromRGB(72, 118, 66), Enum.Material.Grass) -- mtr
baseplate.Locked = true -- mtr

makePart("RoadMain", Vector3.new(420, 0.6, 26), CFrame.new(0, 0.3, 0), Color3.fromRGB(48, 48, 52), Enum.Material.Asphalt) -- mtr
makePart("CurbNorth", Vector3.new(420, 1, 2), CFrame.new(0, 0.9, -14), Color3.fromRGB(125, 125, 135), Enum.Material.Concrete) -- mtr
makePart("CurbSouth", Vector3.new(420, 1, 2), CFrame.new(0, 0.9, 14), Color3.fromRGB(125, 125, 135), Enum.Material.Concrete) -- mtr

for i = 1, 15 do -- mtr
	makeDecor("RoadStripe" .. i, Vector3.new(14, 0.1, 1.2), CFrame.new(-210 + (i - 1) * 30, 0.65, 0), Color3.fromRGB(255, 220, 90), Enum.Material.Neon, 0.1) -- mtr
end -- mtr

local function buildBase(baseName, centerX, floorColor, rimColor) -- mtr
	local floor = makePart(baseName .. "_Floor", Vector3.new(72, 1, 72), CFrame.new(centerX, 0.5, 0), floorColor, Enum.Material.Neon) -- mtr
	floor:SetAttribute("BaseName", baseName) -- mtr
	floor:SetAttribute("Owner", "") -- mtr
	for i = 1, 6 do -- mtr
		local z = -15 + (i - 1) * 6 -- mtr
		local slot = makePart(baseName .. "_Slot" .. i, Vector3.new(6, 0.4, 6), CFrame.new(centerX, 1.2, z), Color3.fromRGB(28, 30, 38), Enum.Material.SmoothPlastic) -- mtr
		slot:SetAttribute("SlotIndex", i) -- mtr
		slot:SetAttribute("BaseName", baseName) -- mtr
		makeDecor(baseName .. "_SlotRim" .. i, Vector3.new(6.4, 0.1, 6.4), CFrame.new(centerX, 1.42, z), rimColor, Enum.Material.Neon, 0.15) -- mtr
	end -- mtr
	makeBillboard(floor, string.upper(baseName), 220, 54, 8) -- mtr
	return floor -- mtr
end -- mtr

buildBase("BaseA", -165, Color3.fromRGB(65, 180, 95), Color3.fromRGB(120, 255, 160)) -- mtr
buildBase("BaseB", 165, Color3.fromRGB(180, 85, 220), Color3.fromRGB(255, 170, 255)) -- mtr

local function buildFence(label, centerX) -- mtr
	local woodColor = Color3.fromRGB(145, 110, 72) -- mtr
	local half = 36 -- mtr
	for i = 1, 7 do -- mtr
		local x = -36 + (i - 1) * 12 -- mtr
		makePart(label .. "_FenceN" .. i, Vector3.new(1.2, 6, 1.2), CFrame.new(centerX + x, 3, -half), woodColor, Enum.Material.Wood) -- mtr
		makePart(label .. "_FenceS" .. i, Vector3.new(1.2, 6, 1.2), CFrame.new(centerX + x, 3, half), woodColor, Enum.Material.Wood) -- mtr
	end -- mtr
	for i = 1, 5 do -- mtr
		local z = -24 + (i - 1) * 12 -- mtr
		makePart(label .. "_FenceW" .. i, Vector3.new(1.2, 6, 1.2), CFrame.new(centerX - half, 3, z), woodColor, Enum.Material.Wood) -- mtr
		makePart(label .. "_FenceE" .. i, Vector3.new(1.2, 6, 1.2), CFrame.new(centerX + half, 3, z), woodColor, Enum.Material.Wood) -- mtr
	end -- mtr
end -- mtr

buildFence("BaseA", -165) -- mtr
buildFence("BaseB", 165) -- mtr

local conveyorFrame = makePart("ConveyorFrame", Vector3.new(300, 0.8, 8), CFrame.new(0, 1.2, 0), Color3.fromRGB(35, 35, 42), Enum.Material.Metal) -- mtr
makePart("ConveyorRailNorth", Vector3.new(300, 1, 1), CFrame.new(0, 1.9, -4.5), Color3.fromRGB(90, 90, 100), Enum.Material.Metal) -- mtr
makePart("ConveyorRailSouth", Vector3.new(300, 1, 1), CFrame.new(0, 1.9, 4.5), Color3.fromRGB(90, 90, 100), Enum.Material.Metal) -- mtr
makeBillboard(conveyorFrame, "CONVEYOR - BELI DI SINI", 280, 48, 5) -- mtr

local movingItems = {} -- mtr
for i = 1, 12 do -- mtr
	local segment = makePart("BeltSegment" .. i, Vector3.new(6, 0.5, 6), CFrame.new(-132 + (i - 1) * 12, 1.8, 0), Color3.fromRGB(95, 95, 105), Enum.Material.Metal) -- mtr
	table.insert(movingItems, {Part = segment, Offset = (i - 1) * 12, Height = 1.8, Spin = false}) -- mtr
end -- mtr

for index, entry in ipairs(BrainrotData.Catalog) do -- mtr
	local brainrot = Instance.new("Part") -- mtr
	brainrot.Name = entry.Name -- mtr
	brainrot.Size = Vector3.new(4, 4, 4) -- mtr
	brainrot.Shape = Enum.PartType.Ball -- mtr
	brainrot.CFrame = CFrame.new(-132 + (index - 1) * 12, 4.2, 0) -- mtr
	brainrot.Color = entry.Color -- mtr
	brainrot.Material = Enum.Material.Neon -- mtr
	brainrot.Transparency = 0.05 -- mtr
	brainrot.Anchored = true -- mtr
	brainrot.CanCollide = false -- mtr
	brainrot.Parent = worldFolder -- mtr
	brainrot:SetAttribute("Price", entry.Price) -- mtr
	brainrot:SetAttribute("PerSecond", entry.PerSecond) -- mtr
	brainrot:SetAttribute("Rarity", entry.Rarity) -- mtr
	brainrot:SetAttribute("BrainrotName", entry.Name) -- mtr
	table.insert(movingItems, {Part = brainrot, Offset = (index - 1) * 12, Height = 4.2, Spin = true}) -- mtr
end -- mtr

task.spawn(function() -- mtr
	local speed = 10 -- mtr
	local span = 264 -- mtr
	while true do -- mtr
		local dt = task.wait(0.1) -- mtr
		for _, item in ipairs(movingItems) do -- mtr
			local part = item.Part -- mtr
			if part and part.Parent then -- mtr
				item.Offset = item.Offset + speed * dt -- mtr
				if item.Offset > 132 then -- mtr
					item.Offset = item.Offset - span -- mtr
				end -- mtr
				local cframe = CFrame.new(-132 + item.Offset, item.Height, 0) -- mtr
				if item.Spin then -- mtr
					cframe = cframe * CFrame.Angles(0, os.clock() * 1.6, 0) -- mtr
				end -- mtr
				part.CFrame = cframe -- mtr
			end -- mtr
		end -- mtr
	end -- mtr
end) -- mtr

for i = 1, 14 do -- mtr
	local angle = (i - 1) * (math.pi * 2 / 14) -- mtr
	local x = math.cos(angle) * 230 -- mtr
	local z = math.sin(angle) * 230 -- mtr
	makePart("TreeTrunk" .. i, Vector3.new(5, 14, 5), CFrame.new(x, 7, z), Color3.fromRGB(95, 70, 45), Enum.Material.Wood) -- mtr
	makeDecor("TreeLeaves" .. i, Vector3.new(13, 13, 13), CFrame.new(x, 18, z), Color3.fromRGB(50, 150, 70), Enum.Material.Grass, 0, Enum.PartType.Ball) -- mtr
end -- mtr

local lampHeads = {} -- mtr
for i = 1, 13 do -- mtr
	local x = -180 + (i - 1) * 30 -- mtr
	for _, z in ipairs({-14, 14}) do -- mtr
		local side = (z < 0) and "N" or "S" -- mtr
		makePart("LampPole_" .. side .. i, Vector3.new(1.5, 12, 1.5), CFrame.new(x, 6, z), Color3.fromRGB(60, 60, 72), Enum.Material.Metal) -- mtr
		local head = makeDecor("LampHead_" .. side .. i, Vector3.new(4, 1.5, 4), CFrame.new(x, 12.3, z), Color3.fromRGB(255, 240, 180), Enum.Material.Neon) -- mtr
		table.insert(lampHeads, head) -- mtr
	end -- mtr
end -- mtr

task.spawn(function() -- mtr
	while true do -- mtr
		for _, head in ipairs(lampHeads) do -- mtr
			if head.Parent then -- mtr
				head.Transparency = 0.25 -- mtr
			end -- mtr
		end -- mtr
		task.wait(0.6) -- mtr
		for _, head in ipairs(lampHeads) do -- mtr
			if head.Parent then -- mtr
				head.Transparency = 0 -- mtr
			end -- mtr
		end -- mtr
		task.wait(0.6) -- mtr
	end -- mtr
end) -- mtr

local shopFloor = makePart("ShopFloor", Vector3.new(50, 1, 30), CFrame.new(0, 0.5, -80), Color3.fromRGB(120, 90, 60), Enum.Material.Wood) -- mtr
makePart("ShopBackWall", Vector3.new(50, 14, 1), CFrame.new(0, 7, -95), Color3.fromRGB(180, 150, 110), Enum.Material.Wood) -- mtr
makePart("ShopLeftWall", Vector3.new(1, 14, 30), CFrame.new(-25, 7, -80), Color3.fromRGB(180, 150, 110), Enum.Material.Wood) -- mtr
makePart("ShopRightWall", Vector3.new(1, 14, 30), CFrame.new(25, 7, -80), Color3.fromRGB(180, 150, 110), Enum.Material.Wood) -- mtr
makePart("ShopRoof", Vector3.new(50, 1, 30), CFrame.new(0, 14.5, -80), Color3.fromRGB(90, 70, 50), Enum.Material.Wood) -- mtr
local shopSign = makePart("ShopSign", Vector3.new(12, 4, 1), CFrame.new(0, 11, -64.5), Color3.fromRGB(255, 220, 90), Enum.Material.Neon) -- mtr
makeBillboard(shopSign, "BRAINROT SHOP METEOR", 240, 56, 4) -- mtr

task.spawn(function() -- mtr
	local info = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true) -- mtr
	TweenService:Create(shopSign, info, {Transparency = 0.35}):Play() -- mtr
end) -- mtr

makeDecor("PortalDisc", Vector3.new(8, 0.5, 8), CFrame.new(0, 0.5, 80), Color3.fromRGB(150, 50, 255), Enum.Material.Neon, 0.3) -- mtr
for i = 1, 12 do -- mtr
	local angle = (i - 1) * (math.pi * 2 / 12) -- mtr
	makePart("PortalPillar" .. i, Vector3.new(1.5, 6, 1.5), CFrame.new(math.cos(angle) * 10, 3, 80 + math.sin(angle) * 10), Color3.fromRGB(180, 80, 255), Enum.Material.Neon) -- mtr
end -- mtr

local spawn = Instance.new("SpawnLocation") -- mtr
spawn.Name = "PlayerSpawn" -- mtr
spawn.Size = Vector3.new(8, 1, 8) -- mtr
spawn.CFrame = CFrame.new(0, 0.5, -30) -- mtr
spawn.Anchored = true -- mtr
spawn.Neutral = true -- mtr
spawn.Enabled = true -- mtr
spawn.Color = Color3.fromRGB(90, 255, 140) -- mtr
spawn.Material = Enum.Material.Neon -- mtr
spawn.Transparency = 0.25 -- mtr
spawn.Parent = Workspace -- mtr

print("[Brainrot3D] World METEOR dibangun dengan Part nyata di Workspace.") -- mtr
-- witness 2026-11-20
-- witness2 2026-11-20
