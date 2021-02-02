-- // Constants \\ --
-- [ Services ] --
local Services = setmetatable({}, {__index = function(Self, Index)
    local NewService = game:GetService(Index)
    if NewService then
        Self[Index] = NewService
    end
    return NewService
end})

-- [ LocalPlayer ] --
local LocalPlayer = Services.Players.LocalPlayer

-- [ Modules ] --
local LoopPlus = loadstring(game:HttpGet("https://raw.githubusercontent.com/iHavoc101/Genesis-Studios/main/Modules/LoopPlus.lua", true))()

-- [ User Interface ] --
local Luminosity = loadstring(game:HttpGet("https://raw.githubusercontent.com/iHavoc101/Genesis-Studios/main/UserInterface/Luminosity.lua", true))()
Luminosity.LoadingScreen()
local Window = Luminosity.new("Genesis Hub", "v1.0.0", 4483362458)

-- // Functions \\ --
local Utility = {}

--[[
Utility.new(Class: string, Properties: Dictionary, Children: Array)
    Creates a new object with the Properties
]]
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

--[[
Utility.Tween(Object: Instance, TweenInformation: TweenInfo, Goal: Dictionary)
    Creates a tween
]]
function Utility.Tween(Object, TweenInformation, Goal)
    -- [ Tween ] --
    local Tween = Services.TweenService:Create(Object, TweenInformation, Goal)

    -- [ Info ] --
    local Info = {}

    -- Yield --
	function Info:Yield()
		Tween:Play()
		Tween.Completed:Wait(10)
	end

	return setmetatable(Info, {__index = function(Self, Index)
		local Value = Tween[Index]
		return typeof(Value) ~= "function" and Value or function(self, ...)
			return Tween[Index](Tween, ...)
		end
	end})
end

--[[
Utility:Wait()
    Yields for a short period of time.
]]
function Utility.Wait(Seconds)
    if Seconds then
        local StartTime = time()
        repeat
            Services.RunService.Heartbeat:Wait(0.1)
        until time() - StartTime > Seconds
    else
        return Services.RunService.Heartbeat:Wait(0.1)
    end
end

--[[
Utility.ESP(Part: BasePart, Color: Color3)
    Creates an ESP box for a Part.
]]
function Utility.ESP(Part, Parent, Color, ExtraInfo)
    local Info = ExtraInfo or {}
    for i,v in pairs({Visible = true}) do
        Info[i] = v
    end

    return Part:FindFirstChildOfClass('BoxHandleAdornment') or Utility.new("BoxHandleAdornment", {
        Name = "BoxHandleAdornment",
        Visible = Info.Visible,
        AlwaysOnTop = true,
        ZIndex = 5,
        Adornee = Part,
        Color3 = Color,
        Size = Part.Size + Vector3.new(0.1, 0.1, 0.1),
        Transparency = 0.4,
        Parent = Parent
    })
end

return {
    -- Rake --
    [2413927524] = function(Window)
        local ESP = Utility.new("BillboardGui", {
            Name = "Warning",
            Enabled = false,
            Parent = Services.CoreGui,
            AlwaysOnTop = true,
            LightInfluence = 1,
            Size = UDim2.new(2, 0, 2, 0)
        }, {
            Utility.new("ImageButton", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Image = "rbxassetid://6031071053",
                ImageColor3 = Color3.fromRGB(255, 0, 0)
            }),
            Utility.new("Frame", {
                Name = "Ripple",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.5,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 0, 0, 0),
                ZIndex = 0
            }, {Utility.new("UICorner", {CornerRadius = UDim.new(1, 0)})})
        })

        local Billboard = Utility.new("BillboardGui", {
            Name = "Info",
            Parent = Services.CoreGui,
            Enabled = false,
            AlwaysOnTop = true,
            Size = UDim2.new(15, 0, 2.5, 0),
            StudsOffsetWorldSpace = Vector3.new(0, 5, 0)
        }, {
            Utility.new("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Creepster,
                RichText = true,
                Text = "<font color=\"rgb(255, 0, 0)\">Rake</font>\n<font color=\"rgb(0, 0, 255)\">Distance: 50</font> - <font color=\"rgb(0, 255, 0)\">Health: 300</font>",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextScaled = true,
                TextWrapped = true
            })
        })

        local Tab = Window.Tab("Rake", 6034509997)
        local Info = {
            RakeESP = {
                Enabled = false;
                Chams = false;
                Objects = {}
            }
        }

        local RakeESP = Tab.Folder("Rake ESP", "Lets you keep track of the Rake's location, helping you avoid it.")
        RakeESP.Switch("Radar", function(Status)
            ESP.Enabled = Status
        end)
        RakeESP.Switch("Chams", function(Status)
            for i,v in ipairs(Info.RakeESP.Objects) do
                v.Visible = Status
            end
        end)
        RakeESP.Switch("Billboard", function(Status)
            Billboard.Enabled = Status
        end)

        -- Loops --
        local RippleTween = Utility.Tween(ESP.Ripple, TweenInfo.new(1), {Size = UDim2.new(40, 0, 40, 0), BackgroundTransparency = 1})
        LoopPlus.new(4, function()
            RippleTween:Yield()
            ESP.Ripple.Size = UDim2.new(0, 0, 0, 0)
            ESP.Ripple.BackgroundTransparency = 0.5
        end)

        LoopPlus.new(0.1, function()
            local Rake = workspace:FindFirstChild("Rake")
            if Rake then
                local RakeInfo = pcall(function()
                    local Humanoid = Rake:FindFirstChildWhichIsA("Humanoid")
                    local PrimaryPart = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character.HumanoidRootPart
                    return {
                        Health = Humanoid.Health;
                        Distance = (Rake.PrimaryPart.Position - PrimaryPart.Position).Magnitude;
                    }
                end)
                if RakeInfo and RakeInfo.Health and RakeInfo.Distance then
                    Billboard.Title.Text = "<font color=\"rgb(255, 0, 0)\">Rake</font>\n<font color=\"rgb(0, 0, 255)\">Distance: " .. (RakeInfo.Distance and tostring(RakeInfo.Distance) or "?") .. "</font> - <font color=\"rgb(0, 255, 0)\">Health: " .. (RakeInfo.Health and tostring(RakeInfo.Health) or "?") .. "</font>"
                end
            end
        end)

        -- Events --
        workspace.ChildAdded:Connect(function(Child)
            if Child.Name == 'Rake' and Child:IsA('Model') then
                Info.RakeESP.Objects = {}
                Utility.Wait(5)
                for i,v in ipairs(Child:GetChildren()) do
                    if v:IsA("BasePart") then
                        table.insert(Info.RakeESP.Objects, Utility.ESP(v, v, Color3.new(1, 0, 0), {Visible = Info.RakeESP.Chams}))
                    end
                end
                ESP.Adornee = workspace.Rake.HumanoidRootPart
                Billboard.Adornee = workspace.Rake.HumanoidRootPart
            end
        end)

        -- Actions --
        if workspace:FindFirstChild("Rake") then
            for i,v in ipairs(workspace.Rake:GetChildren()) do
                if v:IsA("BasePart") then
                    table.insert(Info.RakeESP.Objects, Utility.ESP(v, v, Color3.new(1, 0, 0), {Visible = Info.RakeESP.Chams}))
                end
            end
            ESP.Adornee = workspace.Rake.HumanoidRootPart
            Billboard.Adornee = workspace.Rake.HumanoidRootPart
        end

        -- Building ESP --
        local BuildingBillboards = {
            -- SafeHouse --
            SafeHouse = Utility.new("BillboardGui", {
                Name = "BuildingESP",
                Enabled = false,
                Parent = Services.CoreGui,
                Adornee = Utility.new("Attachment", {WorldPosition = Vector3.new(-370, 40, 75), Parent = workspace.Terrain}),
                AlwaysOnTop = true,
                Size = UDim2.new(10, 10, 10, 10)
            }, {
                Utility.new("ImageLabel", {
                    Name = "Icon",
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Size = UDim2.new(0.75, 0, 0.75, 0),
                    Image = "rbxassetid://6034684937"
                }),
                Utility.new("TextLabel", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0.5, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 1, 0),
                    Size = UDim2.new(2, 0, 0.3, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "Safe House",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextScaled = true,
                    TextWrapped = true
                })
            });

            -- Power Station --
            PowerStation = Utility.new("BillboardGui", {
                Name = "BuildingESP",
                Enabled = false,
                Parent = Services.CoreGui,
                Adornee = Utility.new("Attachment", {WorldPosition = Vector3.new(-285, 40, -210), Parent = workspace.Terrain}),
                AlwaysOnTop = true,
                Size = UDim2.new(10, 10, 10, 10)
            }, {
                Utility.new("ImageLabel", {
                    Name = "Icon",
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Size = UDim2.new(0.75, 0, 0.75, 0),
                    Image = "rbxassetid://6034684937"
                }),
                Utility.new("TextLabel", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0.5, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 1, 0),
                    Size = UDim2.new(2, 0, 0.3, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "Power Station",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextScaled = true,
                    TextWrapped = true
                })
            });

           -- Shop --
            Shop = Utility.new("BillboardGui", {
                Name = "BuildingESP",
                Enabled = false,
                Parent = Services.CoreGui,
                Adornee = Utility.new("Attachment", {WorldPosition = Vector3.new(-25, 40, -265), Parent = workspace.Terrain}),
                AlwaysOnTop = true,
                Size = UDim2.new(10, 10, 10, 10)
            }, {
                Utility.new("ImageLabel", {
                    Name = "Icon",
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Size = UDim2.new(0.75, 0, 0.75, 0),
                    Image = "rbxassetid://6034684937"
                }),
                Utility.new("TextLabel", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0.5, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 1, 0),
                    Size = UDim2.new(2, 0, 0.3, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "Shop",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextScaled = true,
                    TextWrapped = true
                })
            });

            -- Observation Tower --
            ObservationTower = Utility.new("BillboardGui", {
                Name = "BuildingESP",
                Enabled = false,
                Parent = Services.CoreGui,
                Adornee = Utility.new("Attachment", {WorldPosition = Vector3.new(51.5, 75, -52.5), Parent = workspace.Terrain}),
                AlwaysOnTop = true,
                Size = UDim2.new(10, 10, 10, 10)
            }, {
                Utility.new("ImageLabel", {
                    Name = "Icon",
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Size = UDim2.new(0.75, 0, 0.75, 0),
                    Image = "rbxassetid://6034684937"
                }),
                Utility.new("TextLabel", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0.5, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 1, 0),
                    Size = UDim2.new(2, 0, 0.3, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "Observation Tower",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextScaled = true,
                    TextWrapped = true
                })
            });

            -- BaseCamp --
            BaseCamp = Utility.new("BillboardGui", {
                Name = "BuildingESP",
                Enabled = false,
                Parent = Services.CoreGui,
                Adornee = Utility.new("Attachment", {WorldPosition = Vector3.new(-40, 40, 200), Parent = workspace.Terrain}),
                AlwaysOnTop = true,
                Size = UDim2.new(10, 10, 10, 10)
            }, {
                Utility.new("ImageLabel", {
                    Name = "Icon",
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Size = UDim2.new(0.75, 0, 0.75, 0),
                    Image = "rbxassetid://6034684937"
                }),
                Utility.new("TextLabel", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0.5, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 1, 0),
                    Size = UDim2.new(2, 0, 0.3, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "Base Camp",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextScaled = true,
                    TextWrapped = true
                })
            });
        }
        local BuildingESP = Tab.Folder("Building ESP", "ESP to help you locate diffent buildings and structures.")
        BuildingESP.Switch("Power Station ESP", function(Status)
            BuildingBillboards.PowerStation.Enabled = Status
        end)
        BuildingESP.Switch("Shop Building ESP", function(Status)
            BuildingBillboards.Shop.Enabled = Status
        end)
        BuildingESP.Switch("Safe House ESP", function(Status)
            BuildingBillboards.SafeHouse.Enabled = Status
        end)
        BuildingESP.Switch("Observation Tower ESP", function(Status)
            BuildingBillboards.ObservationTower.Enabled = Status
        end)
        BuildingESP.Switch("Base Camp ESP", function(Status)
            BuildingBillboards.BaseCamp.Enabled = Status
        end)

        -- Miscellaneous ESP --
        local FlareBillboard = Utility.new("BillboardGui", {
            Name = "FlareESP",
            Enabled = false,
            Parent = Services.CoreGui,
            Adornee = Utility.new("Attachment", {WorldPosition = Vector3.new(0, 2500, 0), Parent = workspace.Terrain}),
            AlwaysOnTop = true,
            Size = UDim2.new(10, 10, 10, 10)
        }, {
            Utility.new("ImageLabel", {
                Name = "Icon",
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0.75, 0, 0.75, 0),
                Image = "rbxassetid://6035039430",
                ImageColor3 = Color3.fromRGB(255, 125, 0)
            }),
            Utility.new("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 1, 0),
                Size = UDim2.new(2, 0, 0.3, 0),
                Font = Enum.Font.GothamBold,
                Text = "Flare Gun",
                TextColor3 = Color3.fromRGB(255, 125, 0),
                TextScaled = true,
                TextWrapped = true
            })
        })

        local LootBillboard = Utility.new("BillboardGui", {
            Name = "LootCrateESP",
            Enabled = false,
            AlwaysOnTop = true,
            Size = UDim2.new(10, 10, 10, 10)
        }, {
            Utility.new("ImageLabel", {
                Name = "Icon",
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0.75, 0, 0.75, 0),
                Image = "rbxassetid://6035067831",
                ImageColor3 = Color3.fromRGB(0, 200, 255)
            }),
            Utility.new("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 1, 0),
                Size = UDim2.new(2, 0, 0.3, 0),
                Font = Enum.Font.GothamBold,
                Text = "Loot Crate",
                TextColor3 = Color3.fromRGB(0, 200, 255),
                TextScaled = true,
                TextWrapped = true
            })
        })
        local MiscESP = Tab.Folder("Miscellaneous ESP", "ESP for objects other than the Rake and Structures.")
        MiscESP.Switch("Flare Gun ESP", function(Status)
            FlareBillboard.Enabled = Status
            FlareBillboard.Adornee.WorldPosition = workspace.FlareGunPickUp.FlareGun.Position + Vector3.new(0, 20, 0)
        end)
        workspace.ChildAdded:Connect(function(Child)
            if Child.Name == "FlareGunPickUp" and Child:WaitForChild("FlareGun") then
                FlareBillboard.Adornee.WorldPosition = workspace.FlareGunPickUp.FlareGun.Position + Vector3.new(0, 20, 0)
            end
        end)
        local AllLootBillboards = {}
        local LootCrateConnection;
        MiscESP.Switch("Loot Crate ESP", function(Status)
            if Status == true then
                local function CreateBillboard(Item)
                    local NewBillboard = LootBillboard:Clone()
                    NewBillboard.Enabled = true
                    NewBillboard.Parent = Services.CoreGui
                    NewBillboard.Adornee = Utility.new("Attachment", {WorldPosition = Item.GUIPart + Vector3.new(0, 20, 0), Parent = workspace.Terrain})
                    table.insert(AllLootBillboards, NewBillboard)
                end

                for i,v in ipairs(workspace.SupplyCrates:GetChildren()) do
                    CreateBillboard(v)
                end
                LootCrateConnection = workspace.SupplyCrates.ChildAdded:Connect(function(Child)
                    if Child.Name == "Box" and Child:WaitForChild("GUIPart", 5) then
                        CreateBillboard(Child)
                    end
                end)
            else
                for i,v in ipairs(AllLootBillboards) do
                    v:Destroy()
                end
                AllLootBillboards = {}
                if LootCrateConnection then
                    LootCrateConnection:Disconnect()
                end
            end
        end)

        -- Mods --
        local Modifications = Tab.Folder("Modifications", "A collection of modifications to gameplay")
        local InfiniteStamina = nil
        Modifications.Switch("Infinite Stamina", function(Status)
            if Status then
                InfiniteStamina = LocalPlayer.Character.Stamina.Changed:Connect(function(Value)
                    LocalPlayer.Character.Stamina.Value = 100
                end)
            elseif InfiniteStamina then
                InfiniteStamina:Disconnect()
                InfiniteStamina = nil
            end
        end)
    end;

    -- Name --
    [1] = function(Window)
        local Tab = Window.Tab("Name", 6034509997)
        local Info = {}
    end;

    -- Name --
    [1] = function(Window)
        local Tab = Window.Tab("Name", 6034509997)
        local Info = {}
    end;

    -- Name --
    [1] = function(Window)
        local Tab = Window.Tab("Name", 6034509997)
        local Info = {}
    end;

    -- Name --
    [1] = function(Window)
        local Tab = Window.Tab("Name", 6034509997)
        local Info = {}
    end;

    -- Name --
    [1] = function(Window)
        local Tab = Window.Tab("Name", 6034509997)
        local Info = {}
    end;
}
