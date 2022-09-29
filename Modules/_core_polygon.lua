function Point(x,y)
    return {x = x, y = y}
end

function Line(sx,sy,ex,ey)
    return {
        start_X = sx
        ,start_Y = sy
        ,end_X = ex
        ,end_Y = ey
    }
end

function Polygon(...)
    local points,polygon = {...},{}
    for i,p in ipairs(points) do
        if type(p) == "table" and p.x and p.y then
            table.insert(polygon,p)
        end
    end
    return polygon
end

function Get_PolygonMaxMin_XY(Polygon)
    if type(Polygon) == "table" then
        local max_X,max_Y,min_X,min_Y = Polygon[1].x,Polygon[1].y,Polygon[1].x,Polygon[1].y
        for i,p in pairs(Polygon) do
            max_X = p.x > max_X and p.x or max_X
            max_Y = p.y > max_Y and p.y or max_Y
            min_X = p.x < min_X and p.x or min_X
            min_Y = p.y < min_Y and p.y or min_Y
        end
        return max_X,max_Y,min_X,min_Y
    end
    return nil,nil,nil,nil
end

function Get_RandomPointInPolygon(Polygon)
    local hx,hy,lx,ly = Get_PolygonMaxMin_XY(Polygon)
    local x,y
    if hx and hy and lx and ly then
        x,y = GetRandomReal(lx, hx),GetRandomReal(ly, hy)
        if not(IsInPolygon(Point(x,y),Polygon)) then
            x,y = Get_RandomPointInPolygon(Polygon)
        end
    end
    return x,y
end

function IsLineCrossingPolygon(line,polygon)
    local x,y = line.start_X,line.start_Y
    local rad = MATH_GetRadXY(line.start_X,line.start_Y,line.end_X,line.end_Y)
    local dist = round(MATH_GetDistance(x,y,line.end_X,line.end_Y),0)
    for i = dist,1,-1 do
        if IsInPolygon(Point(x,y),polygon) then
            return x,y
        else
            x,y = MATH_MoveXY(x,y,1.0,rad)
        end
    end
    return nil,nil
end

function IsInPolygon(p,polygon)
    local minX,minY,maxX,maxY = polygon[1].x,polygon[1].y,polygon[1].x,polygon[1].y
    for i,q in ipairs(polygon) do
        minX,maxX,minY,maxY = math.min(q.x,minX),math.max(q.x,maxX),math.min(q.y,minY),math.max(q.y,maxY)
    end
    if p.x < minX or p.x > maxX or p.y < minY or p.y > maxY then
        return false
    end 

    -- Part 2, logic behind this is explained here https://wrf.ecse.rpi.edu/Research/Short_Notes/pnpoly.html
    local inside = false
    local j = #polygon
    for i,q in ipairs(polygon) do
        if (q.y > p.y) ~= (polygon[j].y > p.y) and p.x < (polygon[j].x - q.x) * (p.y - q.y) / (polygon[j].y - q.y) + q.x then
            inside = not(inside)
        end
        j = i
    end
    return inside
end