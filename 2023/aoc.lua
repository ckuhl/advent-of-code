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

return aoc
