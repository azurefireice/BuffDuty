-- Print message functions
local function printInfoMessage(msg, color)
    color = color or "ffffff00"
    print(string.format("|cffffe00a•|r|cffd0021aBuff|r|cffff9d00Duty|r|cffffe00a•|r |c%s%s|r", color, msg))
end
BuffDuty.printInfoMessage = printInfoMessage

local function printDebugMessage(msg)
    print(string.format("|cffffe00a•|r|cffd0021aBuff|r|cffff9d00Duty|r|cffffe00a•|r |cffdddddd<DEBUG>%s|r", msg))
end
BuffDuty.printDebugMessage = printDebugMessage

local function printErrorMessage(msg)
    print(string.format("|cffffe00a•|r|cffd0021aBuff|r|cffff9d00Duty|r|cffffe00a•|r |cffff5555!ERROR! %s|r", msg))
end
BuffDuty.printErrorMessage = printErrorMessage

-- Replace macros, e.g. $name, with values from the given table
local function macroReplace(input, macro_table)
    macro_table = macro_table or {}
    macro_table["i"] = macro_table["i"] or "1" -- Ensure we always replace {rt$i} macros with a valid symbol
    input = string.gsub(input, "$(%w+)", macro_table) -- Replace $macro words with table values
    input = string.gsub(input, "_", " ") -- Replace _ (underscore) with a space
    return input
end

function BuffDuty.printDuties(cmd, channel_type, channel_id, duty_table)
    if not duty_table then return end

    -- Local aliases
    local utils = BuffDuty.Utils
    local messages = BuffDuty.Messages

    -- Scan duty table
    local duty_count = 0
    for _ in pairs(duty_table) do
        duty_count = duty_count + 1
    end
    
    -- No player has been assinged buffing duty
    if duty_count == 0 then 
        printInfoMessage(string.format("No %ss to do buffs :(", utils.stringTitleCase(cmd.class)))
        return 
    end

    -- Setup duty macros
    local duty_macros = {}
    duty_macros["class"] = utils.stringTitleCase(cmd.class)
    duty_macros["s"] = (duty_count > 1) and "s" or ""

    -- Only a single player has been assigned buffing duty
    if duty_count == 1 then
        local player_name, player_macros = next(duty_table)
        if channel_type == BuffDuty.WHISPER_CHANNEL_TYPE then
            local single_whisper = cmd.single_whisper or messages.single_whisper
            player_macros["class"] = duty_macros["class"] -- Add the "class" to the player macros
            single_whisper = macroReplace(single_whisper, player_macros)
            if player_name == UnitName("player") then -- Print info message instead of whispering yourself
                printInfoMessage(single_whisper, "ffff78ea")
            else
                single_whisper = string.format(messages.message_title, single_whisper)
                SendChatMessage(single_whisper, BuffDuty.WHISPER_CHANNEL_TYPE, nil, player_name)
            end
        else -- Public channel
            local single_message = string.format(messages.message_title, cmd.single_message or messages.single_message)
            duty_macros["name"] = player_name -- Add the player "name" to the duty info
            single_message = macroReplace(single_message, duty_macros)
            SendChatMessage(single_message, channel_type, nil, channel_id)
        end
        return
    end

    -- Multiple players have been assinged buffing duty
    if channel_type == BuffDuty.WHISPER_CHANNEL_TYPE then 
        local whisper_message = cmd.duty_whisper or messages.duty_whisper
        for player_name, player_macros in pairs(duty_table) do -- For each player
            local duty_whisper = macroReplace(whisper_message, player_macros)
            if player_name == UnitName("player") then -- Print info message instead of whispering yourself
                printInfoMessage(duty_whisper, "ffff78ea")
            else
                whisper_message = string.format(messages.message_title, whisper_message)
                SendChatMessage(duty_whisper, BuffDuty.WHISPER_CHANNEL_TYPE, nil, player_name)
            end
        end
    else -- Public channel
        local public_title = string.format(messages.message_title, cmd.public_title or messages.public_title)
        public_title = macroReplace(public_title, duty_macros)
        SendChatMessage(public_title, channel_type, nil, channel_id)
        -- Duty lines
        for player_name, player_macros in pairs(duty_table) do
            local duty_line = cmd.duty_line or messages.duty_line
            duty_line = macroReplace(duty_line, player_macros)
            SendChatMessage(duty_line, channel_type, nil, channel_id)
        end
    end
end
