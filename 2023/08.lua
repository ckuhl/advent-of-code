-- Set-up
aoc = require("aoc")

-- Part 1 ---------------------------------------------------------------------
function parseGraph(partialGraph, line)
	--- New (lazy?) approach: Construct a graph iteratively: One line at a time, with a partial graph
	for parent, left, right in line:gmatch("(%w+) = %((%w+), (%w+)%)") do
		partialGraph[parent] = { left, right }
	end
	return partialGraph
end

function parseFile(fileName)
	local instructions
	local graph = {}
	local i = 0
	for l in io.lines(fileName) do
		i = i + 1
		if i >= 2 then
			graph = parseGraph(graph, l)
		elseif i == 1 then
			instructions = l
		end
	end
	return instructions, graph
end

function navigateGraph(graph, instr, currNode)
	if instr == "L" then
		return graph[currNode][1]
	elseif instr == "R" then
		return graph[currNode][2]
	else
		-- Shouldn't happen but I want to capture odd output
		print("ERROR", "`" .. instr .. "`")
		return -1
	end
end

function navigateGraphInSteps(graph, instructions, startPatt, endPatt)
	local steps = 0
	local currentPatt = startPatt
	while not currentPatt:match(endPatt) do
		local c = instructions:sub(steps % #instructions + 1, steps % #instructions + 1)
		currentPatt = navigateGraph(graph, c, currentPatt)
		steps = steps + 1
	end
	return steps
end

function part1(fileName)
	local instructions
	local graph
	instructions, graph = parseFile(fileName)
	return navigateGraphInSteps(graph, instructions, "AAA", "ZZZ")
end

assert(part1("inputs/08-example1.txt") == 2)
assert(part1("inputs/08-example2.txt") == 6)
assert(part1("inputs/08.txt") == 19199)

-- Part 2 ---------------------------------------------------------------------

function nodesThatEndInA(graph)
	local t = {}
	i = 1
	for k, _ in pairs(graph) do
		if k:match("..A") then
			t[i] = k
			i = i + 1
		end
	end
	return t
end

function nodesAllEndInZ(nodes)
	for _, n in ipairs(nodes) do
		if not n:match("..Z") then
			return false
		end
	end
	return true
end

function part2(fileName)
	local instructions
	local graph
	instructions, graph = parseFile(fileName)

	local nodes = nodesThatEndInA(graph)
	local steps = 0

	while not nodesAllEndInZ(nodes) do
		local c = instructions:sub(steps % #instructions + 1, steps % #instructions + 1)
		for i, v in ipairs(nodes) do
			nodes[i] = navigateGraph(graph, c, v)
		end
		steps = steps + 1
	end
	return steps
end

assert(part2("inputs/08-example3.txt") == 6)
assert(part2("inputs/08.txt") == 1)
