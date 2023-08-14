local Object = require 'Object'
local game = require 'game'

local Player = Object:new()

function Player:new(x, y)
    local p = Object:new('player', x, y, game.tileSize * 3/4, game.tileSize)
    setmetatable(p, self)
    self.__index = self
    
    p.alive = true
    p.speed = 300
    p.gravity = 1200
    p.useGravity = true
    p.jumpVelocity = -450
    p.justJumped = false
    p.wasTouchingGround = false
    
    return p
end

function Player:update(dt)
    local function gravityUpdate()
        if self.useGravity then
            -- gravity is halved because it's called twice
            --  once before movement and once after movement
            self.velocity.y = self.velocity.y + self.gravity * dt * 0.5
        end
    end

    gravityUpdate()
    local actualX, actualY, cols = self:updateMovement(
        dt,
        self.alive and self.filter or function(item, other) return false end
    )
    
    self.position.x = actualX or self.position.x
    self.position.y = actualY or self.position.y
    
    if self.alive then
        if love.keyboard.isDown('d') then
            self.velocity.x = self.speed
        elseif love.keyboard.isDown('a') then
            self.velocity.x = -self.speed
        else
            self.velocity.x = 0
        end

        if self:isTouchingCeiling() then
            self.velocity.y = self.gravity * dt
        elseif self:isOnGround() then
            if self.justJumped then self.justJumped = false end
            self.wasTouchingGround = true
        elseif self.wasTouchingGround and not self.justJumped then
            self.wasTouchingGround = false
            self.velocity.y = 0
        end

        for i, col in ipairs(cols) do
            if col.other.id == 'water' then self:die() end
        end
    else
        if self.velocity.y < 0 then
            self.useGravity = true
        else
            self.useGravity = false
            self.velocity.y = 0
        end
    end

    gravityUpdate()
end

function Player.filter(item, other)
    if other.id == 'ground' then return 'slide'
    else return 'slide' end
end

function Player:die()
    self.alive = false
    self.velocity.x = 0
    self.velocity.y = self.jumpVelocity
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
    return self:relativePositionForID(0, 5, 'ground')
end

function Player:isTouchingCeiling()
    return self:relativePositionForID(0, -1, 'ground')
end

function Player:keypressed(key)
    if (key == 'w' or key == 'space') and self:isOnGround() and self.alive then
        self.velocity.y = self.jumpVelocity
        self.justJumped = true
    end
end

function Player:draw()
    local x, y, w, h = game.world:getRect(self)
    love.graphics.rectangle('fill', x, y, w, h)
end

return Player