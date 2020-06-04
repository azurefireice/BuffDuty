local RaidInfo = {}
BuffDuty.RaidInfo = RaidInfo

-- Local aliases
local utils = BuffDuty.Utils

local function getNameClassGroup(idx)
    -- WOW API: https://wowwiki.fandom.com/wiki/API_GetRaidRosterInfo
    local name, rank, sub_group, level, class_loc, class = GetRaidRosterInfo(idx)
    return name, class, sub_group
end

local function getRaidMemberCount()
    return GetNumGroupMembers() -- WOW API: https://wowwiki.fandom.com/wiki/API_GetNumGroupMembers
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
function RaidInfo.Scan(class, excluded)
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
        local player_name, player_class, player_group = getNameClassGroup(i)
        -- Setup raid info
        if not raid_info.groups[player_group] then
            raid_info.groups[player_group] = true
            raid_info.group_count = raid_info.group_count + 1
            if player_group < raid_info.group_min then
                raid_info.group_min = player_group
            end
            if player_group > raid_info.group_max then
                raid_info.group_max = player_group
            end
        end
        -- Setup class players
        if player_name and player_class == class and (not utils.containsStringValue(excluded, player_name)) then
            class_players.count = class_players.count + 1
            class_players.map[player_name] = {
                idx = class_players.count,
                name = player_name,
                group = player_group,
            }
        end
    end

    return raid_info, class_players
end
