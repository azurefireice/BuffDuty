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