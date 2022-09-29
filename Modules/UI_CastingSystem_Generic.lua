----------------------------------------------------
--------------CASTING SYSTEM SETUP------------------
----------------------------------------------------

function CASTSYS_IsHidden(value)
    for i,v in pairs(CASTSYS_HIDDEN) do
        if v == value then
            return true
        end
    end
    return false
end

function CASTSYS_IsRegistered(unit)
    local u_id = GetHandleIdBJ(unit)
    if CASTSYS_DATA[u_id] and type(CASTSYS_DATA[u_id]) == 'table' then
        return true
    end
    return false
end

function CASTSYS_RegisterUnit(unit,abCode)
    local u_id = GetHandleIdBJ(unit)
    CASTSYS_DATA[u_id] = {
        unit = unit
        ,frame = CASTSYS_Frame_GetFree()
    }
    CASTSYS_Frame_Load(CASTSYS_DATA[u_id].frame,unit,abCode)
    CASTSYS_RefreshFrames()
end

function CASTSYS_FlushUnit(unit)
    local u_id = GetHandleIdBJ(unit)
    CASTSYS_DATA[u_id] = nil
    CASTSYS_RefreshFrames()
end

function CASTSYS_Frame_IsUsed(frame)
    for i,u_tbl in pairs(CASTSYS_DATA) do
        if frame == u_tbl.frame then
            return true
        end
    end
    return false
end

function CASTSYS_Frame_GetFree()
    for i,tbl in pairs(CASTSYS_FRAMES) do
        if not(CASTSYS_Frame_IsUsed(tbl.frame)) then
            return tbl.frame
        end
    end
    return CASTSYS_Frame_Create()
end

function CASTSYS_Frame_Interact()
    local frame = BlzFrameGetParent(BlzGetTriggerFrame())
    for i,v in pairs(CASTSYS_FRAMES) do
        if v.frame == frame then
            TT_MakeUnit_Target(v.unit)
        end
    end
end

function CASTSYS_Frame_Refresh()
    local c = 0
    for i,tbl in pairs(CASTSYS_FRAMES) do
        if CASTSYS_Frame_IsUsed(tbl.frame) or BlzFrameIsVisible(tbl.frame) then
            if not(CASTSYS_Frame_IsUsed(tbl.frame)) then
                if tbl.curTime > 0 then
                    BlzFrameSetTextColor(tbl.castBarText, BlzConvertColor(255, 255, 20, 20))
                    BlzFrameSetText(tbl.castBarText, 'Interrupted')
                else
                    BlzFrameSetTextColor(tbl.castBarText, BlzConvertColor(255, 20, 255, 20))
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

function CASTSYS_Frame_Load(frame,unit,abCode)
    for i,tbl in pairs(CASTSYS_FRAMES) do
        if tbl.frame == frame then
            local theme = (ABILITIES_DATA[abCode] and ABILITIES_DATA[abCode].barTheme) and ABILITIES_DATA[abCode].barTheme or DBM_BAR_clGRAY
            BlzFrameSetTexture(tbl.castBar, theme.texture, 0, true)
            BlzFrameSetTextColor(tbl.castBarText, theme.fontColor)
            BlzFrameSetTextColor(tbl.counterText, theme.fontColor)
            BlzFrameSetValue(tbl.castBar, 0)

            BlzFrameSetTexture(tbl.icon, UNITS_DATA[GetUnitTypeId(unit)].ICON, 0, true)
            BlzFrameSetTexture(tbl.abIcon, ABILITIES_DATA[abCode].ICON, 0, true)
            BlzFrameSetText(tbl.castBarText, ABILITIES_DATA[abCode].Name)
            CASTSYS_FRAMES[i].unit = unit
            CASTSYS_FRAMES[i].abCode = abCode
            CASTSYS_FRAMES[i].castTime = BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, abCode), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(unit, abCode)-1)
            CASTSYS_FRAMES[i].curTime = CASTSYS_FRAMES[i].castTime
            theme = nil
            if not(IsTriggerEnabled(CASTSYS_TRIGGER)) then
                EnableTrigger(CASTSYS_TRIGGER)
            end
        end
    end
end

function CASTSYS_Frame_Create()
    local id = tableLength(CASTSYS_FRAMES)
    local main_frame = BlzCreateSimpleFrame("CastSystem_MainFrame", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), id)

    local frameTbl = {
        frame = main_frame
        ,button = BlzCreateSimpleFrame("CastSystem_Button_Select", main_frame, id)
        ,castBar = BlzCreateSimpleFrame("CastSystem_CastingBar_Bar", main_frame, id)
        ,abIconFrame = BlzCreateSimpleFrame("CastSystem_AbilityIconFrame", main_frame, id)
    }

    frameTbl.abText = BlzCreateSimpleFrame("CastSystem_BarText_Frame", frameTbl.castBar, id)
    frameTbl.numText = BlzCreateSimpleFrame("CastSystem_Number_Frame", frameTbl.castBar, id)

    frameTbl.icon = BlzGetFrameByName('CastSystem_Button_Select_FrameTexture', id)
    frameTbl.abIcon = BlzGetFrameByName('CastSystem_AbilityIconFrameTexture', id)
    frameTbl.castBarText = BlzGetFrameByName('CastSystem_BarText_Text', id)
    frameTbl.counterText = BlzGetFrameByName('CastSystem_Number_Text', id)

    BlzFrameSetPoint(frameTbl.button, FRAMEPOINT_LEFT, frameTbl.frame, FRAMEPOINT_LEFT, 0, 0)
    BlzFrameSetPoint(frameTbl.castBar, FRAMEPOINT_LEFT, frameTbl.button, FRAMEPOINT_RIGHT, 0, 0)
    BlzFrameSetPoint(frameTbl.abIconFrame, FRAMEPOINT_LEFT, frameTbl.castBar, FRAMEPOINT_RIGHT, 0, 0)
    BlzFrameSetPoint(frameTbl.castBarText, FRAMEPOINT_LEFT, frameTbl.castBar, FRAMEPOINT_LEFT, 0.0069, 0)
    BlzFrameSetPoint(frameTbl.counterText, FRAMEPOINT_RIGHT, frameTbl.castBar, FRAMEPOINT_RIGHT, -0.0069, 0)

    BlzTriggerRegisterFrameEvent(CASTSYS_BUTTON_TRIGGER, frameTbl.button, FRAMEEVENT_CONTROL_CLICK)

    table.insert(CASTSYS_FRAMES,frameTbl)
    CASTSYS_DEF_FRAME_HEIGHT = BlzFrameGetHeight(main_frame)

    id,frameTbl = nil,nil
    return main_frame
end

function CASTSYS_RefreshFrames()
    local frames = {}
    for i,tbl in ipairs(CASTSYS_FRAMES) do
        if CASTSYS_Frame_IsUsed(tbl.frame) or BlzFrameIsVisible(tbl.frame) then
            table.insert(frames,tbl.frame)
            if not(CASTSYS_Frame_IsUsed(tbl.frame)) and not(BlzFrameIsFading(tbl.frame)) then
                UI_Frame_FadeOut({
                    frame = tbl.frame
                    ,fadeDuration = 1.0
                    ,exitFunc = CASTSYS_RefreshFrames
                })
            end
        end
    end
    local x,y = -0.13,(0.35 + ((CASTSYS_DEF_FRAME_HEIGHT/2) * (tableLength(frames) -1)))
    for i,frame in ipairs(frames) do
        if CASTSYS_Frame_IsUsed(frame) then
            BlzFrameSetVisible(frame, true)
        end
        BlzFrameSetAbsPoint(frame, FRAMEPOINT_LEFT, x, y)
        y = y - CASTSYS_DEF_FRAME_HEIGHT
    end
end

function CASTSYS_Register()
    local trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trg, Condition(function() return not(CASTSYS_IsHidden(GetTriggerUnit())) and not(CASTSYS_IsHidden(GetSpellAbilityId())) and BlzGetAbilityRealLevelField(BlzGetUnitAbility(GetTriggerUnit(), GetSpellAbilityId()), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(GetTriggerUnit(), GetSpellAbilityId())-1) > 0 end))
    TriggerAddAction(trg, function()
        CASTSYS_RegisterUnit(GetTriggerUnit(),GetSpellAbilityId())
    end)

    local trg_Finish = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg_Finish, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trg_Finish, Condition(function() return CASTSYS_IsRegistered(GetTriggerUnit()) end))
    TriggerAddAction(trg_Finish, function()
        CASTSYS_FlushUnit(GetTriggerUnit())
    end)

    TriggerRegisterTimerEventPeriodic(CASTSYS_TRIGGER, 0.01)
    TriggerAddAction(CASTSYS_TRIGGER, CASTSYS_Frame_Refresh)

    TriggerAddAction(CASTSYS_BUTTON_TRIGGER, CASTSYS_Frame_Interact)

    CASTSYS_HIDDEN = {
        HERO
        ,ABCODE_FLAMEBLINK
        ,ABCODE_SOULOFFIRE
        ,ABCODE_LUST
        ,ABCODE_SUMMONBEASTS
    }
    trg_Finish,trg = nil

    CASTSYS_Register = nil
end