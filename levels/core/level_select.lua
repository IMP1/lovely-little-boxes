local level = {}

level.tiles = {{}}
level.boxes = {}
level.startPosition = {1, 1}

local function setTile(x, y, tile)
    while not level.tiles[y] do
        table.insert(level.tiles, {})
    end
    while not level.tiles[y][x] do
        table.insert(level.tiles[y], 0)
    end
    level.tiles[y][x] = tile
end

local function load()
    local packs = {}
    for _, filename in pairs(love.filesystem.getDirectoryItems("levels")) do
        local packInfo = love.filesystem.load("levels/" .. filename .. "/.packinfo")
        if packInfo then
            packInfo = packInfo()
            local pack = {
                name = packInfo.name,
                levels = packInfo.order,
            }
            table.insert(packs, pack)
        end
    end
    for i, p in pairs(packs) do
        if i > 1 then
            setTile((i-1)*3+1-1, 1, 4)
            setTile((i-1)*3+1-2, 1, 4)
        end
        setTile((i-1)*3+1, 1, 1)
        setTile((i-1)*3+1, 2, 1)
        for j, lvl in pairs(p.levels) do
            setTile((i-1)*3+1, 2 + j, 1)
            setTile((i-1)*3+1 + 1, 2 + j, 1)
            local box = {
                position  = {(i-1)*3+1 + 1, 2 + j},
                sides     = 11,
                size      = 1,
                name      = lvl,
                lineColor = {32, 32, 32},
            }
            table.insert(level.boxes, box)
        end
    end

    -- @TODO: use progress to colour completed levels.
    -- @TODO: use progress to set player's initial position (by current pack)
end

level.triggers = {
    {
        condition = function(scene)
            return #scene.level.tiles[1] == 0
        end,
        oneTimeOnly = true,
        action = function(scene)
            load()
            scene:resetBoxes()
        end,
    },
}

return level