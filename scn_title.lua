local Game = require 'scn_game'
local Button = require 'gui_button'

local Scene = {}
setmetatable(Scene, Game)
Scene.__index = Scene

function Scene.new()
    local this = Game.new("core", "title")
    setmetatable(this, Scene)
    -- this:load()
    return this
end

-- @Override
function Scene:load(...)
    Game.load(self, ...)
    love.graphics.setBackgroundColor(COLOURS.titleBackground)
end

-- @Override
function Scene:canMove(toX, toY, fromX, fromY)
    if not Game.canMove(self, toX, toY, fromX, fromY) then return false end
    if toX == 3 and toY == 2 then return false end -- @TODO: undisable this option
    return true
    -- @TODO: this entire override method can be removed when all title options work
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


-- @Override
function Scene:keypressed(key, isRepeat)
    Game.keypressed(self, key, isRepeat)
    if key == "/" then
        scene = require("scn_editor").new()
        scene:load()
    end
end



return Scene