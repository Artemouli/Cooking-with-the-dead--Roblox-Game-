-- Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Settings
local difficulty = require(ServerScriptService.DifficultySystem.CustomerDifficultyManager)

-- References
local customerModels = ReplicatedStorage:WaitForChild("Customers"):GetChildren()

local waypoints = workspace:FindFirstChild("AI Waypoints")
local spawnPoints = waypoints:FindFirstChild("Customer Spawn Points"):GetChildren()

local customerAIFolder = workspace:FindFirstChild("AI bots"):FindFirstChild("Customer AI bots")

local workCycleChange = ReplicatedStorage:FindFirstChild("GameplayLoopEvents"):FindFirstChild("WorkCycleEvent")
local gameRunning = ServerScriptService["Non-Scripts"]["Game Functions"].GameRunning.Value

local workCycleChange = ReplicatedStorage:FindFirstChild("GameplayLoopEvents"):FindFirstChild("WorkCycleEvent")
workCycleChange.Event:Connect(function(status)
	gameRunning = status
end)

-- Internal State
local spawnLocations = {}
local customerCount = 0
local spawnTimer = 0
local nextSpawnDelay = math.random(difficulty.customerMinSpawnTime, difficulty.customerMaxSpawnTime)

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
	print("Customer count " .. customerCount)
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
	if not gameRunning then
		return
	end

	spawnTimer += dt
	if spawnTimer >= nextSpawnDelay then
		if customerCount < difficulty.customerMaxAliveAmount then
			SpawnCustomer()
		end
		spawnTimer = 0
		nextSpawnDelay = math.random(difficulty.customerMinSpawnTime, difficulty.customerMaxSpawnTime)
	end
end)
