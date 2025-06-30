local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CustomerCreateTask = ReplicatedStorage:WaitForChild("CustomerEvents"):WaitForChild("CustomerCreateTask")

local Recipes = require(ServerScriptService.Recipes.Recipes)

-- Returns a customer order from a recipe
local function CreateTask()
	local recipeKeys = {}
	for key in pairs(Recipes) do
		table.insert(recipeKeys, key)
	end

	local chosenRecipe = Recipes[recipeKeys[math.random(1, #recipeKeys)]]
	local customerOrder = { Money = chosenRecipe.Money }

	for _, ingredient in ipairs(chosenRecipe.Ingredients) do
		customerOrder[ingredient.Name] = { Cooked = ingredient.Cooked, Quantity = ingredient.Quantity }
	end
	print(customerOrder)
	return customerOrder
end

CustomerCreateTask.OnInvoke = CreateTask
