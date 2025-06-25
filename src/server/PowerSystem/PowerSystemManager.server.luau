local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

-- retrieves list of doors that can be locked
local interactableDoors = CollectionService:GetTagged("InteractableDoor")
-- Event that fires when the powerAmount reaches 0
local powerStateEvent = game.ReplicatedStorage.PowerRelatedEvents.PowerStateChange
-- Event that fires when a door is locked/unlocked, increasing/decreasing power drain amount
local doorInteraction = game.ReplicatedStorage.PowerRelatedEvents.DoorInteraction

-- Event that adds power 
local addPower = game.ReplicatedStorage.PowerRelatedEvents.AddPower

local powerAmount = 100
local powerDecreaseAmount = 1
local powerIncreaseAmount = 20

RunService.Heartbeat:Connect(function(deltaTime)
	if powerAmount > 0 then
		powerAmount -= powerDecreaseAmount * deltaTime
	else
		powerStateEvent:Fire(true)
	end
	--print(string.format("%.2f", powerAmount))
	
end)

-- When a door is locked, the amount of power that is decreased in a second is increased
doorInteraction.Event:Connect(function(doorLocked)
	if doorLocked == true then
		powerDecreaseAmount = powerDecreaseAmount + 1 
	else 
		powerDecreaseAmount = powerDecreaseAmount - 1 
	end
end)

-- when power is added 
addPower.Event:Connect(function()
	print( powerAmount)
	powerAmount += powerIncreaseAmount
	print(powerAmount)
end)