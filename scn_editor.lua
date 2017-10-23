local Base = require 'scn_base'

local Tiles  = require 'cls_tile'
local Box    = require 'cls_box'
local Player = require 'cls_player'
local Game   = require 'scn_game'
local Button = require 'gui_button'
local Camera = require 'lib_camera'

local TILE_SIZE = Tiles.tileSize

local Scene = {}
setmetatable(Scene, Base)
Scene.__index = Scene

function Scene.new()
    local this = Base.new("editor")
    this:load()
    setmetatable(this, Scene)
    return this
end

-- @Override (stub)
function Scene:load(...)
    love.graphics.setBackgroundColor(COLOURS.titleBackground)
    self.level  = self:blankLevel()
    self.camera = Camera.new()
    self.camera:centreOn(TILE_SIZE / 2, TILE_SIZE / 2)
end

function Scene:blankLevel()
    local level = {}
    level.tiles         = {{1}}
    level.boxes         = {}
    level.startPosition = {1, 1}
    level.triggers      = {}
    return level
end

-- @Override (stub)
function Scene:press(sx, sy)
    local wx, wy = self.camera:toWorldPosition(sx, sy)
    local i = math.floor(wx / TILE_SIZE) + 1
    local j = math.floor(wy / TILE_SIZE) + 1
    -- @TODO: handle inputs.
end

-- @Override (stub)
function Scene:drag(dx, dy)
    self.camera:move(-dx, -dy)
end

-- @Override (stub)
function Scene:draw()
    self:drawWorld()
    self:drawGui()
end

function Scene:drawWorld()
    self.camera:set()
    Game.drawMap(self)
    for _, box in pairs(self.level.boxes) do
        Box.drawSides(box)
    end
    Player.draw({position = self.level.startPosition})
    self.camera:unset()
end

function Scene:drawGui()

end

return Scene