local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TouchInputService = game:GetService("TouchInputService")
local DifficultyManager = ServerScriptService.DifficultySystem.CustomerDifficultyManager

-- game running events
local workingCycleEvent = ReplicatedStorage.GameplayLoopEvents.WorkCycleEvent
local gameRunning = ServerScriptService["Game Functions"].GameRunning.Value

-- how long the working cycle lasts for, in seconds
local maxCycleLength = 10
-- current cycle
local curCycleLength = maxCycleLength
-- starts the working/closed cycle and keeps track of it
task.spawn(function()
	while true do
		if gameRunning then
			print("Gameplay loop is running")
			curCycleLength -= 1
			if curCycleLength <= 0 then
				workingCycleEvent:Fire(false)
			end
		end
		task.wait(1)
	end
end)

-- start or end the gameplayLoop
workingCycleEvent.Event:Connect(function(status)
	curCycleLength = maxCycleLength
	if status then
		print("we working now")
		gameRunning = true
	-- stop the working cycle
	else
		gameRunning = false
		warn("working cycle is over!!!")
	end
end)
