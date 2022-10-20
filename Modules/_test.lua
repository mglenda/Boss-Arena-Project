function test_keyboard()
    local trig = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trig,PLAYER,OSKEY_C,KEY_PRESSED_SHIFT,true)
    TriggerAddAction(trig, function()
        --CD_ResetAllAbilitiesCooldown(HERO)
        --FileIO:Write("warlock.txt", save_GenerateString())
    end)

    trig = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trig,PLAYER,OSKEY_X,KEY_PRESSED_SHIFT,true)
    TriggerAddAction(trig, function()
        --HERO_SetLevel(HERO_GetLevel() + 1)
        --print(FileIO:Read("fiotest.txt"))
    end)

    trig = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trig,PLAYER,OSKEY_V,KEY_PRESSED_SHIFT,true)
    TriggerAddAction(trig, function()
        --HERO_SetLevel(HERO_GetLevel() - 1)
    end)

    trig = CreateTrigger()
    TriggerRegisterPlayerChatEvent(trig, Player(0), "power", true)
    TriggerAddAction(trig, function()
        if BUFF_GetStacksCount(HERO,'POWER') == 0 then
            BUFF_AddDebuff_Stack({
                target = HERO
                ,name = 'POWER'
                ,IMMORTAL = true
            })
        else
            for i,b in pairs(DEBUFFS) do
                if b.name == 'POWER' then
                    BUFF_Attribute_SetValue(i,'IMMORTAL',false)
                    BUFF_ClearDebuff(i)
                end
            end
        end
    end)

    trig = CreateTrigger()
    TriggerRegisterPlayerChatEvent(trig, Player(0), "shadow", true)
    TriggerRegisterPlayerChatEvent(trig, Player(0), "holy", true)
    TriggerAddAction(trig, function()
        if GetEventPlayerChatString() == "shadow" then
            UI_ChangeStance(HERO_PRIEST,'shadow')
        elseif GetEventPlayerChatString() == "holy" then
            UI_ChangeStance(HERO_PRIEST,'holy')
        end
    end)


    trig = CreateTrigger()
    TriggerRegisterPlayerChatEvent(trig, Player(0), "show", true)
    TriggerRegisterPlayerChatEvent(trig, Player(0), "hide", true)
    TriggerAddAction(trig, function()
        if GetEventPlayerChatString() == "show" then
            UI_BossLegendShow(BOSS_BEASTMASTER_ID)
        elseif GetEventPlayerChatString() == "hide" then
            UI_BossLegendHide()
        end
    end)

    test_keyboard = nil
end