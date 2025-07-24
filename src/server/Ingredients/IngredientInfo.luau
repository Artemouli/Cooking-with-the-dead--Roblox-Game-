local Ingredients = {
	TestIngredient = "TestIngredient",
	Lettuce = "Lettuce",
	Bun = "Bun",
	Cheese = "Cheese",
	MeatPatty = "MeatPatty",
}
-- is in seconds
Ingredients.CookTime = {
	[Ingredients.TestIngredient] = 5,
	[Ingredients.Lettuce] = 5,
	[Ingredients.TestIngredient] = 5,
	[Ingredients.TestIngredient] = 5,
	[Ingredients.TestIngredient] = 5,
}

return Ingredients
