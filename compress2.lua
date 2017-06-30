local t = require('tools')

getmetatable('').__index = function(str,i) return string.sub(str,i,i) end -- index strings
getmetatable('').__call = string.sub -- substring

local data = io.open('C:/Users/Imperial/Documents/compr_o.txt','rb'):read('*a')
local dictionary = {}
local dictionaryl = 1
local dictionaryi = 1

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

local function compress()
  print('initializing dictionary...')
  -- init table
  local dictionary_header = ''
  for i = 1, 255 do
    dictionary_header = dictionary_header .. string.char(i)
    dictionary[string.char(i)] = tohex(1)(2,2) .. tohex(i)
    dictionaryi = i
  end
  
  print('encoding...')
  -- encode
  local pos = 1
  local dsize = 4194304 -- 4mb dictionary limit
  local encoded = ''
  local temp_enc = ''
  while pos <= #data do
    -- get longest match
    local lm = dictionaryl
    local chunk = ''
    repeat
      chunk = data(pos,pos+lm-1)
      if dictionary[chunk] then
        local olap = tonumber(dictionary[chunk][1],16) + tonumber(dictionary[chunk](2),16)
        if olap < (pos+#dictionary_header) then
          break
        end
      end
      lm = lm - 1
    until lm == -1
    if lm == -1 then error('no match') end
    --
    if ((pos/(#data*2))*100)%5 <= 0.002 then
      print( math.floor((pos/(#data*2))*100) )
    end
    -- encode
    local key = dictionary[chunk]
    local keysize = tohex(#key)(2,2)
    if keysize == '0' then error('keysize error') end
    temp_enc = temp_enc .. keysize .. key
    -- increment position
    pos = pos + (lm)
    -- add current match plus neighbor character
    local newd = chunk..data[pos]
    if (not dictionary[newd]) and (dictionaryi <= dsize) and (#newd <= 15) then
      dictionaryi = dictionaryi + 1
      dictionary[newd] = tohex(#newd)(2,2) .. tohex((pos + #dictionary_header) - (lm))
      if #newd > dictionaryl then dictionaryl = #newd end
    end
    -- in-situ conversion
    if (#temp_enc % 2) == 0 then
      temp_enc = '-' .. temp_enc
      local tmp = ''
      for i = 1, (#temp_enc/2) do
        tmp = tmp .. string.char(tonumber(temp_enc(i*2,(i*2)+1),16))
      end
      encoded = encoded .. tmp
      temp_enc = ''
    end
  end
  -- convert rest of data
  local retval = ''
  if temp_enc ~= '' then
    repeat
      temp_enc = temp_enc .. '0'
    until (#temp_enc%2) == 0
    temp_enc = '-' .. temp_enc
    for i = 1, (#temp_enc/2) do
      retval = retval .. string.char(tonumber(temp_enc(i*2,(i*2)+1),16))
    end
    retval = encoded .. retval
  else
    retval = encoded
  end
  
  -- writing
  print('writing...')
  local fh_enc = io.open('C:/Users/Imperial/Documents/compr_e.txt','wb')
  fh_enc:write(retval)
  fh_enc:close()
  
  print('done')
end

-- decompressing
local function decompress()
  print('Initializing buffer...')
  local rawdata = io.open('C:/Users/Imperial/Documents/compr_e.txt','rb'):read('*a')
  local rawpos = 1
  local mstring = ''
  for i = 1, 32 do
    mstring = mstring .. tohex(string.byte(rawdata[rawpos]))
    rawpos = rawpos + 1
  end
  
  -- setup dictionary
  print('initializing dictionary...')
  local init_dict = ''
  for i = 1, 255 do
    init_dict = init_dict .. string.char(i)
  end
  mstring = init_dict .. mstring
  
  -- decode
  print('decoding...')
  local pos = #init_dict + 1
  local temp = init_dict
  while pos < #mstring do
    -- get key size
    local keysize = tonumber(mstring[pos],16)
    if (not keysize) or keysize == 0 then print('Nul key') break end
    -- get key
    local key = mstring(pos+1,(pos+1)+keysize-1)
    if (#mstring(pos+1,(pos+1)+keysize-1)) ~= keysize then print('Wrong keysize') break end
    -- break key
    local word_len = tonumber(key[1],16)
    local pointer = tonumber(key(2),16)
    --
    if ((pos/(#rawdata*2))*100)%5 <= 0.002 then
      print( math.floor((pos/(#rawdata*2))*100) )
    end
    --print(pos..'/'..#mstring..'/'..(#rawdata*2))
    --print(keysize..':'..key)
    --print(word_len..':'..pointer)
    --print(temp(pointer,pointer+word_len-1))
    -- decode
    temp = temp .. temp(pointer,pointer+word_len-1)
    -- adv
    pos = pos + keysize + 1
    -- in-situ conversion
    if (pos >= #mstring-16) and (rawpos <= #rawdata)then
      for i = 1, 32 do
        if rawpos > #rawdata then break end
        mstring = mstring .. tohex(string.byte(rawdata[rawpos]))
        rawpos = rawpos + 1
      end
    end
  end
  
  print('writing...')
  io.open('C:/Users/Imperial/Documents/compr_d.txt','wb'):write(temp(256))
  
  print('done')
end

--compress()
decompress()

