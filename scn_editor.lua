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
    self.level         = self:blankLevel()
    self.block_buttons = {}
    self.buttons       = {}
    self.box_buttons   = {}
    self.current_block = Tiles.GROUND
    self.selected_box  = nil
    self.camera        = Camera.new()
    self.camera:centreOn(TILE_SIZE / 2, TILE_SIZE / 2)
    self.block_buttons[1] = Button.new({
        position = {TILE_SIZE, 0},
        size     = {TILE_SIZE, TILE_SIZE},
        onclick  = function(btn)
            for _, row in pairs(self.level.tiles) do
                table.insert(row, 1)
            end
            btn.position[1] = btn.position[1] + TILE_SIZE
        end,
        text = "+\n>",
    })
    self.block_buttons[2] = Button.new({
        position = {0, TILE_SIZE},
        size     = {TILE_SIZE, TILE_SIZE},
        onclick  = function(btn) 
            table.insert(self.level.tiles, {})
            for i = 1, #self.level.tiles[1] do
                table.insert(self.level.tiles[#self.level.tiles], 1)
            end
            btn.position[2] = btn.position[2] + TILE_SIZE
        end,
        text = "+\nV",
    })
    self:createButtons()
end

function Scene:createButtons()
    local tile_types = {
        GROUND = 1,
        GOAL   = 2,
        WATER  = 3,
        ICE    = 4,
        TUNNEL = 5,
    }
    local draw = function(btn)
        if btn.selected then
            love.graphics.setColor(255, 255, 255)
        else
            love.graphics.setColor(0, 0, 0)
        end
        Button.draw(btn)
    end
    self:createTileButtons(tile_types, draw)
    self:createBoxButtons()
    local button = Button.new({
        position = {360, 4},
        size     = {128, 32},
        onclick  = function()
            self:playTest()
        end,
        text     = "Play",
    })
    table.insert(self.buttons, button)
    local button = Button.new({
        position = {360 + 136, 4},
        size     = {128, 32},
        onclick  = function()
            scene = require("scn_title").new()
            scene:load()
        end,
        text     = "Back",
    })
    table.insert(self.buttons, button)
end

function Scene:createTileButtons(tile_types, btn_draw)
    local button
    for type, num in pairs(tile_types) do
        local button = Button.new({
            position = {4 + (num + 2) * TILE_SIZE / 2, 4},
            size     = {TILE_SIZE / 2, TILE_SIZE / 2},
            onclick  = function(btn)
                self.current_block = num
                for _, b in pairs(self.buttons) do
                    b.selected = false
                end
                btn.selected = true
            end,
            text = type,
        })
        button.draw = btn_draw
        table.insert(self.buttons, button)
    end

    button = Button.new({
        position = {4 + TILE_SIZE, 4},
        size     = {TILE_SIZE / 2, TILE_SIZE / 2},
        onclick  = function(btn)
            self.current_block = 0
            for _, b in pairs(self.buttons) do
                b.selected = false
            end
            btn.selected = true
        end,
        text = "EMPTY",
    })
    button.draw = btn_draw
    table.insert(self.buttons, button)

    button = Button.new({
        position = {4, 4},
        size     = {TILE_SIZE / 2, TILE_SIZE / 2},
        onclick  = function(btn)
            self.current_block = -1
            for _, b in pairs(self.buttons) do
                b.selected = false
            end
            btn.selected = true
        end,
        text = "PLAYER",
    })
    button.draw = btn_draw
    table.insert(self.buttons, button)

    button = Button.new({
        position = {4 + TILE_SIZE / 2, 4},
        size     = {TILE_SIZE / 2, TILE_SIZE / 2},
        onclick  = function(btn)
            self.current_block = -2
            for _, b in pairs(self.buttons) do
                b.selected = false
            end
            btn.selected = true
        end,
        text = "BOX",
    })
    button.draw = btn_draw
    table.insert(self.buttons, button)
end

function Scene:createBoxButtons()
    local button
    button = Button.new({
        position = {4 + TILE_SIZE / 2, 4 + TILE_SIZE * 2},
        size     = {TILE_SIZE / 2, TILE_SIZE / 2},
        onclick  = function(btn)
            self.selected_box.size = self.selected_box.size + 0.1
        end,
        text = "+",
    })
    table.insert(self.box_buttons, button)
    button = Button.new({
        position = {4, 4 + TILE_SIZE * 2},
        size     = {TILE_SIZE / 2, TILE_SIZE / 2},
        onclick  = function(btn)
            self.selected_box.size = self.selected_box.size - 0.1
        end,
        text = "-",
    })
    table.insert(self.box_buttons, button)

    button = Button.new({
        position = {4 + TILE_SIZE, 4 + TILE_SIZE * 2},
        size     = {TILE_SIZE / 2, TILE_SIZE / 2},
        onclick  = function(btn)
            Box.rotate(self.selected_box, 1)
        end,
        text = "</",
    })
    table.insert(self.box_buttons, button)
    button = Button.new({
        position = {4 + TILE_SIZE * 1.5, 4 + TILE_SIZE * 2},
        size     = {TILE_SIZE / 2, TILE_SIZE / 2},
        onclick  = function(btn)
            Box.rotate(self.selected_box, -1)
        end,
        text = "\\>",
    })
    table.insert(self.box_buttons, button)

    local shrink_lookup = {1, 2, 1, 4, 3, 2, 5, 8, 8, 9, 10, 4, 5, 10, 13}
    button = Button.new({
        position = {4 + TILE_SIZE * 2, 4 + TILE_SIZE * 2},
        size     = {TILE_SIZE / 2, TILE_SIZE / 2},
        onclick  = function(btn)
            self.selected_box.sides = shrink_lookup[self.selected_box.sides]
        end,
        text = "_",
    })
    local grow_lookup = {3, 6, 5, 12, 13, 10, 15, 9, 10, 11, 15, 5, 15, 15, 15}
    table.insert(self.box_buttons, button)
    button = Button.new({
        position = {4 + TILE_SIZE * 2.5, 4 + TILE_SIZE * 2},
        size     = {TILE_SIZE / 2, TILE_SIZE / 2},
        onclick  = function(btn)
            self.selected_box.sides = grow_lookup[self.selected_box.sides]
        end,
        text = "]",
    })
    table.insert(self.box_buttons, button)

    button = Button.new({
        position = {4 + TILE_SIZE * 3, 4 + TILE_SIZE * 2},
        size     = {TILE_SIZE / 2, TILE_SIZE / 2},
        onclick  = function(btn)
            local index = 0
            for i, box in ipairs(self.level.boxes) do
                if box == self.selected_box then
                    index = i
                end
            end
            if index > 0 then
                table.remove(self.level.boxes, index)
                self.selected_box = nil
            end
        end,
        text     = "X",
    })
    table.insert(self.box_buttons, button)
end

function Scene:blankLevel()
    local level = {}
    level.tiles         = {{1}}
    level.boxes         = {}
    level.startPosition = {1, 1}
    level.triggers      = {}
    return level
end

function Scene:levelString()
    local str = "local level = {}\n\n"

    str = str .. "level.tiles = {\n"
    for j, row in pairs(level.tiles) do
        str = str .. "    {"
        for i, tile in pairs(row) do
            str = str .. tile .. ", "
        end
        str = str .. "},\n"
    end
    str = str .. "}\n\n"

    str = str .. "level.bodes = {\n"
    for _, box in pairs(level.boxes) do
        str = str .. "    {"
        str = str .. string.format("        position = {%d, %d},\n", box.position[1], box.position[2])
        str = str .. string.format("        sides    = %d,\n",       box.sides)
        str = str .. string.format("        size     = %.2f,\n",     box.size)
        str = str .. "    },\n"
    end
    str = str .. "}\n\n"

    str = str .. string.format("level.startPosition = {%d, %d}\n\n", level.startPosition[1], level.startPosition[2]))

    str = str .. "level.triggers = {}\n\n"

    return str .. "return level\n"
end

function Scene:printLevel()
    print(self:levelString())
end

function Scene:saveLevel(levelName)
    local level = self.level
    local file = love.filesystem.newFile("lvl_" .. levelName .. ".lua")
    file:open('w')
    file:write("local level = {}\n\n")

    file:write("level.tiles = {\n")
    for j, row in pairs(level.tiles) do
        file:write("    {")
        for i, tile in pairs(row) do
            file:write(tile)
            file:write(", ")
        end
        file:write("},\n")
    end
    file:write("}\n\n")

    file:write("level.boxes = {\n")
    for _, box in pairs(level.boxes) do
        file:write("    {")
        file:write(string.format("        position = {%d, %d},\n", box.position[1], box.position[2]))
        file:write(string.format("        sides    = %d,\n",       box.sides))
        file:write(string.format("        size     = %.2f,\n",     box.size))
        file:write("    },\n")
    end
    file:write("}\n\n")

    file:write(string.format("level.startPosition = {%d, %d}\n\n", level.startPosition[1], level.startPosition[2]))

    file:write("level.triggers = {}\n\n")

    file:write("return level\n")
    file:close()
end

function Scene:playTest()
    self:saveLevel("_playtest")
    self.testScene = Game.new("_playtest")
    self.testScene:load()
    local escape_button = Button.new({
        position = { 32, 32 },
        size     = { 48, 48 },
        onclick  = function()
            self.testScene = nil
            love.filesystem.remove("lvl__playtest.lua")
        end,
        text = "Back to Editor"
    })
    table.remove(self.testScene.buttons, 2)
    table.insert(self.testScene.buttons, escape_button)
end

function Scene:update(dt)
    if self.testScene then
        self.testScene:update(dt)
    end
end

function Scene:keypressed(key)
    if self.testScene then
        self.testScene:keypressed(key)
        if key == "escape" then
            self.testScene.buttons[2]:press()
        end
    end
end

-- @Override (stub)
function Scene:press(sx, sy)
    if self.testScene then
        self.testScene:press(sx, sy)
        return
    end

    local wx, wy = self.camera:toWorldPosition(sx, sy)
    local i = math.floor(wx / TILE_SIZE) + 1
    local j = math.floor(wy / TILE_SIZE) + 1
    if self.current_block and self.level.tiles[j] and self.level.tiles[j][i] then
        local box = nil
        for _, b in pairs(self.level.boxes) do
            if b.position[1] == i and b.position[2] == j then
                box = b
            end
        end
        if box then
            self.selected_box = box
        elseif self.current_block == -1 then
            self.level.startPosition = {i, j}
        elseif self.current_block == -2 then
            local box = {
                position  = {i, j},
                sides     = 13,
                size      = 1,
                lineColor = {0, 0, 0},
                bodyColor = {255, 255, 255, 128},
            }
            table.insert(self.level.boxes, box)
        else
            self.level.tiles[j][i] = self.current_block
        end
        return
    end
    for _, button in pairs(self.block_buttons) do
        if button:isMouseOver(wx, wy) then
            button:press()
        end
    end
    for _, button in pairs(self.buttons) do
        if button:isMouseOver(sx, sy) then
            button:press()
        end
    end
    for _, button in pairs(self.box_buttons) do
        if button:isMouseOver(sx, sy) then
            button:press()
        end
    end
end

-- @Override (stub)
function Scene:drag(dx, dy)
    if self.testScene then
        self.testScene:drag(dx, dy)
        return
    end
    self.camera:move(-dx, -dy)
end

-- @Override (stub)
function Scene:draw()
    if self.testScene then
        self.testScene:draw()
        return
    end
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
    for _, button in pairs(self.block_buttons) do
        button:draw()
    end
    self.camera:unset()
    for _, button in pairs(self.buttons) do
        button:draw()
    end
    if self.selected_box then
        for _, button in pairs(self.box_buttons) do
            button:draw()
        end 
    end
end

function Scene:drawGui()

end

return Scene