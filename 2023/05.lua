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

local Range = {}

function Range:new(startInclusive, stopInclusive, offset)
	if startInclusive > stopInclusive then
		return nil
	end
	local o = {
		startInclusive = startInclusive,
		stopInclusive = stopInclusive,
		offset = offset,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Range:shift(offset)
	self.startInclusive = self.startInclusive + offset
	self.stopInclusive = self.stopInclusive + offset
	return self
end

function Range:overlap(otherRange)
	if self.stopInclusive < otherRange.startInclusive then
		return nil
	elseif self.startInclusive > otherRange.stopInclusive then
		return nil
	else
		return Range:new(
				math.max(self.startInclusive, otherRange.startInclusive),
				math.min(self.stopInclusive, otherRange.stopInclusive)
		)
	end
end

assert(Range:new(10, 20):overlap(Range:new(30, 40)) == nil)
assert(Range:new(30, 40):overlap(Range:new(10, 20)) == nil)
assert(aoc.tableEqual(
		Range:new(5, 20):overlap(Range:new(10, 15)),
		Range:new(10, 15))
)

assert(aoc.tableEqual(
		Range:new(10, 15):overlap(Range:new(5, 20)),
		Range:new(10, 15))
)
assert(aoc.tableEqual(
		Range:new(5, 15):overlap(Range:new(10, 20)),
		Range:new(10, 15))
)
assert(aoc.tableEqual(
		Range:new(10, 20):overlap(Range:new(5, 15)),
		Range:new(10, 15))
)

function Range:partition(otherRange)
	--- Tricky one: We want to break _this_ range over the other range
	--- i.e. we want to end up with one-to-three ranges, breaking at the points in the other range
	--- With the _middle_ range containing
	local left, centre, right
	if self.stopInclusive < otherRange.startInclusive then
		return self, nil, nil
	elseif self.startInclusive > otherRange.stopInclusive then
		return nil, nil, self
	elseif self.startInclusive >= otherRange.startInclusive and self.stopInclusive <= otherRange.stopInclusive then
		centre = self
	elseif self.startInclusive <= otherRange.startInclusive or self.stopInclusive >= otherRange.stopInclusive then
		centre = self:overlap(otherRange)
		left = Range:new(self.startInclusive, centre.startInclusive - 1)
		right = Range:new(centre.stopInclusive + 1, self.stopInclusive)
	end

	if centre then
		centre = centre:shift(otherRange.offset)
	end

	return left, centre, right
end

function parseSeedRanges(lines)
	local seeds = {}
	local i = 0
	for a, b in lines[1]:gmatch("(%d+) (%d+)") do
		i = i + 1
		local start = tonumber(a)
		local offset = tonumber(b)
		seeds[i] = Range:new(start, start + offset - 1)
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
				acc[#acc + 1] = Range:new(
						source_start,
						source_start + range - 1,
						dest_start - source_start
				)
			end
		end
	end
	chunks[#chunks + 1] = acc
	return chunks
end

function mappingTranslation(seeds, mappings)
	local unmappedSeeds = seeds
	local mappedSeeds = {}
	for _, m in ipairs(mappings) do
		local seedsAcc = {}
		for _, s in pairs(unmappedSeeds) do
			l, c, r = s:partition(m)
			-- Clever idea: Inserting nil is a no-op so we don't need to check which values were returned
			table.insert(mappedSeeds, c)
			table.insert(seedsAcc, l)
			table.insert(seedsAcc, r)
		end
		unmappedSeeds = seedsAcc
		seedsAcc = {}
	end
	for i = 1, #unmappedSeeds do
		table.insert(mappedSeeds, unmappedSeeds[i])
	end
	return mappedSeeds
end

local function allMappingTranslation(seeds, mappings)
	for _, m in ipairs(mappings) do
		seeds = mappingTranslation(seeds, m)
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
		if result[r].startInclusive < smallest then
			smallest = result[r].startInclusive
		end
	end
	print(fileName, smallest)
	return smallest
end

assert(part2("inputs/05-example1.txt") == 46)
assert(part2("inputs/05.txt") == 4917124)
