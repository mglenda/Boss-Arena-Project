UNITS_DATA = nil

function UNIT_InitiateGlobalData()
    UNITS_DATA = {
        [HERO_FIREMAGE] = {
            ICON = 'war3mapImported\\BTN_FireMage.dds'
            ,DEF_AS = 1.5
            ,DEF_MS = 400.0
            ,DEF_ARMOR = 10
            ,DEF_REGEN = 1.0
            ,DEF_HP = 5000
            ,DEF_STR = 10
            ,DEF_STR_LVL = 0.0
            ,DEF_INT = 85
            ,DEF_INT_LVL = 0.0
            ,DEF_AGI = 20
            ,DEF_AGI_LVL = 0.0
            ,DEF_HEAL_RESIST = 0
            ,DEF_DMG = 25
            ,ABILITIES = {
                ABCODE_SCORCH
                ,ABCODE_IGNITE
                ,ABCODE_LUST
                ,ABCODE_ORBS
                ,ABCODE_BOLTSOFPHOENIX
                ,ABCODE_BOLTSOFPHOENIXCASTTIME
                ,ABCODE_PYROBLAST
                ,ABCODE_SOULOFFIRE
                ,ABCODE_FLAMEBLINK
                ,ABCODE_ORBOFFIRE
                ,ABCODE_ORBOFFIREDOT
                ,ABCODE_AUTOATTACK
                ,ABCODE_PURGINGFLAMES
                ,ABCODE_FLAMESOFRAGNAROS
                ,Get_DmgTypeAutoAttack()
            }
            ,HEIGHT_CHEST = 100.0
            ,HEIGHT_CAST = 100.0
            ,IMPACT_DIST = 50.0
        }
        ,[HERO_PRIEST] = {
            ICON = 'war3mapImported\\BTN_Priest.dds'
            ,DEF_AS = 1.5
            ,DEF_MS = 400.0
            ,DEF_ARMOR = 10
            ,DEF_REGEN = 1.0
            ,DEF_HP = 5000
            ,DEF_STR = 10
            ,DEF_STR_LVL = 0.0
            ,DEF_INT = 70
            ,DEF_INT_LVL = 0.0
            ,DEF_AGI = 20
            ,DEF_AGI_LVL = 0.0
            ,DEF_HEAL_RESIST = 0
            ,DEF_DMG = 25
            ,ABILITIES = {
                ABCODE_LUST
                ,ABCODE_PENANCE
                ,ABCODE_HOLYBOLT
                ,ABCODE_HOLYNOVA
                ,ABCODE_POWERWORDSHIELD
                ,ABCODE_LEAPOFFAITH
                ,ABCODE_SACREDCURSE
                ,ABCODE_SACREDCURSEDOT
                ,ABCODE_POWERINFUSION
                ,ABCODE_PURIFY
                ,Get_DmgTypeAutoAttack()
            }
            ,HEIGHT_CHEST = 100.0
            ,HEIGHT_CAST = 100.0
            ,IMPACT_DIST = 50.0
        }
        ,[HERO_WARLOCK] = {
            ICON = 'war3mapImported\\BTN_Warlock.dds'
            ,DEF_AS = 1.5
            ,DEF_MS = 400.0
            ,DEF_ARMOR = 0
            ,DEF_REGEN = 1.0
            ,DEF_HP = 7500
            ,DEF_STR = 0
            ,DEF_STR_LVL = 0.0
            ,DEF_INT = 150.0
            ,DEF_INT_LVL = 0.0
            ,DEF_AGI = 15
            ,DEF_AGI_LVL = 0.0
            ,DEF_HEAL_RESIST = 0
            ,DEF_DMG = 0
            ,ABILITIES = {
                ABCODE_LUST
                ,ABCODE_SHADOWBOLTS
                ,ABCODE_CHAOSBOLT
                ,ABCODE_LIFEDRAIN
                ,ABCODE_FELMADNESS
                ,ABCODE_FELMADNESS_DOT
                ,ABCODE_CURSEOFARGUS
                ,ABCODE_SIGILOFSARGERAS
                ,ABCODE_CURSEDSOIL
                ,ABCODE_VOIDRIFT
                ,ABCODE_DEMONICBLESSING
                ,ABCODE_SHIELDOFLEGION
                ,Get_DmgTypeAutoAttack()
            }
            ,HEIGHT_CHEST = 100.0
            ,HEIGHT_CAST = 100.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('h000')] = {
            ICON = 'war3mapImported\\BTN_Footman.dds'
            ,ABILITIES = {
                Get_DmgTypeAutoAttack()
            }
            ,DEF_HEAL_RESIST = 0
            ,DEF_ARMOR = 0
            ,DEF_AS = 1.35
            ,DEF_MS = 270.0
            ,DEF_REGEN = 0.0
            ,DEF_HP = 200
            ,DEF_DMG = 25
            ,HEIGHT_CHEST = 100.0
            ,HEIGHT_CAST = 100.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('h003')] = {
            ICON = 'war3mapImported\\BTN_Footman.dds'
            ,DEF_HEAL_RESIST = 0
            ,DEF_ARMOR = 50
            ,DEF_AS = 100.0
            ,DEF_MS = 0.0
            ,DEF_REGEN = 150.0
            ,DEF_HP = 5000
            ,DEF_DMG = 0
            ,HEIGHT_CHEST = 100.0
            ,HEIGHT_CAST = 100.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('h002')] = {
            ICON = 'war3mapImported\\BTN_TrainingDummy.dds'
            ,DEF_HEAL_RESIST = 0
            ,DEF_ARMOR = 0
            ,DEF_AS = 100.0
            ,DEF_MS = 0.0
            ,DEF_REGEN = 1.0
            ,DEF_HP = 2500
            ,DEF_DMG = 0
            ,IMMORTAL = true
            ,HEIGHT_CHEST = 180.0
            ,HEIGHT_CAST = 180.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('U001')] = {
            ICON = 'war3mapImported\\BTN_Beastmaster.dds'
            ,DEF_AS = 1.0
            ,DEF_MS = 250.0
            ,DEF_ARMOR = 10
            ,DEF_REGEN = 2.0
            ,DEF_HP = 85000
            ,DEF_STR = 100
            ,DEF_STR_LVL = 5.0
            ,DEF_INT = 16
            ,DEF_INT_LVL = 0.0
            ,DEF_AGI = 15
            ,DEF_AGI_LVL = 0.8
            ,DEF_DMG = 550
            ,ABILITIES = {
                Get_DmgTypeAutoAttack()
                ,ABCODE_SUMMONBEASTS
                ,ABCODE_CODOWAVE
            }
            ,DEF_HEAL_RESIST = 0
            ,STUN_IMMUNE = true
            ,HEIGHT_CHEST = 200.0
            ,HEIGHT_CAST = 200.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('n000')] = {
            ICON = 'war3mapImported\\BTN_TimberWolf.dds'
            ,ABILITIES = {
                Get_DmgTypeAutoAttack()
            }
            ,DEF_HEAL_RESIST = 0
            ,DEF_ARMOR = 0
            ,DEF_AS = 1.2
            ,DEF_MS = 450.0
            ,DEF_REGEN = 2.0
            ,DEF_HP = 1150
            ,DEF_DMG = 18
            ,CritRate = 25
            ,HEIGHT_CHEST = 40.0
            ,HEIGHT_CAST = 40.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('n001')] = {
            ICON = 'war3mapImported\\BTN_DireQuillbeast.dds'
            ,ABILITIES = {
                Get_DmgTypeAutoAttack()
            }
            ,DEF_HEAL_RESIST = 0
            ,DEF_ARMOR = 4
            ,DEF_AS = 1.5
            ,DEF_MS = 380.0
            ,DEF_REGEN = 3.0
            ,DEF_HP = 1800
            ,DEF_DMG = 25
            ,HEIGHT_CHEST = 50.0
            ,HEIGHT_CAST = 50.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('n002')] = {
            ICON = 'war3mapImported\\BTN_RagingQuillbeast.dds'
            ,ABILITIES = {
                Get_DmgTypeAutoAttack()
            }
            ,DEF_HEAL_RESIST = 0
            ,DEF_ARMOR = 10
            ,DEF_AS = 1.8
            ,DEF_MS = 350.0
            ,DEF_REGEN = 5.0
            ,DEF_HP = 4100
            ,DEF_DMG = 56
            ,CritRate = 20
            ,HEIGHT_CHEST = 50.0
            ,HEIGHT_CAST = 50.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('n003')] = {
            ICON = 'war3mapImported\\BTN_ArmoredBear.dds'
            ,ABILITIES = {
                Get_DmgTypeAutoAttack()
            }
            ,DEF_HEAL_RESIST = 0
            ,DEF_ARMOR = 30
            ,DEF_AS = 1.7
            ,DEF_MS = 400.0
            ,DEF_REGEN = 12.0
            ,DEF_HP = 10500
            ,DEF_DMG = 112
            ,CritRate = 50
            ,HEIGHT_CHEST = 80.0
            ,HEIGHT_CAST = 80.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('U002')] = {
            ICON = 'war3mapImported\\BTN_Druid.dds'
            ,DEF_AS = 1.0
            ,DEF_MS = 350.0
            ,DEF_ARMOR = 0
            ,DEF_REGEN = 5.0
            ,DEF_HP = 450000
            ,DEF_STR = 15
            ,DEF_STR_LVL = 0.0
            ,DEF_INT = 200
            ,DEF_INT_LVL = 5.0
            ,DEF_AGI = 15
            ,DEF_AGI_LVL = 0.8
            ,DEF_DMG = 350
            ,ABILITIES = {
                Get_DmgTypeAutoAttack()
                ,ABCODE_STARFALL
            }
            ,DEF_HEAL_RESIST = 0
            ,STUN_IMMUNE = true
            ,HEIGHT_CHEST = 200.0
            ,HEIGHT_CAST = 200.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('e000')] = {
            ICON = 'war3mapImported\\BTN_SpiritsOfTheForest.dds'
            ,DEF_HEAL_RESIST = 0
            ,DEF_ARMOR = 0
            ,DEF_AS = 100.0
            ,DEF_MS = 0.0
            ,DEF_REGEN = 0.0
            ,DEF_HP = 1
            ,DEF_DMG = 0
            ,HEIGHT_CHEST = 120.0
            ,HEIGHT_CAST = 120.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('N004')] = {
            ICON = 'war3mapImported\\BTN_Thrall.dds'
            ,DEF_AS = 1.5
            ,DEF_MS = 320.0
            ,DEF_ARMOR = 15
            ,DEF_REGEN = 1.0
            ,DEF_HP = 640000
            ,DEF_STR = 15
            ,DEF_STR_LVL = 0.0
            ,DEF_INT = 500
            ,DEF_INT_LVL = 5.0
            ,DEF_AGI = 15
            ,DEF_AGI_LVL = 1.0
            ,DEF_DMG = 100
            ,ABILITIES = {
                Get_DmgTypeAutoAttack()
                ,ABCODE_ORBOFLIGHTING
                ,ABCODE_CHAINLIGHTING
                ,ABCODE_HEALINGWAVE
                ,ABCODE_LIGHTINGSHIELD
                ,ABCODE_WINDFURY
                ,ABCODE_LIGHTINGELEMENT
                ,ABCODE_FIREELEMENT
                ,ABCODE_TOTEMS_ACTIVATE
                ,ABCODE_WATERELEMENT
                ,ABCODE_FIREELEMENTDOT
                ,ABCODE_WINDELEMENT
                ,ABCODE_ELEMENTALNOVA
                ,ABCODE_ELEMENTALBLAST
                ,ABCODE_LIGHTINGSPARK
            }
            ,DEF_HEAL_RESIST = 0
            ,STUN_IMMUNE = true
            ,HEIGHT_CHEST = 150.0
            ,HEIGHT_CAST = 150.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('n005')] = {
            ICON = 'war3mapImported\\BTN_WindElemental.dds'
            ,ABILITIES = {
                Get_DmgTypeAutoAttack()
            }
            ,DEF_HEAL_RESIST = 0
            ,DEF_ARMOR = 0
            ,DEF_AS = 0.8
            ,DEF_MS = 400.0
            ,DEF_REGEN = 5.0
            ,DEF_HP = 8500
            ,DEF_DMG = 20
            ,CritRate = 25
            ,HEIGHT_CHEST = 50.0
            ,HEIGHT_CAST = 50.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('n006')] = { --Heroic
            ICON = 'war3mapImported\\BTN_WindElemental.dds'
            ,ABILITIES = {
                Get_DmgTypeAutoAttack()
            }
            ,DEF_HEAL_RESIST = 0
            ,DEF_ARMOR = 0
            ,DEF_AS = 0.8
            ,DEF_MS = 400.0
            ,DEF_REGEN = 50.0
            ,DEF_HP = 8500
            ,DEF_DMG = 40
            ,CritRate = 75
            ,HEIGHT_CHEST = 50.0
            ,HEIGHT_CAST = 50.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('N007')] = {
            ICON = 'war3mapImported\\BTN_Zamidan.dds'
            ,DEF_AS = 1.5
            ,DEF_MS = 320.0
            ,DEF_ARMOR = 0
            ,DEF_REGEN = 1.0
            ,DEF_HP = 640000
            ,DEF_STR = 15
            ,DEF_STR_LVL = 0.0
            ,DEF_INT = 750
            ,DEF_INT_LVL = 5.0
            ,DEF_AGI = 20
            ,DEF_AGI_LVL = 1.0
            ,DEF_DMG = 100
            ,ABILITIES = {
                Get_DmgTypeAutoAttack()
                ,ABCODE_VENOMPULZAR
            }
            ,DEF_HEAL_RESIST = 0
            ,STUN_IMMUNE = true
            ,HEIGHT_CHEST = 200.0
            ,HEIGHT_CAST = 200.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('N008')] = {
            ICON = 'war3mapImported\\BTN_Venatrix.dds'
            ,DEF_AS = 1.5
            ,DEF_MS = 320.0
            ,DEF_ARMOR = 0
            ,DEF_REGEN = 1.0
            ,DEF_HP = 640000
            ,DEF_STR = 15
            ,DEF_STR_LVL = 0.0
            ,DEF_INT = 750
            ,DEF_INT_LVL = 5.0
            ,DEF_AGI = 20
            ,DEF_AGI_LVL = 1.0
            ,DEF_DMG = 100
            ,ABILITIES = {
                Get_DmgTypeAutoAttack()
            }
            ,DEF_HEAL_RESIST = 0
            ,STUN_IMMUNE = true
            ,HEIGHT_CHEST = 200.0
            ,HEIGHT_CAST = 200.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('n009')] = {
            ICON = 'war3mapImported\\BTN_DeathSingularity'
            ,DEF_HEAL_RESIST = 0
            ,DEF_ARMOR = 0
            ,DEF_AS = 100.0
            ,DEF_MS = 0.0
            ,DEF_REGEN = 0.0
            ,DEF_HP = 150000
            ,DEF_DMG = 0
            ,HEIGHT_CHEST = 100.0
            ,HEIGHT_CAST = 100.0
            ,IMPACT_DIST = 50.0
        }
        ,[FourCC('n00A')] = {
            ICON = 'war3mapImported\\BTN_VenomSingularity'
            ,DEF_HEAL_RESIST = 0
            ,DEF_ARMOR = 0
            ,DEF_AS = 100.0
            ,DEF_MS = 0.0
            ,DEF_REGEN = 0.0
            ,DEF_HP = 150000
            ,DEF_DMG = 0
            ,HEIGHT_CHEST = 100.0
            ,HEIGHT_CAST = 100.0
            ,IMPACT_DIST = 50.0
        }
    }

    UNIT_InitiateGlobalData = nil
end