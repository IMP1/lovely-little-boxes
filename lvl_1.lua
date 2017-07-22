local level = {}

level.tiles = {
    {2, 1, 1},
    {1, 1, 1},
    {1, 1, 1},
    {1, 1, 1},
    {1, 1, 1},
}
level.boxes = {
    {
        position = {1, 1},
        sides    = 14,
        size     = 1
    },
}

level.startPosition = {2, 5}

level.triggers = {
    {
        condition = function(scene)
            local i, j = scene.player:getPosition()
            return j >= 3 -- and scene.timer > 2
        end,
        oneTimeOnly = true,
        action = function(scene)
            scene.message = "Move yourself around and into the box"
        end,
    },
    {
        condition = function(scene)
            local i, j = scene.player:getPosition()
            return j == 2 and i == 1 and scene.lastInput[1] == 1 and scene.lastInput[2] == 1
        end,
        action = function(scene, triggers)
            scene.message = "You can't get into a box through its solid sides."
        end,
    },
    {
        condition = function(scene)
            local i, j = scene.player:getPosition()
            return j == 1 and i == 1 and scene.boxes[1].position[2] == 1
        end,
        action = function(scene, triggers)
            scene.message = "You can push the box around from inside it."
            triggers[1].hasTriggered = true
            triggers[2].hasTriggered = true
        end,
    },
    {
        condition = function(scene)
            return scene.boxes[1].position[2] ~= 1
        end,
        action = function(scene)
            scene.message = "You can now leave through the hole that the box was blocking."
        end
    },
    {
        condition = function(scene)
            local i, j = scene.player:getPosition()
            local bx, by = unpack(scene.boxes[1].position)
            return by ~= 1 and 
                   scene.lastInput[1] == bx and 
                   scene.lastInput[2] == by and
                   (i ~= bx or j ~= by)
        end,
        action = function(scene, triggers)
            scene.message = "You can only move a box from inside it."
        end,
    },
    {
        condition = function(scene)
            local i, j = scene.player:getPosition()
            return scene.boxes[1].position[2] ~= 1 and i == 1 and j == 1
        end,
        action = function(scene)
            scene:nextLevel()
        end
    }
}

return level