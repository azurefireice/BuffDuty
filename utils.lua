local Utils = {}
BuffDuty.Utils = Utils

function Utils.tableContainsValue(table, val)
    if not table or not val then
        return false
    end
    for _, value in pairs(table) do
        if value:lower() == val:lower() then
            return true
        end
    end
    return false
end

function Utils.getTableSize(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function Utils.getTableKeys(table)
    local key_set = {}
    for k, v in pairs(table) do
        key_set[#key_set + 1] = k
    end
    return key_set
end

function Utils.getTableValues(table)
    local key_set = {}
    for k, v in pairs(table) do
        key_set[#key_set + 1] = v
    end
    return key_set
end

function Utils.sortStringArray(string_array)
    table.sort(string_array, function(a, b)
        return a:lower() < b:lower()
    end)
end
