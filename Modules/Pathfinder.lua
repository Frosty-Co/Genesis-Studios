-- // Constants \\ --
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/iHavoc101/Genesis-Studios/main/Modules/Services.lua", true))()
local TimeRegulation = loadstring(game:HttpGet("https://raw.githubusercontent.com/iHavoc101/Genesis-Studios/main/Modules/TimeRegulation.lua", true))()

-- // Variables \\ --
local StoredPaths = {}

-- // Functions \\ --
local function Move(self)
	if self.Waypoints[self.currentWaypoint] and self.Running then
		self.Humanoid:MoveTo(self.Waypoints[self.currentWaypoint].Position)
		self.elapsed = tick()
	else
		self:Stop("Error: Invalid Waypoints")
	end
end

-- // Main Module \\ --
local PathFinder = {}
PathFinder.ClassName = "PathFinder"
PathFinder.__index = PathFinder

-- [ Constructor ] --
function PathFinder.new(Rig, PathParams, UseStored)
    local PathSave = StoredPaths[Rig]
    if UseStored == true and PathSave ~= nil then
        return PathSave
    end

	local self = setmetatable({}, PathFinder)

	self.Rig = Rig
	self.HumanoidRootPart = Rig:WaitForChild("HumanoidRootPart")
	self.Humanoid = Rig:WaitForChild("Humanoid")
	self.Timeout = 1
	
	self.__Blocked = Instance.new("BindableEvent")
	self.__WaypointReached = Instance.new("BindableEvent")
	self.__Completed = Instance.new("BindableEvent")
	self.Blocked = self.__Blocked.Event
	self.WaypointReached = self.__WaypointReached.Event
	self.Completed = self.__Completed.Event

    self.Path = Services.PathfindingService:CreatePath(PathParams)

    StoredPaths[Rig] = self
    return self
end

function PathFinder:Stop(Status)
	self.Running = nil
    TimeRegulation.Yield(0.02)
	if self.connection and self.connection.Connected then
		self.connection:Disconnect()
	end
	if self.blockedConnection and self.blockedConnection.Connected then
		self.blockedConnection:Disconnect()
	end
	self.blockedConnection = nil
	self.connection = nil
	if self.waypointsFolder then
		self.waypointsFolder:Destroy()
		self.waypointsFolder = nil
	end
	self.__Completed:Fire(Status, self.Rig, self.finalPosition)
	return
end

function PathFinder:Run(finalPosition, showWaypoints)
	if self.busy then return end
	self.busy = true
	
	if self.Running then self:Stop("Stopped Previous Path") end
	self.Running = true
	
	self.finalPosition = finalPosition
	self.Path:ComputeAsync(self.InitialPosition or self.HumanoidRootPart.Position, finalPosition)
	if self.Path.Status == Enum.PathStatus.NoPath then self:Stop("Error: No path found") end
	self.Waypoints = self.Path:GetWaypoints()
	self.currentWaypoint = 1
	
	self.connection = self.Humanoid.MoveToFinished:Connect(function(Reached)
		self.__WaypointReached:Fire(Reached, self.currentWaypoint, self.Waypoints)
        if Reached and self.currentWaypoint < #self.Waypoints and self.Running then
            self.currentWaypoint += 1
            Move(self)
            if self.waypointsFolder then
                self.waypointsFolder[self.currentWaypoint - 1].BrickColor = BrickColor.new("Bright green")
            end
        else
            self:Stop("Success: Path Reached")
        end
	end)
	coroutine.wrap(function()
        while self.running do
            if self.elapsed and (tick() - self.elapsed) >= self.Timeout then
                self:Stop("Error: MoveTo Timeout")
            end
        TimeRegulation.Yield(0.01) end
    end)(self)
	
	self.blockedConnection = self.Path.Blocked:Connect(function(BlockedWaypoint)
		self.__Blocked:Fire(BlockedWaypoint, self.currentWaypoint, self.Waypoints)
	end)

	if showWaypoints then
		self.waypointsFolder = Instance.new("Folder", workspace)
		for index, waypoint in ipairs(self.Waypoints) do
			local part = Instance.new("Part")
			part.Name = tostring(index)
			part.Size = Vector3.new(1, 1, 1)
			part.Position = waypoint.Position
			part.Anchored = true
			part.CanCollide = false
			part.Parent = self.waypointsFolder
			part.Material = Enum.Material.Neon
			part.BrickColor = BrickColor.new("Neon orange")
		end
	end
	
    if self.Waypoints[self.currentWaypoint] and self.Running then
		self.Humanoid:MoveTo(self.Waypoints[self.currentWaypoint].Position)
		self.elapsed = tick()
	else
		self:Stop("Error: Invalid Waypoints")
	end
	
	self.busy = false
end

function PathFinder:Distance(Target)
	local Position = Target
	if typeof(Target) == "Instance" then
		Position = Target.Position
	end
	return (Position - self.HumanoidRootPart.Position).Magnitude
end

function PathFinder:Destroy()
    StoredPaths[self] = nil
	self = nil
    return
end

return PathFinder
