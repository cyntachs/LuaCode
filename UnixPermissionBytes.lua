local function hex(num)
  return string.format("%02x",num):upper()
end
local function num(hex)
  return tonumber(hex,16)
end
local function hexchar(hex) -- range of 0-255 only
  return string.char(num(hex))
end


local function permtobytes(r,w,x)
  -- convert permission number to chars (2 bytes)
  if (r > 7) or (r < 0) then r = 7 end
  if (w > 7) or (w < 0) then w = 7 end
  if (x > 7) or (x < 0) then x = 7 end
  rw_byte = hex( r + (w*16) )
  x_byte = hex(x)
  return hexchar(rw_byte)..hexchar(x_byte)
end

local function bytestoperm(perm)
  -- convert 2 bytes to permission numbers
  rw_byte = hex(string.byte(perm:sub(1,1)))
  r_perm = tonumber(rw_byte:sub(2,2))
  w_perm = tonumber(rw_byte:sub(1,1))
  x_perm = tonumber(string.byte(perm:sub(2,2)))
  return r_perm,w_perm,x_perm
end

r,w,x = 7,6,5

print(permtobytes(r,w,x))
print(bytestoperm(permtobytes(r,w,x)))
print(permtobytes(bytestoperm(permtobytes(r,w,x))))