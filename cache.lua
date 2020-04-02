local Cache = {}
Cache.duties_cache = nil

BuffDuty.Cache = Cache

local function generateHash(class, excluded)
    local current_players = BuffDuty:getClassPlayersMap(GetNumGroupMembers(), class, excluded)
    local player_names = BuffDuty.Utils.getTableKeys(current_players)
    BuffDuty.Utils.sortStringArray(player_names)
    local result = BuffDuty.max_group .. ":" .. table.concat(player_names):lower()
    return result
end

function Cache:addToCache(class, excluded, duties)
    local hash = generateHash(class, excluded)
    self.duties_cache[hash] = duties
end

function Cache:cacheContains(class, excluded)
    local hash = generateHash(class, excluded)
    return self.duties_cache[hash] ~= nil
end

function Cache:getFromCache(class, excluded)
    local hash = generateHash(class, excluded)
    return self.duties_cache[hash]
end
