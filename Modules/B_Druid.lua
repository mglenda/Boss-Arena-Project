----------------------------------------------------
----------------------Druid-------------------------
----------------------------------------------------

function Druid_Init(diff)
    local b_x,b_y = GetRectCenterX(BOSS_DATA[BOSS_DRUID_ID].regions.spawn_Boss),GetRectCenterY(BOSS_DATA[BOSS_DRUID_ID].regions.spawn_Boss)
    local o_x,o_y = GetRectCenterX(BOSS_DATA[BOSS_DRUID_ID].regions.arena_Center),GetRectCenterY(BOSS_DATA[BOSS_DRUID_ID].regions.arena_Center)
    local h_x,h_y = GetRectCenterX(BOSS_DATA[BOSS_DRUID_ID].regions.spawn_Hero),GetRectCenterY(BOSS_DATA[BOSS_DRUID_ID].regions.spawn_Hero)
    UNIT_Boss_Register(UNIT_Create(PLAYER_PASSIVE, BOSS_DATA[BOSS_DRUID_ID].boss_id[1], b_x, b_y, 270.00))
    HERO_Move(h_x,h_y,o_x,o_y)
    PanCameraToTimedForPlayer(PLAYER,o_x,o_y,0)
    TT_MakeUnit_Target(BOSSES[1])

    MAIN_CreateArenaFogModifiers(BOSS_DRUID_ID)
    IssuePointOrder(BOSSES[1], "move", o_x,o_y)

    BOSS_Transmission(BOSS_DRUID_ID,'init')

    b_x,b_y,o_x,o_y,h_x,h_y = nil,nil,nil,nil,nil,nil

    FIGHT_DATA.phase = 1
    FIGHT_DATA.diff = diff
    FIGHT_DATA.spiritLimit = 30

    local trg = CreateBossTrigger()
    TriggerRegisterEnterRectSimple(trg, BOSS_DATA[BOSS_DRUID_ID].regions.arena_Center)
    TriggerAddAction(trg, function()
        if GetEnteringUnit() == BOSSES[1] then
            MS_Freeze(BOSSES[1])
            BOSS_RunCounter(5,Druid_Start)
            DestroyTrigger(GetTriggeringTrigger())
        end
    end)

    trg = CreateBossTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trg, Condition(Druid_IsAbilityStarfall))
    TriggerAddAction(trg, Druid_Starfall)

    trg = CreateBossTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trg, Condition(Druid_IsAbilityStarfall))
    TriggerAddAction(trg, Druid_Starfall_Finish)

    trg = CreateBossTrigger()
    TriggerRegisterUnitEvent(trg, BOSSES[1], EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(trg, HERO, EVENT_UNIT_DEATH)
    TriggerAddAction(trg, function()
        if GetDyingUnit() == HERO then
            BOSS_Defeat(BOSS_DRUID_ID)
        else
            BOSS_Victory(BOSS_DRUID_ID)
        end
        DestroyTrigger(GetTriggeringTrigger())
    end)

    trg = CreateBossTrigger()
    for i,r in pairs(BOSS_DATA[BOSS_DRUID_ID].regions.lake) do
        TriggerRegisterEnterRectSimple(trg,r)
    end
    TriggerAddAction(trg, Druid_LakeEnter)

    BOSS_CreateFleeTrigger(BOSS_DRUID_ID)

    if diff == BOSS_DIFFICULTY_HEROIC then
        local b_id = GetHandleIdBJ(BOSSES[1])
        HP_CONSTANTS[b_id] = {
            {constant = 150000}
        }
        FIGHT_DATA.spiritLimit = 25
        UNIT_RecalculateStats(BOSSES[1])
        b_id = nil
    end

    trg = nil
end

function Druid_IsAbilityStarfall()
    return GetSpellAbilityId() == ABCODE_STARFALL
end

function Druid_LakeEnter()
    local u = GetEnteringUnit()
    local debuff_type = u == BOSSES[1] and 'FORESTSPIRIT_BUFF' or 'FORESTSPIRIT_DEBUFF'
    if BUFF_GetStacksCount(u,debuff_type) > 0 then
        BUFF_UnitClearDebuffAllStacks(u,debuff_type)
        AddSpecialEffectTargetUnitBJ('overhead', u, 'Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl')
    end
end

function Druid_Start()
    SetUnitOwner(BOSSES[1], PLAYER_BOSS, true)
    MS_Unfreeze(BOSSES[1])
    DBM_RegisterTimer({
        time = 330.0
        ,icon = 'war3mapImported\\BTN_Roots.dds'
        ,name = 'Entangling Roots'
        ,id = 'roots'
        ,barTheme = DBM_BAR_clRED
        ,finishFunc = Druid_Enrage
    })
    DBM_RegisterTimer({
        time = 15.0
        ,icon = ABILITIES_DATA[ABCODE_STARFALL].ICON
        ,name = ABILITIES_DATA[ABCODE_STARFALL].Name
        ,id = 'starfall'
        ,barTheme = DBM_BAR_clPINK
        ,finishFunc = Druid_Starfall_Cast
    })
    DBM_RegisterTimer({
        time = 10.0
        ,icon = 'war3mapImported\\BTN_SpiritsOfTheForest.dds'
        ,name = 'Spirits Of The Forest'
        ,id = 'spirits'
        ,barTheme = DBM_BAR_clBLUE
        ,finishFunc = Druid_ForestSpirits_Start
    })
end

function Druid_Enrage()
    BOSS_Transmission(BOSS_DRUID_ID,'enroot')
    for i=1,50 do
        local x,y = GetRandomCoordsInRect(BOSS_DATA[BOSS_DRUID_ID].regions.enrage_rect)
        EFFECT_AddSpecialEffect_LifeSpan('Abilities\\Spells\\NightElf\\EntanglingRoots\\EntanglingRootsTarget.mdl', x, y, 10.0)
        x,y = nil,nil
    end
    BUFF_AddDebuff_Stack({
        name = 'ROOT'
        ,target = HERO
    })
end

function Druid_Starfall_Cast()
    BOSS_Transmission(BOSS_DRUID_ID,'starfall')
    IssueImmediateOrderBJ(BOSSES[1], "unroot")
end

function Druid_Starfall()
    FIGHT_DATA.starSpawnTrig = CreateBossTrigger()
    FIGHT_DATA.starEffect = oldAddEffect('origin', BOSSES[1], 'Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl')
    TriggerRegisterTimerEventPeriodic(FIGHT_DATA.starSpawnTrig, 0.75)
    TriggerAddAction(FIGHT_DATA.starSpawnTrig,Druid_Starfall_Spawn)
end

function Druid_Starfall_Spawn()
    local x,y = GetUnitXY(HERO)
    local eff = BOSS_CreateEffect('Abilities\\Spells\\NightElf\\TrueshotAura\\TrueshotAura.mdl', x, y)
    BlzSetSpecialEffectZ(eff, 10.0)
    BlzSetSpecialEffectScale(eff, 1.2)
    BOSS_WaitAndDo(1.0,Druid_Starfall_Land,eff,x,y)
end

function Druid_Starfall_Land(eff,x,y)
    BOSS_DestroyEffect(eff)
    Druid_Starfall_Hit(x,y)
end

function Druid_Starfall_Hit(x,y)
    AddSpecialEffect('Abilities\\Spells\\NightElf\\Starfall\\StarfallTarget.mdl', x, y)
    BOSS_WaitAndDo(1.0,Druid_Starfall_Impact,x,y)
end

function Druid_Starfall_Impact(x,y)
    AddSpecialEffect('Abilities\\Spells\\Items\\TomeOfRetraining\\TomeOfRetrainingCaster.mdl', x, y)
    local tx,ty = GetUnitXY(HERO)
    if MATH_GetDistance(x,y,tx,ty) <= ABILITIES_DATA[ABCODE_STARFALL].AOE then
        DS_DamageUnit(BOSSES[1], HERO, 150.0, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_UNIVERSAL, ABCODE_STARFALL)
        BUFF_AddDebuff_Stack({
            name = 'STARFALL_HIT'
            ,target = HERO
        })
        BUFF_RefreshDebuffDurationAllStacks(HERO,'STARFALL_HIT')
    end
end

function Druid_Starfall_Finish()
    DestroyEffectBJ(FIGHT_DATA.starEffect)
    DestroyTrigger(FIGHT_DATA.starSpawnTrig)
    if GetTriggerEventId() == EVENT_PLAYER_UNIT_SPELL_FINISH then
        DBM_RegisterTimer({
            time = 20.0
            ,icon = ABILITIES_DATA[ABCODE_STARFALL].ICON
            ,name = ABILITIES_DATA[ABCODE_STARFALL].Name
            ,id = 'starfall'
            ,barTheme = DBM_BAR_clPINK
            ,finishFunc = Druid_Starfall_Cast
        })
    end
end

function Druid_ForestSpirits_Start()
    FIGHT_DATA.spiritsSpawnTrig = CreateBossTrigger()
    FIGHT_DATA.spiritCount = 20
    TriggerRegisterTimerEventPeriodic(FIGHT_DATA.spiritsSpawnTrig, 0.5)
    TriggerAddAction(FIGHT_DATA.spiritsSpawnTrig, Druid_ForestSpirits_Spawn)
    DBM_RegisterTimer({
        time = 10.5
        ,icon = 'war3mapImported\\BTN_SpiritsOfTheForest.dds'
        ,name = 'Spirits Incoming'
        ,id = 'spiritsComing'
        ,barTheme = DBM_BAR_clGREEN
    })
    BOSS_Transmission(BOSS_DRUID_ID,'spirits')
end

function Druid_ForestSpirits_Spawn()
    if FIGHT_DATA.spiritCount > 0 then
        local x,y = GetRandomCoordsInRect(BOSS_DATA[BOSS_DRUID_ID].regions.spawn_Spirits[GetRandomInt(1, 3)])
        local missle,height = MISSLE_CreateMissleXY('du_Spirit',x,y)
        local tbl = {
            missleSpeed = 6.0
            ,missle = missle
            ,height = height
        }
        table.insert(BOSS_MISSLES,tbl)
        x,y = GetRandomCoordsInRect(BOSS_DATA[BOSS_DRUID_ID].regions.spawn_Spirits[GetRandomInt(1, 3)])
        if FIGHT_DATA.diff >= BOSS_DIFFICULTY_HEROIC and (FIGHT_DATA.spiritCount - math.floor(FIGHT_DATA.spiritCount/10)*10) == 0 then
            missle = UNIT_CreateCreep(PLAYER_BOSS, FourCC('e000'), x, y, 270)
            SetUnitPathing(missle, false)
        end
        FIGHT_DATA.spiritCount = FIGHT_DATA.spiritCount - 1
        missle,height,tbl,x,y = nil,nil,nil,nil,nil
        Druid_ForestSpirits_Moving()
    else
        Druid_ForestSpirits_End()
    end
end

function Druid_AddSpiritBuff(unit)
    if not(BOSS_IsUnitInRectList(unit,BOSS_DATA[BOSS_DRUID_ID].regions.lake)) then
        if unit == BOSSES[1] then
            if BUFF_GetStacksCount(unit,'FORESTSPIRIT_BUFF') == FIGHT_DATA.spiritLimit - 1 then
                AddSpecialEffectTargetUnitBJ('overhead', BOSSES[1], 'Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl')
                Druid_DestroySpirits()
                MS_Freeze(BOSSES[1])
                SetUnitAnimation(BOSSES[1], 'morph')
                BOSS_Transmission(BOSS_DRUID_ID,'bearform')
                BOSS_WaitAndDo(1.46,Druid_Bearform)
            end
            BUFF_AddDebuff_Stack({
                name = 'FORESTSPIRIT_BUFF'
                ,armor_constant = FIGHT_DATA.diff == BOSS_DIFFICULTY_HEROIC and 2 or 1
                ,target = unit
            })
        else
            BUFF_AddDebuff_Stack({
                name = 'FORESTSPIRIT_DEBUFF'
                ,target = unit
            })
        end
    end
    unit = nil
end

function Druid_Bearform()
    if IsUnitAliveBJ(BOSSES[1]) then
        BUFF_UnitClearDebuffAllStacks(BOSSES[1],'FORESTSPIRIT_BUFF')
        BUFF_AddDebuff_Stack({
            name = 'BEARFORM'
            ,target = BOSSES[1]
            ,armor_constant = FIGHT_DATA.diff == BOSS_DIFFICULTY_HEROIC and 40 or 30
        })
        AddUnitAnimationProperties(BOSSES[1], 'alternate', true)
        MS_Unfreeze(BOSSES[1])
    end
end

function Druid_DestroySpirits()
    for i = #BOSS_MISSLES,1,-1 do
        local x,y = MISSLE_GetXY(BOSS_MISSLES[i].missle)
        AddSpecialEffect('Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl', x, y)
        MISSLE_Impact(BOSS_MISSLES[i].missle)
        table.remove(BOSS_MISSLES,i)
        x,y = nil,nil
    end
    for i = #BOSS_CREEPS,1,-1 do
        local x,y = GetUnitXY(BOSS_CREEPS[i])
        AddSpecialEffect('Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl', x, y)
        KillUnit(BOSS_CREEPS[i])
        table.remove(BOSS_CREEPS,i)
        x,y = nil,nil
    end
    DBM_DestroyTimerById('spirits')
    DBM_DestroyTimerById('spiritsComing')
    DBM_DestroyTimerById('starfall')
    DestroyTrigger(FIGHT_DATA.spiritsSpawnTrig)
    FIGHT_DATA.spiritsSpawnTrig = nil
    FIGHT_DATA.phase = 2
end

function Druid_ForestSpirits_Moving()
    if not(FIGHT_DATA.spiritsMoveTrig) then
        FIGHT_DATA.spiritsMoveTrig = CreateBossTrigger()
        TriggerRegisterTimerEventPeriodic(FIGHT_DATA.spiritsMoveTrig, 0.02)
        TriggerAddAction(FIGHT_DATA.spiritsMoveTrig,function()
            if tableLength(BOSS_MISSLES) > 0 or tableLength(BOSS_CREEPS) > 0 then
                for i,v in pairs(BOSS_MISSLES) do
                    local grp = {}
                    local mx,my = MISSLE_GetXY(v.missle)
                    local bx,by = GetUnitXY(BOSSES[1])
                    for j,u in pairs(ALL_UNITS) do
                        if not(UNIT_IsCreep(u)) then
                            local ux,uy = GetUnitXY(u)
                            if MATH_GetDistance(ux,uy,mx,my) <= 90.00 and IsUnitAliveBJ(u) then
                                table.insert(grp,u)
                                break
                            end
                            ux,uy = nil,nil
                        end
                    end
                    if #grp > 0 then
                        MISSLE_Impact(v.missle)
                        AddSpecialEffectTargetUnitBJ('origin', grp[1], 'Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl')
                        Druid_AddSpiritBuff(grp[1])
                        table.remove(BOSS_MISSLES,i)
                    else
                        local x,y = MATH_MoveXY(mx,my,v.missleSpeed, MATH_GetRadXY(mx,my,bx,by))
                        BlzSetSpecialEffectPosition(v.missle, x, y, v.height)
                        x,y = nil,nil
                    end
                    grp,mx,my,bx,by = nil,nil,nil,nil,nil
                end
                for i,spirit in pairs(BOSS_CREEPS) do
                    if IsUnitAliveBJ(spirit) then
                        local grp = {}
                        local mx,my = GetUnitXY(spirit)
                        local bx,by = GetUnitXY(BOSSES[1])
                        for j,u in pairs(ALL_UNITS) do
                            if not(UNIT_IsCreep(u)) then
                                local ux,uy = GetUnitXY(u)
                                if MATH_GetDistance(ux,uy,mx,my) <= 90.00 and IsUnitAliveBJ(u) then
                                    table.insert(grp,u)
                                    break
                                end
                                ux,uy = nil,nil
                            end
                        end
                        if #grp > 0 then
                            KillUnit(spirit)
                            RemoveFromArray(spirit,BOSS_CREEPS)
                            if grp[1] ~= BOSSES[1] then
                                DS_DamageUnit(BOSSES[1], grp[1], 1500.0, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC, ABCODE_STARFALL)
                            else
                                local seed = BUFF_GenerateSeed()
                                DS_SetAbsorb(BOSSES[1],BOSSES[1],ABCODE_STARFALL,seed,150000.0)
                                BUFF_AddDebuff_Stack({
                                    name = 'DRUID_SHIELD'
                                    ,target = BOSSES[1]
                                    ,caster = BOSSES[1]
                                    ,seed = seed
                                })
                                seed = nil
                            end
                            AddSpecialEffectTargetUnitBJ('origin', grp[1], 'Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl')
                        else
                            local x,y = MATH_MoveXY(mx,my,5.0, MATH_GetRadXY(mx,my,bx,by))
                            SetUnitPosition(spirit, x, y)
                            x,y = nil,nil
                        end
                        grp,mx,my,bx,by = nil,nil,nil,nil,nil
                    end
                end
            else
                DestroyTrigger(FIGHT_DATA.spiritsMoveTrig)
                FIGHT_DATA.spiritsMoveTrig = nil
            end
        end)
    end
end

function Druid_ForestSpirits_End()
    DestroyTrigger(FIGHT_DATA.spiritsSpawnTrig)
    FIGHT_DATA.spiritsSpawnTrig = nil
    if FIGHT_DATA.phase == 1 then
        DBM_RegisterTimer({
            time = 30.0
            ,icon = 'war3mapImported\\BTN_SpiritsOfTheForest.dds'
            ,name = 'Spirits Of The Forest'
            ,id = 'spirits'
            ,barTheme = DBM_BAR_clBLUE
            ,finishFunc = Druid_ForestSpirits_Start
        })
    end
end

function Druid_Flee()
    DestroyEffectBJ(FIGHT_DATA.starEffect)
    UNIT_SetDmgImmune(BOSSES[1], true)
    PauseUnitBJ(true, BOSSES[1])

    BOSS_Transmission(BOSS_DRUID_ID,'flee')

    BUFF_UnitClearAll(HERO)
    SetUnitLifePercentBJ(HERO, 100)

    local x,y = GetUnitXY(BOSSES[1])
    PanCameraToTimedForPlayer(PLAYER, x, y, 4.5)
    x,y = nil,nil

    BOSS_RemoveAllUnits()
    WaitAndDo(5.0,Druid_Flushing)

    ARENA_ACTIVATED = false
end

function Druid_Victory()
    DestroyEffectBJ(FIGHT_DATA.starEffect)
    BOSS_Transmission(BOSS_DRUID_ID,'victory')
    UNIT_SetDmgImmune(HERO, true)
    BOSS_RemoveAllUnits()
    WaitAndDo(7.0,Druid_Flushing)
    ARENA_ACTIVATED = false
end

function Druid_Defeat()
    DestroyEffectBJ(FIGHT_DATA.starEffect)
    BOSS_Transmission(BOSS_DRUID_ID,'defeat')
    UNIT_SetDmgImmune(BOSSES[1], true)
    PauseUnitBJ(true, BOSSES[1])
    BOSS_RemoveAllUnits()
    WaitAndDo(8.0,Druid_Flushing)
    ARENA_ACTIVATED = false
end

function Druid_Flushing()
    UNIT_Boss_Clear()
    MAIN_ClearFogModifiers()
    BOSS_ShowJournalButton()
    UI_ShowHeroPortrait()
    MAIN_MoveHero()
    WIDGET_HideAll()
end