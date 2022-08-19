----------------------------------------------------
--------------HP REGEN SYSTEM SETUP-----------------
----------------------------------------------------

--key = UnitHandleID, value = constant or factor, logic = regen * factor or regen + constant

function HPREG_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and (v.regen_constant or v.regen_factor) then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function HPREG_Recalculate(unit)
    local reg = HPREG_GetUnitDefaultRegen(unit)
    local NotStack = {}
    if HPREGEN_CONSTANTS[GetHandleIdBJ(unit)] then
        table.sort(HPREGEN_CONSTANTS[GetHandleIdBJ(unit)], function (k1, k2) return k1.constantPriority > k2.constantPriority end )
        for i, v in pairs(HPREGEN_CONSTANTS[GetHandleIdBJ(unit)]) do
            if v.constant or v.factor then
                if v.constant then
                    reg = reg + v.constant
                end
                if v.factor then
                    reg = reg * v.factor
                end
            end
        end
    end
    for i, v in pairs(HPREG_SortedTbl(unit)) do
        if v.regen_constant then
            if v.regen_constantStacks then
                reg = reg + v.regen_constant
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                reg = reg + v.regen_constant
            end
        end
        if v.regen_factor then
            if v.regen_factorStacks then
                reg = reg * v.regen_factor
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                reg = reg * v.regen_factor
            end
        end
    end
    NotStack = nil
    BlzSetUnitRealFieldBJ(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE, reg)
end

function HPREG_GetUnitDefaultRegen(unit)
    return UNITS_DATA[GetUnitTypeId(unit)].DEF_REGEN
end