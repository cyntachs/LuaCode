
local function eucl(a,b)
  local gcd = 0
  if (a <= 0) or (b <= 0) then return gcd end
  if (b > a) then return gcd end
  local r1,r2 = a,b
  local r = r1 % r2
  print(r1..' '..r2..' '..r)
  while r > 0 do
    r1 = r2; r2 = r
    r = r1 % r2
    print(r1..' '..r2..' '..r)
  end
  if (r == 0) then gcd = r2 end
  return gcd
end

print('GCD: '..eucl(441,200))