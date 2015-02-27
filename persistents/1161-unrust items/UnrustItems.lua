init start

	local IgnoreCommon = true
	local DropTrash = true
	local MinValue = 500

	-- DO NOT EDIT BELOW --

init end

auto(1000, 2000)

if maroundfilter(10, false) == 0 then
	unrust(IgnoreCommon, DropTrash, MinValue)
end
