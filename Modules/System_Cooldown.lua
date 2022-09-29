----------------------------------------------------
-------------COOLDOWN SYSTEM SETUP------------------
----------------------------------------------------

function IsAbilityAvailable(unit,abCode)
    return CD_IsAbilityAvailable(unit,abCode) and SILENCE_IsAbilityAvailable(unit,abCode)
end

function CD_DisableAbility(unit,abCode)
    if CD_IsAbilityAvailable(unit,abCode) then
        COOLDOWN_ABILITIES[unit] = COOLDOWN_ABILITIES[unit] or {}
        table.insert(COOLDOWN_ABILITIES[unit],abCode)
        if unit == HERO then
            UI_RefreshAbilityIconState(abCode)
        end
    end
end

function CD_IsAbilityAvailable(unit,abCode)
    local avail = true
    if COOLDOWN_ABILITIES[unit] then
        for i,ab in pairs(COOLDOWN_ABILITIES[unit]) do
            if ab == abCode then
                avail = false
                break
            end
        end
    end
    return avail and GetUnitAbilityLevel(unit, abCode) > 0
end

function CD_EnableAbility(unit,abCode,stacks)
    if unit == HERO then
        local i = IsInArray_ByKey(abCode,UI_ABILITIES,'abCode')
        if i then
            BlzFrameSetText(UI_ABILITIES[i].text, (ABILITIES_DATA[UI_ABILITIES[i].abCode].CooldownStacks or 1) > 1 and stacks or '')
        end
        i = nil
    end
    if not(CD_IsAbilityAvailable(unit,abCode)) then
        RemoveFromArray(abCode,COOLDOWN_ABILITIES[unit])
        if unit == HERO then
            UI_RefreshAbilityIconState(abCode)
        end
    end
end

function CD_UpdateStacksUI(abCode)
    local stacks,cool = CD_GetUnitAbilityCooldownRemaining(HERO,abCode)
    if stacks > 0 then
        CD_EnableAbility(u,abCode,stacks)
    end
end

function CD_UpdateCooldownUI(abCode,cd)
    local i = IsInArray_ByKey(abCode,UI_ABILITIES,'abCode')
    if i then
        BlzFrameSetText(UI_ABILITIES[i].text,strRound(cd,1))
    end
    i = nil
end

function CD_RegisterCooldownSystem()
    TriggerRegisterTimerEventPeriodic(COOLDOWN_TRIGGER, 0.1)
    TriggerAddAction(COOLDOWN_TRIGGER, function()
        local t = 0
        for u,ut in pairs(COOLDOWN_TABLE) do
            for ab,at in pairs(ut) do
                local c = 0
                for ci,cd in pairs(at) do
                    if cd <= 0 then
                        COOLDOWN_TABLE[u][ab][ci] = nil
                    else
                        COOLDOWN_TABLE[u][ab][ci] = round(COOLDOWN_TABLE[u][ab][ci] - 0.1,1)
                        c = c + 1
                    end
                end
                if c == 0 then
                    COOLDOWN_TABLE[u][ab] = nil
                end
                local stacks,cool = CD_GetUnitAbilityCooldownRemaining(u,ab)
                if stacks > 0 then
                    CD_EnableAbility(u,ab,stacks)
                else
                    if CD_IsAbilityAvailable(u,ab) then
                        CD_DisableAbility(u,ab)
                    end
                    if u == HERO then
                        CD_UpdateCooldownUI(ab,cool)
                    end
                end
                c,stacks,cool = nil,nil,nil
                t = t + 1
            end
        end
        if t == 0 then
            DisableTrigger(COOLDOWN_TRIGGER)
        end
    end)
    CD_RegisterCooldownSystem = nil
end


function CD_TriggerAbilityCooldown(abCode,unit,opt_duration)
    opt_duration = opt_duration or CD_GetUnitAbilityCooldown(abCode,unit)
    COOLDOWN_TABLE[unit] = COOLDOWN_TABLE[unit] or {}
    COOLDOWN_TABLE[unit][abCode] = COOLDOWN_TABLE[unit][abCode] or {}
    table.insert(COOLDOWN_TABLE[unit][abCode],opt_duration)
    if not(CD_IsAbilityReady(abCode,unit)) then
        CD_DisableAbility(unit, abCode)
    end
    if not(IsTriggerEnabled(COOLDOWN_TRIGGER)) then
        EnableTrigger(COOLDOWN_TRIGGER)
    end
end

function CD_GetUnitAbilityCooldownRemaining(unit,abCode)
    local stacks = ABILITIES_DATA[abCode].CooldownStacks or 1
    local cooldown = 0
    local x = 1
    if COOLDOWN_TABLE[unit] and COOLDOWN_TABLE[unit][abCode] then
        stacks = stacks - tableLength(COOLDOWN_TABLE[unit][abCode])
        if stacks >= 0 then
            for i,v in pairs(COOLDOWN_TABLE[unit][abCode]) do
                cooldown = (cooldown > v or cooldown == 0) and v or cooldown
            end
        else
            for i=1,math.abs(stacks) do
                table_DeleteMinVal(COOLDOWN_TABLE[unit][abCode])
            end
            cooldown = table_GetMinVal(COOLDOWN_TABLE[unit][abCode])
        end
    end
    stacks = stacks >= 0 and stacks or 0
    return stacks,cooldown
end

function CD_ResetAbilityCooldown(unit,abCode)
    if COOLDOWN_TABLE[unit] and COOLDOWN_TABLE[unit][abCode] then
        for i,v in pairs(COOLDOWN_TABLE[unit][abCode]) do
            COOLDOWN_TABLE[unit][abCode][i] = -1
        end
    end
end

function CD_ResetAllAbilitiesCooldown(unit)
    if COOLDOWN_TABLE[unit] then
        for i,x in pairs(COOLDOWN_TABLE[unit]) do
            for j,v in pairs(COOLDOWN_TABLE[unit][i]) do
                COOLDOWN_TABLE[unit][i][j] = -1
            end
        end
    end
end

function CD_GetDefaultAbilityCooldown_Unit(abCode,unit)
    return ABILITIES_DATA[abCode].Cooldown or BlzGetAbilityCooldown(abCode, GetUnitAbilityLevel(unit, abCode)-1)
end

function CD_GetDefaultAbilityCooldown_Level(abCode,level)
    return BlzGetAbilityCooldown(abCode, level)
end

function CD_GetUnitAbilityCooldown(abCode,unit)
    return ABILITIES_DATA[abCode].Cooldown or BlzGetUnitAbilityCooldown(unit, abCode, GetUnitAbilityLevel(unit, abCode)-1)
end

function CD_IsAbilityOnCooldown(abCode,unit)
    local stacks,cd = CD_GetUnitAbilityCooldownRemaining(unit,abCode)
    return cd > 0 and stacks == 0
end

function CD_GetAvailableStack(abCode,unit)
    local stacks,cd = CD_GetUnitAbilityCooldownRemaining(unit,abCode)
    return stacks >= 0 and stacks or 0
end

function CD_IsAbilityReady(abCode,unit)
    local stacks,cd = CD_GetUnitAbilityCooldownRemaining(unit,abCode)
    return stacks > 0
end