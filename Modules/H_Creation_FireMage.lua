----------------------------------------------------
---------------------HEROES-------------------------
----------------------------------------------------

function ReadyUp_FireMage()
    AB_FireMage_RemoveFireOrbsAll(HERO)
    AB_FireMage_RemoveOrbsOfFire_All()
end

function UI_FireMage()
    UI_LoadAbilities(HERO_FIREMAGE)
    UI_RefreshAbilityPositions()
    UI_RefreshAbilityData()
    UI_RefreshAbilityTrigger()
    UI_FireMageFlush = nil
    UI_FireMage = nil
end

function UI_FireMageFlush()
    UI_FireMage = nil
    UI_FireMageFlush = nil
end

function CreateFireMage()
    HERO = UNIT_Create(PLAYER, HERO_FIREMAGE, START_X, START_Y, 270.00,true)
    HERO_TYPE = HERO_FIREMAGE

    MISSLE_TRIGGERS[ABCODE_PYROBLAST] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_PYROBLAST], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_PYROBLAST])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_PYROBLAST], AB_FireMage_PyroblastMissleFly)
    
    MISSLE_TRIGGERS[ABCODE_ORBS] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_ORBS], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_ORBS])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_ORBS], AB_FireOrbsMissleFly)

    MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIXCASTTIME] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIXCASTTIME], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIXCASTTIME])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIXCASTTIME], AB_FireMage_BoltsOfPhoenix_Channeling)

    MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIX] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIX], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIX])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIX], AB_FireMage_BoltsOfPhoenix_MissleFly)

    MISSLE_TRIGGERS[ABCODE_AUTOATTACK] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_AUTOATTACK], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_AUTOATTACK])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_AUTOATTACK], AB_FireMage_AutoAttack_MissleFly)

    MISSLE_TRIGGERS[ABCODE_ORBOFFIRE] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_ORBOFFIRE], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_ORBOFFIRE])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_ORBOFFIRE], AB_FireMage_OrbOfFire_Blasting)

    MISSLE_GROUPS[ABCODE_ORBS] = {}
    MISSLE_GROUPS[ABCODE_PYROBLAST] = {}
    MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX] = {}
    MISSLE_GROUPS[ABCODE_AUTOATTACK] = {}
    MISSLE_GROUPS[ABCODE_ORBOFFIRE] = {}

    UI_Load(HERO_FIREMAGE)
    AB_RegisterHero(HERO_FIREMAGE)
    TALENTS_Load(HERO_FIREMAGE)

    SILENCE_silenceAbility(HERO,ABCODE_BOLTSOFPHOENIX,'noorbs')
    TT_SelectHero()

    MapSetup_AfterHero()
    CreateFireMage = nil
end