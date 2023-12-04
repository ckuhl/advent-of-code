-- Set-up
aoc = require("aoc")

function lineToParts(str)
	--- Helper: Split a string of the form `Card 1: 41 48 83 | 83 86  6` to a pair of strings
	str = string.match(str, ": (.+)$")
	return str:match("(.+) [|] (.+)")
end

function intStringToTable(intString)
	--- Helper: Create a set table to make membership look-ups fast
	-- https://www.lua.org/pil/11.5.html
	local t = {}
	for n in intString:gmatch("%d+") do
		t[tonumber(n)] = true
	end
	return t
end

function cardMatches(fileName)
	--- Helper: Create a table of `cardNumber: numMatches`
	local scores = {}
	local i = 0
	for l in io.lines(fileName) do
		i = i + 1
		local winners, all = lineToParts(l)

		local winnersSet = intStringToTable(winners)
		local cardSet = intStringToTable(all)

		local matchCount = 0
		for k, _ in pairs(cardSet) do
			if winnersSet[k] == true then
				matchCount = matchCount + 1
			end
		end

		scores[i] = matchCount
	end
	return scores
end

-- Part 1 ---------------------------------------------------------------------

function part1(fileName)
	local totalScore = 0
	for _, score in pairs(cardMatches(fileName)) do
		if score ~= 0 then
			totalScore = totalScore + 2 ^ (score - 1)
		end
	end
	return totalScore
end

assert(part1("inputs/04-example1.txt") == 13)
assert(part1("inputs/04.txt") == 24542)

-- Part 2 ---------------------------------------------------------------------

function part2(fileName)
	-- Key insight: A card can't affect an _earlier_ card index
	local matches = cardMatches(fileName)

	-- First, create a second table to count how many of each card we have
	local cards = {}
	for card = 1, #matches do
		cards[card] = 1
	end

	-- For each index, for each card won, add the number at the current index
	-- e.g. if we have 5 * Card5, and it has one match, add 5 to our Card6 count
	for cardOffset, numMatches in pairs(matches) do
		local multiplier = cards[cardOffset]
		for i = cardOffset + 1, cardOffset + numMatches do
			cards[i] = cards[i] + multiplier
		end
	end

	-- Finally, sum up our table
	local totalCards = 0
	for _, v in pairs(cards) do
		totalCards = totalCards + v
	end
	return totalCards
end

assert(part2("inputs/04-example1.txt") == 30)
assert(part2("inputs/04.txt") == 8736438)
