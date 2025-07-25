local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- ingredients
local ingredientInfo = require(ReplicatedStorage.IngredientInfo.IngredientInfo)

local player = Players.LocalPlayer
local BuyMenuGui = player:WaitForChild("PlayerGui"):WaitForChild("BuyMenu"):WaitForChild("BuyMenuGUI")

-- events
local buyIngredientsEvent = ReplicatedStorage:WaitForChild("UserHUD").BuyMenuOperationEvents.BuyIngredientsEvent
local displayBuyMenuEvent = ReplicatedStorage:WaitForChild("UserHUD").DisplayBuyMenuEvent

-- buttons
-- close button
local closeButton = BuyMenuGui.TestShopFrame.CloseButton

-- buying ingredient buttons
local buyTestIngredient = BuyMenuGui.TestShopFrame.BuyTestIngredient

closeButton.MouseButton1Click:Connect(function()
	displayBuyMenuEvent:FireServer(false)
end)

buyTestIngredient.MouseButton1Click:Connect(function()
	buyIngredientsEvent:FireServer(ingredientInfo.TestIngredient)
end)
