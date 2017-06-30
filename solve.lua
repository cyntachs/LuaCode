local serialize = require('lib/serialize')
local stack = require('lib/stack')

local ntable = {}
local found = {}

local function visualize(data)
  for i = 1, 8 do
    local row = ''
    for k = 1, 11 do
      row = row .. '['..data[i][k]..']'
    end
    print(row)
  end
end

local function newNode(data, score)
  local node = {}
  node.data = {}
  node.score = score or 0
  return node
end

local function generate()
  
end

local function run()
  
end
