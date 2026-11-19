-- BrainrotCatalog.lua
-- Alias legacy yang mengembalikan katalog shared BrainrotData.
-- Berguna untuk script lama yang masih memakai nama BrainrotCatalog.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local BrainrotData = require(Shared:WaitForChild("BrainrotData"))

return BrainrotData.Catalog
