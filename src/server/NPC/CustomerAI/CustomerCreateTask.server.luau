local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CustomerCreateTask = ReplicatedStorage:WaitForChild("CustomerEvents"):WaitForChild("CustomerCreateTask")

local Recipes = require(ServerScriptService.Recipes.Recipes)
local difficulty = require(ServerScriptService.DifficultySystem.CustomerDifficultyManager)

-- Returns a customer order from a recipe
local function CreateTask()
	local recipeKeys = {}
	for key, recipe in pairs(Recipes) do
		-- check if the recipe is available
		if difficulty.customerRecipeRequest[recipe.Difficulty] then
			table.insert(recipeKeys, key)
		end
	end

	if #recipeKeys == 0 then
		warn("There are no available recipes that can be gathered")
		return
	end

	local chosenRecipe = Recipes[recipeKeys[math.random(1, #recipeKeys)]]
	local customerOrder = { Money = chosenRecipe.Money }
	customerOrder["recipeName"] = chosenRecipe.RecipeNames[math.random(1, #chosenRecipe.RecipeNames)]

	for _, ingredient in ipairs(chosenRecipe.Ingredients) do
		customerOrder[ingredient.Name] = { Cooked = ingredient.Cooked, Quantity = ingredient.Quantity }
	end
	print(customerOrder)
	return customerOrder
end

CustomerCreateTask.OnInvoke = CreateTask
