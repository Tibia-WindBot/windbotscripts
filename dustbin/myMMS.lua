init start
    -- diff colors and title display
    --
    --              88                                                                  
    --              ""                                                ,d                
    --                                                                88                
    --   ,adPPYba,  88  8b,dPPYba,  88,dPYba,,adPYba,   ,adPPYYba,  MM88MMM  ,adPPYba,  
    --   I8[    ""  88  88P'   "Y8  88P'   "88"    "8a  ""     `Y8    88    a8P_____88  
    --    `"Y8ba,   88  88          88      88      88  ,adPPPPP88    88    8PP"""""""  
    --   aa    ]8I  88  88          88      88      88  88,    ,88    88,   "8b,   ,aa  
    --   `"YbbdP"'  88  88          88      88      88  `"8bbdP"Y8    "Y888  `"Ybbd8"'  
    --

    --   Name: Monitor My Stats
    --   Last Updated: 19/12/2013
    --   Version: 1.0

    local MMS = {
        ShowInfo = true,
        Info = '                        Status Monitor',
        Version = '1.0.0'
    }

    -- [[ Do not change anything below this line. ]] --

    filterinput(false, true, false, false)

    local HUD_Sections = {
        {Name = 'CHARACTER STATS', State = tobool($botdb:getvalue('MMS', 'CHARACTER STATS')), Items = {
                {'Level', function() return $level .. ' (' .. 100 - math.floor(($exp - expatlvl($level)) * 100 / (expatlvl($level + 1) - expatlvl($level))) .. '%)' end},
                {'Experience', function() return num($exp) end},
                {'Magic Level', function() return $mlevel .. ' (' .. 100 - $mlevelpc .. '%)' end},
                {'Weapon Skill', function() local _ = WeaponSkill() return _.skill .. ' (' .. 100 - _.skillpc .. '%)' end},
                {'Shielding', function() return $shielding .. ' (' .. 100 - $shieldingpc .. '%)' end},
                {'Fishing', function() return $fishing .. ' (' .. 100 - $fishingpc .. '%)' end}
            }
        },

        {Name = 'ENGINE STATES', State = tobool($botdb:getvalue('MMS', 'ENGINE STATES')), Items = {
                {'Spell Healer', function() return getsetting('SpellHealer/Enabled') end, function() return toggle('SpellHealer/Enabled') end},
                {'Potion Healer', function() return getsetting('PotionHealer/Enabled') end, function() return toggle('PotionHealer/Enabled') end},
                {'Condition Healer', function() return getsetting('ConditionHealer/Enabled') end, function() return toggle('ConditionHealer/Enabled') end},
                {'Mana Training', function() return getsetting('ManaTrainer/Enabled') end, function() return toggle('ManaTrainer/Enabled') end},
                {'Cavebot', function() return getsetting('Cavebot/Enabled') end, function() return toggle('Cavebot/Enabled') end},
                {'Looting', function() return getsetting('Looting/Enabled') end, function() return toggle('Looting/Enabled') end},
                {'Targeting', function() return getsetting('Targeting/Enabled') end, function() return toggle('Targeting/Enabled') end}
            }
        },

        {Name = 'BOTTING STATS', State = tobool($botdb:getvalue('MMS', 'BOTTING STATS')), Items = {
                {'Experience per Hour', function() return num($exphour) end},
                {'Experience Left', function() return num(exptolevel()) end},
                {'Experience Today', function() return num($expgained) end},
                {'Time to Next Level', function() return time(timetolevel()) end},
                {'Played Time', function() return time(math.floor($charactertime / 1000)) end},
                {'Stamina', function() return time($stamina) end}
            }
        }
    }

    local HUD_Colors = {
            Font = color(255, 255, 255, 0),
            SectionHeaderBackground = {0.0, color(139, 0, 139), 0.23, color(0, 0, 0)},
            EntryNameBackground = {0.0, color(19, 19, 19)},
            EntryValueBackground = {0.0, color(50, 0, 50)},
            EntryValueEnabledBackground = {0.0, color(36, 52, 6)},
            EntryValueDisabledBackground = {0.0, color(52, 6, 9)},
    }

    function WeaponSkill()
        local SkillTypes = {
            ['axe'] = {type = 'axe', skill = $axe, skillpc = $axepc},
            ['club'] = {type = 'club', skill = $club, skillpc = $clubpc},
            ['sword'] = {type = 'sword', skill = $sword, skillpc = $swordpc},
            ['bow'] = {type = 'distance', skill = $distance, skillpc = $distancepc},
            ['distance weapon'] = {type = 'distance', skill = $distance, skillpc = $distancepc},
            ['no weapon'] = {type = 'fist', skill = $fist, skillpc = $fistpc},
            ['rod'] = {type = 'magic', skill = $mlevel, skillpc = $mlevelpc},
            ['wand'] = {type = 'magic', skill = $mlevel, skillpc = $mlevelpc},
        }

        return SkillTypes[findweapontype()]
    end

    local Moving, Temp, Moved, urllink = false, {0, 0}, {0, 0}, -1
	local tempPos = $botdb:getvalue('MMS', 'Position')
	
	if tempPos then
		tempPos = tempPos:explode(":")
		Moved = {tonumber(tempPos[1]), tonumber(tempPos[2])}
	end
	
    function inputevents(e)
        if (e.type == IEVENT_LMOUSEDOWN) then
            for _, Section in ipairs(HUD_Sections) do
                if (e.elementid == Section.StateSwitch) then
                    Section.State = not Section.State
                    return $botdb:setvalue('MMS', Section.Name, toonezero(Section.State))
                end
            end
			
	        for _, Section in ipairs(HUD_Sections) do
	                if (Section.Name == 'ENGINE STATES') then
	                    for _, SectionItem in ipairs(Section.Items) do
	                        if (e.elementid == SectionItem[4]) then
	                            SectionItem[3]()
	                            return
	                        end
	                    end
	                end
	            end
	        end

        if (e.type == IEVENT_MMOUSEDOWN) then
            Moving, Temp = true, {$cursor.x - Moved[1], $cursor.y - Moved[2]}
        end

        if (e.type == IEVENT_MMOUSEUP) then
            Moving = false
			$botdb:setvalue('MMS', 'Position', table.concat(Moved, ":"))
        end
    end
    
    setmaskcolorxp(0) 
init end

if (Moving) then
    auto(10)
    Moved = {$cursor.x - Temp[1], $cursor.y - Temp[2]}
end

setbordercolor(color(0,0,0))

setposition($clientwin.left + 5 + Moved[1], $worldwin.top + Moved[2])
setfontstyle('Tahoma', 8, 75, 0xFFFFFF, 1, color(0, 0, 0, 20))
local YPosition, SectionRow, SectionItemsRow = 0, 0, 0

if MMS.ShowInfo then
    local StringWidth, StringHeight = measurestring('TEMP')

    setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
    addgradcolors(unpack(HUD_Colors.EntryNameBackground))
    drawroundrect(0, 24 + 0 * 18, 240, 15, 2, 2)
    drawtext(MMS.Info, 6, 24 + 0 * 18 + 15 / 2 - StringHeight * 0.5 + 1)
     
    setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
    addgradcolors(unpack(HUD_Colors.EntryNameBackground))
    drawroundrect(0, 24 + 1 * 18, 240, 15, 2, 2)
    drawtext('Script version:', 6, 24 + 1 * 18 + 15 / 2 - StringHeight * 0.5 + 1)
     
    setfillstyle('gradient', 'linear', 2, 0, 0, 0, 16)
    addgradcolors(unpack(HUD_Colors.EntryValueBackground))
    drawroundrect(130, 24 + 1 * 18, 110, 15, 2, 2)
    drawtext(MMS.Version, 136, 24 + 1 * 18 + 15 / 2 - StringHeight * 0.5 + 1)
    
    YPosition = 22 + 2 * 19
end

for SectionIndex, Section in ipairs(HUD_Sections) do
    setfontsize(8)

    local StringWidth, StringHeight = measurestring('TEMP')

    setfillstyle('gradient', 'linear', 2, 0, 0, 0, 21)
    addgradcolors(unpack(HUD_Colors.SectionHeaderBackground))
    drawroundrect(0, YPosition + (SectionRow * 23) + (SectionItemsRow * 19), 240, 20, 2, 2)
	
	local w = measurestring(Section.Name)

    drawtext(Section.Name, 120 - w * 0.5, YPosition + (SectionRow * 23) + (SectionItemsRow * 19) + 20 / 2 - StringHeight * 0.5 + 1)

    setfillstyle('gradient', 'linear', 2, 0, 0, 0, 21)
    if (Section.State) then
        addgradcolors(unpack(HUD_Colors.EntryValueEnabledBackground))
    else
        addgradcolors(unpack(HUD_Colors.EntryValueDisabledBackground))
    end
    Section.StateSwitch = drawroundrect(220, YPosition + (SectionRow * 23) + (SectionItemsRow * 19), 20, 20, 2, 2)
    drawtext('X', 228, YPosition + (SectionRow * 23) + (SectionItemsRow * 19) + 20 / 2 - StringHeight * 0.5 + 1)

    SectionRow = SectionRow + 1

    if (Section.State) then
        setfontsize(7)

        local StringWidth, StringHeight = measurestring('TEMP')

        for SectionItemIndex, SectionItem in ipairs(Section.Items) do
            setfillstyle('gradient', 'linear', 2, 0, 0, 0, 17)     
            addgradcolors(unpack(HUD_Colors.EntryNameBackground))
            drawroundrect(0, YPosition + (SectionRow * 23) + (SectionItemsRow * 19), 240, 16, 2, 2)
            drawtext(SectionItem[1], 6, YPosition + (SectionRow * 23) + (SectionItemsRow * 19) + 16 / 2 - StringHeight * 0.5 + 1)

            if (Section.Name == 'ENGINE STATES') then
                local EngineCurrentState = SectionItem[2]()

                setfillstyle('gradient', 'linear', 2, 0, 0, 0, 17)
                if (EngineCurrentState == 'yes') then
                    addgradcolors(unpack(HUD_Colors.EntryValueEnabledBackground))
                else
                    addgradcolors(unpack(HUD_Colors.EntryValueDisabledBackground))
                end
                HUD_Sections[SectionIndex].Items[SectionItemIndex][4] = drawroundrect(130, YPosition + (SectionRow * 23) + (SectionItemsRow * 19), 110, 16, 2, 2)


                drawtext((EngineCurrentState == 'yes' and ('On')) or ('Off'), 136, YPosition + (SectionRow * 23) + (SectionItemsRow * 19) + 16 / 2 - StringHeight * 0.5 + 1)
            else
                setfillstyle('gradient', 'linear', 2, 0, 0, 0, 17)
                addgradcolors(unpack(HUD_Colors.EntryValueBackground))
                drawroundrect(130, YPosition + (SectionRow * 23) + (SectionItemsRow * 19), 110, 16, 2, 2)
                drawtext(SectionItem[2](), 136, YPosition + (SectionRow * 23) + (SectionItemsRow * 19) + 16 / 2 - StringHeight * 0.5 + 1)
            end

            SectionItemsRow = SectionItemsRow + 1
        end
    end
end
