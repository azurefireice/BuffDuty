local raid = {
-- Group 1
{name = "Raider11", r = 0, sg = 1, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider12", r = 0, sg = 1, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider13", r = 0, sg = 1, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider14", r = 0, sg = 1, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider15", r = 0, sg = 1, cls_loc = "Warrior", cls = "WARRIOR"},
-- Group 2
{name = "Raider21", r = 0, sg = 2, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider22", r = 0, sg = 2, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Ariakas", r = 0, sg = 2, cls_loc = "Mage", cls = "MAGE"},
{name = "Raider24", r = 0, sg = 2, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider25", r = 0, sg = 2, cls_loc = "Warrior", cls = "WARRIOR"},
-- Group 3
{name = "Raider31", r = 0, sg = 3, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider32", r = 0, sg = 3, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Mage33", r = 0, sg = 3, cls_loc = "Mage", cls = "MAGE"},
{name = "Raider34", r = 0, sg = 3, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider35", r = 0, sg = 3, cls_loc = "Warrior", cls = "WARRIOR"},
-- Group 4
{name = "Raider41", r = 0, sg = 4, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider42", r = 0, sg = 4, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider43", r = 0, sg = 4, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider44", r = 0, sg = 4, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider45", r = 0, sg = 4, cls_loc = "Warrior", cls = "WARRIOR"},
-- Group 5
{name = "Raider51", r = 0, sg = 5, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider52", r = 0, sg = 5, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider53", r = 0, sg = 5, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider54", r = 0, sg = 5, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider55", r = 0, sg = 5, cls_loc = "Warrior", cls = "WARRIOR"},
-- Group 6
{name = "Raider61", r = 0, sg = 6, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider62", r = 0, sg = 6, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider63", r = 0, sg = 6, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider64", r = 0, sg = 6, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Raider65", r = 0, sg = 6, cls_loc = "Warrior", cls = "WARRIOR"},
-- Group 7
{name = "Raider71", r = 0, sg = 7, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Priest72", r = 0, sg = 7, cls_loc = "Priest", cls = "PRIEST"},
{name = "Raider73", r = 0, sg = 7, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Priest74", r = 0, sg = 7, cls_loc = "Priest", cls = "PRIEST"},
{name = "Raider75", r = 0, sg = 7, cls_loc = "Warrior", cls = "WARRIOR"},
-- Group 8
{name = "Priest81", r = 0, sg = 8, cls_loc = "Priest", cls = "PRIEST"},
{name = "Raider82", r = 0, sg = 8, cls_loc = "Warrior", cls = "WARRIOR"},
{name = "Priest83", r = 0, sg = 8, cls_loc = "Priest", cls = "PRIEST"},
{name = "Priest84", r = 0, sg = 8, cls_loc = "Priest", cls = "PRIEST"},
{name = "Raider85", r = 0, sg = 8, cls_loc = "Warrior", cls = "WARRIOR"},
}

function GetRaidRosterInfo(idx)
    local raider = raid[idx]
    if raider then
        return raider.name, raider.r, raider.sg, 60, raider.cls_loc, raider.cls
    end
    return nil
end

function GetNumGroupMembers()
    return 40
end