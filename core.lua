BuffDuty = LibStub("AceAddon-3.0"):NewAddon("BuffDuty", "AceConsole-3.0")
local DUTY_COMMAND = "buffduty"
local MESSAGE_COMMAND = "buffduty-msg"
local defaults = {
    factionrealm = {
        duties_cache = {},
        custom_messages = {}
    }
}

function BuffDuty:OnInitialize()
    self:init()
end

function BuffDuty:init()
    self:RegisterChatCommand(DUTY_COMMAND, "CommandDuty")
    self:RegisterChatCommand(MESSAGE_COMMAND, "CommandMessage")

    --Init DataBase
    self.db = LibStub("AceDB-3.0"):New("BuffDutyDB", defaults)
    BuffDuty.Cache.duties_cache = self.db.factionrealm.duties_cache
    BuffDuty.Messages.custom_messages = self.db.factionrealm.custom_messages

    BuffDuty.Messages:Initialise()
    BuffDuty.Messages:Load()
end

local function executeDuty(input)
    -- Checks whether makes sense to assign people
    if (GetNumGroupMembers() < 10) then -- WOW API: https://wowwiki.fandom.com/wiki/API_GetNumGroupMembers
        BuffDuty.printInfoMessage("Current Group/Raid is too small. No sense in assigning buffs.")
        return
    end

    local cmd = {
        -- Base args, listed here for reference
        class = nil,
        channel_type = nil,
        channel_id = nil,
        -- Tables
        excluded = {},
        order = {},
        assign = {},
        own_group = {},
        -- Custom message settings, listed here for reference
        public_title = nil,
        duty_line = nil,
        duty_whisper = nil,
        single_message = nil,
        single_whisper = nil,
        -- Flags
        Cache = true,
        debug = false,
    }

    if BuffDuty.Console.parseDutyCommand(cmd, LibStub("AceConsole-3.0"):GetArgs(input, 20)) then
        local raid_info, class_players = BuffDuty.RaidInfo.Scan(cmd.class, cmd.excluded)

        local duties = nil
        if cmd.cache then
            duties = BuffDuty.Cache:getFromCache(cmd, raid_info, class_players)
        end
        if not duties then
            duties = BuffDuty.getDutiesTable(cmd, raid_info, class_players)
            BuffDuty.Cache:addToCache(cmd, raid_info, class_players, duties)
        end

        BuffDuty.printDuties(cmd, cmd.channel_type, cmd.channel_id, duties)
    end
end

function BuffDuty:CommandDuty(input)
    local status, err = pcall(executeDuty, input)
    if (not status) then
        print("Error while executing BuffDuty: \n" .. err)
    end
end

local function executeMessage(input)
    local cmd = {
        -- Custom message settings, listed here for reference
        public_title = nil,
        duty_line = nil,
        duty_whisper = nil,
        single_message = nil,
        single_whisper = nil,
        -- Reset flag list
        reset = nil,
        -- Flags
        verbose = false
    }

    if(BuffDuty.Console.parseMessageCommand(cmd, LibStub("AceConsole-3.0"):GetArgs(input, 14))) then
        if cmd.reset then
            BuffDuty.Messages:Reset(cmd.reset, cmd.verbose)
        end
        BuffDuty.Messages:Save(cmd)
    end
end

function BuffDuty:CommandMessage(input)
    local status, err = pcall(executeMessage, input)
    if (not status) then
        print("Error while executing BuffDuty Message: \n" .. err)
    end
end
