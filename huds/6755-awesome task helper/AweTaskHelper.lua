init start
	-- local SCRIPT_VERSION = "3.1.0"

	local TaskHelper = {
		ShowAll		=	true,
	}

	-- DO NOT EDIT BELOW THIS LINE --

	local hud = {
		-- settings
		pos			=	{0, 0},
		aux			=	{0, 0},
		width		=	0,
		height		=	0,
		moving		=	false,

		-- colors
		blue		=	{0.0, color(36, 68, 105, 20), 0.33, color(39, 73, 114, 20), 0.66, color(21, 39, 60, 20)},
		black		=	{0.0, color(75, 75, 75, 20), 0.33, color(45, 45, 45, 20), 0.66, color(19, 19, 19, 20)},
		orange		=	{0.0, color(145, 95, 0, 20), 0.33, color(158, 104, 0, 20), 0.66, color(84, 55, 0, 20)},
	}

	local tempPos = $chardb:getvalue('TaskHelper', 'Position')

	if tempPos then
		tempPos = tempPos:explode(":")
		hud.pos = {tonumber(tempPos[1]), tonumber(tempPos[2])}
	end

	TaskHelper.Monsters = {}

	if not $chardb:getvalue("TaskHelper", "Monsters") then
		foreach settingsentry e 'Targeting/Creatures' do
			local mname = get(e, 'Name')

			table.insert(TaskHelper.Monsters, mname:lower())
		end

		table.sort(TaskHelper.Monsters)
		$chardb:setvalue("TaskHelper", "Monsters", table.tostring(TaskHelper.Monsters))
	else
		TaskHelper.Monsters = $chardb:getvalue("TaskHelper", "Monsters"):totable()
	end

	function inputevents(e)
		if e.type == IEVENT_MMOUSEDOWN then
     			hud.moving, hud.aux = true, {$cursor.x - hud.pos[1], $cursor.y - hud.pos[2]}
		end

		if e.type == IEVENT_MMOUSEUP then
			hud.moving = false
			$chardb:setvalue('TaskHelper', 'Position', table.concat(hud.pos, ':'))
		end

		if e.type == IEVENT_RMOUSEUP then
			requestmenu(0)
			requestmenuitem(tern(TaskHelper.ShowAll, "Show Total Only", "Show All"))
			requestmenuitem("Reset Timer")
			requestmenuitem("Reset Monsters")
			requestmenuitem("Reset Both")
			requestmenuitem("Add Monster")
			requestmenuitem("Remove Monster")
			requestmenuitem("Scan Targeting")
		end

		if e.type == IEVENT_REQUESTMENU then
			if e.value1 == 0 then
				if e.value2 == 'Show Total Only' or e.value2 == 'Show All' then
					TaskHelper.ShowAll = not TaskHelper.ShowAll
				end

				if e.value2 == 'Reset Timer' or e.value2 == 'Reset Both' then
					$chardb:setvalue("TaskHelper", "Timer", tosec(os.date("%X")))
				end

				if e.value2 == 'Reset Monsters' or e.value2 == 'Reset Both' then
					for k, v in pairs(TaskHelper.Monsters) do
						$chardb:setvalue('TH MonstersKilled', v, 0)

						if killCount then
							killCount.set(0, v)
						end
					end
				end

				if e.value2 == 'Scan Targeting' then
					TaskHelper.Monsters = {}

					foreach settingsentry e 'Targeting/Creatures' do
						local mname = get(e, 'Name')

						if not table.find(TaskHelper.Monsters, mname:lower()) then
							table.insert(TaskHelper.Monsters, mname:lower())
						end
					end

					table.sort(TaskHelper.Monsters)
					$chardb:setvalue("TaskHelper", "Monsters", table.tostring(TaskHelper.Monsters))
				end

				if e.value2 == 'Add Monster' then
					requesttext(1, 'Name the monster you want to add:')
				end

				if e.value2 == 'Remove Monster' then
					requestmenu(2)

					for _, v in pairs(TaskHelper.Monsters) do
						requestmenuitem(v:capitalizeall())
					end
				end
			end

			if e.value1 == 2 then
				local t = table.find(TaskHelper.Monsters, e.value2:lower())

				if t then
					table.remove(TaskHelper.Monsters, t)
					$chardb:setvalue("TaskHelper", "Monsters", table.tostring(TaskHelper.Monsters))
				end
			end
		end

		if e.type == IEVENT_REQUESTTEXT then
			if e.value1 == 1 then
				if not table.find(TaskHelper.Monsters, e.value2:lower()) then
					table.insert(TaskHelper.Monsters, e.value2:lower())
					$chardb:setvalue("TaskHelper", "Monsters", table.tostring(TaskHelper.Monsters))
				end
			end
		end
	end

	local tempTime = tosec(os.date("%X"))

	if $chardb:getvalue("TaskHelper", "Timer") then
		if tempTime - $chardb:getvalue("TaskHelper", "Timer") >= 293^2 then
			$chardb:setvalue("TaskHelper", "Timer", tempTime)
		end
	else
		$chardb:setvalue("TaskHelper", "Timer", tempTime)
	end

	filterinput(false, true, false, false)
	setfillstyle('gradient', 'linear', 2, 0, 0, 0, 14)
	setfontstyle('Tahoma', 10, 75, 0xFFFFFF, 1.5, color(0, 0, 0, 50))
	setmaskcolorxp(0)

init end

if hud.moving then
	auto(10)
	hud.pos = {$cursor.x - hud.aux[1], $cursor.y - hud.aux[2]}
end

if killCount and killCount.lastRan <= 10000 then
	foreach $chardb:sectionvalue sec 'TH MonstersKilled' do
		$chardb:setvalue('TH MonstersKilled', sec.name, killCount.get(sec.name))
	end
else
	foreach newmessage m do
		if m.type == MSG_INFO then
			local monster = m.content:match("Loot of a?n? (.+): .-")

			if monster then
				monster = (monster:match("the (.+)") or monster):lower()
				$chardb:setvalue('TH MonstersKilled', monster, ($chardb:getvalue('TH MonstersKilled', monster) or 0) + 1)
			end
		end
	end
end

local Total, Line = 0, 0
local msg = "TASK HELPER"
local strwidth, strheight = measurestring(msg)
hud.width, hud.height = math.max(hud.width, strwidth or 0), math.max(hud.height, strheight or 0)

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
addgradcolors(unpack(hud.blue))
drawroundrect(0, 0, hud.width + 10, hud.height, 2, 2)
drawtext(msg, (hud.width - strwidth + 10) * 0.5, (hud.height - strheight) * 0.5)

setfontsize(8)

Line = Line + 1.2

for _, Name in ipairs(TaskHelper.Monsters) do
	local Amount = $chardb:getvalue("TH MonstersKilled", Name)

	if Amount and Amount > 0 then
		if TaskHelper.ShowAll then
			msg = string.format("[%s] Killed: %s | Rate: %s/HR", Name:capitalizeall(), num(Amount), num(math.positive(math.floor((Amount / (tosec(os.date("%X")) - $chardb:getvalue('TaskHelper', 'Timer')) * 3600)))))
			strwidth, strheight = measurestring(msg)
			hud.width, hud.height = math.max(hud.width, strwidth or 0), math.max(hud.height, strheight or 0)

			addgradcolors(unpack(hud.black))
			drawroundrect(0, Line * hud.height, hud.width + 10, hud.height, 2, 2)
			drawtext(msg, (hud.width - strwidth + 10) * 0.5, Line * hud.height + strheight * 0.1)

			Line = Line + 1.2
		end

		Total = Total + Amount
	end
end

msg = string.format("Killed: %s - Rate: %s/HR - Timer: %s", num(Total), num(math.positive(math.floor((Total / (tosec(os.date('%X')) - $chardb:getvalue('TaskHelper', 'Timer')) * 3600)))), formattime(tosec(os.date('%X')) - $chardb:getvalue('TaskHelper', 'Timer')))
strwidth, strheight = measurestring(msg)
hud.width, hud.height = math.max(hud.width, strwidth or 0), math.max(hud.height, strheight or 0)

addgradcolors(unpack(hud.orange))
drawroundrect(0, Line * hud.height, hud.width + 10, hud.height, 2, 2)
drawtext(msg, (hud.width - strwidth + 10) * 0.5, Line * hud.height + strheight * 0.1)

Line = Line + 1.2

setfixedsize(hud.width * 1.1, hud.height * Line)
setposition(unpack(hud.pos))
