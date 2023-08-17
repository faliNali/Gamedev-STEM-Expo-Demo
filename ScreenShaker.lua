local ScreenShaker = {}

function ScreenShaker:new()
    local ss = {}
    setmetatable(ss, self)
    self.__index = self

    ss.origin = {x=0, y=0}
    ss.intensity = 0
    ss.intensityDecrease = 0

    return ss
end

function ScreenShaker:shake(intensity, intensityDecrease)
    self.intensity = intensity
    self.intensityDecrease = intensityDecrease
end

function ScreenShaker:update(dt)
    if self.intensity > 0 then
        self.intensity = self.intensity - self.intensityDecrease * dt
    else
        self.intensity = 0
    end

    self.origin.x = (math.random() - 0.5) * self.intensity
    self.origin.y = (math.random() - 0.5) * self.intensity
end

function ScreenShaker:translate()
    love.graphics.origin()
    love.graphics.translate(math.floor(self.origin.x), math.floor(self.origin.y))
end

return ScreenShaker