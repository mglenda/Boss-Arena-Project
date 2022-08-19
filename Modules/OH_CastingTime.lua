----------------------------------------------------
------------CASTTIME BUFF SYSTEM SETUP--------------
----------------------------------------------------

function CASTTIME_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and (v.casttime_factor or v.casttime_constant) then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function CASTTIME_Recalculate(unit,casttimeall)
    local NotStack = {}
    local timeData = CASTTIME_GetCastTimeTable(unit,casttimeall)
    if timeData then
        if CASTTIME_CONSTANTS[GetHandleIdBJ(unit)] then
            table.sort(CASTTIME_CONSTANTS[GetHandleIdBJ(unit)], function (k1, k2) return k1.constantPriority > k2.constantPriority end )
            for i, v in pairs(CASTTIME_CONSTANTS[GetHandleIdBJ(unit)]) do
                if v.abilCodes then
                    for j,x in pairs(v.abilCodes) do
                        if timeData[x] then
                            if v.constant or v.factor then
                                if v.constant then
                                    timeData[x].CastingTime = timeData[x].CastingTime + v.constant
                                end
                                if v.factor then
                                    timeData[x].CastingTime = timeData[x].CastingTime * v.factor
                                end
                            end
                        end
                    end
                else
                    for j,x in pairs(timeData) do
                        if v.constant or v.factor then
                            if v.constant then
                                x.CastingTime = x.CastingTime + v.constant
                            end
                            if v.factor then
                                x.CastingTime = x.CastingTime * v.factor
                            end
                        end
                    end
                end
            end
        end
        for i, v in pairs(CASTTIME_SortedTbl(unit)) do
            if v.ABILITIES_CASTTIME then
                if v.casttime_factor then
                    if v.casttime_factorStacks then
                        for j, id in pairs(v.ABILITIES_CASTTIME) do
                            if timeData[id] then
                                timeData[id].CastingTime = timeData[id].CastingTime * v.casttime_factor
                            end
                        end
                    elseif not(IsInArray(v.name,NotStack)) then
                        table.insert(NotStack,v.name)
                        for j, id in pairs(v.ABILITIES_CASTTIME) do
                            if timeData[id] then
                                timeData[id].CastingTime = timeData[id].CastingTime * v.casttime_factor
                            end
                        end
                    end
                end
                if v.casttime_constant then
                    if v.casttime_constantStacks then
                        for j, id in pairs(v.ABILITIES_CASTTIME) do
                            if timeData[id] then
                                timeData[id].CastingTime = timeData[id].CastingTime + v.casttime_constant
                            end
                        end
                    elseif not(IsInArray(v.name,NotStack)) then
                        table.insert(NotStack,v.name)
                        for j, id in pairs(v.ABILITIES_CASTTIME) do
                            if timeData[id] then
                                timeData[id].CastingTime = timeData[id].CastingTime + v.casttime_constant
                            end
                        end
                    end
                end
            else
                if v.casttime_factor then
                    if v.casttime_factorStacks then
                        for j, tb in pairs(timeData) do
                            tb.CastingTime = tb.CastingTime * v.casttime_factor
                        end
                    elseif not(IsInArray(v.name,NotStack)) then
                        table.insert(NotStack,v.name)
                        for j, tb in pairs(timeData) do
                            tb.CastingTime = tb.CastingTime * v.casttime_factor
                        end
                    end
                end
                if v.casttime_constant then
                    if v.casttime_constantStacks then
                        for j, tb in pairs(timeData) do
                            tb.CastingTime = tb.CastingTime + v.casttime_constant
                        end
                    elseif not(IsInArray(v.name,NotStack)) then
                        table.insert(NotStack,v.name)
                        for j, tb in pairs(timeData) do
                            tb.CastingTime = tb.CastingTime + v.casttime_constant
                        end
                    end
                end
            end
        end
        for i, v in pairs(timeData) do
            local val = v.CastingTime >= 0.0 and v.CastingTime or 0.0
            BlzSetAbilityRealLevelField(BlzGetUnitAbility(unit, i), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(unit, i)-1, round(val,2))
        end
        timeData = nil
    end
end

function CASTTIME_GetCastTimeTable(unit,casttimeall)
    local u_id = GetUnitTypeId(unit)
    local tbl = {}
    if UNITS_DATA[u_id] and UNITS_DATA[u_id].ABILITIES then
        for i, v in pairs(UNITS_DATA[u_id].ABILITIES) do
            if v ~= Get_DmgTypeAutoAttack() and (not(ABILITIES_DATA[v].IsPassive) or (casttimeall and ABILITIES_DATA[v].CastingTime)) then
                tbl[v] = {
                    CastingTime = ABILITIES_DATA[v].CastingTime
                }
            end
        end
        return tbl
    end
    return nil
end