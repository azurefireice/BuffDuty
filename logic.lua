local Logic = {}

-- Upvalues
local utils = BuffDuty.Utils

-- Generates and returns a duty list in the following format:
-- list[name]["name"] = the players name
-- list[name]["i"] = the players index truncated to between 1 and 8 (inclusive)
-- list[name]["groups"] = a string list of assigned groups
-- list[name]["s"] = plural modifier; "s" if the player is assigned more than 1 group
function BuffDuty.generateDuties(cmd, raid_info, class_players)
    -- No players to assign :(
    if (class_players.count == 0) then
        return {} 
    end
    -- One player to assign :/
    if (class_players.count == 1) then
        local name = next(class_players.map)
        local duty = {}
        duty["name"] = name
        duty["i"] = 1
        if raid_info.group_count == 1 then
            duty["s"] = ""
            duty["groups"] = string.format("%d", raid_info.group_min)
        else
            duty["s"] = "s"
            duty["groups"] = string.format("%d - %d", raid_info.group_min, raid_info.group_max)
        end
        local duty_list = {}
        duty_list[name] = duty
        return duty_list
    end

    local player_duty_map = nil
    if cmd.assign then
        player_duty_map = Logic.Assign.generateDutyMap(cmd, raid_info, class_players)
    else
        player_duty_map = Logic.Default.generateDutyMap(cmd, raid_info, class_players)
    end

    local function generate_duty(player)
        -- Check that the player has been assigned groups, e.g. the raid may have more mages than groups to buff
        if not player.groups or #player.groups < 1 then return end

        local duty = {}
        duty["name"] = player.name
        duty["i"] = ((player.idx-1) % 8) + 1 -- a number between 1 and 8 (inclusive)

        table.sort(player.groups)
        local groups = ""
        for _, v in pairs(player.groups) do
            groups = groups .. v .. ","
        end
        groups = groups:sub(1, -2) -- remove last ","
        duty["groups"] = groups
        duty["s"] = (#player.groups > 1) and "s" or ""
        return duty
    end

    local duty_list = {}
    for _, player in pairs(player_duty_map) do
        duty_list[player.name] = generate_duty(player)
    end
    return duty_list
end

------------ DEFAULT LOGIC ------------
Logic.Default = {}
function Logic.Default.generateDutyMap(cmd, raid_info, class_players)
    -- Local aliases
    local group_count = raid_info.group_count
    local raid_groups = raid_info.groups
    local player_count = class_players.count
    local player_map = class_players.map

    -- Initialise player map
    for _, player in pairs(player_map) do
        player.duties = nil
        player.groups = {}
    end

    -- Calculate how many groups each player will buff, and how many extra groups there are
    local extra_duties = group_count % player_count
    local duties_per_player = (group_count - extra_duties) / player_count
    if cmd.debug then BuffDuty.printDebugMessage(string.format("Groups = %d; Players = %d; Duties/Player = %d; Extra = %d", group_count, player_count, duties_per_player, extra_duties)) end

    -- Sets a players initial assignable duty count
    local function set_player_duties(player)
        if player.duties then return end -- Ensure we only set duties once
        player.duties = duties_per_player
        if extra_duties > 0 then
            player.duties = player.duties + 1
            extra_duties = extra_duties - 1
        end
    end

     -- Assigns a player to a group, reducing assignable duties by 1
    local function assign_group(player, group)
        if cmd.debug then BuffDuty.printDebugMessage(string.format("%s assigned group %d", player.name, group)) end
        table.insert(player.groups, group)
        player.duties = player.duties - 1
        raid_groups[group] = false
    end

    -- Create ordered player list
    local ordered_players = {}
    local ordered_count = 0
    -- Order list first
    if cmd.order then
        for idx = 1, #cmd.order do
            local player = player_map[cmd.order[idx]]
            if player then
                ordered_count = ordered_count + 1
                ordered_players[ordered_count] = player.name
            end
        end 
    end
    -- Non-ordered players
    local idx = ordered_count
    for name in pairs(player_map) do
        if not utils.containsName(ordered_players, name) then
            idx = idx + 1
            ordered_players[idx] = name
        end
    end
    
    -- Assign player duties in order
    for idx = 1, #ordered_players do
        local player = player_map[ordered_players[idx]]
        set_player_duties(player)
    end

    -- Assign own groups
    if not cmd.own_group["ignore"] then
        -- Only assign own group if the player has a single duty
        local single_duty = cmd.own_group["single"] 
        -- Helper function to validate and assign own group
        local function assign_own_group(player)
            if player and raid_groups[player.group] and (player.duties > 0) and ((not single_duty) or player.duties == 1) then
                assign_group(player, player.group)
            end
        end
         
        if cmd.own_group["order"] then -- Assign in ordered
            for idx = 1, #ordered_players do 
                assign_own_group(player_map[ordered_players[idx]])
            end        
        else -- Default is reverse order
            for idx = #ordered_players, 1, -1 do
                assign_own_group(player_map[ordered_players[idx]])
            end
        end
    end

    -- Iterate groups from start to limit (inclusive) returning the first available group, or nil
    local function get_next_group()
        for group = 1, 8 do
            if raid_groups[group] then
                return group
            end
        end
        return nil
    end

    -- Assign any remaining groups to players
    for _, player in pairs(player_map) do
        set_player_duties(player)
        
        while player.duties > 0 do
            group = get_next_group()
            if group then
                assign_group(player, group)
            else
                BuffDuty.printInfoMessage(string.format("Error assigning player %s a group", player.name))
                player.duties = player.duties - 1
            end
        end
    end

    return player_map
end

------------ ASSIGN LOGIC ------------
Logic.Assign = {}
function Logic.Assign.generateDutyMap(cmd, raid_info, class_players)
    -- Local aliases
    local group_count = raid_info.group_count
    local group_min = raid_info.group_min
    local group_max = raid_info.group_max
    local raid_groups = raid_info.groups
    local player_count = class_players.count
    local player_map = class_players.map

    -- Initialise player map
    for _, player in pairs(player_map) do
        player.duties = nil
        player.groups = {}
        player.last_assigned = nil
    end

    -- Calculate how many groups each player will buff, and how many extra groups there are
    local extra_duties = group_count % player_count
    local duties_per_player = (group_count - extra_duties) / player_count
    
    -- Sets a players initial assignable duty count
    local function set_player_duties(player)
        if player.duties then return end -- Ensure we only set duties once
        player.duties = duties_per_player
        if extra_duties > 0 then
            player.duties = player.duties + 1
            extra_duties = extra_duties - 1
        end
    end
    
    -- Assigns a player to a group, reducing assignable duties by 1
    local function assign_group(player, group)
        if cmd.debug then BuffDuty.printDebugMessage(string.format("%s assigned group %d", player.name, group)) end
        table.insert(player.groups, group)
        player.last_assigned = group
        player.duties = player.duties - 1
        raid_groups[group] = false
    end

    -- Iterate groups from start to limit (inclusive) returning the first available group, or nil
    local function get_next_group(start, limit, reverse)
        start = start or (reverse and group_min or group_max)
        limit = limit or (reverse and group_max or group_min)
        local increment = reverse and -1 or 1
        for group = start, limit, increment do
            if raid_groups[group] then
                return group
            end
        end
        return nil
    end

    -- Returns a group number based on the group equation string
    local function parse_group(player, group_eq_str)
        if not group_eq_str or #group_eq_str == 0 then return nil end
        
        local g_prefix, g_op, g_suffix = parse_equation(group_eq_str, {"<",">"})
        if cmd.debug then BuffDuty.printDebugMessage(string.format("%s - L:%s, Op:%s, R:%s", player.name, g_prefix or "<nil>", g_op or "<nil>", g_suffix or "<nil>")) end

        local start = nil
        if g_prefix and #g_prefix > 0 then
            local prefix, op, add = parse_equation(g_prefix, {"+","-"})
            -- Left hand side
            if prefix and #prefix > 0 then
                if tonumber(prefix) then
                    start = tonumber(prefix)
                else
                    prefix = prefix:lower()
                    if prefix == "o" or prefix == "own" then
                        start = player.group
                    elseif prefix == "m" or prefix == "lim" then
                        start = group_max
                    elseif prefix == "x" then
                        start = player.last_assigned
                    end
                end
            else -- Empty
                start = player.last_assigned or group_max
            end
            -- Calculate with right hand side
            if start then 
                add = tonumber(add) or 1
                if op == "+" then
                    start = start + add
                elseif op == "-" then
                    start = start - add
                end
            end
        else -- Empty
            start = player.last_assigned or group_max
        end

        -- End here if we have an invalid start value, or no group operator
        if not start or not g_op then
            if cmd.debug then BuffDuty.printDebugMessage(string.format("no-op, returned %s", start or "<nil>")) end
            return start
        end

        local limit = nil
        if g_suffix and #g_suffix > 0 then
            prefix, op, add = parse_equation(g_suffix, {"+","-"})
            -- Left hand side
            if prefix and #prefix > 0 then
                if tonumber(prefix) then
                    limit = tonumber(prefix)
                else
                    prefix = prefix:lower()
                    if prefix == "o" or prefix == "own" then
                        limit = player.group
                    elseif prefix == "m" or prefix == "lim" then
                        limit = group_min
                    elseif prefix == "x" then
                        limit = player.last_assigned
                    end
                end
            else -- Empty
                limit = group_min
            end
            -- Calculate with right hand side
            if limit then 
                add = tonumber(add) or 1
                if op == "+" then
                    limit = limit + add
                elseif op == "-" then
                    limit = limit - add
                end
            end
        end
        if not limit then
            limit = group_min
        end
    
        -- Operator
        local group = nil
        if g_op == ">" then
            group = get_next_group(start, limit, false)
        elseif g_op == "<" then
            group = get_next_group(limit, start, true)        
        end

        if cmd.debug then BuffDuty.printDebugMessage(string.format("%d %s %d, returned %s", start, g_op, limit, group or "<nil>")) end
        return group
    end

    -- Parse the list of group equations and attempt to assign player to each returned group
    local function parse_assigned_groups(player, groups_sets)
        if not groups_sets then return end
        
        -- Select the apporiate group equation set
        local group_eq_list = groups_sets[player.duties]
        if not group_eq_list then group_eq_list = groups_sets[0] end
        if not group_eq_list then return end
        
        for _, group_eq_str in pairs(group_eq_list) do
            if player.duties <= 0 then break end
            -- Parse group equation
            group = parse_group(player, group_eq_str)
            -- Attempt to assign player
            if group and raid_groups[group] then
                assign_group(player, group)
            end
        end
    end

    -- Assign specified players to groups
    cmd.assign = cmd.assign or {}
    for _, assign in pairs(cmd.assign) do
        if cmd.debug then BuffDuty.printDebugMessage(string.format("Pre-Assign %s", assign.name)) end
        -- All
        if assign.name == "[*]" then
            for _, player in pairs(player_map) do
                set_player_duties(player)
                parse_assigned_groups(player, assign.groups)
            end
        -- Other
        elseif assign.name:lower() == "[other]" then
            for _, player in pairs(player_map) do
                if not utils.containsName(cmd.assign, player.name, function(x) return x.name end) then
                    set_player_duties(player)
                    parse_assigned_groups(player, assign.groups)
                end
            end
        -- By Name
        else
            local player = player_map[assign.name]
            if player then
                set_player_duties(player)
                parse_assigned_groups(player, assign.groups)
            end
        end
    end

    -- Assign any remaining groups to players
    for _, player in pairs(player_map) do
        set_player_duties(player)
        
        while player.duties > 0 do
            group = get_next_group()
            if group then
                assign_group(player, group)
            else
                BuffDuty.printInfoMessage(string.format("Error assigning player %s a group", player.name))
                player.duties = player.duties - 1
            end
        end
    end

    return player_map
end
