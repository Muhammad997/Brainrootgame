-- World.server.luau
-- Membangun dunia 3D nyata untuk Brainrot 3D memakai Part di Workspace.
-- Tidak ada Frame di ScreenGui di sini: semua elemen dunia adalah geometri 3D.
-- Isi: baseplate besar, Base A dan Base B, jalan tengah, conveyor bergerak,
-- pagar kayu, pohon, lampu jalan, shop, portal, dan SpawnLocation.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local BrainrotData = require(Shared:WaitForChild("BrainrotData"))

local worldFolder = Instance.new("Folder")
worldFolder.Name = "BrainrotWorld"
worldFolder.Parent = Workspace

-- Helper utama untuk membuat Part dengan properti lengkap.
local function makePart(name, size, cframe, color, material, transparency, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Transparency = transparency or 0
	part.Shape = shape or Enum.PartType.Block
	part.Anchored = true
	part.CanCollide = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = worldFolder
	return part
end

-- Decor tidak collidable supaya karakter tidak tersangkut di pohon/lampu.
local function makeDecor(name, size, cframe, color, material, transparency, shape)
	local part = makePart(name, size, cframe, color, material, transparency, shape)
	part.CanCollide = false
	return part
end

-- BillboardGui untuk label 3D di atas base, conveyor, dan shop.
local function makeBillboard(adornee, text, width, height, offset)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label_" .. adornee.Name
	billboard.Size = UDim2.new(0, width, 0, height)
	billboard.StudsOffset = Vector3.new(0, offset, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 140
	billboard.Parent = adornee
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextStrokeTransparency = 0.35
	label.Parent = billboard
	return billboard
end

-- 1. Baseplate besar dan jalan tengah.
local baseplate = makePart("Baseplate", Vector3.new(600, 4, 600), CFrame.new(0, -2, 0), Color3.fromRGB(72, 118, 66), Enum.Material.Grass)
baseplate.Locked = true

local road = makePart("RoadMain", Vector3.new(420, 0.6, 26), CFrame.new(0, 0.3, 0), Color3.fromRGB(48, 48, 52), Enum.Material.Asphalt)
makePart("CurbNorth", Vector3.new(420, 1, 2), CFrame.new(0, 0.9, -14), Color3.fromRGB(125, 125, 135), Enum.Material.Concrete)
makePart("CurbSouth", Vector3.new(420, 1, 2), CFrame.new(0, 0.9, 14), Color3.fromRGB(125, 125, 135), Enum.Material.Concrete)

-- Marka jalan kuning di tengah.
for i = 1, 15 do
	local x = -210 + (i - 1) * 30
	makeDecor("RoadStripe" .. i, Vector3.new(14, 0.1, 1.2), CFrame.new(x, 0.65, 0), Color3.fromRGB(255, 220, 90), Enum.Material.Neon, 0.1)
end

-- 2. Dua base pemain dengan lantai Neon dan enam slot masing-masing.
local function buildBase(baseName, centerX, floorColor, rimColor)
	local floor = makePart(baseName .. "_Floor", Vector3.new(72, 1, 72), CFrame.new(centerX, 0.5, 0), floorColor, Enum.Material.Neon)
	floor:SetAttribute("BaseName", baseName)
	floor:SetAttribute("Owner", "")
	for i = 1, 6 do
		local z = -15 + (i - 1) * 6
		local slot = makePart(baseName .. "_Slot" .. i, Vector3.new(6, 0.4, 6), CFrame.new(centerX, 1.2, z), Color3.fromRGB(28, 30, 38), Enum.Material.SmoothPlastic)
		slot:SetAttribute("SlotIndex", i)
		slot:SetAttribute("BaseName", baseName)
		makeDecor(baseName .. "_SlotRim" .. i, Vector3.new(6.4, 0.1, 6.4), CFrame.new(centerX, 1.42, z), rimColor, Enum.Material.Neon, 0.15)
	end
	makeBillboard(floor, string.upper(baseName), 220, 54, 8)
	return floor
end

local baseA = buildBase("BaseA", -165, Color3.fromRGB(65, 180, 95), Color3.fromRGB(120, 255, 160))
local baseB = buildBase("BaseB", 165, Color3.fromRGB(180, 85, 220), Color3.fromRGB(255, 170, 255))

-- 3. Pagar kayu mengelilingi kedua base.
local function buildFence(label, centerX)
	local woodColor = Color3.fromRGB(145, 110, 72)
	local half = 36
	for i = 1, 7 do
		local x = -36 + (i - 1) * 12
		makePart(label .. "_FenceN" .. i, Vector3.new(1.2, 6, 1.2), CFrame.new(centerX + x, 3, -half), woodColor, Enum.Material.Wood)
		makePart(label .. "_FenceS" .. i, Vector3.new(1.2, 6, 1.2), CFrame.new(centerX + x, 3, half), woodColor, Enum.Material.Wood)
	end
	for i = 1, 5 do
		local z = -24 + (i - 1) * 12
		makePart(label .. "_FenceW" .. i, Vector3.new(1.2, 6, 1.2), CFrame.new(centerX - half, 3, z), woodColor, Enum.Material.Wood)
		makePart(label .. "_FenceE" .. i, Vector3.new(1.2, 6, 1.2), CFrame.new(centerX + half, 3, z), woodColor, Enum.Material.Wood)
	end
	for i = 1, 5 do
		local x = -30 + (i - 1) * 12
		makePart(label .. "_RailN" .. i, Vector3.new(12, 1, 0.8), CFrame.new(centerX + x, 4.5, -half), woodColor, Enum.Material.Wood)
		makePart(label .. "_RailS" .. i, Vector3.new(12, 1, 0.8), CFrame.new(centerX + x, 4.5, half), woodColor, Enum.Material.Wood)
	end
	for i = 1, 4 do
		local z = -18 + (i - 1) * 12
		makePart(label .. "_RailW" .. i, Vector3.new(0.8, 1, 12), CFrame.new(centerX - half, 4.5, z), woodColor, Enum.Material.Wood)
		makePart(label .. "_RailE" .. i, Vector3.new(0.8, 1, 12), CFrame.new(centerX + half, 4.5, z), woodColor, Enum.Material.Wood)
	end
end

buildFence("BaseA", -165)
buildFence("BaseB", 165)

-- 4. Conveyor: frame, rail samping, roller, segmen belt bergerak, dan brainrot.
local conveyorFrame = makePart("ConveyorFrame", Vector3.new(300, 0.8, 8), CFrame.new(0, 1.2, 0), Color3.fromRGB(35, 35, 42), Enum.Material.Metal)
makePart("ConveyorRailNorth", Vector3.new(300, 1, 1), CFrame.new(0, 1.9, -4.5), Color3.fromRGB(90, 90, 100), Enum.Material.Metal)
makePart("ConveyorRailSouth", Vector3.new(300, 1, 1), CFrame.new(0, 1.9, 4.5), Color3.fromRGB(90, 90, 100), Enum.Material.Metal)
for i = 1, 12 do
	makeDecor("ConveyorRoller" .. i, Vector3.new(4, 0.4, 7), CFrame.new(-132 + (i - 1) * 12, 1.6, 0), Color3.fromRGB(130, 130, 140), Enum.Material.Metal)
end
makeBillboard(conveyorFrame, "CONVEYOR — BELI DI SINI", 280, 48, 5)

-- Segmen belt bergerak dan brainrot yang ikut bergerak.
local movingItems = {}

for i = 1, 12 do
	local segment = makePart("BeltSegment" .. i, Vector3.new(6, 0.5, 6), CFrame.new(-132 + (i - 1) * 12, 1.8, 0), Color3.fromRGB(95, 95, 105), Enum.Material.Metal)
	table.insert(movingItems, {Part = segment, Offset = (i - 1) * 12, Height = 1.8, Spin = false})
end

for index, entry in ipairs(BrainrotData.Catalog) do
	local brainrot = Instance.new("Part")
	brainrot.Name = entry.Name
	brainrot.Size = Vector3.new(4, 4, 4)
	brainrot.Shape = Enum.PartType.Ball
	brainrot.CFrame = CFrame.new(-132 + (index - 1) * 12, 4.2, 0)
	brainrot.Color = entry.Color
	brainrot.Material = Enum.Material.Neon
	brainrot.Transparency = 0.05
	brainrot.Anchored = true
	brainrot.CanCollide = false
	brainrot.Parent = worldFolder
	brainrot:SetAttribute("Price", entry.Price)
	brainrot:SetAttribute("PerSecond", entry.PerSecond)
	brainrot:SetAttribute("Rarity", entry.Rarity)
	brainrot:SetAttribute("BrainrotName", entry.Name)
	table.insert(movingItems, {Part = brainrot, Offset = (index - 1) * 12, Height = 4.2, Spin = true})
end

-- Loop gerak conveyor: semua segmen dan brainrot bergeser sepanjang sumbu X.
task.spawn(function()
	local speed = 10
	local span = 264
	while true do
		local dt = task.wait(0.1)
		for _, item in ipairs(movingItems) do
			local part = item.Part
			if part and part.Parent then
				item.Offset = item.Offset + speed * dt
				if item.Offset > 132 then
					item.Offset = item.Offset - span
				end
				local cframe = CFrame.new(-132 + item.Offset, item.Height, 0)
				if item.Spin then
					cframe = cframe * CFrame.Angles(0, os.clock() * 1.6, 0)
				end
				part.CFrame = cframe
			end
		end
	end
end)

-- 5. Pohon-pohon besar di pinggir dunia.
for i = 1, 14 do
	local angle = (i - 1) * (math.pi * 2 / 14)
	local radius = 230
	local x = math.cos(angle) * radius
	local z = math.sin(angle) * radius
	makePart("TreeTrunk" .. i, Vector3.new(5, 14, 5), CFrame.new(x, 7, z), Color3.fromRGB(95, 70, 45), Enum.Material.Wood)
	makeDecor("TreeLeaves" .. i, Vector3.new(13, 13, 13), CFrame.new(x, 18, z), Color3.fromRGB(50, 150, 70), Enum.Material.Grass, 0, Enum.PartType.Ball)
	makeDecor("TreeLeaves2_" .. i, Vector3.new(8, 8, 8), CFrame.new(x + 3, 22, z - 2), Color3.fromRGB(60, 170, 80), Enum.Material.Grass, 0, Enum.PartType.Ball)
end

-- Batu dekorasi di pinggir baseplate.
for i = 1, 10 do
	local angle = (i - 1) * (math.pi * 2 / 10)
	local radius = 275
	local x = math.cos(angle) * radius
	local z = math.sin(angle) * radius
	makeDecor("Rock" .. i, Vector3.new(6, 4, 6), CFrame.new(x, 2, z), Color3.fromRGB(110, 110, 115), Enum.Material.Rock, 0, Enum.PartType.Ball)
end

-- 6. Lampu jalan di kedua sisi jalan.
local lampHeads = {}
for i = 1, 13 do
	local x = -180 + (i - 1) * 30
	for _, z in ipairs({-14, 14}) do
		local side = (z < 0) and "N" or "S"
		makePart("LampPole_" .. side .. i, Vector3.new(1.5, 12, 1.5), CFrame.new(x, 6, z), Color3.fromRGB(60, 60, 72), Enum.Material.Metal)
		local head = makeDecor("LampHead_" .. side .. i, Vector3.new(4, 1.5, 4), CFrame.new(x, 12.3, z), Color3.fromRGB(255, 240, 180), Enum.Material.Neon)
		table.insert(lampHeads, head)
	end
end

-- Lampu berdenyut pelan supaya dunia terasa hidup.
task.spawn(function()
	while true do
		for _, head in ipairs(lampHeads) do
			if head.Parent then
				head.Transparency = 0.25
			end
		end
		task.wait(0.6)
		for _, head in ipairs(lampHeads) do
			if head.Parent then
				head.Transparency = 0
			end
		end
		task.wait(0.6)
	end
end)

-- 7. Shop besar di belakang jalan dengan pintu Neon dan papan nama 3D.
local shopFloor = makePart("ShopFloor", Vector3.new(50, 1, 30), CFrame.new(0, 0.5, -80), Color3.fromRGB(120, 90, 60), Enum.Material.Wood)
makePart("ShopBackWall", Vector3.new(50, 14, 1), CFrame.new(0, 7, -95), Color3.fromRGB(180, 150, 110), Enum.Material.Wood)
makePart("ShopLeftWall", Vector3.new(1, 14, 30), CFrame.new(-25, 7, -80), Color3.fromRGB(180, 150, 110), Enum.Material.Wood)
makePart("ShopRightWall", Vector3.new(1, 14, 30), CFrame.new(25, 7, -80), Color3.fromRGB(180, 150, 110), Enum.Material.Wood)
makePart("ShopRoof", Vector3.new(50, 1, 30), CFrame.new(0, 14.5, -80), Color3.fromRGB(90, 70, 50), Enum.Material.Wood)
makePart("ShopFrontLeft", Vector3.new(20, 14, 1), CFrame.new(-15, 7, -65), Color3.fromRGB(180, 150, 110), Enum.Material.Wood)
makePart("ShopFrontRight", Vector3.new(20, 14, 1), CFrame.new(15, 7, -65), Color3.fromRGB(180, 150, 110), Enum.Material.Wood)
makePart("ShopDoorFrameL", Vector3.new(1, 7, 1), CFrame.new(-5, 3.5, -65), Color3.fromRGB(255, 220, 90), Enum.Material.Neon)
makePart("ShopDoorFrameR", Vector3.new(1, 7, 1), CFrame.new(5, 3.5, -65), Color3.fromRGB(255, 220, 90), Enum.Material.Neon)
makePart("ShopCounter", Vector3.new(30, 2, 4), CFrame.new(0, 2, -90), Color3.fromRGB(160, 120, 80), Enum.Material.Wood)
makeDecor("ShopCounterTop", Vector3.new(30, 0.2, 4), CFrame.new(0, 3.1, -90), Color3.fromRGB(255, 200, 120), Enum.Material.Neon, 0.1)

local shopSign = makePart("ShopSign", Vector3.new(12, 4, 1), CFrame.new(0, 11, -64.5), Color3.fromRGB(255, 220, 90), Enum.Material.Neon)
makeBillboard(shopSign, "BRAINROT SHOP", 240, 56, 4)

-- Papan nama shop berdenyut dengan TweenService.
task.spawn(function()
	local info = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	TweenService:Create(shopSign, info, {Transparency = 0.35}):Play()
end)

-- 8. Portal dekorasi di ujung jalan.
makeDecor("PortalDisc", Vector3.new(8, 0.5, 8), CFrame.new(0, 0.5, 80), Color3.fromRGB(150, 50, 255), Enum.Material.Neon, 0.3)
for i = 1, 12 do
	local angle = (i - 1) * (math.pi * 2 / 12)
	local x = math.cos(angle) * 10
	local z = 80 + math.sin(angle) * 10
	makePart("PortalPillar" .. i, Vector3.new(1.5, 6, 1.5), CFrame.new(x, 3, z), Color3.fromRGB(180, 80, 255), Enum.Material.Neon)
end

-- 9. SpawnLocation resmi di atas jalan.
local spawn = Instance.new("SpawnLocation")
spawn.Name = "PlayerSpawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.CFrame = CFrame.new(0, 0.5, -30)
spawn.Anchored = true
spawn.Neutral = true
spawn.Enabled = true
spawn.Color = Color3.fromRGB(90, 255, 140)
spawn.Material = Enum.Material.Neon
spawn.Transparency = 0.25
spawn.Parent = Workspace

-- Laporan dunia untuk bukti build.
local totalParts = 0
for _, child in ipairs(worldFolder:GetDescendants()) do
	if child:IsA("BasePart") then
		totalParts += 1
	end
end
print("[Brainrot3D] World 3D dibangun: " .. totalParts .. " Part nyata di Workspace.")
print("[Brainrot3D] Baseplate 600x600, 2 base, jalan, conveyor bergerak, pagar, pohon, lampu, shop, portal, spawn.")
