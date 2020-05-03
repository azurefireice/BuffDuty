DutyAssign = LibStub("AceAddon-3.0"):NewAddon("DutyAssign", "AceConsole-3.0")
local CHAT_COMMAND = "duty"

function DutyAssign:OnInitialize()
    self:RegisterChatCommand(CHAT_COMMAND, "Command")
    self.db = LibStub("AceDB-3.0"):New("DutyAssignDB")
end

function DutyAssign:OnEnable()
    DutyAssign.settings.setDefaults()
    DutyAssign.settings.load()
end

-- Supported chat channels
DutyAssign.SAY_CHANNEL_TYPE = "SAY"
DutyAssign.RAID_CHANNEL_TYPE = "RAID"
DutyAssign.CUSTOM_CHANNEL_TYPE = "CHANNEL"
DutyAssign.WHISPER_CHANNEL_TYPE = "WHISPER"
DutyAssign.BG_CHANNEL_TYPE = "INSTANCE_CHAT"

DutyAssign.SUPPORTED_CHANNELS = { [DutyAssign.SAY_CHANNEL_TYPE] = true, [DutyAssign.RAID_CHANNEL_TYPE] = true,
                                [DutyAssign.CUSTOM_CHANNEL_TYPE] = true, [DutyAssign.WHISPER_CHANNEL_TYPE] = true }

-- Supported classes
DutyAssign.MAGE_CLASS = "MAGE"
DutyAssign.PRIEST_CLASS = "PRIEST"
DutyAssign.DRUID_CLASS = "DRUID"

DutyAssign.SUPPORTED_CLASSES = { [DutyAssign.MAGE_CLASS] = true, [DutyAssign.PRIEST_CLASS] = true,
                               [DutyAssign.DRUID_CLASS] = true }

-- Global functions
function DutyAssign.getNameClassGroup(idx)
    local name, rank, sub_group, level, class_loc, class = GetRaidRosterInfo(idx)
    return name, class, sub_group
end

-- Global print functions
function DutyAssign.printInfoMessage(msg)
    print(string.format(DutyAssign.message_info_format, msg))
end

function DutyAssign.printDebugMessage(msg)
    print(string.format(DutyAssign.message_debug_format, msg))
end

function DutyAssign.printErrorMessage(msg)
    print(string.format(DutyAssign.message_error_format, msg))
end

-- Replace macros, e.g. $name, with values from the given table
function DutyAssign.macroReplace(input, tbl_replace, is_final)
    tbl_replace = tbl_replace or {}
    tbl_replace["i"] = tbl_replace["i"] or "1" -- Ensure we replace {rt$i} macros with a valid symbol
    input = string.gsub(input, "$(%w+)", tbl_replace) -- Substitute custom words starting with $, e.g. $name
    input = string.gsub(input, "_", " ") -- Replace Underscore with Space
    if is_final then
        input = string.gsub(input, "%$", "") -- Remove any left over $ symbols
    end
    return input
end

local function string_title_case(input)
    local function tchelper(first, rest)
        return first:upper()..rest:lower()
    end
    
    return string.gsub(input, "(%a)([%w_']*)", tchelper)
end

function DutyAssign.printDuties(cmd, duty_table)
    if not duty_table then return end

    local duty_count = 0
    for _ in pairs(duty_table) do
        duty_count = duty_count + 1
    end
    
    if duty_count == 0 then return end
    
    local duty_info = {}
    duty_info["class"] = string_title_case(cmd.class)
    duty_info["s"] = (duty_count > 1) and "s" or ""

    for _, channel_type in ipairs(cmd.channel_types) do
        -- Single class player
        if duty_count == 1 then
            local player_name, player_info = next(duty_table)
            if channel_type == DutyAssign.WHISPER_CHANNEL_TYPE then
                local whisper_single = cmd.whisper_single or DutyAssign.whisper_single
                player_info["class"] = duty_info["class"] -- Add the class to the players info
                whisper_single = DutyAssign.macroReplace(whisper_single, player_info, true)
                SendChatMessage(whisper_single, DutyAssign.WHISPER_CHANNEL_TYPE, nil, player_name)
            else
                local single_title = string.format(DutyAssign.message_title, cmd.single_title or DutyAssign.single_title)
                duty_info["name"] = player_name -- Add the players name to the duty info
                single_title = DutyAssign.macroReplace(single_title, duty_info, true)
                SendChatMessage(single_title, channel_type, nil, cmd.channel_name)
            end
        else -- Multiple class players
            if channel_type == DutyAssign.WHISPER_CHANNEL_TYPE then 
                local whisper_message = cmd.whisper_message or DutyAssign.whisper_message
                for player_name, player_info in pairs(duty_table) do -- Whisper each player
                    if not (player_name == UnitName("player")) then -- No need to whisper yourself
                        local duty_message = DutyAssign.macroReplace(whisper_message, player_info, true)
                        SendChatMessage(duty_message, DutyAssign.WHISPER_CHANNEL_TYPE, nil, player_name)
                    end
                end
            else -- Public channel
                local public_title = string.format(DutyAssign.message_title, cmd.public_title or DutyAssign.public_title)
                public_title = DutyAssign.macroReplace(public_title, duty_info, true)
                SendChatMessage(public_title, channel_type, nil, cmd.channel_name)
                -- Duty lines
                for player_name, player_info in pairs(duty_table) do
                    local duty_message = cmd.duty_line or DutyAssign.duty_line
                    duty_message = DutyAssign.macroReplace(duty_message, player_info, true)
                    SendChatMessage(duty_message, channel_type, nil, cmd.channel_name)
                end
            end
        end
    end
end

-- Console
local function executeConsole(input)
    local cmd = {
        -- Base args, listed here for reference
        class = nil,
        channel_types = {},
        channel_name = nil,
        -- Chat settings, listed here for reference
        single_title = nil,
        public_title = nil,
        whisper_message = nil,
        whisper_single = nil,
        duty_line = nil,
        -- Tables
        excluded = {},
        assign = {},
        -- flags
        write_settings = false,
        debug = false,
    }

    if DutyAssign.Console.parseArgs(cmd, LibStub("AceConsole-3.0"):GetArgs(input, 20)) then
        if cmd.write_settings then
            DutyAssign.settings.write(cmd)
        else
            local duty_table = DutyAssign.generateDutyTable(cmd)
            DutyAssign.printDuties(cmd, duty_table)
        end
    end
end

function DutyAssign:Command(input)
    local status, err = pcall(executeConsole, input)
    if (not status) then
        print("Error while running DutyAssign: \n" .. err)
    end
end

