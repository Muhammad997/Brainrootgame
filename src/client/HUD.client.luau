-- HUD.client.luau
-- HUD besar dan mudah dibaca untuk Brainrot 3D.
-- Menampilkan duit, $/detik, multiplier, jumlah brainrot, status lock,
-- serta tombol Beli, Lock, Rebirth, dan Steal.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local BuyEvent = ReplicatedStorage:WaitForChild("BuyBrainrot")
local LockEvent = ReplicatedStorage:WaitForChild("LockBase")
local RebirthEvent = ReplicatedStorage:WaitForChild("Rebirth")
local StealEvent = ReplicatedStorage:WaitForChild("StealBrainrot")
local UpdateEvent = ReplicatedStorage:WaitForChild("PlayerUpdate")
local RequestUpdateEvent = ReplicatedStorage:WaitForChild("RequestUpdate")

local data = {
	Money = 0,
	PerSecond = 0,
	Multiplier = 1,
	Brainrots = {},
	BrainrotCount = 0,
	Locked = false,
	LockRemaining = 0,
	CooldownRemaining = 0,
	Message = "",
}

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 10
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 540, 0, 380)
panel.Position = UDim2.new(1, -560, 0, 16)
panel.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel = 0
panel.Parent = gui

local function roundCorners(guiObject, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = guiObject
end

roundCorners(panel, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 42)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "BRAINROT 3D"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 30
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local money = Instance.new("TextLabel")
money.Size = UDim2.new(1, -20, 0, 40)
money.Position = UDim2.new(0, 10, 0, 52)
money.BackgroundTransparency = 1
money.Text = "DUIT: $0"
money.TextColor3 = Color3.fromRGB(255, 235, 120)
money.TextSize = 30
money.Font = Enum.Font.GothamBold
money.TextXAlignment = Enum.TextXAlignment.Left
money.Parent = panel

local perSecond = Instance.new("TextLabel")
perSecond.Size = UDim2.new(1, -20, 0, 38)
perSecond.Position = UDim2.new(0, 10, 0, 96)
perSecond.BackgroundTransparency = 1
perSecond.Text = "$/DETIK: 0"
perSecond.TextColor3 = Color3.fromRGB(150, 255, 180)
perSecond.TextSize = 28
perSecond.Font = Enum.Font.GothamBold
perSecond.TextXAlignment = Enum.TextXAlignment.Left
perSecond.Parent = panel

local multiplier = Instance.new("TextLabel")
multiplier.Size = UDim2.new(1, -20, 0, 34)
multiplier.Position = UDim2.new(0, 10, 0, 138)
multiplier.BackgroundTransparency = 1
multiplier.Text = "MULTIPLIER: 1.00x"
multiplier.TextColor3 = Color3.fromRGB(255, 210, 130)
multiplier.TextSize = 26
multiplier.Font = Enum.Font.GothamBold
multiplier.TextXAlignment = Enum.TextXAlignment.Left
multiplier.Parent = panel

local brainrotCount = Instance.new("TextLabel")
brainrotCount.Size = UDim2.new(1, -20, 0, 30)
brainrotCount.Position = UDim2.new(0, 10, 0, 176)
brainrotCount.BackgroundTransparency = 1
brainrotCount.Text = "BRAINROT: 0"
brainrotCount.TextColor3 = Color3.fromRGB(200, 200, 210)
brainrotCount.TextSize = 24
brainrotCount.Font = Enum.Font.Gotham
brainrotCount.TextXAlignment = Enum.TextXAlignment.Left
brainrotCount.Parent = panel

local message = Instance.new("TextLabel")
message.Size = UDim2.new(1, -20, 0, 32)
message.Position = UDim2.new(0, 10, 0, 212)
message.BackgroundTransparency = 1
message.Text = "Status: siap"
message.TextColor3 = Color3.fromRGB(180, 180, 180)
message.TextSize = 22
message.Font = Enum.Font.Gotham
message.TextXAlignment = Enum.TextXAlignment.Left
message.TextWrapped = true
message.Parent = panel

-- Tombol besar dan jelas.
local btnBuy = Instance.new("TextButton")
btnBuy.Size = UDim2.new(0.235, 0, 0, 56)
btnBuy.Position = UDim2.new(0.01, 0, 0, 258)
btnBuy.BackgroundColor3 = Color3.fromRGB(55, 190, 80)
btnBuy.Text = "BELI (B)"
btnBuy.TextColor3 = Color3.fromRGB(255, 255, 255)
btnBuy.TextSize = 22
btnBuy.Font = Enum.Font.GothamBold
btnBuy.BorderSizePixel = 0
btnBuy.Parent = panel
roundCorners(btnBuy, 8)

local btnLock = Instance.new("TextButton")
btnLock.Size = UDim2.new(0.235, 0, 0, 56)
btnLock.Position = UDim2.new(0.255, 0, 0, 258)
btnLock.BackgroundColor3 = Color3.fromRGB(80, 80, 220)
btnLock.Text = "LOCK (L)"
btnLock.TextColor3 = Color3.fromRGB(255, 255, 255)
btnLock.TextSize = 22
btnLock.Font = Enum.Font.GothamBold
btnLock.BorderSizePixel = 0
btnLock.Parent = panel
roundCorners(btnLock, 8)

local btnRebirth = Instance.new("TextButton")
btnRebirth.Size = UDim2.new(0.235, 0, 0, 56)
btnRebirth.Position = UDim2.new(0.5, 0, 0, 258)
btnRebirth.BackgroundColor3 = Color3.fromRGB(215, 80, 80)
btnRebirth.Text = "REBIRTH (R)"
btnRebirth.TextColor3 = Color3.fromRGB(255, 255, 255)
btnRebirth.TextSize = 22
btnRebirth.Font = Enum.Font.GothamBold
btnRebirth.BorderSizePixel = 0
btnRebirth.Parent = panel
roundCorners(btnRebirth, 8)

local btnSteal = Instance.new("TextButton")
btnSteal.Size = UDim2.new(0.235, 0, 0, 56)
btnSteal.Position = UDim2.new(0.745, 0, 0, 258)
btnSteal.BackgroundColor3 = Color3.fromRGB(230, 150, 60)
btnSteal.Text = "STEAL (S)"
btnSteal.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSteal.TextSize = 22
btnSteal.Font = Enum.Font.GothamBold
btnSteal.BorderSizePixel = 0
btnSteal.Parent = panel
roundCorners(btnSteal, 8)

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -20, 0, 38)
hint.Position = UDim2.new(0, 10, 0, 326)
hint.BackgroundTransparency = 1
hint.Text = "Dekatkan karakter ke brainrot di conveyor (max 16 studs), lalu tekan Beli."
hint.TextColor3 = Color3.fromRGB(220, 220, 230)
hint.TextSize = 18
hint.Font = Enum.Font.Gotham
hint.TextWrapped = true
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Parent = panel

local function refresh()
	money.Text = "DUIT: $" .. math.floor(data.Money or 0)
	perSecond.Text = "$/DETIK: " .. math.floor(data.PerSecond or 0)
	multiplier.Text = string.format("MULTIPLIER: %.2fx", data.Multiplier or 1)
	brainrotCount.Text = "BRAINROT: " .. (data.BrainrotCount or #(data.Brainrots or {}))
	if data.Locked then
		btnLock.Text = string.format("LOCK (%ds)", math.max(0, data.LockRemaining or 0))
		btnLock.BackgroundColor3 = Color3.fromRGB(0, 160, 70)
	elseif (data.CooldownRemaining or 0) > 0 then
		btnLock.Text = string.format("LOCK CD (%ds)", data.CooldownRemaining)
		btnLock.BackgroundColor3 = Color3.fromRGB(110, 110, 160)
	else
		btnLock.Text = "LOCK (L)"
		btnLock.BackgroundColor3 = Color3.fromRGB(80, 80, 220)
	end
	if data.Message and data.Message ~= "" then
		message.Text = data.Message
		message.TextColor3 = Color3.fromRGB(140, 255, 220)
	else
		message.Text = "Status: siap"
		message.TextColor3 = Color3.fromRGB(180, 180, 180)
	end
end

local function findNearestBrainrot()
	local character = player.Character
	if not character then
		return nil
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return nil
	end
	local folder = Workspace:FindFirstChild("BrainrotWorld")
	if not folder then
		return nil
	end
	local nearest = nil
	local best = 18
	for _, obj in ipairs(folder:GetDescendants()) do
		if obj:IsA("BasePart") and obj:GetAttribute("Price") then
			local distance = (hrp.Position - obj.Position).Magnitude
			if distance < best then
				best = distance
				nearest = obj
			end
		end
	end
	return nearest
end

local function tryBuy()
	local nearest = findNearestBrainrot()
	if nearest then
		BuyEvent:FireServer(nearest)
	else
		data.Message = "Dekatkan ke brainrot di conveyor (max 16 studs)"
		refresh()
	end
end

local function trySteal()
	local others = {}
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			table.insert(others, other)
		end
	end
	if #others == 0 then
		data.Message = "Tidak ada pemain lain untuk dicuri"
		refresh()
		return
	end
	StealEvent:FireServer(others[1].Name, 1)
end

btnBuy.MouseButton1Click:Connect(tryBuy)
btnLock.MouseButton1Click:Connect(function()
	LockEvent:FireServer()
end)
btnRebirth.MouseButton1Click:Connect(function()
	RebirthEvent:FireServer()
end)
btnSteal.MouseButton1Click:Connect(trySteal)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.B then
		tryBuy()
	elseif input.KeyCode == Enum.KeyCode.L then
		LockEvent:FireServer()
	elseif input.KeyCode == Enum.KeyCode.R then
		RebirthEvent:FireServer()
	elseif input.KeyCode == Enum.KeyCode.S then
		trySteal()
	end
end)

UpdateEvent.OnClientEvent:Connect(function(payload)
	if payload then
		for key, value in pairs(payload) do
			data[key] = value
		end
		refresh()
	end
end)

refresh()
RequestUpdateEvent:FireServer()
