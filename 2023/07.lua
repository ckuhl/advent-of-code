-- Set-up
aoc = require("aoc")

part1Scores = {
	["A"] = 14,
	["K"] = 13,
	["Q"] = 12,
	["J"] = 11,
	["T"] = 10,
	["9"] = 9,
	["8"] = 8,
	["7"] = 7,
	["6"] = 6,
	["5"] = 5,
	["4"] = 4,
	["3"] = 3,
	["2"] = 2,
}

part2Scores = {
	["A"] = 13,
	["K"] = 12,
	["Q"] = 11,
	["T"] = 10,
	["9"] = 9,
	["8"] = 8,
	["7"] = 7,
	["6"] = 6,
	["5"] = 5,
	["4"] = 4,
	["3"] = 3,
	["2"] = 2,
	["J"] = 1,
}

--- Given a string of the form "A428J", convert it to a table of numbers
function stringToHand(str, useJokers)
	local lookup = useJokers and part2Scores or part1Scores
	local t = {}
	for i = 1, #str do
		local c = str:sub(i, i)
		t[i] = lookup[c]
	end
	return t
end

--- First part of scoring: Determining the hand _type_
function handToType(hand, usingJokers)
	local handCount = {}
	for _, v in pairs(hand) do
		local prev = handCount[v]
		if prev == nil then
			handCount[v] = 1
		else
			handCount[v] = prev + 1
		end
	end

	if usingJokers then
		print(aoc.dumpTable(handCount))
		local jokerCount = handCount[part2Scores.J]
		if jokerCount == nil then
			jokerCount = 0
		end
		print('jc', jokerCount)
		if jokerCount == 5 then
			return 7
		end

		handCount[part2Scores.J] = nil
		local bestCard
		for k, v in pairs(handCount) do
			if bestCard == nil then
				bestCard = k
			elseif v > handCount[bestCard] then
				bestCard = k
			end
		end
		handCount[bestCard] = handCount[bestCard] + jokerCount
		handCount["J"] = nil
	end

	local uniqueCards = aoc.tableSize(handCount)
	if uniqueCards == 1 then
		-- Five of a kind
		return 7
	elseif uniqueCards == 2 then
		for _, v in pairs(handCount) do
			if v == 2 or v == 3 then
				-- Full house
				return 5
			else
				-- Four of a kind
				return 6
			end
		end
	elseif uniqueCards == 3 then
		for _, v in pairs(handCount) do
			if v == 2 then
				-- Two pair
				return 3
			elseif v == 3 then
				-- Three of a kind
				return 4
			end
		end
	elseif uniqueCards == 4 then
		-- One pair
		return 2
	else
		-- High card
		return 1
	end
end

function handLessThan(left, right, useJokers)
	local leftStr = left[1]
	local rightStr = right[1]
	local leftType = handToType(stringToHand(leftStr, useJokers), useJokers)
	local rightType = handToType(stringToHand(rightStr, useJokers), useJokers)
	if leftType < rightType then
		return true
	elseif leftType > rightType then
		return false
	end
	-- Special case: left == right, compare cards
	for i = 1, #leftStr do
		local leftCharScore, rightCharScore
		if useJokers == true then
			leftCharScore = part2Scores[leftStr:sub(i, i)]
			rightCharScore = part2Scores[rightStr:sub(i, i)]
		else
			leftCharScore = part1Scores[leftStr:sub(i, i)]
			rightCharScore = part1Scores[rightStr:sub(i, i)]
		end
		if leftCharScore < rightCharScore then
			return true
		elseif leftCharScore > rightCharScore then
			return false
		end
	end
	-- Error case: Two completely-equal hands
	return nil
end

function formatInputHands(fileName)
	local t = {}
	local i = 0
	for l in io.lines(fileName) do
		i = i + 1
		for hand, bid in l:gmatch("(.+) (%d+)") do
			t[i] = { hand, bid }
		end
	end
	return t
end

-- Part 1 ---------------------------------------------------------------------

function part1(fileName)
	local inputHands = formatInputHands(fileName)
	table.sort(inputHands, handLessThan)

	local totalWinnings = 0
	for i, bid in ipairs(inputHands) do
		totalWinnings = totalWinnings + i * tonumber(bid[2])
	end
	return totalWinnings
end

assert(part1("inputs/07-example1.txt") == 6440)
assert(part1("inputs/07.txt") == 251927063)

-- Part 2 ---------------------------------------------------------------------

--[[
My lazy thinking: For each J, swap _all possible values_
Or lazy thinking 2: Precompute all possible best-hands for partial hands.
i.e. if you have a partial hand of three, and a pair, the best you can have is
four of a kind (since the other two would be jokers).
--]]
function part2(fileName)
	local inputHands = formatInputHands(fileName)
	table.sort(inputHands, function(l, r)
		handLessThan(l, r, true)
	end)

	local totalWinnings = 0
	for i, bid in ipairs(inputHands) do
		totalWinnings = totalWinnings + i * tonumber(bid[2])
	end
	return totalWinnings
end

assert(part2("inputs/07-example1.txt") == 5905)
assert(part2("inputs/07.txt") == 255632664)
