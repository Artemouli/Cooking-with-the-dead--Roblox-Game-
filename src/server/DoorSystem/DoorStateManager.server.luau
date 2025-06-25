-- ServerScriptService
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DoorManager = {}

-- Class to represent a door
local Door = {}
Door.__index = Door

function Door:new(doorInstance)
    local instance = setmetatable({}, Door)
    instance.doorInstance = doorInstance
    instance.lockedState = doorInstance:FindFirstChild("DoorLocked")
    instance.pathfindingModifier = doorInstance:FindFirstChild("PathfindingModifierPart"):FindFirstChild("PathfindingModifier")
    instance.lockButton = doorInstance:FindFirstChild("LockButton")
    instance.proximityPrompt = instance.lockButton:FindFirstChild("Attachment"):FindFirstChild("LockInteraction")
    
    -- Events
    instance.powerStateEvent = game.ReplicatedStorage.PowerRelatedEvents.PowerStateChange
    instance.doorInteractionEvent = game.ReplicatedStorage.PowerRelatedEvents.DoorInteraction
    
    -- Connect proximty prompt triggered event
    instance.proximityPrompt.Triggered:Connect(instance.onProximityPromptTriggered)
    
    -- Connect power state event
    instance.powerStateEvent.Event:Connect(instance.onPowerStateChange)
    
    return instance
end

function Door:onProximityPromptTriggered(player)
    if self.lockedState.Value == true then
        self:unlockDoor()
    elseif self.lockedState.Value == false then
        self:lockDoor()
    end
end

function Door:unlockDoor()
    self.lockedState.Value = false
    self.pathfindingModifier.PassThrough = true
    self.doorInteractionEvent:Fire(false)
end

function Door:lockDoor()
    self.lockedState.Value = true
    self.pathfindingModifier.PassThrough = false
    self.doorInteractionEvent:Fire(true)
end

function Door:onPowerStateChange(state)
    if state == "PowerOff" then
        self:unlockDoor()
    end
end

-- Loop through all tagged doors
for _, doorInstance in pairs(CollectionService:GetTagged("InteractableDoor")) do
    local door = Door:new(doorInstance)
    -- You can add more logic here, like storing doors in a table for easier access
end