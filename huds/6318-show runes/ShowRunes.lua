init start
	local AnimateShape = true
	local CommonShape = false

	-- DO NOT EDIT BELOW --
	-- OR EDIT IF YOU KNOW WHAT YOU'RE DOING
	local runes = {
		{itemID = 3192,	area = "2x2",	id = 16},
		{itemID = 3161,	area = "3x3",	id = 42},
		{itemID = 3191,	area = "3x3",	id = 7},
		{itemID = 3202,	area = "3x3",	id = 12},
		{itemID = 3175,	area = "3x3",	id = 45},
		{itemID = 3180,	area = "mpos",	id = 2128},
		{itemID = 3156,	area = "mpos",	id = 10182},
		{itemID = 3152,	area = "mpos",	id = 13},
		{itemID = 3155,	area = "mpos",	id = 18},
		{itemID = 3160,	area = "mpos",	id = 13},
		{itemID = 3164,	area = "mpos",	id = 2135},
		{itemID = 3172,	area = "mpos",	id = 2134},
		{itemID = 3174,	area = "mpos",	id = 12},
		{itemID = 3179,	area = "mpos",	id = 45},
		{itemID = 3182,	area = "mpos",	id = 40},
		{itemID = 3188,	area = "mpos",	id = 2131},
		{itemID = 3198,	area = "mpos",	id = 12},
		{itemID = 3190,	area = "wall",	id = 2131},
		{itemID = 3176,	area = "wall",	id = 2134},
		{itemID = 3166,	area = "wall",	id = 2135},
		{itemID = 3200,	area = "expl",	id = 5},
	}

	local function drawspellshape(id, x, y)
		local pos, info = table.find(runes, id, "itemID")

		if pos then
			info = runes[pos]
		else
			return false
		end

		if info.area == 'mpos' then
			-- rune is only on 1 sqm
			if info.id == 2128 or info.id == 10182 and not CommonShape then
				return {elements = {{x = x - 1, y = y - 1}}, effectID = info.id}
			end

			return {elements = {{x = x, y = y}}, effectID = info.id}
		elseif info.area == 'expl' then
			-- rune is an explosion rune (+ shaped)
			return {elements = {{x = x, y = y}, {x = x, y = y + 1}, {x = x, y = y - 1}, {x = x + 1, y = y}, {x = x - 1, y = y}}, effectID = info.id}
		elseif info.area == '2x2' then
			-- fire bomb rune
			local elements = {}

			for a = -1, 1 do
				for b = -1, 1 do
					table.insert(elements, {x = x + a, y = y + b})
				end
			end

			return {elements = elements, effectID = info.id}
		elseif info.area == '3x3' then
			-- area rune
			local elements = {}

			for a = -3, 3 do
				for b = -3, 3 do
					if math.abs(a) + math.abs(b) < 5 then
						table.insert(elements, {x = x + a, y = y + b})
					end
				end
			end

			return {elements = elements, effectID = info.id}
		elseif info.area == 'wall' then
			-- energy/poison/fire wall field
			local elements = {{x = x, y = y}}
			local distx, disty = math.abs($posx - x), math.abs($posy - y)

			if x == $posx or y == $posy or (distx == 1 or disty == 1) then
				local delim = 2

				if id == 3166 then -- size of energy wall is 1 sqm larger
					delim = 3
				end

				if distx < disty then
					for i = 1, delim do
						table.insert(elements, {x = x + i, y = y})
						table.insert(elements, {x = x - i, y = y})
					end
				else
					for i = 1, delim do
						table.insert(elements, {x = x, y = y - i})
						table.insert(elements, {x = x, y = y + i})
					end
				end
			else
				-- determine quadrant
				-- these are always equal
				elements[2] = {x = x + 1, y = y}
				elements[3] = {x = x - 1, y = y}

				if (x > $posx and y > $posy) or (x < $posx and y < $posy) then
					-- \
					elements[4] = {x = elements[2].x, y = elements[2].y - 1}
					elements[5] = {x = elements[3].x, y = elements[3].y + 1}
					elements[6] = {x = elements[4].x + 1, y = elements[4].y}
					elements[7] = {x = elements[5].x - 1, y = elements[5].y}
					elements[8] = {x = elements[6].x, y = elements[6].y - 1}
					elements[9] = {x = elements[7].x, y = elements[7].y + 1}

					if id == 3166 then
						elements[10] = {x = elements[8].x + 1, y = elements[8].y}
						elements[11] = {x = elements[9].x - 1, y = elements[9].y}
						elements[12] = {x = elements[10].x, y = elements[10].y - 1}
						elements[13] = {x = elements[11].x, y = elements[11].y + 1}
					end
				else
					-- /
					elements[4] = {x = elements[2].x, y = elements[2].y + 1}
					elements[5] = {x = elements[3].x, y = elements[3].y - 1}
					elements[6] = {x = elements[4].x + 1, y = elements[4].y}
					elements[7] = {x = elements[5].x - 1, y = elements[5].y}
					elements[8] = {x = elements[6].x, y = elements[6].y + 1}
					elements[9] = {x = elements[7].x, y = elements[7].y - 1}

					if id == 3166 then
						elements[10] = {x = elements[8].x + 1, y = elements[8].y}
						elements[11] = {x = elements[9].x - 1, y = elements[9].y}
						elements[12] = {x = elements[10].x, y = elements[10].y + 1}
						elements[13] = {x = elements[11].x, y = elements[11].y - 1}
					end
				end
			end

			return {elements = elements, effectID = info.id}
		end

		return false
	end

	useworldhud()

init end

if $cursorinfo.crosshair > 0 then
	local pos = cursorinfo(($targeting and $cavebot and getsetting('Settings/MouseMode') == 'Simulate Mouse') and $simulatedcursor or $cursor)

	if not (pos.x == 0 and pos.y == 0 and pos.z == 0) then
		local toDraw = drawspellshape($cursorinfo.crosshair, pos.x, pos.y)

		if toDraw then
			local scale = math.floor((($worldwin.width / 13) / 36.5) * 100)

			for _, item in pairs(toDraw.elements) do
				local r = getobjectarea(item.x, item.y, $posz)

				if r then
					if toDraw.effectID <= 75 or CommonShape then
						draweffect(CommonShape and 2 or toDraw.effectID, r.left, r.top, scale, AnimateShape and -1 or 2)
					else
						drawitem(toDraw.effectID, r.left, r.top, scale, 1, AnimateShape and -1 or 2)
					end
				end
			end
		end
	end
end

setposition($worldwin.left, $worldwin.top) setfixedsize($worldwin.width, $worldwin.height)
