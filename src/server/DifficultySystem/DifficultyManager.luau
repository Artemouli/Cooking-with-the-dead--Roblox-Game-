-- Manages specific difficulty settings

local difficulty = {}

-- CUSTOMER difficulty variables
-- the initial amount of customers that can be at the store
local customerInitialMaxAliveAmount = {
	easy = 4,
	medium = 6,
	hard = 10,
	impossible = 14,
}
-- the max amount of customers that can be at the store
local customerMaxAliveAmount = 3
-- how harsh the consequences for the player giving the customer the wrong meal are
local customerRatingDifficulty = {
	easyDiminisher = 4,
	medDiminisher = 5,
	hardDiminisher = 6,
	impDiminisher = 7,
}
-- what kinds of recipes the customers can ask for
local customerRecipeRequest = {
	easyRecipes = true,
	medRecipes = true,
	hardRecipes = false,
	impRecipes = false,
}

-- MONSTER AI difficulty

return difficulty
