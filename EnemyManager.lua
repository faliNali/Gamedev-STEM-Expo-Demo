local game = require 'game'
local ParticleEffect = require 'ParticleEffect'
local Enemy = require 'Enemy'

local EnemyManager = {}

function EnemyManager:new()
    local em = {}
    setmetatable(em, self)
    self.__index = self

    em.enemies = {}
    em.particles = ParticleEffect:new(game.sprites.particle, 120, 2, true)

    return em
end

function EnemyManager:update(dt)
    self.particles:update(dt)

    for i, enemy in ipairs(self.enemies) do
        if enemy.id == 'deadEnemy' then
            self:killEnemy(i)
        else
            enemy:update(dt)
        end
    end
end

function EnemyManager:draw()
    self.particles:draw()
    for i, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
end

function EnemyManager:newEnemy(x, y)
    local enemy = Enemy:new(x, y)
    table.insert(self.enemies, enemy)
end

function EnemyManager:removeEnemy(index)
    game.world:remove(self.enemies[index])
    table.remove(self.enemies, index)
end

function EnemyManager:killEnemy(index)
    local x, y, w, h = game.world:getRect(self.enemies[index])
    self.particles:spawnParticles(x + w/2, y+h/2, 4)

    game.screenShaker:shake(15, 80)
    self:removeEnemy(index)
end

function EnemyManager:clearEnemies()
    self.enemies = {}
end

return EnemyManager