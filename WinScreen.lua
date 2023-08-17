local game = require "game"
local WinScreen = {}

function WinScreen:new()
    local ws = {}
    setmetatable(ws, self)
    self.__index = self

    ws.startY = -100
    ws.targetY = game.getHeight()/2
    ws.y = ws.startY
    ws.height = 150
    ws.velocity = 0
    ws.gravity = 25
    ws.show = false
    ws.stopped = false

    return ws
end

function WinScreen:update(dt)
    if self.show or self.stopped then
        self.velocity = self.velocity + self.gravity * dt
        self.y = self.y + self.velocity

        if self.y >= self.targetY then
            self.velocity = -math.abs(self.velocity) * 40 * dt
            if math.abs(self.velocity) <= 10 then
                self.y = self.targetY
                self.stopped = true
            end
        end
    end
end

function WinScreen:start()
    self.show = true
end

function WinScreen:finish()
    self.show = false
    self.stopped = false
    self.y = self.startY
end

function WinScreen:draw()
    if self.show then
        love.graphics.setColor(0, 0, 0, 0.9)
        love.graphics.rectangle(
            'fill', 0, self.y - self.height/2, game.getWidth(), self.height
        )
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            "Game Finished!\nJOIN GAMEDEV CLUB!! :DD\nPress R to Restart",
            0, self.y - 50, game.getWidth(), "center"
        )
    end
end

return WinScreen

