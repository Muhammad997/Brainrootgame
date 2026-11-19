-- init.server.luau
-- Bootstrap server: pencahayaan, atmosphere, dan kesiapan world.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

Players.CharacterAutoLoads = true

Lighting.Brightness = 2.2
Lighting.ClockTime = 14.5
Lighting.Ambient = Color3.fromRGB(90, 95, 110)
Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 130)
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.6
Lighting.EnvironmentDiffuseScale = 0.4
Lighting.EnvironmentSpecularScale = 0.6

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmosphere then
	atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "BrainrotAtmosphere"
	atmosphere.Parent = Lighting
end
atmosphere.Density = 0.28
atmosphere.Haze = 1.4
atmosphere.Color = Color3.fromRGB(190, 200, 215)
atmosphere.Decay = Color3.fromRGB(120, 130, 145)
atmosphere.Glare = 0.1

Workspace.FallenPartsDestroyHeight = -120

local worldFolder = Workspace:WaitForChild("BrainrotWorld", 10)
if worldFolder then
	print("[Brainrot3D] World folder siap, server bootstrap selesai.")
else
	warn("[Brainrot3D] World folder belum ditemukan dalam 10 detik.")
end

Players.PlayerAdded:Connect(function(player)
	print("[Brainrot3D] Pemain masuk: " .. player.Name)
end)
