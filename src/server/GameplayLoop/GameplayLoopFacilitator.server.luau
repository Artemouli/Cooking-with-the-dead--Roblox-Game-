local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TouchInputService = game:GetService("TouchInputService")
-- game running events
local workingCycleEvent = ReplicatedStorage.GameplayLoopEvents.WorkCycleStart
local closeCycleEvent = ReplicatedStorage.GameplayLoopEvents.CloseCycleStart

local gameRunning = ServerScriptService["Game Functions"].GameRunning.Value

-- starts the working/closed cycle and keeps track of it

-- retrieves if working cycle has started or not (true for has started, false for hasnt)
workingCycleEvent.Event:Connect(function(status)
	if status and gameRunning == false then
		print("we working now")
		gameRunning = true
		-- gameloop that keeps track of how long the working cycle is going on for
		task.spawn(function()
			while gameRunning do
				print("we are running")
				task.wait()
			end
		end)
	-- the working cycle is being forced to run now
	elseif status == false and gameRunning then
		gameRunning = false
	end
end)
