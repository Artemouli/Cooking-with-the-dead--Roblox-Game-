-- Services
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Events
local itemDrag = ReplicatedStorage:FindFirstChild("ItemDrag")
local placedOnPrepEvent = itemDrag:FindFirstChild("PlacedOnPrepEvent")
local removedOffPrepEvent = itemDrag:FindFirstChild("RemovedOffPrepEvent")
local plateEvents = itemDrag:FindFirstChild("PlateEvents")
local placedOnPlateEvent = plateEvents:FindFirstChild("PlacedOnPlateEvent")
local removedOffPlateEvent = plateEvents:FindFirstChild("RemovedOffPlateEvent")
-- local giveItemEvent = ReplicatedStorage:WaitForChild("CustomerEvents"):FindFirstChild("GiveCustomerItemEvent")

-- Collision Group Setup
local collisionGroups = { "CurrentPlayerGroup", "DraggableGroup", "PlateGroup", "TempPlateGroup" }
for _, group in ipairs(collisionGroups) do
	pcall(function()
		PhysicsService:RegisterCollisionGroup(group)
	end)
end

PhysicsService:CollisionGroupSetCollidable("CurrentPlayerGroup", "DraggableGroup", false)
PhysicsService:CollisionGroupSetCollidable("CurrentPlayerGroup", "PlateGroup", false)
PhysicsService:CollisionGroupSetCollidable("CurrentPlayerGroup", "TempPlateGroup", false)

-- Utility Functions
local function getLookAttachment(player)
	local char = player.Character
	if not char then
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	return hrp:FindFirstChild("LookAtt")
end

local function setPlayerCollisionGroup(player)
	local char = player.Character
	if not char then
		return
	end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "CurrentPlayerGroup"
		end
	end
end

local function resetPlayerCollisionGroup(player)
	local char = player.Character
	if not char then
		return
	end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Default"
		end
	end
end

-- Touch Event Handlers
local function onTouched(pickupable, grabbablePart, lastGrabbedPlayer)
	return function(otherPart)
		if
			otherPart.Parent:HasTag("Customer")
			and (grabbablePart.CollisionGroup == "PlateGroup" or grabbablePart.CollisionGroup == "TempPlateGroup")
		then
			if grabbablePart.CollisionGroup == "PlateGroup" then
			-- giveItemEvent:Fire(grabbablePart.Parent)
			else
				-- giveItemEvent:Fire(grabbablePart.Parent.Parent.Parent)
			end
		end

		if otherPart.CollisionGroup == "Default" then
			return
		end

		if
			(otherPart.CollisionGroup == "PlateGroup" or otherPart.CollisionGroup == "TempPlateGroup")
			and grabbablePart.CollisionGroup == "DraggableGroup"
		then
			if otherPart.CollisionGroup == "PlateGroup" then
				placedOnPlateEvent:Fire(otherPart, pickupable, lastGrabbedPlayer)
			else
				placedOnPlateEvent:Fire(
					otherPart.Parent.Parent.Parent:FindFirstChild("Plate model"),
					pickupable,
					lastGrabbedPlayer
				)
			end
		end

		if otherPart.CollisionGroup == "Grill" then
			placedOnPrepEvent:Fire(pickupable, otherPart.CollisionGroup)
		end
	end
end

local function onTouchEnded(pickupable, grabbablePart)
	return function(otherPart)
		if otherPart.CollisionGroup == "Default" then
			return
		end
		if
			(otherPart.CollisionGroup == "PlateGroup" or otherPart.CollisionGroup == "TempPlateGroup")
			and grabbablePart.CollisionGroup == "DraggableGroup"
		then
			removedOffPlateEvent:Fire(otherPart, pickupable)
		end
		if otherPart.CollisionGroup == "Grill" then
			removedOffPrepEvent:Fire(pickupable, otherPart.CollisionGroup)
		end
	end
end

-- Setup Function
local function setupPickupable(pickupable)
	local dragDetector = pickupable:FindFirstChildOfClass("DragDetector")
	local grabbablePart = pickupable:FindFirstChildWhichIsA("BasePart")
	if not dragDetector or not grabbablePart then
		return warn("Missing DragDetector or BasePart for", pickupable.Name)
	end

	local lastGrabbedPlayer = nil
	local currentlyHolding = false

	grabbablePart.CollisionGroup = pickupable:HasTag("Plate") and "PlateGroup" or "DraggableGroup"

	local posAtt = Instance.new("Attachment", grabbablePart)
	local alignPos = Instance.new("AlignPosition", pickupable)
	alignPos.Attachment0 = posAtt
	alignPos.Enabled = false
	alignPos.Responsiveness = 70
	alignPos.MaxVelocity = 50
	alignPos.MaxForce = 50000

	grabbablePart.Touched:Connect(onTouched(pickupable, grabbablePart, lastGrabbedPlayer))
	grabbablePart.TouchEnded:Connect(onTouchEnded(pickupable, grabbablePart))

	dragDetector.DragStart:Connect(function(player)
		if grabbablePart.CollisionGroup == "NotPlatable" then
			grabbablePart.CollisionGroup = "DraggableGroup"
		end

		local att = getLookAttachment(player)
		if att and not grabbablePart.Parent:HasTag("NotInteractable") then
			currentlyHolding = true
			lastGrabbedPlayer = player
			setPlayerCollisionGroup(player)
			grabbablePart:SetNetworkOwner(player)
			alignPos.Attachment1 = att
			alignPos.Enabled = true
			pickupable:SetAttribute("CurrentDrag", player.UserId)
		end
	end)

	dragDetector.DragContinue:Connect(function(player, _, viewFrame)
		local att = getLookAttachment(player)
		if att then
			local y = viewFrame.LookVector.Y
			att.CFrame = CFrame.new(Vector3.new(0, (y * 5) + 1, -8))
		end
	end)

	dragDetector.DragEnd:Connect(function(player)
		currentlyHolding = false
		resetPlayerCollisionGroup(player)
		alignPos.Enabled = false
		alignPos.Attachment1 = nil
		pickupable:SetAttribute("CurrentDrag", nil)
		task.wait(2)
		if dragDetector.Enabled and not currentlyHolding and grabbablePart and grabbablePart.Parent then
			grabbablePart:SetNetworkOwnershipAuto()
		end
	end)
end

-- Setup Existing and New Tagged Instances
for _, instance in ipairs(CollectionService:GetTagged("Pickupable")) do
	setupPickupable(instance)
end

CollectionService:GetInstanceAddedSignal("Pickupable"):Connect(setupPickupable)
