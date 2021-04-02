local Services = setmetatable({}, {__index = function(Self, Index)
    local NewService = game.GetService(game, Index) or game.FindFirstChild(game, Index, true)
    if NewService then
        Self[Index] = NewService
    end
    return NewService
end})

return Services
