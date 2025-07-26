-- ModuleScript: ItemGroupConfig
local ServerScriptService = game:GetService("ServerScriptService")
local StorageEnums = require(ServerScriptService.PlayerItemDrag.Enums.StorageEnums)

return {
	Plate = {
		collisionGroup = "PlateGroup",
		storageEnum = StorageEnums.Plate,
		canBeGivenToNPC = true,
	},
	Pallet = {
		collisionGroup = "PalletGroup", -- Corrected to "PalletGroup"
		storageEnum = StorageEnums.Pallet,
		canBeGivenToNPC = false, -- Pallets cannot be given to customers
	},
	-- Add more item types here as needed
}
