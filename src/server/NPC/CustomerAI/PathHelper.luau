local PathfindingService = game:GetService("PathfindingService")

local PathHelper = {}
PathHelper.Path = PathfindingService:CreatePath({
	AgentCanJump = false,
	Costs = {
		Obstacle = math.huge,
		UseChair = 0,
	},
})

function PathHelper:ComputePath(startPos, endPos)
	local success = pcall(function()
		self.Path:ComputeAsync(startPos, endPos)
	end)

	if success and self.Path.Status == Enum.PathStatus.Success then
		return self.Path:GetWaypoints()
	end
	return nil
end

-- creates a path and keeps going until reaching the destination position
-- returns false is fails to do so, returns true if successful
function PathHelper:Follow(npc, destination)
	local humanoid = npc:FindFirstChild("Humanoid")
	if not humanoid then
		return false
	end

	local waypoints = self:ComputePath(npc.PrimaryPart.Position, destination)
	if not waypoints then
		return false
	end

	for _, wp in ipairs(waypoints) do
		humanoid:MoveTo(wp.Position)

		-- npc has now reached the chair, returns true so that the npc can sit down now
		if wp.Label == "UseChair" then
			--print("reached the chair!")
			return true
		-- if the npc has reached the kill block, destroy the npc
		elseif wp.Label == "DeleteCustomer" then
			--print("im boutta kms")
			npc:Destroy()
			return true
		end

		if not humanoid.MoveToFinished:Wait() then
			warn("NPC failed to reach: ", wp.Position)
			return false
		end
	end
end

return PathHelper
