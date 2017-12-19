local Base = require 'scn_base'
local Button = require 'gui_button'

local TILES_ACROSS = 3

local Scene = {}
setmetatable(Scene, Base)
Scene.__index = Scene

function Scene.new()
    local this = Base.new("level select")
    setmetatable(this, Scene)
    this:load()
    return this
end

local function quit()
    scene = require('scn_title').new()
    scene:load()
end

local function back()
    scene.levels = nil
    scene.buttons[1].action = quit
end

-- @Override (stub)
function Scene:load(...)

    -- @TODO: only load levels that are available? or not? 
    --        this would add complexity to the .packinfo (and progress) files.

    self.buttons = {
        Button.new({
            position = { 32, 32 },
            size     = { 48, 48 },
            onclick  = quit,
            text = "Back"
        }),
    }
    love.graphics.setBackgroundColor(COLOURS.titleBackground)
    self.packs = {}
    self.levels = nil
    self.packLevels = {}
    for packIndex, filename in pairs(love.filesystem.getDirectoryItems("levels")) do
        local packInfo = love.filesystem.load("levels/" .. filename .. "/.packinfo")
        if packInfo then
            packInfo = packInfo()

            self.packLevels[filename] = {}
            for levelIndex, level in ipairs(progress.available(filename)) do
                local j = math.floor((levelIndex - 1) / TILES_ACROSS) + 1
                local i = (levelIndex - 1) % TILES_ACROSS + 1
                local levelButton = Button.new({
                    position = {i * 96 + 32, j * 64 + 32},
                    size     = {64, 32},
                    onclick = function()
                        local packName = filename
                        local levelName = level
                        scene = require('scn_game').new(packName, levelName)
                        scene:load()
                    end,
                    text = level,
                })
                table.insert(self.packLevels[filename], levelButton)
            end

            local j = math.floor((packIndex - 1) / TILES_ACROSS) + 1
            local i = (packIndex - 1) % TILES_ACROSS + 1
            local packButton = Button.new({
                position = {i * 96 - 64, j * 96},
                size     = {64, 64},
                onclick  = function()
                    local packName = filename
                    self.levels = self.packLevels[packName]
                    self.buttons[1].action = back
                end,
                text = packInfo.name .. "\n" .. #packInfo.order,
            })
            table.insert(self.packs, packButton)
        end
    end
    print(#self.packs)
end

function Scene:loadLevels()

end

-- @Override (stub)
function Scene:press(sx, sy)
    if self.levels then
        for _, button in pairs(self.levels) do
            if button:isMouseOver(sx, sy) then
                button:press()
            end
        end
    else
        for _, button in pairs(self.packs) do
            if button:isMouseOver(sx, sy) then
                button:press()
            end
        end
    end
    for _, button in pairs(self.buttons) do
        if button:isMouseOver(sx, sy) then
            button:press()
        end
    end
end

function Scene:keypressed(key)
    if key == "escape" then
        self.buttons[1]:press()
    end 
end

-- @Override (stub)
function Scene:draw()
    for _, button in pairs(self.buttons) do
        button:draw()
    end
    if self.levels then
        for _, button in pairs(self.levels) do
            button:draw()
        end
    else
        for _, button in pairs(self.packs) do
            button:draw()
        end
    end
end

return Scene
