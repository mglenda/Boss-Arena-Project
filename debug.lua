_data = "2:4=false|1=true|2=false|3=false|;1:4=false|1=false|2=false|3=false|;"
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
    --m_tbl,tbl = nil,nil
end

data = nil
if data[1] and data[2][3] then
    print(data[1][2][3])
end

load_BossData(_data)
print('end')