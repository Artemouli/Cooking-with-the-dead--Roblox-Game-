local PlayerServ = game:GetService("Players")

local OffsetVector = Vector3.new(0, 0, -8)

PlayerServ.PlayerAdded:Connect(function(player)
	player.CharacterAppearanceLoaded:Connect(function(model)
		local HRP = model:FindFirstChild("HumanoidRootPart")

		if HRP then
			local att = Instance.new("Attachment")
			att.Parent = HRP
			att.Name = "LookAtt"

			att.CFrame = CFrame.new(OffsetVector)
		end
	end)
end)
