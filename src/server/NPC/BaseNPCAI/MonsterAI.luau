local Players = game:GetService("Players")

local BaseNPC = require(script.Parent.BaseNPC)

local MonsterAI = setmetatable({}, { __index = BaseNPC }) -- CHAIN TO BASENPC
MonsterAI.__index = MonsterAI

local VISION_RANGE = 40
local ATTACK_RANGE = 15
local KILL_RANGE = 3.5

function MonsterAI.new(model, pathCosts)
	local self = setmetatable(BaseNPC.new(model, pathCosts), MonsterAI)

	-- Monster-specific fields
	self.State = "idle"
	self.Target = nil
	self.navigating = false
	self.playerLastKnownPos = nil

	-- Example fallback destination
	self.TEST_DESTINATION = Vector3.new(0, 0, 0)

	task.spawn(function()
		while self.Model and self.Model.Parent do
			self:Tick()
			task.wait()
		end
	end)

	return self
end

function MonsterAI:GetNearestPlayer()
	local maxDistance = VISION_RANGE
	local newTarget = nil

	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character
		if not character then
			continue
		end
		local root = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then
			continue
		end

		local origin = self.Head.Position
		local direction = root.Position - origin
		local distance = direction.Magnitude
		if distance > VISION_RANGE then
			continue
		end

		-- Field of View check for targets farther than attack range
		if distance > ATTACK_RANGE then
			local fov = direction.Unit:Dot(self.Head.CFrame.LookVector)
			if fov < 0.6 then
				continue
			end
		end

		-- Line of Sight check
		local result = workspace:Raycast(origin, direction * VISION_RANGE)
		if not result or not result.Instance then
			continue
		end
		if not result.Instance:IsDescendantOf(character) then
			continue
		end

		if distance < maxDistance then
			maxDistance = distance
			newTarget = character
		end
	end

	return newTarget, maxDistance
end

function MonsterAI:GetWaypoints(destination)
	self.playerLastKnownPos = nil

	local success, err = pcall(function()
		self.path:ComputeAsync(self.PrimaryPart.Position, destination)
	end)

	if success and self.path.Status == Enum.PathStatus.Success then
		return self.path:GetWaypoints()
	else
		-- If pathfinding failed, move back a bit and return false
		local reverse = (self.PrimaryPart.CFrame * CFrame.new(0, 0, 3)).Position
		self.Humanoid:MoveTo(reverse)
		task.wait(0.1)
		return false
	end
end

function MonsterAI:EndNavigation()
	self.navigating = false
end

function MonsterAI:StartNavigation(destination)
	self.navigating = true

	local waypoints = self:GetWaypoints(destination)
	if not waypoints then
		self:EndNavigation()
		return
	end

	for i, waypoint in ipairs(waypoints) do
		self.Target, _ = self:GetNearestPlayer()
		if self.Target then
			self:EndNavigation()
			return
		end

		self.Humanoid:MoveTo(waypoint.Position)
		local reached = self.Humanoid.MoveToFinished:Wait()

		if not reached then
			warn(self.Model.Name .. " failed to reach waypoint. Ending navigation.")
			self:EndNavigation()
			return
		end
	end

	self:EndNavigation()
end

function MonsterAI:Tick()
	-- Update target
	self.Target = self:GetNearestPlayer()

	if self.Target then
		-- Move toward target's HumanoidRootPart position
		self.Humanoid:MoveTo(self.Target.HumanoidRootPart.Position)
		self.playerLastKnownPos = self.Target.HumanoidRootPart.Position
	else
		if not self.navigating then
			if not self.playerLastKnownPos then
				self:StartNavigation(self.TEST_DESTINATION)
			else
				self:StartNavigation(self.playerLastKnownPos)
			end
		end
	end
end

return MonsterAI
