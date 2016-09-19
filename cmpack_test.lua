local cmpack = require('cmpack/lz1')

-- compress file compr_o.txt using lz1
-- write compressed file to compr_e.txt
-- decompress and write to compr_d.txt

local function stat(inp)
  print('Progress: ' .. inp .. '%')
end

local in_f = io.open('compr_o.txt','rb')
local data = in_f:read('*a')
in_f:close()

local retval = cmpack.compress(data,stat)

local fh_enc = io.open('compr_e.txt','wb')
fh_enc:write(retval)
fh_enc:close()

local in_f = io.open('compr_e.txt','rb')
local data = in_f:read('*a')
in_f:close()

local retval = cmpack.decompress(data,stat)

local fh_dec = io.open('compr_d.txt','wb')
fh_dec:write(retval)
fh_dec:close()