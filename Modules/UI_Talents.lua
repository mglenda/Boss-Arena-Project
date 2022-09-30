----------------------------------------------------
-------------TALENTS SYSTEM SETUP-------------------
----------------------------------------------------

function TALENTS_UI_Initialize()
    local trigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(trigger, BlzGetFrameByName("Hero_Portrait", 0), FRAMEEVENT_CONTROL_CLICK)
    BlzTriggerRegisterPlayerKeyEvent(trigger, PLAYER, TALENTS_ABILITY_KEY, KEY_PRESSED_NONE, true)
    TriggerAddAction(trigger, function()
        if BlzFrameIsVisible(TALENTS_FRAME_MAIN) then
            TALENTS_UI_Hide()
        else
            TALENTS_UI_Show()
        end
        BlzFrameSetEnable(BlzGetTriggerFrame(), false)
        BlzFrameSetEnable(BlzGetTriggerFrame(), true)
    end)

    TriggerAddAction(TALENTS_FRAME_TRIGGER_ENTER, function()
        local Tree_ID,Talent_ID = TALENTS_UI_IdentifyFrame(BlzGetTriggerFrame())
        TALENTS_UI_Highlight(Tree_ID,Talent_ID)
    end)
    TriggerAddAction(TALENTS_FRAME_TRIGGER_LEAVE, function()
        local Tree_ID,Talent_ID = TALENTS_UI_IdentifyFrame(BlzGetTriggerFrame())
        TALENTS_UI_Unhighlight(Tree_ID,Talent_ID)
    end)
    TriggerAddAction(TALENTS_FRAME_TRIGGER_CLICK, function()
        local Tree_ID,Talent_ID = TALENTS_UI_IdentifyFrame(BlzGetTriggerFrame())
        TALENTS_UI_ChooseTalent(Tree_ID,Talent_ID)
        BlzFrameSetEnable(BlzGetTriggerFrame(), false)
        BlzFrameSetEnable(BlzGetTriggerFrame(), true)
    end)

    TALENTS_UI_Initialize = nil
end

function TALENTS_UI_IdentifyFrame(frame)
    for i,v in pairs(TALENTS_FRAME_CONTAINER) do
        for j,x in pairs(TALENTS_FRAME_CONTAINER[i]) do
            if x.frame == frame then
                return i,j
            end
        end
    end
end

function TALENTS_UI_Hide()
    BlzFrameSetVisible(TALENTS_FRAME_MAIN, false)
    BlzFrameSetTexture(BlzGetFrameByName("MenuBar_KnowledgeButton_FrameIcon", 0), "war3mapImported\\BTN_Menu_Knowledge.dds", 0, true)
end

function TALENTS_UI_Show()
    if not(ARENA_ACTIVATED) then
        BlzFrameSetTexture(BlzGetFrameByName("MenuBar_KnowledgeButton_FrameIcon", 0), "war3mapImported\\BTN_Menu_KnowledgePushed.dds", 0, true)
        if not(TALENTS_FRAME_MAIN) then
            TALENTS_FRAME_MAIN = BlzCreateFrame('Talents_MainFrame',  BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)
            TALENTS_BUTTON_RESET = BlzCreateFrame('Talents_TalentResetButton',TALENTS_FRAME_MAIN, 0, 0)
            TALENTS_BUTTON_CLOSE = BlzCreateFrame('Talents_TalentCloseButton',TALENTS_FRAME_MAIN, 0, 0)

            local trigger = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trigger, TALENTS_BUTTON_RESET, FRAMEEVENT_CONTROL_CLICK)
            BlzTriggerRegisterFrameEvent(trigger, TALENTS_BUTTON_CLOSE, FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trigger, function()
                local frame = BlzGetTriggerFrame()
                if frame == TALENTS_BUTTON_CLOSE then
                    TALENTS_UI_Hide()
                else
                    TALENTS_ResetAll()
                    TALENTS_UI_LoadTalents()
                end
                BlzFrameSetEnable(frame, false)
                BlzFrameSetEnable(frame, true)
            end)
        end
        local id = 0
        for i,v in ipairs(TALENTS_TABLE) do
            TALENTS_FRAME_CONTAINER[i] = TALENTS_FRAME_CONTAINER[i] or {}
            for j,x in ipairs(TALENTS_TABLE[i]) do
                if not(TALENTS_FRAME_CONTAINER[i][j]) then
                    TALENTS_FRAME_CONTAINER[i][j] = {}
                    TALENTS_FRAME_CONTAINER[i][j].backdrop = BlzCreateFrame('Talents_TalentFrame_FrameTexture',   TALENTS_FRAME_MAIN, 0, id)
                    TALENTS_FRAME_CONTAINER[i][j].tooltip = BlzCreateFrame('Talents_TooltipFrameText',   TALENTS_FRAME_CONTAINER[i][j].backdrop, 0, id)
                    TALENTS_FRAME_CONTAINER[i][j].title = BlzCreateFrame('Talents_TooltipFrameTitle',   TALENTS_FRAME_CONTAINER[i][j].backdrop, 0, id)
                    TALENTS_FRAME_CONTAINER[i][j].icon = BlzCreateFrame('Talents_TalentFrame_Icon',  TALENTS_FRAME_CONTAINER[i][j].backdrop, 0, id)
                    TALENTS_FRAME_CONTAINER[i][j].levelText = BlzCreateFrame('Talents_LevelReqText',   TALENTS_FRAME_CONTAINER[i][j].backdrop, 0, id)
                    TALENTS_FRAME_CONTAINER[i][j].frame = BlzCreateFrame('Talents_TalentFrame',  TALENTS_FRAME_CONTAINER[i][j].backdrop, 0, id)
                    BlzFrameSetPoint(TALENTS_FRAME_CONTAINER[i][j].tooltip, FRAMEPOINT_CENTER, TALENTS_FRAME_CONTAINER[i][j].backdrop, FRAMEPOINT_CENTER, 0, -0.002)
                    BlzFrameSetPoint(TALENTS_FRAME_CONTAINER[i][j].title, FRAMEPOINT_TOP, TALENTS_FRAME_CONTAINER[i][j].backdrop, FRAMEPOINT_TOP, 0, -0.004)
                    BlzFrameSetPoint(TALENTS_FRAME_CONTAINER[i][j].icon, FRAMEPOINT_LEFT, TALENTS_FRAME_CONTAINER[i][j].backdrop, FRAMEPOINT_LEFT, 0.004, 0)
                    BlzFrameSetPoint(TALENTS_FRAME_CONTAINER[i][j].levelText, FRAMEPOINT_CENTER, TALENTS_FRAME_CONTAINER[i][j].backdrop, FRAMEPOINT_CENTER, 0, 0)
                    BlzFrameSetText(TALENTS_FRAME_CONTAINER[i][j].tooltip, TALENTS_TABLE[i][j].Tooltip)
                    BlzFrameSetText(TALENTS_FRAME_CONTAINER[i][j].title, TALENTS_TABLE[i][j].Name)
                    BlzFrameSetPoint(TALENTS_FRAME_CONTAINER[i][j].frame, FRAMEPOINT_CENTER, TALENTS_FRAME_CONTAINER[i][j].backdrop, FRAMEPOINT_CENTER, 0, 0)

                    BlzFrameSetTextAlignment(TALENTS_FRAME_CONTAINER[i][j].levelText, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
                    BlzFrameSetTextAlignment(TALENTS_FRAME_CONTAINER[i][j].tooltip, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
                    
                    BlzTriggerRegisterFrameEvent(TALENTS_FRAME_TRIGGER_ENTER, TALENTS_FRAME_CONTAINER[i][j].frame, FRAMEEVENT_MOUSE_ENTER)
                    BlzTriggerRegisterFrameEvent(TALENTS_FRAME_TRIGGER_LEAVE, TALENTS_FRAME_CONTAINER[i][j].frame, FRAMEEVENT_MOUSE_LEAVE)
                    BlzTriggerRegisterFrameEvent(TALENTS_FRAME_TRIGGER_CLICK, TALENTS_FRAME_CONTAINER[i][j].frame, FRAMEEVENT_CONTROL_CLICK)
                end
                id = id + 1
            end
        end

        BlzFrameSetAbsPoint(TALENTS_FRAME_MAIN, FRAMEPOINT_TOP, 0.4, 0.595)
        BlzFrameSetVisible(TALENTS_FRAME_MAIN, true)

        local frame = TALENTS_FRAME_MAIN
        local button = TALENTS_BUTTON_RESET
        local framePoint = FRAMEPOINT_TOPRIGHT
        for i,v in ipairs(TALENTS_TABLE) do
            for j,x in ipairs(TALENTS_TABLE[i]) do
                BlzFrameSetPoint(TALENTS_FRAME_CONTAINER[i][j].backdrop, framePoint, frame, FRAMEPOINT_BOTTOM, 0, 0)
                framePoint = FRAMEPOINT_TOP
                frame = TALENTS_FRAME_CONTAINER[i][j].backdrop
                BlzFrameSetVisible(frame, true)
            end
            if button == TALENTS_BUTTON_RESET then
                BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, frame, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
                button = TALENTS_BUTTON_CLOSE
            else
                BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_BOTTOMLEFT, 0, 0)
            end
            frame = TALENTS_FRAME_MAIN
            framePoint = FRAMEPOINT_TOPLEFT
        end
        TALENTS_UI_LoadTalents()
    end
end

function TALENTS_UI_ChooseTalent(Tree_ID,Talent_ID)
    TALENTS_ChooseTalent(Tree_ID,Talent_ID)
    TALENTS_UI_LoadTalents()
end

function TALENTS_UI_Highlight(Tree_ID,Talent_ID)
    if not(TALENTS_IsEnabled(Tree_ID,Talent_ID)) and TALENTS_IsAvailable(Tree_ID,Talent_ID) then
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].backdrop, "war3mapImported\\Talents_TalentFramePushed.dds", 0, true)
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].icon, TALENTS_TABLE[Tree_ID][Talent_ID].ICON_PUSHED, 0, true)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].tooltip, 255)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].title, 255)
    end
end

function TALENTS_UI_Unhighlight(Tree_ID,Talent_ID)
    TALENTS_UI_TalentFrameSetEnable(Tree_ID,Talent_ID,TALENTS_IsFaded(Tree_ID,Talent_ID))
end

function TALENTS_UI_LoadTalents()
    for i,v in pairs(TALENTS_FRAME_CONTAINER) do
        for j,x in pairs(TALENTS_FRAME_CONTAINER[i]) do
            TALENTS_UI_TalentFrameSetEnable(i,j,TALENTS_IsFaded(i,j))
        end
    end
end

function TALENTS_UI_TalentFrameSetEnable(Tree_ID,Talent_ID,enable)
    if TALENTS_IsEnabled(Tree_ID,Talent_ID) then
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].backdrop, "war3mapImported\\Talents_TalentFrameActive.dds", 0, true)
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].icon, TALENTS_TABLE[Tree_ID][Talent_ID].ICON, 0, true)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].tooltip, 255)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].title, 255)
    elseif enable then
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].backdrop, "war3mapImported\\Talents_TalentFrame.dds", 0, true)
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].icon, TALENTS_TABLE[Tree_ID][Talent_ID].ICON, 0, true)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].tooltip, 255)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].title, 255)
    else
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].backdrop, "war3mapImported\\Talents_TalentFrameDisabled.dds", 0, true)
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].icon, TALENTS_TABLE[Tree_ID][Talent_ID].ICON_DISABLED, 0, true)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].tooltip, 5)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].title, 5)
    end
    BlzFrameSetVisible(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].levelText, not(TALENTS_IsAvailable(Tree_ID,Talent_ID)))
    BlzFrameSetText(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].levelText, 'Difficulties Beaten ' .. (TALENTS_TABLE[Tree_ID][Talent_ID].LevelRequired-1))
end

function TALENTS_IsFaded(Tree_ID,Talent_ID)
    local avail = true
    for i,v in pairs(TALENTS_TABLE) do
        if i ~= Tree_ID and TALENTS_TABLE[i][Talent_ID].Enabled then
            avail = false
        end
    end
    avail = avail and GetHeroLevel(HERO) >= TALENTS_TABLE[Tree_ID][Talent_ID].LevelRequired
    return avail
end

function TALENTS_IsAvailable(Tree_ID,Talent_ID)
    return GetHeroLevel(HERO) >= TALENTS_TABLE[Tree_ID][Talent_ID].LevelRequired
end

function TALENTS_IsEnabled(Tree_ID,Talent_ID)
    return TALENTS_TABLE[Tree_ID][Talent_ID].Enabled
end

function TALENTS_ChooseTalent(Tree_ID,Talent_ID)
    if TALENTS_IsAvailable(Tree_ID,Talent_ID) and not(TALENTS_IsEnabled(Tree_ID,Talent_ID)) then
        for i,v in pairs(TALENTS_TABLE) do
            if i ~= Tree_ID then
                TALENTS_DiscardTalent(i,Talent_ID)
            end    
        end
        TALENTS_ApplyTalent(Tree_ID,Talent_ID)
        HERO_SaveProfile()
    end
end

function TALENTS_ResetAll()
    for x,s in pairs(TALENTS_TABLE) do
        for i,v in pairs(TALENTS_TABLE[x]) do
            TALENTS_DiscardTalent(x,i)
        end
    end
end

function TALENTS_ApplyAll()
    for x,s in pairs(TALENTS_TABLE) do
        for i,v in pairs(TALENTS_TABLE[x]) do
            TALENTS_ApplyTalent(x,i)
        end
    end
end

function TALENTS_ApplyTalent(Tree_ID,Talent_ID)
    if not(TALENTS_TABLE[Tree_ID][Talent_ID].Enabled) then
        TALENTS_TABLE[Tree_ID][Talent_ID].ApplyFunc()
        TALENTS_TABLE[Tree_ID][Talent_ID].Enabled = true
    end
end

function TALENTS_DiscardTalent(Tree_ID,Talent_ID)
    if TALENTS_TABLE[Tree_ID][Talent_ID].Enabled then
        TALENTS_TABLE[Tree_ID][Talent_ID].DiscardFunc()
        TALENTS_TABLE[Tree_ID][Talent_ID].Enabled = false
    end
end

function TALENTS_Load(hero_type)
    for h_type,t in pairs(HERO_DATA) do
        if h_type == hero_type then
            HERO_DATA[hero_type].TALENTS_registerFunc()
        else
            HERO_DATA[hero_type].TALENTS_memoryCleanFunc()
        end
    end
end