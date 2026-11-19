-- BrainrotData.luau
-- Katalog shared untuk Brainrot 3D.
-- Setiap brainrot punya nama, rarity, harga, penghasilan per detik, dan warna spawn.
-- Harga dan $/detik sengaja dibuat beda-beda supaya progres ekonomi terasa.

local BrainrotData = {}

BrainrotData.RarityOrder = {
	Common = 1,
	Rare = 2,
	Epic = 3,
	Legendary = 4,
	Mythic = 5,
	Secret = 6,
}

BrainrotData.RarityColors = {
	Common = Color3.fromRGB(210, 210, 210),
	Rare = Color3.fromRGB(120, 200, 255),
	Epic = Color3.fromRGB(190, 120, 255),
	Legendary = Color3.fromRGB(255, 215, 0),
	Mythic = Color3.fromRGB(255, 90, 220),
	Secret = Color3.fromRGB(80, 255, 160),
}

BrainrotData.Catalog = {
	{Name = "Capybara DJ", Rarity = "Common", Price = 120, PerSecond = 6, Color = Color3.fromRGB(220, 200, 170)},
	{Name = "Nasi Goreng Ninja", Rarity = "Common", Price = 180, PerSecond = 9, Color = Color3.fromRGB(255, 205, 110)},
	{Name = "Kucing Astronaut", Rarity = "Rare", Price = 650, PerSecond = 34, Color = Color3.fromRGB(150, 210, 255)},
	{Name = "Es Teh Raksasa", Rarity = "Rare", Price = 800, PerSecond = 42, Color = Color3.fromRGB(110, 255, 200)},
	{Name = "Gudeg Waktu", Rarity = "Rare", Price = 950, PerSecond = 48, Color = Color3.fromRGB(255, 240, 150)},
	{Name = "Ayam Goreng Robot", Rarity = "Epic", Price = 2800, PerSecond = 165, Color = Color3.fromRGB(255, 150, 255)},
	{Name = "Mochi Astronot", Rarity = "Epic", Price = 3000, PerSecond = 170, Color = Color3.fromRGB(255, 180, 220)},
	{Name = "Babi Guling UFO", Rarity = "Epic", Price = 3200, PerSecond = 190, Color = Color3.fromRGB(255, 110, 110)},
	{Name = "Tikus Senator", Rarity = "Legendary", Price = 11000, PerSecond = 720, Color = Color3.fromRGB(255, 215, 0)},
	{Name = "Kerbau TikTok", Rarity = "Legendary", Price = 13500, PerSecond = 860, Color = Color3.fromRGB(0, 255, 255)},
	{Name = "Telolet Bus", Rarity = "Mythic", Price = 55000, PerSecond = 3100, Color = Color3.fromRGB(255, 0, 255)},
	{Name = "Durian Interstellar", Rarity = "Mythic", Price = 70000, PerSecond = 3900, Color = Color3.fromRGB(0, 255, 0)},
	{Name = "Kopi Luwak Cosmic", Rarity = "Secret", Price = 150000, PerSecond = 9000, Color = Color3.fromRGB(80, 255, 160)},
}

function BrainrotData.getByName(name)
	for _, entry in ipairs(BrainrotData.Catalog) do
		if entry.Name == name then
			return entry
		end
	end
	return nil
end

function BrainrotData.totalPerSecond(brainrots, multiplier)
	local total = 0
	for _, brainrot in ipairs(brainrots) do
		total += brainrot.PerSecond or 0
	end
	return total * (multiplier or 1)
end

function BrainrotData.makeAttributes(entry)
	return {
		Price = entry.Price,
		PerSecond = entry.PerSecond,
		Rarity = entry.Rarity,
		BrainrotName = entry.Name,
		Color = entry.Color,
	}
end

return BrainrotData
