-- Set-up
aoc = require("aoc")

--[[
Day two of _thinking_:

First of all -- hey! This looks like Picross, er, Nonograms!

Second of all: Hmm. We want to match patterns... of expressions... that have a
certain odd... regularity.
Nah.
Just coincidence.

Rough approach is thus:
1. Iterate through all combinations of ?-replacement values.
2. Construct regex to match string:
	e.g. for `??..??...?##. 1,1,3` construct the regex:
	`^.*#.+#.+###.*$`
	or something similar, since Lua does things differently.
--]]

-- Helper: Parse a string line into the map portion and an array of integers
function parseLine(str)
	local line = str:match("^([%?%.#]+) ")
	local blocks = {}
	for n in str:gmatch("(%d+)") do
		table.insert(blocks, tonumber(n))
	end
	return line, blocks
end

function doBlocksFitLine(line, blocks)
	local re = "^%.*"
	for i, v in ipairs(blocks) do
		if i ~= 1 then
			re = re .. "%.+"
		end
		for _ = 1, v do
			re = re .. "#"
		end
	end
	re = re .. "%.*$"
	return string.match(line, re) ~= nil
end

function nSquaredLineSolutions(line, blocks)
	if line:find("%?") == nil then
		return doBlocksFitLine(line, blocks) and 1 or 0
	else
		local s1 = nSquaredLineSolutions(string.gsub(line, "%?", "#", 1), blocks)
		local s2 = nSquaredLineSolutions(string.gsub(line, "%?", ".", 1), blocks)
		return s1 + s2
	end
end

-- Part 1 ---------------------------------------------------------------------

function part1(fileName)
	local solutionCount = 0
	for l in io.lines(fileName) do
		local line, n = parseLine(l)
		solutionCount = solutionCount + nSquaredLineSolutions(line, n)
	end
	return solutionCount
end

assert(part1("inputs/12-example1.txt") == 21)
assert(part1("inputs/12.txt") == 7857)

-- Part 2 ---------------------------------------------------------------------

-- TODO: Actually approach this algorithmically
function part2(fileName)
	for l in io.lines(fileName) do
	end
	return -1
end

assert(part2("inputs/12-example1.txt") == 525152)
assert(part2("inputs/12.txt") == 1)
