local level = {}

level.tiles = {
    {2, 1, 3, 0, 0},
    {1, 1, 3, 0, 0},
    {0, 0, 1, 1, 1},
    {0, 0, 1, 0, 1},
    {0, 0, 1, 1, 1},
}
level.boxes = {
    {
        position = {4, 3},
        sides    = 14,
        size     = 0.6
    },
    -- {
    --     position = {1, 3},
    --     sides    = 14,
    --     size     = 0.6
    -- },
}

level.startPosition = {3, 5}

level.triggers = {
    {
        condition = function(scene)
            return true
        end,
        oneTimeOnly = true,
        action = function(scene)
            scene.message = "Boxes can float, but you cannot."
        end,
    },
    {
        condition = function(scene)
            for _, b in pairs(scene.boxes) do
                if b.position[1] == 1 and b.position[2] == 1 then return true end
            end
        end,
        oneTimeOnly = true,
        action = function(scene)
            scene.message = "Remember, boxes have solid bottoms."
        end,
    },
    {
        condition = function(scene)
            local i, j = scene.player:getPosition()
            for _, b in pairs(scene.boxes) do
                if b.position[1] == i and b.position[2] == j then return false end
            end
            return i == 1 and j == 1
        end,
        action = function(scene)
            scene:nextLevel()
        end
    },
    -- {
    --     condition = function(scene)
    --         local x1, y1 = unpack(scene.boxes[1].position)
    --         local x2, y2 = unpack(scene.boxes[2].position)
    --         return x1 == x2 and y1 == y2
    --     end,
    --     action = function(scene)
    --         scene:nextLevel()
    --     end
    -- }
}

return level