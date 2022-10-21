----------------------------------------------------
-------------TARGET SYSTEM SETUP--------------------
----------------------------------------------------

PLAYER_MOUSELOC_X,PLAYER_MOUSELOC_Y = nil,nil
PLAYER_MOUSELOC_TRIGGER = CreateTrigger()
PLAYER_QUICKCAST_ENABLED = true
TARGET_ABILITY = FourCC('TARG')
TARGET_TRIGGER_ATTACK = CreateTrigger()
TARGET_TRIGGER_SELECT = CreateTrigger()

function TT_LoadTargetingSystem()
    TT_Register_SelectionEvent()
    TT_Deselections()
    TT_Register_TargetClearing()
    TT_RegisterAttackOrder()
    TT_RegisterAttackEvent()
    TT_RegisterMouseLocation()
    TT_Register_SelectionEvent = nil
    TT_Deselections = nil
    TT_Register_TargetClearing = nil
    TT_RegisterAttackOrder = nil
    TT_RegisterAttackEvent = nil

    TT_LoadTargetingSystem = nil
end

function TT_DisableTargeting()
    DisableTrigger(TARGET_TRIGGER_SELECT)
    DisableTrigger(TARGET_TRIGGER_ATTACK)
end

function TT_EnableTargeting()
    EnableTrigger(TARGET_TRIGGER_SELECT)
    EnableTrigger(TARGET_TRIGGER_ATTACK)
end

function TT_RegisterAttackOrder()
    TriggerRegisterAnyUnitEventBJ(TARGET_TRIGGER_ATTACK, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
    TriggerAddCondition(TARGET_TRIGGER_ATTACK,Condition(function() return ((GetIssuedOrderIdBJ() == String2OrderIdBJ("attack") or GetIssuedOrderIdBJ() == String2OrderIdBJ("smart")) and GetOrderedUnit() == HERO) end))
    TriggerAddAction(TARGET_TRIGGER_ATTACK, function()
        TT_MakeUnit_Target(GetOrderTargetUnit())
    end)
end

function TT_RegisterMouseLocation()
    TriggerRegisterPlayerMouseEventBJ(PLAYER_MOUSELOC_TRIGGER, PLAYER, bj_MOUSEEVENTTYPE_MOVE)
    TriggerAddAction(PLAYER_MOUSELOC_TRIGGER, function()
        PLAYER_MOUSELOC_X,PLAYER_MOUSELOC_Y = BlzGetTriggerPlayerMouseX(),BlzGetTriggerPlayerMouseY()
    end)
end

function TT_EnableQuickCast()
    EnableTrigger(PLAYER_MOUSELOC_TRIGGER)
    PLAYER_QUICKCAST_ENABLED = true
end

function TT_DisableQuickCast()
    DisableTrigger(PLAYER_MOUSELOC_TRIGGER)
    PLAYER_MOUSELOC_X,PLAYER_MOUSELOC_Y = nil,nil
    PLAYER_QUICKCAST_ENABLED = false
end

function TT_RegisterAttackEvent()
    --[[local trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_ATTACKED)
    TriggerAddCondition(trg,Condition(function() return (GetAttacker() == HERO and GetAttackedUnitBJ() ~= HERO and GetAttackedUnitBJ() ~= TARGET) end))
    TriggerAddAction(trg, function()
        TT_MakeUnit_Target(GetAttackedUnitBJ())
    end)]]--
end

function TT_HighlightUnit(unit)
    SetUnitVertexColorBJ(unit, 100, 100, 100, 0)
end

function TT_HighlightUnit_Cancel(unit)
    SetUnitVertexColorBJ(unit, 50.00, 50.00, 50.00, 0)
end

function TT_Deselections()
    local trg = CreateTrigger()
    TriggerRegisterPlayerSelectionEventBJ(trg, PLAYER, false)
    TriggerAddAction(trg, function()
        if GetTriggerUnit() == HERO then
            TT_SelectHero()
        end
    end)
end

function TT_MakeUnit_Target(unit)
    if TARGET then
        TT_HighlightUnit_Cancel(TARGET)
        --UnitRemoveAbilityBJ(TARGET_ABILITY, TARGET)
    end
    TARGET = unit
    TT_HighlightUnit(TARGET)
    --UnitAddAbilityBJ(TARGET_ABILITY, TARGET)
    UI_RefreshIcons(TARGET)
end

function TT_ClearTarget()
    BlzFrameSetVisible(TARGET_DETAILS_DATA.mainFrame, false)
    TT_HighlightUnit_Cancel(TARGET)
    --UnitRemoveAbilityBJ(TARGET_ABILITY, TARGET)
    TARGET = nil
end

function TT_Register_SelectionEvent()
    TriggerRegisterPlayerSelectionEventBJ(TARGET_TRIGGER_SELECT, PLAYER, true)
    TriggerAddAction(TARGET_TRIGGER_SELECT, function()
        if GetTriggerUnit() ~= HERO then
            TT_MakeUnit_Target(GetTriggerUnit())
        end
    end)
end

function TT_SelectHero()
    SelectUnitForPlayerSingle(HERO, PLAYER)
    UI_RefreshIcons(HERO)
end

function TT_Register_TargetClearing()
    local trg = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trg,PLAYER,OSKEY_ESCAPE,KEY_PRESSED_NONE,true)
    TriggerAddAction(trg, function()
        TT_ClearTarget()
        UI_HideAllMenus()
    end)

    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_DEATH)
    TriggerAddAction(trg, function()
        if GetDyingUnit() == TARGET then
            TT_ClearTarget()
        end
    end)

    trg = nil
end