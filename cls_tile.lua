local TILE_SIZE = 64

local tiles = {
    GROUND = 1, -- default
    GOAL   = 2, -- where the player needs to get
    WATER  = 3, -- player cannot pass unless in box
    ICE    = 4, -- player (and any boxes) keep moving until they cannot
    TUNNEL = 5, -- player can only pass if not in a box
}

function tiles.isPassable(tile, isInBox)
    if tile <= 0 then
        return false
    end
    if tile == tiles.GROUND or tile == tiles.GOAL or tile == tiles.ICE then
        return true
    end
    if tile == tiles.WATER then
        return isInBox
    end
    if tile == tiles.TUNNEL then
        return not isInBox
    end
    return false
end

tiles.tileSize = TILE_SIZE

return tiles