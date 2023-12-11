local Set = {}
Set.__index = Set

---
--- Instantiate a new, empty set.
---@return self
function Set.new()
	local self = setmetatable({}, Set)
	self.inner = {}
	return self
end

---
--- Add elements from an array into the set.
---@param t table<number, any>
---@return self
function Set.from(self, t)
	for _, v in ipairs(t) do
		self.table[v] = true
	end
end

---
--- Add a single given element into the set.
---@param item any
---@return self
function Set.add(self, item)
	self.inner[item] = true
end

---
--- Remove and return a single given element.
--- Respects `table.remove` rules for missing elements
---@param item any
---@return any
function Set.remove(self, item)
	return self.inner.remove(item)
end

---
--- Return the number of elements in the set
---@return number
function Set.size(self)
	local count = 0
	for _, _ in pairs(self.inner) do
		count = count + 1
	end
	return count
end

---
--- Test if the element contains a given element.
---@param item any
---@return boolean
function Set.contains(self, item)
	-- TODO: Handle nil case
	return self.inner[item] == true
end

function Set.toArray(self)
	local t = {}
	for k, _ in pairs(self.inner) do
		t[#t + 1] = k
	end
	return t
end

return Set
