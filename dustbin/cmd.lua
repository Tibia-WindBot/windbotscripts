init start

	local cor, toDraw, toSearch = color(5,5,5,50), '', false
	filterinput(true, false, false, true)

	function inputevents(e)
		print(e)
		if e.type == 513 then
			if e.value1 == 8 and #toDraw > 0 then -- backspace
				toDraw = toDraw:sub(1, -2)
			elseif e.value1 == 13 then -- enter
				toDraw = toDraw:explode(' ')
				local name = table.remove(toDraw, 1)

				if #toDraw > 0 then
					if _G[name] then
						_G[name](unpack(toDraw))
					end
				end

				toDraw = ''
			elseif ASCII[e.value1] and #toDraw <= 49 then
				toDraw = toDraw .. ASCII[e.value1]:lower()
			end
		end

		if e.type == IEVENT_RMOUSEUP then
			cor = randomcolor({transparency = 50})
		end
	end

	setfontstyle("Lucida Console", 10, 75, -1, 1, color(5,5,5,100))

	setposition($worldwin.right / 2 - 150, $worldwin.bottom + 2)
init end

setfillstyle("color", cor)
drawrect(0, 0, 500, 15)
drawtext('cmd:', 4, 2)
drawtext(toDraw, 50, 2)