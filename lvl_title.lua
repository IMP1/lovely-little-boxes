local level = {}

level.tiles = {
    {0, 1, 0},
    {1, 1, 1},
    {0, 1, 0},
}
level.boxes = {
    {
        position = {2, 1},
        sides    = 13,
        size     = 1,
        name     = "Continue",
        color    = {32, 32, 32},
    },
    {
        position = {1, 2},
        sides    = 14,
        size     = 1,
        name     = "Level Select",
        textOffset = {-30, 10},
        color    = {32, 32, 32},
    },
    {
        position = {3, 2},
        sides    = 11,
        size     = 1,
        name     = "Settings",
        textOffset = {30, 10},
        color    = {32, 32, 32},
    },
    {
        position = {2, 3},
        sides    = 7,
        size     = 1,
        name     = "Exit",
        textOffset = {0, 80},
        color    = {32, 32, 32},
    },
}

level.startPosition = {2, 2}

level.triggers = {
    {
        condition = function(scene)
            local i, j = scene.player:getPosition()
            return j == 1 and i == 2
        end,
        oneTimeOnly = true,
        action = function(scene)
            scene:nextLevel(progress.levelUpTo)
            -- scene = require("scn_game").new(progress.levelUpTo)
            -- scene:load()
        end,
    },
    {
        condition = function(scene)
            local i, j = scene.player:getPosition()
            return j == 3 and i == 2
        end,
        oneTimeOnly = true,
        action = function()
            love.event.quit()
        end,
    },
}

return level