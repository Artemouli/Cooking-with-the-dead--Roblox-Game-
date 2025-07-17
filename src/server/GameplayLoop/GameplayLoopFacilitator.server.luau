local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TouchInputService = game:GetService("TouchInputService")
-- game running events
local workingCycleEvent = ReplicatedStorage.GameplayLoopEvents.WorkCycleStart
local gameRunning = ServerScriptService["Game Functions"].GameRunning.Value

-- starts the working/closed cycle and keeps track of it
task.spawn(function()
	while true do
		if gameRunning then
			print("Gameplay loop is running")
		end
		task.wait(1)
	end
end)

-- start or end the gameplayLoop
workingCycleEvent.Event:Connect(function(status)
	if status then
		print("we working now")
		gameRunning = true
	-- stop the working cycle
	else
		gameRunning = false
	end
end)
