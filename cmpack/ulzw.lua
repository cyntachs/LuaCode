local lzw = {}

local function hex(num) return string.format("%02x",num):upper() end
local function num(hex) return tonumber(hex,16) end
local function hex2char(hex) return utf8.char(num(hex) + 32) end
local function char2hex(chr) return hex(utf8.codepoint(chr) - 32) end
local function int2char(num) return utf8.char(num) end
local function char2int(chr) return utf8.codepoint(chr) end

local function usub(s,i,j)
  s = s:sub(utf8.offset(s,i)); j = j or utf8.len(s); local b = ''
  for c in s:gmatch(utf8.charpattern) do
    b = b .. c
    i = i + 1
    if i > j then break end
  end
  return b
end

local prevPr = 0
local function progress(c,t,print)
  local Pr = math.floor( (c/t)*100 )
  if Pr ~= prevPr and Pr%5 <= 0 then
    print(Pr)
    prevPr = Pr
  end
end

function lzw.compress(data, print)
  print = print or (function () end)
  -- dictionary variables
  local dictionary = {}
  local dictionary_len = 0
  local max_dictionary_len = 0xFFFFFFFFFFFFFFF
  local high_len = 1
  -- initialize dictionary
  for i = 1, 255 do
    dictionary[int2char(i)] = hex(#(hex(i))):sub(2,2) .. hex(i) -- [key size][key]
    dictionary_len = i
  end
  -- encode
  local pos = 1
  local out_buffer = ''
  local encoded = ''
  while pos <= #data do
    local block = ''
    local blocklen = high_len
    -- find longest block in dictionary
    repeat
      block = data:sub(pos,pos+blocklen-1)
      if dictionary[block] then
        break
      end
      blocklen = blocklen - 1
    until blocklen == -1
    if blocklen == -1 then error('dictionary error') end
    -- convert
    progress(pos, #data, print) -- progress
    out_buffer = out_buffer .. dictionary[block]
    pos = pos + blocklen
    -- add new entries to dictionary
    local newentry = block..data:sub(pos,pos)
    if (not dictionary[newentry]) and (dictionary_len <= max_dictionary_len) then
      dictionary_len = dictionary_len + 1
      dictionary[newentry] = hex(#(hex(dictionary_len))):sub(2,2) .. hex(dictionary_len)
      if #newentry > high_len then high_len = #newentry end
    end
    -- hex to char conversion
    if (#out_buffer % 2) == 0 then
      out_buffer = '-'.. out_buffer
      local t = ''
      for i = 1, (#out_buffer/2) do
        t = t .. hex2char(out_buffer:sub(i*2,(i*2)+1))
      end
      encoded = encoded .. t
      out_buffer = ''
    end
  end
  -- hex to char conversion of whats left
  local retval = ''
  if out_buffer ~= '' then
    repeat
      out_buffer = out_buffer .. '0'
    until (#out_buffer%2) == 0
    out_buffer = '-'..out_buffer
    for i = 1, (#out_buffer/2) do
      retval = retval .. hex2char(out_buffer:sub(i*2,(i*2)+1))
    end
    retval = encoded .. retval
  else
    retval = encoded
  end
  return retval
end

function lzw.decompress(data, print)
  print = print or (function() end)
  -- dictionary variables
  local dictionary = {}
  local dictionary_len = 0
  local high_len = 1
  -- initialize dictionary
  for i = 1, 255 do
    dictionary[hex(i)] = int2char(i)
    dictionary_len = i
  end
  -- char to hex conversion of first 32 chars
  local hexstr = ''
  local rawpos = 1
  for i = 1, 32 do
    local ht = char2hex(usub(data,rawpos,rawpos))
    hexstr = hexstr .. ht
    rawpos = rawpos + 1
  end
  -- decode
  local pos = 1
  local previous = ''
  local out_buffer = ''
  local decoded = ''
  while pos <= #hexstr do
    -- get key size
    local keysize = num(hexstr:sub(pos,pos))
    if (not keysize) or keysize == 0 then break end
    -- convert more data if insuficient
    if pos + (keysize+1) > #hexstr then
      local new = ''
      for i = 1, keysize+1 do
        if rawpos > utf8.len(data) then break end
        new = new .. char2hex(usub(data,rawpos,rawpos))
        rawpos = rawpos + 1
      end
      hexstr = hexstr .. new
    end
    -- get key
    local key = hexstr:sub(pos+1,(pos+1)+keysize-1)
    if (#key) ~= keysize then break end
    pos = pos + keysize + 1
    -- translate from dictionary
    local str = dictionary[key]
    if (not str) then
      str = previous .. previous:sub(1,1)
    end
    out_buffer = out_buffer .. str
    progress(rawpos, utf8.len(data), print) -- progress
    -- add to dictionary
    if previous ~= '' then
      local newentry = previous .. str:sub(1,1)
      dictionary_len = dictionary_len + 1
      dictionary[hex(dictionary_len)] = newentry
    end
    -- set previous
    previous = str
  end
  return out_buffer
end

function lzw.pcompress(data,csize,print)
  csize = csize or 16384
  local retval = ""
  for i = 1, #data, csize do
    local tmp = lzw.compress(data:sub(i,i + csize - 1),print)
    local tsz = ("0000"):sub(1,4-#hex(utf8.len(tmp))) .. hex(utf8.len(tmp))
    local sz = hex2char(tsz)
    retval = retval .. sz .. tmp
  end
  return retval .. hex2char("00") .. hex2char("00")
end
function lzw.pdecompress(data,print)
  local retval = ""
  local pos = 1
  local size = 0
  local tmp = ""
  while pos < utf8.len(data) do
    size = num(char2hex(usub(data,pos,pos)))
    if size == 0 then break end
    pos = pos + 1
    tmp = usub(data,pos,pos+size-1)
    pos = pos + size
    retval = retval .. lzw.decompress(tmp,print)
  end
  return retval
end

return lzw