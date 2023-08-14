local game = require 'game'

local Object = {}

function Object:new(id, x, y, w, h)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.id = id or 'object'
    obj.position = {x=x or 0, y=y or 0}
    obj.velocity = {x=0, y=0}
    game.world:add(
        obj, obj.position.x, obj.position.y,
        w or game.tileSize, h or game.tileSize
    )

    return obj
end

function Object:updateMovement(dt, filter)
    local goalX = self.position.x + self.velocity.x * dt
    local goalY = self.position.y + self.velocity.y * dt
    local actualX, actualY, cols, len = game.world:move(
        self, goalX, goalY, filter
    )
    self.position.x = actualX or self.position.x
    self.position.y = actualY or self.position.y

    return actualX, actualY, cols, len
end

function Object:draw()
    local x, y, w, h = game.world:getRect(self)
    love.graphics.rectangle('fill', x, y, w, h)
end

return Object