local Cache = {}
Cache.duties_cache = {}

BuffDuty.Cache = Cache

local FORMAT_VERSION = 2
local CACHE_TIMEOUT = 2419200 -- 4 Weeks

-- local aliases
local utils = BuffDuty.Utils

local function generateHash(raid_info, class_players)
    -- Raid groups
    local raid_groups = {}
    for i = 1, 8 do
        raid_groups[i] = (raid_info.groups[i] and "1" or "0")
    end
    -- Players
    local player_names = utils.getTableKeys(class_players.map)
    utils.sortStringArray(player_names)
    
    local hash = table.concat(raid_groups) .. ":" .. table.concat(player_names, ",")
    return hash
end

function Cache:Initialise()
    -- Scan cache for old entries and delete them
    local keys = utils.getTableKeys(self.duties_cache)
    for idx = 1, #keys do
        local hash = keys[idx]
        local entry = self.duties_cache[hash]
        if type(entry) == "table" then 
            if entry.version ~= FORMAT_VERSION then
                self.duties_cache[hash] = nil
            elseif (os.time() - entry.time) > CACHE_TIMEOUT then
                self.duties_cache[hash] = nil
            end
        else
            self.duties_cache[keys[idx]] = nil
        end
    end
end

function Cache:AddEntry(raid_info, class_players, duties)
    if not duties or utils.getTableSize(duties) < 1 then
        return -- Don't add entries for empty duty lists
    end

    local entry = {}
    entry.version = FORMAT_VERSION
    entry.time = os.time()
    entry.duties = duties

    local hash = generateHash(raid_info, class_players)
    self.duties_cache[hash] = entry
end

function Cache:GetDuties(raid_info, class_players)
    local hash = generateHash(raid_info, class_players)
    entry = self.duties_cache[hash]
    
    -- Check entry is valid
    if not entry or type(entry) ~= "table" then
        return nil
    end
    -- Chech version
    if entry.version ~= FORMAT_VERSION then
        return nil
    end
    
    -- Update the time stamp
    self.duties_cache[hash].time = os.time()

    return entry.duties
end

function Cache:ClearAll()
    self.duties_cache = {}
end
