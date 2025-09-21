local TextChatService = game:GetService("TextChatService")

local CustomerSpeech = {}
local activeSpeakers = {} -- [npcInstance] = true/false

function CustomerSpeech.Start(npcInstance, text, interval)
	interval = interval or 3
	activeSpeakers[npcInstance] = true

	local hrp = npcInstance:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	task.spawn(function()
		while activeSpeakers[npcInstance] and npcInstance.Parent do
			TextChatService:DisplayBubble(hrp, text)
			task.wait(interval)
		end
	end)
end

function CustomerSpeech.Stop(npcInstance)
	activeSpeakers[npcInstance] = nil
end

return CustomerSpeech
