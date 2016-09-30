local matrix = {}

local function matr(this,col,row)
  local meta = {
    __index = matrix,
    __add = matrix.add,
    __mul = matrix.mult,
    __tostring = matrix.str,
  }
  local v = {}
  v.meta = {row = row or 1, col = col or 1}
  for i = 1, v.meta.col do
    v[i] = {}
    for j = 1, v.meta.row do
      v[i][j] = 0
    end
  end
  return setmetatable(v,meta)
end
setmetatable(matrix,{__call = matr})

function matrix.set(this,...)
  local val = table.pack(...)
  local vali = 1
  if (this.meta.col * this.meta.row) ~= val.n then return nil end
  for i = 1, this.meta.row do
    for j = 1, this.meta.col do
      this[j][i] = val[vali]
      vali = vali + 1
    end
  end
  return this
end

function matrix.add(this,other)
  if (type(this) == 'table' and this.meta) and (type(other) == 'table' and other.meta) then -- matrix addition
    if (this.meta.col == other.meta.col) and (this.meta.row == other.meta.row) then -- matrices must have same dimensions
      local tmp = matrix(this.meta.col,this.meta.row)
      for i = 1, this.meta.col do
        for j = 1, this.meta.row do
          tmp[i][j] = this[i][j] + other[i][j] -- add the matrices together
        end
      end
      return tmp -- return result
    end
  elseif (type(this) == 'number') or (type(other) == 'number') then -- if adding a scalar
    if type(other) == 'table' then -- 'this' must be the matrix
      local tswap = this
      this = other
      other = tswap
    end
    local tmp = matrix(this.meta.col,this.meta.row)
    for i = 1, this.meta.col do
      for j = 1, this.meta.row do
        tmp[i][j] = this[i][j] + other -- add scalar to every entry in matrix
      end
    end
    return tmp -- return result
  end
  return nil
end

function matrix.mult(this,other)
  if type(this) == 'number' or type(other) == 'number' then -- matrix mult with scalar
    -- mult scalar number with matrix
    if type(other) == 'table' then -- 'this' must be the matrix
      local tswap = this
      this = other
      other = tswap
    end
    local tmp = matrix(this.meta.col,this.meta.row)
    for i = 1, this.meta.col do
      for j = 1, this.meta.row do
        tmp[i][j] = this[i][j] * other -- mult evry entry in matrix
      end
    end
    return tmp -- return result
  elseif (not this.meta) and (not other.meta) then return nil end
  -- matrix multiplication
  if this.meta.col == other.meta.row then --  check if correct dimensions
    local tmp = matrix(other.meta.col,this.meta.row)
    for i = 1, tmp.meta.col do
      for j = 1, tmp.meta.row do
        local val = 0
        for k = 1, this.meta.col do
          val = val + (other[i][k] * this[k][j])
        end
        tmp[i][j] = val
      end
    end
    return tmp -- return result
  end
  return nil
end

function matrix.transpose(this) -- flip matrix around main diagonal
  local tmp = matrix(this.meta.row,this.meta.col)
  for i = 1, this.meta.col do
    for j = 1, this.meta.row do
      tmp[j][i] = this[i][j]
    end
  end
  return tmp
end

function matrix.str(this)
  local retval = ''
  for i = 1, this.meta.row do
    local row = ''
    for j = 1, this.meta.col do
      row = row .. '[' .. this[j][i] .. ']'
    end
    retval = retval .. ''..row..'\n'
  end
  return retval
end

return matrix