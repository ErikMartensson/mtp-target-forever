-- Helper functions for MTP Target Forever server Lua scripts

-- include() function - loads and executes a Lua file
-- This is a wrapper around dofile() that handles path resolution
function include(filename)
	-- Try data/lua/ directory first (for server scripts)
	local path = "data/lua/" .. filename
	local f = io.open(path, "r")
	if f then
		f:close()
		dofile(path)
		return
	end

	-- Try data/level/ directory (for level utilities)
	path = "data/level/" .. filename
	f = io.open(path, "r")
	if f then
		f:close()
		dofile(path)
		return
	end

	-- Try direct path
	f = io.open(filename, "r")
	if f then
		f:close()
		dofile(filename)
		return
	end

	-- File not found
	error("include(): Could not find file '" .. filename .. "'")
end
