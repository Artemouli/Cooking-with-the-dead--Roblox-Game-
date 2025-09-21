local player = game.Players.LocalPlayer
local PlayerConstantGui = player:WaitForChild("PlayerGui"):WaitForChild("PlayerUI"):WaitForChild("PlayerConstantGui")
local leaderstats = player:WaitForChild("leaderstats", 10)

-- Function to update the label
local function updateMoney()
	local money = leaderstats:FindFirstChild("Money")
	if money then
		PlayerConstantGui.MoneyLabel.Text = "$" .. money.Value
	end
end

local function updateTimer()
	local timer = leaderstats:FindFirstChild("Timer")
	if timer then
		PlayerConstantGui.TimerLabel.Text = timer.Value
	end
end

local function updateTimerWithGameRunning()
	local gameRunning = leaderstats:FindFirstChild("GameRunning")
	if gameRunning then
		PlayerConstantGui.TimerLabel.Text = "CLOSED!!!"
	end
end

-- Update whenever money changes
local moneyStat = leaderstats:WaitForChild("Money")
moneyStat:GetPropertyChangedSignal("Value"):Connect(updateMoney)

-- Update whenever timer changes
local timerStat = leaderstats:WaitForChild("Timer")
timerStat:GetPropertyChangedSignal("Value"):Connect(updateTimer)

-- Update Timer when break time :)
local gameRunningStat = leaderstats:WaitForChild("GameRunning")
gameRunningStat:GetPropertyChangedSignal("Value"):Connect(updateTimerWithGameRunning)

-- Initial update
updateMoney()
updateTimer()
-- this always must run after updateTimer()
updateTimerWithGameRunning()
