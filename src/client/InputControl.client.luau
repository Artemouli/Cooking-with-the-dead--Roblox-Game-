local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local FREEZE_ACTION = "freezeMovement"
local player = Players.LocalPlayer
local BuyMenuGui = player:WaitForChild("PlayerGui"):WaitForChild("BuyMenu"):WaitForChild("BuyMenuGUI")
local displayBuyMenuEvent = ReplicatedStorage:WaitForChild("UserHUD").DisplayBuyMenuEvent

-- if the buy menu should be displayed or not
displayBuyMenuEvent.OnClientEvent:Connect(function(display)
	BuyMenuGui.Enabled = display
	if display then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true

		-- to freeze player input
		ContextActionService:BindAction(FREEZE_ACTION, function()
			return Enum.ContextActionResult.Sink
		end, false, unpack(Enum.PlayerActions:GetEnumItems()))
	else
		UserInputService.MouseIconEnabled = false
		-- to unfreeze
		ContextActionService:UnbindAction(FREEZE_ACTION)
	end
end)
