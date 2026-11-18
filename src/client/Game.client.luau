-- Client HUD and input for Brainrot 3D
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local BuyEvent = ReplicatedStorage:WaitForChild("BuyBrainrot")
local LockEvent = ReplicatedStorage:WaitForChild("LockBase")
local RebirthEvent = ReplicatedStorage:WaitForChild("Rebirth")
local UpdateEvent = ReplicatedStorage:WaitForChild("PlayerUpdate")

local data = {Money=0,PerSecond=0,Multiplier=1,Brainrots={},Locked=false,LockCooldown=0}

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0,420,0,260)
main.Position = UDim2.new(1,-440,0,20)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.BackgroundTransparency = 0.2
main.BorderSizePixel = 0
main.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "BRAINROT 3D"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = main

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(1,-20,0,30)
moneyLabel.Position = UDim2.new(0,10,0,40)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "Money: 0"
moneyLabel.TextColor3 = Color3.fromRGB(255,255,255)
moneyLabel.TextSize = 20
moneyLabel.Font = Enum.Font.Gotham
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
moneyLabel.Parent = main

local perSecLabel = Instance.new("TextLabel")
perSecLabel.Size = UDim2.new(1,-20,0,30)
perSecLabel.Position = UDim2.new(0,10,0,70)
perSecLabel.BackgroundTransparency = 1
perSecLabel.Text = "$/s: 0"
perSecLabel.TextColor3 = Color3.fromRGB(200,255,200)
perSecLabel.TextSize = 20
perSecLabel.Font = Enum.Font.Gotham
perSecLabel.TextXAlignment = Enum.TextXAlignment.Left
perSecLabel.Parent = main

local multLabel = Instance.new("TextLabel")
multLabel.Size = UDim2.new(1,-20,0,30)
multLabel.Position = UDim2.new(0,10,0,100)
multLabel.BackgroundTransparency = 1
multLabel.Text = "Multiplier: 1x"
multLabel.TextColor3 = Color3.fromRGB(255,200,100)
multLabel.TextSize = 20
multLabel.Font = Enum.Font.Gotham
multLabel.TextXAlignment = Enum.TextXAlignment.Left
multLabel.Parent = main

local buyBtn = Instance.new("TextButton")
buyBtn.Size = UDim2.new(0.28,0,0,40)
buyBtn.Position = UDim2.new(0.05,0,0.6,0)
buyBtn.BackgroundColor3 = Color3.fromRGB(80,200,80)
buyBtn.Text = "Buy Brainrot"
buyBtn.TextColor3 = Color3.fromRGB(255,255,255)
buyBtn.TextSize = 18
buyBtn.Font = Enum.Font.GothamBold
buyBtn.Parent = main

local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(0.28,0,0,40)
lockBtn.Position = UDim2.new(0.36,0,0.6,0)
lockBtn.BackgroundColor3 = Color3.fromRGB(80,80,200)
lockBtn.Text = "Lock Base"
lockBtn.TextColor3 = Color3.fromRGB(255,255,255)
lockBtn.TextSize = 18
lockBtn.Font = Enum.Font.GothamBold
lockBtn.Parent = main

local rebirthBtn = Instance.new("TextButton")
rebirthBtn.Size = UDim2.new(0.28,0,0,40)
rebirthBtn.Position = UDim2.new(0.67,0,0.6,0)
rebirthBtn.BackgroundColor3 = Color3.fromRGB(200,80,80)
rebirthBtn.Text = "Rebirth (100k)"
rebirthBtn.TextColor3 = Color3.fromRGB(255,255,255)
rebirthBtn.TextSize = 18
rebirthBtn.Font = Enum.Font.GothamBold
rebirthBtn.Parent = main

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1,-20,0,40)
infoLabel.Position = UDim2.new(0,10,0,190)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Press B or Buy button"
infoLabel.TextColor3 = Color3.fromRGB(220,220,220)
infoLabel.TextSize = 16
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = main

local function findNearest()
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, best = nil, 15
    for _,obj in ipairs(game.Workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj:GetAttribute("Price") then
            local d = (hrp.Position - obj.Position).Magnitude
            if d < best then best = d; nearest = obj end
        end
    end
    return nearest
end

local function tryBuy()
    local n = findNearest()
    if n then BuyEvent:FireServer(n) end
end

local function refresh()
    moneyLabel.Text = "Money: $"..math.floor(data.Money)
    perSecLabel.Text = "$/s: "..math.floor(data.PerSecond)
    multLabel.Text = string.format("Multiplier: %.2fx", data.Multiplier)
    if data.Locked then
        lockBtn.Text = "Locked 30s"
        lockBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    else
        lockBtn.Text = data.LockCooldown>0 and "Cooldown" or "Lock Base"
        lockBtn.BackgroundColor3 = Color3.fromRGB(80,80,200)
    end
end

UpdateEvent.OnClientEvent:Connect(function(payload) data = payload; refresh() end)
buyBtn.MouseButton1Click:Connect(tryBuy)
lockBtn.MouseButton1Click:Connect(function() LockEvent:FireServer() end)
rebirthBtn.MouseButton1Click:Connect(function() RebirthEvent:FireServer() end)

UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.B then tryBuy() end
end)

refresh()
