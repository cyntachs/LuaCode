local uuid = require('uuid/uuid_lib')

print(os.time())
math.randomseed(os.time())
math.randomseed(math.random(0,os.time()))

local id = uuid.gen()
print(id)
id = uuid.tochar(id)
print(id)
id = uuid.tostr(id)
print(id)