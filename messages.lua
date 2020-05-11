local Messages = {}
BuffDuty.Messages = Messages

local setToDefault = "default"

local defaultPublicTitle = "Dear $class$s, please support our raid with your buffs, love and care!"
local defaultDutyLine = "Group$s $groups - {rt$i} $name {rt$i}"
local defaultDutyWhisper = "Thank you $name, for supporting our raid today! Would you kindly attend to buffing group$s $groups when you are able."
local defaultSingleTitle = "Looks like we only have one $class in the raid today. {rt1}$name{rt1}, dear, would you kindly provide everyone with your wonderful buffs!"
local defaultSingleWhisper = "Dear $name, looks like you are the only $class in the raid today, would you kindly provide everyone with your wonderful buffs!"

function Messages:Initialise()
    -- Fixed messages
    self.message_title = "(Buff Duty) • %s •"
    -- Settable messages
    self.public_title = defaultPublicTitle
    self.duty_line = defaultDutyLine
    self.duty_whisper = defaultDutyWhisper
    self.single_title = defaultSingleTitle
    self.single_whisper = defaultSingleWhisper
end

-- Validation functions return true = OK | false = Error and an error message
local function validatePublicTitle(public_title)
    if public_title == setToDefault then
        return true
    end
    return true
end
Messages.validatePublicTitle = validatePublicTitle

local function validateDutyLine(duty_line)
    if duty_line == setToDefault then
        return true
    end
    if not (string.find(duty_line, "$groups", 1, true) and string.find(duty_line, "$name", 1, true)) then
        error("Duty Line format must contain: $groups and $name", 2)
    end
    return true
end
Messages.validateDutyLine = validateDutyLine

local function validateDutyWhisper(duty_whisper)
    if duty_whisper == setToDefault then
        return true
    end
    if not (string.find(duty_whisper, "$groups", 1, true)) then
        error("Duty Whisper format must contain: $groups", 2)
    end
    return true
end
Messages.validateDutyWhisper = validateDutyWhisper

local function validateSingleTitle(single_title)
    if single_title == setToDefault then
        return true
    end
    if not (string.find(single_title, "$name", 1, true)) then
        error("Single Title format must contain: $name", 2)
    end
    return true
end
Messages.validateSingleTitle = validateSingleTitle

local function validateSingleWhisper(single_whisper)
    if single_whisper == setToDefault then
        return true
    end
    return true
end
Messages.validateSingleWhisper = validateSingleWhisper

-- Saves the given custom messages to persistant storage
function Messages:Save(cmd)
    -- Public Title
    if cmd.public_title then
        if cmd.public_title == setToDefault then
            self.public_title = defaultPublicTitle
            self.custom_messages.public_title = nil
        elseif validatePublicTitle(cmd.public_title) then
            self.public_title = cmd.public_title
            self.custom_messages.public_title = self.public_title
        else
            BuffDuty.printErrorMessage(string.format("Invalid Public Title format given: %s", cmd.public_title))
        end
        BuffDuty.printInfoMessage(string.format("Public Title set to: %s", self.public_title))
    end
    -- Duty Line
    if cmd.duty_line then
        if cmd.duty_line == setToDefault then
            self.duty_line = defaultDutyLine
            self.custom_messages.duty_line = nil
        elseif validateDutyLine(cmd.duty_line) then
            self.duty_line = cmd.duty_line
            self.custom_messages.duty_line = self.duty_line
        else
            BuffDuty.printErrorMessage(string.format("Invalid Duty Line format given: %s", cmd.duty_line))
        end
        BuffDuty.printInfoMessage(string.format("Duty Line set to: %s", self.duty_line))
    end
    -- Duty Whisper
    if cmd.duty_whisper then
        if cmd.duty_whisper == setToDefault then
            self.duty_whisper = defaultDutyWhisper
            self.custom_messages.duty_whisper = nil
        elseif validateDutyWhisper(cmd.duty_whisper) then
            self.duty_whisper = cmd.duty_whisper
            self.custom_messages.duty_whisper = self.duty_whisper
        else
            BuffDuty.printErrorMessage(string.format("Invalid Duty Whisper format given: %s", cmd.duty_whisper))
        end
        BuffDuty.printInfoMessage(string.format("Duty Whisper set to: %s", self.duty_whisper))
    end
    -- Single Title
    if cmd.single_title then
        if cmd.single_title == setToDefault then
            self.single_title = defaultSingleTitle
            self.custom_messages.single_title = nil
        elseif validateSingleTitle(cmd.single_title) then
            self.single_title = cmd.single_title
            self.custom_messages.single_title = self.single_title
        else
            BuffDuty.printErrorMessage(string.format("Invalid Single Title format given: %s", cmd.single_title))
        end
        BuffDuty.printInfoMessage(string.format("Single Title set to: %s", self.single_title))
    end
    -- Single Whisper
    if cmd.single_whisper then
        if cmd.single_whisper == setToDefault then
            self.single_whisper = defaultSingleWhisper
            self.custom_messages.single_whisper = nil
        elseif validateSingleWhisper(cmd.single_whisper) then
            self.single_whisper = cmd.single_whisper
            self.custom_messages.single_whisper = self.single_whisper
        else
            BuffDuty.printErrorMessage(string.format("Invalid Single Whisper format given: %s", cmd.single_whisper))
        end
        BuffDuty.printInfoMessage(string.format("Single Whisper set to: %s", self.single_whisper))
    end
end

-- Load custom messages from persistant storage
function Messages:Load()
    -- Public Title
    if self.custom_messages.public_title then
        self.public_title = self.custom_messages.public_title
    end
    -- Duty Line
    if self.custom_messages.duty_line then
        self.duty_line = self.custom_messages.duty_line
    end
    -- Duty Whipser
    if self.custom_messages.duty_whisper then
        self.duty_whisper = self.custom_messages.duty_whisper
    end
    -- Single Title
    if self.custom_messages.single_title then
        self.single_title = self.custom_messages.single_title
    end
    -- Single Whisper
    if self.custom_messages.single_whisper then
        self.single_whisper = self.custom_messages.single_whisper
    end
end

-- Reset custom messages to default
function Messages:Reset(flags, verbose)
    local all = flags["all"]
    verbose = verbose or (not all) -- print for single resets or forced verbose
    -- Public Title
    if all or flags["public-title"] then
        self.public_title = defaultPublicTitle
        self.custom_messages.public_title = nil
        if verbose then BuffDuty.printInfoMessage(string.format("Public Title reset to: %s", self.public_title)) end
    end
    -- Duty Line
    if all or flags["duty-line"] then
        self.duty_line = defaultDutyLine
        self.custom_messages.duty_line = nil
        if verbose then BuffDuty.printInfoMessage(string.format("Duty Line reset to: %s", self.duty_line)) end
    end
    -- Duty Whisper
    if all or flags["duty-whisper"] then
        self.duty_whisper = defaultDutyWhisper
        self.custom_messages.duty_whisper = nil
        if verbose then BuffDuty.printInfoMessage(string.format("Duty Whisper reset to: %s", self.duty_whisper)) end
    end
    -- Single Title
    if all or flags["single-title"] then
        self.single_title = defaultSingleTitle
        self.custom_messages.single_title = nil
        if verbose then BuffDuty.printInfoMessage(string.format("Single Title reset to: %s", self.single_title)) end
    end
    -- Single Whisper
    if all or flags["single-whisper"] then
        self.single_whisper = defaultSingleWhisper
        self.custom_messages.single_whisper = nil
        if verbose then BuffDuty.printInfoMessage(string.format("Single Whisper reset to: %s", self.single_whisper)) end
    end
    
    if all and (not verbose) then
        BuffDuty.printInfoMessage("All messages reset to default")
    end
end
