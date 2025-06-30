-- Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Settings
local MAX_CUSTOMERS = 1
local MIN_SPAWN_TIME = 3
local MAX_SPAWN_TIME = 5

-- References
local customerModels = ReplicatedStorage:WaitForChild("Customers"):GetChildren()

local waypoints = workspace:FindFirstChild("AI Waypoints")
local spawnPoints = waypoints:FindFirstChild("Customer Spawn Points"):GetChildren()

local customerAIFolder = workspace:FindFirstChild("AI bots"):FindFirstChild("Customer AI bots")

local gameRunningFlag = workspace:WaitForChild("Game Functions"):WaitForChild("GameRunning")

-- Internal State
local spawnLocations = {}
local customerCount = 0
local spawnTimer = 0
local nextSpawnDelay = math.random(MIN_SPAWN_TIME, MAX_SPAWN_TIME)

-- Preprocess spawn points
for _, part in ipairs(spawnPoints) do
	if part:IsA("BasePart") then
		table.insert(spawnLocations, part.CFrame)
	end
end

-- Track customer instance count
customerAIFolder.ChildAdded:Connect(function()
	customerCount += 1
end)

customerAIFolder.ChildRemoved:Connect(function()
	customerCount -= 1
end)

-- Spawning logic
local function SpawnCustomer()
	local template = customerModels[math.random(1, #customerModels)]
	if not template:IsA("Model") then
		return
	end

	local spawnCFrame = spawnLocations[math.random(1, #spawnLocations)]
	local customer = template:Clone()
	customer:PivotTo(spawnCFrame)
	customer.Parent = customerAIFolder
	-- Optional tag for AI behavior later
	CollectionService:AddTag(customer, "Customer")
end

-- Main loop: runs once per frame but only does work if gameRunningFlag is true
RunService.Heartbeat:Connect(function(dt)
	if not gameRunningFlag.Value then
		return
	end

	spawnTimer += dt
	if spawnTimer >= nextSpawnDelay then
		if customerCount < MAX_CUSTOMERS then
			SpawnCustomer()
		end
		spawnTimer = 0
		nextSpawnDelay = math.random(MIN_SPAWN_TIME, MAX_SPAWN_TIME)
	end
end)
