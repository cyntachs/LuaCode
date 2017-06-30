local cmpack = require('cmpack/lzw')

local function stat(inp)
  print('' .. inp .. '')
end
--
local in_f = io.open('A:/Documents/compr_o.txt','rb')
local data = in_f:read('*a')
in_f:close()

print('Compressing...')
--local retval = cmpack.compress(data,stat)
local retval = cmpack.pcompress(data,8192,stat)

--[[
local retval = ""
local csize = 4096
for i = 1, #data, csize do
  retval = retval .. cmpack.compress(data:sub(i,i + csize - 1),stat)
end
--]]

--
local fh_enc = io.open('A:/Documents/compr_e.txt','wb')
fh_enc:write(retval)
fh_enc:close()
--]]
--
local in_f = io.open('A:/Documents/compr_e.txt','rb')
local data2 = in_f:read('*a')
in_f:close()

print('Decompressing...')
local retval = cmpack.pdecompress(data2,stat)

local fh_dec = io.open('A:/Documents/compr_d.txt','wb')
fh_dec:write(retval)
fh_dec:close()
--]]