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
