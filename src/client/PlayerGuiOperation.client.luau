local player = game.Players.LocalPlayer
local MoneyGui = player:WaitForChild("PlayerGui"):WaitForChild("PlayerUI"):WaitForChild("MoneyGui")
local leaderstats = player:WaitForChild("leaderstats", 10)

-- Function to update the label
local function updateMoney()
	local money = leaderstats:FindFirstChild("Money")
	if money then
		MoneyGui.MoneyLabel.Text = "$" .. money.Value
	end
end

-- Update whenever money changes
local moneyStat = leaderstats:WaitForChild("Money")
moneyStat:GetPropertyChangedSignal("Value"):Connect(updateMoney)

-- Initial update
updateMoney()
