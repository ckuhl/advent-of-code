-- Template file to copy-paste for each day
problem = io.lines("inputs/day00.txt")
example = io.lines("inputs/day00_example.txt")

function BuildArray(...)
  local arr = {}
  for v in ... do
    arr[#arr + 1] = v
  end
  return arr
end

local problem = BuildArray(problem)
for l = 1, #problem do
	print(problem[l])
end
