local ServerScriptService = game:GetService("ServerScriptService")
-- Manages specific difficulty settings
local difficultyEnum = require(ServerScriptService.DifficultySystem.DifficultyEnum)
local difficulty = {}

-- CUSTOMER difficulty variables
-- the initial amount of customers that can be at the store
difficulty.customerInitialMaxAliveAmount = {
	easy = 4,
	medium = 6,
	hard = 10,
	impossible = 14,
}
-- the max amount of customers that can be at the store
difficulty.customerMaxAliveAmount = 3
-- how harsh the consequences for the player giving the customer the wrong meal are
difficulty.customerRatingDifficulty = {
	easyDiminisher = 4,
	medDiminisher = 5,
	hardDiminisher = 6,
	impDiminisher = 7,
}
-- what kinds of recipes the customers can ask for
difficulty.customerRecipeRequest = {
	[difficultyEnum.EASY] = true,
	[difficultyEnum.MEDIUM] = false,
	[difficultyEnum.HARD] = false,
	[difficultyEnum.IMPOSSIBLE] = false,
}

-- increases the available recipe difficulty by 1
function difficulty.CustomerIncreaseRecipeDifficulty()
	-- if impossible recipes are already available, then make it so that they are the only recipes that are available
	if difficulty.customerRecipeRequest.impRecipes then
		-- loops through the recipes
		for recipeKey, value in difficulty.customerRecipeRequest do
			-- if the recipeKey is not impossible, set to false
			if recipeKey ~= difficultyEnum.IMPOSSIBLE then
				difficulty.customerRecipeRequest[recipeKey] = false
			end
		end
	elseif difficulty.customerRecipeRequest.hardRecipes then
		difficulty.customerRecipeRequest.impRecipes = true
		difficulty.customerRecipeRequest.medRecipes = false
		--
	elseif difficulty.customerRecipeRequest.medRecipes then
		difficulty.customerRecipeRequest.hardRecipes = true
		difficulty.customerRecipeRequest.easyRecipes = false
		--
	else
		difficulty.customerRecipeRequest.medRecipes = true
	end
end

-- access the available recipe

-- MONSTER AI difficulty

return difficulty
