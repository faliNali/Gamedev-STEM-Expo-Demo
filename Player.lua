local Object = require 'Object'
local game = require 'game'

local Player = Object:new()

function Player:new(x, y)
    local p = Object:new('player', x, y, game.tileSize * 1/2, game.tileSize)
    setmetatable(p, self)
    self.__index = self
    
    p.alive = true
    p.exists = true

    local gameValues = require 'interactiveGameValues'
    p.speed = gameValues.playerSpeed or gameValues.defaults.playerSpeed
    
    p.jumpVelocity = -gameValues.playerJump or -gameValues.defaults.playerJump
    p.gravity = p.gravity * gameValues.playerJump / gameValues.defaults.playerJump

    p.touchedFlag = false
    p.justTouchedFlag = false

    local ParticleEffect = require 'ParticleEffect'
    p.jumpParticles = ParticleEffect:new(game.sprites.particle, 60, 2, true)
    p.deathParticles = ParticleEffect:new(game.sprites.particle, 200, 2, true)

    p.anim = game.anims.player.idle
    
    return p
end

function Player:update(dt)
    self.jumpParticles:update(dt)
    self.deathParticles:update(dt)
    self.anim:update(dt)

    local _, _, cols = self:updateMovement(
        dt,
        not self.alive and function(item, other) return false end or nil
    )

    if self.anim == game.anims.player.walk then
        game.sounds.playerWalk:play()
    end
    
    if self.alive then
        self.anim = game.anims.player.walk
        if love.keyboard.isDown('d') then
            self.velocity.x = self.speed
            self.scale.x = 1
        elseif love.keyboard.isDown('a') then
            self.velocity.x = -self.speed
            self.scale.x = -1
        else
            self.velocity.x = 0
            self.anim = game.anims.player.idle
        end

        if #self:checkBelow('ground') == 0 then
            if self.velocity.y < 60 then self.anim = game.anims.player.jumpUp
            else self.anim = game.anims.player.jumpDown end
        end

        local deadEnemyCols = self:checkBelow('enemy')
        for i, enemyCol in ipairs(deadEnemyCols) do
            enemyCol.other:die()
            self.velocity.y = self.jumpVelocity * 3/4
        end

        for i, col in ipairs(cols) do
            if col.other.id == 'water' then self:die()
            elseif col.other.id == 'flag'then
                self:win()
                col.other:winEffect()
            end
        end
    elseif self.exists then
        if self.velocity.y < 100 then
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

            game.sounds.playerExplode:play()
        end
    end
end

function Player.filter(item, other)
    if other.id == 'flag' then return 'cross'
    else return 'slide' end
end

function Player:keypressed(key)
    if self.alive then
        if (key=='w' or key=='space') and #self:checkBelow('ground') > 0 then
            self.velocity.y = self.jumpVelocity

            local x, y, w, h = game.world:getRect(self)
            self.jumpParticles:spawnParticles(x + w/2, y + h, 3)

            game.sounds.playerJump:play()
        end
    end
end

function Player:draw()
    self.jumpParticles:draw()
    self.deathParticles:draw()
    if self.exists then
        local x, y, w, h = game.world:getRect(self)
        --[[ love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle('fill', x, y, w, h)
        love.graphics.setColor(1, 1, 1) ]]
        self.anim:draw(
            game.sprites.player,
            x + w/2,
            y,
            0,
            self.scale.x,
            self.scale.y,
            game.tileSize/2
        )
    end
end

function Player:die()
    self.anim = game.anims.player.dead
    self.alive = false
    self.velocity.x = 0
    self.velocity.y = self.jumpVelocity
    game.screenShaker:shake(5, 60)

    game.sounds.playerDefeat:play()
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