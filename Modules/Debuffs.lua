----------------------------------------------------
------------------BUFF SYSTEM SETUP-----------------
----------------------------------------------------

function AddSpecialEffectBuff(where,unit,effect)
    local eff = oldAddEffect(where,unit,effect)
    return eff
end

function BUFF_GetStacksCount(unit,debuff_name)
    local c = 0
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.name == debuff_name then
            c = c + 1
        end
    end
    return c
end

function BUFF_UnitHasDebuff(unit,debuff_name)
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.name == debuff_name then
            return true
        end
    end
    return false
end

function BUFF_UnitClearAllDebuffs(unit)
    local d_tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.isDebuff then
            table.insert(d_tbl,i)
        end
    end
    for i,id in ipairs(d_tbl) do
        BUFF_ClearDebuff(id)
    end
    d_tbl = nil
end

function BUFF_UnitClearAll(unit)
    local d_tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit then
            table.insert(d_tbl,i)
        end
    end
    for i,id in ipairs(d_tbl) do
        BUFF_ClearDebuff(id)
    end
    d_tbl = nil
end

function BUFF_UnitClearDying(unit)
    local d_tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and not(v.deathpersistent) then
            table.insert(d_tbl,i)
        end
    end
    for i,id in ipairs(d_tbl) do
        BUFF_ClearDebuff(id)
    end
    d_tbl = nil
end

function BUFF_DispellNRandomBuffs(unit,count)
    local c,d_tbl = 0,{}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and not(v.notDispellable) and not(v.isDebuff) then
            table.insert(d_tbl,v)
            d_tbl[#d_tbl].b_id = i
        end
    end
    table.sort(d_tbl, function (k1, k2) return k1.debuffPriority < k2.debuffPriority end )
    for i=1,#d_tbl,1 do
        if c >= count then
            break
        end
        BUFF_ClearDebuff(d_tbl[i].b_id,true)
        c = c + 1
    end
    d_tbl = nil
end

function BUFF_DispellNRandomDebuffs(unit,count)
    local c,d_tbl = 0,{}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and not(v.notDispellable) and v.isDebuff then
            table.insert(d_tbl,v)
            d_tbl[#d_tbl].b_id = i
        end
    end
    table.sort(d_tbl, function (k1, k2) return k1.debuffPriority < k2.debuffPriority end )
    for i=1,#d_tbl,1 do
        if c >= count then
            break
        end
        BUFF_ClearDebuff(d_tbl[i].b_id,true)
        c = c + 1
    end
    d_tbl = nil
end

function BUFF_DispellAllDebuffs(unit)
    local d_tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and not(v.notDispellable) and v.isDebuff then
            table.insert(d_tbl,v)
            d_tbl[#d_tbl].b_id = i
        end
    end
    table.sort(d_tbl, function (k1, k2) return k1.debuffPriority < k2.debuffPriority end )
    for i=1,#d_tbl,1 do
        BUFF_ClearDebuff(d_tbl[i].b_id,true)
    end
    d_tbl = nil
end

function BUFF_UnitIsRooted(unit)
    for i,v in pairs(DEBUFFS) do
        if v.target == unit and v.movespeed_root then
            return true
        end
    end
    return false
end

function BUFF_ClearDebuff(ID,dispelled)
    if DEBUFFS[ID] and clr_buff_id ~= ID and not(DEBUFFS[ID].IMMORTAL) then
        clr_buff_id = ID
        local msfac = DEBUFFS[ID].movespeed_factor or DEBUFFS[ID].movespeed_constant or DEBUFFS[ID].movespeed_root
        local asfac = DEBUFFS[ID].attackspeed_factor
        local amfac = DEBUFFS[ID].armor_constant
        local healresfac = DEBUFFS[ID].healres_constant
        local regfac = DEBUFFS[ID].regen_factor or DEBUFFS[ID].regen_constant
        local hpfac = DEBUFFS[ID].hp_factor or DEBUFFS[ID].hp_constant
        local strfac = DEBUFFS[ID].stat_factor_str or DEBUFFS[ID].stat_constant_str
        local intfac = DEBUFFS[ID].stat_factor_int or DEBUFFS[ID].stat_constant_int
        local agifac = DEBUFFS[ID].stat_factor_agi or DEBUFFS[ID].stat_constant_agi
        local dmgfac = DEBUFFS[ID].dmg_factor or DEBUFFS[ID].dmg_constant
        local udmgfac = DEBUFFS[ID].unitdmg_factor or DEBUFFS[ID].unitdmg_constant
        local uvicdmgfac = DEBUFFS[ID].unitdmgvic_factor or DEBUFFS[ID].unitdmgvic_constant
        local uviccritfac = DEBUFFS[ID].unitcritvic_constant
        local uviccritMultfac = DEBUFFS[ID].unitcritMultvic_constant
        local ucritfac = DEBUFFS[ID].unitcrit_constant
        local ucritmultfac = DEBUFFS[ID].unitcritMult_constant
        local casttimefac = DEBUFFS[ID].casttime_factor or DEBUFFS[ID].casttime_constant
        local target = DEBUFFS[ID].target

        if not(DEBUFFS[ID].effect_unique) or BUFF_GetStacksCount(DEBUFFS[ID].target,DEBUFFS[ID].name) <= 1 then
            DestroyEffectBJ(DEBUFFS[ID].effect)
        end
        if DEBUFFS[ID].shieldAbility then
            DS_NullifyAbsorb(target,DEBUFFS[ID].shieldAbility,ID)
        end
        if DEBUFFS[ID].healabsAbility then
            HS_NullifyAbsorb(target,DEBUFFS[ID].healabsAbility,ID)
        end
        if dispelled and DEBUFFS[ID].dispellFunc then
            DEBUFFS[ID].dispellFunc()
        end
        if DEBUFFS[ID].endFunc then
            DEBUFFS[ID].endFunc()
        end
        DEBUFFS[ID] = nil
        T_DEBUFFS[ID] = nil
        if msfac then
            MS_Recalculate(target)
        end
        if asfac then
            AS_Recalculate(target)
        end
        if amfac then
            AM_Recalculate(target)
        end
        if regfac then
            HPREG_Recalculate(target)
        end
        if hpfac then
            HP_Recalculate(target)
        end
        if dmgfac then
            DMG_Recalculate(target)
        end
        if intfac then
            STATS_INT_Recalculate(target)
        end
        if agifac then
            STATS_AGI_Recalculate(target)
        end
        if strfac then
            STATS_STR_Recalculate(target)
        end
        if udmgfac then
            UNITDMG_Recalculate(target)
        end
        if ucritfac then
            UNITCRIT_Recalculate(target)
        end
        if ucritmultfac then
            UNITCRITMULT_Recalculate(target)
        end
        if casttimefac then
            CASTTIME_Recalculate(target)
        end
        if uvicdmgfac then
            UNITDMGVIC_Recalculate(target)
        end
        if healresfac then
            HR_Recalculate(target)
        end
        if uviccritfac then
            UNITCRITVIC_Recalculate(target)
        end
        if uviccritMultfac then
            UNITCRITMULTVIC_Recalculate(target)
        end
        target = nil
        clr_buff_id = nil
    end
end

function BUFF_UnitClearDebuff_XStacks(unit,debuff_name,count)
    local d_tbl = {}
    for i, v in pairs(DEBUFFS) do
        if count <= 0 then
            break
        else
            if v.target == unit and v.name == debuff_name then
                table.insert(d_tbl,i)
                count = count - 1
            end
        end
    end
    for i,id in ipairs(d_tbl) do
        BUFF_ClearDebuff(id)
    end
    d_tbl = nil
end

function BUFF_UnitClearDebuffAllStacks(unit,debuff_name)
    local d_tbl = {}
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.name == debuff_name then
            table.insert(d_tbl,i)
        end
    end
    for i,id in ipairs(d_tbl) do
        BUFF_ClearDebuff(id)
    end
    d_tbl = nil
end

function BUFF_RefreshDebuffDurationAllStacks(unit,debuff_name)
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.name == debuff_name then
            BUFF_RefreshDuration(i)
        end
    end
end

function BUFF_AddDebuffDurationAllStacks(unit,debuff_name,value)
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.name == debuff_name then
            BUFF_AddDebuffDuration(i,value)
        end
    end
end

function BUFF_SetDebuffDurationAllStacks(unit,debuff_name,value)
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.name == debuff_name then
            BUFF_SetDebuffDuration(i,value)
        end
    end
end

function BUFF_FreezeDurationAllStacks(unit,debuff_name)
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.name == debuff_name then
            BUFF_FreezeDuration(i)
        end
    end
end

function BUFF_UnfreezeDurationAllStacks(unit,debuff_name)
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.name == debuff_name then
            BUFF_UnfreezeDuration(i)
        end
    end
end

function BUFF_FreezeDuration(ID)
    BUFF_Attribute_SetValue(ID,'pauseCounter',true)
end

function BUFF_UnfreezeDuration(ID)
    BUFF_Attribute_SetValue(ID,'pauseCounter',false)
end

function BUFF_RefreshDuration(ID)
    BUFF_Attribute_SetValue(ID,'curTime',0)
end

function BUFF_AddDebuffDuration(ID,value)
    BUFF_Attribute_AddValue(ID,'duration',value)
end

function BUFF_SetDebuffDuration(ID,value)
    BUFF_Attribute_SetValue(ID,'duration',value)
end

function BUFF_Attribute_AddValue(ID,key,value)
    DEBUFFS[ID][key] = DEBUFFS[ID][key] and DEBUFFS[ID][key] + value or value
end

function BUFF_Attribute_SetValue(ID,key,value)
    DEBUFFS[ID][key] = value
end

function BUFF_Initialize()
    TriggerRegisterTimerEventPeriodic(DEBUFF_TRIGGER, 0.01)
    TriggerAddAction(DEBUFF_TRIGGER, function()
        if tableLength(T_DEBUFFS) > 0 then
            for i,v in pairs(T_DEBUFFS) do
                trg_buff_id = i
                local curTime = round(v.curTime,2)
                local duration = v.duration or nil
                local tick_period = nil
                if v.dotAbility then
                    tick_period = v.caster and UNIT_GetAbilityCastingTime(v.dotAbility,v.caster) or ABILITIES_DATA[v.dotAbility].CastingTime
                end
                tick_period = tick_period or (v.tick_period or nil)
                if tick_period then
                    local curTick = round(v.curTick,2)
                    if curTick >= tick_period then
                        if v.tickFunc then
                            v.tickFunc()
                        end
                        curTick = 0
                    end
                    v.curTick = curTick + 0.01
                end
                if (v.exitFunc and v.exitFunc()) or ((curTime > (duration or curTime)) or (not(IsUnitAliveBJ(v.target) and not(v.deathpersistent)))) then
                    T_DEBUFFS[i] = nil
                    BUFF_ClearDebuff(i)
                end
                v.curTime = not(v.pauseCounter) and (curTime + 0.01) or curTime
                target = nil
            end
            trg_buff_id = nil
        else
            DisableTrigger(DEBUFF_TRIGGER)
        end
    end)

    BUFF_Initialize = nil
end

function BUFF_GenerateSeed()
    BUFF_SEED = BUFF_SEED < BUFF_SEED_MAX and BUFF_SEED + 1 or 0
    return BUFF_SEED
end

function BUFF_GetEffect(unit,debuff_name)
    for i, v in pairs(DEBUFFS) do
        if v.target == unit and v.name == debuff_name and v.effect then
            return v.effect
        end
    end
    return nil
end

function BUFF_AddDebuff_Stack(debuff_Data)
    if debuff_Data.name and debuff_Data.target then
        debuff_Data.effect_unique = debuff_Data.effect_unique or DEBUFFS_DATA[debuff_Data.name].effect_unique
        debuff_Data.effect_where = debuff_Data.effect_where or DEBUFFS_DATA[debuff_Data.name].effect_where
        debuff_Data.effect_scale = debuff_Data.effect_scale or DEBUFFS_DATA[debuff_Data.name].effect_scale
        if debuff_Data.effect_mdl or DEBUFFS_DATA[debuff_Data.name].effect_mdl then
            if debuff_Data.effect_unique then
                local eff = BUFF_GetEffect(debuff_Data.target,debuff_Data.name)
                if eff then 
                    debuff_Data.effect = eff
                else
                    debuff_Data.effect = AddSpecialEffectBuff(debuff_Data.effect_where,debuff_Data.target,debuff_Data.effect_mdl or DEBUFFS_DATA[debuff_Data.name].effect_mdl)
                    BlzSetSpecialEffectScale(debuff_Data.effect, debuff_Data.effect_scale or 1.0)
                end
                eff = nil
            else
                debuff_Data.effect = AddSpecialEffectBuff(debuff_Data.effect_where,debuff_Data.target,debuff_Data.effect_mdl or DEBUFFS_DATA[debuff_Data.name].effect_mdl)
                BlzSetSpecialEffectScale(debuff_Data.effect, debuff_Data.effect_scale or 1.0)
            end
        end
        debuff_Data.ICON = debuff_Data.ICON or DEBUFFS_DATA[debuff_Data.name].ICON
        debuff_Data.txtColor = debuff_Data.txtColor or DEBUFFS_DATA[debuff_Data.name].txtColor
        debuff_Data.shieldAbility = debuff_Data.shieldAbility or DEBUFFS_DATA[debuff_Data.name].shieldAbility
        debuff_Data.healabsAbility = debuff_Data.healabsAbility or DEBUFFS_DATA[debuff_Data.name].healabsAbility
        debuff_Data.dotAbility = debuff_Data.dotAbility or DEBUFFS_DATA[debuff_Data.name].dotAbility
        debuff_Data.duration = debuff_Data.duration or DEBUFFS_DATA[debuff_Data.name].duration
        debuff_Data.tick_period = debuff_Data.tick_period or DEBUFFS_DATA[debuff_Data.name].tick_period
        debuff_Data.deathpersistent = debuff_Data.deathpersistent or DEBUFFS_DATA[debuff_Data.name].deathpersistent
        debuff_Data.tickFunc = debuff_Data.tickFunc or DEBUFFS_DATA[debuff_Data.name].tickFunc
        debuff_Data.exitFunc = debuff_Data.exitFunc or DEBUFFS_DATA[debuff_Data.name].exitFunc 
        debuff_Data.startFunc = debuff_Data.startFunc or DEBUFFS_DATA[debuff_Data.name].startFunc 
        debuff_Data.dispellFunc = debuff_Data.dispellFunc or DEBUFFS_DATA[debuff_Data.name].dispellFunc 
        debuff_Data.endFunc = debuff_Data.endFunc or DEBUFFS_DATA[debuff_Data.name].endFunc
        debuff_Data.bindedDebuff = debuff_Data.bindedDebuff or DEBUFFS_DATA[debuff_Data.name].bindedDebuff
        debuff_Data.curTime = debuff_Data.curTime or 0.0
        debuff_Data.movespeed_root = debuff_Data.movespeed_root or DEBUFFS_DATA[debuff_Data.name].movespeed_root
        debuff_Data.movespeed_constant = debuff_Data.movespeed_constant or DEBUFFS_DATA[debuff_Data.name].movespeed_constant
        debuff_Data.movespeed_constantStacks = debuff_Data.movespeed_constantStacks or DEBUFFS_DATA[debuff_Data.name].movespeed_constantStacks
        debuff_Data.movespeed_factor = debuff_Data.movespeed_factor or DEBUFFS_DATA[debuff_Data.name].movespeed_factor
        debuff_Data.movespeed_factorStacks = debuff_Data.movespeed_factorStacks or DEBUFFS_DATA[debuff_Data.name].movespeed_factorStacks
        debuff_Data.attackspeed_factor = debuff_Data.attackspeed_factor or DEBUFFS_DATA[debuff_Data.name].attackspeed_factor
        debuff_Data.attackspeed_factorStacks = debuff_Data.attackspeed_factorStacks or DEBUFFS_DATA[debuff_Data.name].attackspeed_factorStacks
        debuff_Data.armor_constantStacks = debuff_Data.armor_constantStacks or DEBUFFS_DATA[debuff_Data.name].armor_constantStacks
        debuff_Data.armor_constant = debuff_Data.armor_constant or DEBUFFS_DATA[debuff_Data.name].armor_constant
        debuff_Data.healres_constantStacks = debuff_Data.healres_constantStacks or DEBUFFS_DATA[debuff_Data.name].healres_constantStacks
        debuff_Data.healres_constant = debuff_Data.healres_constant or DEBUFFS_DATA[debuff_Data.name].healres_constant
        debuff_Data.debuffPriority = debuff_Data.debuffPriority or DEBUFFS_DATA[debuff_Data.name].debuffPriority
        debuff_Data.debuffPriority = debuff_Data.debuffPriority or DEBUFFS_DEFAULT_PRIORITY_VALUE
        debuff_Data.isDebuff = debuff_Data.isDebuff or DEBUFFS_DATA[debuff_Data.name].isDebuff
        debuff_Data.regen_constant = debuff_Data.regen_constant or DEBUFFS_DATA[debuff_Data.name].regen_constant
        debuff_Data.regen_constantStacks = debuff_Data.regen_constantStacks or DEBUFFS_DATA[debuff_Data.name].regen_constantStacks
        debuff_Data.regen_factor = debuff_Data.regen_factor or DEBUFFS_DATA[debuff_Data.name].regen_factor
        debuff_Data.regen_factorStacks = debuff_Data.regen_factorStacks or DEBUFFS_DATA[debuff_Data.name].regen_factorStacks
        debuff_Data.hp_constant = debuff_Data.hp_constant or DEBUFFS_DATA[debuff_Data.name].hp_constant
        debuff_Data.hp_constantStacks = debuff_Data.hp_constantStacks or DEBUFFS_DATA[debuff_Data.name].hp_constantStacks
        debuff_Data.hp_factor = debuff_Data.hp_factor or DEBUFFS_DATA[debuff_Data.name].hp_factor
        debuff_Data.hp_factorStacks = debuff_Data.hp_factorStacks or DEBUFFS_DATA[debuff_Data.name].hp_factorStacks
        debuff_Data.stat_constant_str = debuff_Data.stat_constant_str or DEBUFFS_DATA[debuff_Data.name].stat_constant_str
        debuff_Data.stat_constantStacks_str = debuff_Data.stat_constantStacks_str or DEBUFFS_DATA[debuff_Data.name].stat_constantStacks_str
        debuff_Data.stat_factor_str = debuff_Data.stat_factor_str or DEBUFFS_DATA[debuff_Data.name].stat_factor_str
        debuff_Data.stat_factorStacks_str = debuff_Data.stat_factorStacks_str or DEBUFFS_DATA[debuff_Data.name].stat_factorStacks_str
        debuff_Data.stat_constant_agi = debuff_Data.stat_constant_agi or DEBUFFS_DATA[debuff_Data.name].stat_constant_agi
        debuff_Data.stat_constantStacks_agi = debuff_Data.stat_constantStacks_agi or DEBUFFS_DATA[debuff_Data.name].stat_constantStacks_agi
        debuff_Data.stat_factor_agi = debuff_Data.stat_factor_agi or DEBUFFS_DATA[debuff_Data.name].stat_factor_agi
        debuff_Data.stat_factorStacks_agi = debuff_Data.stat_factorStacks_agi or DEBUFFS_DATA[debuff_Data.name].stat_factorStacks_agi
        debuff_Data.stat_constant_int = debuff_Data.stat_constant_int or DEBUFFS_DATA[debuff_Data.name].stat_constant_int
        debuff_Data.stat_constantStacks_int = debuff_Data.stat_constantStacks_int or DEBUFFS_DATA[debuff_Data.name].stat_constantStacks_int
        debuff_Data.stat_factor_int = debuff_Data.stat_factor_int or DEBUFFS_DATA[debuff_Data.name].stat_factor_int
        debuff_Data.stat_factorStacks_int = debuff_Data.stat_factorStacks_int or DEBUFFS_DATA[debuff_Data.name].stat_factorStacks_int
        debuff_Data.dmg_constant = debuff_Data.dmg_constant or DEBUFFS_DATA[debuff_Data.name].dmg_constant
        debuff_Data.dmg_constantStacks = debuff_Data.dmg_constantStacks or DEBUFFS_DATA[debuff_Data.name].dmg_constantStacks
        debuff_Data.dmg_factor = debuff_Data.dmg_factor or DEBUFFS_DATA[debuff_Data.name].dmg_factor
        debuff_Data.dmg_factorStacks = debuff_Data.dmg_factorStacks or DEBUFFS_DATA[debuff_Data.name].dmg_factorStacks
        debuff_Data.unitdmg_constant = debuff_Data.unitdmg_constant or DEBUFFS_DATA[debuff_Data.name].unitdmg_constant
        debuff_Data.unitdmg_constantStacks = debuff_Data.unitdmg_constantStacks or DEBUFFS_DATA[debuff_Data.name].unitdmg_constantStacks
        debuff_Data.unitdmg_factor = debuff_Data.unitdmg_factor or DEBUFFS_DATA[debuff_Data.name].unitdmg_factor
        debuff_Data.unitdmg_factorStacks = debuff_Data.unitdmg_factorStacks or DEBUFFS_DATA[debuff_Data.name].unitdmg_factorStacks
        debuff_Data.unitcrit_constant = debuff_Data.unitcrit_constant or DEBUFFS_DATA[debuff_Data.name].unitcrit_constant
        debuff_Data.unitcrit_constantStacks = debuff_Data.unitcrit_constantStacks or DEBUFFS_DATA[debuff_Data.name].unitcrit_constantStacks
        debuff_Data.unitcritMult_constant = debuff_Data.unitcritMult_constant or DEBUFFS_DATA[debuff_Data.name].unitcritMult_constant
        debuff_Data.unitcritMult_constantStacks = debuff_Data.unitcritMult_constantStacks or DEBUFFS_DATA[debuff_Data.name].unitcritMult_constantStacks
        debuff_Data.casttime_factor = debuff_Data.casttime_factor or DEBUFFS_DATA[debuff_Data.name].casttime_factor
        debuff_Data.casttime_constant = debuff_Data.casttime_constant or DEBUFFS_DATA[debuff_Data.name].casttime_constant
        debuff_Data.casttime_factorStacks = debuff_Data.casttime_factorStacks or DEBUFFS_DATA[debuff_Data.name].casttime_factorStacks
        debuff_Data.casttime_constantStacks = debuff_Data.casttime_constantStacks or DEBUFFS_DATA[debuff_Data.name].casttime_constantStacks
        debuff_Data.unitdmgvic_constant = debuff_Data.unitdmgvic_constant or DEBUFFS_DATA[debuff_Data.name].unitdmgvic_constant
        debuff_Data.unitdmgvic_constantStacks = debuff_Data.unitdmgvic_constantStacks or DEBUFFS_DATA[debuff_Data.name].unitdmgvic_constantStacks
        debuff_Data.unitdmgvic_factor = debuff_Data.unitdmgvic_factor or DEBUFFS_DATA[debuff_Data.name].unitdmgvic_factor
        debuff_Data.unitdmgvic_factorStacks = debuff_Data.unitdmgvic_factorStacks or DEBUFFS_DATA[debuff_Data.name].unitdmgvic_factorStacks
        debuff_Data.unitcritvic_constant = debuff_Data.unitcritvic_constant or DEBUFFS_DATA[debuff_Data.name].unitcritvic_constant
        debuff_Data.unitcritvic_constantStacks = debuff_Data.unitcritvic_constantStacks or DEBUFFS_DATA[debuff_Data.name].unitcritvic_constantStacks
        debuff_Data.unitcritMultvic_constant = debuff_Data.unitcritMultvic_constant or DEBUFFS_DATA[debuff_Data.name].unitcritMultvic_constant
        debuff_Data.unitcritMultvic_constantStacks = debuff_Data.unitcritMultvic_constantStacks or DEBUFFS_DATA[debuff_Data.name].unitcritMultvic_constantStacks
        debuff_Data.ABILITIES_DMGVIC = debuff_Data.ABILITIES_DMGVIC or DEBUFFS_DATA[debuff_Data.name].ABILITIES_DMGVIC
        debuff_Data.ABILITIES_DMG = debuff_Data.ABILITIES_DMG or DEBUFFS_DATA[debuff_Data.name].ABILITIES_DMG
        debuff_Data.ABILITIES_CRIT = debuff_Data.ABILITIES_CRIT or DEBUFFS_DATA[debuff_Data.name].ABILITIES_CRIT
        debuff_Data.ABILITIES_CRITMULT = debuff_Data.ABILITIES_CRITMULT or DEBUFFS_DATA[debuff_Data.name].ABILITIES_CRITMULT
        debuff_Data.ABILITIES_CRITVIC = debuff_Data.ABILITIES_CRITVIC or DEBUFFS_DATA[debuff_Data.name].ABILITIES_CRITVIC
        debuff_Data.ABILITIES_CRITMULTVIC = debuff_Data.ABILITIES_CRITMULTVIC or DEBUFFS_DATA[debuff_Data.name].ABILITIES_CRITMULTVIC
        debuff_Data.ABILITIES_CASTTIME = debuff_Data.ABILITIES_CASTTIME or DEBUFFS_DATA[debuff_Data.name].ABILITIES_CASTTIME
        debuff_Data.curTick = debuff_Data.curTick or 0.0
        debuff_Data.notDispellable = debuff_Data.notDispellable or DEBUFFS_DATA[debuff_Data.name].notDispellable
        debuff_Data.pauseCounter = debuff_Data.pauseCounter or false
        debuff_Data.seed = debuff_Data.seed or BUFF_GenerateSeed()
        
        DEBUFFS[debuff_Data.seed] = debuff_Data

        if debuff_Data.startFunc then
            debuff_Data.startFunc()
        end

        if debuff_Data.tickFunc or debuff_Data.exitFunc or debuff_Data.duration then
            T_DEBUFFS[debuff_Data.seed] = debuff_Data
            if not(IsTriggerEnabled(DEBUFF_TRIGGER)) then
                EnableTrigger(DEBUFF_TRIGGER)
            end
        end

        if debuff_Data.movespeed_factor or debuff_Data.movespeed_constant or debuff_Data.movespeed_root then
            MS_Recalculate(debuff_Data.target)
        end
        if debuff_Data.attackspeed_factor then
            AS_Recalculate(debuff_Data.target)
        end
        if debuff_Data.armor_constant then
            AM_Recalculate(debuff_Data.target)
        end
        if debuff_Data.healres_constant then
            HR_Recalculate(debuff_Data.target)
        end
        if debuff_Data.regen_constant or debuff_Data.regen_factor then
            HPREG_Recalculate(debuff_Data.target)
        end
        if debuff_Data.hp_constant or debuff_Data.hp_factor then
            HP_Recalculate(debuff_Data.target)
        end
        if debuff_Data.dmg_constant or debuff_Data.dmg_factor then
            DMG_Recalculate(debuff_Data.target)
        end
        if debuff_Data.stat_constant_str or debuff_Data.stat_factor_str then
            STATS_STR_Recalculate(debuff_Data.target)
        end
        if debuff_Data.stat_constant_int or debuff_Data.stat_factor_int then
            STATS_INT_Recalculate(debuff_Data.target)
        end
        if debuff_Data.stat_constant_agi or debuff_Data.stat_factor_agi then
            STATS_AGI_Recalculate(debuff_Data.target)
        end
        if debuff_Data.unitdmg_constant or debuff_Data.unitdmg_factor then
            UNITDMG_Recalculate(debuff_Data.target)
        end
        if debuff_Data.unitcrit_constant then
            UNITCRIT_Recalculate(debuff_Data.target)
        end
        if debuff_Data.unitcritMult_constant then
            UNITCRITMULT_Recalculate(debuff_Data.target)
        end
        if debuff_Data.casttime_factor or debuff_Data.casttime_constant then
            CASTTIME_Recalculate(debuff_Data.target)
        end
        if debuff_Data.unitdmgvic_constant or debuff_Data.unitdmgvic_factor then
            UNITDMGVIC_Recalculate(debuff_Data.target)
        end
        if debuff_Data.unitcritvic_constant then
            UNITCRITVIC_Recalculate(debuff_Data.target)
        end
        if debuff_Data.unitcritMultvic_constant then
            UNITCRITMULTVIC_Recalculate(debuff_Data.target)
        end
        debuff_Data = nil
    end
end

function BUFF_AddDebuff_Override(debuff_Data)
    if debuff_Data.name and debuff_Data.target then
        if BUFF_UnitHasDebuff(debuff_Data.target,debuff_Data.name) then
            BUFF_UnitClearDebuffAllStacks(debuff_Data.target,debuff_Data.name)
        end
        BUFF_AddDebuff_Stack(debuff_Data)
    end
end