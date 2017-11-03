local level = {}

level.tiles = {
    {1, 4, 1, 4, 1},
    {4, 0, 4, 0, 4},
    {4, 4, 4, 4, 4},
    {4, 0, 4, 0, 4},
    {1, 4, 1, 4, 1},
}
level.boxes = {
    {
        position  = {3, 4},
        sides     = 12,
        size      = 0.5,
    },
    {
        position  = {4, 3},
        sides     = 3,
        size      = 0.7,
        goalPiece = true,
    },
    {
        position  = {5, 1},
        sides     = 2,
        size      = 0.5,
        goalPiece = true,
    },
}

level.startPosition = {3, 5}

level.triggers = {
    {
        condition = function(scene)
            return true
        end,
        -- oneTimeOnly = true,
        action = function(scene)
            scene.message = "If you get stuck, you can reset the level."
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
            local goalX, goalY = 0, 0
            for _, b in pairs(scene.boxes) do
                if b.goalPiece then
                    if goalX == 0 or goalY == 0 then
                        goalX = b.position[1]
                        goalY = b.position[2]
                    elseif goalX ~= b.position[1] or goalY ~= b.position[2] then
                        return false
                    end
                end
            end
            if goalX == 0 or goalY == 0 then return false end
            return i == goalX and j == goalY
        end,
        action = function(scene)
            scene:nextLevel()
        end
    },
}

return level