----------------------------------------------------
----------CRITRATEMULT BUFF SYSTEM SETUP------------
----------------------------------------------------

function UNITCRITMULT_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.unitcritMult_constant then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function UNITCRITMULT_Recalculate(unit)
    local NotStack = {}
    local dmgData = UNIT_GetDmgFactorTable_CRITMULT(unit)
    for i, v in pairs(UNITCRITMULT_SortedTbl(unit)) do
        if v.ABILITIES_CRITMULT then
            if v.unitcritMult_constantStacks then
                for j, id in pairs(v.ABILITIES_CRITMULT) do
                    if dmgData[id] then
                        dmgData[id].critMultBonus = dmgData[id].critMultBonus + v.unitcritMult_constant
                    end
                end
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                for j, id in pairs(v.ABILITIES_CRITMULT) do
                    if dmgData[id] then
                        dmgData[id].critMultBonus = dmgData[id].critMultBonus + v.unitcritMult_constant
                    end
                end
            end
        else
            if v.unitcritMult_constantStacks then
                for j, ab in pairs(dmgData) do
                    ab.critMultBonus = ab.critMultBonus + v.unitcritMult_constant
                end
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                for j, ab in pairs(dmgData) do
                    ab.critMultBonus = ab.critMultBonus + v.unitcritMult_constant
                end
            end
        end
    end
    local u_id = GetHandleIdBJ(unit)
    for i, v in pairs(dmgData) do
        if dmgFactor_Data[u_id][i] then
            dmgFactor_Data[u_id][i].critMultBonus = v.critMultBonus
        end
    end
    dmgData = nil
end