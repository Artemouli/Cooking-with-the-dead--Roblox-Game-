local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Event that adds Money
local addMoney = game.ReplicatedStorage.MoneyRelatedEvents.AddMoney
-- Event that decreases money
local decreaseMoney = game.ReplicatedStorage.MoneyRelatedEvents.DecreaseMoney

local groupMoneyAmount = ServerScriptService:WaitForChild("Game Functions"):FindFirstChild("PlayerGroupTotalMoney")

addMoney.Event:Connect(function(amount)
	groupMoneyAmount.Value = groupMoneyAmount.Value + amount
	print("the current added amount of money " .. groupMoneyAmount.Value)
end)

decreaseMoney.Event:Connect(function(amount)
	groupMoneyAmount.Value = groupMoneyAmount.Value - amount
	print("the current decreased amount of money " .. groupMoneyAmount.Value)
end)
