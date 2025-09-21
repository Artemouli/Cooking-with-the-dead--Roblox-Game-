local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local BuyMenuGUI = player:WaitForChild("PlayerGui"):WaitForChild("BuyMenu"):WaitForChild("BuyMenuGUI")
local _TestShopFrame = BuyMenuGUI:WaitForChild("TestShopFrame")

local PlayerGUI = player:WaitForChild("PlayerGui"):WaitForChild("PlayerUI"):WaitForChild("PlayerGUI")
-- replaces the users usual crosshair
local crosshair = PlayerGUI.crosshair
-- the grabbing icon
local grabIcon = PlayerGUI.GrabIcon

-- events
-- fires from PickupHandler.server.luau, runs when a player hovers their cursor over a draggable (true = hovering, false = cursor has stopped hovering)
local HoveringOverDraggable = ReplicatedStorage:WaitForChild("UserHUD"):FindFirstChild("HoveringOverDraggable")
-- fires from PickupHandler.server.luau, runs when a player begins dragging an object (true = dragging, false = not dragging)
local DraggingAnObject = ReplicatedStorage:WaitForChild("UserHUD"):FindFirstChild("DraggingAnObject")

-- changes the default cursor when we are displaying the buy menu
local displayBuyMenuEvent = ReplicatedStorage:WaitForChild("UserHUD").DisplayBuyMenuEvent

local _defaultCrosshairIcon = "http://www.roblox.com/asset/?id=4727466020"
--local grabbingCrosshairIcon = "http://www.roblox.com/asset/?id=5036004544"
local defaultBuyMenuIcon = "rbxassetid://7767269282"

UserInputService.MouseIconEnabled = false
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

crosshair.Visible = true

-- change cursor when displaying buy menu, if opening the menu, show the old school one, if closing, show normal gameplay one
displayBuyMenuEvent.OnClientEvent:Connect(function(display)
	if display then
		UserInputService.MouseIconEnabled = true
		mouse.Icon = defaultBuyMenuIcon
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		crosshair.Visible = false
	else
		UserInputService.MouseIconEnabled = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		crosshair.Visible = true
	end
end)

-- follows the players mouse
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		crosshair.Position = UDim2.fromOffset(input.Position.X, input.Position.Y)
		grabIcon.Position = UDim2.fromOffset(input.Position.X, input.Position.Y)
	end
end)

HoveringOverDraggable.OnClientEvent:Connect(function(hovering)
	if hovering then
		crosshair.Visible = false
		grabIcon.Visible = true
		--crosshair.Image = grabbingCrosshairIcon
	else
		crosshair.Visible = true
		grabIcon.Visible = false
		--crosshair.Image = defaultCrosshairIcon
	end
end)

DraggingAnObject.OnClientEvent:Connect(function(dragging)
	if dragging then
		crosshair.Visible = false
		grabIcon.Visible = false
	else
		crosshair.Visible = true
	end
end)
