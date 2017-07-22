-- Global Constants
COLOURS = {}
COLOURS.titleBackground = {128, 192, 255}
COLOURS.levelBackground = {128, 192, 192}
FONTS = {
    default = love.graphics.newFont("font_Melissa.otf", 24),
    title = love.graphics.newFont("font_Melissa.otf", 64),
}
-- Local Constants
local PROGRESS_FILENAME = "progress.lb"
local PRESS_DRAG_LENIENCY = 2

progress = {
    levelUpTo = 1,
}

local function loadProgress()
    if love.filesystem.exists(PROGRESS_FILENAME) then
        progress = love.filesystem.load(PROGRESS_FILENAME)()
    end
end

local function saveProgress()
    local f = love.filesystem.newFile(PROGRESS_FILENAME)
    f:open("w")
    f:write("return {\n")
    for k, v in pairs(progress) do
        f:write("\t" .. k .. " = " .. v .. ",\n")
    end
    f:write("}")
    f:flush()
    f:close()
end

local mousepress = nil

function love.load()
    loadProgress()
    scene = require("scn_title").new()
    scene:load()
end

function love.update(dt)
    if scene.update then scene:update(dt) end
end

function love.keypressed(key, isRepeat)
    if scene.keypressed then
        scene:keypressed(key, isRepeat)
    end
    if key == "q" and love.keyboard.isDown("lctrl") then
        love.event.quit()
    end
end

function love.mousepressed(x, y, key)
    mousepress = { x = x, y = y, key = key }
end

function love.mousemoved(mx, my, dx, dy)
    if mousepress and mousepress.key == 1 then
        scene:drag(dx, dy)
    end
end

function love.mousereleased(x, y, key)
    if mousepress and key == 1 and mousepress.key == 1 then
        local dx = x - mousepress.x
        local dy = y - mousepress.y
        if dx ^ 2 + dy ^ 2 < PRESS_DRAG_LENIENCY ^ 2 then
            scene:press(mousepress.x, mousepress.y)
        else
            scene:drop(x, y, mousepress.x, mousepress.y)
        end
        mousepress = nil
    end
    if key == "wu" then
        scene:zoom(1)
    end
end

function love.draw()
    if scene.draw then scene:draw() end
end

function love.quit()
    print("progress saved")
    saveProgress()
end