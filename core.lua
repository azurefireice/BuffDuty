BuffDuty = LibStub("AceAddon-3.0"):NewAddon("BuffDuty", "AceConsole-3.0")
local CHAT_COMMAND = "buffduty"

function BuffDuty:OnInitialize()
    self:RegisterChatCommand(CHAT_COMMAND, "Command")
end

local function executeLogic(input)
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

    if (BuffDuty.Cache.cacheContains(class, excluded)) then
        local cached_duties = BuffDuty.Cache.getFromCache(class, excluded)
        BuffDuty:printDuties(class, cached_duties, ch_type, channel_name)
        return
    end

    local duties = BuffDuty:getDutiesTable(class, excluded, order)

    BuffDuty.Cache.addToCache(class, excluded, duties)

    BuffDuty:printDuties(class, duties, ch_type, channel_name)
end

function BuffDuty:Command(input)
    local status, err = pcall(executeLogic, input)
    if (not status) then
        print("Error while running BuffDuty: \n" .. err)
    end
end
