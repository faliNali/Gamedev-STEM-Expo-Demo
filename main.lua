local sprites = {}
local quads = {}

local world
local tiles
local player

local tileSize

local function getMapLayer(map, layerName)
    for i, layer in ipairs(map.layers) do
        if layer.name == layerName then
            return layer
        end
    end
end

function love.load()
    local bump = require "lib/bump"
    local map = require "maps/level1"
    tileSize = map.tilewidth

    sprites.tile = love.graphics.newImage("maps/tileset1.png")
    quads.ground = love.graphics.newQuad(0, 0, tileSize,  tileSize, sprites.tile)
    quads.water = love.graphics.newQuad(tileSize, 0, tileSize, tileSize, sprites.tile)

    world = bump.newWorld(80)
    
    local tileLayer = getMapLayer(map, "Tiles")
    tiles = {}
    for i, tileData in ipairs(tileLayer.data) do
        local tileX = ((i-1) % tileLayer.width)*tileSize
        local tileY = math.floor((i-1) / tileLayer.width)*tileSize
        if tileData == 1 or tileData == 2 then
            local tile = {}
            tile.id = tileData == 1 and 'ground' or tileData == 2 and 'water'
            tile.x, tile.y = tileX, tileY

            table.insert(tiles, tile)
            world:add(tile, tile.x, tile.y, tileSize, tileSize)
        elseif tileData == 6 then
            player = Player:new(tileX, tileY)
        end
    end
end

function love.update(dt)
    player:update(dt)
end

function love.keypressed(key)
    if key == 'q' or key == 'escape' then
        love.event.quit()
    end
    player:keypressed(key)
end

function love.draw()
    for i, tile in ipairs(tiles) do
        local x, y, w, h = world:getRect(tile)
        love.graphics.rectangle('line', x, y, w, h)
        if tile.id == 'ground' then
            love.graphics.draw(sprites.tile, quads.ground, x, y)
        elseif tile.id == 'water' then
            love.graphics.draw(sprites.tile, quads.water, x, y)
        end
    end

    player:draw()
end

Player = {}
Player.__index = Player

function Player:new(x, y)
    local p = {}
    setmetatable(p, self)

    p.id = 'player'
    p.speed = 300
    p.gravity = 20
    p.jumpVelocity = -450
    p.justJumped = false

    p.position = {x=x, y=y}
    p.velocity = {x=0, y=0}

    world:add(p, x, y, tileSize * 3/4, tileSize)
    
    return p
end

function Player:update(dt)
    print(self.velocity.y)
    if love.keyboard.isDown('d') then
        self.velocity.x = self.speed
    elseif love.keyboard.isDown('a') then
        self.velocity.x = -self.speed
    else
        self.velocity.x = 0
    end

    if self:isTouchingCeiling() then
        self.velocity.y = self.gravity
    elseif self:isOnGround() then
        if self.justJumped then
            self.justJumped = false
        else
            self.velocity.y = 0
        end
    else
        self.velocity.y = self.velocity.y + self.gravity
    end

    local goalX = self.position.x + self.velocity.x * dt
    local goalY = self.position.y + self.velocity.y * dt
    local actualX, actualY, cols = world:move(self, goalX, goalY, self.filter)
    
    self.position.x = actualX or self.position.x
    self.position.y = actualY or self.position.y
end

function Player.filter(item, other)
    if other.id == 'ground' then return 'slide'
    else return false end
end

function Player:checkRelativePositionCols(relativeX, relativeY)
    return world:check(
        self, self.position.x+relativeX, self.position.y+relativeY, Player.filter
    )
end

function Player:checkRelativePositionForID(relativeX, relativeY, id)
    local actualX, actualY, cols = self:checkRelativePositionCols(relativeX, relativeY)

    for i, col in ipairs(cols) do
        if col.other.id == id then return true end
    end
    return false
end

function Player:isOnGround()
    return self:checkRelativePositionForID(0, 1, 'ground')
end

function Player:isTouchingCeiling()
    return self:checkRelativePositionForID(0, -1, 'ground')
end

function Player:keypressed(key)
    if (key == 'w' or key == 'space') and self:isOnGround() then
        self.velocity.y = self.jumpVelocity
        self.justJumped = true
        print("yay")
    end
end

function Player:draw()
    local x, y, w, h = world:getRect(self)
    love.graphics.rectangle('fill', x, y, w, h)
end