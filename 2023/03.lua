-- Set-up
aoc = require("aoc")

-- Part 1 ---------------------------------------------------------------------
function isSymbol(str)
	if str == nil then
		-- Case: Out of bounds
		return false
	elseif str == "." then
		-- Case: Filter out 'empty' values
		return false
	else
		-- Case: Numbers are not symbols
		return tonumber(str) == nil
	end
end

function isSpecialCharacterAroundRange(mapping, px1, px2, py)
	-- Check if there is a special character
	for y = py - 1, py + 1 do
		for x = px1 - 1, px2 + 1 do
			-- Guard on checking itself
			if not (y == py and x >= px1 and x <= px2) and isSymbol(mapping[tonumber(x) .. ";" .. tonumber(y)]) then
				return true
			end
		end
	end
	return false
end

function part1(fileName)
	local mapping = aoc.fileToPoints(fileName)
	local partsSum = 0
	local y = 0
	for l in io.lines(fileName) do
		y = y + 1
		for x_start, x_end_past in l:gmatch("()%d+()") do
			if isSpecialCharacterAroundRange(mapping, x_start, x_end_past - 1, y) then
				partsSum = partsSum + tonumber(l:sub(x_start, x_end_past - 1))
			end
		end
	end
	return partsSum
end

assert(part1("inputs/03-example1.txt") == 4361)
assert(part1("inputs/03.txt") == 517021)

-- Part 2 ---------------------------------------------------------------------

function findAdjacentStar(mapping, px1, px2, py)
	-- Helper: Given a number (i.e. a range of x values it occupies), return a star if adjacent
	for y = py - 1, py + 1 do
		for x = px1 - 1, px2 + 1 do
			local key = tonumber(x) .. ";" .. tonumber(y)
			if not (y == py and x == px) and mapping[key] == "*" then
				return key
			end
		end
	end
end

function part2(fileName)
	--[[
1. Find number.
2. Is number adjacent to '*'?
2.1. YES: Does star exist in table (i.e. have we already seen a number by this star?)
2.1.1. YES: Multiply value by star entry, add to score.
2.1.2. NO: Add entry to table (star_pos) = number
	--]]
	local mapping = aoc.fileToPoints(fileName)
	local stars = {}
	local gearRatioSum = 0

	local y = 0
	for l in io.lines(fileName) do
		y = y + 1
		for x_start, x_end_past in l:gmatch("()%d+()") do
			local number = tonumber(l:sub(x_start, x_end_past - 1))
			local pos = findAdjacentStar(mapping, x_start, x_end_past - 1, y)
			if pos ~= nil then
				if stars[pos] == nil then
					stars[pos] = number
				else
					gearRatioSum = gearRatioSum + stars[pos] * number
					-- Guard: Overwrite the star value to a sentinel, proving there's no three-number stars
					stars[pos] = 0 / 0
				end
			end
		end
	end
	return gearRatioSum
end

assert(part2("inputs/03-example1.txt") == 467835)
assert(part2("inputs/03.txt") == 81296995)
