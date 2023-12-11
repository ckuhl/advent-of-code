-- Set-up
aoc = require("aoc")
Set = require("set")

function toKey(x, y)
	return tostring(x) .. ";" .. tostring(y)
end

function fromKey(s)
	local x = s:match("^(%d+)")
	local y = s:match("(%d+)$")
	return tonumber(x), tonumber(y)
end

function loadMap(fileName)
	local mapping = {}
	local y = 0
	for l in io.lines(fileName) do
		y = y + 1
		for x = 1, #l do
			mapping[toKey(x, y)] = string.sub(l, x, x)
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

-- So long as the first step (finding the neighbours of S) works, we don't need this
local neighbourDirs = {
	["F"] = { { 0, 1 }, { 1, 0 } },
	["7"] = { { 0, 1 }, { -1, 0 } },
	["L"] = { { 0, -1 }, { 1, 0 } },
	["J"] = { { 0, -1 }, { -1, 0 } },
	["-"] = { { -1, 0 }, { 1, 0 } },
	["|"] = { { 0, -1 }, { 0, 1 } },
	["S"] = { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } },
	["."] = {},
}

function getNeighbours(map, point)
	local neighbours = {}
	local x, y = fromKey(point)

	local n = neighbourDirs[map[point]] or {}
	for _, off in pairs(n) do
		local x_off, y_off = off[1], off[2]
		local key = toKey(x + x_off, y + y_off)
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
	-- Multiple return - `map`, `seen` will only be used in part 2
	return steps, map, seen
end

assert(part1("inputs/10-example1.txt") == 4, "Failed part 1, example 1")
assert(part1("inputs/10-example2.txt") == 8, "Failed part 1, example 2")
assert(part1("inputs/10.txt") == 6870, "Failed part 1, answer")

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

But what if we try counting in a way that doesn't require that?
We could also count along diagonals! Then we _can't_ get long pipes
And elbows that we cross twice (e.g. 7L if going down-left) cancel themselves out.
--]]

-- Return if a given key is a boundary for the loop (if counted down-left)
function isLoopBoundary(map, loop, key)
	if not loop:contains(key) then
		return false
	end

	local tile = map[key]
	if tile == "7" or tile == "L" or tile == "." then
		return false
	else
		return true
	end
end

function countCrossings(map, loop, key)
	if map[key] == nil then
		return 0
	else
		local x, y = fromKey(key)
		return (isLoopBoundary(map, loop, key) and 1 or 0) + countCrossings(map, loop, toKey(x + 1, y + 1))
	end
end

function part2(fileName)
	local withinCount = 0
	local _, map, loop = part1(fileName)

	for k, _ in pairs(map) do
		if not loop:contains(k) then
			if countCrossings(map, loop, k) % 2 == 1 then
				withinCount = withinCount + 1
			end
		end
	end
	return withinCount
end

assert(part2("inputs/10-example3.txt") == 4)
assert(part2("inputs/10-example4.txt") == 8)
assert(part2("inputs/10-example5.txt") == 10)
assert(part2("inputs/10.txt") == 287)
