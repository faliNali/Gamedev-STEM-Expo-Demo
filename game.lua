local map = require 'maps/level1'
local bump = require "lib/bump"

local game = {}

game.world = bump.newWorld(80)
game.tileSize = map.tilewidth

game.sprites = {
    tiles = love.graphics.newImage("maps/tileset1.png")
}

local ts = game.tileSize
game.tileQuads = {
    ground = love.graphics.newQuad(0, 0, ts, ts, game.sprites.tiles),
    water = love.graphics.newQuad(ts, 0, ts, ts, game.sprites.tiles)
}

function game:resetWorld()
    game.world = bump.newWorld(80)
end

return game