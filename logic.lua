local MAX_GROUPS = 8
local buff_duty_info_message_format = "|cffff9d00<|r|cffd0021aBuffDuty|r|cffff9d00>|r |cffffff00%s|r"
local title_message = "Dear mages, let's support our raid with buffs, de-curses and tasty water!"
local assignments_message = "Please see the assignments below:"
local group_too_small_message = "Current Group/Raid is too small. No sense in assigning buffs/de-curses."
local no_mages_message = "No mages to do buffs/de-curses."
local single_mage_message = "Looks like we have only 1 mage in the raid today! {rt1}%s{rt1}, dear, could you please do all the buffing/de-cursing?"

local function getNameClass(idx)
    local name, r, sg, lvl, cls_loc, cls = GetRaidRosterInfo(idx)
    return name, cls
end

local function printInfoMessage(msg)
    print(string.format(buff_duty_info_message_format, msg))
end

-- Debug

--local function dump(o)
--    if type(o) == 'table' then
--        local s = '{ '
--        for k,v in pairs(o) do
--            if type(k) ~= 'number' then k = '"'..k..'"' end
--            s = s .. '['..k..'] = ' .. dump(v) .. ','
--        end
--        return s .. '} '
--    else
--        return tostring(o)
--    end
--end


function BuffDuty:getDutiesTable()
    local m_count = GetNumGroupMembers()
    local mages = {}
    local groups = {}
    local duties = {}

    if (m_count < 10) then
        printInfoMessage(group_too_small_message)
        return {}
    end

    for i = 1, m_count, 1 do
        local name, class = getNameClass(i)
        if (class == "MAGE") then
            table.insert(mages, name)
        end
    end

    for i = 1, MAX_GROUPS, 1 do
        table.insert(groups, "Group" .. i)
    end


    if (#mages == 0) then
        printInfoMessage(no_mages_message)
        return {}
    end

    if (#mages == 1) then
        local mage = mages[1]
        table.insert(duties, string.format(single_mage_message, mage))
        return duties
    end

    for i = 1, MAX_GROUPS, 1 do
        local mage_ixd = i % #mages
        if (mage_ixd == 0) then
            mage_ixd = #mages
        end
        local mage = mages[mage_ixd]
        local group = groups[i]
        table.insert(duties, group .. "-" .. mage)
    end

    return duties
end

function BuffDuty:printDuties(duties_table, channel_type)
    if (#duties_table == 0) then
        return
    end

    if (#duties_table == 1) then
        SendChatMessage(duties_table[1], channel_type)
        return
    end

    SendChatMessage(title_message, channel_type)
    SendChatMessage(assignments_message, channel_type)
    for index, value in pairs(duties_table) do
        SendChatMessage(value, channel_type)
    end
end




