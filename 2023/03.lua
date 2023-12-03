-- Set-up
aoc = require("aoc")

-- Part 1 ---------------------------------------------------------------------
-- Helper: Convert file to list of points
-- Format: "x:y" : <char>
function fileToPoints(fileName)
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

function isNonSymbol(str)
    if str == nil then
        return false
    end
    local symbols = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "." }
    for _, l in ipairs(symbols) do
        symbols[l] = true
    end
    if symbols[str] then
        return false
    else
        return true
    end
end

-- Return true if any adjacent symbols (i.e. any non-'.', non-integer characters)
function adjacentSymbols(mapping, px, py)
    for y = py - 1, py + 1 do
        for x = px - 1, px + 1 do
            if not (y == py and x == px) and isNonSymbol(mapping[tonumber(x) .. ";" .. tonumber(y)]) then
                return true
            end
        end
    end
    return false
end

function specialCharacterInRange(mapping, py, px1, px2)
    for x = px1, px2 do
        if adjacentSymbols(mapping, x, py) then
            return true
        end
    end
    return false
end

function part1(fileName)
    local mapping = fileToPoints(fileName)
    local partsSum = 0
    local y = 0
    for l in io.lines(fileName) do
        y = y + 1
        for x_start, x_end_past in l:gmatch("()%d+()") do
            local x_end = x_end_past - 1
            if specialCharacterInRange(mapping, y, x_start, x_end) then
                partsSum = partsSum + tonumber(string.sub(l, x_start, x_end))
            end
        end
    end
    return partsSum
end

assert(part1("inputs/03-example1.txt") == 4361)
assert(part1("inputs/03.txt") == 517021)

-- Part 2 ---------------------------------------------------------------------

-- TODO: The rest of this is a tomorrow problem

function part2(fileName)
    --for l in io.lines(fileName) do
    --end
    return -1
end

assert(part2("inputs/03-example2.txt") == 1)
assert(part2("inputs/03.txt") == 1)
