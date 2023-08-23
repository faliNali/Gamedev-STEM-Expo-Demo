local Object = require 'Object'
local ParticleEffect = require 'ParticleEffect'
local game = require 'game'

local Flag = Object:new()

function Flag:new(x, y)
    local f = Object:new('flag', x, y)
    setmetatable(f, self)
    self.__index = self
    self.anim = game.anims.flag
    self.justGotTouched = false
    self.particles = ParticleEffect:new(game.sprites.particle, 120, 2)
    self.flagParticles = ParticleEffect:new(game.sprites.flagParticle, 5, 1.5)

    self.flagParticleTime = 0.35
    self.flagParticleTimer = self.flagParticleTime

    return f
end

function Flag:update(dt)
    self.anim:update(dt)
    self.flagParticles:update(dt)
    self.particles:update(dt)

    self.flagParticleTimer = self.flagParticleTimer - dt
    if self.flagParticleTimer <= 0 then
        self.flagParticleTimer = self.flagParticleTimer + self.flagParticleTime
        local x, y, w, h = game.world:getRect(self)
        self.flagParticles:spawnParticle(x + w/2, y + h/2)
    end
end

function Flag:draw()
    self.particles:draw()
    self.flagParticles:draw()
    self.anim:draw(game.sprites.flag, self.position.x, self.position.y)
end

function Flag:winEffect()
    if not self.justGotTouched then
        local x, y, w, h = game.world:getRect(self)
        self.particles:spawnParticles(x + w/2, y + h/2, 10)
        game.sounds.winTheme:play()
        game.sounds.winSound:play()
    end
    self.justGotTouched = true
end

return Flag