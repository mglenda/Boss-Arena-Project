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