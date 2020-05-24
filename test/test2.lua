-- Some more tests
tu = require("tableUtils")
-- Copy Table tests
t1 = {
	a = "Hello",
	b = "World",
	c = true,
	d = {
		x = 23,
		y = 100,
	}
}

t2 = tu.copyTable(t1,{},true)	-- Do a full copy
print("t1 is: ",tu.t2spp(t1))
print("t2 is: ",tu.t2spp(t2))
print("Comparing t1 and t2: ",tu.compareTables(t1,t2))

print("Not test recursive copy")
t1.d.z = t1
print("t1 is: ",tu.t2spp(t1))
print("t1 address is: ",t1)

t2 = tu.copyTable(t1,{},true)	-- Do a full copy

print("t2 is: ",tu.t2spp(t2))
print("t2 address is: ",t2)
print("Comparing t1 and t2: ",tu.compareTables(t1,t2))