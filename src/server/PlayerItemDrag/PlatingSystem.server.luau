-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Remote Events
local plateEvents = ReplicatedStorage:FindFirstChild("ItemDrag"):FindFirstChild("PlateEvents")
local placedOnPlateEvent = plateEvents:FindFirstChild("PlacedOnPlateEvent")
local removedOffPlateEvent = plateEvents:FindFirstChild("RemovedOffPlateEvent")
local resetPlateEvent = plateEvents:FindFirstChild("ResetFoodEvent")

-- Active weld connections
local activeConnections = {}

-- Weld the pickupable object to the collided plate
local function WeldParts(collidedPlate, pickupable)
	local otherPart = pickupable:FindFirstChildWhichIsA("BasePart")
	local weld = Instance.new("WeldConstraint")
	weld.Parent = collidedPlate
	weld.Part0 = collidedPlate
	weld.Part1 = otherPart

	-- Attach item to plate hierarchy
	pickupable.Parent = collidedPlate.Parent:FindFirstChild("Ingredients")
	otherPart.CollisionGroup = "TempPlateGroup"
end

-- Called when an item is placed on a plate
local function OnPlacedOnPlate(collidedPlate, pickupable, lastGrabbedPlayer)
	if activeConnections[pickupable] then
		activeConnections[pickupable]:Disconnect()
		activeConnections[pickupable] = nil
	end

	local timer = 0
	activeConnections[pickupable] = RunService.Heartbeat:Connect(function(deltaTime)
		timer += deltaTime
		if timer >= 0.25 then
			WeldParts(collidedPlate, pickupable)
			activeConnections[pickupable]:Disconnect()
			activeConnections[pickupable] = nil
		end
	end)
end

-- Called when an item is removed off a plate
local function OnRemovedOffPlate(collidedPlate, pickupable)
	if activeConnections[pickupable] then
		activeConnections[pickupable]:Disconnect()
		activeConnections[pickupable] = nil
	end
end

-- Called when a plate is reset, optionally removing the food
local function OnResetPlate(plate, fullReset)
	fullReset = fullReset or false
	print(plate.Name)

	local removedFood = {}
	local plateObject = plate:FindFirstChildWhichIsA("BasePart")
	local ingredientsFolder = plate:FindFirstChild("Ingredients")

	-- Remove welds
	for _, child in ipairs(plateObject:GetChildren()) do
		if child:IsA("WeldConstraint") then
			print("Removing weld constraint")
			child:Destroy()
		end
	end

	-- Handle ingredient models
	for _, child in ipairs(ingredientsFolder:GetChildren()) do
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
