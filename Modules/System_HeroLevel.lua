----------------------------------------------------
--------------LVLUP SYSTEM SETUP--------------------
----------------------------------------------------

function HERO_LevelChange()
    if BlzFrameIsVisible(TALENTS_FRAME_MAIN) then
        TALENTS_UI_LoadTalents()
    end
    UNIT_RecalculateStats(HERO)
end

function HERO_AddLevel(value)
    SetHeroLevelBJ(HERO, HERO_GetLevel() + value, false)
    HERO_LevelChange()
end

function HERO_SetLevel(value)
    SetHeroLevelBJ(HERO, value, false)
    HERO_LevelChange()
end

function HERO_GetLevel()
    return GetHeroLevel(HERO)
end