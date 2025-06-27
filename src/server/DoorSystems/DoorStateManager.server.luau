local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

-- Class to represent a door
local Door = {}
Door.__index = Door

function Door:new(doorInstance)
	local instance = setmetatable({}, Door)
	instance.doorInstance = doorInstance
	instance.lockedState = doorInstance:FindFirstChild("DoorLocked")
	instance.pathfindingModifier =
		doorInstance:FindFirstChild("PathfindingModifierPart"):FindFirstChild("PathfindingModifier")
	instance.lockButton = doorInstance:FindFirstChild("LockButton")
	instance.proximityPrompt = instance.lockButton:FindFirstChild("Attachment"):FindFirstChild("LockInteraction")

	-- Events
	instance.powerStateEvent = ReplicatedStorage.PowerRelatedEvents.PowerStateChange
	instance.doorInteractionEvent = ReplicatedStorage.PowerRelatedEvents.DoorInteraction

	-- Tween info
	instance.tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- Cache all "Door Model" children and their "Door" parts' original CFrames
	instance.doorParts = {} -- Array of {doorPart = MeshPart, originalCFrame = CFrame}
	for i, child in doorInstance:GetChildren() do
		if child.Name == "Door Model" and child:IsA("Model") then
			local doorPart = child:FindFirstChild("Door")
			if doorPart and doorPart:IsA("BasePart") then
				table.insert(instance.doorParts, { doorPart = doorPart, originalCFrame = doorPart.CFrame })
			end
		end
	end

	-- Connect proximity prompt triggered event with correct self binding
	instance.proximityPrompt.Triggered:Connect(function(player)
		instance:onProximityPromptTriggered(player)
	end)

	-- Connect power state event with correct self binding
	instance.powerStateEvent.Event:Connect(function(state)
		instance:onPowerStateChange(state)
	end)

	return instance
end

function Door:onProximityPromptTriggered(player)
	-- Change the LockedState for the door itself, not per player
	print("TRIGGERED for", self.doorInstance.Name)
	print("  lockedState:", self.lockedState and self.lockedState.Value)
	print("  pathfindingModifier:", self.pathfindingModifier)

	if self.lockedState.Value == true then
		self:unlockDoor()
	elseif self.lockedState.Value == false then
		self:lockDoor()
	end
	print("  AFTER: lockedState =", self.lockedState.Value)
end

function Door:unlockDoor()
	self.lockedState.Value = false
	self.pathfindingModifier.PassThrough = true
	self.doorInteractionEvent:Fire(false)
	-- changes the text of the proximity prompt
	self.proximityPrompt.ActionText = "lock"
	-- Unanchor all door parts to allow movement
	for i, doorInfo in self.doorParts do
		doorInfo.doorPart.Anchored = false
	end
end

function Door:lockDoor()
	self.lockedState.Value = true
	self.pathfindingModifier.PassThrough = false
	-- changes the text of the proximity prompt
	self.proximityPrompt.ActionText = "unlock"
	-- Reset door parts to their original CFrame and anchor them
	for i, doorInfo in self.doorParts do
		-- tweens the current position back to the original so it looks nice
		local tween = tweenService:Create(doorInfo.doorPart, self.tweenInfo, { CFrame = doorInfo.originalCFrame })
		tween:Play()
		doorInfo.doorPart.Anchored = true
	end
end

function Door:onPowerStateChange(state)
	if state == "PowerOff" then
		self:unlockDoor()
	end
end

-- Loop through all tagged doors
for _, doorInstance in pairs(CollectionService:GetTagged("InteractableDoor")) do
	local door = Door:new(doorInstance)
	-- You can add more logic here, like storing doors in a table for easier access
end
