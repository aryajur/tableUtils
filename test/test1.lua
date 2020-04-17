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
	[{me=true}]="test",
	[{me=false}]="test"
}
tcopy,map = tu.copyTable(t,{},true)
-- Now lets modify tcopy
--tcopy.x.status = false
--tcopy.x = nil
t.x = nil
diff = tu.diffTable(tcopy,t,map.s2d)
print("The diff t-tcopy is:")
print(tu.t2spp(diff))