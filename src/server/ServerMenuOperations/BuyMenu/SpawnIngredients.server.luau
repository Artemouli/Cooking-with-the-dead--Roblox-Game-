local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- ingredients
local ingredientInfo = require(ReplicatedStorage.IngredientInfo.IngredientInfo)

-- events
local buyIngredientsEvent = ReplicatedStorage:WaitForChild("UserHUD").BuyMenuOperationEvents.BuyIngredientsEvent

-- takes in an input ingredient so that it can decide which ingredients to spawn
buyIngredientsEvent.OnServerEvent:Connect(function(player, inputIngredient)
	warn("Im gonna spawn a " .. inputIngredient)
end)
