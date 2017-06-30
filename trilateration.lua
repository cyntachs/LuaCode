local vector = require('lib/vector')

local pos1 = vector(0,1,0)
local pos2 = vector(0,5,8)
local pos3 = vector(7,1,7)
local unk = vector(3,1,4)
local dist1 = pos1:distance(unk)
local dist2 = pos2:distance(unk)
local dist3 = pos3:distance(unk)
pos1 = pos1 + vector(0,0,0,dist1)
pos2 = pos2 + vector(0,0,0,dist2)
pos3 = pos3 + vector(0,0,0,dist3)

function trilat_location(c1,c2,c3)
  local d1 = c1.w;local d2 = c2.w;local d3 = c3.w
  c1.w = 0;c2.w = 0;c3.w = 0
  local function sq(n) return n*n end
  local ab = c2 - c1
  local ac = c3 - c1
  if math.abs( ab:normalize():dot( ac:normalize() ) ) > 0.999 then
    return nil
  end
  
  local d = #ab
  local ex = ab:normalize()
  local i = ex:dot(ac)
  local ey = (ac - (ex * i)):normalize()
  local j = ey:dot(ac)
  local ez = ex:cross(ey)
  
  local x = (sq(d1) - sq(d2) + sq(d)) / (2*d)
  local y = (sq(d1) - sq(d3) - sq(x) + sq(x-i) + sq(j)) / (2*j)
  
  local result = c1 + (ex*x) + (ey*y)
  
  local zsq = sq(d1) - sq(x) - sq(y)
  if zsq > 0 then
    local z = math.sqrt(zsq)
    local res1,res2 = result + (ez * z), result - (ez * z)
    local r1,r2 = res1:round(0.01),res2:round(0.01)
    if r1 ~= r2 then
      return r1,r2
    else
      return r1
    end
  end
  
  return result:round(0.01)
end

print('pos1: ' .. tostring(pos1))
print('pos2: ' .. tostring(pos2))
print('pos3: ' .. tostring(pos3))
print('unknown: ' .. tostring(unk))
print('distance: '..dist1..','..dist2..','..dist3)


print(trilat_location(pos1,pos2,pos3))