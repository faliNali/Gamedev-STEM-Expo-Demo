local Object = require 'Object'
local game = require 'game'

local Enemy = Object:new()
Enemy.anim = game.anims.enemy

function Enemy:new(x, y)
    local e = Object:new(
        'enemy', x, y + game.tileSize * 1/4, game.tileSize, game.tileSize * 3/4
    )
    setmetatable(e, self)
    self.__index = self

    self.direction = 1
    self.speed = 30

    return e
end

local function mergeTables(table1, table2)
    local newTable = {}
    for i, v in ipairs(table1) do table.insert(newTable, v) end
    for i, v in ipairs(table2) do table.insert(newTable, v) end
    return newTable
end

function Enemy:update(dt)
    self:updateMovement(dt)

    local _, _, forwardCols = self:checkRelativePosition(self.direction, 0)
    local _, _, backwardCols = self:checkRelativePosition(-self.direction, 0)

    local sideCols = mergeTables(forwardCols, backwardCols)
    for i, col in ipairs(sideCols) do 
        if col.other.id == 'player' then col.other:die() end
    end

    self.velocity.x = self.direction * self.speed

    if #self:checkBelow('ground') > 0 then
        local x, y, w, h = game.world:getRect(self)
        local groundCols = game.world:queryPoint(
            x + w/2 + (w/2 * self.direction), y + h + 1, self.groundFilter
        )

        if #forwardCols > 0 or #groundCols == 0 then
            self.direction = -self.direction
        end
    end
end

function Enemy:die()
    self.id = 'deadEnemy'
end

function Enemy.filter(item, other)
    if other.id == 'water' then return false else return 'slide' end
end

function Enemy.groundFilter(item)
    if item.id == 'water' then return false else return 'slide' end
end

function Enemy:draw()
    local x, y, w, h = game.world:getRect(self)
    --[[ love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle('fill', x, y, w, h)
    love.graphics.setColor(1, 1, 1)  ]]

    self.anim:draw(
        game.sprites.enemy,
        x+w/2,
        y,
        0,
        -self.direction,
        1,
        game.tileSize/2,
        game.tileSize - h
    )
end

return Enemy