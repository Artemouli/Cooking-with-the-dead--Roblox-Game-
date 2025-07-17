-- Refactored Customer AI
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SeatManager = require(ServerScriptService.NPC.CustomerAI.SeatManager)
local PathHelper = require(ServerScriptService.NPC.CustomerAI.PathHelper)
local OrderValidator = require(ServerScriptService.NPC.CustomerAI.OrderValidator)
local difficulty = require(ServerScriptService.DifficultySystem.DifficultyManager)

local CustomerCreateTask = ReplicatedStorage:FindFirstChild("CustomerEvents"):FindFirstChild("CustomerCreateTask")
-- connected to PickupHandler.server.luau
local giveItemEvent = ReplicatedStorage:FindFirstChild("CustomerEvents"):FindFirstChild("GiveCustomerItemEvent")
local resetFoodEvent =
	ReplicatedStorage:FindFirstChild("ItemDrag"):FindFirstChild("PlateEvents"):FindFirstChild("ResetFoodEvent")
local addMoney = ReplicatedStorage:WaitForChild("MoneyRelatedEvents"):WaitForChild("AddMoney")

local ReturnHome = workspace:FindFirstChild("AI Waypoints")["Customer Despawn Points"]["npc despawn block"].Position
local customerTasks = {}

local function changeDragDetector(plateParent, enable)
	for _, dragDetector in pairs(plateParent:GetDescendants()) do
		if dragDetector:IsA("DragDetector") then
			dragDetector.Enabled = enable or false
		end
	end
end

local function customerRecievesOrder(npcInstance, humanoid, npcSeat, minWait, maxWait, plateParent)
	task.wait(math.random(minWait, maxWait))
	print(npcInstance.Name)
	humanoid.Sit = false
	resetFoodEvent:Fire(plateParent, true)
	humanoid.Seated:Wait()

	local teleportSpot = npcSeat.Parent:FindFirstChild("NpcTaskFinishTeleport")
	if teleportSpot then
		npcInstance.HumanoidRootPart.CFrame = teleportSpot.CFrame
	end

	changeDragDetector(plateParent, true)
	if plateParent.PrimaryPart then
		plateParent.PrimaryPart.Anchored = false
	end

	task.wait(0.5)
	SeatManager:Release(npcSeat)
	PathHelper:Follow(npcInstance, ReturnHome)
end

local function customerAi(npcInstance)
	-- ensures that the giveItemConnection runs only once
	local givenItemCheck = false

	local humanoid = npcInstance:WaitForChild("Humanoid")
	local customerTask = CustomerCreateTask:Invoke()
	customerTasks[npcInstance] = customerTask

	local seat = SeatManager:GetAvailableSeat()
	if not seat then
		npcInstance:Destroy()
		return
	end
	local destination = seat.Position

	npcInstance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			customerTasks[npcInstance] = nil
		end
	end)

	if PathHelper:Follow(npcInstance, destination) == true then
		--print("im sittin my ass down")
		seat:sit(humanoid)
	end

	local giveItemConnection
	giveItemConnection = giveItemEvent.Event:Connect(function(plateParent, customer)
		-- avoids all customers recieving food when only one should
		if npcInstance == customer then
			if givenItemCheck then
				return
			end

			local isValid, reward = OrderValidator:Validate(plateParent, customerTask)
			if not reward then
				warn("Missing reward")
				return
			end

			changeDragDetector(plateParent, false)
			if plateParent.PrimaryPart then
				plateParent.PrimaryPart.Anchored = true
				plateParent.PrimaryPart.CFrame = seat.Parent:FindFirstChild("PlateLocation").CFrame
			end

			givenItemCheck = true
			if isValid then
				addMoney:Fire(reward)
				customerRecievesOrder(npcInstance, humanoid, seat, 2, 5, plateParent)
			else
				warn("Incorrect order")
				addMoney:Fire(reward / 4)
				customerRecievesOrder(npcInstance, humanoid, seat, 5, 10, plateParent)
			end

			if giveItemConnection then
				giveItemConnection:Disconnect()
			end
		end
	end)
end

CollectionService:GetInstanceAddedSignal("Customer"):Connect(function(instance)
	customerAi(instance)
end)
