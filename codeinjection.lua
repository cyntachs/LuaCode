local t = require('tools')

local table1 = {echo='hello',num=1,add=2,res=3.0,inception={hello='there',this=2.0}}

local function tablecpy(data)
  local retval = {}
  if type(data) ~= 'table' then
    return data
  else
    for k,v in pairs(data) do
      retval[k] = tablecpy(v)
    end
  end
  return retval
end


local tcopy = tablecpy(table1)
tcopy.add = 5
tcopy.echo ='who goes there'
tcopy.inception.hello = 'hi'

--print(t.serialize(table1))
--print(t.serialize(tcopy))

local lprint = print
local function cinject()
  lprint('injected code')
end

local global = _G

print('hello')

for k,v in pairs(global) do
  if type(v) == 'function' then
    local tmp = _G[k]
    _G[k] = function(...)
      cinject()
      tmp(...)
    end
  end
end

--print('hello')