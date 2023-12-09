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
	local seeds = {}
	local i = 0
	for seed in inputLines[1]:gmatch("(%d+)") do
		i = i + 1
		seeds[i] = tonumber(seed)
	end
	return seeds
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

function parseSeedRanges(lines)
	local seeds = {}
	local i = 0
	for a, b in lines[1]:gmatch("(%d+) (%d+)") do
		i = i + 1
		local start = tonumber(a)
		local offset = tonumber(b)
		seeds[i] = { ["left"] = start, ["right"] = start + offset - 1 }
	end
	return seeds
end

function parseMappings(lines)
	local chunks = {}
	local acc = {}
	-- Start at three to skip the initial "seeds" line, and then the newline after
	for i = 3, #lines do
		if lines[i]:match("^$") then
			-- End of mapping, add to array and start next
			chunks[#chunks + 1] = acc
			acc = {}
		elseif lines[i]:match("map:$") then
			-- Start of mapping, add name (for human) to accumulator
			acc["name"] = lines[i]:sub(1, -6)
		else
			for a, b, c in lines[i]:gmatch("(%d+) (%d+) (%d+)") do
				local dest_start = tonumber(a)
				local source_start = tonumber(b)
				local range = tonumber(c)
				acc[#acc + 1] = {
					["srcL"] = source_start,
					["srcR"] = source_start + range,
					["offset"] = dest_start - source_start,
				}
			end
		end
	end
	return chunks
end

--[[
Given a single seed range [start, stop] and a single translation range [srcStart, srcEnd, destStart, destEnd]
Apply any relevant translations, returning an array of ranges (due to overlaps)
We have 4 unique cases to consider:
1. Translation range does not overlap with seed range (left or right).
2. Seed range entirely within translation range.
3. Translation range partially overlaps (left, right, or both - is smaller than seed range)

Return two results:
1. New ranges from modified range.
2. Single range, if unmodified, or empty if modified.
--]]
function singleRangeTranslation(seed, mappedRange)
	if seed.right < mappedRange.srcL then
		-- Case 1: Seed range entirely left of translation range
		return { }, seed
	elseif seed.left > mappedRange.srcR then
		-- Case 1: Seed range entirely right of translation range
		return { }, seed
	elseif seed.left >= mappedRange.srcL and seed.right <= mappedRange.srcR then
		-- Case 2: Seed range entirely within translation range
		return { { ["left"] = seed.left + mappedRange.offset, ["right"] = seed.right + mappedRange.offset } }, nil
	else
		local seeds = {}
		-- Case 3: Partial overlap
		-- 1. Do inner range.
		seeds[1] = {
			["left"] = math.max(seed.left, mappedRange.srcL) + mappedRange.offset,
			["right"] = math.min(seed.right, mappedRange.srcR) + mappedRange.offset,
		}
		-- 2. If left overlap, do left outer range.
		if seed.left < mappedRange.srcL then
			seeds[2] = {
				["left"] = seed.left,
				["right"] = mappedRange.srcL - 1,
			}
		end
		-- 3. If right overlap, do right outer range.
		if seed.right > mappedRange.srcR then
			seeds[#seeds + 1] = {
				["left"] = mappedRange.srcR + 1,
				["right"] = seed.right,
			}
		end
		return seeds, nil
	end
end

-- Given a series of ranges and a _series_ of mappings, apply all translation. Return the range(s).
function wholeMappingTranslation(inputRanges, mappings)
	local outputRanges = {}
	for i, range in ipairs(inputRanges) do
		for j, mapping in ipairs(mappings) do
			local modified
			if range ~= nil then
				modified, range = singleRangeTranslation(range, mapping)
			end
			if modified ~= nil and #modified ~= 0 then
				outputRanges = aoc.tableAppend(outputRanges, modified)
				range = nil
			end
		end
		if range ~= nil then
			outputRanges[#outputRanges + 1] = range
		end
	end
	return outputRanges
end

-- Given a series of ranges and _all_ mappings, apply each mapping block. Return the final ranges.
function allMappingTranslation(seeds, mappings)
	for i = 1, #mappings do
		seeds = wholeMappingTranslation(seeds, mappings[i])
	end
	return seeds
end

function part2(fileName)
	local inputTable = loadFile(fileName)
	local seeds = parseSeedRanges(inputTable)
	local mappings = parseMappings(inputTable)

	local result = allMappingTranslation(seeds, mappings)

	local smallest = 1 / 0
	for r = 1, #result do
		if result[r].left < smallest then
			smallest = result[r].left
		end
	end
	print(fileName, smallest)
	return smallest
end

assert(part2("inputs/05-example1.txt") == 46)
assert(part2("inputs/05.txt") == 1)
