init start
	-- local SCRIPT_VERSION = "3.0.0"

	--[[ ONLY EDIT IF YOU KNOW WHAT YOU'RE DOING ]]--

	local WarnItems = {"red piece of cloth", "green piece of cloth", "blue piece of cloth"}
	local ShowMonsterName = true
	local ShowLootContent = true
	local ShowMessageTime = true
	local ShowEmptyLoot   = true
	local MaxLines		  = 10
	local TextSize		  = 60

	--[[ DO NOT EDIT BELOW THIS LINE ]]--

	table.lower(WarnItems)

	local hud = {
		pos = {0, 0},
		aux = {0, 0},
		width = 0,
		height = 0,
		moving = false,

		blue = {0.0, color(36, 68, 105, 20), 0.23, color(39, 73, 114, 20), 0.76, color(21, 39, 60, 20)},
		black = {0.0, color(75, 75, 75, 20), 0.23, color(45, 45, 45, 20), 0.76, color(19, 19, 19, 20)},
		orange = {0.0, color(145, 95, 0, 20), 0.23, color(158, 104, 0, 20), 0.76, color(84, 55, 0, 20)},

		start = 1,
		finish = MaxLines,

	}

	local tempPos = $chardb:getvalue('RecentLoot', 'Position')

	if tempPos then
		tempPos = tempPos:explode(":")
		hud.pos[1], hud.pos[2] = tonumber(tempPos[1]), tonumber(tempPos[2])
	end

	local tempMsg, LootMessages = $chardb:getvalue('RecentLoot', 'Messages'), {}

	if tempMsg and tempMsg ~= '{}' then
		LootMessages = tempMsg:totable()
	end

	function inputevents(e)
		if e.type == IEVENT_RMOUSEDOWN then
			requestmenu(0)

			requestmenuitem("Reset Messages")
			requestmenuitem(tern(ShowMonsterName, "Hide Monsters Names", "Show Monsters Names"))
			requestmenuitem(tern(ShowLootContent, "Hide Loot Content", "Show Loot Content"))
			requestmenuitem(tern(ShowMessageTime, "Hide Time Stamp", "Show Time Stamp"))
			requestmenuitem(tern(ShowEmptyLoot, "Hide Empty Loots", "Show Empty Loots"))
			requestmenuitem("Set Display Amount")
			requestmenuitem("Set Display Size")
			requestmenuitem("Save to Database")
			requestmenuitem("Load from Database")
		elseif e.type == IEVENT_REQUESTMENU then
			if e.value1 == 0 then
				if e.value2 == 'Reset Messages' then
					LootMessages = {}
				elseif e.value2 == 'Hide Monsters Names' or e.value2 == 'Show Monsters Names' then
					ShowMonsterName = not ShowMonsterName
				elseif e.value2 == 'Hide Loot Content' or e.value2 == 'Show Loot Content' then
					ShowLootContent = not ShowLootContent
				elseif e.value2 == 'Hide Time Stamp' or e.value2 == 'Show Time Stamp' then
					ShowMessageTime = not ShowMessageTime
				elseif e.value2 == 'Set Display Amount' then
					requestint(1, "Set the display lines amount:", MaxLines)
				elseif e.value2 == 'Set Display Size' then
					requestint(2, "Set the display text size:", TextSize)
				elseif e.value2 == 'Save to Database' then
					if #LootMessages > 0 then
						$chardb:setvalue('RecentLoot', 'Messages', table.tostring(LootMessages))
					end

					$chardb:setvalue('RecentLoot', 'ShowContent', tern(ShowLootContent, 1, 0))
					$chardb:setvalue('RecentLoot', 'ShowName', tern(ShowMonsterName, 1, 0))
					$chardb:setvalue('RecentLoot', 'ShowTime', tern(ShowMessageTime, 1, 0))
				end

				if e.value2 == 'Load from Database' then
					if $chardb:getvalue('RecentLoot', 'Messages') ~= nil then
						LootMessages = $chardb:getvalue('RecentLoot', 'Messages'):totable()
					end

					ShowLootContent = $chardb:getvalue('RecentLoot', 'ShowContent') == 1
					ShowMonsterName = $chardb:getvalue('RecentLoot', 'ShowName') == 1
					ShowMessageTime = $chardb:getvalue('RecentLoot', 'ShowTime') == 1
				end
			end
		elseif e.type == IEVENT_REQUESTINT then
			if e.value1 == 1 then
				MaxLines = e.value2
			elseif e.value1 == 2 then
				TextSize = e.value2
			end
		elseif e.type == IEVENT_MMOUSEDOWN then
			hud.moving, hud.aux = true, {$cursor.x - hud.pos[1], $cursor.y - hud.pos[2]}
        	elseif e.type == IEVENT_MMOUSEUP then
			hud.moving = false
			$chardb:setvalue('RecentLoot', 'Position', table.concat(hud.pos, ':'))
		elseif e.type == IEVENT_MOUSEWHEEL then
			if #PrivateMessages > Maxlines then
				if e.value2 < 0 then
					if hud.start <= #PrivateMessages - Maxlines then
						hud.start, hud.finish = hud.start + 1, hud.finish + 1
					end
				elseif e.value2 > 0 then
					if hud.finish > Maxlines then
						hud.start, hud.finish = hud.start - 1, hud.finish - 1
					end
				end
			end
		end
	end

	filterinput(false, true, false, true)
	setfontstyle('Tahoma', 10, 75, 0xFFFFFF, 1.5, color(0, 0, 0, 50))
	setmaskcolorxp(0)

init end

if hud.moving then
    auto(10)
    hud.pos = {$cursor.x - hud.aux[1], $cursor.y - hud.aux[2]}
end

foreach newmessage m do
	if m.type == MSG_INFO then
		local Monster, Loot = m.content:match(REGEX_LOOT)

		if Monster and Loot then
			local tempLoot = Loot:lower()

			if hud.start + #LootMessages >= MaxLines * 2 then
				hud.start, hud.finish = hud.start + 1, hud.finish + 1
			end

			Monster = Monster:gsub('the ', '', 1)

			local Warn = false

			for _, Item in pairs(WarnItems) do
				if tempLoot:find(Item) then
					Warn = true
					break
				end
			end

			table.insert(LootMessages,
				{
					content = Loot:capitalizeall(),
					monster = monster:capitalizeall(),
					timestamp = m.timestr,
					color = tern(Warn, hud.orange, hud.black),
				}
			)
		end
	end
end

local msg, Line = "RECENT LOOT", 0
local strwidth, strheight = measurestring(msg)
hud.width, hud.height = math.max(hud.width, strwidth or 0), math.max(hud.height, strheight or 0)

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
addgradcolors(unpack(hud.blue))
drawroundrect(0, 0, hud.width + 10, hud.height, 2, 2)
drawtext(msg, (hud.width - strwidth + 10) * 0.5, (hud.height - strheight) * 0.5)


for i = hud.start, hud.finish do
	local msgInfo = LootMessages[i]

	if msgInfo then
		local msg = ''

		if ShowMessageTime then
			msg = msg .. msgInfo.timestamp .. " "
		end

		if ShowMonsterName then
			msg = msg .. msgInfo.monster .. " "
		end

		if ShowLootContent then
			msg = msg .. ": " .. msgInfo.content
		end

		msg = msg:fit(TextSize)

		strwidth, strheight = measurestring(msg)
		hud.width, hud.height = math.max(hud.width, strwidth or 0), math.max(hud.height, strheight or 0)

		addgradcolors(unpack(msgInfo.color))
		drawroundrect(0, Line * hud.height, hud.width + 10, hud.height, 2, 2)
		drawtext(msg, (hud.width - strwidth + 10) * 0.5, Line * hud.height + strheight * 0.1)

		Line = Line + 1.2
	end
end

setposition(unpack(hud.pos))
setfixedsize(hud.width * 1.1, hud.height * Line)
