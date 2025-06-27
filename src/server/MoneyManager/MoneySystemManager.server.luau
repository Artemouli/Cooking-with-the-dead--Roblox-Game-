local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

-- Event that adds Money
local addMoney = game.ReplicatedStorage.MoneyRelatedEvents.AddMoney
-- Event that decreases money
local decreaseMoney = game.ReplicatedStorage.MoneyRelatedEvents.DecreaseMoney

local moneyAmount = 0

addMoney.Event:Connect(function(amount)
	moneyAmount = moneyAmount + amount
	print("the current added amount of money " .. moneyAmount)
end)

decreaseMoney.Event:Connect(function(amount)
	moneyAmount = moneyAmount - amount
	print("the current decreased amount of money " .. moneyAmount)
end)
