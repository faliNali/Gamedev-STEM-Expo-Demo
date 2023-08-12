local game
local tiles
local player

local function getMapLayer(map, layerName)
    for i, layer in ipairs(map.layers) do
        if layer.name == layerName then
            return layer
        end
    end
end

function love.load()
    game = require "game"

    local map = require "maps/level1"
    local Player = require 'Player'
    
    local tileLayer = getMapLayer(map, "Tiles")
    tiles = {}
    for i, tileData in ipairs(tileLayer.data) do
        local tileX = ((i-1) % tileLayer.width)*game.tileSize
        local tileY = math.floor((i-1) / tileLayer.width)*game.tileSize
        
        if tileData == 1 or tileData == 2 then
            local tile = {}
            tile.id = tileData == 1 and 'ground' or tileData == 2 and 'water'
            tile.x, tile.y = tileX, tileY

            table.insert(tiles, tile)
            game.world:add(tile, tile.x, tile.y, game.tileSize, game.tileSize)
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
        local x, y, w, h = game.world:getRect(tile)
        love.graphics.rectangle('line', x, y, w, h)
        if tile.id == 'ground' then
            love.graphics.draw(game.sprites.tiles, game.tileQuads.ground, x, y)
        elseif tile.id == 'water' then
            love.graphics.draw(game.sprites.tiles, game.tileQuads.water, x, y)
        end
    end

    player:draw()
end