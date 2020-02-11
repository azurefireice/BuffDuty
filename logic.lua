local MAX_GROUPS = 8
local buff_duty_info_message_format = "|cffffe00a•|r|cffd0021aBuff|r|cffff9d00Duty|r|cffffe00a•|r |cffffff00%s|r"
local group_too_small_message = "Current Group/Raid is too small. No sense in assigning buffs/dispells."
local no_class_players_message = "No %sS to do buffs/dispells."
local single_class_player_message = "Looks like we have only 1 %s in the raid today! {rt1}%s{rt1}, dear, could you please do all the buffing/dispelling?"
local duty_single_line_message = "{rt%d} %s {rt%d} - Group%s %s"
local title_message_content = "please support our raid with buffs, dispells and your love and care! •"
local public_title_message = "(Buff Duty) • Dear %ss, " .. title_message_content
local whisper_title_message = "(Buff Duty) • Dear %s, " .. title_message_content

function BuffDuty:getNameClass(idx)
    local name, r, sg, lvl, cls_loc, cls = GetRaidRosterInfo(idx)
    return name, cls
end

local function printInfoMessage(msg)
    print(string.format(buff_duty_info_message_format, msg))
end

local function contain_value (table, val)
    if not table or not val then
        return false
    end
    for index, value in ipairs(table) do
        if value:lower() == val:lower() then
            return true
        end
    end
    return false
end
-- Debug

--local function dump(o)
--    if type(o) == 'table' then
--        local s = '{ '
--        for k, v in pairs(o) do
--            if type(k) ~= 'number' then
--                k = '"' .. k .. '"'
--            end
--            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
--        end
--        return s .. '} '
--    else
--        return tostring(o)
--    end
--end

function BuffDuty:getDutiesTable(class, excluded)
    local m_count = GetNumGroupMembers()
    local class_players_map = {}
    local duties = {}

    if (m_count < 10) then
        printInfoMessage(group_too_small_message)
        return {}
    end

    local class_players_count = 0
    for i = 1, m_count, 1 do
        local name, player_class = BuffDuty:getNameClass(i)
        if (not contain_value(excluded, name) and player_class == class) then
            class_players_count = class_players_count + 1
            class_players_map[name] = { idx = class_players_count, name = name, groups = {} }
        end
    end
    if (class_players_count == 0) then

        printInfoMessage(string.format(no_class_players_message, class:lower()))
        return {}
    end

    if (class_players_count == 1) then
        local name = next(class_players_map)
        duties[name] = string.format(single_class_player_message, class:lower(), name)
        return duties
    end

    -- Map groups to players of specific class
    local key, player = nil, nil
    for i = 1, MAX_GROUPS, 1 do
        key, player = next(class_players_map, key)
        if key == nil then
            -- If # of players < groups then reiterate on players
            key, player = next(class_players_map)
        end
        table.insert(player.groups, i)
    end

    -- Generate duty message for each player
    local function assignDuty(_, player)
        -- using function to be able continue iterating when "player.groups" empty
        if not next(player.groups) then
            -- When # of players of specific class > MAX_GROUPS in Raid(e.g. 12 mages)
            return
        end
        local groups = ""
        for _, v in pairs(player.groups) do
            groups = groups .. v .. ", "
        end
        groups = groups:sub(1, -3) -- remove last ", "
        local plural = ""
        if groups:len() > 1 then
            plural = "s"
        end
        local duty_message = string.format(duty_single_line_message, player.idx, player.name, player.idx, plural, groups)
        duties[player.name] = duty_message
    end

    for _, player in pairs(class_players_map) do
        assignDuty(_, player)
    end
    return duties
end

function BuffDuty:printDuties(class, duties_table, channel_type, channel_name)
    if not next(duties_table) then
        return
    end

    if (channel_type == BuffDuty.WHISPER_CHANNEL_TYPE) then

        for player_name, duty_message in pairs(duties_table) do
            SendChatMessage(string.format(whisper_title_message, player_name), BuffDuty.WHISPER_CHANNEL_TYPE, nil, player_name)
            SendChatMessage(duty_message, BuffDuty.WHISPER_CHANNEL_TYPE, nil, player_name)
        end
        return
    end

    next_idx, _ = next(duties_table) -- next == nil if duties_table has 1 element.
    if (next_idx == nil) then
        SendChatMessage(duties_table[1], channel_type, nil, channel_name)
        return
    end

    SendChatMessage(string.format(public_title_message, class:lower()), channel_type, nil, channel_name)
    for _, value in pairs(duties_table) do
        SendChatMessage(value, channel_type, nil, channel_name)
    end
end