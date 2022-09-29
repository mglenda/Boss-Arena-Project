----------------------------------------------------
-------------DAMAGE SYSTEM SETUP--------------------
----------------------------------------------------

function Get_DmgTypeAutoAttack()
    return DAMAGE_ENGINE_TYPE_AUTOATTACK
end

function DS_dmgTxt_LoadColor(dmg_id)
    cl_id = (ABILITIES_DATA[dmg_id] and ABILITIES_DATA[dmg_id].TAG_color) and ABILITIES_DATA[dmg_id].TAG_color or TAG_clDefault
    dmgTxt.red = TAG_Colors[cl_id].r
    dmgTxt.green = TAG_Colors[cl_id].g
    dmgTxt.blue = TAG_Colors[cl_id].b
end

function DS_absTxt_LoadColor(abs_id)
    cl_id = (ABILITIES_DATA[abs_id] and ABILITIES_DATA[abs_id].TAG_color_abs) and ABILITIES_DATA[abs_id].TAG_color_abs or TAG_clDefaultAbs
    absTxt.red = TAG_Colors[cl_id].r
    absTxt.green = TAG_Colors[cl_id].g
    absTxt.blue = TAG_Colors[cl_id].b
end

function DS_dmgTxt_Refresh()
    dmgTxt.transp = DEFAULT_TEXTTAG_TRANSP
    dmgTxt.fontSize = DEFAULT_TEXTTAG_FONTSIZE
    dmgTxt.veloc = DEFAULT_TEXTTAG_VELOC
    dmgTxt.lifes = DEFAULT_TEXTTAG_LIFES
    dmgTxt.fadep = DEFAULT_TEXTTAG_FADEP
end

function DS_absTxt_Refresh()
    absTxt.transp = ABSDEFAULT_TEXTTAG_TRANSP
    absTxt.fontSize = ABSDEFAULT_TEXTTAG_FONTSIZE
    absTxt.veloc = ABSDEFAULT_TEXTTAG_VELOC
    absTxt.lifes = ABSDEFAULT_TEXTTAG_LIFES
    absTxt.fadep = ABSDEFAULT_TEXTTAG_FADEP
end

function DS_CreateTxt_Tag(msg,x,y,att)
    local red = att.red or DEFAULT_TEXTTAG_RED
    local green = att.green or DEFAULT_TEXTTAG_GREEN
    local blue = att.blue or DEFAULT_TEXTTAG_BLUE
    local transp = att.transp or DEFAULT_TEXTTAG_TRANSP
    local fontSize = att.fontSize or DEFAULT_TEXTTAG_FONTSIZE
    local veloc = att.veloc or DEFAULT_TEXTTAG_VELOC
    local lifes = att.lifes or DEFAULT_TEXTTAG_LIFES
    local fadep = att.fadep or DEFAULT_TEXTTAG_FADEP
    local tag = CreateTextTag()
    SetTextTagText(tag, msg, fontSize)
    SetTextTagColor(tag, red, green, blue, transp)
    SetTextTagPos(tag, x, y, 0)
    SetTextTagVelocity(tag, 0.0, veloc)
    SetTextTagLifespanBJ(tag, lifes)
    SetTextTagFadepointBJ(tag, fadep)
    SetTextTagPermanentBJ(tag, false) 
    tag,fadep,lifes,veloc,fontSize,transp,blue,green,red = nil,nil,nil,nil,nil,nil,nil,nil,nil
end

function DS_AddAbsorb(caster,unit,abs_id,stack_id,value)
    local u_id = GetHandleIdBJ(unit)
    value = DS_RecalculateValue(caster,unit,abs_id,value)
    dmgAbsorb[u_id] = dmgAbsorb[u_id] or {}
    dmgAbsorb[u_id][abs_id] = dmgAbsorb[u_id][abs_id] or {}
    dmgAbsorb[u_id][abs_id][stack_id] = (dmgAbsorb[u_id][abs_id][stack_id] or 0) + value
    if dmgAbsorb[u_id][abs_id][stack_id] <= 0 then
        dmgAbsorb[u_id][abs_id][stack_id] = nil
    end
    if value > 0 then
        local x,y = MATH_MoveXY(GetUnitX(unit),GetUnitY(unit),180.00, 180.00 * bj_DEGTORAD)
        local msg = '+'..round(value,0)..' Absorb'
        DS_absTxt_LoadColor(abs_id)
        DS_CreateTxt_Tag(msg,x,y,absTxt)
        DS_absTxt_Refresh()
        loc,x,y = nil,nil,nil
    end
    u_id = nil
end

function DS_NullifyAbsorb(unit,abs_id,stack_id)
    local u_id = GetHandleIdBJ(unit)
    dmgAbsorb[u_id] = dmgAbsorb[u_id] or {}
    dmgAbsorb[u_id][abs_id] = dmgAbsorb[u_id][abs_id] or {}
    dmgAbsorb[u_id][abs_id][stack_id] = nil
    u_id = nil
end

function DS_SetAbsorb(caster,unit,abs_id,stack_id,value,exact)
    local u_id = GetHandleIdBJ(unit)
    value = exact and value or DS_RecalculateValue(caster,unit,abs_id,value)
    dmgAbsorb[u_id] = dmgAbsorb[u_id] or {}
    dmgAbsorb[u_id][abs_id] = dmgAbsorb[u_id][abs_id] or {}
    local formVal = dmgAbsorb[u_id][abs_id][stack_id] or 0
    dmgAbsorb[u_id][abs_id][stack_id] = value
    if dmgAbsorb[u_id][abs_id][stack_id] <= 0 then
        dmgAbsorb[u_id][abs_id][stack_id] = nil
    end
    if value > 0 and value > formVal then
        local x,y = MATH_MoveXY(GetUnitX(unit),GetUnitY(unit),180.00, 180.00 * bj_DEGTORAD)
        local msg = '+'..round(value-formVal,0)..' Absorb'
        DS_absTxt_LoadColor(abs_id)
        DS_CreateTxt_Tag(msg,x,y,absTxt)
        DS_absTxt_Refresh()
        loc,x,y = nil,nil,nil
    end
end

function DS_RecalculateValue(deal,vic,dmgID,value)
    local vicID = GetHandleIdBJ(vic)
    local dealID = GetHandleIdBJ(deal)
    local dmgFactor = dmgFactor_Data[dealID][dmgID].curFactor or 1.0
    local dmgFacVic = 1.0
    if dmgFactor_Data_Victim[vicID][dmgID] then
        dmgFacVic = dmgFactor_Data_Victim[vicID][dmgID].curFactor or 1.0
    end
    value = value * GetRandomReal(DAMAGE_RND_MULTIPLIER_LB, DAMAGE_RND_MULTIPLIER_UB) * dmgFactor * dmgFacVic
    local critRate = DS_Get_UnitCritRate(deal,vic,dmgID)
    local critMult = DS_Get_UnitCritRateMult(deal,vic,dmgID)
    local rnd = GetRandomInt(1, 100)
    if critRate >= rnd then
        value = value * critMult
    end
    rnd,critMult,critRate,dmgFacVic,dmgFactor,dealID,vicID = nil,nil,nil,nil,nil,nil,nil
    return value
end

function DS_GetAbsorb_Full(unit)
    local u_id = GetHandleIdBJ(unit)
    local val = 0
    if dmgAbsorb[u_id] then
        for i,x in pairs(dmgAbsorb[u_id]) do
            for j,v in pairs(dmgAbsorb[u_id][i]) do
                val = val + v
            end
        end
        return val > 0 and val or nil
    end
    return nil
end

function DS_GetAbsorb_Ability(unit,abs_id)
    local u_id = GetHandleIdBJ(unit)
    local val = 0
    if dmgAbsorb[u_id] then
        if dmgAbsorb[u_id][abs_id] then
            for i,v in pairs(dmgAbsorb[u_id][abs_id]) do
                val = val + v
            end
            return val > 0 and val or nil
        end
    end
    return nil
end

function DS_GetAbsorb_AbilityStack(unit,abs_id,stack_id)
    local u_id = GetHandleIdBJ(unit)
    if dmgAbsorb[u_id] then
        if dmgAbsorb[u_id][abs_id] then
            return dmgAbsorb[u_id][abs_id][stack_id] or nil
        end
    end
    return nil
end

function DS_DamageEngine_Absorbs(unitID,damage)
    local absorbed = false
    if tableLength(dmgAbsorb[unitID]) == 0 then dmgAbsorb[unitID] = nil end
    if dmgAbsorb[unitID] then
        for i,abTbl in pairs(dmgAbsorb[unitID]) do
            if tableLength(dmgAbsorb[unitID][i]) == 0 then dmgAbsorb[unitID][i] = nil end
            if dmgAbsorb[unitID][i] then
                for j,v in pairs(dmgAbsorb[unitID][i]) do
                    if v > damage then
                        dmgAbsorb[unitID][i][j] = v - damage
                        return 0,true
                    elseif v == damage then
                        dmgAbsorb[unitID][i][j] = nil
                        return 0,true
                    else
                        damage = damage - v
                        dmgAbsorb[unitID][i][j] = nil
                    end
                end
            end
        end
    end
    return damage,absorbed
end

function DS_DamageEngine_Resistance(unit,dmg)
    dmg = dmg * ((100 - math.floor(BlzGetUnitArmor(unit))) / 100)
    if dmg < 0 then
        dmg = 0
    elseif dmg > 0 and dmg < 1 then
        dmg = 1
    end
    return dmg
end

function DS_DamageUnit(source,target,damage,att_type,dmg_type,dmg_code,no_crit)
    local sourceID = GetHandleIdBJ(source)
    dmgData[sourceID] = dmgData[sourceID] or {}
    dmgData[sourceID].dmgID = dmg_code
    dmgData[sourceID].noCrit = no_crit
    UnitDamageTargetBJ(source, target, damage, att_type, dmg_type)
end

function DS_Get_UnitCritRate(unit,vic,dmg_code)
    local bonusVic = 0
    if dmgFactor_Data_Victim[GetHandleIdBJ(vic)][dmg_code] then
        bonusVic = dmgFactor_Data_Victim[GetHandleIdBJ(vic)][dmg_code].critBonus or 0
    end
    local bonus = dmgFactor_Data[GetHandleIdBJ(unit)][dmg_code].critBonus or 0
    return Get_UnitCritRate(unit) + bonus + bonusVic
end

function DS_Get_UnitCritRateMult(unit,vic,dmg_code)
    local bonusVic = 0
    if dmgFactor_Data_Victim[GetHandleIdBJ(vic)][dmg_code] then
        bonusVic = dmgFactor_Data_Victim[GetHandleIdBJ(vic)][dmg_code].critMultBonus or 0
    end
    local bonus = dmgFactor_Data[GetHandleIdBJ(unit)][dmg_code].critMultBonus or 0
    return DAMAGE_DEFAULT_CRIT_MULTP + bonus + bonusVic
end

function DS_DamageEngine()
    if not(CHEAT_DETECTED) and not(BlzGetEventAttackType() == ATTACK_TYPE_NORMAL) then
        local vic,deal,attType = BlzGetEventDamageTarget(),GetEventDamageSource(),BlzGetEventAttackType()
        local vicID,dealID = GetHandleIdBJ(vic),GetHandleIdBJ(deal)

        dmgData[dealID] = dmgData[dealID] or {}
        dmgRecord[dealID] = dmgRecord[dealID] or {}
        dmgRecord[vicID] = dmgRecord[vicID] or {}

        local dmgID = dmgData[dealID].dmgID or DAMAGE_ENGINE_TYPE_AUTOATTACK
        DS_dmgTxt_LoadColor(dmgID)

        dmgData[dealID][dmgID] = dmgData[dealID][dmgID] or {}
        dmgRecord[dealID][dmgID] = dmgRecord[dealID][dmgID] or {}
        dmgRecord[vicID][dmgID] = dmgRecord[vicID][dmgID] or {}

        local dmgFacVic = 1.0
        if dmgFactor_Data_Victim[vicID][dmgID] then
            dmgFacVic = dmgFactor_Data_Victim[vicID][dmgID].curFactor or 1.0
        end

        local dmgFactor = dmgFactor_Data[dealID][dmgID].curFactor or 1.0
        local dmg = GetEventDamage() * GetRandomReal(DAMAGE_RND_MULTIPLIER_LB, DAMAGE_RND_MULTIPLIER_UB) * dmgFactor * dmgFacVic

        if attType == ATTACK_TYPE_HERO then
            BlzSetEventDamage(0)
            DS_Autoattack(deal,vic,Get_UnitBaseDamage(deal))
            return
        end

        local critRate = dmgData[dealID][dmgID].critRate or DS_Get_UnitCritRate(deal,vic,dmgID)
        local critMult = dmgData[dealID][dmgID].critRateMult or DS_Get_UnitCritRateMult(deal,vic,dmgID)
        local absorbed,immune = false,UNIT_IsDmgImmune(vic)
        dmgRecord[vicID][dmgID].dmgReceived_WasCrit,dmgRecord[dealID][dmgID].dmgDone_WasCrit = false,false
        
        if not(immune) then
            if critRate >= GetRandomInt(1, 100) and not(dmgData[dealID].noCrit) then
                dmgTxt.fontSize = dmgTxt.fontSize * 1.15
                dmg = dmg * critMult
                dmgRecord[vicID][dmgID].dmgReceived_WasCrit,dmgRecord[dealID][dmgID].dmgDone_WasCrit = true,true
            end
        else
            dmg = 0
        end
        dmg = not(IsInArray(dmgID,ABILITY_DMG_EXPECTIONS)) and DS_DamageEngine_Resistance(vic,dmg) or dmg
        dmgRecord[dealID][dmgID].dmgDone_BefAbsrb,dmgRecord[vicID][dmgID].dmgReceived_BefAbsrb = round(dmg,0),round(dmg,0)

        UNIT_AddDmgDone(deal,dmgID,dmg)

        dmg,absorbed = DS_DamageEngine_Absorbs(vicID,dmg)
        dmgRecord[dealID][dmgID].dmgDone_AftAbsrb,dmgRecord[vicID][dmgID].dmgReceived_AftAbsrb = round(dmg,0),round(dmg,0)
        BlzSetEventDamage(dmg)

        local dmgmsg = immune and 'Immune' or (absorbed and 'Absorbed' or round(dmg,0))
        dmgTxt.fontSize = (absorbed or immune) and 0.028 or dmgTxt.fontSize

        local x,y = GetUnitXY(vic)
        DS_CreateTxt_Tag(dmgmsg,x,y,dmgTxt)
        x,y = nil,nil

        dmgData[dealID][dmgID].critRateMult = nil
        dmgData[dealID][dmgID].critRate = nil
        dmgData[dealID].dmgID = nil
        DS_dmgTxt_Refresh()

        if UNITS_DATA[GetUnitTypeId(vic)].IMMORTAL then
            BlzSetEventDamage(0)
        end

        dmgmsg,immune,absorbed,critMult,critRate,dmg,dmgFacVic,dmgFactor,dmgID,attType,dealID,vicID,deal,vic = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
    else
        BlzSetEventDamage(-80000)
    end
end

function DS_DamageEngine_Initialize()
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DAMAGED)
    TriggerAddAction(trigger, DS_DamageEngine)

    DS_DamageEngine_Initialize = nil
end

function DS_Autoattack(attacker,victim,dmg)
    if GetUnitTypeId(attacker) == HERO_FIREMAGE then
        AB_FireMage_AutoAttack(attacker,victim,dmg)
    elseif GetUnitTypeId(attacker) == HERO_PRIEST then
        
    elseif GetUnitTypeId(attacker) == FourCC('N004') then
        Shaman_AutoAttack(attacker,victim,dmg)
    end
end