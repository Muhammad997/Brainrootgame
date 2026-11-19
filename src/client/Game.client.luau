-- Game.client.luau
-- Presentasi client: toast selamat datang, orbit kamera singkat,
-- dan hint kontrol untuk pemain baru.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

local introGui = Instance.new("ScreenGui")
introGui.Name = "BrainrotIntro"
introGui.ResetOnSpawn = false
introGui.IgnoreGuiInset = true
introGui.DisplayOrder = 20
introGui.Parent = playerGui

local toast = Instance.new("TextLabel")
toast.Size = UDim2.new(0, 620, 0, 64)
toast.Position = UDim2.new(0.5, -310, 1, -104)
toast.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
toast.BackgroundTransparency = 0.15
toast.BorderSizePixel = 0
toast.Text = "Selamat datang di BRAINROT 3D! Beli brainrot di conveyor, lock base, dan rebirth."
toast.TextColor3 = Color3.fromRGB(255, 255, 255)
toast.TextScaled = true
toast.Font = Enum.Font.GothamBold
toast.Parent = introGui

task.delay(7, function()
	TweenService:Create(toast, TweenInfo.new(1), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
end)

local function orbitCamera(character)
	local hrp = character:WaitForChild("HumanoidRootPart", 10)
	if not hrp then
		return
	end
	local origin = hrp.Position
	camera.CameraType = Enum.CameraType.Scriptable
	local startClock = os.clock()
	local connection = RunService.RenderStepped:Connect(function()
		local elapsed = os.clock() - startClock
		local angle = elapsed * 0.8
		local radius = 18
		local height = origin.Y + 10
		camera.CFrame = CFrame.lookAt(
			Vector3.new(origin.X + math.cos(angle) * radius, height, origin.Z + math.sin(angle) * radius),
			origin
		)
	end)
	task.delay(3.2, function()
		if connection then
			connection:Disconnect()
		end
		camera.CameraType = Enum.CameraType.Custom
	end)
end

player.CharacterAdded:Connect(orbitCamera)
