local RaidInfo = {}
BuffDuty.RaidInfo = RaidInfo

-- Local aliases
local utils = BuffDuty.Utils

local function getNameClassGroup(idx)
    -- WOW API: https://wowwiki.fandom.com/wiki/API_GetRaidRosterInfo
    local name, rank, sub_group, level, class_loc, class = GetRaidRosterInfo(idx)
    return {name = name, class = class, group = sub_group}
    --return name, class, sub_group
end

local function getRaidMemberCount()
    return GetNumGroupMembers() -- WOW API: https://wowwiki.fandom.com/wiki/API_GetNumGroupMembers
end

-- Scan the list for a match to the player
local function containsMatch(list, player)
    for _, func in pairs(list) do
        if func(player) then
            return true
        end
    end
    return false
end

---- Matching Functions ---- 
-- Match the players group
function RaidInfo.MatchGroup(group)
    return function (player) 
        return player.group == group 
    end
end

-- Match the players class
function RaidInfo.MatchClass(class)
    return function (player)
        return player.class == class
    end
end

-- Match the player as a 'caster'
function RaidInfo.MatchCaster()
    return function (player)
        return player.class == "MAGE" or player.class == "PRIEST" or player.class == "WARLOCK"
    end
end

-- Match the player as a 'mana' user
function RaidInfo.MatchManaUser()
    return function (player)
        return player.class == "MAGE" or player.class == "PRIEST" or player.class == "WARLOCK"
        or player.class == "DRUID" or player.class == "PALADIN" or player.class == "SHAMAN"
        or player.class == "HUNTER"
    end
end

-- Select a Match function based on the given key
function RaidInfo.GetMatchFunction(key)
    if not key then return nil end
    -- Special
    if key == "mana" then
        return RaidInfo.MatchManaUser()
    end
    if key == "caster" then
        return RaidInfo.MatchCaster()
    end
    -- Class
    if BuffDuty.CLASSES[key:upper()] then
        return RaidInfo.MatchClass(key:upper())
    end
    -- Group
    if tonumber(key) then
        return RaidInfo.MatchGroup(tonumber(key))
    end
    return nil
end

-- Scans the raid returns two data tables `raid_info`, `class_players`.
-- Table structure:
-- raid_info.member_count - total number of players in the raid
-- raid_info.group_count - the number of valid groups in the raid
-- raid_info.group_min - the lowest numbered raid group; e.g. 1 in most cases
-- raid_info.group_max - the highest numbered raid group; e.g. 8 for a full raid
-- raid_info.groups[i] - a list of valid groups, indexed by group number (1 to 8)
-- class_players.count - the number of duty assignable players in the raid
-- class_players.map - a map of duty assignable players, indexed by name
-- class_players.map[name].idx - the index of the player, from 1 to count
-- class_players.map[name].name - the name of the player
-- class_players.map[name].group - the group the player is in
function RaidInfo.Scan(class, excluded_players, group_blacklist, group_whitelist)
    local raid_info = {}
    raid_info.member_count = getRaidMemberCount()
    raid_info.group_count = 0
    raid_info.group_min = 8 -- Start high so logic works
    raid_info.group_max = 1 -- Start low so logic works
    raid_info.groups = {[1]=false,[2]=false,[3]=false,[4]=false,[5]=false,[6]=false,[7]=false,[8]=false}

    local class_players = {}
    class_players.count = 0
    class_players.map = {}
    
    for i = 1, raid_info.member_count do
        local player = getNameClassGroup(i)
        -- Setup raid info
        if not raid_info.groups[player.group] then
            -- Check group is black / white listed
            if group_blacklist and containsMatch(group_blacklist, player) then -- Do nothing
            elseif not group_whitelist or containsMatch(group_whitelist, player) then
                raid_info.groups[player.group] = true
                raid_info.group_count = raid_info.group_count + 1
                if player.group < raid_info.group_min then
                    raid_info.group_min = player.group
                end
                if player.group > raid_info.group_max then
                    raid_info.group_max = player.group
                end
            end
        end
        -- Setup class players
        if player.name and player.class == class and (not utils.containsStringValue(excluded_players, player.name)) then
            class_players.count = class_players.count + 1
            class_players.map[player.name] = {
                idx = class_players.count,
                name = player.name,
                group = player.group,
            }
        end
    end

    return raid_info, class_players
end
