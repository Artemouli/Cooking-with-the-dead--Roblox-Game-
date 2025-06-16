local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- Resets connected food items and welds
-- connects to PlatingSystem script
local resetFoodEvent = ReplicatedStorage:FindFirstChild("ItemDrag"):FindFirstChild("PlateEvents"):FindFirstChild("ResetFoodEvent")


local function setupPlateStorage(plate) 
	local deattachPrompt = plate:FindFirstChild("Plate model"):FindFirstChild("Attachment"):FindFirstChild("Deattach items")
	
	local function ClearPlate()
		resetFoodEvent:Fire(plate)
	end
	
	deattachPrompt.Triggered:Connect(ClearPlate)
end

CollectionService:GetInstanceAddedSignal("Plate"):Connect(function(instance)
	setupPlateStorage(instance)
end)

for _, plate in pairs(CollectionService:GetTagged("Plate")) do
	setupPlateStorage(plate)
end

