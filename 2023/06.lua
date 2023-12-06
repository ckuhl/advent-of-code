-- Set-up
aoc = require("aoc")

-- Part 1 ---------------------------------------------------------------------

function loadInfo(fileName)
	local f = io.open(fileName)

	local times = {}
	local i = 0
	for n in f:read():gmatch("%d+") do
		i = i + 1
		times[i] = tonumber(n)
	end

	local dists = {}
	i = 0
	for n in f:read():gmatch("%d+") do
		i = i + 1
		dists[i] = tonumber(n)
	end
	return times, dists
end

function countSolutions(time, distance)
	local winners = 0
	for buttonHoldTime = 0, time do
		local travelTime = time - buttonHoldTime
		if buttonHoldTime * travelTime > distance then
			winners = winners + 1
		end
	end
	return winners
end

function part1(fileName)
	local times, dists = loadInfo(fileName)
	local recordWinMult = 1
	for i = 1, #times do
		recordWinMult = recordWinMult * countSolutions(times[i], dists[i])
	end
	return recordWinMult
end

assert(part1("inputs/06-example1.txt") == 288)
assert(part1("inputs/06.txt") == 503424)

-- Part 2 ---------------------------------------------------------------------

function loadInfo2(fileName)
	local f = io.open(fileName)

	local numstr = ""
	for n in f:read():gmatch("%d") do
		numstr = numstr .. n
	end
	local time = tonumber(numstr)

	local diststr = ""
	for n in f:read():gmatch("%d+") do
		diststr = diststr .. n
	end
	local dist = tonumber(diststr)
	return time, dist
end

function part2(fileName)
	time2, dist2 = loadInfo2(fileName)
	return countSolutions(time2, dist2)
end

assert(part2("inputs/06-example1.txt") == 71503)
assert(part2("inputs/06.txt") == 32607562)
