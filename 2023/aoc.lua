local aoc = {}

--- Helper: Dump table into string for easy printing out
function aoc.dumpTable(t)
	local s = "{ "
	for k, v in pairs(t) do
		s = s .. "[" .. tostring(k) .. "] = " .. tostring(v) .. ", "
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

function aoc.tableUpdate(into, from)
	for k, v in pairs(from) do
		into[k] = v
	end
	return into
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
