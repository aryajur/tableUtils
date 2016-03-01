-- Table utils
local tostring = tostring
local type = type
local pairs = pairs
local string = string
local table = table

-- Create the module table here
local M = {}
package.loaded[...] = M
if setfenv and type(setfenv) == "function" then
	setfenv(1,M)	-- Lua 5.1
else
	_ENV = M		-- Lua 5.2+
end

_VERSION = "1.16.2.29"


-- Function to convert a table to a string
-- Metatables not followed
-- Unless key is a number it will be taken and converted to a string
function t2s(t)
	local levels = 0
	local rL = {cL = 1}	-- Table to track recursion into nested tables (cL = current recursion level)
	rL[rL.cL] = {}
	local result = {}
	do
		rL[rL.cL]._f,rL[rL.cL]._s,rL[rL.cL]._var = pairs(t)
		--result[#result + 1] =  "{\n"..string.rep("\t",levels+1)		
		result[#result + 1] = "{"		-- Non pretty version
		rL[rL.cL].t = t
		while true do
			local k,v = rL[rL.cL]._f(rL[rL.cL]._s,rL[rL.cL]._var)
			rL[rL.cL]._var = k
			if not k and rL.cL == 1 then
				break
			elseif not k then
				-- go up in recursion level
				-- If condition for pretty printing
				-- if result[#result]:sub(-1,-1) == "," then
					-- result[#result] = result[#result]:sub(1,-3)	-- remove the tab and the comma
				-- else
					-- result[#result] = result[#result]:sub(1,-2)	-- just remove the tab
				-- end
				result[#result + 1] = "},"	-- non pretty version
				levels = levels - 1
				rL.cL = rL.cL - 1
				rL[rL.cL+1] = nil
				--rL[rL.cL].str = rL[rL.cL].str..",\n"..string.rep("\t",levels+1)
			else
				-- Handle the key and value here
				if type(k) == "number" then
					result[#result + 1] = "["..tostring(k).."]="
				else
					result[#result + 1] = "["..[["]]..tostring(k)..[["]].."]="
				end
				if type(v) == "table" then
					-- Check if this is not a recursive table
					local goDown = true
					for i = 1, rL.cL do
						if v==rL[i].t then
							-- This is recursive do not go down
							goDown = false
							break
						end
					end
					if goDown then
						-- Go deeper in recursion
						levels = levels + 1
						rL.cL = rL.cL + 1
						rL[rL.cL] = {}
						rL[rL.cL]._f,rL[rL.cL]._s,rL[rL.cL]._var = pairs(v)
						--result[#result + 1] = "{\n"..string.rep("\t",levels+1)
						result[#result + 1] = "{"	-- non pretty version
						rL[rL.cL].t = v
					else
						--result[#result + 1] = "\""..tostring(v).."\",\n"..string.rep("\t",levels+1)
						result[#result + 1] = "\""..tostring(v).."\","	-- non pretty version
					end
				elseif type(v) == "number" or type(v) == "boolean" then
					--result[#result + 1] = tostring(v)..",\n"..string.rep("\t",levels+1)
					result[#result + 1] = tostring(v)..","	-- non pretty version
				else
					--result[#result + 1] = string.format("%q",tostring(v))..",\n"..string.rep("\t",levels+1)
					result[#result + 1] = string.format("%q",tostring(v))..","	-- non pretty version
				end		-- if type(v) == "table" then ends
			end		-- if not rL[rL.cL]._var and rL.cL == 1 then ends
		end		-- while true ends here
	end		-- do ends
	-- If condition for pretty printing
	-- if result[#result]:sub(-1,-1) == "," then
		-- result[#result] = result[#result]:sub(1,-3)	-- remove the tab and the comma
	-- else
		-- result[#result] = result[#result]:sub(1,-2)	-- just remove the tab
	-- end
	result[#result + 1] = "}"	-- non pretty version
	return table.concat(result)
end

-- Function to convert a table to a string with indentation for pretty printing
-- Metatables not followed
-- Unless key is a number it will be taken and converted to a string
function t2spp(t)
	local levels = 0
	local rL = {cL = 1}	-- Table to track recursion into nested tables (cL = current recursion level)
	rL[rL.cL] = {}
	local result = {}
	do
		rL[rL.cL]._f,rL[rL.cL]._s,rL[rL.cL]._var = pairs(t)
		result[#result + 1] =  "{\n"..string.rep("\t",levels+1)		
		--result[#result + 1] = "{"		-- Non pretty version
		rL[rL.cL].t = t
		while true do
			local k,v = rL[rL.cL]._f(rL[rL.cL]._s,rL[rL.cL]._var)
			rL[rL.cL]._var = k
			if not k and rL.cL == 1 then
				break
			elseif not k then
				-- go up in recursion level
				-- If condition for pretty printing
				if result[#result]:sub(-1,-1) == "," then
					result[#result] = result[#result]:sub(1,-3)	-- remove the tab and the comma
				else
					result[#result] = result[#result]:sub(1,-2)	-- just remove the tab
				end
				--result[#result + 1] = "},"	-- non pretty version
				levels = levels - 1
				rL.cL = rL.cL - 1
				rL[rL.cL+1] = nil
				result[#result + 1] = "},\n"..string.rep("\t",levels+1)		-- for pretty printing
			else
				-- Handle the key and value here
				if type(k) == "number" then
					result[#result + 1] = "["..tostring(k).."]="
				else
					result[#result + 1] = "["..[["]]..tostring(k)..[["]].."]="
				end
				if type(v) == "table" then
					-- Check if this is not a recursive table
					local goDown = true
					for i = 1, rL.cL do
						if v==rL[i].t then
							-- This is recursive do not go down
							goDown = false
							break
						end
					end
					if goDown then
						-- Go deeper in recursion
						levels = levels + 1
						rL.cL = rL.cL + 1
						rL[rL.cL] = {}
						rL[rL.cL]._f,rL[rL.cL]._s,rL[rL.cL]._var = pairs(v)
						result[#result + 1] = "{\n"..string.rep("\t",levels+1)	-- For pretty printing
						--result[#result + 1] = "{"	-- non pretty version
						rL[rL.cL].t = v
					else
						result[#result + 1] = "\""..tostring(v).."\",\n"..string.rep("\t",levels+1)	-- For pretty printing
						--result[#result + 1] = "\""..tostring(v).."\","	-- non pretty version
					end
				elseif type(v) == "number" or type(v) == "boolean" then
					result[#result + 1] = tostring(v)..",\n"..string.rep("\t",levels+1)	-- For pretty printing
					--result[#result + 1] = tostring(v)..","	-- non pretty version
				else
					result[#result + 1] = string.format("%q",tostring(v))..",\n"..string.rep("\t",levels+1)		-- For pretty printing
					--result[#result + 1] = string.format("%q",tostring(v))..","	-- non pretty version
				end		-- if type(v) == "table" then ends
			end		-- if not rL[rL.cL]._var and rL.cL == 1 then ends
		end		-- while true ends here
	end		-- do ends
	-- If condition for pretty printing
	if result[#result]:sub(-1,-1) == "," then
		result[#result] = result[#result]:sub(1,-3)	-- remove the tab and the comma
	else
		result[#result] = result[#result]:sub(1,-2)	-- just remove the tab
	end
	result[#result + 1] = "}"
	return table.concat(result)
end

function compareTables(t1,t2)
	for k,v in pairs(t1) do
		--print(k,v)
		if type(v) == "number" or type(v) == "string" or type(v) == "boolean" or type(v) == "function" or type(v) == "thread" or type(v) == "userdata" then
			if v ~= t2[k] then
				--print("Value "..tostring(v).." does not match")
				return nil
			end
		else
			-- type(v) = ="table"
			--print("-------->Going In "..tostring(v))
			if not compareTables(v,t2[k]) then
				return nil
			end
		end
	end
	return true
end

