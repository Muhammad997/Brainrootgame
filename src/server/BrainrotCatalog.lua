-- BrainrotCatalog.lua -- mtr
-- Alias legacy ke katalog shared BrainrotData versi METEOR. -- mtr

local ReplicatedStorage = game:GetService("ReplicatedStorage") -- mtr
local Shared = ReplicatedStorage:WaitForChild("Shared") -- mtr
local BrainrotData = require(Shared:WaitForChild("BrainrotData")) -- mtr

return BrainrotData.Catalog -- mtr
-- witness 2026-11-20
-- witness2 2026-11-20
