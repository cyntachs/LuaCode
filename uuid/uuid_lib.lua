UUID = {}
function UUID.generate()
  local rnd = math.random
  return string.gsub('xxxxxxxx-xxxx-4xxx-Nxxx-xxxxxxxxxxxx','[xN]',
  function (s) local tc = ((s=='x') and rnd(0,15)) or (rnd(8,11))
  return string.format('%x',tc) end)
end
function UUID.tochars(id)
  return id:gsub("[-]",""):gsub("..",function (c) return string.char("0x"..c) end)
end
function UUID.tostring(id)
  id = id:gsub(".",function (c) return string.format("%02x",string.byte(c)) end)
  return id:sub(1,8) .. "-" .. id:sub(9,12) .. "-" .. id:sub(13,16) .. "-" .. id:sub(17,20) .. "-" .. id:sub(21)
end
setmetatable(UUID, {__call = UUID.generate})
return UUID