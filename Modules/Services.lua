local Services = getgenv().Services or setmetatable({}, {__index = function(Self, Index)
    local NewService = game:GetService(Index) or game:FindFirstChild(Index)
    if NewService then
        Self[Index] = NewService
    end
    return NewService
end})

getgenv().Services = Services
return Services
