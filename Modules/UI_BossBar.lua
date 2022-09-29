----------------------------------------------------
----------------------------------------------------
----------------------------------------------------

function BOSSBAR_BarCreate()
    local mainFrame = BlzCreateSimpleFrame('BossBar_Border', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    local bar = BlzCreateSimpleFrame('BossBar_Bar', mainFrame, 0)
    local barText = BlzCreateSimpleFrame('BossBar_Bar_TextFrame', bar, 0)
    local nameText = BlzCreateSimpleFrame('BossBar_NameFrame', bar, 0)

    BlzFrameSetPoint(mainFrame, FRAMEPOINT_TOP, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), FRAMEPOINT_TOP, 0, -0.005)
    BlzFrameSetPoint(bar, FRAMEPOINT_CENTER, mainFrame, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(barText, FRAMEPOINT_CENTER, bar, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(nameText, FRAMEPOINT_CENTER, bar, FRAMEPOINT_CENTER, 0, 0)

    barText = BlzGetFrameByName('BossBar_Bar_Text', 0)

    BOSS_BAR = {
        mainFrame = mainFrame
        ,bar = bar
        ,barTextFrame = barText
        ,nameTextFrame = nameText
        ,nameText = BlzGetFrameByName('BossBar_NameText', 0)
        ,barText = BlzGetFrameByName('BossBar_Bar_Text', 0)
    }
    mainFrame,bar,barText,nameText = nil,nil,nil,nil
    BOSSBAR_Hide()

    BOSSBAR_BarCreate = nil
end

function BOSSBAR_Hide()
    BlzFrameSetVisible(BOSS_BAR.mainFrame, false)
end

function BOSSBAR_Show(name,theme)
    theme = theme or DBM_BAR_clRED
    BlzFrameSetTextColor(BOSS_BAR.nameText, theme.fontColor)
    BlzFrameSetTextColor(BOSS_BAR.barText, theme.fontColor)
    BlzFrameSetText(BOSS_BAR.nameText,name or '')
    BlzFrameSetTexture(BOSS_BAR.bar, theme.texture, 0, true)
    BlzFrameSetVisible(BOSS_BAR.mainFrame, true)
end

function BOSSBAR_Set(value,perc,maxValue,decplaces)
    local s = ''
    if perc then 
        s = strRound(value,decplaces) .. '%%'
    else
        s = strRound(value,decplaces) .. '/' .. strRound(maxValue,decplaces)
        value = value / maxValue
    end
    BlzFrameSetValue(BOSS_BAR.bar, value)
    BlzFrameSetText(BOSS_BAR.barText, s)
    s = nil
end