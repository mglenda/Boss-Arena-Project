----------------------------------------------------
---------------------HEROES-------------------------
----------------------------------------------------

function ReadyUp_Priest()
    UNIT_SetEnergy(HERO,0.0)
end

function UI_Priest()
    UI_LoadAbilities(HERO_PRIEST,'holy')
    UI_RefreshAbilityPositions()
    UI_RefreshAbilityData()
    UI_RefreshAbilityTrigger()
    UI_PriestFlush = nil
    UI_Priest = nil
end

function UI_PriestFlush()
    UI_PriestFlush = nil
    UI_Priest = nil
end

function CreatePriest()
    HERO = UNIT_Create(PLAYER, HERO_PRIEST, START_X, START_Y, 270.00,true)
    HERO_TYPE = HERO_PRIEST

    MISSLE_TRIGGERS[ABCODE_PENANCE] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_PENANCE], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_PENANCE])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_PENANCE], AB_Priest_PenanceMissleFly)

    MISSLE_GROUPS[ABCODE_PENANCE] = {}

    UI_Load(HERO_PRIEST)
    AB_RegisterHero(HERO_PRIEST)
    TALENTS_Load(HERO_PRIEST)

    BlzFrameSetTexture(BlzGetFrameByName("Hero_PortraitTexture", 0), 'war3mapImported\\Priest_Portrait.dds', 0, true)

    TT_SelectHero()

    UNIT_SetEnergyCap(HERO,15000.0)
    UNIT_SetEnergy(HERO,0.0)
    UNIT_SetEnergyTheme(HERO,DBM_BAR_clGOLD)

    MapSetup_AfterHero()
    CreatePriest = nil
end