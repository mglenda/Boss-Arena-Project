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