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
    this.goalPiece  = options.goalPiece  or false
    if options.goalPiece then
        local img = love.graphics.newImage("gfx_particle.png")
        this.particleSystem = love.graphics.newParticleSystem(img, 16)
        this.particleSystem:setAreaSpread("uniform", TILE_SIZE / 6, TILE_SIZE / 6)
        this.particleSystem:setParticleLifetime(2, 5)
        this.particleSystem:setEmissionRate(2)
        this.particleSystem:setSizeVariation(1)
        this.particleSystem:setLinearAcceleration(0, -5, 0, -10)
        this.particleSystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.
    end
    return this
end

function Box:update(dt)
    if self.particleSystem then
        self.particleSystem:update(dt)
    end
end

function Box:draw()
    self:drawSides()
    if self.particleSystem then
        local w = (BOX_SIZE / 2) * self.size
        local ox = (self.position[1] - 0.5) * TILE_SIZE
        local oy = (self.position[2] - 0.5) * TILE_SIZE
        love.graphics.draw(self.particleSystem, ox, oy)
    end
    self:drawName()
end

function Box:rotate(amount)
    local clockwise_lookup     = {2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15}
    local anticlockwise_lookup = {8, 1, 9, 2, 10, 3, 11, 4, 12, 5, 13, 6, 14, 7, 15}
    if amount == 0 then 
        return
    end
    local lookup
    if amount < 0 then 
        lookup = anticlockwise_lookup
        amount = -amount
    else
        lookup = clockwise_lookup
    end
    for i = 1, amount do
        self.sides = lookup[self.sides]
    end
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
    love.graphics.print(self.name, ox + x - w / 2, oy + y - TILE_SIZE / 2 - love.graphics.getFont():getHeight())
end


return Box