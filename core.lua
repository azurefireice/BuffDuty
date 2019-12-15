local addonName = "BuffDuty"
BuffDuty = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0")
local command = "buffduty"
local getDutiesTable, printDuties

local SAY_CHANNEL_TYPE = "SAY"
local RAID_CHANNEL_TYPE = "RAID"


function BuffDuty:OnInitialize()
    self:RegisterChatCommand(command, "Command")
end

local function executeLogic(input)
    local channel_type = RAID_CHANNEL_TYPE
    if(input == "s" or input == "say") then channel_type = SAY_CHANNEL_TYPE end
    if(input == "r" or input == "raid") then channel_type = RAID_CHANNEL_TYPE end
    local duties = BuffDuty:getDutiesTable()
    BuffDuty:printDuties(duties, channel_type)
end

function BuffDuty:Command(input)
    local status, err = pcall(executeLogic, input)
    if(not status) then
        print("Error while running BuffDuty: \n"..err)
    end
end