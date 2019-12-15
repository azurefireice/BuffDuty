---------------
--SETUP TESTS--
---------------
local mock_party_size
local mock_mages_num

local mock_getNameClass = function (self, idx)
    if(idx <= mock_mages_num) then return "Mage"..idx, "MAGE" end
    return "NotAMage", "!MAGE"
end

function GetNumGroupMembers()
    return mock_party_size
end

local test_command = "buffduty-test"
function BuffDuty:OnInitialize()
    self:RegisterChatCommand(test_command, "TestCommand")
end

---------------
-- RUN TESTS --
---------------

local function test()
    BuffDuty["getNameClass"] = mock_getNameClass
    ---------------
    mock_party_size = 0
    mock_mages_num = 0
    local duties = BuffDuty:getDutiesTable()
    assert(#duties == 0, "Duties are not empty, while group size and mages are 0")
    ---------------
    mock_party_size = 10
    mock_mages_num = 0
    duties = BuffDuty:getDutiesTable()
    assert(#duties == 0, "Duties are not empty, while no mages to buff")
    ---------------
    mock_party_size = 10
    mock_mages_num = 1
    duties = BuffDuty:getDutiesTable()
    assert(#duties == 1, "Duties are empty or > 2 while mage is one!")
    ---------------
    mock_party_size = 10
    mock_mages_num = 2
    duties = BuffDuty:getDutiesTable()
    assert(#duties == 8, "Duties are not 2 while mages are 2!")
    ---------------
    mock_party_size = 40
    mock_mages_num = 8
    duties = BuffDuty:getDutiesTable()
    assert(#duties == 8, "Duties are not 8 while mages are 8!")
    ---------------
    mock_party_size = 40
    mock_mages_num = 12
    duties = BuffDuty:getDutiesTable()
    --BuffDuty:printDuties(duties, "SAY")
    assert(#duties == 8, "Duties are not 8 while mages are 12!")
end


function BuffDuty:TestCommand(input)
    local status, err = pcall(test)
    if(status) then
        print("All tests successful!")
    else
        print("Error while running BuffDuty tests: \n"..err)
    end
end