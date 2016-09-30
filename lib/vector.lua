local vector = {}

local function vect(this,x,y,z,w)
  local meta = {
    __index = vector,
    __add = vector.add,
    __sub = vector.sub,
    __mul = vector.mult,
    __div = vector.div,
    __unm = vector.negate,
    __len = vector.len,
    __eq = vector.equals,
    __tostring = vector.str,
  }
  local v = {
    x = x or 0.0,
    y = y or 0.0,
    z = z or 0.0,
    w = w or 0.0,
  }
  return setmetatable(v,meta)
end
setmetatable(vector,{__call = vect})

function vector.str(this)
  return '['..tostring(this.x)..','..tostring(this.y)..','..tostring(this.z)..','..tostring(this.w)..']'
end

-- vector functions
function vector.add(this,other)
  return vector(this.x + other.x,this.y + other.y,this.z + other.z,this.w + other.w)
end

function vector.sub(this,other)
  return vector(this.x - other.x,this.y - other.y,this.z - other.z,this.w - other.w)
end

function vector.mult(this,other)
  return vector(this.x * other,this.y * other,this.z * other,this.w * other)
end

function vector.div(this,other)
  return vector(this.x / other,this.y / other,this.z / other,this.w / other)
end

function vector.negate(this)
  return vector(-this.x,-this.y,-this.z,-this.w)
end

function vector.len(this)
  return ((this.x*this.x) + (this.y*this.y) + (this.z*this.z) + (this.w*this.w))^0.5
end

function vector.distance(this,other)
  return #(other - this)
end

function vector.normalize(this)
  return this * (1/#this)
end

function vector.floor(this)
  return vector(math.floor(this.x),math.floor(this.y),math.floor(this.z),math.floor(this.w))
end

function vector.ceil(this)
  return vector(math.ceil(this.x),math.ceil(this.y),math.ceil(this.z),math.ceil(this.w))
end

function vector.round(this,nplace)
  nplace = nplace or 1
  return ( (this + (vector(0.5,0.5,0.5,0.5) * nplace))/nplace ):floor() * nplace
end

function vector.dot(this,other)
  return (this.x * other.x) + (this.y * other.y) + (this.z * other.z) + (this.w * other.w)
end

function vector.cross(this,other)
  local v = {}
  v.x = this.y * other.z - this.z * other.y
  v.y = this.z * other.x - this.x * other.z
  v.z = this.x * other.y - this.y * other.x
  return vector(v.x,v.y,v.z,0)
end

function vector.equals(this,other)
  return (#(this - other) == 0)
end

return vector