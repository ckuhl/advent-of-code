local aoc = {}

--- Helper: Dump table into string for easy printing out
function aoc.dumpTable(t)
	local s = "{ "
	for k, v in pairs(t) do
		local stringK = tostring(k)
		local stringV
		if type(v) == "table" then
			stringV = aoc.dumpTable(v)
		elseif type(v) == "string" then
			stringV = "\"" .. v .. "\""
		else
			stringV = tostring(v)
		end
		s = s .. "[" .. stringK .. "] = " .. stringV .. ", "
	end
	s = s .. "}"
	return s
end

function aoc.tableMin(t)
	local soFar = nil
	for _, v in pairs(t) do
		if soFar == nil or soFar > v then
			soFar = v
		end
	end
	return soFar
end

function aoc.tableMax(t)
	local soFar = nil
	for _, v in pairs(t) do
		if soFar == nil or soFar < v then
			soFar = v
		end
	end
	return soFar
end

function aoc.tableAppend(left, right)
	for i = 1, #right do
		left[#left + i] = right[i]
	end
	return left
end

function aoc.tableUpdate(into, from)
	for k, v in pairs(from) do
		into[k] = v
	end
	return into
end

function aoc.tableSize(t)
	local count = 0
	for _, __ in pairs(t) do
		count = count + 1
	end
	return count
end

--- Helper: Split string into table based on given separator (or spaces if not separator given)
function aoc.split(inputString, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for s in string.gmatch(inputString, "([^" .. sep .. "]+)") do
		table.insert(t, s)
	end
	return t
end

--- Helper: Given a filename, convert it to a table: "x;y" to character
function aoc.fileToPoints(fileName)
	local t = {}
	local y = 0
	for l in io.lines(fileName) do
		y = y + 1
		local x = 0
		for i = 1, #l do
			x = x + 1
			local c = l:sub(i, i)
			t[tostring(x) .. ";" .. tostring(y)] = c
		end
	end
	return t
end

return aoc
