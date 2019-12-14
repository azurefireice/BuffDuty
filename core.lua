local addonName = "BuffDuty"
BuffDuty = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0")
local command = "buffduty"
local getDutiesTable, printDuties

function BuffDuty:OnInitialize()
    self:RegisterChatCommand(command, "Command")
end

function BuffDuty:Command(input)
    local duties = BuffDuty:getDutiesTable()
    BuffDuty:printDuties(duties, "SAY")
end