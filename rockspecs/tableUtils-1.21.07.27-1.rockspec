package = "tableUtils"
version = "1.21.07.27-1"
source = {
	url = "git://github.com/aryajur/tableUtils.git",
	tag = "1.21.07.27"
}
description = {
	summary = "Useful Table Manipulation Utilities",
	detailed = [[
		Module providing some useful utilities for Lua Tables.
	]],
	homepage = "http://milindsweb.amved.com/tableUtils.html", 
	license = "MIT" 
}
dependencies = {
	"lua >= 5.1"
}
build = {
	type = "builtin",
    install = {
        bin = {
            tableUtils = "src/tableUtils.lua",
        },
    },
}