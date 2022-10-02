----------------------------------------------------
---------------------HEROES-------------------------
----------------------------------------------------

function TALENTS_Flush_Warlock()
    TALENTS_Flush_Warlock = nil
    TALENTS_Load_Warlock = nil
end

function TALENTS_Load_Warlock()
    TALENTS_TABLE = {
        [1] = {
            [1] = {
                LevelRequired = 0
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_SHADOWBOLTS,'ShadowSigil',3)
                    AB_SetTalentsModifier(ABCODE_SHADOWBOLTS,'ShadowSigil_Energy',10)
                    UNIT_AddDmgFactor(HERO,ABCODE_SHADOWBOLTS,0.40)
                end
                ,DiscardFunc = function()
                    AB_SetTalentsModifier(ABCODE_SHADOWBOLTS,'ShadowSigil',nil)
                    AB_SetTalentsModifier(ABCODE_SHADOWBOLTS,'ShadowSigil_Energy',nil)
                    UNIT_AddDmgFactor(HERO,ABCODE_SHADOWBOLTS,-0.40)
                end
                ,Name = 'Shadow Sigil'
                ,Tooltip = 'Chaos Bolt stack requires only 3 void power.\nShadow bolt generates +5 fel energy and deals +40%% damage.'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_ShadowSigil.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_ShadowSigilPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_ShadowSigil.dds'
            }
            ,[2] = {
                LevelRequired = 3
                ,ApplyFunc = function()
                    ABILITIES_DATA[ABCODE_VOIDRIFT].CooldownStacks = (ABILITIES_DATA[ABCODE_VOIDRIFT].CooldownStacks or 1) + 1
                    local stacks = CD_GetAvailableStack(ABCODE_VOIDRIFT,HERO)
                    if stacks > 0 then
                        CD_EnableAbility(HERO,ABCODE_VOIDRIFT,stacks)
                    end
                    stacks = nil
                end
                ,DiscardFunc = function() 
                    ABILITIES_DATA[ABCODE_VOIDRIFT].CooldownStacks = (ABILITIES_DATA[ABCODE_VOIDRIFT].CooldownStacks or 2) - 1
                    local stacks = CD_GetAvailableStack(ABCODE_VOIDRIFT,HERO)
                    if stacks > 0 then
                        CD_EnableAbility(HERO,ABCODE_VOIDRIFT,stacks)
                    end
                    stacks = nil
                end
                ,Name = 'Rift Overcharge'
                ,Tooltip = 'Void Rift will have 2 stacks'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_RiftOvercharge.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_RiftOverchargePushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_RiftOvercharge.dds'
            }
            ,[3] = {
                LevelRequired = 5
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_CHAOSBOLT,'InfusedChaos',2)
                    AB_SetTalentsModifier(ABCODE_CHAOSBOLT,'InfusedChaosCap',25)
                end
                ,DiscardFunc = function()
                    AB_SetTalentsModifier(ABCODE_CHAOSBOLT,'InfusedChaos',nil)
                    AB_SetTalentsModifier(ABCODE_CHAOSBOLT,'InfusedChaosCap',nil)
                end
                ,Name = 'Chaos Infusion'
                ,Tooltip = 'Chaos bolt extends duration of all Fel Madness stacks\non the target by 2 seconds up to 25 seconds duration cap.'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_ChaosInfusion.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_ChaosInfusionPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_ChaosInfusion.dds'
            }
            ,[4] = {
                LevelRequired = 7
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_CHAOSBOLT,'ChaosMastery_1',35)
                    AB_SetTalentsModifier(ABCODE_CHAOSBOLT,'ChaosMastery_2',20)
                end
                ,DiscardFunc = function()
                    AB_SetTalentsModifier(ABCODE_CHAOSBOLT,'ChaosMastery_1',nil)
                    AB_SetTalentsModifier(ABCODE_CHAOSBOLT,'ChaosMastery_2',nil)
                end
                ,Name = 'Chaos Bolt Mastery'
                ,Tooltip = 'Chaos bolt got 35%%/20%% chance to generate additional\nbolt dealing 50%%/25%% damage.'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_ChaosBolt.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_ChaosBoltPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_ChaosBolt.dds'
            }
        }
        ,[2] = {
            [1] = {
                LevelRequired = 0
                ,ApplyFunc = function() 
                    CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)] = CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)] or {}
                    table.insert(CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)],{
                        factor = 0.7
                        ,constantPriority = 11
                        ,abilCodes = {ABCODE_SHADOWBOLTS}
                        ,t_id = 101
                    })
                    CASTTIME_Recalculate(HERO)
                    UNIT_AddDmgFactor(HERO,ABCODE_CHAOSBOLT,0.25)
                end
                ,DiscardFunc = function()
                    RemoveFromArray_ByKey(101,CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)],'t_id')
                    CASTTIME_Recalculate(HERO)
                    UNIT_AddDmgFactor(HERO,ABCODE_CHAOSBOLT,-0.25)
                end
                ,Name = 'Fel Sigil'
                ,Tooltip = 'Chaos Bolt damage increased by 25%%.\nShadow Bolts casting time reduced by 30%%.'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_FelSigil.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_FelSigilPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_FelSigil.dds'
            }
            ,[2] = {
                LevelRequired = 3
                ,ApplyFunc = function() 
                    ABILITIES_DATA[ABCODE_VOIDRIFT].Cooldown = ABILITIES_DATA[ABCODE_VOIDRIFT].Cooldown - 5
                end
                ,DiscardFunc = function() 
                    ABILITIES_DATA[ABCODE_VOIDRIFT].Cooldown = ABILITIES_DATA[ABCODE_VOIDRIFT].Cooldown + 5
                end
                ,Name = 'Rift Recharge'
                ,Tooltip = 'Reduces cooldown by 5 seconds'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_RiftRecharge.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_RiftRechargePushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_RiftRecharge.dds'
            }
            ,[3] = {
                LevelRequired = 5
                ,ApplyFunc = function() 
                    CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)] = CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)] or {}
                    table.insert(CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)],{
                        factor = 0.75
                        ,constantPriority = 0
                        ,abilCodes = {ABCODE_CHAOSBOLT}
                        ,t_id = 203
                    })
                    CASTTIME_Recalculate(HERO)
                end
                ,DiscardFunc = function()
                    RemoveFromArray_ByKey(203,CASTTIME_CONSTANTS[GetHandleIdBJ(HERO)],'t_id')
                    CASTTIME_Recalculate(HERO)
                end
                ,Name = 'Chaos Fury'
                ,Tooltip = 'Chaos Bolt casting time reduced by 25%%.'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_ChaosFury.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_ChaosFuryPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_ChaosFury.dds'
            }
            ,[4] = {
                LevelRequired = 7
                ,ApplyFunc = function() 
                    AB_SetTalentsModifier(ABCODE_FELMADNESS,'FelMastery',2)
                end
                ,DiscardFunc = function()
                    AB_SetTalentsModifier(ABCODE_FELMADNESS,'FelMastery',nil)
                end
                ,Name = 'Fel Madness Mastery'
                ,Tooltip = 'Fel Madness criticals generate 1 chaos bolt stack.\nMaximum chaos bolt stacks reduced to 2.'
                ,Enabled = false
                ,ICON = 'war3mapImported\\BTN_FelMadness.dds'
                ,ICON_PUSHED = 'war3mapImported\\BTN_FelMadnessPushed.dds'
                ,ICON_DISABLED = 'war3mapImported\\DISBTN_FelMadness.dds'
            }
        }
    }

    TALENTS_Flush_Warlock = nil
    TALENTS_Load_Warlock = nil
end