----------------------------------------------------
---------------MOVESPEED SYSTEM SETUP---------------
----------------------------------------------------

MSX_PERIOD = 0.00625
MSX_MARGIN = 0.01

MS_MAX_MOVESPEED = 1000
MS_MIN_MOVESPEED = 0

function ApproxEqual (A,B)
    return (A >= (B - MSX_MARGIN)) and (A <= (B + MSX_MARGIN))
end

MOVESPEED_X_TABLE = {}
MOVESPEED_X_ISSUED_TRIGGER = CreateTrigger()
MOVESPEED_X_TRIGGER = CreateTrigger()

function MSX_Initialize()
    TriggerRegisterTimerEventPeriodic(MOVESPEED_X_TRIGGER, MSX_PERIOD)
    TriggerAddAction(MOVESPEED_X_TRIGGER, MSX_Periodic)
    TriggerRegisterAnyUnitEventBJ(MOVESPEED_X_ISSUED_TRIGGER, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
    TriggerAddAction(MOVESPEED_X_ISSUED_TRIGGER, MSX_storeOrderPoint)

    MSX_Initialize = nil
end

function MSX_Periodic()
    local u,order,d,dy,dx,ny,nx = nil,nil,nil,nil,nil,nil,nil
    for i,t in pairs(MOVESPEED_X_TABLE) do
        u = t.unit
        nx,ny = GetUnitXY(u)
        if not(IsUnitAliveBJ(u)) or GetUnitTypeId(u) == 0 then
            MOVESPEED_X_TABLE[i] = nil
        elseif not(ApproxEqual(nx, t.x)) or not(ApproxEqual(ny, t.y)) then
            if not(IsUnitPaused(u)) then
                order = GetUnitCurrentOrder(u)
                dx = nx - t.x
                dy = ny - t.y
                d  = SquareRoot(dx * dx + dy * dy)
                dx = dx / d * t.speed 
                dy = dy / d * t.speed
                if (order == 851986 or order == 851971) and (t.ox - nx)*(t.ox - nx) < (dx*dx) and (t.oy - ny)*(t.oy - ny) < (dy*dy) then
                    SetUnitX(u, t.ox) 
                    SetUnitY(u, t.oy)
                    t.x = t.ox
                    t.y = t.oy 
                    IssueImmediateOrderById(u, 851972)
                else
                    t.x = nx + dx
                    t.y = ny + dy
                    SetUnitX(u, t.x)
                    SetUnitY(u, t.y)
                end
            end
        end
    end
    if tableLength(MOVESPEED_X_TABLE) == 0 then
        if IsTriggerEnabled(MOVESPEED_X_TRIGGER) then
            DisableTrigger(MOVESPEED_X_TRIGGER)
        end
    end
end

function MSX_storeOrderPoint()
    local u_id = GetHandleIdBJ(GetTriggerUnit())
    if MOVESPEED_X_TABLE[u_id] then
        MOVESPEED_X_TABLE[u_id].ox = GetOrderPointX()
        MOVESPEED_X_TABLE[u_id].oy = GetOrderPointY()
    end
end

function MSX_Create (whichUnit,newSpeed)
    local u_id = GetHandleIdBJ(whichUnit)
    MOVESPEED_X_TABLE[u_id] = MOVESPEED_X_TABLE[u_id] or {
        unit = whichUnit
        ,x = GetUnitX(whichUnit)
        ,y = GetUnitY(whichUnit)
    }
    MOVESPEED_X_TABLE[u_id].speed = (newSpeed - 522) * MSX_PERIOD
    if not(IsTriggerEnabled(MOVESPEED_X_TRIGGER)) then
        EnableTrigger(MOVESPEED_X_TRIGGER)
    end
end

function MSX_Update (whichUnit,newSpeed)
    local u_id = GetHandleIdBJ(whichUnit)
    if newSpeed > 522 then
        MSX_Create(whichUnit,newSpeed)
    else
        MOVESPEED_X_TABLE[u_id] = nil
    end
end

function GetUnitMoveSpeed(whichUnit)
    local u_id = GetHandleIdBJ(whichUnit)
    if MOVESPEED_X_TABLE[u_id] then
        return (MOVESPEED_X_TABLE[u_id].speed / MSX_PERIOD) + 522
    end
    return oldGetUnitMS(whichUnit)
end

function SetUnitMoveSpeed(whichUnit,newSpeed)
    oldSetUnitMS(whichUnit, newSpeed)
    MSX_Update(whichUnit, newSpeed)
end