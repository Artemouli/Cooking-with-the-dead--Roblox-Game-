local Recipes = {
	["CookedLettuce"] = {
		Money = 50,
		Ingredients = {
			{ Name = "Lettuce", Cooked = false, Quantity = 1 },
		},
	},
	["TestIngredientx1"] = {
		Money = 100,
		Ingredients = {
			{ Name = "TestIngredient", Cooked = false, Quantity = 1 },
		},
	},
	["x2TestIngredient"] = {
		Money = 100,
		Ingredients = {
			{ Name = "TestIngredient", Cooked = false, Quantity = 2 },
		},
	},
	["UltBurger"] = {
		Money = 10000000,
		Ingredients = {
			{ Name = "Bun", Cooked = false, Quantity = 2 },
			{ Name = "Lettuce", Cooked = false, Quantity = 1 },
			{ Name = "Cheese", Cooked = false, Quantity = 1 },
			{ Name = "MeatPatty", Cooked = true, Quantity = 1 },
		},
	},
}

return Recipes
