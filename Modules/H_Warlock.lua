--------------
----WARLOCK----
--------------

function AB_Warlock_MemoryClear()
    AB_RegisterHero_Warlock = nil
    AB_Warlock_AddDemonicEnergy = nil
    AB_Warlock_ShadowBoltsCasting = nil
    AB_Warlock_ShadowBolts = nil
    AB_Warlock_ShadowBoltsMissleFly = nil
    AB_Warlock_ChaosBolt = nil
    AB_Warlock_ChaosBolt_Cast = nil
    AB_Warlock_ChaosBolt_Trigger = nil
    AB_Warlock_ChaosBoltMissleFly = nil
    AB_Warlock_LifeDrain = nil
    AB_Warlock_LifeDrainCasting = nil
    AB_Warlock_LifeDrainMissleFly = nil
    AB_Warlock_FelMadness = nil
    AB_Warlock_FelMadnessCast = nil
    AB_Warlock_ChaosBolt_Dot = nil
    AB_Warlock_SigilOfSargeras = nil
    AB_Warlock_CursedSoil_Blasting = nil
    AB_Warlock_CursedSoil = nil
    AB_Warlock_RemoveCursedSoils_All = nil
    AB_Warlock_CursedSoil_DestroyAura = nil
    AB_Warlock_CursedSoil_SummonAura = nil
    AB_Warlock_CursedSoil_Blast = nil
    AB_Warlock_CursedSoil_AddStack = nil
    AB_Warlock_CursedSoil_ApplyDebuff = nil
    AB_Warlock_VoidRift = nil
    AB_Warlock_VoidRight_Blast = nil
    AB_Warlock_GetSoiledUnits = nil
    AB_Warlock_DemonicBlessing_Dispell = nil
    AB_Warlock_DemonicBlessingCast = nil
    AB_Warlock_DemonicBlessing = nil
    AB_Warlock_ShieldOfLegion = nil
    AB_Warlock_ChaosBolt_OrbCharging = nil
    AB_Warlock_ChaosBolt_CreateOrb = nil
    AB_Warlock_ChaosBolt_DestroyAllOrbs = nil
    AB_Warlock_AddChaosBolt = nil
    AB_Warlock_RemoveChaosBolt = nil

    AB_Warlock_MemoryClear = nil
end

function AB_RegisterHero_Warlock()
    AB_Warlock_ShadowBolts()
    AB_Warlock_ChaosBolt()
    AB_Warlock_LifeDrain()
    AB_Warlock_FelMadness()
    AB_Warlock_CursedSoil()
    AB_Warlock_VoidRift()
    AB_Warlock_DemonicBlessing()

    AB_Warlock_DemonicBlessing = nil
    AB_Warlock_CursedSoil = nil
    AB_Warlock_FelMadness = nil
    AB_Warlock_LifeDrain = nil
    AB_Warlock_ShadowBolts = nil
    AB_Warlock_ChaosBolt = nil
    AB_RegisterHero_Warlock = nil
    AB_Warlock_VoidRift = nil
end

function AB_Warlock_ShieldOfLegion()
    if IsAbilityAvailable(HERO,ABCODE_SHIELDOFLEGION) and not(IsUnitDisabled(HERO)) then
        CD_TriggerAbilityCooldown(ABCODE_SHIELDOFLEGION,HERO)
        local seed = BUFF_GenerateSeed()
        DS_SetAbsorb(HERO,HERO,ABCODE_SHIELDOFLEGION,seed,ABILITIES_DATA[ABCODE_SHIELDOFLEGION].getDamage(HERO),true)
        BUFF_AddDebuff_Stack({
            name = ABILITIES_DATA[ABCODE_SHIELDOFLEGION].debuff
            ,target = HERO
            ,caster = HERO
            ,seed = seed
        })
        seed = nil
    end
end

function AB_Warlock_DemonicBlessing()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_DEMONICBLESSING end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].target = GetSpellTargetUnit()
    end)

    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_DEMONICBLESSING end))
    TriggerAddAction(trig, function()
        local caster = GetSpellAbilityUnit()
        AB_Warlock_DemonicBlessingCast(caster,SPELLS_DATA[GetHandleIdBJ(caster)].target)
        CD_TriggerAbilityCooldown(ABCODE_DEMONICBLESSING,caster)
        caster,SPELLS_DATA[GetHandleIdBJ(caster)].target = nil,nil
    end)
end

function AB_Warlock_DemonicBlessingCast(caster,target)
    AB_Warlock_DemonicBlessing_Dispell(caster,target)
    local ICON = IsUnitAlly(target, GetOwningPlayer(caster)) and 'war3mapImported\\BTN_DemonicBlessingBuff.dds' or 'war3mapImported\\BTN_DemonicBlessingDebuff.dds'
    local isDebuff = not(IsUnitAlly(target, GetOwningPlayer(caster)))
    BUFF_AddDebuff_Stack({
        name = 'DEMONICBLESSING'
        ,target = target
        ,caster = caster
        ,ICON = ICON
        ,isDebuff = isDebuff
    })
    ICON,isDebuff = nil,nil
end

function AB_Warlock_DemonicBlessing_Dispell(caster,target)
    AddSpecialEffectTargetUnitBJ('chest',target,'Abilities\\Spells\\NightElf\\Immolation\\ImmolationTarget.mdl')
    if IsUnitAlly(target, GetOwningPlayer(caster)) then
        BUFF_DispellNRandomDebuffs(target,1)
    else
        BUFF_DispellNRandomBuffs(target,1)
    end
end

function AB_Warlock_VoidRift()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_VOIDRIFT end))
    TriggerAddAction(trig, function()
        local caster = GetSpellAbilityUnit()
        if not(BUFF_UnitIsRooted(caster)) then
            local tx,ty = GetSpellTargetX(),GetSpellTargetY()
            local x,y = GetUnitXY(caster)

            AddSpecialEffect('war3mapImported\\Gravity Storm.mdl', x, y)
            AB_Warlock_VoidRight_Blast(caster,x,y)
            SetUnitPosition(caster, tx, ty)
            AddSpecialEffect('war3mapImported\\Gravity Storm.mdl', tx, ty)
            AB_Warlock_VoidRight_Blast(caster,tx,ty)

            tx,ty,x,y = nil,nil,nil,nil

            CD_TriggerAbilityCooldown(ABCODE_VOIDRIFT,caster)
        end
        caster = nil
    end)
end

function AB_Warlock_VoidRight_Blast(caster,x,y)
    for i,u in pairs(ALL_UNITS) do
        local ux,uy = GetUnitXY(u)
        if MATH_GetDistance(ux,uy,x,y) <= ABILITIES_DATA[ABCODE_VOIDRIFT].AOE and IsUnitEnemy(u, GetOwningPlayer(caster)) and IsUnitAliveBJ(u) then
            DS_DamageUnit(caster, u, ABILITIES_DATA[ABCODE_VOIDRIFT].getDamage(caster), ATTACK_TYPE_MAGIC, DAMAGE_TYPE_DEATH, ABCODE_VOIDRIFT)
        end
        ux,uy = nil,nil
    end
end

function AB_Warlock_CursedSoil()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_CURSEDSOIL end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].x,SPELLS_DATA[c_id].y = GetSpellTargetX(),GetSpellTargetY()
    end)

    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_CURSEDSOIL end))
    TriggerAddAction(trig, function()
        local caster = GetSpellAbilityUnit()
        local c_id = GetHandleIdBJ(caster)
        AB_Warlock_CursedSoil_SummonAura(caster,SPELLS_DATA[c_id].x,SPELLS_DATA[c_id].y)
        CD_TriggerAbilityCooldown(ABCODE_CURSEDSOIL,caster)
        caster = nil
        SPELLS_DATA[c_id].x,SPELLS_DATA[c_id].y = nil,nil
    end)
end

--REFACTORED
function AB_Warlock_CursedSoil_SummonAura(caster,x,y)
    local aura = oldAddSpecialEffect('war3mapImported\\Malevolence Aura Green.mdx', x, y)
    BlzSetSpecialEffectScale(aura, 3.5)
    local eff_tScale = UNIT_GetAbilityCastingTime(ABCODE_CURSEDSOIL,caster) / ABILITIES_DATA[ABCODE_CURSEDSOIL].CastingTime
    BlzSetSpecialEffectTimeScale(aura, eff_tScale)

    table.insert(MISSLE_GROUPS[ABCODE_CURSEDSOIL],{
        x = x
        ,y = y
        ,caster = caster
        ,aura = aura
        ,cur_tick = 0
        ,cur_period = 0.0
        ,tick_limit = ABILITIES_DATA[ABCODE_CURSEDSOIL].spell_tick_count()
        ,tick_period = ABILITIES_DATA[ABCODE_CURSEDSOIL].spell_tick(caster)
    })

    if not(IsTriggerEnabled(MISSLE_TRIGGERS[ABCODE_CURSEDSOIL])) then
        EnableTrigger(MISSLE_TRIGGERS[ABCODE_CURSEDSOIL])
    end

    eff_tScale = nil
end

function AB_Warlock_CursedSoil_Blast(caster,x,y,damage)
    for i,u in pairs(ALL_UNITS) do
        local ux,uy = GetUnitXY(u)
        if MATH_GetDistance(ux,uy,x,y) <= ABILITIES_DATA[ABCODE_CURSEDSOIL].AOE and IsUnitEnemy(u, GetOwningPlayer(caster)) and IsUnitAliveBJ(u) then
            DS_DamageUnit(caster, u, damage, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_DEATH, ABCODE_CURSEDSOIL)
        end
        ux,uy = nil,nil
    end
end

function AB_Warlock_CursedSoil_ApplyDebuff(caster,x,y)
    for i,u in pairs(ALL_UNITS) do
        local ux,uy = GetUnitXY(u)
        if MATH_GetDistance(ux,uy,x,y) <= ABILITIES_DATA[ABCODE_CURSEDSOIL].AOE and IsUnitEnemy(u, GetOwningPlayer(caster)) and IsUnitAliveBJ(u) then
            AB_Warlock_CursedSoil_AddStack(caster,u)
        end
        ux,uy = nil,nil
    end
end

function AB_Warlock_CursedSoil_AddStack(caster,target)
    if BUFF_UnitHasDebuff(target,'CURSEDSOIL') then
        BUFF_RefreshDebuffDurationAllStacks(target,'CURSEDSOIL')
    else
        BUFF_AddDebuff_Stack({
            name = 'CURSEDSOIL'
            ,target = target
            ,caster = caster
        })
    end
end

function AB_Warlock_CursedSoil_Blasting()
    if #MISSLE_GROUPS[ABCODE_CURSEDSOIL] > 0 then
        for i=#MISSLE_GROUPS[ABCODE_CURSEDSOIL],1,-1 do
            if MISSLE_GROUPS[ABCODE_CURSEDSOIL][i].cur_tick < MISSLE_GROUPS[ABCODE_CURSEDSOIL][i].tick_limit then
                if MISSLE_GROUPS[ABCODE_CURSEDSOIL][i].cur_period >= MISSLE_GROUPS[ABCODE_CURSEDSOIL][i].tick_period then
                    local x,y,caster = MISSLE_GROUPS[ABCODE_CURSEDSOIL][i].x,MISSLE_GROUPS[ABCODE_CURSEDSOIL][i].y,MISSLE_GROUPS[ABCODE_CURSEDSOIL][i].caster
                    AB_Warlock_CursedSoil_Blast(caster,x,y,ABILITIES_DATA[ABCODE_CURSEDSOIL].getDamage(caster))
                    AB_Warlock_CursedSoil_ApplyDebuff(caster,x,y)
                    MISSLE_GROUPS[ABCODE_CURSEDSOIL][i].cur_period = 0.0
                    MISSLE_GROUPS[ABCODE_CURSEDSOIL][i].cur_tick = MISSLE_GROUPS[ABCODE_CURSEDSOIL][i].cur_tick + 1
                    x,y,caster = nil,nil,nil
                else 
                    MISSLE_GROUPS[ABCODE_CURSEDSOIL][i].cur_period = MISSLE_GROUPS[ABCODE_CURSEDSOIL][i].cur_period + 0.02
                end
            else
                AB_Warlock_CursedSoil_DestroyAura(i)
            end
        end
    else    
        DisableTrigger(MISSLE_TRIGGERS[ABCODE_CURSEDSOIL])
    end
end

--REFACTORED
function AB_Warlock_RemoveCursedSoils_All()
    for i=#MISSLE_GROUPS[ABCODE_CURSEDSOIL],1,-1 do
        AB_Warlock_CursedSoil_DestroyAura(i)
    end
end

--REFACTORED
function AB_Warlock_CursedSoil_DestroyAura(i)  
    DestroyEffectBJ(MISSLE_GROUPS[ABCODE_CURSEDSOIL][i].aura)
    table.remove(MISSLE_GROUPS[ABCODE_CURSEDSOIL],i)
end

function AB_Warlock_AddDemonicEnergy(u,value)
    local e,e_c = UNIT_GetEnergy(u),UNIT_GetEnergyCap(u)
    e = (e + value) >= e_c and e_c or (e + value)
    UNIT_SetEnergy(u,e)
    if e >= 50.0 and not(SILENCE_IsSeedUnused(u,ABCODE_LIFEDRAIN,'nopower')) then
        SILENCE_allowAbilitySeed(u,ABCODE_LIFEDRAIN,'nopower')
    elseif e < 50.0 and SILENCE_IsSeedUnused(u,ABCODE_LIFEDRAIN,'nopower') then
        SILENCE_silenceAbility(u,ABCODE_LIFEDRAIN,'nopower')
    end

    if e >= 100.0 and not(SILENCE_IsSeedUnused(u,ABCODE_FELMADNESS,'nopower')) then
        SILENCE_allowAbilitySeed(u,ABCODE_FELMADNESS,'nopower')
    elseif e < 100.0 and SILENCE_IsSeedUnused(u,ABCODE_FELMADNESS,'nopower') then
        SILENCE_silenceAbility(u,ABCODE_FELMADNESS,'nopower')
    end
end

function AB_Warlock_RemoveDemonicEnergy(u,value)
    local e = UNIT_GetEnergy(u)
    e = value > e and 0 or e - value 
    UNIT_SetEnergy(u,e)
    if e >= 50.0 and not(SILENCE_IsSeedUnused(u,ABCODE_LIFEDRAIN,'nopower')) then
        SILENCE_allowAbilitySeed(u,ABCODE_LIFEDRAIN,'nopower')
    elseif e < 50.0 and SILENCE_IsSeedUnused(u,ABCODE_LIFEDRAIN,'nopower') then
        SILENCE_silenceAbility(u,ABCODE_LIFEDRAIN,'nopower')
    end

    if e >= 100.0 and not(SILENCE_IsSeedUnused(u,ABCODE_FELMADNESS,'nopower')) then
        SILENCE_allowAbilitySeed(u,ABCODE_FELMADNESS,'nopower')
    elseif e < 100.0 and SILENCE_IsSeedUnused(u,ABCODE_FELMADNESS,'nopower') then
        SILENCE_silenceAbility(u,ABCODE_FELMADNESS,'nopower')
    end
end

function AB_Warlock_SigilOfSargeras()
    if IsAbilityAvailable(HERO,ABCODE_SIGILOFSARGERAS) and not(IsUnitDisabled(HERO)) then
        CD_TriggerAbilityCooldown(ABCODE_SIGILOFSARGERAS,HERO)
        BUFF_AddDebuff_Override({
            name = ABILITIES_DATA[ABCODE_SIGILOFSARGERAS].debuff
            ,target = HERO
        })
    end
    if not(SILENCE_IsSeedUnused(HERO,ABCODE_CHAOSBOLT,'noenergy')) then
        SILENCE_allowAbilitySeed(HERO,ABCODE_CHAOSBOLT,'noenergy')
    end
end

function AB_Warlock_ChaosBolt_Dot(victim,dealer,damage) 
    BUFF_AddDebuff_Stack({
        name = 'CURSEOFARGUS'
        ,target = victim
        ,caster = dealer
        ,duration = ABILITIES_DATA[ABCODE_CHAOSBOLT].duration()
        ,dmg = damage
        ,tickFunc = function()
            DS_DamageUnit(DEBUFFS[trg_buff_id].caster, DEBUFFS[trg_buff_id].target, DEBUFFS[trg_buff_id].dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_DEATH, ABCODE_CURSEOFARGUS)
        end
    })
end

function AB_Warlock_FelMadness()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_FELMADNESS end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].target = GetSpellTargetUnit()
    end)

    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_FELMADNESS end))
    TriggerAddAction(trig, function()
        AB_Warlock_FelMadnessCast(GetSpellAbilityUnit(),SPELLS_DATA[GetHandleIdBJ(GetSpellAbilityUnit())].target)
    end)
end

function AB_Warlock_FelMadnessCast(caster,target)
    AB_Warlock_RemoveDemonicEnergy(caster,100.0)

    local units = AB_Warlock_GetSoiledUnits(caster,target)

    for _,u in pairs(units) do
        local dmg = ABILITIES_DATA[ABCODE_FELMADNESS].getDamage(caster)
        --AddSpecialEffectTargetUnitBJ('chest',u,'Abilities\\Spells\\NightElf\\Immolation\\ImmolationTarget.mdl')
        DS_DamageUnit(caster, u, dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_DEATH, ABCODE_FELMADNESS)
        dmg = nil

        BUFF_AddDebuff_Stack({
            name = 'FELMADNESS'
            ,target = u
            ,caster = caster
            ,tickFunc = function()
                local dmg = ABILITIES_DATA[ABCODE_FELMADNESS].getDamage(DEBUFFS[trg_buff_id].caster)
                --AddSpecialEffectTargetUnitBJ('chest',DEBUFFS[trg_buff_id].target,'Abilities\\Spells\\NightElf\\Immolation\\ImmolationTarget.mdl')
                DS_DamageUnit(DEBUFFS[trg_buff_id].caster, DEBUFFS[trg_buff_id].target, dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_DEATH, ABCODE_FELMADNESS)
                if AB_GetTalentModifier(ABCODE_FELMADNESS,'FelMastery') and dmgRecord[GetHandleIdBJ(DEBUFFS[trg_buff_id].target)][ABCODE_FELMADNESS].dmgReceived_WasCrit then
                    AB_Warlock_AddChaosBolt(DEBUFFS[trg_buff_id].caster)
                end
                dmg = nil
            end
        })
    end
    units = nil
end

function AB_Warlock_GetSoiledUnits(caster,target)
    local x,y = GetUnitXY(caster)
    local tbl = {}
    table.insert(tbl,target)
    for i,u in pairs(ALL_UNITS) do
        local ux,uy = GetUnitXY(u)
        if BUFF_UnitHasDebuff(u,'CURSEDSOIL') and MATH_GetDistance(ux,uy,x,y) <= 2500.0 and IsUnitEnemy(u, GetOwningPlayer(caster)) and IsUnitAliveBJ(u) then
            table.insert(tbl,u)
        end
        ux,uy = nil,nil
    end
    x,y = nil,nil
    return table_RemoveDuplicates(tbl)
end

function AB_Warlock_LifeDrain()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_LIFEDRAIN end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        AB_Warlock_RemoveDemonicEnergy(GetSpellAbilityUnit(),50.0)
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].target = GetSpellTargetUnit()
        SPELLS_DATA[c_id].caster = GetSpellAbilityUnit()
        SPELLS_DATA[c_id].trigger = CreateTrigger()
        SPELLS_DATA[c_id].per = round((UNIT_GetAbilityCastingTime(ABCODE_LIFEDRAIN,SPELLS_DATA[c_id].caster) / ABILITIES_DATA[ABCODE_LIFEDRAIN].spell_tick_count()) - 0.01,2)
        BUFF_AddDebuff_Stack({
            name = 'LIFEDRAIN'
            ,target = SPELLS_DATA[c_id].target
        })
        TriggerRegisterTimerEventPeriodic(SPELLS_DATA[c_id].trigger, SPELLS_DATA[c_id].per)
        TriggerAddAction(SPELLS_DATA[c_id].trigger, AB_Warlock_LifeDrainCasting)
        if SPELLS_DATA[c_id].caster == HERO then
            HERO_PlayAnimation('A_SPELL_SUMMON_START',HERO,SPELLS_DATA[c_id].per)
        end
    end)
    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_LIFEDRAIN end))
    TriggerAddAction(trig, function()
        local caster = GetSpellAbilityUnit()
        local c_id = GetHandleIdBJ(caster)
        BUFF_UnitClearDebuffAllStacks(SPELLS_DATA[c_id].target,'LIFEDRAIN')
        DestroyTrigger(SPELLS_DATA[c_id].trigger)
        SPELLS_DATA[c_id] = {}
        caster = nil
    end)
end

function AB_Warlock_LifeDrainCasting()
    for i,v in pairs(SPELLS_DATA) do
        if v.trigger == GetTriggeringTrigger() then
            if IsUnitAliveBJ(v.target) then
                if v.caster == HERO then
                    HERO_PlayAnimation('A_SPELL_CHANNEL_SUMMON',HERO)
                end
                local units = AB_Warlock_GetSoiledUnits(v.caster,v.target)
                for _,u in pairs(units) do
                    local x,y = GetUnitXY(u)
                    local missle,height = MISSLE_CreateMissleXY(ABILITIES_DATA[ABCODE_LIFEDRAIN].MissleEffect,x,y)
                    local height_t = (UNIT_GetChestHeight(u) or height) - (100.0 - height)
                    BlzSetSpecialEffectZ(missle, height_t)
                    height = (UNIT_GetChestHeight(v.caster) or height) - (100.0 - height)

                    local dmg = ABILITIES_DATA[ABCODE_LIFEDRAIN].getDamage(v.caster)
                    DS_DamageUnit(v.caster, u, dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_DEATH, ABCODE_LIFEDRAIN)
                    dmg = dmgRecord[GetHandleIdBJ(u)][ABCODE_LIFEDRAIN].dmgReceived_BefAbsrb

                    if dmg > 0 then
                        table.insert(MISSLE_GROUPS[ABCODE_LIFEDRAIN],{
                            target = u
                            ,caster = v.caster
                            ,dmg = dmg
                            ,missleSpeed = ABILITIES_DATA[ABCODE_LIFEDRAIN].MissleSpeed
                            ,missle = missle
                            ,height = height
                        })

                        if not(IsTriggerEnabled(MISSLE_TRIGGERS[ABCODE_LIFEDRAIN])) then
                            EnableTrigger(MISSLE_TRIGGERS[ABCODE_LIFEDRAIN])
                        end
                    else
                        MISSLE_Impact(missle)
                    end
                    missle,height,x,y,height_t,dmg = nil,nil,nil,nil,nil,nil
                end
                units = nil
            else
                IssueImmediateOrderBJ(v.caster, 'stop')
            end
        end
    end
end

function AB_Warlock_LifeDrainMissleFly()
    if #MISSLE_GROUPS[ABCODE_LIFEDRAIN] > 0 then
        for i=#MISSLE_GROUPS[ABCODE_LIFEDRAIN],1,-1 do
            local target,missle = MISSLE_GROUPS[ABCODE_LIFEDRAIN][i].caster,MISSLE_GROUPS[ABCODE_LIFEDRAIN][i].missle
            if IsUnitDeadBJ(target) then
                MISSLE_Impact(missle)
                table.remove(MISSLE_GROUPS[ABCODE_LIFEDRAIN],i)
            else
                local caster,missleSpeed = MISSLE_GROUPS[ABCODE_LIFEDRAIN][i].caster,MISSLE_GROUPS[ABCODE_LIFEDRAIN][i].missleSpeed
                local tx,ty = GetUnitXY(target)
                local x,y = MISSLE_GetXY(missle)
                local dist = MATH_GetDistance(x,y,tx,ty)
                local int = dist / missleSpeed > 1 and dist / missleSpeed or 1.0
                local m_z,t_z = BlzGetLocalSpecialEffectZ(missle) - MISSLE_GROUPS[ABCODE_LIFEDRAIN][i].height,GetUnitZ(target)
                if dist <= UNIT_GetImpactDist(target) then
                    MISSLE_Impact(missle)
                    HS_HealUnit(caster,target,MISSLE_GROUPS[ABCODE_LIFEDRAIN][i].dmg,ABCODE_LIFEDRAIN,true)
                    table.remove(MISSLE_GROUPS[ABCODE_LIFEDRAIN],i)
                else
                    local rad = MATH_GetRadXY(x,y,tx,ty)
                    x,y = MATH_MoveXY(x,y,missleSpeed,rad)
                    BlzSetSpecialEffectPosition(missle, x, y, m_z + ((t_z - m_z) / int) + MISSLE_GROUPS[ABCODE_LIFEDRAIN][i].height)
                    BlzSetSpecialEffectYaw(missle, rad)
                    rad = nil
                end
                tx,ty,x,y,m_z,t_z,dist,int,caster,missleSpeed = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
            end
            target,missle = nil,nil
        end
    else    
        DisableTrigger(MISSLE_TRIGGERS[ABCODE_LIFEDRAIN])
    end
end

function AB_Warlock_AddVoidEnergy(caster)
    local i = BUFF_GetStacksCount(caster,'VOID_ENERGY')
    if i < (AB_GetTalentModifier(ABCODE_SHADOWBOLTS,'ShadowSigil') or 6) then
        BUFF_AddDebuff_Stack({
            name = 'VOID_ENERGY'
            ,target = caster
        })
    end
    if i >= (AB_GetTalentModifier(ABCODE_SHADOWBOLTS,'ShadowSigil') or 6) - 1 then
        AB_Warlock_RemoveVoidEnergy(caster)
        AB_Warlock_AddChaosBolt(caster)
    end
end

function AB_Warlock_AddChaosBolt(caster)
    if BUFF_GetStacksCount(caster,'CHAOS_BOLT') < (AB_GetTalentModifier(ABCODE_FELMADNESS,'FelMastery') or 3) then
        BUFF_AddDebuff_Stack({
            name = 'CHAOS_BOLT'
            ,target = caster
        })
        SILENCE_allowAbilitySeed(caster,ABCODE_CHAOSBOLT,'noenergy')
    end
end

function AB_Warlock_RemoveChaosBolt(caster)
    BUFF_UnitClearDebuff_XStacks(caster,'CHAOS_BOLT',1)
    if BUFF_GetStacksCount(caster,'CHAOS_BOLT') <= 0 then
        SILENCE_silenceAbility(caster,ABCODE_CHAOSBOLT,'noenergy')
    end
end

function AB_Warlock_RemoveVoidEnergy(caster)
    BUFF_UnitClearDebuffAllStacks(caster,'VOID_ENERGY')
end

function AB_Warlock_ChaosBolt() 
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_CHAOSBOLT end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].target = GetSpellTargetUnit()
    end)

    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_CHAOSBOLT end))
    TriggerAddAction(trig, function()
        AB_Warlock_ChaosBolt_Trigger(GetSpellAbilityUnit(),SPELLS_DATA[GetHandleIdBJ(GetSpellAbilityUnit())].target)
    end)
end

function AB_Warlock_ChaosBolt_Trigger(caster,target)
    AB_Warlock_ChaosBolt_Cast(caster,target,ABILITIES_DATA[ABCODE_CHAOSBOLT].getDamage(caster))

    local rnd = GetRandomInt(1, 100)
    local x,y
    if rnd <= AB_GetTalentModifier(ABCODE_CHAOSBOLT,'ChaosMastery_1') then
        x,y = GetUnitXY(caster)
        x,y = MATH_MoveXY(x,y, 150.0, (GetUnitFacing(caster) + 135.0) * bj_DEGTORAD)
        AB_Warlock_ChaosBolt_CreateOrb(caster,target,x,y,1.0,ABILITIES_DATA[ABCODE_CHAOSBOLT].getDamage(caster) * 0.5)
    end
    if rnd <= AB_GetTalentModifier(ABCODE_CHAOSBOLT,'ChaosMastery_2') then
        x,y = GetUnitXY(caster)
        x,y = MATH_MoveXY(x,y, 150.0, (GetUnitFacing(caster) - 135.0) * bj_DEGTORAD)
        AB_Warlock_ChaosBolt_CreateOrb(caster,target,x,y,2.0,ABILITIES_DATA[ABCODE_CHAOSBOLT].getDamage(caster) * 0.25)
    end
end

function AB_Warlock_ChaosBolt_CreateOrb(caster,target,x,y,time,dmg)
    local orb = oldAddSpecialEffect('Abilities\\Spells\\Undead\\DarkSummoning\\DarkSummonMissile.mdl', x, y)
    local scale = 0.01
    local inc = 1.0 / (time / 0.02)
    BlzSetSpecialEffectScale(orb, scale)
    BlzSetSpecialEffectZ(orb, 100.0)

    table.insert(MISSLE_GROUPS['cb_Orbs'],{
        target = target
        ,caster = caster
        ,dmg = dmg
        ,scale = scale
        ,inc = inc
        ,orb = orb
    })

    if not(IsTriggerEnabled(MISSLE_TRIGGERS['cb_Orbs'])) then
        EnableTrigger(MISSLE_TRIGGERS['cb_Orbs'])
    end
end

function AB_Warlock_ChaosBolt_OrbCharging()
    if #MISSLE_GROUPS['cb_Orbs'] > 0 then
        for i=#MISSLE_GROUPS['cb_Orbs'],1,-1 do
            local target,orb = MISSLE_GROUPS['cb_Orbs'][i].target,MISSLE_GROUPS['cb_Orbs'][i].orb
            if IsUnitDeadBJ(target) then
                DestroyEffectBJ(orb)
                table.remove(MISSLE_GROUPS['cb_Orbs'],i)
            else
                local scale = MISSLE_GROUPS['cb_Orbs'][i].scale
                local inc = MISSLE_GROUPS['cb_Orbs'][i].inc
                if scale >= 1.0 then
                    local caster,target,dmg = MISSLE_GROUPS['cb_Orbs'][i].caster,MISSLE_GROUPS['cb_Orbs'][i].target,MISSLE_GROUPS['cb_Orbs'][i].dmg
                    local x = BlzGetLocalSpecialEffectX(orb)
                    local y = BlzGetLocalSpecialEffectY(orb)
                    DestroyEffectBJ(orb)
                    AB_Warlock_ChaosBolt_Cast(caster,target,dmg,x,y,'noenergy')
                    table.remove(MISSLE_GROUPS['cb_Orbs'],i)
                    caster,target,dmg,x,y = nil,nil,nil,nil,nil
                else
                    scale = scale + inc
                    BlzSetSpecialEffectScale(orb, scale)
                    MISSLE_GROUPS['cb_Orbs'][i].scale = scale
                end
                scale,inc = nil,nil
            end
            target,orb = nil,nil
        end 
    else    
        DisableTrigger(MISSLE_TRIGGERS['cb_Orbs'])
    end
end

function AB_Warlock_ChaosBolt_DestroyAllOrbs()
    for i=#MISSLE_GROUPS['cb_Orbs'],1,-1 do
        DestroyEffectBJ(MISSLE_GROUPS['cb_Orbs'][i].orb)
        table.remove(MISSLE_GROUPS['cb_Orbs'],i)
    end
end

function AB_Warlock_ChaosBolt_Cast(caster,target,dmg,x,y,noenergy)
    if not(BUFF_UnitHasDebuff(caster,'SIGILOFSARGERAS')) and not(noenergy) then
        AB_Warlock_RemoveChaosBolt(caster)
    end
    if target and IsUnitAliveBJ(target) then
        local x = x or GetUnitX(caster)
        local y = y or GetUnitY(caster)
        local missle,height = MISSLE_CreateMissleXY(ABILITIES_DATA[ABCODE_CHAOSBOLT].MissleEffect,x,y)
        height = (UNIT_GetChestHeight(target) or height) - (100.0 - height)

        table.insert(MISSLE_GROUPS[ABCODE_CHAOSBOLT],{
            target = target
            ,caster = caster
            ,dmg = dmg
            ,missleSpeed = ABILITIES_DATA[ABCODE_CHAOSBOLT].MissleSpeed
            ,missle = missle
            ,height = height
        })

        if not(IsTriggerEnabled(MISSLE_TRIGGERS[ABCODE_CHAOSBOLT])) then
            EnableTrigger(MISSLE_TRIGGERS[ABCODE_CHAOSBOLT])
        end

        AB_Warlock_AddDemonicEnergy(HERO,20.0)

        missle,x,y,height = nil,nil,nil,nil
    end
end

function AB_Warlock_ChaosBoltMissleFly()
    if #MISSLE_GROUPS[ABCODE_CHAOSBOLT] > 0 then
        for i=#MISSLE_GROUPS[ABCODE_CHAOSBOLT],1,-1 do
            local target,missle = MISSLE_GROUPS[ABCODE_CHAOSBOLT][i].target,MISSLE_GROUPS[ABCODE_CHAOSBOLT][i].missle
            if IsUnitDeadBJ(target) then
                MISSLE_Impact(missle)
                table.remove(MISSLE_GROUPS[ABCODE_CHAOSBOLT],i)
            else
                local caster,missleSpeed = MISSLE_GROUPS[ABCODE_CHAOSBOLT][i].caster,MISSLE_GROUPS[ABCODE_CHAOSBOLT][i].missleSpeed
                local tx,ty = GetUnitXY(target)
                local x,y = MISSLE_GetXY(missle)
                local dist = MATH_GetDistance(x,y,tx,ty)
                local int = dist / missleSpeed > 1 and dist / missleSpeed or 1.0
                local m_z,t_z = BlzGetLocalSpecialEffectZ(missle) - MISSLE_GROUPS[ABCODE_CHAOSBOLT][i].height,GetUnitZ(target)
                if dist <= UNIT_GetImpactDist(target) then
                    MISSLE_Impact(missle)
                    AddSpecialEffectTargetUnitBJ('chest',target,'Abilities\\Weapons\\DemonHunterMissile\\DemonHunterMissile.mdl')
                    AddSpecialEffectTargetUnitBJ('chest',target,'Abilities\\Spells\\NightElf\\Immolation\\ImmolationTarget.mdl')
                    DS_DamageUnit(caster, target, MISSLE_GROUPS[ABCODE_CHAOSBOLT][i].dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_DEATH,ABCODE_CHAOSBOLT)
                    AB_Warlock_ChaosBolt_Dot(target,caster,dmgRecord[GetHandleIdBJ(target)][ABCODE_CHAOSBOLT].dmgReceived_BefAbsrb * 0.1)
                    local ic = AB_GetTalentModifier(ABCODE_CHAOSBOLT,'InfusedChaos')
                    if ic then
                        BUFF_AddDebuffDurationAllStacks(target,'FELMADNESS',ic)
                    end
                    table.remove(MISSLE_GROUPS[ABCODE_CHAOSBOLT],i)
                    eff,ic = nil,nil
                else
                    local rad = MATH_GetRadXY(x,y,tx,ty)
                    x,y = MATH_MoveXY(x,y,missleSpeed,rad)
                    BlzSetSpecialEffectPosition(missle, x, y, m_z + ((t_z - m_z) / int) + MISSLE_GROUPS[ABCODE_CHAOSBOLT][i].height)
                    BlzSetSpecialEffectYaw(missle, rad)
                    rad = nil
                end
                tx,ty,x,y,m_z,t_z,dist,int,caster,missleSpeed = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
            end
            target,missle = nil,nil
        end
    else    
        DisableTrigger(MISSLE_TRIGGERS[ABCODE_CHAOSBOLT])
    end
end

function AB_Warlock_ShadowBolts()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_SHADOWBOLTS end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].target = GetSpellTargetUnit()
        SPELLS_DATA[c_id].caster = GetSpellAbilityUnit()
        SPELLS_DATA[c_id].trigger = CreateTrigger()
        SPELLS_DATA[c_id].per = round((UNIT_GetAbilityCastingTime(ABCODE_SHADOWBOLTS,SPELLS_DATA[c_id].caster) / ABILITIES_DATA[ABCODE_SHADOWBOLTS].spell_tick_count()) - 0.01,2)
        TriggerRegisterTimerEventPeriodic(SPELLS_DATA[c_id].trigger, SPELLS_DATA[c_id].per)
        TriggerAddAction(SPELLS_DATA[c_id].trigger, AB_Warlock_ShadowBoltsCasting)
        if SPELLS_DATA[c_id].caster == HERO then
            HERO_PlayAnimation('A_SPELL_THROW',HERO,SPELLS_DATA[c_id].per)
        end
    end)
    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_SHADOWBOLTS end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        DestroyTrigger(SPELLS_DATA[c_id].trigger)
        SPELLS_DATA[c_id] = {}
    end)
end

function AB_Warlock_ShadowBoltsCasting()
    for i,v in pairs(SPELLS_DATA) do
        if v.trigger == GetTriggeringTrigger() then
            if IsUnitAliveBJ(v.target) then
                if v.caster == HERO then
                    HERO_PlayAnimation('A_SPELL_CHANNEL_POINTING',HERO)
                    AB_Warlock_AddDemonicEnergy(HERO,AB_GetTalentModifier(ABCODE_SHADOWBOLTS,'ShadowSigil_Energy') or 5.0)
                    AB_Warlock_AddVoidEnergy(HERO)
                end
                local x,y = GetUnitXY(v.caster)
                x,y = MATH_MoveXY(x,y, 100.0, (GetUnitFacing(v.caster) + 12.0) * bj_DEGTORAD)
                local missle,height = MISSLE_CreateMissleXY(ABILITIES_DATA[ABCODE_SHADOWBOLTS].MissleEffect,x,y)
                height = (UNIT_GetChestHeight(v.target) or height) - (100.0 - height)
                table.insert(MISSLE_GROUPS[ABCODE_SHADOWBOLTS],{
                    target = v.target
                    ,caster = v.caster
                    ,dmg = ABILITIES_DATA[ABCODE_SHADOWBOLTS].getDamage(v.caster)
                    ,missleSpeed = ABILITIES_DATA[ABCODE_SHADOWBOLTS].MissleSpeed
                    ,missle = missle
                    ,height = height
                    ,mainMissle = missle
                })
            
                local mainMissle = missle
                local tx,ty = GetUnitXY(v.target)
                if MATH_GetDistance(x,y,tx,ty) >= 150.0 then    
                    for i=-1,1,2 do
                        missle,height = MISSLE_CreateMissleXY(ABILITIES_DATA[ABCODE_SHADOWBOLTS].MissleEffect,x,y)
                        height = (UNIT_GetChestHeight(v.target) or height) - (100.0 - height)
                        table.insert(MISSLE_GROUPS[ABCODE_SHADOWBOLTS],{
                            target = v.target
                            ,caster = v.caster
                            ,dmg = ABILITIES_DATA[ABCODE_SHADOWBOLTS].getDamage(v.caster)
                            ,missleSpeed = ABILITIES_DATA[ABCODE_SHADOWBOLTS].MissleSpeed
                            ,missle = missle
                            ,height = height
                            ,mainMissle = mainMissle
                            ,id = i
                            ,sep_away = 1
                        })
                    end
                end

                if not(IsTriggerEnabled(MISSLE_TRIGGERS[ABCODE_SHADOWBOLTS])) then
                    EnableTrigger(MISSLE_TRIGGERS[ABCODE_SHADOWBOLTS])
                end
                missle,height,x,y,mainMissle,tx,ty = nil,nil,nil,nil,nil,nil,nil
            else
                IssueImmediateOrderBJ(v.caster, 'stop')
            end
        end
    end
end

function AB_Warlock_ShadowBoltsMissleFly()
    if #MISSLE_GROUPS[ABCODE_SHADOWBOLTS] > 0 then
        for i=#MISSLE_GROUPS[ABCODE_SHADOWBOLTS],1,-1 do
            local target,missle = MISSLE_GROUPS[ABCODE_SHADOWBOLTS][i].target,MISSLE_GROUPS[ABCODE_SHADOWBOLTS][i].missle
            if IsUnitDeadBJ(target) then
                MISSLE_Impact(missle)
                table.remove(MISSLE_GROUPS[ABCODE_SHADOWBOLTS],i)
            else 
                local caster,missleSpeed = MISSLE_GROUPS[ABCODE_SHADOWBOLTS][i].caster,MISSLE_GROUPS[ABCODE_SHADOWBOLTS][i].missleSpeed
                local mainMissle = MISSLE_GROUPS[ABCODE_SHADOWBOLTS][i].mainMissle
                local tx,ty = GetUnitXY(target)
                local x,y = MISSLE_GetXY(mainMissle)
                local dist = MATH_GetDistance(x,y,tx,ty)
                local int = dist / missleSpeed > 1 and dist / missleSpeed or 1.0
                local m_z,t_z = BlzGetLocalSpecialEffectZ(mainMissle) - MISSLE_GROUPS[ABCODE_SHADOWBOLTS][i].height,GetUnitZ(target)
                if dist <= UNIT_GetImpactDist(target) then
                    MISSLE_Impact(missle)
                    if mainMissle == missle then
                        DS_DamageUnit(caster, target, MISSLE_GROUPS[ABCODE_SHADOWBOLTS][i].dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_DEATH, ABCODE_SHADOWBOLTS)
                    end
                    table.remove(MISSLE_GROUPS[ABCODE_SHADOWBOLTS],i)
                else
                    if mainMissle ~=  missle then
                        local rad = (MATH_GetAngleXY(x,y,tx,ty) + (90.0 * MISSLE_GROUPS[ABCODE_SHADOWBOLTS][i].id)) * bj_DEGTORAD
                        tx,ty = MISSLE_GetXY(missle)
                        local sep_dist = MATH_GetDistance(x,y,tx,ty)
                        MISSLE_GROUPS[ABCODE_SHADOWBOLTS][i].sep_away = sep_dist >= 150.0 and 0 or MISSLE_GROUPS[ABCODE_SHADOWBOLTS][i].sep_away
                        local sep_away = MISSLE_GROUPS[ABCODE_SHADOWBOLTS][i].sep_away
                        
                        sep_dist = sep_away == 1 and sep_dist + ((150.0 - sep_dist) / (int / 5)) or sep_dist - (sep_dist / int)

                        x,y = MATH_MoveXY(x,y,sep_dist,rad)
                        local rad_face = MATH_GetRadXY(tx,ty,x,y)

                        BlzSetSpecialEffectPosition(missle, x, y, m_z + ((t_z - m_z) / int) + MISSLE_GROUPS[ABCODE_SHADOWBOLTS][i].height)
                        BlzSetSpecialEffectYaw(missle, rad_face)

                        rad,sep_dist,rad_face,sep_away = nil,nil,nil,nil
                    else
                        local rad = MATH_GetRadXY(x,y,tx,ty)
                        x,y = MATH_MoveXY(x,y,missleSpeed,rad)
                        BlzSetSpecialEffectPosition(missle, x, y, m_z + ((t_z - m_z) / int) + MISSLE_GROUPS[ABCODE_SHADOWBOLTS][i].height)
                        BlzSetSpecialEffectYaw(missle, rad)
                        rad = nil
                    end
                end
                tx,ty,x,y,m_z,t_z,dist,int,caster,missleSpeed,mainMissle = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
            end
            target,missle = nil,nil
        end
    else
        DisableTrigger(MISSLE_TRIGGERS[ABCODE_SHADOWBOLTS])
    end
end