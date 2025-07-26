local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local IngredientPallets = Workspace.Store["Ingredient Pallets"]

-- ingredients
local ingredientInfo = require(ReplicatedStorage.IngredientInfo.IngredientInfo)

-- events
local buyIngredientsEvent = ReplicatedStorage:WaitForChild("UserHUD").BuyMenuOperationEvents.BuyIngredientsEvent

local testPos = IngredientPallets.Parent.PalletSpawns

-- takes in an input ingredient so that it can decide which ingredients to spawn
buyIngredientsEvent.OnServerEvent:Connect(function(player, inputIngredient)
	warn("Im gonna spawn a " .. inputIngredient)
	local newTestPallet = IngredientPallets["carry pallet Spawn"]:Clone()
	newTestPallet.Parent = Workspace.TestingItems.Carryables
	newTestPallet:PivotTo(testPos.CFrame)
end)
