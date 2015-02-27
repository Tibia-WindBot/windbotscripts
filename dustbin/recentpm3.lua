init start
	-- local SCRIPT_VERSION = "3.0.0"

	--[[ ONLY EDIT IF YOU KNOW WHAT YOU'RE DOING ]]--

	local ShowSentMessages = true
	local ShowReceivedMessages = true
	local ShowMsgName = true
	local ShowMsgTime = true
	local ShowMsgContent = true
	local ShowMsgLevel = true
	local Maxlines = 10
	local TextSize = 60

	--[[ DO NOT EDIT BELOW THIS LINE ]]--

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
		finish = Maxlines,

	}

	local tempPos = $chardb:getvalue('PrivateMessages', 'Position')

	if tempPos then
		tempPos = tempPos:explode(":")
		hud.pos[1], hud.pos[2] = tonumber(tempPos[1]), tonumber(tempPos[2])
	end

	local tempMsg, PrivateMessages = $chardb:getvalue('PrivateMessages', 'Messages'), {}

	if tempMsg then
		PrivateMessages = tempMsg:totable()
	end

	function inputevents(e)
		if e.type == IEVENT_RMOUSEDOWN then
			requestmenu(0)

			requestmenuitem("Reset Messages")
			requestmenuitem(tern(ShowSentMessages, "Hide Sent", "Show Sent"))
			requestmenuitem(tern(ShowReceivedMessages, "Hide Received", "Show Received"))
			requestmenuitem(tern(ShowMsgName, "Hide Sender", "Show Sender"))
			requestmenuitem(tern(ShowMsgTime, "Hide Time Stamp", "Show Time Stamp"))
			requestmenuitem(tern(ShowMsgLevel, "Hide Level", "Show Level"))
			requestmenuitem(tern(ShowMsgContent, "Hide Content", "Show Content"))
			requestmenuitem("Set Display Amount")
			requestmenuitem("Set Display Size")
			requestmenuitem("Save to Database")
			requestmenuitem("Load from Database")
		elseif e.type == IEVENT_REQUESTMENU then
			if e.value1 == 0 then
				if e.value2 == 'Reset Messages' then
					PrivateMessages = {}
				end

				if e.value2 == 'Hide Sent' or e.value2 == 'Show Sent' then
					ShowSentMessages = not ShowSentMessages
				end

				if e.value2 == 'Hide Received' or e.value2 == 'Show Received' then
					ShowReceivedMessages = not ShowReceivedMessages
				end

				if e.value2 == 'Set Display Amount' then
					requestint(1, "Set the display lines amount:", MaxLines)
				end

				if e.value2 == 'Set Display Size' then
					requestint(2, "Set the display text size:", TextSize)
				end

				if e.value2 == 'Save to Database' then
					if #PrivateMessages > 0 then
						$chardb:setvalue('PrivateMessages', 'Messages', table.tostring(PrivateMessages))
					end

					$chardb:setvalue('PrivateMessages', 'ShowContent', tern(ShowMsgContent, 1, 0))
					$chardb:setvalue('PrivateMessages', 'ShowLevel', tern(ShowMsgLevel, 1, 0))
					$chardb:setvalue('PrivateMessages', 'ShowName', tern(ShowMsgName, 1, 0))
					$chardb:setvalue('PrivateMessages', 'ShowTime', tern(ShowMsgTime, 1, 0))
				end

				if e.value2 == 'Load from Database' then
					if $chardb:getvalue('PrivateMessages', 'Messages') ~= nil then
						PrivateMessages = $chardb:getvalue('PrivateMessages', 'Messages'):totable()
					end

					ShowMsgContent = $chardb:getvalue('PrivateMessages', 'ShowContent') == 1
					ShowMsgLevel = $chardb:getvalue('PrivateMessages', 'ShowLevel') == 1
					ShowMsgName = $chardb:getvalue('PrivateMessages', 'ShowName') == 1
					ShowMsgTime = $chardb:getvalue('PrivateMessages', 'ShowTime') == 1
				end

				if e.value2 == 'Reset Messages' then
					PrivateMessages = {}
				end
			end
		elseif e.type == IEVENT_REQUESTINT then
			if e.value1 == 1 then
				MaxLines = e.value2
			end

			if e.value1 == 2 then
				TextSize = e.value2
			end
		elseif e.type == IEVENT_MMOUSEDOWN then
			hud.moving, hud.aux = true, {$cursor.x - hud.pos[1], $cursor.y - hud.pos[2]}
        	elseif e.type == IEVENT_MMOUSEUP then
			hud.moving = false
			$chardb:setvalue('PrivateMessages', 'Position', table.concat(hud.pos, ':'))
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
	if m.channel:lower() ~= 'npcs' and (ShowSentMessages and m.type == MSG_SENT) or (ShowReceivedMessages and m.type == MSG_PVT) then
		table.insert(PrivateMessages,
			{
				sender = m.sender,
				level = m.level,
				message = m.content,
				timestamp = m.timestr,
				color = tern(m.type == MSG_PVT, hud.orange, hud.black),
			}
		)
	end
end

local msg, Line = "PRIVATE MESSAGES", 0
local strwidth, strheight = measurestring(msg)
hud.width, hud.height = math.max(hud.width, strwidth or 0), math.max(hud.height, strheight or 0)

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
addgradcolors(unpack(hud.blue))
drawroundrect(0, 0, hud.width + 10, hud.height, 2, 2)
drawtext(msg, (hud.width - strwidth + 10) * 0.5, (hud.height - strheight) * 0.5)


for i = hud.start, hud.finish do
	local msgInfo = PrivateMessages[i]
	if msgInfo then
		local msg = ''

		if ShowMsgTime then
			msg = msg .. msgInfo.timestamp .. " "
		end

		if ShowMsgName then
			msg = msg .. msgInfo.sender .. " "
		end

		if ShowMsgLevel then
			msg = msg .. "[" .. msgInfo.level .. "]"
		end

		if ShowMsgContent then
			msg = msg .. ": " .. msgInfo.message
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
