local TILE_SIZE = require('cls_tile').tileSize

local Player = {}
Player.size = TILE_SIZE / 3
Player.__index = Player

function Player.new()
    local this = {}
    setmetatable(this, Player)
    this.position = {0, 0}
    return this
end

function Player:setPosition(x, y)
    self.position[1] = x
    self.position[2] = y
end

function Player:isAt(x, y)
    return self.position[1] == x and self.position[2] == y
end

function Player:getPosition()
    return self.position[1], self.position[2]
end

function Player:draw(ox, oy)
    local i, j = unpack(self.position)
    local x = (i - 1) * TILE_SIZE + (ox or 0)
    local y = (j - 1) * TILE_SIZE + (oy or 0)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", x + TILE_SIZE / 3, y + TILE_SIZE / 3, TILE_SIZE / 3, TILE_SIZE / 3, 4, 4)
end

return Player