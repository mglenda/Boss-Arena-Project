----------------------------------------------------
------------------REGIONS DATA----------------------
----------------------------------------------------

function REGIONS_Initialize()
    REGIONS_Create()
    REGIONS_Create = nil

    REGIONS_Initialize = nil
end

function REGIONS_Create()
    STARTING_ZONE = Rect(-15968.0, -16096.0, -12128.0, -13088.0)
    local we = AddWeatherEffect(STARTING_ZONE, FourCC("LRma"))
    EnableWeatherEffect(we, true)
    CreateFogModifierRectBJ(true, PLAYER, FOG_OF_WAR_VISIBLE, STARTING_ZONE)
    we = nil
end

function MAIN_Initialize()
    MAIN_RegisterZoneLeaving()
    MAIN_RegisterZoneLeaving = nil
    BOSS_CreateJournalButton()
    BOSS_CreateJournalButton= nil
    BOSS_LoadData()
    BOSS_LoadData = nil
    BOSS_LoadJournalData()
    BOSS_LoadJournalData = nil

    MAIN_Initialize = nil
end

function MAIN_RegisterZoneLeaving()
    TriggerRegisterLeaveRectSimple(SAFEZONE_LEAVING_TRIGGER,STARTING_ZONE)
    TriggerAddCondition(SAFEZONE_LEAVING_TRIGGER, Condition(function() return GetLeavingUnit() == HERO end))
    TriggerAddAction(SAFEZONE_LEAVING_TRIGGER, MAIN_MoveHero)
end

function MAIN_MoveHero()
    if not(ARENA_ACTIVATED) then
        local loc = GetPlayerStartLocationLoc(PLAYER)
        if IsUnitAliveBJ(HERO) then
            HERO_Move(START_X,START_Y)
        else 
            HERO_Respawn(START_X,START_Y)
        end
        BUFF_UnitClearAll(HERO)
        SetUnitLifePercentBJ(HERO, 100)
        CD_ResetAllAbilitiesCooldown(HERO)
        UNIT_SetDmgImmune(HERO, false)
        UNIT_CleanData(HERO)
        HERO_DATA[HERO_TYPE].ReadyUpFunc()
    end
end

function HERO_Respawn(x,y)
    ReviveHero(HERO, x, y, true)
    PanCameraToTimedForPlayer(PLAYER, x, y, 0.0)
    TT_SelectHero()
end

function HERO_Move(x,y,tx,ty,deg)
    SetUnitPosition(HERO, x, y)
    deg = deg or 270
    SetUnitFacing(HERO, (tx and ty) and MATH_GetAngleXY(x,y,tx,ty) or deg)
    PanCameraToTimedForPlayer(PLAYER, x, y, 0.0)
end

function MAIN_CreateArenaFogModifiers(id)
    for i,r in pairs(BOSS_DATA[id].regions.arena) do
        MAIN_CreateFogModifier(r)
    end
end

function MAIN_CreateFogModifier(zone)
    local fm = CreateFogModifierRectBJ(true, PLAYER, FOG_OF_WAR_VISIBLE, zone)
    table.insert(ARENA_FOG_MODIFIERS,fm)
end

function MAIN_ClearFogModifiers()
    for i,v in ipairs(ARENA_FOG_MODIFIERS) do
        DestroyFogModifier(v)
    end
end