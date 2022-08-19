----------------------------------------------------
--------------MOVESPEED SYSTEM SETUP----------------
----------------------------------------------------

--key = UnitHandleID, value = speed, logic = ms + speed

function MS_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and (v.movespeed_factor or v.movespeed_constant) then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function MS_GetDefaultMoveSpeed(unit)
    return UNITS_DATA[GetUnitTypeId(unit)].DEF_MS
end

function MS_Recalculate(unit)
    if not(BUFF_UnitIsRooted(unit)) then
        local ms = MS_GetDefaultMoveSpeed(unit)
        local NotStack = {}
        if not(UNIT_GetData(unit,'ms_immune')) then
            if MOVESPEED_CONSTANTS[GetHandleIdBJ(unit)] then
                table.sort(MOVESPEED_CONSTANTS[GetHandleIdBJ(unit)], function (k1, k2) return k1.constantPriority > k2.constantPriority end )
                for i, v in pairs(MOVESPEED_CONSTANTS[GetHandleIdBJ(unit)]) do
                    if v.constant or v.factor then
                        if v.constant then
                            ms = ms + v.constant
                        end
                        if v.factor then
                            ms = ms * v.factor
                        end
                    end
                end
            end
            for i, v in pairs(MS_SortedTbl(unit)) do
                if v.movespeed_constant then
                    if v.movespeed_constantStacks then
                        ms = ms + v.movespeed_constant
                    elseif not(IsInArray(v.name,NotStack)) then
                        table.insert(NotStack,v.name)
                        ms = ms + v.movespeed_constant
                    end
                end
                if v.movespeed_factor then
                    if v.movespeed_factorStacks then
                        ms = ms * v.movespeed_factor
                    elseif not(IsInArray(v.name,NotStack)) then
                        table.insert(NotStack,v.name)
                        ms = ms * v.movespeed_factor
                    end
                end
            end
        end
        if ms > MS_MAX_MOVESPEED then
            ms = MS_MAX_MOVESPEED
        elseif ms < MS_MIN_MOVESPEED then
            ms = MS_MIN_MOVESPEED
        end
        NotStack = nil
        SetUnitMoveSpeed(unit, ms)
        return
    end
    SetUnitMoveSpeed(unit, 0)
end

function MS_NullifyMS(unit)
    MOVESPEED_CONSTANTS[GetHandleIdBJ(unit)] = MOVESPEED_CONSTANTS[GetHandleIdBJ(unit)] or {}
    MOVESPEED_CONSTANTS[GetHandleIdBJ(unit)].freezer = {
        constant = -9000000
    }
    MS_Recalculate(unit)
end

function MS_Freeze(unit)
    IssueImmediateOrderBJ(unit, "stop")
    MS_NullifyMS(unit)
    BlzSetUnitWeaponBooleanFieldBJ(unit, UNIT_WEAPON_BF_ATTACKS_ENABLED, 0, false)
end

function MS_Unfreeze(unit)
    MS_UnNullifyMS(unit)
    BlzSetUnitWeaponBooleanFieldBJ(unit, UNIT_WEAPON_BF_ATTACKS_ENABLED, 0, true)
end

function MS_IsFreezed(unit)
    if MOVESPEED_CONSTANTS[GetHandleIdBJ(unit)] then
        return MOVESPEED_CONSTANTS[GetHandleIdBJ(unit)].freezer
    end
    return false
end

function MS_UnNullifyMS(unit)
    if MOVESPEED_CONSTANTS[GetHandleIdBJ(unit)] then
        MOVESPEED_CONSTANTS[GetHandleIdBJ(unit)].freezer = nil
    end
    MS_Recalculate(unit)
end