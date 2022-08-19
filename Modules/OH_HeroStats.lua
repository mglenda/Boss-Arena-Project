----------------------------------------------------
--------------STATS BUFFS SYSTEM SETUP--------------
----------------------------------------------------

--key = UnitHandleID, value = constant or factor, logic = stat * factor or stat + constant

function STATS_STR_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and (v.stat_constant_str or v.stat_factor_str) then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function STATS_STR_Recalculate(unit)
    local stat = STATS_CalculateUnitStat(unit,bj_HEROSTAT_STR)
    local NotStack = {}
    if STATS_CONSTANTS[GetHandleIdBJ(unit)] then
        table.sort(STATS_CONSTANTS[GetHandleIdBJ(unit)], function (k1, k2) return k1.constantPriority > k2.constantPriority end )
        for i, v in pairs(STATS_CONSTANTS[GetHandleIdBJ(unit)]) do
            if v.constant_str or v.factor_str then
                if v.constant_str then
                    stat = stat + v.constant_str
                end
                if v.factor_str then
                    stat = stat * v.factor_str
                end
            end
        end
    end
    for i, v in pairs(STATS_STR_SortedTbl(unit)) do
        if v.stat_constant_str then
            if v.stat_constantStacks_str then
                stat = stat + v.stat_constant_str
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                stat = stat + v.stat_constant_str
            end
        end
        if v.stat_factor_str then
            if v.stat_factorStacks_str then
                stat = stat * v.stat_factor_str
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                stat = stat * v.stat_factor_str
            end
        end
    end
    NotStack = nil
    SetHeroStr(unit, math.floor(stat), true)
end

function STATS_INT_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and (v.stat_constant_int or v.stat_factor_int) then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function STATS_INT_Recalculate(unit)
    local stat = STATS_CalculateUnitStat(unit,bj_HEROSTAT_INT)
    local NotStack = {}
    if STATS_CONSTANTS[GetHandleIdBJ(unit)] then
        table.sort(STATS_CONSTANTS[GetHandleIdBJ(unit)], function (k1, k2) return k1.constantPriority > k2.constantPriority end )
        for i, v in pairs(STATS_CONSTANTS[GetHandleIdBJ(unit)]) do
            if v.constant_int or v.factor_int then
                if v.constant_int then
                    stat = stat + v.constant_int
                end
                if v.factor_int then
                    stat = stat * v.factor_int
                end
            end
        end
    end
    for i, v in pairs(STATS_INT_SortedTbl(unit)) do
        if v.stat_constant_int then
            if v.stat_constantStacks_int then
                stat = stat + v.stat_constant_int
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                stat = stat + v.stat_constant_int
            end
        end
        if v.stat_factor_int then
            if v.stat_factorStacks_int then
                stat = stat * v.stat_factor_int
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                stat = stat * v.stat_factor_int
            end
        end
    end
    NotStack = nil
    SetHeroInt(unit, math.floor(stat), true)
end

function STATS_AGI_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and (v.stat_constant_agi or v.stat_factor_agi) then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function STATS_AGI_Recalculate(unit)
    local stat = STATS_CalculateUnitStat(unit,bj_HEROSTAT_AGI)
    local NotStack = {}
    if STATS_CONSTANTS[GetHandleIdBJ(unit)] then
        table.sort(STATS_CONSTANTS[GetHandleIdBJ(unit)], function (k1, k2) return k1.constantPriority > k2.constantPriority end )
        for i, v in pairs(STATS_CONSTANTS[GetHandleIdBJ(unit)]) do
            if v.constant_agi or v.factor_agi then
                if v.constant_agi then
                    stat = stat + v.constant_agi
                end
                if v.factor_agi then
                    stat = stat * v.factor_agi
                end
            end
        end
    end
    for i, v in pairs(STATS_AGI_SortedTbl(unit)) do
        if v.stat_constant_agi then
            if v.stat_constantStacks_agi then
                stat = stat + v.stat_constant_agi
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                stat = stat + v.stat_constant_agi
            end
        end
        if v.stat_factor_agi then
            if v.stat_factorStacks_agi then
                stat = stat * v.stat_factor_agi
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                stat = stat * v.stat_factor_agi
            end
        end
    end
    NotStack = nil
    SetHeroAgi(unit, math.floor(stat), true)
end

function STATS_CalculateUnitStat(unit,stat)
    local lvl = GetHeroLevel(unit) - 1
    if stat == bj_HEROSTAT_STR then
        return math.floor(STATS_GetSTRStarting(unit) + (STATS_GetSTRPerLevel(unit) * lvl))
    elseif stat == bj_HEROSTAT_AGI then
        return math.floor(STATS_GetAGIStarting(unit) + (STATS_GetAGIPerLevel(unit) * lvl))
    elseif stat == bj_HEROSTAT_INT then
        return math.floor(STATS_GetINTStarting(unit) + (STATS_GetINTPerLevel(unit) * lvl))
    end
end

function STATS_GetINTPerLevel(unit)
    return UNITS_DATA[GetUnitTypeId(unit)].DEF_INT_LVL
end

function STATS_GetINTStarting(unit)
    return UNITS_DATA[GetUnitTypeId(unit)].DEF_INT
end

function STATS_GetAGIPerLevel(unit)
    return UNITS_DATA[GetUnitTypeId(unit)].DEF_AGI_LVL
end

function STATS_GetAGIStarting(unit)
    return UNITS_DATA[GetUnitTypeId(unit)].DEF_AGI
end

function STATS_GetSTRPerLevel(unit)
    return UNITS_DATA[GetUnitTypeId(unit)].DEF_STR_LVL
end

function STATS_GetSTRStarting(unit)
    return UNITS_DATA[GetUnitTypeId(unit)].DEF_STR
end