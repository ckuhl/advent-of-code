-- Set-up
aoc = require("aoc")

-- Part 1 ---------------------------------------------------------------------

function allZero(t)
	for _, v in pairs(t) do
		if v ~= 0 then
			return false
		end
	end
	return true
end

function findNext(diff)
	local next = 0
	while not allZero(diff) do
		for i = 1, #diff - 1 do
			diff[i] = diff[i + 1] - diff[i]
		end
		next = next + diff[#diff]
		diff[#diff] = nil
	end
	return next
end

function part1(fileName)
	local lineSum = 0
	for l in io.lines(fileName) do
		local t = {}
		local i = 0
		for n in l:gmatch("%-?%d+") do
			i = i + 1
			t[i] = tonumber(n)
		end
		lineSum = lineSum + findNext(t)
	end
	return lineSum
end

assert(part1("inputs/09-example1.txt") == 114)
assert(part1("inputs/09.txt") == 2075724761)

-- Part 2 ---------------------------------------------------------------------

-- Insight: We can find the first item by flipping between subtracting and adding alternating numbers down the pyramid
-- this can lazily be accomplished without a depth-counter by flipping a sign (multiplying by -1) each turn
function findPrev(diff)
	local prev = diff[1]
	local sign = -1

	while not allZero(diff) do
		for i = 1, #diff - 1 do
			diff[i] = diff[i + 1] - diff[i]
		end
		diff[#diff] = nil

		prev = prev + diff[1] * sign
		sign = sign * -1
	end
	return prev
end

-- FIXME: Consider extracting and unifying with part1
-- Perhaps alongside unifying the findPrev/findNext functions as well
function part2(fileName)
	local lineSum = 0
	for l in io.lines(fileName) do
		local t = {}
		local i = 0
		for n in l:gmatch("%-?%d+") do
			i = i + 1
			t[i] = tonumber(n)
		end
		lineSum = lineSum + findPrev(t)
	end
	return lineSum
end

assert(part2("inputs/09-example1.txt") == 2)
assert(part2("inputs/09.txt") == 1072)
