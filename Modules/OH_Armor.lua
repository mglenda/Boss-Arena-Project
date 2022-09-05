----------------------------------------------------
----------------ARMOR SYSTEM SETUP------------------
----------------------------------------------------

--key = UnitHandleID, value = constant, logic = am + constant

function AM_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.armor_constant then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function AM_Recalculate(unit)
    local am = AM_GetUnitDefaultArmor(unit)
    local NotStack = {}
    if ARMOR_CONSTANTS[GetHandleIdBJ(unit)] then
        table.sort(ARMOR_CONSTANTS[GetHandleIdBJ(unit)], function (k1, k2) return k1.constantPriority > k2.constantPriority end )
        for i, v in pairs(ARMOR_CONSTANTS[GetHandleIdBJ(unit)]) do
            if v.armor then
                am = am + v.armor
            end
        end
    end
    for i, v in pairs(AM_SortedTbl(unit)) do
        if v.armor_constantStacks then
            am = am + v.armor_constant
        elseif not(IsInArray(v.name,NotStack)) then
            table.insert(NotStack,v.name)
            am = am + v.armor_constant
        end
    end
    NotStack = nil
    BlzSetUnitArmor(unit, am)
end

function AM_GetUnitDefaultArmor(unit)
    return UNITS_DATA[GetUnitTypeId(unit)].DEF_ARMOR
end