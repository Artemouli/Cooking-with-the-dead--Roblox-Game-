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
local giveItemEvent = ReplicatedStorage:WaitForChild("CustomerEvents"):FindFirstChild("GiveCustomerItemEvent")

-- New: Require ItemGroupConfig for dynamic configuration
local ItemGroupConfig = require(game:GetService("ServerScriptService").PlayerItemDrag.Enums.ItemGroupConfig)

-- Collision Group Setup
-- Add "PalletGroup" to the collision groups
local collisionGroups = { "CurrentPlayerGroup", "DraggableGroup", "PlateGroup", "TempPlateGroup", "PalletGroup" }
for _, group in ipairs(collisionGroups) do
	pcall(function()
		PhysicsService:RegisterCollisionGroup(group)
	end)
end

PhysicsService:CollisionGroupSetCollidable("CurrentPlayerGroup", "DraggableGroup", false)
PhysicsService:CollisionGroupSetCollidable("CurrentPlayerGroup", "PlateGroup", false)
PhysicsService:CollisionGroupSetCollidable("CurrentPlayerGroup", "TempPlateGroup", false)
PhysicsService:CollisionGroupSetCollidable("CurrentPlayerGroup", "PalletGroup", false) -- New: Pallet collision

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
		-- Check if the grabbablePart is a Plate (or TempPlate) and can be given to a customer
		-- New: Use ItemGroupConfig to determine if it can be given to NPC
		local itemConfig = nil
		if pickupable:HasTag("Plate") then
			itemConfig = ItemGroupConfig.Plate
		elseif pickupable:HasTag("Pallet") then
			itemConfig = ItemGroupConfig.Pallet
		end

		if
			otherPart.Parent:HasTag("Customer")
			and itemConfig
			and itemConfig.canBeGivenToNPC
			and (grabbablePart.CollisionGroup == "PlateGroup" or grabbablePart.CollisionGroup == "TempPlateGroup")
		then
			if grabbablePart.CollisionGroup == "PlateGroup" then
				giveItemEvent:Fire(grabbablePart.Parent, otherPart.Parent)
			else
				-- Assuming TempPlateGroup implies it's an item on a plate/pallet
				-- You might need to adjust this logic if TempPlateGroup is used differently
				giveItemEvent:Fire(grabbablePart.Parent.Parent.Parent, otherPart.Parent.Parent.Parent)
			end
		end

		if otherPart.CollisionGroup == "Default" then
			return
		end

		-- Check if a DraggableGroup item is placed on a PlateGroup or PalletGroup (or TempPlateGroup)
		if
			(
				otherPart.CollisionGroup == "PlateGroup"
				or otherPart.CollisionGroup == "TempPlateGroup"
				or otherPart.CollisionGroup == "PalletGroup"
			) -- New: Include PalletGroup
			and grabbablePart.CollisionGroup == "DraggableGroup"
		then
			if otherPart.CollisionGroup == "PlateGroup" or otherPart.CollisionGroup == "PalletGroup" then
				placedOnPlateEvent:Fire(otherPart, pickupable, lastGrabbedPlayer)
			else
				-- If it's a TempPlateGroup, it means it's likely an item already on a plate/pallet being moved
				placedOnPlateEvent:Fire(
					-- retrieves the primary part, so that it can be welded to in WeldParts()
					otherPart.Parent.Parent.Parent.PrimaryPart or otherPart.Parent.Parent.Parent.Parent.PrimaryPart, -- New: Look for Pallet model too
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
		-- Check if a DraggableGroup item is removed from a PlateGroup or PalletGroup (or TempPlateGroup)
		if
			(
				otherPart.CollisionGroup == "PlateGroup"
				or otherPart.CollisionGroup == "TempPlateGroup"
				or otherPart.CollisionGroup == "PalletGroup"
			) -- New: Include PalletGroup
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
	-- grabs original rotation of pickupable
	local initRotation, _ = pickupable:GetBoundingBox()

	local dragDetector = pickupable:FindFirstChildOfClass("DragDetector")
	local grabbablePart = pickupable:FindFirstChildWhichIsA("BasePart")
	if not dragDetector or not grabbablePart then
		return warn("Missing DragDetector or BasePart for", pickupable.Name)
	end

	local lastGrabbedPlayer = nil
	local currentlyHolding = false

	-- Determine collision group based on tag
	if pickupable:HasTag("Plate") then
		grabbablePart.CollisionGroup = "PlateGroup"
	elseif pickupable:HasTag("Pallet") then
		grabbablePart.CollisionGroup = "PalletGroup" -- New: Assign PalletGroup
	else
		grabbablePart.CollisionGroup = "DraggableGroup"
	end

	-- aligns the position of the grabbable part
	local posAtt = Instance.new("Attachment", grabbablePart)
	local alignPos = Instance.new("AlignPosition", pickupable)
	alignPos.Attachment0 = posAtt
	alignPos.Enabled = false
	alignPos.Responsiveness = 70
	alignPos.MaxVelocity = 50
	alignPos.MaxForce = 50000

	local alignOrientation = Instance.new("AlignOrientation", pickupable)
	alignOrientation.Attachment0 = posAtt
	alignOrientation.CFrame = initRotation
	alignOrientation.Mode = 0
	alignOrientation.Enabled = false

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

			-- sets rotation
			initRotation, _ = pickupable:GetBoundingBox()
			alignOrientation.CFrame = initRotation
			alignOrientation.Enabled = true
		end
	end)

	dragDetector.DragContinue:Connect(function(player, _, viewFrame)
		-- sets rotation
		local att = getLookAttachment(player)
		if att then
			local y = viewFrame.LookVector.Y
			att.CFrame = CFrame.new(Vector3.new(0, (y * 5) + 1, -8))
			--pickupable.PrimaryPart.Orientation = initRotation
		end
	end)

	dragDetector.DragEnd:Connect(function(player)
		currentlyHolding = false
		resetPlayerCollisionGroup(player)
		alignPos.Enabled = false
		alignPos.Attachment1 = nil
		alignOrientation.Enabled = false
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
