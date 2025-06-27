local CollectionService = game:GetService("CollectionService")
local NpcFolder = game:GetService("ServerScriptService"):WaitForChild("NPC")
local BaseNPCAIFolder = NpcFolder:WaitForChild("BaseNPCAI")

local PathCosts = require(NpcFolder:WaitForChild("PathCostConfig"))
local MonsterAI = require(BaseNPCAIFolder:WaitForChild("MonsterAI"))
local CustomerAI = require(BaseNPCAIFolder:WaitForChild("CustomerAI"))

local Workspace = game:GetService("Workspace")
local ChairsFolder = Workspace:WaitForChild("AI Waypoints")["Customer Chairs"] -- ["Service counter"]["Tables &  Chairs"].Chairs

local npcSeats = {}
for _, seatModel in ipairs(ChairsFolder:GetChildren()) do
	local seat = seatModel:FindFirstChildWhichIsA("Seat")
	if seat then
		table.insert(npcSeats, seat)
	end
end

local function handleNPC(npc)
	if CollectionService:HasTag(npc, "Monster") then
		print("new monster")
		MonsterAI.new(npc, PathCosts.Monster)
	elseif CollectionService:HasTag(npc, "Customer") then
		CustomerAI.new(npc, PathCosts.Customer, npcSeats)
	end
end

-- Init for existing
for _, npc in ipairs(CollectionService:GetTagged("Monster")) do
	print("wha aa")
	handleNPC(npc)
end
for _, npc in ipairs(CollectionService:GetTagged("Customer")) do
	handleNPC(npc)
end

-- Connect new NPCs
CollectionService:GetInstanceAddedSignal("Monster"):Connect(handleNPC)
CollectionService:GetInstanceAddedSignal("Customer"):Connect(handleNPC)
