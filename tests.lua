---------------
--SETUP TESTS--
---------------
local mock_party_size
local mock_players_num

local CLASS_TO_TEST = "DRUID"
local CLASS_TO_TEST_REF = CLASS_TO_TEST:lower()


local mock_getNameClassGroup = function(self, idx)
    local num_groups = mock_party_size / 5
    local group = idx % num_groups + 1
    if group > BuffDuty.max_group then
        BuffDuty.max_group = group
    end
    if (idx <= mock_players_num) then
        return CLASS_TO_TEST_REF .. idx, CLASS_TO_TEST, group
    end
    return "NotA" .. CLASS_TO_TEST_REF, "!" .. CLASS_TO_TEST, group
end

function GetNumGroupMembers()
    return mock_party_size
end

local test_command = "buffduty-test"
function BuffDuty:OnInitialize()
    self:RegisterChatCommand(test_command, "TestCommand")
end

--function dump(o)
--    if type(o) == 'table' then
--        local s = '{ '
--        for k, v in pairs(o) do
--            if type(k) ~= 'number' then
--                k = '"' .. k .. '"'
--            end
--            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
--        end
--        return s .. '} '
--    else
--        return tostring(o)
--    end
--end


---------------
-- RUN TESTS --
---------------

local function test()
    BuffDuty["getNameClassGroup"] = mock_getNameClassGroup
    ---------------
    mock_party_size = 1
    mock_players_num = 0
    local duties = BuffDuty:getDutiesTable(CLASS_TO_TEST)
    assert(#duties == 0, "Duties are not empty, while group size and players are 0")
    ---------------
    mock_party_size = 10
    mock_players_num = 0
    duties = BuffDuty:getDutiesTable(CLASS_TO_TEST)
    assert(#duties == 0, "Duties are not empty, while no players to buff")
    ---------------
    mock_party_size = 10
    mock_players_num = 1
    duties = BuffDuty:getDutiesTable(CLASS_TO_TEST)
    print("Duties : " .. dump(duties))
    key, value = next(duties)
    assert(key == CLASS_TO_TEST_REF .. "1", "Duties are empty!")
    key, value = next(duties, key)
    assert(key == nil, "Duties cunt is > 2 while player is one!")
    ---------------
    mock_party_size = 10
    mock_players_num = 2
    duties = BuffDuty:getDutiesTable(CLASS_TO_TEST)
    key, value = next(duties)
    assert(key == CLASS_TO_TEST_REF .. "2", "Duties are empty!")
    key, value = next(duties, key)
    assert(key == CLASS_TO_TEST_REF .. "1", "Duties are < 2 while players are 2!")
    key, value = next(duties, key)
    assert(key == nil, "Duties are > 2 while players are 2!")
    ---------------
    mock_party_size = 40
    mock_players_num = 8
    duties = BuffDuty:getDutiesTable(CLASS_TO_TEST)
    local duties_count = 0
    for _, _ in pairs(duties) do
        duties_count = duties_count + 1
    end
    assert(duties_count == 8, "Duties are not 8 while players are 8!")
    ---------------
    mock_party_size = 40
    mock_players_num = 12
    duties = BuffDuty:getDutiesTable(CLASS_TO_TEST)
    duties_count = 0
    for _, _ in pairs(duties) do
        duties_count = duties_count + 1
    end
    assert(duties_count == 8, "Duties are not 8 while players are 12!")
    ---------------
    mock_party_size = 40
    mock_players_num = 8
    duties = BuffDuty:getDutiesTable(CLASS_TO_TEST, { "druid1", "druid2" })
    duties_count = 0
    for _, _ in pairs(duties) do
        duties_count = duties_count + 1
    end
    key, value = next(duties)
    assert(key == CLASS_TO_TEST_REF .. "5", "Expected druid5 to be first in duty list, got another.")
    key, value = next(duties, key)
    assert(key == CLASS_TO_TEST_REF .. "6", "Expected druid6 to be first in duty list, got another.")
    assert(duties_count == 6, "Duties are not 6 while players are 8 and 2 are excluded!")
    ---------------
    mock_party_size = 40
    mock_players_num = 8
    duties = BuffDuty:getDutiesTable(CLASS_TO_TEST, { "druid1", "druid2", "druid3" }, { "druid3", "druid4" })
    duties_count = 0
    for _, _ in pairs(duties) do
        duties_count = duties_count + 1
    end
    assert(duties_count == 5, "Duties are not 6 while players are 8 and 2 are excluded!")
    ---------------
end


function BuffDuty:TestCommand(input)
    local status, err = pcall(test)
    if(status) then
        print("All tests successful!")
    else
        print("Error while running BuffDuty tests: \n"..err)
    end
end
