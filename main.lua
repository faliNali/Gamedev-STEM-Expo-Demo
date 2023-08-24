local game
local map
local Player
local Flag
local RestartScreen
local WinScreen
local EnemyManager

local tiles
local player
local flag
local enemyManager
local restartScreen
local winScreen

local function getMapLayer(map, layerName)
    for i, layer in ipairs(map.layers) do
        if layer.name == layerName then
            return layer
        end
    end
end

local function newObjectIfNonExistent(item, cls, ...)
    local args = {...}
    if not game.world:hasItem(item) or item == nil then
        return cls:new(...)
    end
    return item
end

local function restartGame()
    winScreen:finish()
    restartScreen:finish()
    enemyManager:clearEnemies()
    game.resetWorld()

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
        elseif tileData == 3 then
            flag = newObjectIfNonExistent(flag, Flag, tileX, tileY)
        elseif tileData == 4 then
            player = newObjectIfNonExistent(player, Player, tileX, tileY)
        elseif tileData == 5 then
            enemyManager:newEnemy(tileX, tileY) end
    end
end

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')

    game = require "game"
    map = require "maps/map"
    Player = require 'Player'
    Enemy = require 'Enemy'
    Flag = require 'Flag'
    EnemyManager = require 'EnemyManager'
    RestartScreen = require 'RestartScreen'
    WinScreen = require 'WinScreen'

    enemyManager = EnemyManager:new()
    restartScreen = RestartScreen:new()
    winScreen = WinScreen:new()
    
    restartGame()
end

function love.update(dt)
    player:update(dt)
    enemyManager:update(dt)
    restartScreen:update(dt)
    winScreen:update(dt)
    game.screenShaker:update(dt)
    flag:update(dt)
    game.anims.water:update(dt)

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
        restartScreen:start()
    end
    player:keypressed(key)
end

function love.draw()
    game.screenShaker:translate()
    love.graphics.scale(game.scale.x, game.scale.y)

    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.draw(
        game.sprites.background,
        love.graphics.getWidth()/(game.scale.x*2),
        love.graphics.getHeight()/(game.scale.x*2),
        0, 1, 1,
        game.sprites.background:getWidth()/2,
        game.sprites.background:getHeight()/2
    )
    love.graphics.setColor(1, 1, 1, 1)

    for i, tile in ipairs(tiles) do
        local x, y, w, h = game.world:getRect(tile)
        --love.graphics.rectangle('line', x, y, w, h)
        if tile.id == 'ground' then
            love.graphics.draw(game.sprites.ground, x, y)
        elseif tile.id == 'water' then
            game.anims.water:draw(game.sprites.water, x, y)
        end
    end

    enemyManager:draw()
    flag:draw()
    player:draw()
    winScreen:draw()
    restartScreen:draw()
end