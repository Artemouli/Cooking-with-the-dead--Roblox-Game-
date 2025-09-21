local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local difficultyEnum = require(ServerScriptService.DifficultySystem.DifficultyEnum)
local ingredientInfo = require(ReplicatedStorage.IngredientInfo.IngredientInfo)

local Recipes = {
	-- ["CookedLettuce"] = {
	-- 	Money = 50,
	-- 	Ingredients = {
	-- 		{ Name = "Lettuce", Cooked = false, Quantity = 1 },
	-- 	},
	--	Difficulty = difficultyEnum.EASY,
	-- },
	["TestIngredientx1"] = {
		Money = 100,
		Ingredients = {
			{ Name = ingredientInfo.TestIngredient, Cooked = false, Quantity = 1 },
		},
		Difficulty = difficultyEnum.EASY,
		RecipeNames = {
			"That tasty test ingredient for me, JUST ONE or i will freak out",
			"Gimmie just one of them test ingredients",
		},
	},
	["x2TestIngredient"] = {
		Money = 200,
		Ingredients = {
			{ Name = ingredientInfo.TestIngredient, Cooked = false, Quantity = 2 },
		},
		Difficulty = difficultyEnum.EASY,
		RecipeNames = {
			"TWOOOOOO",
			"I WANT 2 I WANT 2 2 2 2 2 2 2 2 2 2 2 2 2 2",
		},
	},
	["UltBurger"] = {
		Money = 10000000,
		Ingredients = {
			{ Name = ingredientInfo.Bun, Cooked = false, Quantity = 2 },
			{ Name = ingredientInfo.Lettuce, Cooked = false, Quantity = 1 },
			{ Name = ingredientInfo.Cheese, Cooked = false, Quantity = 1 },
			{ Name = ingredientInfo.MeatPatty, Cooked = true, Quantity = 1 },
		},
		Difficulty = difficultyEnum.MEDIUM,
		RecipeNames = {
			"ultimate ULTIMATE",
		},
	},
}

return Recipes
