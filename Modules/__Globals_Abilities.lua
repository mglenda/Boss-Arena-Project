----------------------------------------------------
----------------------------------------------------
----------------------------------------------------

SPELLS_DATA = {}
TALENTS_MODIFIERS = {}

AB_RANGECHECK = CreateTrigger()
AB_ORDERS = {}

ABILITIES_DATA = nil

AB_TARGET_UNIT = 0
AB_TARGET_POINT = 1
AB_TARGET_INSTANT = 2
AB_TARGET_UNITORPOINT = 3
AB_TARGET_NOCAST = 4

ABCODE_SCORCH = FourCC('A000')
ABCODE_IGNITE = FourCC('A001')
ABCODE_LUST = FourCC('LUST')
ABCODE_ORBS = FourCC('ORBS')
ABCODE_BOLTSOFPHOENIX = FourCC('A002')
ABCODE_BOLTSOFPHOENIXCASTTIME = FourCC('A003')
ABCODE_PYROBLAST = FourCC('A004')
ABCODE_SOULOFFIRE = FourCC('FMCD')
ABCODE_FLAMEBLINK = FourCC('A005')
ABCODE_ORBOFFIRE = FourCC('A007')
ABCODE_ORBOFFIREDOT = FourCC('A006')
ABCODE_AUTOATTACK = FourCC('AUTO')
ABCODE_SUMMONBEASTS = FourCC('A008')
ABCODE_CODOWAVE = FourCC('A009')
ABCODE_STARFALL = FourCC('A00A')
ABCODE_ORBOFLIGHTING = FourCC('A00B')
ABCODE_CHAINLIGHTING = FourCC('A00C')
ABCODE_LIGHTINGSHIELD = FourCC('A00D')
ABCODE_HEALINGWAVE = FourCC('A00E')
ABCODE_WINDFURY = FourCC('A00F')
ABCODE_PURGINGFLAMES = FourCC('A00G')
ABCODE_TOTEMS_ACTIVATE = FourCC('A00H')
ABCODE_FIREELEMENT = FourCC('A00L')
ABCODE_WINDELEMENT = FourCC('A00M')
ABCODE_WATERELEMENT = FourCC('A00N')
ABCODE_LIGHTINGELEMENT = FourCC('A00O')
ABCODE_FIREELEMENTDOT = FourCC('A00P')
ABCODE_ELEMENTALNOVA = FourCC('A00J')
ABCODE_FLAMESOFRAGNAROS = FourCC('A00Q')
ABCODE_ELEMENTALBLAST = FourCC('A00K')
ABCODE_PENANCE = FourCC('A00R')
ABCODE_HOLYBOLT = FourCC('A00S')
ABCODE_HOLYNOVA = FourCC('A00T')
ABCODE_POWERWORDSHIELD = FourCC('A00U')
ABCODE_LEAPOFFAITH = FourCC('A00V')
ABCODE_SACREDCURSE = FourCC('A00W')
ABCODE_SACREDCURSEDOT = FourCC('A00X')
ABCODE_POWERINFUSION = FourCC('A00Y')
ABCODE_PURIFY = FourCC('A00Z')
ABCODE_SHADOWBOLTS = FourCC('A010')
ABCODE_CHAOSBOLT = FourCC('A011')
ABCODE_LIFEDRAIN = FourCC('A012')
ABCODE_FELMADNESS = FourCC('A013')
ABCODE_FELMADNESS_DOT = FourCC('A014')
ABCODE_CURSEOFARGUS = FourCC('A015')
ABCODE_SIGILOFSARGERAS = FourCC('A016')
ABCODE_CURSEDSOIL = FourCC('A017')
ABCODE_VOIDRIFT = FourCC('A018')
ABCODE_DEMONICBLESSING = FourCC('A019')
ABCODE_SHIELDOFLEGION = FourCC('A01A')
ABCODE_LIGHTINGSPARK = FourCC('A01B')
ABCODE_VENOMPULZAR = FourCC('A01C')

ABCODE_ASMODIFIER = FourCC('ASAB')

function RegisterAbilitiesData()
    -- use IsPassive even on active abilities if you dont want to have them included in casting time recalculations

    ABILITIES_DATA = {
        [ABCODE_SHIELDOFLEGION] = {
            Name = 'Shield of Legion'
            ,ICON = 'war3mapImported\\BTN_ShieldOfLegion.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_ShieldOfLegionPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_ShieldOfLegion.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_ShieldOfLegionFocused.dds'
            ,Cooldown = 180.0
            ,IsPassive = true
            ,TARGET_TYPE = AB_TARGET_NOCAST
            ,UI_SHORTCUT = UI_SHORTCUT_3
            ,castFunc = AB_Warlock_ShieldOfLegion
            ,debuff = 'SHIELDOFLEGION'
            ,getDamage = function(caster)
                return 50000
            end
        }
        ,[ABCODE_LIFEDRAIN] = {
            Name = 'Life Drain'
            ,ICON = 'war3mapImported\\BTN_LifeDrain.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_LifeDrainPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_LifeDrain.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_LifeDrainFocused.dds'
            ,DMG_METER = true
            ,Range = 2500.00
            ,CastingTime = 2.0
            ,UI_SHORTCUT = UI_SHORTCUT_E
            ,TARGET_TYPE = AB_TARGET_UNIT
            ,barTheme = DBM_BAR_clDARKGREEN
            ,getDamage = function(caster)
                return GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) * 2.0
            end
            ,TAG_color = TAG_clLightBlue
            ,TAG_color_abs = TAG_clLightGreen
            ,spell_tick_count = function()
                return 6
            end
            ,MissleEffect = 'wl_LfDrain'
            ,MissleSpeed = 22.0
        }
        ,[ABCODE_DEMONICBLESSING] = {
            Name = 'Demonic Blessing'
            ,ICON = 'war3mapImported\\BTN_DemonicBlessing.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_DemonicBlessingPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_DemonicBlessing.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_DemonicBlessingFocused.dds'
            ,CastingTime = 0.5
            ,Cooldown = 2.0
            ,Range = 2500.00
            ,UI_SHORTCUT = UI_SHORTCUT_X
            ,TARGET_TYPE = AB_TARGET_UNIT
            ,barTheme = DBM_BAR_clDARKGREEN
            ,TAG_color = TAG_clLightGreen
            ,TAG_color_abs = TAG_clLightGreen
        }
        ,[ABCODE_VOIDRIFT] = {
            Name = 'Void Rift'
            ,IsPassive = true
            ,ICON = 'war3mapImported\\BTN_VoidRift.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_VoidRiftPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_VoidRift.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_VoidRiftFocused.dds'
            ,AOE = 300.00
            ,Cooldown = 8.0
            ,DMG_METER = true
            ,Range = 1400.00
            ,RangeAuto = true
            ,UI_SHORTCUT = UI_SHORTCUT_V
            ,TARGET_TYPE = AB_TARGET_POINT
            ,getDamage = function(caster)
                return 2.0 * I2R(GetHeroStatBJ(bj_HEROSTAT_INT, caster, true))
            end
            ,TAG_color = TAG_clBlue
        }
        ,[ABCODE_CURSEDSOIL] = {
            Name = 'Cursed Soil'
            ,ICON = 'war3mapImported\\BTN_CursedSoil.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_CursedSoilPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_CursedSoil.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_CursedSoilFocused.dds'
            ,CastingTime = 1.0
            ,AOE = 450.00
            ,Cooldown = 10.0
            ,DMG_METER = true
            ,Range = 2500.00
            ,UI_SHORTCUT = UI_SHORTCUT_C
            ,TARGET_TYPE = AB_TARGET_POINT
            ,barTheme = DBM_BAR_clBROWN
            ,getDamage = function(caster)
                return I2R(GetHeroStatBJ(bj_HEROSTAT_INT, caster, true)) * 0.5
            end
            ,getSlow_ms = function()
                return ((DEBUFFS_DATA['CURSEDSOIL'].movespeed_factor or 1) - 1) * 100.0
            end
            ,spell_tick_count = function()
                return 20
            end
            ,spell_tick = function(caster)
                return 0.5
            end
            ,TAG_color = TAG_clLightBrown
        }
        ,[ABCODE_SIGILOFSARGERAS] = {
            Name = 'Sigil of Sargeras'
            ,ICON = 'war3mapImported\\BTN_SigilOfSargeras.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_SigilOfSargerasPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_SigilOfSargeras.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_SigilOfSargerasFocused.dds'
            ,Cooldown = 80.0
            ,IsPassive = true
            ,TARGET_TYPE = AB_TARGET_NOCAST
            ,UI_SHORTCUT = UI_SHORTCUT_2
            ,castFunc = AB_Warlock_SigilOfSargeras
            ,debuff = 'SIGILOFSARGERAS'
        }
        ,[ABCODE_FELMADNESS] = {
            Name = 'Fel Madness'
            ,ICON = 'war3mapImported\\BTN_FelMadness.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_FelMadnessPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_FelMadness.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_FelMadnessFocused.dds'
            ,DMG_METER = true
            ,CastingTime = 1.0
            ,Range = 2500.00
            ,UI_SHORTCUT = UI_SHORTCUT_R
            ,TARGET_TYPE = AB_TARGET_UNIT
            ,barTheme = DBM_BAR_clRED
            ,getDamage = function(caster)
                return GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) * 3.8
            end
            ,duration = function() 
                return DEBUFFS_DATA['FELMADNESS'].duration
            end
            ,TAG_color = TAG_clOrange
        }
        ,[ABCODE_FELMADNESS_DOT] = {
            Name = 'Fel Madness DOT'
            ,CastingTime = 1.0
        }
        ,[ABCODE_SHADOWBOLTS] = {
            Name = 'Shadow Bolts'
            ,ICON = 'war3mapImported\\BTN_ShadowBolts.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_ShadowBoltsPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_ShadowBolts.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_ShadowBoltsFocused.dds'
            ,DMG_METER = true
            ,Range = 2500.00
            ,CastingTime = 1.5
            ,UI_SHORTCUT = UI_SHORTCUT_Q
            ,TARGET_TYPE = AB_TARGET_UNIT
            ,barTheme = DBM_BAR_clSHADOW
            ,getDamage = function(caster)
                return GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) * 1.0
            end
            ,TAG_color = TAG_clShadow
            ,TAG_color_abs = TAG_clShadow
            ,spell_tick_count = function()
                return 3
            end
            ,MissleEffect = 'wl_ShBolts'
            ,MissleSpeed = 22.0
        }
        ,[ABCODE_CURSEOFARGUS] = {
            Name = 'Curse Of Argus'
            ,CastingTime = 1.0
            ,ICON = 'war3mapImported\\BTN_CurseOfArgus.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_CurseOfArgusPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_CurseOfArgus.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_CurseOfArgusFocused.dds'
            ,DMG_METER = true
            ,Range = 2500.00
            ,TAG_color = TAG_clGold
        }
        ,[ABCODE_CHAOSBOLT] = {
            Name = 'Chaos Bolt'
            ,CastingTime = 1.0
            ,ICON = 'war3mapImported\\BTN_ChaosBolt.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_ChaosBoltPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_ChaosBolt.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_ChaosBoltFocused.dds'
            ,MissleEffect = 'wl_ChBolt'
            ,MissleSpeed = 22.0
            ,DMG_METER = true
            ,Range = 2500.00
            ,UI_SHORTCUT = UI_SHORTCUT_W
            ,TARGET_TYPE = AB_TARGET_UNIT
            ,barTheme = DBM_BAR_clGREEN
            ,getDamage = function(caster)
                return GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) * 7.50
            end
            ,duration = function() 
                return DEBUFFS_DATA['CURSEOFARGUS'].duration
            end
            ,TAG_color = TAG_clGold
        }
        ,[ABCODE_PENANCE] = {
            Name = 'Penance'
            ,ICON = 'war3mapImported\\BTN_Penance.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_PenancePushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_Penance.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_PenanceFocused.dds'
            ,DMG_METER = true
            ,Range = 2500.00
            ,CastingTime = 1.2
            ,Cooldown = 10.0
            ,UI_SHORTCUT = UI_SHORTCUT_W
            ,TARGET_TYPE = AB_TARGET_UNIT
            ,barTheme = DBM_BAR_clGREEN
            ,getDamage = function(caster)
                return (GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) * 3.5) * (1 + ((BUFF_GetStacksCount(caster,'BLESSED') > 0 and 1 or 0) * DEBUFFS_DATA['BLESSED'].unitdmg_constant))
            end
            ,getHeal = function(caster)
                return GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) * 3.5 * (1 + ((BUFF_GetStacksCount(caster,'BLESSED') > 0 and 1 or 0) * DEBUFFS_DATA['BLESSED'].unitdmg_constant)) * 0.75
            end
            ,TAG_color = TAG_clGold
            ,TAG_color_abs = TAG_clGold
            ,spell_tick_count = function()
                return 3
            end
            ,MissleEffect = 'pt_Penance'
            ,MissleSpeed = 28.0
            ,stance = 'holy'
        }
        ,[ABCODE_PURIFY] = {
            Name = 'Purify'
            ,ICON = 'war3mapImported\\BTN_Purify.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_PurifyPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_Purify.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_PurifyFocused.dds'
            ,CastingTime = 0.5
            ,Range = 2500.00
            ,UI_SHORTCUT = UI_SHORTCUT_X
            ,TARGET_TYPE = AB_TARGET_UNIT
            ,barTheme = DBM_BAR_clDARKGREEN
            ,TAG_color = TAG_clLightGreen
            ,TAG_color_abs = TAG_clLightGreen
            ,stance = 'holy'
        }
        ,[ABCODE_POWERINFUSION] = {
            Name = 'Power Infusion'
            ,ICON = 'war3mapImported\\BTN_PowerInfusion.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_PowerInfusionPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_PowerInfusion.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_PowerInfusionFocused.dds'
            ,Cooldown = 50.0
            ,IsPassive = true
            ,TARGET_TYPE = AB_TARGET_NOCAST
            ,UI_SHORTCUT = UI_SHORTCUT_2
            ,castFunc = AB_Priest_PowerInfusion
            ,debuff = 'POWERINFUSION'
            ,stat_factor_int = function()
                return DEBUFFS_DATA['POWERINFUSION'].stat_factor_int
            end
            ,stance = 'holy'
        }
        ,[ABCODE_SACREDCURSE] = {
            Name = 'Sacred Curse'
            ,IsPassive = true
            ,ICON = 'war3mapImported\\BTN_SacredCurse.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_SacredCursePushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_SacredCurse.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_SacredCurseFocused.dds'
            ,DMG_METER = true
            ,Range = 2500.00
            ,UI_SHORTCUT = UI_SHORTCUT_E
            ,TARGET_TYPE = AB_TARGET_UNIT
            ,barTheme = DBM_BAR_clGOLD
            ,getDamage = function(caster)
                return 1.5 * I2R(GetHeroStatBJ(bj_HEROSTAT_INT, caster, true))
            end
            ,duration = function() 
                return DEBUFFS_DATA['SACREDCURSE'].duration
            end
            ,TAG_color = TAG_clGray
            ,stance = 'holy'
        }
        ,[ABCODE_SACREDCURSEDOT] = {
            Name = 'Sacred Curse DOT'
            ,CastingTime = 1.0
        }
        ,[ABCODE_POWERWORDSHIELD] = {
            Name = 'Power Word: Shield'
            ,IsPassive = true
            ,TAG_color = TAG_clYellow
            ,TAG_color_abs = TAG_clYellow
        }
        ,[ABCODE_LEAPOFFAITH] = {
            Name = 'Leap Of Faith'
            ,IsPassive = true
            ,ICON = 'war3mapImported\\BTN_LeapOfFaith.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_LeapOfFaithPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_LeapOfFaith.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_LeapOfFaithFocused.dds'
            ,Cooldown = 4.0
            ,DMG_METER = true
            ,Range = 1500.00
            ,RangeAuto = true
            ,UI_SHORTCUT = UI_SHORTCUT_V
            ,TARGET_TYPE = AB_TARGET_POINT
            ,TAG_color = TAG_clPink
            ,stance = 'holy'
        }
        ,[ABCODE_HOLYNOVA] = {
            Name = 'Holy Nova'
            ,ICON = 'war3mapImported\\BTN_HolyEruption.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_HolyEruptionPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_HolyEruption.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_HolyEruptionFocused.dds'
            ,DMG_METER = true
            ,CastingTime = 5.0
            ,UI_SHORTCUT = UI_SHORTCUT_C
            ,TARGET_TYPE = AB_TARGET_INSTANT
            ,barTheme = DBM_BAR_clYELLOW
            ,AOE = 600.0
            ,getDamage = function(caster)
                return GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) * 1.5
            end
            ,getHeal = function(caster)
                return GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) * 0.75
            end
            ,TAG_color = TAG_clYellow
            ,TAG_color_abs = TAG_clYellow
            ,spell_tick_count = function()
                return 5
            end
            ,stance = 'holy'
        }
        ,[ABCODE_HOLYBOLT] = {
            Name = 'Holy Bolt'
            ,CastingTime = 0.5
            ,ICON = 'war3mapImported\\BTN_HolyBolt.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_HolyBoltPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_HolyBolt.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_HolyBoltFocused.dds'
            ,DMG_METER = true
            ,Range = 2500.00
            ,UI_SHORTCUT = UI_SHORTCUT_Q
            ,TARGET_TYPE = AB_TARGET_UNIT
            ,barTheme = DBM_BAR_clBROWN
            ,getDamage = function(caster)
                return 2.0 * I2R(GetHeroStatBJ(bj_HEROSTAT_INT, caster, true))
            end
            ,TAG_color = TAG_clRed
            ,stance = 'holy'
        }
        ,[ABCODE_SCORCH] = {
            Name = 'Scorch'
            ,CastingTime = 0.5
            ,ICON = 'war3mapImported\\BTN_Scorch.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_ScorchPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_Scorch.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_ScorchFocused.dds'
            ,DMG_METER = true
            ,AOE = 600.00
            ,Range = 2500.00
            ,UI_SHORTCUT = UI_SHORTCUT_Q
            ,TARGET_TYPE = AB_TARGET_UNIT
            ,barTheme = DBM_BAR_clBROWN
            ,getDamage = function(caster)
                return 1.8 * I2R(GetHeroStatBJ(bj_HEROSTAT_INT, caster, true))
            end
            ,TAG_color = TAG_clRed
        }
        ,[ABCODE_IGNITE] = {
            Name = 'Ignite'
            ,CastingTime = 1.0
            ,DMG_METER = true
            ,ICON = 'war3mapImported\\BTN_Ignite.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_Ignite.dds'
            ,UI_SHORTCUT = UI_SHORTCUT_R
            ,duration = function()
                return AB_GetTalentModifier(ABCODE_IGNITE,'Perpetual') and DEBUFFS_DATA['IGNITED'].duration + AB_GetTalentModifier(ABCODE_IGNITE,'Perpetual') or DEBUFFS_DATA['IGNITED'].duration
            end
            ,getDurationDeff = function()
                return DEBUFFS_DATA['IGNITED'].duration
            end
            ,getResistFactor = function()
                return DEBUFFS_DATA['IGNITED'].armor_constant
            end
            ,TAG_color = TAG_clOrange
        }
        ,[ABCODE_LUST] = {
            Name = 'Bloodlust'
            ,ICON = 'war3mapImported\\BTN_Bloodlust.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_BloodlustPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_Bloodlust.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_BloodlustFocused.dds'
            ,IsPassive = true
            ,Cooldown = 360.0
            ,TARGET_TYPE = AB_TARGET_NOCAST
            ,UI_SHORTCUT = UI_SHORTCUT_1
            ,castFunc = AB_Bloodlust
            ,debuff = 'BLOODLUST'
            ,stance = 'universal'
        }
        ,[ABCODE_ORBS] = {
            Name = 'Fire Orbs'
            ,IsPassive = true
            ,MaxCount = 5
            ,MissleEffect = 'fm_Orb'
            ,MissleSpeed = 4.0
        }
        ,[ABCODE_BOLTSOFPHOENIX] = {
            Name = 'Bolts of Phoenix'
            ,IsPassive = true
            ,debuff = 'FIREORB_SHIELDBUFF'
            ,getMaxStacks = function()
                return 5 + (AB_GetTalentModifier(ABCODE_BOLTSOFPHOENIX,'Protector') or 0)
            end
            ,ICON = 'war3mapImported\\BTN_PhoenixClaw.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_PhoenixClawPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_PhoenixClaw.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_PhoenixClawFocused.dds'
            ,DMG_METER = true
            ,Range = 2500.00
            ,UI_SHORTCUT = UI_SHORTCUT_W
            ,TARGET_TYPE = AB_TARGET_UNIT
            ,barTheme = DBM_BAR_clYELLOW
            ,getDamage = function(caster)
                return GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) * 2.00
            end
            ,castAbility = ABCODE_BOLTSOFPHOENIXCASTTIME
            ,HealFactor = 0.03
            ,TAG_color = TAG_clLightBlue
            ,TAG_color_abs = TAG_clLightBlue
        }
        ,[ABCODE_BOLTSOFPHOENIXCASTTIME] = {
            Name = 'Bolts of Phoenix CastTime'
            ,CastingTime = 0.33
            ,MissleEffect = 'fm_PhBolt'
            ,MissleSpeed = 20.0
        }
        ,[ABCODE_PYROBLAST] = {
            Name = 'Pyroblast'
            ,CastingTime = 5.0
            ,ICON = 'war3mapImported\\BTN_FireBolt.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_FireBoltPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_FireBolt.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_FireBoltFocused.dds'
            ,MissleEffect = 'fm_Pyro'
            ,MissleSpeed = 18.0
            ,DMG_METER = true
            ,Range = 2500.00
            ,UI_SHORTCUT = UI_SHORTCUT_E
            ,TARGET_TYPE = AB_TARGET_UNIT
            ,barTheme = DBM_BAR_clGREEN
            ,getDamage = function(caster)
                return GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) * 10.00
            end
            ,TAG_color = TAG_clGold
        }
        ,[ABCODE_SOULOFFIRE] = {
            Name = 'Soul of Fire'
            ,ICON = 'war3mapImported\\BTN_SoulOfFire.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_SoulOfFirePushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_SoulOfFire.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_SoulOfFireFocused.dds'
            ,Cooldown = 50.0
            ,IsPassive = true
            ,TARGET_TYPE = AB_TARGET_NOCAST
            ,UI_SHORTCUT = UI_SHORTCUT_2
            ,castFunc = AB_FireMage_SoulOfFire
            ,debuff = 'SOULOFFIRE'
            ,stat_factor_int = function()
                return AB_GetTalentModifier(ABCODE_SOULOFFIRE,'Soulofinferno') or DEBUFFS_DATA['SOULOFFIRE'].stat_factor_int
            end
        }
        ,[ABCODE_FLAMESOFRAGNAROS] = {
            Name = 'Flames of Ragnaros'
            ,ICON = 'war3mapImported\\BTN_FlamesOfRagnaros.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_FlamesOfRagnarosPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_FlamesOfRagnaros.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_FlamesOfRagnarosFocused.dds'
            ,Cooldown = 240.0
            ,IsPassive = true
            ,TARGET_TYPE = AB_TARGET_NOCAST
            ,UI_SHORTCUT = UI_SHORTCUT_3
            ,castFunc = AB_FireMage_FlamesOfRagnaros
            ,debuff = 'FLAMESOFRAGNAROS'
            ,getResistFactor = function()
                return DEBUFFS_DATA['FLAMESOFRAGNAROS'].armor_constant
            end
        }
        ,[ABCODE_FLAMEBLINK] = {
            Name = 'Flame Blink'
            ,IsPassive = true
            ,ICON = 'war3mapImported\\BTN_Melted.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_MeltedPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_Melted.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_MeltedFocused.dds'
            ,AOE = 300.00
            ,Cooldown = 10.0
            ,DMG_METER = true
            ,Range = 1400.00
            ,RangeAuto = true
            ,UI_SHORTCUT = UI_SHORTCUT_V
            ,TARGET_TYPE = AB_TARGET_POINT
            ,getDamage = function(caster)
                return 2.0 * I2R(GetHeroStatBJ(bj_HEROSTAT_INT, caster, true))
            end
            ,TAG_color = TAG_clPink
        }
        ,[ABCODE_ORBOFFIRE] = {
            Name = 'Orb of Fire'
            ,ICON = 'war3mapImported\\BTN_FlameBlink.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_FlameBlinkPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_FlameBlink.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_FlameBlinkFocused.dds'
            ,CastingTime = 1.0
            ,AOE = 350.00
            ,Cooldown = 8.0
            ,DMG_METER = true
            ,Range = 2500.00
            ,UI_SHORTCUT = UI_SHORTCUT_C
            ,TARGET_TYPE = AB_TARGET_POINT
            ,barTheme = DBM_BAR_clPINK
            ,getDamage = function(caster)
                return 1.5 * I2R(GetHeroStatBJ(bj_HEROSTAT_INT, caster, true))
            end
            ,getDamageDOT = function(caster)
                return 0.75 * I2R(GetHeroStatBJ(bj_HEROSTAT_INT, caster, true))
            end
            ,getImpactDamage = function(caster)
                return 2.5 * I2R(GetHeroStatBJ(bj_HEROSTAT_INT, caster, true))
            end
            ,duration = function() 
                return DEBUFFS_DATA['ORBOFFIRE'].duration
            end
            ,getSlow_ms = function()
                return ((DEBUFFS_DATA['ORBOFFIRE'].movespeed_factor or 1) - 1) * 100.0
            end
            ,getMaxStacks = function()
                return 2
            end
            ,spell_tick_count = function()
                return 6 + (AB_GetTalentModifier(ABCODE_ORBOFFIRE,'Flamer') or 0)
            end
            ,spell_tick = function()
                return 0.75
            end
            ,TAG_color = TAG_clLightBrown
        }
        ,[ABCODE_ORBOFFIREDOT] = {
            Name = 'Living Bomb DOT'
            ,CastingTime = 1.0
        }
        ,[ABCODE_AUTOATTACK] = {
            Name = 'Firebolt'
            ,MissleEffect = 'fm_AutoAtt'
            ,MissleSpeed = 20.0
            ,IsPassive = true
            ,DMG_METER = true
            ,ICON = 'war3mapImported\\BTN_AttackDamage.dds'
            ,TAG_color = TAG_clWhite
        }
        ,[ABCODE_SUMMONBEASTS] = {
            Name = 'Summon Beasts'
            ,ICON = 'war3mapImported\\BTN_SummonBeast.dds'
            ,CastingTime = 20.0
            ,IsPassive = true
            ,noSilence = true
            ,noInterrupt = true
            ,barTheme = DBM_BAR_clGREEN
        }
        ,[ABCODE_CODOWAVE] = {
            Name = 'Codo Wave'
            ,ICON = 'war3mapImported\\BTN_CodoWave.dds'
            ,CastingTime = 10.0
            ,MissleEffect = 'bm_Codo'
            ,MissleSpeed = 12.0
            ,IsPassive = true
            ,noSilence = true
            ,noInterrupt = true
            ,barTheme = DBM_BAR_clGREEN
        }
        ,[ABCODE_STARFALL] = {
            Name = 'Starfall'
            ,ICON = 'war3mapImported\\BTN_Starfall.dds'
            ,CastingTime = 10.5
            ,IsPassive = true
            ,AOE = 125.0
            ,noSilence = true
            ,noInterrupt = true
            ,barTheme = DBM_BAR_clPINK
        }
        ,[ABCODE_ORBOFLIGHTING] = {
            Name = 'Orb of Lighting'
            ,ICON = 'war3mapImported\\BTN_OrbOfLighting.dds'
            ,CastingTime = 3.0
            ,AOE = 150.0
            ,noSilence = true
            ,noInterrupt = true
            ,barTheme = DBM_BAR_clBLUE
            ,TAG_color = TAG_clAzure
        }
        ,[ABCODE_CHAINLIGHTING] = {
            Name = 'Chain Lighting'
            ,ICON = 'war3mapImported\\BTN_ChainLighting.dds'
            ,CastingTime = 5.0
            ,AOE = 350.0
            ,noSilence = true
            ,noInterrupt = true
            ,barTheme = DBM_BAR_clGRAY
            ,TAG_color = TAG_clGold
        }
        ,[ABCODE_HEALINGWAVE] = {
            Name = 'Healing Wave'
            ,ICON = 'war3mapImported\\BTN_Regrowth.dds'
            ,CastingTime = 30.0
            ,noSilence = true
            ,noInterrupt = true
            ,barTheme = DBM_BAR_clGREEN
        }
        ,[ABCODE_LIGHTINGSHIELD] = {
            Name = 'Lighting Shield'
            ,ICON = 'war3mapImported\\BTN_LightingShield.dds'
            ,CastingTime = 2.5
            ,noSilence = true
            ,noInterrupt = true
            ,barTheme = DBM_BAR_clLIGHTBLUE
            ,TAG_color_abs = TAG_clLightBlue
        }
        ,[ABCODE_WINDFURY] = {
            Name = 'Windfury'
            ,ICON = 'war3mapImported\\BTN_Windfury.dds'
            ,CastingTime = 4.0
            ,noSilence = true
            ,noInterrupt = true
            ,IsPassive = true
            ,barTheme = DBM_BAR_clDARKGREEN
        }
        ,[ABCODE_PURGINGFLAMES] = {
            Name = 'Purging Flames'
            ,ICON = 'war3mapImported\\BTN_FireNova.dds'
            ,ICON_PUSHED = 'war3mapImported\\BTN_FireNovaPushed.dds'
            ,ICON_DISABLED = 'war3mapImported\\DISBTN_FireNova.dds'
            ,ICON_FOCUSED = 'war3mapImported\\BTN_FireNovaFocused.dds'
            ,CastingTime = 0.5
            ,Range = 2500.00
            ,UI_SHORTCUT = UI_SHORTCUT_X
            ,TARGET_TYPE = AB_TARGET_UNIT
            ,barTheme = DBM_BAR_clDARKGREEN
            ,TAG_color = TAG_clLightGreen
            ,TAG_color_abs = TAG_clLightGreen
        }
        ,[ABCODE_TOTEMS_ACTIVATE] = {
            Name = 'Call the Elements'
            ,ICON = 'war3mapImported\\BTN_LightingTotem.dds'
            ,CastingTime = 3.0
            ,noSilence = true
            ,noInterrupt = true
            ,IsPassive = true
            ,barTheme = DBM_BAR_clDARKGREEN
        }
        ,[ABCODE_FIREELEMENT] = {
            Name = 'Fire Element'
            ,ICON = 'war3mapImported\\BTN_FireElement.dds'
            ,CastingTime = 20.0
            ,noSilence = true
            ,noInterrupt = true
            ,IsPassive = true
            ,barTheme = DBM_BAR_clRED
            ,TAG_color = TAG_clOrange
        }
        ,[ABCODE_WINDELEMENT] = {
            Name = 'Wind Element'
            ,ICON = 'war3mapImported\\BTN_WaterElement.dds'
            ,CastingTime = 15.0
            ,noSilence = true
            ,noInterrupt = true
            ,IsPassive = true
            ,barTheme = DBM_BAR_clGRAY
            ,TAG_color = TAG_clGray
        }
        ,[ABCODE_WATERELEMENT] = {
            Name = 'Water Element'
            ,ICON = 'war3mapImported\\BTN_WaterElement.dds'
            ,noSilence = true
            ,noInterrupt = true
            ,IsPassive = true
            ,barTheme = DBM_BAR_clGREEN
            ,TAG_color = TAG_clBlue
            ,TAG_color_abs = TAG_clBlue
        }
        ,[ABCODE_LIGHTINGELEMENT] = {
            Name = 'Lighting Element'
            ,ICON = 'war3mapImported\\BTN_LightingElement.dds'
            ,CastingTime = 18.0
            ,noSilence = true
            ,noInterrupt = true
            ,IsPassive = true
            ,barTheme = DBM_BAR_clLIGHTBLUE
            ,TAG_color = TAG_clLightBlue
        }
        ,[ABCODE_FIREELEMENTDOT] = {
            Name = 'Fire Element DOT'
            ,CastingTime = 1.0
        }
        ,[ABCODE_ELEMENTALNOVA] = {
            Name = 'Elemental Nova'
            ,ICON = 'war3mapImported\\BTN_ElementalFury.dds'
            ,CastingTime = 5.0
            ,noSilence = true
            ,noInterrupt = true
            ,IsPassive = true
            ,barTheme = DBM_BAR_clBROWN
            ,TAG_color = TAG_clGold
        }
        ,[ABCODE_LIGHTINGSPARK] = {
            Name = 'Lighting Spark'
            ,ICON = 'war3mapImported\\BTN_ElectricSpark.dds'
            ,noSilence = true
            ,noInterrupt = true
            ,IsPassive = true
            ,barTheme = DBM_BAR_clBLUE
            ,TAG_color = TAG_clBlue
        }
        ,[ABCODE_ELEMENTALBLAST] = {
            Name = 'Elemental Blast'
            ,ICON = 'war3mapImported\\BTN_ElementalBlast.dds'
            ,CastingTime = 3.0
            ,noSilence = true
            ,noInterrupt = true
            ,IsPassive = true
            ,barTheme = DBM_BAR_clRED
            ,TAG_color = TAG_clGold
        }
        ,[ABCODE_VENOMPULZAR] = {
            Name = 'Venom Pulzar'
            ,ICON = 'war3mapImported\\BTN_VenomPulzar.dds'
            ,CastingTime = 3.0
            ,noSilence = true
            ,noInterrupt = true
            ,barTheme = DBM_BAR_clDARKGREEN
        }
    }

    ABILITY_DMG_EXPECTIONS = {
        ABCODE_IGNITE
        ,ABCODE_CURSEOFARGUS
    } -- THESE ABILITIES WONT BE INCLUDED IN UNITDMG RECALCULATIONS UNLESS THEY ARE CONTAINED IN BUFF ABILITIES_DMG table, they won't be included in resistance recalculations either

    RegisterAbilitiesData = nil
end