local serialize = require('lib/serialize')

local test = {
  n = 20,
  [1] = {height = 20},
  [2] = {height = 18},
  [3] = {height = 19},
  [4] = {height = 21},
  [5] = {height = 22},
  [6] = {height = 23},
  [7] = {height = 30},
  [8] = {height = 31},
  [9] = {height = 35},
  [10] = {height = 42},
  [11] = {height = 44},
  [12] = {height = 28},
  [13] = {height = 23},
  [14] = {height = 20},
  [15] = {height = 18},
  [16] = {height = 17},
  [17] = {height = 19},
  [18] = {height = 8},
  [19] = {height = 13},
  [20] = {height = 18},
}

local function terraingen(res, range, init, min)
  init =  init or 0
  range = range or 5
  min = min or 10
  local retval = {n = res,[0] = {height = init}}
  for i = 1, res do
    local prev = retval[i-1].height
    local low = prev - range
    local high = prev + range
    if low < min then low = min end
    local rval = math.random(low, high)
    retval[i] = {height = rval}
  end
  table.remove(retval,0)
  return retval
end

local function collisioncheck(old,new)
  for i = 1, new.n do
    if new[i].height < old[i].height then
      print('Collision detected at '..i..'!')
      print('Old height: '..old[i].height..'   New height: '..new[i].height)
    end
  end
end

local function visualize(arr)
  for i = 1, arr.n do
    local str = ''
    for n = 1, arr[i].height do
      str = str .. '#'
    end
    print(string.format('%02d',i) .. ': ' .. str .. '    ['..arr[i].height..']')
  end
end

-- Terrain Avoidance
-- return: recommended flight height
local function GetRecommendedFlightHeight(I,heightmap,flightheight)
  local recommendedheight = flightheight or 15
  for i = 1, heightmap.n do
    if heightmap[i].height >= recommendedheight then
      recommendedheight = heightmap[i].height + 5
    end
  end
  return recommendedheight
end

-- Flight Path Planner
local function GetCruisePathOverTerrain(heightmap,flightheight,cycles)
  local function proc()
    heightmap[heightmap.n+1] = heightmap[heightmap.n]
    heightmap[0] = heightmap[1]
    local maxp = {n = 0}
    local retval = {n = 0}
    for i = 1, heightmap.n do
      local curp,lastp,nextp = heightmap[i].height, heightmap[i-1].height, heightmap[i+1].height
      if (curp >= lastp) and (curp >= nextp) then
        table.insert(maxp,{node = i,height = curp}) maxp.n = maxp.n + 1
      end
    end
    if maxp[1].node ~= 1 then
      table.insert(maxp,1,{node = 1,height = heightmap[1].height})
      maxp.n = maxp.n + 1
    end
    if maxp[maxp.n].node ~= heightmap.n then
      table.insert(maxp,{node = heightmap.n,height = heightmap[heightmap.n].height})
      maxp.n = maxp.n + 1
    end
    table.insert(maxp,{node = heightmap.n+1,height = heightmap[heightmap.n].height})
    --print(serialize(maxp))
    for i = 1, maxp.n do
      local ndiff = maxp[i+1].node - maxp[i].node
      local slope = (maxp[i+1].height-maxp[i].height) / (ndiff)
      for k = 1, ndiff do
        local sheight = math.ceil((slope*(k-1)) + maxp[i].height)
        table.insert(retval,{height = sheight + flightheight})
        retval.n = retval.n + 1
      end
    end
    return retval
  end
  cycles = cycles or 1
  if flightheight < 0 then flightheight = 0 end
  for i = 1, cycles do
    heightmap = proc()
  end
  return heightmap
end
-- 219,2345,1845
math.randomseed(2345)
test = terraingen(200,4,10,5)

--collisioncheck(test,GetCruisePathOverTerrain(test,0,1))

--visualize(test)
--print('res:')
--visualize(GetCruisePathOverTerrain(test,0,2))
--visualize(terraingen(200,4,10,5))