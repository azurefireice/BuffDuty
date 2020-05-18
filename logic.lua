local Logic = {}
BuffDuty.Logic = Logic

-- Support for multiple logic types
Logic.Type = {}
Logic.Type.DEFAULT = "DEFAULT"
Logic.Type.ASSIGN = "ASSIGN"

-- local aliases
local utils = BuffDuty.Utils

-- Generates and returns a duty list in the following format:
-- list[name]["name"] = the players name
-- list[name]["i"] = the players index truncated to between 1 and 8 (inclusive)
-- list[name]["groups"] = a string list of assigned groups
-- list[name]["s"] = plural modifier; "s" if the player is assigned more than 1 group
function BuffDuty.getDutiesTable(cmd, raid_info, class_players, logic_type)
    -- No players to assign :(
    if (class_players.count == 0) then
        return {} 
    end
    -- One player to assign :/
    if (class_player.count == 1) then
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

    logic_type = logic_type or Logic.Type.DEFAULT
    local generateDutyMap = nil
    if Logic[logic_type] then
        generateDutyMap = Logic[logic_type].generateDutyMap
    end
    if not generateDutyMap then
        BuffDuty.printErrorMessage(string.format("Invalid Logic Type '%s'", logic_type))
        return nil
    end
    
    local player_duty_map = generateDutyMap(cmd, raid_info, class_players)
    
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

-- Returns a list of ordered players and a count of players specified in order
local function getOrderedPlayerList(player_map, order)
    local ordered_players = {}
    local ordered_count = 0
    -- Order list first
    if order then
        for _, name in pairs(order) do
            if player_map[name] then
                ordered_count = ordered_count + 1
                ordered_players[ordered_count] = name
            end
        end
    end
    -- Remaining players in map
    local idx = ordered_count
    for name, player in pairs(player_map) do
        if not utils.containsName(ordered_players, name) then
            idx = idx + 1
            ordered_players[idx] = name
        end
    end
    return ordered_players, ordered_count
end
Logic.getOrderedPlayerList = getOrderedPlayerList

------------ DEFAULT LOGIC ------------
local defaultLogic = {}
Logic[Logic.Type.DEFAULT] = defaultLogic

function defaultLogic.generateDutyMap(cmd, raid_info, class_players)
    -- Local aliases
    local group_count = raid_info.groups_count
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

    local ordered_players, ordered_count = getOrderedPlayerList(player_map, cmd.order)
    -- Assign players their number of duties in order
    for idx = 1, #ordered_players do
        local player = player_map[ordered_players[idx]]
        set_player_duties(player)
    end

    -- Assign own groups
    if not cmd.own_group["ignore"] then
        -- Only assign own group if the player has a single duty
        local single_duty = cmd.own_group["single"] 
        -- Validate that own group can be assign
        local function assign_own_group(player)
            if player and raid_groups[player.group] and (player.duties > 0) then
                if (not single_duty) or player.duties == 1 then
                    assign_group(player, player.group)
                end
            end
        end
         
        if cmd.own_group["priority"] then -- Assign in ordered
            for idx = 1, #ordered_players do 
                assign_own_group(player_map[ordered_players[idx]])
            end        
        else -- Default of non-ordered players first
            for idx = ordered_count + 1, #ordered_players do
                assign_own_group(player_map[ordered_players[idx]])
            end
            -- Ordered players in reverse order
            for idx = ordered_count, 1, -1 do
                assign_own_group(player_map[ordered_players[idx]])
            end
        end
    end

    -- Get the next player, in order, that has remaining duties
    local function next_player(idx, loop)
        local player = player_map[ordered_players[idx]]
        -- Check if the player has remaining duties
        while player and (not (player.duties > 0)) do
            idx = idx + 1
            player = player_map[ordered_players[idx]]
        end
        -- End of the list
        if loop and not player then
            return next_player(1, false) -- Guard against infinite recursion, should never need to loop more than once
        end
        return idx, player
    end

    -- Assign remaining groups to players in order
    local idx = 1
    for group = 1, group_count do
        if raid_groups[group] then
            idx, player = next_player(idx, true)
            if player then
                assign_group(player, group)
            else
                BuffDuty:printErrorMessage(string.format("Failed to assign group %d, no available players", group))
            end
        end
    end

    return player_map
end
