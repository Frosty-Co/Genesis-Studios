-- // Constants \\ --
-- [ Services ] --
local Services = setmetatable({}, {__index = function(Self, Index)
	local NewService = game.GetService(game, Index)
	if NewService then
		Self[Index] = NewService
	end
	return NewService
end})

-- [ LocalPlayer ] --
local LocalPlayer = Services.Players.LocalPlayer

-- // Variables \\ --
local IconChanged = Instance.new("BindableEvent")

-- // Functions \\ --
local Utility = {}
function Utility.new(Class, Properties, Children)
    local NewInstance = Instance.new(Class)
    for i,v in pairs(Properties or {}) do
        if i ~= "Parent" then
            NewInstance[i] = v
        end
    end
    for i,v in ipairs(Children or {}) do
        if typeof(v) == "Instance" then
            v.Parent = NewInstance
        end
    end

    NewInstance.Parent = Properties.Parent
    return NewInstance
end

local function Quadratic(Origin, CurveOffset, Goal, Alpha)
	local L1 = Origin:Lerp(CurveOffset, Alpha)
	local L2 = CurveOffset:Lerp(Goal, Alpha)
	return L1:Lerp(L2, Alpha)
end

local function GetMousePosition()
    return Services.UserInputService:GetMouseLocation() - Vector2.new(0, 36)
end

-- // Main Module \\ --
local OrnamentalMouse = {}
OrnamentalMouse.ClassName = "OrnamentalMouse"
OrnamentalMouse.__index = OrnamentalMouse

function OrnamentalMouse.new()
    local self = setmetatable({
        Enabled = true;
        AutoUpdate = true;
        Sensitivity = 0.5;
    }, OrnamentalMouse)
    self._ForceUpdate = false;

    -- Interface --
    self._ScreenGui = Instance.new("ScreenGui")
    self._Icon = Instance.new("ImageLabel")

    -- Event Listeners --
    IconChanged.Event:Connect(function(Icon)
        if Icon == "" then
            Icon = "rbxasset://textures/ArrowFarCursor.png"
        end
        Services.RunService.RenderStepped:Wait()
        self._Icon.Image = Icon
    end)

    -- Actions --
    self._ScreenGui.DisplayOrder = 5e10

    self._Icon.Name = "Icon"
    self._Icon.AnchorPoint = Vector2.new(0.5, 0.5)
    self._Icon.BackgroundTransparency = 1
    self._Icon.Size = UDim2.new(0, 64, 0, 64)
    self._Icon.Image = "rbxasset://textures/ArrowFarCursor.png"
    self._Icon.ScaleType = Enum.ScaleType.Fit

    self._Icon.Parent = self._ScreenGui
    self._ScreenGui.Parent = Services.RunService:IsStudio() and (LocalPlayer:FindFirstChildWhichIsA("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")) or Services.CoreGui

    Services.RunService:BindToRenderStep("UpdateOrnamentalMouse", Enum.RenderPriority.Input.Value, function()
        Services.UserInputService.MouseIconEnabled = not self.Enabled
        self._Icon.Visible = self.Enabled
        self._Icon.Size = Services.UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter and UDim2.new(0, 32, 0, 32) or UDim2.new(0, 64, 0, 64)
        if self.AutoUpdate or self._ForceUpdate then
            local MousePosition = GetMousePosition()
            self:TweenPosition(MousePosition, 0.05)
        end
        if Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or Services.UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            self._ForceUpdate = true
        end
    end)

    return self
end

function OrnamentalMouse:OverridePosition(Position)
    self._Icon.Position = UDim2.fromOffset(Position.X, Position.Y)
end

function OrnamentalMouse:TweenPosition(Position, Duration)
    local Distance = (GetMousePosition() - self._Icon.AbsolutePosition).Magnitude
    local Speed = (Distance * 0.01) / (self.Sensitivity * 10)
    Services.TweenService:Create(self._Icon, TweenInfo.new(Duration or Speed), {Position = UDim2.fromOffset(Position.X, Position.Y)}):Play()
end

function OrnamentalMouse:MoveBezier(Position)
    local Distance = (GetMousePosition() - Position).Magnitude
    local LoopCount = math.clamp(Distance * 0.05, 1, 50)  / (self.Sensitivity * 10)
    local RandomOffset = math.random(-25, 25)
    for i = 1, LoopCount do
        local MousePosition = GetMousePosition()
        local Result = Quadratic(MousePosition, Vector2.new(Position.X + RandomOffset, MousePosition.Y), Position, i/LoopCount)
        self:TweenPosition(Result)
        Services.RunService.RenderStepped:Wait()
    end
end

-- // Metatable \\ --
-- [ Metatable ] --
local RawMetatable = getrawmetatable(game)
local __newindex = RawMetatable.__newindex
local __namecall = RawMetatable.__namecall

setreadonly(RawMetatable, false)

RawMetatable.__newindex = newcclosure(function(Self, Index, Value)
    if (typeof(Self) == "Instance" and (Self:IsA("PlayerMouse") or Self:IsA("Mouse"))) and Index == "Icon" then
        IconChanged:Fire(Value)
    end
    return __newindex(Self, Index, Value)
end)

setreadonly(RawMetatable, true)

-- // Actions \\ --
local MouseBoi = OrnamentalMouse.new()
wait(20.5)
--[[
while true do
    wait(2.5)
    MouseBoi.AutoUpdate = false
    MouseBoi:MoveBezier(Vector2.new(100, 100))
    wait(5)
    MouseBoi.AutoUpdate = true
end
]]
--LocalPlayer:GetMouse().Icon = "http://www.roblox.com/asset/?id=6022668898"

return OrnamentalMouse
