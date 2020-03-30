local Cache = {}
BuffDuty.Cache = Cache

local duties_cache = {}

local function generateHash(class, excluded)
    local current_players = BuffDuty.getClassPlayersMap(BuffDuty, GetNumGroupMembers(), class, excluded)
    local player_names = BuffDuty.Utils.getTableKeys(current_players)
    BuffDuty.Utils.sortStringArray(player_names)
    return table.concat(player_names)
end

function Cache.addToCache(class, excluded, duties)
    local hash = generateHash(class, excluded)
    duties_cache[hash] = duties
end

function Cache.cacheContains(class, excluded)
    local hash = generateHash(class, excluded)
    return duties_cache[hash] ~= nil
end

function Cache.getFromCache(class, excluded)
    local hash = generateHash(class, excluded)
    return duties_cache[hash]
end
