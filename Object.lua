local game = require 'game'

local Object = {}

function Object:new(id, x, y, w, h)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.id = id or 'object'
    obj.position = {x=x or 0, y=y or 0}
    obj.velocity = {x=0, y=0}

    obj.gravity = 600
    obj.useGravity = true

    game.world:add(
        obj, obj.position.x, obj.position.y,
        w or game.tileSize, h or game.tileSize
    )

    return obj
end

function Object:updateMovement(dt, filter)
    filter = filter or self.filter
    if self.useGravity then
        self.velocity.y = self.velocity.y + self.gravity * dt * 0.5
    end

    local goalX, goalY = self.position.x, self.position.y
    if dt < 1/10 then
        goalX = goalX + self.velocity.x * dt
        goalY = goalY + self.velocity.y * dt
    end
    local actualX, actualY, cols, len = game.world:move(
        self, goalX, goalY, filter
    )
    self.position.x = actualX or self.position.x
    self.position.y = actualY or self.position.y
    if self.useGravity then
        if self:isTouchingCeiling(filter) then
            self.velocity.y = self.gravity * dt
        elseif self:isOnGround(filter) then
            self.velocity.y = 0
        end
        
        self.velocity.y = self.velocity.y + self.gravity * dt * 0.5
    end

    return actualX, actualY, cols, len
end

function Object:draw()
    local x, y, w, h = game.world:getRect(self)
    love.graphics.rectangle('fill', x, y, w, h)
end

function Object:relativePositionCols(relativeX, relativeY, filter)
    return game.world:check(
        self,
        self.position.x+relativeX,
        self.position.y+relativeY,
        filter or self.filter
    )
end

function Object:relativePositionForID(relativeX, relativeY, id, filter)
    local _, _, cols = self:relativePositionCols(relativeX, relativeY, filter)

    for i, col in ipairs(cols) do
        if col.other.id == id then return true end
    end
    return false
end

function Object:isOnGround(filter)
    return self:relativePositionForID(0, 2, 'ground', filter)
end

function Object:isTouchingCeiling(filter)
    return self:relativePositionForID(0, -1, 'ground', filter)
end

return Object