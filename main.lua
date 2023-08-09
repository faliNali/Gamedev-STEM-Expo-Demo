local world
local tiles

function love.load()
    local bump = require "lib/bump"
    local map = require "maps/level1"

    world = bump.newWorld(80)
    
    tileLayer = getMapLayer(map, "Tiles")
    tiles = {}
    for i, tileData in ipairs(tileLayer.data) do
        if tileData == 1 then
            local tile = {x = ((i-1) % tileLayer.width)*40,
                          y = math.floor((i-1) / tileLayer.width)*40}
            table.insert(tiles, tile)
            world:add(tile, tile.x, tile.y, 40, 40)
        end
    end
end

function love.update(dt)

end

function love.draw()
    --[[ for i, tile in ipairs(tiles) do
        local x, y, w, h = world:getRect(tile)
        love.graphics.rectangle('line', x, y, w, h)
    end ]]

    
end

function getMapLayer(map, layerName)
    for i, layer in ipairs(map.layers) do
        if layer.name == layerName then
            return layer
        end
    end
end