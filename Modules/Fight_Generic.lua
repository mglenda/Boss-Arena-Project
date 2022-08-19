----------------------------------------------------
-------------------FIGHT GENERIC--------------------
----------------------------------------------------

function GENERIC_Effect_PolishedSpawn_AddToQueue(eff,scale)
    FIGHT_DATA.eff_pol_SpawnTable = FIGHT_DATA.eff_pol_SpawnTable or {}
    table.insert(FIGHT_DATA.eff_pol_SpawnTable,{e = eff,s = scale})
    if not(FIGHT_DATA.eff_pol_Spawner) then
        FIGHT_DATA.eff_pol_Spawner = CreateBossTrigger()
        TriggerRegisterTimerEventPeriodic(FIGHT_DATA.eff_pol_Spawner, 0.01)
        TriggerAddAction(FIGHT_DATA.eff_pol_Spawner, GENERIC_Effect_PolishedSpawn_Action)
    elseif not(IsTriggerEnabled(FIGHT_DATA.eff_pol_Spawner)) then
        EnableTrigger(FIGHT_DATA.eff_pol_Spawner)
    end
end

function GENERIC_Effect_PolishedSpawn_Action()
    for i=#FIGHT_DATA.eff_pol_SpawnTable,1,-1 do
        local s = BlzGetSpecialEffectScale(FIGHT_DATA.eff_pol_SpawnTable[i].e)
        if s + 0.01 >= FIGHT_DATA.eff_pol_SpawnTable[i].s then
            BlzSetSpecialEffectScale(FIGHT_DATA.eff_pol_SpawnTable[i].e,FIGHT_DATA.eff_pol_SpawnTable[i].s)
            table.remove(FIGHT_DATA.eff_pol_SpawnTable,i)
        else
            BlzSetSpecialEffectScale(FIGHT_DATA.eff_pol_SpawnTable[i].e, s + 0.01)
        end
    end
    if #FIGHT_DATA.eff_pol_SpawnTable == 0 then
        DestroyTrigger(FIGHT_DATA.eff_pol_Spawner)
        FIGHT_DATA.eff_pol_SpawnTable = nil
        FIGHT_DATA.eff_pol_Spawner = nil
    end
end

function GENERIC_Effect_PolishedRemove_AddToQueue(eff)
    FIGHT_DATA.eff_pol_RemoverTable = FIGHT_DATA.eff_pol_RemoverTable or {}
    table.insert(FIGHT_DATA.eff_pol_RemoverTable,eff)
    if not(FIGHT_DATA.eff_pol_Remover) then
        FIGHT_DATA.eff_pol_Remover = CreateBossTrigger()
        TriggerRegisterTimerEventPeriodic(FIGHT_DATA.eff_pol_Remover, 0.01)
        TriggerAddAction(FIGHT_DATA.eff_pol_Remover, GENERIC_Effect_PolishedRemove_Action)
    elseif not(IsTriggerEnabled(FIGHT_DATA.eff_pol_Remover)) then
        EnableTrigger(FIGHT_DATA.eff_pol_Remover)
    end
end

function GENERIC_Effect_PolishedRemove_Action()
    for i=#FIGHT_DATA.eff_pol_RemoverTable,1,-1 do
        local s = BlzGetSpecialEffectScale(FIGHT_DATA.eff_pol_RemoverTable[i])
        if s - 0.02 <= 0.01 then
            BOSS_DestroyEffect(FIGHT_DATA.eff_pol_RemoverTable[i])
            table.remove(FIGHT_DATA.eff_pol_RemoverTable,i)
        else
            BlzSetSpecialEffectScale(FIGHT_DATA.eff_pol_RemoverTable[i], s - 0.02)
        end
    end
    if #FIGHT_DATA.eff_pol_RemoverTable == 0 then
        DestroyTrigger(FIGHT_DATA.eff_pol_Remover)
        FIGHT_DATA.eff_pol_RemoverTable = nil
        FIGHT_DATA.eff_pol_Remover = nil
    end
end