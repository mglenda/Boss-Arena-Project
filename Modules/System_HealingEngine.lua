----------------------------------------------------
-------------HEALING SYSTEM SETUP-------------------
----------------------------------------------------

function HS_healTxt_Refresh()
    healTxt.red = HEAL_DEFAULT_TEXTTAG_RED
    healTxt.green = HEAL_DEFAULT_TEXTTAG_GREEN
    healTxt.blue = HEAL_DEFAULT_TEXTTAG_BLUE
    healTxt.transp = HEAL_DEFAULT_TEXTTAG_TRANSP
    healTxt.fontSize = HEAL_DEFAULT_TEXTTAG_FONTSIZE
    healTxt.veloc = HEAL_DEFAULT_TEXTTAG_VELOC
    healTxt.lifes = HEAL_DEFAULT_TEXTTAG_LIFES
    healTxt.fadep = HEAL_DEFAULT_TEXTTAG_FADEP
end

function HS_healabsTxt_Refresh()
    healabsTxt.red = HEALABS_DEFAULT_TEXTTAG_RED
    healabsTxt.green = HEALABS_DEFAULT_TEXTTAG_GREEN
    healabsTxt.blue = HEALABS_DEFAULT_TEXTTAG_BLUE
    healabsTxt.transp = HEALABS_DEFAULT_TEXTTAG_TRANSP
    healabsTxt.fontSize = HEALABS_DEFAULT_TEXTTAG_FONTSIZE
    healabsTxt.veloc = HEALABS_DEFAULT_TEXTTAG_VELOC
    healabsTxt.lifes = HEALABS_DEFAULT_TEXTTAG_LIFES
    healabsTxt.fadep = HEALABS_DEFAULT_TEXTTAG_FADEP
end

function HS_CreateTxt_Tag(msg,x,y,att)
    local red = att.red or HEAL_DEFAULT_TEXTTAG_RED
    local green = att.green or HEAL_DEFAULT_TEXTTAG_GREEN
    local blue = att.blue or HEAL_DEFAULT_TEXTTAG_BLUE
    local transp = att.transp or HEAL_DEFAULT_TEXTTAG_TRANSP
    local fontSize = att.fontSize or HEAL_DEFAULT_TEXTTAG_FONTSIZE
    local veloc = att.veloc or HEAL_DEFAULT_TEXTTAG_VELOC
    local lifes = att.lifes or HEAL_DEFAULT_TEXTTAG_LIFES
    local fadep = att.fadep or HEAL_DEFAULT_TEXTTAG_FADEP
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

function HS_NullifyAbsorb(unit,abs_id,stack_id)
    local u_id = GetHandleIdBJ(unit)
    healAbsorb[u_id] = healAbsorb[u_id] or {}
    healAbsorb[u_id][abs_id] = healAbsorb[u_id][abs_id] or {}
    healAbsorb[u_id][abs_id][stack_id] = nil
end

function HS_AddAbsorb(unit,abs_id,stack_id,value)
    local u_id = GetHandleIdBJ(unit)
    healAbsorb[u_id] = healAbsorb[u_id] or {}
    healAbsorb[u_id][abs_id] = healAbsorb[u_id][abs_id] or {}
    healAbsorb[u_id][abs_id][stack_id] = (healAbsorb[u_id][abs_id][stack_id] or 0) + value
    if healAbsorb[u_id][abs_id][stack_id] <= 0 then
        healAbsorb[u_id][abs_id][stack_id] = nil
    end
    if value > 0 then
        local x,y = MATH_MoveXY(GetUnitX(unit),GetUnitY(unit),180.00, 180.00 * bj_DEGTORAD)
        msg = '+'..round(value,0)..' HealAbsorb'
        HS_CreateTxt_Tag(msg,x,y,healabsTxt)
        HS_healabsTxt_Refresh()
        x,y = nil,nil
    end
end

function HS_SetAbsorb(unit,abs_id,stack_id,value)
    local u_id = GetHandleIdBJ(unit)
    healAbsorb[u_id] = healAbsorb[u_id] or {}
    healAbsorb[u_id][abs_id] = healAbsorb[u_id][abs_id] or {}
    local formVal = healAbsorb[u_id][abs_id][stack_id] or 0
    healAbsorb[u_id][abs_id][stack_id] = value
    if healAbsorb[u_id][abs_id][stack_id] <= 0 then
        healAbsorb[u_id][abs_id][stack_id] = nil
    end
    if value > 0 and value > formVal then
        local x,y = MATH_MoveXY(GetUnitX(unit),GetUnitY(unit),180.00, 180.00 * bj_DEGTORAD)
        local msg = '+'..round(value-formVal,0)..' HealAbsorb'
        HS_CreateTxt_Tag(msg,x,y,healabsTxt)
        HS_healabsTxt_Refresh()
        x,y = nil,nil
    end
end

function HS_GetAbsorb_Full(unit)
    local u_id = GetHandleIdBJ(unit)
    local val = 0
    if healAbsorb[u_id] then
        for i,x in pairs(healAbsorb[u_id]) do
            for j,v in pairs(healAbsorb[u_id][i]) do
                val = val + v
            end
        end
        return val > 0 and val or nil
    end
    return nil
end

function HS_GetAbsorb_Ability(unit,abs_id)
    local u_id = GetHandleIdBJ(unit)
    local val = 0
    if healAbsorb[u_id] then
        if healAbsorb[u_id][abs_id] then
            for i,v in pairs(healAbsorb[u_id][abs_id]) do
                val = val + v
            end
            return val > 0 and val or nil
        end
    end
    return nil
end

function HS_GetAbsorb_AbilityStack(unit,abs_id,stack_id)
    local u_id = GetHandleIdBJ(unit)
    if healAbsorb[u_id] then
        if healAbsorb[u_id][abs_id] then
            return healAbsorb[u_id][abs_id][stack_id]
        end
    end
    return nil
end

function HS_HealingEngine_Absorbs(unitID,heal)
    local absorbed = false
    if tableLength(healAbsorb[unitID]) == 0 then healAbsorb[unitID] = nil end
    if healAbsorb[unitID] then
        for i,abTbl in pairs(healAbsorb[unitID]) do
            if tableLength(healAbsorb[unitID][i]) == 0 then healAbsorb[unitID][i] = nil end
            if healAbsorb[unitID][i] then
                for j,v in pairs(healAbsorb[unitID][i]) do
                    if v > heal then
                        healAbsorb[unitID][i][j] = v - heal
                        return 0,true
                    elseif v == heal then
                        healAbsorb[unitID][i][j] = nil
                        return 0,true
                    else
                        heal = heal - v
                        healAbsorb[unitID][i][j] = nil
                    end
                end
            end
        end
    end
    return heal,absorbed
end

function HS_Get_UnitCritRateMult(unit,vic,dmg_code)
    local bonusVic = 0
    if dmgFactor_Data_Victim[GetHandleIdBJ(vic)][dmg_code] then
        bonusVic = dmgFactor_Data_Victim[GetHandleIdBJ(vic)][dmg_code].critMultBonus or 0
    end
    local bonus = dmgFactor_Data[GetHandleIdBJ(unit)][dmg_code].critMultBonus or 0
    return HEAL_DEFAULT_CRIT_MULTP + bonus + bonusVic
end

function HS_HealingEngine_Resistance(unit,heal)
    heal = heal * ((100 - math.floor(GetUnitUserData(unit))) / 100)
    if heal < 0 then
        heal = 0
    elseif heal > 0 and heal < 1 then
        heal = 1
    end
    return heal
end

function HS_HealUnit(healer,target,value,healID,noCrit)
    local tarID = GetHandleIdBJ(target)
    local healerID = GetHandleIdBJ(healer)
    healData[healerID] = healData[healerID] or {}
    local healFactor = dmgFactor_Data[healerID][healID].curFactor or 1.0
    local healFacVic = 1.0
    if dmgFactor_Data_Victim[tarID][healID] then
        healFacVic = dmgFactor_Data_Victim[tarID][healID].curFactor or 1.0
    end
    healRecord[healerID] = healRecord[healerID] or {}
    healRecord[tarID] = healRecord[tarID] or {}
    healData[healerID][healID] = healData[healerID][healID] or {}
    healRecord[healerID][healID] = healRecord[healerID][healID] or {}
    healRecord[tarID][healID] = healRecord[tarID][healID] or {}
    local heal = value * GetRandomReal(HEAL_RND_MULTIPLIER_LB, HEAL_RND_MULTIPLIER_UB) * healFactor * healFacVic
    local critRate = DS_Get_UnitCritRate(healer,target,healID)
    critRate = healData[healerID][healID].critRate or critRate
    local critMult = HS_Get_UnitCritRateMult(healer,target,healID)
    critMult = healData[healerID][healID].critRateMult or critMult
    local absorbed = false
    healRecord[tarID][healID].healReceived_WasCrit = false
    healRecord[healerID][healID].healDone_WasCrit = false
    local rnd = GetRandomInt(1, 100)
    if critRate >= rnd and not(noCrit) then
        healTxt.fontSize = healTxt.fontSize * 1.15
        heal = heal * critMult
        healRecord[tarID][healID].healReceived_WasCrit = true
        healRecord[healerID][healID].healDone_WasCrit = true
    end
    heal = HS_HealingEngine_Resistance(target,heal)
    healRecord[healerID][healID].healDone_BefAbsrb = round(heal,0)
    healRecord[tarID][healID].healReceived_BefAbsrb = round(heal,0)
    UNIT_AddHealingDone(healer,healID,heal)
    heal,absorbed = HS_HealingEngine_Absorbs(tarID,heal)
    healRecord[healerID][healID].healDone_AftAbsrb = round(heal,0)
    healRecord[tarID][healID].healReceived_AftAbsrb = round(heal,0)
    healRecord[tarID][healID].overheal = (GetUnitStateSwap(UNIT_STATE_LIFE, target) + heal) - BlzGetUnitMaxHP(target)
    SetUnitLifeBJ(target, GetUnitStateSwap(UNIT_STATE_LIFE, target) + heal)
    local healmsg = absorbed and 'Absorbed' or '+'..round(heal,0)
    healTxt.fontSize = (absorbed) and 0.024 or healTxt.fontSize
    if tostring(healmsg) ~= '0' then
        local x,y = GetUnitXY(target)
        HS_CreateTxt_Tag(healmsg,x,y,healTxt)
        x,y = nil,nil
    end
    healData[healerID][healID].critRateMult = nil
    healData[healerID][healID].critRate = nil
    healData[healerID].healID = nil
    HS_healTxt_Refresh()
    tarID,healerID,healFactor,healFacVic,heal,critRate,critMult,absorbed,rnd,healmsg = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
end