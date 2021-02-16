local TimeRegulation = loadstring(game:HttpGet("https://raw.githubusercontent.com/iHavoc101/Genesis-Studios/main/Modules/TimeRegulation.lua", true))()
local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/iHavoc101/Genesis-Studios/main/Modules/Signal.lua", true))()

-- // Main Module \\ --
local MagnitudeModule = {}
MagnitudeModule.__index = MagnitudeModule

function MagnitudeModule.new(MainPart, Objects, Distance)
    local self = setmetatable({}, MagnitudeModule)
    self.MainPart = MainPart
    self.Objects = Objects or {}
    self.Distance = Distance or 5

    self.ObjectEntered = Signal.new()
    self.ObjectLeft = Signal.new()

    self.__Objects = {}
    self.__LoopConnection = nil

    return self
end

function MagnitudeModule:GetClosest()
    local Closest = {
        Object = nil;
        Distance = self.Distance;
        Unit = nil;
    }
    for i,v in ipairs(self.Objects) do
        local Object = v
        if v:IsA("Player") and v.Character then
            Object = v.Character.PrimaryPart or v.Character:WaitForChild("HumanoidRootPart")
        elseif v:IsA("Model") and (v.PrimaryPart or v:FindFirstChild("HumanoidRootPart")) then
            Object = v.PrimaryPart or v.HumanoidRootPart
        end
        local Delta = (self.MainPart.Position - Object.Position)
        local Magnitude = Delta.Magnitude
        local Unit = Delta.Unit
        if Magnitude < Closest.Distance then
            Closest = {
                Object = v;
                Distance = Magnitude;
                Unit = Unit;
            }
        end
    end

    return Closest
end

function MagnitudeModule:GetInRange()
    local ObjectsInRange = {}

    for i,v in ipairs(self.Objects) do
        local Object = v
        if v:IsA("Player") and v.Character then
            Object = v.Character.PrimaryPart or v.Character:WaitForChild("HumanoidRootPart")
        elseif v:IsA("Model") and (v.PrimaryPart or v:FindFirstChild("HumanoidRootPart")) then
            Object = v.PrimaryPart or v.HumanoidRootPart
        end
        local Delta = (self.MainPart.Position - Object.Position)
        local Magnitude = Delta.Magnitude
        local Unit = Delta.Unit
        if Magnitude < self.Distance then
            table.insert(ObjectsInRange, {
                Object = v;
                Distance = Magnitude;
                Unit = Unit;
            })
        end
    end

    return ObjectsInRange
end

return MagnitudeModule
