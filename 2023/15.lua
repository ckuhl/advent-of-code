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
	local boxValue = HashAlgorithm(label)
	return boxValue, label, focalLength
end

-- Partial lens array: Table of drawer : arrays of {lensLabel, lensFocus}
function HashmapAlgorithm(str, partialLensArray)
	local drawerOffset, label, lens = extractValueLabelLength(str)
	local drawer = partialLensArray[drawerOffset] or {}

	if lens ~= nil then
		-- Case: `=` operation, insert or update
		local newItem = { label, tonumber(lens) }
		local wasUpdated = false
		for i, item in ipairs(drawer) do
			if item[1] == label then
				drawer[i] = newItem
				wasUpdated = true
				break
			end
		end
		if not wasUpdated then
			table.insert(drawer, newItem)
		end
	else
		-- Case: `-` operation, remove element if it exists
		for i, item in ipairs(drawer) do
			if item[1] == label then
				table.remove(drawer, i)
				break
			end
		end
	end

	partialLensArray[drawerOffset] = drawer
	return partialLensArray
end

function focusingPower(lensArray)
	local power = 0
	for i, drawer in pairs(lensArray) do
		for j, lens in ipairs(drawer) do
			power = power + (i + 1) * j * lens[2]
		end
	end
	return power
end

function part2(fileName)
	local inputs = parseInputPairs(fileName)
	local lensArray = {}
	for _, v in ipairs(inputs) do
		lensArray = HashmapAlgorithm(v, lensArray)
	end
	return focusingPower(lensArray)
end

assert(part2("inputs/15-example1.txt") == 145)
assert(part2("inputs/15.txt") == 286097)
