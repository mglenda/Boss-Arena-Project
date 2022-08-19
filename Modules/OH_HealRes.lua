----------------------------------------------------
---------------HEALRES SYSTEM SETUP-----------------
----------------------------------------------------

--key = UnitHandleID, value = constant, logic = am + constant

function HR_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.healres_constant then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function HR_Recalculate(unit)
    local hr = HR_GetUnitDefaultResist(unit)
    local NotStack = {}
    if HEALRESIST_CONSTANTS[GetHandleIdBJ(unit)] then
        table.sort(HEALRESIST_CONSTANTS[GetHandleIdBJ(unit)], function (k1, k2) return k1.constantPriority > k2.constantPriority end )
        for i, v in pairs(HEALRESIST_CONSTANTS[GetHandleIdBJ(unit)]) do
            if v.resist then
                hr = hr + v.resist
            end
        end
    end
    for i, v in pairs(HR_SortedTbl(unit)) do
        if v.healres_constantStacks then
            hr = hr + v.healres_constant
        elseif not(IsInArray(v.name,NotStack)) then
            table.insert(NotStack,v.name)
            hr = hr + v.healres_constant
        end
    end
    NotStack = nil
    SetUnitUserData(unit, hr)
end

function HR_GetUnitDefaultResist(unit)
    return UNITS_DATA[GetUnitTypeId(unit)].DEF_HEAL_RESIST
end