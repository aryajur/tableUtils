-- Table utils
local tostring = tostring
local type = type
local pairs = pairs
local string = string
local table = table
local load = load
local pcall = pcall

-- Create the module table here
local M = {}
package.loaded[...] = M
if setfenv and type(setfenv) == "function" then
	setfenv(1,M)	-- Lua 5.1
else
	_ENV = M		-- Lua 5.2+
end

_VERSION = "1.20.03.04"


-- Function to convert a table to a string
-- Metatables not followed
-- Unless key is a number it will be taken and converted to a string
function t2s(t)
	-- local levels = 0
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
			if k==nil and rL.cL == 1 then
				break
			elseif k==nil then
				-- go up in recursion level
				-- If condition for pretty printing
				-- if result[#result]:sub(-1,-1) == "," then
					-- result[#result] = result[#result]:sub(1,-3)	-- remove the tab and the comma
				-- else
					-- result[#result] = result[#result]:sub(1,-2)	-- just remove the tab
				-- end
				result[#result + 1] = "},"	-- non pretty version
				-- levels = levels - 1
				rL.cL = rL.cL - 1
				rL[rL.cL+1] = nil
				--rL[rL.cL].str = rL[rL.cL].str..",\n"..string.rep("\t",levels+1)
			else
				-- Handle the key and value here
				if type(k) == "number" or type(k) == "boolean" then
					result[#result + 1] = "["..tostring(k).."]="
				elseif type(k) == "table" then
					result[#result + 1] = "["..t2s(k).."]="
				else
					local kp = tostring(k)
					if kp:match([["]]) then
						result[#result + 1] = "["..[[']]..kp..[[']].."]="
					else
						result[#result + 1] = "["..[["]]..kp..[["]].."]="
					end
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
						-- levels = levels + 1
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
			if k == nil and rL.cL == 1 then
				break
			elseif k == nil then
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
				if type(k) == "number" or type(k) == "boolean" then
					result[#result + 1] = "["..tostring(k).."]="
				elseif type(k) == "table" then
					result[#result + 1] = "["..t2spp(k).."]="
				else
					local kp = tostring(k)
					if kp:match([["]]) then
						result[#result + 1] = "["..[[']]..kp..[[']].."]="
					else
						result[#result + 1] = "["..[["]]..kp..[["]].."]="
					end
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

-- Function to convert a table to string following the recursive tables also
-- Metatables are not followed
-- Lua has 8 basic types:
-- 1. nil
-- 2. boolean
-- 3. number
-- 4. string
-- 5. function
-- 6. userdata
-- 7. thread
-- 8. table
-- The table to string and string to table conversion will maintain the following types:
-- nil, boolean, number, string, table
-- The other three types (function, userdata and thread) get their tostring values stored and end up as a string ID.
function t2sr(t)
	if type(t) ~= 'table' then return nil, 'Expected table parameter' end 
	local rL = {cL = 1}	-- Table to track recursion into nested tables (cL = current recursion level)
	rL[rL.cL] = {}
	local tabIndex = {}	-- Table to store a list of tables indexed into a string and their variable name
	local latestTab = 0
	local result = {}
	do
		rL[rL.cL]._f,rL[rL.cL]._s,rL[rL.cL]._var = pairs(t)	-- Start the key value traveral for the table and store the iterator returns
		result[#result + 1] = 't0={}'	-- t0 would be the main table
		--rL[rL.cL].str = 't0={}'
		rL[rL.cL].t = t		-- Table to stringify at this level
		rL[rL.cL].tabIndex = 0
		tabIndex[t] = rL[rL.cL].tabIndex
		while true do
			local key
			local k,v = rL[rL.cL]._f(rL[rL.cL]._s,rL[rL.cL]._var)	-- Get the 1st key and value from the iterator in k,v
			rL[rL.cL]._var = k
			if k == nil and rL.cL == 1 then
				break	-- All done!
			elseif k == nil then
				-- go up in recursion level
				--rL[rL.cL-1].str = rL[rL.cL-1].str..'\\n'..rL[rL.cL].str
				rL.cL = rL.cL - 1
				if rL[rL.cL].vNotDone then
					-- We were converting a key to string since that was a table. Now do the same for the value at this level
					key = 't'..rL[rL.cL].tabIndex..'[t'..tostring(rL[rL.cL+1].tabIndex)..']'
					--rL[rL.cL].str = rL[rL.cL].str..'\\n'..key..'='
					result[#result + 1] = "\n"..key.."="
					v = rL[rL.cL].vNotDone
				end
				rL[rL.cL+1] = nil
			else
				-- Handle the key and value here
				if type(k) == 'number' or type(k) == 'boolean' then
					key = 't'..rL[rL.cL].tabIndex..'['..tostring(k)..']'
					--rL[rL.cL].str = rL[rL.cL].str..'\\n'..key..'='
					result[#result + 1] = "\n"..key.."="
				elseif type(k) == 'string' then
					key = 't'..rL[rL.cL].tabIndex..'.'..tostring(k)
					--rL[rL.cL].str = rL[rL.cL].str..'\\n'..key..'='
					result[#result + 1] = "\n"..key.."="
				elseif type(k) == 'table' then
					-- Table key
					-- Check if the table already exists
					if tabIndex[k] then
						key = 't'..rL[rL.cL].tabIndex..'[t'..tabIndex[k]..']'
						--rL[rL.cL].str = rL[rL.cL].str..'\\n'..key..'='
						result[#result + 1] = "\n"..key.."="
					else
						-- Go deeper to stringify this table
						latestTab = latestTab + 1
						--rL[rL.cL].str = rL[rL.cL].str..'\\nt'..tostring(latestTab)..'={}'
						result[#result + 1] = "\nt"..tostring(latestTab).."={}"
						rL[rL.cL].vNotDone = v
						rL.cL = rL.cL + 1
						rL[rL.cL] = {}
						rL[rL.cL]._f,rL[rL.cL]._s,rL[rL.cL]._var = pairs(k)
						rL[rL.cL].tabIndex = latestTab
						rL[rL.cL].t = k
						--rL[rL.cL].str = ''
						tabIndex[k] = rL[rL.cL].tabIndex
					end		-- if tabIndex[k] then ends
				else
					-- k is of the type function, userdata or thread
					key = 't'..rL[rL.cL].tabIndex..'.'..tostring(k)
					--rL[rL.cL].str = rL[rL.cL].str..'\\n'..key..'='
					result[#result + 1] = "\n"..key.."="					
				end		-- if type(k)ends
			end		-- if not k and rL.cL == 1 then ends
			if key then
				rL[rL.cL].vNotDone = nil
				if type(v) == 'table' then
					-- Check if this table is already indexed
					if tabIndex[v] then
						--rL[rL.cL].str = rL[rL.cL].str..'t'..tabIndex[v]
						result[#result + 1] = 't'..tabIndex[v]
					else
						-- Go deeper in recursion
						latestTab = latestTab + 1
						--rL[rL.cL].str = rL[rL.cL].str..'{}'
						--rL[rL.cL].str = rL[rL.cL].str..'\\nt'..tostring(latestTab)..'='..key
						result[#result + 1] = "{}\nt"..tostring(latestTab)..'='..key		-- New table
						rL.cL = rL.cL + 1
						rL[rL.cL] = {}
						rL[rL.cL]._f,rL[rL.cL]._s,rL[rL.cL]._var = pairs(v)
						rL[rL.cL].tabIndex = latestTab
						rL[rL.cL].t = v
						--rL[rL.cL].str = ''
						tabIndex[v] = rL[rL.cL].tabIndex
					end
				elseif type(v) == 'number' then
					--rL[rL.cL].str = rL[rL.cL].str..tostring(v)
					result[#result + 1] = tostring(v)
				elseif type(v) == 'boolean' then
					--rL[rL.cL].str = rL[rL.cL].str..tostring(v)
					result[#result + 1] = tostring(v)
				else
					--rL[rL.cL].str = rL[rL.cL].str..string.format('%q',tostring(v))
					result[#result + 1] = string.format('%q',tostring(v))
				end		-- if type(v) == "table" then ends
			end		-- if key then ends
		end		-- while true ends here
	end		-- do ends
	--return rL[rL.cL].str
	return table.concat(result)
end


-- Function to convert a string containing a lua table to a lua table object
function s2t(str)
  local fileFunc
	local safeenv = {}
  if loadstring and setfenv then
    fileFunc = loadstring("t="..str)
    setfenv(f,safeenv)
  else
    fileFunc = load("t="..str,"stringToTable","t",safeenv)
  end
	local err,msg = pcall(fileFunc)
	if not err or not safeenv.t or type(safeenv.t) ~= "table" then
		return nil,msg or type(safeenv.t) ~= "table" and "Not a table"
	end
	return safeenv.t
end

-- Function to convert a string containing a lua recursive table (from t2sr) to a lua table object
function s2tr(str)
  local fileFunc
	local safeenv = {}
  if loadstring and setfenv then
    fileFunc = loadstring(str)
    setfenv(f,safeenv)
  else
    fileFunc = load(str,"stringToTable","t",safeenv)
  end
	local err,msg = pcall(fileFunc)
	if not err or not safeenv.t0 or type(safeenv.t0) ~= "table" then
		return nil,msg or type(safeenv.t0) ~= "table" and "Not a table"
	end
	return safeenv.t0
end


-- Function to compare 2 tables. Returns nil if they are not equal in value
-- Recursive tables are allowed
function compareTables(t1,t2,traversed)
	traversed = traversed or {}
	traversed[t1] = true
	local donet2 = {}	-- To mark wchich keys are taken	
	for k,v in pairs(t1) do
		--print(k,v)
		if type(v) == "number" or type(v) == "string" or type(v) == "boolean" or type(v) == "function" or type(v) == "thread" or type(v) == "userdata" then
			if type(k) == "table" then
				-- Find a matching key
				local found
				for k2,v2 in pairs(t2) do
					if not donet2[k2] and type(k2) == "table" then
						if (traversed[k2] or compareTables(k,k2,traversed)) and v2 == v then
							found = k2
							break
						end
					end
				end
				if not found then
					return false
				end
				donet2[found] = true
			else
				if v ~= t2[k] then
					return false
				end
				donet2[k] = true
			end
		else
			-- type(v) = ="table"
			--print("-------->Going In "..tostring(v))
			if type(k) == "table" then
				-- Find a matching key
				local found
				for k2,v2 in pairs(t2) do
					if not donet2[k2] and type(k2) == "table" then
						if (traversed[k2] or compareTables(k,k2,traversed)) and (traversed[v2] or compareTables(v,v2,traversed)) then
							found = k2
							break
						end
					end
				end
				if not found then
					return false
				end
				donet2[found] = true
			else
				if not (traversed[t2[k]] or compareTables(v,t2[k],traversed)) then
					return false
				end
				donet2[k] = true
			end
		end
	end
	-- Check if any keys left in t2
	for k,v in pairs(t2) do
		if not donet2[k] then
			return false	-- extra stuff in t2
		end
	end
	return true
end


-- Copy table t1 to t2 overwriting any common keys
-- If full is true then copy is recursively going down into nested tables
-- returns t2 and mapping of source to destination and destination to source tables
function copyTable(t1,t2,full,map)
	map = map or {
			s2d={
				[t1]=t2
			},
			d2s={
				[t2]=t1
			}
		}	-- s2d contains mapping of source table tables to destination tables
			-- d2s contains mapping of destination table tables to source tables
	for k,v in pairs(t1) do
		if type(v) == "number" or type(v) == "string" or type(v) == "boolean" or type(v) == "function" or type(v) == "thread" or type(v) == "userdata" then
			if type(k) == "table" and full then
				local kp = {}
				copyTable(k,kp,true,map)
				map.d2s[kp] = k
				map.s2d[k] = kp
				t2[kp] = v
			else
				t2[k] = v
			end
		else
			-- type(v) = ="table"
			if full then 
				if type(k) == "table" then
					local kp = {}
					copyTable(k,kp,true,map)
					map.d2s[kp] = k
					map.s2d[k] = kp
					t2[kp] = {}
					copyTable(v,t2[kp],true,map)
					map.d2s[t2[kp]] = v
					map.s2d[v] = t2[kp]
				else
					t2[k] = {}
					copyTable(v,t2[k],true,map)
					map.d2s[t2[k]] = v
					map.s2d[v] = t2[k]
				end
			else
				t2[k] = v
			end
		end
	end
	return t2,map
end

local setnil = {}	-- Marker table for diff to set nil

-- Function to patch table t with the diff provided to convert it to the next table
-- diff is a structure as returned by the diffTable function
function patch(t,diff,tabDone)
	local tabDone = tabDone or {[t]=true}
	for k,v in pairs(diff[t]) do
		t[k] = v
	end
	for k,v in pairs(diff[t]) do
		if type(k) == "table" and not tabDone[k] then
			patch(k,diff,tabDone)
		end
		if type(v) == "table" and not tabDone[k] then
			patch(v,diff,tabDone)
		end
	end
	return true
end

-- Function to return the diff patch of t2-t1. The patch when applied to t1 will make it equal in value to t2 such that compareTables will return true
-- Use the patch function the apply the patch
-- map is the table that can provide mapping of any table in t2 to a table in t1 i.e. they can be considered the referring to the same table i.e. that table in t2 after the patch operation would be the same in value as the table in t1 that the map defines but its address will still be the address it was in t2. If there is no mapping for the table found then the same table is looked up at that level to match. But if there is a same table then the diff for that table is obviously 0

-- NOTE: a diff object is temporary and cannot be saved for a later session. To save it is better to serialize and save t1 and t2 using t2s functions
function diffTable(t1,t2,map,tabDone)
	map = map or {
			[t2]=t1
		}
	tabDone = tabDone or {[t2]=true}	-- To keep track of recursive tables
	local diff = {}
	local diffDirty 
	local keyTabs = {}
	-- To convert t1 to t2 let us iterate over all elements of t2 first
	for k,v in pairs(t2) do
		-- There are 8 types in Lua (except nil and table we check everything here
		if type(v) ~= "table" then			--
			if type(k) == "table" then
				-- Check if there is a mapping else the mapping in t1 is k
				local kt1 = k
				if map[k] then
					kt1 = map[k]
					-- Get diff of kt1 and k
					if not tabDone[k] then
						diff[kt1] = diffTable(kt1,k,map,tabDone)
						diffDirty = diffDirty or diff[kt1] and true
					end
				end
				keyTabs[kt1] = k
				if t1[kt1] == nil or t1[kt1] ~= v then
					diff[kt1] = v 
					diffDirty = true
				end
			else	-- if type(k) == "table" then else
				-- Neither v is a table not k is a table
				if t1[k] ~= v then
					diff[k] = v
					diffDirty = true
				end				
			end		-- if type(k) == "table" then ends
		else	--if type(v) ~= "table" then	
			-- v == "table"
			if type(k) == "table" then
				-- Both v and k are tables
				local kt1 = k
				if map[k] then
					kt1 = map[k]
					if not tabDone[k] then
						diff[kt1] = diffTable(kt1,k,map,tabDone)
						diffDirty = diffDirty or diff[kt1] and true
					end
				end
				keyTabs[kt1] = k
				local vt1 = v
				if map[v] then
					vt1 = map[v]
					if not tabDone[v] then
						diff[vt1] = diffTable(vt1,v,map,tabDone)
						diffDirty = diffDirty or diff[vt1] and true
					end
				end
				if t1[kt1] == nil or t1[kt1] ~= vt1 then
					diff[kt1] = vt1
					diffDirty = true
				end
			else
				local vt1 = v
				if map[v] then
					vt1 = map[v]
					-- Get the diff of vt1 and v
					if not tabDone[v] then
						diff[vt1] = diffTable(vt1,v,map,tabDone)
						diffDirty = diffDirty or diff[vt1] and true
					end
				end
				if t1[k] == nil or t1[k] ~= vt1 then
					diff[k] = vt1
					diffDirty = true
				end
			end
		end	--if type(v) ~= "table" then ends
	end	-- for k,v in pairs(t2) do ends
	-- Now to find extra stuff in t1 which should be removed
	for k,v in pairs(t1) do
		if type(k) ~= "table" then
			if t2[k] == nil then
				diff[k] = setnil
				diffDirty = true
			end
		else
			-- k is a table 
			-- get the t2 counterpart if it was found
			if not keyTabs[k] then
				diff[k] = setnil
				diffDirty = true
			end
		end
	end
	return diffDirty and diff
end

-- Merge arrays t1 to t2
-- if duplicates flag is false then duplicates are skipped
-- if isduplicate is a given function then that is used to check whether the value of t1 and value of t2 are duplicate using a call like this:
-- isduplicate(t1[i],t2[j])
-- returns table t2
function mergeArrays(t1,t2,duplicates,isduplicate)
	isduplicate = (type(isduplicate)=="function" and isduplicate) or function(v1,v2)
		return v1==v2
	end
	for i = 1,#t1 do
		local add = true
		if not duplicates then
			-- Check if this is a duplicate
			for j = 1,#t2 do
				if isduplicate(t1[i],t2[j]) then
					add = false
					break
				end
			end
		end
		if add then
			table.insert(t2, t1[i])
		end
	end	
	return t2
end

-- Function to check whether value v is in array t1
-- if equal is a given function 
function inArray(t1,v,equal)
	equal = (type(equal)=="function" and equal) or function(v1,v2)
		return v1==v2
	end
	for i = 1,#t1 do
		if equal(t1[i],v) then
			return i		-- Value v found in t1 at ith location
		end
	end
	return false	-- Value v not in t1
end

function emptyTable(t)
	for k,v in pairs(t) do
		t[k] = nil
	end
	return true
end

function emptyArray(t)
	for i = 1,#t do
		t[i] = nil
	end
	return true
end
