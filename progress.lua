local PROGRESS_FILENAME = "progress.lb"

local packs = {}

local completionStats = {}
local packCompletion = {}
local lastLevelPack  = nil
local lastLevelName  = nil

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
            packCompletion[filename] = {}
            for _, levelName in pairs(packInfo.order) do
                packCompletion[filename][levelName] = false
            end
        end
    end

    if not love.filesystem.exists(PROGRESS_FILENAME) then
        local f = love.filesystem.newFile(PROGRESS_FILENAME)
        f:open("w")
        f:write("return {\n")
        f:write("    packCompletion = {},\n")
        f:write("}\n")
        f:flush()
        f:close("w")
    end
    local progress = love.filesystem.load(PROGRESS_FILENAME)()
    for pack, levels in pairs(progress.packCompletion) do
        if packCompletion[pack] then
            for level, completed in pairs(levels) do
                packCompletion[pack][level] = completed
            end
        end
    end
    if progress.lastLevel then
        lastLevelPack = progress.lastLevel.pack
        lastLevelName = progress.lastLevel.level
    end
end

local function saveProgress()
    local f = love.filesystem.newFile(PROGRESS_FILENAME)
    f:open("w")
    f:write("return {\n")
    f:write("    packCompletion = {\n")
    for pack, levels in pairs(packCompletion) do
        f:write("        [\"" .. pack .. "\"] = {\n")
        for level, completed in pairs(levels) do 
            f:write("            [\"" .. level .. "\"] = " .. tostring(completed) .. ",\n")
            print(pack, level, completed)
        end
        f:write("        },\n")
    end
    f:write("    },\n")
    f:write("    lastLevel = {\n")
    f:write("        pack  = \"" .. lastLevelPack .. "\",")
    f:write("        level = \"" .. lastLevelName .. "\",")
    f:write("    }\n")
    f:write("}\n")
    f:flush()
    f:close()
end

local function nextLevel(packName, currentLevel)
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

local function completeLevel(packName, levelName, stats)
    packCompletion[packName][levelName] = true
    -- @TODO: do stuff with completion stats.
end

local function beginLevel(packName, levelName)
    lastLevelPack = packName
    lastLevelName = levelName
end

local function lastLevel()
    if (not lastLevelPack) or (not lastLevelName) then
        for packName, pack in pairs(packs) do
            return packName, pack.levels[1]
        end
    end
    return lastLevelPack, lastLevelName
end

local progress = {
    load      = loadProgress,
    save      = saveProgress,
    nextLevel = nextLevel,
    complete  = completeLevel,
    begin     = beginLevel,
    continue  = lastLevel,
}

return progress