init start

	local UseSmartScreenshot = true

	local Skills = {
		-- Downgrades
		Death		=	true,

		-- Upgrades
		Level		=	true,
		Magic		=	true,
		Fist		=	true,
		Axe		=	true,
		Club		=	true,
		Sword		=	true,
		Distance	=	true,
		Shielding	=	true,
		Fishing		=	true,
	}

	-- DO NOT EDIT BELOW --
	
	local screenShotFunc = function(a)
		if UseSmartScreenshot and smartscreenshot ~= nil then
			return smartscreenshot(a)
		end

		return screenshot(a)
	end

init end

auto(400, 800)

foreach newmessage m do
	if m.type == MSG_STATUS or m.type == MSG_ADVANCE then
		local Skill = m.content:match('You advanced .- (.-)[%s%.].-')

		if Skill and Skills[Skill:capitalize()] then
			screenShotFunc(string.format('Advance_%s_%s', $name, os.date('%Y-%m-%d %H-%M-%S')))
		end
	end
end

if Skills.Death and $dead then
	screenShotFunc(string.format('Death_%s_%s', $name, os.date('%Y-%m-%d %H-%M-%S')))
	repeat
		wait(1000)
	until not $dead
end
