local vector = require('lib/vector')
local matrix = require('lib/matrix')

local m1 = matrix(2,2)
local m2 = matrix(2,2)
local m3 = matrix(2,3)
local m4 = matrix(3,2)

m1[1] = {1,3}
m1[2] = {2,4}

m2[1] = {0,0}
m2[2] = {1,0}

--m3[1] = {1,2,3}
--m3[2] = {4,5,6}
m3:set(
1,2,
2,2,
2,2
)
m4:set(
2,2,2,
2,2,2
)

print(m1)
print(m2)
print(m3)

print(matrix(3,3) + 2)

print(m3)
print(m3:transpose())

print(m3 * m4)