
HERO_JOURNAL_MAINFRAME = nil
HERO_JOURNAL_IMAGE = nil
HERO_JOURNAL_NAME = nil
HERO_JOURNAL_BUTTON_CHOOSE = nil
HERO_JOURNAL_BUTTON_NEXT = nil
HERO_JOURNAL_TRIGGER_CLICK = CreateTrigger()
HERO_JOURNAL_TRIGGER_BOSS_CLICK = CreateTrigger()
HERO_JOURNAL_TRIGGER_BOSS_CLEAN = CreateTrigger()
HERO_JOURNAL_ACTIVE_BOSS = nil
HERO_JOURNAL_INDEXES = {}
HERO_JOURNAL_WIDGETS = {}
HERO_JOURNAL_TYPES = {
    EASY = {
        font_cl = BlzConvertColor(255, 0, 110, 0)
        ,texture = 'war3mapImported\\HeroJournal_Easy.dds'
        ,text = 'Easy'
    }
    ,MEDIUM = {
        font_cl = BlzConvertColor(255, 0, 80, 110)
        ,texture = 'war3mapImported\\HeroJournal_Medium.dds'
        ,text = 'Medium'
    }
    ,HARD = {
        font_cl = BlzConvertColor(255, 110, 0, 0)
        ,texture = 'war3mapImported\\HeroJournal_Hard.dds'
        ,text = 'Hard'
    }
    ,MELEE = {
        font_cl = BlzConvertColor(255, 165, 114, 0)
        ,texture = 'war3mapImported\\HeroJournal_Melee.dds'
        ,text = 'Melee'
    }
    ,RANGED = {
        font_cl = BlzConvertColor(255, 100, 100, 0)
        ,texture = 'war3mapImported\\HeroJournal_Ranged.dds'
        ,text = 'Ranged'
    }
    ,CASTER = {
        font_cl = BlzConvertColor(255, 0, 0, 110)
        ,texture = 'war3mapImported\\HeroJournal_Caster.dds'
        ,text = 'Caster'
    }
    ,STRIKER = {
        font_cl = BlzConvertColor(255, 93, 43, 0)
        ,texture = 'war3mapImported\\HeroJournal_Striker.dds'
        ,text = 'Striker'
    }
    ,HYBRID = {
        font_cl = BlzConvertColor(255, 59, 0, 103)
        ,texture = 'war3mapImported\\HeroJournal_Hybrid.dds'
        ,text = 'Hybrid'
    }
}

function UI_HeroJournal_Initialize()
    UI_CreateHeroJournal()
    UI_HeroJournal_LoadData()
    UI_HeroJournal_Inject(HERO_JOURNAL_INDEXES[#HERO_JOURNAL_INDEXES])

    TriggerAddAction(HERO_JOURNAL_TRIGGER_CLICK, function()
        if BlzGetTriggerFrame() == HERO_JOURNAL_BUTTON_CHOOSE then
            local h_id = HERO_JOURNAL_INDEXES[#HERO_JOURNAL_INDEXES]
            UI_HeroJournal_Flush()
            UI_HeroJournal_Choose(h_id)
            h_id = nil
        else    
            UI_HeroJournal_Next()
        end
    end)

    UI_HeroJournal_Initialize = nil
end

function UI_HeroJournal_Choose(h_id)
    HERO_DATA[h_id].CreateFunc()
    UI_HeroJournal_Choose = nil
end

function UI_HeroJournal_Next()
    table.remove(HERO_JOURNAL_INDEXES, #HERO_JOURNAL_INDEXES)
    if #HERO_JOURNAL_INDEXES == 0 then
        UI_HeroJournal_LoadData()
    end
    UI_HeroJournal_Inject(HERO_JOURNAL_INDEXES[#HERO_JOURNAL_INDEXES])
end

function UI_HeroJournal_Flush()
    BlzDestroyFrame(HERO_JOURNAL_MAINFRAME)
    DestroyTrigger(HERO_JOURNAL_TRIGGER_CLICK)
    DestroyTrigger(HERO_JOURNAL_TRIGGER_BOSS_CLICK)
    DestroyTrigger(HERO_JOURNAL_TRIGGER_BOSS_CLEAN)

    HERO_JOURNAL_MAINFRAME = nil
    HERO_JOURNAL_IMAGE = nil
    HERO_JOURNAL_NAME = nil
    HERO_JOURNAL_BUTTON_CHOOSE = nil
    HERO_JOURNAL_BUTTON_NEXT = nil
    HERO_JOURNAL_TRIGGER_CLICK = nil
    HERO_JOURNAL_TRIGGER_BOSS_CLICK = nil
    HERO_JOURNAL_INDEXES = nil
    HERO_JOURNAL_WIDGETS = nil
    UI_HeroJournal_LoadData = nil
    UI_HeroJournal_Inject = nil
    UI_HeroJournal_Next = nil
    UI_HeroJournal_PositionateBossWidgets = nil
    HERO_JOURNAL_TYPES = nil
    HERO_JOURNAL_ACTIVE_BOSS = nil
    UI_HeroJournal_ActivateBoss = nil
    UI_HeroJournal_DeactivateBoss = nil
    HERO_JOURNAL_TRIGGER_BOSS_CLEAN = nil

    UI_HeroJournal_Flush = nil
end

function UI_HeroJournal_Inject(h_id)
    BlzFrameSetTexture(HERO_JOURNAL_IMAGE, HERO_DATA[h_id].Journal_Image, 0, true)
    BlzFrameSetText(HERO_JOURNAL_NAME, HERO_DATA[h_id].Journal_Title)
    HERO_TYPE = h_id
    HERO_LoadProfile()

    BlzFrameSetTexture(HERO_JOURNAL_WIDGETS.diffImage, HERO_JOURNAL_TYPES[HERO_DATA[h_id].Journal_Difficulty].texture, 0, true)
    BlzFrameSetTextColor(HERO_JOURNAL_WIDGETS.diffText, HERO_JOURNAL_TYPES[HERO_DATA[h_id].Journal_Difficulty].font_cl)
    BlzFrameSetText(HERO_JOURNAL_WIDGETS.diffText,  HERO_JOURNAL_TYPES[HERO_DATA[h_id].Journal_Difficulty].text)

    BlzFrameSetTexture(HERO_JOURNAL_WIDGETS.typeImage, HERO_JOURNAL_TYPES[HERO_DATA[h_id].Journal_Type].texture, 0, true)
    BlzFrameSetTextColor(HERO_JOURNAL_WIDGETS.typeText, HERO_JOURNAL_TYPES[HERO_DATA[h_id].Journal_Type].font_cl)
    BlzFrameSetText(HERO_JOURNAL_WIDGETS.typeText,  HERO_JOURNAL_TYPES[HERO_DATA[h_id].Journal_Type].text)

    BlzFrameSetTexture(HERO_JOURNAL_WIDGETS.combatImage, HERO_JOURNAL_TYPES[HERO_DATA[h_id].Journal_Combat].texture, 0, true)
    BlzFrameSetTextColor(HERO_JOURNAL_WIDGETS.combatText, HERO_JOURNAL_TYPES[HERO_DATA[h_id].Journal_Combat].font_cl)
    BlzFrameSetText(HERO_JOURNAL_WIDGETS.combatText,  HERO_JOURNAL_TYPES[HERO_DATA[h_id].Journal_Combat].text)

    BlzFrameSetText(HERO_JOURNAL_WIDGETS.legendText,  HERO_DATA[h_id].Journal_Description)

    BOSS_RecalculateDifficulties()

    for b_id,v in ipairs(BOSS_DATA) do
        if b_id == HERO_JOURNAL_ACTIVE_BOSS then
            if BOSS_AtLeastOneDiffDefeated(b_id) then
                UI_HeroJournal_ActivateBoss(b_id)
                BlzFrameSetEnable( HERO_JOURNAL_WIDGETS.boss_buttons[b_id], true)
            else
                if BlzFrameIsVisible(HERO_JOURNAL_WIDGETS.canvas_Records) then
                    BlzFrameSetVisible(HERO_JOURNAL_WIDGETS.canvas_Records, false)
                end
                BlzFrameSetTexture(BlzGetFrameByName("HeroJournal_BossButtonTexture", b_id), v.Journal_ImageDisabled, 0, true)
                BlzFrameSetEnable( HERO_JOURNAL_WIDGETS.boss_buttons[b_id], false)
            end
        else
            if BOSS_AtLeastOneDiffDefeated(b_id) then
                BlzFrameSetTexture(BlzGetFrameByName("HeroJournal_BossButtonTexture", b_id), v.Journal_Image, 0, true)
                BlzFrameSetEnable( HERO_JOURNAL_WIDGETS.boss_buttons[b_id], true)
            else
                BlzFrameSetTexture(BlzGetFrameByName("HeroJournal_BossButtonTexture", b_id), v.Journal_ImageDisabled, 0, true)
                BlzFrameSetEnable( HERO_JOURNAL_WIDGETS.boss_buttons[b_id], false)
            end
        end
    end
end

function UI_HeroJournal_LoadData()
    for i,v in pairs(HERO_DATA) do
        table.insert(HERO_JOURNAL_INDEXES,i)
    end
end

function UI_CreateHeroJournal()
    HERO_JOURNAL_MAINFRAME = BlzCreateSimpleFrame('HeroJournal_Frame', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    local heroImage = BlzCreateSimpleFrame('HeroJournal_HeroImage', HERO_JOURNAL_MAINFRAME, 0)
    HERO_JOURNAL_IMAGE = BlzGetFrameByName("HeroJournal_HeroImageTexture", 0)
    local mainTexture = BlzGetFrameByName("HeroJournal_FrameTexture", 0)
    local heroName = BlzCreateSimpleFrame('HeroJournal_Name', HERO_JOURNAL_MAINFRAME, 0)
    HERO_JOURNAL_NAME = BlzGetFrameByName("HeroJournal_Name_Text", 0)
    --BUTTONS
    HERO_JOURNAL_BUTTON_NEXT = BlzCreateSimpleFrame('HeroJournal_Button_Next', HERO_JOURNAL_MAINFRAME, 0)
    HERO_JOURNAL_BUTTON_CHOOSE = BlzCreateSimpleFrame('HeroJournal_Button_Confirm', HERO_JOURNAL_MAINFRAME, 0)

    BlzFrameSetPoint(HERO_JOURNAL_BUTTON_NEXT, FRAMEPOINT_BOTTOMRIGHT, HERO_JOURNAL_MAINFRAME, FRAMEPOINT_BOTTOMRIGHT, -0.02, 0.02)
    BlzFrameSetPoint(HERO_JOURNAL_BUTTON_CHOOSE, FRAMEPOINT_RIGHT, HERO_JOURNAL_BUTTON_NEXT, FRAMEPOINT_LEFT, -0.02, 0)

    BlzFrameSetPoint(heroImage, FRAMEPOINT_LEFT, HERO_JOURNAL_MAINFRAME, FRAMEPOINT_LEFT, 0.02, -0.02)
    BlzFrameSetPoint(heroName, FRAMEPOINT_TOP, HERO_JOURNAL_MAINFRAME, FRAMEPOINT_TOP, 0, -0.01)

    BlzFrameSetAbsPoint(HERO_JOURNAL_MAINFRAME, FRAMEPOINT_BOTTOMLEFT, -0.14, 0)

    BlzTriggerRegisterFrameEvent(HERO_JOURNAL_TRIGGER_CLICK, HERO_JOURNAL_BUTTON_NEXT, FRAMEEVENT_CONTROL_CLICK)
    BlzTriggerRegisterFrameEvent(HERO_JOURNAL_TRIGGER_CLICK, HERO_JOURNAL_BUTTON_CHOOSE, FRAMEEVENT_CONTROL_CLICK)

    BlzFrameSetTexture(mainTexture, 'war3mapImported\\HeroesJournal_Background.dds', 0, true)

    local canvas_Description = BlzCreateSimpleFrame('HeroJournal_Canvas', HERO_JOURNAL_MAINFRAME, 0)

    BlzFrameSetPoint(canvas_Description, FRAMEPOINT_TOPLEFT, HERO_JOURNAL_MAINFRAME, FRAMEPOINT_TOP, -0.14, -0.1)


    local diffCaption = BlzCreateSimpleFrame('HeroJournal_DifficultyCaption', canvas_Description, 0)

    BlzFrameSetPoint(diffCaption, FRAMEPOINT_TOPLEFT, canvas_Description, FRAMEPOINT_TOPLEFT, 0.04, -0.01)
    BlzFrameSetText(BlzGetFrameByName("HeroJournal_DifficultyCaption_Text", 0), 'Difficulty:')

    local diffImage = BlzCreateSimpleFrame('HeroJournal_DifficultyImage', canvas_Description, 0)

    BlzFrameSetPoint(diffImage, FRAMEPOINT_LEFT, diffCaption, FRAMEPOINT_RIGHT, 0.03, 0)

    HERO_JOURNAL_WIDGETS.diffImage =  BlzGetFrameByName("HeroJournal_DifficultyImage_Texture", 0)
    HERO_JOURNAL_WIDGETS.diffText = BlzGetFrameByName("HeroJournal_DifficultyImage_Text", 0)

    local typeCaption = BlzCreateSimpleFrame('HeroJournal_DifficultyCaption', canvas_Description, 1)

    BlzFrameSetPoint(typeCaption, FRAMEPOINT_TOP, diffCaption, FRAMEPOINT_BOTTOM, 0.0, -0.02)
    BlzFrameSetText(BlzGetFrameByName("HeroJournal_DifficultyCaption_Text", 1), 'Type:')

    local typeImage = BlzCreateSimpleFrame('HeroJournal_DifficultyImage', canvas_Description, 1)

    BlzFrameSetPoint(typeImage, FRAMEPOINT_LEFT, typeCaption, FRAMEPOINT_RIGHT, 0.03, 0)

    HERO_JOURNAL_WIDGETS.typeImage =  BlzGetFrameByName("HeroJournal_DifficultyImage_Texture", 1)
    HERO_JOURNAL_WIDGETS.typeText = BlzGetFrameByName("HeroJournal_DifficultyImage_Text", 1)

    local combatCaption = BlzCreateSimpleFrame('HeroJournal_DifficultyCaption', canvas_Description, 2)

    BlzFrameSetPoint(combatCaption, FRAMEPOINT_TOP, typeCaption, FRAMEPOINT_BOTTOM, 0.0, -0.02)
    BlzFrameSetText(BlzGetFrameByName("HeroJournal_DifficultyCaption_Text", 2), 'Combat:')

    local combatImage = BlzCreateSimpleFrame('HeroJournal_DifficultyImage', canvas_Description, 2)

    BlzFrameSetPoint(combatImage, FRAMEPOINT_LEFT, combatCaption, FRAMEPOINT_RIGHT, 0.03, 0)

    HERO_JOURNAL_WIDGETS.combatImage =  BlzGetFrameByName("HeroJournal_DifficultyImage_Texture", 2)
    HERO_JOURNAL_WIDGETS.combatText = BlzGetFrameByName("HeroJournal_DifficultyImage_Text", 2)

    local canvas_Legend = BlzCreateSimpleFrame('HeroJournal_Canvas', HERO_JOURNAL_MAINFRAME, 1)

    BlzFrameSetPoint(canvas_Legend, FRAMEPOINT_LEFT, canvas_Description, FRAMEPOINT_RIGHT, 0.04, 0)

    local legendFrame = BlzCreateSimpleFrame('HeroJournal_Legend', HERO_JOURNAL_MAINFRAME, 0)

    BlzFrameSetPoint(legendFrame, FRAMEPOINT_CENTER, canvas_Legend, FRAMEPOINT_CENTER, 0, 0) 

    HERO_JOURNAL_WIDGETS.legendText = BlzGetFrameByName("HeroJournal_Legend_Text", 0)

    BlzFrameSetPoint(HERO_JOURNAL_WIDGETS.legendText, FRAMEPOINT_BOTTOMLEFT, legendFrame, FRAMEPOINT_BOTTOMLEFT, 0, 0)
    BlzFrameSetPoint(HERO_JOURNAL_WIDGETS.legendText, FRAMEPOINT_BOTTOMRIGHT, legendFrame, FRAMEPOINT_BOTTOMRIGHT, 0, 0)

    local canvas_Bosses = BlzCreateSimpleFrame('HeroJournal_Canvas', HERO_JOURNAL_MAINFRAME, 2)

    BlzFrameSetPoint(canvas_Bosses, FRAMEPOINT_TOPLEFT, canvas_Description, FRAMEPOINT_BOTTOMLEFT, 0, -0.02)
    BlzFrameSetSize(canvas_Bosses, 0.3, 0.225)

    HERO_JOURNAL_WIDGETS.boss_buttons = {}
    for b_id,v in ipairs(BOSS_DATA) do
        HERO_JOURNAL_WIDGETS.boss_buttons[b_id] = BlzCreateSimpleFrame('HeroJournal_BossButton', canvas_Bosses, b_id)
        BlzFrameSetTexture(BlzGetFrameByName("HeroJournal_BossButtonTexture", b_id), v.Journal_Image, 0, true)
        BlzFrameSetEnable(HERO_JOURNAL_WIDGETS.boss_buttons[b_id], false)
        BlzTriggerRegisterFrameEvent(HERO_JOURNAL_TRIGGER_BOSS_CLICK, HERO_JOURNAL_WIDGETS.boss_buttons[b_id], FRAMEEVENT_CONTROL_CLICK)
    end

    TriggerAddAction(HERO_JOURNAL_TRIGGER_BOSS_CLICK, function()
        local frame = BlzGetTriggerFrame()
        for b_id,b in pairs(HERO_JOURNAL_WIDGETS.boss_buttons) do
            if b == frame then
                if b_id == HERO_JOURNAL_ACTIVE_BOSS then
                    UI_HeroJournal_DeactivateBoss()
                else
                    UI_HeroJournal_ActivateBoss(b_id)
                end
            end
        end
        frame = nil
    end)

    BlzTriggerRegisterPlayerKeyEvent(HERO_JOURNAL_TRIGGER_BOSS_CLEAN,PLAYER,OSKEY_ESCAPE,KEY_PRESSED_NONE,true)
    TriggerAddAction(HERO_JOURNAL_TRIGGER_BOSS_CLEAN,UI_HeroJournal_DeactivateBoss)

    UI_HeroJournal_PositionateBossWidgets(canvas_Bosses)

    HERO_JOURNAL_WIDGETS.canvas_Records = BlzCreateSimpleFrame('HeroJournal_Canvas', HERO_JOURNAL_MAINFRAME, 3)

    BlzFrameSetPoint(HERO_JOURNAL_WIDGETS.canvas_Records, FRAMEPOINT_LEFT, canvas_Bosses, FRAMEPOINT_RIGHT, 0.04, 0)

    BlzFrameSetSize(HERO_JOURNAL_WIDGETS.canvas_Records, 0.3, 0.225)
    BlzFrameSetVisible(HERO_JOURNAL_WIDGETS.canvas_Records, false)

    local normalDiff = BlzCreateSimpleFrame('HeroJournal_Record_DiffImage', HERO_JOURNAL_WIDGETS.canvas_Records, BOSS_DIFFICULTY_NORMAL)
    local heroicDiff = BlzCreateSimpleFrame('HeroJournal_Record_DiffImage', HERO_JOURNAL_WIDGETS.canvas_Records, BOSS_DIFFICULTY_HEROIC)
    local mythicDiff = BlzCreateSimpleFrame('HeroJournal_Record_DiffImage', HERO_JOURNAL_WIDGETS.canvas_Records, BOSS_DIFFICULTY_MYTHIC)

    local normal_DPS = BlzCreateSimpleFrame('HeroJournal_Record_Image', HERO_JOURNAL_WIDGETS.canvas_Records, BOSS_DIFFICULTY_NORMAL)
    local heroic_DPS = BlzCreateSimpleFrame('HeroJournal_Record_Image', HERO_JOURNAL_WIDGETS.canvas_Records, BOSS_DIFFICULTY_HEROIC)
    local mythic_DPS = BlzCreateSimpleFrame('HeroJournal_Record_Image', HERO_JOURNAL_WIDGETS.canvas_Records, BOSS_DIFFICULTY_MYTHIC)

    local normal_time = BlzCreateSimpleFrame('HeroJournal_Record_Image', HERO_JOURNAL_WIDGETS.canvas_Records, BOSS_DIFFICULTY_NORMAL * 10)
    local heroic_time = BlzCreateSimpleFrame('HeroJournal_Record_Image', HERO_JOURNAL_WIDGETS.canvas_Records, BOSS_DIFFICULTY_HEROIC * 10)
    local mythic_time = BlzCreateSimpleFrame('HeroJournal_Record_Image', HERO_JOURNAL_WIDGETS.canvas_Records, BOSS_DIFFICULTY_MYTHIC * 10)

    HERO_JOURNAL_WIDGETS.records_Widgets = {
        [BOSS_DIFFICULTY_NORMAL] = {
            texture = BlzGetFrameByName("HeroJournal_Record_DiffImageTexture", BOSS_DIFFICULTY_NORMAL)
            ,dps = normal_DPS
            ,time = normal_time
            ,main = normalDiff
            ,dps_text = BlzGetFrameByName("HeroJournal_Record_ImageText", BOSS_DIFFICULTY_NORMAL)
            ,time_text = BlzGetFrameByName("HeroJournal_Record_ImageText", BOSS_DIFFICULTY_NORMAL * 10)
        }
        ,[BOSS_DIFFICULTY_HEROIC] = {
            texture = BlzGetFrameByName("HeroJournal_Record_DiffImageTexture", BOSS_DIFFICULTY_HEROIC)
            ,dps = heroic_DPS
            ,time = heroic_time
            ,main = heroicDiff
            ,dps_text = BlzGetFrameByName("HeroJournal_Record_ImageText", BOSS_DIFFICULTY_HEROIC)
            ,time_text = BlzGetFrameByName("HeroJournal_Record_ImageText", BOSS_DIFFICULTY_HEROIC * 10)
        }
        ,[BOSS_DIFFICULTY_MYTHIC] = {
            texture = BlzGetFrameByName("HeroJournal_Record_DiffImageTexture", BOSS_DIFFICULTY_MYTHIC)
            ,dps = mythic_DPS
            ,time = mythic_time
            ,main = mythicDiff
            ,dps_text = BlzGetFrameByName("HeroJournal_Record_ImageText", BOSS_DIFFICULTY_MYTHIC)
            ,time_text = BlzGetFrameByName("HeroJournal_Record_ImageText", BOSS_DIFFICULTY_MYTHIC * 10)
        }
    }

    BlzFrameSetPoint(normalDiff, FRAMEPOINT_TOPLEFT, HERO_JOURNAL_WIDGETS.canvas_Records, FRAMEPOINT_TOPLEFT, 0.028, -0.015)
    BlzFrameSetPoint(heroicDiff, FRAMEPOINT_LEFT, normalDiff, FRAMEPOINT_RIGHT, 0.026, 0)
    BlzFrameSetPoint(mythicDiff, FRAMEPOINT_LEFT, heroicDiff, FRAMEPOINT_RIGHT, 0.026, 0)

    for i,v in pairs(HERO_JOURNAL_WIDGETS.records_Widgets) do
        BlzFrameSetTexture(BlzGetFrameByName("HeroJournal_Record_ImageTexture", i), 'war3mapImported\\HeroJournal_DPS.dds', 0, true)
        BlzFrameSetTexture(BlzGetFrameByName("HeroJournal_Record_ImageTexture", i * 10), 'war3mapImported\\HeroJournal_TIME.dds', 0, true)
        BlzFrameSetPoint(v.time, FRAMEPOINT_TOP, v.main, FRAMEPOINT_BOTTOM, 0, -0.03)
        BlzFrameSetPoint(v.dps, FRAMEPOINT_TOP, v.time, FRAMEPOINT_BOTTOM, 0, -0.03)
    end

    heroImage,mainTexture,heroName,canvas_Description,diffCaption,diffImage,typeCaption,typeImage,combatCaption,combatImage,canvas_Legend,legendFrame = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
    normalDiff,heroicDiff,mythicDiff = nil,nil,nil
    normal_DPS,heroic_DPS,mythic_DPS = nil,nil,nil
    normal_time,heroic_time,mythic_time = nil,nil,nil
    UI_CreateHeroJournal = nil
end

function UI_HeroJournal_ActivateBoss(b_id)
    if HERO_JOURNAL_ACTIVE_BOSS and HERO_JOURNAL_ACTIVE_BOSS ~= b_id then
        BlzFrameSetTexture(BlzGetFrameByName("HeroJournal_BossButtonTexture", HERO_JOURNAL_ACTIVE_BOSS), BOSS_DATA[HERO_JOURNAL_ACTIVE_BOSS].Journal_Image, 0, true)
    end
    if not(BlzFrameIsVisible(HERO_JOURNAL_WIDGETS.canvas_Records)) then
        BlzFrameSetVisible(HERO_JOURNAL_WIDGETS.canvas_Records, true)
    end
    BlzFrameSetTexture(BlzGetFrameByName("HeroJournal_BossButtonTexture", b_id), BOSS_DATA[b_id].Journal_ImagePushed, 0, true)
    for d_id,rec in pairs(BOSS_DATA[b_id].records) do
        if rec.record_time > 0 then
            BlzFrameSetTexture(HERO_JOURNAL_WIDGETS.records_Widgets[d_id].texture, BOSS_DIFFICULTY_TEXTURES[d_id].active, 0, true)
            BlzFrameSetVisible(HERO_JOURNAL_WIDGETS.records_Widgets[d_id].dps, true)
            BlzFrameSetVisible(HERO_JOURNAL_WIDGETS.records_Widgets[d_id].time, true)
            BlzFrameSetText(HERO_JOURNAL_WIDGETS.records_Widgets[d_id].time_text, FromatSeconds(rec.record_time,true))
            BlzFrameSetText(HERO_JOURNAL_WIDGETS.records_Widgets[d_id].dps_text, strRound(rec.record_dps,0))
        else
            BlzFrameSetTexture(HERO_JOURNAL_WIDGETS.records_Widgets[d_id].texture, BOSS_DIFFICULTY_TEXTURES[d_id].disable, 0, true)
            BlzFrameSetVisible(HERO_JOURNAL_WIDGETS.records_Widgets[d_id].dps, false)
            BlzFrameSetVisible(HERO_JOURNAL_WIDGETS.records_Widgets[d_id].time, false)
        end
    end
    HERO_JOURNAL_ACTIVE_BOSS = b_id
end

function UI_HeroJournal_DeactivateBoss()
    if BlzFrameIsVisible(HERO_JOURNAL_WIDGETS.canvas_Records) then
        BlzFrameSetVisible(HERO_JOURNAL_WIDGETS.canvas_Records, false)
    end
    BlzFrameSetTexture(BlzGetFrameByName("HeroJournal_BossButtonTexture", HERO_JOURNAL_ACTIVE_BOSS), BOSS_DATA[HERO_JOURNAL_ACTIVE_BOSS].Journal_Image, 0, true)
    HERO_JOURNAL_ACTIVE_BOSS = nil
end

function UI_HeroJournal_PositionateBossWidgets(canvas)
    BlzFrameSetPoint(HERO_JOURNAL_WIDGETS.boss_buttons[1], FRAMEPOINT_TOPLEFT, canvas, FRAMEPOINT_TOPLEFT, 0.011, -0.015)
    for i = 2, #HERO_JOURNAL_WIDGETS.boss_buttons do
        if (i-1) - math.floor((i-1)/4)*4 == 0 then
            BlzFrameSetPoint(HERO_JOURNAL_WIDGETS.boss_buttons[i], FRAMEPOINT_TOP, HERO_JOURNAL_WIDGETS.boss_buttons[i-4], FRAMEPOINT_BOTTOM, 0, -0.009)
        else
            BlzFrameSetPoint(HERO_JOURNAL_WIDGETS.boss_buttons[i], FRAMEPOINT_LEFT, HERO_JOURNAL_WIDGETS.boss_buttons[i-1], FRAMEPOINT_RIGHT, 0.012, 0)
        end
    end
end