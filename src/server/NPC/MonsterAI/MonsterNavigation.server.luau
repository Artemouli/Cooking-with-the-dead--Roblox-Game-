local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local PathFindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Monster = {}
Monster.__index = Monster

local WorkCycleEvent = ReplicatedStorage.GameplayLoopEvents.WorkCycleEvent

local interactables = workspace:FindFirstChild("Interactables")
local interactableDoors = interactables:FindFirstChild("Doors"):FindFirstChild("Interactable Doors")

local traversalCosts = ReplicatedStorage:FindFirstChild("AI pathfinding Costs"):FindFirstChild("Monster AI Costs")

local difficulty = require(ServerScriptService.DifficultySystem.CustomerDifficultyManager)

-- these are used to declare what the ai should be doing right now
local AI_STATES = {
	IDLE = {
		Name = "idle",
	},
	PATROLLING = {
		Name = "patrolling",
		MinDuration = 0,
		MaxDuration = 0,
	},
	-- runs when the patrolling timer is finished, the npc then pathfinds to
	CURIOUS = {
		Name = "curious",
		MinDuration = 0,
		MaxDuration = 0,
	},
	SEARCHING = {
		Name = "searching",
	},
	CHASING = {
		Name = "chasing",
	},
}

local DOOR_STATES = {
	SupplyRoom = interactableDoors:FindFirstChild("SupplyRoomDoor"):FindFirstChild("DoorLocked"),
	OrderRoom = interactableDoors:FindFirstChild("OrderBuyDoor"):FindFirstChild("DoorLocked"),
	SecurityRoom = interactableDoors:FindFirstChild("SecurityRoomDoor"):FindFirstChild("DoorLocked"),
}

-- TODO, split waypoints into seperate waypoints, general bumming about waypoints, and waypoints within the restauraunt for when the monster is curious to explore
local outsideWaypoints =
	workspace:FindFirstChild("AI Waypoints"):FindFirstChild("Monster Waypoints"):FindFirstChild("Outside"):GetChildren()

-- local TEST_DESTINATION = Vector3.new(-444.27, 1.5, 68.05)

-- Class constructor
function Monster.new(monsterInstance)
	local self = setmetatable({}, Monster)
	self.instance = monsterInstance
	self.humanoid = monsterInstance:WaitForChild("Humanoid")
	self.rootPart = monsterInstance.PrimaryPart or monsterInstance:WaitForChild("HumanoidRootPart")

	self.navigating = false
	self.currentTarget = nil
	self.playerLastKnownPos = nil

	-- keeps track of the current ai state
	self.currentState = AI_STATES.IDLE

	self.path = PathFindingService:CreatePath({
		Costs = {
			UseDoorSupply = traversalCosts:FindFirstChild("SupplyRoomDoorCost").Value,
			UseDoorOrder = traversalCosts:FindFirstChild("OrderRoomDoorCost").Value,
			UseDoorSecurity = traversalCosts:FindFirstChild("SecurityRoomCost").Value,
			UseRegularDoor = traversalCosts:FindFirstChild("RegularDoorCost").Value,
		},
	})

	task.spawn(function()
		self:RunAI()
	end)

	return self
end

-- Player detection
function Monster:GetTarget()
	local VISION_RANGE = 40
	local ATTACK_RANGE = 3

	local origin = self.instance.Head.Position
	local bestTarget, closestDistance = nil, VISION_RANGE

	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		if not char then
			continue
		end
		local root = char:FindFirstChild("HumanoidRootPart")
		local humanoid = char:FindFirstChild("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then
			continue
		end

		local direction = root.Position - origin
		local distance = direction.Magnitude
		if distance > VISION_RANGE then
			continue
		end

		-- FOV check
		if distance > ATTACK_RANGE then
			local fov = direction.Unit:Dot(self.instance.Head.CFrame.LookVector)
			if fov < 0.6 then
				continue
			end
		end

		if ATTACK_RANGE > distance then
			Monster:Attack(player)
		end

		local result = workspace:Raycast(origin, direction)
		if result and result.Instance and result.Instance:IsDescendantOf(char) then
			if distance < closestDistance then
				closestDistance = distance
				bestTarget = char
			end
		end
	end

	return bestTarget, closestDistance
end

-- Navigation helpers
function Monster:GetPathTo(destination)
	local success = pcall(function()
		self.path:ComputeAsync(self.rootPart.Position, destination)
	end)

	if success and self.path.Status == Enum.PathStatus.Success then
		return self.path:GetWaypoints()
	else
		local fallback = self.rootPart.CFrame * CFrame.new(0, 0, 3)
		self.humanoid:MoveTo(fallback.Position)
		return nil
	end
end

function Monster:EndNavigation()
	self.navigating = false
end

function Monster:StartNavigation(destination)
	self.navigating = true
	local waypoints = self:GetPathTo(destination)
	if not waypoints then
		self:EndNavigation()
		return
	end

	for _, waypoint in ipairs(waypoints) do
		if self:GetTarget() then
			self:EndNavigation()
			return
		end

		if self:IsDoorLocked(waypoint.Label) then
			warn("Door locked: " .. waypoint.Label)
			task.wait(1)
			self:EndNavigation()
			return
		end

		self.humanoid:MoveTo(waypoint.Position)
		local reached = self.humanoid.MoveToFinished:Wait()
		if not reached then
			warn("Failed to reach waypoint. Ending navigation")
			self:EndNavigation()
			return
		end
	end

	self:EndNavigation()
end

-- function that runs when a player is close enough to the monster
function Monster:Attack(target)
	warn("woah im attacking")
end

function Monster:IsDoorLocked(label)
	if label == "UseDoorSupply" then
		return DOOR_STATES.SupplyRoom.Value
	end
	if label == "UseDoorOrder" then
		return DOOR_STATES.OrderRoom.Value
	end
	if label == "UseDoorSecurity" then
		return DOOR_STATES.SecurityRoom.Value
	end
	return false
end

function Monster:RunAI()
	while self.instance do
		-- print("running ai")
		self.instance.PrimaryPart:SetNetworkOwner(nil)

		-- check for when the game starts
		WorkCycleEvent.Event:Connect(function(active)
			if active then
				self.currentState = AI_STATES.PATROLLING
			else
				self.currentState = AI_STATES.IDLE
			end
		end)
		local target, distance = self:GetTarget()
		if target then
			task.spawn(function()
				self.currentState = AI_STATES.CHASING
				self.currentTarget = target
				self.playerLastKnownPos = target.HumanoidRootPart.Position
				self.humanoid:MoveTo(target.HumanoidRootPart.Position)
			end)
		elseif not self.navigating then
			if self.playerLastKnownPos then
				task.spawn(function()
					self.currentState = AI_STATES.SEARCHING
					self:StartNavigation(self.playerLastKnownPos)
					self.playerLastKnownPos = nil
					task.wait(0.2)
				end)
			else
				task.spawn(function()
					-- print("im going going going")
					-- couldn't find the player, or just wandering
					if self.currentState == AI_STATES.PATROLLING then
						self:StartNavigation(outsideWaypoints[math.random(1, #outsideWaypoints)].Position)
					elseif self.currentState == AI_STATES.SEARCHING then
						print("So we searching now ")
					end
				end)
			end
		end

		task.wait(0.1)
	end
end

-- Auto-initialize any monster
CollectionService:GetInstanceAddedSignal("Monster"):Connect(function(monsterInstance)
	Monster.new(monsterInstance)
end)

for _, monsterInstance in ipairs(CollectionService:GetTagged("Monster")) do
	Monster.new(monsterInstance)
end

return Monster
