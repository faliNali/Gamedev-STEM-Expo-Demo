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

    p.touchedFlag = false
    p.justTouchedFlag = false

    p.jumpParticles = ParticleEffect:new(game.sprites.particle, 120, 2, true)
    p.deathParticles = ParticleEffect:new(game.sprites.particle, 200, 2, true)
    
    return p
end

function Player:update(dt)
    self.jumpParticles:update(dt)
    self.deathParticles:update(dt)

    local actualX, actualY, cols = self:updateMovement(
        dt,
        not self.alive and function(item, other) return false end or nil
    )
    
    if self.alive then
        if love.keyboard.isDown('d') then
            self.velocity.x = self.speed
        elseif love.keyboard.isDown('a') then
            self.velocity.x = -self.speed
        else
            self.velocity.x = 0
        end

        for i, col in ipairs(cols) do
            if col.other.id == 'water' or col.other.id == 'enemy' then self:die()
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
end

function Player.filter(item, other)
    if other.id == 'flag' then return 'cross'
    else return 'slide' end
end

function Player:keypressed(key)
    if self.alive then
        if (key == 'w' or key == 'space') and self:isOnGround() then
            self.velocity.y = self.jumpVelocity

            local x, y, w, h = game.world:getRect(self)
            self.jumpParticles:spawnParticles(x + w/2, y + h, 3)
        end
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

function Player:isReadyForGameRestart()
    return not self.deathParticles:hasParticles() and not self.exists
end

function Player:justWonGame() return self.justTouchedFlag end

return Player