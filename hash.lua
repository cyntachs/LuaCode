-- ==================
-- ===    hash    ===
-- ==================
-- based on the md5 pseudocode in wikipedia
-- with some minor changes.
-- http://en.wikipedia.org/wiki/MD5#Pseudocode

local math = math or require('math')
local b = bit32 or require('bit32')

local hash = {}

-- main
local s = {
  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21
}

local K = {}
for i = 0, 67 do
  K[i] = math.floor( math.abs(math.sin(i+1)) * math.pow(2,32) )
end

local function strbin(num) -- number to binary
  local str = ''
  local c = tonumber(num)
  repeat
    local i,f = math.modf(c/2)
    if f > 0 then
      str = '1' .. str
    else
      str = '0' .. str
    end
    c = i
  until c == 0
  return str
end

local function charbin(num) -- character to binary
  local str = strbin(num)
  if #str < 8 then
    repeat
      str = '0' .. str
    until #str == 8
  end
  return str
end

local function strnum(bin) -- binary to integer
  local top = #bin
  local ret = 0
  for i = 1, top do
    if bin:byte(i) == 49 then
      ret = ret + math.pow(2,top-i)
    end
  end
  return ret
end

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

function hash.hash(text)
  local msg = ''
  -- convert each character to 8 bit binary
  for i = 1, #text do
    msg = msg .. charbin(string.byte(text,i))
  end
  -- append bit 1 to message
  msg = msg .. '1'
  -- pad with 0
  local orglen = #msg
  repeat
    msg = msg .. '0'
  until math.fmod(#msg+64,512) == 0
  -- append message length
  orglen = strbin(orglen)
  if #orglen < 64 then -- pad length
    repeat
      orglen = '0' .. orglen
    until #orglen == 64
  end
  msg = msg .. orglen
  -- if not divisible by 512 then padding error
  if math.fmod(#msg,512) ~= 0 then
    return nil, 'Error in padding'
  end 
  
  -- main loop
  local a0 = K[64]
  local b0 = K[65]
  local c0 = K[66]
  local d0 = K[67]
  local F = 0
  local g = 0
  for i = 0, #msg/512 do
    local chunk = msg:sub(512 * i, (512 * i)+512)
    local M = {}
    for i = 0, 15 do
      local bchk = chunk:sub(i*32,(i*32)+32)
      M[i] = strnum(bchk)
    end
    local A = a0
    local B = b0
    local C = c0
    local D = d0
    for i = 0, 63 do
      if (0 <= i) and (i <= 15) then
        F = b.bor(b.band(B,C), b.band(b.bnot(B), D))
        g = i
      elseif (16 <= i) and (i <= 31) then
        F = b.bor(b.band(D,B),b.band(b.bnot(D), C))
        g = math.fmod((5 * i + 1),16)
      elseif (32 <= i) and (i <= 47) then
        F = b.bxor(B,C,D)
        g = math.fmod(3 * i + 5,16)
      elseif (48 <= i) and (i <= 63) then
        F = b.bxor(C,b.bor(B,b.bnot(D)))
        g = math.fmod((7 * i),16)
      end
      local dtemp = D
      D = C
      C = B
      B = B + b.lrotate((A + F + K[i] + M[g]),s[i+1])
      A = dtemp
    end
    a0 = a0 + A
    b0 = b0 + B
    c0 = c0 + C
    d0 = d0 + D
  end
  local hash = tohex(a0) .. tohex(b0) .. tohex(c0) .. tohex(d0)
  return hash, (a0+b0+c0+d0)
end

-- return
return hash