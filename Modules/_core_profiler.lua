PROFILER_DEF_DATA = {}
PROFILERS_ALIASES = {
    record_time = 'rt'
    ,record_dps = 'rd'
    ,record_victories = 'rv'
    ,record_wipes = 'rw'
    ,record_flees = 'rf'
}

function init_profiler()
    for _,v in pairs(BOSS_DATA) do
        v.records = {}
        for i,_ in pairs(v.diff.avail) do
            v.records[i] = {
                record_time = 0
                ,record_dps = 0.0
                ,record_victories = 0
                ,record_wipes = 0
                ,record_flees = 0
            }
        end
    end

    local tbl = PROFILERS_ALIASES
    for i,v in pairs(tbl) do
        PROFILERS_ALIASES[v] = i
    end
    tbl = nil

    PROFILER_DEF_DATA.bossDifficulties = get_BossDifficulties_Data()
    PROFILER_DEF_DATA.bossRecords = get_BossRecords_Data()
    PROFILER_DEF_DATA.talents = get_HeroTalents_Data_Default()
    init_profiler = nil
end

function flush_profiler()
    PROFILER_DEF_DATA = nil
    get_HeroTalents_Data_Default = nil
    inject_Data = nil
    parse_bossDifficulties = nil
    parse_bossRecords = nil
    parse_talents = nil
    load_Profile = nil
    HERO_LoadProfile = nil
    flush_profiler = nil
    TALENTS_ApplyProfilerData = nil
end

function get_BossDifficulties_Data()
    local _data = ""
    for i,v in pairs(BOSS_DATA) do
        _data = _data .. i .. ":"
        for j,bool in pairs(v.diff.defeated) do
            _data = _data .. j .. "=" .. tostring(bool) .. "|"
        end
        _data = _data .. ';'
    end

    return _data
end

function get_BossRecords_Data()
    local _data = ""
    for i,v in pairs(BOSS_DATA) do
        _data = _data .. i .. ":"
        for d_i,d in pairs(v.records) do
            _data = _data .. d_i .. "/"
            for j,val in pairs(d) do
                _data = _data .. PROFILERS_ALIASES[j] .. "=" .. tostring(val) .. "|"
            end
            _data = _data .. '*'
        end
        _data = _data .. ';'
    end

    return _data
end

function get_HeroTalents_Data_Default()
    local tbl = {}
    for i=1,2 do
        tbl[i] = {}
        for j=1,10 do
            tbl[i][j] = false
        end
    end 

    return tbl
end

function get_HeroTalents_Data()
    local _data = ""
    for tree_i,tals in pairs(TALENTS_TABLE) do
        _data = _data .. tree_i .. ":"
        for j,bool in pairs(tals) do
            _data = _data .. j .. "=" .. tostring(bool.Enabled) .. "|"
        end
        _data = _data .. ';'
    end

    return _data
end

function parse_bossDifficulties(str)
    local m_tbl = {}
    for _,data in pairs(string_split(str,';')) do
        local i,_= data:find(':',1)
        local b_id = math.tointeger(data:sub(1,i-1))
        data = data:sub(i+1)
        data = string_split(data,'|')
        m_tbl[b_id] = {}
        for _,v in pairs(data) do
            i,_ = v:find('=',1)
            local d_id = math.tointeger(v:sub(1,i-1))
            local d_val = toboolean[v:sub(i+1)]
            m_tbl[b_id][d_id] = d_val
        end
    end

    return m_tbl
end

function parse_bossRecords(str)
    local m_tbl = {}
    for _,data in pairs(string_split(str,';')) do
        local i,_= data:find(':',1)
        local b_id = math.tointeger(data:sub(1,i-1))
        data = data:sub(i+1)
        m_tbl[b_id] = {}
        for _,d in pairs(string_split(data,'*')) do
            i,_ = d:find('/',1)
            local d_id = math.tointeger(d:sub(1,i-1))
            d = d:sub(i+1)
            m_tbl[b_id][d_id] = {}
            for _,v in pairs(string_split(d,'|')) do
                i,_ = v:find('=',1)
                local r_id = v:sub(1,i-1)
                local r_val = tonumber(v:sub(i+1))
                m_tbl[b_id][d_id][r_id] = r_val
            end
        end
    end

    return m_tbl
end

function parse_talents(str)
    local m_tbl = {}
    for _,data in pairs(string_split(str,';')) do
        local i,_= data:find(':',1)
        local b_id = math.tointeger(data:sub(1,i-1))
        data = data:sub(i+1)
        data = string_split(data,'|')
        m_tbl[b_id] = {}
        for _,v in pairs(data) do
            i,_ = v:find('=',1)
            local d_id = math.tointeger(v:sub(1,i-1))
            local d_val = toboolean[v:sub(i+1)]
            m_tbl[b_id][d_id] = d_val
        end
    end
    
    return m_tbl
end

function inject_Data(tbl)
    --DIFFICULTIES
    for b_id,diff in pairs(parse_bossDifficulties(tbl.bossDifficulties)) do
        for diff_id,bool in pairs(diff) do
            BOSS_DATA[b_id].diff.defeated[diff_id] = bool
        end
    end

    --RECORDS
    for b_id,d_t in pairs(parse_bossRecords(tbl.bossRecords)) do
        for d_id,r_t in pairs(d_t) do
            for r_id,r_val in pairs(r_t) do
                BOSS_DATA[b_id].records[d_id][PROFILERS_ALIASES[r_id]] = r_val
            end
        end
    end

    --TALENTS
    PROFILER_DEF_DATA.talentsParsed = parse_talents(tbl.talents)
end

function TALENTS_ApplyProfilerData()
    for m_i,_ in pairs(PROFILER_DEF_DATA.talentsParsed) do
        for c_i,t in pairs(PROFILER_DEF_DATA.talentsParsed) do
            for t_i,bool in pairs(t) do
                if m_i ~= c_i and PROFILER_DEF_DATA.talentsParsed[m_i][t_i] and bool then
                    print('Looks like there are multiple talents of same tier activated in your profile file. Talents will not be loaded. Cheating is not allowed.')
                    return
                end
            end
        end
    end

    for tree_i,tree in pairs(PROFILER_DEF_DATA.talentsParsed) do
        for t_i,bool in pairs(tree) do
            if TALENTS_TABLE[tree_i] and TALENTS_TABLE[tree_i][t_i] and bool then
                TALENTS_ApplyTalent(tree_i,t_i)
            end
        end
    end
end

function load_Profile(HERO_TYPE)
    local data = {
        bossDifficulties = FileIO:Read(HERO_DATA[HERO_TYPE].data_files.bossDifficulties)
        ,bossRecords = FileIO:Read(HERO_DATA[HERO_TYPE].data_files.bossRecords)
        ,talents = FileIO:Read(HERO_DATA[HERO_TYPE].data_files.talents)
    }
    for i,v in pairs(data) do
        v = v == "" and PROFILER_DEF_DATA[i] or v
    end
    inject_Data(data)
end

function save_Profile(HERO_TYPE)
    local data = {
        bossDifficulties = get_BossDifficulties_Data()
        ,bossRecords = get_BossRecords_Data()
        ,talents = get_HeroTalents_Data()
    }
    for i,v in pairs(data) do
        FileIO:Write(HERO_DATA[HERO_TYPE].data_files[i], v)
    end
end

function HERO_SaveProfile()
    save_Profile(HERO_TYPE)
end

function HERO_LoadProfile()
    load_Profile(HERO_TYPE)
end