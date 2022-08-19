----------------------------------------------------
--------------STUNNING SYSTEM SETUP-----------------
----------------------------------------------------

function IsUnitDisabled(unit)
    return STUN_IsStunned(unit)
end

function STUN_IsStunned(unit)
    return BUFF_GetStacksCount(unit,'STUN') > 0
end

oldPauseUnitBJ = PauseUnitBJ
function PauseUnitBJ(pause, whichUnit)
    pause = not(pause) and not(BUFF_GetStacksCount(whichUnit,'STUN') == 0) or pause
    oldPauseUnitBJ(pause,whichUnit)
end

function StopUnitImmediate(unit)
    PauseUnitBJ(true, unit)
    PauseUnitBJ(false, unit)
    IssueImmediateOrderById(unit, 851972)
end

function STUN_StunUnit(unit,duration)
    local u_type = GetUnitTypeId(unit)
    if not(UNITS_DATA[u_type].STUN_IMMUNE) then
        PauseUnitBJ(true, unit)
        BUFF_AddDebuff_Stack({
            name = 'STUN'
            ,target = unit
            ,duration = duration
            ,endFunc = function()
                if BUFF_GetStacksCount(DEBUFFS[clr_buff_id].target,'STUN') == 1 then
                    oldPauseUnitBJ(false, DEBUFFS[clr_buff_id].target)
                end
            end 
        })
    end
    u_type = nil
end

function STUN_CleanAllStuns(unit)
    BUFF_UnitClearDebuffAllStacks(unit,'STUN')
end