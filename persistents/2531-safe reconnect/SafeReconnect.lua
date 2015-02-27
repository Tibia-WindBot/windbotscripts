init start
	-- local SCRIPT_VERSION = "2.3.2"
	-- If ReopenBps is set to true then it'll try to reopen the visible backpacks on the main backpack
	-- setting it to false will just ignore your bps after you are logged in

	local ReopenBps = true

	-- If IgnoreServerSave is set to false it'll wait to relog if server save is occurring
	-- setting it to true will try to relog even on server saving time

	local IgnoreServerSave = false

	-- [[ ONLY EDIT SPECIAL CHECKS IF YOU KNOW WHAT YOU'RE DOING ]]--

	-- special checks are the checks it'll do after you login
	-- for example: if you are skulled, inside temple, etc ...

	local SpecialChecks = {
		{
			function()
				return isontemple()
			end,
			function()
				printerrorf("Safe Reconnect: [%q] Client closed. Reason: Character was inside a temple.", $name)
				closeclient(true)
			end
		},
		{
			function()
				return ($self.skull == SKULL_RED or $self.skull == SKULL_BLACK) and $pzone
			end,
			function()
				printerrorf("Safe Reconnect: [%q] Client closed. Reason: Character was red/black skulled inside a protection zone.", $name)
				closeclient(true)
			end
		},
		{
			function()
				return $stamina <= 14*60 and $pzone
			end,
			function()
				printerrorf("Safe Reconnect: [%q] Client closed. Reason: Character had less/equal than 14 hours of stamina and inside a protection zone.", $name)
				closeclient(true)
			end
		},
	}

	-- DO NOT EDIT BELOW --
	local reconState = 1

	if $curscript.type ~= 'persistent' then
		reconState = -1
		printerror('Reconnect should be placed at Scripter/Persistents.\nChange this setting to run it properly.')
	end

	local openFunc = function()
		local lifeTime = $timems
		local reopenLogin = get('Looting/OpenBPsAtLogin')

		set('Looting/OpenBPsAtLogin', 'no')
		reopenwindows('small')

		while $openingbps do
			wait(100)

			if $timems - lifeTime >= 10000 and not $pzone then

				set('Looting/OpenBPsAtLogin', reopenLogin)
				return false
			end
		end

		set('Looting/OpenBPsAtLogin', reopenLogin)
		return true
	end

	local randTimeSS = math.random(100, 700)

init end

auto(1000)

if (not $connected) and (IgnoreServerSave or (sstime() >= 600 + randTimeSS and sstime() <= 85800 - randTimeSS)) and reconState == 1 then
	set('Targeting/Enabled', 'no')
	set('Cavebot/Enabled', 'no')

	local changeSettings = false

	if $worldvisible then
		changeSettings = get('Settings/OpenMenuPolicy')
		set('Settings/OpenMenuPolicy', 'Do nothing')
	end

	reconnect($worldvisible)

	randTimeSS = math.random(100, 700)

	if changeSettings then
		set('Settings/OpenMenuPolicy', changeSettings)
	end

	if $connected then
		pausewalking(10000)
	else
		return
	end

	if ReopenBps then
		local clientMin = $minimized

		if clientMin and not $addons.enabled then
			-- if windaddons is enabled then we don't need to restore the window
			-- but if it's not, the bp opener will get stuck and alert you anytime
			-- se we restore the window to make sure it'll open and you won't die
			restoreclient() waitping()
		end

		local reopenSuccess = openFunc()

		if not reopenSuccess then
			-- this will only happen if you took more than 10 seconds to open bps
			-- if this happened probably you have another script trying to open it
			-- or any other thing blocking it from opening, if so we should start
			-- cavebot and targeting again to make sure you won't die, because after
			-- 10 seconds the monsters will surround you and start attacking
			printerrorf("Safe Reconnect: [%q] It took too long to open the backpacks, they could be already opened but for safety reasons you were alerted.", $name)
			pausewalking(0)
			set('Targeting/Enabled', 'yes')
			set('Cavebot/Enabled', 'yes')

			-- alert in this case
			for _ = 1, 10 do
				beep()
				wait(1000)
			end
		end

		if clientMin and not $minimized then
			minimizeclient()
		end
	end

	for _, callback in ipairs(SpecialChecks) do
		-- here we check for the given special checks like
		-- is on temple, low stamina, skulled, and logout
		-- if something happened
		if callback[1]() then
			reconState = 0

			return (callback[2] ~= nil and stopattack() and callback[2]()) or false
		end
	end

	if not ($targeting and $cavebot) then
		set('Targeting/Enabled', 'yes')
		set('Cavebot/Enabled', 'yes')
		pausewalking(0)
	end
end
