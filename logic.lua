local function contains_name(table, name, get_name_func)
    if not table or not name then
        return false
    end
    if not get_name_func then
        get_name_func = function(x) return x end
    end
    name = name:lower()
    for _, item in pairs(table) do
        if name == string.lower(get_name_func(item)) then
            return true
        end
    end
    return false
end

local function parse_equation(eq_str, operators)
    local idx = nil
    for _, op in pairs(operators) do
        idx = string.find(eq_str, op, 1, true) -- plain search; i.e ignore pattens
        if idx then break end
    end
    local lhs = idx and string.sub(eq_str, 1, idx - 1) or eq_str
    local rhs = idx and string.sub(eq_str, idx + 1, -1)
    local op = idx and string.sub(eq_str, idx, idx)
    return lhs, op, rhs
end



function DutyAssign.generateDutyTable(cmd)
    local raid_count = GetNumGroupMembers()
    if (raid_count < 10) then
        DutyAssign.printInfoMessage(DutyAssign.message_group_too_small)
        return {}
    end

    -- Table of assignable groups
    local tbl_groups = {[1] = false, [2] = false, [3] = false, [4] = false, [5] = false, [6] = false, [7] = false, [8] = false}
    tbl_groups.max = 1
    tbl_groups.min = 8
    tbl_groups.count = 0
   
    -- Player map and counter
    local player_map = {}
    local player_map_count = 0

    -- Count and initialise players of the specified class
    cmd.excluded = cmd.excluded or {}
    for i = 1, raid_count do
        local name, class, group = DutyAssign.getNameClassGroup(i)
        -- Setup groups table
        if not tbl_groups[group] then
            tbl_groups[group] = true
            tbl_groups.count = tbl_groups.count + 1
            if group > tbl_groups.max then
                tbl_groups.max = group
            end
            if group < tbl_groups.min then
                tbl_groups.min = group
            end
        end
        -- Check for valid player of class
        if name and class == cmd.class and not contains_name(cmd.excluded, name) then
            player_map_count = player_map_count + 1
            player_map[name] = { 
                idx = player_map_count, 
                name = name, 
                group = group, 
                groups = {}, 
                duties = nil, 
                last_assigned = nil,
            }
        end
    end

    -- No players of class
    if (player_map_count == 0) then        
        DutyAssign.printInfoMessage(string.format(DutyAssign.message_no_class_players, cmd.class:lower()))
        return {}
    end
    
    -- One player of class
    if (player_map_count == 1) then
        local name = next(player_map)
        local player_info = {}
        player_info["name"] = name
        player_info["i"] = 1
        player_info["s"] = tbl_groups.count > 1 and "s" or ""
        player_info["groups"] = string.format("%d - %d", tbl_groups.min, tbl_groups.max)
        local duty_list = {}
        duty_list[name] = player_info
        return duty_list
    end

    -- Calculate how many groups each player will be assigned
    local extra_duties = tbl_groups.count % player_map_count
    local duties_per_player = (tbl_groups.count - extra_duties) / player_map_count
 
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
        if cmd.debug then DutyAssign.printDebugMessage(string.format("%s assigned group %d", player.name, group)) end
        table.insert(player.groups, group)
        player.last_assigned = group
        player.duties = player.duties - 1
        tbl_groups[group] = false
    end

    -- Iterate groups from start to limit (inclusive) returning the first available group, or nil
    local function get_next_group(start, limit, reverse)
        start = start or (reverse and tbl_groups.max or tbl_groups.min)
        limit = limit or (reverse and tbl_groups.min or tbl_groups.max)
        local increment = reverse and -1 or 1
        for group = start, limit, increment do
            if tbl_groups[group] then
                return group
            end
        end
        return nil
    end

    -- Returns a group number based on the group equation string
    local function parse_group(player, group_eq_str)
        if not group_eq_str or #group_eq_str == 0 then return nil end
        
        local g_prefix, g_op, g_suffix = parse_equation(group_eq_str, {"<",">"})
        if cmd.debug then DutyAssign.printDebugMessage(string.format("%s - L:%s, Op:%s, R:%s", player.name, g_prefix or "<nil>", g_op or "<nil>", g_suffix or "<nil>")) end

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
                        start = tbl_groups.min
                    elseif prefix == "x" then
                        start = player.last_assigned
                    end
                end
            else -- Empty
                start = player.last_assigned or tbl_groups.min
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
            start = player.last_assigned or tbl_groups.min
        end

        -- End here if we have an invalid start value, or no group operator
        if not start or not g_op then
            if cmd.debug then DutyAssign.printDebugMessage(string.format("no-op, returned %s", start or "<nil>")) end
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
                        limit = tbl_groups.max
                    elseif prefix == "x" then
                        limit = player.last_assigned
                    end
                end
            else -- Empty
                limit = tbl_groups.max
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
            limit = tbl_groups.max
        end
    
        -- Operator
        local group = nil
        if g_op == ">" then
            group = get_next_group(start, limit, false)
        elseif g_op == "<" then
            group = get_next_group(limit, start, true)        
        end

        if cmd.debug then DutyAssign.printDebugMessage(string.format("%d %s %d, returned %s", start, g_op, limit, group or "<nil>")) end
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
            if group and tbl_groups[group] then
                assign_group(player, group)
            end
        end
    end

    -- Assign specified players to groups
    cmd.assign = cmd.assign or {}
    for _, assign in pairs(cmd.assign) do
        if cmd.debug then DutyAssign.printDebugMessage(string.format("Pre-Assign %s", assign.name)) end
        -- All
        if assign.name == "[*]" then
            for _, player in pairs(player_map) do
                set_player_duties(player)
                parse_assigned_groups(player, assign.groups)
            end
        -- Other
        elseif assign.name:lower() == "[other]" then
            for _, player in pairs(player_map) do
                if not contains_name(cmd.assign, player.name, function(x) return x.name end) then
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
                DutyAssign.printInfoMessage(string.format("Error assigning player %s a group", player.name))
                player.duties = player.duties - 1
            end
        end
    end

    -- Generate duty info list for each player
    local duty_list = {}
    local function generate_duty_list(player)
        -- Check that the player has been assigned groups, e.g. the raid may have more mages than groups to buff
        if not player.groups or #player.groups < 1 then return end

        local player_info = {}
        player_info["name"] = player.name
        player_info["i"] = ((player.idx-1) % 8) + 1 -- a number between 1 and 8 (inclusive)

        table.sort(player.groups)
        local group_str = ""
        for _, v in pairs(player.groups) do
            group_str = group_str .. v .. ", "
        end
        group_str = group_str:sub(1, -3) -- remove the last ", "
        player_info["groups"] = group_str
        player_info["s"] = (#player.groups > 1) and "s" or ""

        duty_list[player.name] = player_info
    end

    for _, player in pairs(player_map) do
        generate_duty_list(player)
    end
    return duty_list
end