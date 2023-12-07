-- Set-up
aoc = require("aoc")

function loadFile(fileName)
	t = {}
	i = 0
	for l in io.lines(fileName) do
		i = i + 1
		t[i] = l
	end
	return t
end

-- Given the input string(s), parse in the input seeds
function parseSeeds(inputLines)
	for _, l in pairs(inputLines) do
		if l:match("seeds:") then
			local seeds = {}
			local i = 0
			for seed in l:gmatch("(%d+)") do
				i = i + 1
				seeds[i] = tonumber(seed)
			end
			return seeds
		end
	end
end

function applyTranslation(values, dest_start, source_start, range)
	local source_end = source_start + range - 1
	local offset = dest_start - source_start

	local outputLines = {}

	for i, v in pairs(values) do
		if v >= source_start and v <= source_end then
			outputLines[i] = v + offset
			values[i] = nil
		end
	end
	return outputLines, values
end

function doAllTranslations(inputLines, values)
	local nextValues = {}
	for _, l in pairs(inputLines) do
		if l:match("^%d") then
			for a, b, c in l:gmatch("(%d+) (%d+) (%d+)") do
				local dest_start = tonumber(a)
				local source_start = tonumber(b)
				local range = tonumber(c)
				modified, values = applyTranslation(values, dest_start, source_start, range)
				nextValues = aoc.tableUpdate(nextValues, modified)
			end
		elseif l:match("^$") then
			values = aoc.tableUpdate(values, nextValues)
			nextValues = {}
		end
	end
	return aoc.tableUpdate(values, nextValues)
end

-- Part 1 ---------------------------------------------------------------------

function part1(fileName)
	local inputTable = loadFile(fileName)
	local seeds = parseSeeds(inputTable)
	local soils = doAllTranslations(inputTable, seeds)
	return aoc.tableMin(soils)
end

assert(part1("inputs/05-example1.txt") == 35)
assert(part1("inputs/05.txt") == 993500720)

-- Part 2 ---------------------------------------------------------------------

function part2(fileName)
	for l in io.lines(fileName) do
	end
	return -1
end

assert(part2("inputs/05-example1.txt") == 1)
assert(part2("inputs/05.txt") == 1)
