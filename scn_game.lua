local Base = require 'scn_base'

local Tiles  = require 'cls_tile'
local Box    = require 'cls_box'
local Button = require 'gui_button'
local Player = require 'cls_player'

local TILE_SIZE = Tiles.tileSize

local Scene = {}
setmetatable(Scene, Base)
Scene.__index = Scene

function Scene.new(levelPack, levelName)
    local this = {}
    setmetatable(this, Scene)
    this.levelPack = levelPack
    this.levelName = levelName
    return this
end

-- @Override (stub)
function Scene:load()
    self.buttons = {
        Button.new({
            position = { 32, love.graphics.getHeight() - 80 },
            size     = { 48, 48 },
            onclick  = function()
                self:loadLevel()
            end,
            text = "Reset"
        }),
        Button.new({
            position = { 32, 32 },
            size     = { 48, 48 },
            onclick  = function()
                self:gotoLevel("", "")
            end,
            text = "Back"
        }),
    }
    love.graphics.setBackgroundColor(COLOURS.levelBackground)
    self:loadLevel()
    self:createCamera()
end

function Scene:loadLevel()
    self.message       = ""
    self.player        = Player.new()
    self.timer         = 0
    self.needUpdate    = false
    self.playerSliding = nil
    self.transition    = nil
    self.lastInput     = nil
    self.level         = love.filesystem.load("levels/" .. self.levelPack .. "/" .. self.levelName .. ".lua")()
    self:resetBoxes()
    self:resetPlayer()
    self:createParticleSystems()
end

function Scene:resetBoxes()
    self.boxes         = {}
    for _, b in pairs(self.level.boxes) do
        table.insert(self.boxes, Box.new(b))
    end
end

function Scene:createParticleSystems()
    local img = love.graphics.newImage("gfx_particle.png")
    self.particleSystems = {}
    for j, row in pairs(self.level.tiles) do
        for i, tile in pairs(row) do
            if tile == Tiles.GOAL then
                local px = (i - 0.5) * TILE_SIZE
                local py = (j - 0.5) * TILE_SIZE
                local ps = love.graphics.newParticleSystem(img, 64)
                ps:setAreaSpread("uniform", TILE_SIZE / 6, TILE_SIZE / 6)
                ps:setParticleLifetime(2, 5)
                ps:setEmissionRate(5)
                ps:setSizeVariation(1)
                ps:setLinearAcceleration(0, -5, 0, -10)
                ps:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.
                ps:setPosition(px, py)
                table.insert(self.particleSystems, ps)
            end
        end
    end
end

function Scene:resetPlayer()
    self.player:setPosition(unpack(self.level.startPosition))
end

function Scene:createCamera()
    self.camera = require("lib_camera").new()
    local i, j = self.player:getPosition()
    local px = (i - 0.5) * TILE_SIZE
    local py = (j - 0.5) * TILE_SIZE
    self.camera:centreOn(px, py)
    local minX = love.graphics.getWidth() - #self.level.tiles[1] * TILE_SIZE
    local minY = love.graphics.getHeight() - #self.level.tiles * TILE_SIZE
    self.camera:setBounds(-minX, -minY, 0, 0)
end

function Scene:gotoLevel(levelPack, levelName)
    local nextLevel = {
        pack = levelPack,
        level = levelName,
    }
    if not love.filesystem.exists("levels/" .. levelPack .. "/" .. levelName .. ".lua") then
        nextLevel = nil
    end
    self.transition = {
        nextLevel = nextLevel,
        timer     = 0.1,
    }
end

function Scene:nextLevel(nextLevel)
    if not nextLevel then 
        nextLevel = progress.nextLevel(self.levelPack, self.levelName)
    end
    if nextLevel then
        self:gotoLevel(self.levelPack, nextLevel)
    else
        self:gotoLevel("", "")
    end
end

-- @Override (stub)
function Scene:update(dt)
    if self.transition then
        self:updateTransition(dt)
        return
    end
    self.timer = self.timer + dt
    for _, trigger in pairs(self.level.triggers) do
        if trigger.condition(self) and not (trigger.oneTimeOnly and trigger.hasTriggered) then
            trigger.action(self, self.level.triggers)
            trigger.hasTriggered = true
        end
    end
    -- update bobbing
    for _, ps in pairs(self.particleSystems) do
        ps:update(dt)
    end
    for _, box in pairs(self.boxes) do
        box:update(dt)
    end
    self.needUpdate = false
    -- update sliding
    if self.playerSliding then
        self.needUpdate = true
        if self.playerSliding.timer <= 0 then
            local i, j = unpack(self.player.position)
            local x = i + self.playerSliding.dx
            local y = j + self.playerSliding.dy
            if self:canMove(x, y, i, j) then
                self:move(i, j, x, y)
                self.playerSliding.timer = Tiles.slideSpeed
                if self.level.tiles[y][x] ~= Tiles.ICE then
                    self.playerSliding = nil
                    self.needUpdate = false
                end
            else
                self.playerSliding = nil    
                self.needUpdate = false
            end
        else
            self.playerSliding.timer = self.playerSliding.timer - dt
        end
    end
end

function Scene:updateTransition(dt)
    self.transition.timer = self.transition.timer - dt
    if self.transition.timer <= 0 then
        if self.transition.nextLevel then
            scene = Scene.new(self.transition.nextLevel.pack, self.transition.nextLevel.level)
        else
            -- @TODO: be a bit more ceremonious about this
            scene = require("scn_title").new()
        end
        scene:load()
    end
end

function Scene:canMove(toX, toY, fromX, fromY)
    if not self.level.tiles[toY] then 
        return false 
    end
    if not self.level.tiles[toY][toX] then 
        return false 
    end
    local dist = math.abs(toX - fromX) + math.abs(toY - fromY)
    if dist > 1 then 
        return false 
    end
    local inBox = false
    local largestBoxIn = 0
    for _, box in pairs(self.boxes) do
        if box.position[1] == fromX and box.position[2] == fromY then
            local sides = box.sides
            if sides >= 8 then
                if fromY == toY + 1 then 
                    inBox = true 
                    largestBoxIn = math.max(largestBoxIn, box.size)
                end
                sides = sides - 8
            end
            if sides >= 4 then
                if fromX == toX + 1 then 
                    inBox = true 
                    largestBoxIn = math.max(largestBoxIn, box.size)
                end
                sides = sides - 4
            end
            if sides >= 2 then
                if fromY == toY - 1 then 
                    inBox = true 
                    largestBoxIn = math.max(largestBoxIn, box.size)
                end
                sides = sides - 2
            end
            if sides >= 1 then
                if fromX == toX - 1 then 
                    inBox = true 
                    largestBoxIn = math.max(largestBoxIn, box.size)
                end
                sides = sides - 1
            end
        end
        if box.position[1] == toX and box.position[2] == toY then
            local sides = box.sides
            if sides >= 8 then
                if fromY == toY - 1 then return false end
                sides = sides - 8
            end
            if sides >= 4 then
                if fromX == toX - 1 then return false end
                sides = sides - 4
            end
            if sides >= 2 then
                if fromY == toY + 1 then return false end
                sides = sides - 2
            end
            if sides >= 1 then
                if fromX == toX + 1 then return false end
                sides = sides - 1
            end
            if box.size <= largestBoxIn then return false end
            inBox = true
        end
    end
    return Tiles.isPassable(self.level.tiles[toY][toX], inBox)
    -- return true
end

function Scene:move(fromX, fromY, toX, toY)
    self.player:setPosition(toX, toY)
    local pushing = false
    local pushing_size = 0
    for _, b in pairs(self.boxes) do
        if b.position[1] == fromX and b.position[2] == fromY then
            local pushing = false
            local sides = b.sides
            if sides >= 8 then
                if fromY == toY + 1 then pushing = true end
                sides = sides - 8
            end
            if sides >= 4 then
                if fromX == toX + 1 then pushing = true end
                sides = sides - 4
            end
            if sides >= 2 then
                if fromY == toY - 1 then pushing = true end
                sides = sides - 2
            end
            if sides >= 1 then
                if fromX == toX - 1 then pushing = true end
                sides = sides - 1
            end
            if pushing then
                pushing_size = math.max(pushing_size, b.size)
            end
        end
    end
    for _, b in pairs(self.boxes) do
        if b.position[1] == fromX and b.position[2] == fromY and b.size <= pushing_size then
            b.position = {toX, toY}
        end
    end
end

-- @Override (stub)
function Scene:press(sx, sy)
    if self.needUpdate then return end
    local wx, wy = self.camera:toWorldPosition(sx, sy)
    local i = math.floor(wx / TILE_SIZE) + 1
    local j = math.floor(wy / TILE_SIZE) + 1
    local oldI, oldJ = self.player:getPosition()
    if self:canMove(i, j, oldI, oldJ) then
        self:move(oldI, oldJ, i, j)
        if self.level.tiles[j][i] == Tiles.ICE then
            local dx = i - oldI
            local dy = j - oldJ
            self.playerSliding = {
                dx    = dx, 
                dy    = dy, 
                timer = Tiles.slideSpeed,
            }
        end
    end
    self.lastInput = { i, j }
    self.needUpdate = true
    for _, button in pairs(self.buttons) do
        if button:isMouseOver(sx, sy) then
            button:press()
        end
    end
end

-- @Override (stub)
function Scene:drag(dx, dy)
    self.camera:move(-dx, -dy)
end

-- @Override (stub)
function Scene:keypressed(key, isRepeat)
    if key == "r" then
        self.buttons[1]:press()
    end
    if key == "escape" then
        self.buttons[2]:press()
    end 

    local i, j = self.player:getPosition()
    if key == "up" or key == "w" then
        j = j - 1
    end
    if key == "left" or key == "a" then
        i = i - 1
    end
    if key == "down" or key == "s" then
        j = j + 1
    end
    if key == "right" or key == "d" then
        i = i + 1
    end
    local wx = (i - 0.5) * TILE_SIZE
    local wy = (j - 0.5) * TILE_SIZE
    local sx, sy = self.camera:toScreenPosition(wx, wy)
    self:press(sx, sy)

    if key == "n" then
        self:nextLevel()
    end
end

-- @Override (stub)
function Scene:draw()
    self:drawWorld()
    self:drawGui()
    self:drawDebug()
end

function Scene:drawWorld()
    self.camera:set()
    self:drawMap()
    self:drawMapEffects()
    self:drawBoxes()
    self:drawPlayer()
    self.camera:unset()
end

function Scene:drawMap()
    for j, row in pairs(self.level.tiles) do
        for i, tile in pairs(row) do
            if tile > 0 then
                if tile == Tiles.WATER then
                    love.graphics.setColor(128, 128, 255)
                elseif tile == Tiles.ICE then
                    love.graphics.setColor(224, 224, 255)
                else
                    love.graphics.setColor(255, 255, 255)
                end
                love.graphics.rectangle("fill", (i-1) * TILE_SIZE, (j-1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
                love.graphics.setColor(128, 128, 128)
                love.graphics.rectangle("line", (i-1) * TILE_SIZE, (j-1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
                if tile == Tiles.GOAL then
                    local x = (i - 0.5) * TILE_SIZE - Player.size / 2
                    local y = (j - 0.5) * TILE_SIZE - Player.size / 2
                    love.graphics.setColor(COLOURS.levelBackground)
                    love.graphics.rectangle("fill", x, y, Player.size, Player.size, 4, 4)
                end
            end
        end
    end
end

function Scene:drawMapEffects()
    for _, ps in pairs(self.particleSystems) do
        love.graphics.draw(ps, 0, 0)
    end
end

function Scene:drawBoxes()
    for _, box in pairs(self.boxes) do
        box:draw()
    end
end

function Scene:drawPlayer()
    local ox, oy = 0, 0
    if self.playerSliding then
        local n = Tiles.slideSpeed
        local i = self.playerSliding.timer
        ox = ox - self.playerSliding.dx * TILE_SIZE * (i / n)
        oy = oy - self.playerSliding.dy * TILE_SIZE * (i / n)
    end
    self.player:draw(ox, oy)
end

function Scene:drawGui()
    love.graphics.setFont(FONTS.default)
    love.graphics.printf(self.message, 0, love.graphics.getHeight() - 64, love.graphics.getWidth(), "center")
    for _, button in pairs(self.buttons) do
        button:draw()
    end
end

function Scene:drawDebug()
    love.graphics.setFont(FONTS.default)
    local i, j = self.player:getPosition()
    love.graphics.print(i .. ", " .. j, 0, 0)
end

return Scene