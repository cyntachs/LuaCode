local t = require('tools')

local buffer = [[
# main comment 1
option1 = thisvalue # this is a comment
option2 = othervalue 
option3 = val
#main comment 2
background = 0xFF00CC #also this one
#haratara ajhad = ahdflkjs adf df
foreground = 0x660033
block_size = 120
welcome_msg = "hello there how are you im fine thank you!"

]]

-- cfg format reader
local function cfg_parse(data)
  local entry,err = string.gmatch(data,'(.-)\n')
  if not entry and err then error(err) end
  local get = entry()
  if not get then error('Could not parse data') end
  local cfgvalues = {}
  repeat
    get = string.match(' '..get,'(.+)#') or get
    local tag,value = string.match(get,'([%w%p%s]+)=([%w%p%s]+)')
    if tag and value then
      cfgvalues[string.match(tag,'[%w%p]+')] = string.match(value,'[\"\']([%w%p%s]+)[\"\']') or string.match(value,'[%w%p]+')
    end
    get = entry()
  until not get
  return cfgvalues
end
local function cfg_make(data)
  local retval = ''
  for k,v in pairs(data) do
    if string.find(v,'[%s]') then
      retval = retval .. k .. ' = "' .. v .. '"\n'
    else
      retval = retval .. k .. ' = ' .. v .. '\n'
    end
  end
  return retval
end

--print(t.serialize(cfg_parse(buffer)))

buffer = [[
!(cstate_version:2.0)
[statevars.system_sigroutines]
timequantum = 0.5
[statevars.system]
shellparams = "Default 160 50"
shelldir = A:/sys/os/intmgr.lua
path = A:/bin;A:/shared/bin;A:/sys
[users.debug]
homedir = A:/usr/debug
userdata = A:/usr/debug/_!usrdata
path = A:/usr/debug
]]

local function cstate_parse(data)
  local entry,err = string.gmatch(data,'(.-)\n')
  if not entry and err then error(err) end
  local get = entry()
  if not get then error('Could not parse data') end
  -- version check
  local version = string.match(get,'%!%(cstate_version:([%w%p]+)%)')
  if version ~= '2.0' then return 'Incompatible version' end get = entry()
  local cstatevalues = {}
  local root,node = '',''
  repeat
    local r,n = string.match(get,'%[([%w%p]+)%.([%w%p]+)%]')
    if (r and n) then
      root,node = r,n
      if not cstatevalues[root] then cstatevalues[root] = {} end
      if not cstatevalues[root][node] then cstatevalues[root][node] = {} end
    else
      local tag,value = string.match(get,'([%w%p%s]+)=([%w%p%s]+)')
      if tag and value then
        cstatevalues[root][node][string.match(tag,'[%w%p]+')] = string.match(value,'[\"\']([%w%p%s]+)[\"\']') or string.match(value,'[%w%p]+')
      else
        return 'Error in parsing cstate data'
      end
    end
    get = entry()
  until not get
  return cstatevalues
end
local function cstate_make(data)
  local retval = '!(cstate_version:2.0)\n'
  for k1,v1 in pairs(data) do
    for k2,v2 in pairs(v1) do
      retval = retval .. '[' .. k1 .. '.' .. k2 .. ']\n'
      for k3,v3 in pairs(v2) do
        if string.find(v3,'[%s]') then
          retval = retval .. k3 .. ' = "' .. tostring(v3) .. '"\n'
        else
          retval = retval .. k3 .. ' = ' .. tostring(v3) .. '\n'
        end
      end
    end
  end
  return retval
end

--print(t.serialize(cstate_parse(buffer)))
print(cstate_make(cstate_parse(buffer)))
print(t.serialize(cstate_parse(cstate_make(cstate_parse(buffer)))))