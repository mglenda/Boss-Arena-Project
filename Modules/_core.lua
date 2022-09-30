local oldInit = InitBlizzard
function InitBlizzard()
    UI_HideOriginalUI()
    oldInit()
    MapSetup()
end

function DestroyTrigger(t)
    RemoveFromArray(t,BOSS_TRIGGERS)
    oldDestroyTrigger(t)
end

function MapSetup()
    LoadTOCFile("war3mapImported\\CustomUI.toc")
    BOSS_LoadData()
    HERODATA_Load()
    UNIT_InitiateGlobalData()
    UNIT_RegisterPreCreatedUnits()
    RegisterAbilitiesData()
    core_LoadImportedEffects()
    AntiCheatsLoad()
    test_keyboard()
end

function LoadTOCFile(path)
    if BlzLoadTOCFile(path) then
        return
    end
    print(path .. " import failed")
end

function core_LoadImportedEffects()
    local effects = {
        'war3mapImported\\Tidal Burst.mdx'
        ,'war3mapImported\\Electric Spark.mdx'
        ,'war3mapImported\\Nature Blast.mdx'
        ,'war3mapImported\\Wind Blast.mdx'
        ,'war3mapImported\\Orb of Corruption.mdx'
        ,'war3mapImported\\Orb of Fire.mdx'
        ,'war3mapImported\\Orb of Frost.mdx'
        ,'war3mapImported\\Orb of Poison.mdx'
        ,'war3mapImported\\Empyrean Nova.mdx'
        ,'war3mapImported\\Gravity Storm.mdx'
        ,'war3mapImported\\Burning Blast.mdx'

    }
    for i,e in pairs(effects) do
        AddSpecialEffect(e, START_X, START_Y)
    end

    core_LoadImportedEffects = nil
end