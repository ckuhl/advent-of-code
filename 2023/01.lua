-- Template file to copy-paste for each day
problem = io.lines("inputs/01.txt")
example = io.lines("inputs/01-example1.txt")

function BuildArray(...)
  local arr = {}
  for v in ... do
    arr[#arr + 1] = v
  end
  return arr
end

local problem = BuildArray(problem)
local total = 0
for l = 1, #problem do
  local s = problem[l]
  total = total + tonumber(s:match('^%a*(%d)') .. s:match('(%d)%a*$'))
end

-- Part 1:
-- Example: 142
-- Problem: 54951
print(total)

-- Part 2:
-- Excuse me? Lua does not have a regex OR???

