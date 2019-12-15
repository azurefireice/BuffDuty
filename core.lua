local addonName = "BuffDuty"
BuffDuty = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0")
local command = "buffduty"

local SAY_CHANNEL_TYPE = "SAY"
local RAID_CHANNEL_TYPE = "RAID"
local BG_CHANNEL_TYPE = "INSTANCE_CHAT"

function BuffDuty:OnInitialize()
    self:RegisterChatCommand(command, "Command")
end

local function selectChannelType(input)
    if (input == "s" or input == "say") then
       return SAY_CHANNEL_TYPE
    end

    -- if (input == "r" or input == "raid") then

    local inInstance, instanceType = IsInInstance()
    -- if a person is in BG - use the battleground channel
    if(inInstance and instanceType == "pvp") then
        return BG_CHANNEL_TYPE
    end

    return RAID_CHANNEL_TYPE
end

local function executeLogic(input)
    local channel_type = selectChannelType(input)
    local duties = BuffDuty:getDutiesTable()
    BuffDuty:printDuties(duties, channel_type)
end

function BuffDuty:Command(input)
    local status, err = pcall(executeLogic, input)
    if (not status) then
        print("Error while running BuffDuty: \n" .. err)
    end
end