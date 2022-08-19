function WIDGET_Initializte()
    TriggerAddAction(BOSS_WIDGETS_TARGET_TRIGGER,function()
        TT_MakeUnit_Target(BOSSES[IsInArray_ByKey(BlzGetTriggerFrame(),BOSS_WIDGETS,'iconButton')] or TARGET)
    end)

    TriggerRegisterTimerEventPeriodic(BOSS_WIDGETS_REFRESH_TRIGGER, 0.1)
    TriggerAddAction(BOSS_WIDGETS_REFRESH_TRIGGER, function()
        local c = 0
        for i,b in pairs(BOSSES) do
            WIDGET_Refresh(i)
            c = c + 1
        end
        if c == 0 then
            DisableTrigger(BOSS_WIDGETS_REFRESH_TRIGGER)
        end
    end)

    WIDGET_Initializte = nil
end

function WIDGET_Get(id)
    return BOSS_WIDGETS[id] or WIDGET_Create(id)
end

function WIDGET_Create(id)
    local widget_frame = BlzCreateSimpleFrame("BossWidget", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), id)
    local hp_border = BlzCreateSimpleFrame("BossWidget_HP_Border", widget_frame, id)
    local hp_bar = BlzCreateSimpleFrame("BossWidget_HP_Bar", hp_border, id)
    BlzCreateSimpleFrame("BossWidget_HP_TextFrame", hp_bar, id)

    local hp_text = BlzGetFrameByName("BossWidget_HP_Text", id)

    local icon_button = BlzCreateSimpleFrame("BossWidget_IconButton", widget_frame, id)

    local power_border = BlzCreateSimpleFrame("BossWidget_Power_Border", hp_border, id)
    local power_bar = BlzCreateSimpleFrame("BossWidget_Power_Bar", power_border, id)
    BlzCreateSimpleFrame("BossWidget_Power_TextFrame", power_bar, id)

    local power_text = BlzGetFrameByName("BossWidget_Power_Text", id)

    local name_frame = BlzCreateSimpleFrame("BossWidget_NameFrame", widget_frame, id)

    BlzFrameSetPoint(name_frame, FRAMEPOINT_TOP, widget_frame, FRAMEPOINT_TOP, 0.028, -0.0035)

    BlzFrameSetPoint(power_bar, FRAMEPOINT_CENTER, power_border, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(BlzGetFrameByName("BossWidget_Power_TextFrame", id), FRAMEPOINT_CENTER, power_bar, FRAMEPOINT_CENTER, 0, -0.001)
    BlzFrameSetPoint(power_border, FRAMEPOINT_TOP, hp_border, FRAMEPOINT_BOTTOM, 0, 0)

    BlzFrameSetPoint(hp_bar, FRAMEPOINT_CENTER, hp_border, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(BlzGetFrameByName("BossWidget_HP_TextFrame", id), FRAMEPOINT_CENTER, hp_bar, FRAMEPOINT_CENTER, 0, -0.001)
    BlzFrameSetPoint(icon_button, FRAMEPOINT_TOPLEFT, widget_frame, FRAMEPOINT_TOPLEFT, 0.005, -0.005)
    BlzFrameSetPoint(hp_border, FRAMEPOINT_TOP, widget_frame, FRAMEPOINT_BOTTOM, 0, 0)

    local dmg_frame = BlzCreateSimpleFrame("BossWidget_AttDmg_Frame", widget_frame, id)
    local crit_frame = BlzCreateSimpleFrame("BossWidget_Crit_Frame", widget_frame, id)
    local power_frame = BlzCreateSimpleFrame("BossWidget_PowerStat_Frame", widget_frame, id)
    local resist_frame = BlzCreateSimpleFrame("BossWidget_Resist_Frame", widget_frame, id)

    BlzFrameSetPoint(dmg_frame, FRAMEPOINT_TOPLEFT, icon_button, FRAMEPOINT_TOPRIGHT, 0.004, -0.015)
    BlzFrameSetPoint(crit_frame, FRAMEPOINT_BOTTOMLEFT, icon_button, FRAMEPOINT_BOTTOMRIGHT, 0.004, 0)
    BlzFrameSetPoint(power_frame, FRAMEPOINT_TOPLEFT, icon_button, FRAMEPOINT_TOPRIGHT, 0.045, -0.015)
    BlzFrameSetPoint(resist_frame, FRAMEPOINT_BOTTOMLEFT, icon_button, FRAMEPOINT_BOTTOMRIGHT, 0.045, 0)

    local buffs = {}
    local x,y = nil,-1 * (BlzFrameGetHeight(icon_button) + 0.01)
    for i=0,5 do
        local tbl = {
            buff_frame = BlzCreateSimpleFrame("BossWidget_DebuffFrame", widget_frame, id*10 + (i + 1))
        }
        tbl.buffTexture = BlzGetFrameByName('BossWidget_DebuffTexture', id*10 + (i + 1))
        tbl.buffText = BlzGetFrameByName('BossWidget_DebuffText', id*10 + (i + 1))
        table.insert(buffs,tbl)
        x = ((BlzFrameGetWidth(widget_frame) - BlzFrameGetWidth(buffs[(i + 1)].buff_frame) * 6) / 7) * (i + 1) + BlzFrameGetWidth(buffs[(i + 1)].buff_frame) * i
        BlzFrameSetPoint(buffs[(i + 1)].buff_frame, FRAMEPOINT_TOPLEFT, widget_frame, FRAMEPOINT_TOPLEFT, x, y)
    end

    BlzFrameSetAbsPoint(widget_frame, FRAMEPOINT_TOP, 0.934 - (BlzFrameGetWidth(widget_frame)/2), 0.6)

    table.insert(BOSS_WIDGETS,{
        widget = widget_frame
        ,hpBar = hp_bar
        ,hpText = hp_text
        ,hpBarBorder = hp_border
        ,powerBar = power_bar
        ,powerText = power_text
        ,powerBarBorder = power_border
        ,icon = BlzGetFrameByName("BossWidget_Icon", id)
        ,iconButton = icon_button
        ,buffs = buffs
        ,nameText = BlzGetFrameByName("BossWidget_NameText", id)
        ,resistText = BlzGetFrameByName("BossWidget_ResistText", id)
        ,dmgText = BlzGetFrameByName("BossWidget_AttDmgText", id)
        ,statText = BlzGetFrameByName("BossWidget_PowerStatText", id)
        ,critText = BlzGetFrameByName("BossWidget_CritText", id)
        ,statTexture = BlzGetFrameByName("BossWidget_PowerStatTexture", id)
    })

    BlzTriggerRegisterFrameEvent(BOSS_WIDGETS_TARGET_TRIGGER, icon_button, FRAMEEVENT_CONTROL_CLICK)

    hp_border,widget_frame,hp_bar,hp_text,icon_button,power_text,power_bar,power_border,buffs,name_frame,dmg_frame,crit_frame,power_frame,resist_frame = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
    return BOSS_WIDGETS[#BOSS_WIDGETS]
end

function WIDGET_Refresh(id)
    BlzFrameSetValue(BOSS_WIDGETS[id].hpBar, GetUnitLifePercent(BOSSES[id]))
    BlzFrameSetText(BOSS_WIDGETS[id].hpText, strRound(GetUnitLifePercent(BOSSES[id]),2) .. '%%')
    BlzFrameSetText(BOSS_WIDGETS[id].resistText, math.floor(BlzGetUnitArmor(BOSSES[id]))..'%%')
    BlzFrameSetText(BOSS_WIDGETS[id].dmgText, Get_UnitBaseDamage(BOSSES[id]))
    BlzFrameSetText(BOSS_WIDGETS[id].statText, GetHeroStatBJ(ATTRIBUTES[Get_UnitPrimaryAttribute(BOSSES[id])].stat, BOSSES[id], true))
    BlzFrameSetText(BOSS_WIDGETS[id].critText, Get_UnitCritRate(BOSSES[id])..'%%')
    WIDGET_RefreshBuffs(id)
end

function WIDGET_RefreshBuffs(id)
    local Buff_Tbl = {}
    local tbl = nil
    for i, v in pairs(DEBUFFS) do
        if v.target == BOSSES[id] and not(IsInArray_CustField(v.name,Buff_Tbl,'name')) then
            tbl = {
                ['name'] = v.name
                ,stackCount = BUFF_GetStacksCount(BOSSES[id],v.name)
                ,priority = v.debuffPriority
                ,ICON = v.ICON
            }
            table.insert(Buff_Tbl,tbl)
            tbl = nil
        end
    end
    table.sort (Buff_Tbl, function (k1, k2) return k1.priority < k2.priority end )
    local c = 1
    for i, v in pairs(Buff_Tbl) do
        if v.ICON and c <= #BOSS_WIDGETS[id].buffs then
            if not(BlzFrameIsVisible(BOSS_WIDGETS[id].buffs[c].buff_frame)) then
                BlzFrameSetVisible(BOSS_WIDGETS[id].buffs[c].buff_frame, true)
            end
            BlzFrameSetText(BOSS_WIDGETS[id].buffs[c].buffText, v.stackCount > 1 and I2S(v.stackCount) or '')
            BlzFrameSetTexture(BOSS_WIDGETS[id].buffs[c].buffTexture, v.ICON, 0, true)
            c = c + 1
        end
    end
    for i = c,#BOSS_WIDGETS[id].buffs do
        if BlzFrameIsVisible(BOSS_WIDGETS[id].buffs[i].buff_frame) then
            BlzFrameSetVisible(BOSS_WIDGETS[id].buffs[i].buff_frame, false)
        end
    end
    Buff_Tbl = nil
end

function WIDGET_DBMGetVisible()
    for i,w in ipairs(BOSS_WIDGETS) do
        if BlzFrameIsVisible(w.widget) then
            return w.widget
        end
    end
    return nil
end

function WIDGET_Load(id,b_id)
    local w = WIDGET_Get(id)
    BlzFrameSetVisible(w.widget, true)
    BlzFrameSetValue(w.hpBar, GetUnitLifePercent(BOSSES[id]))
    BlzFrameSetText(w.hpText, strRound(GetUnitLifePercent(BOSSES[id]),2) .. '%%')
    BlzFrameSetTexture(w.icon, UNITS_DATA[BOSS_DATA[b_id].boss_id[id]].ICON, 0, true)
    BlzFrameSetText(w.nameText, GetUnitName(BOSSES[id]))
    BlzFrameSetText(w.resistText, math.floor(BlzGetUnitArmor(BOSSES[id]))..'%%')
    BlzFrameSetText(w.dmgText, Get_UnitBaseDamage(BOSSES[id]))
    BlzFrameSetText(w.statText, GetHeroStatBJ(ATTRIBUTES[Get_UnitPrimaryAttribute(BOSSES[id])].stat, BOSSES[id], true))
    BlzFrameSetText(w.critText, Get_UnitCritRate(BOSSES[id])..'%%')
    BlzFrameSetTexture(w.statTexture, ATTRIBUTES[Get_UnitPrimaryAttribute(BOSSES[id])].icon, 0, true)
    if not(BOSS_DATA[b_id].boss_power) then
        BlzFrameSetVisible(w.powerBarBorder, false)
        if id > 1 then
            BlzFrameSetPoint(w.widget, FRAMEPOINT_TOP, BOSS_WIDGETS[id-1].hpBarBorder, FRAMEPOINT_BOTTOM, 0, 0)
        end
    else
        BlzFrameSetTexture(w.powerBar, BOSS_DATA[b_id].boss_power[id], 0, true)
        BlzFrameSetVisible(w.powerBarBorder, true)
        BlzFrameSetPoint(w.widget, FRAMEPOINT_TOP, BOSS_WIDGETS[id-1].powerBarBorder, FRAMEPOINT_BOTTOM, 0, 0)
    end
    WIDGET_RefreshBuffs(id)
    w = nil
end

function WIDGET_LoadAll(b_id)
    for i,b in pairs(BOSSES) do
        WIDGET_Load(i,b_id)
    end
    if not(IsTriggerEnabled(BOSS_WIDGETS_REFRESH_TRIGGER)) then
        EnableTrigger(BOSS_WIDGETS_REFRESH_TRIGGER)
    end
end

function WIDGET_HideAll()
    for i,w in pairs(BOSS_WIDGETS) do
        BlzFrameSetVisible(w.widget, false)
    end
end