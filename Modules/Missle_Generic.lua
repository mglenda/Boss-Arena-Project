----------------------------------------------------
---------------MISSLE SYSTEM SETUP------------------
----------------------------------------------------

function MISSLE_Impact(missle)
    DestroyEffectBJ(missle)
end 

function MISSLE_CreateMissleXY(miss_id,x,y,facing)
    local eff = oldAddSpecialEffect(MISSLE_DATA[miss_id].model, x, y)
    BlzSetSpecialEffectScale(eff, MISSLE_DATA[miss_id].scale)
    BlzSetSpecialEffectYaw(eff, (facing or 270.0) * bj_DEGTORAD)
    BlzSetSpecialEffectZ(eff, MISSLE_DATA[miss_id].height)
    return eff,MISSLE_DATA[miss_id].height
end

function MISSLE_GetXY(missle)
    return BlzGetLocalSpecialEffectX(missle),BlzGetLocalSpecialEffectY(missle)
end