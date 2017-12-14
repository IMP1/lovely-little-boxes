local Game = require 'scn_game'
local Button = require 'gui_button'

local Scene = {}
setmetatable(Scene, Game)
Scene.__index = Scene

function Scene.new()
    local this = Game.new("core", "level_select")
    setmetatable(this, Scene)
    this:load()
    return this
end

-- @Override (stub)
function Scene:load(...)
    love.graphics.setBackgroundColor(COLOURS.titleBackground)
    self.selectedPack = nil
    self.selectedLevel = nil
    self.packs = {}
    for _, filename in pairs(love.filesystem.getDirectoryItems("levels")) do
        local packInfo = love.filesystem.load("levels/" .. filename .. "/.packinfo")
        if packInfo then
            packInfo = packInfo()
            local pack = {
                name = packInfo.name,
                levels = packInfo.order,
            }
            table.insert(self.packs, pack)
        end
    end
    self.loadLevels()
end

function Scene:loadLevels()
    print(#self.packs)
    self.level.tiles = {}
    for _, pack in pairs(self.packs) do
        print(#pack.levels)
    end
end

-- @Override (stub)
function Scene:press(sx, sy)
    i = math.floor((sx + 32) / 96)
    j = math.floor((sy + 32) / 96)
end

-- @Override (stub)
function Scene:draw()
    if self.selectedPack then

    else
        for i, pack in pairs(self.packs) do
            love.graphics.rectangle("line", i * 96 - 32, 64, 64, 64)
            love.graphics.printf(pack.name, i * 96 - 32, 64, 64, "center")
            love.graphics.printf(#pack.levels, i * 96 - 32, 64 + 32, 64, "center")
        end
    end
    if i or j then
        love.graphics.print(i .. ", " .. j, 0, 0)
    end
end

return Scene
