local script = io.open("ShowRunes.lua", "r"):read("*a")
local threadPat = io.open("thread.txt", "r"):read("*a")

local file = io.open("threadFinal.txt", "w+")

if file ~= nil then
	file:write(string.format(threadPat, script))
	file:flush()
	file:close()
end
