local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Your authoritative value

local groupMoneyAmount = ServerScriptService:WaitForChild("Non-Scripts")
	:WaitForChild("Game Functions")
	:FindFirstChild("PlayerGroupTotalMoney")

-- When a player joins
Players.PlayerAdded:Connect(function(player)
	local leaderstats = player:WaitForChild("leaderstats", 5)
	-- Create replicated Money value
	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = groupMoneyAmount.Value -- sync initial value
	money.Parent = leaderstats

	-- Update this player's Money whenever the server value changes
	groupMoneyAmount:GetPropertyChangedSignal("Value"):Connect(function()
		money.Value = groupMoneyAmount.Value
	end)
end)
