init start
	-- VERSION 1.1.0 --

	local Monsters = {"Swampling", "Marsh Stalker", "Snake", "Water Buffalo"}

	local AmountToShoot = 3

	local Players = {
		Consider = true,
		Distance = 20,
		SafeList = {"Bubble", "Eternal Oblivion"},
		FloorDifference = 1
	}

	local Rune = "Avalanche Rune"

	local MoveSpeed = 9

	-- DO NOT EDIT BELOW --

	if not ($fasthotkeys or isbinded({Rune, 'crosshair'})) then
		printerrorf('Rune "%s" is not set on Tibia hotkeys, please change settings and restart script', Rune)
	end

	setsetting('Settings/MouseMoveSpeed', tostring(MoveSpeed))

init end

auto(100, 200)

if not Players.Consider or paroundfloorignore(Players.Distance, Players.FloorDifference, unpack(Players.SafeList)) == 0 then
	local sqm = getarearunetile(not Players.Consider, unpack(Monsters))

	if sqm.amount >= AmountToShoot then
		pausewalking(1000)
		useitemon(Rune, 0, sqm.tile)
		pausewalking(0)
		wait(2000)
	end
end
