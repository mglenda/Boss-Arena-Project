----------------------------------------------------
----------------------------------------------------
----------------------------------------------------

DEF_CAM_DISTANCE = 2900.0
DEF_CAM = CreateCameraSetup()

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