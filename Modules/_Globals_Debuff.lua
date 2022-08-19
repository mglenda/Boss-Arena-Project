--required in buffs data: target,buff_name

-- info settings
-- notDispellable = true 
-- movespeed_factorStacks = true
-- movespeed_factor = logic speed * factor
-- movespeed_root = true
-- attackspeed_factor = logic speed * factor
-- attackspeed_factorStacks = true
-- isDebuff = true
-- armor_constantStacks = true
-- armor_constant = logic armor + constant
-- healres_constant = logic res + constant
-- healres_constantStacks = true
-- regen_constant = logic regen + constant
-- regen_constantStacks = true
-- regen_factor = logic regen * factor
-- regen_factorStacks = true
-- hp_constant = logic hp + constant
-- hp_constantStacks = true
-- hp_factor = logic hp * factor
-- hp_factorStacks = true
-- stat_constant_str = logic str + constant
-- stat_constantStacks_str = true
-- stat_factor_str = logic str * factor
-- stat_factorStacks_str = true
-- stat_constant_int = logic int + constant
-- stat_constantStacks_int = true
-- stat_factor_int = logic int * factor
-- stat_factorStacks_int = true
-- stat_constant_agi = logic agi + constant
-- stat_constantStacks_agi = true
-- stat_factor_agi = logic agi * factor
-- stat_factorStacks_agi = true
-- dmg_constant = logic dmg + constant
-- dmg_constantStacks = true
-- dmg_factor = logic dmg * factor
-- dmg_factorStacks = true
-- unitdmg_constant = logic dmg + constant
-- unitdmg_constantStacks = true
-- unitdmg_factor = logic dmg * factor
-- unitdmg_factorStacks = true
-- unitcrit_constant = logic dmg + constant
-- unitcrit_constantStacks = true
-- unitcritMult_constant = logic dmg + constant
-- unitcritMult_constantStacks = true
-- casttime_factor
-- casttime_constant
-- casttime_factorStacks
-- casttime_constantStacks
-- debuffPriority for UI sorting and effect applying prioritization, lower values applies last which means their effect has biggest impact, when not defined it gains DEBUFFS_DEFAULT_PRIORITY_VALUE
-- LOWEST == 10,HIGHEST == 0
-- dotAbility = logic ABILITYID which defines dot/hot, casting time of this ability will be used as tick_period, tick_period is overriden
-- shieldAbility
-- healabsAbility
-- if caster is not declared using dotAbility param, then default ability castingtime is going to be used

-- unitdmgvic_constant = logic dmg + constant
-- unitdmgvic_constantStacks = true
-- unitdmgvic_factor = logic dmg * factor
-- unitdmgvic_factorStacks = true
-- unitcritvic_constant
-- unitcritvic_constantStacks
-- unitcritMultvic_constant
-- unitcritMultvic_constantStacks

-- ABILITIES_DMGVIC = {} table list of abilityCodes which are affected by unitdmg, unitcrit, unitcritmult and casttime
-- ABILITIES_DMG
-- ABILITIES_CRIT
-- ABILITIES_CRITMULT
-- ABILITIES_CRITVIC
-- ABILITIES_CRITMULTVIC
-- ABILITIES_CASTTIME

BUFF_SEED = 0
BUFF_SEED_MAX = 10000
DEBUFF_TRIGGER = CreateTrigger()

DEBUFFS = {}
T_DEBUFFS = {}

trg_buff_id = nil
clr_buff_id = nil

DEBUFFS_DEFAULT_PRIORITY_VALUE = 10
DEBUFFS_DEFAULT_TEXT_COLOR = BlzConvertColor(255, 255, 255, 255)

UI_COLOR_TXT_Black = BlzConvertColor(255, 0, 0, 0)

DEBUFFS_DATA = {
    ['FELMADNESS'] = {
        duration = 5
        ,deathpersistent = false
        ,isDebuff = true
        ,ICON = 'war3mapImported\\BTN_FelMadnessDebuff.dds'
        ,debuffPriority = 1
        ,movespeed_factor = 0.5
        ,movespeed_factorStacks = true
        ,dotAbility = ABCODE_FELMADNESS_DOT
        ,effect_mdl = 'Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl'
        ,effect_where = 'chest'
        ,effect_unique = true
        ,txtColor = UI_COLOR_TXT_Black
    }
    ,['CHAOS_BOLT'] = {
        deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_ChaosBoltBuff.dds'
        ,debuffPriority = -1
        ,notDispellable = true
        ,txtColor = UI_COLOR_TXT_Black
    }
    ,['SHIELDOFLEGION'] = {
        deathpersistent = false
        ,duration = 5
        ,ICON = 'war3mapImported\\BTN_ShieldOfLegionBuff.dds'
        ,debuffPriority = 0
        ,effect_mdl = 'Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl'
        ,effect_where = 'chest'
        ,effect_unique = true
        ,shieldAbility = ABCODE_SHIELDOFLEGION
        ,exitFunc = function() 
            return not(DS_GetAbsorb_AbilityStack(DEBUFFS[trg_buff_id].target,DEBUFFS[trg_buff_id].shieldAbility,trg_buff_id))
        end
    }
    ,['DEMONICBLESSING'] = {
        debuffPriority = 3
        ,ICON = 'war3mapImported\\BTN_DemonicBlessingBuff.dds'
        ,deathpersistent = false
        ,duration = 2
        ,tick_period = 0.5
        ,tickFunc = function()
            AB_Warlock_DemonicBlessing_Dispell(DEBUFFS[trg_buff_id].caster,DEBUFFS[trg_buff_id].target)
        end
    }
    ,['SIGILOFSARGERAS'] = {
        duration = 15
        ,effect_mdl = 'Abilities\\Spells\\NightElf\\Immolation\\ImmolationTarget.mdl'
        ,effect_where = 'chest'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_SigilOfSargerasBuff.dds'
        ,debuffPriority = 1
        ,casttime_factor = 0.90
        ,stat_constant_agi = 15
        ,endFunc = function()
            if BUFF_GetStacksCount(DEBUFFS[clr_buff_id].target,'CHAOS_BOLT') <= 0 then
                SILENCE_silenceAbility(DEBUFFS[clr_buff_id].target,ABCODE_CHAOSBOLT,'noenergy')
            end
        end
    }
    ,['CURSEDSOIL'] = {
        duration = 1
        ,effect_mdl = 'Abilities\\Spells\\Other\\AcidBomb\\BottleImpact.mdl'
        ,effect_where = 'origin'
        ,deathpersistent = false
        ,isDebuff = true
        ,ICON = 'war3mapImported\\BTN_CursedSoilDebuff.dds'
        ,debuffPriority = 3
        ,movespeed_factor = 0.20
        ,movespeed_factorStacks = false
        ,effect_scale = 2.0
    }
    ,['CURSEOFARGUS'] = {
        duration = 5
        ,effect_mdl = 'Abilities\\Spells\\NightElf\\Immolation\\ImmolationTarget.mdl'
        ,effect_where = 'chest'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_CurseOfArgusDebuff.dds'
        ,isDebuff = true
        ,debuffPriority = 1
        ,dotAbility = ABCODE_CURSEOFARGUS
        ,unitdmgvic_constant = 0.2
        ,unitdmgvic_constantStacks = true
        ,ABILITIES_DMGVIC = {
            ABCODE_CHAOSBOLT
            ,ABCODE_FELMADNESS
        }
    }
    ,['VOID_ENERGY'] = {
        deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_ShadowBoltsBuff.dds'
        ,debuffPriority = -1
        ,notDispellable = true
    }
    ,['LIFEDRAIN'] = {
        effect_mdl = 'Abilities\\Spells\\Other\\Drain\\DrainTarget.mdl'  
        ,effect_where = 'overhead'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_LifeDrainDebuff.dds'
        ,isDebuff = true
        ,debuffPriority = 2
        ,attackspeed_factor = 0.20
        ,movespeed_factor = 0.20
        ,notDispellable = true
        ,effect_scale = 1.5
    }
    ,['IGNITED'] = {
        duration = 6
        ,effect_mdl = 'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl'
        ,effect_where = 'chest'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_Ignite_Debuff.dds'
        ,isDebuff = true
        ,debuffPriority = 4
        ,dotAbility = ABCODE_IGNITE
        ,unitdmgvic_constant = 0.05
        ,unitdmgvic_constantStacks = true
        ,ABILITIES_DMGVIC = {
            ABCODE_BOLTSOFPHOENIX
            ,ABCODE_PYROBLAST
        }
        ,unitcritvic_constant = 20
        ,ABILITIES_CRITVIC = {
            ABCODE_SCORCH
        }
        ,unitcritMultvic_constant = 0.1 * DAMAGE_DEFAULT_CRIT_MULTP
        ,unitcritMultvic_constantStacks = true
        ,ABILITIES_CRITMULTVIC = {
            ABCODE_PYROBLAST
        }
        ,armor_constantStacks = true
        ,armor_constant = -1
    }
    ,['FLAMESOFRAGNAROS'] = {
        debuffPriority = 0
        ,ICON = 'war3mapImported\\BTN_FlamesOfRagnarosBuff.dds'
        ,deathpersistent = false
        ,effect_where = 'origin'
        ,effect_scale = 2.0
        ,effect_mdl = 'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl'
        ,armor_constant = 70.0
        ,duration = 4
        ,notDispellable = true
    }
    ,['ORBOFFIRE'] = {
        duration = 8
        ,effect_mdl = 'Abilities\\Spells\\Other\\Incinerate\\IncinerateBuff.mdl'
        ,effect_where = 'chest'
        ,deathpersistent = false
        ,isDebuff = true
        ,ICON = 'war3mapImported\\BTN_FlameBlinkDebuff.dds'
        ,debuffPriority = 3
        ,movespeed_factor = 0.70
        ,movespeed_factorStacks = true
        ,dotAbility = ABCODE_ORBOFFIREDOT
        ,unitcritvic_constant = 10
        ,ABILITIES_CRITVIC = {
            ABCODE_SCORCH
        }
    }
    ,['BLOODLUST'] = {
        duration = 30
        ,effect_mdl = 'Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl'  
        ,effect_where = 'overhead'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_BloodlustBuff.dds'
        ,debuffPriority = 0
        ,casttime_factor = 0.70
        ,attackspeed_factor = 1.30
        ,movespeed_factor = 1.30
        ,notDispellable = true
    }
    ,['BLINKFURY'] = {
        duration = 4
        ,effect_mdl = 'Environment\\NightElfBuildingFire\\ElfLargeBuildingFire1.mdl'  
        ,effect_where = 'origin'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_BlinkFuryBuff.dds'
        ,debuffPriority = 3
        ,movespeed_factor = 1.8
    }
    ,['FIREORB_SHIELDBUFF'] = {
        deathpersistent = false
        ,duration = 12
        ,ICON = 'war3mapImported\\BTN_PhoenixClawBuff.dds'
        ,debuffPriority = 4
        ,effect_mdl = 'war3mapImported\\Ubershield Ember.mdx'
        ,effect_where = 'chest'
        ,shieldAbility = ABCODE_BOLTSOFPHOENIX
        ,exitFunc = function() 
            return not(DS_GetAbsorb_AbilityStack(DEBUFFS[trg_buff_id].target,DEBUFFS[trg_buff_id].shieldAbility,trg_buff_id))
        end
    }
    ,['POWERWORD_SHIELD'] = {
        deathpersistent = false
        ,duration = 25
        ,ICON = 'war3mapImported\\BTN_PowerWordShieldBuff.dds'
        ,debuffPriority = 4
        ,effect_mdl = 'war3mapImported\\Sacred Guard Gold.mdx'
        ,effect_where = 'chest'
        ,effect_unique = true
        ,shieldAbility = ABCODE_POWERWORDSHIELD
        ,exitFunc = function() 
            return not(DS_GetAbsorb_AbilityStack(DEBUFFS[trg_buff_id].target,DEBUFFS[trg_buff_id].shieldAbility,trg_buff_id))
        end
        ,txtColor = UI_COLOR_TXT_Black
    }
    ,['HOLYFOCUS'] = {
        deathpersistent = false
        ,duration = 8
        ,ICON = 'war3mapImported\\BTN_HolyBoltDebuff.dds'
        ,debuffPriority = 3
        ,unitdmgvic_constant = 0.1
        ,unitdmgvic_constantStacks = true
        ,ABILITIES_DMGVIC = {
            ABCODE_PENANCE
            ,ABCODE_HOLYNOVA
            ,ABCODE_HOLYBOLT
        }
        ,txtColor = UI_COLOR_TXT_Black
    }
    ,['POWERINFUSION'] = {
        duration = 20
        ,effect_mdl = 'Environment\\NightElfBuildingFire\\ElfLargeBuildingFire1.mdl'
        ,effect_where = 'chest'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_PowerInfusionBuff.dds'
        ,debuffPriority = 1
        ,casttime_factor = 0.80
        ,stat_constant_agi = 20
    }
    ,['ATONEMENT'] = {
        duration = 18
        ,effect_mdl = 'Abilities\\Spells\\NightElf\\Rejuvenation\\RejuvenationTarget.mdl'
        ,effect_where = 'overhead'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_AtonementBuff.dds'
        ,debuffPriority = 1
        ,casttime_factor = 0.90
        ,stat_factor_int = 1.25
        ,stat_constant_agi = 10
    }
    ,['SACREDCURSE'] = {
        duration = 8
        ,effect_mdl = 'Abilities\\Spells\\Human\\InnerFire\\InnerFireTarget.mdl'
        ,effect_where = 'overhead'
        ,deathpersistent = false
        ,isDebuff = true
        ,ICON = 'war3mapImported\\BTN_SacredCurseDebuff.dds'
        ,debuffPriority = 3
        ,movespeed_factor = 0.65
        ,movespeed_factorStacks = true
        ,dotAbility = ABCODE_SACREDCURSEDOT
        ,unitcritvic_constant = 10
        ,ABILITIES_CRITVIC = {
            ABCODE_HOLYBOLT
        }
        ,unitdmgvic_constant = 0.25
        ,unitdmgvic_constantStacks = true
        ,ABILITIES_DMGVIC = {
            ABCODE_PENANCE
            ,ABCODE_HOLYNOVA
        }
    }
    ,['BLESSED'] = {
        deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_HolyBoltBuff.dds'
        ,debuffPriority = 2
        ,effect_mdl = 'Abilities\\Spells\\Human\\InnerFire\\InnerFireTarget.mdl'
        ,effect_where = 'overhead'
        ,unitdmg_constant = 0.5
        ,ABILITIES_DMG = {}
        ,txtColor = UI_COLOR_TXT_Black
    }
    ,['FIREORB_PYROBUFF'] = {
        deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_FireBoltBuff.dds'
        ,debuffPriority = -1
        ,notDispellable = true
        ,casttime_constant = -1
        ,casttime_constantStacks = true
        ,ABILITIES_CASTTIME = {
            ABCODE_PYROBLAST
        }
    }
    ,['SOULOFFIRE'] = {
        duration = 18
        ,effect_mdl = 'Environment\\NightElfBuildingFire\\ElfLargeBuildingFire1.mdl'
        ,effect_where = 'chest'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_SoulOfFireBuff.dds'
        ,debuffPriority = 1
        ,casttime_factor = 0.90
        ,attackspeed_factor = 1.1
        ,stat_factor_int = 1.5
        ,stat_constant_agi = 15
    }
    ,['CALLOFALPHA'] = {
        effect_mdl = 'Abilities\\Spells\\NightElf\\BattleRoar\\RoarTarget.mdl'
        ,effect_where = 'overhead'
        ,deathpersistent = false
        ,notDispellable = true
        ,ICON = 'war3mapImported\\BTN_SummonBeastBuff.dds'
        ,debuffPriority = 1
        ,attackspeed_factor = 1.35
        ,attackspeed_factorStacks = true
        ,armor_constant = 5
        ,armor_constantStacks = true
        ,hp_factor = 1.15
        ,hp_factorStacks = true
        ,dmg_factor = 1.25
        ,dmg_factorStacks = true
    }
    ,['STUN'] = {
        effect_mdl = 'Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl'
        ,effect_where = 'overhead'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_StunDebuff.dds'
        ,debuffPriority = 0
        ,isDebuff = true
    }
    ,['STARFALL_HIT'] = {
        effect_mdl = 'Abilities\\Spells\\Undead\\Cripple\\CrippleTarget.mdl'
        ,effect_where = 'overhead'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_StarfallDebuff.dds'
        ,debuffPriority = 1
        ,isDebuff = true
        ,armor_constant = -5
        ,armor_constantStacks = true
        ,casttime_factor = 1.25
        ,casttime_factorStacks = true
        ,movespeed_factor = 0.25
        ,duration = 5.0
    }
    ,['FORESTSPIRIT_BUFF'] = {
        effect_mdl = 'Abilities\\Spells\\Other\\Drain\\ManaDrainTarget.mdl'
        ,effect_where = 'origin'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_SpiritsOfTheForestBuff.dds'
        ,debuffPriority = 1
        ,movespeed_factorStacks = true
        ,movespeed_factor = 0.97
        ,armor_constantStacks = true
        ,armor_constant = 1
        ,notDispellable = true
    }
    ,['FORESTSPIRIT_DEBUFF'] = {
        effect_mdl = 'Abilities\\Spells\\Other\\Drain\\ManaDrainTarget.mdl'
        ,effect_where = 'origin'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_SpiritsOfTheForestDebuff.dds'
        ,debuffPriority = 0
        ,isDebuff = true
        ,hp_factor = 0.75
        ,hp_factorStacks = true
        ,unitdmg_constant = 0.25
        ,unitdmg_constantStacks = true
        ,stat_constant_agi = 1
        ,stat_constantStacks_agi = true
        ,notDispellable = true
    }
    ,['BEARFORM'] = {
        ICON = 'war3mapImported\\BTN_BearFormBuff.dds'
        ,debuffPriority = 0
        ,movespeed_factor = 1.8
        ,armor_constant = 30
        ,dmg_constant = 650.0
        ,notDispellable = true
    }
    ,['ROOT'] = {
        ICON = 'war3mapImported\\BTN_RootsDebuff.dds'
        ,effect_mdl = 'Abilities\\Spells\\NightElf\\EntanglingRoots\\EntanglingRootsTarget.mdl'
        ,effect_where = 'origin'
        ,debuffPriority = 0
        ,movespeed_root = true
        ,isDebuff = true
        ,notDispellable = true
    }
    ,['POWER'] = {
        debuffPriority = 0
        ,unitdmg_constant = 15.0
    }
    ,['DRUID_SHIELD'] = {
        deathpersistent = false
        ,notDispellable = true
        ,ICON = 'war3mapImported\\BTN_SpiritShieldBuff.dds'
        ,debuffPriority = 0
        ,effect_mdl = 'Abilities\\Spells\\Human\\ManaShield\\ManaShieldCaster.mdl'
        ,effect_where = 'origin'
        ,shieldAbility = ABCODE_STARFALL
        ,exitFunc = function() 
            return not(DS_GetAbsorb_AbilityStack(DEBUFFS[trg_buff_id].target,DEBUFFS[trg_buff_id].shieldAbility,trg_buff_id))
        end
    }
    ,['ELECTRIFIED'] = {
        deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_ElectrifiedDebuff.dds'
        ,debuffPriority = 2
        ,effect_mdl = 'Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl'
        ,effect_where = 'chest'
        ,isDebuff = true
        ,unitdmg_factor = 0.70
        ,unitdmg_factorStacks = true
        ,movespeed_factor = 0.91
        ,movespeed_factorStacks = true
        ,duration = 15
        ,unitdmgvic_constant = 0.3
        ,unitdmgvic_constantStacks = true
        ,ABILITIES_DMGVIC = {
            ABCODE_CHAINLIGHTING
            ,ABCODE_ORBOFLIGHTING
            ,ABCODE_LIGHTINGELEMENT
        }
    }
    ,['LIGHTINGSHIELD'] = {
        deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_LightingShieldBuff.dds'
        ,debuffPriority = 2
        ,effect_mdl = 'Abilities\\Spells\\Orc\\LightningShield\\LightningShieldTarget.mdl'
        ,effect_where = 'chest'
        ,shieldAbility = ABCODE_LIGHTINGSHIELD
        ,exitFunc = function() 
            return not(DS_GetAbsorb_AbilityStack(DEBUFFS[trg_buff_id].target,DEBUFFS[trg_buff_id].shieldAbility,trg_buff_id))
        end
        ,notDispellable = true
    }
    ,['FIREELEMENT_HIT'] = {
        effect_mdl = 'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl'
        ,ICON = 'war3mapImported\\BTN_FireElementDebuff.dds'
        ,effect_where = 'chest'
        ,deathpersistent = false
        ,debuffPriority = 2
        ,duration = 10
        ,unitdmgvic_constant = 0.25
        ,unitdmgvic_constantStacks = true
        ,ABILITIES_DMGVIC = {
            ABCODE_FIREELEMENT
        }
        ,dotAbility = ABCODE_FIREELEMENTDOT
        ,isDebuff = true
    }
    ,['WINDELEMENT_HIT'] = {
        effect_mdl = 'Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl'
        ,ICON = 'war3mapImported\\BTN_WindElementDebuff.dds'
        ,effect_where = 'chest'
        ,deathpersistent = false
        ,debuffPriority = 2
        ,duration = 10
        ,unitdmgvic_constant = 0.75
        ,movespeed_factor = 0.90
        ,movespeed_factorStacks = true
        ,unitdmgvic_constantStacks = true
        ,ABILITIES_DMGVIC = {
            ABCODE_WINDELEMENT
        }
        ,isDebuff = true
    }
    ,['FIREELEMENT_BUFF'] = {
        ICON = 'war3mapImported\\BTN_FireElementBuff.dds'
        ,deathpersistent = false
        ,notDispellable = true
        ,debuffPriority = 1
        ,unitdmgvic_factor = 0
        ,ABILITIES_DMGVIC = {
            ABCODE_FIREELEMENT
        }
        ,unitdmg_constant = 0.15
    }
    ,['WINDELEMENT_BUFF'] = {
        ICON = 'war3mapImported\\BTN_WindElementBuff.dds'
        ,deathpersistent = false
        ,notDispellable = true
        ,debuffPriority = 1
        ,unitdmgvic_factor = 0
        ,casttime_factor = 0.90
        ,ABILITIES_DMGVIC = {
            ABCODE_WINDELEMENT
        }
    }
    ,['WATERELEMENT_SHIELD'] = {
        deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_WaterElementBuff.dds'
        ,debuffPriority = 1
        ,effect_mdl = 'Abilities\\Spells\\Human\\ManaShield\\ManaShieldCaster.mdl'
        ,effect_where = 'origin'
        ,shieldAbility = ABCODE_WATERELEMENT
        ,exitFunc = function() 
            return not(DS_GetAbsorb_AbilityStack(DEBUFFS[trg_buff_id].target,DEBUFFS[trg_buff_id].shieldAbility,trg_buff_id))
        end
        ,notDispellable = true
    }
    ,['WATERELEMENT_BUFF'] = {
        ICON = 'war3mapImported\\BTN_WaterElementBuff.dds'
        ,deathpersistent = false
        ,notDispellable = true
        ,debuffPriority = 1
        ,unitdmgvic_factor = 0
        ,regen_constant = 25.0
        ,ABILITIES_DMGVIC = {
            ABCODE_WATERELEMENT
        }
    }
    ,['LIGHTINGELEMENT_BUFF'] = {
        ICON = 'war3mapImported\\BTN_LightingElementBuff.dds'
        ,deathpersistent = false
        ,notDispellable = true
        ,debuffPriority = 1
        ,unitdmgvic_factor = 0
        ,ABILITIES_DMGVIC = {
            ABCODE_LIGHTINGELEMENT
        }
        ,stat_constant_agi = 10
    }
    ,['ELEMENTAL_FURY'] = {
        ICON = 'war3mapImported\\BTN_ElementalFuryBuff.dds'
        ,effect_mdl = 'Abilities\\Spells\\Orc\\Voodoo\\VoodooAuraTarget.mdl'
        ,effect_where = 'chest'
        ,deathpersistent = false
        ,notDispellable = true
        ,debuffPriority = 1
        ,unitdmgvic_factor = 0
        ,ABILITIES_DMGVIC = {
            ABCODE_LIGHTINGELEMENT
            ,ABCODE_WATERELEMENT
            ,ABCODE_WINDELEMENT
            ,ABCODE_FIREELEMENT
        }
        ,stat_constant_agi = 15
        ,regen_constant = 35.0
        ,casttime_factor = 0.85
        ,unitdmg_constant = 0.25
    }
    ,['CHARGED'] = {
        ICON = 'war3mapImported\\BTN_ElectricSparkBuff'
        ,effect_mdl = 'Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl'
        ,effect_where = 'overhead'
        ,effect_unique = true
        ,deathpersistent = false
        ,notDispellable = true
        ,duration = 20
        ,debuffPriority = 1
        ,stat_constant_int = 1
        ,stat_constant_str = 1
        ,stat_constantStacks_str = true
        ,stat_constantStacks_int = true
    }
    ,['ELEMENTAL_EXHAUSTION'] = {
        ICON = 'war3mapImported\\BTN_ElementalFuryDebuff.dds'
        ,deathpersistent = false
        ,notDispellable = true
        ,debuffPriority = 1
        ,regen_factor = 0.0
        ,isDebuff = true
    }
    ,['SHAMANISTIC_RAGE'] = {
        effect_mdl = 'Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl'  
        ,effect_where = 'overhead'
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_BloodlustBuff.dds'
        ,unitdmg_constant = 5.0
        ,notDispellable = true
        ,debuffPriority = 0
    }
    ,['ELEMENTAL_MAGNET'] = {
        effect_mdl = 'Abilities\\Spells\\Human\\CloudOfFog\\CloudOfFog.mdl'
        ,effect_where = 'origin'
        ,effect_scale = 0.5
        ,deathpersistent = false
        ,ICON = 'war3mapImported\\BTN_ElementalMagnetDebuff.dds'
        ,debuffPriority = 0
        ,isDebuff = true
        ,movespeed_factor = 0.70
    }
    ,['ELEMENTAL_BLASTED'] = {
        ICON = 'war3mapImported\\BTN_ElementalBlastDebuff.dds'
        ,deathpersistent = false
        ,debuffPriority = 0
        ,unitdmgvic_constant = 0.25
        ,unitdmgvic_constantStacks = true
        ,isDebuff = true
        ,ABILITIES_DMGVIC = {
            ABCODE_LIGHTINGELEMENT
            ,ABCODE_WINDELEMENT
            ,ABCODE_FIREELEMENT
            ,ABCODE_CHAINLIGHTING
            ,ABCODE_ORBOFLIGHTING
            ,ABCODE_WINDFURY
            ,ABCODE_ELEMENTALNOVA
            ,ABCODE_ELEMENTALBLAST
        }
        ,notDispellable = true
    }
} 