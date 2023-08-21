local Object = require 'Object'
local ParticleEffect = require 'ParticleEffect'
local game = require 'game'

local Player = Object:new()

function Player:new(x, y)
    local p = Object:new('player', x, y, game.tileSize * 3/4, game.tileSize)
    setmetatable(p, self)
    self.__index = self
    
    p.alive = true
    p.exists = true

    p.speed = 150
    
    p.jumpVelocity = -225
    p.justJumped = false
    p.wasTouchingGround = false

    p.touchedFlag = false
    p.justTouchedFlag = false

    p.jumpParticles = ParticleEffect:new(game.sprites.particle, 120, 2, true)
    p.deathParticles = ParticleEffect:new(game.sprites.particle, 200, 2, true)
    
    return p
end

function Player:update(dt)
    self.jumpParticles:update(dt)
    self.deathParticles:update(dt)

    self:updateHalfGravity(dt)
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
            if col.other.id == 'water' then self:die()
            elseif col.other.id == 'flag' then self:win() end
        end
    elseif self.exists then
        if self.velocity.y < 0 then
            self.useGravity = true
        else
            self.exists = false
            self.useGravity = false
            self.velocity.y = 0

            game.screenShaker:shake(25, 80)
            
            local _, _, w, h = game.world:getRect(self)
            self.deathParticles:spawnParticles(
                self.position.x + w/2, self.position.y + h/2, 10
            )
        end
    end

    self:updateHalfGravity(dt)
end

function Player.filter(item, other)
    if other.id == 'flag' then return 'cross'
    else return 'slide' end
end

function Player:keypressed(key)
    if (key == 'w' or key == 'space') and self:isOnGround() and self.alive then
        self.velocity.y = self.jumpVelocity
        self.justJumped = true

        local x, y, w, h = game.world:getRect(self)
        self.jumpParticles:spawnParticles(x + w/2, y + h, 3)
    end
end

function Player:draw()
    self.jumpParticles:draw()
    self.deathParticles:draw()
    if self.exists then
        local x, y, w, h = game.world:getRect(self)
        love.graphics.rectangle('fill', x, y, w, h)
    end
end

function Player:die()
    self.alive = false
    self.velocity.x = 0
    self.velocity.y = self.jumpVelocity
    game.screenShaker:shake(5, 60)
end

function Player:win()
    self.justTouchedFlag = not self.touchedFlag
    self.touchedFlag = true
end

function Player:relativePositionCols(relativeX, relativeY)
    return game.world:check(
        self, self.position.x+relativeX, self.position.y+relativeY, Player.filter
    )
end

function Player:relativePositionForID(relativeX, relativeY, id)
    local _, _, cols = self:relativePositionCols(relativeX, relativeY)

    for i, col in ipairs(cols) do
        if col.other.id == id then return true end
    end
    return false
end

function Player:isOnGround()
    return self:relativePositionForID(0, 2, 'ground')
end

function Player:isTouchingCeiling()
    return self:relativePositionForID(0, -1, 'ground')
end

function Player:isReadyForGameRestart()
    return not self.deathParticles:hasParticles() and not self.exists
end

function Player:justWonGame() return self.justTouchedFlag end

return Player