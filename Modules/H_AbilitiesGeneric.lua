----------------------------------------------------
-------------ABILITIES SYSTEM SETUP-----------------
----------------------------------------------------

function AB_SetTalentsModifier(abCode,key,value)
    TALENTS_MODIFIERS[abCode] = TALENTS_MODIFIERS[abCode] or {}
    TALENTS_MODIFIERS[abCode][key] = value
end

function AB_GetTalentModifier(abCode,key)
    if TALENTS_MODIFIERS[abCode] then
        return TALENTS_MODIFIERS[abCode][key]
    end
    return nil
end

function AB_SystemInit()
    AB_InitiateHeroAbilities()
    AB_CreateRangeCheck()
    AB_CreateRangeCheck = nil
    AB_InitiateHeroAbilities = nil

    AB_SystemInit = nil
end

function AB_InitiateHeroAbilities()
    for i,ab in pairs(UNITS_DATA[GetUnitTypeId(HERO)].ABILITIES) do
        local order = String2OrderIdBJ(BlzGetAbilityStringLevelField(BlzGetUnitAbility(HERO, ab), ABILITY_SLF_BASE_ORDER_ID_NCL6, 0))
        if order ~= 0 then
            ABILITIES_DATA[ab].order = order
            table.insert(AB_ORDERS,{
                order = order
                ,abCode = ab
            })
        end
        BlzSetAbilityRealLevelField(BlzGetUnitAbility(HERO, ab), ABILITY_RLF_CAST_RANGE, 0, (ABILITIES_DATA[ab] and ABILITIES_DATA[ab].Range or 0))
        order = nil
    end
end

function AB_Order2AbilityId(order)
    for i,v in pairs(AB_ORDERS) do
        if v.order == order then
            return v.abCode
        end
    end
    return nil
end

function AB_CreateRangeCheck()
    TriggerRegisterUnitEvent(AB_RANGECHECK, HERO, EVENT_UNIT_ISSUED_POINT_ORDER)
    TriggerRegisterUnitEvent(AB_RANGECHECK, HERO, EVENT_UNIT_ISSUED_TARGET_ORDER)
    TriggerAddAction(AB_RANGECHECK, function()
        local order = GetIssuedOrderId()
        local range = BlzGetAbilityRealLevelField(BlzGetUnitAbility(HERO, AB_Order2AbilityId(order)), ABILITY_RLF_CAST_RANGE, 0) or nil
        local evtId,rangeAuto = GetTriggerEventId(),ABILITIES_DATA[AB_Order2AbilityId(order)].RangeAuto
        if range then
            local tx,ty
            if evtId == EVENT_UNIT_ISSUED_POINT_ORDER then
                tx,ty = GetOrderPointX(),GetOrderPointY()
            else
                tx,ty = GetWidgetX(GetOrderTarget()),GetWidgetY(GetOrderTarget())
            end
            local cx,cy = GetUnitXY(HERO)
            local dist = MATH_GetDistance(tx,ty,cx,cy)
            if dist > range then
                if evtId == EVENT_UNIT_ISSUED_POINT_ORDER and rangeAuto then
                    tx,ty = MATH_MoveXY(cx,cy,range-1,MATH_GetRadXY(cx,cy,tx,ty))
                    StopUnitImmediate(HERO)
                    IssuePointOrderById(HERO, order, tx, ty)
                else
                    StopUnitImmediate(HERO)
                end
            end
            dist,tx,ty,cx,cy = nil,nil,nil,nil,nil
        end
        range,evtId,rangeAuto,order = nil,nil,nil,nil
    end)
end

function AB_RegisterHero(hero_type)
    for h_type,t in pairs(HERO_DATA) do
        if h_type == hero_type then
            HERO_DATA[h_type].AB_registerFunc()
        else
            HERO_DATA[h_type].AB_memoryCleanFunc()
        end
    end
end

function AB_Bloodlust()
    if IsAbilityAvailable(HERO,ABCODE_LUST) and not(IsUnitDisabled(HERO)) then
        CD_TriggerAbilityCooldown(ABCODE_LUST,HERO)
        BUFF_AddDebuff_Override({
            name = ABILITIES_DATA[ABCODE_LUST].debuff
            ,target = HERO
        })
    end
end