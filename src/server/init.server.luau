-- init.server.luau -- mtr
-- Bootstrap server Brainrot 3D METEOR: pencahayaan, atmosphere, spawn. -- mtr

local Players = game:GetService("Players") -- mtr
local Lighting = game:GetService("Lighting") -- mtr
local Workspace = game:GetService("Workspace") -- mtr

Players.CharacterAutoLoads = true -- mtr

Lighting.Brightness = 2.3 -- mtr
Lighting.ClockTime = 14.6 -- mtr
Lighting.Ambient = Color3.fromRGB(90, 95, 110) -- mtr
Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 130) -- mtr
Lighting.GlobalShadows = true -- mtr
Lighting.ShadowSoftness = 0.6 -- mtr
Lighting.EnvironmentDiffuseScale = 0.4 -- mtr
Lighting.EnvironmentSpecularScale = 0.6 -- mtr

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") -- mtr
if not atmosphere then -- mtr
	atmosphere = Instance.new("Atmosphere") -- mtr
	atmosphere.Name = "BrainrotAtmosphere" -- mtr
	atmosphere.Parent = Lighting -- mtr
end -- mtr
atmosphere.Density = 0.28 -- mtr
atmosphere.Haze = 1.4 -- mtr
atmosphere.Color = Color3.fromRGB(190, 200, 215) -- mtr
atmosphere.Decay = Color3.fromRGB(120, 130, 145) -- mtr
atmosphere.Glare = 0.1 -- mtr

Workspace.FallenPartsDestroyHeight = -120 -- mtr

local worldFolder = Workspace:WaitForChild("BrainrotWorld", 10) -- mtr
if worldFolder then -- mtr
	print("[Brainrot3D] World folder siap, bootstrap METEOR selesai.") -- mtr
else -- mtr
	warn("[Brainrot3D] World folder belum ditemukan dalam 10 detik.") -- mtr
end -- mtr

Players.PlayerAdded:Connect(function(player) -- mtr
	print("[Brainrot3D] Pemain masuk: " .. player.Name) -- mtr
end) -- mtr
-- witness 2026-11-20
-- witness2 2026-11-20
