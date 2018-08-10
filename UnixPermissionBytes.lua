local function hex(num)
  return string.format("%02x",num):upper()
end
local function num(hex)
  return tonumber(hex,16)
end
local function hexchar(hex) -- range of 0-255 only
  return string.char(num(hex))
end


local function permtobytes(u,g,p)
  -- convert permission number to chars (2 bytes)
  if (u > 7) or (u < 0) then r = 7 end
  if (g > 7) or (g < 0) then w = 7 end
  if (p > 7) or (p < 0) then x = 7 end
  ug_byte = hex( u + (g*16) )
  p_byte = hex(p)
  return hexchar(ug_byte)..hexchar(p_byte)
end

local function bytestoperm(perm)
  -- convert 2 bytes to permission numbers
  ug_byte = hex(string.byte(perm:sub(1,1)))
  u_perm = tonumber(ug_byte:sub(2,2))
  g_perm = tonumber(ug_byte:sub(1,1))
  p_perm = tonumber(string.byte(perm:sub(2,2)))
  return u_perm,g_perm,p_perm
end

u,g,p = 7,6,5

print(permtobytes(u,g,p))
print(bytestoperm(permtobytes(u,g,p)))
print(permtobytes(bytestoperm(permtobytes(u,g,p))))
