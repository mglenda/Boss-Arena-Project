----------------------------------------------------
------------------UI TOOLTIPING---------------------
----------------------------------------------------

TOOLTIP_DATA = {}
TOOLTIP_TRIGGER = CreateTrigger()
TOOLTIP_FRAMES = nil

TOOLTIP_TYPE_ABILITY = 'ability'
TOOLTIP_TYPE_BUFF = 'buff'
TOOLTIP_TYPE_STAT = 'stat'


function TOOLTIP_RegisterTooltiping()
    for i,v in pairs(TOOLTIP_DATA) do
        BlzFrameSetTooltip(v.frame, v.tooltip)
    end
    TriggerRegisterTimerEventPeriodic(TOOLTIP_TRIGGER, 0.1)
    TriggerAddAction(TOOLTIP_TRIGGER, function()
        local tooltiped = false
        for i,v in pairs(TOOLTIP_DATA) do
            tooltiped = tooltiped or BlzFrameIsVisible(v.tooltip)
            if BlzFrameIsVisible(v.tooltip) and not(v.tooltiped) then
                TOOLTIP_HideAll()
                TOOLTIP_Load(v.type,v.id)
                v.tooltiped = true
            elseif not(BlzFrameIsVisible(v.tooltip)) then
                v.tooltiped = false
            end
        end
        if not(tooltiped) then
            TOOLTIP_HideAll()
        end
    end)
    TOOLTIP_FRAMES = {
        ability = {
            mainFrame = BlzCreateFrame('Tooltip_Ability', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0,0)
        }
    }
    TOOLTIP_FRAMES.ability.Title = BlzGetFrameByName('Tooltip_AbilityTitle', 0)
    TOOLTIP_FRAMES.ability.Text = BlzGetFrameByName('Tooltip_AbilityText', 0)
    TOOLTIP_FRAMES.ability.TextData = BlzGetFrameByName('Tooltip_AbilityTextData', 0)
    BlzFrameSetAbsPoint(TOOLTIP_FRAMES.ability.mainFrame, FRAMEPOINT_BOTTOM, 0.4, UI_TOOLTIP_ABILITY_Y)
    
    UI_TOOLTIP_ABILITY_Y = nil
    TOOLTIP_RegisterTooltiping = nil
end

function TOOLTIP_HideAll()
    for i,v in pairs(TOOLTIP_FRAMES) do
        BlzFrameSetVisible(v.mainFrame, false)
    end
end

function TOOLTIP_RegisterTooltip(frame,type,id,alt)
    local tooltip = alt and BlzCreateFrame('Tooltip_Visibler_Alt', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, #TOOLTIP_DATA) or BlzCreateSimpleFrame('Tooltip_Visibler', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), #TOOLTIP_DATA)
    BlzFrameSetVisible(tooltip, false)
    table.insert(TOOLTIP_DATA,{
        frame = frame
        ,tooltip = tooltip
        ,type = type
        ,id = id
        ,tooltiped = false
    })
    tooltip = nil
end

function TOOLTIP_Load(type,id)
    local sub_id,_ = type:gsub('[a-z]', '')
    type,_ = type:gsub('[0-9]', '')
    if type == TOOLTIP_TYPE_ABILITY then
        BlzFrameSetVisible(TOOLTIP_FRAMES[type].mainFrame, true)
        BlzFrameSetText(TOOLTIP_FRAMES[type].Text, TOOLTIP_InjectParams(BlzGetAbilityExtendedTooltip(UI_ABILITIES[id].abCode, 0),id,type))
        BlzFrameSetText(TOOLTIP_FRAMES[type].Title, TOOLTIP_InjectParams(BlzGetAbilityTooltip(UI_ABILITIES[id].abCode, 0),id,type))
        BlzFrameSetText(TOOLTIP_FRAMES[type].TextData, TOOLTIP_InjectParams(BlzGetAbilityActivatedExtendedTooltip(UI_ABILITIES[id].abCode, 0),id,type))
    end
end

function TOOLTIP_InjectParams(text,id,type)
    if type == 'ability' then
        text,_ = text:gsub("AB_NAME",ABILITIES_DATA[UI_ABILITIES[id].abCode].Name)
        text,_ = text:gsub("AB_RANGE",ABILITIES_DATA[UI_ABILITIES[id].abCode].Range or '')
        text,_ = text:gsub("AB_COLDOWN",ABILITIES_DATA[UI_ABILITIES[id].abCode].Cooldown or '0.0')
        text,_ = text:gsub("AB_DAMAGEDOT",ABILITIES_DATA[UI_ABILITIES[id].abCode].getDamageDOT and ABILITIES_DATA[UI_ABILITIES[id].abCode].getDamageDOT(HERO) or '')
        text,_ = text:gsub("AB_AOE",ABILITIES_DATA[UI_ABILITIES[id].abCode].AOE or '')
        text,_ = text:gsub("AB_DAMAGEFAC",UNIT_GetDmgFactor(HERO,UI_ABILITIES[id].abCode) * 100 or '')
        text,_ = text:gsub("AB_DAMAGE",ABILITIES_DATA[UI_ABILITIES[id].abCode].getDamage and ABILITIES_DATA[UI_ABILITIES[id].abCode].getDamage(HERO) * UNIT_GetDmgFactor(HERO,UI_ABILITIES[id].abCode) or '')
        text,_ = text:gsub("AB_IMPACTDAMAGE",ABILITIES_DATA[UI_ABILITIES[id].abCode].getImpactDamage and ABILITIES_DATA[UI_ABILITIES[id].abCode].getImpactDamage(HERO) * UNIT_GetDmgFactor(HERO,UI_ABILITIES[id].abCode) or '')
        text,_ = text:gsub("AB_DURATIONDEF", strRound(ABILITIES_DATA[UI_ABILITIES[id].abCode].getDurationDeff and ABILITIES_DATA[UI_ABILITIES[id].abCode].getDurationDeff() or '',1))
        text,_ = text:gsub("AB_SLOW_MS",strRound(ABILITIES_DATA[UI_ABILITIES[id].abCode].getSlow_ms and ABILITIES_DATA[UI_ABILITIES[id].abCode].getSlow_ms() or '',1))
        text,_ = text:gsub("AB_RESIST", strRound(ABILITIES_DATA[UI_ABILITIES[id].abCode].getResistFactor and ABILITIES_DATA[UI_ABILITIES[id].abCode].getResistFactor() or '',1))
        text,_ = text:gsub("AB_MAXSTACKS", ABILITIES_DATA[UI_ABILITIES[id].abCode].getMaxStacks and ABILITIES_DATA[UI_ABILITIES[id].abCode].getMaxStacks() or '')
        text,_ = text:gsub("AB_HEALFACTOR",ABILITIES_DATA[UI_ABILITIES[id].abCode].HealFactor and ABILITIES_DATA[UI_ABILITIES[id].abCode].HealFactor * 100 or '')
        text,_ = text:gsub("AB_STATFACTORINT", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'stat_factor_int',-1,100),0))
        text,_ = text:gsub("AB_CASTTIMEFACTOR", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'casttime_factor',-1,-100),0))
        text,_ = text:gsub("AB_ATTACKSPEEDFACTOR", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'attackspeed_factor',-1,100),0))
        text,_ = text:gsub("AB_MOVESPEEDFACTOR", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'movespeed_factor',-1,100),0))
        text,_ = text:gsub("AB_STATCONSTANTAGI", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'stat_constant_agi',0),0))
        text,_ = text:gsub("AB_DURATION", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'duration',0),1))
        text,_ = text:gsub("AB_SPELLDURATION", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'spell_duration',0),1))
        text,_ = text:gsub("AB_SPELLTICK", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'spell_tick',0),1))
        text,_ = text:gsub("AB_SPELLCOUNTTICK", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'spell_tick_count',0),1))
        text,_ = text:gsub("AB_CASTTIME",TOOLTIP_GetCastTime(UI_ABILITIES[id].abCode,HERO))
    end
    return text
end

function TOOLTIP_GetDebuffData(abCode,key,inc,mult,decpl)
    inc,mult,decpl = inc or 1,mult or 1,decpl or 1
    local val = ABILITIES_DATA[abCode][key] and ABILITIES_DATA[abCode][key]() or (ABILITIES_DATA[abCode].debuff and DEBUFFS_DATA[ABILITIES_DATA[abCode].debuff][key] or (inc * -1))
    val = (val + inc) * mult
    return round(val,decpl)
end

function TOOLTIP_GetCastTime(id,unit)
    id = ABILITIES_DATA[id].castAbility or id
    local text = strRound(UNIT_GetAbilityCastingTime(id,unit),2)
    return text == '0.00' and 'Instant' or text
end