-- // Constants \\ --
local Services = loadstring(game:HttpGet("https://raw.githubusercontent.com/iHavoc101/Genesis-Studios/main/Modules/Services.lua", true))()

-- // Functions \\ --
local Utility = {}

function Utility.new(Class, Properties, Children)
    local NewInstance = Instance.new(Class)

    for i,v in pairs(Properties or {}) do
        if i ~= "Parent" then
            NewInstance[i] = v
        end
    end

    for i, Child in pairs(Children or {}) do
        if typeof(Child) == "Instance" then
            Child.Parent = NewInstance
        end
    end

    NewInstance.Parent = Properties.Parent
    return NewInstance
end

-- // Main Module \\ --
local ESP = {}

function ESP.Chams(Part, Color)
    Part = Part or Instance.new("Part")
    return Part:FindFirstChildOfClass('BoxHandleAdornment') or Utility.new("BoxHandleAdornment", {
        Name = "BoxHandleAdornment",
        AlwaysOnTop = true,
        ZIndex = 5,
        Adornee = Part,
        Color3 = Color,
        Size = Part.Size + Vector3.new(0.1, 0.1, 0.1),
        Transparency = 0.4,
        Parent = Services.CoreGui
    })
end

function ESP.Location(Title, Icon, Color, Position)
    local Billboard = Utility.new("BillboardGui", {
        Name = "BuildingESP",
        Enabled = true,
        Parent = Services.CoreGui,
        Adornee = Utility.new("Attachment", {WorldPosition = Position, Parent = workspace.Terrain}),
        AlwaysOnTop = true,
        Size = UDim2.new(10, 10, 10, 10)
    }, {
        Utility.new("ImageLabel", {
            Name = "Icon",
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(0.75, 0, 0.75, 0),
            Image = "rbxassetid://"  .. (Icon and tostring(Icon) or "6034684937"),
            ImageColor3 = Color
        }),
        Utility.new("TextLabel", {
            Name = "Title",
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 1, 0),
            Size = UDim2.new(2, 0, 0.3, 0),
            Font = Enum.Font.GothamBold,
            Text = Title and tostring(Title) or "Location",
            TextColor3 = Color,
            TextScaled = true,
            TextWrapped = true
        })
    })
    return Billboard, Billboard.Adornee
end

return ESP
