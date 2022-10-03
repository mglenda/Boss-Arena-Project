----------------------------------------------------
--------------------PLAGUE CULT---------------------
----------------------------------------------------

function PlagueCult_Init(diff)
    local b_x,b_y = GetRectCenterX(BOSS_DATA[BOSS_PLAGUE_CULT].regions.spawn_Boss[1]),GetRectCenterY(BOSS_DATA[BOSS_PLAGUE_CULT].regions.spawn_Boss[1])
    local b_xx,b_yy = GetRectCenterX(BOSS_DATA[BOSS_PLAGUE_CULT].regions.spawn_Boss[2]),GetRectCenterY(BOSS_DATA[BOSS_PLAGUE_CULT].regions.spawn_Boss[2])
    local o_x,o_y = GetRectCenterX(BOSS_DATA[BOSS_PLAGUE_CULT].regions.arena_Center),GetRectCenterY(BOSS_DATA[BOSS_PLAGUE_CULT].regions.arena_Center)
    local h_x,h_y = GetRectCenterX(BOSS_DATA[BOSS_PLAGUE_CULT].regions.spawn_Hero),GetRectCenterY(BOSS_DATA[BOSS_PLAGUE_CULT].regions.spawn_Hero)
    UNIT_Boss_Register(UNIT_Create(PLAYER_PASSIVE, BOSS_DATA[BOSS_PLAGUE_CULT].boss_id[1], b_x, b_y, 270.00))
    UNIT_Boss_Register(UNIT_Create(PLAYER_PASSIVE, BOSS_DATA[BOSS_PLAGUE_CULT].boss_id[2], b_xx, b_yy, 270.00))
    HERO_Move(h_x,h_y,o_x,o_y)
    PanCameraToTimedForPlayer(PLAYER,o_x,o_y,0)
    TT_MakeUnit_Target(BOSSES[1])

    MAIN_CreateArenaFogModifiers(BOSS_PLAGUE_CULT)

    b_x,b_y,o_x,o_y,h_x,h_y,b_xx,b_yy = nil,nil,nil,nil,nil,nil,nil,nil

    FIGHT_DATA.phase = 1
    FIGHT_DATA.diff = diff
    FIGHT_DATA.Zamidaan = BOSSES[1]
    FIGHT_DATA.Venatrix = BOSSES[2]
    FIGHT_DATA.spellEffects = {
        [GetHandleIdBJ(FIGHT_DATA.Zamidaan)] = {}
        ,[GetHandleIdBJ(FIGHT_DATA.Venatrix)] = {}
    }

    MS_Freeze(BOSSES[1])
    MS_Freeze(BOSSES[2])
    SetTimeOfDay(6.00)
    PlagueCult_Encounter_Begin()

    BOSS_PlayAnimation(FIGHT_DATA.Venatrix,BOSS_PLAGUE_CULT,'A_VENAT_FLY_STUNNED')

    trg = CreateBossTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trg, Condition(PlagueCult_IsBossCaster))
    TriggerAddAction(trg, PlagueCult_SpellEffects)

    trg = CreateBossTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trg, Condition(PlagueCult_IsBossCaster))
    TriggerAddAction(trg, Plaguecult_SpellEffects_Finish)

    trg = CreateBossTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trg, Condition(PlagueCult_IsBossCaster))
    TriggerAddAction(trg, PlagueCult_SpellEffects_Interrupt)

    trg = CreateBossTrigger()
    TriggerRegisterUnitEvent(trg, BOSSES[1], EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(trg, BOSSES[2], EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(trg, HERO, EVENT_UNIT_DEATH)
    TriggerAddAction(trg, function()
        if GetDyingUnit() == HERO then
            BOSS_Defeat(BOSS_PLAGUE_CULT)
            DestroyTrigger(GetTriggeringTrigger())
        elseif not(IsUnitAliveBJ(BOSSES[1])) and not(IsUnitAliveBJ(BOSSES[2])) then
            BOSS_Victory(BOSS_PLAGUE_CULT)
            DestroyTrigger(GetTriggeringTrigger())
        end
    end)

    BOSS_CreateFleeTrigger(BOSS_PLAGUE_CULT)

    trg = nil
end

function PlagueCult_SpellEffects()
    local u = GetSpellAbilityUnit()
    if GetSpellAbilityId() == ABCODE_VENOMPULZAR then
        BOSS_PlayAnimation(u,BOSS_PLAGUE_CULT,'A_ZAMID_CHANNELING')
        PlagueCult_AddSpellEffectTarget('left hand',u,'Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl',0.75)
        PlagueCult_AddSpellEffectTarget('right hand',u,'Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl',0.75)
    end
    u = nil
end

function Plaguecult_SpellEffects_Finish()
    FIGHT_DATA.FinishedAb = GetSpellAbilityId()
    local u = GetSpellAbilityUnit()
    if FIGHT_DATA.FinishedAb == ABCODE_VENOMPULZAR then
        PlagueCult_RemoveSpellEffects(u)
        PlagueCult_VenomPulzar_Start()
    end
    FIGHT_DATA.FinishedAb = nil
    u = nil
end

function PlagueCult_SpellEffects_Interrupt()
    local abId,u = GetSpellAbilityId(),GetSpellAbilityUnit()
    if abId ~= FIGHT_DATA.FinishedAb then
        if abId == ABCODE_VENOMPULZAR then
            PlagueCult_RemoveSpellEffects(u)
            PlagueCult_VenomPulzar_Stop()
        end
    end
    u = nil
end 

function PlagueCult_VenomPulzar_Cast()
    --BOSS_Transmission(BOSS_PLAGUE_CULT,'regrowth')
    IssueImmediateOrderBJ(FIGHT_DATA.Zamidaan, "holybolt")
end

function PlagueCult_VenomPulzar_Start()

end

function PlagueCult_VenomPulzar_Stop()

end

function PlagueCult_IsBossCaster()
    return GetSpellAbilityUnit() == BOSSES[1] or GetSpellAbilityUnit() == BOSSES[2]
end

function PlagueCult_Start()
    BOSS_StartRecordTrigger()
    SetUnitOwner(BOSSES[1], PLAYER_BOSS, true)
    SetUnitOwner(BOSSES[2], PLAYER_BOSS, true)
    UNIT_SetDmgImmune(BOSSES[1], true)
    UNIT_SetDmgImmune(BOSSES[2], true)
    PlagueCult_VenomPulzar_Cast()
end

function PlagueCult_Encounter_Begin()
    BOSS_RunCounter(5,PlagueCult_Start)
end

function PlagueCult_Flee()
    if IsUnitAliveBJ(BOSSES[1]) then
        UNIT_SetDmgImmune(BOSSES[1], true)
        PauseUnitBJ(true, BOSSES[1])
    end
    if IsUnitAliveBJ(BOSSES[2]) then
        UNIT_SetDmgImmune(BOSSES[2], true)
        PauseUnitBJ(true, BOSSES[2])
    end
    --BOSS_Transmission(BOSS_DRUID_ID,'flee')

    BUFF_UnitClearAll(HERO)
    SetUnitLifePercentBJ(HERO, 100)

    local x = IsUnitAliveBJ(BOSSES[1]) and GetUnitX(BOSSES[1]) or GetUnitX(BOSSES[2])
    local y = IsUnitAliveBJ(BOSSES[1]) and GetUnitY(BOSSES[1]) or GetUnitY(BOSSES[2])
    PanCameraToTimedForPlayer(PLAYER, x, y, 4.5)
    x,y = nil,nil

    BOSS_RemoveAllUnits()
    WaitAndDo(5.0,PlagueCult_Flushing)

    ARENA_ACTIVATED = false
end

function PlagueCult_Victory()
    --BOSS_Transmission(BOSS_DRUID_ID,'victory')
    UNIT_SetDmgImmune(HERO, true)
    BOSS_RemoveAllUnits()
    WaitAndDo(7.0,PlagueCult_Flushing)
    ARENA_ACTIVATED = false
end

function PlagueCult_Defeat()
    --BOSS_Transmission(BOSS_DRUID_ID,'defeat')
    if IsUnitAliveBJ(BOSSES[1]) then
        UNIT_SetDmgImmune(BOSSES[1], true)
        PauseUnitBJ(true, BOSSES[1])
    end
    if IsUnitAliveBJ(BOSSES[2]) then
        UNIT_SetDmgImmune(BOSSES[2], true)
        PauseUnitBJ(true, BOSSES[2])
    end
    BOSS_RemoveAllUnits()
    WaitAndDo(8.0,PlagueCult_Flushing)
    ARENA_ACTIVATED = false
end

function PlagueCult_Flushing()
    UNIT_Boss_Clear()
    MAIN_ClearFogModifiers()
    BOSS_ShowJournalButton()
    UI_ShowHeroPortrait()
    MAIN_MoveHero()
    WIDGET_HideAll()
end

function PlagueCult_AddSpellEffectTarget(where,unit,effect,scale)
    local eff = BOSS_CreateEffectAttached(where,unit,effect)
    BlzSetSpecialEffectScale(eff, scale or BlzGetSpecialEffectScale(eff))
    table.insert(FIGHT_DATA.spellEffects[GetHandleIdBJ(unit)],eff)
    return eff
end

function PlagueCult_RemoveSpellEffects(unit)
    for i = #FIGHT_DATA.spellEffects[GetHandleIdBJ(unit)],1,-1 do
        if FIGHT_DATA.eff_pol_RemoverTable then
            for x = #FIGHT_DATA.eff_pol_RemoverTable,1,-1 do
                if FIGHT_DATA.eff_pol_RemoverTable[x] == FIGHT_DATA.spellEffects[GetHandleIdBJ(unit)][i] then
                    table.remove(FIGHT_DATA.eff_pol_RemoverTable,x)
                end
            end
        end
        if FIGHT_DATA.eff_pol_SpawnTable then
            for x = #FIGHT_DATA.eff_pol_SpawnTable,1,-1 do
                if FIGHT_DATA.eff_pol_SpawnTable[x].e == FIGHT_DATA.spellEffects[GetHandleIdBJ(unit)][i] then
                    table.remove(FIGHT_DATA.eff_pol_SpawnTable,x)
                end
            end
        end
        DestroyEffectBJ(FIGHT_DATA.spellEffects[GetHandleIdBJ(unit)][i])
        table.remove(FIGHT_DATA.spellEffects[GetHandleIdBJ(unit)],i)
    end
end

function PlagueCult_RemoveSpellEffects_Polished(unit)
    for i = #FIGHT_DATA.spellEffects[GetHandleIdBJ(unit)],1,-1 do
        GENERIC_Effect_PolishedRemove_AddToQueue(FIGHT_DATA.spellEffects[GetHandleIdBJ(unit)][i])
        table.remove(FIGHT_DATA.spellEffects[GetHandleIdBJ(unit)],i)
    end
end