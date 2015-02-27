Icon = {}
Icon.__index = Icon
Icon.__class = "Icon"

local _ICONS = {}

-- dont even know if this works

function Icon.New(x, y, w, h, drawType, borderSize, borderColor, image)
	local tbl = setmetatable(
		{
			id = -1,
			width = w,
			height = h,
			x = x,
			y = y,
			drawType = drawType or 'rect',
			borderSize = borderSize or 1,
			borderColor = borderColor or -1,
			image = image,
		}, Icon)

	_ICONS[#_ICONS + 1] = tbl

	tbl.id = #_ICONS

	return tbl
end

function Icon:SetPosition(posx, posy)
	self.x = posx
	self.y = posy
	_ICONS[self.id] = self
end

function Icon:SetDrawingType(drawType)
	self.drawType = drawType
	_ICONS[self.id] = self
end

function Icon:SetBorder(size, color)
	self.borderSize = size or 1
	self.botderColor = color or -1
	_ICONS[self.id] = self
end

function Icon:SetSize(w, h)
	self.w = w
	self.h = h
	_ICONS[self.id] = self
end

function Icon:SetFillImage(img)
	self.image = img
	_ICONS[self.id] = self
end

function Icon:Align(ref)
	local pos = {x = 0, y = 0}

	if ref then
		pos.x, pos.y = ref.x, ref.y
	else
		local dist = math.huge

		for _, icon in ipairs(_ICONS) do
			local distTemp = getdistancebetween(self.x, self.y, 0, icon.x, icon.y, 0)

			if icon.id ~= self.id and distTemp < dist then
				pos = icon
				dist = distTemp
			end
		end
	end

	if pos.x == 0 and pos.y == 0 then
		self.x, self.y = 0, 0

		return
	end

	local distx, disty = math.abs(pos.x - self.x), math.abs(pos.y - self.y)

	if distx < disty then
		-- x-axis is closer
		if pos.x > self.x then
			-- current icon is right from the ref point
			self.x = (pos.x + pos.w + pos.borderSize)
		elseif pos.x < self.x then
			-- current icon is left from the ref point
			self.x = (pos.x - self.w - self.borderSize)
		end

		self.y = pos.y
	else if distx > disty then
		-- y-axis is closer
		if pos.y > self.y then
			-- current icon is above ref point
			self.y = (pos.y - self.h - self.borderSize)
		elseif pos.y < self.y then
			-- current icon is below ref point
			self.y = (pos.y + pos.h + pos.borderSize)
		end

		self.x = pos.x
	end

	return
end

function Icon:Draw()
	return true
end
