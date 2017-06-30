local t = require('tools')

getmetatable('').__index = function(str,i) return string.sub(str,i,i) end -- index strings
getmetatable('').__call = string.sub -- substring

local mstring = io.open('A:/Documents/compr_o.txt','r'):read('*a')
local dictionary = {}
local dictionaryl = 1
local dictionaryi = 1

local used_keys = {}

print('initializing dictionary...')
-- init table
for i = 1, 255 do
  dictionary[string.char(i)] = i
  dictionaryi = i
end

print('encoding...')
local function tohex(num)
  local hextable = {'1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}; hextable[0] = '0'
  local hex = ''
  local q = num
  repeat
    local i,f = math.modf(q/16)
    hex = hextable[16 * f] .. hex
    q = i
  until q <= 15
  hex = hextable[q] .. hex
  return hex
end
-- encode
local pos = 1
local dsize = 4194304 -- 4mb dictionary limit
local encode = ''
local lvl = 1
while pos < #mstring do
  -- get longest match
  local lm = dictionaryl
  local chunk = ''
  repeat
    chunk = mstring(pos,pos+lm-1)
    lm = lm - 1
  until dictionary[chunk] or lm == -1
  if lm == -1 then error('no match') end
  -- encode
  used_keys[dictionary[chunk]] = true
  local key = tohex(dictionary[chunk])
  local keysize = tohex(#key)(2,2)
  if keysize == '0' then error('keysize error') end
  encode = encode .. keysize .. key
  -- increment position
  pos = pos + (lm+1)
  -- add current match plus neighbor character
  local newd = chunk..mstring[pos]
  if (not dictionary[newd]) and (dictionaryi <= dsize) then
    dictionaryi = dictionaryi + 1
    dictionary[newd] = dictionaryi
    if #newd > dictionaryl then dictionaryl = #newd end
  end
end

-- culling dictionary
print('culling dictionary...')
local rkn = 0
for k,v in pairs(dictionary) do
  if not used_keys[v] then
    dictionary[k] = nil
    rkn = rkn + 1
  end
end
print('removed '..rkn..' unused keys')

local dtable_t = {}
for k,v in pairs(dictionary) do
  dtable_t[v] = k
end

-- convert to bin and write
print('preparing compressed data...')
local retval = ''
while (#encode%2) == 0 do
  encode = encode .. 'F'
end
encode = '-' .. encode
for i = 1, (#encode/2) do
  retval = retval .. string.char(tonumber(encode(i*2,(i*2)+1),16))
end

-- writing
print('writing...')
local fh_enc = io.open('A:/Documents/compr_e.txt','wb')
fh_enc:write(retval)
fh_enc:close()

print('done')

-- decompressing
print('converting to hex...')
local mstring = io.open('A:/Documents/compr_e.txt','rb'):read('*a')
local tmp = ''
for i = 1, #mstring do
  tmp = tmp .. tohex(string.byte(mstring[i]))
end
mstring = tmp

-- setup dictionary
print('constructing dictionary...')
local dtabled = {}
for k,v in pairs(dictionary) do
  dtabled[v] = k
end

-- decode
print('decoding...')
local pos = 1
local temp = ''
while pos < #mstring do
  -- get key size
  local keysize = tonumber(mstring[pos],16)
  if (not keysize) or keysize == 0 then break end
  -- get key
  local key = tonumber(mstring(pos+1,(pos+1)+keysize-1),16)
  if (#mstring(pos+1,(pos+1)+keysize-1)) ~= keysize then break end
  -- decode
  temp = temp .. dtabled[key]
  -- adv
  pos = pos + keysize + 1
end

print('writing...')
io.open('A:/Documents/compr_d.txt','w'):write(temp)

print('done')
io.read()