-- RGimg
-- Raster graphic image file format
-- header: 0x0C (2 char), RGIMG (5 char), width(2char/4hex), height(2char/4hex), extra options (16 char)
-- header len: 27 char
local rgimg = {}
local vector = require('lib/vector')

local function tohex(num)
  local hextable = {'1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}; hextable[0] = '0'
  local hex = ''
  local q = num
  repeat
    local i,f = math.modf(q/16)
    hex = hextable[16 * f] .. hex
    q = i
  until q < 16
  hex = hextable[q] .. hex
  return hex
end

local function tonum(num)
  return tonumber(num,16)
end

local function encode(data)
  local retval = ''
  for i = 1, (#data/2) do
    retval = retval .. string.char(tonum(data:sub((i*2)-1,(i*2))))
  end
  return retval
end

local function decode(data)
  local retval = ''
  for i = 1, (#data) do
    retval = retval .. tohex(string.byte(data:sub(i,i)))
  end
  return retval
end

function rgimg.write(data)
  -- data must be a table
  local retval = ''
  repeat
    local i = 1
    local pix = tostring(data[i].x) .. tostring(data[i].y) .. tostring(data[i].z)
    retval = retval .. encode(pix)
  until i >= (data.width * data.height)
end

function rgimg.read(data)
  -- data must be a string
  if type(data) ~= 'string' then return false,'Unknown data provided as parameter.' end
  -- get header
  local header = data:sub(1,7) .. decode(data:sub(8,27))
  data = data:sub(28) -- remove header from data
  -- parse header
  if header:sub(1,2) ~= '0C' then return false,'Incorrect data format.' end
  if header:sub(3,7) ~= 'RGIMG' then  return false,'Incorrect data type.' end
  local width = tonum(header:sub(8,11))
  local height = tonum(header:sub(12,15))
  -- convert to table
  local len = width * height
  if #data ~= (len*3) then return false,'Incorrect data length.' end
  local res = {}
  local cp = 0
  repeat
    -- read every pixel and convert into vector
    local pdat = data:sub((cp*3)+1,(cp*3)+3)
    local pixel = vector(
        tonum(decode(pdat:sub(1,1))),
        tonum(decode(pdat:sub(2,2))),
        tonum(decode(pdat:sub(3,3)))
    )
    cp = cp + 1
    res[cp] = pixel
  until cp ==  len
  res.width = width
  res.height = height
  return res
end

local s = require('lib/serialize') -- debug
local test = '0002000200000000000000000000000000000000A26CC6B4907EA290C6D8D8D8' -- debug

test = '0CRGIMG' .. encode(test)

print('Raw(Bin): ' .. test)
print('Raw(Hex): ' .. test:sub(1,7) .. decode(test:sub(8)))
print(s(rgimg.read(test)))
