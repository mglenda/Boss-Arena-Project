--ability widgets
--minion widgets
--buffs widgets

BOSS_LEGEND_DATA = {
    [BOSS_BEASTMASTER_ID] = {
        [1] = {
            title = 'Phase 1'
            ,description = 'This is my first phase.'
            ,abilities = {
                ABCODE_SUMMONBEASTS
                ,ABCODE_CODOWAVE
            }
            ,minions = {
                FourCC('n000')
                ,FourCC('n001')
                ,FourCC('n002')
                ,FourCC('n003')
            }
            ,buffs = {
                'CALLOFALPHA'
            }
        }
        ,[2] = {
            title = 'Phase 2'
            ,description = 'This is my second phase.'
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

function UI_BossLegend_LoadFrames(b_id)
    BlzFrameSetText(BOSS_LEGEND_PAGES.bossName, BOSS_DATA[b_id].name)
    BlzFrameSetTexture(BOSS_LEGEND_PAGES.bossImage, BOSS_DATA[b_id].Legend_Texture, 0, true)

    BOSS_LEGEND_PAGES.container = BlzCreateSimpleFrame('BossLegend_Container', BOSS_LEGEND_MAINFRAME, 0)
    BlzFrameSetPoint(BOSS_LEGEND_PAGES.container, FRAMEPOINT_CENTER, BOSS_LEGEND_MAINFRAME, FRAMEPOINT_CENTER, 0, 0)

    BOSS_LEGEND_PAGES.chapters = {}
    for i,v in ipairs(BOSS_LEGEND_DATA[b_id]) do
        print(i)
        local chapter = BlzCreateSimpleFrame('BossLegend_ChapterFrame', BOSS_LEGEND_PAGES.container, i)
        BlzFrameSetText(BlzGetFrameByName('BossLegend_ChapterFrameText', i), v.title)
        if BOSS_LEGEND_PAGES.chapters[i-1] then
            BlzFrameSetPoint(chapter, FRAMEPOINT_TOP, BOSS_LEGEND_PAGES.chapters[i-1] , FRAMEPOINT_BOTTOM, 0, 0)
        else
            BlzFrameSetPoint(chapter, FRAMEPOINT_TOPLEFT, BOSS_LEGEND_PAGES.bossImage, FRAMEPOINT_TOPRIGHT, 0.06, -0.02)
        end
        table.insert(BOSS_LEGEND_PAGES.chapters,chapter)
    end
end

function UI_BossLegend_EraseFrames()
    BlzDestroyFrame(BOSS_LEGEND_PAGES.container)
end

function UI_BossLegendShow(b_id)
    UI_BossLegend_LoadFrames(b_id)
    BOSS_LEGEND_PAGES.boss_id = b_id
    UI_Hide()
    BlzFrameSetVisible(BOSS_LEGEND_MAINFRAME, true)
    BlzFrameSetAlpha(BOSS_LEGEND_MAINFRAME, 255)
end

function UI_BossLegendHide()
    UI_BossLegend_EraseFrames()
    BlzFrameSetVisible(BOSS_LEGEND_MAINFRAME, false)
    UI_Show()
end