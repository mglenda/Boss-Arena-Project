----------------------------------------------------
------------------DAMAGE METER----------------------
----------------------------------------------------

DMGMETER_FRAME = nil
DMGMETER_FRAME_TEXT = nil
DMGMETER_ENABLED = true
DMGMETER_ABFRAMES_CONTAINER = {}
DMGMETER_FRAME_X = 0.7765
DMGMETER_FRAME_Y_DEFAULT = 0.024
DMGMETER_FRAME_Y = 0.024
DMGMETER_COMBAT_PERIOD = 0
DMGMETER_COMBAT_DURATION = 0
DMGMETER_COMBAT_MAXDURATION = 5
DMGMETER_COMBAT_TIMER = nil
DMGMETER_SUMMARY_INDEX = 1
DMGMETER_SUMMARY_FRAME = nil
DMGMETER_SUMMARY_FRAME_DMG = nil
DMGMETER_SUMMARY_FRAME_DPS = nil

function DamageMeter_Initiate()
    DMGMETER_FRAME = BlzCreateSimpleFrame("DamageMeter_MainFrame",  BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    BlzFrameSetAbsPoint(DMGMETER_FRAME, FRAMEPOINT_BOTTOMLEFT, DMGMETER_FRAME_X, DMGMETER_FRAME_Y)
    DMGMETER_FRAME_TEXT = BlzGetFrameByName("DamageMeter_CaptionFrameText", 0)

    local trigger = CreateTrigger()

    BlzTriggerRegisterPlayerKeyEvent(trigger, PLAYER, OSKEY_D, KEY_PRESSED_NONE, true)
    BlzTriggerRegisterFrameEvent(trigger, BlzGetFrameByName("DamageMeter_Button", 0), FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(trigger, function()
        if DMGMETER_ENABLED then
            DMGMETER_ENABLED = false
            BlzFrameSetTexture(BlzGetFrameByName("DamageMeter_Button_FrameIcon", 0), "war3mapImported\\BTN_DmgMeter_UP.dds", 0, true)
            DamageMeter_HideAbilities()
        else 
            DMGMETER_ENABLED = true
            BlzFrameSetTexture(BlzGetFrameByName("DamageMeter_Button_FrameIcon", 0), "war3mapImported\\BTN_DmgMeter_DOWN.dds", 0, true)
            DamageMeter_ShowAbilities()
        end
    end)

    trigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(trigger, BlzGetFrameByName("DamageMeter_Button_Reset", 0), FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(trigger, function()
        DamageMeter_Reset()
    end)

    BlzFrameSetText(DMGMETER_FRAME_TEXT, "Damage Meter")

    DMGMETER_SUMMARY_FRAME = BlzCreateSimpleFrame("DamageMeter_AbilityFrame", DMGMETER_FRAME, DMGMETER_SUMMARY_INDEX)
    BlzFrameSetPoint(DMGMETER_SUMMARY_FRAME, FRAMEPOINT_TOP, DMGMETER_FRAME, FRAMEPOINT_BOTTOM, 0, 0)

    local frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameTotal", DMGMETER_SUMMARY_FRAME, DMGMETER_SUMMARY_INDEX)
    BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_SUMMARY_FRAME, FRAMEPOINT_LEFT, 0.01, 0)
    BlzFrameSetText(BlzGetFrameByName("DamageMeter_AbilityFrameTotal_Text", DMGMETER_SUMMARY_INDEX), "[Total]")

    frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameDMG", DMGMETER_SUMMARY_FRAME, DMGMETER_SUMMARY_INDEX)
    BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_SUMMARY_FRAME, FRAMEPOINT_LEFT, 0.05, 0)
    frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameDPS", DMGMETER_SUMMARY_FRAME, DMGMETER_SUMMARY_INDEX)
    BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_SUMMARY_FRAME, FRAMEPOINT_LEFT, 0.13, 0)

    DMGMETER_SUMMARY_FRAME_DMG = BlzGetFrameByName("DamageMeter_AbilityFrameDMG_Text", DMGMETER_SUMMARY_INDEX)
    DMGMETER_SUMMARY_FRAME_DPS = BlzGetFrameByName("DamageMeter_AbilityFrameDPS_Text", DMGMETER_SUMMARY_INDEX)

    DMGMETER_COMBAT_TIMER = CreateTrigger()

    TriggerRegisterTimerEventPeriodic(DMGMETER_COMBAT_TIMER, 1)
    
    DisableTrigger(DMGMETER_COMBAT_TIMER)
    TriggerAddAction(DMGMETER_COMBAT_TIMER, function()
        DMGMETER_COMBAT_DURATION = DMGMETER_COMBAT_DURATION + 1
        DMGMETER_COMBAT_PERIOD = DMGMETER_COMBAT_PERIOD + 1
        if DMGMETER_COMBAT_PERIOD == DMGMETER_COMBAT_MAXDURATION then
            DisableTrigger(DMGMETER_COMBAT_TIMER)
            DMGMETER_COMBAT_DURATION = (DMGMETER_COMBAT_DURATION > DMGMETER_COMBAT_MAXDURATION ) and DMGMETER_COMBAT_DURATION - DMGMETER_COMBAT_MAXDURATION or 0
            DMGMETER_COMBAT_PERIOD = 0
            if DMGMETER_ENABLED then
                DamageMeter_Sort()
            else
                DamageMeter_Sort_TotalOnly()
            end
        end
    end)

    trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DAMAGED)
    TriggerAddCondition(trigger, Condition(function() return GetEventDamageSource() == HERO end))
    TriggerAddAction(trigger, function()
        DMGMETER_COMBAT_PERIOD = 0
        if DMGMETER_ENABLED then
            DamageMeter_Sort()
        else
            DamageMeter_Sort_TotalOnly()
        end
        if not(IsTriggerEnabled(DMGMETER_COMBAT_TIMER)) then
            EnableTrigger(DMGMETER_COMBAT_TIMER)
        end
    end)

    DamageMeter_Initiate = nil
end

function DamageMeter_HideAbilities()
    for i,v in pairs(DMGMETER_ABFRAMES_CONTAINER) do
        BlzFrameSetVisible(v.frame, false)
    end
    BlzFrameSetAbsPoint(DMGMETER_FRAME, FRAMEPOINT_BOTTOMLEFT, DMGMETER_FRAME_X, DMGMETER_FRAME_Y)
end

function DamageMeter_ShowAbilities()
    local id = GetHandleIdBJ(HERO)
    for i,v in pairs(DMGMETER_ABFRAMES_CONTAINER) do
        if dmgFactor_Data[id][i].dmgDone_Meter > 0 then
            BlzFrameSetVisible(v.frame, true)
        end
    end
    DamageMeter_Sort()
end

function DamageMeter_Reset()
    local id = GetHandleIdBJ(HERO)
    local type_id = GetUnitTypeId(HERO)
    for i, v in pairs(UNITS_DATA[type_id].ABILITIES) do
        dmgFactor_Data[id][v].dmgDone_Meter = 0
    end
    BlzFrameSetText(DMGMETER_SUMMARY_FRAME_DPS, 'DPS: 0')
    BlzFrameSetText(DMGMETER_SUMMARY_FRAME_DMG, 'DMG: 0')
    DMGMETER_COMBAT_DURATION = 0
    DamageMeter_HideAbilities()
end

function DamageMeter_AddAbility(abCode)
    if not(DMGMETER_ABFRAMES_CONTAINER[abCode]) then
        DMGMETER_ABFRAMES_CONTAINER[abCode] = {}
        local frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrame", DMGMETER_FRAME, abCode)
        DMGMETER_ABFRAMES_CONTAINER[abCode].frame = frame
        frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameIcon", frame, abCode)
        DMGMETER_ABFRAMES_CONTAINER[abCode].icon = frame
        BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_ABFRAMES_CONTAINER[abCode].frame, FRAMEPOINT_LEFT, 0.02, 0)
        frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameOrder", DMGMETER_ABFRAMES_CONTAINER[abCode].frame, abCode)
        DMGMETER_ABFRAMES_CONTAINER[abCode].order = frame
        BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_ABFRAMES_CONTAINER[abCode].frame, FRAMEPOINT_LEFT, 0, 0)
        frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameDMG", DMGMETER_ABFRAMES_CONTAINER[abCode].frame, abCode)
        DMGMETER_ABFRAMES_CONTAINER[abCode].dmg = frame
        BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_ABFRAMES_CONTAINER[abCode].frame, FRAMEPOINT_LEFT, 0.05, 0)
        frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameDPS", DMGMETER_ABFRAMES_CONTAINER[abCode].frame, abCode)
        DMGMETER_ABFRAMES_CONTAINER[abCode].dps = frame
        BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_ABFRAMES_CONTAINER[abCode].frame, FRAMEPOINT_LEFT, 0.13, 0)
        BlzFrameSetTexture(BlzGetFrameByName('DamageMeter_AbilityFrameIconTexture', abCode), ABILITIES_DATA[abCode].ICON, 0, true)
    else
        BlzFrameSetVisible(DMGMETER_ABFRAMES_CONTAINER[abCode].frame, true)
    end
end

function DamageMeter_Sort_TotalOnly()
    local id = GetHandleIdBJ(HERO)
    local type_id = GetUnitTypeId(HERO)
    local dmg_total = 0
    for i, v in pairs(UNITS_DATA[type_id].ABILITIES) do
        if ABILITIES_DATA[v] and ABILITIES_DATA[v].DMG_METER and dmgFactor_Data[id][v].dmgDone_Meter > 0 then
            dmg_total = dmg_total + dmgFactor_Data[id][v].dmgDone_Meter
        end
    end
    BlzFrameSetText(DMGMETER_SUMMARY_FRAME_DPS, 'DPS: ' .. math.floor(dmg_total/DMGMETER_COMBAT_DURATION == 1 and 0 or dmg_total/DMGMETER_COMBAT_DURATION))
    BlzFrameSetText(DMGMETER_SUMMARY_FRAME_DMG, 'DMG: ' .. math.floor(dmg_total))
end

function DamageMeter_Sort()
    local id = GetHandleIdBJ(HERO)
    local type_id = GetUnitTypeId(HERO)
    local dmg_Tbl = {}
    local tbl = nil
    for i, v in pairs(UNITS_DATA[type_id].ABILITIES) do
        if ABILITIES_DATA[v] and ABILITIES_DATA[v].DMG_METER and dmgFactor_Data[id][v].dmgDone_Meter > 0 then
            tbl = {
                abCode = v
                ,dmgDone = dmgFactor_Data[id][v].dmgDone_Meter
            }
            table.insert(dmg_Tbl,tbl)
            tbl = nil
            DamageMeter_AddAbility(v)
            DMGMETER_FRAME_Y = DMGMETER_FRAME_Y + 0.024
        end
    end
    table.sort (dmg_Tbl, function (k1, k2) return k1.dmgDone > k2.dmgDone end )

    BlzFrameSetAbsPoint(DMGMETER_FRAME, FRAMEPOINT_BOTTOMLEFT, DMGMETER_FRAME_X, DMGMETER_FRAME_Y)
    local lastFrame = DMGMETER_SUMMARY_FRAME
    local dmg_total = 0
    for i,v in pairs(dmg_Tbl) do
        BlzFrameSetPoint(DMGMETER_ABFRAMES_CONTAINER[v.abCode].frame, FRAMEPOINT_TOP, lastFrame, FRAMEPOINT_BOTTOM, 0, 0)
        lastFrame = DMGMETER_ABFRAMES_CONTAINER[v.abCode].frame
        BlzFrameSetText(BlzGetFrameByName('DamageMeter_AbilityFrameDPS_Text', v.abCode), 'DPS: ' .. math.floor(v.dmgDone/DMGMETER_COMBAT_DURATION))
        BlzFrameSetText(BlzGetFrameByName('DamageMeter_AbilityFrameDMG_Text', v.abCode), 'DMG: ' .. math.floor(v.dmgDone))
        BlzFrameSetText(BlzGetFrameByName('DamageMeter_AbilityFrameOrder_Text', v.abCode), i)
        dmg_total = dmg_total + v.dmgDone
    end
    BlzFrameSetText(DMGMETER_SUMMARY_FRAME_DPS, 'DPS: ' .. math.floor(dmg_total/DMGMETER_COMBAT_DURATION == 1 and 0 or dmg_total/DMGMETER_COMBAT_DURATION))
    BlzFrameSetText(DMGMETER_SUMMARY_FRAME_DMG, 'DMG: ' .. math.floor(dmg_total))
    DMGMETER_FRAME_Y = DMGMETER_FRAME_Y_DEFAULT
    dmg_Tbl,type_id,id = nil,nil,nil
end