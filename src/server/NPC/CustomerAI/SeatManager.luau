local ChairsFolder = workspace:WaitForChild("AI Waypoints")["Customer Chairs"]

local SeatManager = {}
SeatManager.Seats = {}

for _, seatModel in ipairs(ChairsFolder:GetChildren()) do
	if seatModel:IsA("Model") then
		local seat = seatModel:FindFirstChildWhichIsA("Seat")
		if seat then
			table.insert(SeatManager.Seats, seat)
		end
	end
end

function SeatManager:GetAvailableSeat()
	for i, seat in ipairs(self.Seats) do
		if seat.SeatClaimed and seat.SeatClaimed.Value == false then
			seat.SeatClaimed.Value = true
			return seat, i
		end
	end
	return nil
end

function SeatManager:Release(seat)
	if seat and seat.SeatClaimed then
		seat.SeatClaimed.Value = false
	end
end

return SeatManager
