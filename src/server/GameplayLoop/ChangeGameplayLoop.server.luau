local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- game running events
local workingCycleEvent = ReplicatedStorage.GameplayLoopEvents.WorkCycleEvent
local gameplayLoopTag = "GameplayFacilitator"

for _, object in pairs(CollectionService:GetTagged(gameplayLoopTag)) do
	object:FindFirstChild("Attachment"):FindFirstChild("ProximityPrompt").Triggered:Connect(function(_player)
		local status = false
		if object.Name == "End Game" then
			print("we ending")
			status = false
		else
			print("we starting")
			status = true
		end
		-- TODO: remove or change to improve solution
		object:FindFirstChild("Attachment"):FindFirstChild("ProximityPrompt").Enabled = false
		workingCycleEvent:fire(status)
	end)
end
