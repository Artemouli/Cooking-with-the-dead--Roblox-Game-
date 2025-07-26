local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Resets connected food items and welds
-- connects to PlatingSystem script
local resetFoodEvent =
	ReplicatedStorage:FindFirstChild("ItemDrag"):FindFirstChild("PlateEvents"):FindFirstChild("ResetFoodEvent")

-- Function to set up storage for any item group that can hold other items
local function setupItemGroupStorage(itemGroupInstance)
	local deattachPrompt = itemGroupInstance
		:FindFirstChild(itemGroupInstance.PrimaryPart.Name)
		:FindFirstChild("Attachment")
		:FindFirstChild("Deattach items")

	if not deattachPrompt then
		warn("Deattach items prompt not found for", itemGroupInstance.Name)
		return
	end

	local function ClearItems()
		-- The resetFoodEvent currently targets "plate". You might need to make this more generic
		-- or create a separate event for pallets if their reset logic differs significantly.
		-- For now, assuming resetFoodEvent can handle both if PlatingSystem is updated.
		resetFoodEvent:Fire(itemGroupInstance)
	end

	deattachPrompt.Triggered:Connect(ClearItems)
end

-- Connect to "Plate" tagged instances
CollectionService:GetInstanceAddedSignal("Plate"):Connect(function(instance)
	setupItemGroupStorage(instance)
end)

for _, plate in pairs(CollectionService:GetTagged("Plate")) do
	setupItemGroupStorage(plate)
end

-- Connect to "Pallet" tagged instances
CollectionService:GetInstanceAddedSignal("Pallet"):Connect(function(instance)
	setupItemGroupStorage(instance)
end)

for _, pallet in pairs(CollectionService:GetTagged("Pallet")) do
	setupItemGroupStorage(pallet)
end
