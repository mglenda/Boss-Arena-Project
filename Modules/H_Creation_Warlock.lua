----------------------------------------------------
---------------------HEROES-------------------------
----------------------------------------------------

function ReadyUp_Warlock()
    UNIT_SetEnergy(HERO,0.0)
    AB_Warlock_RemoveCursedSoils_All()
    AB_Warlock_ChaosBolt_DestroyAllOrbs()
    SILENCE_silenceAbility(HERO,ABCODE_CHAOSBOLT,'noenergy')
    SILENCE_silenceAbility(HERO,ABCODE_LIFEDRAIN,'nopower')
    SILENCE_silenceAbility(HERO,ABCODE_FELMADNESS,'nopower')
end

function UI_Warlock()
    UI_LoadAbilities(HERO_WARLOCK)
    UI_RefreshAbilityPositions()
    UI_RefreshAbilityData()
    UI_RefreshAbilityTrigger()
    UI_WarlockFlush = nil
    UI_Warlock = nil
end

function UI_WarlockFlush()
    UI_WarlockFlush = nil
    UI_Warlock = nil
end

function CreateWarlock()
    HERO = UNIT_Create(PLAYER, HERO_WARLOCK, START_X, START_Y, 270.00,true)
    HERO_TYPE = HERO_WARLOCK

    MISSLE_TRIGGERS[ABCODE_SHADOWBOLTS] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_SHADOWBOLTS], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_SHADOWBOLTS])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_SHADOWBOLTS], AB_Warlock_ShadowBoltsMissleFly)

    MISSLE_GROUPS[ABCODE_SHADOWBOLTS] = {}

    MISSLE_TRIGGERS[ABCODE_CHAOSBOLT] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_CHAOSBOLT], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_CHAOSBOLT])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_CHAOSBOLT], AB_Warlock_ChaosBoltMissleFly)

    MISSLE_GROUPS[ABCODE_CHAOSBOLT] = {}

    MISSLE_TRIGGERS[ABCODE_LIFEDRAIN] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_LIFEDRAIN], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_LIFEDRAIN])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_LIFEDRAIN], AB_Warlock_LifeDrainMissleFly)

    MISSLE_GROUPS[ABCODE_LIFEDRAIN] = {}

    MISSLE_TRIGGERS[ABCODE_CURSEDSOIL] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_CURSEDSOIL], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_CURSEDSOIL])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_CURSEDSOIL], AB_Warlock_CursedSoil_Blasting)

    MISSLE_GROUPS[ABCODE_CURSEDSOIL] = {}

    MISSLE_TRIGGERS['cb_Orbs'] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS['cb_Orbs'], 0.02)
    DisableTrigger(MISSLE_TRIGGERS['cb_Orbs'])
    TriggerAddAction(MISSLE_TRIGGERS['cb_Orbs'], AB_Warlock_ChaosBolt_OrbCharging)

    MISSLE_GROUPS['cb_Orbs'] = {}

    UI_Load(HERO_WARLOCK)
    AB_RegisterHero(HERO_WARLOCK)
    TALENTS_Load(HERO_WARLOCK)

    BlzFrameSetTexture(BlzGetFrameByName("Hero_PortraitTexture", 0), 'war3mapImported\\Warlock_Portrait.dds', 0, true)

    SILENCE_silenceAbility(HERO,ABCODE_CHAOSBOLT,'noenergy')
    SILENCE_silenceAbility(HERO,ABCODE_LIFEDRAIN,'nopower')
    SILENCE_silenceAbility(HERO,ABCODE_FELMADNESS,'nopower')
    
    TT_SelectHero()

    UNIT_SetEnergyCap(HERO,100.0)
    UNIT_SetEnergy(HERO,0.0)
    UNIT_SetEnergyTheme(HERO,DBM_BAR_clDARKGREEN)

    MapSetup_AfterHero()
    CreateWarlock = nil
end