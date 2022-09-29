----------------------------------------------------
---------------FRAME FADEOUT SETUP------------------
----------------------------------------------------

function UI_Frame_FadeOut(data)
    local i = BlzFrameIsFading(frame)
    if UI_FADEOUT_DATA[i] then
        UI_FADEOUT_DATA[i].fade_rate = (BlzFrameGetAlpha(data.frame) / data.fadeDuration) / 100
        UI_FADEOUT_DATA[i].cur_alpha = BlzFrameGetAlpha(data.frame)
        UI_FADEOUT_DATA[i].exitFunc = data.exitFunc or UI_FADEOUT_DATA[i].exitFunc
    else
        local trg = CreateTrigger()
        UI_FADEOUT_DATA[GetHandleIdBJ(trg)] = {
            trigger = trg
            ,frame = data.frame
            ,fade_rate = (BlzFrameGetAlpha(data.frame) / data.fadeDuration) / 100
            ,cur_alpha = BlzFrameGetAlpha(data.frame)
            ,exitFunc = data.exitFunc
        }
        TriggerRegisterTimerEventPeriodic(trg, 0.01)
        TriggerAddAction(trg, function()
            local trg = GetTriggeringTrigger()
            local t_id = GetHandleIdBJ(trg)
            if UI_FADEOUT_DATA[t_id] then
                if UI_FADEOUT_DATA[t_id].cur_alpha > 0 then
                    UI_FADEOUT_DATA[t_id].cur_alpha = UI_FADEOUT_DATA[t_id].cur_alpha - UI_FADEOUT_DATA[t_id].fade_rate
                    BlzFrameSetAlpha(UI_FADEOUT_DATA[t_id].frame, R2I( UI_FADEOUT_DATA[t_id].cur_alpha))
                else
                    BlzFrameSetVisible(UI_FADEOUT_DATA[t_id].frame, false)
                    if UI_FADEOUT_DATA[t_id].exitFunc then
                        UI_FADEOUT_DATA[t_id].exitFunc()
                    end
                    UI_Frame_FadeOut_Stop(t_id)
                end
            else
                DestroyTrigger(GetTriggeringTrigger())
            end
        end)
    end
end

function UI_Frame_FadeOut_Stop(t_id)
    if UI_FADEOUT_DATA[t_id] then
        DestroyTrigger(UI_FADEOUT_DATA[t_id].trigger)
        UI_FADEOUT_DATA[t_id] = nil
    end
end

function UI_Frame_FadeOut_StopFrame(frame)
    for i,v in pairs(UI_FADEOUT_DATA) do
        if v.frame == frame then
            UI_Frame_FadeOut_Stop(i)
        end
    end
end

function BlzFrameIsFading(frame)
    for i,v in pairs(UI_FADEOUT_DATA) do
        if v.frame == frame then
            return i
        end
    end
    return nil
end

function BlzFrameSetVisible(frame,bool,alpha)
    if bool then
        UI_Frame_FadeOut_StopFrame(frame)
        BlzFrameSetAlpha(frame, alpha or 255)
    end
    oldBlzFrameSetVisible(frame,bool)
end