----------------------------------------------------
------------CRITRATE BUFF SYSTEM SETUP--------------
----------------------------------------------------

function UNITCRIT_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.unitcrit_constant then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function UNITCRIT_Recalculate(unit)
    local NotStack = {}
    local dmgData = UNIT_GetDmgFactorTable_CRIT(unit)
    for i, v in pairs(UNITCRIT_SortedTbl(unit)) do
        if v.ABILITIES_CRIT then
            if v.unitcrit_constantStacks then
                for j, id in pairs(v.ABILITIES_CRIT) do
                    if dmgData[id] then
                        dmgData[id].critBonus = dmgData[id].critBonus + v.unitcrit_constant
                    end
                end
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                for j, id in pairs(v.ABILITIES_CRIT) do
                    if dmgData[id] then
                        dmgData[id].critBonus = dmgData[id].critBonus + v.unitcrit_constant
                    end
                end
            end
        else
            if v.unitcrit_constantStacks then
                for j, ab in pairs(dmgData) do
                    ab.critBonus = ab.critBonus + v.unitcrit_constant
                end
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                for j, ab in pairs(dmgData) do
                    ab.critBonus = ab.critBonus + v.unitcrit_constant
                end
            end
        end
    end
    local u_id = GetHandleIdBJ(unit)
    for i, v in pairs(dmgData) do
        if dmgFactor_Data[u_id][i] then
            dmgFactor_Data[u_id][i].critBonus = v.critBonus
        end
    end
    dmgData = nil
end