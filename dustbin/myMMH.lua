init start
	-- edited version to sort items in many ways and diff colors
	--
	--                        88                                                                  
	--                        ""                                                ,d                
	--                                                                          88                
	--             ,adPPYba,  88  8b,dPPYba,  88,dPYba,,adPYba,   ,adPPYYba,  MM88MMM  ,adPPYba,  
	--             I8[    ""  88  88P'   "Y8  88P'   "88"    "8a  ""     `Y8    88    a8P_____88  
	--              `"Y8ba,   88  88          88      88      88  ,adPPPPP88    88    8PP"""""""  
	--             aa    ]8I  88  88          88      88      88  88,    ,88    88,   "8b,   ,aa  
	--   Author:   `"YbbdP"'  88  88          88      88      88  `"8bbdP"Y8    "Y888  `"Ybbd8"'  
	--   
	--   Monitor My Hunting!
	--
	--   Version: 1.0
	--   Created: 29.12.2013
	--   Last update: 29.12.2013
	--

	local MMH = {
		SHOW_ALL_ITEMS = false,
		SHOW_ALL_SUPPLIES = false,
	}

	-- [[ Do not change anything below this line. ]] --

	-- [[ COLORS ]] --
	MMH.COLORS = {}
	MMH.COLORS.FONT_COLOR = color(255, 255, 255, 0)
	MMH.COLORS.SECTION_HEADER_BACKGROUND = {0.0, color(139, 0, 139), 0.23, color(0, 0, 0)}
	MMH.COLORS.ENTRY_NAME_BACKGROUND = {0.0, color(19, 19, 19)}
	MMH.COLORS.ENTRY_VALUE_BACKGROUND = {0.0, color(50, 0, 50)}
	MMH.COLORS.RESULT_POSITIVE_BACKGROUND = {0.0, color(36, 52, 6)}
	MMH.COLORS.RESULT_NEGATIVE_BACKGROUND = {0.0, color(52, 6, 9)}
	MMH.COLORS.RESET_BUTTON_BACKGROUND = MMH.COLORS.RESULT_POSITIVE_BACKGROUND

	-- [[ ELEMENTS ]] --
	MMH.ELEMENTS = {}
	MMH.ELEMENTS.RESET_BUTTON = -1
	MMH.ELEMENTS.SWITCH_ITEMS_LOOTED = -1
	MMH.ELEMENTS.SWITCH_SUPPLIES_USED = -1

	-- [[ SECTION STATES ]] --
	MMH.SECTIONS = {}
	MMH.SECTIONS.ITEMS_LOOTED = tobool($botdb:getvalue("MMH", "LootingTabShow"))
	MMH.SECTIONS.SUPPLIES_USED = tobool($botdb:getvalue("MMH", "SuppliesTabShow"))

	-- [[ OTHERS ]] --	
	filterinput(false, true, false, false)

	local MOVING, TEMP, MOVED = false, {0, 0}, {0, 0}

	local tempPos = $botdb:getvalue("MMH", "Position")
	
	if tempPos then
		tempPos = tempPos:explode(":")
		MOVED = {tonumber(tempPos[1]), tonumber(tempPos[2])}
	end

	-- sorting methods

	
	local currentSort, sortConv = 'nameasc', {['Name Ascendant'] = 'nameasc', ['Name Descendant'] = 'namedesc', ['Amount Ascendant'] = 'amountasc', ['Amount Descendant'] = 'amountdesc', ['Value Ascendant'] = 'valueasc', ['Value Descendant'] = 'valuedesc', ['Totals Ascendant'] = 'totalasc', ['Totals Descendant'] = 'totaldesc'}
	local sortfunction = {
		nameasc = function(a, b)
			return a.name < b.name
		end,
		namedesc = function(a, b)
			return a.name > b.name
		end,
		amountasc = function(a, b)
			if a.objtype == 'supplydata' then
				return a.amountused < b.amountused
			elseif a.objtype == 'lootingdata' then
				return a.amountlooted < b.amountlooted
			end
		end,
		amountdesc = function(a, b)
			if a.objtype == 'supplydata' then
				return a.amountused > b.amountused
			elseif a.objtype == 'lootingdata' then
				return a.amountlooted > b.amountlooted
			end
		end,
		valueasc = function(a, b)
			if a.objtype == 'supplydata' then
				return a.buyprice < b.buyprice
			elseif a.objtype == 'lootingdata' then
				return a.sellprice < b.sellprice
			end
		end,
		valuedesc = function(a, b)
			if a.objtype == 'supplydata' then
				return a.buyprice > b.buyprice
			elseif a.objtype == 'lootingdata' then
				return a.sellprice > b.sellprice
			end
		end,
		totalasc = function(a, b)
			if a.objtype == 'supplydata' then
				return a.buyprice * a.amountused < b.buyprice * b.amountused
			elseif a.objtype == 'lootingdata' then
				return a.sellprice * a.amountlooted < b.sellprice * b.amountlooted
			end
		end,
		totaldesc = function(a, b)
			if a.objtype == 'supplydata' then
				return a.buyprice * a.amountused > b.buyprice * b.amountused
			elseif a.objtype == 'lootingdata' then
				return a.sellprice * a.amountlooted > b.sellprice * b.amountlooted
			end
		end
	}

	function inputevents(e)
		if (e.type == IEVENT_LMOUSEDOWN) then
			if (e.elementid == MMH.ELEMENTS.RESET_BUTTON) then
				resetcharactertime()
				resetlootcounter()
				resetexpcounter()
			elseif (e.elementid == MMH.ELEMENTS.SWITCH_ITEMS_LOOTED) then
				MMH.SECTIONS.ITEMS_LOOTED = not MMH.SECTIONS.ITEMS_LOOTED
				$botdb:setvalue("MMH", "LootingTabShow", tern(MMH.SECTIONS.ITEMS_LOOTED, 1, 0))
			elseif (e.elementid == MMH.ELEMENTS.SWITCH_SUPPLIES_USED) then
				MMH.SECTIONS.SUPPLIES_USED = not MMH.SECTIONS.SUPPLIES_USED
				$botdb:setvalue("MMH", "SuppliesTabShow", tern(MMH.SECTIONS.SUPPLIES_USED, 1, 0))
			end
		end

		if (e.type == IEVENT_MMOUSEDOWN) then
			MOVING, TEMP = true, {$cursor.x - MOVED[1], $cursor.y - MOVED[2]}
		end

		if (e.type == IEVENT_MMOUSEUP) then
			MOVING = false
			$botdb:setvalue("MMH", "Position", table.concat(MOVED, ":"))
		end

		if e.type == IEVENT_RMOUSEUP then
			requestmenu(0)
			
			for menuItem, sortVar in pairs(sortConv) do
				if sortVar ~= currentSort then
					requestmenuitem(menuItem)
				end
			end
		end
	
		if e.type == IEVENT_REQUESTMENU then
			print('teste')
			if e.value1 == 0 then
				currentSort = sortConv[e.value2]
			end
		end
	end

	setmaskcolorxp(0)
init end

if (MOVING) then
    auto(10)
    MOVED = {$cursor.x - TEMP[1], $cursor.y - TEMP[2]}
end

setposition($clientwin.right - 424 + MOVED[1], $worldwin.top + MOVED[2])
setfontstyle('Tahoma', 8, 75, MMH.COLORS.FONT_COLOR, 1, color(0, 0, 0, 20))

local ROW_QUANTITY, STRING_WIDTH, STRING_HEIGHT = 0, measurestring('TEMP')
local ITEMS_LOOTED_WORTH, ITEM_LOOTED_QUANTITY, ITEM_LOOTED_WORTH = 0, 0, 0
local SUPPLIES_USED_WORTH, SUPPLY_USED_QUANTITY, SUPPLY_USED_WORTH = 0, 0, 0

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 21)
addgradcolors(unpack(MMH.COLORS.ENTRY_NAME_BACKGROUND))
drawroundrect(0, 0, 240, 20, 2, 2)
drawtext('                     Hunting Monitor', 6, 20 / 2 - STRING_HEIGHT * 0.5)

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 21)
addgradcolors(unpack(MMH.COLORS.RESET_BUTTON_BACKGROUND))
MMH.ELEMENTS.RESET_BUTTON = drawroundrect(196, 0, 44, 20, 2, 2)
drawtext('RESET', 202, 20 / 2 - STRING_HEIGHT * 0.5)

setfontsize(7)

STRING_WIDTH, STRING_HEIGHT = measurestring('TEMP')

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
addgradcolors(unpack(MMH.COLORS.ENTRY_NAME_BACKGROUND))
drawroundrect(0, 23, 240, 15, 2, 2)
drawtext('Looting Accuracy', 6, 23 + 15 / 2 - STRING_HEIGHT * 0.5 + 1)

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
addgradcolors(unpack(MMH.COLORS.ENTRY_VALUE_BACKGROUND))
drawroundrect(130, 23, 110, 15, 2, 2)
drawtext(string.format('%.2f', $lootaccuracy) .. '%', 136, 23 + 15 / 2 - STRING_HEIGHT * 0.5 + 1)

setfontsize(8)

STRING_WIDTH, STRING_HEIGHT = measurestring('TEMP')

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 21)
addgradcolors(unpack(MMH.COLORS.SECTION_HEADER_BACKGROUND))
drawroundrect(0, 41, 240, 20, 2, 2)
drawtext('ITEMS LOOTED', 6, 41 + 20 / 2 - STRING_HEIGHT * 0.5)

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 21)
if (MMH.SECTIONS.ITEMS_LOOTED) then
	addgradcolors(unpack(MMH.COLORS.RESULT_POSITIVE_BACKGROUND))
else
	addgradcolors(unpack(MMH.COLORS.RESULT_NEGATIVE_BACKGROUND))
end
MMH.ELEMENTS.SWITCH_ITEMS_LOOTED = drawroundrect(220, 41, 20, 20, 2, 2)
drawtext('X', 228, 41 + 20 / 2 - STRING_HEIGHT * 0.5)

setfontsize(7)

STRING_WIDTH, STRING_HEIGHT = measurestring('TEMP')

local lootItems, supplyItems = {}, {}

foreach lootingitem item do
	table.insert(lootItems, {
		objtype = 'lootingdata',
		name = item.name,
		amountlooted = item.amountlooted,
		sellprice = item.sellprice,
	})
end
 
foreach supplyitem item do
	table.insert(supplyItems, {
		objtype = 'supplydata',
		name = item.name,
		amountused = item.amountused,
		sellprice = item.sellprice,
	})
end

table.sort(lootItems, sortfunction[currentSort]) table.sort(supplyItems, sortfunction[currentSort])

for _, ItemEntry in ipairs(lootItems) do
	if (MMH.SHOW_ALL_ITEMS or ItemEntry.amountlooted > 0) then
		ITEM_LOOTED_QUANTITY = ItemEntry.amountlooted
		ITEM_LOOTED_WORTH = ItemEntry.sellprice * ITEM_LOOTED_QUANTITY

		if (MMH.SECTIONS.ITEMS_LOOTED) then
			setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
			addgradcolors(unpack(MMH.COLORS.ENTRY_NAME_BACKGROUND))
			drawroundrect(0, 64 + ROW_QUANTITY * 18, 240, 15, 2, 2)
		
			setcompositionmode(CompositionMode_SourceOver)
			drawitem(ItemEntry.id, 6, 64 + ROW_QUANTITY * 18, 50, 100)
			setcompositionmode(CompositionMode_Automatic)

			drawtext(((#ItemEntry.name > 16 and string.match(string.sub(ItemEntry.name, 1, 16), '(.-)%s?$') .. '...') or ItemEntry.name):capitalizeall(), 28, 64 + ROW_QUANTITY * 18 + 15 / 2 - STRING_HEIGHT * 0.5)

			setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
			addgradcolors(unpack(MMH.COLORS.ENTRY_VALUE_BACKGROUND))
			drawroundrect(130, 64 + ROW_QUANTITY * 18, 110, 15, 2, 2)
			drawtext(num(ITEM_LOOTED_QUANTITY) .. ' (' .. math.floor(ITEM_LOOTED_WORTH / 100) / 10 .. 'K)', 136, 64 + ROW_QUANTITY * 18 + 15 / 2 - STRING_HEIGHT * 0.5)

			ROW_QUANTITY = ROW_QUANTITY + 1
		end

		ITEMS_LOOTED_WORTH = ITEMS_LOOTED_WORTH + ITEM_LOOTED_WORTH
	end
end

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
addgradcolors(unpack(MMH.COLORS.ENTRY_NAME_BACKGROUND))
drawroundrect(0, 64 + ROW_QUANTITY * 18, 240, 15, 2, 2)
drawtext('Total: ' .. num(ITEMS_LOOTED_WORTH) .. ' GPs', 6, 64 + ROW_QUANTITY * 18 + 15 / 2 - STRING_HEIGHT * 0.5)

ROW_QUANTITY = ROW_QUANTITY + 1

setfontsize(8)

STRING_WIDTH, STRING_HEIGHT = measurestring('TEMP')

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 21)
addgradcolors(unpack(MMH.COLORS.SECTION_HEADER_BACKGROUND))
drawroundrect(0, 64 + ROW_QUANTITY * 18, 240, 20, 2, 2)
drawtext('SUPPLIES USED', 6, 64 + ROW_QUANTITY * 18 + 20 / 2 - STRING_HEIGHT * 0.5)

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 21)
if (MMH.SECTIONS.SUPPLIES_USED) then
	addgradcolors(unpack(MMH.COLORS.RESULT_POSITIVE_BACKGROUND))
else
	addgradcolors(unpack(MMH.COLORS.RESULT_NEGATIVE_BACKGROUND))
end
MMH.ELEMENTS.SWITCH_SUPPLIES_USED = drawroundrect(220, 64 + ROW_QUANTITY * 18, 20, 20, 2, 2)
drawtext('X', 228, 64 + ROW_QUANTITY * 18 + 20 / 2 - STRING_HEIGHT * 0.5)

setfontsize(7)

STRING_WIDTH, STRING_HEIGHT = measurestring('TEMP')

for _, ItemEntry in ipairs(supplyItems) do
	if (MMH.SHOW_ALL_SUPPLIES or ItemEntry.amountused > 0) then
		SUPPLY_USED_QUANTITY = ItemEntry.amountused
		SUPPLY_USED_WORTH = ItemEntry.buyprice * SUPPLY_USED_QUANTITY

		if (MMH.SECTIONS.SUPPLIES_USED) then
			setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
			addgradcolors(unpack(MMH.COLORS.ENTRY_NAME_BACKGROUND))
			drawroundrect(0, 87 + ROW_QUANTITY * 18, 240, 15, 2, 2)

			setcompositionmode(CompositionMode_SourceOver)
			drawitem(ItemEntry.id, 6, 87 + ROW_QUANTITY * 18, 50, 100)
			setcompositionmode(CompositionMode_Automatic)

			drawtext(((#ItemEntry.name > 16 and string.match(string.sub(ItemEntry.name, 1, 16), '(.-)%s?$') .. '...') or ItemEntry.name):capitalizeall(), 28, 87 + ROW_QUANTITY * 18 + 15 / 2 - STRING_HEIGHT * 0.5)

			setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
			addgradcolors(unpack(MMH.COLORS.ENTRY_VALUE_BACKGROUND))
			drawroundrect(130, 87 + ROW_QUANTITY * 18, 110, 15, 2, 2)
			drawtext(num(SUPPLY_USED_QUANTITY) .. ' (' .. math.floor(SUPPLY_USED_WORTH / 100) / 10 .. 'K)', 136, 87 + ROW_QUANTITY * 18 + 15 / 2 - STRING_HEIGHT * 0.5)

			ROW_QUANTITY = ROW_QUANTITY + 1
		end

		SUPPLIES_USED_WORTH = SUPPLIES_USED_WORTH + SUPPLY_USED_WORTH
	end
end

if (MMH.SECTIONS.SUPPLIES_USED and $moneyspent > 0) then
	setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
	addgradcolors(unpack(MMH.COLORS.ENTRY_NAME_BACKGROUND))
	drawroundrect(0, 87 + ROW_QUANTITY * 18, 240, 15, 2, 2)

	setcompositionmode(CompositionMode_SourceOver)
	drawitem(3031, 6, 87 + ROW_QUANTITY * 18, 50, 100)
	setcompositionmode(CompositionMode_Automatic)

	drawtext('Money Spent', 28, 87 + ROW_QUANTITY * 18 + 15 / 2 - STRING_HEIGHT * 0.5)

	setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
	addgradcolors(unpack(MMH.COLORS.ENTRY_VALUE_BACKGROUND))
	drawroundrect(130, 87 + ROW_QUANTITY * 18, 110, 15, 2, 2)
	drawtext(num($moneyspent) .. ' (' .. math.floor($moneyspent / 100) / 10 .. 'K)', 136, 87 + ROW_QUANTITY * 18 + 15 / 2 - STRING_HEIGHT * 0.5)

	ROW_QUANTITY = ROW_QUANTITY + 1
end

SUPPLIES_USED_WORTH = SUPPLIES_USED_WORTH + $moneyspent

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
addgradcolors(unpack(MMH.COLORS.ENTRY_NAME_BACKGROUND))
drawroundrect(0, 87 + ROW_QUANTITY * 18, 240, 15, 2, 2)
drawtext('Total: ' .. num(SUPPLIES_USED_WORTH) .. ' GPs', 6, 87 + ROW_QUANTITY * 18 + 15 / 2 - STRING_HEIGHT * 0.5)

ROW_QUANTITY = ROW_QUANTITY + 1

setfontsize(8)

STRING_WIDTH, STRING_HEIGHT = measurestring('TEMP')

setfillstyle('gradient', 'linear', 2, 0, 0, 0, 21)
if (ITEMS_LOOTED_WORTH >= SUPPLIES_USED_WORTH) then
	addgradcolors(unpack(MMH.COLORS.RESULT_POSITIVE_BACKGROUND))
else
	addgradcolors(unpack(MMH.COLORS.RESULT_NEGATIVE_BACKGROUND))
end
drawroundrect(0, 87 + ROW_QUANTITY * 18, 240, 20, 2, 2)
drawtext(((ITEMS_LOOTED_WORTH >= SUPPLIES_USED_WORTH and ('PROFIT: ')) or ('WASTE: ')) .. num(ITEMS_LOOTED_WORTH - SUPPLIES_USED_WORTH) .. ' GPs (' .. math.abs(math.floor(((ITEMS_LOOTED_WORTH - SUPPLIES_USED_WORTH) * 3600) / ($charactertime / 1000) / 100) / 10) .. ' k/h)', 6, 87 + ROW_QUANTITY * 18 + 20 / 2 - STRING_HEIGHT * 0.5)
