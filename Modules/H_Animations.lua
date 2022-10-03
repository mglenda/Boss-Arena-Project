----------------------------------------------------
------------------HERO ANIMATIONS-------------------
----------------------------------------------------

HERO_SPELL_EFFECTS = {}

function HERO_PlayAnimation(animName,hero,time,reset)
    local h_id = GetUnitTypeId(hero)
    if HERO_DATA[h_id].anims and HERO_DATA[h_id].anims[animName] then
        if time then
            local speed = HERO_DATA[h_id].anims[animName].time
            speed = (speed == 0 and time or speed) / time
            SetUnitTimeScale(hero, speed)
            if reset then
                WaitAndDo(time,HERO_ResetAnimation,hero) 
            end
        else
            SetUnitTimeScale(hero, 1.0)
        end
        SetUnitAnimationByIndex(hero, HERO_DATA[h_id].anims[animName].id)
    end
end

function HERO_ResetAnimation(hero)
    SetUnitTimeScale(hero, 1.0)
    ResetUnitAnimation(hero)
end

function HERO_AddSpellEffectTarget(where,unit,effect,scale)
    local eff = oldAddEffect(where,unit,effect)
    BlzSetSpecialEffectScale(eff, scale or BlzGetSpecialEffectScale(eff))
    table.insert(HERO_SPELL_EFFECTS,eff)
    return eff
end

function HERO_DestroySpellEffects()
    for i = #HERO_SPELL_EFFECTS,1,-1 do
        DestroyEffect(HERO_SPELL_EFFECTS[i])
        table.remove(HERO_SPELL_EFFECTS,i)
    end
end

function HERO_PolishedAbilities_Register()
    local trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trg, Condition(HERO_IsCastingUnit))
    TriggerAddAction(trg, HERO_PolishedAbilities_Cast)

    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trg, Condition(HERO_IsCastingUnit))
    TriggerAddAction(trg, HERO_PolishedAbilities_Stop)

    trg = nil
    HERO_PolishedAbilities_Register = nil
end

function HERO_PolishedAbilities_Cast()
    local unit,abCode = GetTriggerUnit(),GetSpellAbilityId()
    local time = BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, abCode), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(unit, abCode)-1)
    time = time == 9000 and nil or time
    if abCode == ABCODE_PYROBLAST then
        HERO_PlayAnimation('A_SPELL_CINEMATIC',unit,time)
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
    elseif abCode == ABCODE_BOLTSOFPHOENIX then
        HERO_PlayAnimation('A_SPELL_CHANNEL',unit,time)
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
    elseif abCode == ABCODE_PURGINGFLAMES then
        HERO_PlayAnimation('A_SPELL',unit,time)
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
    elseif abCode == ABCODE_SCORCH then
        HERO_PlayAnimation('A_SPELL_CHANNEL',unit)
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
    elseif abCode == ABCODE_ORBOFFIRE then
        HERO_PlayAnimation('A_SPELL_SLAM',unit,time)
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
    elseif abCode == ABCODE_HOLYBOLT then
        HERO_PlayAnimation('A_SPELL',unit,time)
    elseif abCode == ABCODE_SACREDCURSE then
        HERO_PlayAnimation('A_SPELL',unit)
    elseif abCode == ABCODE_PENANCE then
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Weapons\\PriestMissile\\PriestMissile.mdl',1.5)
    elseif abCode == ABCODE_HOLYNOVA then
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Weapons\\PriestMissile\\PriestMissile.mdl',1.5)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Weapons\\PriestMissile\\PriestMissile.mdl',1.5)
    elseif abCode == ABCODE_PURIFY then
        HERO_PlayAnimation('A_SPELL',unit,time)
    elseif abCode == ABCODE_CHAOSBOLT then
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl',0.4)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl',0.4)
        HERO_PlayAnimation('A_SPELL_CHANNEL_BOTH',unit)
    elseif abCode == ABCODE_LIFEDRAIN then
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl',0.4)
    elseif abCode == ABCODE_FELMADNESS then
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl',0.4)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl',0.4)
        HERO_PlayAnimation('A_SPELL_CHANNEL_BOTH',unit)
    end
end

function HERO_PolishedAbilities_Stop()
    local unit,abcode = GetTriggerUnit(),GetSpellAbilityId()
    HERO_DestroySpellEffects()
    SetUnitTimeScale(unit, 1.0)
    if abcode == ABCODE_CHAOSBOLT or abcode == ABCODE_FELMADNESS then
        HERO_PlayAnimation('A_SPELL_THROW',HERO,0.5,true)
    end
end

function HERO_IsCastingUnit()
    return GetTriggerUnit() == HERO
end