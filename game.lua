local map = require 'maps/map'
local bump = require "lib/bump"
local anim8 = require 'lib/anim8'
local ScreenShaker = require 'ScreenShaker'

local game = {}


game.world = bump.newWorld(80)
game.screenShaker = ScreenShaker:new()
game.tileSize = map.tilewidth
game.scale = {x=2, y=2}

game.font = love.graphics.newFont('fonts/DinaRemasterII.ttc', 32)
love.graphics.setFont(game.font)

game.sprites = {
    tiles = love.graphics.newImage("maps/tileset.png"),
    particle = love.graphics.newImage("images/particle.png"),
    smallParticle = love.graphics.newImage('images/smallParticle.png'),
    player = love.graphics.newImage('images/player.png'),
    enemy = love.graphics.newImage('images/enemy.png'),
    flyingEnemy = love.graphics.newImage('images/flyingEnemy.png'),
    flag = love.graphics.newImage('images/flag.png'),
    flagParticle = love.graphics.newImage('images/flagParticle.png'),
    water = love.graphics.newImage('images/water.png')
}

local s = game.sprites
local ts = game.tileSize
game.quads = {
    player = anim8.newGrid(ts, ts, s.player:getWidth(), s.player:getHeight()),
    enemy = anim8.newGrid(ts, ts, s.enemy:getWidth(), s.enemy:getHeight()),
    flyingEnemy = anim8.newGrid(ts, ts, s.flyingEnemy:getWidth(), s.flyingEnemy:getHeight()),
    flag = anim8.newGrid(ts, ts, s.flag:getWidth(), s.flag:getHeight()),
    water = anim8.newGrid(ts, ts, s.water:getWidth(), s.water:getHeight())
}

local q = game.quads
game.anims = {
    player = {
        idle = anim8.newAnimation(q.player(1,1), 1),
        dead = anim8.newAnimation(q.player(2,1), 1),
        walk = anim8.newAnimation(q.player('1-4',2), 0.06),
        jumpUp = anim8.newAnimation(q.player(1,3), 1),
        jumpDown = anim8.newAnimation(q.player(2,3), 1)
    },
    enemy = anim8.newAnimation(q.enemy('1-2',1), 0.5),
    flag = anim8.newAnimation(q.flag('1-3',1), 0.25),
    water = anim8.newAnimation(q.water('1-3',1), 0.5)
}

game.tileQuads = {
    ground = love.graphics.newQuad(0, 0, ts, ts, game.sprites.tiles),
    water = love.graphics.newQuad(ts, 0, ts, ts, game.sprites.tiles)
}

game.sounds = {
    playerWalk = love.audio.newSource('sounds/playerWalk.wav', 'static'),
    playerJump = love.audio.newSource('sounds/playerJump.wav', 'static'),
    playerDefeat = love.audio.newSource('sounds/playerDefeat.wav', 'static'),
    playerExplode = love.audio.newSource('sounds/playerExplode.wav', 'static'),
    enemyExplode = love.audio.newSource('sounds/enemyExplode.wav', 'static'),
    winTheme = love.audio.newSource('sounds/winTheme.wav', 'stream'),
    winSound = love.audio.newSource('sounds/winSound.wav', 'static'),
    blackScreenIn = love.audio.newSource('sounds/blackScreenIn.wav', 'static'),
    blackScreenOut = love.audio.newSource('sounds/blackScreenOut.wav', 'static')
}
game.sounds.winTheme:setVolume(0.5)

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