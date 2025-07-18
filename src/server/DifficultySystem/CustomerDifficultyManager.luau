local ServerScriptService = game:GetService("ServerScriptService")
-- Manages specific difficulty settings
local difficultyEnum = require(ServerScriptService.DifficultySystem.DifficultyEnum)
local customerDifficulty = {}

-- CUSTOMER difficulty variables
-- the initial amount of customers that can be at the store
customerDifficulty.customerInitialMaxAliveAmount = {
	[difficultyEnum.EASY] = 4,
	[difficultyEnum.MEDIUM] = 6,
	[difficultyEnum.HARD] = 10,
	[difficultyEnum.IMPOSSIBLE] = 14,
}
-- the max amount of customers that can be at the store
customerDifficulty.customerMaxAliveAmount = 2
customerDifficulty.customerMinSpawnTime = 3
customerDifficulty.customerMaxSpawnTime = 5
-- how harsh the consequences for the player giving the customer the wrong meal are
customerDifficulty.customerRatingDifficulty = {
	[difficultyEnum.EASY] = 4,
	[difficultyEnum.MEDIUM] = 5,
	[difficultyEnum.HARD] = 6,
	[difficultyEnum.IMPOSSIBLE] = 7,
}
-- what kinds of recipes the customers can ask for
customerDifficulty.customerRecipeRequest = {
	[difficultyEnum.EASY] = true,
	[difficultyEnum.MEDIUM] = false,
	[difficultyEnum.HARD] = false,
	[difficultyEnum.IMPOSSIBLE] = false,
}

-- increases the available recipe difficulty by 1
-- customer recipes should be seperate from general difficulty
function customerDifficulty.CustomerIncreaseRecipeDifficulty()
	if customerDifficulty.customerRecipeRequest[difficultyEnum.IMPOSSIBLE] then
		for recipeKey in pairs(customerDifficulty.customerRecipeRequest) do
			customerDifficulty.customerRecipeRequest[recipeKey] = (recipeKey == difficultyEnum.IMPOSSIBLE)
		end
	elseif customerDifficulty.customerRecipeRequest[difficultyEnum.HARD] then
		customerDifficulty.customerRecipeRequest[difficultyEnum.IMPOSSIBLE] = true
		customerDifficulty.customerRecipeRequest[difficultyEnum.MEDIUM] = false
	elseif customerDifficulty.customerRecipeRequest[difficultyEnum.MEDIUM] then
		customerDifficulty.customerRecipeRequest[difficultyEnum.HARD] = true
		customerDifficulty.customerRecipeRequest[difficultyEnum.EASY] = false
	else
		customerDifficulty.customerRecipeRequest[difficultyEnum.MEDIUM] = true
	end
end
--retrieves customerRatingDifficulty
function customerDifficulty.RetrieveCustomerRatingDifficulty()
	return customerDifficulty.customerRatingDifficulty[difficultyEnum.GetCurrentDifficulty()]
end
-- retrive customer max alive amount
function customerDifficulty.RetrieveMaxCustomerAliveAmount()
	return customerDifficulty.customerMaxAliveAmount[difficultyEnum.GetCurrentDifficulty()]
end

return customerDifficulty
