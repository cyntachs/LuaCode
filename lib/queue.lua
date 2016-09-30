local queue = {}

local function queue_n(this)
  local meta = {
    __index = queue,
    __tostring = queue.str,
  }
  local v = {n=0}
  return setmetatable(v,meta)
end
setmetatable(queue,{__call = queue_n})

function queue.push(this,value)
  this.n = this.n + 1
  table.insert(this,1,value)
end

function queue.pop(this)
  if #this == 0 then return nil end
  this.n = this.n - 1
  return table.remove(this)
end

function queue.pop_back(this)
  if #this == 0 then return nil end
  this.n = this.n - 1
  return table.remove(this,1)
end

function queue.front(this)
  return this[this.n]
end

function queue.back(this)
  return this[1]
end

function queue.size(this)
  return this.n
end

function queue.swap(this,other)
  local temp = this
  this = other
  other = this
end

function queue.str(this)
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

return queue