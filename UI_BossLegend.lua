--ability widgets
--minion widgets
--buffs widgets

BOSS_LEGEND_DATA = {
    [BOSS_BEASTMASTER_ID] = {
        [1] = {
            title = 'Call of the Wild'
            ,description = 'This is my first phase.'
            ,font_cl = BlzConvertColor(255, 150, 120, 0)
            ,content = {
                [ABCODE_SUMMONBEASTS] = 'ability'
                ,[ABCODE_CODOWAVE] = 'ability'
                ,[FourCC('n000')] = 'minion'
                ,[FourCC('n001')] = 'minion'
                ,[FourCC('n002')] = 'minion'
                ,[FourCC('n003')] = 'minion'
                ,['CALLOFALPHA'] = 'buff'
            }
        }
        ,[2] = {
            title = 'Berserk'
            ,description = 'This is my second phase.'
            ,font_cl = BlzConvertColor(255, 160, 50, 0)
        }
    }
    ,[BOSS_DRUID_ID] = {

    }
    ,[BOSS_SHAMAN_ID] = {

    }
}
BOSS_LEGEND_MAINFRAME = nil
BOSS_LEGEND_PAGES = {}

function UI_BossLegend_Initialize()
    UI_CreateBossLegend()
    UI_BossLegend_Initialize = nil
end

function UI_CreateBossLegend()
    BOSS_LEGEND_MAINFRAME = BlzCreateSimpleFrame('BossLegend_Frame', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    BlzFrameSetAbsPoint(BOSS_LEGEND_MAINFRAME, FRAMEPOINT_BOTTOMLEFT, -0.14, 0)

    local bossImage = BlzCreateSimpleFrame('BossLegend_BossImage', BOSS_LEGEND_MAINFRAME, 0)
    BOSS_LEGEND_PAGES.bossImage = BlzGetFrameByName("BossLegend_BossImageTexture", 0)

    local bossName = BlzCreateSimpleFrame('BossLegend_Name', BOSS_LEGEND_MAINFRAME, 0)
    BOSS_LEGEND_PAGES.bossName = BlzGetFrameByName("BossLegend_Name_Text", 0)

    BlzFrameSetPoint(bossImage, FRAMEPOINT_LEFT, BOSS_LEGEND_MAINFRAME, FRAMEPOINT_LEFT, 0.02, -0.02)
    BlzFrameSetPoint(bossName, FRAMEPOINT_TOP, BOSS_LEGEND_MAINFRAME, FRAMEPOINT_TOP, 0, -0.01)

    BlzFrameSetVisible(BOSS_LEGEND_MAINFRAME, false)
    bossImage,bossName = nil,nil
end

function UI_BossLegend_LoadChapters()
    BlzFrameSetText(BOSS_LEGEND_PAGES.bossName, BOSS_DATA[BOSS_LEGEND_PAGES.boss_id].name)
    BlzFrameSetTexture(BOSS_LEGEND_PAGES.bossImage, BOSS_DATA[BOSS_LEGEND_PAGES.boss_id].Legend_Texture, 0, true)

    BOSS_LEGEND_PAGES.container = BlzCreateSimpleFrame('BossLegend_Container', BOSS_LEGEND_MAINFRAME, 0)
    BlzFrameSetPoint(BOSS_LEGEND_PAGES.container, FRAMEPOINT_CENTER, BOSS_LEGEND_MAINFRAME, FRAMEPOINT_CENTER, 0, 0)

    BOSS_LEGEND_PAGES.chapterTrigger = CreateTrigger()
    TriggerAddAction(BOSS_LEGEND_PAGES.chapterTrigger, UI_BossLegend_ChapterClick)

    BOSS_LEGEND_PAGES.chapters = {}
    for i,v in ipairs(BOSS_LEGEND_DATA[BOSS_LEGEND_PAGES.boss_id]) do
        local chapter = BlzCreateSimpleFrame('BossLegend_ChapterFrame', BOSS_LEGEND_PAGES.container, i)
        BlzTriggerRegisterFrameEvent(BOSS_LEGEND_PAGES.chapterTrigger, chapter, FRAMEEVENT_CONTROL_CLICK)
        local img = BlzCreateSimpleFrame('BossLegend_ChapterImage', chapter, i)

        BlzFrameSetTexture(BlzGetFrameByName('BossLegend_ChapterImageTexture', i), 'war3mapImported\\EmblemTexture.dds', 0, true)
        BlzFrameSetText(BlzGetFrameByName('BossLegend_ChapterFrameText', i), v.title)
        BlzFrameSetTextColor(BlzGetFrameByName('BossLegend_ChapterFrameText', i), v.font_cl)

        BlzFrameSetPoint(img, FRAMEPOINT_LEFT, chapter, FRAMEPOINT_LEFT, 0.02, 0)
        
        if BOSS_LEGEND_PAGES.chapters[i-1] then
            BlzFrameSetPoint(chapter, FRAMEPOINT_TOP, BOSS_LEGEND_PAGES.chapters[i-1] , FRAMEPOINT_BOTTOM, 0, -0.02)
        else
            BlzFrameSetPoint(chapter, FRAMEPOINT_TOPLEFT, BOSS_LEGEND_PAGES.bossImage, FRAMEPOINT_TOPRIGHT, 0.12, -0.02)
        end
        table.insert(BOSS_LEGEND_PAGES.chapters,chapter)
    end
end

function UI_BossLegend_LoadChapter(c_id)
    BOSS_LEGEND_PAGES.container = BlzCreateSimpleFrame('BossLegend_Container', BOSS_LEGEND_MAINFRAME, 0)
    BlzFrameSetPoint(BOSS_LEGEND_PAGES.container, FRAMEPOINT_CENTER, BOSS_LEGEND_MAINFRAME, FRAMEPOINT_CENTER, 0, 0)

    BOSS_LEGEND_PAGES.chapterTrigger = CreateTrigger()
    TriggerAddAction(BOSS_LEGEND_PAGES.chapterTrigger, UI_BossLegend_ContentClick)

    BOSS_LEGEND_PAGES.curChapter = BlzCreateSimpleFrame('BossLegend_ChapterFrame', BOSS_LEGEND_PAGES.container, 0)
    BlzTriggerRegisterFrameEvent(BOSS_LEGEND_PAGES.chapterTrigger, BOSS_LEGEND_PAGES.curChapter, FRAMEEVENT_CONTROL_CLICK)

    local img = BlzCreateSimpleFrame('BossLegend_ChapterImage', BOSS_LEGEND_PAGES.curChapter, 0)

    BlzFrameSetTexture(BlzGetFrameByName('BossLegend_ChapterImageTexture', 0), 'war3mapImported\\EmblemTexture.dds', 0, true)
    BlzFrameSetTexture(BlzGetFrameByName('BossLegend_ChapterFrameTexture', 0), 'war3mapImported\\ChapterTextureActive.dds', 0, true)
    BlzFrameSetText(BlzGetFrameByName('BossLegend_ChapterFrameText', 0), BOSS_LEGEND_DATA[BOSS_LEGEND_PAGES.boss_id][c_id].title)
    BlzFrameSetTextColor(BlzGetFrameByName('BossLegend_ChapterFrameText', 0), BOSS_LEGEND_DATA[BOSS_LEGEND_PAGES.boss_id][c_id].font_cl)

    BlzFrameSetPoint(img, FRAMEPOINT_LEFT, BOSS_LEGEND_PAGES.curChapter, FRAMEPOINT_LEFT, 0.02, 0)

    BlzFrameSetPoint(BOSS_LEGEND_PAGES.curChapter, FRAMEPOINT_TOPLEFT, BOSS_LEGEND_PAGES.bossImage, FRAMEPOINT_TOPRIGHT, 0.12, -0.02)
end

function UI_BossLegend_ContentClick()
    local chapter = BlzGetTriggerFrame()
    if chapter == BOSS_LEGEND_PAGES.curChapter then
        UI_BossLegend_EraseFrames()
        UI_BossLegend_LoadChapters()
    else

    end
    chapter = nil
end

function UI_BossLegend_ChapterClick()
    local chapter = BlzGetTriggerFrame()
    local c_i = IsInArray(chapter,BOSS_LEGEND_PAGES.chapters)
    UI_BossLegend_EraseFrames()
    UI_BossLegend_LoadChapter(c_i)
    chapter,c_i = nil,nil
end

function UI_BossLegend_EraseFrames()
    BlzDestroyFrame(BOSS_LEGEND_PAGES.container)
    DestroyTrigger(BOSS_LEGEND_PAGES.chapterTrigger)
end

function UI_BossLegendShow(b_id)
    BOSS_LEGEND_PAGES.boss_id = b_id
    UI_BossLegend_LoadChapters()
    UI_Hide()
    BlzFrameSetVisible(BOSS_LEGEND_MAINFRAME, true)
    BlzFrameSetAlpha(BOSS_LEGEND_MAINFRAME, 255)
end

function UI_BossLegendHide()
    UI_BossLegend_EraseFrames()
    BlzFrameSetVisible(BOSS_LEGEND_MAINFRAME, false)
    UI_Show()
end