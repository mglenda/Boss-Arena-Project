PROFILER_DEF_DATA = nil

function init_profiler()
    PROFILER_DEF_DATA = get_BossData()
    init_profiler = nil
end

function get_BossData()
    local _data = ""
    for i,v in pairs(BOSS_DATA) do
        _data = _data .. i .. ":"
        for j,bool in pairs(v.diff.defeated) do
            _data = _data .. j .. "=" .. tostring(bool) .. "|"
        end
        _data = _data .. ';'
    end
    _data = _data .. "]"
    return _data
end

function load_BossData(str)
    local m_tbl = {}
    local tbl = string_split(str,';')
    for _,data in pairs(tbl) do
        local d_tbl = {}
        local i,_= data:find(':',1)
        local b_id = math.tointeger(data:sub(1,i-1))
        data = data:sub(i+1)
        data = string_split(data,'|')
        for _,v in pairs(data) do
            i,_ = v:find('=',1)
            local d_id = math.tointeger(v:sub(1,i-1))
            local d_val = toboolean[v:sub(i+1)]
            d_tbl[d_id] = d_val
        end
        m_tbl[b_id] = d_tbl
        d_tbl = nil
    end

    for b_id,diff in pairs(m_tbl) do
        for diff_id,bool in pairs(diff) do
            BOSS_DATA[b_id].diff.defeated[diff_id] = bool
        end
    end
    m_tbl,tbl = nil,nil
end

function load_Profile(filename)
    local data = FileIO:Read(filename)
    data = data == "" and PROFILER_DEF_DATA or data
    data = string_split(data,']')
    load_BossData(data[1])
end

function save_Profile(filename)
    local data = get_BossData()
    FileIO:Write(filename, data)
end

function HERO_SaveProfile()
    save_Profile(HERO_DATA[HERO_TYPE].profile_filename)
end