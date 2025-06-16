--// Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Remote Events
local itemDragEvents = ReplicatedStorage:FindFirstChild("ItemDrag")
local placedOnPrepEvent = itemDragEvents:FindFirstChild("PlacedOnPrepEvent")
local removedOffPrepEvent = itemDragEvents:FindFirstChild("RemovedOffPrepEvent")

--// Cooking Configuration
local cookTimes = {
	TestIngredient = 3
}

--// Active Cooking Connections
local activeConnections = {}

--// Handle Item Placed on Grill
local function onPlacedOnPrep(pickupable, collisionGroup)
	if collisionGroup ~= "Grill" then return end

	local foodPreps = pickupable:FindFirstChild("Food Preps")
	if not foodPreps then
		warn("This object does not have a Food Preps folder and cannot be cooked.")
		-- TODO: Add feedback effect (e.g. particle) to indicate it's not cookable
		return
	end

	local cookedAmount = foodPreps:FindFirstChild("Cooked amount")
	if not cookedAmount then return end

	-- Disconnect previous connection if it exists
	if activeConnections[pickupable] then
		activeConnections[pickupable]:Disconnect()
		activeConnections[pickupable] = nil
	end

	-- Begin Cooking if cook time exists for this item
	local cookTime = cookTimes[pickupable.Name]
	if not cookTime then
		warn("No cooking time for this item: " .. pickupable.Name)
		return
	end

	activeConnections[pickupable] = RunService.Heartbeat:Connect(function(deltaTime)
		cookedAmount.Value += deltaTime

		-- TODO: Add cooking/overcooked particle effects
		if cookedAmount.Value >= cookTime + 2 then
			print("Overcooked")
			foodPreps:FindFirstChild("FoodRuined").Value = true
		elseif cookedAmount.Value >= cookTime then
			print("Fully cooked")
			foodPreps:FindFirstChild("FullCooked").Value = true
		end
	end)
end

--// Handle Item Removed from Grill
local function onRemovedOffPrep(pickupable, collisionGroup)
	if activeConnections[pickupable] then
		activeConnections[pickupable]:Disconnect()
		activeConnections[pickupable] = nil
	end

	local foodPreps = pickupable:FindFirstChild("Food Preps")
	if not foodPreps then return end

	local cookedAmount = foodPreps:FindFirstChild("Cooked amount")
	if cookedAmount then
		cookedAmount.Value = 0
	end
end

--// Connect Events
placedOnPrepEvent.Event:Connect(onPlacedOnPrep)
removedOffPrepEvent.Event:Connect(onRemovedOffPrep)
