init start
	--local SCRIPT_VERSION = "2.0.0"
	
	local MinimumDistance = 1
	local SafeList = {"Bubble", "Eternal Oblivion"}

	-- DO NOT EDIT BELOW --
	MinimumDistance = math.max(MinimumDistance, 1)
	table.lower(SafeList)

init end

auto(100, 200)

local players, monsters = {}, {}

foreach creature c 'xf' do
	if c.id ~= $target.id then
		if c.isplayer and not table.find(SafeList, c.name:lower()) then
			table.insert(players, c)
		elseif c.ismonster then
			table.insert(monsters, c)
		end
	end
end

table.sort(monsters, function(a, b)
	if a.dist == b.dist then
		if a.speed == b.speed then
			if a.hppc == b.hppc then
				return a.id < b.id
			else
				return a.hppc < b.hppc
			end
		else
			return a.speed < b.speed
		end
	else
		return a.dist < b.dist
	end
end)

for _, cre in ipairs(monsters) do
	if #players == 0 or cre.lastattacked <= 10000 or cre.dist <= MinimumDistance then
		ignorecreature(cre, true)
	elseif (not tilereachable(cre.posx, cre.posy, cre.posz)) or #players > 0 or cre.dist > MinimumDistance then
		ignorecreature(cre)
	end
end

if $attacked.ignored then
	keyevent(0x1B) waitping()
end
