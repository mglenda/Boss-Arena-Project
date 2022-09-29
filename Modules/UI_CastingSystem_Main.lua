----------------------------------------------------
------------CASTING SYSTEM SETUP MAIN---------------
----------------------------------------------------

function CASTMAIN_CreateHeroBar()
    local id = tableLength(CASTMAIN_DATA)
    local data = {}
    local main_frame = BlzCreateSimpleFrame("CastingBar_Texture_Frame", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), id)
    BlzFrameSetAbsPoint(main_frame, FRAMEPOINT_BOTTOM, 0.4, UI_CASTBAR_Y)

    data.frame = main_frame

    frame = BlzCreateSimpleFrame("CastingBar_AbilityIcon_Frame", main_frame, id)
    BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, main_frame, FRAMEPOINT_LEFT, 0, 0)

    data.abIcon = BlzGetFrameByName('CastingBar_AbilityIcon_Texture', id)

    local frame = BlzCreateSimpleFrame("CastingBar_Bar", main_frame, id)
    BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, data.abIcon, FRAMEPOINT_RIGHT, 0, 0)

    data.castBar = frame

    frame = BlzCreateSimpleFrame("CastingBar_BarText_Frame", data.castBar, id)
    BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, data.castBar, FRAMEPOINT_LEFT, 0, 0)

    data.castBarText = BlzGetFrameByName('CastingBar_BarText_Text', id)

    frame = BlzCreateSimpleFrame("CastingBar_Number_Frame", data.castBar, id)
    BlzFrameSetPoint(frame, FRAMEPOINT_RIGHT, data.castBar, FRAMEPOINT_RIGHT, 0, 0)

    data.counterText = BlzGetFrameByName('CastingBar_Number_Text', id)

    BlzFrameSetVisible(main_frame, false)

    CASTMAIN_Register(HERO,data)
end

function CASTMAIN_Register(unit,data)
    local u_id = GetHandleIdBJ(unit)
    CASTMAIN_DATA[u_id] = data
end

function CASTMAIN_Clear(u_id)
    if CASTMAIN_DATA[u_id] then
        BlzDestroyFrame(CASTMAIN_DATA[u_id].frame)
        CASTMAIN_DATA[u_id] = nil
    end
end

function CASTMAIN_GetFrame(unit)
    local u_id = GetHandleIdBJ(unit)
    if CASTMAIN_DATA[u_id] then
        return CASTMAIN_DATA[u_id].frame
    end
    return nil
end

function CASTMAIN_IsRegistered(unit)
    local u_id = GetHandleIdBJ(unit)
    if CASTMAIN_DATA[u_id] and type(CASTMAIN_DATA[u_id]) == 'table' then
        return true
    end
    return false
end

function CASTMAIN_StartCasting(unit,abCode)
    local u_id = GetHandleIdBJ(unit)
    local castTime = BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, abCode), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(unit, abCode)-1)
    local theme = (ABILITIES_DATA[abCode] and ABILITIES_DATA[abCode].barTheme) and ABILITIES_DATA[abCode].barTheme or DBM_BAR_clGRAY
    BlzFrameSetTexture(CASTMAIN_DATA[u_id].abIcon, ABILITIES_DATA[abCode].ICON, 0, true)
    BlzFrameSetTexture(CASTMAIN_DATA[u_id].castBar, theme.texture, 0, true)
    BlzFrameSetTextColor(CASTMAIN_DATA[u_id].castBarText, theme.fontColor)
    BlzFrameSetTextColor(CASTMAIN_DATA[u_id].counterText, theme.fontColor)
    BlzFrameSetText(CASTMAIN_DATA[u_id].castBarText, ABILITIES_DATA[abCode].Name)
    CASTMAIN_DATA[u_id].castTime = castTime
    CASTMAIN_DATA[u_id].curTime = castTime 
    CASTMAIN_DATA[u_id].IsCasting = true
    BlzFrameSetVisible(CASTMAIN_DATA[u_id].frame, true)
    if not(IsTriggerEnabled(CASTMAIN_TRIGGER)) then
        EnableTrigger(CASTMAIN_TRIGGER)
    end
    u_id,castTime,theme= nil,nil,nil
end

function CASTMAIN_StopCasting(unit)
    local u_id = GetHandleIdBJ(unit)
    CASTMAIN_DATA[u_id].IsCasting = false
    UI_Frame_FadeOut({
        frame = CASTMAIN_DATA[u_id].frame
        ,fadeDuration = 1.0
    })
end

function CASTMAIN_Frame_Refresh()
    local c = 0
    for i,tbl in pairs(CASTMAIN_DATA) do
        if BlzFrameIsVisible(tbl.frame) then
            if not(tbl.IsCasting) then
                if tbl.curTime > 0 then
                    BlzFrameSetTextColor(tbl.castBarText, BlzConvertColor(255, 255, 20, 20))
                    BlzFrameSetTextColor(tbl.counterText, BlzConvertColor(255, 255, 20, 20))
                    BlzFrameSetText(tbl.castBarText, 'Interrupted')
                else
                    BlzFrameSetTextColor(tbl.castBarText, BlzConvertColor(255, 20, 255, 20))
                    BlzFrameSetTextColor(tbl.counterText, BlzConvertColor(255, 20, 255, 20))
                    BlzFrameSetValue(tbl.castBar, 100)
                    BlzFrameSetText(tbl.castBarText, 'Completed')
                    BlzFrameSetText(tbl.counterText, '0.0')
                end
            else
                if tbl.castTime < 9000 then
                    if tbl.curTime >= 0 then
                        BlzFrameSetText(tbl.counterText, strRound(tbl.curTime,1))
                        BlzFrameSetValue(tbl.castBar, 100-((tbl.curTime/tbl.castTime)*100)+2)
                    end
                    tbl.curTime = tbl.curTime - 0.01
                else
                    BlzFrameSetText(tbl.counterText, 'CH')
                    BlzFrameSetValue(tbl.castBar, 100)
                end
                c = c + 1
            end
        end
    end
    if c == 0 then
        DisableTrigger(GetTriggeringTrigger())
    end
end

function CASTMAIN_Initialize()
    local trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trg, Condition(function() return CASTMAIN_IsRegistered(GetTriggerUnit()) and BlzGetAbilityRealLevelField(BlzGetUnitAbility(GetTriggerUnit(), GetSpellAbilityId()), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(GetTriggerUnit(), GetSpellAbilityId())-1) > 0 end))
    TriggerAddAction(trg, function()
        if GetTriggerUnit() == HERO then
            UI_PLAYER_CASTING = GetSpellAbilityId()
            UI_SetAbilityIconState_Casting(UI_PLAYER_CASTING)
        end
        CASTMAIN_StartCasting(GetTriggerUnit(),GetSpellAbilityId())
    end)

    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trg, Condition(function() return CASTMAIN_IsRegistered(GetTriggerUnit()) end))
    TriggerAddAction(trg, function()
        if GetTriggerUnit() == HERO then
            UI_RefreshAbilityIconState(UI_PLAYER_CASTING)
            UI_PLAYER_CASTING = nil
        end
        CASTMAIN_StopCasting(GetTriggerUnit())
    end)

    TriggerRegisterTimerEventPeriodic(CASTMAIN_TRIGGER, 0.01)
    TriggerAddAction(CASTMAIN_TRIGGER, CASTMAIN_Frame_Refresh)

    CASTMAIN_CreateHeroBar()
    trg = nil

    CASTMAIN_Initialize = nil
end