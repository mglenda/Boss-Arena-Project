----------------------------------------------------
---------------------HEROES-------------------------
----------------------------------------------------

HERO_FIREMAGE = FourCC("U000")
HERO_PRIEST = FourCC("H001")
HERO_WARLOCK = FourCC("H004")
HERO_DATA = {}
HERO_TYPE = nil

function HERODATA_Load()
    HERO_DATA[HERO_FIREMAGE] = {
        CreateFunc = CreateFireMage
        ,AB_memoryCleanFunc = AB_FireMage_MemoryClear
        ,AB_registerFunc = AB_RegisterHero_FireMage
        ,TALENTS_registerFunc = TALENTS_Load_FireMage
        ,TALENTS_memoryCleanFunc = TALENTS_Flush_FireMage
        ,UI_registerFunc = UI_FireMage
        ,UI_memoryCleanFunc = UI_FireMageFlush
        ,ReadyUpFunc = ReadyUp_FireMage
        ,Journal_Image = 'war3mapImported\\Mage.dds'
        ,Journal_Title = 'Mage'
        ,Journal_Difficulty = 'HARD'
        ,Journal_Type = 'CASTER'
        ,Journal_Combat = 'RANGED'
        ,Journal_Description = ''
        ,data_files = {
            bossDifficulties = 'd3be53e7-d38e-409c-954e-90581979d6ab.txt'
            ,bossRecords = 'deaebaf5-5cdb-4079-b223-fd193fd795b5.txt'
            ,talents = '6f72bcc7-3a34-4200-8827-36fcf4913547.txt'
        }
        ,PopUps = {
            [1] = {
                texture = 'war3mapImported\\FirePowerAura.dds'
                ,hideFunc = function() return UNIT_GetAbilityCastingTime(ABCODE_PYROBLAST,HERO) > 0 end
                ,showFunc = function() return UNIT_GetAbilityCastingTime(ABCODE_PYROBLAST,HERO) <= 0 and not(AB_GetTalentModifier(ABCODE_PYROBLAST,'Pyromancer')) end
                ,key = 'blasted'
            }
        }
        ,anims = {
            A_STAND_1 = {id = 0,time = 0}
            ,A_STAND_2 = {id = 1,time = 0}
            ,A_STAND_3 = {id = 2,time = 0}
            ,A_STAND_4 = {id = 3,time = 0}
            ,A_STAND_5 = {id = 4,time = 0}
            ,A_WALK = {id = 5,time = 0}
            ,A_WALK_READY = {id = 6,time = 0}
            ,A_STAND_READY = {id = 7,time = 0}
            ,A_STAND_VICTORY = {id = 8,time = 0}
            ,A_PULL = {id = 9,time = 2.47}
            ,A_DANCE = {id = 10,time = 4.97}
            ,A_ATTACK_1 = {id = 11,time = 1.97}
            ,A_ATTACK_2 = {id = 12,time = 1.97}
            ,A_ATTACK_3 = {id = 13,time = 1.97}
            ,A_ATTACK_4 = {id = 14,time = 1.97}
            ,A_SPELL_CHANNEL = {id = 15,time = 0}
            ,A_SPELL_SLAM = {id = 16,time = 0.97}
            ,A_SPELL = {id = 17,time = 0.93}
            ,A_SPELL_THROW = {id = 18,time = 0.93}
            ,A_ATTACK_SLAM = {id = 19,time = 1.47}
            ,A_SPELL_CINEMATIC = {id = 20,time = 1.8}
            ,A_DEATH = {id = 25,time = 3.0}
            ,A_DISSIPATE = {id = 26,time = 2.0}
        }
    }
    
    HERO_DATA[HERO_WARLOCK] = {
        CreateFunc = CreateWarlock
        ,AB_memoryCleanFunc = AB_Warlock_MemoryClear
        ,AB_registerFunc = AB_RegisterHero_Warlock
        ,TALENTS_registerFunc = TALENTS_Load_Warlock
        ,TALENTS_memoryCleanFunc = TALENTS_Flush_Warlock
        ,UI_registerFunc = UI_Warlock
        ,UI_memoryCleanFunc = UI_WarlockFlush
        ,ReadyUpFunc = ReadyUp_Warlock
        ,Journal_Image = 'war3mapImported\\Warlock.dds'
        ,Journal_Title = 'Warlock'
        ,Journal_Difficulty = 'EASY'
        ,Journal_Type = 'CASTER'
        ,Journal_Combat = 'RANGED'
        ,Journal_Description = 'In the face of demonic power, most heroes see death. Warlock sees only opportunity. This mighty spellcaster tames unstable fel magic and use it\'s power against his enemies. He either crush them in short damage burst periods, or build up overpowered dot debuffs.\n\n Beginner friendly class design with enjoybale pretty straightforward easy-to-learn mechanics. Warlocks only weaknes is lack of sustainable absorb shielding, but is mostly compensated by his huge damage burst windows.'
        ,data_files = {
            bossDifficulties = '7638c47e-3aa9-4849-ad91-ce9534c1b377.txt'
            ,bossRecords = 'f816ef8d-a759-487b-9c7d-445e4f4146dd.txt'
            ,talents = '16e00aa3-b421-4e26-b10f-f2a1ff8495bb.txt'
        }
        ,anims = {
            A_STAND_1 = {id = 0,time = 0}
            ,A_WALK = {id = 1,time = 0}
            ,A_STAND_READY = {id = 2,time = 0}
            ,A_ATTACK_1 = {id = 3,time = 1.04}
            ,A_DEATH = {id = 4,time = 2.78}
            ,A_STAND_HIT = {id = 5, time = 0.52}
            ,A_ATTACK_2 = {id = 6, time = 1.04}
            ,A_STAND_2 = {id = 7, time = 3.47}
            ,A_SPELL_CHANNEL_BOTH = {id = 8, time = 0}
            ,A_SPELL_THROW = {id = 9, time = 1.04}
            ,A_ATTACK_4 = {id = 10, time = 1.04}
            ,A_ATTACK_3 = {id = 11, time = 1.04}
            ,A_STAND_3 = {id = 12, time = 2.43}
            ,A_STAND_DEFEND = {id = 13, time = 0.69}
            ,A_ATTACK_5 = {id = 14, time = 1.04}
            ,A_TALK_3 = {id = 15, time = 2.08}
            ,A_TALK_2 = {id = 16, time = 1.88}
            ,A_STAND_VICTORY = {id = 17, time = 1.91}
            ,A_STAND_ALTERNATE = {id = 18, time = 0}
            ,A_TALK = {id = 19, time = 2.08}
            ,A_SPELL_CHANNEL = {id = 20, time = 0}
            ,A_SPELL_SUMMON_START = {id = 21, time = 1.04}
            ,A_SPELL_CHANNEL_POINTING = {id = 22, time = 0}
            ,A_ROAR = {id = 23, time = 1.04}
            ,A_SPELL_CHANNEL_SUMMON = {id = 24, time = 0}
        }
        ,PopUps = {
            [1] = {
                texture = 'war3mapImported\\ChaosPowerAura.dds'
                ,hideFunc = function() return not(IsAbilityAvailable(HERO,ABCODE_CHAOSBOLT)) end
                ,showFunc = function() return IsAbilityAvailable(HERO,ABCODE_CHAOSBOLT) end
                ,key = 'chaosbolt'
            }
        }
    }

    HERO_DATA[HERO_PRIEST] = {
        CreateFunc = CreatePriest
        ,AB_memoryCleanFunc = AB_Priest_MemoryClear
        ,AB_registerFunc = AB_RegisterHero_Priest
        ,TALENTS_registerFunc = TALENTS_Load_Priest
        ,TALENTS_memoryCleanFunc = TALENTS_Flush_Priest
        ,UI_registerFunc = UI_Priest
        ,UI_memoryCleanFunc = UI_PriestFlush
        ,ReadyUpFunc = ReadyUp_Priest
        ,Journal_Image = 'war3mapImported\\Priest.dds'
        ,Journal_Title = 'Priest'
        ,Journal_Difficulty = 'MEDIUM'
        ,Journal_Type = 'CASTER'
        ,Journal_Combat = 'RANGED'
        ,Journal_Description = ''
        ,data_files = {
            bossDifficulties = 'a840cede-792f-47ce-a005-7154482096a1.txt'
            ,bossRecords = '9b9722e2-863b-4816-95b4-747160a75e03.txt'
            ,talents = 'e8902958-992f-4ed5-bb6e-a24cffd4e1b9.txt'
        }
        ,anims = {
            A_STAND_1 = {id = 12,time = 0}
            ,A_STAND_2 = {id = 14,time = 5.87}
            ,A_WALK = {id = 10,time = 0}
            ,A_SPELL_THROW = {id = 11, time = 1.0}
            ,A_FLY = {id = 13, time = 0}
            ,A_SPELL_CHANNEL_POINTING = {id = 9, time = 0}
            ,A_SPRINT = {id = 2, time = 0}
            ,A_SPELL_CHANNEL_BOTH = {id = 5, time = 0}
            ,A_FLY_START = {id = 7, time = 1.0}
            ,A_FLY_END = {id = 8,time = 1.0}
            ,A_SPELL_CHANNEL_UP_START = {id = 3, time = 1.0}
            ,A_SPELL_CHANNEL_UP = {id = 4,time = 0}
            ,A_DEATH = {id = 6, time = 1.67}
            ,A_ATTACK_SPIN = {id = 1,time = 1.33}
            ,A_SPELL = {id = 0, time = 0.8}
        }
        ,PopUps = {
            [1] = {
                texture = 'war3mapImported\\HolyPowerAura.dds'
                ,hideFunc = function() return BUFF_GetStacksCount(HERO,'BLESSED') <= 0 end
                ,showFunc = function() return BUFF_GetStacksCount(HERO,'BLESSED') > 0 and IsAbilityAvailable(HERO,ABCODE_PENANCE) end
                ,key = 'blessed'
            }
        }
    }


    HERODATA_Load = nil

    HERO_PolishedAbilities_Register()
    UI_HeroJournal_Initialize()
end