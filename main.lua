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

function tableGetMaxIndex(table)
    local maxi = 0
    for i,v in pairs(table) do
        maxi = maxi >= i and maxi or i
    end
    return maxi
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

function WaitAndDo(duration,func, ...)
    local t = CreateTimer()
    local param = table.pack(...)
    TimerStart(t, duration, false, function()
        DestroyTimer(t)
        func(table.unpack(param))
        t,func,param = nil,nil,nil
    end)
end


function PLAYER_IsActive(player)
    for i,p in pairs(PLAYERS_GROUP) do
        if p == player then
            return true
        end
    end
    return false
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

function getJASSDataType(data)
    local dataType = tostring(data)
    local i = string.find(dataType,':')
    if i == nil then 
        return nil         
    end
    return string.sub(dataType,1,i-1)
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