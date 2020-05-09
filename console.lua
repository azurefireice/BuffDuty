local Console = {}
BuffDuty.Console = Console


BuffDuty.SAY_CHANNEL_TYPE = "SAY"
BuffDuty.RAID_CHANNEL_TYPE = "RAID"
BuffDuty.CUSTOM_CHANNEL_TYPE = "CHANNEL"
BuffDuty.WHISPER_CHANNEL_TYPE = "WHISPER"
BuffDuty.BG_CHANNEL_TYPE = "INSTANCE_CHAT"

BuffDuty.MAGE_CLASS = "MAGE"
BuffDuty.PRIEST_CLASS = "PRIEST"
BuffDuty.DRUID_CLASS = "DRUID"

BuffDuty.SUPPORTED_CLASSES = { [BuffDuty.MAGE_CLASS] = true, [BuffDuty.PRIEST_CLASS] = true,
                               [BuffDuty.DRUID_CLASS] = true }

BuffDuty.SUPPORTED_CHANNELS = { [BuffDuty.SAY_CHANNEL_TYPE] = true, [BuffDuty.RAID_CHANNEL_TYPE] = true,
                                [BuffDuty.CUSTOM_CHANNEL_TYPE] = true, [BuffDuty.WHISPER_CHANNEL_TYPE] = true }

local function expandClassArg(input)
    if (input == "M") then
        return BuffDuty.MAGE_CLASS
    end
    if (input == "P") then
        return BuffDuty.PRIEST_CLASS
    end
    if (input == "D") then
        return BuffDuty.DRUID_CLASS
    end
    return input
end

local function expandChannelTypeArg(input)
    if (input == "S") then
        return BuffDuty.SAY_CHANNEL_TYPE
    end
    if (input == "C") then
        return BuffDuty.CUSTOM_CHANNEL_TYPE
    end
    if (input == "W") then
        return BuffDuty.WHISPER_CHANNEL_TYPE
    end
    if (input == "R") then
        return BuffDuty.RAID_CHANNEL_TYPE
    end
    return input
end

local function selectChannelType(input)
    if (input == BuffDuty.RAID_CHANNEL_TYPE) then
        local inInstance, instanceType = IsInInstance()
        -- if a person is in BG - use the battleground channel
        if (inInstance and instanceType == "pvp") then
            return BuffDuty.BG_CHANNEL_TYPE
        end
    end
    return input
end

function BuffDuty:convertArgs(class, ch_type, channel_name)
    if not class then
        class = BuffDuty.MAGE_CLASS
    end
    if not ch_type then
        ch_type = BuffDuty.WHISPER_CHANNEL_TYPE
    end

    class, ch_type = class:upper(), ch_type:upper()
    class = expandClassArg(class)
    ch_type = expandChannelTypeArg(ch_type)
    ch_type = selectChannelType(ch_type)
    if ch_type == BuffDuty.CUSTOM_CHANNEL_TYPE then
        channel_name = GetChannelName(channel_name)
    end
    return class, ch_type, channel_name
end

function BuffDuty:validateArgs(class, ch_type, channel_name)
    if not BuffDuty.SUPPORTED_CLASSES[class] then
        error("Class \"" .. class .. "\" is not supported.")
    end
    if not BuffDuty.SUPPORTED_CHANNELS[ch_type] then
        error("Channel \"" .. ch_type .. "\" is not supported.")
    end
    if ch_type == BuffDuty.CUSTOM_CHANNEL_TYPE then
        if channel_name == nil or channel_name == '' or channel_name == 0 then
            error("Channel name specified for custom channel was not found.")
        end
    end
end

function BuffDuty:convertPlayerList(identifier, input)
    if not input then
        return {}
    end
    local result = {}
    local players = string.gsub(input, identifier .. "\{(.*)\}", "%1")
    for value in string.gmatch(players, '([^,]+)') do
        table.insert(result, value)
    end
    return result
end

function Console.parseMessageCommand(cmd, ...)
    local arg = {...} -- Arg list
    local idx = 1 -- Current Arg index

    local function arg_valid(i)
        i = i or idx
        return (arg[i] and not (i == #arg)) -- Not nil, and ignore the last Arg that AceConsole appends
    end
    
    -- Print Usage Help
    if arg[1] == "?" then
        BuffDuty.printInfoMessage("Usage: /buffduty-msg [options]")
        BuffDuty.printInfoMessage("reset | Resets all messages to default values")
        BuffDuty.printInfoMessage("public-title \"value\" | Sets public title message format to \"value\"")
        BuffDuty.printInfoMessage("duty-line \"value\" | Sets duty line message format to \"value\"")
        BuffDuty.printInfoMessage("duty-whisper \"value\" | Sets duty whisper message format to \"value\"")
        BuffDuty.printInfoMessage("single-title \"value\" | Sets single title message format to \"value\"")
        BuffDuty.printInfoMessage("single-whisper \"value\" | Sets single whisper message format to \"value\"")
        return false
    end
    
    -- Options
    while arg_valid() do
        local tag = string.match(arg[idx], "^[%a%-]+") -- Match starting letters including '-' and '?'
        -- Reset All
        if tag == "reset" then
            cmd.reset_all = true
        -- Public Title
        elseif tag == "public-title" or tag == "-pt" then
            idx = idx + 1 -- next arg
            if arg_valid() then
                local ok, error = BuffDuty.Messages.validatePublicTitle(arg[idx])
                if ok then
                    cmd.public_title = arg[idx]
                else
                    BuffDuty.printErrorMessage(error)
                    return false
                end
            else
                BuffDuty.printErrorMessage("Invalid or missing "..tag.." value")
            end
        -- Duty Line
        elseif tag == "duty-line" or tag == "-dl" then
            idx = idx + 1 -- next arg
            if arg_valid() then
                local ok, error = BuffDuty.Messages.validateDutyLine(arg[idx])
                if ok then
                    cmd.duty_line = arg[idx]
                else
                    BuffDuty.printErrorMessage(error)
                    return false
                end
            else
                BuffDuty.printErrorMessage("Invalid or missing "..tag.." value")
            end
        -- Duty Whisper
        elseif tag == "duty-whisper" or tag == "-dw" then
            idx = idx + 1 -- next arg
            if arg_valid() then
                local ok, error = BuffDuty.Messages.validateDutyWhisper(arg[idx])
                if ok then
                    cmd.duty_whisper = arg[idx]
                else
                    BuffDuty.printErrorMessage(error)
                    return false
                end
            else
                BuffDuty.printErrorMessage("Invalid or missing "..tag.." value")
            end
        -- Single Title
        elseif tag == "single-title" or tag == "-st" then
            idx = idx + 1 -- next arg
            if arg_valid() then
                local ok, error = BuffDuty.Messages.validateSingleTitle(arg[idx])
                if ok then
                    cmd.single_title = arg[idx]
                else
                    BuffDuty.printErrorMessage(error)
                    return false
                end
            else
                BuffDuty.printErrorMessage("Invalid or missing "..tag.." value")
            end
        -- Single Whisper
        elseif tag == "single-whisper" or tag == "-sw" then
            idx = idx + 1 -- next arg
            if arg_valid() then
                local ok, error = BuffDuty.Messages.validateSingleWhisper(arg[idx])
                if ok then
                    cmd.single_whisper = arg[idx]
                else
                    BuffDuty.printErrorMessage(error)
                    return false
                end
            else
                BuffDuty.printErrorMessage("Invalid or missing "..tag.." value")
            end
        end
        idx = idx + 1
    end
    return true
end

