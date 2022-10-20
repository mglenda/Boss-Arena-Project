BUFF_PANEL = {}
BUFF_PANEL_FRAME = nil
BUFF_PANEL_TRIGGER = CreateTrigger()

function UI_BuffPanel_CreateButton(data)
    if not(BUFF_PANEL_FRAME) then
        BUFF_PANEL_FRAME = BlzCreateSimpleFrame('BuffPanel_Container',BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    end
    local button = BlzCreateSimpleFrame('BuffPanel_Button', BUFF_PANEL_FRAME, 0)
    local text = BlzGetFrameByName('BuffPanel_Button_Text', 0)
    local time = BlzCreateSimpleFrame('BuffPanel_Time', button, 0)
    local timeText = BlzGetFrameByName('BuffPanel_Time_Text', 0)

    BlzFrameSetTexture(BlzGetFrameByName('BuffPanel_Button_Texture', 0), data.texture, 0, true)
    BlzFrameSetTextColor(text, data.txtColor)

    BlzFrameSetPoint(time, FRAMEPOINT_TOP, button, FRAMEPOINT_BOTTOM, 0, -0.006)

    table.insert(BUFF_PANEL,{
        name = data.name
        ,isDebuff = data.isDebuff
        ,priority = data.priority
        ,notCancelable = data.notCancelable
        ,button = button
        ,text = text
        ,timeText = timeText
    })

    table.sort(BUFF_PANEL, function (k1, k2) return k1.priority < k2.priority end)

    if not(BUFF_PANEL_TRIGGER) then
        BUFF_PANEL_TRIGGER = CreateTrigger()
        TriggerAddAction(BUFF_PANEL_TRIGGER,UI_BuffPanel_onClick)
    end
    BlzTriggerRegisterFrameEvent(BUFF_PANEL_TRIGGER, button, FRAMEEVENT_CONTROL_CLICK)

    button,text,time,timeText = nil,nil,nil,nil
end

function UI_BuffPanel_onClick()
    UI_BuffPanel_Clear(BlzGetTriggerFrame())
end

function UI_BuffPanel_Clear(frame)
    for i,v in ipairs(BUFF_PANEL) do
        if v.button == frame and not(v.isDebuff) and not(v.notCancelable) then
            BUFF_UnitClearDebuffAllStacks(HERO,v.name)
        end
    end
end

function UI_BuffPanel_LoadDebuffs()
    for i,v in pairs(DEBUFFS) do
        if v.target == HERO and v.ICON and not(UI_BuffPanel_IsBuffRegistered(v.name)) then
            UI_BuffPanel_CreateButton({
                name = v.name
                ,isDebuff = v.isDebuff
                ,priority = v.debuffPriority
                ,notCancelable = v.notCancelable
                ,texture = v.ICON
                ,txtColor = v.txtColor or DEBUFFS_DEFAULT_TEXT_COLOR
            })
        end
    end
    UI_BuffPanel_Refresh()
end

function UI_BuffPanel_Refresh()
    for i = #BUFF_PANEL,1,-1 do
        if not(BUFF_UnitHasDebuff(HERO,BUFF_PANEL[i].name)) then
            BlzDestroyFrame(BUFF_PANEL[i].button)
            table.remove(BUFF_PANEL,i)
        end
    end
    if #BUFF_PANEL > 0 then
        for i=1,#BUFF_PANEL do
            if i == 1 then
                BlzFrameSetAbsPoint(BUFF_PANEL[i].button, FRAMEPOINT_BOTTOMLEFT, -0.125, 0.56) 
            else
                BlzFrameSetPoint(BUFF_PANEL[i].button, FRAMEPOINT_LEFT, BUFF_PANEL[i-1].button, FRAMEPOINT_RIGHT, 0.008, 0)
            end
            local s_c = BUFF_GetStacksCount(HERO,BUFF_PANEL[i].name)
            local r_time = BUFF_GetRemainingTime_Unit(HERO,BUFF_PANEL[i].name)
            BlzFrameSetText(BUFF_PANEL[i].text, s_c > 1 and tostring(s_c) or '')
            BlzFrameSetText(BUFF_PANEL[i].timeText, r_time > 0 and FormatSecondsMinutes(r_time) or '')
            s_c,r_time = nil,nil
        end
    else
        DestroyTrigger(BUFF_PANEL_TRIGGER)
        BUFF_PANEL_TRIGGER = nil
    end
end

function UI_BuffPanel_IsBuffRegistered(name)
    for _,data in pairs(BUFF_PANEL) do
        if data.name == name then
            return true
        end
    end
    return false
end