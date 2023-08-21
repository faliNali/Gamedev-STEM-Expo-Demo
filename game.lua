local map = require 'maps/map'
local bump = require "lib/bump"
local ScreenShaker = require 'ScreenShaker'

local game = {}


game.world = bump.newWorld(80)
game.screenShaker = ScreenShaker:new()
game.tileSize = map.tilewidth
game.scale = {x=2, y=2}

game.sprites = {
    tiles = love.graphics.newImage("maps/tileset.png"),
    particle = love.graphics.newImage("images/particle.png")
}

local ts = game.tileSize
game.tileQuads = {
    ground = love.graphics.newQuad(0, 0, ts, ts, game.sprites.tiles),
    water = love.graphics.newQuad(ts, 0, ts, ts, game.sprites.tiles)
}

game.font = love.graphics.newFont('fonts/DinaRemasterII.ttc', 32)
love.graphics.setFont(game.font)

function game.resetWorld()
    game.world = bump.newWorld(80)
end

function game.getWidth()
    return love.graphics.getWidth()/game.scale.x
end

function game.getHeight()
    return love.graphics.getHeight()/game.scale.y
end

return game