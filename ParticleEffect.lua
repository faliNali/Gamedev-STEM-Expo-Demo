local ParticleEffect = {}

function ParticleEffect:new(particleSpeed, alphaSpeed)
    local pe = {}
    setmetatable(pe, self)
    self.__index = self

    pe.particles = {}
    pe.particleSpeed = particleSpeed
    pe.alphaSpeed = alphaSpeed

    return pe
end

function ParticleEffect:start(x, y)
    if self.started == false then
        self.started = true
        self:updatePosition(x, y)
    end
end

function ParticleEffect:update(dt)
    for i, particle in ipairs(self.particles) do
        particle.position.x = particle.position.x + particle.velocity.x * dt
        particle.position.y = particle.position.y + particle.velocity.y * dt

        particle.alpha = particle.alpha - self.alphaSpeed * dt
        if particle.alpha <= 0 then table.remove(self.particles, i) end
    end
end

function ParticleEffect:updatePosition(x, y) self.position = {x=x, y=y} end

function ParticleEffect:spawnParticle(x, y)
    local p = {}
    p.position = {x=x, y=y}
    p.angle = math.random() * math.pi*2

    table.insert(self.particles, p)
end

function ParticleEffect:spawnAllParticles(numOfParticles)
    for i=0, numOfParticles do
        self:spawnParticle()
    end
end

function ParticleEffect:draw()
    love.graphics.setColor(1, 1, 1, self.alpha)
    for i, particle in ipairs(self.particles) do
        love.graphics.circle(
            'fill',
            particle.position.x + self.position.x,
            particle.position.y + self.position.y,
            3
        )
    end
    love.graphics.setColor(1, 1, 1)
end

return ParticleEffect