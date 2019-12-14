local MAX_GROUPS = 8
local welcome_message1 = "Dear mages, let's support our raid with buffs, decurses and tasty water!"
local welcome_message2 = "Please see the assignments below:"

function getNameClass(idx)
    local name, r, sg, lvl, cls_loc, cls = GetRaidRosterInfo(idx)
    return name, cls
end

function getDutiesTable()
    local m_count = GetNumGroupMembers()
    local mages = {}
    local groups = {}
    local duties = {}

    for i = 1, m_count, 1 do
        local name, class = getNameClass(i)
        if (class == "MAGE") then
            table.insert(mages, name)
        end
    end
    --print("BUffDuty raid mages:" .. dump(mages))

    for i = 1, MAX_GROUPS, 1 do
        table.insert(groups, "Group" .. i)
    end

    --print("BUffDuty groups:" .. dump(groups))

    if (#mages == 0) then
        table.insert(duties, "No mages to do buffs/decurses.")
        return duties
    end

    if (#mages == 1) then
        local mage = mages[1]
        table.insert(duties, "A lucky mage, named " .. mage .. " is doing all buffing/decurses!")
        return duties
    end

    local duties_count = 0

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

function printDuties(duties_table, channel_type)
    SendChatMessage(welcome_message1, channel_type)
    SendChatMessage(welcome_message2, channel_type)
    for index, value in pairs(duties_table) do
        SendChatMessage(value, channel_type)
    end
end


-- Debug

--function dump(o)
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

