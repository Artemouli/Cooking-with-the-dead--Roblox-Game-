local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TouchInputService = game:GetService("TouchInputService")
local DifficultyManager = ServerScriptService.DifficultySystem.CustomerDifficultyManager

-- game running events
local workingCycleEvent = ReplicatedStorage.GameplayLoopEvents.WorkCycleEvent
local gameRunning = ServerScriptService["Non-Scripts"]["Game Functions"].GameRunning.Value

-- when the working cycle is over
-- Causes all customers to immediately leave if they havent been served yet
local allCustomersLeaveEvent = ReplicatedStorage:FindFirstChild("CustomerEvents")
	:FindFirstChild("ImmediatelyLeaveEvent")
-- how long the working cycle lasts for, in seconds (current default is 60)
local maxCycleLength = ServerScriptService["Non-Scripts"]["Game Functions"].MaxCycleLength.Value
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
