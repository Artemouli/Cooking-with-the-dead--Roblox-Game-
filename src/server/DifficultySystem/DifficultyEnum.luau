-- the terms used for difficulty
local DifficultyEnum = {
	EASY = "EASY",
	MEDIUM = "MEDIUM",
	HARD = "HARD",
	IMPOSSIBLE = "IMPOSSIBLE",
}

DifficultyEnum.Order = {
	DifficultyEnum.EASY,
	DifficultyEnum.MEDIUM,
	DifficultyEnum.HARD,
	DifficultyEnum.IMPOSSIBLE,
}

-- what is the current difficulty
DifficultyEnum.CurrentDiff = {
	[DifficultyEnum.EASY] = true,
	[DifficultyEnum.MEDIUM] = false,
	[DifficultyEnum.HARD] = false,
	[DifficultyEnum.IMPOSSIBLE] = false,
}

function DifficultyEnum.GetCurrentDifficulty()
	for _, diff in ipairs(DifficultyEnum.Order) do
		if DifficultyEnum.CurrentDiff[diff] then
			return diff
		end
	end
	return nil
end

-- takes in a difficulty enum and sets that value specifically
function DifficultyEnum.SetExactDifficulty(setDifficulty)
	-- sets the current difficulty to false
	local current = DifficultyEnum.GetCurrentDifficulty()
	DifficultyEnum.CurrentDiff[current] = false

	DifficultyEnum.CurrentDiff[setDifficulty] = true
end

-- sets the next difficulty to true
function DifficultyEnum.GetNextDifficulty()
	-- dont increase difficulty if already max
	if DifficultyEnum.CurrentDiff[DifficultyEnum.IMPOSSIBLE] == false then
		local current = DifficultyEnum.GetCurrentDifficulty()
		for i, diff in ipairs(DifficultyEnum.Order) do
			if diff == current then
				DifficultyEnum.SetExactDifficulty(DifficultyEnum.Order[i + 1])
			end
		end
	end
end

return DifficultyEnum
