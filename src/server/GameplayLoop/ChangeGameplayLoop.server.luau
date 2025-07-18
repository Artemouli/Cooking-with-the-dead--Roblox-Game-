local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TouchInputService = game:GetService("TouchInputService")

-- game running events
local workingCycleEvent = ReplicatedStorage.GameplayLoopEvents.WorkCycleStart
local gameplayLoopTag = "GameplayFacilitator"

for _, object in pairs(CollectionService:GetTagged(gameplayLoopTag)) do
	object:FindFirstChild("Attachment"):FindFirstChild("ProximityPrompt").Triggered:Connect(function(player)
		local status = false
		if object.Name == "End Game" then
			print("we ending")
			status = false
		else
			print("we starting")
			status = true
		end
		workingCycleEvent:fire(status)
	end)
end
