-- https://devforum.roblox.com/t/quick-ui-window-creation-module-v02052025/3193011
-- https://www.roblox.com/games/17582066556/windows-module-dev-place-thingy#!/game-instances
-- open the above game in roblox studio to see how it works lol its crazy

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DisplayBuyMenuEvent = ReplicatedStorage:WaitForChild("UserHUD"):WaitForChild("DisplayBuyMenuEvent")

-- local Windows = ServerScriptService.UI.Windows

local OrderingLaptopUI =
	workspace:WaitForChild("Interactables")["Order Interactables"]["OrderingLaptop"]["Laptop Part"].Attachment["Open UI"]

OrderingLaptopUI.Triggered:Connect(function(player)
	DisplayBuyMenuEvent:FireClient(player, true)
	-- local window = Windows:create(shopGui, UDim2.new(0.45, 0, 0.5, 0), "Frutiger Aero")
end)
