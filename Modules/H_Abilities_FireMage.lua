-------------
--FIRE MAGE--
-------------

function AB_FireMage_MemoryClear()
    AB_RegisterHero_FireMage = nil
    AB_FireMage_FlameBlink = nil
    AB_FireMage_Pyroblast = nil
    AB_FireMage_OrbOfFire = nil
    AB_FireMage_BoltsOfPhoenix = nil
    AB_FireMage_Scorch = nil
    AB_FireMage_IgniteTarget_NoFireOrbs = nil
    AB_FireMage_IgniteTarget = nil
    AB_FireMage_Pyroblast_Cast = nil
    AB_FireMage_PyroblastMissleFly = nil
    AB_FireMage_AddFireOrb = nil
    AB_AddFireOrb = nil
    AB_FireOrbsMissleFly = nil
    AB_RemoveFireOrb = nil
    AB_FireMage_RemoveFireOrb = nil
    AB_FireMage_OrbOfFire_SummonOrb = nil
    AB_FireMage_OrbOfFire_Blast = nil
    AB_FireMage_OrbOfFire_AddStack = nil
    AB_FireMage_BoltsOfPhoenix_Channeling = nil
    AB_FireMage_BoltsOfPhoenix_MissleFly = nil
    AB_FireMage_AutoAttack = nil
    AB_FireMage_AutoAttack_MissleFly = nil
    AB_FireMage_RemoveFireOrbsAll = nil
    AB_FireMage_RemoveOrbsOfFire_All = nil
    AB_FireMage_SoulOfFire = nil
    AB_FireMage_FlamesOfRagnaros = nil
    AB_FireMage_OrbOfFire_Blasting = nil
    AB_FireMage_OrbOfFire_Impact = nil
    AB_FireMage_PurgingFlamesCast = nil
    AB_FireMage_PurgingFlames = nil
    AB_FireMage_MemoryClear = nil
end

function AB_RegisterHero_FireMage()
    AB_FireMage_Scorch()
    AB_FireMage_BoltsOfPhoenix()
    AB_FireMage_Pyroblast()
    AB_FireMage_FlameBlink()
    AB_FireMage_OrbOfFire()
    AB_FireMage_PurgingFlames()
    AB_FireMage_Scorch = nil
    AB_FireMage_BoltsOfPhoenix = nil
    AB_FireMage_Pyroblast = nil
    AB_FireMage_FlameBlink = nil
    AB_FireMage_OrbOfFire = nil
    AB_FireMage_PurgingFlames = nil
end


--REFACTORED
function AB_FireMage_PurgingFlames()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_PURGINGFLAMES end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].target = GetSpellTargetUnit()
    end)

    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_PURGINGFLAMES end))
    TriggerAddAction(trig, function()
        local caster = GetSpellAbilityUnit()
        AB_FireMage_PurgingFlamesCast(caster,SPELLS_DATA[GetHandleIdBJ(caster)].target)
        caster,SPELLS_DATA[GetHandleIdBJ(caster)].target = nil,nil
    end)
end

--REFACTORED
function AB_FireMage_PurgingFlamesCast(caster,target)
    AddSpecialEffectTargetUnitBJ("chest", target, 'Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl')
    if IsUnitAlly(target, GetOwningPlayer(caster)) then
        BUFF_DispellNRandomDebuffs(target,1)
    else
        BUFF_DispellNRandomBuffs(target,1)
    end
end

--REFACTORED
function AB_FireMage_SoulOfFire()
    if IsAbilityAvailable(HERO,ABCODE_SOULOFFIRE) and not(IsUnitDisabled(HERO)) then
        CD_TriggerAbilityCooldown(ABCODE_SOULOFFIRE,HERO)
        BUFF_AddDebuff_Override({
            name = ABILITIES_DATA[ABCODE_SOULOFFIRE].debuff
            ,target = HERO
            ,stat_factor_int = ABILITIES_DATA[ABCODE_SOULOFFIRE].stat_factor_int()
        })
    end
end

--REFACTORED
function AB_FireMage_FlamesOfRagnaros()
    if IsAbilityAvailable(HERO,ABCODE_FLAMESOFRAGNAROS) and not(IsUnitDisabled(HERO)) then
        CD_TriggerAbilityCooldown(ABCODE_FLAMESOFRAGNAROS,HERO)
        BUFF_AddDebuff_Override({
            name = ABILITIES_DATA[ABCODE_FLAMESOFRAGNAROS].debuff
            ,target = HERO
            ,armor_constant = ABILITIES_DATA[ABCODE_FLAMESOFRAGNAROS].getResistFactor()
            ,tick_period = 0.5
            ,tickFunc = function()
                BUFF_DispellAllDebuffs(DEBUFFS[trg_buff_id].target)
            end
        })
    end
end

--REFACTORED
function AB_FireMage_Pyroblast_Cast(caster,target,noclear,freeblast)
    if not(noclear) then
        BUFF_UnitClearDebuffAllStacks(caster,'FIREORB_PYROBUFF')
        SPELLS_DATA[GetHandleIdBJ(caster)].target = nil
    end
    if target and IsUnitAliveBJ(target) then
        local x,y = GetUnitXY(caster)
        local missle,height = MISSLE_CreateMissleXY(ABILITIES_DATA[ABCODE_PYROBLAST].MissleEffect,x,y)
        height = (UNIT_GetChestHeight(target) or height) - (100.0 - height)

        table.insert(MISSLE_GROUPS[ABCODE_PYROBLAST],{
            target = target
            ,caster = caster
            ,dmg = ABILITIES_DATA[ABCODE_PYROBLAST].getDamage(caster)
            ,missleSpeed = ABILITIES_DATA[ABCODE_PYROBLAST].MissleSpeed
            ,missle = missle
            ,height = height
        })

        if not(IsTriggerEnabled(MISSLE_TRIGGERS[ABCODE_PYROBLAST])) then
            EnableTrigger(MISSLE_TRIGGERS[ABCODE_PYROBLAST])
        end

        if not(freeblast) and AB_GetTalentModifier(ABCODE_PYROBLAST,'Pyromancer') >= GetRandomInt(1, 100) then
            WaitAndDo(0.5,AB_FireMage_Pyroblast_Cast,caster,target,true,true) 
        end

        missle,x,y,height = nil,nil,nil,nil
    end
end

--REFACTORED
function AB_FireMage_PyroblastMissleFly()
    if #MISSLE_GROUPS[ABCODE_PYROBLAST] > 0 then
        for i=#MISSLE_GROUPS[ABCODE_PYROBLAST],1,-1 do
            local target,missle = MISSLE_GROUPS[ABCODE_PYROBLAST][i].target,MISSLE_GROUPS[ABCODE_PYROBLAST][i].missle
            if IsUnitDeadBJ(target) then
                MISSLE_Impact(missle)
                table.remove(MISSLE_GROUPS[ABCODE_PYROBLAST],i)
            else
                local caster,missleSpeed = MISSLE_GROUPS[ABCODE_PYROBLAST][i].caster,MISSLE_GROUPS[ABCODE_PYROBLAST][i].missleSpeed
                local tx,ty = GetUnitXY(target)
                local x,y = MISSLE_GetXY(missle)
                local dist = MATH_GetDistance(x,y,tx,ty)
                local int = dist / missleSpeed > 1 and dist / missleSpeed or 1.0
                local m_z,t_z = BlzGetLocalSpecialEffectZ(missle) - MISSLE_GROUPS[ABCODE_PYROBLAST][i].height,GetUnitZ(target)
                if dist <= UNIT_GetImpactDist(target) then
                    MISSLE_Impact(missle)
                    DS_DamageUnit(caster, target, MISSLE_GROUPS[ABCODE_PYROBLAST][i].dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FIRE,ABCODE_PYROBLAST)
                    if dmgRecord[GetHandleIdBJ(target)][ABCODE_PYROBLAST].dmgReceived_WasCrit and IsAbilityAvailable(caster,ABCODE_IGNITE) then
                        AB_FireMage_AddFireOrb(caster)

                        AB_FireMage_IgniteTarget(target,caster,dmgRecord[GetHandleIdBJ(target)][ABCODE_PYROBLAST].dmgReceived_BefAbsrb)
                    end
                    table.remove(MISSLE_GROUPS[ABCODE_PYROBLAST],i)
                else
                    local rad = MATH_GetRadXY(x,y,tx,ty)
                    x,y = MATH_MoveXY(x,y,missleSpeed,rad)
                    BlzSetSpecialEffectPosition(missle, x, y, m_z + ((t_z - m_z) / int) + MISSLE_GROUPS[ABCODE_PYROBLAST][i].height)
                    BlzSetSpecialEffectYaw(missle, rad)
                    rad = nil
                end
                tx,ty,x,y,m_z,t_z,dist,int,caster,missleSpeed = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
            end
            target,missle = nil,nil
        end
    else    
        DisableTrigger(MISSLE_TRIGGERS[ABCODE_PYROBLAST])
    end
end

--REFACTORED
function AB_FireMage_AutoAttack(caster,target,dmg)
    local x,y = GetUnitXY(caster)
    local missle,height = MISSLE_CreateMissleXY(ABILITIES_DATA[ABCODE_AUTOATTACK].MissleEffect,x,y)
    height = (UNIT_GetChestHeight(target) or height) - (100.0 - height)
    table.insert(MISSLE_GROUPS[ABCODE_AUTOATTACK],{
        target = target
        ,caster = caster
        ,dmg = dmg
        ,missleSpeed = ABILITIES_DATA[ABCODE_AUTOATTACK].MissleSpeed
        ,missle = missle
        ,height = height
    })
    if not(IsTriggerEnabled(MISSLE_TRIGGERS[ABCODE_AUTOATTACK])) then
        EnableTrigger(MISSLE_TRIGGERS[ABCODE_AUTOATTACK])
    end
    missle,height,x,y  = nil,nil,nil,nil
end

--REFACTORED
function AB_FireMage_AutoAttack_MissleFly()
    if #MISSLE_GROUPS[ABCODE_AUTOATTACK] > 0 then
        for i=#MISSLE_GROUPS[ABCODE_AUTOATTACK],1,-1 do
            local target,missle = MISSLE_GROUPS[ABCODE_AUTOATTACK][i].target,MISSLE_GROUPS[ABCODE_AUTOATTACK][i].missle
            if IsUnitDeadBJ(target) then
                MISSLE_Impact(missle)
                table.remove(MISSLE_GROUPS[ABCODE_AUTOATTACK],i)
            else
                local caster,missleSpeed = MISSLE_GROUPS[ABCODE_AUTOATTACK][i].caster,MISSLE_GROUPS[ABCODE_AUTOATTACK][i].missleSpeed
                local tx,ty = GetUnitXY(target)
                local x,y = MISSLE_GetXY(missle)
                local dist = MATH_GetDistance(x,y,tx,ty)
                local int = dist / missleSpeed > 1 and dist / missleSpeed or 1.0
                local m_z,t_z = BlzGetLocalSpecialEffectZ(missle) - MISSLE_GROUPS[ABCODE_AUTOATTACK][i].height,GetUnitZ(target)
                if dist <= UNIT_GetImpactDist(target) then
                    MISSLE_Impact(missle)
                    DS_DamageUnit(caster, target, MISSLE_GROUPS[ABCODE_AUTOATTACK][i].dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FIRE,ABCODE_AUTOATTACK)
                    if dmgRecord[GetHandleIdBJ(target)][ABCODE_AUTOATTACK].dmgReceived_WasCrit and IsAbilityAvailable(caster,ABCODE_IGNITE) then
                        AB_FireMage_IgniteTarget(target,caster,dmgRecord[GetHandleIdBJ(target)][ABCODE_AUTOATTACK].dmgReceived_BefAbsrb)
                    end
                    table.remove(MISSLE_GROUPS[ABCODE_AUTOATTACK],i)
                else
                    local rad = MATH_GetRadXY(x,y,tx,ty)
                    x,y = MATH_MoveXY(x,y,missleSpeed,rad)
                    BlzSetSpecialEffectPosition(missle, x, y, m_z + ((t_z - m_z) / int) + MISSLE_GROUPS[ABCODE_AUTOATTACK][i].height)
                    BlzSetSpecialEffectYaw(missle, rad)
                    rad = nil
                end
                tx,ty,x,y,m_z,t_z,dist,int,caster,missleSpeed = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
            end
            target,missle = nil,nil
        end
    else
        DisableTrigger(MISSLE_TRIGGERS[ABCODE_AUTOATTACK])
    end
end

function AB_FireMage_BoltsOfPhoenix()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_BOLTSOFPHOENIX end))
    TriggerAddAction(trig, function()
        MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIXCASTTIME] = {
            caster = GetSpellAbilityUnit()
            ,target = GetSpellTargetUnit()
            ,curPeriod = 0
        }
        if not(IsTriggerEnabled(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIXCASTTIME])) then
            EnableTrigger(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIXCASTTIME])
        end
    end)

    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_BOLTSOFPHOENIX end))
    TriggerAddAction(trig, function()
        MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIXCASTTIME] = nil
    end)
end

--REFACTORED
function AB_FireMage_BoltsOfPhoenix_Channeling()
    if MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIXCASTTIME] then
        local target,caster = MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIXCASTTIME].target,MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIXCASTTIME].caster
        if #MISSLE_GROUPS[ABCODE_ORBS] > 0 and IsUnitAliveBJ(target) then
            local period = UNIT_GetAbilityCastingTime(ABCODE_BOLTSOFPHOENIXCASTTIME,caster)
            if MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIXCASTTIME].curPeriod >= period then
                local x,y = nil,nil
                if AB_GetTalentModifier(ABCODE_ORBS,'Burster') and BUFF_UnitHasDebuff(caster,'SOULOFFIRE') then
                    x,y = AB_FireMage_GetFireOrbXY(MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIXCASTTIME].caster)
                else
                    x,y = AB_FireMage_RemoveFireOrb(MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIXCASTTIME].caster)
                end
                local missle,height = MISSLE_CreateMissleXY(ABILITIES_DATA[ABCODE_BOLTSOFPHOENIXCASTTIME].MissleEffect,x,y)
                height = (UNIT_GetChestHeight(target) or height) - (100.0 - height)
                table.insert(MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX],{
                    caster = caster
                    ,target = target
                    ,missle = missle
                    ,missleSpeed = ABILITIES_DATA[ABCODE_BOLTSOFPHOENIXCASTTIME].MissleSpeed
                    ,dmg = ABILITIES_DATA[ABCODE_BOLTSOFPHOENIX].getDamage(caster)
                    ,height = height
                })
                
                if not(IsTriggerEnabled(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIX])) then
                    EnableTrigger(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIX])
                end

                MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIXCASTTIME].curPeriod = 0
                missle,height,x,y = nil,nil,nil,nil

                if IsUnitEnemy(target, GetOwningPlayer(caster)) then
                    if BUFF_GetStacksCount(caster,'FIREORB_PYROBUFF') < 5 then
                        BUFF_AddDebuff_Stack({
                            name = 'FIREORB_PYROBUFF'
                            ,target = caster
                            ,tick_period = 0.05
                            ,tickFunc = function()
                                if AB_GetTalentModifier(ABCODE_PYROBLAST,'Pyromancer') and UNIT_GetAbilityCastingTime(ABCODE_PYROBLAST,DEBUFFS[trg_buff_id].target) <= 0 then
                                    AB_FireMage_Pyroblast_Cast(DEBUFFS[trg_buff_id].target,TARGET)
                                end
                            end
                        })
                    end
                end
            end
            MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIXCASTTIME].curPeriod = round(MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIXCASTTIME].curPeriod + 0.02,2)
            period = nil
        else
            IssueImmediateOrderBJ(caster, 'stop')
            MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIXCASTTIME] = nil
        end
        target,caster = nil,nil
    else
        DisableTrigger(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIXCASTTIME])
    end
end

--REFACTORED
function AB_FireMage_BoltsOfPhoenix_MissleFly()
    if #MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX] > 0 then
        for i=#MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX],1,-1 do
            local target,missle = MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX][i].target,MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX][i].missle
            if IsUnitDeadBJ(target) then
                MISSLE_Impact(missle)
                table.remove(MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX],i)
            else 
                local caster,missleSpeed = MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX][i].caster,MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX][i].missleSpeed
                local tx,ty = GetUnitXY(target)
                local x,y = MISSLE_GetXY(missle)
                local dist = MATH_GetDistance(x,y,tx,ty)
                local int = dist / missleSpeed > 1 and dist / missleSpeed or 1.0
                local m_z,t_z = BlzGetLocalSpecialEffectZ(missle) - MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX][i].height,GetUnitZ(target)
                if dist <= UNIT_GetImpactDist(target) then
                    MISSLE_Impact(missle)
                    if IsUnitEnemy(target, GetOwningPlayer(caster)) then
                        DS_DamageUnit(caster, target, MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX][i].dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FIRE,ABCODE_BOLTSOFPHOENIX)
                        if AB_GetTalentModifier(ABCODE_BOLTSOFPHOENIX,'DarkPhoenix') then
                            if dmgRecord[GetHandleIdBJ(target)][ABCODE_BOLTSOFPHOENIX].dmgReceived_WasCrit and IsAbilityAvailable(caster,ABCODE_IGNITE) then
                                AB_FireMage_IgniteTarget(target,caster,dmgRecord[GetHandleIdBJ(target)][ABCODE_BOLTSOFPHOENIX].dmgReceived_BefAbsrb)
                            end
                        end
                    else
                        if BUFF_GetStacksCount(target,'FIREORB_SHIELDBUFF') >= ABILITIES_DATA[ABCODE_BOLTSOFPHOENIX].getMaxStacks() then
                            BUFF_UnitClearDebuff_XStacks(target,'FIREORB_SHIELDBUFF',1)
                        end
                        local seed = BUFF_GenerateSeed()
                        DS_SetAbsorb(caster,target,ABCODE_BOLTSOFPHOENIX,seed,((MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX][i].dmg * 0.8) * (AB_GetTalentModifier(ABCODE_BOLTSOFPHOENIX,'Defender') or 1)))
                        BUFF_AddDebuff_Stack({
                            name = 'FIREORB_SHIELDBUFF'
                            ,target = target
                            ,caster = caster
                            ,seed = seed
                            ,dotAbility = ABCODE_BOLTSOFPHOENIXCASTTIME
                            ,tickFunc = function()
                                HS_HealUnit(DEBUFFS[trg_buff_id].caster,DEBUFFS[trg_buff_id].target,(DS_GetAbsorb_AbilityStack(DEBUFFS[trg_buff_id].target,DEBUFFS[trg_buff_id].shieldAbility,trg_buff_id) or 0) * ABILITIES_DATA[ABCODE_BOLTSOFPHOENIX].HealFactor,ABCODE_BOLTSOFPHOENIXCASTTIME)
                            end
                        })
                        seed = nil
                    end
                    table.remove(MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX],i)
                else
                    local rad = MATH_GetRadXY(x,y,tx,ty)
                    x,y = MATH_MoveXY(x,y,missleSpeed,rad)
                    BlzSetSpecialEffectPosition(missle, x, y, m_z + ((t_z - m_z) / int) + MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX][i].height)
                    BlzSetSpecialEffectYaw(missle, rad)
                    rad = nil
                end
                tx,ty,x,y,m_z,t_z,dist,int,caster,missleSpeed = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
            end
            target,missle = nil,nil
        end
    else
        DisableTrigger(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIX])
    end
end

function AB_FireMage_FlameBlink()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_FLAMEBLINK end))
    TriggerAddAction(trig, function()
        local caster = GetSpellAbilityUnit()
        if not(BUFF_UnitIsRooted(caster)) then
            local tx,ty = GetSpellTargetX(),GetSpellTargetY()
            local x,y = GetUnitXY(caster)

            AddSpecialEffect('Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl', tx, ty)

            EFFECT_AddSpecialEffect_LifeSpan('Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl', x, y, 0.5)

            SetUnitPosition(caster, tx, ty)

            for i,u in pairs(ALL_UNITS) do
                local ux,uy = GetUnitXY(u)
                if MATH_GetDistance(ux,uy,tx,ty) <= ABILITIES_DATA[ABCODE_FLAMEBLINK].AOE and IsUnitEnemy(u, GetOwningPlayer(caster)) and IsUnitAliveBJ(u) then
                    DS_DamageUnit(caster, u, ABILITIES_DATA[ABCODE_FLAMEBLINK].getDamage(caster), ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FIRE,ABCODE_FLAMEBLINK)
                    if dmgRecord[GetHandleIdBJ(u)][ABCODE_FLAMEBLINK].dmgReceived_WasCrit and IsAbilityAvailable(caster,ABCODE_IGNITE) then
                        AB_FireMage_IgniteTarget_NoFireOrbs(u,caster,dmgRecord[GetHandleIdBJ(u)][ABCODE_FLAMEBLINK].dmgReceived_BefAbsrb)
                    end
                end
                ux,uy = nil,nil
            end

            tx,ty,x,y = nil,nil,nil,nil

            CD_TriggerAbilityCooldown(ABCODE_FLAMEBLINK,caster)
            if caster == HERO and AB_GetTalentModifier(ABCODE_FLAMEBLINK,'BlinkFury') then
                BUFF_AddDebuff_Override({
                    name = 'BLINKFURY'
                    ,target = caster
                })
            end
        end
        caster = nil
    end)
end

function AB_FireMage_Pyroblast()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_PYROBLAST end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].target = GetSpellTargetUnit()
    end)

    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_PYROBLAST end))
    TriggerAddAction(trig, function()
        AB_FireMage_Pyroblast_Cast(GetSpellAbilityUnit(),SPELLS_DATA[GetHandleIdBJ(GetSpellAbilityUnit())].target)
    end)
end

function AB_FireMage_OrbOfFire()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_ORBOFFIRE end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].x,SPELLS_DATA[c_id].y = GetSpellTargetX(),GetSpellTargetY()
    end)

    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_ORBOFFIRE end))
    TriggerAddAction(trig, function()
        local caster = GetSpellAbilityUnit()
        local c_id = GetHandleIdBJ(caster)
        AB_FireMage_OrbOfFire_SummonOrb(caster,SPELLS_DATA[c_id].x,SPELLS_DATA[c_id].y)
        CD_TriggerAbilityCooldown(ABCODE_ORBOFFIRE,caster)
        caster = nil
        SPELLS_DATA[c_id].x,SPELLS_DATA[c_id].y = nil,nil
    end)
end

function AB_FireMage_Scorch()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_SCORCH end))
    TriggerAddAction(trig, function()
        local c_id = GetHandleIdBJ(GetSpellAbilityUnit())
        SPELLS_DATA[c_id] = SPELLS_DATA[c_id] or {}
        SPELLS_DATA[c_id].target = GetSpellTargetUnit()
    end)

    trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddCondition(trig, Condition(function() return GetSpellAbilityId() == ABCODE_SCORCH end))
    TriggerAddAction(trig, function()
        local caster = GetSpellAbilityUnit()
        local target = SPELLS_DATA[GetHandleIdBJ(caster)].target
        AB_FireMage_ScorchCast(caster,target,true)
        AB_FireMage_OrbOfFire_TriggerScorch(caster,target)
        SPELLS_DATA[GetHandleIdBJ(caster)].target = nil
        caster = nil
        target = nil
    end)
end

function AB_FireMage_ScorchCast(caster,target,ignited)
    AddSpecialEffectTargetUnitBJ("chest", target, 'Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl')
    DS_DamageUnit(caster, target, ABILITIES_DATA[ABCODE_SCORCH].getDamage(caster), ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FIRE,ABCODE_SCORCH)
    if ignited then
        if dmgRecord[GetHandleIdBJ(target)][ABCODE_SCORCH].dmgReceived_WasCrit and IsAbilityAvailable(caster,ABCODE_IGNITE) then
            AB_FireMage_AddFireOrb(caster)
            AB_FireMage_IgniteTarget(target,caster,dmgRecord[GetHandleIdBJ(target)][ABCODE_SCORCH].dmgReceived_BefAbsrb)
        end
    end
end

function AB_FireMage_OrbOfFire_TriggerScorch(caster,target)
    local x,y = GetUnitXY(target)

    for i,u in pairs(ALL_UNITS) do
        local ux,uy = GetUnitXY(u)
        if MATH_GetDistance(ux,uy,x,y) <= ABILITIES_DATA[ABCODE_SCORCH].AOE and IsUnitEnemy(u, GetOwningPlayer(caster)) and BUFF_UnitHasDebuff(u,'ORBOFFIRE') and u ~= target then
            AB_FireMage_ScorchCast(caster,u,AB_GetTalentModifier(ABCODE_SCORCH,'Combustion'))
        end
        ux,uy = nil,nil
    end

    x,y = nil,nil
end

function AB_FireMage_IgniteTarget_NoFireOrbs(victim,dealer,damage) 
    for i=1,(AB_GetTalentModifier(ABCODE_IGNITE,'Ignitemaster') or 1) do
        BUFF_AddDebuff_Stack({
            name = 'IGNITED'
            ,target = victim
            ,caster = dealer
            ,armor_constant = ABILITIES_DATA[ABCODE_IGNITE].getResistFactor()
            ,duration = ABILITIES_DATA[ABCODE_IGNITE].duration()
            ,dmg = damage / (DEBUFFS_DATA['IGNITED'].duration / ABILITIES_DATA[ABCODE_IGNITE].CastingTime)
            ,tickFunc = function()
                DS_DamageUnit(DEBUFFS[trg_buff_id].caster, DEBUFFS[trg_buff_id].target, DEBUFFS[trg_buff_id].dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FIRE,ABCODE_IGNITE)
            end
        })
    end
end

function AB_FireMage_IgniteTarget(victim,dealer,damage)
    for i=1,(AB_GetTalentModifier(ABCODE_IGNITE,'Ignitemaster') or 1) do
        BUFF_AddDebuff_Stack({
            name = 'IGNITED'
            ,target = victim
            ,caster = dealer
            ,armor_constant = ABILITIES_DATA[ABCODE_IGNITE].getResistFactor()
            ,duration = ABILITIES_DATA[ABCODE_IGNITE].duration()
            ,dmg = damage / (DEBUFFS_DATA['IGNITED'].duration / ABILITIES_DATA[ABCODE_IGNITE].CastingTime)
            ,tickFunc = function()
                DS_DamageUnit(DEBUFFS[trg_buff_id].caster, DEBUFFS[trg_buff_id].target, DEBUFFS[trg_buff_id].dmg, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FIRE,ABCODE_IGNITE)
                if dmgRecord[GetHandleIdBJ(DEBUFFS[trg_buff_id].target)][ABCODE_IGNITE].dmgReceived_WasCrit and IsAbilityAvailable(DEBUFFS[trg_buff_id].caster,ABCODE_IGNITE) then
                    AB_FireMage_AddFireOrb(DEBUFFS[trg_buff_id].caster)
                end
            end
        })
    end
end

function AB_AddFireOrb(caster)
    local orbc = #MISSLE_GROUPS[ABCODE_ORBS] + 1
    if orbc <= (ABILITIES_DATA[ABCODE_ORBS].MaxCount + (AB_GetTalentModifier(ABCODE_ORBS,'Keeper') or 0)) then
        local angle = orbc > 1 and MISSLE_GROUPS[ABCODE_ORBS][1].angle or 0
        local angleInc = 360.00 / orbc

        for i, orb in ipairs(MISSLE_GROUPS[ABCODE_ORBS]) do
            orb.angle = angle
            angle = angle + angleInc
        end

        local x,y = MATH_MoveXY(GetUnitX(caster),GetUnitY(caster),100.00,angle * bj_DEGTORAD)
        local missle,height = MISSLE_CreateMissleXY(ABILITIES_DATA[ABCODE_ORBS].MissleEffect,x,y)

        table.insert(MISSLE_GROUPS[ABCODE_ORBS],{
            missle = missle
            ,angle = angle
            ,caster = caster
            ,height = height
            ,speed = ABILITIES_DATA[ABCODE_ORBS].MissleSpeed
        })

        if not(IsTriggerEnabled(MISSLE_TRIGGERS[ABCODE_ORBS])) then
            EnableTrigger(MISSLE_TRIGGERS[ABCODE_ORBS])
        end

        angle,angleInc,orbc,x,y,missle,height = nil,nil,nil,nil,nil,nil,nil
    end
    orbc = nil
end

--REFACTORED
function AB_FireOrbsMissleFly()
    if #MISSLE_GROUPS[ABCODE_ORBS] > 0 then
        for i = #MISSLE_GROUPS[ABCODE_ORBS],1,-1 do
            local caster,missle = MISSLE_GROUPS[ABCODE_ORBS][i].caster,MISSLE_GROUPS[ABCODE_ORBS][i].missle
            if IsUnitAliveBJ(caster) then
                MISSLE_GROUPS[ABCODE_ORBS][i].angle = MISSLE_GROUPS[ABCODE_ORBS][i].angle + MISSLE_GROUPS[ABCODE_ORBS][i].speed
                local rad = MISSLE_GROUPS[ABCODE_ORBS][i].angle * bj_DEGTORAD
                local x,y = MATH_MoveXY(GetUnitX(caster),GetUnitY(caster),100.00,rad)
                local z = GetUnitZ(caster)
                BlzSetSpecialEffectPosition(missle, x, y, z + MISSLE_GROUPS[ABCODE_ORBS][i].height)
                BlzSetSpecialEffectYaw(missle, rad)
                x,y,z,rad = nil,nil,nil,nil
            else
                MISSLE_Impact(missle)
                MISSLE_GROUPS[ABCODE_ORBS][i] = nil
            end
            caster,missle = nil,nil
        end
    else
        DisableTrigger(MISSLE_TRIGGERS[ABCODE_ORBS])
    end
end

function AB_RemoveFireOrb(caster)
    local orbc = #MISSLE_GROUPS[ABCODE_ORBS]
    if orbc > 0 then
        local x,y = MISSLE_GetXY(MISSLE_GROUPS[ABCODE_ORBS][orbc].missle)
        MISSLE_Impact(MISSLE_GROUPS[ABCODE_ORBS][orbc].missle)
        MISSLE_GROUPS[ABCODE_ORBS][orbc] = nil

        if orbc > 1 then
            local angle,angleInc = MISSLE_GROUPS[ABCODE_ORBS][1].angle,360.00 / (orbc - 1)
            for i, orb in ipairs(MISSLE_GROUPS[ABCODE_ORBS]) do
                orb.angle = angle
                angle = angle + angleInc
            end
            angle,angleInc = nil,nil
        end
        orbc = nil
        return x,y
    end
    orbc = nil
    return nil,nil
end

function AB_FireMage_GetFireOrbXY(caster)
    local i = GetRandomInt(1, #MISSLE_GROUPS[ABCODE_ORBS])
    return MISSLE_GetXY(MISSLE_GROUPS[ABCODE_ORBS][i].missle)
end

function AB_FireMage_AddFireOrb(caster)
    AB_AddFireOrb(caster)
    local i = IsInArray_ByKey(ABCODE_BOLTSOFPHOENIX,UI_ABILITIES,'abCode')
    if i then
        BlzFrameSetText(UI_ABILITIES[i].text, #MISSLE_GROUPS[ABCODE_ORBS])
        SILENCE_allowAbilitySeed(caster,ABCODE_BOLTSOFPHOENIX,'noorbs')
    end
end

function AB_FireMage_RemoveFireOrb(caster)
    local orbc = #MISSLE_GROUPS[ABCODE_ORBS] - 1
    local i = IsInArray_ByKey(ABCODE_BOLTSOFPHOENIX,UI_ABILITIES,'abCode')
    if i then
        BlzFrameSetText(UI_ABILITIES[i].text, orbc > 0 and I2S(orbc) or '')
        if orbc <= 0 then
            SILENCE_silenceAbility(caster,ABCODE_BOLTSOFPHOENIX,'noorbs')
        end
    end
    orbc,i = nil,nil
    return AB_RemoveFireOrb(caster)
end

--REFACTORED
function AB_FireMage_RemoveOrbsOfFire_All()
    for i=#MISSLE_GROUPS[ABCODE_ORBOFFIRE],1,-1 do
        AB_FireMage_OrbsOfFire_DestroyOrb(i)
    end
end

--REFACTORED
function AB_FireMage_OrbsOfFire_DestroyOrb(i)  
    DestroyEffectBJ(MISSLE_GROUPS[ABCODE_ORBOFFIRE][i].orb)
    table.remove(MISSLE_GROUPS[ABCODE_ORBOFFIRE],i)
end

--REFACTORED
function AB_FireMage_OrbOfFire_Blasting()
    if #MISSLE_GROUPS[ABCODE_ORBOFFIRE] > 0 then
        for i=#MISSLE_GROUPS[ABCODE_ORBOFFIRE],1,-1 do
            if MISSLE_GROUPS[ABCODE_ORBOFFIRE][i].cur_tick < MISSLE_GROUPS[ABCODE_ORBOFFIRE][i].tick_limit then
                if MISSLE_GROUPS[ABCODE_ORBOFFIRE][i].cur_period >= MISSLE_GROUPS[ABCODE_ORBOFFIRE][i].tick_period then
                    local x,y,caster = MISSLE_GROUPS[ABCODE_ORBOFFIRE][i].x,MISSLE_GROUPS[ABCODE_ORBOFFIRE][i].y,MISSLE_GROUPS[ABCODE_ORBOFFIRE][i].caster
                    local eff = oldAddSpecialEffect('war3mapImported\\Burning Blast.mdx', x, y)
                    BlzSetSpecialEffectScale(eff, 1.7)
                    BlzSetSpecialEffectZ(eff, 40.0)
                    DestroyEffectBJ(eff)
                    AB_FireMage_OrbOfFire_Blast(caster,x,y,ABILITIES_DATA[ABCODE_ORBOFFIRE].getDamage(caster))
                    MISSLE_GROUPS[ABCODE_ORBOFFIRE][i].cur_period = 0.0
                    MISSLE_GROUPS[ABCODE_ORBOFFIRE][i].cur_tick = MISSLE_GROUPS[ABCODE_ORBOFFIRE][i].cur_tick + 1
                    x,y,caster,eff = nil,nil,nil,nil
                else 
                    MISSLE_GROUPS[ABCODE_ORBOFFIRE][i].cur_period = MISSLE_GROUPS[ABCODE_ORBOFFIRE][i].cur_period + 0.02
                end
            else
                AB_FireMage_OrbsOfFire_DestroyOrb(i)
            end
        end
    else    
        DisableTrigger(MISSLE_TRIGGERS[ABCODE_ORBOFFIRE])
    end
end

--REFACTORED
function AB_FireMage_OrbOfFire_SummonOrb(caster,x,y)
    local orb = oldAddSpecialEffect('war3mapImported\\Orb of Fire.mdx', x, y)
    BlzSetSpecialEffectScale(orb, 1.6)
    BlzPlaySpecialEffectWithTimeScale(orb, ANIM_TYPE_BIRTH, 0.4)
    WaitAndDo(0.6, AB_FireMage_OrbOfFire_Impact,caster, x, y, orb)
end

--REFACTORED
function AB_FireMage_OrbOfFire_Impact(caster,x,y,orb)
    local eff = oldAddSpecialEffect('war3mapImported\\Burning Blast.mdx', x, y)
    BlzSetSpecialEffectScale(eff, 1.7)
    BlzSetSpecialEffectZ(eff, 40.0)
    DestroyEffectBJ(eff)
    AB_FireMage_OrbOfFire_Blast(caster,x,y,ABILITIES_DATA[ABCODE_ORBOFFIRE].getImpactDamage(caster))

    table.insert(MISSLE_GROUPS[ABCODE_ORBOFFIRE],{
        x = x
        ,y = y
        ,caster = caster
        ,orb = orb
        ,cur_tick = 0
        ,cur_period = 0.0
        ,tick_limit = ABILITIES_DATA[ABCODE_ORBOFFIRE].spell_tick_count()
        ,tick_period = ABILITIES_DATA[ABCODE_ORBOFFIRE].spell_tick()
    })

    if not(IsTriggerEnabled(MISSLE_TRIGGERS[ABCODE_ORBOFFIRE])) then
        EnableTrigger(MISSLE_TRIGGERS[ABCODE_ORBOFFIRE])
    end
end

function AB_FireMage_OrbOfFire_Blast(caster,x,y,damage)
    for i,u in pairs(ALL_UNITS) do
        local ux,uy = GetUnitXY(u)
        if MATH_GetDistance(ux,uy,x,y) <= ABILITIES_DATA[ABCODE_ORBOFFIRE].AOE and IsUnitEnemy(u, GetOwningPlayer(caster)) and IsUnitAliveBJ(u) then
            DS_DamageUnit(caster, u, damage, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FIRE,ABCODE_ORBOFFIRE)
            AB_FireMage_OrbOfFire_AddStack(u,caster)
        end
        ux,uy = nil,nil
    end
end

function AB_FireMage_OrbOfFire_AddStack(victim,dealer)
    local sc = BUFF_GetStacksCount(victim,'ORBOFFIRE')
    local mc = ABILITIES_DATA[ABCODE_ORBOFFIRE].getMaxStacks()
    if sc >= mc then
        BUFF_UnitClearDebuff_XStacks(victim,'ORBOFFIRE',(sc - mc) + 1)
    end
    BUFF_AddDebuff_Stack({
        name = 'ORBOFFIRE'
        ,target = victim
        ,caster = dealer
        ,duration = ABILITIES_DATA[ABCODE_ORBOFFIRE].duration()
        ,tickFunc = function()
            DS_DamageUnit(DEBUFFS[trg_buff_id].caster, DEBUFFS[trg_buff_id].target, ABILITIES_DATA[ABCODE_ORBOFFIRE].getDamageDOT(DEBUFFS[trg_buff_id].caster), ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FIRE,ABCODE_ORBOFFIRE)
        end
    })
end

function AB_FireMage_RemoveFireOrbsAll(unit)
    for i = #MISSLE_GROUPS[ABCODE_ORBS],1,-1 do
        AB_FireMage_RemoveFireOrb(unit)
    end
    BlzFrameSetText(UI_ABILITIES[IsInArray_ByKey(ABCODE_BOLTSOFPHOENIX,UI_ABILITIES,'abCode')].text, '')
    SILENCE_silenceAbility(unit,ABCODE_BOLTSOFPHOENIX,'noorbs')
end