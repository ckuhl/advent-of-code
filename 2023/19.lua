-- Set-up
aoc = require("aoc")

--[[
For Part 1 at least, this follows a relatively simple approach:
We construct a table mapping rule-names to rules.
We then have a recursive function that takes a part, current rule, and rule table.
Each iteration, it finds the next relevant rule and calls itself.
Or, returns with A or R.
--]]

--- Parse a single rule string (e.g. px{a<2006:qkq,m>2090:A,rfg})
--- into a pair of rule-name, table-of-rules
function parseRule(str)
	local name = str:match("^(%a+){")
	local subStr = string.match(str, "{(.+)}$")

	local rules = {}
	for item in subStr:gmatch("([^,]+)") do
		table.insert(rules, item)
	end
	return name, rules
end

--- Parse a part rating into a table
function parsePart(str)
	local t = {}
	for label, value in str:gmatch("([^,{}]+)=([^,{}]+)") do
		t[label] = tonumber(value)
	end
	return t
end

function parseInput(fileName)
	local rules, parts = {}, {}
	local inRules = true
	for l in io.lines(fileName) do
		if l:match("^$") then
			inRules = false
		elseif inRules then
			local name, rule = parseRule(l)
			rules[name] = rule
		else
			table.insert(parts, parsePart(l))
		end
	end
	return rules, parts
end

function doesPassRule(part, rule)
	-- Base case: If a rule is a label, always return that
	if not rule:match(":") then
		return rule
	end

	local partField = rule:match("^([^<>]+)")
	local condition = rule:match("[<>]")
	local value = tonumber(rule:match("%d+"))
	local dest = rule:match(":(.+)$")

	if condition == ">" then
		return part[partField] > value and dest or false
	else
		return part[partField] < value and dest or false
	end
end

function isPartAccepted(rules, part, label)
	-- All parts start at the rule "in"
	if label == nil then
		label = "in"
	end
	for _, rule in ipairs(rules[label]) do
		local outcome = doesPassRule(part, rule)
		if outcome == "A" then
			return true
		elseif outcome == "R" then
			return false
		elseif outcome ~= false then
			return isPartAccepted(rules, part, outcome)
		end
	end
	error("Label: " .. label .. " was not found to have any matching rules")
end
-- Part 1 ---------------------------------------------------------------------

function part1(fileName)
	local partRatingSum = 0

	local rules, parts = parseInput(fileName)
	for _, part in ipairs(parts) do
		if isPartAccepted(rules, part) then
			for _, v in pairs(part) do
				partRatingSum = partRatingSum + v
			end
		end
	end
	return partRatingSum
end

assert(part1("inputs/19-example1.txt") == 19114)
assert(part1("inputs/19.txt") == 432434)

-- Part 2 ---------------------------------------------------------------------

--[[
Hmm, so now we want to determine which combinations will be valid.
Obviously the naive way won't work - that number is too big.
We also can't track each range globally - rules are conditional on previous
rules. So we need to go down each path of rules separately.

In effect, at _each_ rule, we want to split: "If this was true, what range of
values could I have left? If this was false, ```"
Then we'd sum them up.
--]]
function part2(fileName)
	local rules = parseInput(fileName)
	local validCombinations = -1
	print(fileName, validCombinations)
	return validCombinations
end

assert(part2("inputs/19-example1.txt") == 167409079868000)
assert(part2("inputs/19.txt") == 1)
