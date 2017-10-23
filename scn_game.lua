local Base = require 'scn_base'

local Tiles  = require 'cls_tile'
local Box    = require 'cls_box'
local Button = require 'gui_button'
local Player = require 'cls_player'

local TILE_SIZE = Tiles.tileSize

local Scene = {}
setmetatable(Scene, Base)
Scene.__index = Scene

function Scene.new(levelName)
    local this = {}
    setmetatable(this, Scene)
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
        })
    }
    love.graphics.setBackgroundColor(COLOURS.levelBackground)
    self:loadLevel()
    self:createCamera()
end

function Scene:loadLevel()
    self.level = love.filesystem.load("lvl_" .. self.levelName .. ".lua")()
    self.boxes = {}
    for _, b in pairs(self.level.boxes) do
        table.insert(self.boxes, Box.new(b))
    end
    self.message = ""
    self.player = Player.new()
    self.timer = 0
    self.needUpdate = false
    self.transition = nil
    self.lastInput = nil
    self:resetPlayer()
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

function Scene:nextLevel(levelName)
    levelName = levelName or tostring(self.levelName + 1)
    if not love.filesystem.exists("lvl_" .. levelName .. ".lua") then
        levelName = nil
    end
    self.transition = {
        nextLevel = levelName,
        timer     = 0.1,
    }
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
    -- update pretty animations
    self.needUpdate = false
end

function Scene:updateTransition(dt)
    self.transition.timer = self.transition.timer - dt
    if self.transition.timer <= 0 then
        if self.transition.nextLevel then
            scene = Scene.new(self.transition.nextLevel)
            scene:load()
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
    for _, box in pairs(self.boxes) do
        if box.position[1] == fromX and box.position[2] == fromY then
            local sides = box.sides
            if sides >= 8 then
                if fromY == toY - 1 then inBox = true end
                sides = sides - 8
            end
            if sides >= 4 then
                if fromX == toX + 1 then inBox = true end
                sides = sides - 4
            end
            if sides >= 2 then
                if fromY == toY + 1 then inBox = true end
                sides = sides - 2
            end
            if sides >= 1 then
                if fromX == toX - 1 then inBox = true end
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
            for _, b in pairs(self.boxes) do
                if b ~= box and b.position[1] == fromX and b.position[2] == fromY then
                    if box.size <= b.size then return false end
                end
            end
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

function Scene:drawBoxes()
    for _, box in pairs(self.boxes) do
        box:draw()
    end
end

function Scene:drawPlayer()
    self.player:draw()
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