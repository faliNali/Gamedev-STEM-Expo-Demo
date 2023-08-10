local sprites = {}
local quads = {}

local world
local tiles

local function getMapLayer(map, layerName)
    for i, layer in ipairs(map.layers) do
        if layer.name == layerName then
            return layer
        end
    end
end

function love.load()

    sprites.tile = love.graphics.newImage("maps/tileset1.png")
    quads.ground = love.graphics.newQuad(0, 0, 40, 40, sprites.tile)
    quads.water = love.graphics.newQuad(40, 0, 40, 40, sprites.tile)
    
    local bump = require "lib/bump"
    local map = require "maps/level1"

    world = bump.newWorld(80)
    
    local tileLayer = getMapLayer(map, "Tiles")
    tiles = {}
    for i, tileData in ipairs(tileLayer.data) do
        if tileData == 1 or tileData == 2 then
            local tile = {}
            tile.type = tileData == 1 and 'ground' or tileData == 2 and 'water'
            tile.x = ((i-1) % tileLayer.width)*40
            tile.y = math.floor((i-1) / tileLayer.width)*40

            table.insert(tiles, tile)
            world:add(tile, tile.x, tile.y, 40, 40)
        end
    end
end

function love.update(dt)

end

function love.keypressed(key)
    if key == 'q' or key == 'escape' then
        love.event.quit()
    end
end

function love.draw()
    for i, tile in ipairs(tiles) do
        local x, y, w, h = world:getRect(tile)
        love.graphics.rectangle('line', x, y, w, h)
        if tile.type == 'ground' then
            love.graphics.draw(sprites.tile, quads.ground, x, y)
        elseif tile.type == 'water' then
            love.graphics.draw(sprites.tile, quads.water, x, y)
        end
    end 
end

Player = {}
Player.__index = Player

function Player:new(world, x, y)
    local p = {}
    setmetatable(p, self)

    p.x, p.y = x, y
    world:add(p, x, y, 40, 40)
    
    return p
end

function Player:update(dt)

end

function Player:draw()

end