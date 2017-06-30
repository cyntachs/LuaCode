local s = require('lib/serialize')

local function ftohex(num)
  local hextable = {'1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}; hextable[0] = '0'
  local hex = ''
  local q = num
  repeat
    local i,f = math.modf(q*16)
    hex = hex .. hextable[i]
    q = f
  until q == 0
  return hex
end

local count = 0
local tstring
local tried = {}


local in_f = io.open('C:/Users/Imperial/Documents/compr_h.txt','r')
local data = in_f:read('*a')
in_f:close()

tstring = '13AC317A31'

-- init and create probability table
local ptable = {} -- probability table
local rtable_low = {} -- range table (low)
local rtable_high = {} -- range table (high)
local chr = {n = 0} --  order

for i = 1, #data do
  local ch = data:sub(i,i)
  if ptable[ch] == nil then
    ptable[ch] = 1
    rtable_low[ch] = 0
    rtable_high[ch] = 0
    table.insert(chr,ch)
    chr.n = chr.n + 1
  else
    ptable[ch] = ptable[ch] + 1
  end
end
for k,v in pairs(ptable) do
  ptable[k] = v / #data
end
print("probabilities:")
--print(s.serialize(ptable))
for k,v in pairs(ptable) do
  print(k..' = '..ftohex(v))
end
print('order:')
table.sort(chr)
print(s.serialize(chr))

-- create range
print("range:")
local range_low,range_high = -1,1 --24^(#tstring)
print('low:  '..range_low)
print('high: '..range_high)

-- init low and high ranges
for i = 1, chr.n do
  if i == 1 then
    rtable_low[chr[i]] = range_low
    rtable_high[chr[i]] = range_high * ptable[chr[i]]
  else
    rtable_low[chr[i]] = rtable_high[chr[i-1]]
    rtable_high[chr[i]] = (range_high * ptable[chr[i]]) + rtable_high[chr[i-1]]
  end
end
print('subranges:')
for i = 1, chr.n do
  print(''..chr[i]..': ['..rtable_low[chr[i]]..'-'..rtable_high[chr[i]]..']')
end

-- encode
print('\nencode:')
for i = 1, #tstring do
  local ch = tstring:sub(i,i)
  if i == #tstring then
    range_low = rtable_low[ch]
    range_high = rtable_high[ch]
    break
  end
  range_low = rtable_low[ch]
  range_high = rtable_high[ch]
  -- recalc subranges
  for i = 1, chr.n do
    if i == 1 then
      rtable_low[chr[i]] = range_low
      rtable_high[chr[i]] = ((range_high - range_low) * ptable[chr[i]]) + range_low
    else
      rtable_low[chr[i]] = rtable_high[chr[i-1]]
      rtable_high[chr[i]] = ((range_high - range_low) * ptable[chr[i]]) + rtable_high[chr[i-1]]
    end
  end
  print('subranges for '..ch..':')
  for i = 1, chr.n do
    print(''..chr[i]..': ['..rtable_low[chr[i]]..'-'..rtable_high[chr[i]]..']')
  end
end
print('end range: ['..range_low..'-'..range_high..']')
--print('end range: [0x'..ftohex(range_low)..'-0x'..ftohex(range_high)..']')
--print('difference high: '..math.abs(math.floor(tonumber(tostring(range_high):sub(1,3)))-math.floor(tonumber(tostring(range_low):sub(1,3)))))
--print('difference low:  '..math.abs(math.floor(tonumber(tostring(range_high):sub(4,6)))-math.floor(tonumber(tostring(range_low):sub(4,6)))))
count = count + 1
print('count: '..count..' string: '..tstring..' difference: '..tostring(range_high - range_low))

--local fh_enc = io.open('C:/Users/Imperial/Documents/compr_e.txt','wb')
--fh_enc:write(retval)
--fh_enc:close()

