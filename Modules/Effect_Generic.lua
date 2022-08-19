----------------------------------------------------
---------------EFFECT SYSTEM SETUP------------------
----------------------------------------------------

function AddSpecialEffectTargetUnitBJ(where,unit,effect)
    local eff = oldAddEffect(where,unit,effect)
    DestroyEffectBJ(eff)
end

function AddSpecialEffect(modelName, x, y)
    DestroyEffectBJ(oldAddSpecialEffect(modelName, x, y))
end

function EFFECT_AddSpecialEffect_LifeSpan(modelName, x, y, duration, scale)
    local t = CreateTimer()
    local eff = oldAddSpecialEffect(modelName, x, y)
    BlzSetSpecialEffectScale(eff, (scale or 1.0))
    TimerStart(t, duration, false, function()
        DestroyEffectBJ(eff)
        DestroyTimer(t)
        t,eff = nil,nil
    end)
    return eff
end

function EFFECT_AddSpecialEffectTargetUnit_LifeSpan(attachPointName, targetWidget, modelName, duration, scale)
    local t = CreateTimer()
    local eff = oldAddEffect(attachPointName, targetWidget, modelName)
    BlzSetSpecialEffectScale(eff, (scale or 1.0))
    TimerStart(t, duration, false, function()
        DestroyEffectBJ(eff)
        DestroyTimer(t)
        t,eff = nil,nil
    end)
    return eff
end

function EFFECT_GetXY(eff)
    return BlzGetLocalSpecialEffectX(eff),BlzGetLocalSpecialEffectY(eff)
end