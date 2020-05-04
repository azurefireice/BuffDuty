local function string_split(input, seperator)
    local list = {}
    for value in string.gmatch(input, "([^"..seperator.."]+)") do -- Match all characters between seperators
        table.insert(list, value)
    end
    return list
end

local function string_trim(value, start_patten, end_patten)
    start_patten = start_patten or "%s*" -- Default to whitespace characters
    end_patten = end_patten or "%s*"
    value = string.gsub(value, "^"..start_patten.."(.-)"..end_patten.."$", "%1")
    return value
end

local function string_len(value)
    if not value or not (type(value) == "string") then
        return -1
    end
    return #value
end

local function expandClassArg(input)
    input = input:upper()
    if (input == "M") then
        return DutyAssign.MAGE_CLASS
    end
    if (input == "P") then
        return DutyAssign.PRIEST_CLASS
    end
    if (input == "D") then
        return DutyAssign.DRUID_CLASS
    end
    return input
end

local function expandChannelTypeArg(input)
    input = input:upper()
    if (input == "S") then
        return DutyAssign.SAY_CHANNEL_TYPE
    end
    if (input == "C") then
        return DutyAssign.CUSTOM_CHANNEL_TYPE
    end
    if (input == "W") then
        return DutyAssign.WHISPER_CHANNEL_TYPE
    end
    if (input == "R") then
        local inInstance, instanceType = IsInInstance()
        if (inInstance and instanceType == "pvp") then
            return DutyAssign.BG_CHANNEL_TYPE
        end
        return DutyAssign.RAID_CHANNEL_TYPE
    end
    return input
end

local function parseAssign(arg)
    local input = string.match(arg, "%b{}") -- Match everything between { and } inclusive
    if not input then return nil end
    input = string_trim(input, "{", "}")

    local list = string_split(input, ";")
    
    -- Extract player names and check for pre-assinged groups
    local assign = {}
    for i = 1, #list do
        local name_group = string_split(list[i], "=")
        assign[i] = {name = name_group[1], groups = nil}
        -- Parse groups
        local group_str = name_group[2]
        if group_str and #group_str > 0 then
            assign[i].groups = {}
            -- Parse group sets
            local group_sets = string_split(group_str, "%[%]$")
            for k = 1, #group_sets do
                local idx_set = string_split(group_sets[k], "|")
                if #idx_set > 1 then
                    local n = tonumber(idx_set[1])
                    if n then assign[i].groups[n] = string_split(idx_set[2], ",") end
                else
                    assign[i].groups[0] = string_split(idx_set[1], ",")
                end
            end
        end
    end
    return assign
end

local function parseList(arg)
    local input = string.match(arg, "%b{}") -- Match everything between { and } inclusive
    if not input then return nil end
    input = string_trim(input, "{", "}")

    return string_split(input, ",")
end

DutyAssign.Console = {}
function DutyAssign.Console.parseArgs(cmd, ...)
    local arg = {...}
    local idx = 0
    --for i = 0, #arg do print(i, arg[i]) end -- Debug

    local function arg_valid(i)
        i = i or idx
        return (arg[i] and not (i == #arg)) -- Not nil, and ignore the last arg that AceConsole appends
    end

    if arg[1] == "-set" then -- Settings command
        cmd.write_settings = true
        idx = 2
    else -- Standard command
        if not (arg_valid(1) and arg_valid(2)) then
            DutyAssign.printInfoMessage("Usage: /duty class channels [channel_name] [options]")
            return false
        end

        cmd.class = expandClassArg(arg[1])
        if not cmd.class or not DutyAssign.SUPPORTED_CLASSES[cmd.class] then
            DutyAssign.printErrorMessage(string.format("Unsupported class: %s", arg[1]))
            return false
        end

        local channels = string_split(arg[2], ",")
        if #channels == 0 then
            DutyAssign.printErrorMessage(string.format("Bad channels format: %s", arg[2]))
            return false
        end

        idx = 3
        for _, channel in ipairs(channels) do
            local channel_type = expandChannelTypeArg(channel)
            if not channel_type or not DutyAssign.SUPPORTED_CHANNELS[channel_type] then
                DutyAssign.printErrorMessage(string.format("Unsupported channel type: %s", channel_type))
                return false
            end
            table.insert(cmd.channel_types, channel_type)
            
            if(channel_type == DutyAssign.CUSTOM_CHANNEL_TYPE) then
                if not arg_valid(3) then
                    DutyAssign.printInfoMessage(string.format("Usage: /duty %s %s channel_name [options]", arg[1], arg[2]))
                    return false
                end
                
                cmd.channel_name = GetChannelName(arg[3])
                if cmd.channel_name == nil or cmd.channel_name == '' or cmd.channel_name == 0 then
                    DutyAssign.printErrorMessage(string.format("Custom channel name '%s' not found", arg[3]))
                    return false
                end

                idx = 4
            end
        end
    end

    -- Optional args
    while arg_valid() do
        local tag = string.match(arg[idx], "^[%a%-]+") -- Match starting letters including '-'
        if tag == "a" then
            cmd.assign = parseAssign(arg[idx])
        elseif tag == "e" then
            cmd.excluded = parseList(arg[idx])
        elseif tag == "-f" or tag == "-format" then
            idx = idx + 1 -- Next arg
            local duty_line = arg[idx]
            if arg_valid() then 
                if duty_line == "default" or string.find(duty_line, "$groups", 1, true) then
                    cmd.duty_line = duty_line
                else
                    DutyAssign.printErrorMessage("Duty line format must contain at least $groups")
                    return false
                end
            else
                DutyAssign.printErrorMessage("Invalid or missing "..tag.."value")
            end
        elseif tag == "-t" or tag == "-title" then
            idx = idx + 1 -- Next arg
            local public_title = arg[idx]
            if arg_valid() then
                cmd.public_title = public_title
            else
                DutyAssign.printErrorMessage("Invalid or missing "..tag.."value")
                return false
            end
        elseif tag == "-st" or tag == "-stitle" then
            idx = idx + 1 -- Next arg
            local single_title = arg[idx]
            if arg_valid() then
                if single_title == "default" or string.find(single_title, "$name", 1, true) then
                    cmd.single_title = single_title
                else
                    DutyAssign.printErrorMessage("Single title must contain at least $name")
                end
            else
                DutyAssign.printErrorMessage("Invalid or missing "..tag.."value")
                return false
            end
        elseif tag == "-w" or tag == "-whisper" then
            idx = idx + 1 -- Next arg
            local whisper_message = arg[idx]
            if arg_valid() then
                cmd.whisper_message = whisper_message
            else
                DutyAssign.printErrorMessage("Invalid or missing "..tag.."value")
                return false
            end
        elseif tag == "-sw" or tag == "-swhisper" then
            idx = idx + 1 -- Next arg
            local whisper_single = arg[idx]
            if arg_valid() then
                cmd.whisper_single = whisper_single
            else
                DutyAssign.printErrorMessage("Invalid or missing "..tag.."value")
                return false
            end
        elseif tag == "-d" or tag == "-debug" then
            cmd.debug = true
        end
        idx = idx + 1
    end

    return true
end
