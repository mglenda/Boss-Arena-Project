----------------------------------------------------
----------------------------------------------------
----------------------------------------------------

function BOSS_LoadJournalData()
    BOSS_JOURNAL_DATA = {}
    for i,v in ipairs(BOSS_DATA) do
        BOSS_JOURNAL_DATA[i] = {}
        BOSS_JOURNAL_DATA[i].texture = BlzCreateSimpleFrame('BossJournal_BossFrame_Texture', BOSS_JOURNAL_MAINFRAME, i)
        BOSS_JOURNAL_DATA[i].textureImage = BlzGetFrameByName('BossJournal_BossFrame_TextureTexture', i)
        BOSS_JOURNAL_DATA[i].background = BlzCreateSimpleFrame('BossJournal_BossFrame_BackgroundTexture', BOSS_JOURNAL_DATA[i].texture, i)
        BOSS_JOURNAL_DATA[i].backgroundImage = BlzGetFrameByName('BossJournal_BossFrame_BackgroundTextureTexture', i)
        BOSS_JOURNAL_DATA[i].title = BlzCreateSimpleFrame('BossJournal_BossFrameTitle', BOSS_JOURNAL_DATA[i].texture, i)
        BOSS_JOURNAL_DATA[i].titleText = BlzGetFrameByName('BossJournal_BossFrameTitleText', i)
        BOSS_JOURNAL_DATA[i].frame = BlzCreateFrame('BossJournal_BossFrame', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, i)
        BOSS_JOURNAL_DATA[i].mButton = BlzCreateSimpleFrame('BossJournal_DiffButton_Mythic', BOSS_JOURNAL_DATA[i].background, i)
        BOSS_JOURNAL_DATA[i].nButton = BlzCreateSimpleFrame('BossJournal_DiffButton_Normal', BOSS_JOURNAL_DATA[i].background, i)
        BOSS_JOURNAL_DATA[i].hButton = BlzCreateSimpleFrame('BossJournal_DiffButton_Heroic', BOSS_JOURNAL_DATA[i].background, i)
        BOSS_JOURNAL_DATA[i].nButtonTitle = BlzGetFrameByName('BossJournal_DiffButton_NormalTitle', i)
        BOSS_JOURNAL_DATA[i].hButtonTitle = BlzGetFrameByName('BossJournal_DiffButton_HeroicTitle', i)
        BOSS_JOURNAL_DATA[i].mButtonTitle = BlzGetFrameByName('BossJournal_DiffButton_MythicTitle', i)
        BOSS_JOURNAL_DATA[i].nButtonTexture = BlzGetFrameByName('BossJournal_DiffButton_Normal_Icon', i)
        BOSS_JOURNAL_DATA[i].hButtonTexture = BlzGetFrameByName('BossJournal_DiffButton_Heroic_Icon', i)
        BOSS_JOURNAL_DATA[i].mButtonTexture = BlzGetFrameByName('BossJournal_DiffButton_Mythic_Icon', i)
        BOSS_JOURNAL_DATA[i].active = false
        BlzFrameSetPoint(BOSS_JOURNAL_DATA[i].background, FRAMEPOINT_CENTER, BOSS_JOURNAL_DATA[i].texture, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetPoint(BOSS_JOURNAL_DATA[i].frame, FRAMEPOINT_CENTER, BOSS_JOURNAL_DATA[i].texture, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetPoint(BOSS_JOURNAL_DATA[i].title, FRAMEPOINT_CENTER, BOSS_JOURNAL_DATA[i].texture, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetPoint(BOSS_JOURNAL_DATA[i].nButton, FRAMEPOINT_TOPLEFT, BOSS_JOURNAL_DATA[i].texture, FRAMEPOINT_TOPLEFT, 0.033, -0.006)
        BlzFrameSetPoint(BOSS_JOURNAL_DATA[i].hButton, FRAMEPOINT_TOPLEFT, BOSS_JOURNAL_DATA[i].nButton, FRAMEPOINT_TOPRIGHT, 0, 0)
        BlzFrameSetPoint(BOSS_JOURNAL_DATA[i].mButton, FRAMEPOINT_TOPLEFT, BOSS_JOURNAL_DATA[i].hButton, FRAMEPOINT_TOPRIGHT, 0, 0)
        BlzFrameSetTexture(BOSS_JOURNAL_DATA[i].backgroundImage, BOSS_DATA[i].BACKGROUND, 0, true)
        BlzFrameSetText(BOSS_JOURNAL_DATA[i].titleText, v.name)
        BlzTriggerRegisterFrameEvent(BOSS_JOURNAL_WIDGETLISTENER, BOSS_JOURNAL_DATA[i].frame, FRAMEEVENT_CONTROL_CLICK)
        BlzTriggerRegisterFrameEvent(BOSS_JOURNAL_WIDGETLISTENER, BOSS_JOURNAL_DATA[i].frame, FRAMEEVENT_MOUSE_ENTER)
        BlzTriggerRegisterFrameEvent(BOSS_JOURNAL_WIDGETLISTENER, BOSS_JOURNAL_DATA[i].frame, FRAMEEVENT_MOUSE_LEAVE)
        BlzTriggerRegisterFrameEvent(BOSS_JOURNAL_DIFFICULTYLISTENER, BOSS_JOURNAL_DATA[i].mButton, FRAMEEVENT_CONTROL_CLICK)
        BlzTriggerRegisterFrameEvent(BOSS_JOURNAL_DIFFICULTYLISTENER, BOSS_JOURNAL_DATA[i].hButton, FRAMEEVENT_CONTROL_CLICK)
        BlzTriggerRegisterFrameEvent(BOSS_JOURNAL_DIFFICULTYLISTENER, BOSS_JOURNAL_DATA[i].nButton, FRAMEEVENT_CONTROL_CLICK)

        BlzFrameSetText(BOSS_JOURNAL_DATA[i].nButtonTitle,'Normal')
        BlzFrameSetText(BOSS_JOURNAL_DATA[i].hButtonTitle,'Heroic')
        BlzFrameSetText(BOSS_JOURNAL_DATA[i].mButtonTitle,'Mythic')

        BlzFrameSetVisible(BOSS_JOURNAL_DATA[i].frame, false)
    end
    BOSS_PositionateWidgets()
    BOSS_PositionateWidgets = nil
    TriggerAddAction(BOSS_JOURNAL_WIDGETLISTENER, BOSS_WidgetListenerAction)
    TriggerAddAction(BOSS_JOURNAL_DIFFICULTYLISTENER, BOSS_DifficultyChoose)
end

function BOSS_PositionateWidgets()
    BlzFrameSetPoint(BOSS_JOURNAL_DATA[1].texture, FRAMEPOINT_TOPLEFT, BOSS_JOURNAL_MAINFRAME, FRAMEPOINT_TOPLEFT, 0.0565, -0.025)
    for i = 2, #BOSS_JOURNAL_DATA do
        if (i-1) - math.floor((i-1)/3)*3 == 0 then
            BlzFrameSetPoint(BOSS_JOURNAL_DATA[i].texture, FRAMEPOINT_TOP, BOSS_JOURNAL_DATA[i-3].texture, FRAMEPOINT_BOTTOM, 0, 0)
        else
            BlzFrameSetPoint(BOSS_JOURNAL_DATA[i].texture, FRAMEPOINT_LEFT, BOSS_JOURNAL_DATA[i-1].texture, FRAMEPOINT_RIGHT, 0, 0)
        end
    end
end

function BOSS_IdentifyWidget(frame)
    for i,v in ipairs(BOSS_JOURNAL_DATA) do
        if v.frame == frame then
            return i
        end
    end
    return nil
end

function BOSS_IdentifyDiffButton(frame)
    for i,v in ipairs(BOSS_JOURNAL_DATA) do
        if v.nButton == frame then
            return i,BOSS_DIFFICULTY_NORMAL
        elseif v.hButton == frame then
            return i,BOSS_DIFFICULTY_HEROIC
        elseif v.mButton == frame then
            return i,BOSS_DIFFICULTY_MYTHIC
        end
    end
    return nil,nil
end

function BOSS_WidgetListenerAction()
    local frame = BlzGetTriggerFrame()
    local evt = BlzGetTriggerFrameEvent()
    local w_id = BOSS_IdentifyWidget(frame)
    if evt == FRAMEEVENT_MOUSE_ENTER then
        BOSS_HighlightWidget(w_id)
    elseif evt == FRAMEEVENT_MOUSE_LEAVE then
        BOSS_UnHighlightWidget(w_id)
    else
        BlzFrameSetEnable(BlzGetTriggerFrame(), false)
        BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        BOSS_ActivateWidget(w_id)
    end
end

function BOSS_HighlightWidget(id)
    if not(BOSS_WidgetIsActivated(id)) then
        BlzFrameSetTexture(BOSS_JOURNAL_DATA[id].textureImage, 'war3mapImported\\Boss_WidgetPushed.dds', 0, true)
    end
end

function BOSS_UnHighlightWidget(id)
    if not(BOSS_WidgetIsActivated(id)) then
        BlzFrameSetTexture(BOSS_JOURNAL_DATA[id].textureImage, 'war3mapImported\\Boss_WidgetEnabled.dds', 0, true)
    end
end

function BOSS_DisableWidget(id)
    BlzFrameSetTexture(BOSS_JOURNAL_DATA[id].textureImage, 'war3mapImported\\Boss_WidgetDisabled.dds', 0, true)
    BlzFrameSetAlpha(BOSS_JOURNAL_DATA[id].title, 4)
    BlzFrameSetAlpha(BOSS_JOURNAL_DATA[id].background, 4)
    BlzFrameSetEnable(BOSS_JOURNAL_DATA[id].frame, false)
    BOSS_WidgetHideDifficulties(id)
end

function BOSS_EnableWidget(id)
    BlzFrameSetTexture(BOSS_JOURNAL_DATA[id].textureImage, 'war3mapImported\\Boss_WidgetEnabled.dds', 0, true)
    BlzFrameSetAlpha(BOSS_JOURNAL_DATA[id].title, 255)
    BlzFrameSetAlpha(BOSS_JOURNAL_DATA[id].background, 255)
    BlzFrameSetEnable(BOSS_JOURNAL_DATA[id].frame, true)
    BOSS_WidgetHideDifficulties(id)
end

function BOSS_WidgetHideDifficulties(id)
    BlzFrameSetVisible(BOSS_JOURNAL_DATA[id].mButton, false)
    BlzFrameSetVisible(BOSS_JOURNAL_DATA[id].nButton, false)
    BlzFrameSetVisible(BOSS_JOURNAL_DATA[id].hButton, false)
    BlzFrameSetVisible(BOSS_JOURNAL_DATA[id].icon, false)
    BlzFrameSetVisible(BOSS_JOURNAL_DATA[id].title, true, BlzFrameGetAlpha(BOSS_JOURNAL_DATA[id].title))
end

function BOSS_WidgetShowDifficulties(id)
    BlzFrameSetVisible(BOSS_JOURNAL_DATA[id].title, false)
    BlzFrameSetVisible(BOSS_JOURNAL_DATA[id].hButton, true)
    BlzFrameSetVisible(BOSS_JOURNAL_DATA[id].nButton, true)
    BlzFrameSetVisible(BOSS_JOURNAL_DATA[id].icon, true)
    if BOSS_DATA[id].diff.avail[BOSS_DIFFICULTY_NORMAL] then
        BlzFrameSetEnable(BOSS_JOURNAL_DATA[id].nButton, true)
    else
        BlzFrameSetEnable(BOSS_JOURNAL_DATA[id].nButton, false)
    end
    if BOSS_DATA[id].diff.avail[BOSS_DIFFICULTY_HEROIC] then 
        BlzFrameSetEnable(BOSS_JOURNAL_DATA[id].hButton, true)
    else
        BlzFrameSetEnable(BOSS_JOURNAL_DATA[id].hButton, false)
    end

    BlzFrameSetTexture(BOSS_JOURNAL_DATA[id].nButtonTexture,BOSS_DATA[id].diff.defeated[BOSS_DIFFICULTY_NORMAL] and BOSS_DIFFICULTY_TEXTURES[BOSS_DIFFICULTY_NORMAL].done or (BOSS_DATA[id].diff.avail[BOSS_DIFFICULTY_NORMAL] and BOSS_DIFFICULTY_TEXTURES[BOSS_DIFFICULTY_NORMAL].active or BOSS_DIFFICULTY_TEXTURES[BOSS_DIFFICULTY_NORMAL].disable), 0, true)
    BlzFrameSetTexture(BOSS_JOURNAL_DATA[id].hButtonTexture,BOSS_DATA[id].diff.defeated[BOSS_DIFFICULTY_HEROIC] and BOSS_DIFFICULTY_TEXTURES[BOSS_DIFFICULTY_HEROIC].done or (BOSS_DATA[id].diff.avail[BOSS_DIFFICULTY_HEROIC] and BOSS_DIFFICULTY_TEXTURES[BOSS_DIFFICULTY_HEROIC].active or BOSS_DIFFICULTY_TEXTURES[BOSS_DIFFICULTY_HEROIC].disable), 0, true)
    BlzFrameSetTexture(BOSS_JOURNAL_DATA[id].mButtonTexture,BOSS_DATA[id].diff.defeated[BOSS_DIFFICULTY_MYTHIC] and BOSS_DIFFICULTY_TEXTURES[BOSS_DIFFICULTY_MYTHIC].done or (BOSS_DATA[id].diff.avail[BOSS_DIFFICULTY_MYTHIC] and BOSS_DIFFICULTY_TEXTURES[BOSS_DIFFICULTY_MYTHIC].active or BOSS_DIFFICULTY_TEXTURES[BOSS_DIFFICULTY_MYTHIC].disable), 0, true)

    if BOSS_DATA[id].diff.avail[BOSS_DIFFICULTY_MYTHIC] then
        BlzFrameSetVisible(BOSS_JOURNAL_DATA[id].mButton, true) 
        BlzFrameClearAllPoints(BOSS_JOURNAL_DATA[id].nButton)
        BlzFrameClearAllPoints(BOSS_JOURNAL_DATA[id].hButton)
        BlzFrameClearAllPoints(BOSS_JOURNAL_DATA[id].mButton)
        BlzFrameSetSize(BOSS_JOURNAL_DATA[id].nButton, 0.025, 0.025)
        BlzFrameSetSize(BOSS_JOURNAL_DATA[id].hButton, 0.025, 0.025)
        BlzFrameSetSize(BOSS_JOURNAL_DATA[id].mButton, 0.045, 0.045)
        BlzFrameSetPoint(BOSS_JOURNAL_DATA[id].mButton, FRAMEPOINT_TOP, BOSS_JOURNAL_DATA[id].texture, FRAMEPOINT_TOP, 0, -0.0125)
        BlzFrameSetPoint(BOSS_JOURNAL_DATA[id].nButton, FRAMEPOINT_BOTTOMRIGHT, BOSS_JOURNAL_DATA[id].mButton, FRAMEPOINT_LEFT, -0.02125, 0)
        BlzFrameSetPoint(BOSS_JOURNAL_DATA[id].hButton, FRAMEPOINT_BOTTOMLEFT, BOSS_JOURNAL_DATA[id].mButton, FRAMEPOINT_RIGHT, 0.02125, 0)
    else
        BlzFrameClearAllPoints(BOSS_JOURNAL_DATA[id].nButton)
        BlzFrameClearAllPoints(BOSS_JOURNAL_DATA[id].hButton)
        BlzFrameClearAllPoints(BOSS_JOURNAL_DATA[id].mButton)
        BlzFrameSetSize(BOSS_JOURNAL_DATA[id].nButton, 0.04, 0.04)
        BlzFrameSetSize(BOSS_JOURNAL_DATA[id].hButton, 0.04, 0.04)
        BlzFrameSetPoint(BOSS_JOURNAL_DATA[id].nButton, FRAMEPOINT_TOPLEFT, BOSS_JOURNAL_DATA[id].texture, FRAMEPOINT_TOPLEFT, 0.033, -0.015)
        BlzFrameSetPoint(BOSS_JOURNAL_DATA[id].hButton, FRAMEPOINT_TOPLEFT, BOSS_JOURNAL_DATA[id].nButton, FRAMEPOINT_TOPRIGHT, 0.033, 0)
    end
end

function BOSS_ActivateWidget(id)
    for i,v in ipairs(BOSS_DATA) do
        if BOSS_WidgetIsActivated(i) then
            BOSS_DeActivateWidget(i)
        end
    end
    BOSS_JOURNAL_DATA[id].active = true
    BlzFrameSetTexture(BOSS_JOURNAL_DATA[id].textureImage, 'war3mapImported\\Boss_WidgetActive.dds', 0, true)
    BlzFrameSetAlpha(BOSS_JOURNAL_DATA[id].background, 40)
    BOSS_WidgetShowDifficulties(id)
end

function BOSS_DeActivateWidget(id)
    BOSS_JOURNAL_DATA[id].active = false
    BlzFrameSetTexture(BOSS_JOURNAL_DATA[id].textureImage, 'war3mapImported\\Boss_WidgetEnabled.dds', 0, true)
    BlzFrameSetAlpha(BOSS_JOURNAL_DATA[id].background, 255)
    BOSS_WidgetHideDifficulties(id)
end

function BOSS_WidgetIsActivated(id)
    return BOSS_JOURNAL_DATA[id].active
end

function BOSS_ReLoadWidgets()
    for i,v in ipairs(BOSS_DATA) do
        BOSS_ReLoadWidget(i)
    end
end

function BOSS_AtLeastOneDiffAllowed(id)
    for i,d in pairs(BOSS_DATA[id].diff.avail) do
        if d then
            return d
        end
    end
    return false
end

function BOSS_AtLeastOneDiffDefeated(id)
    for i,d in pairs(BOSS_DATA[id].diff.defeated) do
        if d then
            return d
        end
    end
    return false
end

function BOSS_ReLoadWidget(id)
    BOSS_JOURNAL_DATA[id].active = false
    if BOSS_AtLeastOneDiffAllowed(id) then
        BOSS_EnableWidget(id)
    else
        BOSS_DisableWidget(id)
    end
end

function BOSS_CreateJournalButton()
    BOSS_JOURNAL_BUTTON = BlzCreateSimpleFrame('BossJournal_BookFrame', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    BOSS_JOURNAL_TEXTURE = BlzGetFrameByName('BossJournal_BookFrameTexture', 0)
    BOSS_JOURNAL_LISTENER = BlzCreateFrame('BossJournal_BookListener', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)
    BlzFrameSetPoint(BOSS_JOURNAL_BUTTON, FRAMEPOINT_BOTTOMRIGHT, HERO_DETAILS_DATA.mainFrame, FRAMEPOINT_BOTTOMLEFT, 0, 0)
    BlzFrameSetPoint(BOSS_JOURNAL_LISTENER, FRAMEPOINT_CENTER, BOSS_JOURNAL_BUTTON, FRAMEPOINT_CENTER, 0, 0)

    BOSS_JOURNAL_MAINFRAME = BlzCreateSimpleFrame('BossJournal_MainFrame', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    BlzFrameSetPoint(BOSS_JOURNAL_MAINFRAME, FRAMEPOINT_TOP, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), FRAMEPOINT_TOP, 0, -0.01)
    BlzFrameSetVisible(BOSS_JOURNAL_MAINFRAME, false)

    local trg = CreateTrigger()
    BlzTriggerRegisterFrameEvent(trg, BOSS_JOURNAL_LISTENER, FRAMEEVENT_CONTROL_CLICK)
    BlzTriggerRegisterFrameEvent(trg, BOSS_JOURNAL_LISTENER, FRAMEEVENT_MOUSE_ENTER)
    BlzTriggerRegisterFrameEvent(trg, BOSS_JOURNAL_LISTENER, FRAMEEVENT_MOUSE_LEAVE)
    TriggerAddAction(trg, function()
        if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_ENTER then
            BOSS_HighlightJournal()
        elseif BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_LEAVE then
            if not(BlzFrameIsVisible(BOSS_JOURNAL_MAINFRAME)) then
                BOSS_UnhighlightJournal()
            end
        else
            if not(BlzFrameIsVisible(BOSS_JOURNAL_MAINFRAME)) then
                BOSS_ShowJournal()
            else    
                BOSS_HideJournal()
            end
            BlzFrameSetEnable(BlzGetTriggerFrame(), false)
            BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        end
    end)

    trg = nil
end

function BOSS_ShowJournal()
    if not(ARENA_ACTIVATED) then
        BOSS_HighlightJournal()
        BlzFrameSetVisible(BOSS_JOURNAL_MAINFRAME, true)
        BOSS_ReLoadWidgets()
        BOSS_SetJournalButtonsVisible(true)
        BOSS_RecalculateDifficulties()
    end
end

function BOSS_HideJournal()
    BOSS_UnhighlightJournal()
    if ARENA_ACTIVATED then
        BOSS_HideJournalButton()
    end
    BOSS_SetJournalButtonsVisible(false)
    BlzFrameSetVisible(BOSS_JOURNAL_MAINFRAME, false)
end

function BOSS_SetJournalButtonsVisible(visible)
    for i,v in pairs(BOSS_JOURNAL_DATA) do
        if BlzFrameIsVisible(v.frame) == not(visible) then
            BlzFrameSetVisible(v.frame, visible)
        end
    end
end

function BOSS_HideJournalButton()
    BlzFrameSetVisible(BOSS_JOURNAL_BUTTON, false)
end

function BOSS_ShowJournalButton()
    BlzFrameSetVisible(BOSS_JOURNAL_BUTTON, true)
end

function BOSS_HighlightJournal()
    BlzFrameSetTexture(BOSS_JOURNAL_TEXTURE, "war3mapImported\\JournalButtonFocused.dds", 0, true)
end

function BOSS_UnhighlightJournal()
    BlzFrameSetTexture(BOSS_JOURNAL_TEXTURE, "war3mapImported\\JournalButton.dds", 0, true)
end