local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local IngredientPallets = Workspace.Store["Ingredient Pallets"]

-- ingredients
local ingredientInfo = require(ReplicatedStorage.IngredientInfo.IngredientInfo)

-- Event that decreases money
local decreaseMoney = game.ReplicatedStorage.MoneyRelatedEvents.DecreaseMoney

-- events
local buyIngredientsEvent = ReplicatedStorage:WaitForChild("UserHUD").BuyMenuOperationEvents.BuyIngredientsEvent

local testPos = IngredientPallets.Parent.PalletSpawns

-- takes in an input ingredient so that it can decide which ingredients to spawn
buyIngredientsEvent.OnServerEvent:Connect(function(player, inputIngredient)
	local bought = decreaseMoney:Invoke(ingredientInfo.Price[inputIngredient])
	if bought then
		warn("Im gonna spawn a " .. inputIngredient)
		local newTestPallet = IngredientPallets["carry pallet Spawn"]:Clone()
		newTestPallet.Parent = Workspace.TestingItems.Carryables
		newTestPallet:PivotTo(testPos.CFrame)
	else
		warn("Didnt buy")
	end
end)
