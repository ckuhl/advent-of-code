-- Set-up
aoc = require("aoc")

--[[
For part 1, this seems, well, relatively simple:
Given an input map, we want to apply modifications to it.
These modifications only ever happen one direction (NSEW) at a time.
So what we want to do is:
- Load a 2D array of our map
- Write a function to apply the transformation to (i.e. "tilt") a single row
- Apply that to each column (for to tilt North)
--]]

--- Load the map into a single two-dimensional array
function loadMap(fileName)
	local map = {}
	local y = 0
	for l in io.lines(fileName) do
		local row = {}
		y = y + 1
		for x = 1, #l do
			row[x] = l:sub(x, x)
		end
		map[y] = row
	end
	return map
end

--- Given a 2D-array and a column index, return each value in that column
function getColumn(map, index)
	local column = {}
	for y, row in ipairs(map) do
		column[y] = row[index]
	end
	return column
end

--- Given a 2D-array, column index, and new column values, replace the column values in the map
function setColumn(map, index, column)
	for y, row in ipairs(map) do
		row[index] = column[y]
		map[y] = row
	end
	return map
end

--- "Tilt" one row to the left: Move all O as far left as possible before encountering a #
function tiltRow(t)
	local spaces, rocks = 0, 0
	for i, v in ipairs(t) do
		if v == "O" then
			rocks = rocks + 1
		elseif v == "." then
			spaces = spaces + 1
		end

		if v == "#" or i == #t then
			-- Special handling: Count the last column, unless it's a block
			local index = (i == #t and v ~= "#") and i or i - 1

			while spaces > 0 do
				t[index] = "."
				spaces = spaces - 1
				index = index - 1
			end
			while rocks > 0 do
				t[index] = "O"
				rocks = rocks - 1
				index = index - 1
			end
		end
	end
	return t
end

function tiltNorth(map)
	for i = 1, #map[1] do
		local tiltedRow = tiltRow(getColumn(map, i))
		map = setColumn(map, i, tiltedRow)
	end
	return map
end

function totalLoad(map)
	local tot = 0

	for y, row in ipairs(map) do
		for _, v in ipairs(row) do
			if v == "O" then
				tot = tot + (#map - y + 1)
			end
		end
	end
	return tot
end

-- Part 1 ---------------------------------------------------------------------

function part1(fileName)
	local map = loadMap(fileName)
	local tilted = tiltNorth(map)
	return totalLoad(tilted)
end

assert(part1("inputs/14-example1.txt") == 136)
assert(part1("inputs/14.txt") == 106997)

-- Part 2 ---------------------------------------------------------------------

function tiltWest(map)
	for y, row in ipairs(map) do
		map[y] = tiltRow(row)
	end
	return map
end

function tiltEast(map)
	for y, row in ipairs(map) do
		map[y] = aoc.reverse(tiltRow(aoc.reverse(row)))
	end
	return map
end

function tiltSouth(map)
	for i = 1, #map[1] do
		local tiltedRow = aoc.reverse(tiltRow(aoc.reverse(getColumn(map, i))))
		map = setColumn(map, i, tiltedRow)
	end
	return map
end

function tiltCycle(map)
	map = tiltNorth(map)
	map = tiltWest(map)
	map = tiltSouth(map)
	map = tiltEast(map)
	return map
end

-- FIXME: Hack, find loop, then start again and retrace our steps to get the answer
function part2(fileName)
	local map = loadMap(fileName)
	local state = aoc.dumpTable(map)

	local loopCounter = {}
	local steps = 0

	while loopCounter[state] == nil do
		loopCounter[state] = steps
		map = tiltCycle(map)
		state = aoc.dumpTable(map)
		steps = steps + 1
	end

	local loopInterval = steps - loopCounter[state]
	local loopOffset = ((1000000000 - steps) % loopInterval)

	map = loadMap(fileName)
	for _ = 1, steps + loopOffset do
		map = tiltCycle(map)
	end

	local final = totalLoad(map)
	return final
end

assert(part2("inputs/14-example1.txt") == 64)
assert(part2("inputs/14.txt") == 99641)
