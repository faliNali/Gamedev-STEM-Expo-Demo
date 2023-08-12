local Object = require 'Object'
local game = require 'game'

local Player = Object:new()

function Player:new(x, y)
    local p = Object:new('player', x, y, game.tileSize * 3/4, game.tileSize)
    setmetatable(p, self)
    self.__index = self
    
    p.speed = 300
    p.gravity = 20
    p.jumpVelocity = -450
    p.justJumped = false
    
    return p
end

function Player:update(dt)
    print(self.velocity.y)
    if love.keyboard.isDown('d') then
        self.velocity.x = self.speed
    elseif love.keyboard.isDown('a') then
        self.velocity.x = -self.speed
    else
        self.velocity.x = 0
    end

    if self:isTouchingCeiling() then
        self.velocity.y = self.gravity
    elseif self:isOnGround() then
        if self.justJumped then
            self.justJumped = false
        else
            self.velocity.y = 0
        end
    else
        self.velocity.y = self.velocity.y + self.gravity
    end

    local goalX = self.position.x + self.velocity.x * dt
    local goalY = self.position.y + self.velocity.y * dt
    local actualX, actualY, cols = game.world:move(self, goalX, goalY, self.filter)
    
    self.position.x = actualX or self.position.x
    self.position.y = actualY or self.position.y

    for col in ipairs(cols) do
        if col.other.id == 'water' then

        end
    end
end

function Player.filter(item, other)
    if other.id == 'ground' then return 'slide'
    else return false end
end

function Player:relativePositionCols(relativeX, relativeY)
    return game.world:check(
        self, self.position.x+relativeX, self.position.y+relativeY, Player.filter
    )
end

function Player:relativePositionForID(relativeX, relativeY, id)
    local actualX, actualY, cols = self:relativePositionCols(relativeX, relativeY)

    for i, col in ipairs(cols) do
        if col.other.id == id then return true end
    end
    return false
end

function Player:isOnGround()
    return self:relativePositionForID(0, 1, 'ground')
end

function Player:isTouchingCeiling()
    return self:relativePositionForID(0, -1, 'ground')
end

function Player:keypressed(key)
    if (key == 'w' or key == 'space') and self:isOnGround() then
        self.velocity.y = self.jumpVelocity
        self.justJumped = true
        print("yay")
    end
end

function Player:draw()
    local x, y, w, h = game.world:getRect(self)
    love.graphics.rectangle('fill', x, y, w, h)
end

return Player