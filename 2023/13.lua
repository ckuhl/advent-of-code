-- Set-up
aoc = require("aoc")

local function readPatterns(fileName)
	--- Read input into a series of tables representing each pattern
	local chunks = {}
	local currentChunk = {}
	for l in io.lines(fileName) do
		if l == "" then
			table.insert(chunks, currentChunk)
			currentChunk = {}
		else
			table.insert(currentChunk, l)
		end
	end
	table.insert(chunks, currentChunk)
	return chunks
end

local function findHorizontalReflection(pattern)
	--- A reflection is when two lines repeat, and every line before matches another line 2n+1 steps later, until the edge.
	--- i.e. if 5-6 match, 4-7 match as well, then 3-8, then 2-9.
	--- So there's two parts: First, finding a repeating pair of lines; then checking if they're a full reflection
	local candidateReflections = {}
	local hold = pattern[1]
	for i = 2, #pattern do
		if pattern[i] == hold then
			table.insert(candidateReflections, i)
		end
		hold = pattern[i]
	end
	-- Now we have our list of Candidate reflections
	local reflectionIndex
	for _, rightReflection in ipairs(candidateReflections) do
		local offset = 1
		for pointer = rightReflection, #pattern do
			reflectionIndex = rightReflection
			if pattern[pointer] == nil or pattern[pointer - offset] == nil then
				break
			elseif pattern[pointer] ~= pattern[pointer - offset] then
				reflectionIndex = nil
				break
			else
				offset = offset + 2
			end
		end
		if reflectionIndex ~= nil then
			return reflectionIndex
		end
	end
	return reflectionIndex
end

local function findVerticalReflection(pattern)
	local mirrored = {}

	for y = 1, #pattern[1] do
		mirrored[y] = ""
	end

	for x = 1, #pattern[1] do
		for y = 1, #pattern do
			mirrored[x] = mirrored[x] .. string.sub(pattern[y], x, x)
		end
	end

	return findHorizontalReflection(mirrored)
end

-- Part 1 ---------------------------------------------------------------------

--[[
Thinking through this one: we want to find reflections in two axes.
It feels like it might be more desirable to reduce this to searching in one axis:
i.e. rotating patterns 90º where we don't find an initial reflection

Looking at my puzzle input, for part 1 at least, this feels doable even with poor algorithmic efficiency.
--]]

function part1(fileName)
	local chunks = readPatterns(fileName)
	local sum = 0

	for _, chunk in ipairs(chunks) do
		local horRe = findHorizontalReflection(chunk)
		local veRe = findVerticalReflection(chunk)

		if horRe ~= nil then
			sum = sum + 100 * (horRe - 1)
		elseif veRe ~= nil then
			sum = sum + veRe - 1
		else
			error("No reflection found! " .. aoc.dumpTable(chunk))
		end
	end
	return sum
end

assert(part1("inputs/13-example1.txt") == 405)
assert(part1("inputs/13.txt") == 35210)

-- Part 2 ---------------------------------------------------------------------

function part2(fileName)
	return 0
end

assert(part2("inputs/13-example1.txt") == 1)
assert(part2("inputs/13.txt") == 1)
