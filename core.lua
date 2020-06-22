BuffDuty = LibStub("AceAddon-3.0"):NewAddon("BuffDuty", "AceConsole-3.0")
BuffDuty.VERSION = {KEY="160", MAJOR=1, MINOR=6, PATCH=0}
local DUTY_COMMAND = "buffduty"
local MESSAGE_COMMAND = "buffduty-msg"
local defaults = {
    global = {
        version = {}
    },
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

    BuffDuty.Cache:Initialise()

    BuffDuty.Messages:Initialise()
    BuffDuty.Messages:Load()

    -- Version Update
    if not (self.db.global.version.KEY == BuffDuty.VERSION.KEY) then
        self.db.global.version = BuffDuty.VERSION -- Set updated version
    end
end

local function pack(...)
    return {...}
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
        order = nil,
        assign = nil,
        group_blacklist = nil,
        group_whitelist = nil,
        -- Logic settings
        own_group = {},
        -- Custom message settings, listed here for reference
        public_title = nil,
        duty_line = nil,
        duty_whisper = nil,
        single_message = nil,
        single_whisper = nil,
        -- Flags
        cache = true,
        debug = false,
    }

    local max_args = 20
    local args = pack(LibStub("AceConsole-3.0"):GetArgs(input, max_args))
    if BuffDuty.Console.parseDutyCommand(cmd, args) then
        -- Scan the raid
        local raid_info, class_players = BuffDuty.RaidInfo.Scan(cmd.class, cmd.excluded, cmd.group_blacklist, cmd.group_whitelist)
        -- Check we have groups to assign
        if raid_info.group_count == 0 then
            BuffDuty.printInfoMessage("All raid groups excluded, no duties to assign.")
            return
        end
        local limited_duty = cmd.group_blacklist or cmd.group_whitelist
        
        -- Generate a cache hash key
        local cache_key = BuffDuty.Cache.generateHash(raid_info, class_players)
        -- Retrieve or generate duties
        local duties = nil
        if cmd.cache then
            duties = BuffDuty.Cache:GetDuties(cache_key)
        end
        if not duties then
            duties = BuffDuty.generateDuties(cmd, raid_info, class_players) -- NOTE: Logic polutes raid_info and class_players
            BuffDuty.Cache:AddEntry(cache_key, duties)
        end

        BuffDuty.printDuties(cmd, cmd.channel_type, cmd.channel_id, duties, limited_duty)
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

    local max_args = 14
    local args = pack(LibStub("AceConsole-3.0"):GetArgs(input, max_args))
    if BuffDuty.Console.parseMessageCommand(cmd, args) then
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
