local file = [[
print('hello there how are you?')
local tools = {}
tools.serialize = function(o, ind)
  ind = ind or 1
  local indn = 0
  local indent = ''
  while indn < ind do
    indent = indent .. '  '
    indn =  indn + 1
  end
  local retstr = ''
    if type(o) == "number" then
      retstr = retstr .. o .. ''
    elseif type(o) == "boolean" then
      retstr = retstr .. tostring(o)
    elseif type(o) == "string" then
      retstr = retstr .. string.format("%q", o) .. ''
    elseif type(o) == "table" then
      retstr = retstr .. '{\n'
      for k,v in pairs(o) do
        retstr = retstr .. indent .. '' .. k .. '='
        retstr = retstr .. tools.serialize(v,ind+1)
        retstr = retstr .. ',\n'
      end
      retstr = retstr .. string.sub(indent,1,#indent-2) .. '}'
    else
      retstr = retstr .. '<'..type(o)..'>'
    end
    return retstr
end
return tools
]]

print('dumping')
local loaded = load(file,'=file')
local run = loaded()
local dump = string.dump(run)
print('reloading')
local reload = load(dump,'=dump')
local ran = reload()