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

-- Validate the argurment as not nil and not the final value that AceConsole appends
local function argValid(arg, idx)
    return (arg[idx] and not (idx == #arg)) 
end

-- Executes optional arguments
-- Optional arguments are indexed by tag and have the form:
-- option.has_value = true if the next argument is the value
-- option.validate = function(value) return ok, error_msg
-- option.onError = function(error) return isFatal
-- option.execute = function(cmd, value)
local function executeOptionalArgs(cmd, arg, idx, option_table)
    while argValid(arg, idx) do
        local tag = string.match(arg[idx], "^[%a%-]+") -- Match starting letters including '-'
        if tag then tag = tag:lower() end -- Make case insensitive
        local option = option_table[tag]
        -- Check that the option is valid
        if option then
            -- Check if the option has a following value
            if option.has_value then
                idx = idx + 1
                if not argValid(arg, idx) then
                    BuffDuty.printErrorMessage("Missing "..tag.." value")
                    return false
                end
            end
            -- Get the value
            local value = arg[idx]
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

function Console.parseMessageCommand(cmd, ...)
    local arg = {...} -- Argument list
    
    -- Local aliases
    local utils = BuffDuty.Utils

    -- Print Usage Help
    if arg[1] == "?" or arg[1] == "help" or arg[1] == "-h" then
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
    reset.execute = function(cmd, value) 
        cmd.reset = {}
        for _,flag in pairs(utils.stringSplit(value, ",")) do
            cmd.reset[flag] = true
        end
    end
    option_table["reset"] = reset
    option_table["-r"] = reset
    
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
    option_table["-st"] = single_message

    local single_whisper = {has_value = true}
    single_whisper.validate = BuffDuty.Messages.validateSingleWhisper
    single_whisper.execute = function(cmd, value) cmd.single_whisper = value end
    option_table["single-whisper"] = single_whisper
    option_table["-sw"] = single_whisper

    return executeOptionalArgs(cmd, arg, 1, option_table)
end
