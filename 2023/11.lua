-- Set-up
aoc = require("aoc")

--[[
Today feels about the day where I need to start thinking through problems
before I start working through them. So... let's start thinking.fileName

The added twist to part 1 is that we need to manipulate the input in two steps:
1. Read it in as an array.
2. For each completely-empty row/column between an object and the origin, add 1
 	 to the distance.

Immediately on _thinking_ there is an observation:
> Read in the input as a sparse array - only galaxies are counted, everything
> else is, well, the same as out-of-bounds: A default value is provided.
> Then parse out the empty rows and columns separately. From there we don't
> really care about the mapping... only distances between each point.

--]]

-- Initialize the initial sparse array
function readSparseArray(fileName)
	local y_arr = {}
	local y = 0
	for l in io.lines(fileName) do
		y = y + 1
		local x_arr = {}
		for x = 1, #l do
			local c = l:sub(x, x)
			if c ~= "." then
				x_arr[x] = true
			end
		end
		y_arr[y] = x_arr
	end
	return y_arr
end

-- Read in empty lines, output two tables of which x and y lines are empty
function readEmptyLines(fileName)
	local empty_x, empty_y = {}, {}
	local y_ct = 0

	for _ in io.lines(fileName) do
		y_ct = y_ct + 1
		empty_y[y_ct] = true
	end
	y_ct = 0

	for l in io.lines(fileName) do
		y_ct = y_ct + 1

		for x = 1, #l do
			if y_ct == 1 then
				empty_x[x] = true
			end

			local c = l:sub(x, x)
			if c ~= "." then
				empty_y[y_ct] = false
				empty_x[x] = false
			end
		end
	end

	return empty_x, empty_y
end

function sparseDist(x_0, y_0, x_1, y_1, empty_x, empty_y, offset)
	local x_off, y_off = 0, 0

	for x = math.min(x_0, x_1), math.max(x_0, x_1) do
		if empty_x[x] then
			x_off = x_off + 1
		end
	end

	for y = math.min(y_0, y_1), math.max(y_0, y_1) do
		if empty_y[y] then
			y_off = y_off + 1
		end
	end

	return math.abs(x_1 - x_0) + x_off * (offset - 1) + math.abs(y_1 - y_0) + y_off * (offset - 1)
end

function spaceDist(fileName, offset)
	offset = offset or 2
	local totalMinDist = 0
	local arr = readSparseArray(fileName)
	local empty_x, empty_y = readEmptyLines(fileName)
	for y_0, y_arr in pairs(arr) do
		for x_0, _ in pairs(y_arr) do

			for y_1, y_1_arr in pairs(arr) do
				for x_1, _ in pairs(y_1_arr) do

					if not (x_0 == x_1 and y_0 == y_1) then
						local sd = sparseDist(x_0, y_0, x_1, y_1, empty_x, empty_y, offset)
						totalMinDist = totalMinDist + sd
					else
					end
				end
			end
			arr[y_0][x_0] = nil
		end
		arr[y_0] = nil
	end
	return totalMinDist
end

-- Part 1 ---------------------------------------------------------------------
function part1(fileName)
	return spaceDist(fileName)
end

assert(part1("inputs/11-example1.txt") == 374)
assert(part1("inputs/11.txt") == 9965032)

-- Part 2 ---------------------------------------------------------------------

function part2(fileName, offset)
	if offset == nil then
		offset = 1000000
	end
	return spaceDist(fileName, offset)
end

assert(part2("inputs/11-example1.txt", 10) == 1030)
assert(part2("inputs/11-example1.txt", 100) == 8410)
assert(part2("inputs/11.txt") == 1)
