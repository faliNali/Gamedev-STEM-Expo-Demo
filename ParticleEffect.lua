local ParticleEffect = {}

function ParticleEffect:new(image, particleSpeed, alphaSpeed, isParticleSpeedRandom)
    local pe = {}
    setmetatable(pe, self)
    self.__index = self

    pe.image = image
    pe.particles = {}
    pe.particleSpeed = particleSpeed
    pe.isParticleSpeedRandom = isParticleSpeedRandom or false
    pe.alphaSpeed = alphaSpeed

    return pe
end

function ParticleEffect:spawnParticle(x, y)
    local p = {}
    p.position = {x=x, y=y}
    p.angle = math.random() * math.pi*2
    p.alpha = 1

    table.insert(self.particles, p)
end

function ParticleEffect:spawnParticles(x, y, numOfParticles)
    for i=1, numOfParticles do
        self:spawnParticle(x, y)
    end
end

function ParticleEffect:update(dt)
    for i, particle in ipairs(self.particles) do
        local velocity = {
            x = math.cos(particle.angle) * self.particleSpeed,
            y = math.sin(particle.angle) * self.particleSpeed
        }
        if self.isParticleSpeedRandom then
            velocity.x = velocity.x * math.random()
            velocity.y = velocity.y * math.random()
        end
        particle.position.x = particle.position.x + velocity.x * dt
        particle.position.y = particle.position.y + velocity.y * dt

        particle.alpha = particle.alpha - self.alphaSpeed * dt
        if particle.alpha <= 0 then table.remove(self.particles, i) end
    end
end

function ParticleEffect:draw()
    local offsetX, offsetY = self.image:getWidth()/2, self.image:getHeight()/2
    for i, particle in ipairs(self.particles) do
        love.graphics.setColor(1, 1, 1, particle.alpha)
        love.graphics.draw(
            self.image,
            particle.position.x - offsetX,
            particle.position.y - offsetY
        )
    end
    love.graphics.setColor(1, 1, 1)
end

function ParticleEffect:hasParticles() return #self.particles > 0 end

return ParticleEffect