local Object = require 'Object'
local game = require 'game'

local Enemy = Object:new()

function Enemy:new(x, y)
    local e = Object:new('enemy', x, y, game.tileSize, game.tileSize)
    setmetatable(e, self)
    self.__index = self

    return e
end

return Enemy