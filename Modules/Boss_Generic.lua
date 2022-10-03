----------------------------------------------------
-------------------BOSS GENERIC---------------------
----------------------------------------------------

function BOSS_WaitAndDo(duration,func, ...)
    local t = CreateTimer()
    table.insert(BOSS_TIMERS,t)
    local param = table.pack(...)
    TimerStart(t, duration, false, function()
        BOSS_DestoryTimer(t)
        func(table.unpack(param))
        t,func,param = nil,nil,nil
    end)
end

function BOSS_WaitAndDoExclusive(duration,func, ...)
    local t = CreateTimer()
    table.insert(BOSS_TIMERS_EXCLUSIVES,t)
    local param = table.pack(...)
    TimerStart(t, duration, false, function()
        BOSS_DestoryTimerExclusive(t)
        func(table.unpack(param))
        t,func,param = nil,nil,nil
    end)
end

function BOSS_DestoryTimerExclusive(timer)
    for i,t in pairs(BOSS_TIMERS_EXCLUSIVES) do
        if t == timer then
            table.remove(BOSS_TIMERS_EXCLUSIVES,i)
        end
    end
    DestroyTimer(timer)
end 

function BOSS_DestoryTimer(timer)
    for i,t in pairs(BOSS_TIMERS) do
        if t == timer then
            table.remove(BOSS_TIMERS,i)
        end
    end
    DestroyTimer(timer)
end

function BOSS_DestroyAllTimersExclusive()
    for i = #BOSS_TIMERS_EXCLUSIVES,1,-1 do
        DestroyTimer(BOSS_TIMERS_EXCLUSIVES[i])
        table.remove(BOSS_TIMERS_EXCLUSIVES,i)
    end
end

function BOSS_DestroyAllTimers()
    for i,t in pairs(BOSS_ANIM_TIMERS) do
        DestroyTimer(t)
    end
    for i = #BOSS_TIMERS,1,-1 do
        DestroyTimer(BOSS_TIMERS[i])
        table.remove(BOSS_TIMERS,i)
    end
    BOSS_ANIM_TIMERS = {}
end

function BOSS_AnimationWait(time,boss)
    local b = boss
    if BOSS_ANIM_TIMERS[b] then
        DestroyTimer(BOSS_ANIM_TIMERS[b])
    end
    BOSS_ANIM_TIMERS[b] = CreateTimer()
    TimerStart(BOSS_ANIM_TIMERS[b], time, false, function()
        BOSS_ResetAnimation(b)
        DestroyTimer(BOSS_ANIM_TIMERS[b])
        BOSS_ANIM_TIMERS[b] = nil
        b = nil
    end)
end

function BOSS_PlayAnimationAndDo(boss,boss_id,animName,time,func, ...)
    BOSS_PlayAnimation(boss,boss_id,animName,time)
    if not(time) and  BOSS_DATA[boss_id].anims and BOSS_DATA[boss_id].anims[animName] then
        time = BOSS_DATA[boss_id].anims[animName].time
    end
    BOSS_WaitAndDo(time,func,...)
end

function BOSS_PlayAnimation(boss,boss_id,animName,time)
    if BOSS_DATA[boss_id].anims and BOSS_DATA[boss_id].anims[animName] then
        if time then
            local speed = BOSS_DATA[boss_id].anims[animName].time
            speed = (speed == 0 and time or speed) / time
            SetUnitTimeScale(boss, speed)
            BOSS_AnimationWait(time,boss)
        elseif BOSS_ANIM_TIMERS[boss] then
            DestroyTimer(BOSS_ANIM_TIMERS[boss])
            BOSS_ResetAnimation(boss)
            BOSS_ANIM_TIMERS[boss] = nil
        end
        SetUnitAnimationByIndex(boss, BOSS_DATA[boss_id].anims[animName].id)
    end
end

function BOSS_ResetAnimation(boss)
    SetUnitTimeScale(boss, 1.0)
end

function BOSS_Transmission(b_id,key,id,time)
    PlaySoundBJ(BOSS_DATA[b_id].sounds[key])
    TransmissionFromUnitWithNameBJ(GetPlayersAll(), BOSSES[id or 1], BOSS_DATA[b_id].name, nil, BOSS_DATA[b_id].quotes[key], bj_TIMETYPE_ADD, time or 0, false)
end

function BOSS_RemoveAllUnits()
    BOSS_RemoveAllLightings()
    BOSS_RemoveAllCreeps()
    BOSS_RemoveAllDummies()
    BOSS_DestroyAllEffects()
end

function BOSS_RemoveAllCreeps()
    for i=#BOSS_CREEPS,1,-1 do 
        UNIT_RemoveClean(BOSS_CREEPS[i])
        BOSS_CREEPS[i] = nil
    end
end

function BOSS_RemoveAllDummies()
    for i = #BOSS_MISSLES,1,-1 do
        MISSLE_Impact(BOSS_MISSLES[i].missle)
        BOSS_MISSLES[i] = nil
    end
end

function BOSS_DestroyMissle(missle)
    for i,v in pairs(BOSS_MISSLES) do
        if v.missle == missle then
            MISSLE_Impact(v.missle)
            table.remove(BOSS_MISSLES,i)
            break
        end
    end
end

function BOSS_CreateEffectAttached(where,unit,effect)
    local eff = oldAddEffect(where,unit,effect)
    table.insert(BOSS_EFFECTS,eff)
    return eff
end

function BOSS_CreateEffect(modelName, x, y)
    local eff = oldAddSpecialEffect(modelName, x, y)
    table.insert(BOSS_EFFECTS,eff)
    return eff
end

function BOSS_AddSpellEffect_Polished(modelName, x, y, scale, initScale)
    local eff = BOSS_CreateEffect(modelName, x, y)
    BlzSetSpecialEffectScale(eff, initScale or 0.01)
    scale = scale or 1.0
    GENERIC_Effect_PolishedSpawn_AddToQueue(eff,scale)
    return eff
end

function BOSS_AddSpellEffectTarget_Polished(where,unit,effect,scale, initScale)
    local eff = BOSS_CreateEffectAttached(where,unit,effect)
    BlzSetSpecialEffectScale(eff, initScale or 0.01)
    scale = scale or 1.0
    GENERIC_Effect_PolishedSpawn_AddToQueue(eff,scale)
    return eff
end

function BOSS_DestroyAllEffects()
    for i = #BOSS_EFFECTS,1,-1 do
        DestroyEffectBJ(BOSS_EFFECTS[i])
        BOSS_EFFECTS[i] = nil
    end
end

function BOSS_DestroyEffect(eff)
    for i,e in pairs(BOSS_EFFECTS) do
        if e == eff then
            table.remove(BOSS_EFFECTS,i)
            break
        end
    end
    DestroyEffectBJ(eff)
end

function BOSS_CreateLighting(codeName, checkVisibility, x1, y1, z1, x2, y2, z2)
    local bolt = AddLightningEx(codeName, checkVisibility, x1, y1, z1, x2, y2, z2)
    table.insert(BOSS_LIGHTINGS,bolt)
    return bolt
end

function BOSS_RemoveAllLightings()
    for i = #BOSS_LIGHTINGS,1,-1 do
        DestroyLightning(BOSS_LIGHTINGS[i])
        BOSS_LIGHTINGS[i] = nil
    end
end

function BOSS_DestroyLighting(lighting)
    for i,l in pairs(BOSS_LIGHTINGS) do
        if l == lighting then
            DestroyLightning(l)
            table.remove(BOSS_LIGHTINGS,i)
            break
        end
    end
end

function BOSS_Defeat(id)
    BOSS_TriggersErase()
    BOSS_DestroyAllTimers()
    BOSS_DestroyAllTimersExclusive()
    DBM_DestroyAll()
    BOSS_StoreRecords(id,FIGHT_DATA.diff,'wipe')
    BOSS_DATA[id].defeatFunc()
    FIGHT_DATA = {}
    UNIT_RemoveAllDeads()
    BOSSBAR_Hide()
    HERO_SaveProfile()
end

function BOSS_Victory(id)
    BOSS_TriggersErase()
    BOSS_DestroyAllTimers()
    BOSS_DestroyAllTimersExclusive()
    DBM_DestroyAll()
    BOSS_ProgressDifficulties(id,FIGHT_DATA.diff)
    BOSS_StoreRecords(id,FIGHT_DATA.diff,'win')
    BOSS_DATA[id].victoryFunc()
    FIGHT_DATA = {}
    UNIT_RemoveAllDeads()
    BOSSBAR_Hide()
    HERO_SaveProfile()
end

function BOSS_FleeBattle(id)
    BOSS_TriggersErase()
    BOSS_DestroyAllTimers()
    BOSS_DestroyAllTimersExclusive()
    DBM_DestroyAll()
    BOSS_StoreRecords(id,FIGHT_DATA.diff,'flee')
    BOSS_DATA[id].fleeFunc()
    FIGHT_DATA = {}
    UNIT_RemoveAllDeads()
    BOSSBAR_Hide()
    HERO_SaveProfile()
end

function BOSS_StoreRecords(id,diff,type)
    if type == 'win' then
        local dps = DamageMeter_GetDps_Total()
        BOSS_DATA[id].records[diff].record_dps = BOSS_DATA[id].records[diff].record_dps < dps and dps or BOSS_DATA[id].records[diff].record_dps
        BOSS_DATA[id].records[diff].record_time = (BOSS_DATA[id].records[diff].record_time > FIGHT_DATA.RECORD_DURATION or BOSS_DATA[id].records[diff].record_time == 0) and FIGHT_DATA.RECORD_DURATION or BOSS_DATA[id].records[diff].record_time
        BOSS_DATA[id].records[diff].record_victories = BOSS_DATA[id].records[diff].record_victories + 1
        dps = nil
    elseif type == 'flee' then
        BOSS_DATA[id].records[diff].record_flees = BOSS_DATA[id].records[diff].record_flees + 1
    else
        BOSS_DATA[id].records[diff].record_wipes = BOSS_DATA[id].records[diff].record_wipes + 1
    end
end

function BOSS_ProgressDifficulties(id,diff)
    if diff >= BOSS_DIFFICULTY_NORMAL and not(BOSS_DATA[id].diff.defeated[BOSS_DIFFICULTY_NORMAL]) then
        BOSS_DATA[id].diff.defeated[BOSS_DIFFICULTY_NORMAL] = true
    end
    if diff >= BOSS_DIFFICULTY_HEROIC and not(BOSS_DATA[id].diff.defeated[BOSS_DIFFICULTY_HEROIC]) then
        BOSS_DATA[id].diff.defeated[BOSS_DIFFICULTY_HEROIC] = true
    end
    if diff == BOSS_DIFFICULTY_MYTHIC and not(BOSS_DATA[id].diff.defeated[BOSS_DIFFICULTY_MYTHIC]) then
        BOSS_DATA[id].diff.defeated[BOSS_DIFFICULTY_MYTHIC] = true
    end
    BOSS_RecalculateLevels()
    BOSS_RecalculateDifficulties()
end

function BOSS_RecalculateLevels()
    local lvl = 1
    for i,v in pairs(BOSS_DATA) do
        for j,diff in pairs(BOSS_DIFFICULTIES) do
            if v.diff.defeated[diff] then
                lvl = lvl + 1
            end
        end
    end
    HERO_SetLevel(lvl)
end

function BOSS_RecalculateDifficulties()
    for b_id,b in pairs(BOSS_DATA) do
        if b_id > 1 then
            BOSS_DATA[b_id].diff.avail[BOSS_DIFFICULTY_NORMAL] = (BOSS_DATA[b_id-1].diff.defeated[BOSS_DIFFICULTY_HEROIC] or BOSS_DATA[b_id-1].diff.defeated[BOSS_DIFFICULTY_NORMAL]) and (not(BOSS_DATA[b_id-2]) or BOSS_DATA[b_id-2].diff.defeated[BOSS_DIFFICULTY_HEROIC])
            BOSS_DATA[b_id].diff.avail[BOSS_DIFFICULTY_HEROIC] = BOSS_DATA[b_id-1].diff.defeated[BOSS_DIFFICULTY_HEROIC]
        end
    end
end

function BOSS_TriggersErase()
    for i=#BOSS_TRIGGERS,1,-1 do
        DestroyTrigger(BOSS_TRIGGERS[i])
    end
end

function CreateBossTrigger()
    local trg = CreateTrigger()
    table.insert(BOSS_TRIGGERS,trg)
    return trg
end

function BOSS_RunCounter(duration,func)
    local c_frame = BlzCreateFrame('Boss_FightCounter', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)
    BlzFrameSetPoint(c_frame, FRAMEPOINT_CENTER, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetText(c_frame, duration)
    local t = CreateTimer()
    TimerStart(t, 1.0 , true,function()
        duration = duration - 1
        if duration == 0 or not(ARENA_ACTIVATED) then 
            BlzDestroyFrame(c_frame)
            if func and ARENA_ACTIVATED then
                func()
            end
            DestroyTimer(t)
            func,t,c_frame,duration = nil,nil,nil,nil
        else
            BlzFrameSetText(c_frame, duration)
        end
    end)
end

function BOSS_CreateFleeTrigger(id)
    trg = CreateBossTrigger()
    for i,r in pairs(BOSS_DATA[id].regions.arena) do
        TriggerRegisterLeaveRectSimple(trg,r)
    end
    TriggerAddAction(trg, function()
        if GetLeavingUnit() == HERO and not(BOSS_IsHeroInArena(id)) then
            BOSS_FleeBattle(id)
            DestroyTrigger(GetTriggeringTrigger())
            id = nil
        end
    end)
    return trg
end

function BOSS_IsHeroInArena(id)
    return BOSS_IsUnitInRectList(HERO,BOSS_DATA[id].regions.arena)
end

function BOSS_IsUnitInArena(u,id)
    return BOSS_IsUnitInRectList(u,BOSS_DATA[id].regions.arena)
end

function BOSS_GetRandomCoordsInArena(id)
    local i = GetRandomInt(1, #BOSS_DATA[id].regions.arena)
    return GetRandomCoordsInRect(BOSS_DATA[id].regions.arena[i])
end

function BOSS_IsPointInArena(p,id)
    return BOSS_IsPointInRectList(p,BOSS_DATA[id].regions.arena)
end

function BOSS_IsPointInRectList(p,rList)
    for i,r in pairs(rList) do
        if IsPointInRect(p,r) then
            return true
        end
    end
    return false
end

function BOSS_IsUnitInRectList(unit,rList)
    for i,r in pairs(rList) do
        if IsUnitInRect(unit,r) then
            return true
        end
    end
    return false
end

function BOSS_DifficultyChoose()
    local index,diff = BOSS_IdentifyDiffButton(BlzGetTriggerFrame())
    if BOSS_DATA[index] and not(ARENA_ACTIVATED) then
        ARENA_ACTIVATED = true
        UI_HideAllMenus()
        BOSS_HideJournalButton()
        UI_HideHeroPortrait()
        BUFF_UnitClearAll(HERO)
        UNIT_SetDmgImmune(HERO, false)
        BOSS_ClearTrainingDummies()
        HERO_DATA[HERO_TYPE].ReadyUpFunc()
        CD_ResetAllAbilitiesCooldown(HERO)
        SetUnitLifePercentBJ(HERO, 100)
        BOSS_DATA[index].initFunc(diff)
        WIDGET_LoadAll(index)
        DamageMeter_Reset()
        FIGHT_DATA.RECORD_DURATION = 0.0
    end
    BlzFrameSetEnable(BlzGetTriggerFrame(), false)
    BlzFrameSetEnable(BlzGetTriggerFrame(), true)
end

function BOSS_StartRecordTrigger()
    local trg = CreateBossTrigger()
    TriggerRegisterTimerEventPeriodic(trg, 0.1)
    TriggerAddAction(trg, BOSS_DurationCount)
    trg = nil
end

function BOSS_DurationCount()
    FIGHT_DATA.RECORD_DURATION = FIGHT_DATA.RECORD_DURATION + 0.1
end

function BOSS_ClearTrainingDummies()
    for i,dummy in pairs(TRAINING_DUMMIES) do
        BUFF_UnitClearAll(dummy)
    end
end