local BaseNPC = require(script.Parent.BaseNPC)

local CustomerAI = setmetatable({}, { __index = BaseNPC }) -- CHAIN TO BASENPC
CustomerAI.__index = CustomerAI

function CustomerAI.new(model, pathCosts, seatList)
	local self = setmetatable(BaseNPC.new(model, pathCosts), CustomerAI)

	self.SeatList = seatList
	self.SeatIndex = math.random(1, #seatList)
	self.Seat = seatList[self.SeatIndex]
	self.Reward = 10 -- dummy

	task.spawn(function()
		self:FollowPath(self.Seat.Position)
	end)

	return self
end

return CustomerAI
