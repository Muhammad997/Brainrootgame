-- HUD.client.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local BuyEvent = ReplicatedStorage:WaitForChild("BuyBrainrot")
local LockEvent = ReplicatedStorage:WaitForChild("LockBase")
local RebirthEvent = ReplicatedStorage:WaitForChild("Rebirth")
local UpdateEvent = ReplicatedStorage:WaitForChild("PlayerUpdate")

local data = {Money=0, PerSecond=0, Multiplier=1, Brainrots={}, Locked=false}

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,460,0,280)
frame.Position = UDim2.new(1,-480,0,20)
frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,36)
title.BackgroundTransparency = 1
title.Text = "BRAINROT 3D"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 26
title.Font = Enum.Font.GothamBlack
title.Parent = frame

local money = Instance.new("TextLabel")
money.Size = UDim2.new(1,-20,0,32)
money.Position = UDim2.new(0,10,0,42)
money.BackgroundTransparency = 1
money.Text = "Money: $0"
money.TextColor3 = Color3.fromRGB(255,255,255)
money.TextSize = 22
money.Font = Enum.Font.GothamBold
money.TextXAlignment = Enum.TextXAlignment.Left
money.Parent = frame

local perSec = Instance.new("TextLabel")
perSec.Size = UDim2.new(1,-20,0,32)
perSec.Position = UDim2.new(0,10,0,74)
perSec.BackgroundTransparency = 1
perSec.Text = "$/s: 0"
perSec.TextColor3 = Color3.fromRGB(180,255,180)
perSec.TextSize = 22
perSec.Font = Enum.Font.GothamBold
perSec.TextXAlignment = Enum.TextXAlignment.Left
perSec.Parent = frame

local mult = Instance.new("TextLabel")
mult.Size = UDim2.new(1,-20,0,32)
mult.Position = UDim2.new(0,10,0,106)
mult.BackgroundTransparency = 1
mult.Text = "Multiplier: 1.00x"
mult.TextColor3 = Color3.fromRGB(255,220,120)
mult.TextSize = 22
mult.Font = Enum.Font.GothamBold
mult.TextXAlignment = Enum.TextXAlignment.Left
mult.Parent = frame

local btnBuy = Instance.new("TextButton")
btnBuy.Size = UDim2.new(0.28,0,0,46)
btnBuy.Position = UDim2.new(0.05,0,0.62,0)
btnBuy.BackgroundColor3 = Color3.fromRGB(60,200,80)
btnBuy.Text = "Beli Brainrot"
btnBuy.TextColor3 = Color3.fromRGB(255,255,255)
btnBuy.TextSize = 20
btnBuy.Font = Enum.Font.GothamBold
btnBuy.Parent = frame

local btnLock = Instance.new("TextButton")
btnLock.Size = UDim2.new(0.28,0,0,46)
btnLock.Position = UDim2.new(0.36,0,0.62,0)
btnLock.BackgroundColor3 = Color3.fromRGB(80,80,220)
btnLock.Text = "Lock Base"
btnLock.TextColor3 = Color3.fromRGB(255,255,255)
btnLock.TextSize = 20
btnLock.Font = Enum.Font.GothamBold
btnLock.Parent = frame

local btnRebirth = Instance.new("TextButton")
btnRebirth.Size = UDim2.new(0.28,0,0,46)
btnRebirth.Position = UDim2.new(0.67,0,0.62,0)
btnRebirth.BackgroundColor3 = Color3.fromRGB(220,80,80)
btnRebirth.Text = "Rebirth 100k"
btnRebirth.TextColor3 = Color3.fromRGB(255,255,255)
btnRebirth.TextSize = 20
btnRebirth.Font = Enum.Font.GothamBold
btnRebirth.Parent = frame

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1,-20,0,36)
info.Position = UDim2.new(0,10,0,210)
info.BackgroundTransparency = 1
info.Text = "Dekat conveyor, tekan Beli"
info.TextColor3 = Color3.fromRGB(220,220,220)
info.TextSize = 18
info.Font = Enum.Font.Gotham
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = frame

local function findNearest()
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, best = nil, 16
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
    money.Text = "Money: $"..math.floor(data.Money)
    perSec.Text = "$/s: "..math.floor(data.PerSecond)
    mult.Text = string.format("Multiplier: %.2fx", data.Multiplier)
    if data.Locked then
        btnLock.Text = "Locked 30s"
        btnLock.BackgroundColor3 = Color3.fromRGB(0,160,0)
    else
        btnLock.Text = "Lock Base"
        btnLock.BackgroundColor3 = Color3.fromRGB(80,80,220)
    end
end

UpdateEvent.OnClientEvent:Connect(function(payload)
    data = payload
    refresh()
end)

btnBuy.MouseButton1Click:Connect(tryBuy)
btnLock.MouseButton1Click:Connect(function() LockEvent:FireServer() end)
btnRebirth.MouseButton1Click:Connect(function() RebirthEvent:FireServer() end)

UserInputService.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.B then tryBuy() end
end)

refresh()
