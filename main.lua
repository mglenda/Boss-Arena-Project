function MapSetup_AfterHero()
    DS_DamageEngine_Initialize()
    TT_LoadTargetingSystem()
    UNIT_RegisterGlobalEvents()
    DamageMeter_Initiate()
    TALENTS_UI_Initialize()
    MSX_Initialize()
    Camera_LockDistance()
    CASTSYS_Register()
    CASTMAIN_Initialize()
    REGIONS_Initialize()
    MAIN_Initialize()
    BUFF_Initialize()
    WIDGET_Initializte()
    BOSSBAR_BarCreate()
    DBM_Initialize()
    AB_SystemInit()
    CD_RegisterCooldownSystem()

    BOSS_RecalculateLevels()
    BOSS_RecalculateDifficulties()

    TOOLTIP_RegisterTooltiping()

    MapSetup_AfterHero = nil
end