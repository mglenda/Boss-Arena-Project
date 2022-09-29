----------------------------------------------------
--------------SILENCE SYSTEM SETUP------------------
----------------------------------------------------

SILENCE_TABLE = {}
SILENCE_DISPELLEXPC = {'noorbs','nopower','noenergy'}

function SILENCE_IsAbilityAvailable(unit,abCode)
    for i,v in pairs(SILENCE_TABLE) do
        if v.unit == unit and v.abCode == abCode then
            return false
        end
    end
    return true
end

function SILENCE_UI_ChangeState(unit,abCode)
    if unit == HERO then
        UI_RefreshAbilityIconState(abCode)
    end
end

function SILENCE_IsSeedUnused(unit,abCode,seed)
    for i,v in pairs(SILENCE_TABLE) do
        if v.unit == unit and v.abCode == abCode and v.seed == seed then
            return false
        end
    end
    return true
end

function SILENCE_silenceAbility(unit,abCode,seed)
    if ABILITIES_DATA[abCode] and not(ABILITIES_DATA[abCode].noSilence) and SILENCE_IsSeedUnused(unit,abCode,seed) then
        local tbl = {
            unit = unit
            ,abCode = abCode
            ,seed = seed
        }
        table.insert(SILENCE_TABLE,tbl)
        tbl = nil
        SILENCE_UI_ChangeState(unit,abCode)
    end
end

function SILENCE_silenceUnit(unit)
    for i,ab in pairs(UNITS_DATA[GetUnitTypeId(unit)].ABILITIES) do
        if i ~= Get_DmgTypeAutoAttack() and ABILITIES_DATA[ab] and not(ABILITIES_DATA[ab].noSilence) then
            local tbl = {
                unit = unit
                ,abCode = ab
            }
            table.insert(SILENCE_TABLE,tbl)
            tbl = nil
            SILENCE_UI_ChangeState(unit,ab)
        end
    end
end

function SILENCE_allowAbilitySeed(unit,abCode,seed)
    local tbl = {}
    for i,t in pairs(SILENCE_TABLE) do
        if t.unit == unit and t.abCode == abCode and t.seed == seed then
            table.insert(tbl,i)
        end
    end
    table.sort(tbl)
    for i = #tbl,1,-1 do
        table.remove(SILENCE_TABLE,tbl[i])
    end
    tbl = nil
    SILENCE_UI_ChangeState(unit,abCode)
end

function SILENCE_allowAbility(unit,abCode,seed_expections)
    local tbl = {}
    seed_expections = seed_expections or SILENCE_DISPELLEXPC
    for i,t in pairs(SILENCE_TABLE) do
        if t.unit == unit and t.abCode == abCode and not(IsInArray(t.seed,seed_expections)) then
            table.insert(tbl,i)
        end
    end
    table.sort(tbl)
    for i = #tbl,1,-1 do
        table.remove(SILENCE_TABLE,tbl[i])
    end
    tbl,seed_expections = nil,nil
    SILENCE_UI_ChangeState(unit,abCode)
end

function SILLENCE_allowUnit(unit,seed_expections)
    local tbl = {}
    seed_expections = seed_expections or SILENCE_DISPELLEXPC
    for i,t in pairs(SILENCE_TABLE) do
        if t.unit == unit and not(IsInArray(t.seed,seed_expections)) then
            table.insert(tbl,i)
        end
    end
    table.sort(tbl)
    for i = #tbl,1,-1 do
        local abCode = SILENCE_TABLE[tbl[i]].abCode
        table.remove(SILENCE_TABLE,tbl[i])
        SILENCE_UI_ChangeState(unit,abCode)
        abCode = nil
    end
    tbl,seed_expections = nil,nil
end