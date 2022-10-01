----------------------------------------------------
---------------------Shaman-------------------------
----------------------------------------------------

function Shaman_Init(diff)
    local b_x,b_y = GetRectCenterX(BOSS_DATA[BOSS_SHAMAN_ID].regions.spawn_Boss),GetRectCenterY(BOSS_DATA[BOSS_SHAMAN_ID].regions.spawn_Boss)
    local o_x,o_y = GetRectCenterX(BOSS_DATA[BOSS_SHAMAN_ID].regions.arena_Center),GetRectCenterY(BOSS_DATA[BOSS_SHAMAN_ID].regions.arena_Center)
    local h_x,h_y = GetRectCenterX(BOSS_DATA[BOSS_SHAMAN_ID].regions.spawn_Hero),GetRectCenterY(BOSS_DATA[BOSS_SHAMAN_ID].regions.spawn_Hero)
    UNIT_Boss_Register(UNIT_Create(PLAYER_PASSIVE, BOSS_DATA[BOSS_SHAMAN_ID].boss_id[1], b_x, b_y, 270.00))
    HERO_Move(h_x,h_y,o_x,o_y)
    PanCameraToTimedForPlayer(PLAYER,o_x,o_y,0)
    TT_MakeUnit_Target(BOSSES[1])

    MAIN_CreateArenaFogModifiers(BOSS_SHAMAN_ID)

    BOSS_Transmission(BOSS_SHAMAN_ID,'init')

    b_x,b_y,o_x,o_y,h_x,h_y = nil,nil,nil,nil,nil,nil

    FIGHT_DATA.phase = 1
    FIGHT_DATA.diff = diff
    FIGHT_DATA.Elementals = {}
    FIGHT_DATA.SpellFuncs = {}
    FIGHT_DATA.state = 0
    FIGHT_DATA.spellEffects = {}
    FIGHT_DATA.nova_cast = 1

    MS_Freeze(BOSSES[1])
    BOSS_PlayAnimationAndDo(BOSSES[1],BOSS_SHAMAN_ID,'A_STANDUP',3.0,Shaman_Encounter_Begin)

    local trg = CreateBossTrigger()
    TriggerRegisterUnitEvent(trg, BOSSES[1], EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(trg, HERO, EVENT_UNIT_DEATH)
    TriggerAddAction(trg, function()
        if GetDyingUnit() == HERO then
            BOSS_Defeat(BOSS_SHAMAN_ID)
        else
            BOSS_Victory(BOSS_SHAMAN_ID)
        end
        DestroyTrigger(GetTriggeringTrigger())
    end)

    trg = CreateBossTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trg, Condition(Shaman_IsShamanCaster))
    TriggerAddAction(trg, Shaman_SpellEffects)

    trg = CreateBossTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trg, Condition(Shaman_IsShamanCaster))
    TriggerAddAction(trg, Shaman_SpellEffects_Finish)


    trg = CreateBossTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trg, Condition(Shaman_IsShamanCaster))
    TriggerAddAction(trg, Shaman_SpellEffects_Interrupt)

    if diff == BOSS_DIFFICULTY_HEROIC then
        local b_id = GetHandleIdBJ(BOSSES[1])
        HP_CONSTANTS[b_id] = {
            {constant = 260000}
        }
        UNIT_RecalculateStats(BOSSES[1])
        UNIT_SetEnergyCap(BOSSES[1],100.0)
        UNIT_SetEnergy(BOSSES[1],0.0)
        UNIT_SetEnergyTheme(BOSSES[1],DBM_BAR_clBLUE)

        BOSSBAR_Show('Overcharged',DBM_BAR_clBLUE)
        BOSSBAR_Set(0.0,true,100.0,0)
        b_id = nil
    end

    FIGHT_DATA.mid_phaseTrg_A = CreateBossTrigger()
    TriggerRegisterUnitLifeEvent(FIGHT_DATA.mid_phaseTrg_A, BOSSES[1], LESS_THAN_OR_EQUAL, BlzGetUnitMaxHP(BOSSES[1]) * 0.7)
    TriggerAddAction(FIGHT_DATA.mid_phaseTrg_A, function()
        DestroyTrigger(FIGHT_DATA.mid_phaseTrg_A)
        FIGHT_DATA.mid_phaseTrg_A = nil
        DisableTrigger(FIGHT_DATA.mid_phaseTrg_B)
        Shaman_Windfury_Trigger()
    end)

    FIGHT_DATA.mid_phaseTrg_B = CreateBossTrigger()
    TriggerRegisterUnitLifeEvent(FIGHT_DATA.mid_phaseTrg_B, BOSSES[1], LESS_THAN_OR_EQUAL, BlzGetUnitMaxHP(BOSSES[1]) * 0.4)
    TriggerAddAction(FIGHT_DATA.mid_phaseTrg_B, function()
        DestroyTrigger(FIGHT_DATA.mid_phaseTrg_B)
        FIGHT_DATA.mid_phaseTrg_B = nil
        Shaman_Windfury_Trigger()
    end)

    BOSS_CreateFleeTrigger(BOSS_SHAMAN_ID)

    trg = nil
end

function Shaman_Start()
    SetUnitOwner(BOSSES[1], PLAYER_BOSS, true)
    MS_Unfreeze(BOSSES[1])
    local enrage_time = FIGHT_DATA.diff >= BOSS_DIFFICULTY_HEROIC and 840.0 or 840.0
    DBM_RegisterTimer({
        time = enrage_time
        ,icon = 'war3mapImported\\BTN_Bloodlust.dds'
        ,name = 'Shamanistic Rage'
        ,id = 'enrage'
        ,barTheme = DBM_BAR_clRED
        ,finishFunc = Shaman_EnrageBuff
    })
    if FIGHT_DATA.diff >= BOSS_DIFFICULTY_HEROIC then
        DBM_RegisterTimer({
            time = 25.0
            ,icon = 'war3mapImported\\BTN_ElectricSpark.dds'
            ,name = 'Lighting Spark'
            ,id = 'l_spark'
            ,barTheme = DBM_BAR_clLIGHTBLUE
            ,finishFunc = Shaman_LightingSpark_Summon
        })
    end
    Shaman_OrbOfLighting_Cast()
    enrage_time = nil
end

function Shaman_EnrageBuff()
    BUFF_AddDebuff_Override({
        name = 'SHAMANISTIC_RAGE'
        ,target = BOSSES[1]
    })
end

function Shaman_Encounter_Begin()
    Shaman_SpawnElementals()
    BOSS_RunCounter(5,Shaman_Start)
end

function Shaman_HealingWave_Cast()
    BOSS_Transmission(BOSS_SHAMAN_ID,'regrowth')
    IssueImmediateOrderBJ(BOSSES[1], "holybolt")
end

function Shaman_LightingShield_Cast()
    IssueImmediateOrderBJ(BOSSES[1], "volcano")
end

function Shaman_OrbOfLighting_Cast()
    IssueImmediateOrderBJ(BOSSES[1], "unroot")
end

function Shaman_ChainLighting_Cast()
    BOSS_Transmission(BOSS_SHAMAN_ID,'lighting_orb')
    IssueTargetOrderBJ(BOSSES[1], "ambush", HERO)
end

function Shaman_ActivateTotems_Cast()
    BOSS_Transmission(BOSS_SHAMAN_ID,'summon_totems')
    IssueImmediateOrderBJ(BOSSES[1], "charm")
end

function Shaman_ElementalNova_Cast()
    BOSS_Transmission(BOSS_SHAMAN_ID,'elemental_nova')
    IssueImmediateOrderBJ(BOSSES[1], "cloudoffog")
end

function Shaman_ElementalBlast_Cast()
    IssueTargetOrderBJ(BOSSES[1], "clusterrockets", HERO)
end

function Shaman_IsShamanCaster()
    return GetSpellAbilityUnit() == BOSSES[1]
end

function Shaman_SpellEffects()
    if GetSpellAbilityId() == ABCODE_CHAINLIGHTING then
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL_CHANNEL')
        Shaman_AddSpellEffectTarget('left hand',BOSSES[1],'Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl',1.4)
        Shaman_ChainLighting_Start()

    elseif GetSpellAbilityId() == ABCODE_ORBOFLIGHTING then
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL')
        Shaman_AddSpellEffectTarget('left hand',BOSSES[1],'Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl',1.2)

    elseif GetSpellAbilityId() == ABCODE_HEALINGWAVE then
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL_CHANNEL')
        Shaman_AddSpellEffectTarget('left hand',BOSSES[1],'Abilities\\Weapons\\BansheeMissile\\BansheeMissile.mdl',1.2)
        Shaman_AddSpellEffectTarget('right hand',BOSSES[1],'Abilities\\Weapons\\BansheeMissile\\BansheeMissile.mdl',1.2)
        Shaman_HealingWave_Start()

    elseif GetSpellAbilityId() == ABCODE_LIGHTINGSHIELD then
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL_CHANNEL')
        Shaman_AddSpellEffectTarget('left hand',BOSSES[1],'Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl',1.2)
        Shaman_AddSpellEffectTarget('right hand',BOSSES[1],'Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl',1.2)
    
    elseif GetSpellAbilityId() == ABCODE_WINDFURY then
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL')
        Shaman_AddSpellEffectTarget('left hand',BOSSES[1],'Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdl',1.2)
        Shaman_AddSpellEffectTarget('right hand',BOSSES[1],'Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdl',1.2)

    elseif GetSpellAbilityId() == ABCODE_TOTEMS_ACTIVATE then
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL')

    elseif GetSpellAbilityId() == ABCODE_FIREELEMENT then
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL')
        Shaman_AddSpellEffectTarget('left hand',BOSSES[1],'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
        Shaman_FireElement_Start()

    elseif GetSpellAbilityId() == ABCODE_WINDELEMENT then
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_FLY_SPELL')
        Shaman_AddSpellEffectTarget('right hand',BOSSES[1],'Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdl',1.6)
        Shaman_WindElement_Start()
        
    elseif GetSpellAbilityId() == ABCODE_WATERELEMENT then
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL')
        Shaman_WaterElement_Start()

    elseif GetSpellAbilityId() == ABCODE_LIGHTINGELEMENT then
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL_CHANNEL')
        Shaman_LightingElement_Start()

    elseif GetSpellAbilityId() == ABCODE_ELEMENTALNOVA then
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL_CHANNEL')
        Shaman_Exhausted_Effects_Start()

    elseif GetSpellAbilityId() == ABCODE_ELEMENTALBLAST then
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL_CHANNEL')
        Shaman_Exhausted_Effects_Start()
        Shaman_ElementalBlast_Start()

    end
end

function Shaman_SpellEffects_Interrupt()
    local abId = GetSpellAbilityId()
    if abId ~= FIGHT_DATA.FinishedAb then
        if abId == ABCODE_CHAINLIGHTING then
            Shaman_ChainLighting_Stop()
            Shaman_RemoveSpellEffects()
        elseif abId == ABCODE_HEALINGWAVE then
            Shaman_RemoveSpellEffects()
        elseif abId == ABCODE_ORBOFLIGHTING then
            Shaman_RemoveSpellEffects()
        elseif abId == ABCODE_LIGHTINGSHIELD then
            Shaman_RemoveSpellEffects()
        elseif abId == ABCODE_WINDFURY then
            Shaman_RemoveSpellEffects()
        elseif abId == ABCODE_TOTEMS_ACTIVATE then
            Shaman_RemoveSpellEffects()
        elseif abId == ABCODE_FIREELEMENT then
            Shaman_FireElement_End()
        elseif abId == ABCODE_WINDELEMENT then
            Shaman_WindElement_End()
        elseif abId == ABCODE_WATERELEMENT then
            Shaman_WaterElement_End()
        elseif abId == ABCODE_LIGHTINGELEMENT then
            Shaman_LightingElement_End()
        elseif abId == ABCODE_ELEMENTALNOVA then
            Shaman_Exhausted_Effects_End()
        elseif abId == ABCODE_ELEMENTALBLAST then
            Shaman_Exhausted_Effects_End()
        end
    end
end

function Shaman_SpellEffects_Finish()
    FIGHT_DATA.FinishedAb = GetSpellAbilityId()
    if FIGHT_DATA.FinishedAb == ABCODE_CHAINLIGHTING then
         Shaman_ChainLighting_Finish()

    elseif FIGHT_DATA.FinishedAb == ABCODE_HEALINGWAVE then
        MS_Freeze(BOSSES[1])
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL_THROW',2.25)
        BOSS_WaitAndDo(0.75,Shaman_HealingWave_Finish)

    elseif FIGHT_DATA.FinishedAb == ABCODE_ORBOFLIGHTING then
        MS_Freeze(BOSSES[1])
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL_THROW',1.5)
        BOSS_WaitAndDo(0.5,Shaman_OrbOfLighting_Finish)

    elseif FIGHT_DATA.FinishedAb == ABCODE_LIGHTINGSHIELD then
        MS_Freeze(BOSSES[1])
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL_THROW',2.25)
        BOSS_WaitAndDo(0.75,Shaman_LightingShield_Finish)

    elseif FIGHT_DATA.FinishedAb == ABCODE_WINDFURY then
        MS_Freeze(BOSSES[1])
        BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL_THROW',2.0)
        BOSS_WaitAndDo(1.1,Shaman_Windfury_Start)

    elseif FIGHT_DATA.FinishedAb == ABCODE_TOTEMS_ACTIVATE then
        Shaman_Totems_Activate()

    elseif FIGHT_DATA.FinishedAb == ABCODE_FIREELEMENT then
        Shaman_FireElement_End()

    elseif FIGHT_DATA.FinishedAb == ABCODE_WINDELEMENT then
        Shaman_WindElement_End()

    elseif FIGHT_DATA.FinishedAb == ABCODE_WATERELEMENT then
        Shaman_WaterElement_End()

    elseif FIGHT_DATA.FinishedAb == ABCODE_LIGHTINGELEMENT then
        Shaman_LightingElement_End()
    
    elseif FIGHT_DATA.FinishedAb == ABCODE_ELEMENTALNOVA then
        Shaman_Exhausted_Effects_End()
        Shaman_ElementalNova()
        Shaman_Totems_Activate(true)
    elseif FIGHT_DATA.FinishedAb == ABCODE_ELEMENTALBLAST then
        Shaman_ElementalBlast_Finish()

    end
    FIGHT_DATA.FinishedAb = nil
end

function Shaman_LightingSpark_Summon()
    local x,y = GetRectCenterX(BOSS_DATA[BOSS_SHAMAN_ID].regions.arena_Center),GetRectCenterY(BOSS_DATA[BOSS_SHAMAN_ID].regions.arena_Center)
    local dist = GetRandomReal(500.0,1000.0)
    local ang = GetRandomReal(0.0, 360.0)
    local z = 150.0
    x,y = MATH_MoveXY(x,y, dist, ang * bj_DEGTORAD)

    local spark = BOSS_CreateEffect('Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl',x,y)
    BlzSetSpecialEffectScale(spark, 1.0)
    BlzSetSpecialEffectZ(spark, z)
    local marker = BOSS_CreateEffect('war3mapImported\\Spell Marker Blue.mdx',x,y)
    BlzSetSpecialEffectScale(marker, 0.01)

    table.insert(BOSS_MISSLES,{
        missle = spark
        ,marker = marker
        ,height = z
        ,id = 'l_spark'
        ,x = x
        ,y = y
    })
    GENERIC_Effect_PolishedSpawn_AddToQueue(spark,5.0)
    GENERIC_Effect_PolishedSpawn_AddToQueue(marker,4.0)
    BOSS_WaitAndDoExclusive(4.0,Shaman_LightingSpark_Activate,spark)

    DBM_RegisterTimer({
        time = 40.0
        ,icon = 'war3mapImported\\BTN_ElectricSpark.dds'
        ,name = 'Lighting Spark'
        ,id = 'l_spark'
        ,barTheme = DBM_BAR_clLIGHTBLUE
        ,finishFunc = Shaman_LightingSpark_Summon
    })

    x,y,dist,ang,z,marker = nil,nil,nil,nil,nil,nil
end

function Shaman_LightingSpark_Activate(spark)
    for i=#BOSS_MISSLES,1,-1 do
        if BOSS_MISSLES[i].missle == spark then
            BOSS_MISSLES[i].active = 0.0
            Shaman_LightingSpark_RefreshTarget(i)
            local tx,ty = GetUnitXY(BOSS_MISSLES[i].target)
            local tz = UNIT_GetChestHeight(BOSS_MISSLES[i].target)
            BOSS_MISSLES[i].bolt = BOSS_CreateLighting('PURP', true, tx, ty, tz, BOSS_MISSLES[i].x, BOSS_MISSLES[i].y, BOSS_MISSLES[i].height)
            BOSS_MISSLES[i].bolt_spark = BOSS_CreateEffect('Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl',tx,ty)
            BlzSetSpecialEffectZ(BOSS_MISSLES[i].bolt_spark, tz)
            BlzSetSpecialEffectScale(BOSS_MISSLES[i].bolt_spark, 2.0)

            tx,ty,tz = nil,nil,nil
        end
    end
    if FIGHT_DATA.overfade_trigger then
        DestroyTrigger(FIGHT_DATA.overfade_trigger)
        FIGHT_DATA.overfade_trigger = nil
    end
    if not(FIGHT_DATA.spark_trigger) then
        FIGHT_DATA.spark_trigger = CreateBossTrigger()
        TriggerRegisterTimerEventPeriodic(FIGHT_DATA.spark_trigger, 0.02)
        TriggerAddAction(FIGHT_DATA.spark_trigger, Shaman_LightingSpark_Tick)
    end
end

function Shaman_LightingSpark_RefreshTarget(id)
    local hx,hy = GetUnitXY(HERO)
    if MATH_GetDistance(hx,hy,BOSS_MISSLES[id].x,BOSS_MISSLES[id].y) <= 400.0 then
        BOSS_MISSLES[id].target = HERO
    else
        BOSS_MISSLES[id].target = BOSSES[1]
    end
    hx,hy = nil,nil
end

function Shaman_LightingSpark_Tick()
    local m_c = 0
    for i=#BOSS_MISSLES,1,-1 do
        if BOSS_MISSLES[i].id == 'l_spark' and BOSS_MISSLES[i].active then
            if BOSS_MISSLES[i].active >= 15.0 then
                BOSS_DestroyEffect(BOSS_MISSLES[i].missle)
                GENERIC_Effect_PolishedRemove_AddToQueue(BOSS_MISSLES[i].marker)
                BOSS_DestroyLighting(BOSS_MISSLES[i].bolt)
                BOSS_DestroyEffect(BOSS_MISSLES[i].bolt_spark)
                table.remove(BOSS_MISSLES,i)
            else
                local spark_id = GetHandleIdBJ(BOSS_MISSLES[i].missle)
                local h_hit_cd = UNIT_GetData(HERO,spark_id) or 50
                
                Shaman_LightingSpark_RefreshTarget(i)
                local tx,ty = GetUnitXY(BOSS_MISSLES[i].target)
                local tz = UNIT_GetChestHeight(BOSS_MISSLES[i].target)
                MoveLightningEx(BOSS_MISSLES[i].bolt, true, tx, ty, tz, BOSS_MISSLES[i].x, BOSS_MISSLES[i].y, BOSS_MISSLES[i].height)
                BlzSetSpecialEffectPosition(BOSS_MISSLES[i].bolt_spark, tx, ty, tz)

                if BOSS_MISSLES[i].target == HERO then
                    if h_hit_cd >= 50 then
                        BUFF_AddDebuff_Stack({
                            name = 'CHARGED'
                            ,target = HERO
                        })
                        BUFF_RefreshDebuffDurationAllStacks(HERO,'CHARGED')
                        h_hit_cd = -1
                    end
                else
                    local e,e_c = UNIT_GetEnergy(BOSS_MISSLES[i].target),UNIT_GetEnergyCap(BOSS_MISSLES[i].target)
                    e = (e + 0.2) >= e_c and e_c or (e + 0.2)
                    UNIT_SetEnergy(BOSS_MISSLES[i].target,e)
                    BOSSBAR_Set(e,true,e_c,0)
                    if e >= e_c then
                        Shaman_LightingSpark_Erupt()
                    end
                end

                UNIT_SetData(HERO,spark_id,h_hit_cd + 1)

                m_c = m_c + 1
                BOSS_MISSLES[i].active = BOSS_MISSLES[i].active + 0.02
                tx,ty,tz = nil,nil,nil
            end
        end
    end
    if m_c == 0 then
        DestroyTrigger(FIGHT_DATA.spark_trigger)
        FIGHT_DATA.spark_trigger = nil
        if not(FIGHT_DATA.overfade_trigger) and UNIT_GetEnergy(BOSSES[1]) > 0 then
            FIGHT_DATA.overfade_trigger = CreateBossTrigger()
            TriggerRegisterTimerEventPeriodic(FIGHT_DATA.overfade_trigger, 0.02)
            TriggerAddAction(FIGHT_DATA.overfade_trigger, Shaman_LightingSpark_OverchargeFading)
        end
    end
    m_c = nil
end

function Shaman_LightingSpark_OverchargeFading()
    local e,e_c = UNIT_GetEnergy(BOSSES[1]),UNIT_GetEnergyCap(BOSSES[1])
    if e > 0 then
        e = e - 0.16 >= 0 and e - 0.16 or 0
        UNIT_SetEnergy(BOSSES[1],e)
        BOSSBAR_Set(e,true,e_c,0)
    else
        DestroyTrigger(FIGHT_DATA.overfade_trigger)
        FIGHT_DATA.overfade_trigger = nil
    end
    e,e_c = nil,nil
end

function Shaman_LightingSpark_Erupt()
    Shaman_LightingSpark_DestroyOrbs()

    local x,y = GetUnitXY(BOSSES[1])
    local spark = oldAddSpecialEffect('war3mapImported\\Electric Spark.mdx', x, y)
    BlzSetSpecialEffectScale(spark, 4.5)
    DestroyEffectBJ(spark)

    AddSpecialEffectTargetUnitBJ('chest',HERO,'war3mapImported\\Electric Spark.mdx')
    UNIT_SetEnergy(BOSSES[1],0)
    BOSSBAR_Set(0.0,true,100.0,0)

    local hp_p = 0.75
    local dmg = BlzGetUnitMaxHP(HERO) * hp_p
    DS_DamageUnit(BOSSES[1], HERO, dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_LIGHTNING, ABCODE_LIGHTINGSPARK, 'noCrit')
    spark,x,y,dmg,hp_p = nil,nil,nil,nil,nil
end

function Shaman_LightingSpark_DestroyOrbs()
    for i=#BOSS_MISSLES,1,-1 do
        if BOSS_MISSLES[i].id == 'l_spark' then
            BOSS_DestroyEffect(BOSS_MISSLES[i].missle)
            GENERIC_Effect_PolishedRemove_AddToQueue(BOSS_MISSLES[i].marker)
            if BOSS_MISSLES[i].bolt then
                BOSS_DestroyLighting(BOSS_MISSLES[i].bolt)
                BOSS_DestroyEffect(BOSS_MISSLES[i].bolt_spark)
            end
            table.remove(BOSS_MISSLES,i)
        end
    end
end

function Shaman_ElementalBlast_Start()
    local caster,target = GetSpellAbilityUnit(),GetSpellTargetUnit()
    local c_id = GetHandleIdBJ(caster)
    SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
    SPELLS_DATA[c_id].target = target
    FIGHT_DATA.facing_trig = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(FIGHT_DATA.facing_trig, 0.02)
    TriggerAddAction(FIGHT_DATA.facing_trig,function()
        local cx,cy,tx,ty = GetUnitX(caster),GetUnitY(caster),GetUnitX(target),GetUnitY(target)
        SetUnitFacing(caster, MATH_GetAngleXY(cx,cy,tx,ty))
    end)
end

function Shaman_ElementalBlast_Stop()
    local caster = GetSpellAbilityUnit()
    local c_id = GetHandleIdBJ(caster)
    SPELLS_DATA[c_id].target = nil
    DestroyTrigger(FIGHT_DATA.facing_trig)
    FIGHT_DATA.facing_trig = nil
end

function Shaman_ElementalBlast_Finish()
    local caster = GetSpellAbilityUnit()
    local target = SPELLS_DATA[GetHandleIdBJ(caster)].target
    local c_id = GetHandleIdBJ(caster)
    SPELLS_DATA[c_id].target = nil
    MS_Freeze(caster)

    BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL_THROW',1.5)
    BOSS_WaitAndDo(0.5,Shaman_ElementalBlast_Release,caster,target)
end

function Shaman_ElementalBlast_Release(caster,target)
    Shaman_Exhausted_Effects_End()
    DestroyTrigger(FIGHT_DATA.facing_trig)
    FIGHT_DATA.facing_trig = nil

    local x,y = GetUnitXY(caster)
    local tx,ty = GetUnitXY(target)
    local ang = MATH_GetAngleXY(x,y,tx,ty)
    x,y = MATH_MoveXY(x,y, 140.0, (GetUnitFacing(caster) + 6.0) * bj_DEGTORAD)

    local missle,height = MISSLE_CreateMissleXY('sh_ElBlastA',x,y,ang)

    table.insert(BOSS_MISSLES,{
        missleSpeed = 4.0
        ,missle = missle
        ,height = height
        ,id = 'el_blast'
        ,ang = ang
        ,interval = 0
        ,dmg = true
        ,caster = caster
    })

    missle,height = MISSLE_CreateMissleXY('sh_ElBlastB',x,y,ang)

    table.insert(BOSS_MISSLES,{
        missleSpeed = 4.0
        ,missle = missle
        ,height = height
        ,id = 'el_blast'
        ,ang = ang
        ,interval = 0
    })

    missle,height = MISSLE_CreateMissleXY('sh_ElBlastC',x,y,ang)

    table.insert(BOSS_MISSLES,{
        missleSpeed = 4.0
        ,missle = missle
        ,height = height
        ,id = 'el_blast'
        ,ang = ang
        ,interval = 0
    })

    local trg = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(trg, 0.02)
    TriggerAddAction(trg, Shaman_ElementalBlast_MissleFly)
    trg = nil
    
    MS_Unfreeze(caster)
    if FIGHT_DATA.el_fury then
        FIGHT_DATA.el_fury = nil
        Shaman_ElementalFury()
    else
        Shaman_Totems_CastNext()
    end
end

function Shaman_ElementalBlast_MissleFly()
    local c = 0
    for i,v in pairs(BOSS_MISSLES) do
        if v.id == 'el_blast' then
            local targets = {}
            local mx,my = MISSLE_GetXY(v.missle)
            local t = nil
            if not(BOSS_IsPointInArena(Point(mx,my),BOSS_SHAMAN_ID)) then
                --fly away from arena
                MISSLE_Impact(v.missle)
                table.remove(BOSS_MISSLES,i)
            else
                for j,u in pairs(ALL_UNITS) do
                    if (not(UNIT_IsBoss(u)) or v.interval > 30) and IsUnitAliveBJ(u) and BOSS_IsUnitInArena(u,BOSS_SHAMAN_ID) then
                        local ux,uy = GetUnitXY(u)
                        local dist = MATH_GetDistance(ux,uy,mx,my)
                        if BUFF_UnitHasDebuff(u,'ELEMENTAL_MAGNET') or dist <= 80 then
                            table.insert(targets,{
                                unit = u
                                ,dist = dist
                            })
                        end
                        dist,ux,uy = nil,nil,nil
                    end
                end
                if #targets >= 1 then 
                    table.sort(targets, function (k1, k2) return k1.dist < k2.dist end)
                    local ux,uy = GetUnitXY(targets[1].unit)
                    v.ang = MATH_GetAngleXY(mx,my,ux,uy)
                    if targets[1].dist <= 80 then
                        t = targets[1].unit
                    end
                    ux,uy = nil,nil
                end
                if t then
                    --collision with t (unit)
                    MISSLE_Impact(v.missle)
                    table.remove(BOSS_MISSLES,i)
                    if v.dmg then
                        DS_DamageUnit(v.caster, t, 8500.0, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_UNIVERSAL, ABCODE_ELEMENTALBLAST)
                        BUFF_AddDebuff_Stack({
                            name = 'ELEMENTAL_BLASTED'
                            ,target = t
                        })
                    end
                else
                    BlzSetSpecialEffectYaw(v.missle, v.ang * bj_DEGTORAD)
                    mx,my = MATH_MoveXY(mx,my,v.missleSpeed, v.ang * bj_DEGTORAD)
                    BlzSetSpecialEffectPosition(v.missle, mx, my, v.height)
                    v.missleSpeed = v.missleSpeed + 0.01
                    v.interval = v.interval + 1
                end
            end
            c = c + 1
            targets,mx,my,t = nil,nil,nil,nil
        end
    end
    if c == 0 then
        DestroyTrigger(GetTriggeringTrigger())
    end
end

function Shaman_RefreshTotemsFunc()
    if #FIGHT_DATA.SpellFuncs == 0 then
        FIGHT_DATA.SpellFuncs = {
            Shaman_FireElement_Cast
            ,Shaman_WindElement_Cast
            ,Shaman_WaterElement_Cast
            ,Shaman_LightingElement_Cast
        }
    end
end

function Shaman_ElementalNova()
    local effects = {
        'war3mapImported\\Tidal Burst.mdx'
        ,'war3mapImported\\Electric Spark.mdx'
        ,'war3mapImported\\Nature Blast.mdx'
        ,'war3mapImported\\Wind Blast.mdx'
        ,'Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl'
    }

    local e_tbl = {}

    for i=1,140 do
        local x,y = BOSS_GetRandomCoordsInArena(BOSS_SHAMAN_ID)
        local j = GetRandomInt(1, #effects)
        local eff = oldAddSpecialEffect(effects[j], x, y)
        BlzSetSpecialEffectScale(eff, 1.4)
        table.insert(e_tbl,eff)
        x,y = nil,nil
    end

    WaitAndDo(1.5,function()
        for i=#e_tbl,1,-1 do
            DestroyEffect(e_tbl[i])
            table.remove(e_tbl,i)
        end
        e_tbl = nil
    end)

    for j,u in pairs(ALL_UNITS) do
        if not(UNIT_IsBoss(u)) and IsUnitAliveBJ(u) and BOSS_IsUnitInArena(u,BOSS_SHAMAN_ID) then
            local hp_p = FIGHT_DATA.diff <= BOSS_DIFFICULTY_NORMAL and 0.2 or 0.35
            local dmg = (GetUnitStateSwap(UNIT_STATE_LIFE, u) * hp_p) * FIGHT_DATA.nova_cast
            DS_DamageUnit(BOSSES[1], u, dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_UNIVERSAL, ABCODE_ELEMENTALNOVA, 'noCrit')
            dmg,hp_p = nil
        end
    end

    BUFF_AddDebuff_Override({
        name = 'ELEMENTAL_MAGNET'
        ,target = HERO
    })

    FIGHT_DATA.nova_cast = FIGHT_DATA.nova_cast + 1

    effects = nil
end

function Shaman_Totems_Activate(elBlast)
    Shaman_RemoveSpellEffects()

    local tx,ty = BlzGetLocalSpecialEffectX(FIGHT_DATA.Totems[FIGHT_DATA.Fire]),BlzGetLocalSpecialEffectY(FIGHT_DATA.Totems[FIGHT_DATA.Fire])
    FIGHT_DATA.element_orb_fire = BOSS_CreateEffect('Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl', tx, ty)
    BlzSetSpecialEffectZ(FIGHT_DATA.element_orb_fire, 250.0)
    BlzSetSpecialEffectScale(FIGHT_DATA.element_orb_fire, 3.0)

    tx,ty = BlzGetLocalSpecialEffectX(FIGHT_DATA.Totems[FIGHT_DATA.Wind]),BlzGetLocalSpecialEffectY(FIGHT_DATA.Totems[FIGHT_DATA.Wind])
    FIGHT_DATA.element_orb_wind = BOSS_CreateEffect('Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl', tx, ty)
    BlzSetSpecialEffectZ(FIGHT_DATA.element_orb_wind, 300.0)
    BlzSetSpecialEffectScale(FIGHT_DATA.element_orb_wind, 3.0)

    tx,ty = BlzGetLocalSpecialEffectX(FIGHT_DATA.Totems[FIGHT_DATA.Water]),BlzGetLocalSpecialEffectY(FIGHT_DATA.Totems[FIGHT_DATA.Water])
    FIGHT_DATA.element_orb_water = BOSS_CreateEffect('war3mapImported\\Orb of Frost.mdx', tx, ty)
    BlzSetSpecialEffectZ(FIGHT_DATA.element_orb_water, 250.0)
    BlzSetSpecialEffectScale(FIGHT_DATA.element_orb_water, 1.0)

    tx,ty = BlzGetLocalSpecialEffectX(FIGHT_DATA.Totems[FIGHT_DATA.Lighting]),BlzGetLocalSpecialEffectY(FIGHT_DATA.Totems[FIGHT_DATA.Lighting])
    FIGHT_DATA.element_orb_lighting = BOSS_CreateEffect('Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl', tx, ty)
    BlzSetSpecialEffectZ(FIGHT_DATA.element_orb_lighting, 300.0)
    BlzSetSpecialEffectScale(FIGHT_DATA.element_orb_lighting, 3.0)

    tx,ty = nil,nil

    Shaman_RefreshTotemsFunc()
    Shaman_Totems_CastNext(elBlast)
end

function Shaman_Totems_CastNext(elBlast)
    if BUFF_GetStacksCount(HERO,'WATERELEMENT_BUFF') >= 1 and BUFF_GetStacksCount(HERO,'FIREELEMENT_BUFF') >= 1 and BUFF_GetStacksCount(HERO,'WINDELEMENT_BUFF') >= 1 and BUFF_GetStacksCount(HERO,'LIGHTINGELEMENT_BUFF') >= 1 then
        if FIGHT_DATA.phase < 3 then
            Shaman_ElementalFury()
        elseif not(FIGHT_DATA.windfury) then
            FIGHT_DATA.el_fury = true
            Shaman_ElementalBlast_Cast()
            BUFF_AddDebuff_Override({
                name = 'ELEMENTAL_MAGNET'
                ,target = HERO
            })
        end
    elseif not(FIGHT_DATA.windfury) then
        if #FIGHT_DATA.SpellFuncs > 0 then
            if not(elBlast) then
                Shaman_CastRandomAbility()
            else
                Shaman_ElementalBlast_Cast()
            end
        elseif FIGHT_DATA.phase < 3 then
            Shaman_ActivateTotems_Cast()
        else
            Shaman_ElementalNova_Cast()
        end
    end
end

function Shaman_ElementalFury()
    BUFF_UnitClearDebuffAllStacks(HERO,'WATERELEMENT_BUFF')
    BUFF_UnitClearDebuffAllStacks(HERO,'FIREELEMENT_BUFF')
    BUFF_UnitClearDebuffAllStacks(HERO,'WINDELEMENT_BUFF')
    BUFF_UnitClearDebuffAllStacks(HERO,'LIGHTINGELEMENT_BUFF')
    BUFF_AddDebuff_Override({
        name = 'ELEMENTAL_FURY'
        ,target = HERO
    })
    if not(FIGHT_DATA.windfury) then
        SetUnitFacing(BOSSES[1], 270.0)
        MS_Freeze(BOSSES[1])
        BOSS_PlayAnimationAndDo(BOSSES[1],BOSS_SHAMAN_ID,'A_TORTURE',nil,Shaman_Exhausted_Kneel)
        BOSS_Transmission(BOSS_SHAMAN_ID,'exhausted')

        Shaman_Exhausted_Effects_Start()

        BUFF_AddDebuff_Override({
            name = 'ELEMENTAL_EXHAUSTION'
            ,target = BOSSES[1]
        })

        DBM_RegisterTimer({
            time = 20.0
            ,icon = 'war3mapImported\\BTN_ElementalFury.dds'
            ,name = 'Elemental Fury'
            ,id = 'e_fury'
            ,barTheme = DBM_BAR_clGREEN
            ,finishFunc = Shaman_Exhausted_End
        })
    end
end

function Shaman_Exhausted_Effects_Start()
    FIGHT_DATA.exhausted_effects = {
        'Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl'
        ,'Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdl'
        ,'Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl'
        ,'Abilities\\Weapons\\BansheeMissile\\BansheeMissile.mdl'
    }
    FIGHT_DATA.exhausted_attp = {
        'chest'
        ,'right hand'
        ,'left hand'
    }
    FIGHT_DATA.exhausted_trigger = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(FIGHT_DATA.exhausted_trigger, 0.2)
    TriggerAddAction(FIGHT_DATA.exhausted_trigger, Shaman_Exhausted_Effects)
end

function Shaman_Exhausted_Effects_End()
    DestroyTrigger(FIGHT_DATA.exhausted_trigger)
    FIGHT_DATA.exhausted_trigger = nil
    FIGHT_DATA.exhausted_effects = nil
    FIGHT_DATA.exhausted_attp = nil
end

function Shaman_Exhausted_Effects()
    local i = GetRandomInt(1, #FIGHT_DATA.exhausted_effects)
    local j = GetRandomInt(1, #FIGHT_DATA.exhausted_attp)
    AddSpecialEffectTargetUnitBJ(FIGHT_DATA.exhausted_attp[j],BOSSES[1],FIGHT_DATA.exhausted_effects[i])
end

function Shaman_Exhausted_Kneel()    
    BOSS_PlayAnimationAndDo(BOSSES[1],BOSS_SHAMAN_ID,'A_KNEEL',nil,Shaman_Exhausted_Kneeling)
    
    local trg = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(trg, 0.1)
    TriggerAddAction(trg, function()
        if DBM_GetTimeById('e_fury') <= 2.0 then
            DestroyTrigger(GetTriggeringTrigger())
            Shaman_Exhausted_StandUp()
        end
    end)
end

function Shaman_Exhausted_Kneeling()   
    BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_KNEELING')
    BOSS_Transmission(BOSS_SHAMAN_ID,'exhausted_kneeling')
end

function Shaman_Exhausted_StandUp()
    BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_KNEEL_STAND')
end

function Shaman_Exhausted_End()
    Shaman_Exhausted_Effects_End()
    BUFF_UnitClearDebuffAllStacks(HERO,'ELEMENTAL_FURY')
    BUFF_UnitClearDebuffAllStacks(BOSSES[1],'ELEMENTAL_EXHAUSTION')
    MS_Unfreeze(BOSSES[1])
    Shaman_Totems_CastNext()
end

function Shaman_LightingElement_Cast()
    IssueImmediateOrderBJ(BOSSES[1], 'inferno')
    BOSS_Transmission(BOSS_SHAMAN_ID,'lighting_element')
end

function Shaman_LightingElement_Start()
    local x,y = GetUnitXY(BOSSES[1])
    local z = 150.0
    x,y = MATH_MoveXY(x, y, 100.0, GetUnitFacing(BOSSES[1]) * bj_DEGTORAD)
    FIGHT_DATA.element_eff_lighting = Shaman_AddSpellEffect('Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl', x, y, 4.0)
    BlzSetSpecialEffectZ(FIGHT_DATA.element_eff_lighting, z)

    local tx,ty,tz = BlzGetLocalSpecialEffectX(FIGHT_DATA.element_orb_lighting),BlzGetLocalSpecialEffectY(FIGHT_DATA.element_orb_lighting),BlzGetLocalSpecialEffectZ(FIGHT_DATA.element_orb_lighting)
    FIGHT_DATA.element_lighting_mainBolt = BOSS_CreateLighting('PURP', true, x, y, z, tx, ty, tz)

    FIGHT_DATA.element_casting_lighting = true
    FIGHT_DATA.element_interval_lighting = 0
    FIGHT_DATA.element_interval_bolts = 0
    FIGHT_DATA.element_trigger = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(FIGHT_DATA.element_trigger, 0.02)
    TriggerAddAction(FIGHT_DATA.element_trigger, Shaman_LightingElement_Action)
end

function Shaman_LightingElement_Action()
    for i,v in pairs(BOSS_MISSLES) do
        if v.id == 'orb_light_element' then
            local hx,hy = GetUnitXY(HERO)
            local mx,my = MISSLE_GetXY(v.missle)
            local bolt_polygon = Polygon(
                Point(MATH_MoveXY(v.bolt_x,v.bolt_y,30.0, (MATH_GetAngleXY(v.bolt_x,v.bolt_y,mx,my) - 90.0) * bj_DEGTORAD))
                ,Point(MATH_MoveXY(v.bolt_x,v.bolt_y,30.0, (MATH_GetAngleXY(v.bolt_x,v.bolt_y,mx,my) + 90.0) * bj_DEGTORAD))
                ,Point(MATH_MoveXY(mx,my,30.0, (MATH_GetAngleXY(v.bolt_x,v.bolt_y,mx,my) + 90.0) * bj_DEGTORAD))
                ,Point(MATH_MoveXY(mx,my,30.0, (MATH_GetAngleXY(v.bolt_x,v.bolt_y,mx,my) - 90.0) * bj_DEGTORAD))
            )
            for j,u in pairs(ALL_UNITS) do
                local ux,uy = GetUnitXY(u)
                if not(UNIT_IsBoss(u)) and IsUnitAliveBJ(u) and BOSS_IsUnitInArena(u,BOSS_SHAMAN_ID) then
                    local orb_id = 'orb_hit_' .. GetHandleIdBJ(v.missle)
                    local bolt_id = 'bolt_hit_' .. GetHandleIdBJ(v.missle)
                    local orb_hit_cd = UNIT_GetData(u,orb_id) or 25
                    local bolt_hit_cd = UNIT_GetData(u,bolt_id) or 15
                    if orb_hit_cd >= 25 then
                        if MATH_GetDistance(ux,uy,mx,my) <= 120.00 then
                            --Orb Hit
                            DS_DamageUnit(BOSSES[1], u, 100.0, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_LIGHTNING, ABCODE_LIGHTINGELEMENT)
                            BUFF_RefreshDebuffDurationAllStacks(u,'ELECTRIFIED')
                            BUFF_AddDebuff_Stack({
                                target = u
                                ,name = 'ELECTRIFIED'
                            })
                            UNIT_SetData(u,orb_id,0)
                        else
                            UNIT_SetData(u,orb_id,nil)
                        end
                    else
                        UNIT_SetData(u,orb_id,orb_hit_cd + 1)   
                    end
                    if bolt_hit_cd >= 15 then
                        if IsInPolygon(Point(ux,uy),bolt_polygon) then
                            --laser Hit
                            DS_DamageUnit(BOSSES[1], u, 30.0, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_LIGHTNING, ABCODE_LIGHTINGELEMENT)
                            BUFF_RefreshDebuffDurationAllStacks(u,'ELECTRIFIED')
                            BUFF_AddDebuff_Stack({
                                target = u
                                ,name = 'ELECTRIFIED'
                            })
                            UNIT_SetData(u,bolt_id,0)
                        else
                            UNIT_SetData(u,bolt_id,nil)
                        end
                    else
                        UNIT_SetData(u,bolt_id,bolt_hit_cd + 1)   
                    end
                    orb_id,orb_hit_cd,bolt_hit_cd,bolt_id = nil,nil,nil,nil
                end
                ux,uy = nil,nil
            end
            mx,my = MATH_MoveXY(mx,my,v.missleSpeed, MATH_GetRadXY(mx,my,hx,hy))
            BlzSetSpecialEffectPosition(v.missle, mx, my, v.height)
            MoveLightningEx(v.bolt, true, v.bolt_x, v.bolt_y, v.bolt_z, mx, my, v.height)
            hx,hy,mx,my,bolt_polygon = nil,nil,nil,nil,nil
        end
    end
    if FIGHT_DATA.element_interval_lighting >= 100 and FIGHT_DATA.element_interval_bolts < 5 then
        local x,y = BOSS_GetRandomCoordsInArena(BOSS_SHAMAN_ID)
        local sx,sy,sz = BlzGetLocalSpecialEffectX(FIGHT_DATA.element_eff_lighting),BlzGetLocalSpecialEffectY(FIGHT_DATA.element_eff_lighting),BlzGetLocalSpecialEffectZ(FIGHT_DATA.element_eff_lighting)
        local missle,height = MISSLE_CreateMissleXY('sh_LightOrb',x,y)
        local bolt = BOSS_CreateLighting('PURP', true, sx, sy, sz, x, y, height)
        local tbl = {
            missleSpeed = 6.5
            ,missle = missle
            ,height = height
            ,id = 'orb_light_element'
            ,bolt = bolt
            ,bolt_x = sx
            ,bolt_y = sy
            ,bolt_z = sz
        }
        table.insert(BOSS_MISSLES,tbl)

        missle,height,tbl,x,y,bolt,sx,sy,sz = nil,nil,nil,nil,nil,nil,nil,nil,nil
        FIGHT_DATA.element_interval_lighting = 0
        FIGHT_DATA.element_interval_bolts = FIGHT_DATA.element_interval_bolts + 1
    else
        FIGHT_DATA.element_interval_lighting = FIGHT_DATA.element_interval_lighting + 1
    end
end

function Shaman_LightingElement_DestroyOrbs()
    for i=#BOSS_MISSLES,1,-1 do
        if BOSS_MISSLES[i].id == 'orb_light_element' then
            MISSLE_Impact(BOSS_MISSLES[i].missle)
            BOSS_DestroyLighting(BOSS_MISSLES[i].bolt)
            table.remove(BOSS_MISSLES,i)
        end
    end
end

function Shaman_LightingElement_End()
    DestroyTrigger(FIGHT_DATA.element_trigger)
    FIGHT_DATA.element_trigger = nil
    FIGHT_DATA.element_casting_lighting = nil

    BOSS_DestroyLighting(FIGHT_DATA.element_lighting_mainBolt)
    FIGHT_DATA.element_lighting_mainBolt = nil

    Shaman_RemoveSpellEffects()
    Shaman_LightingElement_DestroyOrbs()

    BUFF_AddDebuff_Override({
        name = 'LIGHTINGELEMENT_BUFF'
        ,target = HERO
    })

    BOSS_DestroyEffect(FIGHT_DATA.element_orb_lighting)
    FIGHT_DATA.element_orb_lighting = nil

    Shaman_Totems_CastNext()
end

function Shaman_WaterElement_Cast()
    IssueImmediateOrderBJ(BOSSES[1], 'impale')
    BOSS_Transmission(BOSS_SHAMAN_ID,'water_element')
end

function Shaman_WaterElement_Start()
    local x,y = GetUnitXY(BOSSES[1])
    local z = 300.0
    x,y = MATH_MoveXY(x, y, 100.0, (GetUnitFacing(BOSSES[1]) + 20.0) * bj_DEGTORAD)
    FIGHT_DATA.element_eff_water = Shaman_AddSpellEffect('Abilities\\Spells\\Undead\\AbsorbMana\\AbsorbManaBirthMissile.mdl', x, y, 3.0)
    BlzSetSpecialEffectZ(FIGHT_DATA.element_eff_water, z)

    local tx,ty,tz = BlzGetLocalSpecialEffectX(FIGHT_DATA.element_orb_water),BlzGetLocalSpecialEffectY(FIGHT_DATA.element_orb_water),BlzGetLocalSpecialEffectZ(FIGHT_DATA.element_orb_water) + 30.0
    FIGHT_DATA.element_lighting_water = BOSS_CreateLighting('WATL', true, x, y, z, tx, ty, tz)

    local abs = 15000.0 + (FIGHT_DATA.diff == BOSS_DIFFICULTY_HEROIC and 3000.0 or 0.0)
    local seed = BUFF_GenerateSeed()
    DS_SetAbsorb(BOSSES[1],BOSSES[1],ABCODE_WATERELEMENT,seed,abs)
    BUFF_AddDebuff_Override({
        name = 'WATERELEMENT_SHIELD'
        ,target = BOSSES[1]
        ,caster = BOSSES[1]
        ,seed = seed
    })
    seed = nil

    FIGHT_DATA.element_casting_water = true
    FIGHT_DATA.element_interval_water = 0
    FIGHT_DATA.element_trigger_water = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(FIGHT_DATA.element_trigger_water, 0.02)
    TriggerAddAction(FIGHT_DATA.element_trigger_water, Shaman_WaterElement_Action)
end

function Shaman_WaterElement_Action()
    if BUFF_GetStacksCount(BOSSES[1],'WATERELEMENT_SHIELD') <= 0 then
        DestroyTrigger(FIGHT_DATA.element_trigger_water)
        FIGHT_DATA.element_trigger_water = nil

        BUFF_AddDebuff_Override({
            name = 'WATERELEMENT_BUFF'
            ,target = HERO
        })
        Shaman_Totems_CastNext()
    else
        if FIGHT_DATA.element_interval_water >= 50 then
            AddSpecialEffectTargetUnitBJ('chest', BOSSES[1], 'Abilities\\Spells\\Items\\RitualDagger\\RitualDaggerTarget.mdl')
            HS_HealUnit(BOSSES[1],BOSSES[1],BlzGetUnitMaxHP(BOSSES[1]) * 0.0028,ABCODE_WATERELEMENT)
            FIGHT_DATA.element_interval_water = 0 
        end
        FIGHT_DATA.element_interval_water = FIGHT_DATA.element_interval_water + 1
    end
end

function Shaman_WaterElement_End()
    FIGHT_DATA.element_casting_water = nil
    Shaman_RemoveSpellEffects()

    BOSS_DestroyLighting(FIGHT_DATA.element_lighting_water)

    BUFF_UnitClearDebuffAllStacks(BOSSES[1],'WATERELEMENT_SHIELD')

    BOSS_DestroyEffect(FIGHT_DATA.element_orb_water)
    FIGHT_DATA.element_orb_water = nil
end

function Shaman_WindElement_Cast()
    local x,y = GetUnitXY(HERO)
    IssuePointOrder(BOSSES[1], 'immolation', x, y)
    BOSS_Transmission(BOSS_SHAMAN_ID,'wind_element')
end

function Shaman_WindElement_Start()
    FIGHT_DATA.element_casting_wind = true
    FIGHT_DATA.element_interval_wind = 0
    FIGHT_DATA.element_trigger = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(FIGHT_DATA.element_trigger, 0.02)
    TriggerAddAction(FIGHT_DATA.element_trigger, Shaman_WindElement_Action)
end

function Shaman_WindElement_Action()
    local hx,hy = GetUnitXY(HERO)
    local bx,by = GetUnitXY(BOSSES[1])
    local ang = MATH_GetAngleXY(bx,by,hx,hy)
    SetUnitFacing(BOSSES[1], ang)

    if FIGHT_DATA.element_interval_wind >= 25 then
        bx,by = GetUnitXY(BOSSES[1])
        local missle = BOSS_AddSpellEffect_Polished('war3mapImported\\cycloneBig.mdl', bx, by, 1.5, 0.3)

        local tbl = {
            missleSpeed = 14.0
            ,missle = missle
            ,rad = ang * bj_DEGTORAD
            ,travel_dist = 0.0
            ,hit_box = 30.0
            ,hit_boxMax = 200.0
            ,maxDist = 3500.0
            ,id = 'el_wind'
        }
        table.insert(BOSS_MISSLES,tbl)

        FIGHT_DATA.element_interval_wind = 0
        if not(FIGHT_DATA.windMissle_trigger) then
            FIGHT_DATA.windMissle_trigger = CreateBossTrigger()
            TriggerRegisterTimerEventPeriodic(FIGHT_DATA.windMissle_trigger, 0.02)
            TriggerAddAction(FIGHT_DATA.windMissle_trigger, Shaman_WindElement_MissleFly)
        end
    end

    FIGHT_DATA.element_interval_wind = FIGHT_DATA.element_interval_wind + 1
    hx,hy,bx,by,ang = nil,nil,nil,nil,nil
end

function Shaman_WindElement_MissleFly()
    local c = 0
    for i,v in pairs(BOSS_MISSLES) do
        if v.id == 'el_wind' then
            local x,y = MISSLE_GetXY(v.missle)
            if v.travel_dist >= v.maxDist or not(BOSS_IsPointInArena(Point(x,y),BOSS_SHAMAN_ID)) then
                GENERIC_Effect_PolishedRemove_AddToQueue(v.missle)
                MISSLE_Impact(v.missle)
                table.remove(BOSS_MISSLES,i)
            else
                x,y = MATH_MoveXY(x,y,v.missleSpeed,v.rad)
                BlzSetSpecialEffectPosition(v.missle, x, y, GetPointZ(x,y))
                v.travel_dist = v.travel_dist + v.missleSpeed
                v.hit_box = v.hit_box < v.hit_boxMax and v.hit_box + 5.0 or v.hit_boxMax

                for j,u in pairs(ALL_UNITS) do
                    local ux,uy = GetUnitXY(u)
                    if not(UNIT_IsBoss(u)) and IsUnitAliveBJ(u) and BOSS_IsUnitInArena(u,BOSS_SHAMAN_ID) then
                        local orb_id = 'orb_hit_' .. GetHandleIdBJ(v.missle)
                        local orb_hit_cd = UNIT_GetData(u,orb_id) or 25
                        if orb_hit_cd >= 25 then
                            if MATH_GetDistance(ux,uy,x,y) <= v.hit_box then
                                --Orb Hit
                                local dmg = FIGHT_DATA.diff <= BOSS_DIFFICULTY_NORMAL and 200.0 or 400.0
                                DS_DamageUnit(BOSSES[1], u, dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FORCE, ABCODE_WINDELEMENT)
                                BUFF_AddDebuff_Stack({
                                    target = u
                                    ,name = 'WINDELEMENT_HIT'
                                })
                                UNIT_SetData(u,orb_id,0)
                                dmg = nil
                            else
                                UNIT_SetData(u,orb_id,nil)
                            end
                        else
                            UNIT_SetData(u,orb_id,orb_hit_cd + 1)   
                        end
                        orb_id,orb_hit_cd = nil,nil
                    end
                    ux,uy = nil,nil
                end
            end
            c = c + 1
        end
    end
    if c == 0 then
        DestroyTrigger(FIGHT_DATA.windMissle_trigger)
        FIGHT_DATA.windMissle_trigger = nil
    end
end

function Shaman_WindElement_End()
    Shaman_RemoveSpellEffects()
    DestroyTrigger(FIGHT_DATA.element_trigger)
    FIGHT_DATA.element_casting_wind = false
    FIGHT_DATA.element_trigger = nil

    BUFF_AddDebuff_Override({
        name = 'WINDELEMENT_BUFF'
        ,target = HERO
    })

    BOSS_DestroyEffect(FIGHT_DATA.element_orb_wind)
    FIGHT_DATA.element_orb_wind = nil

    Shaman_Totems_CastNext()
end

function Shaman_FireElement_Cast()
    IssueImmediateOrderBJ(BOSSES[1], "howlofterror")
    BOSS_Transmission(BOSS_SHAMAN_ID,'fire_element')
end

function Shaman_FireElement_Start()
    FIGHT_DATA.element_casting_fire = true
    FIGHT_DATA.element_interval_fire = 0
    FIGHT_DATA.element_trigger = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(FIGHT_DATA.element_trigger, 0.02)
    TriggerAddAction(FIGHT_DATA.element_trigger, Shaman_FireElement_Action)
end

function Shaman_FireElement_Action()
    if FIGHT_DATA.element_interval_fire - math.floor(FIGHT_DATA.element_interval_fire/2) * 2 == 0 then
        local x,y = BOSS_GetRandomCoordsInArena(BOSS_SHAMAN_ID)
        local effM = BOSS_CreateEffect('Abilities\\Spells\\Undead\\VampiricAura\\VampiricAura.mdl',x,y)
        BlzSetSpecialEffectScale(effM, 1.5)
        BlzSetSpecialEffectTimeScale(effM, 0.5)
        BOSS_WaitAndDoExclusive(1.0,Shaman_MeteorSpawn,effM,x,y)
    end
    FIGHT_DATA.element_interval_fire = FIGHT_DATA.element_interval_fire + 1
end

function Shaman_MeteorSpawn(effM,x,y)
    local effP = BOSS_CreateEffect('Abilities\\Spells\\Demon\\RainOfFire\\RainOfFireTarget.mdl',x,y)
    BlzSetSpecialEffectScale(effP, 2.0)
    BOSS_WaitAndDoExclusive(0.8,Shaman_MeteorImpact,effM,effP,x,y)
end

function Shaman_MeteorImpact(effM,effP,x,y)
    local effE = BOSS_CreateEffect('Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl',x,y)

    for i,u in pairs(ALL_UNITS) do
        local ux,uy = GetUnitXY(u)
        if BOSS_IsUnitInArena(u,BOSS_SHAMAN_ID) and not(UNIT_IsBoss(u)) and IsUnitAliveBJ(u) then
            if MATH_GetDistance(ux,uy,x,y) <= 170.0 then
                DS_DamageUnit(BOSSES[1], u, 1250.0, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FIRE, ABCODE_FIREELEMENT)
                BUFF_AddDebuff_Stack({
                    name = 'FIREELEMENT_HIT'
                    ,target = u
                    ,caster = BOSSES[1]
                    ,dmg = 135.0
                    ,tickFunc = function()
                        DS_DamageUnit(DEBUFFS[trg_buff_id].caster, DEBUFFS[trg_buff_id].target, DEBUFFS[trg_buff_id].dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FIRE, ABCODE_FIREELEMENT)
                    end
                })
            end
        end
        ux,uy = nil,nil
    end

    BOSS_DestroyEffect(effP)
    BOSS_DestroyEffect(effM)
    BOSS_DestroyEffect(effE)
end

function Shaman_FireElement_End()
    Shaman_RemoveSpellEffects()
    DestroyTrigger(FIGHT_DATA.element_trigger)
    FIGHT_DATA.element_casting_fire = nil
    FIGHT_DATA.element_trigger = nil

    BUFF_AddDebuff_Override({
        name = 'FIREELEMENT_BUFF'
        ,target = HERO
    })

    BOSS_DestroyEffect(FIGHT_DATA.element_orb_fire)
    FIGHT_DATA.element_orb_fire = nil

    Shaman_Totems_CastNext()
end

function Shaman_SummonTotems()
    FIGHT_DATA.Totems = {}
    FIGHT_DATA.Fire = 1
    FIGHT_DATA.Water = 2
    FIGHT_DATA.Wind = 3
    FIGHT_DATA.Lighting = 4
    for i,v in pairs(FIGHT_DATA.Elementals) do
        local x,y = BlzGetLocalSpecialEffectX(v.effect),BlzGetLocalSpecialEffectY(v.effect)
        local eff = BOSS_CreateEffect('war3mapImported\\8xp_tauren_heritage_totem.mdl',x,y)
        BlzSetSpecialEffectScale(eff, 2.2)
        BlzSetSpecialEffectZ(eff, -70.0)
        table.insert(FIGHT_DATA.Totems,eff)
        DestroyEffectBJ(v.effect)
        eff,x,y = nil,nil,nil
    end
    FIGHT_DATA.Elementals = nil
end

function Shaman_Windfury_Cast()
    MS_Freeze(BOSSES[1])
    local x,y = GetRectCenterX(BOSS_DATA[BOSS_SHAMAN_ID].regions.spawn_Hero),GetRectCenterY(BOSS_DATA[BOSS_SHAMAN_ID].regions.spawn_Hero)
    IssuePointOrder(BOSSES[1], 'blizzard', x, y)
    BOSS_Transmission(BOSS_SHAMAN_ID,'windfury')
end

function Shaman_Windfury_Start()
    UNIT_SetDmgImmune(BOSSES[1], true)
    UNIT_MakeUnitFlyable(BOSSES[1])
    Shaman_RemoveSpellEffects()
    BUFF_UnitClearAllDebuffs(BOSSES[1])

    BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_FLY')

    local x,y = GetUnitXY(BOSSES[1])
    Shaman_AddSpellEffect_Polished('war3mapImported\\cycloneBig.mdl', x, y, 6.0)
    Shaman_AddSpellEffect_Polished('war3mapImported\\Autumn Aura.mdx', x, y, 6.0)
    local target_H,interval = GetUnitZ(BOSSES[1]) + 700.0,0

    UNIT_SetImpactDist(BOSSES[1], 300.0)
    FIGHT_DATA.stormDamage = 0.6
    FIGHT_DATA.stormAOE = 0.0

    Shaman_Windfury_Storm_Start()

    local trg = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(trg, 0.01)
    TriggerAddAction(trg, function()
        local cur_H = GetUnitZ(BOSSES[1])
        if cur_H >= target_H then
            DestroyTrigger(trg)
            target_H,interval = nil,nil
        else
            cur_H = cur_H + 1.2
            if interval - math.floor(interval/250) * 250 == 0 then
                Shaman_AddSpellEffect_Polished('war3mapImported\\cycloneBig.mdl', x, y, 6.0)
            end
            SetUnitFlyHeightBJ(BOSSES[1], cur_H, 0.00)
            interval = interval + 1
        end
        FIGHT_DATA.stormDamage = FIGHT_DATA.stormDamage + 0.6
        FIGHT_DATA.stormAOE = FIGHT_DATA.stormAOE + 1.37
        cur_H = nil
    end)
end

function Shaman_Windfury_End()
    SetUnitFlyHeightBJ(BOSSES[1],0,0.00)
    UNIT_Make_MS_Vulnerable(BOSSES[1])
    UNIT_ResetImpactDist(BOSSES[1])
    Shaman_RemoveSpellEffects_Polished()
    DestroyTrigger(FIGHT_DATA.StormTrigger)
    FIGHT_DATA.StormTrigger = nil
    FIGHT_DATA.stormDamage = nil
    FIGHT_DATA.stormAOE = nil
    FIGHT_DATA.windfury = nil
    UNIT_SetDmgImmune(BOSSES[1], false)
    MS_Unfreeze(BOSSES[1])
    if FIGHT_DATA.phase == 2 then
        Shaman_LightingShield_Cast()
    elseif FIGHT_DATA.phase == 3 then
        Shaman_Totems_CastNext()
    end
    if FIGHT_DATA.diff >= BOSS_DIFFICULTY_HEROIC then
        DBM_RegisterTimer({
            time = 15.0
            ,icon = 'war3mapImported\\BTN_ElectricSpark.dds'
            ,name = 'Lighting Spark'
            ,id = 'l_spark'
            ,barTheme = DBM_BAR_clLIGHTBLUE
            ,finishFunc = Shaman_LightingSpark_Summon
        })
    end
end

function Shaman_Windfury_Storm_Start()
    BUFF_UnitClearDebuffAllStacks(HERO,'ELEMENTAL_FURY')
    FIGHT_DATA.StormDuration = 0.0
    FIGHT_DATA.StormTrigger = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(FIGHT_DATA.StormTrigger, 0.02)
    TriggerAddAction(FIGHT_DATA.StormTrigger, Shaman_Windfury_Storm_Action)

    DBM_RegisterTimer({
        time = 60.0
        ,icon = 'war3mapImported\\BTN_Windfury.dds'
        ,name = 'Windfury'
        ,id = 'w_storm'
        ,barTheme = DBM_BAR_clDARKGREEN
    })

    local trg = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(trg, 0.1)
    TriggerAddAction(trg, function()
        if DBM_GetTimeById('w_storm') <= 6 then
            DestroyTrigger(trg)
            trg = nil
            Shaman_Windfury_Storm_End()
        end
    end)
end

function Shaman_Windfury_Storm_Action()
    FIGHT_DATA.StormDuration = FIGHT_DATA.StormDuration + 1
    local x,y = GetUnitX(BOSSES[1]),GetUnitY(BOSSES[1])
    local hx,hy = GetUnitXY(HERO)
    if FIGHT_DATA.StormDuration - math.floor(FIGHT_DATA.StormDuration/50) * 50 == 0 and DBM_GetTimeById('w_storm') > 20 then
        local u_id = FIGHT_DATA.diff <= BOSS_DIFFICULTY_NORMAL and FourCC('n005') or FourCC('n006')
        UNIT_CreateCreep(PLAYER_BOSS, u_id, x, y, MATH_GetAngleXY(x,y,hx,hy))
        u_id = nil
    end
    if FIGHT_DATA.StormDuration == 300 then
        Shaman_Windfury_StartLighting()
    end
    if FIGHT_DATA.windfury_orb then
        local tx,ty = BlzGetLocalSpecialEffectX(FIGHT_DATA.windfury_orb),BlzGetLocalSpecialEffectY(FIGHT_DATA.windfury_orb)
        local hx,hy = GetUnitXY(HERO)
        tx,ty = MATH_MoveXY(tx,ty, 5.0, MATH_GetRadXY(tx,ty,hx,hy))
        BlzSetSpecialEffectPosition(FIGHT_DATA.windfury_orb, tx, ty, 150.0)
        SetUnitFacing(BOSSES[1], MATH_GetAngleXY(x,y,tx,ty))

        x,y = MATH_MoveXY(x,y, 140.0, (GetUnitFacing(BOSSES[1]) - 6.0) * bj_DEGTORAD)
        MoveLightningEx(FIGHT_DATA.windfury_bolt, true, x, y, GetUnitZ(BOSSES[1]) + 300.0, tx, ty, 150.0)

        for i,u in pairs(ALL_UNITS) do
            local ux,uy = GetUnitXY(u)
            if not(UNIT_IsBoss(u)) and IsUnitAliveBJ(u) and BOSS_IsUnitInArena(u,BOSS_SHAMAN_ID) then
                local orb_id = 'orb_hit_' .. GetHandleIdBJ(FIGHT_DATA.windfury_orb)
                local orb_hit_cd = UNIT_GetData(u,orb_id) or 10
                if orb_hit_cd >= 10 then
                    if MATH_GetDistance(ux,uy,tx,ty) <= 220.00 then
                        --Orb Hit
                        DS_DamageUnit(BOSSES[1], u, 300.0, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC, ABCODE_ORBOFLIGHTING)
                        BUFF_RefreshDebuffDurationAllStacks(u,'ELECTRIFIED')
                        BUFF_AddDebuff_Stack({
                            target = u
                            ,name = 'ELECTRIFIED'
                        })
                        UNIT_SetData(u,orb_id,0)
                    else
                        UNIT_SetData(u,orb_id,nil)
                    end
                else
                    UNIT_SetData(u,orb_id,orb_hit_cd + 1)   
                end
                orb_id,orb_hit_cd = nil,nil
            end
            ux,uy = nil,nil
        end
        tx,ty,bx,by = nil,nil,nil,nil
    end

    for i,u in pairs(ALL_UNITS) do
        local ux,uy = GetUnitXY(u)
        if not(UNIT_IsBoss(u)) and IsUnitAliveBJ(u) and BOSS_IsUnitInArena(u,BOSS_SHAMAN_ID)  and IsUnitEnemy(u, PLAYER_BOSS) then
            local storm_hit_cd = UNIT_GetData(u,'stormHit') or 15
            if storm_hit_cd >= 15 then
                if MATH_GetDistance(ux,uy,x,y) <= FIGHT_DATA.stormAOE then
                    DS_DamageUnit(BOSSES[1], u, FIGHT_DATA.stormDamage, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FORCE, ABCODE_WINDFURY)
                    AddSpecialEffectTargetUnitBJ('chest',u,'Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl')
                    UNIT_SetData(u,'stormHit',0)
                else    
                    UNIT_SetData(u,'stormHit',nil)
                end
            else
                UNIT_SetData(u,'stormHit',storm_hit_cd + 1)  
            end
            storm_hit_cd = nil
        end
        ux,uy = nil,nil
    end
    x,y = nil,nil,nil,nil
end

function Shaman_Windfury_StartLighting()
    BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_FLY_SPELL')
    FIGHT_DATA.effect_lighting_hand = Shaman_AddSpellEffectTarget('right hand',BOSSES[1],'Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl',1.8)

    local x,y = GetRectCenterX(BOSS_DATA[BOSS_SHAMAN_ID].regions.spawn_Hero),GetRectCenterY(BOSS_DATA[BOSS_SHAMAN_ID].regions.spawn_Hero)
    FIGHT_DATA.windfury_orb = Shaman_AddSpellEffect('Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl', x, y, 6.0)
    BlzSetSpecialEffectZ(FIGHT_DATA.windfury_orb, 150.0)

    local bx,by = MATH_MoveXY(GetUnitX(BOSSES[1]),GetUnitY(BOSSES[1]), 140.0, (GetUnitFacing(BOSSES[1]) - 6.0) * bj_DEGTORAD)
    FIGHT_DATA.windfury_bolt = BOSS_CreateLighting('PURP', true, bx, by,GetUnitZ(BOSSES[1]) + 300.0, x, y, 100.0)

    bx,by = nil,nil
    x,y = nil,nil
end

function Shaman_Windfury_Storm_End()
    DestroyEffectBJ(FIGHT_DATA.effect_lighting_hand)
    DestroyEffectBJ(FIGHT_DATA.windfury_orb)
    DestroyLightning(FIGHT_DATA.windfury_bolt)
    FIGHT_DATA.effect_lighting_hand = nil
    FIGHT_DATA.windfury_orb = nil
    FIGHT_DATA.windfury_bolt = nil

    BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_FLY')
    SetUnitFacingTimed(BOSSES[1], 270.0, 1.0)

    local target_H = GetUnitZ(BOSSES[1]) - 700.0
    target_H = target_H >= 0 and target_H or 0
    local trg = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(trg, 0.01)
    TriggerAddAction(trg, function()
        local cur_H = GetUnitZ(BOSSES[1])
        if cur_H - 1.2 <= target_H then
            DestroyTrigger(trg)
            target_H,trg = nil,nil
            Shaman_Windfury_End()
        else
            SetUnitFlyHeightBJ(BOSSES[1], cur_H - 1.2, 0.00)
        end
        cur_H = nil
    end)
end

function Shaman_Windfury_MoveOrder(x,y)
    MS_Unfreeze(BOSSES[1])
    UNIT_Make_MS_Immune(BOSSES[1])
    IssuePointOrderById(BOSSES[1], 851986, x, y)
end

function Shaman_IsInCenter()
    return IsUnitInRect(BOSSES[1],BOSS_DATA[BOSS_SHAMAN_ID].regions.arena_Center)
end

function Shaman_Windfury_Trigger()
    FIGHT_DATA.phase = FIGHT_DATA.phase + 1
    FIGHT_DATA.windfury = true
    BOSS_DestroyAllTimers()
    DBM_DestroyTimerById('l_orb')
    DBM_DestroyTimerById('e_fury')
    if FIGHT_DATA.diff >= BOSS_DIFFICULTY_HEROIC then
        DBM_DestroyTimerById('l_spark')
        Shaman_LightingSpark_DestroyOrbs()
    end
    Shaman_ChainLighting_Flush()

    MS_Freeze(BOSSES[1])

    BUFF_UnitClearDebuffAllStacks(BOSSES[1],'ELEMENTAL_EXHAUSTION')

    if FIGHT_DATA.exhausted_trigger then
        Shaman_Exhausted_Effects_End()
    end

    local x,y = GetRectCenterX(BOSS_DATA[BOSS_SHAMAN_ID].regions.arena_Center),GetRectCenterY(BOSS_DATA[BOSS_SHAMAN_ID].regions.arena_Center)
    Shaman_Windfury_MoveOrder(x,y)

    if Shaman_IsInCenter() then
        SetUnitX(BOSSES[1], x)
        SetUnitY(BOSSES[1], y)
        Shaman_Windfury_Cast()
    else
        local trg = CreateBossTrigger()
        TriggerRegisterEnterRectSimple(trg, BOSS_DATA[BOSS_SHAMAN_ID].regions.arena_Center)
        TriggerAddAction(trg, function()
            if GetEnteringUnit() == BOSSES[1] then
                DestroyTrigger(GetTriggeringTrigger())
                SetUnitX(BOSSES[1], x)
                SetUnitY(BOSSES[1], y)
                Shaman_Windfury_Cast()
            end
        end)
    end
end

function Shaman_AddSpellEffect_Polished(modelName, x, y, scale)
    local eff = BOSS_CreateEffect(modelName, x, y)
    BlzSetSpecialEffectScale(eff, 0.01)
    table.insert(FIGHT_DATA.spellEffects,eff)
    scale = scale or 1.0
    GENERIC_Effect_PolishedSpawn_AddToQueue(eff,scale)
    return eff
end

function Shaman_AddSpellEffectTarget_Polished(where,unit,effect,scale)
    local eff = BOSS_CreateEffectAttached(where,unit,effect)
    BlzSetSpecialEffectScale(eff, 0.01)
    table.insert(FIGHT_DATA.spellEffects,eff)
    scale = scale or 1.0
    GENERIC_Effect_PolishedSpawn_AddToQueue(eff,scale)
    return eff
end

function Shaman_AddSpellEffectTarget(where,unit,effect,scale)
    local eff = BOSS_CreateEffectAttached(where,unit,effect)
    BlzSetSpecialEffectScale(eff, scale or BlzGetSpecialEffectScale(eff))
    table.insert(FIGHT_DATA.spellEffects,eff)
    return eff
end

function Shaman_AddSpellEffect(modelName, x, y, scale)
    local eff = BOSS_CreateEffect(modelName, x, y)
    BlzSetSpecialEffectScale(eff, scale or BlzGetSpecialEffectScale(eff))
    table.insert(FIGHT_DATA.spellEffects,eff)
    return eff
end

function Shaman_RemoveSpellEffects()
    for i = #FIGHT_DATA.spellEffects,1,-1 do
        if FIGHT_DATA.eff_pol_RemoverTable then
            for x = #FIGHT_DATA.eff_pol_RemoverTable,1,-1 do
                if FIGHT_DATA.eff_pol_RemoverTable[x] == FIGHT_DATA.spellEffects[i] then
                    table.remove(FIGHT_DATA.eff_pol_RemoverTable,x)
                end
            end
        end
        if FIGHT_DATA.eff_pol_SpawnTable then
            for x = #FIGHT_DATA.eff_pol_SpawnTable,1,-1 do
                if FIGHT_DATA.eff_pol_SpawnTable[x].e == FIGHT_DATA.spellEffects[i] then
                    table.remove(FIGHT_DATA.eff_pol_SpawnTable,x)
                end
            end
        end
        DestroyEffectBJ(FIGHT_DATA.spellEffects[i])
        table.remove(FIGHT_DATA.spellEffects,i)
    end
end

function Shaman_RemoveSpellEffects_Polished()
    for i = #FIGHT_DATA.spellEffects,1,-1 do
        GENERIC_Effect_PolishedRemove_AddToQueue(FIGHT_DATA.spellEffects[i])
        table.remove(FIGHT_DATA.spellEffects,i)
    end
end

function Shaman_HealingWave_Start()
    FIGHT_DATA.healTrig = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(FIGHT_DATA.healTrig, 0.01)
    TriggerAddAction(FIGHT_DATA.healTrig,Shaman_HealingWave_CastCheck)
end

function Shaman_HealingWave_CastCheck()
    if BUFF_GetStacksCount(BOSSES[1],'LIGHTINGSHIELD') <= 0 then
        IssueImmediateOrderBJ(BOSSES[1], 'stop')
        DestroyTrigger(FIGHT_DATA.healTrig)
        FIGHT_DATA.healTrig = nil
        Shaman_OrbOfLighting_Cast()
    end
end

function Shaman_HealingWave_Finish()
    Shaman_RemoveSpellEffects()
    BUFF_UnitClearDebuffAllStacks(BOSSES[1],'LIGHTINGSHIELD')
    AddSpecialEffectTargetUnitBJ('chest', BOSSES[1], 'Abilities\\Spells\\Items\\RitualDagger\\RitualDaggerTarget.mdl')
    HS_HealUnit(BOSSES[1],BOSSES[1],BlzGetUnitMaxHP(BOSSES[1]) * 0.15,ABCODE_HEALINGWAVE)
    DestroyTrigger(FIGHT_DATA.healTrig)
    FIGHT_DATA.healTrig = nil
    MS_Unfreeze(BOSSES[1])
    Shaman_OrbOfLighting_Cast()
end

function Shaman_LightingShield_Finish()
    Shaman_RemoveSpellEffects()
    local abs = 10000.0 + (FIGHT_DATA.diff == BOSS_DIFFICULTY_HEROIC and 2000.0 or 0.0)
    abs = abs + (abs * Shaman_DestroyAllOrbs())
    local seed = BUFF_GenerateSeed()
    DS_SetAbsorb(BOSSES[1],BOSSES[1],ABCODE_LIGHTINGSHIELD,seed,abs)
    BUFF_AddDebuff_Stack({
        name = 'LIGHTINGSHIELD'
        ,target = BOSSES[1]
        ,caster = BOSSES[1]
        ,seed = seed
    })
    seed = nil
    MS_Unfreeze(BOSSES[1])
    if FIGHT_DATA.phase == 1 then
        Shaman_HealingWave_Cast()
    elseif FIGHT_DATA.phase == 2 then
        if FIGHT_DATA.mid_phaseTrg_B then
            EnableTrigger(FIGHT_DATA.mid_phaseTrg_B)
        end
        Shaman_SummonTotems()
        Shaman_ActivateTotems_Cast()
    end
end

function Shaman_SpawnElementals()
    local x,y = GetRectCenterX(BOSS_DATA[BOSS_SHAMAN_ID].regions.arena_Center),GetRectCenterY(BOSS_DATA[BOSS_SHAMAN_ID].regions.arena_Center)
    local hitbox_area = 100.0
    for i=0,3 do
        local ex,ey = MATH_MoveXY(x,y,1000.0, (45.0 + i * 90.0) * bj_DEGTORAD)
        local eff = BOSS_CreateEffect('Abilities\\Spells\\Other\\Drain\\ManaDrainTarget.mdl',ex,ey)
        local tbl = {
            effect = eff
            ,binded_orb = nil
            ,hitbox_pol = Polygon(
                Point(MATH_MoveXY(ex,ey,hitbox_area, 45.0 * bj_DEGTORAD))
                ,Point(MATH_MoveXY(ex,ey,hitbox_area, 135.0 * bj_DEGTORAD))
                ,Point(MATH_MoveXY(ex,ey,hitbox_area, 225.0 * bj_DEGTORAD))
                ,Point(MATH_MoveXY(ex,ey,hitbox_area, 315.0 * bj_DEGTORAD))
            )
        }
        BlzSetSpecialEffectZ(eff, 110.0)
        BlzSetSpecialEffectScale(eff, 1.8)
        table.insert(FIGHT_DATA.Elementals,tbl)
        eff,tbl,ex,ey = nil,nil,nil,nil
    end
    hitbox_area,x,y = nil,nil,nil
end

function Shaman_CastRandomAbility()
    local i = GetRandomInt(1, #FIGHT_DATA.SpellFuncs)
    FIGHT_DATA.SpellFuncs[i]()
    table.remove(FIGHT_DATA.SpellFuncs,i)
end

function Shaman_ChainLighting_Start()
    local caster,target = GetSpellAbilityUnit(),GetSpellTargetUnit()
    local c_id = GetHandleIdBJ(caster)
    SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
    SPELLS_DATA[c_id].target = target
    FIGHT_DATA.facing_trig = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(FIGHT_DATA.facing_trig, 0.02)
    TriggerAddAction(FIGHT_DATA.facing_trig,function()
        local cx,cy,tx,ty = GetUnitX(caster),GetUnitY(caster),GetUnitX(target),GetUnitY(target)
        SetUnitFacing(caster, MATH_GetAngleXY(cx,cy,tx,ty))
    end)
end

function Shaman_ChainLighting_Stop()
    local caster = GetSpellAbilityUnit()
    local c_id = GetHandleIdBJ(caster)
    SPELLS_DATA[c_id].target = nil
    DestroyTrigger(FIGHT_DATA.facing_trig)
    FIGHT_DATA.facing_trig = nil
end

function Shaman_ChainLighting_Finish()
    local caster = GetSpellAbilityUnit()
    local target = SPELLS_DATA[GetHandleIdBJ(caster)].target
    local c_id = GetHandleIdBJ(caster)
    SPELLS_DATA[c_id].target = nil
    MS_Freeze(caster)

    BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_SPELL_THROW',1.5)
    BOSS_WaitAndDo(2.5,Shaman_ChainLighting_EndCast,caster)
    BOSS_WaitAndDo(0.5,Shaman_ChainLighting_Hit,caster,target)
end

function Shaman_ChainLighting_Flush()
    Shaman_RemoveSpellEffects()
    if FIGHT_DATA.facing_trig then
        DestroyTrigger(FIGHT_DATA.facing_trig)
        FIGHT_DATA.facing_trig = nil
    end
    if FIGHT_DATA.chainTrigger then
        DestroyTrigger(FIGHT_DATA.chainTrigger)
        DestroyEffectBJ(FIGHT_DATA.chainEffect)
        DestroyLightning(FIGHT_DATA.chainBolt)
        FIGHT_DATA.chainTrigger = nil
        FIGHT_DATA.chainBolt = nil
        FIGHT_DATA.chainEffect = nil
    end
end

function Shaman_ChainLighting_Hit(caster,target)
    FIGHT_DATA.chainTrigger = CreateBossTrigger()
    local bx,by = GetUnitXY(caster)
    bx,by = MATH_MoveXY(bx,by, 140.0, (GetUnitFacing(caster) + 6.0) * bj_DEGTORAD)
    FIGHT_DATA.chainBolt = BOSS_CreateLighting('PURP', false, bx, by, 0, bx, by, 0)
    FIGHT_DATA.chainEffect = BOSS_CreateEffect('Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl', bx, by)
    local duration,cur_dur = 1.3,0.0
    local c_height = 170.0
    local tx,ty = GetUnitXY(target)
    local orb_id,t_height
    local e_tick,e_per = 5,5

    BlzSetSpecialEffectScale(FIGHT_DATA.chainEffect, 2.5)
    TriggerRegisterTimerEventPeriodic(FIGHT_DATA.chainTrigger, 0.02)
    TriggerAddAction(FIGHT_DATA.chainTrigger,function()
        if cur_dur <= duration then
            if not(orb_id) then
                for i,e in pairs(FIGHT_DATA.Elementals) do
                    if e.binded_orb and IsLineCrossingPolygon(Line(bx,by,tx,ty),e.hitbox_pol) then
                        target = e.effect
                        tx,ty = EFFECT_GetXY(target)
                        t_height = 100.0
                        orb_id = i
                        DestroyTrigger(FIGHT_DATA.facing_trig)
                        FIGHT_DATA.facing_trig = nil
                        break
                    end
                end
            end
            if getJASSDataType(target) == JASS_DATATYPE_UNIT then
                t_height = UNIT_GetChestHeight(target)
                tx,ty = GetUnitXY(target)
                if e_per >= e_tick then
                    DS_DamageUnit(BOSSES[1], target, 150.0, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC, ABCODE_CHAINLIGHTING)
                    BUFF_RefreshDebuffDurationAllStacks(target,'ELECTRIFIED')
                    BUFF_AddDebuff_Stack({
                        target = target
                        ,name = 'ELECTRIFIED'
                    })
                    e_per = 0
                else
                    e_per = e_per + 1
                end
            else
                tx,ty = EFFECT_GetXY(target)
            end
            BlzSetSpecialEffectPosition(FIGHT_DATA.chainEffect, tx, ty, t_height)
            MoveLightningEx(FIGHT_DATA.chainBolt, true, bx, by, c_height, tx, ty, t_height)
            cur_dur = cur_dur + 0.02
        else
            if orb_id then 
                Shaman_UnbindElement(orb_id)
            end
            Shaman_RemoveSpellEffects()
            BOSS_DestroyEffect(FIGHT_DATA.chainEffect)
            BOSS_DestroyLighting(FIGHT_DATA.chainBolt)
            DestroyTrigger(FIGHT_DATA.chainTrigger)
            DestroyTrigger(FIGHT_DATA.facing_trig)
            FIGHT_DATA.facing_trig = nil
        end
    end)
end

function Shaman_ChainLighting_EndCast(caster)
    MS_Unfreeze(caster)
    FIGHT_DATA.state = FIGHT_DATA.state - 1
    Shaman_FightStateCastCheck()
end

function Shaman_UnbindElement(id)
    if FIGHT_DATA.Elementals[id] then
        BOSS_DestroyMissle(FIGHT_DATA.Elementals[id].binded_orb)
        FIGHT_DATA.Elementals[id].binded_orb = nil
    end
end

function Shaman_UnbindAllElements()
    for i,e in pairs(FIGHT_DATA.Elementals) do
        if e.binded_orb then
            Shaman_UnbindElement(i)
        end
    end
end

function Shaman_FightStateCastCheck()
    if FIGHT_DATA.state == 0 then
        Shaman_LightingShield_Cast()
    else
        Shaman_ChainLighting_Cast()
    end
end

function Shaman_DestroyAllOrbs()
    local c = 0
    for i = #BOSS_MISSLES,1,-1 do
        if BOSS_MISSLES[i].id == 'orb_light' then
            DestroyEffectBJ(BOSS_MISSLES[i].missle)
            DestroyLightning(BOSS_MISSLES[i].bolt)
            c = c + 1
            BOSS_MISSLES[i] = nil
        end
    end
    Shaman_UnbindAllElements()
    return c
end

function Shaman_OrbOfLighting_Finish()
    Shaman_RemoveSpellEffects()
    MS_Unfreeze(BOSSES[1])
    local bx,by = GetUnitXY(BOSSES[1])
    local x,y = BOSS_GetRandomCoordsInArena(BOSS_SHAMAN_ID)
    local missle,height = MISSLE_CreateMissleXY('sh_LightOrb',x,y)
    EFFECT_AddSpecialEffect_LifeSpan('Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl', x, y, 1.0, 2.0)
    local height_c = UNIT_GetChestHeight(BOSSES[1])
    local tbl = {
        missleSpeed = 6.0
        ,missle = missle
        ,height = height
        ,height_c = height_c
        ,id = 'orb_light'
        ,binded = false
    }
    table.insert(BOSS_MISSLES,tbl)
    missle,height,tbl,x,y,bx,by = nil,nil,nil,nil,nil,nil,nil
    Shaman_Orb_Moving()

    FIGHT_DATA.state = FIGHT_DATA.state + 1
    if FIGHT_DATA.state < 4 then
        DBM_RegisterTimer({
            time = 7.0
            ,icon = 'war3mapImported\\BTN_OrbOfLighting.dds'
            ,name = 'Lighting Orb'
            ,id = 'l_orb'
            ,barTheme = DBM_BAR_clBLUE
            ,finishFunc = Shaman_OrbOfLighting_Cast
        })
    else
        Shaman_ChainLighting_Cast()
    end
end

function Shaman_Orb_Moving()
    if not(FIGHT_DATA.orbsMoveTrig) then
        FIGHT_DATA.orbsMoveTrig = CreateBossTrigger()
        TriggerRegisterTimerEventPeriodic(FIGHT_DATA.orbsMoveTrig, 0.02)
        TriggerAddAction(FIGHT_DATA.orbsMoveTrig,function()
            local count = 0
            for i,v in pairs(BOSS_MISSLES) do
                if v.id == 'orb_light' then
                    local mx,my = MISSLE_GetXY(v.missle)
                    local bx,by = GetUnitXY(BOSSES[1])
                    for j,u in pairs(ALL_UNITS) do
                        local ux,uy = GetUnitXY(u)
                        if not(UNIT_IsBoss(u)) and IsUnitAliveBJ(u) and BOSS_IsUnitInArena(u,BOSS_SHAMAN_ID) then
                            local orb_id = 'orb_hit_' .. GetHandleIdBJ(v.missle)
                            local orb_hit_cd = UNIT_GetData(u,orb_id) or 25
                            if orb_hit_cd >= 25 then
                                if MATH_GetDistance(ux,uy,mx,my) <= 120.00 then
                                    --Orb Hit
                                    DS_DamageUnit(BOSSES[1], u, 100.0, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC, ABCODE_ORBOFLIGHTING)
                                    BUFF_RefreshDebuffDurationAllStacks(u,'ELECTRIFIED')
                                    BUFF_AddDebuff_Stack({
                                        target = u
                                        ,name = 'ELECTRIFIED'
                                    })
                                    UNIT_SetData(u,orb_id,0)
                                else
                                    UNIT_SetData(u,orb_id,nil)
                                end
                            else
                                UNIT_SetData(u,orb_id,orb_hit_cd + 1)   
                            end
                            orb_id,orb_hit_cd = nil,nil
                        end
                        ux,uy = nil,nil
                    end
                    if not(v.binded) then 
                        local bind = false
                        for x,ele in pairs(FIGHT_DATA.Elementals) do
                            if not(ele.binded_orb) then
                                local ex,ey = EFFECT_GetXY(ele.effect)
                                if MATH_GetDistance(ex,ey,mx,my) <= 75.00 then
                                    ele.binded_orb = v.missle
                                    bind = true
                                    mx,my = ex,ey
                                    break
                                end
                                ex,ey = nil,nil
                            end
                        end
                        if bind then
                            v.binded = true
                        else
                            local hx,hy = GetUnitXY(HERO)
                            mx,my = MATH_MoveXY(mx,my,v.missleSpeed, MATH_GetRadXY(mx,my,hx,hy))
                            hx,hy = nil,nil
                        end
                        BlzSetSpecialEffectPosition(v.missle, mx, my, v.height)
                        bind = nil
                    end
                    mx,my = nil,nil
                    count = count + 1
                end
            end
            if count == 0 then
                DestroyTrigger(FIGHT_DATA.orbsMoveTrig)
                FIGHT_DATA.orbsMoveTrig = nil
            end
        end)
    end
end

function Shaman_Flee()
    UNIT_SetDmgImmune(BOSSES[1], true)
    BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_TALK')
    PauseUnitBJ(true, BOSSES[1])

    BOSS_Transmission(BOSS_SHAMAN_ID,'flee')

    BUFF_UnitClearAll(HERO)
    SetUnitLifePercentBJ(HERO, 100)

    local x,y = GetUnitXY(BOSSES[1])
    PanCameraToTimedForPlayer(PLAYER, x, y, 4.5)
    x,y = nil,nil

    BOSS_RemoveAllUnits()
    WaitAndDo(5.0,Shaman_Flushing)

    ARENA_ACTIVATED = false
end

function Shaman_Victory()
    BOSS_Transmission(BOSS_SHAMAN_ID,'victory')
    UNIT_SetDmgImmune(HERO, true)
    BOSS_RemoveAllUnits()
    WaitAndDo(7.0,Shaman_Flushing)
    ARENA_ACTIVATED = false
end

function Shaman_Defeat()
    BOSS_Transmission(BOSS_SHAMAN_ID,'defeat')
    UNIT_SetDmgImmune(BOSSES[1], true)
    BOSS_PlayAnimation(BOSSES[1],BOSS_SHAMAN_ID,'A_TALK_2')
    PauseUnitBJ(true, BOSSES[1])
    BOSS_RemoveAllUnits()
    WaitAndDo(6.0,Shaman_Flushing)
    ARENA_ACTIVATED = false
end

function Shaman_Flushing()
    UNIT_Boss_Clear()
    MAIN_ClearFogModifiers()
    BOSS_ShowJournalButton()
    UI_ShowHeroPortrait()
    MAIN_MoveHero()
    WIDGET_HideAll()
end