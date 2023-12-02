-- Set-up

-- Part 1 ---------------------------------------------------------------------

-- TODO: Write a "string.split" function for a self-library
function part1(fileName)
	local colourLimits = { ["red"] = 12, ["blue"] = 14, ["green"] = 13 }
	local legalGameSum = 0

	for l in io.lines(fileName) do
		local gameNumber = tonumber(l:match("Game ([0-9]+)"))
		for colour, limit in pairs(colourLimits) do
			for s in string.gmatch(l, "([0-9]+) " .. colour) do
				-- If any value is illegal, we don't want to count it... simply make the value zero!
				if tonumber(s) > limit then
					gameNumber = 0
				end
			end
		end
		legalGameSum = legalGameSum + gameNumber
	end
	return legalGameSum
end

assert(part1("inputs/02-example1.txt") == 8)
assert(part1("inputs/02.txt") == 2207)

-- Part 2 ---------------------------------------------------------------------

function part2(fileName)
	local gamePowerSum = 0
	for l in io.lines(fileName) do
		local colours = { ["red"] = 0, ["blue"] = 0, ["green"] = 0 }
		for colour, _ in pairs(colours) do
			for s in string.gmatch(l, "([0-9]+) " .. colour) do
				colours[colour] = math.max(colours[colour], tonumber(s))
			end
		end
		gamePowerSum = gamePowerSum + (colours.red * colours.green * colours.blue)
	end
	return gamePowerSum
end

assert(part2("inputs/02-example1.txt") == 2286)
assert(part2("inputs/02.txt") == 62241)
