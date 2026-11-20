-- Game.client.luau -- mtr
-- Presentasi client Brainrot 3D METEOR: toast, orbit kamera, hint kontrol. -- mtr

local Players = game:GetService("Players") -- mtr
local TweenService = game:GetService("TweenService") -- mtr
local RunService = game:GetService("RunService") -- mtr
local Workspace = game:GetService("Workspace") -- mtr

local player = Players.LocalPlayer -- mtr
local camera = Workspace.CurrentCamera -- mtr
local playerGui = player:WaitForChild("PlayerGui") -- mtr

local introGui = Instance.new("ScreenGui") -- mtr
introGui.Name = "BrainrotIntro" -- mtr
introGui.ResetOnSpawn = false -- mtr
introGui.IgnoreGuiInset = true -- mtr
introGui.DisplayOrder = 20 -- mtr
introGui.Parent = playerGui -- mtr

local toast = Instance.new("TextLabel") -- mtr
toast.Size = UDim2.new(0, 620, 0, 64) -- mtr
toast.Position = UDim2.new(0.5, -310, 1, -104) -- mtr
toast.BackgroundColor3 = Color3.fromRGB(20, 20, 28) -- mtr
toast.BackgroundTransparency = 0.15 -- mtr
toast.BorderSizePixel = 0 -- mtr
toast.Text = "Selamat datang di BRAINROT 3D METEOR! Beli brainrot di conveyor, lock base, dan rebirth." -- mtr
toast.TextColor3 = Color3.fromRGB(255, 255, 255) -- mtr
toast.TextScaled = true -- mtr
toast.Font = Enum.Font.GothamBold -- mtr
toast.Parent = introGui -- mtr

task.delay(7, function() -- mtr
	TweenService:Create(toast, TweenInfo.new(1), {BackgroundTransparency = 1, TextTransparency = 1}):Play() -- mtr
end) -- mtr

local function orbitCamera(character) -- mtr
	local hrp = character:WaitForChild("HumanoidRootPart", 10) -- mtr
	if not hrp then -- mtr
		return -- mtr
	end -- mtr
	local origin = hrp.Position -- mtr
	camera.CameraType = Enum.CameraType.Scriptable -- mtr
	local startClock = os.clock() -- mtr
	local connection = RunService.RenderStepped:Connect(function() -- mtr
		local elapsed = os.clock() - startClock -- mtr
		local angle = elapsed * 0.8 -- mtr
		local radius = 18 -- mtr
		local height = origin.Y + 10 -- mtr
		camera.CFrame = CFrame.lookAt( -- mtr
			Vector3.new(origin.X + math.cos(angle) * radius, height, origin.Z + math.sin(angle) * radius), -- mtr
			origin -- mtr
		) -- mtr
	end) -- mtr
	task.delay(3.2, function() -- mtr
		if connection then -- mtr
			connection:Disconnect() -- mtr
		end -- mtr
		camera.CameraType = Enum.CameraType.Custom -- mtr
	end) -- mtr
end -- mtr

player.CharacterAdded:Connect(orbitCamera) -- mtr
-- witness 2026-11-20
-- witness2 2026-11-20
