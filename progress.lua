local PROGRESS_FILENAME = "progress.lb"

local lastLevelPack  = nil
local lastLevelIndex = nil
local lastLevelName  = nil

local levelCompletion = {}
local packCompletion = {}

local packs = {
    
}

local function loadProgress()
    for _, filename in pairs(love.filesystem.getDirectoryItems("levels")) do
        local packInfo = love.filesystem.load("levels/" .. filename .. "/.packinfo")
        if packInfo then
            packInfo = packInfo()
            local pack = {
                name = packInfo.name,
                levels = packInfo.order,
            }
            packs[filename] = pack
        end
    end
end

local function saveProgress()

end

local function nextLevel(packName, currentLevel)
    for k, v in pairs(packs) do print(k, v) end print("--")
    pack = packs[packName]

    local useNext = false
    local nextLevelName = nil

    for i, level in pairs(pack.levels) do
        if nextLevelName == nil and level == currentLevel then
            useNext = true
        elseif nextLevelName == nil and useNext then
            nextLevelName = level
        end
    end

    return nextLevelName
end

local progress = {
    load = loadProgress,
    save = saveProgress,
    nextLevel = nextLevel,
}

return progress