-- // Variables \\ --
local Enabled = true
local Drawings = {}

-- // Main Module \\ --
local DrawingAPI = setmetatable({}, {__newindex = function(Self, Index, Value)
    if Index == "Enabled" then
        Enabled = not not Value
        for i,v in ipairs(Drawings) do
            v.Visible = Enabled
        end
    else
        rawset(Self, Index, Value)
    end
end})

function DrawingAPI.new(Class, Properties)
    local NewDrawing = Drawing.new(Class)
    for i,v in pairs(Properties) do
        NewDrawing[i] = v
    end
    NewDrawing.Visible = Enabled
    table.insert(Drawings, NewDrawing)
    return NewDrawing
end

function DrawingAPI:Clear()
    for i,v in ipairs(Drawings) do
        pcall(function()
            v:Remove()
        end)
    end
    Drawings = {}
    return Drawings
end

return DrawingAPI
