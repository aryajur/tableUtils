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
