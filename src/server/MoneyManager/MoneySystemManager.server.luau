local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Event that adds Money
local addMoney = game.ReplicatedStorage.MoneyRelatedEvents.AddMoney
-- Event that decreases money
local decreaseMoney = game.ReplicatedStorage.MoneyRelatedEvents.DecreaseMoney

local groupMoneyAmount = ServerScriptService:WaitForChild("Non-Scripts")
	:WaitForChild("Game Functions")
	:FindFirstChild("PlayerGroupTotalMoney")

addMoney.Event:Connect(function(amount)
	groupMoneyAmount.Value = groupMoneyAmount.Value + amount
	print("the current added amount of money " .. groupMoneyAmount.Value)
end)

-- returns a true or false value depending on if the item can be bought
decreaseMoney.Event:Connect(function(amount)
	if (groupMoneyAmount.Value - amount) < 0 then
		warn("I cant afford this !!!")
		return false
	end
	groupMoneyAmount.Value = groupMoneyAmount.Value - amount
	print("the current decreased amount of money " .. groupMoneyAmount.Value)
	return true
end)
