local Object = require 'Object'
local game = require 'game'

local Enemy = Object:new()

function Enemy:new(x, y)
    local e = Object:new('enemy', x, y, game.tileSize, game.tileSize)
    setmetatable(e, self)
    self.__index = self

    self.direction = 1
    self.speed = 30

    return e
end

function Enemy:update(dt)
    self:updateMovement(dt)

    self.velocity.x = self.direction * self.speed

    if self:isOnGround(self.filter) then
        _, _, wallCols = self:relativePositionCols(self.direction, 0)

        local x, y, w, h = game.world:getRect(self)
        local groundCols = game.world:queryPoint(
            x + w/2 + (w/2 * self.direction), y + h + 1, self.groundFilter
        )

        if #wallCols > 0 or #groundCols == 0 then
            self.direction = -self.direction
        end
    end
end

function Enemy.filter(item, other)
    if other.id == 'water' then return false else return 'slide' end
end

function Enemy.groundFilter(item)
    if item.id == 'water' then return false else return 'slide' end
end

return Enemy