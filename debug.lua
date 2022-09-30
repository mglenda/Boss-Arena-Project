_data = "4:1=false|2=false|3=false|;1:1=true|2=true|3=false|;2:1=true|2=true|3=false|;3:1=true|2=true|3=false|;]"

toboolean = {["true"]=true,["false"]=false,[1]=true,[0]=false}

function string_split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
      table.insert(Table,cap)
       end
       last_end = e+1
       s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
       cap = pString:sub(last_end)
       table.insert(Table, cap)
    end
    return Table
end

function load_BossData(str)
    local m_tbl = {}
    _data = string_split(str,';')
    for _,data in pairs(_data) do
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
    return m_tbl
end

function load_Profile(filename)
    local data = FileIO:Read("warlock.txt")
end

data = string_split(_data,']')
data_x = string_split(data[1],';')
load_BossData(data[1])
print('end')