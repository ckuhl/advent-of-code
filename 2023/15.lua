-- Set-up
aoc = require("aoc")

function parseInputPairs(fileName)
	local t = {}
	for l in io.lines(fileName) do
		for x in l:gmatch("([^,]+)") do
			table.insert(t, x)
		end
		return t
	end
end

-- Part 1 ---------------------------------------------------------------------

function HashAlgorithm(str)
	local currentValue = 0
	for i = 1, #str do
		local c = string.sub(str, i, i)
		currentValue = currentValue + string.byte(c)
		currentValue = currentValue * 17
		currentValue = currentValue % 256
	end
	return currentValue
end

function part1(fileName)
	local sum = 0
	local inputs = parseInputPairs(fileName)
	for _, v in ipairs(inputs) do
		sum = sum + HashAlgorithm(v)
	end
	return sum
end

assert(part1("inputs/15-example1.txt") == 1320)
assert(part1("inputs/15.txt") == 517551)

-- Part 2 ---------------------------------------------------------------------

function extractValueLabelLength(str)
	local label = str:match("^([^=%-]+)")
	local focalLength = str:match("([^=%-]+)$")
	local boxValue = HashAlgorithm(str)
	return boxValue, label, focalLength
end

function HashmapAlgorithm(str, partialLensArray)
	local value, label, length = extractValueLabelLength(str)
	error("TODO, implement rest")
end

function focusingPower(lensArray)
	error("TODO: Calculate focusing power")
end

function part2(fileName)
	local inputs = parseInputPairs(fileName)
	local lensArray = {}
	for _, v in ipairs(inputs) do
		lensArray = HashmapAlgorithm(v, lensArray)
	end
	print(fileName, focusingPower(lensArray))
	return focusingPower(lensArray)
end

assert(part2("inputs/15-example1.txt") == 145)
assert(part2("inputs/15.txt") == 1)
