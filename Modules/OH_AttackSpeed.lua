    ----------------------------------------------------
    --------------ATTACKPEED SYSTEM SETUP---------------
    ----------------------------------------------------

    --key = UnitHandleID, value = factor, logic = speed * factor

    function AS_SortedTbl(unit)
        local tbl = {}
        for i, v in pairs(DEBUFFS) do
            if v.target == unit and v.attackspeed_factor then
                table.insert(tbl,v)
            end
        end
        table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
        return tbl
    end

    function AS_Recalculate(unit)
        local as = UNITS_DATA[GetUnitTypeId(unit)].DEF_AS
        local NotStack = {}
        if ATTACKSPEED_CONSTANTS[GetHandleIdBJ(unit)] then
            table.sort(ATTACKSPEED_CONSTANTS[GetHandleIdBJ(unit)], function (k1, k2) return k1.constantPriority > k2.constantPriority end )
            for i, v in pairs(ATTACKSPEED_CONSTANTS[GetHandleIdBJ(unit)]) do
                if v.factor then
                    as = as * v.factor
                end
            end
        end
        for i, v in pairs(AS_SortedTbl(unit)) do
            if v.attackspeed_factorStacks then
                as = as * v.attackspeed_factor
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                as = as * v.attackspeed_factor
            end
        end
        NotStack = nil
        as = (as / UNITS_DATA[GetUnitTypeId(unit)].DEF_AS) - 1
        AS_UnitSetAttackSpeed(unit,as)
    end

    function AS_UnitSetAttackSpeed(u,as)
        if GetUnitAbilityLevel(u, ABCODE_ASMODIFIER) == 0 then
            UnitAddAbility(u, ABCODE_ASMODIFIER)
        end
        BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, ABCODE_ASMODIFIER), ABILITY_RLF_ATTACK_SPEED_INCREASE_ISX1, 0, as)
        SetUnitAbilityLevel(u, ABCODE_ASMODIFIER, 2)
        SetUnitAbilityLevel(u, ABCODE_ASMODIFIER, 1)
    end