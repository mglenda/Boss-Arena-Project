-- Forbiden Keys {S H A P M}

KEY_PRESSED_NONE = 0
KEY_PRESSED_SHIFT = 1
KEY_PRESSED_CTRL = 2
KEY_PRESSED_SHIFT_CTRL = 3
KEY_PRESSED_ALT = 4
KEY_PRESSED_SHIFT_ALT = 5
KEY_PRESSED_CTRL_ALT = 6
KEY_PRESSED_SHIFT_CTRL_ALT = 7

JASS_DATATYPE_TRIGGER = 'trigger'
JASS_DATATYPE_LOCATION = 'location'
JASS_DATATYPE_PLAYER = 'player'
JASS_DATATYPE_UNIT = 'unit'
JASS_DATATYPE_EFFECT = 'effect'

dmgFactor_Data = {}
dmgFactor_Data_Victim = {}

TARGET_ABILITY = FourCC('TARG')

MS_MAX_MOVESPEED = 1000
MS_MIN_MOVESPEED = 0

PLAYER = Player(0)
PLAYER_BOSS = Player(PLAYER_NEUTRAL_AGGRESSIVE)
PLAYER_GUARDIANS = Player(1)
PLAYER_PASSIVE = Player(PLAYER_NEUTRAL_PASSIVE)
PLAYERS_GROUP = {
    PLAYER
    ,PLAYER_BOSS
    ,PLAYER_GUARDIANS
    ,PLAYER_PASSIVE
}

TRAINING_DUMMIES = {}

DEFAULT_NONHERO_CRITRATE = 10
PRIMARY_ATTRIBUTE_STR = 1
PRIMARY_ATTRIBUTE_INT = 2
PRIMARY_ATTRIBUTE_AGI = 3

ATTDMG_PER_PRIMARY_ATTRIBUTE = 0.4

DAMAGE_ENGINE_TYPE_AUTOATTACK = 0

ATTRIBUTE_UNDEFINED_ICON = 'war3mapImported\\STAT_AttackPower.dds'
STATS_ATTDMG_ICON = 'war3mapImported\\STAT_AttackDmg.dds'
STATS_RESISTANCE_ICON = 'war3mapImported\\STAT_Resistance.dds'
STATS_CRITICAL_ICON = 'war3mapImported\\STAT_CriticalChance.dds'

ATTRIBUTES = {
    [PRIMARY_ATTRIBUTE_STR] = {
        stat = bj_HEROSTAT_STR
        ,icon = 'war3mapImported\\STAT_AttackPower.dds'
    },
    [PRIMARY_ATTRIBUTE_INT] = {
        stat = bj_HEROSTAT_INT
        ,icon = 'war3mapImported\\STAT_SpellPower.dds'
    },
    [PRIMARY_ATTRIBUTE_AGI] = {
        stat = bj_HEROSTAT_AGI
        ,icon = 'war3mapImported\\STAT_AttackPower.dds'
    }
}

TALENTS_ABILITY_KEY = OSKEY_N
TALENTS_ABILITY_TOOLTIP = 'N'

UNITS_DATA = nil

ABILITIES_DATA = nil

Casting_Trigger = nil
HERO = nil
TARGET = nil
ANTICHEAT_TARGET = nil

oldDestroyTrigger = DestroyTrigger
function DestroyTrigger(t)
    RemoveFromArray(t,BOSS_TRIGGERS)
    oldDestroyTrigger(t)
end

oldKillUnit = KillUnit
function KillUnit(unit)
    oldKillUnit(unit)
end

function AddSpecialEffectBuff(where,unit,effect)
    local eff = oldAddEffect(where,unit,effect)
    return eff
end

function Get_DmgTypeAutoAttack()
    return DAMAGE_ENGINE_TYPE_AUTOATTACK
end

function IsInArray(value,array)
    if array then
        for i, v in pairs(array) do
            if v == value then
                return i
            end
        end
    end
    return nil
end

function IsInArray_ByKey(value,array,key)
    if array then
        for i, v in pairs(array) do
            if v[key] == value then
                return i
            end
        end
    end
    return nil
end

function IsInArray_CustField(value,array,field)
    if array then
        for i, v in pairs(array) do
            if v[field] == value then
                return true
            end
        end
    end
    return false
end

function RemoveFromArray_ByKey(value,array,key)
    if array then
        for i, v in pairs(array) do
            if v[key] == value then
                return table.remove(array, i)
            end
        end
    end
    return nil
end

function RemoveFromArray(value,array)
    if array then
        for i,v in pairs(array) do
            if v == value then
                return table.remove(array, i)
            end
        end
    end
    return nil
end

function getJASSDataType(data)
    local dataType = tostring(data)
    local i = string.find(dataType,':')
    if i == nil then 
        return nil         
    end
    return string.sub(dataType,1,i-1)
end

function tableGetMaxIndex(table)
    local maxi = 0
    for i,v in pairs(table) do
        maxi = maxi >= i and maxi or i
    end
    return maxi
end

function FromatSeconds(time)
    time = time > 0 and time * 10 or 0
    local hours = math.floor(time / 36000)
    time = time - math.floor(time/36000)*36000
    local minutes = strRound(time / 600,0)
    time = time - math.floor(time/600)*600
    local seconds = strRound(time / 10,0)
    time = time - math.floor(time/10)*10
    return tostring((hours > 0 and strRound(hours,0) .. ':' or '') .. (minutes == '0' and '' or minutes .. ':') .. (minutes == '0' and seconds or ("0"..seconds):sub(-2)) .. '.' .. strRound(time,0))
end

function Point(x,y)
    return {x = x, y = y}
end

function Line(sx,sy,ex,ey)
    return {
        start_X = sx
        ,start_Y = sy
        ,end_X = ex
        ,end_Y = ey
    }
end

function Polygon(...)
    local points,polygon = {...},{}
    for i,p in ipairs(points) do
        if type(p) == "table" and p.x and p.y then
            table.insert(polygon,p)
        end
    end
    return polygon
end

function Get_PolygonMaxMin_XY(Polygon)
    if type(Polygon) == "table" then
        local max_X,max_Y,min_X,min_Y = Polygon[1].x,Polygon[1].y,Polygon[1].x,Polygon[1].y
        for i,p in pairs(Polygon) do
            max_X = p.x > max_X and p.x or max_X
            max_Y = p.y > max_Y and p.y or max_Y
            min_X = p.x < min_X and p.x or min_X
            min_Y = p.y < min_Y and p.y or min_Y
        end
        return max_X,max_Y,min_X,min_Y
    end
    return nil,nil,nil,nil
end

function Get_RandomPointInPolygon(Polygon)
    local hx,hy,lx,ly = Get_PolygonMaxMin_XY(Polygon)
    local x,y
    if hx and hy and lx and ly then
        x,y = GetRandomReal(lx, hx),GetRandomReal(ly, hy)
        if not(IsInPolygon(Point(x,y),Polygon)) then
            x,y = Get_RandomPointInPolygon(Polygon)
        end
    end
    return x,y
end

function IsLineCrossingPolygon(line,polygon)
    local x,y = line.start_X,line.start_Y
    local rad = MATH_GetRadXY(line.start_X,line.start_Y,line.end_X,line.end_Y)
    local dist = round(MATH_GetDistance(x,y,line.end_X,line.end_Y),0)
    for i = dist,1,-1 do
        if IsInPolygon(Point(x,y),polygon) then
            return x,y
        else
            x,y = MATH_MoveXY(x,y,1.0,rad)
        end
    end
    return nil,nil
end

function IsInPolygon(p,polygon)
    local minX,minY,maxX,maxY = polygon[1].x,polygon[1].y,polygon[1].x,polygon[1].y
    for i,q in ipairs(polygon) do
        minX,maxX,minY,maxY = math.min(q.x,minX),math.max(q.x,maxX),math.min(q.y,minY),math.max(q.y,maxY)
    end
    if p.x < minX or p.x > maxX or p.y < minY or p.y > maxY then
        return false
    end 

    -- Part 2, logic behind this is explained here https://wrf.ecse.rpi.edu/Research/Short_Notes/pnpoly.html
    local inside = false
    local j = #polygon
    for i,q in ipairs(polygon) do
        if (q.y > p.y) ~= (polygon[j].y > p.y) and p.x < (polygon[j].x - q.x) * (p.y - q.y) / (polygon[j].y - q.y) + q.x then
            inside = not(inside)
        end
        j = i
    end
    return inside
end

function test_keyboard()
    local trig = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trig,PLAYER,OSKEY_C,KEY_PRESSED_SHIFT,true)
    TriggerAddAction(trig, function()
        --CD_ResetAllAbilitiesCooldown(HERO)
    end)

    trig = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trig,PLAYER,OSKEY_X,KEY_PRESSED_SHIFT,true)
    TriggerAddAction(trig, function()
        HERO_SetLevel(HERO_GetLevel() + 1)
    end)

    trig = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trig,PLAYER,OSKEY_V,KEY_PRESSED_SHIFT,true)
    TriggerAddAction(trig, function()
        HERO_SetLevel(HERO_GetLevel() - 1)
    end)

    trig = CreateTrigger()
    TriggerRegisterPlayerChatEvent(trig, Player(0), "power", true)
    TriggerAddAction(trig, function()
        if BUFF_GetStacksCount(HERO,'POWER') == 0 then
            BUFF_AddDebuff_Stack({
                target = HERO
                ,name = 'POWER'
                ,IMMORTAL = true
            })
        else
            for i,b in pairs(DEBUFFS) do
                if b.name == 'POWER' then
                    BUFF_Attribute_SetValue(i,'IMMORTAL',false)
                    BUFF_ClearDebuff(i)
                end
            end
        end
    end)

    trig = CreateTrigger()
    TriggerRegisterPlayerChatEvent(trig, Player(0), "mage", true)
    TriggerRegisterPlayerChatEvent(trig, Player(0), "priest", true)
    TriggerRegisterPlayerChatEvent(trig, Player(0), "warlock", true)
    TriggerAddAction(trig, function()
        DestroyTrigger(GetTriggeringTrigger())
        if GetEventPlayerChatString() == "mage" then
            CreateFireMage()
        elseif GetEventPlayerChatString() == "priest" then
            CreatePriest()
        elseif GetEventPlayerChatString() == "warlock" then
            CreateWarlock()
        end
    end)

    trig = CreateTrigger()
    TriggerRegisterPlayerChatEvent(trig, Player(0), "shadow", true)
    TriggerRegisterPlayerChatEvent(trig, Player(0), "holy", true)
    TriggerAddAction(trig, function()
        if GetEventPlayerChatString() == "shadow" then
            UI_ChangeStance(HERO_PRIEST,'shadow')
        elseif GetEventPlayerChatString() == "holy" then
            UI_ChangeStance(HERO_PRIEST,'holy')
        end
    end)

    test_keyboard = nil
end

function tableLength(t)
    local count = 0
    if type(t) == 'table' then
        for _ in pairs(t) do count = count + 1 end
    end
    return count
end

function table_DeleteMinVal(t)
    if type(t) == 'table' then
        local key = next(t)
        local min = t[key]

        for k, v in pairs(t) do
            if t[k] < min then
                key, min = k, v
            end
        end
        t[key] = nil
    end
end

function table_RemoveDuplicates(tbl)
    local hash = {}
    local res = {}

    for _,v in pairs(tbl) do
        if (not hash[v]) then
            res[#res+1] = v
            hash[v] = true
        end
    end

    return res
end

function WaitAndDo(duration,func, ...)
    local t = CreateTimer()
    local param = table.pack(...)
    TimerStart(t, duration, false, function()
        DestroyTimer(t)
        func(table.unpack(param))
        t,func,param = nil,nil,nil
    end)
end

function table_GetMinVal(t)
    if type(t) == 'table' then
        local key = next(t)
        local min = t[key]

        for k, v in pairs(t) do
            if t[k] < min then
                key, min = k, v
            end
        end
        return min
    end
end

function PLAYER_IsActive(player)
    for i,p in pairs(PLAYERS_GROUP) do
        if p == player then
            return true
        end
    end
    return false
end

function GetUnitIcon_String(UnitTypeID)
    return UNITS_DATA[UnitTypeID].ICON
end

function round(num, numDecimalPlaces)
    local result = nil
    if numDecimalPlaces and numDecimalPlaces>0 then
      local mult = 10^numDecimalPlaces
      return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function instr(str,find)
    for i=1,string.len(str) do
        if string.sub(str,i,i) == find then
            return i
        end
    end
    return nil
end

function strRound(value,decplaces)
    local dot,s = instr(tostring(value),'.'),tostring(value)
    decplaces = decplaces and (not(dot) and decplaces == 0 and decplaces or (dot and decplaces or decplaces + 1)) or 0
    local decs = decplaces > 0 and (dot and '' or '.') or ''
    dot = decplaces > 0 and (dot or string.len(s)) or (dot and dot - 1 or string.len(s))
    for i=1,decplaces do
        decs = decs .. '0'
    end
    return string.sub(s .. decs,1,dot+decplaces)
end

function GetUnitXY(u)
    return GetUnitX(u),GetUnitY(u)
end

function GetUnitXYZ(u)
    return GetUnitX(u),GetUnitY(u),GetUnitZ(u)
end

UNIT_Z_LOCATION = Location(0, 0)

function GetUnitZ(u) 
    MoveLocation(UNIT_Z_LOCATION,GetUnitX(u),GetUnitY(u))
    return GetLocationZ(UNIT_Z_LOCATION) + GetUnitFlyHeight(u)
end

function GetPointZ(x,y)
    MoveLocation(UNIT_Z_LOCATION,x,y)
    return GetLocationZ(UNIT_Z_LOCATION)
end

function GetRectX1Y1X2Y2(r)
    return GetRectMinX(r),GetRectMinY(r),GetRectMaxX(r),GetRectMaxY(r)
end

function IsUnitInRect(u,rect)
    local ux,uy = GetUnitXY(u)
    local rx1,ry1,rx2,ry2 = GetRectX1Y1X2Y2(rect)
    return not(ux <= rx1 or uy <= ry1 or ux >= rx2 or uy >= ry2)
end

function IsPointInRect(p,rect)
    local px,py = p.x,p.y
    local rx1,ry1,rx2,ry2 = GetRectX1Y1X2Y2(rect)
    return not(px <= rx1 or py <= ry1 or px >= rx2 or py >= ry2)
end

function MATH_Avg(tbl)
    c,s = tableLength(tbl),0
    for i,v in pairs(tbl) do
        s = s + v
    end
    tbl = nil
    return s/c
end

function MATH_GetRadXY(x,y,tx,ty)
    return Atan2(ty - y, tx - x)
end

function MATH_GetAngleXY(x,y,tx,ty)
    return Atan2(ty - y, tx - x) * bj_RADTODEG
end

function MATH_MoveXY(x,y,dist,rad)
    return x + dist * Cos(rad),y + dist * Sin(rad)
end

function MATH_MoveX(x,dist,rad)
    return x + dist * Cos(rad)
end

function MATH_MoveY(y,dist,rad)
    return y + dist * Sin(rad)
end

function MATH_GetDistance(x,y,tx,ty)
    local dx,dy = tx - x,ty - y 
    return SquareRoot(dx * dx + dy * dy)
end

function GetRandomCoordInRectX(rect)
    return GetRandomReal(GetRectMinX(rect), GetRectMaxX(rect))
end

function GetRandomCoordInRectY(rect)
    return GetRandomReal(GetRectMinY(rect), GetRectMaxY(rect))
end

function GetRandomCoordsInRect(rect)
    return GetRandomReal(GetRectMinX(rect), GetRectMaxX(rect)),GetRandomReal(GetRectMinY(rect), GetRectMaxY(rect))
end

function LoadTOCFile(path)
    if BlzLoadTOCFile(path) then
        return
    end
    print(path .. " import failed")
end

function Get_UnitPrimaryAttribute(unit)
    return BlzGetUnitIntegerField(unit, UNIT_IF_PRIMARY_ATTRIBUTE)
end

function Get_UnitBaseDamage(unit)
    return BlzGetUnitWeaponIntegerField(unit, UNIT_WEAPON_IF_ATTACK_DAMAGE_BASE, 0)
end

function Get_UnitCritRate(unit)
    if IsUnitType(unit, UNIT_TYPE_HERO) then
        return GetHeroAgi(unit, true)
    end
    return UNITS_DATA[GetUnitTypeId(unit)].CritRate or DEFAULT_NONHERO_CRITRATE
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

local oldInit = InitBlizzard
function InitBlizzard()
    UI_HideOriginalUI()
    oldInit()
    MapSetup()
end

function MapSetup_AfterHero()
    DS_DamageEngine_Initialize()
    TT_LoadTargetingSystem()
    UNIT_RegisterGlobalEvents()
    DamageMeter_Initiate()
    TALENTS_UI_Initialize()
    MSX_Initialize()
    Camera_LockDistance()
    CASTSYS_Register()
    CASTMAIN_Initialize()
    REGIONS_Initialize()
    MAIN_Initialize()
    AntiCheatsLoad()
    BUFF_Initialize()
    WIDGET_Initializte()
    BOSSBAR_BarCreate()
    DBM_Initialize()
    AB_SystemInit()
    CD_RegisterCooldownSystem()
    UI_FixFocusBug()

    BOSS_RecalculateLevels()
    BOSS_RecalculateDifficulties()

    TOOLTIP_RegisterTooltiping()

    MapSetup_AfterHero = nil
end

function MapSetup()
    LoadTOCFile("war3mapImported\\CustomUI.toc")
    HERODATA_Load()
    UNIT_InitiateGlobalData()
    UNIT_RegisterPreCreatedUnits()
    RegisterAbilitiesData()
    core_LoadImportedEffects()
    test_keyboard()
end

DEF_CAM_DISTANCE = 2900.0
DEF_CAM = CreateCameraSetup()

function AntiCheatsLoad()
    ANTICHEAT_TARGET = UNIT_Create(PLAYER_BOSS, FourCC("h003"), 15348.0, -15623.0, 270.00)

    local trg = CreateTrigger()
    TriggerRegisterUnitEvent(trg, ANTICHEAT_TARGET, EVENT_UNIT_DEATH)
    TriggerAddAction(trg, function()
        CHEAT_DETECTED = true
        print('I am sorry, but cheats are not accepted in this game, your damage is now nullified, feel free to reload the map and dont ever use cheat again.')
        DestroyTrigger(GetTriggeringTrigger())
    end)

    AntiCheatsLoad = nil
end

function Camera_LockDistance()
    Camera_CreateDefault()
    local trig = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(trig, 0.001)
    TriggerAddAction(trig, Camera_ResetView)
    Camera_CreateDefault = nil
    trig = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trig, PLAYER, ConvertOsKeyType(33), KEY_PRESSED_NONE, true)
    BlzTriggerRegisterPlayerKeyEvent(trig, PLAYER, ConvertOsKeyType(34), KEY_PRESSED_NONE, true)
    BlzTriggerRegisterPlayerKeyEvent(trig, PLAYER, ConvertOsKeyType(33), KEY_PRESSED_SHIFT, true)
    BlzTriggerRegisterPlayerKeyEvent(trig, PLAYER, ConvertOsKeyType(34), KEY_PRESSED_SHIFT, true)
    TriggerAddAction(trig, function()
        local multip = BlzGetTriggerPlayerMetaKey() == KEY_PRESSED_SHIFT and 5 or 1
        if BlzGetTriggerPlayerKey() == ConvertOsKeyType(34) then
            DEF_CAM_DISTANCE = DEF_CAM_DISTANCE - 10 * multip
        else
            DEF_CAM_DISTANCE = DEF_CAM_DISTANCE + 10 * multip
        end
        CameraSetupSetField(DEF_CAM, CAMERA_FIELD_TARGET_DISTANCE, DEF_CAM_DISTANCE, 0.0)
    end)

    Camera_LockDistance = nil
end

function Camera_ResetView()
    SetCameraFieldForPlayer(PLAYER, CAMERA_FIELD_ZOFFSET, CameraSetupGetFieldSwap(CAMERA_FIELD_ZOFFSET, DEF_CAM), 0)
    SetCameraFieldForPlayer(PLAYER, CAMERA_FIELD_ROTATION, CameraSetupGetFieldSwap(CAMERA_FIELD_ROTATION, DEF_CAM), 0)
    SetCameraFieldForPlayer(PLAYER, CAMERA_FIELD_ANGLE_OF_ATTACK, CameraSetupGetFieldSwap(CAMERA_FIELD_ANGLE_OF_ATTACK, DEF_CAM), 0)
    SetCameraFieldForPlayer(PLAYER, CAMERA_FIELD_TARGET_DISTANCE, CameraSetupGetFieldSwap(CAMERA_FIELD_TARGET_DISTANCE, DEF_CAM), 0)
    SetCameraFieldForPlayer(PLAYER, CAMERA_FIELD_ROLL, CameraSetupGetFieldSwap(CAMERA_FIELD_ROLL, DEF_CAM), 0)
    SetCameraFieldForPlayer(PLAYER, CAMERA_FIELD_FIELD_OF_VIEW, CameraSetupGetFieldSwap(CAMERA_FIELD_FIELD_OF_VIEW, DEF_CAM), 0)
    SetCameraFieldForPlayer(PLAYER, CAMERA_FIELD_FARZ, CameraSetupGetFieldSwap(CAMERA_FIELD_FARZ, DEF_CAM), 0)
    SetCameraFieldForPlayer(PLAYER, CAMERA_FIELD_NEARZ, CameraSetupGetFieldSwap(CAMERA_FIELD_NEARZ, DEF_CAM), 0)
    SetCameraFieldForPlayer(PLAYER, CAMERA_FIELD_LOCAL_PITCH, CameraSetupGetFieldSwap(CAMERA_FIELD_LOCAL_PITCH, DEF_CAM), 0)
    SetCameraFieldForPlayer(PLAYER, CAMERA_FIELD_LOCAL_YAW, CameraSetupGetFieldSwap(CAMERA_FIELD_LOCAL_YAW, DEF_CAM), 0)
    SetCameraFieldForPlayer(PLAYER, CAMERA_FIELD_LOCAL_ROLL, CameraSetupGetFieldSwap(CAMERA_FIELD_LOCAL_ROLL, DEF_CAM), 0)
end

function Camera_CreateDefault()
    CameraSetupSetField(DEF_CAM, CAMERA_FIELD_ZOFFSET, 0.0, 0.0)
    CameraSetupSetField(DEF_CAM, CAMERA_FIELD_ROTATION, 90.0, 0.0)
    CameraSetupSetField(DEF_CAM, CAMERA_FIELD_ANGLE_OF_ATTACK, 304.0, 0.0)
    CameraSetupSetField(DEF_CAM, CAMERA_FIELD_TARGET_DISTANCE, DEF_CAM_DISTANCE, 0.0)
    CameraSetupSetField(DEF_CAM, CAMERA_FIELD_ROLL, 0.0, 0.0)
    CameraSetupSetField(DEF_CAM, CAMERA_FIELD_FIELD_OF_VIEW, 70.0, 0.0)
    CameraSetupSetField(DEF_CAM, CAMERA_FIELD_FARZ, 5000.0, 0.0)
    CameraSetupSetField(DEF_CAM, CAMERA_FIELD_NEARZ, 16.0, 0.0)
    CameraSetupSetField(DEF_CAM, CAMERA_FIELD_LOCAL_PITCH, 0.0, 0.0)
    CameraSetupSetField(DEF_CAM, CAMERA_FIELD_LOCAL_YAW, 0.0, 0.0)
    CameraSetupSetField(DEF_CAM, CAMERA_FIELD_LOCAL_ROLL, 0.0, 0.0)
    CameraSetupSetDestPosition(DEF_CAM, -525.3, 51.5, 0.0)
end

----------------------------------------------------
-------------HEALING SYSTEM SETUP-------------------
----------------------------------------------------

HEAL_DEFAULT_TEXTTAG_RED = 76.00
HEAL_DEFAULT_TEXTTAG_GREEN = 255.00
HEAL_DEFAULT_TEXTTAG_BLUE = 76.00
HEAL_DEFAULT_TEXTTAG_TRANSP = 0.00
HEAL_DEFAULT_TEXTTAG_FONTSIZE = 0.028
HEAL_DEFAULT_TEXTTAG_VELOC = 0.14
HEAL_DEFAULT_TEXTTAG_LIFES = 1.50
HEAL_DEFAULT_TEXTTAG_FADEP = 0
HEAL_RND_MULTIPLIER_LB = 0.99
HEAL_RND_MULTIPLIER_UB = 1.01
HEAL_DEFAULT_CRIT_MULTP = 1.50

HEALABS_DEFAULT_TEXTTAG_RED = 255.00
HEALABS_DEFAULT_TEXTTAG_GREEN = 76.00
HEALABS_DEFAULT_TEXTTAG_BLUE = 76.00
HEALABS_DEFAULT_TEXTTAG_TRANSP = 0.00
HEALABS_DEFAULT_TEXTTAG_FONTSIZE = 0.024
HEALABS_DEFAULT_TEXTTAG_VELOC = 0.14
HEALABS_DEFAULT_TEXTTAG_LIFES = 1.50
HEALABS_DEFAULT_TEXTTAG_FADEP = 0

healAbsorb = {}
healAbsorb_Unit = {}
healRecord = {}
healData = {}

healTxt = {
    red = HEAL_DEFAULT_TEXTTAG_RED
    ,green = HEAL_DEFAULT_TEXTTAG_GREEN
    ,blue = HEAL_DEFAULT_TEXTTAG_BLUE
    ,transp = HEAL_DEFAULT_TEXTTAG_TRANSP
    ,fontSize = HEAL_DEFAULT_TEXTTAG_FONTSIZE
    ,veloc = HEAL_DEFAULT_TEXTTAG_VELOC
    ,lifes = HEAL_DEFAULT_TEXTTAG_LIFES
    ,fadep = HEAL_DEFAULT_TEXTTAG_FADEP
}

healabsTxt = {
    red = HEALABS_DEFAULT_TEXTTAG_RED
    ,green = HEALABS_DEFAULT_TEXTTAG_GREEN
    ,blue = HEALABS_DEFAULT_TEXTTAG_BLUE
    ,transp = HEALABS_DEFAULT_TEXTTAG_TRANSP
    ,fontSize = HEALABS_DEFAULT_TEXTTAG_FONTSIZE
    ,veloc = HEALABS_DEFAULT_TEXTTAG_VELOC
    ,lifes = HEALABS_DEFAULT_TEXTTAG_LIFES
    ,fadep = HEALABS_DEFAULT_TEXTTAG_FADEP
}

function HS_healTxt_Refresh()
    healTxt.red = HEAL_DEFAULT_TEXTTAG_RED
    healTxt.green = HEAL_DEFAULT_TEXTTAG_GREEN
    healTxt.blue = HEAL_DEFAULT_TEXTTAG_BLUE
    healTxt.transp = HEAL_DEFAULT_TEXTTAG_TRANSP
    healTxt.fontSize = HEAL_DEFAULT_TEXTTAG_FONTSIZE
    healTxt.veloc = HEAL_DEFAULT_TEXTTAG_VELOC
    healTxt.lifes = HEAL_DEFAULT_TEXTTAG_LIFES
    healTxt.fadep = HEAL_DEFAULT_TEXTTAG_FADEP
end

function HS_healabsTxt_Refresh()
    healabsTxt.red = HEALABS_DEFAULT_TEXTTAG_RED
    healabsTxt.green = HEALABS_DEFAULT_TEXTTAG_GREEN
    healabsTxt.blue = HEALABS_DEFAULT_TEXTTAG_BLUE
    healabsTxt.transp = HEALABS_DEFAULT_TEXTTAG_TRANSP
    healabsTxt.fontSize = HEALABS_DEFAULT_TEXTTAG_FONTSIZE
    healabsTxt.veloc = HEALABS_DEFAULT_TEXTTAG_VELOC
    healabsTxt.lifes = HEALABS_DEFAULT_TEXTTAG_LIFES
    healabsTxt.fadep = HEALABS_DEFAULT_TEXTTAG_FADEP
end

function HS_CreateTxt_Tag(msg,x,y,att)
    local red = att.red or HEAL_DEFAULT_TEXTTAG_RED
    local green = att.green or HEAL_DEFAULT_TEXTTAG_GREEN
    local blue = att.blue or HEAL_DEFAULT_TEXTTAG_BLUE
    local transp = att.transp or HEAL_DEFAULT_TEXTTAG_TRANSP
    local fontSize = att.fontSize or HEAL_DEFAULT_TEXTTAG_FONTSIZE
    local veloc = att.veloc or HEAL_DEFAULT_TEXTTAG_VELOC
    local lifes = att.lifes or HEAL_DEFAULT_TEXTTAG_LIFES
    local fadep = att.fadep or HEAL_DEFAULT_TEXTTAG_FADEP
    local tag = CreateTextTag()
    SetTextTagText(tag, msg, fontSize)
    SetTextTagColor(tag, red, green, blue, transp)
    SetTextTagPos(tag, x, y, 0)
    SetTextTagVelocity(tag, 0.0, veloc)
    SetTextTagLifespanBJ(tag, lifes)
    SetTextTagFadepointBJ(tag, fadep)
    SetTextTagPermanentBJ(tag, false) 
    tag,fadep,lifes,veloc,fontSize,transp,blue,green,red = nil,nil,nil,nil,nil,nil,nil,nil,nil
end

function HS_NullifyAbsorb(unit,abs_id,stack_id)
    local u_id = GetHandleIdBJ(unit)
    healAbsorb[u_id] = healAbsorb[u_id] or {}
    healAbsorb[u_id][abs_id] = healAbsorb[u_id][abs_id] or {}
    healAbsorb[u_id][abs_id][stack_id] = nil
end

function HS_AddAbsorb(unit,abs_id,stack_id,value)
    local u_id = GetHandleIdBJ(unit)
    healAbsorb[u_id] = healAbsorb[u_id] or {}
    healAbsorb[u_id][abs_id] = healAbsorb[u_id][abs_id] or {}
    healAbsorb[u_id][abs_id][stack_id] = (healAbsorb[u_id][abs_id][stack_id] or 0) + value
    if healAbsorb[u_id][abs_id][stack_id] <= 0 then
        healAbsorb[u_id][abs_id][stack_id] = nil
    end
    if value > 0 then
        local x,y = MATH_MoveXY(GetUnitX(unit),GetUnitY(unit),180.00, 180.00 * bj_DEGTORAD)
        msg = '+'..round(value,0)..' HealAbsorb'
        HS_CreateTxt_Tag(msg,x,y,healabsTxt)
        HS_healabsTxt_Refresh()
        x,y = nil,nil
    end
end

function HS_SetAbsorb(unit,abs_id,stack_id,value)
    local u_id = GetHandleIdBJ(unit)
    healAbsorb[u_id] = healAbsorb[u_id] or {}
    healAbsorb[u_id][abs_id] = healAbsorb[u_id][abs_id] or {}
    local formVal = healAbsorb[u_id][abs_id][stack_id] or 0
    healAbsorb[u_id][abs_id][stack_id] = value
    if healAbsorb[u_id][abs_id][stack_id] <= 0 then
        healAbsorb[u_id][abs_id][stack_id] = nil
    end
    if value > 0 and value > formVal then
        local x,y = MATH_MoveXY(GetUnitX(unit),GetUnitY(unit),180.00, 180.00 * bj_DEGTORAD)
        local msg = '+'..round(value-formVal,0)..' HealAbsorb'
        HS_CreateTxt_Tag(msg,x,y,healabsTxt)
        HS_healabsTxt_Refresh()
        x,y = nil,nil
    end
end

function HS_GetAbsorb_Full(unit)
    local u_id = GetHandleIdBJ(unit)
    local val = 0
    if healAbsorb[u_id] then
        for i,x in pairs(healAbsorb[u_id]) do
            for j,v in pairs(healAbsorb[u_id][i]) do
                val = val + v
            end
        end
        return val > 0 and val or nil
    end
    return nil
end

function HS_GetAbsorb_Ability(unit,abs_id)
    local u_id = GetHandleIdBJ(unit)
    local val = 0
    if healAbsorb[u_id] then
        if healAbsorb[u_id][abs_id] then
            for i,v in pairs(healAbsorb[u_id][abs_id]) do
                val = val + v
            end
            return val > 0 and val or nil
        end
    end
    return nil
end

function HS_GetAbsorb_AbilityStack(unit,abs_id,stack_id)
    local u_id = GetHandleIdBJ(unit)
    if healAbsorb[u_id] then
        if healAbsorb[u_id][abs_id] then
            return healAbsorb[u_id][abs_id][stack_id]
        end
    end
    return nil
end

function HS_HealingEngine_Absorbs(unitID,heal)
    local absorbed = false
    if tableLength(healAbsorb[unitID]) == 0 then healAbsorb[unitID] = nil end
    if healAbsorb[unitID] then
        for i,abTbl in pairs(healAbsorb[unitID]) do
            if tableLength(healAbsorb[unitID][i]) == 0 then healAbsorb[unitID][i] = nil end
            if healAbsorb[unitID][i] then
                for j,v in pairs(healAbsorb[unitID][i]) do
                    if v > heal then
                        healAbsorb[unitID][i][j] = v - heal
                        return 0,true
                    elseif v == heal then
                        healAbsorb[unitID][i][j] = nil
                        return 0,true
                    else
                        heal = heal - v
                        healAbsorb[unitID][i][j] = nil
                    end
                end
            end
        end
    end
    return heal,absorbed
end

function HS_Get_UnitCritRateMult(unit,vic,dmg_code)
    local bonusVic = 0
    if dmgFactor_Data_Victim[GetHandleIdBJ(vic)][dmg_code] then
        bonusVic = dmgFactor_Data_Victim[GetHandleIdBJ(vic)][dmg_code].critMultBonus or 0
    end
    local bonus = dmgFactor_Data[GetHandleIdBJ(unit)][dmg_code].critMultBonus or 0
    return HEAL_DEFAULT_CRIT_MULTP + bonus + bonusVic
end

function HS_HealingEngine_Resistance(unit,heal)
    heal = heal * ((100 - math.floor(GetUnitUserData(unit))) / 100)
    if heal < 0 then
        heal = 0
    elseif heal > 0 and heal < 1 then
        heal = 1
    end
    return heal
end

function HS_HealUnit(healer,target,value,healID,noCrit)
    local tarID = GetHandleIdBJ(target)
    local healerID = GetHandleIdBJ(healer)
    healData[healerID] = healData[healerID] or {}
    local healFactor = dmgFactor_Data[healerID][healID].curFactor or 1.0
    local healFacVic = 1.0
    if dmgFactor_Data_Victim[tarID][healID] then
        healFacVic = dmgFactor_Data_Victim[tarID][healID].curFactor or 1.0
    end
    healRecord[healerID] = healRecord[healerID] or {}
    healRecord[tarID] = healRecord[tarID] or {}
    healData[healerID][healID] = healData[healerID][healID] or {}
    healRecord[healerID][healID] = healRecord[healerID][healID] or {}
    healRecord[tarID][healID] = healRecord[tarID][healID] or {}
    local heal = value * GetRandomReal(HEAL_RND_MULTIPLIER_LB, HEAL_RND_MULTIPLIER_UB) * healFactor * healFacVic
    local critRate = DS_Get_UnitCritRate(healer,target,healID)
    critRate = healData[healerID][healID].critRate or critRate
    local critMult = HS_Get_UnitCritRateMult(healer,target,healID)
    critMult = healData[healerID][healID].critRateMult or critMult
    local absorbed = false
    healRecord[tarID][healID].healReceived_WasCrit = false
    healRecord[healerID][healID].healDone_WasCrit = false
    local rnd = GetRandomInt(1, 100)
    if critRate >= rnd and not(noCrit) then
        healTxt.fontSize = healTxt.fontSize * 1.15
        heal = heal * critMult
        healRecord[tarID][healID].healReceived_WasCrit = true
        healRecord[healerID][healID].healDone_WasCrit = true
    end
    heal = HS_HealingEngine_Resistance(target,heal)
    healRecord[healerID][healID].healDone_BefAbsrb = round(heal,0)
    healRecord[tarID][healID].healReceived_BefAbsrb = round(heal,0)
    UNIT_AddHealingDone(healer,healID,heal)
    heal,absorbed = HS_HealingEngine_Absorbs(tarID,heal)
    healRecord[healerID][healID].healDone_AftAbsrb = round(heal,0)
    healRecord[tarID][healID].healReceived_AftAbsrb = round(heal,0)
    healRecord[tarID][healID].overheal = (GetUnitStateSwap(UNIT_STATE_LIFE, target) + heal) - BlzGetUnitMaxHP(target)
    SetUnitLifeBJ(target, GetUnitStateSwap(UNIT_STATE_LIFE, target) + heal)
    local healmsg = absorbed and 'Absorbed' or '+'..round(heal,0)
    healTxt.fontSize = (absorbed) and 0.024 or healTxt.fontSize
    if tostring(healmsg) ~= '0' then
        local x,y = GetUnitXY(target)
        HS_CreateTxt_Tag(healmsg,x,y,healTxt)
        x,y = nil,nil
    end
    healData[healerID][healID].critRateMult = nil
    healData[healerID][healID].critRate = nil
    healData[healerID].healID = nil
    HS_healTxt_Refresh()
    tarID,healerID,healFactor,healFacVic,heal,critRate,critMult,absorbed,rnd,healmsg = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
end

----------------------------------------------------
-------------DAMAGE SYSTEM SETUP--------------------
----------------------------------------------------

DEFAULT_TEXTTAG_RED = 255.00
DEFAULT_TEXTTAG_GREEN = 76.00
DEFAULT_TEXTTAG_BLUE = 76.00
DEFAULT_TEXTTAG_TRANSP = 0.00
DEFAULT_TEXTTAG_FONTSIZE = 0.032
DEFAULT_TEXTTAG_VELOC = 0.14
DEFAULT_TEXTTAG_LIFES = 1.00
DEFAULT_TEXTTAG_FADEP = 0
DAMAGE_RND_MULTIPLIER_LB = 0.99
DAMAGE_RND_MULTIPLIER_UB = 1.01
DAMAGE_DEFAULT_CRIT_MULTP = 1.50

ABSDEFAULT_TEXTTAG_RED = 76.00
ABSDEFAULT_TEXTTAG_GREEN = 255.00
ABSDEFAULT_TEXTTAG_BLUE = 76.00
ABSDEFAULT_TEXTTAG_TRANSP = 0.00
ABSDEFAULT_TEXTTAG_FONTSIZE = 0.024
ABSDEFAULT_TEXTTAG_VELOC = 0.14
ABSDEFAULT_TEXTTAG_LIFES = 1.50
ABSDEFAULT_TEXTTAG_FADEP = 0

CHEAT_DETECTED = false

dmgAbsorb = {}
dmgRecord = {}
dmgData = {}

dmgTxt = {
    red = DEFAULT_TEXTTAG_RED
    ,green = DEFAULT_TEXTTAG_GREEN
    ,blue = DEFAULT_TEXTTAG_BLUE
    ,transp = DEFAULT_TEXTTAG_TRANSP
    ,fontSize = DEFAULT_TEXTTAG_FONTSIZE
    ,veloc = DEFAULT_TEXTTAG_VELOC
    ,lifes = DEFAULT_TEXTTAG_LIFES
    ,fadep = DEFAULT_TEXTTAG_FADEP
}

absTxt = {
    red = ABSDEFAULT_TEXTTAG_RED
    ,green = ABSDEFAULT_TEXTTAG_GREEN
    ,blue = ABSDEFAULT_TEXTTAG_BLUE
    ,transp = ABSDEFAULT_TEXTTAG_TRANSP
    ,fontSize = ABSDEFAULT_TEXTTAG_FONTSIZE
    ,veloc = ABSDEFAULT_TEXTTAG_VELOC
    ,lifes = ABSDEFAULT_TEXTTAG_LIFES
    ,fadep = ABSDEFAULT_TEXTTAG_FADEP
}

TAG_clRed = 1
TAG_clLightGreen = 2
TAG_clBlue = 3
TAG_clDefault = 4
TAG_clDefaultAbs = 5
TAG_clWhite = 6
TAG_clGray = 7
TAG_clYellow = 8
TAG_clOrange = 9
TAG_clAzure = 10
TAG_clLightBlue = 11
TAG_clGreen = 12
TAG_clPink = 13
TAG_clBrown = 14
TAG_clGold = 15
TAG_clLightBrown = 16
TAG_clShadow = 17

TAG_Colors = {
    [TAG_clRed] = {
        r = 255.0
        ,g = 0.0
        ,b = 0.0
    }
    ,[TAG_clLightGreen] = {
        r = 0.0
        ,g = 255.0
        ,b = 0.0
    }
    ,[TAG_clBlue] = {
        r = 0.0
        ,g = 0.0
        ,b = 255.0
    }
    ,[TAG_clDefault] = {
        r = DEFAULT_TEXTTAG_RED
        ,g = DEFAULT_TEXTTAG_GREEN
        ,b = DEFAULT_TEXTTAG_BLUE
    }
    ,[TAG_clDefaultAbs] = {
        r = ABSDEFAULT_TEXTTAG_RED
        ,g = ABSDEFAULT_TEXTTAG_GREEN
        ,b = ABSDEFAULT_TEXTTAG_BLUE
    }
    ,[TAG_clWhite] = {
        r = 255.0
        ,g = 255.0
        ,b = 255.0
    }
    ,[TAG_clGray] = {
        r = 150.0
        ,g = 150.0
        ,b = 150.0
    }
    ,[TAG_clYellow] = {
        r = 255.0
        ,g = 255.0
        ,b = 0.0
    }
    ,[TAG_clOrange] = {
        r = 255.0
        ,g = 130.0
        ,b = 0.0
    }
    ,[TAG_clAzure] = {
        r = 0.0
        ,g = 255.0
        ,b = 255.0
    }
    ,[TAG_clLightBlue] = {
        r = 0.0
        ,g = 130.0
        ,b = 255.0
    }
    ,[TAG_clGreen] = {
        r = 0.0
        ,g = 130.0
        ,b = 0.0
    }
    ,[TAG_clPink] = {
        r = 255.0
        ,g = 60.0
        ,b = 170.0
    }
    ,[TAG_clBrown] = {
        r = 85.0
        ,g = 53.0
        ,b = 26.0
    }
    ,[TAG_clGold] = {
        r = 255.0
        ,g = 204.0
        ,b = 0.0
    }
    ,[TAG_clLightBrown] = {
        r = 188.0
        ,g = 158.0
        ,b = 130.0
    }
    ,[TAG_clShadow] = {
        r = 100.0
        ,g = 78.0
        ,b = 127.0
    }
}

function DS_dmgTxt_LoadColor(dmg_id)
    cl_id = (ABILITIES_DATA[dmg_id] and ABILITIES_DATA[dmg_id].TAG_color) and ABILITIES_DATA[dmg_id].TAG_color or TAG_clDefault
    dmgTxt.red = TAG_Colors[cl_id].r
    dmgTxt.green = TAG_Colors[cl_id].g
    dmgTxt.blue = TAG_Colors[cl_id].b
end

function DS_absTxt_LoadColor(abs_id)
    cl_id = (ABILITIES_DATA[abs_id] and ABILITIES_DATA[abs_id].TAG_color_abs) and ABILITIES_DATA[abs_id].TAG_color_abs or TAG_clDefaultAbs
    absTxt.red = TAG_Colors[cl_id].r
    absTxt.green = TAG_Colors[cl_id].g
    absTxt.blue = TAG_Colors[cl_id].b
end

function DS_dmgTxt_Refresh()
    dmgTxt.transp = DEFAULT_TEXTTAG_TRANSP
    dmgTxt.fontSize = DEFAULT_TEXTTAG_FONTSIZE
    dmgTxt.veloc = DEFAULT_TEXTTAG_VELOC
    dmgTxt.lifes = DEFAULT_TEXTTAG_LIFES
    dmgTxt.fadep = DEFAULT_TEXTTAG_FADEP
end

function DS_absTxt_Refresh()
    absTxt.transp = ABSDEFAULT_TEXTTAG_TRANSP
    absTxt.fontSize = ABSDEFAULT_TEXTTAG_FONTSIZE
    absTxt.veloc = ABSDEFAULT_TEXTTAG_VELOC
    absTxt.lifes = ABSDEFAULT_TEXTTAG_LIFES
    absTxt.fadep = ABSDEFAULT_TEXTTAG_FADEP
end

function DS_CreateTxt_Tag(msg,x,y,att)
    local red = att.red or DEFAULT_TEXTTAG_RED
    local green = att.green or DEFAULT_TEXTTAG_GREEN
    local blue = att.blue or DEFAULT_TEXTTAG_BLUE
    local transp = att.transp or DEFAULT_TEXTTAG_TRANSP
    local fontSize = att.fontSize or DEFAULT_TEXTTAG_FONTSIZE
    local veloc = att.veloc or DEFAULT_TEXTTAG_VELOC
    local lifes = att.lifes or DEFAULT_TEXTTAG_LIFES
    local fadep = att.fadep or DEFAULT_TEXTTAG_FADEP
    local tag = CreateTextTag()
    SetTextTagText(tag, msg, fontSize)
    SetTextTagColor(tag, red, green, blue, transp)
    SetTextTagPos(tag, x, y, 0)
    SetTextTagVelocity(tag, 0.0, veloc)
    SetTextTagLifespanBJ(tag, lifes)
    SetTextTagFadepointBJ(tag, fadep)
    SetTextTagPermanentBJ(tag, false) 
    tag,fadep,lifes,veloc,fontSize,transp,blue,green,red = nil,nil,nil,nil,nil,nil,nil,nil,nil
end

function DS_AddAbsorb(caster,unit,abs_id,stack_id,value)
    local u_id = GetHandleIdBJ(unit)
    value = DS_RecalculateValue(caster,unit,abs_id,value)
    dmgAbsorb[u_id] = dmgAbsorb[u_id] or {}
    dmgAbsorb[u_id][abs_id] = dmgAbsorb[u_id][abs_id] or {}
    dmgAbsorb[u_id][abs_id][stack_id] = (dmgAbsorb[u_id][abs_id][stack_id] or 0) + value
    if dmgAbsorb[u_id][abs_id][stack_id] <= 0 then
        dmgAbsorb[u_id][abs_id][stack_id] = nil
    end
    if value > 0 then
        local x,y = MATH_MoveXY(GetUnitX(unit),GetUnitY(unit),180.00, 180.00 * bj_DEGTORAD)
        local msg = '+'..round(value,0)..' Absorb'
        DS_absTxt_LoadColor(abs_id)
        DS_CreateTxt_Tag(msg,x,y,absTxt)
        DS_absTxt_Refresh()
        loc,x,y = nil,nil,nil
    end
    u_id = nil
end

function DS_NullifyAbsorb(unit,abs_id,stack_id)
    local u_id = GetHandleIdBJ(unit)
    dmgAbsorb[u_id] = dmgAbsorb[u_id] or {}
    dmgAbsorb[u_id][abs_id] = dmgAbsorb[u_id][abs_id] or {}
    dmgAbsorb[u_id][abs_id][stack_id] = nil
    u_id = nil
end

function DS_SetAbsorb(caster,unit,abs_id,stack_id,value,exact)
    local u_id = GetHandleIdBJ(unit)
    value = exact and value or DS_RecalculateValue(caster,unit,abs_id,value)
    dmgAbsorb[u_id] = dmgAbsorb[u_id] or {}
    dmgAbsorb[u_id][abs_id] = dmgAbsorb[u_id][abs_id] or {}
    local formVal = dmgAbsorb[u_id][abs_id][stack_id] or 0
    dmgAbsorb[u_id][abs_id][stack_id] = value
    if dmgAbsorb[u_id][abs_id][stack_id] <= 0 then
        dmgAbsorb[u_id][abs_id][stack_id] = nil
    end
    if value > 0 and value > formVal then
        local x,y = MATH_MoveXY(GetUnitX(unit),GetUnitY(unit),180.00, 180.00 * bj_DEGTORAD)
        local msg = '+'..round(value-formVal,0)..' Absorb'
        DS_absTxt_LoadColor(abs_id)
        DS_CreateTxt_Tag(msg,x,y,absTxt)
        DS_absTxt_Refresh()
        loc,x,y = nil,nil,nil
    end
end

function DS_RecalculateValue(deal,vic,dmgID,value)
    local vicID = GetHandleIdBJ(vic)
    local dealID = GetHandleIdBJ(deal)
    local dmgFactor = dmgFactor_Data[dealID][dmgID].curFactor or 1.0
    local dmgFacVic = 1.0
    if dmgFactor_Data_Victim[vicID][dmgID] then
        dmgFacVic = dmgFactor_Data_Victim[vicID][dmgID].curFactor or 1.0
    end
    value = value * GetRandomReal(DAMAGE_RND_MULTIPLIER_LB, DAMAGE_RND_MULTIPLIER_UB) * dmgFactor * dmgFacVic
    local critRate = DS_Get_UnitCritRate(deal,vic,dmgID)
    local critMult = DS_Get_UnitCritRateMult(deal,vic,dmgID)
    local rnd = GetRandomInt(1, 100)
    if critRate >= rnd then
        value = value * critMult
    end
    rnd,critMult,critRate,dmgFacVic,dmgFactor,dealID,vicID = nil,nil,nil,nil,nil,nil,nil
    return value
end

function DS_GetAbsorb_Full(unit)
    local u_id = GetHandleIdBJ(unit)
    local val = 0
    if dmgAbsorb[u_id] then
        for i,x in pairs(dmgAbsorb[u_id]) do
            for j,v in pairs(dmgAbsorb[u_id][i]) do
                val = val + v
            end
        end
        return val > 0 and val or nil
    end
    return nil
end

function DS_GetAbsorb_Ability(unit,abs_id)
    local u_id = GetHandleIdBJ(unit)
    local val = 0
    if dmgAbsorb[u_id] then
        if dmgAbsorb[u_id][abs_id] then
            for i,v in pairs(dmgAbsorb[u_id][abs_id]) do
                val = val + v
            end
            return val > 0 and val or nil
        end
    end
    return nil
end

function DS_GetAbsorb_AbilityStack(unit,abs_id,stack_id)
    local u_id = GetHandleIdBJ(unit)
    if dmgAbsorb[u_id] then
        if dmgAbsorb[u_id][abs_id] then
            return dmgAbsorb[u_id][abs_id][stack_id] or nil
        end
    end
    return nil
end

function DS_DamageEngine_Absorbs(unitID,damage)
    local absorbed = false
    if tableLength(dmgAbsorb[unitID]) == 0 then dmgAbsorb[unitID] = nil end
    if dmgAbsorb[unitID] then
        for i,abTbl in pairs(dmgAbsorb[unitID]) do
            if tableLength(dmgAbsorb[unitID][i]) == 0 then dmgAbsorb[unitID][i] = nil end
            if dmgAbsorb[unitID][i] then
                for j,v in pairs(dmgAbsorb[unitID][i]) do
                    if v > damage then
                        dmgAbsorb[unitID][i][j] = v - damage
                        return 0,true
                    elseif v == damage then
                        dmgAbsorb[unitID][i][j] = nil
                        return 0,true
                    else
                        damage = damage - v
                        dmgAbsorb[unitID][i][j] = nil
                    end
                end
            end
        end
    end
    return damage,absorbed
end

function DS_DamageEngine_Resistance(unit,dmg)
    dmg = dmg * ((100 - math.floor(BlzGetUnitArmor(unit))) / 100)
    if dmg < 0 then
        dmg = 0
    elseif dmg > 0 and dmg < 1 then
        dmg = 1
    end
    return dmg
end

function DS_DamageUnit(source,target,damage,att_type,dmg_type,dmg_code,no_crit)
    local sourceID = GetHandleIdBJ(source)
    dmgData[sourceID] = dmgData[sourceID] or {}
    dmgData[sourceID].dmgID = dmg_code
    dmgData[sourceID].noCrit = no_crit
    UnitDamageTargetBJ(source, target, damage, att_type, dmg_type)
end

function DS_Get_UnitCritRate(unit,vic,dmg_code)
    local bonusVic = 0
    if dmgFactor_Data_Victim[GetHandleIdBJ(vic)][dmg_code] then
        bonusVic = dmgFactor_Data_Victim[GetHandleIdBJ(vic)][dmg_code].critBonus or 0
    end
    local bonus = dmgFactor_Data[GetHandleIdBJ(unit)][dmg_code].critBonus or 0
    return Get_UnitCritRate(unit) + bonus + bonusVic
end

function DS_Get_UnitCritRateMult(unit,vic,dmg_code)
    local bonusVic = 0
    if dmgFactor_Data_Victim[GetHandleIdBJ(vic)][dmg_code] then
        bonusVic = dmgFactor_Data_Victim[GetHandleIdBJ(vic)][dmg_code].critMultBonus or 0
    end
    local bonus = dmgFactor_Data[GetHandleIdBJ(unit)][dmg_code].critMultBonus or 0
    return DAMAGE_DEFAULT_CRIT_MULTP + bonus + bonusVic
end

function DS_DamageEngine()
    if not(CHEAT_DETECTED) and not(BlzGetEventAttackType() == ATTACK_TYPE_NORMAL) then
        local vic,deal,attType = BlzGetEventDamageTarget(),GetEventDamageSource(),BlzGetEventAttackType()
        local vicID,dealID = GetHandleIdBJ(vic),GetHandleIdBJ(deal)

        dmgData[dealID] = dmgData[dealID] or {}
        dmgRecord[dealID] = dmgRecord[dealID] or {}
        dmgRecord[vicID] = dmgRecord[vicID] or {}

        local dmgID = dmgData[dealID].dmgID or DAMAGE_ENGINE_TYPE_AUTOATTACK
        DS_dmgTxt_LoadColor(dmgID)

        dmgData[dealID][dmgID] = dmgData[dealID][dmgID] or {}
        dmgRecord[dealID][dmgID] = dmgRecord[dealID][dmgID] or {}
        dmgRecord[vicID][dmgID] = dmgRecord[vicID][dmgID] or {}

        local dmgFacVic = 1.0
        if dmgFactor_Data_Victim[vicID][dmgID] then
            dmgFacVic = dmgFactor_Data_Victim[vicID][dmgID].curFactor or 1.0
        end

        local dmgFactor = dmgFactor_Data[dealID][dmgID].curFactor or 1.0
        local dmg = GetEventDamage() * GetRandomReal(DAMAGE_RND_MULTIPLIER_LB, DAMAGE_RND_MULTIPLIER_UB) * dmgFactor * dmgFacVic

        if attType == ATTACK_TYPE_HERO then
            BlzSetEventDamage(0)
            DS_Autoattack(deal,vic,Get_UnitBaseDamage(deal))
            return
        end

        local critRate = dmgData[dealID][dmgID].critRate or DS_Get_UnitCritRate(deal,vic,dmgID)
        local critMult = dmgData[dealID][dmgID].critRateMult or DS_Get_UnitCritRateMult(deal,vic,dmgID)
        local absorbed,immune = false,UNIT_IsDmgImmune(vic)
        dmgRecord[vicID][dmgID].dmgReceived_WasCrit,dmgRecord[dealID][dmgID].dmgDone_WasCrit = false,false
        
        if not(immune) then
            if critRate >= GetRandomInt(1, 100) and not(dmgData[dealID].noCrit) then
                dmgTxt.fontSize = dmgTxt.fontSize * 1.15
                dmg = dmg * critMult
                dmgRecord[vicID][dmgID].dmgReceived_WasCrit,dmgRecord[dealID][dmgID].dmgDone_WasCrit = true,true
            end
        else
            dmg = 0
        end
        dmg = not(IsInArray(dmgID,ABILITY_DMG_EXPECTIONS)) and DS_DamageEngine_Resistance(vic,dmg) or dmg
        dmgRecord[dealID][dmgID].dmgDone_BefAbsrb,dmgRecord[vicID][dmgID].dmgReceived_BefAbsrb = round(dmg,0),round(dmg,0)

        UNIT_AddDmgDone(deal,dmgID,dmg)

        dmg,absorbed = DS_DamageEngine_Absorbs(vicID,dmg)
        dmgRecord[dealID][dmgID].dmgDone_AftAbsrb,dmgRecord[vicID][dmgID].dmgReceived_AftAbsrb = round(dmg,0),round(dmg,0)
        BlzSetEventDamage(dmg)

        local dmgmsg = immune and 'Immune' or (absorbed and 'Absorbed' or round(dmg,0))
        dmgTxt.fontSize = (absorbed or immune) and 0.028 or dmgTxt.fontSize

        local x,y = GetUnitXY(vic)
        DS_CreateTxt_Tag(dmgmsg,x,y,dmgTxt)
        x,y = nil,nil

        dmgData[dealID][dmgID].critRateMult = nil
        dmgData[dealID][dmgID].critRate = nil
        dmgData[dealID].dmgID = nil
        DS_dmgTxt_Refresh()

        if UNITS_DATA[GetUnitTypeId(vic)].IMMORTAL then
            BlzSetEventDamage(0)
        end

        dmgmsg,immune,absorbed,critMult,critRate,dmg,dmgFacVic,dmgFactor,dmgID,attType,dealID,vicID,deal,vic = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
    else
        BlzSetEventDamage(-80000)
    end
end

function DS_DamageEngine_Initialize()
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DAMAGED)
    TriggerAddAction(trigger, DS_DamageEngine)

    DS_DamageEngine_Initialize = nil
end

function DS_Autoattack(attacker,victim,dmg)
    if GetUnitTypeId(attacker) == HERO_FIREMAGE then
        AB_FireMage_AutoAttack(attacker,victim,dmg)
    elseif GetUnitTypeId(attacker) == HERO_PRIEST then
        
    elseif GetUnitTypeId(attacker) == FourCC('N004') then
        Shaman_AutoAttack(attacker,victim,dmg)
    end
end

----------------------------------------------------
------------------DAMAGE METER----------------------
----------------------------------------------------

DMGMETER_FRAME = nil
DMGMETER_FRAME_TEXT = nil
DMGMETER_ENABLED = true
DMGMETER_ABFRAMES_CONTAINER = {}
DMGMETER_FRAME_X = 0.7765
DMGMETER_FRAME_Y_DEFAULT = 0.024
DMGMETER_FRAME_Y = 0.024
DMGMETER_COMBAT_PERIOD = 0
DMGMETER_COMBAT_DURATION = 0
DMGMETER_COMBAT_MAXDURATION = 5
DMGMETER_COMBAT_TIMER = nil
DMGMETER_SUMMARY_INDEX = 1
DMGMETER_SUMMARY_FRAME = nil
DMGMETER_SUMMARY_FRAME_DMG = nil
DMGMETER_SUMMARY_FRAME_DPS = nil

function DamageMeter_Initiate()
    DMGMETER_FRAME = BlzCreateSimpleFrame("DamageMeter_MainFrame",  BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    BlzFrameSetAbsPoint(DMGMETER_FRAME, FRAMEPOINT_BOTTOMLEFT, DMGMETER_FRAME_X, DMGMETER_FRAME_Y)
    DMGMETER_FRAME_TEXT = BlzGetFrameByName("DamageMeter_CaptionFrameText", 0)

    local trigger = CreateTrigger()

    BlzTriggerRegisterPlayerKeyEvent(trigger, PLAYER, OSKEY_D, KEY_PRESSED_NONE, true)
    BlzTriggerRegisterFrameEvent(trigger, BlzGetFrameByName("DamageMeter_Button", 0), FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(trigger, function()
        if DMGMETER_ENABLED then
            DMGMETER_ENABLED = false
            BlzFrameSetTexture(BlzGetFrameByName("DamageMeter_Button_FrameIcon", 0), "war3mapImported\\BTN_DmgMeter_UP.dds", 0, true)
            DamageMeter_HideAbilities()
        else 
            DMGMETER_ENABLED = true
            BlzFrameSetTexture(BlzGetFrameByName("DamageMeter_Button_FrameIcon", 0), "war3mapImported\\BTN_DmgMeter_DOWN.dds", 0, true)
            DamageMeter_ShowAbilities()
        end
    end)

    trigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(trigger, BlzGetFrameByName("DamageMeter_Button_Reset", 0), FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(trigger, function()
        DamageMeter_Reset()
    end)

    BlzFrameSetText(DMGMETER_FRAME_TEXT, "Damage Meter")

    DMGMETER_SUMMARY_FRAME = BlzCreateSimpleFrame("DamageMeter_AbilityFrame", DMGMETER_FRAME, DMGMETER_SUMMARY_INDEX)
    BlzFrameSetPoint(DMGMETER_SUMMARY_FRAME, FRAMEPOINT_TOP, DMGMETER_FRAME, FRAMEPOINT_BOTTOM, 0, 0)

    local frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameTotal", DMGMETER_SUMMARY_FRAME, DMGMETER_SUMMARY_INDEX)
    BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_SUMMARY_FRAME, FRAMEPOINT_LEFT, 0.01, 0)
    BlzFrameSetText(BlzGetFrameByName("DamageMeter_AbilityFrameTotal_Text", DMGMETER_SUMMARY_INDEX), "[Total]")

    frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameDMG", DMGMETER_SUMMARY_FRAME, DMGMETER_SUMMARY_INDEX)
    BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_SUMMARY_FRAME, FRAMEPOINT_LEFT, 0.05, 0)
    frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameDPS", DMGMETER_SUMMARY_FRAME, DMGMETER_SUMMARY_INDEX)
    BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_SUMMARY_FRAME, FRAMEPOINT_LEFT, 0.13, 0)

    DMGMETER_SUMMARY_FRAME_DMG = BlzGetFrameByName("DamageMeter_AbilityFrameDMG_Text", DMGMETER_SUMMARY_INDEX)
    DMGMETER_SUMMARY_FRAME_DPS = BlzGetFrameByName("DamageMeter_AbilityFrameDPS_Text", DMGMETER_SUMMARY_INDEX)

    DMGMETER_COMBAT_TIMER = CreateTrigger()

    TriggerRegisterTimerEventPeriodic(DMGMETER_COMBAT_TIMER, 1)
    
    DisableTrigger(DMGMETER_COMBAT_TIMER)
    TriggerAddAction(DMGMETER_COMBAT_TIMER, function()
        DMGMETER_COMBAT_DURATION = DMGMETER_COMBAT_DURATION + 1
        DMGMETER_COMBAT_PERIOD = DMGMETER_COMBAT_PERIOD + 1
        if DMGMETER_COMBAT_PERIOD == DMGMETER_COMBAT_MAXDURATION then
            DisableTrigger(DMGMETER_COMBAT_TIMER)
            DMGMETER_COMBAT_DURATION = (DMGMETER_COMBAT_DURATION > DMGMETER_COMBAT_MAXDURATION ) and DMGMETER_COMBAT_DURATION - DMGMETER_COMBAT_MAXDURATION or 0
            DMGMETER_COMBAT_PERIOD = 0
            if DMGMETER_ENABLED then
                DamageMeter_Sort()
            else
                DamageMeter_Sort_TotalOnly()
            end
        end
    end)

    trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DAMAGED)
    TriggerAddCondition(trigger, Condition(function() return GetEventDamageSource() == HERO end))
    TriggerAddAction(trigger, function()
        DMGMETER_COMBAT_PERIOD = 0
        if DMGMETER_ENABLED then
            DamageMeter_Sort()
        else
            DamageMeter_Sort_TotalOnly()
        end
        if not(IsTriggerEnabled(DMGMETER_COMBAT_TIMER)) then
            EnableTrigger(DMGMETER_COMBAT_TIMER)
        end
    end)

    DamageMeter_Initiate = nil
end

function DamageMeter_HideAbilities()
    for i,v in pairs(DMGMETER_ABFRAMES_CONTAINER) do
        BlzFrameSetVisible(v.frame, false)
    end
    BlzFrameSetAbsPoint(DMGMETER_FRAME, FRAMEPOINT_BOTTOMLEFT, DMGMETER_FRAME_X, DMGMETER_FRAME_Y)
end

function DamageMeter_ShowAbilities()
    local id = GetHandleIdBJ(HERO)
    for i,v in pairs(DMGMETER_ABFRAMES_CONTAINER) do
        if dmgFactor_Data[id][i].dmgDone_Meter > 0 then
            BlzFrameSetVisible(v.frame, true)
        end
    end
    DamageMeter_Sort()
end

function DamageMeter_Reset()
    local id = GetHandleIdBJ(HERO)
    local type_id = GetUnitTypeId(HERO)
    for i, v in pairs(UNITS_DATA[type_id].ABILITIES) do
        dmgFactor_Data[id][v].dmgDone_Meter = 0
    end
    BlzFrameSetText(DMGMETER_SUMMARY_FRAME_DPS, 'DPS: 0')
    BlzFrameSetText(DMGMETER_SUMMARY_FRAME_DMG, 'DMG: 0')
    DMGMETER_COMBAT_DURATION = 0
    DamageMeter_HideAbilities()
end

function DamageMeter_AddAbility(abCode)
    if not(DMGMETER_ABFRAMES_CONTAINER[abCode]) then
        DMGMETER_ABFRAMES_CONTAINER[abCode] = {}
        local frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrame", DMGMETER_FRAME, abCode)
        DMGMETER_ABFRAMES_CONTAINER[abCode].frame = frame
        frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameIcon", frame, abCode)
        DMGMETER_ABFRAMES_CONTAINER[abCode].icon = frame
        BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_ABFRAMES_CONTAINER[abCode].frame, FRAMEPOINT_LEFT, 0.02, 0)
        frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameOrder", DMGMETER_ABFRAMES_CONTAINER[abCode].frame, abCode)
        DMGMETER_ABFRAMES_CONTAINER[abCode].order = frame
        BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_ABFRAMES_CONTAINER[abCode].frame, FRAMEPOINT_LEFT, 0, 0)
        frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameDMG", DMGMETER_ABFRAMES_CONTAINER[abCode].frame, abCode)
        DMGMETER_ABFRAMES_CONTAINER[abCode].dmg = frame
        BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_ABFRAMES_CONTAINER[abCode].frame, FRAMEPOINT_LEFT, 0.05, 0)
        frame = BlzCreateSimpleFrame("DamageMeter_AbilityFrameDPS", DMGMETER_ABFRAMES_CONTAINER[abCode].frame, abCode)
        DMGMETER_ABFRAMES_CONTAINER[abCode].dps = frame
        BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, DMGMETER_ABFRAMES_CONTAINER[abCode].frame, FRAMEPOINT_LEFT, 0.13, 0)
        BlzFrameSetTexture(BlzGetFrameByName('DamageMeter_AbilityFrameIconTexture', abCode), ABILITIES_DATA[abCode].ICON, 0, true)
    else
        BlzFrameSetVisible(DMGMETER_ABFRAMES_CONTAINER[abCode].frame, true)
    end
end

function DamageMeter_Sort_TotalOnly()
    local id = GetHandleIdBJ(HERO)
    local type_id = GetUnitTypeId(HERO)
    local dmg_total = 0
    for i, v in pairs(UNITS_DATA[type_id].ABILITIES) do
        if ABILITIES_DATA[v] and ABILITIES_DATA[v].DMG_METER and dmgFactor_Data[id][v].dmgDone_Meter > 0 then
            dmg_total = dmg_total + dmgFactor_Data[id][v].dmgDone_Meter
        end
    end
    BlzFrameSetText(DMGMETER_SUMMARY_FRAME_DPS, 'DPS: ' .. math.floor(dmg_total/DMGMETER_COMBAT_DURATION == 1 and 0 or dmg_total/DMGMETER_COMBAT_DURATION))
    BlzFrameSetText(DMGMETER_SUMMARY_FRAME_DMG, 'DMG: ' .. math.floor(dmg_total))
end

function DamageMeter_Sort()
    local id = GetHandleIdBJ(HERO)
    local type_id = GetUnitTypeId(HERO)
    local dmg_Tbl = {}
    local tbl = nil
    for i, v in pairs(UNITS_DATA[type_id].ABILITIES) do
        if ABILITIES_DATA[v] and ABILITIES_DATA[v].DMG_METER and dmgFactor_Data[id][v].dmgDone_Meter > 0 then
            tbl = {
                abCode = v
                ,dmgDone = dmgFactor_Data[id][v].dmgDone_Meter
            }
            table.insert(dmg_Tbl,tbl)
            tbl = nil
            DamageMeter_AddAbility(v)
            DMGMETER_FRAME_Y = DMGMETER_FRAME_Y + 0.024
        end
    end
    table.sort (dmg_Tbl, function (k1, k2) return k1.dmgDone > k2.dmgDone end )

    BlzFrameSetAbsPoint(DMGMETER_FRAME, FRAMEPOINT_BOTTOMLEFT, DMGMETER_FRAME_X, DMGMETER_FRAME_Y)
    local lastFrame = DMGMETER_SUMMARY_FRAME
    local dmg_total = 0
    for i,v in pairs(dmg_Tbl) do
        BlzFrameSetPoint(DMGMETER_ABFRAMES_CONTAINER[v.abCode].frame, FRAMEPOINT_TOP, lastFrame, FRAMEPOINT_BOTTOM, 0, 0)
        lastFrame = DMGMETER_ABFRAMES_CONTAINER[v.abCode].frame
        BlzFrameSetText(BlzGetFrameByName('DamageMeter_AbilityFrameDPS_Text', v.abCode), 'DPS: ' .. math.floor(v.dmgDone/DMGMETER_COMBAT_DURATION))
        BlzFrameSetText(BlzGetFrameByName('DamageMeter_AbilityFrameDMG_Text', v.abCode), 'DMG: ' .. math.floor(v.dmgDone))
        BlzFrameSetText(BlzGetFrameByName('DamageMeter_AbilityFrameOrder_Text', v.abCode), i)
        dmg_total = dmg_total + v.dmgDone
    end
    BlzFrameSetText(DMGMETER_SUMMARY_FRAME_DPS, 'DPS: ' .. math.floor(dmg_total/DMGMETER_COMBAT_DURATION == 1 and 0 or dmg_total/DMGMETER_COMBAT_DURATION))
    BlzFrameSetText(DMGMETER_SUMMARY_FRAME_DMG, 'DMG: ' .. math.floor(dmg_total))
    DMGMETER_FRAME_Y = DMGMETER_FRAME_Y_DEFAULT
    dmg_Tbl,type_id,id = nil,nil,nil
end

----------------------------------------------------
-------------TALENTS SYSTEM SETUP-------------------
----------------------------------------------------

TALENTS_TABLE = nil
TALENTS_FRAME_CONTAINER = {}
TALENTS_FRAME_MAIN = nil
TALENTS_BUTTON_RESET = nil
TALENTS_BUTTON_CLOSE = nil
TALENTS_FRAME_TRIGGER_ENTER = CreateTrigger()
TALENTS_FRAME_TRIGGER_LEAVE = CreateTrigger()
TALENTS_FRAME_TRIGGER_CLICK = CreateTrigger()

function TALENTS_UI_Initialize()
    local trigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(trigger, BlzGetFrameByName("Hero_Portrait", 0), FRAMEEVENT_CONTROL_CLICK)
    BlzTriggerRegisterPlayerKeyEvent(trigger, PLAYER, TALENTS_ABILITY_KEY, KEY_PRESSED_NONE, true)
    TriggerAddAction(trigger, function()
        if BlzFrameIsVisible(TALENTS_FRAME_MAIN) then
            TALENTS_UI_Hide()
        else
            TALENTS_UI_Show()
        end
        BlzFrameSetEnable(BlzGetTriggerFrame(), false)
        BlzFrameSetEnable(BlzGetTriggerFrame(), true)
    end)

    TriggerAddAction(TALENTS_FRAME_TRIGGER_ENTER, function()
        local Tree_ID,Talent_ID = TALENTS_UI_IdentifyFrame(BlzGetTriggerFrame())
        TALENTS_UI_Highlight(Tree_ID,Talent_ID)
    end)
    TriggerAddAction(TALENTS_FRAME_TRIGGER_LEAVE, function()
        local Tree_ID,Talent_ID = TALENTS_UI_IdentifyFrame(BlzGetTriggerFrame())
        TALENTS_UI_Unhighlight(Tree_ID,Talent_ID)
    end)
    TriggerAddAction(TALENTS_FRAME_TRIGGER_CLICK, function()
        local Tree_ID,Talent_ID = TALENTS_UI_IdentifyFrame(BlzGetTriggerFrame())
        TALENTS_UI_ChooseTalent(Tree_ID,Talent_ID)
        BlzFrameSetEnable(BlzGetTriggerFrame(), false)
        BlzFrameSetEnable(BlzGetTriggerFrame(), true)
    end)

    TALENTS_UI_Initialize = nil
end

function TALENTS_UI_IdentifyFrame(frame)
    for i,v in pairs(TALENTS_FRAME_CONTAINER) do
        for j,x in pairs(TALENTS_FRAME_CONTAINER[i]) do
            if x.frame == frame then
                return i,j
            end
        end
    end
end

function TALENTS_UI_Hide()
    BlzFrameSetVisible(TALENTS_FRAME_MAIN, false)
    BlzFrameSetTexture(BlzGetFrameByName("MenuBar_KnowledgeButton_FrameIcon", 0), "war3mapImported\\BTN_Menu_Knowledge.dds", 0, true)
end

function TALENTS_UI_Show()
    if not(ARENA_ACTIVATED) then
        BlzFrameSetTexture(BlzGetFrameByName("MenuBar_KnowledgeButton_FrameIcon", 0), "war3mapImported\\BTN_Menu_KnowledgePushed.dds", 0, true)
        if not(TALENTS_FRAME_MAIN) then
            TALENTS_FRAME_MAIN = BlzCreateFrame('Talents_MainFrame',  BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)
            TALENTS_BUTTON_RESET = BlzCreateFrame('Talents_TalentResetButton',TALENTS_FRAME_MAIN, 0, 0)
            TALENTS_BUTTON_CLOSE = BlzCreateFrame('Talents_TalentCloseButton',TALENTS_FRAME_MAIN, 0, 0)

            local trigger = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trigger, TALENTS_BUTTON_RESET, FRAMEEVENT_CONTROL_CLICK)
            BlzTriggerRegisterFrameEvent(trigger, TALENTS_BUTTON_CLOSE, FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trigger, function()
                local frame = BlzGetTriggerFrame()
                if frame == TALENTS_BUTTON_CLOSE then
                    TALENTS_UI_Hide()
                else
                    TALENTS_ResetAll()
                    TALENTS_UI_LoadTalents()
                end
                BlzFrameSetEnable(frame, false)
                BlzFrameSetEnable(frame, true)
            end)
        end
        local id = 0
        for i,v in ipairs(TALENTS_TABLE) do
            TALENTS_FRAME_CONTAINER[i] = TALENTS_FRAME_CONTAINER[i] or {}
            for j,x in ipairs(TALENTS_TABLE[i]) do
                if not(TALENTS_FRAME_CONTAINER[i][j]) then
                    TALENTS_FRAME_CONTAINER[i][j] = {}
                    TALENTS_FRAME_CONTAINER[i][j].backdrop = BlzCreateFrame('Talents_TalentFrame_FrameTexture',   TALENTS_FRAME_MAIN, 0, id)
                    TALENTS_FRAME_CONTAINER[i][j].tooltip = BlzCreateFrame('Talents_TooltipFrameText',   TALENTS_FRAME_CONTAINER[i][j].backdrop, 0, id)
                    TALENTS_FRAME_CONTAINER[i][j].title = BlzCreateFrame('Talents_TooltipFrameTitle',   TALENTS_FRAME_CONTAINER[i][j].backdrop, 0, id)
                    TALENTS_FRAME_CONTAINER[i][j].icon = BlzCreateFrame('Talents_TalentFrame_Icon',  TALENTS_FRAME_CONTAINER[i][j].backdrop, 0, id)
                    TALENTS_FRAME_CONTAINER[i][j].levelText = BlzCreateFrame('Talents_LevelReqText',   TALENTS_FRAME_CONTAINER[i][j].backdrop, 0, id)
                    TALENTS_FRAME_CONTAINER[i][j].frame = BlzCreateFrame('Talents_TalentFrame',  TALENTS_FRAME_CONTAINER[i][j].backdrop, 0, id)
                    BlzFrameSetPoint(TALENTS_FRAME_CONTAINER[i][j].tooltip, FRAMEPOINT_CENTER, TALENTS_FRAME_CONTAINER[i][j].backdrop, FRAMEPOINT_CENTER, 0, -0.002)
                    BlzFrameSetPoint(TALENTS_FRAME_CONTAINER[i][j].title, FRAMEPOINT_TOP, TALENTS_FRAME_CONTAINER[i][j].backdrop, FRAMEPOINT_TOP, 0, -0.004)
                    BlzFrameSetPoint(TALENTS_FRAME_CONTAINER[i][j].icon, FRAMEPOINT_LEFT, TALENTS_FRAME_CONTAINER[i][j].backdrop, FRAMEPOINT_LEFT, 0.004, 0)
                    BlzFrameSetPoint(TALENTS_FRAME_CONTAINER[i][j].levelText, FRAMEPOINT_CENTER, TALENTS_FRAME_CONTAINER[i][j].backdrop, FRAMEPOINT_CENTER, 0, 0)
                    BlzFrameSetText(TALENTS_FRAME_CONTAINER[i][j].tooltip, TALENTS_TABLE[i][j].Tooltip)
                    BlzFrameSetText(TALENTS_FRAME_CONTAINER[i][j].title, TALENTS_TABLE[i][j].Name)
                    BlzFrameSetPoint(TALENTS_FRAME_CONTAINER[i][j].frame, FRAMEPOINT_CENTER, TALENTS_FRAME_CONTAINER[i][j].backdrop, FRAMEPOINT_CENTER, 0, 0)

                    BlzFrameSetTextAlignment(TALENTS_FRAME_CONTAINER[i][j].levelText, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
                    BlzFrameSetTextAlignment(TALENTS_FRAME_CONTAINER[i][j].tooltip, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
                    
                    BlzTriggerRegisterFrameEvent(TALENTS_FRAME_TRIGGER_ENTER, TALENTS_FRAME_CONTAINER[i][j].frame, FRAMEEVENT_MOUSE_ENTER)
                    BlzTriggerRegisterFrameEvent(TALENTS_FRAME_TRIGGER_LEAVE, TALENTS_FRAME_CONTAINER[i][j].frame, FRAMEEVENT_MOUSE_LEAVE)
                    BlzTriggerRegisterFrameEvent(TALENTS_FRAME_TRIGGER_CLICK, TALENTS_FRAME_CONTAINER[i][j].frame, FRAMEEVENT_CONTROL_CLICK)
                end
                id = id + 1
            end
        end

        BlzFrameSetAbsPoint(TALENTS_FRAME_MAIN, FRAMEPOINT_TOP, 0.4, 0.595)
        BlzFrameSetVisible(TALENTS_FRAME_MAIN, true)

        local frame = TALENTS_FRAME_MAIN
        local button = TALENTS_BUTTON_RESET
        local framePoint = FRAMEPOINT_TOPRIGHT
        for i,v in ipairs(TALENTS_TABLE) do
            for j,x in ipairs(TALENTS_TABLE[i]) do
                BlzFrameSetPoint(TALENTS_FRAME_CONTAINER[i][j].backdrop, framePoint, frame, FRAMEPOINT_BOTTOM, 0, 0)
                framePoint = FRAMEPOINT_TOP
                frame = TALENTS_FRAME_CONTAINER[i][j].backdrop
                BlzFrameSetVisible(frame, true)
            end
            if button == TALENTS_BUTTON_RESET then
                BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, frame, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
                button = TALENTS_BUTTON_CLOSE
            else
                BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_BOTTOMLEFT, 0, 0)
            end
            frame = TALENTS_FRAME_MAIN
            framePoint = FRAMEPOINT_TOPLEFT
        end
        TALENTS_UI_LoadTalents()
    end
end

function TALENTS_UI_ChooseTalent(Tree_ID,Talent_ID)
    TALENTS_ChooseTalent(Tree_ID,Talent_ID)
    TALENTS_UI_LoadTalents()
end

function TALENTS_UI_Highlight(Tree_ID,Talent_ID)
    if not(TALENTS_IsEnabled(Tree_ID,Talent_ID)) and TALENTS_IsAvailable(Tree_ID,Talent_ID) then
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].backdrop, "war3mapImported\\Talents_TalentFramePushed.dds", 0, true)
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].icon, TALENTS_TABLE[Tree_ID][Talent_ID].ICON_PUSHED, 0, true)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].tooltip, 255)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].title, 255)
    end
end

function TALENTS_UI_Unhighlight(Tree_ID,Talent_ID)
    TALENTS_UI_TalentFrameSetEnable(Tree_ID,Talent_ID,TALENTS_IsFaded(Tree_ID,Talent_ID))
end

function TALENTS_UI_LoadTalents()
    for i,v in pairs(TALENTS_FRAME_CONTAINER) do
        for j,x in pairs(TALENTS_FRAME_CONTAINER[i]) do
            TALENTS_UI_TalentFrameSetEnable(i,j,TALENTS_IsFaded(i,j))
        end
    end
end

function TALENTS_UI_TalentFrameSetEnable(Tree_ID,Talent_ID,enable)
    if TALENTS_IsEnabled(Tree_ID,Talent_ID) then
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].backdrop, "war3mapImported\\Talents_TalentFrameActive.dds", 0, true)
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].icon, TALENTS_TABLE[Tree_ID][Talent_ID].ICON, 0, true)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].tooltip, 255)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].title, 255)
    elseif enable then
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].backdrop, "war3mapImported\\Talents_TalentFrame.dds", 0, true)
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].icon, TALENTS_TABLE[Tree_ID][Talent_ID].ICON, 0, true)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].tooltip, 255)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].title, 255)
    else
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].backdrop, "war3mapImported\\Talents_TalentFrameDisabled.dds", 0, true)
        BlzFrameSetTexture(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].icon, TALENTS_TABLE[Tree_ID][Talent_ID].ICON_DISABLED, 0, true)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].tooltip, 5)
        BlzFrameSetAlpha(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].title, 5)
    end
    BlzFrameSetVisible(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].levelText, not(TALENTS_IsAvailable(Tree_ID,Talent_ID)))
    BlzFrameSetText(TALENTS_FRAME_CONTAINER[Tree_ID][Talent_ID].levelText, 'Difficulties Beaten ' .. (TALENTS_TABLE[Tree_ID][Talent_ID].LevelRequired-1))
end

function TALENTS_IsFaded(Tree_ID,Talent_ID)
    local avail = true
    for i,v in pairs(TALENTS_TABLE) do
        if i ~= Tree_ID and TALENTS_TABLE[i][Talent_ID].Enabled then
            avail = false
        end
    end
    avail = avail and GetHeroLevel(HERO) >= TALENTS_TABLE[Tree_ID][Talent_ID].LevelRequired
    return avail
end

function TALENTS_IsAvailable(Tree_ID,Talent_ID)
    return GetHeroLevel(HERO) >= TALENTS_TABLE[Tree_ID][Talent_ID].LevelRequired
end

function TALENTS_IsEnabled(Tree_ID,Talent_ID)
    return TALENTS_TABLE[Tree_ID][Talent_ID].Enabled
end

function TALENTS_ChooseTalent(Tree_ID,Talent_ID)
    if TALENTS_IsAvailable(Tree_ID,Talent_ID) and not(TALENTS_IsEnabled(Tree_ID,Talent_ID)) then
        for i,v in pairs(TALENTS_TABLE) do
            if i ~= Tree_ID then
                TALENTS_DiscardTalent(i,Talent_ID)
            end    
        end
        TALENTS_ApplyTalent(Tree_ID,Talent_ID)
    end
end

function TALENTS_ResetAll()
    for x,s in pairs(TALENTS_TABLE) do
        for i,v in pairs(TALENTS_TABLE[x]) do
            TALENTS_DiscardTalent(x,i)
        end
    end
end

function TALENTS_ApplyAll()
    for x,s in pairs(TALENTS_TABLE) do
        for i,v in pairs(TALENTS_TABLE[x]) do
            TALENTS_ApplyTalent(x,i)
        end
    end
end

function TALENTS_ApplyTalent(Tree_ID,Talent_ID)
    if not(TALENTS_TABLE[Tree_ID][Talent_ID].Enabled) then
        TALENTS_TABLE[Tree_ID][Talent_ID].ApplyFunc()
        TALENTS_TABLE[Tree_ID][Talent_ID].Enabled = true
    end
end

function TALENTS_DiscardTalent(Tree_ID,Talent_ID)
    if TALENTS_TABLE[Tree_ID][Talent_ID].Enabled then
        TALENTS_TABLE[Tree_ID][Talent_ID].DiscardFunc()
        TALENTS_TABLE[Tree_ID][Talent_ID].Enabled = false
    end
end

function TALENTS_Load(hero_type)
    for h_type,t in pairs(HERO_DATA) do
        if h_type == hero_type then
            HERO_DATA[hero_type].TALENTS_registerFunc()
        else
            HERO_DATA[hero_type].TALENTS_memoryCleanFunc()
        end
    end
end

function TALENTS_Flush_Warlock()
    TALENTS_Flush_Warlock = nil
    TALENTS_Load_Warlock = nil
end

function TALENTS_Flush_Priest()
    TALENTS_Flush_Priest = nil
    TALENTS_Load_Priest = nil
end

function TALENTS_Flush_FireMage()
    TALENTS_Load_FireMage = nil
    TALENTS_Flush_FireMage = nil
end

function TALENTS_Load_Priest()
    TALENTS_TABLE = {}

    TALENTS_Flush_Priest = nil
    TALENTS_Load_Priest = nil
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
                end
                ,DiscardFunc = function()
                    AB_SetTalentsModifier(ABCODE_CHAOSBOLT,'InfusedChaos',nil)
                end
                ,Name = 'Chaos Infusion'
                ,Tooltip = 'Chaos bolt extends duration of all Fel Madness stacks\non the target by 2 seconds.'
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

----------------------------------------------------
-----------------ABILITIES_DATA---------------------
----------------------------------------------------

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
                return GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) * 5.0
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
                return GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) * 10.00
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

----------------------------------------------------
------------------HERO ANIMATIONS-------------------
----------------------------------------------------

HERO_SPELL_EFFECTS = {}

function HERO_PlayAnimation(animName,hero,time,reset)
    local h_id = GetUnitTypeId(hero)
    if HERO_DATA[h_id].anims and HERO_DATA[h_id].anims[animName] then
        if time then
            local speed = HERO_DATA[h_id].anims[animName].time
            speed = (speed == 0 and time or speed) / time
            SetUnitTimeScale(hero, speed)
            if reset then
                WaitAndDo(time,HERO_ResetAnimation,hero) 
            end
        else
            SetUnitTimeScale(hero, 1.0)
        end
        SetUnitAnimationByIndex(hero, HERO_DATA[h_id].anims[animName].id)
    end
end

function HERO_ResetAnimation(hero)
    SetUnitTimeScale(hero, 1.0)
    ResetUnitAnimation(hero)
end

function HERO_AddSpellEffectTarget(where,unit,effect,scale)
    local eff = oldAddEffect(where,unit,effect)
    BlzSetSpecialEffectScale(eff, scale or BlzGetSpecialEffectScale(eff))
    table.insert(HERO_SPELL_EFFECTS,eff)
    return eff
end

function HERO_DestroySpellEffects()
    for i = #HERO_SPELL_EFFECTS,1,-1 do
        DestroyEffect(HERO_SPELL_EFFECTS[i])
        table.remove(HERO_SPELL_EFFECTS,i)
    end
end

function HERO_PolishedAbilities_Register()
    local trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trg, Condition(HERO_IsCastingUnit))
    TriggerAddAction(trg, HERO_PolishedAbilities_Cast)

    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trg, Condition(HERO_IsCastingUnit))
    TriggerAddAction(trg, HERO_PolishedAbilities_Stop)

    trg = nil
    HERO_PolishedAbilities_Register = nil
end

function HERO_PolishedAbilities_Cast()
    local unit,abCode = GetTriggerUnit(),GetSpellAbilityId()
    local time = BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, abCode), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(unit, abCode)-1)
    time = time == 9000 and nil or time
    if abCode == ABCODE_PYROBLAST then
        HERO_PlayAnimation('A_SPELL_CINEMATIC',unit,time)
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
    elseif abCode == ABCODE_BOLTSOFPHOENIX then
        HERO_PlayAnimation('A_SPELL_CHANNEL',unit,time)
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
    elseif abCode == ABCODE_PURGINGFLAMES then
        HERO_PlayAnimation('A_SPELL',unit,time)
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
    elseif abCode == ABCODE_SCORCH then
        HERO_PlayAnimation('A_SPELL_CHANNEL',unit)
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
    elseif abCode == ABCODE_ORBOFFIRE then
        HERO_PlayAnimation('A_SPELL_SLAM',unit,time)
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl',0.6)
    elseif abCode == ABCODE_HOLYBOLT then
        HERO_PlayAnimation('A_SPELL_CHANNEL_HAND',unit)
    elseif abCode == ABCODE_SACREDCURSE then
        HERO_PlayAnimation('A_SPELL_CHANNEL_HAND',unit)
    elseif abCode == ABCODE_PENANCE then
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Weapons\\PriestMissile\\PriestMissile.mdl',1.5)
    elseif abCode == ABCODE_HOLYNOVA then
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Weapons\\PriestMissile\\PriestMissile.mdl',1.5)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Weapons\\PriestMissile\\PriestMissile.mdl',1.5)
    elseif abCode == ABCODE_PURIFY then
        HERO_PlayAnimation('A_SPELL_CHANNEL_FINISH',unit,time)
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Weapons\\PriestMissile\\PriestMissile.mdl',1.5)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Weapons\\PriestMissile\\PriestMissile.mdl',1.5)
    elseif abCode == ABCODE_CHAOSBOLT then
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl',0.4)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl',0.4)
        HERO_PlayAnimation('A_SPELL_CHANNEL_BOTH',unit)
    elseif abCode == ABCODE_LIFEDRAIN then
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl',0.4)
    elseif abCode == ABCODE_FELMADNESS then
        HERO_AddSpellEffectTarget('left hand',unit,'Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl',0.4)
        HERO_AddSpellEffectTarget('right hand',unit,'Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl',0.4)
        HERO_PlayAnimation('A_SPELL_CHANNEL_BOTH',unit)
    end
end

function HERO_PolishedAbilities_Stop()
    local unit,abcode = GetTriggerUnit(),GetSpellAbilityId()
    HERO_DestroySpellEffects()
    SetUnitTimeScale(unit, 1.0)
    if abcode == ABCODE_CHAOSBOLT or abcode == ABCODE_FELMADNESS then
        HERO_PlayAnimation('A_SPELL_THROW',HERO,0.5,true)
    end
end

function HERO_IsCastingUnit()
    return GetTriggerUnit() == HERO
end

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

    HERO_DATA[HERO_PRIEST] = {
        CreateFunc = CreatePriest
        ,AB_memoryCleanFunc = AB_Priest_MemoryClear
        ,AB_registerFunc = AB_RegisterHero_Priest
        ,TALENTS_registerFunc = TALENTS_Load_Priest
        ,TALENTS_memoryCleanFunc = TALENTS_Flush_Priest
        ,UI_registerFunc = UI_Priest
        ,UI_memoryCleanFunc = UI_PriestFlush
        ,ReadyUpFunc = ReadyUp_Priest
        ,anims = {
            A_STAND_1 = {id = 0,time = 0}
            ,A_STAND_2 = {id = 1,time = 4.5}
            ,A_WALK = {id = 2,time = 0}
            ,A_TALK = {id = 3,time = 2.0}
            ,A_SPELL_CHANNEL = {id = 4,time = 0}
            ,A_SPELL_CHANNEL_FINISH = {id = 5,time = 0.9}
            ,A_SPELL_CHANNEL_SUMMON = {id = 6,time = 0}
            ,A_SPELL_CHANNEL_HAND = {id = 7,time = 0}
            ,A_ATTACK = {id = 8,time = 1.0}
            ,A_SPELL_CHANNEL_POINTING = {id = 9, time = 0}
            ,A_DEATH = {id = 10,time = 4.17}
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

    HERO_DATA[HERO_WARLOCK] = {
        CreateFunc = CreateWarlock
        ,AB_memoryCleanFunc = AB_Warlock_MemoryClear
        ,AB_registerFunc = AB_RegisterHero_Warlock
        ,TALENTS_registerFunc = TALENTS_Load_Warlock
        ,TALENTS_memoryCleanFunc = TALENTS_Flush_Warlock
        ,UI_registerFunc = UI_Warlock
        ,UI_memoryCleanFunc = UI_WarlockFlush
        ,ReadyUpFunc = ReadyUp_Warlock
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


    HERODATA_Load = nil

    HERO_PolishedAbilities_Register()
end

function ReadyUp_FireMage()
    AB_FireMage_RemoveFireOrbsAll(HERO)
    AB_FireMage_RemoveOrbsOfFire_All()
end

function ReadyUp_Priest()
    UNIT_SetEnergy(HERO,0.0)
end

function ReadyUp_Warlock()
    UNIT_SetEnergy(HERO,0.0)
    AB_Warlock_RemoveCursedSoils_All()
    AB_Warlock_ChaosBolt_DestroyAllOrbs()
    SILENCE_silenceAbility(HERO,ABCODE_CHAOSBOLT,'noenergy')
    SILENCE_silenceAbility(HERO,ABCODE_LIFEDRAIN,'nopower')
    SILENCE_silenceAbility(HERO,ABCODE_FELMADNESS,'nopower')
end

START_X,START_Y = -14080.0,-14870.0

function CreateWarlock()
    HERO = UNIT_Create(PLAYER, HERO_WARLOCK, START_X, START_Y, 270.00,true)
    HERO_TYPE = HERO_WARLOCK

    MISSLE_TRIGGERS[ABCODE_SHADOWBOLTS] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_SHADOWBOLTS], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_SHADOWBOLTS])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_SHADOWBOLTS], AB_Warlock_ShadowBoltsMissleFly)

    MISSLE_GROUPS[ABCODE_SHADOWBOLTS] = {}

    MISSLE_TRIGGERS[ABCODE_CHAOSBOLT] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_CHAOSBOLT], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_CHAOSBOLT])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_CHAOSBOLT], AB_Warlock_ChaosBoltMissleFly)

    MISSLE_GROUPS[ABCODE_CHAOSBOLT] = {}

    MISSLE_TRIGGERS[ABCODE_LIFEDRAIN] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_LIFEDRAIN], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_LIFEDRAIN])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_LIFEDRAIN], AB_Warlock_LifeDrainMissleFly)

    MISSLE_GROUPS[ABCODE_LIFEDRAIN] = {}

    MISSLE_TRIGGERS[ABCODE_CURSEDSOIL] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_CURSEDSOIL], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_CURSEDSOIL])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_CURSEDSOIL], AB_Warlock_CursedSoil_Blasting)

    MISSLE_GROUPS[ABCODE_CURSEDSOIL] = {}

    MISSLE_TRIGGERS['cb_Orbs'] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS['cb_Orbs'], 0.02)
    DisableTrigger(MISSLE_TRIGGERS['cb_Orbs'])
    TriggerAddAction(MISSLE_TRIGGERS['cb_Orbs'], AB_Warlock_ChaosBolt_OrbCharging)

    MISSLE_GROUPS['cb_Orbs'] = {}

    UI_Load(HERO_WARLOCK)
    AB_RegisterHero(HERO_WARLOCK)
    TALENTS_Load(HERO_WARLOCK)

    BlzFrameSetTexture(BlzGetFrameByName("Hero_PortraitTexture", 0), 'war3mapImported\\Warlock_Portrait.dds', 0, true)

    SILENCE_silenceAbility(HERO,ABCODE_CHAOSBOLT,'noenergy')
    SILENCE_silenceAbility(HERO,ABCODE_LIFEDRAIN,'nopower')
    SILENCE_silenceAbility(HERO,ABCODE_FELMADNESS,'nopower')
    
    TT_SelectHero()

    UNIT_SetEnergyCap(HERO,100.0)
    UNIT_SetEnergy(HERO,0.0)
    UNIT_SetEnergyTheme(HERO,DBM_BAR_clDARKGREEN)

    MapSetup_AfterHero()
    CreateWarlock = nil
end

function CreatePriest()
    HERO = UNIT_Create(PLAYER, HERO_PRIEST, START_X, START_Y, 270.00,true)
    HERO_TYPE = HERO_PRIEST

    MISSLE_TRIGGERS[ABCODE_PENANCE] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_PENANCE], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_PENANCE])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_PENANCE], AB_Priest_PenanceMissleFly)

    MISSLE_GROUPS[ABCODE_PENANCE] = {}

    UI_Load(HERO_PRIEST)
    AB_RegisterHero(HERO_PRIEST)
    TALENTS_Load(HERO_PRIEST)

    BlzFrameSetTexture(BlzGetFrameByName("Hero_PortraitTexture", 0), 'war3mapImported\\Priest_Portrait.dds', 0, true)

    TT_SelectHero()

    UNIT_SetEnergyCap(HERO,15000.0)
    UNIT_SetEnergy(HERO,0.0)
    UNIT_SetEnergyTheme(HERO,DBM_BAR_clGOLD)

    MapSetup_AfterHero()
    CreatePriest = nil
end

function CreateFireMage()
    HERO = UNIT_Create(PLAYER, HERO_FIREMAGE, START_X, START_Y, 270.00,true)
    HERO_TYPE = HERO_FIREMAGE

    MISSLE_TRIGGERS[ABCODE_PYROBLAST] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_PYROBLAST], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_PYROBLAST])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_PYROBLAST], AB_FireMage_PyroblastMissleFly)
    
    MISSLE_TRIGGERS[ABCODE_ORBS] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_ORBS], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_ORBS])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_ORBS], AB_FireOrbsMissleFly)

    MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIXCASTTIME] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIXCASTTIME], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIXCASTTIME])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIXCASTTIME], AB_FireMage_BoltsOfPhoenix_Channeling)

    MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIX] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIX], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIX])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_BOLTSOFPHOENIX], AB_FireMage_BoltsOfPhoenix_MissleFly)

    MISSLE_TRIGGERS[ABCODE_AUTOATTACK] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_AUTOATTACK], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_AUTOATTACK])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_AUTOATTACK], AB_FireMage_AutoAttack_MissleFly)

    MISSLE_TRIGGERS[ABCODE_ORBOFFIRE] = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(MISSLE_TRIGGERS[ABCODE_ORBOFFIRE], 0.02)
    DisableTrigger(MISSLE_TRIGGERS[ABCODE_ORBOFFIRE])
    TriggerAddAction(MISSLE_TRIGGERS[ABCODE_ORBOFFIRE], AB_FireMage_OrbOfFire_Blasting)

    MISSLE_GROUPS[ABCODE_ORBS] = {}
    MISSLE_GROUPS[ABCODE_PYROBLAST] = {}
    MISSLE_GROUPS[ABCODE_BOLTSOFPHOENIX] = {}
    MISSLE_GROUPS[ABCODE_AUTOATTACK] = {}
    MISSLE_GROUPS[ABCODE_ORBOFFIRE] = {}

    UI_Load(HERO_FIREMAGE)
    AB_RegisterHero(HERO_FIREMAGE)
    TALENTS_Load(HERO_FIREMAGE)

    SILENCE_silenceAbility(HERO,ABCODE_BOLTSOFPHOENIX,'noorbs')
    TT_SelectHero()

    MapSetup_AfterHero()
    CreateFireMage = nil
end

----------------------------------------------------
------------------UI TOOLTIPING---------------------
----------------------------------------------------

TOOLTIP_DATA = {}
TOOLTIP_TRIGGER = CreateTrigger()
TOOLTIP_FRAMES = nil

TOOLTIP_TYPE_ABILITY = 'ability'
TOOLTIP_TYPE_BUFF = 'buff'
TOOLTIP_TYPE_STAT = 'stat'


function TOOLTIP_RegisterTooltiping()
    for i,v in pairs(TOOLTIP_DATA) do
        BlzFrameSetTooltip(v.frame, v.tooltip)
    end
    TriggerRegisterTimerEventPeriodic(TOOLTIP_TRIGGER, 0.1)
    TriggerAddAction(TOOLTIP_TRIGGER, function()
        local tooltiped = false
        for i,v in pairs(TOOLTIP_DATA) do
            tooltiped = tooltiped or BlzFrameIsVisible(v.tooltip)
            if BlzFrameIsVisible(v.tooltip) and not(v.tooltiped) then
                TOOLTIP_HideAll()
                TOOLTIP_Load(v.type,v.id)
                v.tooltiped = true
            elseif not(BlzFrameIsVisible(v.tooltip)) then
                v.tooltiped = false
            end
        end
        if not(tooltiped) then
            TOOLTIP_HideAll()
        end
    end)
    TOOLTIP_FRAMES = {
        ability = {
            mainFrame = BlzCreateFrame('Tooltip_Ability', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0,0)
        }
    }
    TOOLTIP_FRAMES.ability.Title = BlzGetFrameByName('Tooltip_AbilityTitle', 0)
    TOOLTIP_FRAMES.ability.Text = BlzGetFrameByName('Tooltip_AbilityText', 0)
    TOOLTIP_FRAMES.ability.TextData = BlzGetFrameByName('Tooltip_AbilityTextData', 0)
    BlzFrameSetAbsPoint(TOOLTIP_FRAMES.ability.mainFrame, FRAMEPOINT_BOTTOM, 0.4, UI_TOOLTIP_ABILITY_Y)
    
    UI_TOOLTIP_ABILITY_Y = nil
    TOOLTIP_RegisterTooltiping = nil
end

function TOOLTIP_HideAll()
    for i,v in pairs(TOOLTIP_FRAMES) do
        BlzFrameSetVisible(v.mainFrame, false)
    end
end

function TOOLTIP_RegisterTooltip(frame,type,id,alt)
    local tooltip = alt and BlzCreateFrame('Tooltip_Visibler_Alt', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, #TOOLTIP_DATA) or BlzCreateSimpleFrame('Tooltip_Visibler', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), #TOOLTIP_DATA)
    BlzFrameSetVisible(tooltip, false)
    table.insert(TOOLTIP_DATA,{
        frame = frame
        ,tooltip = tooltip
        ,type = type
        ,id = id
        ,tooltiped = false
    })
    tooltip = nil
end

function TOOLTIP_Load(type,id)
    local sub_id,_ = type:gsub('[a-z]', '')
    type,_ = type:gsub('[0-9]', '')
    if type == TOOLTIP_TYPE_ABILITY then
        BlzFrameSetVisible(TOOLTIP_FRAMES[type].mainFrame, true)
        BlzFrameSetText(TOOLTIP_FRAMES[type].Text, TOOLTIP_InjectParams(BlzGetAbilityExtendedTooltip(UI_ABILITIES[id].abCode, 0),id,type))
        BlzFrameSetText(TOOLTIP_FRAMES[type].Title, TOOLTIP_InjectParams(BlzGetAbilityTooltip(UI_ABILITIES[id].abCode, 0),id,type))
        BlzFrameSetText(TOOLTIP_FRAMES[type].TextData, TOOLTIP_InjectParams(BlzGetAbilityActivatedExtendedTooltip(UI_ABILITIES[id].abCode, 0),id,type))
    end
end

function TOOLTIP_InjectParams(text,id,type)
    if type == 'ability' then
        text,_ = text:gsub("AB_NAME",ABILITIES_DATA[UI_ABILITIES[id].abCode].Name)
        text,_ = text:gsub("AB_RANGE",ABILITIES_DATA[UI_ABILITIES[id].abCode].Range or '')
        text,_ = text:gsub("AB_COLDOWN",ABILITIES_DATA[UI_ABILITIES[id].abCode].Cooldown or '0.0')
        text,_ = text:gsub("AB_DAMAGEDOT",ABILITIES_DATA[UI_ABILITIES[id].abCode].getDamageDOT and ABILITIES_DATA[UI_ABILITIES[id].abCode].getDamageDOT(HERO) or '')
        text,_ = text:gsub("AB_AOE",ABILITIES_DATA[UI_ABILITIES[id].abCode].AOE or '')
        text,_ = text:gsub("AB_DAMAGEFAC",UNIT_GetDmgFactor(HERO,UI_ABILITIES[id].abCode) * 100 or '')
        text,_ = text:gsub("AB_DAMAGE",ABILITIES_DATA[UI_ABILITIES[id].abCode].getDamage and ABILITIES_DATA[UI_ABILITIES[id].abCode].getDamage(HERO) * UNIT_GetDmgFactor(HERO,UI_ABILITIES[id].abCode) or '')
        text,_ = text:gsub("AB_IMPACTDAMAGE",ABILITIES_DATA[UI_ABILITIES[id].abCode].getImpactDamage and ABILITIES_DATA[UI_ABILITIES[id].abCode].getImpactDamage(HERO) * UNIT_GetDmgFactor(HERO,UI_ABILITIES[id].abCode) or '')
        text,_ = text:gsub("AB_DURATIONDEF", strRound(ABILITIES_DATA[UI_ABILITIES[id].abCode].getDurationDeff and ABILITIES_DATA[UI_ABILITIES[id].abCode].getDurationDeff() or '',1))
        text,_ = text:gsub("AB_SLOW_MS",strRound(ABILITIES_DATA[UI_ABILITIES[id].abCode].getSlow_ms and ABILITIES_DATA[UI_ABILITIES[id].abCode].getSlow_ms() or '',1))
        text,_ = text:gsub("AB_RESIST", strRound(ABILITIES_DATA[UI_ABILITIES[id].abCode].getResistFactor and ABILITIES_DATA[UI_ABILITIES[id].abCode].getResistFactor() or '',1))
        text,_ = text:gsub("AB_MAXSTACKS", ABILITIES_DATA[UI_ABILITIES[id].abCode].getMaxStacks and ABILITIES_DATA[UI_ABILITIES[id].abCode].getMaxStacks() or '')
        text,_ = text:gsub("AB_HEALFACTOR",ABILITIES_DATA[UI_ABILITIES[id].abCode].HealFactor and ABILITIES_DATA[UI_ABILITIES[id].abCode].HealFactor * 100 or '')
        text,_ = text:gsub("AB_STATFACTORINT", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'stat_factor_int',-1,100),0))
        text,_ = text:gsub("AB_CASTTIMEFACTOR", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'casttime_factor',-1,-100),0))
        text,_ = text:gsub("AB_ATTACKSPEEDFACTOR", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'attackspeed_factor',-1,100),0))
        text,_ = text:gsub("AB_MOVESPEEDFACTOR", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'movespeed_factor',-1,100),0))
        text,_ = text:gsub("AB_STATCONSTANTAGI", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'stat_constant_agi',0),0))
        text,_ = text:gsub("AB_DURATION", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'duration',0),1))
        text,_ = text:gsub("AB_SPELLDURATION", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'spell_duration',0),1))
        text,_ = text:gsub("AB_SPELLTICK", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'spell_tick',0),1))
        text,_ = text:gsub("AB_SPELLCOUNTTICK", strRound(TOOLTIP_GetDebuffData(UI_ABILITIES[id].abCode,'spell_tick_count',0),1))
        text,_ = text:gsub("AB_CASTTIME",TOOLTIP_GetCastTime(UI_ABILITIES[id].abCode,HERO))
    end
    return text
end

function TOOLTIP_GetDebuffData(abCode,key,inc,mult,decpl)
    inc,mult,decpl = inc or 1,mult or 1,decpl or 1
    local val = ABILITIES_DATA[abCode][key] and ABILITIES_DATA[abCode][key]() or (ABILITIES_DATA[abCode].debuff and DEBUFFS_DATA[ABILITIES_DATA[abCode].debuff][key] or (inc * -1))
    val = (val + inc) * mult
    return round(val,decpl)
end

function TOOLTIP_GetCastTime(id,unit)
    id = ABILITIES_DATA[id].castAbility or id
    local text = strRound(UNIT_GetAbilityCastingTime(id,unit),2)
    return text == '0.00' and 'Instant' or text
end

----------------------------------------------------
--------------------UI SETUP------------------------
----------------------------------------------------

UI_SHORTCUT_1 = 1
UI_SHORTCUT_2 = 2
UI_SHORTCUT_3 = 3
UI_SHORTCUT_4 = 4
UI_SHORTCUT_5 = 5
UI_SHORTCUT_6 = 6
UI_SHORTCUT_7 = 7
UI_SHORTCUT_8 = 8
UI_SHORTCUT_9 = 9
UI_SHORTCUT_0 = 10
UI_SHORTCUT_Q = 11
UI_SHORTCUT_W = 12
UI_SHORTCUT_E = 13
UI_SHORTCUT_R = 14
UI_SHORTCUT_Z = 15
UI_SHORTCUT_X = 16
UI_SHORTCUT_C = 17
UI_SHORTCUT_V = 18

UI_ABILITIES = {
    [UI_SHORTCUT_1] = {OS_Key = ConvertOsKeyType(49)}
    ,[UI_SHORTCUT_2] = {OS_Key = ConvertOsKeyType(50)}
    ,[UI_SHORTCUT_3] = {OS_Key = ConvertOsKeyType(51)}
    ,[UI_SHORTCUT_4] = {OS_Key = ConvertOsKeyType(52)}
    ,[UI_SHORTCUT_5] = {OS_Key = ConvertOsKeyType(53)}
    ,[UI_SHORTCUT_6] = {OS_Key = ConvertOsKeyType(54)}
    ,[UI_SHORTCUT_7] = {OS_Key = ConvertOsKeyType(55)}
    ,[UI_SHORTCUT_8] = {OS_Key = ConvertOsKeyType(56)}
    ,[UI_SHORTCUT_9] = {OS_Key = ConvertOsKeyType(57)}
    ,[UI_SHORTCUT_0] = {OS_Key = ConvertOsKeyType(58)}
    ,[UI_SHORTCUT_Q] = {OS_Key = OSKEY_Q}
    ,[UI_SHORTCUT_W] = {OS_Key = OSKEY_W}
    ,[UI_SHORTCUT_E] = {OS_Key = OSKEY_E}
    ,[UI_SHORTCUT_R] = {OS_Key = OSKEY_R}
    ,[UI_SHORTCUT_Z] = {OS_Key = OSKEY_Z}
    ,[UI_SHORTCUT_X] = {OS_Key = OSKEY_X}
    ,[UI_SHORTCUT_C] = {OS_Key = OSKEY_C}
    ,[UI_SHORTCUT_V] = {OS_Key = OSKEY_V}
}

UI_ABILITIES_TRIGGER_USE = nil
UI_ABILITIES_TRIGGER_FOCUS = CreateTrigger()
UI_PLAYER_CASTING = nil

UI_STAT_DMG = 1
UI_STAT_POWER = 2
UI_STAT_CRIT = 3
UI_STAT_RESIST = 4

UI_BUFF_COUNT = 9

UI_FOCUSBUG_TRIGGER = CreateTrigger()

BUFF_DEFAULT_TEXTURE = 'war3mapImported\\BTN_EmptyBuff.dds'

function UI_FixFocusBug()
    BlzTriggerRegisterFrameEvent(UI_FOCUSBUG_TRIGGER, BlzGetFrameByName("MenuBar_KnowledgeButton_Frame_Button", 0), FRAMEEVENT_CONTROL_CLICK)
    BlzTriggerRegisterFrameEvent(UI_FOCUSBUG_TRIGGER, BlzGetFrameByName("MenuBar_StatsButton_Frame_Button", 0), FRAMEEVENT_CONTROL_CLICK)
    BlzTriggerRegisterFrameEvent(UI_FOCUSBUG_TRIGGER, BlzGetFrameByName("MenuBar_InfoButton_Frame_Button", 0), FRAMEEVENT_CONTROL_CLICK)

    TriggerAddAction(UI_FOCUSBUG_TRIGGER, function()
        if BlzFrameGetEnable(BlzGetTriggerFrame()) then
            BlzFrameSetEnable(BlzGetTriggerFrame(), false)
            BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        end
    end)
    UI_FixFocusBug = nil
end

function UI_HideOriginalUI()
    UI_HideOriginalFrames()
    UI_HideOriginalFrames = nil
    UI_HideOriginalUI = nil
end

function UI_HideOriginalFrames()
    BlzHideOriginFrames(true)
    BlzFrameSetVisible(BlzGetFrameByName("ConsoleUIBackdrop",0), false)
    BlzFrameSetScale(BlzGetFrameByName("ConsoleUI", 0), 0.001)
    BlzEnableUIAutoPosition(false)
end

function UI_HideAllMenus()
    TALENTS_UI_Hide()
    BOSS_HideJournal()
end

function UI_Load(hero_type)
    for h_type,t in pairs(HERO_DATA) do
        if h_type == hero_type then
            HERO_DATA[h_type].UI_registerFunc()
        else
            HERO_DATA[h_type].UI_memoryCleanFunc()
        end
    end
    UI_LoadAbilityTrigger_Focus()
    UI_LoadHeroStatistics()
    UI_CreateTargetDetails()
    UI_CreateHeroDetails()
    UI_InitializeRefreshDetails()
    UI_CreatePopUps(hero_type)
    UI_Load = nil
end

UI_POPUPS = {}

function UI_CreatePopUps(hero_type)
    if HERO_DATA[hero_type].PopUps then
        for i,v in pairs(HERO_DATA[hero_type].PopUps) do
            local popUp = BlzCreateSimpleFrame('Ability_PopUp', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), i) 
            BlzFrameSetTexture(BlzGetFrameByName('Ability_PopUpTexture', i), v.texture, 0, true)
            if v.hideFunc and v.showFunc then
                UI_POPUPS[v.key or i] = {
                    popUp = popUp
                    ,hideFunc = v.hideFunc
                    ,showFunc = v.showFunc
                    ,inc = 1
                }
                BlzFrameSetVisible(popUp, false)
            else
                BlzDestroyFrame(popUp)
            end
            popUp = nil
        end
        UI_RegisterPopUps()
    end
    UI_RegisterPopUps = nil
    UI_CreatePopUps = nil
end

function UI_RegisterPopUps()
    local trig = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(trig, 0.1)
    TriggerAddAction(trig,UI_RefreshPopUps)

    trig = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(trig, 0.01)
    TriggerAddAction(trig,UI_GlowingPopUps)

    trig = nil
end

function UI_GlowingPopUps()
    for i,v in pairs(UI_POPUPS) do
        if BlzFrameIsVisible(v.popUp) then
            local alpha = BlzFrameGetAlpha(v.popUp)
            v.inc = (alpha <= 10 or alpha == 255) and v.inc * (-1) or v.inc
            BlzFrameSetAlpha(v.popUp, alpha + v.inc)
        end
    end
end

function UI_RefreshPopUps()
    local c,x,y = 0,0.4,0.5
    for i,v in pairs(UI_POPUPS) do
        if v.showFunc() and not(BlzFrameIsVisible(v.popUp)) then
            v.inc = 3
            BlzFrameSetVisible(v.popUp, true)
            x = x - (BlzFrameGetWidth(v.popUp)/2)
            c = c + 1
        elseif v.hideFunc() and BlzFrameIsVisible(v.popUp) then
            BlzFrameSetVisible(v.popUp, false)
        end
    end
    if c > 0 then
        for i,v in pairs(UI_POPUPS) do
            if BlzFrameIsVisible(v.popUp) then
                BlzFrameClearAllPoints(v.popUp)
                BlzFrameSetAbsPoint(v.popUp, FRAMEPOINT_LEFT, x, y)
                x = x + BlzFrameGetWidth(v.popUp)
            end
        end
    end
    c,x,y = nil,nil,nil
end

HERO_DETAILS_DATA = nil
TARGET_DETAILS_DATA = nil

function UI_InitializeRefreshDetails()
    local trg = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(trg, 0.1)
    TriggerAddAction(trg, UI_RefreshDetails)
    trg = nil
    UI_InitializeRefreshDetails = nil
end

function UI_RefreshIcons(unit)
    if unit == HERO then
        BlzFrameSetTexture(HERO_DETAILS_DATA.stats.stat_powerTexture, ATTRIBUTES[Get_UnitPrimaryAttribute(HERO)].icon or ATTRIBUTE_UNDEFINED_ICON, 0, true)
        BlzFrameSetTexture(HERO_DETAILS_DATA.unitIconTexture, UNITS_DATA[GetUnitTypeId(HERO)].ICON, 0, true)
    else
        BlzFrameSetTexture(TARGET_DETAILS_DATA.stats.stat_powerTexture, ATTRIBUTES[Get_UnitPrimaryAttribute(TARGET)].icon or ATTRIBUTE_UNDEFINED_ICON, 0, true)
        BlzFrameSetTexture(TARGET_DETAILS_DATA.unitIconTexture, UNITS_DATA[GetUnitTypeId(TARGET)].ICON, 0, true)
    end
end

function UI_RefreshDetails()
    if TARGET then
        if not(BlzFrameIsVisible(TARGET_DETAILS_DATA.mainFrame)) then
            BlzFrameSetVisible(TARGET_DETAILS_DATA.mainFrame, true)
        end

        local te = UNIT_GetEnergy(TARGET)
        local te_c = UNIT_GetEnergyCap(TARGET)
        local te_t = UNIT_GetEnergyTheme(TARGET)

        if te_c then
            if not(BlzFrameIsVisible(TARGET_DETAILS_DATA.energy_frame)) then
                BlzFrameSetVisible(TARGET_DETAILS_DATA.energy_frame, true)
            end
            UI_EnergyBar_ChangeTheme_Target(te_t)
            BlzFrameSetValue(TARGET_DETAILS_DATA.energy_bar, tostring((te / te_c) * 100))
            BlzFrameSetText(TARGET_DETAILS_DATA.energy_bar_value_text, tostring(math.floor(te))..'/'..tostring(math.floor(te_c)))
        else    
            if BlzFrameIsVisible(TARGET_DETAILS_DATA.energy_frame) then
                BlzFrameSetVisible(TARGET_DETAILS_DATA.energy_frame, false)
            end
        end

        te,te_c,te_t = nil,nil,nil

        BlzFrameSetValue(TARGET_DETAILS_DATA.bar, GetUnitLifePercent(TARGET))
        BlzFrameSetText(TARGET_DETAILS_DATA.unitNameText, GetUnitName(TARGET))
        BlzFrameSetText(TARGET_DETAILS_DATA.unitHPText, tostring(math.floor(GetUnitStateSwap(UNIT_STATE_LIFE, TARGET)))..'/'..tostring(math.floor(GetUnitStateSwap(UNIT_STATE_MAX_LIFE, TARGET))))
        BlzFrameSetText(TARGET_DETAILS_DATA.unitRegText, strRound(GetUnitLifePercent(TARGET),1) .. '%%'.. ' (' .. BlzGetUnitRealField(TARGET, UNIT_RF_HIT_POINTS_REGENERATION_RATE)..'/sec)')

        BlzFrameSetText(TARGET_DETAILS_DATA.stats.stat_powerText,GetHeroStatBJ(ATTRIBUTES[Get_UnitPrimaryAttribute(TARGET)].stat, TARGET, true))
        BlzFrameSetText(TARGET_DETAILS_DATA.stats.stat_critText,Get_UnitCritRate(TARGET)..'%%')
        BlzFrameSetText(TARGET_DETAILS_DATA.stats.stat_resistText,math.floor(BlzGetUnitArmor(TARGET))..'%%')
        BlzFrameSetText(TARGET_DETAILS_DATA.stats.stat_dmgText,Get_UnitBaseDamage(TARGET))

        UI_RefreshBuffs(TARGET,TARGET_DETAILS_DATA.buffs)
    end
    --HERO

    local e = UNIT_GetEnergy(HERO)
    local e_c = UNIT_GetEnergyCap(HERO)
    local e_t = UNIT_GetEnergyTheme(HERO)

    if e_c then
        if not(BlzFrameIsVisible(HERO_DETAILS_DATA.energy_frame)) then
            BlzFrameSetVisible(HERO_DETAILS_DATA.energy_frame, true)
        end
        UI_EnergyBar_ChangeTheme_Hero(e_t)
        BlzFrameSetValue(HERO_DETAILS_DATA.energy_bar, tostring((e / e_c) * 100))
        BlzFrameSetText(HERO_DETAILS_DATA.energy_bar_value_text, tostring(math.floor(e))..'/'..tostring(math.floor(e_c)))
    else    
        if BlzFrameIsVisible(HERO_DETAILS_DATA.energy_frame) then
            BlzFrameSetVisible(HERO_DETAILS_DATA.energy_frame, false)
        end
    end

    e,e_c,e_t = nil,nil,nil

    BlzFrameSetValue(HERO_DETAILS_DATA.bar, GetUnitLifePercent(HERO))
    BlzFrameSetText(HERO_DETAILS_DATA.unitNameText, GetUnitName(HERO))
    BlzFrameSetText(HERO_DETAILS_DATA.unitHPText, tostring(math.floor(GetUnitStateSwap(UNIT_STATE_LIFE, HERO)))..'/'..tostring(math.floor(GetUnitStateSwap(UNIT_STATE_MAX_LIFE, HERO))))
    BlzFrameSetText(HERO_DETAILS_DATA.unitRegText, strRound(GetUnitLifePercent(HERO),1) .. '%%'.. ' (' .. BlzGetUnitRealField(HERO, UNIT_RF_HIT_POINTS_REGENERATION_RATE)..'/sec)')

    BlzFrameSetText(HERO_DETAILS_DATA.stats.stat_powerText,GetHeroStatBJ(ATTRIBUTES[Get_UnitPrimaryAttribute(HERO)].stat, HERO, true))
    BlzFrameSetText(HERO_DETAILS_DATA.stats.stat_critText,Get_UnitCritRate(HERO)..'%%')
    BlzFrameSetText(HERO_DETAILS_DATA.stats.stat_resistText,math.floor(BlzGetUnitArmor(HERO))..'%%')
    BlzFrameSetText(HERO_DETAILS_DATA.stats.stat_dmgText,Get_UnitBaseDamage(HERO))

    UI_RefreshBuffs(HERO,HERO_DETAILS_DATA.buffs)
end

function UI_EnergyBar_ChangeTheme_Hero(theme)
    theme = theme.texture and theme or DBM_BAR_clGRAY
    BlzFrameSetTexture(HERO_DETAILS_DATA.energy_bar, theme.texture, 0, true)
    BlzFrameSetTextColor(HERO_DETAILS_DATA.energy_bar_value_text, theme.fontColor)
end

function UI_EnergyBar_ChangeTheme_Target(theme)
    theme = theme.texture and theme or DBM_BAR_clGRAY
    BlzFrameSetTexture(TARGET_DETAILS_DATA.energy_bar, theme.texture, 0, true)
    BlzFrameSetTextColor(TARGET_DETAILS_DATA.energy_bar_value_text, theme.fontColor)
end

function UI_RefreshBuffs(unit,frames)
    local Buff_Tbl = {}
    for i,v in pairs(DEBUFFS) do
        if v.target == unit and not(IsInArray_CustField(v.name,Buff_Tbl,'name')) then
            local tbl = {
                ['name'] = v.name
                ,stackCount = BUFF_GetStacksCount(unit,v.name)
                ,priority = v.debuffPriority
                ,isDebuff = v.isDebuff
                ,txtColor = v.txtColor or DEBUFFS_DEFAULT_TEXT_COLOR
                ,ICON = v.ICON
            }
            table.insert(Buff_Tbl,tbl)
            tbl = nil
        end
    end
    table.sort (Buff_Tbl, function (k1, k2) return k1.priority < k2.priority end )
    local c = 1
    for i,v in pairs(Buff_Tbl) do
        if c <= UI_BUFF_COUNT and v.ICON then
            BlzFrameSetTexture(frames[c].buffTexture, v.ICON, 0, true)
            BlzFrameSetTextColor(frames[c].buffText, v.txtColor)
            BlzFrameSetText(frames[c].buffText, v.stackCount > 1 and I2S(v.stackCount) or '')
            if not(BlzFrameIsVisible(frames[c].buffFrame)) then
                BlzFrameSetVisible(frames[c].buffFrame, true)
            end
            c = c + 1
        end
    end

    if c < UI_BUFF_COUNT then
        for i = c,UI_BUFF_COUNT do
            if BlzFrameIsVisible(frames[i].buffFrame) then
                BlzFrameSetVisible(frames[i].buffFrame, false)
            end
        end
    end
    Buff_Tbl,c = nil,nil
end

function UI_CreateTargetDetails()
    local fw,fh = UI_GetAbilityFrameWidthHeight()
    local x,y = (0.4 - (2 * fw)) + 4*fw,0
    TARGET_DETAILS_DATA = UI_CreateUnitDetails(1)
    TARGET_DETAILS_DATA.buffs = UI_CreateBuffDetails(1,TARGET_DETAILS_DATA.mainFrame)
    TARGET_DETAILS_DATA.stats = UI_CreateStatDetails(1,TARGET_DETAILS_DATA.mainFrame)

    BlzFrameClearAllPoints(TARGET_DETAILS_DATA.mainFrame)
    BlzFrameSetAbsPoint(TARGET_DETAILS_DATA.mainFrame, FRAMEPOINT_BOTTOMLEFT, x, y)
    BlzFrameSetVisible(TARGET_DETAILS_DATA.mainFrame, false)
    fw,fh,x,y = nil,nil,nil,nil

    local prev = TARGET_DETAILS_DATA.buffs[1].buffFrame
    BlzFrameSetPoint(prev, FRAMEPOINT_TOPRIGHT, TARGET_DETAILS_DATA.mainFrame, FRAMEPOINT_TOPRIGHT, -0.006, -0.0045)
    for i=2,#TARGET_DETAILS_DATA.buffs do
        if (i-1) - math.floor((i-1)/3)*3 == 0 then
            BlzFrameSetPoint(TARGET_DETAILS_DATA.buffs[i].buffFrame, FRAMEPOINT_TOP, TARGET_DETAILS_DATA.buffs[i-3].buffFrame, FRAMEPOINT_BOTTOM, 0, 0)
        else
            BlzFrameSetPoint(TARGET_DETAILS_DATA.buffs[i].buffFrame, FRAMEPOINT_RIGHT, prev, FRAMEPOINT_LEFT, -0.006, 0)
        end
        prev = TARGET_DETAILS_DATA.buffs[i].buffFrame
    end

    BlzFrameSetPoint(TARGET_DETAILS_DATA.stats.mainFrame, FRAMEPOINT_LEFT, TARGET_DETAILS_DATA.mainFrame, FRAMEPOINT_LEFT, 0, 0)

    TARGET_DETAILS_DATA.energy_frame = BlzCreateSimpleFrame('Details_Energy_BarFrame', TARGET_DETAILS_DATA.mainFrame, 1)
    TARGET_DETAILS_DATA.energy_bar = BlzCreateSimpleFrame('Details_Energy_Bar', TARGET_DETAILS_DATA.energy_frame, 1)
    TARGET_DETAILS_DATA.energy_bar_value = BlzCreateSimpleFrame('Details_Energy_Bar_Value', TARGET_DETAILS_DATA.energy_bar, 1)

    BlzFrameSetPoint(TARGET_DETAILS_DATA.energy_frame, FRAMEPOINT_BOTTOM, TARGET_DETAILS_DATA.barFrame, FRAMEPOINT_TOP, 0, 0)
    BlzFrameSetPoint(TARGET_DETAILS_DATA.energy_bar, FRAMEPOINT_CENTER, TARGET_DETAILS_DATA.energy_frame, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(TARGET_DETAILS_DATA.energy_bar_value, FRAMEPOINT_CENTER, TARGET_DETAILS_DATA.energy_bar, FRAMEPOINT_CENTER, 0, 0)
    TARGET_DETAILS_DATA.energy_bar_value_text = BlzGetFrameByName('Details_Energy_Bar_Value_Text', 1)

    prev = nil

    UI_CreateTargetDetails = nil
end

function UI_CreateHeroDetails()
    HERO_DETAILS_DATA = UI_CreateUnitDetails(0)
    HERO_DETAILS_DATA.buffs = UI_CreateBuffDetails(0,HERO_DETAILS_DATA.mainFrame)
    HERO_DETAILS_DATA.stats = UI_CreateStatDetails(0,HERO_DETAILS_DATA.mainFrame)

    local prev = HERO_DETAILS_DATA.buffs[1].buffFrame
    BlzFrameSetPoint(prev, FRAMEPOINT_TOPLEFT, HERO_DETAILS_DATA.mainFrame, FRAMEPOINT_TOPLEFT, 0.006, -0.0045)
    for i=2,#HERO_DETAILS_DATA.buffs do
        if (i-1) - math.floor((i-1)/3)*3 == 0 then
            BlzFrameSetPoint(HERO_DETAILS_DATA.buffs[i].buffFrame, FRAMEPOINT_TOP, HERO_DETAILS_DATA.buffs[i-3].buffFrame, FRAMEPOINT_BOTTOM, 0, 0)
        else
            BlzFrameSetPoint(HERO_DETAILS_DATA.buffs[i].buffFrame, FRAMEPOINT_LEFT, prev, FRAMEPOINT_RIGHT, 0.006, 0)
        end
        prev = HERO_DETAILS_DATA.buffs[i].buffFrame
    end

    BlzFrameSetPoint(HERO_DETAILS_DATA.stats.mainFrame, FRAMEPOINT_RIGHT, HERO_DETAILS_DATA.mainFrame, FRAMEPOINT_RIGHT, 0, 0)

    HERO_DETAILS_DATA.energy_frame = BlzCreateSimpleFrame('Details_Energy_BarFrame', HERO_DETAILS_DATA.mainFrame, 0)
    HERO_DETAILS_DATA.energy_bar = BlzCreateSimpleFrame('Details_Energy_Bar', HERO_DETAILS_DATA.energy_frame, 0)
    HERO_DETAILS_DATA.energy_bar_value = BlzCreateSimpleFrame('Details_Energy_Bar_Value', HERO_DETAILS_DATA.energy_bar, 0)

    BlzFrameSetPoint(HERO_DETAILS_DATA.energy_frame, FRAMEPOINT_BOTTOM, HERO_DETAILS_DATA.barFrame, FRAMEPOINT_TOP, 0, 0)
    BlzFrameSetPoint(HERO_DETAILS_DATA.energy_bar, FRAMEPOINT_CENTER, HERO_DETAILS_DATA.energy_frame, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(HERO_DETAILS_DATA.energy_bar_value, FRAMEPOINT_CENTER, HERO_DETAILS_DATA.energy_bar, FRAMEPOINT_CENTER, 0, 0)
    HERO_DETAILS_DATA.energy_bar_value_text = BlzGetFrameByName('Details_Energy_Bar_Value_Text', 0)

    prev = nil
    UI_CreateHeroDetails = nil
end

function UI_CreateStatDetails(id,parent)
    local mainFrame = BlzCreateSimpleFrame('Stats_Frame', parent, id)
    local mainFrameTexture = BlzGetFrameByName('Stats_Texture', id)
    local stat_dmg = BlzCreateSimpleFrame('Stats_StatFrame', mainFrame, (id*10) + UI_STAT_DMG)
    local stat_power = BlzCreateSimpleFrame('Stats_StatFrame', mainFrame, (id*10) + UI_STAT_POWER)
    local stat_resist = BlzCreateSimpleFrame('Stats_StatFrame', mainFrame, (id*10) + UI_STAT_RESIST)
    local stat_crit = BlzCreateSimpleFrame('Stats_StatFrame', mainFrame, (id*10) + UI_STAT_CRIT)
    local tbl = {
        mainFrame = mainFrame
        ,mainFrameTexture = mainFrameTexture
        ,stat_dmg = stat_dmg
        ,stat_dmgText = BlzGetFrameByName('Stats_StatText', (id*10) + UI_STAT_DMG)
        ,stat_dmgTexture = BlzGetFrameByName('Stats_StatTexture', (id*10) + UI_STAT_DMG)
        ,stat_dmgListener = BlzGetFrameByName('Stats_FrameListener', (id*10) + UI_STAT_DMG)
        ,stat_power = stat_power
        ,stat_powerText = BlzGetFrameByName('Stats_StatText', (id*10) + UI_STAT_POWER)
        ,stat_powerTexture = BlzGetFrameByName('Stats_StatTexture', (id*10) + UI_STAT_POWER)
        ,stat_powerListener = BlzGetFrameByName('Stats_FrameListener', (id*10) + UI_STAT_POWER)
        ,stat_resist = stat_power
        ,stat_resistText = BlzGetFrameByName('Stats_StatText', (id*10) + UI_STAT_RESIST)
        ,stat_resistTexture = BlzGetFrameByName('Stats_StatTexture', (id*10) + UI_STAT_RESIST)
        ,stat_resistListener = BlzGetFrameByName('Stats_FrameListener', (id*10) + UI_STAT_RESIST)
        ,stat_crit = stat_power
        ,stat_critText = BlzGetFrameByName('Stats_StatText', (id*10) + UI_STAT_CRIT)
        ,stat_critTexture = BlzGetFrameByName('Stats_StatTexture', (id*10) + UI_STAT_CRIT)
        ,stat_critListener = BlzGetFrameByName('Stats_FrameListener', (id*10) + UI_STAT_CRIT)
    }

    BlzFrameSetPoint(stat_dmg, FRAMEPOINT_TOPLEFT, mainFrame, FRAMEPOINT_TOPLEFT, 0.01, -0.005)
    BlzFrameSetPoint(stat_power, FRAMEPOINT_LEFT, stat_dmg, FRAMEPOINT_RIGHT, 0.01, 0)
    BlzFrameSetPoint(stat_crit, FRAMEPOINT_BOTTOMLEFT, mainFrame, FRAMEPOINT_BOTTOMLEFT, 0.01, 0.013)
    BlzFrameSetPoint(stat_resist, FRAMEPOINT_LEFT, stat_crit, FRAMEPOINT_RIGHT, 0.01, 0)

    BlzFrameSetTexture(tbl.stat_dmgTexture, STATS_ATTDMG_ICON, 0, true)
    BlzFrameSetTexture(tbl.stat_critTexture, STATS_CRITICAL_ICON, 0, true)
    BlzFrameSetTexture(tbl.stat_resistTexture, STATS_RESISTANCE_ICON, 0, true)
    BlzFrameSetTexture(tbl.stat_powerTexture, ATTRIBUTE_UNDEFINED_ICON, 0, true)

    BlzFrameSetPoint(tbl.stat_resistListener, FRAMEPOINT_CENTER, stat_resist, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(tbl.stat_dmgListener, FRAMEPOINT_CENTER, stat_dmg, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(tbl.stat_critListener, FRAMEPOINT_CENTER, stat_crit, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(tbl.stat_powerListener, FRAMEPOINT_CENTER, stat_power, FRAMEPOINT_CENTER, 0, 0)

    TOOLTIP_RegisterTooltip(tbl.stat_resistListener,TOOLTIP_TYPE_STAT .. id,UI_STAT_RESIST)
    TOOLTIP_RegisterTooltip(tbl.stat_critListener,TOOLTIP_TYPE_STAT .. id,UI_STAT_CRIT)
    TOOLTIP_RegisterTooltip(tbl.stat_powerListener,TOOLTIP_TYPE_STAT .. id,UI_STAT_POWER)
    TOOLTIP_RegisterTooltip(tbl.stat_dmgListener,TOOLTIP_TYPE_STAT .. id,UI_STAT_DMG)

    mainFrame,mainFrameTexture,stat_dmg,stat_power,stat_resist,stat_crit = nil,nil,nil,nil,nil,nil
    return tbl
end

function UI_CreateBuffDetails(id,parent)
    local seed = id * 100
    local tbl = {}
    for i=1,UI_BUFF_COUNT do
        local buffFrame = BlzCreateSimpleFrame('Buff_Frame', parent, seed + i)
        local buff_tbl = {
            buffFrame = buffFrame
            ,buffTexture = BlzGetFrameByName('Buff_Texture', seed + i)
            ,buffText = BlzGetFrameByName('Buff_Text', seed + i)
            ,buffListener = BlzGetFrameByName('Buff_FrameListener', seed + i)
        }
        table.insert(tbl,buff_tbl)
        TOOLTIP_RegisterTooltip(buff_tbl.buffListener,TOOLTIP_TYPE_BUFF .. id,i)
        BlzFrameSetPoint(buff_tbl.buffListener, FRAMEPOINT_CENTER, buff_tbl.buffFrame, FRAMEPOINT_CENTER, 0, 0)
        buffFrame,buff_tbl = nil,nil,nil
    end
    seed = nil
    return tbl
end

function UI_CreateUnitDetails(id)
    local fw,fh = UI_GetAbilityFrameWidthHeight()
    local x,y = 0.4 - (2 * fw),0.0
    local mainFrame = BlzCreateSimpleFrame('Details_Frame', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), id)
    local barFrame = BlzCreateSimpleFrame('Details_BarFrame', mainFrame, id)
    local bar = BlzCreateSimpleFrame('Details_Bar', barFrame, id)
    local barName = BlzCreateSimpleFrame('Details_Bar_Name', bar, id)
    local barHP = BlzCreateSimpleFrame('Details_Bar_HP', bar, id)
    local barReg = BlzCreateSimpleFrame('Details_Bar_HPReg', bar, id)
    local unitIcon = BlzCreateSimpleFrame('Details_UnitIcon', barFrame, id)

    local tbl = {
        mainFrame = mainFrame
        ,barFrame = barFrame
        ,bar = bar
        ,unitName = barName
        ,unitHP = barHP
        ,unitReg = barReg
        ,mainTexture = BlzGetFrameByName('Details_Texture', id)
        ,barFrameTexture = BlzGetFrameByName('Details_BarTexture', id)
        ,unitNameText = BlzGetFrameByName('Details_Bar_Name_Text', id)
        ,unitHPText = BlzGetFrameByName('Details_Bar_HP_Text', id)
        ,unitRegText = BlzGetFrameByName('Details_Bar_HPReg_Text', id)
        ,unitIcon = unitIcon
        ,unitIconTexture = BlzGetFrameByName('Details_UnitIconTexture', id)
    }

    BlzFrameSetPoint(barFrame, FRAMEPOINT_BOTTOM, mainFrame, FRAMEPOINT_TOP, 0, 0)
    BlzFrameSetPoint(unitIcon, FRAMEPOINT_LEFT, barFrame, FRAMEPOINT_LEFT, 0, 0)
    BlzFrameSetPoint(bar, FRAMEPOINT_LEFT, unitIcon, FRAMEPOINT_RIGHT, 0, 0)
    BlzFrameSetPoint(barName, FRAMEPOINT_LEFT, bar, FRAMEPOINT_LEFT, 0, 0)
    BlzFrameSetPoint(barHP, FRAMEPOINT_BOTTOMRIGHT, bar, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
    BlzFrameSetPoint(barReg, FRAMEPOINT_TOPRIGHT, bar, FRAMEPOINT_TOPRIGHT, 0, 0)

    BlzFrameSetAbsPoint(mainFrame, FRAMEPOINT_BOTTOMRIGHT, x, y)

    BlzFrameSetTexture(tbl.bar, DBM_BAR_clDARKGREEN.texture, 0, true)

    x,y,fw,fh,mainFrame,barFrame,bar,barName,barHP,barReg,unitIcon = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
    return tbl
end

HERO_PORTRAIT = nil

function UI_LoadHeroStatistics()
    HERO_PORTRAIT = BlzCreateSimpleFrame('Hero_Portrait', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    BlzFrameSetAbsPoint(HERO_PORTRAIT, FRAMEPOINT_BOTTOMLEFT, -0.134, 0)

    UI_LoadHeroStatistics = nil
end

function UI_ShowHeroPortrait()
    BlzFrameSetVisible(HERO_PORTRAIT, true)
end

function UI_HideHeroPortrait()
    BlzFrameSetVisible(HERO_PORTRAIT, false)
end

function UI_LoadAbilityTrigger_Focus()
    for i,ui in pairs(UI_ABILITIES) do
        BlzTriggerRegisterFrameEvent(UI_ABILITIES_TRIGGER_FOCUS, ui.listener, FRAMEEVENT_MOUSE_ENTER)
        BlzTriggerRegisterFrameEvent(UI_ABILITIES_TRIGGER_FOCUS, ui.listener, FRAMEEVENT_MOUSE_LEAVE)
    end
    TriggerAddAction(UI_ABILITIES_TRIGGER_FOCUS, function()
        i = IsInArray_ByKey(BlzGetTriggerFrame(),UI_ABILITIES,'listener')
        if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_ENTER and ABILITIES_DATA[UI_ABILITIES[i].abCode].ICON_FOCUSED and IsAbilityAvailable(HERO,UI_ABILITIES[i].abCode) and UI_ABILITIES[i].abCode ~= UI_PLAYER_CASTING then
            BlzFrameSetTexture(UI_ABILITIES[i].icon, ABILITIES_DATA[UI_ABILITIES[i].abCode].ICON_FOCUSED, 0, true)
        elseif BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_LEAVE and IsAbilityAvailable(HERO,UI_ABILITIES[i].abCode) and UI_ABILITIES[i].abCode ~= UI_PLAYER_CASTING then
            BlzFrameSetTexture(UI_ABILITIES[i].icon, ABILITIES_DATA[UI_ABILITIES[i].abCode].ICON, 0, true)
        end
    end)
    UI_LoadAbilityTrigger_Focus = nil
end

function UI_CreateAbilityFrame(i)
    local border = BlzCreateSimpleFrame('AbilityButton_Border', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), i)
    local mainFrame = BlzCreateFrame('AbilityButton_Frame',  BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, i)
    local icon = BlzCreateFrame('AbilityButton_Icon',  mainFrame, 0, i)
    local text = BlzCreateFrame('AbilityButton_Text',  mainFrame, 0, i)
    local shortcut = BlzCreateFrame('AbilityButton_Shortcut',  icon, 0, i)
    local shortcutText = BlzCreateFrame('AbilityButton_ShortcutText',  shortcut, 0, i)
    local listener = BlzCreateFrame('AbilityButton_Listener',  mainFrame, 0, i)

    BlzFrameSetPoint(border, FRAMEPOINT_CENTER, mainFrame, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(icon, FRAMEPOINT_CENTER, mainFrame, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(text, FRAMEPOINT_CENTER, icon, FRAMEPOINT_CENTER, 0, -0.001)
    BlzFrameSetPoint(shortcut, FRAMEPOINT_BOTTOMRIGHT, icon, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
    BlzFrameSetPoint(shortcutText, FRAMEPOINT_CENTER, shortcut, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetPoint(listener, FRAMEPOINT_CENTER, mainFrame, FRAMEPOINT_CENTER, 0, 0)

    BlzFrameSetVisible(mainFrame, true)

    UI_ABILITIES[i].mainFrame = mainFrame
    UI_ABILITIES[i].border = border
    UI_ABILITIES[i].borderTexture = BlzGetFrameByName('AbilityButton_Border_Texture', i)
    UI_ABILITIES[i].icon = icon
    UI_ABILITIES[i].listener = listener
    UI_ABILITIES[i].text = text
    UI_ABILITIES[i].shortcut = shortcut
    UI_ABILITIES[i].shortcutText = shortcutText
    
    TOOLTIP_RegisterTooltip(listener,TOOLTIP_TYPE_ABILITY,i,true)

    mainFrame,icon,text,shortcut,shortcutText,listener,border = nil,nil,nil,nil,nil,nil,nil
end

function UI_GetAbilityFrameWidthHeight()
    for i,ui in pairs(UI_ABILITIES) do
        if ui.abCode and i >= UI_SHORTCUT_Q then
            return BlzFrameGetWidth(ui.mainFrame),BlzFrameGetHeight(ui.mainFrame)
        end
    end
    return 0.03,0.03
end

UI_CASTBAR_Y = 0
UI_TOOLTIP_ABILITY_Y = 0

function UI_RefreshAbilityPositions()
    local fw,fh = UI_GetAbilityFrameWidthHeight()
    local x,y,maxi = 0.4 - (2 * fw),0.0,tableGetMaxIndex(UI_ABILITIES)
    for i=maxi - 3,11,-4 do
        BlzFrameSetAbsPoint(UI_ABILITIES[i].mainFrame, FRAMEPOINT_BOTTOMLEFT, x, y)
        for j=i+1,i+3 do
            BlzFrameSetPoint(UI_ABILITIES[j].mainFrame, FRAMEPOINT_LEFT, UI_ABILITIES[j-1].mainFrame, FRAMEPOINT_RIGHT, 0, 0)
        end
        y = y + fh
    end
    local c,maxi = 0,fh
    for i,v in pairs(UI_ABILITIES) do
        if i <= 10 then
            if v.abCode then
                BlzFrameSetScale(v.mainFrame, 0.8)
                BlzFrameSetScale(v.border, 0.8)
                BlzFrameSetAbsPoint(v.mainFrame, FRAMEPOINT_BOTTOMLEFT, x, y)
                x = x + BlzFrameGetWidth(v.mainFrame)
                fh = BlzFrameGetHeight(v.mainFrame)
                c = c + 1
                if c - math.floor(c/5)*5 == 0 then
                    x,y = 0.4 - (2 * fw),y + fh
                end
            else
                BlzFrameSetVisible(v.mainFrame, false)
            end
        end
    end
    UI_CASTBAR_Y = (c > 0 and y + fh or y) + maxi
    UI_TOOLTIP_ABILITY_Y = c > 0 and y + fh or y
    fw,fh,x,y,c,maxi = nil,nil,nil,nil,nil,nil
end

function UI_RefreshAbilityData()
    for i,ui in pairs(UI_ABILITIES) do
        if ui.abCode then
            BlzFrameSetTexture(ui.icon, ABILITIES_DATA[ui.abCode].ICON, 0, true)
            if ABILITIES_DATA[ui.abCode].ICON_FOCUSED then
                BlzFrameSetVisible(ui.shortcut, true)                
                BlzFrameSetText(ui.shortcutText, string.char(GetHandleId(ui.OS_Key)))
            else
                BlzFrameSetVisible(ui.shortcut, false)
            end
            BlzFrameSetVisible(ui.icon, true)
            BlzFrameSetEnable(ui.listener, true)
            UI_RefreshAbilityIconState(ui.abCode)
            CD_UpdateStacksUI(ui.abCode)
        else
            BlzFrameSetVisible(ui.icon, false)
            BlzFrameSetEnable(ui.listener, false)
        end
    end
end

function UI_RefreshAbilityTrigger()
    DestroyTrigger(UI_ABILITIES_TRIGGER_USE)
    UI_ABILITIES_TRIGGER_USE = CreateTrigger()

    for i,ui in pairs(UI_ABILITIES) do
        if ui.abCode and ui.listener then
            BlzTriggerRegisterFrameEvent(UI_ABILITIES_TRIGGER_USE, ui.listener, FRAMEEVENT_CONTROL_CLICK)
            BlzTriggerRegisterPlayerKeyEvent(UI_ABILITIES_TRIGGER_USE, PLAYER, ui.OS_Key, KEY_PRESSED_NONE, true)
            BlzTriggerRegisterPlayerKeyEvent(UI_ABILITIES_TRIGGER_USE, PLAYER, ui.OS_Key, KEY_PRESSED_SHIFT, true)
        end
    end
    TriggerAddAction(UI_ABILITIES_TRIGGER_USE, UI_AbilityAction)
end

function UI_AbilityAction()
    local i
    local metaK = KEY_PRESSED_NONE
    if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
        BlzFrameSetEnable(BlzGetTriggerFrame(), false)
        BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        i = IsInArray_ByKey(BlzGetTriggerFrame(),UI_ABILITIES,'listener')
    else
        i = IsInArray_ByKey(BlzGetTriggerPlayerKey(),UI_ABILITIES,'OS_Key')
        metaK = BlzGetTriggerPlayerMetaKey()
    end
    local ab = UI_ABILITIES[i].abCode
    if UI_PLAYER_CASTING ~= ab and IsAbilityAvailable(HERO,ab) and ABILITIES_DATA[ab] then
        local t_type,order = ABILITIES_DATA[ab].TARGET_TYPE,ABILITIES_DATA[ab].order
        if t_type == AB_TARGET_POINT then
            local x,y = metaK ~= KEY_PRESSED_SHIFT and PLAYER_MOUSELOC_X or GetUnitX(HERO), metaK ~= KEY_PRESSED_SHIFT and PLAYER_MOUSELOC_Y or GetUnitY(HERO)
            if x ~= 0.0 or y ~= 0.0 then
                IssuePointOrderById(HERO, order, x, y)
            end
            x,y = nil
        elseif t_type == AB_TARGET_INSTANT then
            IssueImmediateOrderById(HERO, order)
        elseif t_type == AB_TARGET_UNIT and (TARGET or metaK == KEY_PRESSED_SHIFT) then
            IssueTargetOrderById(HERO, order, metaK == KEY_PRESSED_SHIFT and HERO or TARGET)
        elseif t_type == AB_TARGET_UNITORPOINT then
            print('UNITORPOINT is not coded')
        elseif t_type == AB_TARGET_NOCAST then
            if ABILITIES_DATA[ab].castFunc then
                ABILITIES_DATA[ab].castFunc()
            end
        end
        t_type,order,metaK = nil,nil,nil
    end
    ab,i = nil,nil
end

function UI_SetAbilityIconState_Casting(abCode)
    local i = IsInArray_ByKey(abCode,UI_ABILITIES,'abCode')
    if i then
        BlzFrameSetTexture(UI_ABILITIES[i].icon, ABILITIES_DATA[abCode].ICON_PUSHED, 0, true)
    end
    i = nil
end

function UI_RefreshAbilityIconState(abCode)
    local i = IsInArray_ByKey(abCode,UI_ABILITIES,'abCode')
    if i then
        if IsAbilityAvailable(HERO,abCode) then
            BlzFrameSetTexture(UI_ABILITIES[i].icon, ABILITIES_DATA[abCode].ICON, 0, true)
        else
            BlzFrameSetTexture(UI_ABILITIES[i].icon, ABILITIES_DATA[abCode].ICON_DISABLED, 0, true)
        end
    end
    i = nil
end

function UI_LoadAbilities(hero_type,stance)
    UI_LoadStance(hero_type,stance)
    for i,ui in pairs(UI_ABILITIES) do
        UI_CreateAbilityFrame(i)
    end
    UI_LoadAbilities = nil
end

function UI_LoadStance(hero_type,stance)
    for i,ui in pairs(UI_ABILITIES) do
        if ui.abCode then
            local abCode = ui.abCode
            ui.abCode = nil
            if ABILITIES_DATA[abCode].stance ~= 'universal' and ABILITIES_DATA[abCode].stance ~= stance and ui.text then
                BlzFrameSetText(ui.text,'')
            end
            abCode = nil
        end
    end
    for i,ab in pairs(UNITS_DATA[hero_type].ABILITIES) do
        if ab ~= Get_DmgTypeAutoAttack() and ABILITIES_DATA[ab].UI_SHORTCUT and (not(stance) or ABILITIES_DATA[ab].stance == stance or ABILITIES_DATA[ab].stance == 'universal') then
            UI_ABILITIES[ABILITIES_DATA[ab].UI_SHORTCUT].abCode = ab
        end
    end
end

function UI_ChangeStance(hero_type,stance)
    UI_LoadStance(hero_type,stance)
    UI_RefreshAbilityPositions()
    UI_RefreshAbilityData()
end

function UI_Warlock()
    UI_LoadAbilities(HERO_WARLOCK)
    UI_RefreshAbilityPositions()
    UI_RefreshAbilityData()
    UI_RefreshAbilityTrigger()
    UI_WarlockFlush = nil
    UI_Warlock = nil
end

function UI_WarlockFlush()
    UI_WarlockFlush = nil
    UI_Warlock = nil
end

function UI_Priest()
    UI_LoadAbilities(HERO_PRIEST,'holy')
    UI_RefreshAbilityPositions()
    UI_RefreshAbilityData()
    UI_RefreshAbilityTrigger()
    UI_PriestFlush = nil
    UI_Priest = nil
end

function UI_PriestFlush()
    UI_PriestFlush = nil
    UI_Priest = nil
end

function UI_FireMage()
    UI_LoadAbilities(HERO_FIREMAGE)
    UI_RefreshAbilityPositions()
    UI_RefreshAbilityData()
    UI_RefreshAbilityTrigger()
    UI_FireMageFlush = nil
    UI_FireMage = nil
end

function UI_FireMageFlush()
    UI_FireMage = nil
    UI_FireMageFlush = nil
end

----------------------------------------------------
--------------SILENCE SYSTEM SETUP------------------
----------------------------------------------------

SILENCE_TABLE = {}
SILENCE_DISPELLEXPC = {'noorbs','nopower','noenergy'}

function SILENCE_IsAbilityAvailable(unit,abCode)
    for i,v in pairs(SILENCE_TABLE) do
        if v.unit == unit and v.abCode == abCode then
            return false
        end
    end
    return true
end

function SILENCE_UI_ChangeState(unit,abCode)
    if unit == HERO then
        UI_RefreshAbilityIconState(abCode)
    end
end

function SILENCE_IsSeedUnused(unit,abCode,seed)
    for i,v in pairs(SILENCE_TABLE) do
        if v.unit == unit and v.abCode == abCode and v.seed == seed then
            return false
        end
    end
    return true
end

function SILENCE_silenceAbility(unit,abCode,seed)
    if ABILITIES_DATA[abCode] and not(ABILITIES_DATA[abCode].noSilence) and SILENCE_IsSeedUnused(unit,abCode,seed) then
        local tbl = {
            unit = unit
            ,abCode = abCode
            ,seed = seed
        }
        table.insert(SILENCE_TABLE,tbl)
        tbl = nil
        SILENCE_UI_ChangeState(unit,abCode)
    end
end

function SILENCE_silenceUnit(unit)
    for i,ab in pairs(UNITS_DATA[GetUnitTypeId(unit)].ABILITIES) do
        if i ~= Get_DmgTypeAutoAttack() and ABILITIES_DATA[ab] and not(ABILITIES_DATA[ab].noSilence) then
            local tbl = {
                unit = unit
                ,abCode = ab
            }
            table.insert(SILENCE_TABLE,tbl)
            tbl = nil
            SILENCE_UI_ChangeState(unit,ab)
        end
    end
end

function SILENCE_allowAbilitySeed(unit,abCode,seed)
    local tbl = {}
    for i,t in pairs(SILENCE_TABLE) do
        if t.unit == unit and t.abCode == abCode and t.seed == seed then
            table.insert(tbl,i)
        end
    end
    table.sort(tbl)
    for i = #tbl,1,-1 do
        table.remove(SILENCE_TABLE,tbl[i])
    end
    tbl = nil
    SILENCE_UI_ChangeState(unit,abCode)
end

function SILENCE_allowAbility(unit,abCode,seed_expections)
    local tbl = {}
    seed_expections = seed_expections or SILENCE_DISPELLEXPC
    for i,t in pairs(SILENCE_TABLE) do
        if t.unit == unit and t.abCode == abCode and not(IsInArray(t.seed,seed_expections)) then
            table.insert(tbl,i)
        end
    end
    table.sort(tbl)
    for i = #tbl,1,-1 do
        table.remove(SILENCE_TABLE,tbl[i])
    end
    tbl,seed_expections = nil,nil
    SILENCE_UI_ChangeState(unit,abCode)
end

function SILLENCE_allowUnit(unit,seed_expections)
    local tbl = {}
    seed_expections = seed_expections or SILENCE_DISPELLEXPC
    for i,t in pairs(SILENCE_TABLE) do
        if t.unit == unit and not(IsInArray(t.seed,seed_expections)) then
            table.insert(tbl,i)
        end
    end
    table.sort(tbl)
    for i = #tbl,1,-1 do
        local abCode = SILENCE_TABLE[tbl[i]].abCode
        table.remove(SILENCE_TABLE,tbl[i])
        SILENCE_UI_ChangeState(unit,abCode)
        abCode = nil
    end
    tbl,seed_expections = nil,nil
end

----------------------------------------------------
-------------COOLDOWN SYSTEM SETUP------------------
----------------------------------------------------

COOLDOWN_TABLE = {}
COOLDOWN_TRIGGER = CreateTrigger()
COOLDOWN_ABILITIES = {}

function IsAbilityAvailable(unit,abCode)
    return CD_IsAbilityAvailable(unit,abCode) and SILENCE_IsAbilityAvailable(unit,abCode)
end

function CD_DisableAbility(unit,abCode)
    if CD_IsAbilityAvailable(unit,abCode) then
        COOLDOWN_ABILITIES[unit] = COOLDOWN_ABILITIES[unit] or {}
        table.insert(COOLDOWN_ABILITIES[unit],abCode)
        if unit == HERO then
            UI_RefreshAbilityIconState(abCode)
        end
    end
end

function CD_IsAbilityAvailable(unit,abCode)
    local avail = true
    if COOLDOWN_ABILITIES[unit] then
        for i,ab in pairs(COOLDOWN_ABILITIES[unit]) do
            if ab == abCode then
                avail = false
                break
            end
        end
    end
    return avail and GetUnitAbilityLevel(unit, abCode) > 0
end

function CD_EnableAbility(unit,abCode,stacks)
    if unit == HERO then
        local i = IsInArray_ByKey(abCode,UI_ABILITIES,'abCode')
        if i then
            BlzFrameSetText(UI_ABILITIES[i].text, (ABILITIES_DATA[UI_ABILITIES[i].abCode].CooldownStacks or 1) > 1 and stacks or '')
        end
        i = nil
    end
    if not(CD_IsAbilityAvailable(unit,abCode)) then
        RemoveFromArray(abCode,COOLDOWN_ABILITIES[unit])
        if unit == HERO then
            UI_RefreshAbilityIconState(abCode)
        end
    end
end

function CD_UpdateStacksUI(abCode)
    local stacks,cool = CD_GetUnitAbilityCooldownRemaining(HERO,abCode)
    if stacks > 0 then
        CD_EnableAbility(u,abCode,stacks)
    end
end

function CD_UpdateCooldownUI(abCode,cd)
    local i = IsInArray_ByKey(abCode,UI_ABILITIES,'abCode')
    if i then
        BlzFrameSetText(UI_ABILITIES[i].text,strRound(cd,1))
    end
    i = nil
end

function CD_RegisterCooldownSystem()
    TriggerRegisterTimerEventPeriodic(COOLDOWN_TRIGGER, 0.1)
    TriggerAddAction(COOLDOWN_TRIGGER, function()
        local t = 0
        for u,ut in pairs(COOLDOWN_TABLE) do
            for ab,at in pairs(ut) do
                local c = 0
                for ci,cd in pairs(at) do
                    if cd <= 0 then
                        COOLDOWN_TABLE[u][ab][ci] = nil
                    else
                        COOLDOWN_TABLE[u][ab][ci] = round(COOLDOWN_TABLE[u][ab][ci] - 0.1,1)
                        c = c + 1
                    end
                end
                if c == 0 then
                    COOLDOWN_TABLE[u][ab] = nil
                end
                local stacks,cool = CD_GetUnitAbilityCooldownRemaining(u,ab)
                if stacks > 0 then
                    CD_EnableAbility(u,ab,stacks)
                else
                    if CD_IsAbilityAvailable(u,ab) then
                        CD_DisableAbility(u,ab)
                    end
                    if u == HERO then
                        CD_UpdateCooldownUI(ab,cool)
                    end
                end
                c,stacks,cool = nil,nil,nil
                t = t + 1
            end
        end
        if t == 0 then
            DisableTrigger(COOLDOWN_TRIGGER)
        end
    end)
    CD_RegisterCooldownSystem = nil
end


function CD_TriggerAbilityCooldown(abCode,unit,opt_duration)
    opt_duration = opt_duration or CD_GetUnitAbilityCooldown(abCode,unit)
    COOLDOWN_TABLE[unit] = COOLDOWN_TABLE[unit] or {}
    COOLDOWN_TABLE[unit][abCode] = COOLDOWN_TABLE[unit][abCode] or {}
    table.insert(COOLDOWN_TABLE[unit][abCode],opt_duration)
    if not(CD_IsAbilityReady(abCode,unit)) then
        CD_DisableAbility(unit, abCode)
    end
    if not(IsTriggerEnabled(COOLDOWN_TRIGGER)) then
        EnableTrigger(COOLDOWN_TRIGGER)
    end
end

function CD_GetUnitAbilityCooldownRemaining(unit,abCode)
    local stacks = ABILITIES_DATA[abCode].CooldownStacks or 1
    local cooldown = 0
    local x = 1
    if COOLDOWN_TABLE[unit] and COOLDOWN_TABLE[unit][abCode] then
        stacks = stacks - tableLength(COOLDOWN_TABLE[unit][abCode])
        if stacks >= 0 then
            for i,v in pairs(COOLDOWN_TABLE[unit][abCode]) do
                cooldown = (cooldown > v or cooldown == 0) and v or cooldown
            end
        else
            for i=1,math.abs(stacks) do
                table_DeleteMinVal(COOLDOWN_TABLE[unit][abCode])
            end
            cooldown = table_GetMinVal(COOLDOWN_TABLE[unit][abCode])
        end
    end
    stacks = stacks >= 0 and stacks or 0
    return stacks,cooldown
end

function CD_ResetAbilityCooldown(unit,abCode)
    if COOLDOWN_TABLE[unit] and COOLDOWN_TABLE[unit][abCode] then
        for i,v in pairs(COOLDOWN_TABLE[unit][abCode]) do
            COOLDOWN_TABLE[unit][abCode][i] = -1
        end
    end
end

function CD_ResetAllAbilitiesCooldown(unit)
    if COOLDOWN_TABLE[unit] then
        for i,x in pairs(COOLDOWN_TABLE[unit]) do
            for j,v in pairs(COOLDOWN_TABLE[unit][i]) do
                COOLDOWN_TABLE[unit][i][j] = -1
            end
        end
    end
end

function CD_GetDefaultAbilityCooldown_Unit(abCode,unit)
    return ABILITIES_DATA[abCode].Cooldown or BlzGetAbilityCooldown(abCode, GetUnitAbilityLevel(unit, abCode)-1)
end

function CD_GetDefaultAbilityCooldown_Level(abCode,level)
    return BlzGetAbilityCooldown(abCode, level)
end

function CD_GetUnitAbilityCooldown(abCode,unit)
    return ABILITIES_DATA[abCode].Cooldown or BlzGetUnitAbilityCooldown(unit, abCode, GetUnitAbilityLevel(unit, abCode)-1)
end

function CD_IsAbilityOnCooldown(abCode,unit)
    local stacks,cd = CD_GetUnitAbilityCooldownRemaining(unit,abCode)
    return cd > 0 and stacks == 0
end

function CD_GetAvailableStack(abCode,unit)
    local stacks,cd = CD_GetUnitAbilityCooldownRemaining(unit,abCode)
    return stacks >= 0 and stacks or 0
end

function CD_IsAbilityReady(abCode,unit)
    local stacks,cd = CD_GetUnitAbilityCooldownRemaining(unit,abCode)
    return stacks > 0
end

----------------------------------------------------
-------------TARGET SYSTEM SETUP--------------------
----------------------------------------------------

PLAYER_MOUSELOC_X,PLAYER_MOUSELOC_Y = nil,nil
PLAYER_MOUSELOC_TRIGGER = CreateTrigger()
PLAYER_QUICKCAST_ENABLED = true

function TT_LoadTargetingSystem()
    TT_Register_SelectionEvent()
    TT_Deselections()
    TT_Register_TargetClearing()
    TT_RegisterAttackOrder()
    TT_RegisterAttackEvent()
    TT_RegisterMouseLocation()
    TT_Register_SelectionEvent = nil
    TT_Deselections = nil
    TT_Register_TargetClearing = nil
    TT_RegisterAttackOrder = nil
    TT_RegisterAttackEvent = nil

    TT_LoadTargetingSystem = nil
end

function TT_RegisterAttackOrder()
    local trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
    TriggerAddCondition(trg,Condition(function() return ((GetIssuedOrderIdBJ() == String2OrderIdBJ("attack") or GetIssuedOrderIdBJ() == String2OrderIdBJ("smart")) and GetOrderedUnit() == HERO) end))
    TriggerAddAction(trg, function()
        TT_MakeUnit_Target(GetOrderTargetUnit())
    end)
end

function TT_RegisterMouseLocation()
    TriggerRegisterPlayerMouseEventBJ(PLAYER_MOUSELOC_TRIGGER, PLAYER, bj_MOUSEEVENTTYPE_MOVE)
    TriggerAddAction(PLAYER_MOUSELOC_TRIGGER, function()
        PLAYER_MOUSELOC_X,PLAYER_MOUSELOC_Y = BlzGetTriggerPlayerMouseX(),BlzGetTriggerPlayerMouseY()
    end)
end

function TT_EnableQuickCast()
    EnableTrigger(PLAYER_MOUSELOC_TRIGGER)
    PLAYER_QUICKCAST_ENABLED = true
end

function TT_DisableQuickCast()
    DisableTrigger(PLAYER_MOUSELOC_TRIGGER)
    PLAYER_MOUSELOC_X,PLAYER_MOUSELOC_Y = nil,nil
    PLAYER_QUICKCAST_ENABLED = false
end

function TT_RegisterAttackEvent()
    --[[local trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_ATTACKED)
    TriggerAddCondition(trg,Condition(function() return (GetAttacker() == HERO and GetAttackedUnitBJ() ~= HERO and GetAttackedUnitBJ() ~= TARGET) end))
    TriggerAddAction(trg, function()
        TT_MakeUnit_Target(GetAttackedUnitBJ())
    end)]]--
end

function TT_HighlightUnit(unit)
    SetUnitVertexColorBJ(unit, 100, 100, 100, 0)
end

function TT_HighlightUnit_Cancel(unit)
    SetUnitVertexColorBJ(unit, 50.00, 50.00, 50.00, 0)
end

function TT_Deselections()
    local trg = CreateTrigger()
    TriggerRegisterPlayerSelectionEventBJ(trg, PLAYER, false)
    TriggerAddAction(trg, function()
        if GetTriggerUnit() == HERO then
            TT_SelectHero()
        end
    end)
end

function TT_MakeUnit_Target(unit)
    if TARGET then
        TT_HighlightUnit_Cancel(TARGET)
        --UnitRemoveAbilityBJ(TARGET_ABILITY, TARGET)
    end
    TARGET = unit
    TT_HighlightUnit(TARGET)
    --UnitAddAbilityBJ(TARGET_ABILITY, TARGET)
    UI_RefreshIcons(TARGET)
end

function TT_ClearTarget()
    BlzFrameSetVisible(TARGET_DETAILS_DATA.mainFrame, false)
    TT_HighlightUnit_Cancel(TARGET)
    --UnitRemoveAbilityBJ(TARGET_ABILITY, TARGET)
    TARGET = nil
end

function TT_Register_SelectionEvent()
    local trg = CreateTrigger()
    TriggerRegisterPlayerSelectionEventBJ(trg, PLAYER, true)
    TriggerAddAction(trg, function()
        if GetTriggerUnit() ~= HERO then
            TT_MakeUnit_Target(GetTriggerUnit())
        end
    end)
end

function TT_SelectHero()
    SelectUnitForPlayerSingle(HERO, PLAYER)
    UI_RefreshIcons(HERO)
end

function TT_Register_TargetClearing()
    local trg = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trg,PLAYER,OSKEY_ESCAPE,KEY_PRESSED_NONE,true)
    TriggerAddAction(trg, function()
        TT_ClearTarget()
        UI_HideAllMenus()
    end)

    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_DEATH)
    TriggerAddAction(trg, function()
        if GetDyingUnit() == TARGET then
            TT_ClearTarget()
        end
    end)

    trg = nil
end

----------------------------------------------------
------------CASTING SYSTEM SETUP MAIN---------------
----------------------------------------------------

CASTMAIN_DATA = {}
CASTMAIN_TRIGGER = CreateTrigger()

function CASTMAIN_CreateHeroBar()
    local id = tableLength(CASTMAIN_DATA)
    local data = {}
    local main_frame = BlzCreateSimpleFrame("CastingBar_Texture_Frame", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), id)
    BlzFrameSetAbsPoint(main_frame, FRAMEPOINT_BOTTOM, 0.4, UI_CASTBAR_Y)

    data.frame = main_frame

    frame = BlzCreateSimpleFrame("CastingBar_AbilityIcon_Frame", main_frame, id)
    BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, main_frame, FRAMEPOINT_LEFT, 0, 0)

    data.abIcon = BlzGetFrameByName('CastingBar_AbilityIcon_Texture', id)

    local frame = BlzCreateSimpleFrame("CastingBar_Bar", main_frame, id)
    BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, data.abIcon, FRAMEPOINT_RIGHT, 0, 0)

    data.castBar = frame

    frame = BlzCreateSimpleFrame("CastingBar_BarText_Frame", data.castBar, id)
    BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, data.castBar, FRAMEPOINT_LEFT, 0, 0)

    data.castBarText = BlzGetFrameByName('CastingBar_BarText_Text', id)

    frame = BlzCreateSimpleFrame("CastingBar_Number_Frame", data.castBar, id)
    BlzFrameSetPoint(frame, FRAMEPOINT_RIGHT, data.castBar, FRAMEPOINT_RIGHT, 0, 0)

    data.counterText = BlzGetFrameByName('CastingBar_Number_Text', id)

    BlzFrameSetVisible(main_frame, false)

    CASTMAIN_Register(HERO,data)
end

function CASTMAIN_Register(unit,data)
    local u_id = GetHandleIdBJ(unit)
    CASTMAIN_DATA[u_id] = data
end

function CASTMAIN_Clear(u_id)
    if CASTMAIN_DATA[u_id] then
        BlzDestroyFrame(CASTMAIN_DATA[u_id].frame)
        CASTMAIN_DATA[u_id] = nil
    end
end

function CASTMAIN_GetFrame(unit)
    local u_id = GetHandleIdBJ(unit)
    if CASTMAIN_DATA[u_id] then
        return CASTMAIN_DATA[u_id].frame
    end
    return nil
end

function CASTMAIN_IsRegistered(unit)
    local u_id = GetHandleIdBJ(unit)
    if CASTMAIN_DATA[u_id] and type(CASTMAIN_DATA[u_id]) == 'table' then
        return true
    end
    return false
end

function CASTMAIN_StartCasting(unit,abCode)
    local u_id = GetHandleIdBJ(unit)
    local castTime = BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, abCode), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(unit, abCode)-1)
    local theme = (ABILITIES_DATA[abCode] and ABILITIES_DATA[abCode].barTheme) and ABILITIES_DATA[abCode].barTheme or DBM_BAR_clGRAY
    BlzFrameSetTexture(CASTMAIN_DATA[u_id].abIcon, ABILITIES_DATA[abCode].ICON, 0, true)
    BlzFrameSetTexture(CASTMAIN_DATA[u_id].castBar, theme.texture, 0, true)
    BlzFrameSetTextColor(CASTMAIN_DATA[u_id].castBarText, theme.fontColor)
    BlzFrameSetTextColor(CASTMAIN_DATA[u_id].counterText, theme.fontColor)
    BlzFrameSetText(CASTMAIN_DATA[u_id].castBarText, ABILITIES_DATA[abCode].Name)
    CASTMAIN_DATA[u_id].castTime = castTime
    CASTMAIN_DATA[u_id].curTime = castTime 
    CASTMAIN_DATA[u_id].IsCasting = true
    BlzFrameSetVisible(CASTMAIN_DATA[u_id].frame, true)
    if not(IsTriggerEnabled(CASTMAIN_TRIGGER)) then
        EnableTrigger(CASTMAIN_TRIGGER)
    end
    u_id,castTime,theme= nil,nil,nil
end

function CASTMAIN_StopCasting(unit)
    local u_id = GetHandleIdBJ(unit)
    CASTMAIN_DATA[u_id].IsCasting = false
    UI_Frame_FadeOut({
        frame = CASTMAIN_DATA[u_id].frame
        ,fadeDuration = 1.0
    })
end

function CASTMAIN_Frame_Refresh()
    local c = 0
    for i,tbl in pairs(CASTMAIN_DATA) do
        if BlzFrameIsVisible(tbl.frame) then
            if not(tbl.IsCasting) then
                if tbl.curTime > 0 then
                    BlzFrameSetTextColor(tbl.castBarText, BlzConvertColor(255, 255, 20, 20))
                    BlzFrameSetTextColor(tbl.counterText, BlzConvertColor(255, 255, 20, 20))
                    BlzFrameSetText(tbl.castBarText, 'Interrupted')
                else
                    BlzFrameSetTextColor(tbl.castBarText, BlzConvertColor(255, 20, 255, 20))
                    BlzFrameSetTextColor(tbl.counterText, BlzConvertColor(255, 20, 255, 20))
                    BlzFrameSetValue(tbl.castBar, 100)
                    BlzFrameSetText(tbl.castBarText, 'Completed')
                    BlzFrameSetText(tbl.counterText, '0.0')
                end
            else
                if tbl.castTime < 9000 then
                    if tbl.curTime >= 0 then
                        BlzFrameSetText(tbl.counterText, strRound(tbl.curTime,1))
                        BlzFrameSetValue(tbl.castBar, 100-((tbl.curTime/tbl.castTime)*100)+2)
                    end
                    tbl.curTime = tbl.curTime - 0.01
                else
                    BlzFrameSetText(tbl.counterText, 'CH')
                    BlzFrameSetValue(tbl.castBar, 100)
                end
                c = c + 1
            end
        end
    end
    if c == 0 then
        DisableTrigger(GetTriggeringTrigger())
    end
end

function CASTMAIN_Initialize()
    local trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trg, Condition(function() return CASTMAIN_IsRegistered(GetTriggerUnit()) and BlzGetAbilityRealLevelField(BlzGetUnitAbility(GetTriggerUnit(), GetSpellAbilityId()), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(GetTriggerUnit(), GetSpellAbilityId())-1) > 0 end))
    TriggerAddAction(trg, function()
        if GetTriggerUnit() == HERO then
            UI_PLAYER_CASTING = GetSpellAbilityId()
            UI_SetAbilityIconState_Casting(UI_PLAYER_CASTING)
        end
        CASTMAIN_StartCasting(GetTriggerUnit(),GetSpellAbilityId())
    end)

    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trg, Condition(function() return CASTMAIN_IsRegistered(GetTriggerUnit()) end))
    TriggerAddAction(trg, function()
        if GetTriggerUnit() == HERO then
            UI_RefreshAbilityIconState(UI_PLAYER_CASTING)
            UI_PLAYER_CASTING = nil
        end
        CASTMAIN_StopCasting(GetTriggerUnit())
    end)

    TriggerRegisterTimerEventPeriodic(CASTMAIN_TRIGGER, 0.01)
    TriggerAddAction(CASTMAIN_TRIGGER, CASTMAIN_Frame_Refresh)

    CASTMAIN_CreateHeroBar()
    trg = nil

    CASTMAIN_Initialize = nil
end

----------------------------------------------------
--------------CASTING SYSTEM SETUP------------------
----------------------------------------------------

CASTSYS_DATA = {}
CASTSYS_FRAMES = {}
CASTSYS_HIDDEN = {}
CASTSYS_DEF_FRAME_HEIGHT = nil
CASTSYS_TRIGGER = CreateTrigger()
CASTSYS_BUTTON_TRIGGER = CreateTrigger()

function CASTSYS_IsHidden(value)
    for i,v in pairs(CASTSYS_HIDDEN) do
        if v == value then
            return true
        end
    end
    return false
end

function CASTSYS_IsRegistered(unit)
    local u_id = GetHandleIdBJ(unit)
    if CASTSYS_DATA[u_id] and type(CASTSYS_DATA[u_id]) == 'table' then
        return true
    end
    return false
end

function CASTSYS_RegisterUnit(unit,abCode)
    local u_id = GetHandleIdBJ(unit)
    CASTSYS_DATA[u_id] = {
        unit = unit
        ,frame = CASTSYS_Frame_GetFree()
    }
    CASTSYS_Frame_Load(CASTSYS_DATA[u_id].frame,unit,abCode)
    CASTSYS_RefreshFrames()
end

function CASTSYS_FlushUnit(unit)
    local u_id = GetHandleIdBJ(unit)
    CASTSYS_DATA[u_id] = nil
    CASTSYS_RefreshFrames()
end

function CASTSYS_Frame_IsUsed(frame)
    for i,u_tbl in pairs(CASTSYS_DATA) do
        if frame == u_tbl.frame then
            return true
        end
    end
    return false
end

function CASTSYS_Frame_GetFree()
    for i,tbl in pairs(CASTSYS_FRAMES) do
        if not(CASTSYS_Frame_IsUsed(tbl.frame)) then
            return tbl.frame
        end
    end
    return CASTSYS_Frame_Create()
end

function CASTSYS_Frame_Interact()
    local frame = BlzFrameGetParent(BlzGetTriggerFrame())
    for i,v in pairs(CASTSYS_FRAMES) do
        if v.frame == frame then
            TT_MakeUnit_Target(v.unit)
        end
    end
end

function CASTSYS_Frame_Refresh()
    local c = 0
    for i,tbl in pairs(CASTSYS_FRAMES) do
        if CASTSYS_Frame_IsUsed(tbl.frame) or BlzFrameIsVisible(tbl.frame) then
            if not(CASTSYS_Frame_IsUsed(tbl.frame)) then
                if tbl.curTime > 0 then
                    BlzFrameSetTextColor(tbl.castBarText, BlzConvertColor(255, 255, 20, 20))
                    BlzFrameSetText(tbl.castBarText, 'Interrupted')
                else
                    BlzFrameSetTextColor(tbl.castBarText, BlzConvertColor(255, 20, 255, 20))
                    BlzFrameSetText(tbl.castBarText, 'Completed')
                    BlzFrameSetText(tbl.counterText, '0.0')
                end
            else
                if tbl.castTime < 9000 then
                    if tbl.curTime >= 0 then
                        BlzFrameSetText(tbl.counterText, strRound(tbl.curTime,1))
                        BlzFrameSetValue(tbl.castBar, 100-((tbl.curTime/tbl.castTime)*100)+2)
                    end
                    tbl.curTime = tbl.curTime - 0.01
                else
                    BlzFrameSetText(tbl.counterText, 'CH')
                    BlzFrameSetValue(tbl.castBar, 100)
                end
                c = c + 1
            end
        end
    end
    if c == 0 then
        DisableTrigger(GetTriggeringTrigger())
    end
end

function CASTSYS_Frame_Load(frame,unit,abCode)
    for i,tbl in pairs(CASTSYS_FRAMES) do
        if tbl.frame == frame then
            local theme = (ABILITIES_DATA[abCode] and ABILITIES_DATA[abCode].barTheme) and ABILITIES_DATA[abCode].barTheme or DBM_BAR_clGRAY
            BlzFrameSetTexture(tbl.castBar, theme.texture, 0, true)
            BlzFrameSetTextColor(tbl.castBarText, theme.fontColor)
            BlzFrameSetTextColor(tbl.counterText, theme.fontColor)
            BlzFrameSetValue(tbl.castBar, 0)

            BlzFrameSetTexture(tbl.icon, UNITS_DATA[GetUnitTypeId(unit)].ICON, 0, true)
            BlzFrameSetTexture(tbl.abIcon, ABILITIES_DATA[abCode].ICON, 0, true)
            BlzFrameSetText(tbl.castBarText, ABILITIES_DATA[abCode].Name)
            CASTSYS_FRAMES[i].unit = unit
            CASTSYS_FRAMES[i].abCode = abCode
            CASTSYS_FRAMES[i].castTime = BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, abCode), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(unit, abCode)-1)
            CASTSYS_FRAMES[i].curTime = CASTSYS_FRAMES[i].castTime
            theme = nil
            if not(IsTriggerEnabled(CASTSYS_TRIGGER)) then
                EnableTrigger(CASTSYS_TRIGGER)
            end
        end
    end
end

function CASTSYS_Frame_Create()
    local id = tableLength(CASTSYS_FRAMES)
    local main_frame = BlzCreateSimpleFrame("CastSystem_MainFrame", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), id)

    local frameTbl = {
        frame = main_frame
        ,button = BlzCreateSimpleFrame("CastSystem_Button_Select", main_frame, id)
        ,castBar = BlzCreateSimpleFrame("CastSystem_CastingBar_Bar", main_frame, id)
        ,abIconFrame = BlzCreateSimpleFrame("CastSystem_AbilityIconFrame", main_frame, id)
    }

    frameTbl.abText = BlzCreateSimpleFrame("CastSystem_BarText_Frame", frameTbl.castBar, id)
    frameTbl.numText = BlzCreateSimpleFrame("CastSystem_Number_Frame", frameTbl.castBar, id)

    frameTbl.icon = BlzGetFrameByName('CastSystem_Button_Select_FrameTexture', id)
    frameTbl.abIcon = BlzGetFrameByName('CastSystem_AbilityIconFrameTexture', id)
    frameTbl.castBarText = BlzGetFrameByName('CastSystem_BarText_Text', id)
    frameTbl.counterText = BlzGetFrameByName('CastSystem_Number_Text', id)

    BlzFrameSetPoint(frameTbl.button, FRAMEPOINT_LEFT, frameTbl.frame, FRAMEPOINT_LEFT, 0, 0)
    BlzFrameSetPoint(frameTbl.castBar, FRAMEPOINT_LEFT, frameTbl.button, FRAMEPOINT_RIGHT, 0, 0)
    BlzFrameSetPoint(frameTbl.abIconFrame, FRAMEPOINT_LEFT, frameTbl.castBar, FRAMEPOINT_RIGHT, 0, 0)
    BlzFrameSetPoint(frameTbl.castBarText, FRAMEPOINT_LEFT, frameTbl.castBar, FRAMEPOINT_LEFT, 0.0069, 0)
    BlzFrameSetPoint(frameTbl.counterText, FRAMEPOINT_RIGHT, frameTbl.castBar, FRAMEPOINT_RIGHT, -0.0069, 0)

    BlzTriggerRegisterFrameEvent(CASTSYS_BUTTON_TRIGGER, frameTbl.button, FRAMEEVENT_CONTROL_CLICK)

    table.insert(CASTSYS_FRAMES,frameTbl)
    CASTSYS_DEF_FRAME_HEIGHT = BlzFrameGetHeight(main_frame)

    id,frameTbl = nil,nil
    return main_frame
end

function CASTSYS_RefreshFrames()
    local frames = {}
    for i,tbl in ipairs(CASTSYS_FRAMES) do
        if CASTSYS_Frame_IsUsed(tbl.frame) or BlzFrameIsVisible(tbl.frame) then
            table.insert(frames,tbl.frame)
            if not(CASTSYS_Frame_IsUsed(tbl.frame)) and not(BlzFrameIsFading(tbl.frame)) then
                UI_Frame_FadeOut({
                    frame = tbl.frame
                    ,fadeDuration = 1.0
                    ,exitFunc = CASTSYS_RefreshFrames
                })
            end
        end
    end
    local x,y = -0.13,(0.35 + ((CASTSYS_DEF_FRAME_HEIGHT/2) * (tableLength(frames) -1)))
    for i,frame in ipairs(frames) do
        if CASTSYS_Frame_IsUsed(frame) then
            BlzFrameSetVisible(frame, true)
        end
        BlzFrameSetAbsPoint(frame, FRAMEPOINT_LEFT, x, y)
        y = y - CASTSYS_DEF_FRAME_HEIGHT
    end
end

function CASTSYS_Register()
    local trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddCondition(trg, Condition(function() return not(CASTSYS_IsHidden(GetTriggerUnit())) and not(CASTSYS_IsHidden(GetSpellAbilityId())) and BlzGetAbilityRealLevelField(BlzGetUnitAbility(GetTriggerUnit(), GetSpellAbilityId()), ABILITY_RLF_FOLLOW_THROUGH_TIME, GetUnitAbilityLevel(GetTriggerUnit(), GetSpellAbilityId())-1) > 0 end))
    TriggerAddAction(trg, function()
        CASTSYS_RegisterUnit(GetTriggerUnit(),GetSpellAbilityId())
    end)

    local trg_Finish = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg_Finish, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddCondition(trg_Finish, Condition(function() return CASTSYS_IsRegistered(GetTriggerUnit()) end))
    TriggerAddAction(trg_Finish, function()
        CASTSYS_FlushUnit(GetTriggerUnit())
    end)

    TriggerRegisterTimerEventPeriodic(CASTSYS_TRIGGER, 0.01)
    TriggerAddAction(CASTSYS_TRIGGER, CASTSYS_Frame_Refresh)

    TriggerAddAction(CASTSYS_BUTTON_TRIGGER, CASTSYS_Frame_Interact)

    CASTSYS_HIDDEN = {
        HERO
        ,ABCODE_FLAMEBLINK
        ,ABCODE_SOULOFFIRE
        ,ABCODE_LUST
        ,ABCODE_SUMMONBEASTS
    }
    trg_Finish,trg = nil

    CASTSYS_Register = nil
end

----------------------------------------------------
---------------FRAME FADEOUT SETUP------------------
----------------------------------------------------

UI_FADEOUT_DATA = {}

function UI_Frame_FadeOut(data)
    local i = BlzFrameIsFading(frame)
    if UI_FADEOUT_DATA[i] then
        UI_FADEOUT_DATA[i].fade_rate = (BlzFrameGetAlpha(data.frame) / data.fadeDuration) / 100
        UI_FADEOUT_DATA[i].cur_alpha = BlzFrameGetAlpha(data.frame)
        UI_FADEOUT_DATA[i].exitFunc = data.exitFunc or UI_FADEOUT_DATA[i].exitFunc
    else
        local trg = CreateTrigger()
        UI_FADEOUT_DATA[GetHandleIdBJ(trg)] = {
            trigger = trg
            ,frame = data.frame
            ,fade_rate = (BlzFrameGetAlpha(data.frame) / data.fadeDuration) / 100
            ,cur_alpha = BlzFrameGetAlpha(data.frame)
            ,exitFunc = data.exitFunc
        }
        TriggerRegisterTimerEventPeriodic(trg, 0.01)
        TriggerAddAction(trg, function()
            local trg = GetTriggeringTrigger()
            local t_id = GetHandleIdBJ(trg)
            if UI_FADEOUT_DATA[t_id] then
                if UI_FADEOUT_DATA[t_id].cur_alpha > 0 then
                    UI_FADEOUT_DATA[t_id].cur_alpha = UI_FADEOUT_DATA[t_id].cur_alpha - UI_FADEOUT_DATA[t_id].fade_rate
                    BlzFrameSetAlpha(UI_FADEOUT_DATA[t_id].frame, R2I( UI_FADEOUT_DATA[t_id].cur_alpha))
                else
                    BlzFrameSetVisible(UI_FADEOUT_DATA[t_id].frame, false)
                    if UI_FADEOUT_DATA[t_id].exitFunc then
                        UI_FADEOUT_DATA[t_id].exitFunc()
                    end
                    UI_Frame_FadeOut_Stop(t_id)
                end
            else
                DestroyTrigger(GetTriggeringTrigger())
            end
        end)
    end
end

function UI_Frame_FadeOut_Stop(t_id)
    if UI_FADEOUT_DATA[t_id] then
        DestroyTrigger(UI_FADEOUT_DATA[t_id].trigger)
        UI_FADEOUT_DATA[t_id] = nil
    end
end

function UI_Frame_FadeOut_StopFrame(frame)
    for i,v in pairs(UI_FADEOUT_DATA) do
        if v.frame == frame then
            UI_Frame_FadeOut_Stop(i)
        end
    end
end

function BlzFrameIsFading(frame)
    for i,v in pairs(UI_FADEOUT_DATA) do
        if v.frame == frame then
            return i
        end
    end
    return nil
end

oldBlzFrameSetVisible = BlzFrameSetVisible
function BlzFrameSetVisible(frame,bool,alpha)
    if bool then
        UI_Frame_FadeOut_StopFrame(frame)
        BlzFrameSetAlpha(frame, alpha or 255)
    end
    oldBlzFrameSetVisible(frame,bool)
end