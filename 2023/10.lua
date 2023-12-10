-- Set-up
aoc = require("aoc")
Set = require("set")

function loadMap(fileName)
	local mapping = {}
	local y = 0
	for l in io.lines(fileName) do
		y = y + 1
		for x = 1, #l do
			local key = tostring(x) .. ";" .. tostring(y)
			mapping[key] = string.sub(l, x, x)
		end
	end
	return mapping
end

function getStart(map)
	for k, v in pairs(map) do
		if v == "S" then
			return k
		end
	end
	error("No key found!")
end

function validPipe(dir_x, dir_y, pipe)
	local down = { ["|"] = true, ["L"] = true, ["J"] = true }
	local up = { ["|"] = true, ["7"] = true, ["F"] = true }
	local left = { ["-"] = true, ["L"] = true, ["F"] = true }
	local right = { ["-"] = true, ["J"] = true, ["7"] = true }

	if dir_x == 1 and dir_y == 0 then
		return right[pipe] == true
	elseif dir_x == -1 and dir_y == 0 then
		return left[pipe] == true
	elseif dir_x == 0 and dir_y == 1 then
		return down[pipe] == true
	elseif dir_x == 0 and dir_y == -1 then
		return up[pipe] == true
	else
		error("Unexpected x, y", x, y)
	end
end

function getNeighbours(map, point)
	local neighbours = {}
	local x = point:match("^(%d+)")
	local y = point:match("(%d+)$")

	local offsets = { { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }
	for _, off in pairs(offsets) do
		local x_off, y_off = off[1], off[2]
		local key = tostring(x + x_off) .. ";" .. tostring(y + y_off)
		local result = map[key]

		if validPipe(x_off, y_off, result) then
			table.insert(neighbours, key)
		end
	end
	return neighbours
end

-- Part 1 ---------------------------------------------------------------------
--- @return number, table<string, string>, table<string, boolean>
function part1(fileName)
	local map = loadMap(fileName)
	local start = getStart(map)

	local seen = Set.new()
	local steps = 1
	seen:add(start)

	local frontier = getNeighbours(map, start)
	local nextFrontier = {}
	while #frontier > 0 or #nextFrontier > 0 do
		if #frontier == 0 then
			frontier = nextFrontier
			nextFrontier = {}
			steps = steps + 1
		end

		local point = table.remove(frontier)
		seen:add(point)
		for _, neighbour in ipairs(getNeighbours(map, point)) do
			if not seen:contains(neighbour) then
				table.insert(nextFrontier, neighbour)
			end
		end
	end
	-- Multiple return - map, seen will be used in part 2
	return steps, map, seen
end

assert(part1("inputs/10-example1.txt") == 4)
assert(part1("inputs/10-example2.txt") == 8)
assert(part1("inputs/10.txt") == 6870)

-- Part 2 ---------------------------------------------------------------------

--[[
Intuitively: You cannot cross a line and stay on the same side of the line.
From this we can say: If you cross the loop once, you enter it.
If you cross the loop twice, you exit it.
Three times, you re-enter it.

Thus, we can track the number of loop-crossings from the outside edges.
Caveats:
- If we trace along a segment of pipe, that is neither entering nor exiting
- If we encounter two elbows kitty-corner (e.g. `7L`) that does count as crossing (twice!)
--]]
function part2(fileName)
	local _, map, loop = part1(fileName)
	return -1
end

assert(part2("inputs/10-example3.txt") == 4)
assert(part2("inputs/10-example4.txt") == 8)
assert(part2("inputs/10-example5.txt") == 10)
assert(part2("inputs/10.txt") == 1 / 0)
