BuffDuty = LibStub("AceAddon-3.0"):NewAddon("BuffDuty", "AceConsole-3.0")
local CHAT_COMMAND = "buffduty"

function BuffDuty:OnInitialize()
    self:RegisterChatCommand(CHAT_COMMAND, "Command")
end


local function executeLogic(input)
    local class, ch_type, channel_name = LibStub("AceConsole-3.0"):GetArgs(input, 3)
    class, ch_type, channel_name = BuffDuty:convertArgs(class, ch_type, channel_name)
    BuffDuty:validateArgs(class, ch_type, channel_name)
    local duties = BuffDuty:getDutiesTable(class)
    BuffDuty:printDuties(class, duties, ch_type, channel_name)
end

function BuffDuty:Command(input)
    local status, err = pcall(executeLogic, input)
    if (not status) then
        print("Error while running BuffDuty: \n" .. err)
    end
end