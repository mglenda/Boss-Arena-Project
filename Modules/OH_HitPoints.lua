----------------------------------------------------
--------------HP BUFFS SYSTEM SETUP-----------------
----------------------------------------------------

--key = UnitHandleID, value = constant or factor, logic = hp * factor or hp + constant

function HP_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and (v.hp_constant or v.hp_factor) then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function HP_Recalculate(unit)
    local hp = HP_GetUnitDefaultHP(unit)
    local hp_perc = GetUnitLifePercent(unit)
    local NotStack = {}
    if HP_CONSTANTS[GetHandleIdBJ(unit)] then
        table.sort(HP_CONSTANTS[GetHandleIdBJ(unit)], function (k1, k2) return k1.constantPriority > k2.constantPriority end )
        for i, v in pairs(HP_CONSTANTS[GetHandleIdBJ(unit)]) do
            if v.constant or v.factor then
                if v.constant then
                    hp = hp + v.constant
                end
                if v.factor then
                    hp = hp * v.factor
                end
            end
        end
    end
    for i, v in pairs(HP_SortedTbl(unit)) do
        if v.hp_constant then
            if v.hp_constantStacks then
                hp = hp + v.hp_constant
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                hp = hp + v.hp_constant
            end
        end
        if v.hp_factor then
            if v.hp_factorStacks then
                hp = hp * v.hp_factor
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                hp = hp * v.hp_factor
            end
        end
    end
    NotStack = nil
    hp = math.floor(hp)
    if hp < 1 then
        hp = 1
    end
    BlzSetUnitMaxHP(unit, hp)
    SetUnitLifePercentBJ(unit, hp_perc)
end

function HP_GetUnitDefaultHP(unit)
    return UNITS_DATA[GetUnitTypeId(unit)].DEF_HP
end