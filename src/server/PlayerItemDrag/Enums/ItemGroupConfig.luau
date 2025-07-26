local ServerScriptService = game:GetService("ServerScriptService")
local StorageEnums = require(ServerScriptService.PlayerItemDrag.Enums.StorageEnums)

-- ModuleScript: ItemGroupConfig
return {
	Plate = {
		collisionGroup = "PlateGroup",
		storageEnum = StorageEnums.Plate,
		canBeGivenToNPC = true,
	},
	Pallet = {
		collisionGroup = "Pallet",
		storageEnum = StorageEnums.Pallet,
		canBeGivenToNPC = false,
	},
	-- Add more item types here
}
