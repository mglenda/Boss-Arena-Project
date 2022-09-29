--------------
----PRIEST----
--------------

function AB_Priest_MemoryClear()
    AB_RegisterHero_Priest = nil
    AB_Priest_Penance = nil
    AB_Priest_PenanceMissleFly = nil
    AB_Priest_PenanceCasting = nil
    AB_Priest_HolyBolt = nil
    AB_Priest_HolyBolt_Cast = nil
    AB_Priest_HolyNova = nil
    AB_Priest_HolyNovaCasting = nil
    AB_Priest_LeapOfFaith = nil
    AB_Priest_LeapOfFaith_Move = nil
    AB_Priest_SacredCurse = nil
    AB_Priest_SacredCurse_Cast = nil
    AB_Priest_PowerInfusion = nil
    AB_Priest_Purify = nil
    AB_Priest_PurifyCast = nil
    AB_Priest_AddHolyEnergy = nil

    AB_Priest_MemoryClear = nil
end

function AB_RegisterHero_Priest()
    AB_Priest_Penance()
    AB_Priest_HolyBolt()
    AB_Priest_HolyNova()
    AB_Priest_LeapOfFaith()
    AB_Priest_SacredCurse()
    AB_Priest_Purify()
    AB_Priest_Purify = nil
    AB_Priest_LeapOfFaith = nil
    AB_Priest_Penance = nil
    AB_Priest_HolyBolt = nil
    AB_Priest_HolyNova = nil
    AB_Priest_SacredCurse = nil

    AB_RegisterHero_Priest = nil
end

function AB_Priest_Purify()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_PURIFY end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].target = GetSpellTargetUnit()
    end)

    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_PURIFY end))
    TriggerAddAction(trig, function()
        local caster = GetSpellAbilityUnit()
        AB_Priest_PurifyCast(caster,SPELLS_DATA[GetHandleIdBJ(caster)].target)
        caster,SPELLS_DATA[GetHandleIdBJ(caster)].target = nil,nil
    end)
end

function AB_Priest_PurifyCast(caster,target)
    AddSpecialEffectTargetUnitBJ("chest", target, 'Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl')
    if IsUnitAlly(target, GetOwningPlayer(caster)) then
        BUFF_DispellNRandomDebuffs(target,1)
    else
        BUFF_DispellNRandomBuffs(target,1)
    end
end

function AB_Priest_PowerInfusion()
    if IsAbilityAvailable(HERO,ABCODE_POWERINFUSION) and not(IsUnitDisabled(HERO)) then
        CD_TriggerAbilityCooldown(ABCODE_POWERINFUSION,HERO)
        BUFF_AddDebuff_Override({
            name = ABILITIES_DATA[ABCODE_POWERINFUSION].debuff
            ,target = HERO
            ,stat_factor_int = ABILITIES_DATA[ABCODE_POWERINFUSION].stat_factor_int()
        })
    end
end

function AB_Priest_AddHolyEnergy(u,value)
    if BUFF_GetStacksCount(u,'ATONEMENT') >= 1 then
        UNIT_SetEnergy(u,0)
    else
        local e,e_c = UNIT_GetEnergy(u),UNIT_GetEnergyCap(u)
        e = e + value
        if e >= e_c then
            BUFF_AddDebuff_Stack({
                name = 'ATONEMENT'
                ,target = u
            })
            e = 0
        end
        UNIT_SetEnergy(u,e)
    end
end

function AB_Priest_LeapOfFaith()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_LEAPOFFAITH end))
    TriggerAddAction(trig, function()
        local caster = GetSpellAbilityUnit()
        if not(BUFF_UnitIsRooted(caster)) then
            local tx,ty = GetSpellTargetX(),GetSpellTargetY()
            local x,y = GetUnitXY(caster)

            local eff = EFFECT_AddSpecialEffect_LifeSpan('Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl', tx, ty, 0.8, 1.5)
            BlzSetSpecialEffectYaw(eff, MATH_GetRadXY(tx,ty,x,y))
            BlzPlaySpecialEffectWithTimeScale(eff, ANIM_TYPE_BIRTH, 2.5)
            BlzSetSpecialEffectZ(eff, GetPointZ(tx,ty) - 150.0)
            WaitAndDo(0.8,AB_Priest_LeapOfFaith_Move,caster,tx,ty) 

            tx,ty,x,y,eff = nil,nil,nil,nil,nil

            CD_TriggerAbilityCooldown(ABCODE_LEAPOFFAITH,caster)
        end
        caster = nil
    end)
end

function AB_Priest_LeapOfFaith_Move(unit,tx,ty)
    if IsUnitAliveBJ(unit) then
        local x,y = GetUnitXY(unit)
        EFFECT_AddSpecialEffect_LifeSpan('Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl', x, y, 2.0)
        SetUnitX(unit, tx)
        SetUnitY(unit, ty)
        EFFECT_AddSpecialEffect_LifeSpan('Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl', tx, ty, 2.0)
        x,y = nil,nil
    end
end

function AB_Priest_HolyNova()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_HOLYNOVA end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].caster = GetSpellAbilityUnit()
        SPELLS_DATA[c_id].trigger = CreateTrigger()
        SPELLS_DATA[c_id].per = round((UNIT_GetAbilityCastingTime(ABCODE_HOLYNOVA,SPELLS_DATA[c_id].caster) / ABILITIES_DATA[ABCODE_HOLYNOVA].spell_tick_count()) - 0.01,2)
        TriggerRegisterTimerEventPeriodic(SPELLS_DATA[c_id].trigger, SPELLS_DATA[c_id].per)
        TriggerAddAction(SPELLS_DATA[c_id].trigger, AB_Priest_HolyNovaCasting)
        if SPELLS_DATA[c_id].caster == HERO then
            HERO_PlayAnimation('A_SPELL_CHANNEL_FINISH',HERO,SPELLS_DATA[c_id].per)
        end
    end)
    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_HOLYNOVA end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        DestroyTrigger(SPELLS_DATA[c_id].trigger)
        SPELLS_DATA[c_id] = {}
    end)
end

function AB_Priest_HolyNovaCasting()
    for i,v in pairs(SPELLS_DATA) do
        if v.trigger == GetTriggeringTrigger() then
            if v.caster == HERO then
                HERO_PlayAnimation('A_SPELL_CHANNEL_SUMMON',HERO)
            end
            local x,y = GetUnitXY(v.caster)
            local eff = oldAddSpecialEffect('war3mapImported\\Empyrean Nova.mdx', x, y)
            BlzSetSpecialEffectScale(eff, 1.6)
            WaitAndDo(2.0,DestroyEffectBJ,eff)
            for j,u in pairs(ALL_UNITS) do
                local ux,uy = GetUnitXY(u)
                if MATH_GetDistance(ux,uy,x,y) <= ABILITIES_DATA[ABCODE_HOLYNOVA].AOE and IsUnitAliveBJ(u) and GetOwningPlayer(u) ~= PLAYER_PASSIVE then
                    AddSpecialEffectTargetUnitBJ("chest", u, 'Abilities\\Weapons\\PriestMissile\\PriestMissile.mdl')
                    if IsUnitEnemy(u, GetOwningPlayer(v.caster)) then
                        DS_DamageUnit(v.caster, u, ABILITIES_DATA[ABCODE_HOLYNOVA].getDamage(v.caster), ATTACK_TYPE_MAGIC, DAMAGE_TYPE_DIVINE,ABCODE_HOLYNOVA)
                        AB_Priest_AddHolyEnergy(v.caster,dmgRecord[GetHandleIdBJ(u)][ABCODE_HOLYNOVA].dmgReceived_BefAbsrb)
                        AB_Priest_Atonement_Heal(v.caster,dmgRecord[GetHandleIdBJ(u)][ABCODE_HOLYNOVA].dmgReceived_BefAbsrb * 0.05,ABCODE_HOLYNOVA)
                    else
                        AB_Priest_HealUnit_Holy(v.caster,u,ABILITIES_DATA[ABCODE_HOLYNOVA].getHeal(v.caster),ABCODE_HOLYNOVA)
                        AB_Priest_AddHolyEnergy(v.caster,healRecord[GetHandleIdBJ(u)][ABCODE_HOLYNOVA].healReceived_BefAbsrb)
                    end
                end
                ux,uy = nil,nil
            end
            x,y = nil,nil
        end
    end
end

function AB_Priest_SacredCurse()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_SACREDCURSE end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].target = GetSpellTargetUnit()
    end)

    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_SACREDCURSE end))
    TriggerAddAction(trig, function()
        local caster = GetSpellAbilityUnit()
        local target = SPELLS_DATA[GetHandleIdBJ(caster)].target
        AB_Priest_SacredCurse_Cast(caster,target)
        SPELLS_DATA[GetHandleIdBJ(caster)].target = nil
    end)
end

function AB_Priest_SacredCurse_Cast(caster,target)
    BUFF_AddDebuff_Override({
        name = 'SACREDCURSE'
        ,target = target
        ,caster = caster
        ,duration = ABILITIES_DATA[ABCODE_SACREDCURSE].duration()
        ,tickFunc = function()
            DS_DamageUnit(DEBUFFS[trg_buff_id].caster, DEBUFFS[trg_buff_id].target, ABILITIES_DATA[ABCODE_SACREDCURSE].getDamage(DEBUFFS[trg_buff_id].caster), ATTACK_TYPE_MAGIC, DAMAGE_TYPE_DIVINE,ABCODE_SACREDCURSE)
            AB_Priest_AddHolyEnergy(DEBUFFS[trg_buff_id].caster,dmgRecord[GetHandleIdBJ(DEBUFFS[trg_buff_id].target)][ABCODE_SACREDCURSE].dmgReceived_BefAbsrb)
            AB_Priest_Atonement_Heal(DEBUFFS[trg_buff_id].caster,dmgRecord[GetHandleIdBJ(DEBUFFS[trg_buff_id].target)][ABCODE_SACREDCURSE].dmgReceived_BefAbsrb * 0.05,ABCODE_SACREDCURSE)
        end
    })
end

function AB_Priest_HolyBolt()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_HOLYBOLT end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].target = GetSpellTargetUnit()
    end)

    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_HOLYBOLT end))
    TriggerAddAction(trig, function()
        local caster = GetSpellAbilityUnit()
        local target = SPELLS_DATA[GetHandleIdBJ(caster)].target
        AB_Priest_HolyBolt_Cast(caster,target)
        SPELLS_DATA[GetHandleIdBJ(caster)].target = nil
    end)
end

function AB_Priest_HolyBolt_Cast(caster,target)
    AddSpecialEffectTargetUnitBJ("origin", target, 'Abilities\\Spells\\Items\\AIem\\AIemTarget.mdl')
    AddSpecialEffectTargetUnitBJ("chest", target, 'Abilities\\Weapons\\AncestralGuardianMissile\\AncestralGuardianMissile.mdl')
    DS_DamageUnit(caster, target, ABILITIES_DATA[ABCODE_HOLYBOLT].getDamage(caster), ATTACK_TYPE_MAGIC, DAMAGE_TYPE_DIVINE, ABCODE_HOLYBOLT)
    AB_Priest_AddHolyEnergy(caster,dmgRecord[GetHandleIdBJ(target)][ABCODE_HOLYBOLT].dmgReceived_BefAbsrb)
    AB_Priest_Atonement_Heal(caster,dmgRecord[GetHandleIdBJ(target)][ABCODE_HOLYBOLT].dmgReceived_BefAbsrb * 0.05,ABCODE_HOLYBOLT)
    if dmgRecord[GetHandleIdBJ(target)][ABCODE_HOLYBOLT].dmgReceived_WasCrit then
        if BUFF_GetStacksCount(caster,'BLESSED') < 3 then
            BUFF_AddDebuff_Stack({
                name = 'BLESSED'
                ,target = caster
            })
        end
        CD_ResetAbilityCooldown(caster,ABCODE_PENANCE)
    end
    BUFF_RefreshDebuffDurationAllStacks(target,'HOLYFOCUS')
    if BUFF_GetStacksCount(target,'HOLYFOCUS') < 5 then
        BUFF_AddDebuff_Stack({
            name = 'HOLYFOCUS'
            ,target = target
        })
    end
end

function AB_Priest_Penance()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_PENANCE end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].target = GetSpellTargetUnit()
        SPELLS_DATA[c_id].caster = GetSpellAbilityUnit()
        SPELLS_DATA[c_id].trigger = CreateTrigger()
        SPELLS_DATA[c_id].per = round((UNIT_GetAbilityCastingTime(ABCODE_PENANCE,SPELLS_DATA[c_id].caster) / (ABILITIES_DATA[ABCODE_PENANCE].spell_tick_count() + (BUFF_GetStacksCount(SPELLS_DATA[c_id].caster,'BLESSED') > 0 and 2 or 0))) - 0.01,2)
        TriggerRegisterTimerEventPeriodic(SPELLS_DATA[c_id].trigger, SPELLS_DATA[c_id].per)
        TriggerAddAction(SPELLS_DATA[c_id].trigger, AB_Priest_PenanceCasting)
        if SPELLS_DATA[c_id].caster == HERO then
            HERO_PlayAnimation('A_ATTACK',HERO,SPELLS_DATA[c_id].per)
        end
    end)
    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_PENANCE end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        DestroyTrigger(SPELLS_DATA[c_id].trigger)
        BUFF_UnitClearDebuff_XStacks(SPELLS_DATA[c_id].caster,'BLESSED',1)
        if BUFF_GetStacksCount(SPELLS_DATA[c_id].caster,'BLESSED') == 0 then
            CD_TriggerAbilityCooldown(ABCODE_PENANCE,SPELLS_DATA[c_id].caster)
        end
        SPELLS_DATA[c_id] = {}
    end)
end

function AB_Priest_PenanceCasting()
    for i,v in pairs(SPELLS_DATA) do
        if v.trigger == GetTriggeringTrigger() then
            if IsUnitAliveBJ(v.target) then
                if v.caster == HERO then
                    HERO_PlayAnimation('A_SPELL_CHANNEL_POINTING',HERO)
                end
                local x,y = GetUnitXY(v.caster)
                x,y = MATH_MoveXY(x,y, 80.0, (GetUnitFacing(v.caster) + 12.0) * bj_DEGTORAD)
                local missle,height = MISSLE_CreateMissleXY(ABILITIES_DATA[ABCODE_PENANCE].MissleEffect,x,y)
                height = (UNIT_GetChestHeight(v.target) or height) - (100.0 - height)
                table.insert(MISSLE_GROUPS[ABCODE_PENANCE],{
                    caster = v.caster
                    ,target = v.target
                    ,missle = missle
                    ,missleSpeed = ABILITIES_DATA[ABCODE_PENANCE].MissleSpeed
                    ,dmg = ABILITIES_DATA[ABCODE_PENANCE].getDamage(v.caster)
                    ,heal = ABILITIES_DATA[ABCODE_PENANCE].getHeal(v.caster)
                    ,height = height
                    ,weaver_cur = 0.0
                    ,weaver_goal = 10.0
                    ,weaver_inc = 2.0
                    ,weaver_goal_z = 25.0
                    ,weaver_cur_z = 25.0
                    ,weaver_inc_z = 5.0
                    ,x = BlzGetLocalSpecialEffectX(missle)
                    ,y = BlzGetLocalSpecialEffectY(missle)
                    ,z = BlzGetLocalSpecialEffectZ(missle) - height
                })
                
                if not(IsTriggerEnabled(MISSLE_TRIGGERS[ABCODE_PENANCE])) then
                    EnableTrigger(MISSLE_TRIGGERS[ABCODE_PENANCE])
                end
                missle,height,x,y = nil,nil,nil,nil
            else
                IssueImmediateOrderBJ(v.caster, 'stop')
            end
        end
    end
end

function AB_Priest_PenanceMissleFly()
    if #MISSLE_GROUPS[ABCODE_PENANCE] > 0 then
        for i=#MISSLE_GROUPS[ABCODE_PENANCE],1,-1 do
            local target,missle = MISSLE_GROUPS[ABCODE_PENANCE][i].target,MISSLE_GROUPS[ABCODE_PENANCE][i].missle
            if IsUnitDeadBJ(target) then
                MISSLE_Impact(missle)
                table.remove(MISSLE_GROUPS[ABCODE_PENANCE],i)
            else 
                local caster,missleSpeed = MISSLE_GROUPS[ABCODE_PENANCE][i].caster,MISSLE_GROUPS[ABCODE_PENANCE][i].missleSpeed
                local tx,ty = GetUnitXY(target)
                local x,y = MISSLE_GROUPS[ABCODE_PENANCE][i].x,MISSLE_GROUPS[ABCODE_PENANCE][i].y
                local dist = MATH_GetDistance(x,y,tx,ty)
                local int = dist / missleSpeed > 1 and dist / missleSpeed or 1.0
                local m_z,t_z = MISSLE_GROUPS[ABCODE_PENANCE][i].z - MISSLE_GROUPS[ABCODE_PENANCE][i].height,GetUnitZ(target)
                if dist <= UNIT_GetImpactDist(target) then
                    MISSLE_Impact(missle)
                    if IsUnitEnemy(target, GetOwningPlayer(caster)) then
                        BUFF_RefreshDebuffDurationAllStacks(target,'SACREDCURSE')
                        DS_DamageUnit(caster, target, MISSLE_GROUPS[ABCODE_PENANCE][i].dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_DIVINE, ABCODE_PENANCE)
                        AB_Priest_AddHolyEnergy(caster,dmgRecord[GetHandleIdBJ(target)][ABCODE_PENANCE].dmgReceived_BefAbsrb)
                        AB_Priest_Atonement_Heal(caster,dmgRecord[GetHandleIdBJ(target)][ABCODE_PENANCE].dmgReceived_BefAbsrb * 0.05,ABCODE_PENANCE)
                    else
                        AB_Priest_HealUnit_Holy(caster,target,MISSLE_GROUPS[ABCODE_PENANCE][i].heal,ABCODE_PENANCE)
                        AB_Priest_AddHolyEnergy(caster,healRecord[GetHandleIdBJ(target)][ABCODE_PENANCE].healReceived_BefAbsrb)
                    end
                    table.remove(MISSLE_GROUPS[ABCODE_PENANCE],i)
                else
                    local rad = MATH_GetRadXY(x,y,tx,ty)
                    x,y = MATH_MoveXY(x,y,missleSpeed,rad)
                    MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_cur = MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_cur + MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_inc
                    MISSLE_GROUPS[ABCODE_PENANCE][i].x = x
                    MISSLE_GROUPS[ABCODE_PENANCE][i].y = y
                    x,y = MATH_MoveXY(x,y,MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_cur,rad - (90.0 * bj_DEGTORAD))
                    if MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_cur >= MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_goal or MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_cur <= (MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_goal * (-1)) then
                        MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_inc = MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_inc * (-1)
                    end
                    m_z = m_z + ((t_z - m_z) / int) + MISSLE_GROUPS[ABCODE_PENANCE][i].height
                    MISSLE_GROUPS[ABCODE_PENANCE][i].z = m_z
                    m_z = m_z + MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_cur_z
                    if MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_cur_z >= MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_goal_z or MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_cur_z <= (MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_goal_z * (-1)) then
                        MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_inc_z = MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_inc_z * (-1)
                    end
                    MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_cur_z = MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_cur_z + MISSLE_GROUPS[ABCODE_PENANCE][i].weaver_inc_z
                    BlzSetSpecialEffectPosition(missle, x, y, m_z)
                    BlzSetSpecialEffectYaw(missle, rad)
                    rad = nil
                end
                tx,ty,x,y,m_z,t_z,dist,int,caster,missleSpeed = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
            end
            target,missle = nil,nil
        end
    else
        DisableTrigger(MISSLE_TRIGGERS[ABCODE_PENANCE])
    end
end

function AB_Priest_Atonement_Heal(caster,amount,abCode)
    if BUFF_GetStacksCount(caster,'ATONEMENT') >= 1 then 
        HS_HealUnit(caster,caster,amount,abCode)
    end
end

function AB_Priest_HealUnit_Holy(caster,target,amount,abcode)
    HS_HealUnit(caster,target,amount,abcode)
    local overheal = healRecord[GetHandleIdBJ(target)][abcode].overheal 
    if overheal > 1 then
        local seed = BUFF_GenerateSeed()
        DS_SetAbsorb(caster,target,ABCODE_POWERWORDSHIELD,seed,overheal,true)
        BUFF_AddDebuff_Stack({
            name = 'POWERWORD_SHIELD'
            ,target = target
            ,caster = caster
            ,seed = seed
        })
        seed = nil
    end
    overheal = nil
end