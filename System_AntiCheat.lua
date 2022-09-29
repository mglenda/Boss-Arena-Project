ANTICHEAT_TARGET = nil

function AntiCheatsLoad()
    ANTICHEAT_TARGET = UNIT_Create(PLAYER_BOSS, FourCC("h003"), 15348.0, -15623.0, 270.00)

    local trg = CreateTrigger()
    TriggerRegisterUnitEvent(trg, ANTICHEAT_TARGET, EVENT_UNIT_DEATH)
    TriggerAddAction(trg, function()
        CHEAT_DETECTED = true
        print('I am sorry, but cheats are not accepted in this game, your damage is now nullified, feel free to reload the map and dont ever use cheat again.')
        DestroyTrigger(GetTriggeringTrigger())
    end)

    AntiCheatsLoad = nil
end