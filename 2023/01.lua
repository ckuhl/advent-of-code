function part1(fileName)
	local total = 0
	for l in io.lines(fileName) do
		total = total + tonumber(l:match('^%a*(%d)') .. l:match('(%d)%a*$'))
	end
	return total
end

-- Part 1:
assert(part1('inputs/01-example1.txt') == 142)
assert(part1('inputs/01.txt') == 54951)

-- Part 2:
-- Excuse me? Lua does not have a regex OR???

local numbers = {
	'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', '%d'
}

function findFirst(s)
	local earliest = s:len()
	local value = nil
	for n = 1, #numbers do
		for c, d in s:gmatch('()' .. numbers[n] .. '()') do
			-- if this is a new "earliest" number
			if d ~= nil and d - 1 <= earliest then
				earliest = d - 1
				if n == 10 then
					value = tonumber(s:match('^%a*(%d)'))
				else
		value = n
				end
			end
		end
	end
	return value
end

-- TODO: Consider merging these two into a "find all" and return offsets
function findLast(s)
	local latest = 0
	local value = nil
	for n = 1, #numbers do
		for c, d in s:gmatch('()' .. numbers[n] .. '()') do
			-- if this is a new "earliest" number
			if c ~= nil and c >= latest then
				latest = c
				if n == 10 then
					value = tonumber(s:match('(%d)%a-$'))
				else
					-- We set up the word regexes to match their index
					value = n
				end
			end
		end
	end
	return value
end

function part2(fileName)
	local total = 0
	for l in io.lines(fileName) do
		total = total + tonumber(tostring(findFirst(l)) .. tostring(findLast(l)))
	end
	return total
end

assert(part2("inputs/01-example2.txt") == 281)
assert(part2("inputs/01.txt") == 55218)

