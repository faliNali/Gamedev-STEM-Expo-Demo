local game = require 'game'
local RestartScreen = {}

local states = {
    clear = 1,
    covering = 2,
    covered = 3,
    clearing = 4
}

function RestartScreen:new()
    local rs = {}
    setmetatable(rs, self)
    self.__index = self

    self.extraCoverWidth = -500
    self.leftX = self.extraCoverWidth
    self.rightX = 0
    self.state = states.clear
    self.speed = 2000

    return self
end

function RestartScreen:update(dt)
    if self.state == states.covering then
        if self.rightX < game.getWidth() then
            self.rightX = self.rightX + self.speed * dt
        else
            self.state = states.covered
        end
    elseif self.state == states.clearing then
        if self.leftX < game.getWidth() then
            self.leftX = self.leftX + self.speed * dt
        else
            self.state = states.clear
            self.leftX, self.rightX = self.extraCoverWidth, 0
        end
    end
end

function RestartScreen:start()
    if self.state == states.clear then self.state = states.covering end
end

function RestartScreen:finish()
    if self.state == states.covered then self.state = states.clearing end
end

function RestartScreen:isCovered()
    return self.state == states.covered
end

function RestartScreen:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle(
        'fill', self.leftX, 0,
        self.rightX - self.leftX, game.getHeight()
    )
    love.graphics.setColor(1, 1, 1)
end

return RestartScreen