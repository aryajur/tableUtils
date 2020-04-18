tu = require("tableUtils")

print([[Table to string for the table:
{
	[1]="Hello",
	[2]="World",
	Hello="World",
	x = {},
	[{me=true}]="test"
}
]])
print(tu.t2s({
			[1]="Hello",
			[2]="World",
			Hello="World",
			x = {},
			[{me=true}]="test"
		}))
		
print("Result of compareTables:")
print(tu.compareTables(tu.s2t(tu.t2s({
			[1]="Hello",
			[2]="World",
			Hello="World",
			x = {},
			[{me=true}]="test",
			[{me=false}]="test"
		})),{
			[1]="Hello",
			[2]="World",
			Hello="World",
			x = {},
			[{me=false}]="test",
			[{me=true}]="test",
		}))
		
print("Now table to string with pretty print")
print(tu.t2spp({
			[1]="Hello",
			[2]="World",
			Hello="World",
			x = {},
			[{me=true}]="test"
		}))

print("Now table with function and boolean as keys")
print(tu.t2sr({
			[true] = 1,
			[false] = 2,
			[function() print("hello") end] = 3
		}))
print("Test diffTable and patch functions now")

tk = {
	me = true
}
t = {
	[1]="Hello",
	[2]="World",
	Hello="World",
	x = {
		subTab = {
			name = "tableUtils"
		},
		status = true
	},
	[tk]="test",
	[{me=false}]="test"
}
tcopy,map = tu.copyTable(t,{},true)
-- Now lets modify tcopy
--tcopy.x.status = false
--tcopy.x = nil
t.x = nil
tk.me = 23
print("---------------------------------------------")
print("Original table copy is:")
print(tu.t2spp(tcopy))
print("---------------------------------------------")
print("The modified table is:")
print(tu.t2spp(t))
print("---------------------------------------------")
diff = tu.diffTable(t,tcopy,map.d2s)
print("The diff tcopy-t is:")
print(tu.t2spp(diff))
print("---------------------------------------------")
print("The patched table is:")
-- Now patch and compare
tpatch = tu.patch(t,diff)
print(tu.t2spp(tpatch))
print("---------------------------------------------")
print("Compare tpatch and tcopy:",tu.compareTables(tpatch,tcopy))