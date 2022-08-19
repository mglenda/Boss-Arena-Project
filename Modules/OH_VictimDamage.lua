----------------------------------------------------
------------DAMAGE VIC BUFF SYSTEM SETUP------------
----------------------------------------------------

function UNITDMGVIC_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and (v.unitdmgvic_factor or v.unitdmgvic_constant) then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function UNITDMGVIC_Recalculate(unit)
    local NotStack = {}
    local dmgData = {}
    local u_id = GetHandleIdBJ(unit)
    dmgFactor_Data_Victim[u_id] = dmgFactor_Data_Victim[u_id] or {}
    for i, v in pairs(dmgFactor_Data_Victim[u_id]) do
        if i ~= 'dmg_immune' then
            v.curFactor = nil
        end
    end
    for i, v in pairs(UNITDMGVIC_SortedTbl(unit)) do
        if v.ABILITIES_DMGVIC then
            if v.unitdmgvic_factor then
                if v.unitdmgvic_factorStacks then
                    for j, id in pairs(v.ABILITIES_DMGVIC) do
                        dmgData[id] = dmgData[id] or {['curFactor'] = 1.0}
                        dmgData[id].curFactor = dmgData[id].curFactor * v.unitdmgvic_factor
                    end
                elseif not(IsInArray(v.name,NotStack)) then
                    table.insert(NotStack,v.name)
                    for j, id in pairs(v.ABILITIES_DMGVIC) do
                        dmgData[id] = dmgData[id] or {['curFactor'] = 1.0}
                        dmgData[id].curFactor = dmgData[id].curFactor * v.unitdmgvic_factor
                    end
                end
            end
            if v.unitdmgvic_constant then
                if v.unitdmgvic_constantStacks then
                    for j, id in pairs(v.ABILITIES_DMGVIC) do
                        dmgData[id] = dmgData[id] or {['curFactor'] = 1.0}
                        dmgData[id].curFactor = dmgData[id].curFactor + v.unitdmgvic_constant
                    end
                elseif not(IsInArray(v.name,NotStack)) then
                    table.insert(NotStack,v.name)
                    for j, id in pairs(v.ABILITIES_DMGVIC) do
                        dmgData[id] = dmgData[id] or {['curFactor'] = 1.0}
                        dmgData[id].curFactor = dmgData[id].curFactor + v.unitdmgvic_constant
                    end
                end
            end
        end
    end
    for i, v in pairs(dmgData) do
        dmgFactor_Data_Victim[u_id][i] = dmgFactor_Data_Victim[u_id][i] or {}
        dmgFactor_Data_Victim[u_id][i].curFactor = v.curFactor
    end
    dmgData = nil
end