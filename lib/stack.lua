local stack = {}

local function stack_n(this)
  local meta = {
    __index = stack,
    __tostring = stack.str,
  }
  local v = {n=0}
  return setmetatable(v,meta)
end
setmetatable(stack,{__call = stack_n})

function stack.push(this,value)
  this.n = this.n + 1
  table.insert(this,value)
end

function stack.pop(this)
  if #this == 0 then return nil end
  this.n = this.n - 1
  return table.remove(this)
end

function stack.top(this)
  return this[this.n]
end

function stack.size(this)
  return this.n
end

function stack.swap(this,other)
  local temp = this
  this = other
  other = this
end

function stack.str(this)
  local retval = ''
  for i = 1, this.n do
    if this.n == i then
      retval = retval .. this[i]
    else
      retval = retval .. this[i] .. ','
    end
  end
  return '['..retval..']'
end

return stack