local Utils = {}
BuffDuty.Utils = Utils


function Utils.containsName(table, name, get_name_func)
    if not table or not name then
        return false
    end
    if not get_name_func then
        get_name_func = function(x) return x end
    end
    name = name:lower()
    for _, value in pairs(table) do
        if name == string.lower(get_name_func(value)) then
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

function Utils.stringSplit(input, seperator)
    local list = {}
    local idx = 0
    for value in string.gmatch(input, "([^"..seperator.."]+)") do -- Match all characters between seperators
        idx = idx + 1
        list[idx] = value
    end
    return list
end

function Utils.stringSplitAsFlags(input, separator)
    local list = {}
    for value in string.gmatch(input, "([^"..seperator.."]+)") do -- Match all characters between seperators
        if value and #value > 1 then
            list[value:lower()] = true
        end
    end
    return list
end

function Utils.stringTrim(value, start_patten, end_patten)
    start_patten = start_patten or "%s*" -- Default to whitespace characters
    end_patten = end_patten or "%s*"
    value = string.gsub(value, "^"..start_patten.."(.-)"..end_patten.."$", "%1")
    return value
end

function Utils.stringTitleCase(input)
    local function tchelper(first, rest)
        return first:upper()..rest:lower()
    end
    return string.gsub(input, "(%a)([%w_']*)", tchelper)
end
