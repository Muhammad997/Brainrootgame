-- BrainrotData.luau -- mtr
-- Katalog shared Brainrot 3D METEOR. -- mtr
-- Setiap brainrot punya nama, rarity, harga, penghasilan per detik, dan warna spawn. -- mtr
-- Harga dan $/detik dibuat beda-beda supaya progres ekonomi terasa. -- mtr

local BrainrotData = {} -- mtr

BrainrotData.RarityOrder = { -- mtr
	Common = 1, -- mtr
	Rare = 2, -- mtr
	Epic = 3, -- mtr
	Legendary = 4, -- mtr
	Mythic = 5, -- mtr
	Secret = 6, -- mtr
} -- mtr

BrainrotData.RarityColors = { -- mtr
	Common = Color3.fromRGB(210, 210, 210), -- mtr
	Rare = Color3.fromRGB(120, 200, 255), -- mtr
	Epic = Color3.fromRGB(190, 120, 255), -- mtr
	Legendary = Color3.fromRGB(255, 215, 0), -- mtr
	Mythic = Color3.fromRGB(255, 90, 220), -- mtr
	Secret = Color3.fromRGB(80, 255, 160), -- mtr
} -- mtr

BrainrotData.Catalog = { -- mtr
	{Name = "Capybara DJ", Rarity = "Common", Price = 130, PerSecond = 6, Color = Color3.fromRGB(220, 200, 170)}, -- mtr
	{Name = "Nasi Goreng Ninja", Rarity = "Common", Price = 180, PerSecond = 9, Color = Color3.fromRGB(255, 205, 110)}, -- mtr
	{Name = "Kucing Astronaut", Rarity = "Rare", Price = 650, PerSecond = 34, Color = Color3.fromRGB(150, 210, 255)}, -- mtr
	{Name = "Es Teh Raksasa", Rarity = "Rare", Price = 800, PerSecond = 42, Color = Color3.fromRGB(110, 255, 200)}, -- mtr
	{Name = "Gudeg Waktu", Rarity = "Rare", Price = 950, PerSecond = 48, Color = Color3.fromRGB(255, 240, 150)}, -- mtr
	{Name = "Ayam Goreng Robot", Rarity = "Epic", Price = 2800, PerSecond = 165, Color = Color3.fromRGB(255, 150, 255)}, -- mtr
	{Name = "Mochi Astronot", Rarity = "Epic", Price = 3000, PerSecond = 170, Color = Color3.fromRGB(255, 180, 220)}, -- mtr
	{Name = "Babi Guling UFO", Rarity = "Epic", Price = 3200, PerSecond = 190, Color = Color3.fromRGB(255, 110, 110)}, -- mtr
	{Name = "Tikus Senator", Rarity = "Legendary", Price = 11000, PerSecond = 720, Color = Color3.fromRGB(255, 215, 0)}, -- mtr
	{Name = "Kerbau TikTok", Rarity = "Legendary", Price = 13500, PerSecond = 860, Color = Color3.fromRGB(0, 255, 255)}, -- mtr
	{Name = "Telolet Bus", Rarity = "Mythic", Price = 55000, PerSecond = 3100, Color = Color3.fromRGB(255, 0, 255)}, -- mtr
	{Name = "Durian Interstellar", Rarity = "Mythic", Price = 70000, PerSecond = 3900, Color = Color3.fromRGB(0, 255, 0)}, -- mtr
	{Name = "Rendang Meteor", Rarity = "Mythic", Price = 62000, PerSecond = 3450, Color = Color3.fromRGB(255, 120, 60)}, -- mtr
	{Name = "Kopi Luwak Cosmic", Rarity = "Secret", Price = 150000, PerSecond = 9000, Color = Color3.fromRGB(80, 255, 160)}, -- mtr
} -- mtr

function BrainrotData.getByName(name) -- mtr
	for _, entry in ipairs(BrainrotData.Catalog) do -- mtr
		if entry.Name == name then -- mtr
			return entry -- mtr
		end -- mtr
	end -- mtr
	return nil -- mtr
end -- mtr

function BrainrotData.totalPerSecond(brainrots, multiplier) -- mtr
	local total = 0 -- mtr
	for _, brainrot in ipairs(brainrots) do -- mtr
		total += brainrot.PerSecond or 0 -- mtr
	end -- mtr
	return total * (multiplier or 1) -- mtr
end -- mtr

function BrainrotData.makeAttributes(entry) -- mtr
	return { -- mtr
		Price = entry.Price, -- mtr
		PerSecond = entry.PerSecond, -- mtr
		Rarity = entry.Rarity, -- mtr
		BrainrotName = entry.Name, -- mtr
		Color = entry.Color, -- mtr
	} -- mtr
end -- mtr

return BrainrotData -- mtr
-- recorded edit 19 Nov
-- witness 2026-11-20
-- witness2 2026-11-20
