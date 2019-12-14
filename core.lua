local addonName = "BuffDuty"
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0")
local command = "buffduty"

function addon:OnInitialize()
    self:RegisterChatCommand(command, "Command")
end

function addon:Command(input)
    printDuties(getDutiesTable(), "SAY")
end