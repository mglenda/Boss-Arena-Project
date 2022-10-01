
HERO_JOURNAL_MAINFRAME = nil
HERO_JOURNAL_IMAGE = nil
HERO_JOURNAL_NAME = nil
HERO_JOURNAL_BUTTON_CHOOSE = nil
HERO_JOURNAL_BUTTON_NEXT = nil
HERO_JOURNAL_TRIGGER_CLICK = CreateTrigger()
HERO_JOURNAL_INDEXES = {}

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
    UI_HeroJournal_LoadData = nil
    UI_HeroJournal_Inject = nil
    UI_HeroJournal_Next = nil

    UI_HeroJournal_Flush = nil
end

function UI_HeroJournal_Inject(h_id)
    BlzFrameSetTexture(HERO_JOURNAL_IMAGE, HERO_DATA[h_id].Journal_Image, 0, true)
    BlzFrameSetText(HERO_JOURNAL_NAME, HERO_DATA[h_id].Journal_Title)
    HERO_TYPE = h_id
    HERO_LoadProfile()
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

    BlzFrameSetPoint(heroImage, FRAMEPOINT_LEFT, HERO_JOURNAL_MAINFRAME, FRAMEPOINT_LEFT, 0.03, -0.02)
    BlzFrameSetPoint(heroName, FRAMEPOINT_TOP, HERO_JOURNAL_MAINFRAME, FRAMEPOINT_TOP, 0, -0.01)

    BlzFrameSetAbsPoint(HERO_JOURNAL_MAINFRAME, FRAMEPOINT_BOTTOMLEFT, -0.14, 0)

    BlzTriggerRegisterFrameEvent(HERO_JOURNAL_TRIGGER_CLICK, HERO_JOURNAL_BUTTON_NEXT, FRAMEEVENT_CONTROL_CLICK)
    BlzTriggerRegisterFrameEvent(HERO_JOURNAL_TRIGGER_CLICK, HERO_JOURNAL_BUTTON_CHOOSE, FRAMEEVENT_CONTROL_CLICK)

    BlzFrameSetTexture(mainTexture, 'war3mapImported\\HeroesJournal_Background.dds', 0, true)

    heroImage,mainTexture,heroName = nil,nil,nil

    UI_CreateHeroJournal = nil
end