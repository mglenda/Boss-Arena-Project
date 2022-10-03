----------------------------------------------------
----------------------------------------------------
----------------------------------------------------

function BOSS_LoadData()
    BOSS_DATA = {
       --[[[BOSS_PLAGUE_CULT] = {
            boss_id = {
                FourCC('N007')
                ,FourCC('N008')
            }
            ,BACKGROUND = 'war3mapImported\\Boss_WidgetThrall.dds'
            ,name = 'Plague Cult'
            ,Journal_Image = 'war3mapImported\\BTN_ZamidanJournal.dds'
            ,diff = {
                avail = {
                    [BOSS_DIFFICULTY_NORMAL] = false
                    ,[BOSS_DIFFICULTY_HEROIC] = false
                    ,[BOSS_DIFFICULTY_MYTHIC] = false
                }
                ,defeated = {
                    [BOSS_DIFFICULTY_NORMAL] = false
                    ,[BOSS_DIFFICULTY_HEROIC] = false
                    ,[BOSS_DIFFICULTY_MYTHIC] = false
                }
            }
            ,regions = {
                arena = {
                     Rect(672.0, 14176.0, 992.0, 14336.0)
                    ,Rect(544.0, 14048.0, 1120.0, 14208.0)
                    ,Rect(416.0, 13920.0, 1248.0, 14080.0)
                    ,Rect(288.0, 13792.0, 1376.0, 13952.0)
                    ,Rect(160.0, 13664.0, 1504.0, 13824.0)
                    ,Rect(32.0, 13536.0, 1632.0, 13696.0)
                    ,Rect(-96.0, 13408.0, 1760.0, 13568.0)
                    ,Rect(-224.0, 13280.0, 1888.0, 13440.0)
                    ,Rect(-352.0, 13152.0, 2016.0, 13312.0)
                    ,Rect(-480.0, 13024.0, 2144.0, 13184.0)
                    ,Rect(-608.0, 12896.0, 2272.0, 13056.0)
                    ,Rect(-768.0, 11392.0, 2432.0, 12928.0)
                }
                ,spawn_Hero = Rect(768.0, 11776.0, 1024.0, 12032.0)
                ,spawn_Boss = {
                    Rect(256.0, 12992.0, 480.0, 13184.0)
                    ,Rect(1248.0, 12992.0, 1472.0, 13184.0)
                }
                ,arena_Center = Rect(768.0, 12448.0, 1024.0, 12672.0)
            }
            ,sounds = {
            }
            ,quotes = {
            }
            ,initFunc = PlagueCult_Init
            ,fleeFunc = PlagueCult_Flee
            ,victoryFunc = PlagueCult_Victory
            ,defeatFunc = PlagueCult_Defeat
            ,anims = {
                A_ZAMID_STAND = {id = 0,time = 0}
                ,A_ZAMID_WALK = {id = 2, time = 0}
                ,A_ZAMID_FLY = {id = 3, time = 0}
                ,A_ZAMID_ATTACK = {id = 4, time = 0.97}
                ,A_ZAMID_ATTACK_2 = {id = 5, time = 1.0}
                ,A_ZAMID_ATTACK_3 = {id = 6, time = 0.9}
                ,A_ZAMID_ATTACK_SLAM = {id = 9, time = 1.5}
                ,A_ZAMID_FLY_HANDS = {id = 10, time = 0}
                ,A_ZAMID_CHANNEL_START = {id = 12, time = 0.88}
                ,A_ZAMID_THROW_START = {id = 13, time = 1.13}
                ,A_ZAMID_ATTACK_SPIN = {id = 14, time = 1.17}
                ,A_ZAMID_DEATH = {id = 16, time = 4.87}
                ,A_ZAMID_THROWING = {id = 19, time = 0}
                ,A_ZAMID_STAND_FLY = {id = 20, time = 0}
                ,A_ZAMID_CHANNELING = {id = 21, time = 0}
                ,A_VENAT_SUFFOCATE = {id = 0, time = 0}
                ,A_VENAT_STAND = {id = 4, time = 0}
                ,A_VENAT_FLY = {id = 6, time = 0}
                ,A_VENAT_STAND_2 = {id = 8, time = 0}
                ,A_VENAT_WALK = {id = 11, time = 0}
                ,A_VENAT_FLY_HANDS = {id = 13, time = 0}
                ,A_VENAT_ATTACK = {id = 14, time = 1.33}
                ,A_VENAT_ATTACK_2 = {id = 15, time = 1.37}
                ,A_VENAT_FLY_STUNNED = {id = 16, time = 0}
                ,A_VENAT_HIT = {id = 19, time = 0}
                ,A_VENAT_DEATH = {id = 22, time = 2.03}
                ,A_VENAT_SPELL_THROW_CHANNEL = {id = 24, time = 0}
                ,A_VENAT_SPELL_THROW = {id = 23, time = 0}
                ,A_VENAT_SPELL_THROW_START = {id = 25, time = 1.0}
                ,A_VENAT_SPELL_CHANNEL_CHANNEL = {id = 27, time = 0}
                ,A_VENAT_SPELL_CHANNEL_START = {id = 28, time = 1.0}
                ,A_VENAT_SPELL_CHANNEL = {id = 26, time = 0}
            }
        },]]--
        [BOSS_SHAMAN_ID] = {
            boss_id = {
                FourCC('N004')
            }
            ,BACKGROUND = 'war3mapImported\\Boss_WidgetThrall.dds'
            ,name = 'Shaman'
            ,Journal_Image = 'war3mapImported\\BTN_ThrallJournal.dds'
            ,Journal_ImagePushed = 'war3mapImported\\BTN_ThrallJournalPushed.dds'
            ,Journal_ImageDisabled = 'war3mapImported\\DISBTN_ThrallJournal.dds'
            ,diff = {
                avail = {
                    [BOSS_DIFFICULTY_NORMAL] = false
                    ,[BOSS_DIFFICULTY_HEROIC] = false
                    ,[BOSS_DIFFICULTY_MYTHIC] = false
                }
                ,defeated = {
                    [BOSS_DIFFICULTY_NORMAL] = false
                    ,[BOSS_DIFFICULTY_HEROIC] = false
                    ,[BOSS_DIFFICULTY_MYTHIC] = false
                }
            }
            ,regions = {
                arena = {
                    Rect(-7072.0, 11872.0, -3680.0, 14624.0)
                }
                ,spawn_Hero = Rect(-5472.0, 12736.0, -5344.0, 12864.0)
                ,spawn_Boss = Rect(-5472.0, 13652.0, -5344.0, 13780.0)
                ,arena_Center = Rect(-5409.0, 13215.0, -5407.0, 13217.0)
            }
            ,sounds = {
                init = gg_snd_SH_Init
                ,flee = gg_snd_SH_Flee
                ,defeat = gg_snd_SH_Defeat
                ,victory = gg_snd_SH_Victory
                ,elemental_nova = gg_snd_SH_ElementalNova
                ,exhausted = gg_snd_SH_Exhausted
                ,exhausted_kneeling = gg_snd_SH_ExhaustedKneeling
                ,fire_element = gg_snd_SH_FireElement
                ,lighting_element = gg_snd_SH_LightingElement
                ,lighting_orb = gg_snd_SH_LightingOrb
                ,regrowth = gg_snd_SH_Regrowth
                ,summon_totems = gg_snd_SH_SummonTotems
                ,water_element = gg_snd_SH_WaterElement
                ,wind_element = gg_snd_SH_WindElement
                ,windfury = gg_snd_SH_Windfury
            }
            ,quotes = {
                init = "I always knew this day would come."
                ,flee = "My power is all around you."
                ,defeat = "You have earned your warrior's death, old friend."
                ,victory = "No old friend. You've freed us all."
                ,elemental_nova = "The elements have spoken, azeroth is doomed !"
                ,exhausted = "Elements, hear me, give me the strenght to ... Aaaargh !"
                ,exhausted_kneeling = "Failed. I have failed this world. The elements will not speak to me."
                ,fire_element = "Fury of fire !"
                ,lighting_element = "Speed of the storm, heat my call !"
                ,lighting_orb = "Fury of storms, hear my plea !"
                ,regrowth = "Spirits of earth, aid me !"
                ,summon_totems = "Spirits, hear my call !"
                ,water_element = "Fury of water, heal our injured !"
                ,wind_element = "Wind of boundless fury, unleash your tempest !"
                ,windfury = "The very earth beneath your feet and the skies above your head, will lash out against your damned crusade !"
            }
            ,initFunc = Shaman_Init
            ,fleeFunc = Shaman_Flee
            ,victoryFunc = Shaman_Victory
            ,defeatFunc = Shaman_Defeat
            ,anims = {
                A_STAND = {id = 0,time = 0}
                ,A_SCARED = {id = 1, time = 0}
                ,A_SPELL = {id = 2, time = 0}
                ,A_SITTING = {id = 3, time = 0}
                ,A_SIT = {id = 4, time = 2.5}
                ,A_STANDUP = {id = 5, time = 2.5}
                ,A_TALK = {id = 6, time = 6.5}
                ,A_STAND_AGGRESIVE = {id = 7, time = 0}
                ,A_WALK = {id = 8, time = 0}
                ,A_WALKFAST = {id = 9, time = 0}
                ,A_TALK_2 = {id = 10, time = 4.83}
                ,A_ROAR = {id = 11, time = 5.64}
                ,A_KNEELING = {id = 12, time = 0}
                ,A_FLY = {id = 13, time = 0}
                ,A_KNEEL = {id = 14, time = 3.87}
                ,A_KNEEL_STAND = {id = 15, time = 2.0}
                ,A_TORTURE = {id = 16, time = 8.17}
                ,A_ATTACK = {id = 17, time = 1.0}
                ,A_SPELL_CHANNEL = {id = 18, time = 0}
                ,A_SPELL_THROW = {id = 20, time = 0.86}
                ,A_DEATH = {id = 21, time = 5.24}
                ,A_SIT_CHAIR = {id = 22, time = 0}
                ,A_FLY_SPELL = {id = 23, time = 0}
                ,A_FALL = {id = 24, time = 0}
                ,A_JUMPING = {id = 26, time = 0}
                ,A_JUMP_END = {id = 27, time = 1.33}
                ,A_JUMP_START = {id = 28, time = 0.8}
            }
        }
        ,[BOSS_DRUID_ID] = {
            boss_id = {
                FourCC('U002')
            }
            ,BACKGROUND = 'war3mapImported\\Boss_WidgetDruid.dds'
            ,Journal_Image = 'war3mapImported\\BTN_DruidJournal.dds'
            ,Journal_ImageDisabled = 'war3mapImported\\DISBTN_DruidJournal.dds'
            ,Journal_ImagePushed = 'war3mapImported\\BTN_DruidJournalPushed.dds'
            ,diff = {
                avail = {
                    [BOSS_DIFFICULTY_NORMAL] = false
                    ,[BOSS_DIFFICULTY_HEROIC] = false
                    ,[BOSS_DIFFICULTY_MYTHIC] = false
                }
                ,defeated = {
                    [BOSS_DIFFICULTY_NORMAL] = false
                    ,[BOSS_DIFFICULTY_HEROIC] = false
                    ,[BOSS_DIFFICULTY_MYTHIC] = false
                }
            }
            ,name = 'Druid'
            ,regions = {
                arena = {
                    Rect(-11008.0, 12544.0, -8192.0, 14368.0)
                    ,Rect(-10880.0, 12416.0, -8320.0, 12576.0)
                    ,Rect(-10752.0, 12288.0, -8448.0, 12448.0)
                    ,Rect(-10624.0, 12160.0, -8576.0, 12320.0)
                    ,Rect(-10496.0, 12032.0, -8704.0, 12192.0)
                    ,Rect(-10368.0, 11872.0, -8800.0, 12064.0)
                    ,Rect(-10240.0, 11744.0, -8960.0, 11904.0)
                    ,Rect(-10112.0, 11616.0, -9088.0, 11776.0)
                }
                ,lake = {
                    Rect(-10304.0, 11968.0, -8896.0, 12160.0)
                    ,Rect(-10208.0, 11840.0, -8992.0, 12000.0)
                    ,Rect(-10112.0, 11712.0, -9152.0, 11872.0)
                }
                ,spawn_Spirits = {
                    Rect(-11104.0, 12416.0, -10976.0, 14400.0)
                    ,Rect(-11104.0, 14336.0, -8064.0, 14464.0)
                    ,Rect(-8192.0, 12480.0, -8064.0, 14464.0)
                }
                ,spawn_Hero = Rect(-9664.0, 12640.0, -9536.0, 12768.0)
                ,spawn_Boss = Rect(-9664.0, 14048.0, -9536.0, 14176.0)
                ,arena_Center = Rect(-9664.0, 13312.0, -9536.0, 13440.0)
                ,enrage_rect = Rect(-10752.0, 12384.0, -8416.0, 14144.0)
            }
            ,sounds = {
                init = gg_snd_DU_Init
                ,flee = gg_snd_DU_Flee
                ,enroot = gg_snd_DU_Enroot
                ,starfall = gg_snd_DU_Starfall
                ,bearform = gg_snd_DU_Bearform
                ,spirits = gg_snd_DU_Spirits
                ,defeat = gg_snd_DU_Defeat
                ,victory = gg_snd_DU_Victory
            }
            ,quotes = {
                init = "Nature seeks balance, in all things."
                ,flee = "A single thought is worth many actions."
                ,enroot = "Nature is resilient."
                ,starfall = "Stand strong ! Only a bit longer."
                ,bearform = "Raaaaaargh ... !!!"
                ,spirits = "Urgh, i am under assult, assist me !"
                ,defeat = "I release you from this fate. May you finally find your peace, in death."
                ,victory = "We serve the land ... arghhhh ..."
            }
            ,initFunc = Druid_Init
            ,fleeFunc = Druid_Flee
            ,victoryFunc = Druid_Victory
            ,defeatFunc = Druid_Defeat
        }
        ,[BOSS_BEASTMASTER_ID] = {
            boss_id = {
                FourCC('U001')
            }
            ,BACKGROUND = 'war3mapImported\\Boss_WidgetBeastmaster.dds'
            ,Journal_Image = 'war3mapImported\\BTN_BeastmasterJournal.dds'
            ,Journal_ImageDisabled = 'war3mapImported\\DISBTN_BeastmasterJournal.dds'
            ,Journal_ImagePushed = 'war3mapImported\\BTN_BeastmasterJournalPushed.dds'
            ,diff = {
                avail = {
                    [BOSS_DIFFICULTY_NORMAL] = true
                    ,[BOSS_DIFFICULTY_HEROIC] = true
                    ,[BOSS_DIFFICULTY_MYTHIC] = false
                }
                ,defeated = {
                    [BOSS_DIFFICULTY_NORMAL] = false
                    ,[BOSS_DIFFICULTY_HEROIC] = false
                    ,[BOSS_DIFFICULTY_MYTHIC] = false
                }
            }
            ,name = 'Beastmaster'
            ,regions = {
                arena = {
                    Rect(-14528.0, 11840.0, -11712.0, 14368.0)
                }
                ,spawn_Hero = Rect(-13184.0, 12256.0, -13056.0, 12384.0)
                ,spawn_Boss = Rect(-13216.0, 14016.0, -13088.0, 14144.0)
                ,arena_Center = Rect(-13184.0, 13152.0, -13056.0, 13280.0)
                ,spawn_Adds = {
                    [1] = Rect(-14464.0, 11968.0, -14368.0, 14272.0)
                    ,[2] = Rect(-14464.0, 11936.0, -11776.0, 12032.0)
                    ,[3] = Rect(-11872.0, 11936.0, -11776.0, 14272.0)
                    ,[4] = Rect(-14464.0, 14176.0, -11776.0, 14272.0)
                }
            }
            ,sounds = {
                init = gg_snd_BM_Init
                ,flee = gg_snd_BM_Defeat
                ,enrage = gg_snd_BM_Enrage
                ,codowave = gg_snd_BM_CodoWave
                ,raged = gg_snd_BM_Raged
                ,summonbeast = gg_snd_BM_SummonBeasts
                ,defeat = gg_snd_BM_Flee
                ,victory = gg_snd_BM_Victory
            }
            ,quotes = {
                init = "That does it, i will hunt you down !"
                ,flee = "Phr, hardly a challenge it would seem."
                ,enrage = "Your head will soon be mounted on my wall !"
                ,codowave = "My beasts will devour you !"
                ,raged = "Raaaaaargh ... !!!"
                ,summonbeast = "Come my pets, serve your master !"
                ,defeat = "It is the law of the wild, the strong take from the weak."
                ,victory = "At last, the hunt ... is oveeerghh ..."
            }
            ,initFunc = Beastmaster_Init
            ,fleeFunc = Beastmaster_Flee
            ,victoryFunc = Beastmaster_Victory
            ,defeatFunc = Beastmaster_Defeat
        }
    }

    init_profiler()
    BOSS_LoadData = nil
end