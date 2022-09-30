----------------------------------------------------
--------------------UI SETUP------------------------
----------------------------------------------------

function UI_HideOriginalUI()
    UI_HideOriginalFrames()
    UI_HideOriginalFrames = nil
    UI_HideOriginalUI = nil
end

function UI_HideOriginalFrames()
    BlzHideOriginFrames(true)
    BlzFrameSetVisible(BlzGetFrameByName("ConsoleUIBackdrop",0), false)
    BlzFrameSetScale(BlzGetFrameByName("ConsoleUI", 0), 0.001)
    BlzEnableUIAutoPosition(false)
end

function UI_HideAllMenus()
    TALENTS_UI_Hide()
    BOSS_HideJournal()
end

function UI_Load(hero_type)
    for h_type,t in pairs(HERO_DATA) do
        if h_type == hero_type then
            HERO_DATA[h_type].UI_registerFunc()
        else
            HERO_DATA[h_type].UI_memoryCleanFunc()
        end
    end
    UI_LoadAbilityTrigger_Focus()
    UI_LoadHeroStatistics()
    UI_CreateTargetDetails()
    UI_CreateHeroDetails()
    UI_InitializeRefreshDetails()
    UI_CreatePopUps(hero_type)
    UI_Load = nil
end

UI_POPUPS = {}

function UI_CreatePopUps(hero_type)
    if HERO_DATA[hero_type].PopUps then
        for i,v in pairs(HERO_DATA[hero_type].PopUps) do
            local popUp = BlzCreateSimpleFrame('Ability_PopUp', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), i) 
            BlzFrameSetTexture(BlzGetFrameByName('Ability_PopUpTexture', i), v.texture, 0, true)
            if v.hideFunc and v.showFunc then
                UI_POPUPS[v.key or i] = {
                    popUp = popUp
                    ,hideFunc = v.hideFunc
                    ,showFunc = v.showFunc
                    ,inc = 1
                }
                BlzFrameSetVisible(popUp, false)
            else
                BlzDestroyFrame(popUp)
            end
            popUp = nil
        end
        UI_RegisterPopUps()
    end
    UI_RegisterPopUps = nil
    UI_CreatePopUps = nil
end

function UI_RegisterPopUps()
    local trig = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(trig, 0.1)
    TriggerAddAction(trig,UI_RefreshPopUps)

    trig = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(trig, 0.01)
    TriggerAddAction(trig,UI_GlowingPopUps)

    trig = nil
end

function UI_GlowingPopUps()
    for i,v in pairs(UI_POPUPS) do
        if BlzFrameIsVisible(v.popUp) then
            local alpha = BlzFrameGetAlpha(v.popUp)
            v.inc = (alpha <= 10 or alpha == 255) and v.inc * (-1) or v.inc
            BlzFrameSetAlpha(v.popUp, alpha + v.inc)
        end
    end
end

function UI_RefreshPopUps()
    local c,x,y = 0,0.4,0.5
    for i,v in pairs(UI_POPUPS) do
        if v.showFunc() and not(BlzFrameIsVisible(v.popUp)) then
            v.inc = 3
            BlzFrameSetVisible(v.popUp, true)
            x = x - (BlzFrameGetWidth(v.popUp)/2)
            c = c + 1
        elseif v.hideFunc() and BlzFrameIsVisible(v.popUp) then
            BlzFrameSetVisible(v.popUp, false)
        end
    end
    if c > 0 then
        for i,v in pairs(UI_POPUPS) do
            if BlzFrameIsVisible(v.popUp) then
                BlzFrameClearAllPoints(v.popUp)
                BlzFrameSetAbsPoint(v.popUp, FRAMEPOINT_LEFT, x, y)
                x = x + BlzFrameGetWidth(v.popUp)
            end
        end
    end
    c,x,y = nil,nil,nil
end

HERO_DETAILS_DATA = nil
TARGET_DETAILS_DATA = nil

function UI_InitializeRefreshDetails()
    local trg = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(trg, 0.1)
    TriggerAddAction(trg, UI_RefreshDetails)
    trg = nil
    UI_InitializeRefreshDetails = nil
end

function UI_RefreshIcons(unit)
    if unit == HERO then
        BlzFrameSetTexture(HERO_DETAILS_DATA.stats.stat_powerTexture, ATTRIBUTES[Get_UnitPrimaryAttribute(HERO)].icon or ATTRIBUTE_UNDEFINED_ICON, 0, true)
        BlzFrameSetTexture(HERO_DETAILS_DATA.unitIconTexture, UNITS_DATA[GetUnitTypeId(HERO)].ICON, 0, true)
    else
        BlzFrameSetTexture(TARGET_DETAILS_DATA.stats.stat_powerTexture, ATTRIBUTES[Get_UnitPrimaryAttribute(TARGET)].icon or ATTRIBUTE_UNDEFINED_ICON, 0, true)
        BlzFrameSetTexture(TARGET_DETAILS_DATA.unitIconTexture, UNITS_DATA[GetUnitTypeId(TARGET)].ICON, 0, true)
    end
end

function UI_RefreshDetails()
    if TARGET then
        if not(BlzFrameIsVisible(TARGET_DETAILS_DATA.mainFrame)) then
            BlzFrameSetVisible(TARGET_DETAILS_DATA.mainFrame, true)
        end

        local te = UNIT_GetEnergy(TARGET)
        local te_c = UNIT_GetEnergyCap(TARGET)
        local te_t = UNIT_GetEnergyTheme(TARGET)

        if te_c then
            if not(BlzFrameIsVisible(TARGET_DETAILS_DATA.energy_frame)) then
                BlzFrameSetVisible(TARGET_DETAILS_DATA.energy_frame, true)
            end
            UI_EnergyBar_ChangeTheme_Target(te_t)
            BlzFrameSetValue(TARGET_DETAILS_DATA.energy_bar, tostring((te / te_c) * 100))
            BlzFrameSetText(TARGET_DETAILS_DATA.energy_bar_value_text, tostring(math.floor(te))..'/'..tostring(math.floor(te_c)))
        else    
            if BlzFrameIsVisible(TARGET_DETAILS_DATA.energy_frame) then
                BlzFrameSetVisible(TARGET_DETAILS_DATA.energy_frame, false)
            end
        end

        te,te_c,te_t = nil,nil,nil

        BlzFrameSetValue(TARGET_DETAILS_DATA.bar, GetUnitLifePercent(TARGET))
        BlzFrameSetText(TARGET_DETAILS_DATA.unitNameText, GetUnitName(TARGET))
        BlzFrameSetText(TARGET_DETAILS_DATA.unitHPText, tostring(math.floor(GetUnitStateSwap(UNIT_STATE_LIFE, TARGET)))..'/'..tostring(math.floor(GetUnitStateSwap(UNIT_STATE_MAX_LIFE, TARGET))))
        BlzFrameSetText(TARGET_DETAILS_DATA.unitRegText, strRound(GetUnitLifePercent(TARGET),1) .. '%%'.. ' (' .. BlzGetUnitRealField(TARGET, UNIT_RF_HIT_POINTS_REGENERATION_RATE)..'/sec)')

        BlzFrameSetText(TARGET_DETAILS_DATA.stats.stat_powerText,GetHeroStatBJ(ATTRIBUTES[Get_UnitPrimaryAttribute(TARGET)].stat, TARGET, true))
        BlzFrameSetText(TARGET_DETAILS_DATA.stats.stat_critText,Get_UnitCritRate(TARGET)..'%%')
        BlzFrameSetText(TARGET_DETAILS_DATA.stats.stat_resistText,math.floor(BlzGetUnitArmor(TARGET))..'%%')
        BlzFrameSetText(TARGET_DETAILS_DATA.stats.stat_dmgText,Get_UnitBaseDamage(TARGET))

        UI_RefreshBuffs(TARGET,TARGET_DETAILS_DATA.buffs)
    end
    --HERO

    local e = UNIT_GetEnergy(HERO)
    local e_c = UNIT_GetEnergyCap(HERO)
    local e_t = UNIT_GetEnergyTheme(HERO)

    if e_c then
        if not(BlzFrameIsVisible(HERO_DETAILS_DATA.energy_frame)) then
            BlzFrameSetVisible(HERO_DETAILS_DATA.energy_frame, true)
        end
        UI_EnergyBar_ChangeTheme_Hero(e_t)
        BlzFrameSetValue(HERO_DETAILS_DATA.energy_bar, tostring((e / e_c) * 100))
        BlzFrameSetText(HERO_DETAILS_DATA.energy_bar_value_text, tostring(math.floor(e))..'/'..tostring(math.floor(e_c)))
    else    
        if BlzFrameIsVisible(HERO_DETAILS_DATA.energy_frame) then
            BlzFrameSetVisible(HERO_DETAILS_DATA.energy_frame, false)
        end
    end

    e,e_c,e_t = nil,nil,nil

    BlzFrameSetValue(HERO_DETAILS_DATA.bar, GetUnitLifePercent(HERO))
    BlzFrameSetText(HERO_DETAILS_DATA.unitNameText, GetUnitName(HERO))
    BlzFrameSetText(HERO_DETAILS_DATA.unitHPText, tostring(math.floor(GetUnitStateSwap(UNIT_STATE_LIFE, HERO)))..'/'..tostring(math.floor(GetUnitStateSwap(UNIT_STATE_MAX_LIFE, HERO))))
    BlzFrameSetText(HERO_DETAILS_DATA.unitRegText, strRound(GetUnitLifePercent(HERO),1) .. '%%'.. ' (' .. BlzGetUnitRealField(HERO, UNIT_RF_HIT_POINTS_REGENERATION_RATE)..'/sec)')

    BlzFrameSetText(HERO_DETAILS_DATA.stats.stat_powerText,GetHeroStatBJ(ATTRIBUTES[Get_UnitPrimaryAttribute(HERO)].stat, HERO, true))
    BlzFrameSetText(HERO_DETAILS_DATA.stats.stat_critText,Get_UnitCritRate(HERO)..'%%')
    BlzFrameSetText(HERO_DETAILS_DATA.stats.stat_resistText,math.floor(BlzGetUnitArmor(HERO))..'%%')
    BlzFrameSetText(HERO_DETAILS_DATA.stats.stat_dmgText,Get_UnitBaseDamage(HERO))

    UI_RefreshBuffs(HERO,HERO_DETAILS_DATA.buffs)
end

function UI_EnergyBar_ChangeTheme_Hero(theme)
    theme = theme.texture and theme or DBM_BAR_clGRAY
    BlzFrameSetTexture(HERO_DETAILS_DATA.energy_bar, theme.texture, 0, true)
    BlzFrameSetTextColor(HERO_DETAILS_DATA.energy_bar_value_text, theme.fontColor)
end

function UI_EnergyBar_ChangeTheme_Target(theme)
    theme = theme.texture and theme or DBM_BAR_clGRAY
    BlzFrameSetTexture(TARGET_DETAILS_DATA.energy_bar, theme.texture, 0, true)
    BlzFrameSetTextColor(TARGET_DETAILS_DATA.energy_bar_value_text, theme.fontColor)
end

function UI_RefreshBuffs(unit,frames)
    local Buff_Tbl = {}
    for i,v in pairs(DEBUFFS) do
        if v.target == unit and not(IsInArray_CustField(v.name,Buff_Tbl,'name')) then
            local tbl = {
                ['name'] = v.name
                ,stackCount = BUFF_GetStacksCount(unit,v.name)
                ,priority = v.debuffPriority
                ,isDebuff = v.isDebuff
                ,txtColor = v.txtColor or DEBUFFS_DEFAULT_TEXT_COLOR
                ,ICON = v.ICON
            }
            table.insert(Buff_Tbl,tbl)
            tbl = nil
        end
    end
    table.sort (Buff_Tbl, function (k1, k2) return k1.priority < k2.priority end )
    local c = 1
    for i,v in pairs(Buff_Tbl) do
        if c <= UI_BUFF_COUNT and v.ICON then
            BlzFrameSetTexture(frames[c].buffTexture, v.ICON, 0, true)
            BlzFrameSetTextColor(frames[c].buffText, v.txtColor)
            BlzFrameSetText(frames[c].buffText, v.stackCount > 1 and I2S(v.stackCount) or '')
            if not(BlzFrameIsVisible(frames[c].buffFrame)) then
                BlzFrameSetVisible(frames[c].buffFrame, true)
            end
            c = c + 1
        end
    end

    if c < UI_BUFF_COUNT then
        for i = c,UI_BUFF_COUNT do
            if BlzFrameIsVisible(frames[i].buffFrame) then
                BlzFrameSetVisible(frames[i].buffFrame, false)
            end
        end
    end
    Buff_Tbl,c = nil,nil
end

function UI_CreateTargetDetails()
    local fw,fh = UI_GetAbilityFrameWidthHeight()
    local x,y = (0.4 - (2 * fw)) + 4*fw,0
    TARGET_DETAILS_DATA = UI_CreateUnitDetails(1)
    TARGET_DETAILS_DATA.buffs = UI_CreateBuffDetails(1,TARGET_DETAILS_DATA.mainFrame)
    TARGET_DETAILS_DATA.stats = UI_CreateStatDetails(1,TARGET_DETAILS_DATA.mainFrame)

    BlzFrameClearAllPoints(TARGET_DETAILS_DATA.mainFrame)
    BlzFrameSetAbsPoint(TARGET_DETAILS_DATA.mainFrame, FRAMEPOINT_BOTTOMLEFT, x, y)
    BlzFrameSetVisible(TARGET_DETAILS_DATA.mainFrame, false)
    fw,fh,x,y = nil,nil,nil,nil

    local prev = TARGET_DETAILS_DATA.buffs[1].buffFrame
    BlzFrameSetPoint(prev, FRAMEPOINT_TOPRIGHT, TARGET_DETAILS_DATA.mainFrame, FRAMEPOINT_TOPRIGHT, -0.006, -0.0045)
    for i=2,#TARGET_DETAILS_DATA.buffs do
        if (i-1) - math.floor((i-1)/3)*3 == 0 then
            BlzFrameSetPoint(TARGET_DETAILS_DATA.buffs[i].buffFrame, FRAMEPOINT_TOP, TARGET_DETAILS_DATA.buffs[i-3].buffFrame, FRAMEPOINT_BOTTOM, 0, 0)
        else
            BlzFrameSetPoint(TARGET_DETAILS_DATA.buffs[i].buffFrame, FRAMEPOINT_RIGHT, prev, FRAMEPOINT_LEFT, -0.006, 0)
        end
        prev = TARGET_DETAILS_DATA.buffs[i].buffFrame
    end

    BlzFrameSetPoint(TARGET_DETAILS_DATA.stats.mainFrame, FRAMEPOINT_LEFT, TARGET_DETAILS_DATA.mainFrame, FRAMEPOINT_LEFT, 0, 0)

    TARGET_DETAILS_DATA.energy_frame = BlzCreateSimpleFrame('Details_Energy_BarFrame', TARGET_DETAILS_DATA.mainFrame, 1)
    TARGET_DETAILS_DATA.energy_bar = BlzCreateSimpleFrame('Details_Energy_Bar', TARGET_DETAILS_DATA.energy_frame, 1)
    TARGET_DETAILS_DATA.energy_bar_value = BlzCreateSimpleFrame('Details_Energy_Bar_Value', TARGET_DETAILS_DATA.energy_bar, 1)

    BlzFrameSetPoint(TARGET_DETAILS_DATA.energy_frame, FRAMEPOINT_BOTTOM, TARGET_DETAILS_DATA.barFrame, FRAMEPOINT_TOP, 0, 0)
    BlzFrameSetPoint(TARGET_DETAILS_DATA.energy_bar, FRAMEPOINT_CENTER, TARGET_DETAILS_DATA.energy_frame, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(TARGET_DETAILS_DATA.energy_bar_value, FRAMEPOINT_CENTER, TARGET_DETAILS_DATA.energy_bar, FRAMEPOINT_CENTER, 0, 0)
    TARGET_DETAILS_DATA.energy_bar_value_text = BlzGetFrameByName('Details_Energy_Bar_Value_Text', 1)

    prev = nil

    UI_CreateTargetDetails = nil
end

function UI_CreateHeroDetails()
    HERO_DETAILS_DATA = UI_CreateUnitDetails(0)
    HERO_DETAILS_DATA.buffs = UI_CreateBuffDetails(0,HERO_DETAILS_DATA.mainFrame)
    HERO_DETAILS_DATA.stats = UI_CreateStatDetails(0,HERO_DETAILS_DATA.mainFrame)

    local prev = HERO_DETAILS_DATA.buffs[1].buffFrame
    BlzFrameSetPoint(prev, FRAMEPOINT_TOPLEFT, HERO_DETAILS_DATA.mainFrame, FRAMEPOINT_TOPLEFT, 0.006, -0.0045)
    for i=2,#HERO_DETAILS_DATA.buffs do
        if (i-1) - math.floor((i-1)/3)*3 == 0 then
            BlzFrameSetPoint(HERO_DETAILS_DATA.buffs[i].buffFrame, FRAMEPOINT_TOP, HERO_DETAILS_DATA.buffs[i-3].buffFrame, FRAMEPOINT_BOTTOM, 0, 0)
        else
            BlzFrameSetPoint(HERO_DETAILS_DATA.buffs[i].buffFrame, FRAMEPOINT_LEFT, prev, FRAMEPOINT_RIGHT, 0.006, 0)
        end
        prev = HERO_DETAILS_DATA.buffs[i].buffFrame
    end

    BlzFrameSetPoint(HERO_DETAILS_DATA.stats.mainFrame, FRAMEPOINT_RIGHT, HERO_DETAILS_DATA.mainFrame, FRAMEPOINT_RIGHT, 0, 0)

    HERO_DETAILS_DATA.energy_frame = BlzCreateSimpleFrame('Details_Energy_BarFrame', HERO_DETAILS_DATA.mainFrame, 0)
    HERO_DETAILS_DATA.energy_bar = BlzCreateSimpleFrame('Details_Energy_Bar', HERO_DETAILS_DATA.energy_frame, 0)
    HERO_DETAILS_DATA.energy_bar_value = BlzCreateSimpleFrame('Details_Energy_Bar_Value', HERO_DETAILS_DATA.energy_bar, 0)

    BlzFrameSetPoint(HERO_DETAILS_DATA.energy_frame, FRAMEPOINT_BOTTOM, HERO_DETAILS_DATA.barFrame, FRAMEPOINT_TOP, 0, 0)
    BlzFrameSetPoint(HERO_DETAILS_DATA.energy_bar, FRAMEPOINT_CENTER, HERO_DETAILS_DATA.energy_frame, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(HERO_DETAILS_DATA.energy_bar_value, FRAMEPOINT_CENTER, HERO_DETAILS_DATA.energy_bar, FRAMEPOINT_CENTER, 0, 0)
    HERO_DETAILS_DATA.energy_bar_value_text = BlzGetFrameByName('Details_Energy_Bar_Value_Text', 0)

    prev = nil
    UI_CreateHeroDetails = nil
end

function UI_CreateStatDetails(id,parent)
    local mainFrame = BlzCreateSimpleFrame('Stats_Frame', parent, id)
    local mainFrameTexture = BlzGetFrameByName('Stats_Texture', id)
    local stat_dmg = BlzCreateSimpleFrame('Stats_StatFrame', mainFrame, (id*10) + UI_STAT_DMG)
    local stat_power = BlzCreateSimpleFrame('Stats_StatFrame', mainFrame, (id*10) + UI_STAT_POWER)
    local stat_resist = BlzCreateSimpleFrame('Stats_StatFrame', mainFrame, (id*10) + UI_STAT_RESIST)
    local stat_crit = BlzCreateSimpleFrame('Stats_StatFrame', mainFrame, (id*10) + UI_STAT_CRIT)
    local tbl = {
        mainFrame = mainFrame
        ,mainFrameTexture = mainFrameTexture
        ,stat_dmg = stat_dmg
        ,stat_dmgText = BlzGetFrameByName('Stats_StatText', (id*10) + UI_STAT_DMG)
        ,stat_dmgTexture = BlzGetFrameByName('Stats_StatTexture', (id*10) + UI_STAT_DMG)
        ,stat_dmgListener = BlzGetFrameByName('Stats_FrameListener', (id*10) + UI_STAT_DMG)
        ,stat_power = stat_power
        ,stat_powerText = BlzGetFrameByName('Stats_StatText', (id*10) + UI_STAT_POWER)
        ,stat_powerTexture = BlzGetFrameByName('Stats_StatTexture', (id*10) + UI_STAT_POWER)
        ,stat_powerListener = BlzGetFrameByName('Stats_FrameListener', (id*10) + UI_STAT_POWER)
        ,stat_resist = stat_power
        ,stat_resistText = BlzGetFrameByName('Stats_StatText', (id*10) + UI_STAT_RESIST)
        ,stat_resistTexture = BlzGetFrameByName('Stats_StatTexture', (id*10) + UI_STAT_RESIST)
        ,stat_resistListener = BlzGetFrameByName('Stats_FrameListener', (id*10) + UI_STAT_RESIST)
        ,stat_crit = stat_power
        ,stat_critText = BlzGetFrameByName('Stats_StatText', (id*10) + UI_STAT_CRIT)
        ,stat_critTexture = BlzGetFrameByName('Stats_StatTexture', (id*10) + UI_STAT_CRIT)
        ,stat_critListener = BlzGetFrameByName('Stats_FrameListener', (id*10) + UI_STAT_CRIT)
    }

    BlzFrameSetPoint(stat_dmg, FRAMEPOINT_TOPLEFT, mainFrame, FRAMEPOINT_TOPLEFT, 0.01, -0.005)
    BlzFrameSetPoint(stat_power, FRAMEPOINT_LEFT, stat_dmg, FRAMEPOINT_RIGHT, 0.01, 0)
    BlzFrameSetPoint(stat_crit, FRAMEPOINT_BOTTOMLEFT, mainFrame, FRAMEPOINT_BOTTOMLEFT, 0.01, 0.013)
    BlzFrameSetPoint(stat_resist, FRAMEPOINT_LEFT, stat_crit, FRAMEPOINT_RIGHT, 0.01, 0)

    BlzFrameSetTexture(tbl.stat_dmgTexture, STATS_ATTDMG_ICON, 0, true)
    BlzFrameSetTexture(tbl.stat_critTexture, STATS_CRITICAL_ICON, 0, true)
    BlzFrameSetTexture(tbl.stat_resistTexture, STATS_RESISTANCE_ICON, 0, true)
    BlzFrameSetTexture(tbl.stat_powerTexture, ATTRIBUTE_UNDEFINED_ICON, 0, true)

    BlzFrameSetPoint(tbl.stat_resistListener, FRAMEPOINT_CENTER, stat_resist, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(tbl.stat_dmgListener, FRAMEPOINT_CENTER, stat_dmg, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(tbl.stat_critListener, FRAMEPOINT_CENTER, stat_crit, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(tbl.stat_powerListener, FRAMEPOINT_CENTER, stat_power, FRAMEPOINT_CENTER, 0, 0)

    TOOLTIP_RegisterTooltip(tbl.stat_resistListener,TOOLTIP_TYPE_STAT .. id,UI_STAT_RESIST)
    TOOLTIP_RegisterTooltip(tbl.stat_critListener,TOOLTIP_TYPE_STAT .. id,UI_STAT_CRIT)
    TOOLTIP_RegisterTooltip(tbl.stat_powerListener,TOOLTIP_TYPE_STAT .. id,UI_STAT_POWER)
    TOOLTIP_RegisterTooltip(tbl.stat_dmgListener,TOOLTIP_TYPE_STAT .. id,UI_STAT_DMG)

    mainFrame,mainFrameTexture,stat_dmg,stat_power,stat_resist,stat_crit = nil,nil,nil,nil,nil,nil
    return tbl
end

function UI_CreateBuffDetails(id,parent)
    local seed = id * 100
    local tbl = {}
    for i=1,UI_BUFF_COUNT do
        local buffFrame = BlzCreateSimpleFrame('Buff_Frame', parent, seed + i)
        local buff_tbl = {
            buffFrame = buffFrame
            ,buffTexture = BlzGetFrameByName('Buff_Texture', seed + i)
            ,buffText = BlzGetFrameByName('Buff_Text', seed + i)
            ,buffListener = BlzGetFrameByName('Buff_FrameListener', seed + i)
        }
        table.insert(tbl,buff_tbl)
        TOOLTIP_RegisterTooltip(buff_tbl.buffListener,TOOLTIP_TYPE_BUFF .. id,i)
        BlzFrameSetPoint(buff_tbl.buffListener, FRAMEPOINT_CENTER, buff_tbl.buffFrame, FRAMEPOINT_CENTER, 0, 0)
        buffFrame,buff_tbl = nil,nil,nil
    end
    seed = nil
    return tbl
end

function UI_CreateUnitDetails(id)
    local fw,fh = UI_GetAbilityFrameWidthHeight()
    local x,y = 0.4 - (2 * fw),0.0
    local mainFrame = BlzCreateSimpleFrame('Details_Frame', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), id)
    local barFrame = BlzCreateSimpleFrame('Details_BarFrame', mainFrame, id)
    local bar = BlzCreateSimpleFrame('Details_Bar', barFrame, id)
    local barName = BlzCreateSimpleFrame('Details_Bar_Name', bar, id)
    local barHP = BlzCreateSimpleFrame('Details_Bar_HP', bar, id)
    local barReg = BlzCreateSimpleFrame('Details_Bar_HPReg', bar, id)
    local unitIcon = BlzCreateSimpleFrame('Details_UnitIcon', barFrame, id)

    local tbl = {
        mainFrame = mainFrame
        ,barFrame = barFrame
        ,bar = bar
        ,unitName = barName
        ,unitHP = barHP
        ,unitReg = barReg
        ,mainTexture = BlzGetFrameByName('Details_Texture', id)
        ,barFrameTexture = BlzGetFrameByName('Details_BarTexture', id)
        ,unitNameText = BlzGetFrameByName('Details_Bar_Name_Text', id)
        ,unitHPText = BlzGetFrameByName('Details_Bar_HP_Text', id)
        ,unitRegText = BlzGetFrameByName('Details_Bar_HPReg_Text', id)
        ,unitIcon = unitIcon
        ,unitIconTexture = BlzGetFrameByName('Details_UnitIconTexture', id)
    }

    BlzFrameSetPoint(barFrame, FRAMEPOINT_BOTTOM, mainFrame, FRAMEPOINT_TOP, 0, 0)
    BlzFrameSetPoint(unitIcon, FRAMEPOINT_LEFT, barFrame, FRAMEPOINT_LEFT, 0, 0)
    BlzFrameSetPoint(bar, FRAMEPOINT_LEFT, unitIcon, FRAMEPOINT_RIGHT, 0, 0)
    BlzFrameSetPoint(barName, FRAMEPOINT_LEFT, bar, FRAMEPOINT_LEFT, 0, 0)
    BlzFrameSetPoint(barHP, FRAMEPOINT_BOTTOMRIGHT, bar, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
    BlzFrameSetPoint(barReg, FRAMEPOINT_TOPRIGHT, bar, FRAMEPOINT_TOPRIGHT, 0, 0)

    BlzFrameSetAbsPoint(mainFrame, FRAMEPOINT_BOTTOMRIGHT, x, y)

    BlzFrameSetTexture(tbl.bar, DBM_BAR_clDARKGREEN.texture, 0, true)

    x,y,fw,fh,mainFrame,barFrame,bar,barName,barHP,barReg,unitIcon = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
    return tbl
end

HERO_PORTRAIT = nil

function UI_LoadHeroStatistics()
    HERO_PORTRAIT = BlzCreateSimpleFrame('Hero_Portrait', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    BlzFrameSetAbsPoint(HERO_PORTRAIT, FRAMEPOINT_BOTTOMLEFT, -0.134, 0)

    UI_LoadHeroStatistics = nil
end

function UI_ShowHeroPortrait()
    BlzFrameSetVisible(HERO_PORTRAIT, true)
end

function UI_HideHeroPortrait()
    BlzFrameSetVisible(HERO_PORTRAIT, false)
end

function UI_LoadAbilityTrigger_Focus()
    for i,ui in pairs(UI_ABILITIES) do
        BlzTriggerRegisterFrameEvent(UI_ABILITIES_TRIGGER_FOCUS, ui.listener, FRAMEEVENT_MOUSE_ENTER)
        BlzTriggerRegisterFrameEvent(UI_ABILITIES_TRIGGER_FOCUS, ui.listener, FRAMEEVENT_MOUSE_LEAVE)
    end
    TriggerAddAction(UI_ABILITIES_TRIGGER_FOCUS, function()
        i = IsInArray_ByKey(BlzGetTriggerFrame(),UI_ABILITIES,'listener')
        if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_ENTER and ABILITIES_DATA[UI_ABILITIES[i].abCode].ICON_FOCUSED and IsAbilityAvailable(HERO,UI_ABILITIES[i].abCode) and UI_ABILITIES[i].abCode ~= UI_PLAYER_CASTING then
            BlzFrameSetTexture(UI_ABILITIES[i].icon, ABILITIES_DATA[UI_ABILITIES[i].abCode].ICON_FOCUSED, 0, true)
        elseif BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_LEAVE and IsAbilityAvailable(HERO,UI_ABILITIES[i].abCode) and UI_ABILITIES[i].abCode ~= UI_PLAYER_CASTING then
            BlzFrameSetTexture(UI_ABILITIES[i].icon, ABILITIES_DATA[UI_ABILITIES[i].abCode].ICON, 0, true)
        end
    end)
    UI_LoadAbilityTrigger_Focus = nil
end

function UI_CreateAbilityFrame(i)
    local border = BlzCreateSimpleFrame('AbilityButton_Border', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), i)
    local mainFrame = BlzCreateFrame('AbilityButton_Frame',  BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, i)
    local icon = BlzCreateFrame('AbilityButton_Icon',  mainFrame, 0, i)
    local text = BlzCreateFrame('AbilityButton_Text',  mainFrame, 0, i)
    local shortcut = BlzCreateFrame('AbilityButton_Shortcut',  icon, 0, i)
    local shortcutText = BlzCreateFrame('AbilityButton_ShortcutText',  shortcut, 0, i)
    local listener = BlzCreateFrame('AbilityButton_Listener',  mainFrame, 0, i)

    BlzFrameSetPoint(border, FRAMEPOINT_CENTER, mainFrame, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(icon, FRAMEPOINT_CENTER, mainFrame, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(text, FRAMEPOINT_CENTER, icon, FRAMEPOINT_CENTER, 0, -0.001)
    BlzFrameSetPoint(shortcut, FRAMEPOINT_BOTTOMRIGHT, icon, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
    BlzFrameSetPoint(shortcutText, FRAMEPOINT_CENTER, shortcut, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(listener, FRAMEPOINT_CENTER, mainFrame, FRAMEPOINT_CENTER, 0, 0)

    BlzFrameSetVisible(mainFrame, true)

    UI_ABILITIES[i].mainFrame = mainFrame
    UI_ABILITIES[i].border = border
    UI_ABILITIES[i].borderTexture = BlzGetFrameByName('AbilityButton_Border_Texture', i)
    UI_ABILITIES[i].icon = icon
    UI_ABILITIES[i].listener = listener
    UI_ABILITIES[i].text = text
    UI_ABILITIES[i].shortcut = shortcut
    UI_ABILITIES[i].shortcutText = shortcutText
    
    TOOLTIP_RegisterTooltip(listener,TOOLTIP_TYPE_ABILITY,i,true)

    mainFrame,icon,text,shortcut,shortcutText,listener,border = nil,nil,nil,nil,nil,nil,nil
end

function UI_GetAbilityFrameWidthHeight()
    for i,ui in pairs(UI_ABILITIES) do
        if ui.abCode and i >= UI_SHORTCUT_Q then
            return BlzFrameGetWidth(ui.mainFrame),BlzFrameGetHeight(ui.mainFrame)
        end
    end
    return 0.03,0.03
end

UI_CASTBAR_Y = 0
UI_TOOLTIP_ABILITY_Y = 0

function UI_RefreshAbilityPositions()
    local fw,fh = UI_GetAbilityFrameWidthHeight()
    local x,y,maxi = 0.4 - (2 * fw),0.0,tableGetMaxIndex(UI_ABILITIES)
    for i=maxi - 3,11,-4 do
        BlzFrameSetAbsPoint(UI_ABILITIES[i].mainFrame, FRAMEPOINT_BOTTOMLEFT, x, y)
        for j=i+1,i+3 do
            BlzFrameSetPoint(UI_ABILITIES[j].mainFrame, FRAMEPOINT_LEFT, UI_ABILITIES[j-1].mainFrame, FRAMEPOINT_RIGHT, 0, 0)
        end
        y = y + fh
    end
    local c,maxi = 0,fh
    for i,v in pairs(UI_ABILITIES) do
        if i <= 10 then
            if v.abCode then
                BlzFrameSetScale(v.mainFrame, 0.8)
                BlzFrameSetScale(v.border, 0.8)
                BlzFrameSetAbsPoint(v.mainFrame, FRAMEPOINT_BOTTOMLEFT, x, y)
                x = x + BlzFrameGetWidth(v.mainFrame)
                fh = BlzFrameGetHeight(v.mainFrame)
                c = c + 1
                if c - math.floor(c/5)*5 == 0 then
                    x,y = 0.4 - (2 * fw),y + fh
                end
            else
                BlzFrameSetVisible(v.mainFrame, false)
            end
        end
    end
    UI_CASTBAR_Y = (c > 0 and y + fh or y) + maxi
    UI_TOOLTIP_ABILITY_Y = c > 0 and y + fh or y
    fw,fh,x,y,c,maxi = nil,nil,nil,nil,nil,nil
end

function UI_RefreshAbilityData()
    for i,ui in pairs(UI_ABILITIES) do
        if ui.abCode then
            BlzFrameSetTexture(ui.icon, ABILITIES_DATA[ui.abCode].ICON, 0, true)
            if ABILITIES_DATA[ui.abCode].ICON_FOCUSED then
                BlzFrameSetVisible(ui.shortcut, true)                
                BlzFrameSetText(ui.shortcutText, string.char(GetHandleId(ui.OS_Key)))
            else
                BlzFrameSetVisible(ui.shortcut, false)
            end
            BlzFrameSetVisible(ui.icon, true)
            BlzFrameSetEnable(ui.listener, true)
            UI_RefreshAbilityIconState(ui.abCode)
            CD_UpdateStacksUI(ui.abCode)
        else
            BlzFrameSetVisible(ui.icon, false)
            BlzFrameSetEnable(ui.listener, false)
        end
    end
end

function UI_RefreshAbilityTrigger()
    DestroyTrigger(UI_ABILITIES_TRIGGER_USE)
    UI_ABILITIES_TRIGGER_USE = CreateTrigger()

    for i,ui in pairs(UI_ABILITIES) do
        if ui.abCode and ui.listener then
            BlzTriggerRegisterFrameEvent(UI_ABILITIES_TRIGGER_USE, ui.listener, FRAMEEVENT_CONTROL_CLICK)
            BlzTriggerRegisterPlayerKeyEvent(UI_ABILITIES_TRIGGER_USE, PLAYER, ui.OS_Key, KEY_PRESSED_NONE, true)
            BlzTriggerRegisterPlayerKeyEvent(UI_ABILITIES_TRIGGER_USE, PLAYER, ui.OS_Key, KEY_PRESSED_SHIFT, true)
        end
    end
    TriggerAddAction(UI_ABILITIES_TRIGGER_USE, UI_AbilityAction)
end

function UI_AbilityAction()
    local i
    local metaK = KEY_PRESSED_NONE
    if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
        BlzFrameSetEnable(BlzGetTriggerFrame(), false)
        BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        i = IsInArray_ByKey(BlzGetTriggerFrame(),UI_ABILITIES,'listener')
    else
        i = IsInArray_ByKey(BlzGetTriggerPlayerKey(),UI_ABILITIES,'OS_Key')
        metaK = BlzGetTriggerPlayerMetaKey()
    end
    local ab = UI_ABILITIES[i].abCode
    if UI_PLAYER_CASTING ~= ab and IsAbilityAvailable(HERO,ab) and ABILITIES_DATA[ab] then
        local t_type,order = ABILITIES_DATA[ab].TARGET_TYPE,ABILITIES_DATA[ab].order
        if t_type == AB_TARGET_POINT then
            local x,y = metaK ~= KEY_PRESSED_SHIFT and PLAYER_MOUSELOC_X or GetUnitX(HERO), metaK ~= KEY_PRESSED_SHIFT and PLAYER_MOUSELOC_Y or GetUnitY(HERO)
            if x ~= 0.0 or y ~= 0.0 then
                IssuePointOrderById(HERO, order, x, y)
            end
            x,y = nil
        elseif t_type == AB_TARGET_INSTANT then
            IssueImmediateOrderById(HERO, order)
        elseif t_type == AB_TARGET_UNIT and (TARGET or metaK == KEY_PRESSED_SHIFT) then
            IssueTargetOrderById(HERO, order, metaK == KEY_PRESSED_SHIFT and HERO or TARGET)
        elseif t_type == AB_TARGET_UNITORPOINT then
            print('UNITORPOINT is not coded')
        elseif t_type == AB_TARGET_NOCAST then
            if ABILITIES_DATA[ab].castFunc then
                ABILITIES_DATA[ab].castFunc()
            end
        end
        t_type,order,metaK = nil,nil,nil
    end
    ab,i = nil,nil
end

function UI_SetAbilityIconState_Casting(abCode)
    local i = IsInArray_ByKey(abCode,UI_ABILITIES,'abCode')
    if i then
        BlzFrameSetTexture(UI_ABILITIES[i].icon, ABILITIES_DATA[abCode].ICON_PUSHED, 0, true)
    end
    i = nil
end

function UI_RefreshAbilityIconState(abCode)
    local i = IsInArray_ByKey(abCode,UI_ABILITIES,'abCode')
    if i then
        if IsAbilityAvailable(HERO,abCode) then
            BlzFrameSetTexture(UI_ABILITIES[i].icon, ABILITIES_DATA[abCode].ICON, 0, true)
        else
            BlzFrameSetTexture(UI_ABILITIES[i].icon, ABILITIES_DATA[abCode].ICON_DISABLED, 0, true)
        end
    end
    i = nil
end

function UI_LoadAbilities(hero_type,stance)
    UI_LoadStance(hero_type,stance)
    for i,ui in pairs(UI_ABILITIES) do
        UI_CreateAbilityFrame(i)
    end
    UI_LoadAbilities = nil
end

function UI_LoadStance(hero_type,stance)
    for i,ui in pairs(UI_ABILITIES) do
        if ui.abCode then
            local abCode = ui.abCode
            ui.abCode = nil
            if ABILITIES_DATA[abCode].stance ~= 'universal' and ABILITIES_DATA[abCode].stance ~= stance and ui.text then
                BlzFrameSetText(ui.text,'')
            end
            abCode = nil
        end
    end
    for i,ab in pairs(UNITS_DATA[hero_type].ABILITIES) do
        if ab ~= Get_DmgTypeAutoAttack() and ABILITIES_DATA[ab].UI_SHORTCUT and (not(stance) or ABILITIES_DATA[ab].stance == stance or ABILITIES_DATA[ab].stance == 'universal') then
            UI_ABILITIES[ABILITIES_DATA[ab].UI_SHORTCUT].abCode = ab
        end
    end
end

function UI_ChangeStance(hero_type,stance)
    UI_LoadStance(hero_type,stance)
    UI_RefreshAbilityPositions()
    UI_RefreshAbilityData()
end