init start
 
	local Monsters = {"Swampling", "Snake", "Marsh Stalker", "Water Buffalo", "Salamander", "Emerald Damselfly"}
 
	local Players = {
		Consider = true,
		Distance = 10,
		FloorDifference = 1,
		SafeList = {"Bubble", "Eternal Oblivion"},
	}
 
	local Spells = {
		{Name = "exori gran", Amount = 4},
		{Name = "exori", Amount = 3},
		{Name = "exori min", Amount = 2},
		{Name = "exori ico", Hppc = 10},
		{Name = "exori hur", Hppc = 10},
		{Name = "utito tempo", Amount = 5},
	}
 
	local SpecialAreas = {
--		{min x, max x, min y, max y, z}
	}
 
	local UseTargetState = false
	
	-- DO NOT CHANGE ANYTHING BELOW THIS LINE
 
	local i, LastFloor, Exhaust = 1, $posz, $timems
 
	while Spells[i] ~= nil do
		Spells[i].Info = spellinfo(Spells[i].Name)
 
		if Spells[i].Info.words == 0 then
			table.remove(Spells, i)
		else
			Spells[i].Monsters = Spells[i].Monsters or Monsters
			Spells[i].NeedDirection = table.find({"WaveSmall", "WaveMedium", "WaveVerySmall", "WaveBig", "BeamSmall", "BeamBig", "Front", "Strike"}, Spells[i].Info.castarea) ~= nil
			Spells[i].AttackSupport = Spells[i].Info.group:match("Support") ~= nil
 
			table.lower(Spells[i].Monsters)
			i = i + 1
		end
	end
 
init end
 
auto(200, 400)
 
if $posz ~= LastFloor then
	LastFloor, Exhaust = $posz, $timems + 2000
	return
end
 
if $timems >= Exhaust and ($targeting or not UseTargetState) then
	for _, Spell in ipairs(Spells) do
		if cancast(Spell.Info) and not isinsidearea(SpecialAreas) then
			if Spell.Amount and (not Players.Consider or paroundfloorignore(Players.Distance, Players.FloorDifference, unpack(Players.SafeList)) == 0) then
				local BestAmount, BestDir = 0, $self.dir
 
				if Spell.NeedDirection then
					for Dir, Amount in pairs({n = 0, e = 0, s = 0, w = 0}) do
						Amount = maroundspell(Spell.Name, Dir, unpack(Spell.Monsters))
						
						if Amount > BestAmount or (Amount >= BestAmount and Dir == $self.dir) then
							BestAmount, BestDir = Amount, Dir
						end
					end
				else
					BestAmount = not Spell.AttackSupport and maroundspell(Spell.Name, BestDir, unpack(Spell.Monsters)) or maround(1, false, unpack(Spell.Monsters))
				end
				
				if BestAmount >= math.max(Spell.Amount, 1) then
					while $self.dir ~= BestDir do
						turn(BestDir) waitping()
					end
					cast(Spell.Name) waitping()
				end
			elseif Spell.Hppc and $attacked.hppc >= math.max(Spell.Hppc, 1) and table.find(Spell.Monsters, $attacked.name:lower()) and cancast(Spell.Info, $attacked) then
				cast(Spell.Name) waitping()
			end
		end
	end
end
