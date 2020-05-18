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

-- Scans the raid returns the following structed information:
-- member_count - total number of players in the raid
-- groups[i] - true if group 'i' is a valid raid group
-- groups.count - the number of valid groups in the raid
-- groups.max - the highest numbered raid group; e.g. 8 for a full raid
-- groups.min - the lowest numbered raid group; e.g. 1 in most cases
-- players.count - the number of duty assignable players in the raid
-- players.map - a map of duty assignable players index by name
-- players.map[name].idx - the index of the player, from 1 to count
-- players.map[name].name - the name of the player
-- players.map[name].group - the group the player is in
function RaidInfo.Scan(class, excluded)
    local raid_info = {}
    raid_info.member_count = getRaidMemberCount()

    local group_info = {[1] = false, [2] = false, [3] = false, [4] = false, [5] = false, [6] = false, [7] = false, [8] = false}
    group_info.max = 1 -- Start low so logic works
    group_info.min = 8 -- Start high so logic works
    group_info.count = 0
    raid_info.groups = group_info

    local player_info = {}
    player_info.map = {}
    player_info.count = 0
    raid_info.players = player_info

    for i = 1, raid_info.member_count do
        local name, class, group = getNameClassGroup(i)
        -- Setup group info
        if not group_info[group] then
            group_info[group] = true
            group_info.count = group_info.count + 1
            if group > group_info.max then
                tbl_groups.max = group
            end
            if group < group_info.min then
                group_info.min = group
            end
        end
        -- Setup player info
        if name and class == class and (not utils.containsName(excluded, name)) then
            player_info.count = player_info.count + 1
            player_info.map[name] = {
                idx = player_info.count,
                name = name,
                group = group,
            }
        end
    end

    return raid_info
end
