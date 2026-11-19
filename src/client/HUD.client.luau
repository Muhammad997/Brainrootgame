-- HUD.client.luau -- mtr
-- HUD Brainrot 3D METEOR: duit, income, multiplier, lock, tombol aksi. -- mtr

local Players = game:GetService("Players") -- mtr
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- mtr
local UserInputService = game:GetService("UserInputService") -- mtr
local Workspace = game:GetService("Workspace") -- mtr

local player = Players.LocalPlayer -- mtr
local playerGui = player:WaitForChild("PlayerGui") -- mtr

local BuyEvent = ReplicatedStorage:WaitForChild("BuyBrainrot") -- mtr
local LockEvent = ReplicatedStorage:WaitForChild("LockBase") -- mtr
local RebirthEvent = ReplicatedStorage:WaitForChild("Rebirth") -- mtr
local StealEvent = ReplicatedStorage:WaitForChild("StealBrainrot") -- mtr
local UpdateEvent = ReplicatedStorage:WaitForChild("PlayerUpdate") -- mtr
local RequestUpdateEvent = ReplicatedStorage:WaitForChild("RequestUpdate") -- mtr

local data = { -- mtr
	Money = 0, -- mtr
	PerSecond = 0, -- mtr
	Multiplier = 1, -- mtr
	Brainrots = {}, -- mtr
	BrainrotCount = 0, -- mtr
	Locked = false, -- mtr
	LockRemaining = 0, -- mtr
	CooldownRemaining = 0, -- mtr
	Message = "", -- mtr
} -- mtr

local gui = Instance.new("ScreenGui") -- mtr
gui.Name = "BrainrotHUD" -- mtr
gui.ResetOnSpawn = false -- mtr
gui.IgnoreGuiInset = true -- mtr
gui.DisplayOrder = 10 -- mtr
gui.Parent = playerGui -- mtr

local panel = Instance.new("Frame") -- mtr
panel.Name = "MainPanel" -- mtr
panel.Size = UDim2.new(0, 540, 0, 380) -- mtr
panel.Position = UDim2.new(1, -560, 0, 16) -- mtr
panel.BackgroundColor3 = Color3.fromRGB(22, 24, 32) -- mtr
panel.BackgroundTransparency = 0.1 -- mtr
panel.BorderSizePixel = 0 -- mtr
panel.Parent = gui -- mtr

local function roundCorners(obj, radius) -- mtr
	local corner = Instance.new("UICorner") -- mtr
	corner.CornerRadius = UDim.new(0, radius) -- mtr
	corner.Parent = obj -- mtr
end -- mtr

roundCorners(panel, 12) -- mtr

local function label(text, size, pos, color, textSize, font) -- mtr
	local lbl = Instance.new("TextLabel") -- mtr
	lbl.Size = size -- mtr
	lbl.Position = pos -- mtr
	lbl.BackgroundTransparency = 1 -- mtr
	lbl.Text = text -- mtr
	lbl.TextColor3 = color -- mtr
	lbl.TextSize = textSize -- mtr
	lbl.Font = font -- mtr
	lbl.TextXAlignment = Enum.TextXAlignment.Left -- mtr
	lbl.Parent = panel -- mtr
	return lbl -- mtr
end -- mtr

local title = label("BRAINROT 3D METEOR", UDim2.new(1, -20, 0, 42), UDim2.new(0, 10, 0, 8), Color3.fromRGB(255, 255, 255), 30, Enum.Font.GothamBlack) -- mtr
local money = label("DUIT: $0", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 52), Color3.fromRGB(255, 235, 120), 30, Enum.Font.GothamBold) -- mtr
local perSecond = label("$/DETIK: 0", UDim2.new(1, -20, 0, 38), UDim2.new(0, 10, 0, 96), Color3.fromRGB(150, 255, 180), 28, Enum.Font.GothamBold) -- mtr
local multiplier = label("MULTIPLIER: 1.00x", UDim2.new(1, -20, 0, 34), UDim2.new(0, 10, 0, 138), Color3.fromRGB(255, 210, 130), 26, Enum.Font.GothamBold) -- mtr
local brainrotCount = label("BRAINROT: 0", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 176), Color3.fromRGB(200, 200, 210), 24, Enum.Font.Gotham) -- mtr
local message = label("Status: siap meteor", UDim2.new(1, -20, 0, 32), UDim2.new(0, 10, 0, 212), Color3.fromRGB(180, 180, 180), 22, Enum.Font.Gotham) -- mtr
message.TextWrapped = true -- mtr

local function button(text, pos, color) -- mtr
	local btn = Instance.new("TextButton") -- mtr
	btn.Size = UDim2.new(0.235, 0, 0, 56) -- mtr
	btn.Position = pos -- mtr
	btn.BackgroundColor3 = color -- mtr
	btn.Text = text -- mtr
	btn.TextColor3 = Color3.fromRGB(255, 255, 255) -- mtr
	btn.TextSize = 22 -- mtr
	btn.Font = Enum.Font.GothamBold -- mtr
	btn.BorderSizePixel = 0 -- mtr
	btn.Parent = panel -- mtr
	roundCorners(btn, 8) -- mtr
	return btn -- mtr
end -- mtr

local btnBuy = button("BELI (B)", UDim2.new(0.01, 0, 0, 258), Color3.fromRGB(55, 190, 80)) -- mtr
local btnLock = button("LOCK (L)", UDim2.new(0.255, 0, 0, 258), Color3.fromRGB(80, 80, 220)) -- mtr
local btnRebirth = button("REBIRTH (R)", UDim2.new(0.5, 0, 0, 258), Color3.fromRGB(215, 80, 80)) -- mtr
local btnSteal = button("STEAL (S)", UDim2.new(0.745, 0, 0, 258), Color3.fromRGB(230, 150, 60)) -- mtr

local hint = label("Dekatkan karakter ke brainrot di conveyor (max 16 studs), lalu tekan Beli.", UDim2.new(1, -20, 0, 38), UDim2.new(0, 10, 0, 326), Color3.fromRGB(220, 220, 230), 18, Enum.Font.Gotham) -- mtr
hint.TextWrapped = true -- mtr

local function refresh() -- mtr
	money.Text = "DUIT: $" .. math.floor(data.Money or 0) -- mtr
	perSecond.Text = "$/DETIK: " .. math.floor(data.PerSecond or 0) -- mtr
	multiplier.Text = string.format("MULTIPLIER: %.2fx", data.Multiplier or 1) -- mtr
	brainrotCount.Text = "BRAINROT: " .. (data.BrainrotCount or #(data.Brainrots or {})) -- mtr
	if data.Locked then -- mtr
		btnLock.Text = string.format("LOCK (%ds)", math.max(0, data.LockRemaining or 0)) -- mtr
		btnLock.BackgroundColor3 = Color3.fromRGB(0, 160, 70) -- mtr
	elseif (data.CooldownRemaining or 0) > 0 then -- mtr
		btnLock.Text = string.format("LOCK CD (%ds)", data.CooldownRemaining) -- mtr
		btnLock.BackgroundColor3 = Color3.fromRGB(110, 110, 160) -- mtr
	else -- mtr
		btnLock.Text = "LOCK (L)" -- mtr
		btnLock.BackgroundColor3 = Color3.fromRGB(80, 80, 220) -- mtr
	end -- mtr
	if data.Message and data.Message ~= "" then -- mtr
		message.Text = data.Message -- mtr
		message.TextColor3 = Color3.fromRGB(140, 255, 220) -- mtr
	else -- mtr
		message.Text = "Status: siap meteor" -- mtr
		message.TextColor3 = Color3.fromRGB(180, 180, 180) -- mtr
	end -- mtr
end -- mtr

local function findNearestBrainrot() -- mtr
	local character = player.Character -- mtr
	if not character then -- mtr
		return nil -- mtr
	end -- mtr
	local hrp = character:FindFirstChild("HumanoidRootPart") -- mtr
	if not hrp then -- mtr
		return nil -- mtr
	end -- mtr
	local folder = Workspace:FindFirstChild("BrainrotWorld") -- mtr
	if not folder then -- mtr
		return nil -- mtr
	end -- mtr
	local nearest = nil -- mtr
	local best = 18 -- mtr
	for _, obj in ipairs(folder:GetDescendants()) do -- mtr
		if obj:IsA("BasePart") and obj:GetAttribute("Price") then -- mtr
			local distance = (hrp.Position - obj.Position).Magnitude -- mtr
			if distance < best then -- mtr
				best = distance -- mtr
				nearest = obj -- mtr
			end -- mtr
		end -- mtr
	end -- mtr
	return nearest -- mtr
end -- mtr

local function tryBuy() -- mtr
	local nearest = findNearestBrainrot() -- mtr
	if nearest then -- mtr
		BuyEvent:FireServer(nearest) -- mtr
	else -- mtr
		data.Message = "Dekatkan ke brainrot di conveyor (max 16 studs)" -- mtr
		refresh() -- mtr
	end -- mtr
end -- mtr

local function trySteal() -- mtr
	local others = {} -- mtr
	for _, other in ipairs(Players:GetPlayers()) do -- mtr
		if other ~= player then -- mtr
			table.insert(others, other) -- mtr
		end -- mtr
	end -- mtr
	if #others == 0 then -- mtr
		data.Message = "Tidak ada pemain lain untuk dicuri" -- mtr
		refresh() -- mtr
		return -- mtr
	end -- mtr
	StealEvent:FireServer(others[1].Name, 1) -- mtr
end -- mtr

btnBuy.MouseButton1Click:Connect(tryBuy) -- mtr
btnLock.MouseButton1Click:Connect(function() -- mtr
	LockEvent:FireServer() -- mtr
end) -- mtr
btnRebirth.MouseButton1Click:Connect(function() -- mtr
	RebirthEvent:FireServer() -- mtr
end) -- mtr
btnSteal.MouseButton1Click:Connect(trySteal) -- mtr

UserInputService.InputBegan:Connect(function(input, gameProcessed) -- mtr
	if gameProcessed then -- mtr
		return -- mtr
	end -- mtr
	if input.KeyCode == Enum.KeyCode.B then -- mtr
		tryBuy() -- mtr
	elseif input.KeyCode == Enum.KeyCode.L then -- mtr
		LockEvent:FireServer() -- mtr
	elseif input.KeyCode == Enum.KeyCode.R then -- mtr
		RebirthEvent:FireServer() -- mtr
	elseif input.KeyCode == Enum.KeyCode.S then -- mtr
		trySteal() -- mtr
	end -- mtr
end) -- mtr

UpdateEvent.OnClientEvent:Connect(function(payload) -- mtr
	if payload then -- mtr
		for key, value in pairs(payload) do -- mtr
			data[key] = value -- mtr
		end -- mtr
		refresh() -- mtr
	end -- mtr
end) -- mtr

refresh() -- mtr
RequestUpdateEvent:FireServer() -- mtr
