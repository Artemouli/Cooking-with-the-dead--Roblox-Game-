local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CustomerSpeech = require(ReplicatedStorage:WaitForChild("NpcModules"):FindFirstChild("CustomerSpeechModule"))

local events = ReplicatedStorage:WaitForChild("CustomerEvents")
local customerSpeechEvent = events:WaitForChild("CustomerSpeechEvent")
local stopEvent = events:WaitForChild("CustomerStopSpeechEvent") -- server tells NPC to stop

-- Start speaking
customerSpeechEvent.OnClientEvent:Connect(function(npcInstance, recipeName)
	CustomerSpeech.Start(npcInstance, recipeName, 10) -- repeat every 10 seconds
end)

-- Stop speaking
stopEvent.OnClientEvent:Connect(function(npcInstance)
	CustomerSpeech.Stop(npcInstance)
end)
