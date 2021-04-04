--[[
     ___                 __   ___ _
    / __|_ __  ___  ___ / _| | _ \ |_  _ ___
    \__ \ '_ \/ _ \/ _ \  _| |  _/ | || (_-<
    |___/ .__/\___/\___/_|   |_| |_|\_,_/__/
        |_|

    Source:
        https://raw.githubusercontent.com/iHavoc101/Genesis-Studios/main/Modules/SpoofPlus.lua

    Version:
        0.1.0

    Date:
        April 3rd, 2021

    Author:
        OminousVibes @ v3rmillion.net / OminousVibes#7259  @ discord.gg

    Contributors:
        Max Gamer @ v3rmillion.net -- Moral Support
]]

-- // Constants \\ --
assert(getrawmetatable and newcclosure and checkcaller, "Unsupported exploit")
local RawMetatable = getrawmetatable(game)
local OldIndex = RawMetatable.__index

-- // Variables \\ --
local SpoofedIndex = {}

-- // Main Module \\ --
local SpoofPlus = {}
SpoofPlus.ClassName = "SpoofObject"
SpoofPlus.__index = SpoofPlus

function SpoofPlus.new(Object)
    local self = setmetatable({}, SpoofPlus)
    self._object = Object
    self._spoofs = {}
    return self
end

function SpoofPlus:AddSpoof(Index, Value)
    SpoofedIndex[self._object] = SpoofedIndex[self._object] or {}
    assert(table.find(self._spoofs, Index) == nil and SpoofedIndex[self._object][Index] == nil, "Spoof already exists, please remove pre-existing spoof.")

    local NewSpoof = {
        Index = Index;
        Value = typeof(Value) == "function" and Value or function() return Value end;
    }
    SpoofedIndex[self._object][Index] = NewSpoof
    table.insert(self._spoofs, Index)

    function NewSpoof:GetSpoofed()
        return NewSpoof.Value(self._object, Index)
    end

    function NewSpoof:Disconnect()
        SpoofedIndex[self._object][Index] = nil
        table.remove(self._spoofs, table.find(self._spoofs, Index))
    end

    return NewSpoof
end

function SpoofPlus:Destroy()
    for i,v in ipairs(self._spoofs) do
        self._type[v] = nil
    end
    self = nil
    return nil
end

-- // Metatable \\ --
setreadonly(RawMetatable, false)

RawMetatable.__index = newcclosure(function(Self, Index)
    local Return;

    if game:IsAncestorOf(rawget(getfenv(2), "script")) then
        pcall(function()
            local SpoofedObject = rawget(SpoofedIndex, Self) or rawget(SpoofedIndex, tostring(Self))
            local Spoof = rawget(SpoofedObject, Index)
            if Spoof then
                Return = Spoof.Value(Self, Index)
            end
        end)
    end

    return Return or OldIndex(Self, Index)
end)

setreadonly(RawMetatable, true)

return SpoofPlus
