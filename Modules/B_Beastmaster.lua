----------------------------------------------------
-------------------Beastmaster----------------------
----------------------------------------------------

function Beastmaster_Init(diff)
    local b_x,b_y = GetRectCenterX(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.spawn_Boss),GetRectCenterY(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.spawn_Boss)
    local o_x,o_y = GetRectCenterX(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.arena_Center),GetRectCenterY(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.arena_Center)
    local h_x,h_y = GetRectCenterX(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.spawn_Hero),GetRectCenterY(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.spawn_Hero)
    UNIT_Boss_Register(UNIT_Create(PLAYER_PASSIVE, BOSS_DATA[BOSS_BEASTMASTER_ID].boss_id[1], b_x, b_y, 270.00))
    HERO_Move(h_x,h_y,o_x,o_y)
    PanCameraToTimedForPlayer(PLAYER,o_x,o_y,0)
    MAIN_CreateFogModifier(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.arena[1])
    BOSS_Transmission(BOSS_BEASTMASTER_ID,'init')
    IssuePointOrder(BOSSES[1], "move", o_x,o_y)
    TT_MakeUnit_Target(BOSSES[1])

    b_x,b_y,o_x,o_y,h_x,h_y = nil,nil,nil,nil,nil,nil

    FIGHT_DATA.bm_Waves = 0
    FIGHT_DATA.phase = 1
    FIGHT_DATA.diff = diff

    local trg = CreateBossTrigger()
    TriggerRegisterEnterRectSimple(trg, BOSS_DATA[BOSS_BEASTMASTER_ID].regions.arena_Center)
    TriggerAddAction(trg, function()
        if GetEnteringUnit() == BOSSES[1] then
            MS_Freeze(BOSSES[1])
            BOSS_RunCounter(5,Beastmaster_Start)
            DestroyTrigger(GetTriggeringTrigger())
        end
    end)

    BOSS_CreateFleeTrigger(BOSS_BEASTMASTER_ID)

    trg = CreateBossTrigger()
    TriggerRegisterUnitEvent(trg, BOSSES[1], EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(trg, HERO, EVENT_UNIT_DEATH)
    TriggerAddAction(trg, function()
        if GetDyingUnit() == HERO then
            BOSS_Defeat(BOSS_BEASTMASTER_ID)
        else
            BOSS_Victory(BOSS_BEASTMASTER_ID)
        end
        DestroyTrigger(GetTriggeringTrigger())
    end)

    trg = CreateBossTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trg, Condition(Beastmaster_IsAbilityBeastWave))
    TriggerAddAction(trg, Beastmaster_SummonBeasts)

    trg = CreateBossTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trg, Condition(Beastmaster_IsAbilityCodoWave))
    TriggerAddAction(trg, Beastmaster_CodoWave)

    trg = CreateBossTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trg, Condition(Beastmaster_IsAbilityCodoWave))
    TriggerAddAction(trg, Beastmaster_CodoWave_Finish)

    if diff == BOSS_DIFFICULTY_HEROIC then
        BOSSBAR_Show('Rage')
        FIGHT_DATA.rage = 0
        BOSSBAR_Set(FIGHT_DATA.rage,true,nil,0)
        trg = CreateBossTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_DEATH)
        TriggerAddCondition(trg, Condition(function() return UNIT_IsCreep(GetDyingUnit()) and GetKillingUnitBJ() == HERO end))
        TriggerAddAction(trg,Beastmaster_AddRage)

        local b_id = GetHandleIdBJ(BOSSES[1])
        HP_CONSTANTS[b_id] = {
            {constant = 15000}
        }
        ARMOR_CONSTANTS[b_id] = {
            {armor = 10}
        }
        UNIT_RecalculateStats(BOSSES[1])

        trg = CreateBossTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_DAMAGING)
        TriggerAddCondition(trg, Condition(function() return GetUnitTypeId(GetEventDamageSource()) == FourCC('n003') end))
        TriggerAddAction(trg, function()
            if GetRandomInt(1, 100) <= 25 then
                STUN_StunUnit(BlzGetEventDamageTarget(),1.5)
            end
        end)
        b_id = nil
    end

    trg = CreateBossTrigger()
    TriggerRegisterUnitLifeEvent(trg, BOSSES[1], LESS_THAN_OR_EQUAL, BlzGetUnitMaxHP(BOSSES[1]) * 0.2)
    TriggerAddAction(trg, function()
        DestroyTrigger(GetTriggeringTrigger())
        BOSS_Transmission(BOSS_BEASTMASTER_ID,'enrage')
        IssueImmediateOrderBJ(BOSSES[1], "stop")
        MS_Unfreeze(BOSSES[1])
        DBM_DestroyAll()
        FIGHT_DATA.phase = 2
    end)

    trg = nil
end

function Beastmaster_IsAbilityCodoWave()
    return GetSpellAbilityId() == ABCODE_CODOWAVE
end

function Beastmaster_IsAbilityBeastWave()
    return GetSpellAbilityId() == ABCODE_SUMMONBEASTS
end

function Beastmaster_AddRage()
    FIGHT_DATA.rage = FIGHT_DATA.rage + 20
    if FIGHT_DATA.rage == 100 then
        FIGHT_DATA.rage = 0
        Beastmaster_RageOut()
    end
    BOSSBAR_Set(FIGHT_DATA.rage,true,nil,0)
end

function Beastmaster_RageOut()
    BOSS_Transmission(BOSS_BEASTMASTER_ID,'raged')
    AddSpecialEffectTargetUnitBJ("overhead", BOSSES[1], 'Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl')

    for i,u in pairs(ALL_UNITS) do
        if UNIT_IsCreep(u) and IsUnitAliveBJ(u) then
            BUFF_AddDebuff_Stack({
                name = 'CALLOFALPHA'
                ,target = u
            })
        end
    end

    local x,y = GetRandomCoordsInRect(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.spawn_Adds[GetRandomInt(1, 4)])
    UNIT_CreateCreep(PLAYER_BOSS, FourCC('n003'), x, y, 270)
    x,y = nil,nil
end

function Beastmaster_SummonBeasts()
    local tbl = {
        FourCC('n000')
        ,FourCC('n000')
        ,FourCC('n000')
        ,FourCC('n001')
        ,FourCC('n001')
        ,FourCC('n001')
        ,FourCC('n002')
        ,FIGHT_DATA.diff == BOSS_DIFFICULTY_HEROIC and FourCC('n002') or nil
    }

    for i,u_id in pairs(tbl) do
        local x,y = GetRandomCoordsInRect(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.spawn_Adds[GetRandomInt(1, 4)])
        UNIT_CreateCreep(PLAYER_BOSS, u_id, x, y, 270)
        x,y = nil,nil
    end

    tbl = nil

    FIGHT_DATA.bm_Waves = FIGHT_DATA.bm_Waves + 1
    if FIGHT_DATA.bm_Waves < 2 then
        BOSS_Transmission(BOSS_BEASTMASTER_ID,'summonbeast')
        DBM_RegisterTimer({
            time = ABILITIES_DATA[ABCODE_SUMMONBEASTS].CastingTime + 1
            ,icon = ABILITIES_DATA[ABCODE_SUMMONBEASTS].ICON
            ,name = ABILITIES_DATA[ABCODE_SUMMONBEASTS].Name
            ,id = 'beasts'
            ,barTheme = DBM_BAR_clBROWN
        })
        IssueImmediateOrderBJ(BOSSES[1], "stop")
        BOSS_WaitAndDo(1.0,Beastmaster_Cast_SummonBeasts)
    else
        FIGHT_DATA.bm_Waves = 0
        DBM_RegisterTimer({
            time = ABILITIES_DATA[ABCODE_SUMMONBEASTS].CastingTime + ABILITIES_DATA[ABCODE_CODOWAVE].CastingTime + 2.5
            ,icon = ABILITIES_DATA[ABCODE_SUMMONBEASTS].ICON
            ,name = ABILITIES_DATA[ABCODE_SUMMONBEASTS].Name
            ,id = 'beasts'
            ,barTheme = DBM_BAR_clBROWN
        })
        IssueImmediateOrderBJ(BOSSES[1], "stop")
        BOSS_WaitAndDo(1.0,Beastmaster_Cast_CodoWave)
    end
end

function Beastmaster_Cast_SummonBeasts()
    if FIGHT_DATA.phase == 1 then
        IssueImmediateOrderBJ(BOSSES[1], "unroot") 
    end 
end

function Beastmaster_Cast_CodoWave()
    if FIGHT_DATA.phase == 1 then
        IssueImmediateOrderBJ(BOSSES[1], "blink") 
    end
end

function Beastmaster_CodoWave_Spawn()
    local bx,by = GetRectMinX(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.arena[1]),GetRectMaxY(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.arena[1])
    local rmin,rmax,range = 50,200,350
    local uCount = R2I(round(IAbsBJ(GetRectMaxX(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.arena[1]) - GetRectMinX(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.arena[1])) / range,0)) - 1
    local maxDist = IAbsBJ(GetRectMaxY(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.arena[1]) - GetRectMinY(BOSS_DATA[BOSS_BEASTMASTER_ID].regions.arena[1]))
    for i = 0,uCount do
        local x,y = MATH_MoveXY(bx,by,I2R(i * range + GetRandomInt(rmin, rmax)), 360 * bj_DEGTORAD)
        local missle,height = MISSLE_CreateMissleXY(ABILITIES_DATA[ABCODE_CODOWAVE].MissleEffect,x,y)
        local tbl = {
            missleSpeed = ABILITIES_DATA[ABCODE_CODOWAVE].MissleSpeed
            ,missle = missle
            ,travel_dist = 0
            ,maxDist = maxDist
            ,height = height
            ,angle = 270.0
        }
        table.insert(BOSS_MISSLES,tbl)
        missle,height,tbl,x,y = nil,nil,nil,nil,nil
    end
    BeastMaster_CodoWaveMoving()
    bx,by,rmin,rmax,range,uCount,maxDist = nil,nil,nil,nil,nil,nil,nil
end

function BeastMaster_CodoWaveMoving()
    if not(FIGHT_DATA.codoMoveTrig) then
        FIGHT_DATA.codoMoveTrig = CreateBossTrigger()
        TriggerRegisterTimerEventPeriodic(FIGHT_DATA.codoMoveTrig, 0.03)
        TriggerAddAction(FIGHT_DATA.codoMoveTrig,function()
            if tableLength(BOSS_MISSLES) > 0 then
                for i,v in pairs(BOSS_MISSLES) do
                    if v.travel_dist >= v.maxDist then
                        MISSLE_Impact(v.missle)
                        table.remove(BOSS_MISSLES,i)
                    else
                        local grp = {}
                        local mx,my = MISSLE_GetXY(v.missle)
                        local ix,iy = MATH_MoveXY(mx,my,75.0,v.angle * bj_DEGTORAD)
                        for j,u in pairs(ALL_UNITS) do
                            local ux,uy = GetUnitXY(u)
                            if MATH_GetDistance(ux,uy,ix,iy) <= 100.00 and IsUnitAliveBJ(u) and not(UNIT_IsBoss(u)) then
                                table.insert(grp,u)
                                break
                            end
                            ux,uy = nil,nil
                        end
                        if #grp > 0 then
                            MISSLE_Impact(v.missle)
                            table.remove(BOSS_MISSLES,i)
                            AddSpecialEffect('Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl', ix, iy)
                            local dmg = grp[1] == HERO and 2500.00 or 5000.00
                            DS_DamageUnit(BOSSES[1], grp[1], dmg, ATTACK_TYPE_SIEGE, DAMAGE_TYPE_DEMOLITION, ABCODE_CODOWAVE)
                            dmg = nil
                        else
                            v.travel_dist = v.travel_dist + v.missleSpeed
                            local x,y = MATH_MoveXY(mx,my,v.missleSpeed, v.angle * bj_DEGTORAD)
                            BlzSetSpecialEffectX(v.missle, x)
                            BlzSetSpecialEffectY(v.missle, y)
                            x,y = nil,nil
                        end
                        grp,mx,my,ix,iy = nil,nil,nil,nil,nil
                    end
                end
            else
                FIGHT_DATA.codoMoveTrig = nil
                DestroyTrigger(GetTriggeringTrigger())
            end
        end)
    end
end

function Beastmaster_CodoWave()
    BOSS_Transmission(BOSS_BEASTMASTER_ID,'codowave')
    FIGHT_DATA.codoSpawnTrig = CreateBossTrigger()

    TriggerRegisterTimerEventPeriodic(FIGHT_DATA.codoSpawnTrig, 1.0)
    TriggerAddAction(FIGHT_DATA.codoSpawnTrig,Beastmaster_CodoWave_Spawn)
end

function Beastmaster_CodoWave_Finish()
    DestroyTrigger(FIGHT_DATA.codoSpawnTrig)
    if GetTriggerEventId() == EVENT_PLAYER_UNIT_SPELL_FINISH then
        DBM_RegisterTimer({
            time = ABILITIES_DATA[ABCODE_SUMMONBEASTS].CastingTime * 2 + 4
            ,icon = ABILITIES_DATA[ABCODE_CODOWAVE].ICON
            ,name = ABILITIES_DATA[ABCODE_CODOWAVE].Name
            ,id = 'codo'
            ,barTheme = DBM_BAR_clGREEN
        })
        IssueImmediateOrderBJ(BOSSES[1], "stop")
        BOSS_WaitAndDo(1.0,Beastmaster_Cast_SummonBeasts)
    end
end

function Beastmaster_Victory()
    BOSS_Transmission(BOSS_BEASTMASTER_ID,'victory')
    UNIT_SetDmgImmune(HERO, true)
    BOSS_RemoveAllUnits()
    WaitAndDo(7.0,Beastmaster_Flushing)
    ARENA_ACTIVATED = false
end

function Beastmaster_Defeat()
    BOSS_Transmission(BOSS_BEASTMASTER_ID,'defeat')
    UNIT_SetDmgImmune(BOSSES[1], true)
    PauseUnitBJ(true, BOSSES[1])
    BOSS_RemoveAllUnits()
    WaitAndDo(5.0,Beastmaster_Flushing)
    ARENA_ACTIVATED = false
end

function Beastmaster_Start()
    SetUnitOwner(BOSSES[1], PLAYER_BOSS, true)
    IssueImmediateOrderBJ(BOSSES[1], "unroot")
    DBM_RegisterTimer({
        time = ABILITIES_DATA[ABCODE_SUMMONBEASTS].CastingTime
        ,icon = ABILITIES_DATA[ABCODE_SUMMONBEASTS].ICON
        ,name = ABILITIES_DATA[ABCODE_SUMMONBEASTS].Name
        ,id = 'beasts'
        ,barTheme = DBM_BAR_clBROWN
    })
    DBM_RegisterTimer({
        time = ABILITIES_DATA[ABCODE_SUMMONBEASTS].CastingTime * 2 + 2.5
        ,icon = ABILITIES_DATA[ABCODE_CODOWAVE].ICON
        ,name = ABILITIES_DATA[ABCODE_CODOWAVE].Name
        ,id = 'codo'
        ,barTheme = DBM_BAR_clGREEN
    })
end

function Beastmaster_Flee()
    UNIT_SetDmgImmune(BOSSES[1], true)
    PauseUnitBJ(true, BOSSES[1])

    BUFF_UnitClearAll(HERO)
    SetUnitLifePercentBJ(HERO, 100)

    BOSS_Transmission(BOSS_BEASTMASTER_ID,'flee')

    local x,y = GetUnitXY(BOSSES[1])
    PanCameraToTimedForPlayer(PLAYER, x, y, 4.5)
    x,y = nil,nil

    BOSS_RemoveAllUnits()
    WaitAndDo(5.0,Beastmaster_Flushing)

    ARENA_ACTIVATED = false
end

function Beastmaster_Flushing()
    UNIT_Boss_Clear()
    MAIN_ClearFogModifiers()
    BOSS_ShowJournalButton()
    UI_ShowHeroPortrait()
    MAIN_MoveHero()
    WIDGET_HideAll()
end