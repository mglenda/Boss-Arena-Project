function DBM_Initialize()
    TriggerRegisterTimerEventPeriodic(DBM_TimerTrigger, 0.01)
    TriggerAddAction(DBM_TimerTrigger, DBM_RefreshTimers)

    DBM_Initialize = nil
end

function DBM_GetContextSeed()
    DBM_ContextSeed = DBM_ContextSeed + 1
    return DBM_ContextSeed
end

function DBM_RefreshTimers()
    if #DBM_TimerFrames > 0 then
        for i,t in pairs(DBM_TimerFrames) do
            if not(t.paused) then
                if BlzFrameGetValue(t.bar) < 100 then
                    t.time = t.time > 0 and t.time - 0.01 or 0
                    BlzFrameSetText(t.timeText, FromatSeconds(t.time))
                    BlzFrameSetValue(t.bar, BlzFrameGetValue(t.bar) + t.progress)
                else
                    DBM_DestroyTimer(i)
                    if t.finishFunc then
                        t.finishFunc()
                    end
                end
            end
        end
    else 
        DisableTrigger(DBM_TimerTrigger)
    end
end

function DBM_DestroyAll()
    for i=#DBM_TimerFrames,1,-1 do
        DBM_DestroyTimer(i)
    end
end

function DBM_PauseTimer(i)
    DBM_TimerFrames[i].paused = true
end

function DBM_UnpauseTimer(i)
    DBM_TimerFrames[i].paused = false
end

function DBM_GetTime(i)
    return DBM_TimerFrames[i].time
end

function DBM_SetTime(i,time)
    DBM_TimerFrames[i].time = time
end

function DBM_GetTimeById(id)
    return DBM_GetTime(DBM_GetTimerById(id))
end

function DBM_SetTimeById(id,time)
    DBM_SetTime(DBM_GetTimerById(id),time)
end

function DBM_PauseTimerById(id)
    DBM_PauseTimer(DBM_GetTimerById(id))
end

function DBM_UnpauseTimerById(id)
    DBM_UnpauseTimer(DBM_GetTimerById(id))
end

function DBM_IsTimerPaused(id)
    return DBM_TimerFrames[DBM_GetTimerById(id)].paused
end

function DBM_FlushTimer(timer)
    for i,t in pairs(DBM_TimerFrames) do
        if t.mainFrame == timer then
            table.remove(DBM_TimerFrames,i)
            break
        end
    end
    BlzDestroyFrame(timer)
    DBM_RepositionTimers()
end

function DBM_DestroyTimer(i)
    if i then
        DBM_PauseTimer(i)
        DBM_TimerFrames[i].id = nil
        UI_Frame_FadeOut({
            frame = DBM_TimerFrames[i].mainFrame
            ,fadeDuration = 1.0
            ,exitFunc = function()
                DBM_FlushTimer(UI_FADEOUT_DATA[GetHandleIdBJ(GetTriggeringTrigger())].frame)
            end
        })
    end
end

function DBM_DestroyTimerById(id)
    DBM_DestroyTimer(DBM_GetTimerById(id))
end

function DBM_GetTimerById(id)
    for i,t in pairs(DBM_TimerFrames) do
        if t.id == id then
            return i
        end
    end
    return nil
end

function DBM_RegisterTimer(data)
    data = data or {}
    local dataTbl = {
        barTheme = data.barTheme or DBM_BAR_clGRAY
        ,time = data.time or 1.0
        ,progress = data.time and round(1/data.time,4) or 1.0
        ,icon = data.icon or 'war3mapImported\\BTN_Undefined.dds'
        ,name = data.name or 'Unknown'
        ,id = data.id or 0
        ,paused = false
        ,finishFunc = data.finishFunc
    }
    data = nil
    DBM_CreateTimer(dataTbl)
end

function DBM_RepositionTimers()
    local first = DBM_TimerFrames[1]
    if first then
        BlzFrameClearAllPoints(first.mainFrame)
        local widget = WIDGET_DBMGetVisible()
        if widget then
            BlzFrameSetPoint(first.mainFrame, FRAMEPOINT_TOPRIGHT, widget, FRAMEPOINT_TOPLEFT, 0, 0)
        else
            BlzFrameSetAbsPoint(first.mainFrame, FRAMEPOINT_TOP, 0.934 - (BlzFrameGetWidth(first.mainFrame)/2), 0.6)
        end
        for i=2,#DBM_TimerFrames do
            BlzFrameSetPoint(DBM_TimerFrames[i].mainFrame, FRAMEPOINT_TOP, DBM_TimerFrames[i-1].mainFrame, FRAMEPOINT_BOTTOM, 0, 0)
        end
        widget = nil
    end
    first = nil
end

function DBM_CreateTimer(data)
    local seed = DBM_GetContextSeed()
    data.mainFrame = BlzCreateSimpleFrame('DBM_TimerFrame', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), seed)
    local iconFrame = BlzCreateSimpleFrame('DBM_TimerFrameIcon', data.mainFrame, seed)
    data.iconFrame = BlzGetFrameByName('DBM_TimerFrameIcon_Texture', seed)
    data.bar = BlzCreateSimpleFrame('DBM_TimerBar', data.mainFrame, seed)
    local name = BlzCreateSimpleFrame('DBM_TimerBar_Name', data.bar, seed)
    local time = BlzCreateSimpleFrame('DBM_TimerBar_Time', data.bar, seed)
    data.nameText = BlzGetFrameByName('DBM_TimerBar_Name_Text', seed)
    data.timeText = BlzGetFrameByName('DBM_TimerBar_Time_Text', seed)
    BlzFrameSetTexture(data.bar, data.barTheme.texture, 0, true)
    BlzFrameSetTexture(data.iconFrame, data.icon, 0, true)
    BlzFrameSetPoint(iconFrame, FRAMEPOINT_LEFT, data.mainFrame, FRAMEPOINT_LEFT, 0, 0)
    BlzFrameSetPoint(data.bar, FRAMEPOINT_LEFT, iconFrame, FRAMEPOINT_RIGHT, 0, 0)
    BlzFrameSetPoint(name, FRAMEPOINT_CENTER, data.bar, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(time, FRAMEPOINT_CENTER, data.bar, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetVisible(data.mainFrame, true)
    BlzFrameSetValue(data.bar, 0)
    BlzFrameSetText(data.timeText, FromatSeconds(data.time))
    BlzFrameSetText(data.nameText, data.name)
    BlzFrameSetTextColor(data.timeText, data.barTheme.fontColor)
    BlzFrameSetTextColor(data.nameText, data.barTheme.fontColor)
    seed,name,time,iconFrame = nil,nil,nil,nil
    table.insert(DBM_TimerFrames,data)
    DBM_RepositionTimers()
    if not(IsTriggerEnabled(DBM_TimerTrigger)) then
        EnableTrigger(DBM_TimerTrigger)
    end
    data = nil
end