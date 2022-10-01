
HERO_JOURNAL_MAINFRAME = nil
HERO_JOURNAL_IMAGE = nil
HERO_JOURNAL_NAME = nil
HERO_JOURNAL_BUTTON_CHOOSE = nil
HERO_JOURNAL_BUTTON_NEXT = nil
HERO_JOURNAL_TRIGGER_CLICK = CreateTrigger()
HERO_JOURNAL_INDEXES = {}
HERO_JOURNAL_RECORD_WIDGETS = {}

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

    HERO_JOURNAL_MAINFRAME = nil
    HERO_JOURNAL_IMAGE = nil
    HERO_JOURNAL_NAME = nil
    HERO_JOURNAL_BUTTON_CHOOSE = nil
    HERO_JOURNAL_BUTTON_NEXT = nil
    HERO_JOURNAL_TRIGGER_CLICK = nil
    HERO_JOURNAL_INDEXES = nil
    HERO_JOURNAL_RECORD_WIDGETS = nil
    UI_HeroJournal_LoadData = nil
    UI_HeroJournal_Inject = nil
    UI_HeroJournal_Next = nil
    UI_HeroJournal_CreateRecordsWidget = nil
    UI_HeroJournal_CreateRecordsWidgets = nil
    UI_HeroJournal_PositionateRecordWidgets = nil

    UI_HeroJournal_Flush = nil
end

function UI_HeroJournal_Inject(h_id)
    BlzFrameSetTexture(HERO_JOURNAL_IMAGE, HERO_DATA[h_id].Journal_Image, 0, true)
    BlzFrameSetText(HERO_JOURNAL_NAME, HERO_DATA[h_id].Journal_Title)
    HERO_TYPE = h_id
    HERO_LoadProfile()

    for b_id,v in pairs(BOSS_DATA) do
        for d_id,tbl in pairs(v.records) do
            BlzFrameSetText(HERO_JOURNAL_RECORD_WIDGETS[b_id][d_id].timeText, tbl.record_time > 0 and 'Time: '.. FromatSeconds(tbl.record_time,true) or '')
            BlzFrameSetText(HERO_JOURNAL_RECORD_WIDGETS[b_id][d_id].dpsText, tbl.record_dps > 0 and 'DPS: ' .. strRound(tbl.record_dps,1) or '')
        end
    end
end

function UI_HeroJournal_LoadData()
    for i,v in pairs(HERO_DATA) do
        table.insert(HERO_JOURNAL_INDEXES,i)
    end
end

function UI_HeroJournal_CreateRecordsWidget(b_id)
    local r_tbl = {
        [BOSS_DIFFICULTY_HEROIC] = {}
        ,[BOSS_DIFFICULTY_NORMAL] = {}
        ,[BOSS_DIFFICULTY_MYTHIC] = {}
        ,mainFrame = BlzCreateSimpleFrame('RecordWidget_BossImage', HERO_JOURNAL_MAINFRAME, b_id)
    }

    local bossImg = BlzGetFrameByName("RecordWidget_BossImageTexture", b_id)
    
    BlzFrameSetTexture(bossImg, BOSS_DATA[b_id].Journal_Image, 0, true)

    r_tbl[BOSS_DIFFICULTY_HEROIC].mainFrame = BlzCreateSimpleFrame('RecordWidget_DiffImage', r_tbl.mainFrame, b_id * 10 + BOSS_DIFFICULTY_HEROIC)

    BlzFrameSetPoint(r_tbl[BOSS_DIFFICULTY_HEROIC].mainFrame, FRAMEPOINT_LEFT, r_tbl.mainFrame, FRAMEPOINT_RIGHT, 0, 0)
    BlzFrameSetTexture(BlzGetFrameByName("RecordWidget_DiffImageTexture", b_id * 10 + BOSS_DIFFICULTY_HEROIC), 'war3mapImported\\BTN_Heroic.dds', 0, true)

    r_tbl[BOSS_DIFFICULTY_NORMAL].mainFrame = BlzCreateSimpleFrame('RecordWidget_DiffImage', r_tbl.mainFrame, b_id * 10 + BOSS_DIFFICULTY_NORMAL)

    BlzFrameSetPoint(r_tbl[BOSS_DIFFICULTY_NORMAL].mainFrame, FRAMEPOINT_BOTTOM, r_tbl[BOSS_DIFFICULTY_HEROIC].mainFrame, FRAMEPOINT_TOP, 0, 0)
    BlzFrameSetTexture(BlzGetFrameByName("RecordWidget_DiffImageTexture", b_id * 10 + BOSS_DIFFICULTY_NORMAL), 'war3mapImported\\BTN_NormalDiff.dds', 0, true)

    r_tbl[BOSS_DIFFICULTY_MYTHIC].mainFrame = BlzCreateSimpleFrame('RecordWidget_DiffImage', r_tbl.mainFrame, b_id * 10 + BOSS_DIFFICULTY_MYTHIC)

    BlzFrameSetPoint(r_tbl[BOSS_DIFFICULTY_MYTHIC].mainFrame, FRAMEPOINT_TOP, r_tbl[BOSS_DIFFICULTY_HEROIC].mainFrame, FRAMEPOINT_BOTTOM, 0, 0)
    BlzFrameSetTexture(BlzGetFrameByName("RecordWidget_DiffImageTexture", b_id * 10 + BOSS_DIFFICULTY_MYTHIC), 'war3mapImported\\BTN_Mythic.dds', 0, true)

    for _,i in pairs(BOSS_DIFFICULTIES) do
        r_tbl[i].timeFrame = BlzCreateSimpleFrame('RecordWidget_Text', r_tbl.mainFrame, b_id * 100 + i + 10)
        r_tbl[i].timeText = BlzGetFrameByName("RecordWidget_Text_String", b_id * 100 + i + 10)
        BlzFrameSetPoint(r_tbl[i].timeFrame, FRAMEPOINT_LEFT, r_tbl[i].mainFrame, FRAMEPOINT_RIGHT, 0.0025, 0)

        r_tbl[i].dpsFrame = BlzCreateSimpleFrame('RecordWidget_Text', r_tbl.mainFrame, b_id * 100 + i + 20)
        r_tbl[i].dpsText = BlzGetFrameByName("RecordWidget_Text_String", b_id * 100 + i + 20)
        BlzFrameSetPoint(r_tbl[i].dpsFrame, FRAMEPOINT_LEFT, r_tbl[i].timeFrame, FRAMEPOINT_RIGHT, 0.0025, 0)

        BlzFrameSetText(r_tbl[i].timeText, '')
        BlzFrameSetText(r_tbl[i].dpsText, '')
    end

    HERO_JOURNAL_RECORD_WIDGETS[b_id] = r_tbl

    bossImg,r_tbl = nil,nil
end

function UI_HeroJournal_CreateRecordsWidgets()
    for i,_ in ipairs(BOSS_DATA) do
        UI_HeroJournal_CreateRecordsWidget(i)
    end
end

function UI_HeroJournal_PositionateRecordWidgets()
    BlzFrameSetPoint(HERO_JOURNAL_RECORD_WIDGETS[1].mainFrame, FRAMEPOINT_TOPLEFT, HERO_JOURNAL_MAINFRAME, FRAMEPOINT_TOP, -0.18, -0.125)
    for i = 2, #HERO_JOURNAL_RECORD_WIDGETS do
        if (i-1) - math.floor((i-1)/3)*3 == 0 then
            BlzFrameSetPoint(HERO_JOURNAL_RECORD_WIDGETS[i].mainFrame, FRAMEPOINT_TOP, HERO_JOURNAL_RECORD_WIDGETS[i-3].mainFrame, FRAMEPOINT_BOTTOM, 0, -0.06)
        else
            BlzFrameSetPoint(HERO_JOURNAL_RECORD_WIDGETS[i].mainFrame, FRAMEPOINT_LEFT, HERO_JOURNAL_RECORD_WIDGETS[i-1].mainFrame, FRAMEPOINT_RIGHT, 0.19, 0)
        end
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

    UI_HeroJournal_CreateRecordsWidgets()
    UI_HeroJournal_PositionateRecordWidgets()

    heroImage,mainTexture,heroName = nil,nil,nil

    UI_CreateHeroJournal = nil
end