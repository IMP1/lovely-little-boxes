local Game = require 'scn_game'
local Button = require("gui_button") -- import button

local Scene = {}
setmetatable(Scene, Game)
Scene.__index = Scene

function Scene.new()
    local this = Game.new("title")
    this:load()
    setmetatable(this, Scene)
    return this
end

function Scene:load(...)
    Game.load(self, ...)
    love.graphics.setBackgroundColor(COLOURS.titleBackground)
end

-- @Override
function Scene:canMove(toX, toY, fromX, fromY)
    if not Game.canMove(self, toX, toY, fromX, fromY) then return false end
    if toX == 1 and toY == 2 then return false end -- @TODO: undisable this option
    if toX == 3 and toY == 2 then return false end -- @TODO: undisable this option
    return true
    -- @TODO: this override can be removed when all title options work
end

-- @Override
function Scene:drawMap()
    -- don't draw the map. It's a bit cluttered for a title screen.
end

-- @Override
function Scene:drawGui()
    love.graphics.setFont(FONTS.title)
    love.graphics.printf("Little Boxes", 0, 0, love.graphics.getWidth(), "center")
end



return Scene