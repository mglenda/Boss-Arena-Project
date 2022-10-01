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

function instr(str,find)
    for i=1,string.len(str) do
        if string.sub(str,i,i) == find then
            return i
        end
    end
    return nil
end

function strRound(value,decplaces)
    local dot,s = instr(tostring(value),'.'),tostring(value)
    decplaces = decplaces and (not(dot) and decplaces == 0 and decplaces or (dot and decplaces or decplaces + 1)) or 0
    local decs = decplaces > 0 and (dot and '' or '.') or ''
    dot = decplaces > 0 and (dot or string.len(s)) or (dot and dot - 1 or string.len(s))
    for i=1,decplaces do
        decs = decs .. '0'
    end
    return string.sub(s .. decs,1,dot+decplaces)
end

function FromatSeconds(time,keepAll)
    time = time > 0 and time * 10 or 0
    local hours = math.floor(time/36000)
    time = time - math.floor(time/36000)*36000
    local minutes = strRound(time / 600,0)
    time = time - math.floor(time/600)*600
    local seconds = strRound(time / 10,0)
    time = time - math.floor(time/10)*10
    hours = (hours > 0 and strRound(hours,0) .. ':' or (keepAll and '00:' or ''))
    hours = (hours:len() == 2 and keepAll) and '0' .. hours or hours
    seconds = (minutes == '0' and seconds or ("0"..seconds):sub(-2)) .. '.' .. strRound(time,0)
    minutes = (minutes == '0' and (keepAll and '00:' or '') or minutes .. ':')
    minutes = (minutes:len() == 2 and keepAll) and '0' .. minutes or minutes
    return tostring(hours .. minutes .. seconds)
end

print(FromatSeconds(1212.3,true))