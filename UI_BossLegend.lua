--ability widgets
--minion widgets
--buffs widgets

BOSS_LEGEND_DATA = {
    BOSS_BEASTMASTER_ID = {
        [1] = {
            title = 'Phase 1'
            ,description = ''
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
            ,description = ''
        }
    }
    ,BOSS_DRUID_ID = {

    }
    ,BOSS_SHAMAN_ID = {

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

    BlzFrameSetPoint(bossImage, FRAMEPOINT_LEFT, BOSS_LEGEND_MAINFRAME, FRAMEPOINT_LEFT, 0.02, -0.02)

    BlzFrameSetVisible(BOSS_LEGEND_MAINFRAME, false)
    bossImage = nil
end

function UI_BossLegendShow(b_id)
    BOSS_LEGEND_PAGES.boss_id = b_id
    UI_Hide()
    BlzFrameSetVisible(BOSS_LEGEND_MAINFRAME, true)
    BlzFrameSetAlpha(BOSS_LEGEND_MAINFRAME, 255)
end

function UI_BossLegendHide()
    BlzFrameSetVisible(BOSS_LEGEND_MAINFRAME, false)
    UI_Show()
end