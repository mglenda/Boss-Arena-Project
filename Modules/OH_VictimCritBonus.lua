----------------------------------------------------
----------CRITBONUS VIC BUFF SYSTEM SETUP-----------
----------------------------------------------------

function UNITCRITVIC_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.unitcritvic_constant then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function UNITCRITVIC_Recalculate(unit)
    local NotStack = {}
    local dmgData = {}
    local u_id = GetHandleIdBJ(unit)
    dmgFactor_Data_Victim[u_id] = dmgFactor_Data_Victim[u_id] or {}
    for i, v in pairs(dmgFactor_Data_Victim[u_id]) do
        if i ~= 'dmg_immune' then
            v.critBonus = nil
        end
    end
    for i, v in pairs(UNITCRITVIC_SortedTbl(unit)) do
        if v.ABILITIES_CRITVIC then
            if v.unitcritvic_constantStacks then
                for j, id in pairs(v.ABILITIES_CRITVIC) do
                    dmgData[id] = dmgData[id] or {['critBonus'] = 0}
                    dmgData[id].critBonus = dmgData[id].critBonus + v.unitcritvic_constant
                end
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                for j, id in pairs(v.ABILITIES_CRITVIC) do
                    dmgData[id] = dmgData[id] or {['critBonus'] = 0}
                    dmgData[id].critBonus = dmgData[id].critBonus + v.unitcritvic_constant
                end
            end
        end
    end
    for i, v in pairs(dmgData) do
        dmgFactor_Data_Victim[u_id][i] = dmgFactor_Data_Victim[u_id][i] or {}
        dmgFactor_Data_Victim[u_id][i].critBonus = v.critBonus
    end
    dmgData = nil
end