----------------------------------------------------
--------------DAMAGE BUFF SYSTEM SETUP--------------
----------------------------------------------------

function UNITDMG_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and (v.unitdmg_factor or v.unitdmg_constant) then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function UNITDMG_Recalculate(unit)
    local NotStack = {}
    local dmgData = UNIT_GetDmgFactorTable_DMG(unit)
    for i, v in pairs(UNITDMG_SortedTbl(unit)) do
        if v.ABILITIES_DMG then
            if v.unitdmg_factor then
                if v.unitdmg_factorStacks then
                    for j, id in pairs(v.ABILITIES_DMG) do
                        if dmgData[id] then
                            dmgData[id].curFactor = dmgData[id].curFactor * v.unitdmg_factor
                        end
                    end
                elseif not(IsInArray(v.name,NotStack)) then
                    table.insert(NotStack,v.name)
                    for j, id in pairs(v.ABILITIES_DMG) do
                        if dmgData[id] then
                            dmgData[id].curFactor = dmgData[id].curFactor * v.unitdmg_factor
                        end
                    end
                end
            end
            if v.unitdmg_constant then
                if v.unitdmg_constantStacks then
                    for j, id in pairs(v.ABILITIES_DMG) do
                        if dmgData[id] then
                            dmgData[id].curFactor = dmgData[id].curFactor + v.unitdmg_constant
                        end
                    end
                elseif not(IsInArray(v.name,NotStack)) then
                    table.insert(NotStack,v.name)
                    for j, id in pairs(v.ABILITIES_DMG) do
                        if dmgData[id] then
                            dmgData[id].curFactor = dmgData[id].curFactor + v.unitdmg_constant
                        end
                    end
                end
            end
        else
            if v.unitdmg_factor then
                if v.unitdmg_factorStacks then
                    for j, ab in pairs(dmgData) do
                        if not(IsInArray(j,ABILITY_DMG_EXPECTIONS)) then
                            ab.curFactor = ab.curFactor * v.unitdmg_factor
                        end
                    end
                elseif not(IsInArray(v.name,NotStack)) then
                    table.insert(NotStack,v.name)
                    for j, ab in pairs(dmgData) do
                        if not(IsInArray(j,ABILITY_DMG_EXPECTIONS)) then
                            ab.curFactor = ab.curFactor * v.unitdmg_factor
                        end
                    end
                end
            end
            if v.unitdmg_constant then
                if v.unitdmg_constantStacks then
                    for j, ab in pairs(dmgData) do
                        if not(IsInArray(j,ABILITY_DMG_EXPECTIONS)) then
                            ab.curFactor = ab.curFactor + v.unitdmg_constant
                        end
                    end
                elseif not(IsInArray(v.name,NotStack)) then
                    table.insert(NotStack,v.name)
                    for j, ab in pairs(dmgData) do
                        if not(IsInArray(j,ABILITY_DMG_EXPECTIONS)) then
                            ab.curFactor = ab.curFactor + v.unitdmg_constant
                        end
                    end
                end
            end
        end
    end
    local u_id = GetHandleIdBJ(unit)
    for i, v in pairs(dmgData) do
        if dmgFactor_Data[u_id][i] then
            dmgFactor_Data[u_id][i].curFactor = v.curFactor
        end
    end
    dmgData = nil
end