local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Your authoritative value

local curCycleLength =
	ServerScriptService:WaitForChild("Non-Scripts"):WaitForChild("Game Functions"):FindFirstChild("CurCycleLength")

local gameRunningServer =
	ServerScriptService:WaitForChild("Non-Scripts"):WaitForChild("Game Functions"):FindFirstChild("GameRunning")

-- When a player joins
Players.PlayerAdded:Connect(function(player)
	local leaderstats = player:WaitForChild("leaderstats", 5)
	-- Create replicated Timer value
	local timer = Instance.new("IntValue")
	timer.Name = "Timer"
	timer.Value = curCycleLength.Value -- sync initial value
	timer.Parent = leaderstats

	-- Create replicated GameRunning value
	local gameRunning = Instance.new("BoolValue")
	gameRunning.Name = "GameRunning"
	gameRunning.Value = gameRunningServer.Value -- sync initial value
	gameRunning.Parent = leaderstats

	-- Update this player's Timer whenever the server value changes
	curCycleLength:GetPropertyChangedSignal("Value"):Connect(function()
		timer.Value = curCycleLength.Value
	end)

	-- Update this player's Money whenever the server value changes
	gameRunningServer:GetPropertyChangedSignal("Value"):Connect(function()
		gameRunning.Value = gameRunningServer.Value
	end)
end)
