----------------------------------------------------
---------------UNIT SYSTEM SETUP--------------------
----------------------------------------------------

function UNIT_GetEnergyTheme(u)
    return UNIT_GetData(u,'energy_theme')
end

function UNIT_SetEnergyTheme(u,t)
    UNIT_SetData(u,'energy_theme',t)
end

function UNIT_GetEnergyCap(u)
    return UNIT_GetData(u,'energy_cap') or UNITS_DATA[GetUnitTypeId(u)].ENERGY_CAP
end

function UNIT_SetEnergyCap(u,e)
    UNIT_SetData(u,'energy_cap',e)
end

function UNIT_GetEnergy(u)
    return UNIT_GetData(u,'energy') or 0
end

function UNIT_SetEnergy(u,e)
    UNIT_SetData(u,'energy',e)
end

function UNIT_GetImpactDist(u)
    return UNIT_GetData(u,'impact_dist') or UNITS_DATA[GetUnitTypeId(u)].IMPACT_DIST
end

function UNIT_SetImpactDist(u,dist)
    UNIT_SetData(u,'impact_dist',dist)
end

function UNIT_ResetImpactDist(u)
    UNIT_SetData(u,'impact_dist',nil)
end

function UNIT_GetChestHeight(u)
    local u_id = GetUnitTypeId(u)
    return UNITS_DATA[u_id].HEIGHT_CHEST
end

function UNIT_GetCastHeight(u)
    local u_id = GetUnitTypeId(u)
    return UNITS_DATA[u_id].HEIGHT_CAST
end

function CreateUnit(id, unitid, x, y, face)
    local u = oldCreateUnit(id, unitid, x, y, face)
    table.insert(ALL_UNITS, u)
    return u
end

function RemoveUnit(whichUnit)
    local u_id = GetHandleIdBJ(whichUnit)
    RemoveFromArray(whichUnit,ALL_UNITS)
    RemoveFromArray_ByKey(u_id,ALL_UNITS_DATA,'u_id')
    oldRemoveUnit(whichUnit)
    u_id = nil
end

function UNIT_MakeUnitFlyable(unit)
    UnitAddAbilityBJ(FourCC("Amrf"), unit)
    UnitRemoveAbilityBJ(FourCC("Amrf"), unit)
end

function UNIT_SetData(unit,data_key,data_value)
    local u_id = GetHandleIdBJ(unit)
    local i = IsInArray_ByKey(u_id,ALL_UNITS_DATA,'u_id')
    if i then
        ALL_UNITS_DATA[i][data_key] = data_value
    else
        local tbl = {
            u_id = u_id
            ,[data_key] = data_value
        }
        table.insert(ALL_UNITS_DATA,tbl)
        tbl = nil
    end
end

function UNIT_GetData(unit,data_key)
    local u_id = GetHandleIdBJ(unit)
    local i = IsInArray_ByKey(u_id,ALL_UNITS_DATA,'u_id')
    if i then
        return ALL_UNITS_DATA[i][data_key]
    end
    return nil
end

function UNIT_Make_MS_Immune(unit)
    UNIT_SetData(unit,'ms_immune',true)
    MS_Recalculate(unit)
end

function UNIT_Make_MS_Vulnerable(unit)
    UNIT_SetData(unit,'ms_immune',nil)
    MS_Recalculate(unit)
end

function UNIT_CleanData(unit)
    local u_id = GetHandleIdBJ(unit)
    for i,v in pairs(ALL_UNITS_DATA) do
        if v.u_id == u_id then
            local tbl = {}
            for j,k in pairs(persistent_keys) do
                tbl[k] = ALL_UNITS_DATA[i][k]
            end
            ALL_UNITS_DATA[i] = tbl
            return
        end
    end
end

function UNIT_Create(id, unitid, x, y, face, notRefresh)
    local u = CreateUnit(id, unitid, x, y, face)
    UNIT_Initiate_Data(u,notRefresh)
    SetUnitColor(u, PLAYER_COLOR_SNOW)
    return u
end

function UNIT_CreateCreep(id, unitid, x, y, face, notRefresh)
    local u = CreateUnit(id, unitid, x, y, face)
    UNIT_Initiate_Data(u,notRefresh)
    SetUnitColor(u, PLAYER_COLOR_SNOW)
    table.insert(BOSS_CREEPS, u)
    return u
end

function UNIT_Initiate_Data(unit,notRefresh)
    local id = GetHandleIdBJ(unit)
    local type_id = GetUnitTypeId(unit)
    dmgFactor_Data[id] = dmgFactor_Data[id] or {}
    dmgFactor_Data_Victim[id] = dmgFactor_Data_Victim[id] or {}
    if UNITS_DATA[type_id].ABILITIES then
        for i, v in pairs(UNITS_DATA[type_id].ABILITIES) do
            dmgFactor_Data[id][v] = dmgFactor_Data[id][v] or {}
            dmgFactor_Data[id][v].origFactor = 1.0
            dmgFactor_Data[id][v].curFactor = 1.0
            dmgFactor_Data[id][v].dmgDone = 0.0
            dmgFactor_Data[id][v].dmgDone_Meter = 0.0
            dmgFactor_Data[id][v].critBonusOrig = 0
            dmgFactor_Data[id][v].critBonus = 0
            dmgFactor_Data[id][v].critMultBonusOrig = 0.0
            dmgFactor_Data[id][v].critMultBonus = 0.0
            dmgFactor_Data[id][v].healingDone = 0.0
        end
    end
    if not(notRefresh) then
        UNIT_RecalculateStats(unit,true)
    end
    SetUnitUserData(unit, UNITS_DATA[GetUnitTypeId(unit)].DEF_HEAL_RESIST)
end

function UNIT_SetDmgImmune(unit,immune)
    dmgFactor_Data_Victim[GetHandleIdBJ(unit)].dmg_immune = immune
end

function UNIT_IsDmgImmune(unit)
    return dmgFactor_Data_Victim[GetHandleIdBJ(unit)].dmg_immune
end

function UNIT_RecalculateStats(unit,casttimeall)
    MS_Recalculate(unit)
    AS_Recalculate(unit)
    AM_Recalculate(unit)
    HPREG_Recalculate(unit)
    HP_Recalculate(unit)
    if IsUnitType(unit, UNIT_TYPE_HERO) then
        STATS_INT_Recalculate(unit)
        STATS_AGI_Recalculate(unit)
        STATS_STR_Recalculate(unit)
    end
    DMG_Recalculate(unit)
    UNITDMG_Recalculate(unit)
    UNITCRIT_Recalculate(unit)
    UNITCRITMULT_Recalculate(unit)
    CASTTIME_Recalculate(unit,casttimeall)
    UNITDMGVIC_Recalculate(unit)
    HR_Recalculate(unit)
    UNITCRITVIC_Recalculate(unit)
    UNITCRITMULTVIC_Recalculate(unit)
end

function UNIT_GetDmgFactorTable_CRITMULT(unit)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    local tbl = {}
    for i,v in pairs(dmgFactor_Data[id]) do
        tbl[i] = {
            critMultBonus = v.critMultBonusOrig
        }
    end
    return tbl
end

function UNIT_GetDmgFactorTable_CRIT(unit)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    local tbl = {}
    for i,v in pairs(dmgFactor_Data[id]) do
        tbl[i] = {
            critBonus = v.critBonusOrig
        }
    end
    return tbl
end

function UNIT_GetDmgFactorTable_DMG(unit)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    local tbl = {}
    for i,v in pairs(dmgFactor_Data[id]) do
        tbl[i] = {
            curFactor = v.origFactor
        }
    end
    return tbl
end

function UNIT_GetDmgFactorTable(unit)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    return dmgFactor_Data[id]
end

function UNIT_GetDmgFactor(unit,dmg_id)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    return dmgFactor_Data[id][dmg_id].origFactor
end

function UNIT_GetCritBonus(unit,dmg_id)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    return dmgFactor_Data[id][dmg_id].critBonusOrig
end

function UNIT_GetCritMultBonus(unit,dmg_id)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    return dmgFactor_Data[id][dmg_id].critMultBonusOrig
end

function UNIT_AddDmgDone(unit,dmg_id,value)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    dmgFactor_Data[id][dmg_id].dmgDone = dmgFactor_Data[id][dmg_id].dmgDone + value
    dmgFactor_Data[id][dmg_id].dmgDone_Meter = dmgFactor_Data[id][dmg_id].dmgDone_Meter + value
end

function UNIT_AddHealingDone(unit,heal_id,value)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    dmgFactor_Data[id][heal_id].healingDone = dmgFactor_Data[id][heal_id].healingDone + value
end

function UNIT_AddDmgFactor(unit,dmg_id,value)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    dmgFactor_Data[id][dmg_id].origFactor = dmgFactor_Data[id][dmg_id].origFactor + value
    UNITDMG_Recalculate(unit)
end

function UNIT_AddDmgFactorAll(unit,value)
    local id,u_type = GetHandleIdBJ(unit),GetUnitTypeId(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    for i, ab in pairs(dmgFactor_Data[id]) do
        ab.origFactor = ab.origFactor + value
    end
    UNITDMG_Recalculate(unit)
end

function UNIT_AddCritFactor(unit,dmg_id,value)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    dmgFactor_Data[id][dmg_id].critBonusOrig = dmgFactor_Data[id][dmg_id].critBonusOrig + value
    UNITCRIT_Recalculate(unit)
end

function UNIT_AddCritMultFactor(unit,dmg_id,value)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    dmgFactor_Data[id][dmg_id].critMultBonusOrig = dmgFactor_Data[id][dmg_id].critMultBonusOrig + value
    UNITCRITMULT_Recalculate(unit)
end

function UNIT_SetDmgFactor(unit,dmg_id,value)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    dmgFactor_Data[id][dmg_id].origFactor = value
    UNITDMG_Recalculate(unit)
end

function UNIT_GetAbilityCastingTime(abCode,unit)
    return round(BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, abCode), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(unit, abCode)-1),2)
end

function UNIT_SetCritFactor(unit,dmg_id,value)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    dmgFactor_Data[id][dmg_id].critBonusOrig = value
    UNITCRIT_Recalculate(unit)
end

function UNIT_SetCritMultFactor(unit,dmg_id,value)
    local id = GetHandleIdBJ(unit)
    if not(dmgFactor_Data[id]) then
        UNIT_Initiate_Data(unit)
    end
    dmgFactor_Data[id][dmg_id].critMultBonusOrig = value
    UNITCRITMULT_Recalculate(unit)
end

function UNIT_RegisterPreCreatedUnits()
    CreateUnit(PLAYER_BOSS, FourCC('h002'), -14466.7, -14134.8, 285.0)
    CreateUnit(PLAYER_BOSS, FourCC('h002'), -14146.7, -14134.8, 285.0)
    CreateUnit(PLAYER_BOSS, FourCC('h002'), -13826.7, -14134.8, 285.0)

    UNIT_RegisterPreCreatedUnits = nil
end

function UNIT_RegisterGlobalEvents()
    local trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_DEATH)
    TriggerAddAction(trg, function()
        local u = GetDyingUnit()
        BUFF_UnitClearDying(u)
        WaitAndDo(2.0,UNIT_DeadEvent_MemoryClear,u)
    end)

    for i,u in pairs(ALL_UNITS) do
        if PLAYER_IsActive(GetOwningPlayer(u)) then
            if GetUnitTypeId(u) == FourCC('h002') then
                table.insert(TRAINING_DUMMIES,u)
            end
            UNIT_Initiate_Data(u)
        end
    end

    UNIT_RegisterGlobalEvents = nil
end

function UNIT_Boss_Register(unit)
    table.insert(BOSSES,unit)
end

function UNIT_Boss_Clear()
    for i=#BOSSES,1,-1 do
        UNIT_RemoveClean(BOSSES[i])
        BOSSES[i] = nil
    end
    BOSSES = {}
end

function UNIT_MemoryClear(unit)
    local id = GetHandleIdBJ(unit)
    SPELLS_DATA[id] = nil
    dmgFactor_Data[id] = nil
    dmgFactor_Data_Victim[id] = nil
    healAbsorb[id] = nil
    healRecord[id] = nil
    healData[id] = nil
    dmgAbsorb[id] = nil
    dmgRecord[id] = nil
    dmgData[id] = nil
    ATTACKSPEED_CONSTANTS[id] = nil
    MOVESPEED_CONSTANTS[id] = nil
    ARMOR_CONSTANTS[id] = nil
    HPREGEN_CONSTANTS[id] = nil
    HP_CONSTANTS[id] = nil
    STATS_CONSTANTS[id] = nil
    ATTDMG_CONSTANTS[id] = nil
    CASTTIME_CONSTANTS[id] = nil
    id = nil
    COOLDOWN_TABLE[unit] = nil
end

function UNIT_IsCreep(unit)
    for i,u in pairs(BOSS_CREEPS) do
        if u == unit then
            return true
        end
    end
    return false
end

function UNIT_IsBoss(unit)
    for i,u in pairs(BOSSES) do
        if u == unit then
            return true
        end
    end
    return false
end

function UNIT_DeadEvent_MemoryClear(unit)
    if unit ~= HERO then
        UNIT_MemoryClear(unit)
    end
end

function UNIT_RemoveClean(unit)
    if unit == TARGET then
        TARGET = nil
    end
    BUFF_UnitClearAll(unit)
    UNIT_MemoryClear(unit)
    RemoveUnit(unit)
end

function UNIT_RemoveAllDeads()
    for i,u in pairs(ALL_UNITS) do
        if GetOwningPlayer(u) ~= PLAYER and not(UNIT_IsBoss(u)) and IsUnitDeadBJ(u) then
            UNIT_RemoveClean(u)
        end
    end
end