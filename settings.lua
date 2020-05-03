DutyAssign.settings = {}

local defaultPublicTitle = "Dear $class$s, please support our raid with your buffs, love and care!"
local defaultSingleTitle = "Looks like we only have one $class in the raid today. {rt1}$name{rt1}, dear, would you kindly provide everyone with your wonderful buffs!"
local defaultWhisperMessage = "Thank you $name, for supporting our raid today! Would you kindly attend to buffing group$s $groups when you are able."
local defaultWhisperSingle = "Dear $name, looks like you are the only $class in the raid today, would you kindly provide everyone with your wonderful buffs!"
local defaultDutyLine = "{rt$i}_$name_{rt$i}_-_Group$s_$groups"

function DutyAssign.settings.setDefaults()
    -- Message Prefixs
    DutyAssign.message_info_format = "|cffff9d00Duty Assign|r |cffffff00%s|r"
    DutyAssign.message_debug_format = "|cffff9d00Duty Assign|r |cffdddddd<DEBUG>%s|r"
    DutyAssign.message_error_format = "|cffff9d00Duty Assign|r |cffff5555ERROR! %s|r"
    -- Fixed messages
    DutyAssign.message_group_too_small = "Current Group/Raid is too small. No sense in assigning buffs."
    DutyAssign.message_no_class_players = "No %ss to do buffs :("
    DutyAssign.message_title = "(Duty Assignment) • %s  •"
    -- Settable messages
    DutyAssign.public_title = defaultPublicTitle
    DutyAssign.single_title = defaultSingleTitle
    DutyAssign.whisper_message = defaultWhisperMessage
    DutyAssign.whisper_single = defaultWhisperSingle
    DutyAssign.duty_line = defaultDutyLine
end

function DutyAssign.settings.write(cmd)
    -- Messages
    if cmd.public_title then
        if cmd.public_title == "default" then
            DutyAssign.public_title = defaultPublicTitle
            DutyAssign.db.global.public_title = nil
        else
            DutyAssign.public_title = cmd.public_title
            DutyAssign.db.global.public_title = DutyAssign.public_title
        end
        DutyAssign.printInfoMessage(string.format("General Title format set to: %s", DutyAssign.public_title))
    end

    if cmd.single_title then
        if cmd.single_title == "default" then
            DutyAssign.single_title = defaultSingleTitle
            DutyAssign.db.global.single_title = nil
        else
            DutyAssign.single_title = cmd.single_title
            DutyAssign.db.global.single_title = DutyAssign.single_title
        end
        DutyAssign.printInfoMessage(string.format("Single Title format set to: %s", DutyAssign.single_title))
    end

    if cmd.whisper_message then
        if cmd.whisper_message == "default" then
            DutyAssign.whisper_message = defaultWhisperMessage
            DutyAssign.db.global.whisper_message = nil
        else
            DutyAssign.whisper_message = cmd.whisper_message
            DutyAssign.db.global.whisper_message = DutyAssign.whisper_message
        end
        DutyAssign.printInfoMessage(string.format("Whisper message format set to: %s", DutyAssign.whisper_message))
    end

    if cmd.whisper_single then
        if cmd.whisper_single == "default" then
            DutyAssign.whisper_single = defaultWhisperSingle
            DutyAssign.db.global.whisper_single = nil
        else
            DutyAssign.whisper_single = cmd.whisper_single
            DutyAssign.db.global.whisper_single = DutyAssign.whisper_single
        end
        DutyAssign.printInfoMessage(string.format("Whisper single format set to: %s", DutyAssign.whisper_single))
    end

    if cmd.duty_line then
        if cmd.duty_line == "default" then
            DutyAssign.duty_line = defaultDutyLine
            DutyAssign.db.global.duty_line = nil
        else
            DutyAssign.duty_line = cmd.duty_line
            DutyAssign.db.global.duty_line = DutyAssign.duty_line
        end
        DutyAssign.printInfoMessage(string.format("Duty Line format set to: %s", DutyAssign.duty_line))
    end
end

function DutyAssign.settings.load()
    -- Load from AceDB
    if DutyAssign.db.global.public_title then
        DutyAssign.public_title = DutyAssign.db.global.public_title
    end
    if DutyAssign.db.global.single_title then
        DutyAssign.single_title = DutyAssign.db.global.single_title
    end
    if DutyAssign.db.global.whisper_message then
        DutyAssign.whisper_message = DutyAssign.db.global.whisper_message
    end
    if DutyAssign.db.global.whisper_single then
        DutyAssign.whisper_single = DutyAssign.db.global.whisper_single
    end
    if DutyAssign.db.global.duty_line then
        DutyAssign.duty_line = DutyAssign.db.global.duty_line
    end
end