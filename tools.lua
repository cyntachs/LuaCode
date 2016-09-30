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

tools.lserialize = function(o, depth, ind)
  ind = ind or 1
  depth = depth or 20
  depth = depth - 1
  if depth <= 0 then return '' end
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
        retstr = retstr .. __serialize(v, depth, ind+1)
        retstr = retstr .. ',\n'
      end
      retstr = retstr .. indent:sub(1,indent:len()-2) .. '}'
    else
      retstr = retstr .. '<'..type(o)..'>'
    end
    return retstr
end

return tools