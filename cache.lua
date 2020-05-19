local Cache = {}
Cache.duties_cache = {}

BuffDuty.Cache = Cache

local FORMAT_VERSION = 2
local CACHE_TIMEOUT = 2419200 -- 4 Weeks

-- local aliases
local utils = BuffDuty.Utils

local function getTime()
    return GetServerTime() -- WOW API: https://wow.gamepedia.com/API_GetServerTime
end

function Cache.generateHash(raid_info, class_players)
    -- Raid groups
    local raid_groups = {}
    for i = 1, 8 do
        raid_groups[i] = raid_info.groups[i] and "1" or "0"
    end
    -- Players
    local player_names = utils.getTableKeys(class_players.map)
    utils.sortStringArray(player_names)
    
    return table.concat(raid_groups) .. ":" .. table.concat(player_names, ",")
end

function Cache:Initialise()
   self:CleanUp()
end

function Cache:CleanUp()
    -- Scan cache for old entries and delete them
    local keys = utils.getTableKeys(self.duties_cache)
    for idx = 1, #keys do
        local key = keys[idx]
        local entry = self.duties_cache[key]
        if type(entry) == "table" then 
            if (entry.version or 0) ~= FORMAT_VERSION then
                self.duties_cache[key] = nil
            elseif (getTime() - (entry.time or 0)) > CACHE_TIMEOUT then
                self.duties_cache[key] = nil
            elseif not entry.duties then
                self.duties_cache[key] = nil
            end
        else
            self.duties_cache[key] = nil
        end
    end
end

function Cache:AddEntry(key, duties)
    if not duties or utils.getTableSize(duties) < 1 then
        return -- Don't add entries for empty duty lists
    end

    local entry = {}
    entry.version = FORMAT_VERSION
    entry.time = getTime()
    entry.duties = duties

    self.duties_cache[key] = entry
end

function Cache:GetDuties(key)
    entry = self.duties_cache[key]
    
    -- Check entry is valid
    if not entry or type(entry) ~= "table" then
        return nil
    end
    -- Chech version
    if entry.version ~= FORMAT_VERSION then
        return nil
    end
    
    -- Update the time stamp
    entry.time = getTime()

    return entry.duties
end

function Cache:ClearAll()
    self.duties_cache = {}
end
