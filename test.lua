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