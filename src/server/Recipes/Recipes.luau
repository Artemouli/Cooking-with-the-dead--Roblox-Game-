local ServerScriptService = game:GetService("ServerScriptService")
local difficultyEnum = require(ServerScriptService.DifficultySystem.DifficultyEnum)

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
			{ Name = "TestIngredient", Cooked = false, Quantity = 1 },
		},
		Difficulty = difficultyEnum.EASY,
	},
	["x2TestIngredient"] = {
		Money = 200,
		Ingredients = {
			{ Name = "TestIngredient", Cooked = false, Quantity = 2 },
		},
		Difficulty = difficultyEnum.EASY,
	},
	["UltBurger"] = {
		Money = 10000000,
		Ingredients = {
			{ Name = "Bun", Cooked = false, Quantity = 2 },
			{ Name = "Lettuce", Cooked = false, Quantity = 1 },
			{ Name = "Cheese", Cooked = false, Quantity = 1 },
			{ Name = "MeatPatty", Cooked = true, Quantity = 1 },
		},
		Difficulty = difficultyEnum.MEDIUM,
	},
}

return Recipes
