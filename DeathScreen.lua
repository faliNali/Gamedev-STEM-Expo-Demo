local DeathScreen = {}

local states = {
    clear = 1,
    covering = 2,
    covered = 3,
    clearing = 4
}

function DeathScreen:new()
    local ds = {}
    setmetatable(ds, self)
    self.__index = self

    self.extraCoverWidth = -1000
    self.leftX = self.extraCoverWidth
    self.rightX = 0
    self.state = states.clear
    self.speed = 4000

    return self
end

function DeathScreen:update(dt)
    if self.state == states.covering then
        if self.rightX < love.graphics.getWidth() then
            self.rightX = self.rightX + self.speed * dt
        else
            self.state = states.covered
        end
    elseif self.state == states.clearing then
        if self.leftX < love.graphics.getWidth() then
            self.leftX = self.leftX + self.speed * dt
        else
            self.state = states.clear
            self.leftX, self.rightX = self.extraCoverWidth, 0
        end
    end
end

function DeathScreen:start()
    if self.state == states.clear then self.state = states.covering end
end

function DeathScreen:finish()
    if self.state == states.covered then self.state = states.clearing end
end

function DeathScreen:isCovered()
    return self.state == states.covered
end

function DeathScreen:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle(
        'fill', self.leftX, 0,
        self.rightX - self.leftX, love.graphics.getHeight()
    )
    love.graphics.setColor(1, 1, 1)
end

return DeathScreen