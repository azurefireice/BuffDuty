BuffDuty = LibStub("AceAddon-3.0"):NewAddon("BuffDuty", "AceConsole-3.0")
local CHAT_COMMAND = "buffduty"
local defaults = {
    factionrealm = {
        duties_cache = {}
    }
}

function BuffDuty:OnInitialize()
    self:init()
end

function BuffDuty:init()
    self:RegisterChatCommand(CHAT_COMMAND, "Command")

    --Init DataBase
    self.db = LibStub("AceDB-3.0"):New("BuffDutyDB", defaults)
    BuffDuty.Cache.duties_cache = self.db.factionrealm.duties_cache
end

local function executeLogic(input)
    -- Checks whether makes sense to assign people
    if (GetNumGroupMembers() < 10) then
        BuffDuty:printInfoMessage("Current Group/Raid is too small. No sense in assigning buffs.")
        return
    end

    -- Logic execution
    local class, ch_type, channel_name, excluded, order = LibStub("AceConsole-3.0"):GetArgs(input, 5)
    class, ch_type, channel_name = BuffDuty:convertArgs(class, ch_type, channel_name)
    BuffDuty:validateArgs(class, ch_type, channel_name)
    if ch_type ~= BuffDuty.CUSTOM_CHANNEL_TYPE then
        order = excluded
        excluded = channel_name
    end
    if excluded and string.sub(excluded, 1, 1) == "o" then
        order = excluded
    end
    excluded = BuffDuty:convertPlayerList("e", excluded)
    order = BuffDuty:convertPlayerList("o", order)
    local duties = {}

    if (BuffDuty.Cache:cacheContains(class, excluded) and next(BuffDuty.Cache:getFromCache(class, excluded))) then
        duties = BuffDuty.Cache:getFromCache(class, excluded)
    else
        duties = BuffDuty:getDutiesTable(class, excluded, order)
        BuffDuty.Cache:addToCache(class, excluded, duties)
    end

    BuffDuty:printDuties(class, duties, ch_type, channel_name)
end

function BuffDuty:Command(input)
    local status, err = pcall(executeLogic, input)
    if (not status) then
        print("Error while executing BuffDuty: \n" .. err)
    end
end
