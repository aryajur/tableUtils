t = require("tableUtils")

recT = {
	x = {},
}

t1 = {y = recT}

recT.x.z = t1

t2 = {
	a = true,
	hello = "world",
	t3 = {
		x = 1,
		y = 2,
		z = 3
	}
}

print(t.isRecursive(recT))
print(t.isRecursive(t1))
print(t.isRecursive(t2))