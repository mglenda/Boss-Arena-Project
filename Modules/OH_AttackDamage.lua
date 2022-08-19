----------------------------------------------------
------------ATTACK DAMAGE SYSTEM SETUP--------------
----------------------------------------------------

--key = UnitHandleID, value = constant or factor, logic = dmg * factor or dmg + constant

function DMG_SortedTbl(unit)
    local tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and (v.dmg_constant or v.dmg_factor) then
            table.insert(tbl,v)
        end
    end
    table.sort(tbl, function (k1, k2) return k1.debuffPriority > k2.debuffPriority end)
    return tbl
end

function DMG_Recalculate(unit)
    local dmg = DMG_GetUnitDefaultDMG(unit)
    local NotStack = {}
    if ATTDMG_CONSTANTS[GetHandleIdBJ(unit)] then
        table.sort(ATTDMG_CONSTANTS[GetHandleIdBJ(unit)], function (k1, k2) return k1.constantPriority > k2.constantPriority end )
        for i, v in pairs(ATTDMG_CONSTANTS[GetHandleIdBJ(unit)]) do
            if v.constant or v.factor then
                if v.constant then
                    dmg = dmg + v.constant
                end
                if v.factor then
                    dmg = dmg * v.factor
                end
            end
        end
    end
    for i, v in pairs(DMG_SortedTbl(unit)) do
        if v.dmg_constant then
            if v.dmg_constantStacks then
                dmg = dmg + v.dmg_constant
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                dmg = dmg + v.dmg_constant
            end
        end
        if v.dmg_factor then
            if v.dmg_factorStacks then
                dmg = dmg * v.dmg_factor
            elseif not(IsInArray(v.name,NotStack)) then
                table.insert(NotStack,v.name)
                dmg = dmg * v.dmg_factor
            end
        end
    end
    NotStack = nil
    dmg = math.floor(dmg)
    BlzSetUnitBaseDamage(unit, dmg, 0)
end

function DMG_GetUnitDefaultDMG(unit)
    return UNITS_DATA[GetUnitTypeId(unit)].DEF_DMG + (ATTDMG_PER_PRIMARY_ATTRIBUTE * (IsUnitType(unit,UNIT_TYPE_HERO) and GetHeroStatBJ(ATTRIBUTES[Get_UnitPrimaryAttribute(unit)].stat, unit, true) or 0))
end