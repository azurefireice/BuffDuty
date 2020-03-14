--local MAX_GROUPS = 8
local buff_duty_info_message_format = "|cffffe00a•|r|cffd0021aBuff|r|cffff9d00Duty|r|cffffe00a•|r |cffffff00%s|r"
local group_too_small_message = "Current Group/Raid is too small. No sense in assigning buffs."
local no_class_players_message = "No %ss to do buffs :("
local single_class_player_message = "Looks like we have only 1 %s in the raid today! {rt1}%s{rt1}, dear, would you kindly provide everyone with your wonderful buffs."
local duty_single_line_message = "{rt%d} %s {rt%d} - Group%s %s"
local title_message_content = "please support our raid with your buffs, love and care! •"
local public_title_message = "(Buff Duty) • Dear %ss, " .. title_message_content
local whisper_title_message = "(Buff Duty) • Dear %s, " .. title_message_content

BuffDuty.max_group = 1

function BuffDuty:getNameClassGroup(idx)
    local name, r, sg, lvl, cls_loc, cls = GetRaidRosterInfo(idx)
    if sg > BuffDuty.max_group then
        BuffDuty.max_group = sg
    end
    return name, cls, sg
end

local function printInfoMessage(msg)
    print(string.format(buff_duty_info_message_format, msg))
end

local function contains_value_string (table, val)
    if not table or not val then
        return false
    end
    for _, value in pairs(table) do
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

function BuffDuty:getDutiesTable(class, excluded, order)
    local m_count = GetNumGroupMembers()
    local class_players_count = 0
    local class_players_map = {}
    local ordered_players_count = 0
    local ordered_players_list = {}
    local group_assigned = { [1] = false, [2] = false, [3] = false, [4] = false, [5] = false, [6] = false, [7] = false, [8] = false }
    local duty_list = {}

    if (m_count < 10) then
        printInfoMessage(group_too_small_message)
        return {}
    end

    for i = 1, m_count do
        local name, player_class, group = BuffDuty:getNameClassGroup(i)
        if (player_class == class and not contains_value_string(excluded, name)) then
            class_players_count = class_players_count + 1
            class_players_map[name] = { idx = class_players_count, name = name, group = group, duties = 0, groups = {} }
        end
    end

    if (class_players_count == 0) then
        printInfoMessage(string.format(no_class_players_message, class:lower()))
        return {}
    end

    if (class_players_count == 1) then
        local name = next(class_players_map)
        duty_list[name] = string.format(single_class_player_message, class:lower(), name)
        return duty_list
    end

    -- Calculate how many groups each player will buff, and how many extra groups there are
    local extra_duties = BuffDuty.max_group % class_players_count
    local duties_per_player = (BuffDuty.max_group - extra_duties) / class_players_count
    --printInfoMessage(string.format("Groups = %d; Count = %d; Duties per player = %d; Extra = %d", max_group, class_players_count, duties_per_player, extra_duties))

    local function set_player_duties(player)
        player.duties = duties_per_player
        if extra_duties > 0 then
            player.duties = player.duties + 1
            extra_duties = extra_duties - 1
        end
    end

    local function assign_group(player, group)
        table.insert(player.groups, group)
        player.duties = player.duties - 1
        group_assigned[group] = true
    end

    -- Create ordered list of player names, starting with ordered players and setting duties
    if order then
        for _, name in pairs(order) do
            local player = class_players_map[name]
            if player then
                --printInfoMessage(string.format("Ordered %s added at %d", name, ordered_players_count))
                ordered_players_list[ordered_players_count] = name
                ordered_players_count = ordered_players_count + 1
                set_player_duties(player)
            end
        end
    end

    -- Add non-ordered players to ordered players list, settings duties and assigning to their own group first (if needed)
    local assign_own_group = BuffDuty.max_group - ordered_players_count -- Only assign as many as we don't have ordered players to cover
    local non_ordered_idx = ordered_players_count
    for name, player in pairs(class_players_map) do
        if not contains_value_string(ordered_players_list, name) then
            --printInfoMessage(string.format("Non-Ordered %s added at %d", name, non_ordered_idx))
            ordered_players_list[non_ordered_idx] = name
            non_ordered_idx = non_ordered_idx + 1
            set_player_duties(player)
            -- Assign to own group if needed
            if (assign_own_group > 0) and (player.duties > 0) and (not group_assigned[player.group]) then
                --printInfoMessage(string.format("Non-Ordered %s assigned own group %d", name, player.group))
                assign_group(player, player.group)
                assign_own_group = assign_own_group - 1
            end
        end
    end

    -- Assign ordered players to their own group if still available, and in reverse order
    for ordered_idx = ordered_players_count - 1, 0, -1 do
        local player = class_players_map[ordered_players_list[ordered_idx]]
        if not group_assigned[player.group] and player.duties > 0 then
            --printInfoMessage(string.format("Ordered %s assigned own group %d", name, player.group))
            assign_group(player, player.group)
        end
    end

    local function next_player(idx)
        local player = class_players_map[ordered_players_list[idx]]
        -- Check if the player has remaining duties
        while player and not (player.duties > 0) do
            idx = idx + 1
            player = class_players_map[ordered_players_list[idx]]
        end
        -- End of the list
        if not player then
            return next_player(0)
        end
        return idx, player
    end

    -- Assign remaining groups to players in order
    local order_idx = 0
    for group = 1, BuffDuty.max_group, 1 do
        if not group_assigned[group] then
            order_idx, player = next_player(order_idx)
            assign_group(player, group)
        end
    end

    -- Generate duty message for each player
    local function assignDuty(_, player)
        -- using function to be able continue iterating when "player.groups" empty
        if not next(player.groups) then
            -- When # of players of specific class > MAX_GROUPS in Raid(e.g. 12 mages)
            return
        end
        table.sort(player.groups)
        local groups = ""
        for _, v in pairs(player.groups) do
            groups = groups .. v .. ", "
        end
        groups = groups:sub(1, -3) -- remove last ", "
        local plural = ""
        if groups:len() > 1 then
            plural = "s"
        end
        local duty_message = string.format(duty_single_line_message, (player.idx % 8 + 1), player.name, (player.idx % 8 + 1), plural, groups)
        duty_list[player.name] = duty_message
    end

    for _, player in pairs(class_players_map) do
        assignDuty(_, player)
    end
    return duty_list
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
