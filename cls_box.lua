local Box = {}
Box.__index = Box

local TILE_SIZE = require('cls_tile').tileSize
local BOX_SIZE = TILE_SIZE * 0.8

function Box.new(options)
    local this = {}
    setmetatable(this, Box)
    this.position   = options.position
    this.sides      = options.sides
    this.size       = options.size       or 1
    this.name       = options.name       or ""
    this.lineColor  = options.lineColor  or {0, 0, 0}
    this.bodyColor  = options.bodyColor  or {255, 255, 255, 128}
    this.textColor  = options.textColor  or {0, 0, 0}
    this.textOffset = options.textOffset or {0, 0}
    return this
end

function Box:draw()
    self:drawSides()
    self:drawName()
end

function Box:drawSides()
    local w = (BOX_SIZE / 2) * self.size
    local ox = (self.position[1] - 0.5) * TILE_SIZE
    local oy = (self.position[2] - 0.5) * TILE_SIZE
    local sides = self.sides
    love.graphics.setColor(self.lineColor)
    if sides >= 8 then
        love.graphics.line(ox - w, oy - w, ox + w, oy - w)
        sides = sides - 8
    end
    if sides >= 4 then
        love.graphics.line(ox - w, oy - w, ox - w, oy + w)
        sides = sides - 4
    end
    if sides >= 2 then
        love.graphics.line(ox - w, oy + w, ox + w, oy + w)
        sides = sides - 2
    end
    if sides >= 1 then
        love.graphics.line(ox + w, oy - w, ox + w, oy + w)
        sides = sides - 1
    end
    love.graphics.setColor(self.bodyColor)
    love.graphics.rectangle("fill", ox - w, oy - w, w * 2, w * 2)
end

function Box:drawName()
    local i, j = self.position[1], self.position[2]
    local x, y = (i-0.5) * TILE_SIZE, (j-0.5) * TILE_SIZE
    local ox, oy = unpack(self.textOffset)
    local w = love.graphics.getFont():getWidth(self.name)
    love.graphics.setFont(FONTS.default)
    love.graphics.setColor(self.textColor)
    love.graphics.print(self.name, ox + x - (w) / 2, oy + y - TILE_SIZE / 2 - love.graphics.getFont():getHeight())
end


return Box