local game
local map
local Player
local Flag
local RestartScreen
local WinScreen

local tiles
local player
local flag
local restartScreen
local winScreen

local function getMapLayer(map, layerName)
    for i, layer in ipairs(map.layers) do
        if layer.name == layerName then
            return layer
        end
    end
end

local function restartGame()
    winScreen:finish()
    restartScreen:finish()
    game:resetWorld()
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
        elseif tileData == 4 then 
            flag = Flag:new(tileX, tileY)
        elseif tileData == 5 then
        elseif tileData == 6 then player = Player:new(tileX, tileY) end
    end
end

function love.load()
    game = require "game"
    map = require "maps/level1"
    Player = require 'Player'
    Flag = require 'Flag'
    RestartScreen = require 'RestartScreen'
    WinScreen = require 'WinScreen'

    restartScreen = RestartScreen:new()
    winScreen = WinScreen:new()
    
    restartGame()
end

function love.update(dt)
    player:update(dt)
    restartScreen:update(dt)
    winScreen:update(dt)

    if player:isReadyForGameRestart() then
        restartScreen:start()
    end

    if restartScreen:isCovered() then
        restartGame()
    end

    if player:justWonGame() then
        winScreen:start()
    end
end

function love.keypressed(key)
    if key == 'q' or key == 'escape' then
        love.event.quit()
    end

    if key == 'r' then
        print("wow")
        restartScreen:start()
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

    flag:draw()
    player:draw()
    winScreen:draw()
    restartScreen:draw()
end