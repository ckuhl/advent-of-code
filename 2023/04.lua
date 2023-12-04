-- Set-up
aoc = require("aoc")

function lineToParts(str)
	str = string.match(str, ": (.+)$")
	return str:match("(.+) [|] (.+)")
end

function intStringToTable(intString)
	-- https://www.lua.org/pil/11.5.html
	local t = {}
	for n in intString:gmatch("%d+") do
		t[tonumber(n)] = true
	end
	return t
end

-- Part 1 ---------------------------------------------------------------------


function part1(fileName)
	local totalScore = 0
	for l in io.lines(fileName) do
		local cardScore = 0
		local winners, all = lineToParts(l)

		local winnersSet = intStringToTable(winners)
		local cardSet = intStringToTable(all)

		for k, _ in pairs(cardSet) do
			if winnersSet[k] == true then
				if cardScore == 0 then
					cardScore = 1
				else
					cardScore = cardScore * 2
				end
			end
		end
		totalScore = totalScore + cardScore
	end
	return totalScore
end

assert(part1("inputs/04-example1.txt") == 13)
assert(part1("inputs/04.txt") == 24542)

-- Part 2 ---------------------------------------------------------------------

-- Key insight: Work backwards!
-- The last card cannot win any cards, done (n)
-- The second last card can win at most the last card (n-1 -> n), or none (n-1).
-- TODO: The rest tomorrow morning.
function part2(fileName)
	for l in io.lines(fileName) do
	end
	return -1
end

--assert(part2("inputs/04-example2.txt") == 30)
--assert(part2("inputs/04.txt") == 1)
