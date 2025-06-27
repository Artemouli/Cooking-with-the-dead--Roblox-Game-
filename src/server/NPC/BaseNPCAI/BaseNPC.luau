local PathfindingService = game:GetService("PathfindingService")

local BaseNPC = {}
BaseNPC.__index = BaseNPC

function BaseNPC.new(npcModel, pathCosts)
	local self = setmetatable({}, BaseNPC)
	self.Model = npcModel
	self.Humanoid = npcModel:WaitForChild("Humanoid")
	self.PrimaryPart = npcModel.PrimaryPart or npcModel:WaitForChild("HumanoidRootPart")

	self.Path = PathfindingService:CreatePath({
		AgentCanJump = false,
		Costs = pathCosts or {},
	})

	return self
end

function BaseNPC:ComputePath(destination)
	local success, err = pcall(function()
		self.Path:ComputeAsync(self.PrimaryPart.Position, destination)
	end)
	return (success and self.Path.Status == Enum.PathStatus.Success) and self.Path:GetWaypoints() or nil
end

function BaseNPC:FollowPath(destination)
	local waypoints = self:ComputePath(destination)
	if not waypoints then
		return false
	end

	for _, wp in ipairs(waypoints) do
		self.Humanoid:MoveTo(wp.Position)
		local reached = self.Humanoid.MoveToFinished:Wait()
		if not reached then
			return false
		end
	end

	return true
end

return BaseNPC
