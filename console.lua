local Console = {}
BuffDuty.Console = Console

-- Upvalues
local utils = BuffDuty.Utils

-- Validate the argurment as not nil and not the final value that AceConsole appends
local function argValid(args, idx)
    return (args[idx] and not (idx == #args)) 
end

-- Executes optional arguments
-- Optional arguments are indexed by tag and have the form:
-- option.has_value = true if the next argument is the value
-- option.validate = function(value) return ok, error_msg
-- option.onError = function(error) return isFatal
-- option.execute = function(cmd, value)
local function executeOptionalArgs(cmd, args, idx, option_table)
    while argValid(args, idx) do
        local tag = string.match(args[idx], "^[%a%-]+") -- Match starting letters including '-'
        if tag then tag = tag:lower() end -- Make case insensitive
        local option = option_table[tag]
        -- Check that the option is valid
        if option then
            -- Check if the option has a following value
            if option.has_value then
                idx = idx + 1
                if not argValid(args, idx) then
                    BuffDuty.printErrorMessage("Missing "..tag.." value")
                    return false
                end
            end
            -- Get the value
            local value = args[idx]
            -- Validate the value
            local status, result = true, true
            if option.validate then 
                status, result = pcall(option.validate, value)
            end
            -- Check validation status
            if status then 
                if result then
                    option.execute(cmd, value)
                else
                    BuffDuty.printErrorMessage("Invalid "..tag.." value")
                end
            else -- Error
                if option.onError then
                    if option.onError(result) then -- isFatal?
                        return false
                    end
                else
                    BuffDuty.printErrorMessage(result)
                    return false -- Treat errors as fatal
                end
            end
        end
        -- Next
        idx = idx + 1
    end
    return true
end

-- Set the custom message commands in the options table
local function setMessageOptions(option_table)
    local public_title = {has_value = true}
    public_title.validate = BuffDuty.Messages.validatePublicTitle
    public_title.execute = function(cmd, value) cmd.public_title = value end
    option_table["public-title"] = public_title
    option_table["-pt"] = public_title

    local duty_line = {has_value = true}
    duty_line.validate = BuffDuty.Messages.validateDutyLine
    duty_line.execute = function(cmd, value) cmd.duty_line = value end
    option_table["duty-line"] = duty_line
    option_table["-dl"] = duty_line

    local duty_whisper = {has_value = true}
    duty_whisper.validate = BuffDuty.Messages.validateDutyWhisper
    duty_whisper.execute = function(cmd, value) cmd.duty_whisper = value end
    option_table["duty-whisper"] = duty_whisper
    option_table["-dw"] = duty_whisper

    local single_message = {has_value = true}
    single_message.validate = BuffDuty.Messages.validateSingleMessage
    single_message.execute = function(cmd, value) cmd.single_message = value end
    option_table["single-message"] = single_message
    option_table["-sm"] = single_message

    local single_whisper = {has_value = true}
    single_whisper.validate = BuffDuty.Messages.validateSingleWhisper
    single_whisper.execute = function(cmd, value) cmd.single_whisper = value end
    option_table["single-whisper"] = single_whisper
    option_table["-sw"] = single_whisper
end

-- Parse a list formatted as {item1,item2,item3,...}
local function parseList(input)
    local value = string.match(input, "%b{}") -- Match everything between { and } inclusive
    if not value then return nil end
    value = utils.stringTrim(value, "{", "}")
    return utils.stringSplit(value, ",")
end

-- Parse the assign list formatted as {item1=v1,v2;item2=[i|v3];...}
local function parseAssign(input)
    local value = string.match(input, "%b{}") -- Match everything between { and } inclusive
    if not value then return nil end
    value = utils.stringTrim(value, "{", "}")

    local list = utils.stringSplit(value, ";")
    
    -- Extract player names and check for pre-assinged groups
    local assign = {}
    for i = 1, #list do
        local name_group = utils.stringSplit(list[i], "=")
        assign[i] = {name = name_group[1], groups = nil}
        -- Parse groups
        local group_str = name_group[2]
        if group_str and #group_str > 0 then
            assign[i].groups = {}
            -- Parse group sets
            local sets = utils.stringSplit(group_str, "%[%]$") -- Split into [ ] sets
            for k = 1, #sets do
                local condition_groups = utils.stringSplit(sets[k], "|") -- Seperate condition from groups
                if #condition_groups > 1 then -- Condition and Groups
                    local n = tonumber(condition_groups[1])
                    if n then 
                        assign[i].groups[n] = utils.stringSplit(condition_groups[2], ",") 
                    end
                else -- Zero indexed Groups
                    assign[i].groups[0] = utils.stringSplit(condition_groups[1], ",")
                end
            end
        end
    end
    return assign
end

-- Command for /buffduty
function Console.parseDutyCommand(cmd, args)
    --local args = {...} -- Argument list
    --for i = 0, #args do print(i, args[i]) end -- Debug

    -- Print version
    if args[1] == "version" or args[1] == "-v" then
        BuffDuty.printInfoMessage(string.format("Version: %d.%d.%d", BuffDuty.VERSION.MAJOR, BuffDuty.VERSION.MINOR, BuffDuty.VERSION.PATCH))
        return false
    end

    -- Print Usage Help
    if args[1] == "?" or args[1] == "help" or args[1] == "-h" then
        BuffDuty.printInfoMessage("Usage: /buffduty class channel [channel_name] [options]")
        BuffDuty.printInfoMessage("class | Mage, Priest, Druid, Paladin")
        BuffDuty.printInfoMessage("channel | Say, Raid, Whisper, Channel")
        BuffDuty.printInfoMessage("channel_name | Custom Channel name")
        BuffDuty.printInfoMessage("Options:")
        BuffDuty.printInfoMessage("e{player1,player2} | Exclude List - listed players will not be assigned buffing duties")
        BuffDuty.printInfoMessage("o{player1,player2} | Order List - listed players are prioritised for buffing duties dependant on logic")
        BuffDuty.printInfoMessage("a{player1=1,2;player2=own} | Assign List - listed players are assigned specified the groups if available")
        return false
    end

    -- Check for standard arguments
    if not (argValid(args, 1) and argValid(args, 2)) then
        BuffDuty.printErrorMessage("Class and Channel required")
        BuffDuty.printInfoMessage("Usage: /buffduty class channel [channel_name] [options]")
        BuffDuty.printInfoMessage("Type '/buffduty help' or see the README for further details")
        return false
    end

    -- Class
    cmd.class = BuffDuty.SUPPORTED_CLASSES[string.upper(args[1])]
    if not cmd.class then
        BuffDuty.printErrorMessage(string.format("Unsupported class: %s", args[1]))
        BuffDuty.printInfoMessage("Type '/buffduty help' or see the README for further details")
        return false
    end

    -- Channel Type
    cmd.channel_type = BuffDuty.SUPPORTED_CHANNELS[string.upper(args[2])]
    if not cmd.channel_type then
        BuffDuty.printErrorMessage(string.format("Unsupported channel type: %s", args[2]))
        BuffDuty.printInfoMessage("Type '/buffduty help' or see the README for further details")
    end

    local idx = 3 -- Set Options starting index to 3
    if cmd.channel_type == BuffDuty.CHANNELS.RAID then
        local inInstance, instanceType = IsInInstance() -- WOW API: https://wowwiki.fandom.com/wiki/API_IsInInstance
        -- If a person is in a BG then use the battleground channel
        if (inInstance and instanceType == "pvp") then
            cmd.channel_type = BuffDuty.CHANNELS.BATTLEGROUND
        end
    elseif cmd.channel_type == BuffDuty.CHANNELS.CUSTOM then
        if not argValid(args, 3) then
            BuffDuty.printErrorMessage("Channel Name required for Custom Channel")
            BuffDuty.printInfoMessage(string.format("Usage: /buffduty %s %s channel_name [options]", args[1], args[2]))
            return false
        end
        
        cmd.channel_id = GetChannelName(args[3]) -- WOW API: https://wowwiki.fandom.com/wiki/API_GetChannelName
        if (not cmd.channel_id) or cmd.channel_id == 0 then
            BuffDuty.printErrorMessage(string.format("Custom channel name '%s' not found", args[3]))
            return false
        end

        idx = 4 -- Set Options starting index to 4
    end

    -- Options
    local option_table = {}

    local excluded = {}
    excluded.execute = function(cmd, value) cmd.excluded = parseList(value) end
    option_table["e"] = excluded

    local order = {}
    order.execute = function(cmd, value) cmd.order = parseList(value) end
    option_table["o"] = order

    local assign = {}
    assign.execute = function(cmd, value) cmd.assign = parseAssign(value) end
    option_table["a"] = assign

    local own_group = {has_value = true}
    own_group.execute = function(cmd, value) cmd.own_group = utils.stringSplitAsFlags(value, ",") end
    option_table["own-group"] = own_group
    option_table["-own"] = own_group

    local nocache = {}
    nocache.execute = function(cmd, value) cmd.cache = false end
    option_table["no-cache"] = nocache

    local debug = {}
    debug.execute = function(cmd, value) cmd.debug = true end
    option_table["debug"] = debug
    option_table["-d"] = debug

    setMessageOptions(option_table)

    return executeOptionalArgs(cmd, args, idx, option_table)
end

-- Command for /buffduty-msg
function Console.parseMessageCommand(cmd, args)
    --local args = {...} -- Argument list

    -- Print Usage Help
    if args[1] == "?" or args[1] == "help" or args[1] == "-h" then
        BuffDuty.printInfoMessage("Usage: /buffduty-msg [options]")
        BuffDuty.printInfoMessage("reset type1,type2 | Reset listed messages types, or all, to default values")
        BuffDuty.printInfoMessage("public-title \"custom message\" | Set Public Title to \"custom message\"")
        BuffDuty.printInfoMessage("duty-line \"custom message\" | Set Duty Line to \"custom message\"")
        BuffDuty.printInfoMessage("duty-whisper \"custom message\" | Set Duty Whisper to \"custom message\"")
        BuffDuty.printInfoMessage("single-message \"custom message\" | Set Single Message to \"custom message\"")
        BuffDuty.printInfoMessage("single-whisper \"custom message\" | Set Single Whisper to \"custom message\"")
        return false
    end

    local option_table = {}

    local verbose = {}
    verbose.execute = function(cmd, value) cmd.verbose = true end
    option_table["verbose"] = verbose
    option_table["-v"] = verbose

    local reset = {has_value = true}
    reset.execute = function(cmd, value) cmd.reset = utils.stringSplitAsFlags(value, ",") end
    option_table["reset"] = reset
    option_table["-r"] = reset
    
    setMessageOptions(option_table)

    return executeOptionalArgs(cmd, args, 1, option_table)
end
