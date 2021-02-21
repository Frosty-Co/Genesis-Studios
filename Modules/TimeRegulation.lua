-- // Constants \\ --
-- [ Services ] --
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/iHavoc101/Genesis-Studios/main/Modules/Services.lua", true))()

-- // Variables \\ --
local Connections = {}

-- // Main Module \\ --
local Module = {}

--[[
Module.new(Delay: integer, Callback: Function)
    Creates a loop.
]]
function Module.new(Delay: integer, Callback: Function, Event: RBXScriptSignal)
    local Loop = {
        Delay = Delay;
        Function = Callback;
        LastCalled = time();
    }

    local Connection = (Event or Services.RunService.Heartbeat):Connect(function()
        if time() - Loop.LastCalled > Loop.Delay then
            Loop.LastCalled = math.huge
            Loop.Function()
            Loop.LastCalled = time()
        end
    end)
    table.insert(Connections, Connection)

    function Loop:Break()
        Connection:Disconnect()
    end

    function Loop:Execute()
        if time() - Loop.LastCalled > Loop.Delay then
            Loop.LastCalled = math.huge
            Loop.Function()
            Loop.LastCalled = time()
        end
    end

    return Loop
end

--[[
Module.Yield(Delay: integer)
    Delays a certain amount of time.
]]
function Module.Yield(Delay: integer)
    local InitialTime = time()
    repeat
        Services.RunService.RenderStepped:Wait(0.5)
    until time() - InitialTime > Delay
end

--[[
Module:Disconnect()
    Breaks all loops currently running.
]]
function Module:Disconnect()
    for i,v in ipairs(Connections) do
        v:Disconnect()
    end
end

return Module
