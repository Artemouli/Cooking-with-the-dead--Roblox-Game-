-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService") -- New: Needed for getting tags

-- Remote Events
local plateEvents = ReplicatedStorage:FindFirstChild("ItemDrag"):FindFirstChild("PlateEvents")
local placedOnPlateEvent = plateEvents:FindFirstChild("PlacedOnPlateEvent")
local removedOffPlateEvent = plateEvents:FindFirstChild("RemovedOffPlateEvent")
local resetPlateEvent = plateEvents:FindFirstChild("ResetFoodEvent")

-- Active weld connections
local activeConnections = {}

-- Weld the pickupable object to the collided container (plate or pallet)
local function WeldParts(collidedContainer, pickupable)
	local otherPart = pickupable:FindFirstChildWhichIsA("BasePart")
	local weld = Instance.new("WeldConstraint")
	weld.Parent = collidedContainer -- Weld to the base part of the container
	warn("here")
	warn(collidedContainer.Name)
	weld.Part0 = collidedContainer
	weld.Part1 = otherPart

	-- Attach item to the container's "Ingredients" or "Items" folder
	local itemsFolder = collidedContainer.Parent:FindFirstChild("Ingredients") -- For Plates
	if not itemsFolder then
		itemsFolder = collidedContainer.Parent:FindFirstChild("Items") -- For Pallets or a more generic name
		if not itemsFolder then
			warn("Could not find Ingredients or Items folder for", collidedContainer.Parent.Name)
			return
		end
	end

	pickupable.Parent = itemsFolder
	otherPart.CollisionGroup = "TempPlateGroup" -- This collision group name might be misleading now, consider renaming
end

-- Called when an item is placed on a container
local function OnPlacedOnPlate(collidedContainerPart, pickupable, lastGrabbedPlayer)
	-- collidedContainerPart can be the base part of the Plate or Pallet
	local collidedContainerModel = collidedContainerPart.Parent

	warn(collidedContainerModel.Name)

	-- Check if the container is actually a Plate or Pallet
	if not (collidedContainerModel:HasTag("Plate") or collidedContainerModel:HasTag("Pallet")) then
		warn("OnPlacedOnPlate called with non-plate/pallet object:", collidedContainerModel.Name)
		return
	end

	if activeConnections[pickupable] then
		activeConnections[pickupable]:Disconnect()
		activeConnections[pickupable] = nil
	end

	local timer = 0
	activeConnections[pickupable] = RunService.Heartbeat:Connect(function(deltaTime)
		timer += deltaTime
		if timer >= 0.25 then
			WeldParts(collidedContainerPart, pickupable)
			activeConnections[pickupable]:Disconnect()
			activeConnections[pickupable] = nil
		end
	end)
end

-- Called when an item is removed off a container
local function OnRemovedOffPlate(collidedContainerPart, pickupable)
	if activeConnections[pickupable] then
		activeConnections[pickupable]:Disconnect()
		activeConnections[pickupable] = nil
	end
end

-- Called when a container is reset, optionally removing the items
local function OnResetPlate(containerModel, fullReset) -- Renamed 'plate' to 'containerModel'
	fullReset = fullReset or false
	print("Resetting container:", containerModel.Name)

	local removedFood = {}
	local containerBasePart = containerModel:FindFirstChildWhichIsA("BasePart")
	if not containerBasePart then
		warn("Could not find base part for container:", containerModel.Name)
		return
	end

	local itemsFolder = containerModel:FindFirstChild("Ingredients") -- For Plates
	if not itemsFolder then
		itemsFolder = containerModel:FindFirstChild("Items") -- For Pallets or a more generic name
		if not itemsFolder then
			warn("Could not find Ingredients or Items folder for", containerModel.Name)
			return
		end
	end

	-- Remove welds
	for _, child in ipairs(containerBasePart:GetChildren()) do
		if child:IsA("WeldConstraint") then
			print("Removing weld constraint")
			child:Destroy()
		end
	end

	-- Handle ingredient/item models
	for _, child in ipairs(itemsFolder:GetChildren()) do
		local basePart = child:FindFirstChildWhichIsA("BasePart")
		if basePart then
			if not fullReset then
				basePart.CollisionGroup = "NotPlatable"
				child.Parent = workspace
				table.insert(removedFood, child)
			else
				child:Destroy()
			end
		end
	end

	-- Delay before allowing collisions
	task.wait(2)
end

-- Connect Events
placedOnPlateEvent.Event:Connect(OnPlacedOnPlate)
removedOffPlateEvent.Event:Connect(OnRemovedOffPlate)
resetPlateEvent.Event:Connect(OnResetPlate)
