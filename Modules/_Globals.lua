---------------------
-----UNIT SYSTEM-----
---------------------
ALL_UNITS = {}
ALL_UNITS_DATA = {}

persistent_keys = {
    'energy'
    ,'energy_cap'
    ,'energy_theme'
    ,'u_id'
}

---------------------
---------------------

----------------------------------------------------
--------------------BOSS SYSTEM---------------------
----------------------------------------------------

BOSS_JOURNAL_BUTTON = nil
BOSS_JOURNAL_LISTENER = nil
BOSS_JOURNAL_TEXTURE = nil
BOSS_JOURNAL_MAINFRAME = nil
BOSS_JOURNAL_DATA = nil
BOSS_JOURNAL_WIDGETLISTENER = CreateTrigger()
BOSS_JOURNAL_DIFFICULTYLISTENER = CreateTrigger()

BOSS_DIFFICULTY_NORMAL = 1
BOSS_DIFFICULTY_HEROIC = 2
BOSS_DIFFICULTY_MYTHIC = 3
BOSS_DIFFICULTIES = {
    BOSS_DIFFICULTY_NORMAL
    ,BOSS_DIFFICULTY_HEROIC
    ,BOSS_DIFFICULTY_MYTHIC
}

BOSS_BEASTMASTER_ID = 1
BOSS_DRUID_ID = 2
BOSS_SHAMAN_ID = 3
BOSS_PLAGUE_CULT = 4

BOSS_DATA = nil

----------------------------------------------------
-------------------BOSS GENERIC---------------------
----------------------------------------------------

BOSS_TRIGGERS = {}
BOSSES = {}
BOSS_CREEPS = {}
BOSS_MISSLES = {}
BOSS_LIGHTINGS = {}
BOSS_EFFECTS = {}
FIGHT_DATA = {}
BOSS_ANIM_TIMERS = {}
BOSS_TIMERS = {}
BOSS_TIMERS_EXCLUSIVES = {}

BOSS_BAR = nil

BOSS_WIDGETS = {}
BOSS_WIDGETS_TARGET_TRIGGER = CreateTrigger()
BOSS_WIDGETS_REFRESH_TRIGGER = CreateTrigger()

SAFEZONE_LEAVING_TRIGGER = CreateTrigger()
ARENA_ACTIVATED = false
ARENA_FOG_MODIFIERS = {}

STARTING_ZONE = nil