-- Refactored Customer AI
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SeatManager = require(ServerScriptService.NPC.CustomerAI.SeatManager)
local PathHelper = require(ServerScriptService.NPC.CustomerAI.PathHelper)
local OrderValidator = require(ServerScriptService.NPC.CustomerAI.OrderValidator)

local CustomerCreateTask = ReplicatedStorage:FindFirstChild("CustomerEvents"):FindFirstChild("CustomerCreateTask")
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

local function customerRecievesOrder(npcInstance, humanoid, npcSeatIndex, minWait, maxWait, plateParent)
	task.wait(math.random(minWait, maxWait))

	humanoid.Sit = false
	resetFoodEvent:Fire(plateParent, true)

	local teleportSpot = SeatManager.Seats[npcSeatIndex].Parent:FindFirstChild("NpcTaskFinishTeleport")
	if teleportSpot then
		npcInstance.HumanoidRootPart.CFrame = teleportSpot.CFrame
	end
	humanoid.Seated:Wait()

	changeDragDetector(plateParent, true)
	if plateParent.PrimaryPart then
		plateParent.PrimaryPart.Anchored = false
	end

	task.wait(0.5)
	PathHelper:Follow(npcInstance, ReturnHome)
end

local function customerAi(npcInstance)
	print("im here")

	local humanoid = npcInstance:WaitForChild("Humanoid")
	local plateLocation = nil
	local customerTask = CustomerCreateTask:Invoke()
	customerTasks[npcInstance] = customerTask

	local seat, seatIndex = SeatManager:GetAvailableSeat()
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
		print("im sittin my ass down")

		seat:sit(humanoid)
	end

	local giveItemConnection
	giveItemConnection = giveItemEvent.Event:Connect(function(plateParent)
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

		if isValid then
			addMoney:Fire(reward)
			customerRecievesOrder(npcInstance, humanoid, seatIndex, 2, 5, plateParent)
		else
			warn("Incorrect order")
			addMoney:Fire(reward / 4)
			customerRecievesOrder(npcInstance, humanoid, seatIndex, 5, 10, plateParent)
		end

		if giveItemConnection then
			giveItemConnection:Disconnect()
		end
	end)
end

CollectionService:GetInstanceAddedSignal("Customer"):Connect(function(instance)
	customerAi(instance)
end)

for _, customer in ipairs(CollectionService:GetTagged("Customer")) do
	customerAi(customer)
end
