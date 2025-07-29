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
	[Ingredients.Bun] = 5,
	[Ingredients.Cheese] = 5,
	[Ingredients.MeatPatty] = 5,
}

Ingredients.Price = {
	[Ingredients.TestIngredient] = 10,
	[Ingredients.Lettuce] = 5,
	[Ingredients.Bun] = 5,
	[Ingredients.Cheese] = 5,
	[Ingredients.MeatPatty] = 5,
}

return Ingredients
