----------------------------------------------------
---------------------HEROES-------------------------
----------------------------------------------------

function TALENTS_Flush_FireMage()
    TALENTS_Load_FireMage = nil
    TALENTS_Flush_FireMage = nil
end

function TALENTS_Load_FireMage()
    TALENTS_TABLE = {
        [1] = {
            [1] = {
                LevelRequired = 0
                ,ApplyFunc = function() 
                    CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)] = CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)] or {}
                    table.insert(CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)],{
                        factor = 0.80
                        ,constantPriority = 5
                        ,t_id = 101
                    })
                    CASTTIME_Recalculate(HERO)
                end
                ,DiscardFunc = function() 
                    RemoveFromArray_ByKey(101,CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)],'t_id')
                    CASTTIME_Recalculate(HERO)
                end
                ,Name = 'Furious'
                ,Tooltip = 'Increase haste by 20%%'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_Furious.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_FuriousPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_Furious.dds'
            }
            ,[2] = {
                LevelRequired = 3
                ,ApplyFunc = function()
                    ABILITIES_DATA[ABCODE_FLAMEBLINK].CooldownStacks = (ABILITIES_DATA[ABCODE_FLAMEBLINK].CooldownStacks or 1) + 1
                    local stacks = CD_GetAvailableStack(ABCODE_FLAMEBLINK,HERO)
                    if stacks > 0 then
                        CD_EnableAbility(HERO,ABCODE_FLAMEBLINK,stacks)
                    end
                    stacks = nil
                end
                ,DiscardFunc = function() 
                    ABILITIES_DATA[ABCODE_FLAMEBLINK].CooldownStacks = (ABILITIES_DATA[ABCODE_FLAMEBLINK].CooldownStacks or 2) - 1
                    local stacks = CD_GetAvailableStack(ABCODE_FLAMEBLINK,HERO)
                    if stacks > 0 then
                        CD_EnableAbility(HERO,ABCODE_FLAMEBLINK,stacks)
                    end
                    stacks = nil
                end
                ,Name = 'Swift'
                ,Tooltip = 'Flame Blink 2 Stacks'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_FlameBlink.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_FlameBlinkPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_FlameBlink.dds'
            }
            ,[3] = {
                LevelRequired = 5
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_IGNITE,'Perpetual',5.0)
                end
                ,DiscardFunc = function() 
                    AB_SetTalentsModifier(ABCODE_IGNITE,'Perpetual',nil)
                end
                ,Name = 'Perpetual'
                ,Tooltip = 'Ignited Duration + 5 Seconds'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_Ignite.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_IgnitePushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_Ignite.dds'
            }
            ,[4] = {
                LevelRequired = 7
                ,ApplyFunc = function()
                    AB_SetTalentsModifier(ABCODE_ORBS,'Keeper',3)
                end
                ,DiscardFunc = function() 
                    AB_SetTalentsModifier(ABCODE_ORBS,'Keeper',nil)
                    AB_FireMage_RemoveFireOrbsAll(HERO)
                end
                ,Name = 'Keeper'
                ,Tooltip = 'Fire orbs limit +3'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_Keeper.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_KeeperPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_Keeper.dds'
            }
            ,[5] = {
                LevelRequired = 9
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_BOLTSOFPHOENIX,'Protector',2)
                end
                ,DiscardFunc = function() 
                    AB_SetTalentsModifier(ABCODE_BOLTSOFPHOENIX,'Protector',nil)
                end
                ,Name = 'Protector'
                ,Tooltip = 'FireOrb Shield + 2 maxstacks'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_Protector.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_ProtectorPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_Protector.dds'
            }
            ,[6] = {
                LevelRequired = 11
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_BOLTSOFPHOENIX,'DarkPhoenix',true)
                    UNIT_AddDmgFactor(HERO,ABCODE_BOLTSOFPHOENIX,0.5)
                end
                ,DiscardFunc = function() 
                    AB_SetTalentsModifier(ABCODE_BOLTSOFPHOENIX,'DarkPhoenix',false)
                    UNIT_AddDmgFactor(HERO,ABCODE_BOLTSOFPHOENIX,-0.5)
                end
                ,Name = 'Dark Phoenix'
                ,Tooltip = 'Bolts of phoenix damage increased by 50%%\nIts criticals now trigger Ignited'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_PhoenixClaw.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_PhoenixClawPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_PhoenixClaw.dds'
            }
            ,[7] = {
                LevelRequired = 13
                ,ApplyFunc = function()
                    ABILITIES_DATA[ABCODE_ORBOFFIRE].Cooldown = ABILITIES_DATA[ABCODE_ORBOFFIRE].Cooldown + 6
                    AB_SetTalentsModifier(ABCODE_ORBOFFIRE,'Flamer',4)
                    ABILITIES_DATA[ABCODE_ORBOFFIRE].CooldownStacks = (ABILITIES_DATA[ABCODE_ORBOFFIRE].CooldownStacks or 1) + 2
                    local stacks = CD_GetAvailableStack(ABCODE_ORBOFFIRE,HERO)
                    if stacks > 0 then
                        CD_EnableAbility(HERO,ABCODE_ORBOFFIRE,stacks)
                    end
                    stacks = nil
                end
                ,DiscardFunc = function() 
                    ABILITIES_DATA[ABCODE_ORBOFFIRE].Cooldown = ABILITIES_DATA[ABCODE_ORBOFFIRE].Cooldown - 6
                    AB_SetTalentsModifier(ABCODE_ORBOFFIRE,'Flamer',nil)
                    ABILITIES_DATA[ABCODE_ORBOFFIRE].CooldownStacks = (ABILITIES_DATA[ABCODE_ORBOFFIRE].CooldownStacks or 3) - 2
                    local stacks = CD_GetAvailableStack(ABCODE_ORBOFFIRE,HERO)
                    if stacks > 0 then
                        CD_EnableAbility(HERO,ABCODE_ORBOFFIRE,stacks)
                    end
                    stacks = nil
                end
                ,Name = 'Flamer'
                ,Tooltip = 'Orb of Fire 3 stacks / +4 ticks\n+6 sec cd'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_FlameBlink.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_FlameBlinkPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_FlameBlink.dds'
            }
            ,[8] = {
                LevelRequired = 15
                ,ApplyFunc = function() 
                    CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)] = CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)] or {}
                    table.insert(CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)],{
                        constant = -0.15
                        ,constantPriority = 11
                        ,abilCodes = {ABCODE_IGNITE}
                        ,t_id = 108
                    })
                    CASTTIME_Recalculate(HERO)
                end
                ,DiscardFunc = function()
                    RemoveFromArray_ByKey(108,CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)],'t_id')
                    CASTTIME_Recalculate(HERO)
                end
                ,Name = 'Furious Flames'
                ,Tooltip = 'Ignite casting speed -0.15 sec'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_FuriousFlames.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_FuriousFlamesPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_FuriousFlames.dds'
            }
            ,[9] = {
                LevelRequired = 17
                ,ApplyFunc = function() 
                    ABILITIES_DATA[ABCODE_SOULOFFIRE].Cooldown = ABILITIES_DATA[ABCODE_SOULOFFIRE].Cooldown * 0.6
                end
                ,DiscardFunc = function()
                    ABILITIES_DATA[ABCODE_SOULOFFIRE].Cooldown = ABILITIES_DATA[ABCODE_SOULOFFIRE].Cooldown / 0.6 
                end
                ,Name = 'Elemental Heart'
                ,Tooltip = 'Soul of  Fire cooldown decrease by -40%%'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_ElementalHeart.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_ElementalHeartPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_ElementalHeart.dds'
            }
            ,[10] = {
                LevelRequired = 19
                ,ApplyFunc = function() 
                    UNIT_AddDmgFactor(HERO,ABCODE_SCORCH,0.3)
                end
                ,DiscardFunc = function() 
                    UNIT_AddDmgFactor(HERO,ABCODE_SCORCH,-0.3)
                end
                ,Name = 'Improved Scorch'
                ,Tooltip = 'Scorch damage +30%%'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_Scorch.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_ScorchPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_Scorch.dds'
            }
            ,[11] = {
                LevelRequired = 21
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_IGNITE,'Ignitemaster',2)
                end
                ,DiscardFunc = function() 
                    AB_SetTalentsModifier(ABCODE_IGNITE,'Ignitemaster',nil)
                end
                ,Name = 'Ignitemaster'
                ,Tooltip = 'Ignite procs now generate 2 stacks instead of 1.'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_Scorchmaster.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_ScorchmasterPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_Scorchmaster.dds'
            }
        }
        ,[2] = {
            [1] = {
                LevelRequired = 0
                ,ApplyFunc = function() 
                    STATS_CONSTANTS[GetHandleIdBJ(HERO)] = STATS_CONSTANTS[GetHandleIdBJ(HERO)] or {}
                    table.insert(STATS_CONSTANTS[GetHandleIdBJ(HERO)],{
                        factor_int = 1.50
                        ,constant_agi = 10
                        ,constantPriority = 0
                        ,t_id = 201
                    })
                    STATS_INT_Recalculate(HERO)
                    STATS_AGI_Recalculate(HERO)
                end
                ,DiscardFunc = function() 
                    RemoveFromArray_ByKey(201,STATS_CONSTANTS[GetHandleIdBJ(HERO)],'t_id')
                    STATS_INT_Recalculate(HERO)
                    STATS_AGI_Recalculate(HERO)
                end
                ,Name = 'Hellshand'
                ,Tooltip = '+10%% Crit Rate, +50%% Spell Power'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_Hellshand.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_HellshandPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_Hellshand.dds'
            }
            ,[2] = {
                LevelRequired = 3
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_FLAMEBLINK,'BlinkFury',true)
                    ABILITIES_DATA[ABCODE_FLAMEBLINK].Cooldown = ABILITIES_DATA[ABCODE_FLAMEBLINK].Cooldown - 2
                end
                ,DiscardFunc = function() 
                    AB_SetTalentsModifier(ABCODE_FLAMEBLINK,'BlinkFury',false)
                    ABILITIES_DATA[ABCODE_FLAMEBLINK].Cooldown = ABILITIES_DATA[ABCODE_FLAMEBLINK].Cooldown + 2
                end
                ,Name = 'Blink Fury'
                ,Tooltip = 'Got MS buff after blinking\nReduces cooldown by 2 seconds'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_BlinkFury.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_BlinkFuryPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_BlinkFury.dds'
            }
            ,[3] = {
                LevelRequired = 5
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_PYROBLAST,'Pyromancer',25)
                end
                ,DiscardFunc = function() 
                    AB_SetTalentsModifier(ABCODE_PYROBLAST,'Pyromancer',nil)
                end
                ,Name = 'Pyromancer'
                ,Tooltip = 'Pyroblasted triggers automatically.\nSecond instant pyroblast chance (25%%)'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_Pyromancer.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_PyromancerPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_Pyromancer.dds'
            }
            ,[4] = {
                LevelRequired = 7
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_ORBS,'Burster',true)
                end
                ,DiscardFunc = function() 
                    AB_SetTalentsModifier(ABCODE_ORBS,'Burster',nil)
                end
                ,Name = 'Burster'
                ,Tooltip = 'Do not consume fire orbs during Soul of Fire'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_Burster.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_BursterPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_Burster.dds'
            }
            ,[5] = {
                LevelRequired = 9
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_BOLTSOFPHOENIX,'Defender',1.4)
                end
                ,DiscardFunc = function() 
                    AB_SetTalentsModifier(ABCODE_BOLTSOFPHOENIX,'Defender',nil)
                end
                ,Name = 'Defender'
                ,Tooltip = 'FireOrb shield +40%% absorb'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_Defender.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_DefenderPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_Defender.dds'
            }
            ,[6] = {
                LevelRequired = 11
                ,ApplyFunc = function()
                    UNIT_AddCritMultFactor(HERO,ABCODE_PYROBLAST,4.5)
                    UNIT_AddCritFactor(HERO,ABCODE_PYROBLAST,25)
                end
                ,DiscardFunc = function() 
                    UNIT_AddCritMultFactor(HERO,ABCODE_PYROBLAST,-4.5)
                    UNIT_AddCritFactor(HERO,ABCODE_PYROBLAST,-25)
                end
                ,Name = 'Superblast'
                ,Tooltip = '+450%% Critical Pyroblast dmg\n+25%% Pyroblast Crit Chance'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_Superblast.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_SuperblastPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_Superblast.dds'
            }
            ,[7] = {
                LevelRequired = 13
                ,ApplyFunc = function()
                    CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)] = CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)] or {}
                    table.insert(CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)],{
                        factor = 0.0
                        ,constantPriority = 0
                        ,abilCodes = {ABCODE_ORBOFFIRE}
                        ,t_id = 207
                    })
                    CASTTIME_Recalculate(HERO)
                    ABILITIES_DATA[ABCODE_ORBOFFIRE].Cooldown = ABILITIES_DATA[ABCODE_ORBOFFIRE].Cooldown - 2
                end
                ,DiscardFunc = function() 
                    RemoveFromArray_ByKey(207,CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)],'t_id')
                    CASTTIME_Recalculate(HERO)
                    ABILITIES_DATA[ABCODE_ORBOFFIRE].Cooldown = ABILITIES_DATA[ABCODE_ORBOFFIRE].Cooldown + 2
                end
                ,Name = 'Orbmaster'
                ,Tooltip = 'Orb of Fire -2 sec CD / Instant Cast '
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_Bombmaster.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_BombmasterPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_Bombmaster.dds'
            }
            ,[8] = {
                LevelRequired = 15
                ,ApplyFunc = function() 
                    UNIT_AddDmgFactor(HERO,ABCODE_IGNITE,0.6)
                end
                ,DiscardFunc = function() 
                    UNIT_AddDmgFactor(HERO,ABCODE_IGNITE,-0.6)
                end
                ,Name = 'Destructive Flames'
                ,Tooltip = 'Ignite damage +60%%'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_DestructiveFlames.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_DestructiveFlamesPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_DestructiveFlames.dds'
            }
            ,[9] = {
                LevelRequired = 17
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_SOULOFFIRE,'Soulofinferno',2.0)
                end
                ,DiscardFunc = function()
                    AB_SetTalentsModifier(ABCODE_SOULOFFIRE,'Soulofinferno',nil)
                end
                ,Name = 'Soul of Inferno'
                ,Tooltip = 'Soul of Fire spell power bonus +100%%'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_SoulOfInferno.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_SoulOfInfernoPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_SoulOfInferno.dds'
            }
            ,[10] = {
                LevelRequired = 19
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_SCORCH,'Combustion',true)
                end
                ,DiscardFunc = function() 
                    AB_SetTalentsModifier(ABCODE_SCORCH,'Combustion',false)
                end
                ,Name = 'Combustion'
                ,Tooltip = 'AOE Scorch triggers Ignited'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_Combustion.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_CombustionPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_Combustion.dds'
            }
            ,[11] = {
                LevelRequired = 21
                ,ApplyFunc = function() 
                    CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)] = CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)] or {}
                    table.insert(CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)],{
                        constant = -2.0
                        ,constantPriority = 0
                        ,abilCodes = {ABCODE_PYROBLAST}
                        ,t_id = 211
                    })
                    CASTTIME_Recalculate(HERO)
                end
                ,DiscardFunc = function() 
                    RemoveFromArray_ByKey(211,CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)],'t_id')
                    CASTTIME_Recalculate(HERO)
                end
                ,Name = 'God of Blast'
                ,Tooltip = 'Pyroblast - 2 sec casttime'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_GodOfBlast.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_GodOfBlastPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_GodOfBlast.dds'
            }
        }
    }
    TALENTS_Flush_FireMage = nil
    TALENTS_Load_FireMage = nil
end