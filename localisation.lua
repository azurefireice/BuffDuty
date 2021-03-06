-- CHANNELS
local CHANNELS = {}
CHANNELS.SAY = "SAY"
CHANNELS.RAID = "RAID"
CHANNELS.WHISPER = "WHISPER"
CHANNELS.CUSTOM = "CHANNEL"
CHANNELS.BATTLEGROUND = "INSTANCE_CHAT"
BuffDuty.CHANNELS = CHANNELS

local SUPPORTED_CHANNELS = {
    -- English
    ["SAY"] = CHANNELS.SAY,
    ["S"] = CHANNELS.SAY,
    ["RAID"] = CHANNELS.RAID,
    ["R"] = CHANNELS.RAID,
    ["WHISPER"] = CHANNELS.WHISPER,
    ["W"] = CHANNELS.WHISPER,
    ["CHANNEL"] = CHANNELS.CUSTOM,
    ["C"] = CHANNELS.CUSTOM,
    ["CUSTOM"] = CHANNELS.CUSTOM,
}
BuffDuty.SUPPORTED_CHANNELS = SUPPORTED_CHANNELS

-- CLASSES
local CLASSES = {}
-- English
CLASSES.MAGE = "MAGE"
CLASSES.PRIEST = "PRIEST"
CLASSES.DRUID = "DRUID"
CLASSES.PALADIN = "PALADIN"
CLASSES.HUNTER = "HUNTER"
CLASSES.ROGUE = "ROGUE"
CLASSES.SHAMAN = "SHAMAN"
CLASSES.WARLOCK = "WARLOCK"
CLASSES.WARRIOR = "WARRIOR"
BuffDuty.CLASSES = CLASSES

local SUPPORTED_CLASSES = { 
    -- English
    ["MAGE"] = CLASSES.MAGE,
    ["M"] = CLASSES.MAGE, -- Depricated
    ["PRIEST"] = CLASSES.PRIEST,
    ["P"] = CLASSES.PRIEST, -- Depricated
    ["DRUID"] = CLASSES.DRUID,
    ["D"] = CLASSES.DRUID, -- Depricated
    ["PALADIN"] = CLASSES.PALADIN,
    ["HUNTER"] = CLASSES.HUNTER,
    ["ROGUE"] = CLASSES.ROGUE,
    ["SHAMAN"] = CLASSES.SHAMAN,
    ["WARLOCK"] = CLASSES.WARLOCK,
    ["WARRIOR"] = CLASSES.WARRIOR,
}
BuffDuty.SUPPORTED_CLASSES = SUPPORTED_CLASSES
