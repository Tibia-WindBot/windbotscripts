init start
	-- VERSION 2.0.0 --

	local Config = {
		SafeList = {"Bubble", "Eternal Oblivion"},
		MinLevel = 10,
		IgnoreMonsters = false,
		LogText = true,
		UseDatabase = false,
	}

	-- DO NOT EDIT BELOW --

	local Responder = {
		MessageInfo = {},
		Timer = os.time(),
	}

	Responder.Ignored = $chardb:getvalue('AUTO_RESPONDER', 'IgnoredGuys')

	if Config.UseDatabase and Responder.Ignored and Responder.Ignored ~= '{}' then
		Responder.Ignored = Responder.Ignored:totable()
	else
		Responder.Ignored = {}
	end

	Responder.SpeechWords = {
		{
			k = {"spanish?", "spanish ?", "span?", "spanol?", "spanol?", "spanol ?", "spanol ?"},
			r = {{"no", "nope"}, {"nope man", "nopss", "no man bb"}}
		},
		{
			k = {"hi", "hai", "hello", "sup", "yo", "yoo", "hiho", "HI", "HELLO", "SUP", "YO", "YOO", "HIHO", "HAI"},
			r = {{"hi", "hello", "hiho", "yo", "sup"}, {"i said hi", "already said hi", "sup, again"}, {"ok man, this is getting boring", "this is boring man", "damn stop saying hi"}}
		},
		{
			k = {"use bot?", "use bot ?", "use bot", "bot?", "bot", "botter", "bottter", "botterrr", "botting", "you are bot", "you're bot", "your bot"},
			r = {{"me?", "me ? lol", "no man", "you wrong", "you're wrong", "i dont bot"}, {"leave plz", "stop dis or ignored", "gtfo", "stop plz", "annoying :["}}
		},
		{
			k = {"auto respond", "auto responder", "auto respond ?", "auto respond?", "auto responder?", "auto responder ?", "auto-respond", "auto-responder", "auto-responder?", "auto-responder ?", "auto-respond?", "auto-respond ?", "auto talk", "auto-talk", "auto talk?", "auto talk ?", "auto-talk?"},
			r = {{"no, just type and do enter", "lol man", "lol wtf is this?", "lol'ed now", "oh tibia have that ?", "hahaha"}, {"whatever", "stop dis pls", "byee"}, {"i'm sirious now", "stop or ignored"}}
		},
		{
			k = {"no kill", "plz no kill", "dont kill", "i'm skilling", "im skilling", "im skill", "plz no kill", "i'm skill", "man no kill", "ks?", "ks", "ks lol", "dont ks", "don't ks"},
			r = {{"sry i need exp", "i need all exp", "all exp is mine", "leave plz i need exp"}, {"i will kill everything", "i kill what i want", "ks is fun"}}
		},
		{
			k = {"noob", "n00b", "nb", "noob -.-", "n00b -.-", "noobie", "newbie", "nb plz", "noob plz"},
			r = {{"noob u", "noob you", "nab", "sure noob", "-.-"}, {"whatever", "w.e", "ok man bb", "noob gtfo"}, {"aff", "boring", "i'm mad now"}}
		},
		{
			k = {"whats my name?", "what is my name ?", "what is my name?", "what's my name?", "what's my name ?"},
			r = {{"look on your character lol", "your name is noob", "u dont know how to read ?"}, {"lol man u know your name", "u know your name stop spam", "stop spam man"}, {"look on your screen and read", "such a noob"}, {"ok now i'll ignore you"}}
		},
		{
			k = {"going to delete you", "going to delete your char", "i'll delete your char", "i will delete your char", "i'll ban you", "i'll ban u", "going to ban you", "going to ban u"},
			r = {{"omaiga", "so you're a gm..", "no you're not", "ok man do what u want"}, {"come back tomorrow", "stop man bb", "stop spam"}, {"next msg like this = ignore"}}
		},
		{
			k = {"fuck you", "fuck u", "fuk you", "fuk u", "fak you", "fak u", "fak", "fuck", "damn you", ".i.", "..i..", ",,i,,", ",i,"},
			r = {{"not nice man", "stop", "i dont like that"}, {"sounds like a you dont like me", "stop or ignore", "stop or reported", "reported"}}
		},
		{
			k = {"leave", "leave plz", "leave man", "leave pls", "leavee"},
			r = {{"nop", "sry no", "nonono", "can't", "i'll stay", "sry bb"}, {"no man byee", "i will hunt now", "i am here now begone"}, {"damn can't your see ? i'm here now", "B.Y.E"}}
		},
		{
			k = {"lol", "rofl", "lmao", "ftw", "wtf", "haha", "hehe", "LMAO", "ROFL", "LOL", "loled", "lol'ed", "lul", "lool", "luls", "lulz", "lols"},
			r = {{"haha", "lul", "lool", "hehehe", "rofl", "roflmao", ":)", "^^", ":]", ":>"}, {"haha", "lul", "lool", "hehehe", "rofl", "roflmao", ":)", "^^", ":]", ":>"}, {"haha", "lul", "lool", "hehehe", "rofl", "roflmao", ":)", "^^", ":]", ":>"}, {"haha", "lul", "lool", "hehehe", "rofl", "roflmao", ":)", "^^", ":]", ":>"}, {"ok, i like to smile but it's enough let me alone now", "ok but now let me alone", ":) well i'm going, cya"}}
		},
		{
			k = {"how do you type?", "how do you type ?", "how you type ?", "how you type?", "how to type?", "how to type ?"},
			r = {{"type text and do enter", "u need something special", "u need to be special", "with fingers", "with hands"}, {"lol stuff you said", "man i need to hunt alone", "bb or ignored"}}
		},
		{
			k = {"whoa you're so fast", "wow you're so fast", "you type really fast", "you type fast", "so fast you type", "type fast", "you're so fast", "your fast", "so fast"},
			r = {{"yeah i train a lot", "ye imma hell of a racemachine", "yes i do"}, {"i said that i'm fast", "ye already said that, i'm really fast", "i'm so fast that i can hunt and talk to you :)"}, {"ok man..", "ye you know", "true.."}, {"i'm getting tired of this", "ok man now bb"}}
		},
	}

	table.insert(Config.SafeList, $name)
	table.lower(Config.SafeList)

	function table.findtext(self, v)
		local c = table.find(self, v)
		if not c then
			for i, k in pairs(self) do
				if v:find(k) or v:lower():find(k:lower()) then
					return i
				end
			end
		else
			return c
		end
		return nil
	end

	-- we want to simulate a human typing
	-- so when fasthotkeys are enabled they're
	-- typed so fast that the sender will
	-- know you're actually botting, this will
	-- simulate pressing time if fasthotkeys
	-- are enabled. (Took from Raphael's lib)
	local function __waitcast(msg)
		if $fasthotkeys then
			local t = 0
			local minWait, maxWait = get('Settings/TypeWaitTime'):match(REGEX_RANGE)
			minWait, maxWait = tonumber(minWait), tonumber(maxWait)

			for i = 0, #msg do
				t = t + math.random(minWait, maxWait)
			end

			return wait(t)
		end
	end

	local fileName = sprintf('[%s] - Auto Responder.txt', $name)

	if Config.LogText and not file.exists(fileName) then
		file.clear(fileName)
	end

init end

auto(1000, 1200)

foreach newmessage m do
	if table.find({MSG_DEFAULT, MSG_WHISPER, MSG_YELL, MSG_PVT}, m.type) and (not table.find(Config.SafeList, m.sender:lower())) and m.level >= Config.MinLevel and os.difftime(os.time(), Responder.Timer) >= 2 and (not Responder.Ignored[m.sender]) and #spellinfo(m.content).words == 0 then
		if Config.LogText then
			file.writeline(fileName, string.format("RECEIVED: [%s] VIA: %s FROM: %s CONTENT: %s", m.timestr, m.type == MSG_PVT and "Private" or "Local Chat", m.sender, m.content))
		end

		for State, Entry in pairs(Responder.SpeechWords) do
			if table.findtext(Entry.k, m.content) then
				if Responder.MessageInfo[m.sender] then
					if Responder.MessageInfo[m.sender][State] then
						if not Responder.SpeechWords[State].r[Responder.MessageInfo[m.sender][State] + 1] then
							Responder.Ignored[m.sender] = true

							local msg = ({"ignored -.-", "ignored"})[math.random(1, 2)]

							if not Config.IgnoreMonsters then
								while maround(1, false) > 0 do
									wait(100, 200)
								end
							end

							if m.type ~= MSG_PVT then
								__waitcast(msg)
								say("Local Chat", msg)
							else
								__waitcast(msg)
								say("Local Chat", string.format("@%s@ %s", m.sender, msg))
							end

							if Config.LogText then
								file.writeline(fileName, string.format("SENT: [%s] VIA: %s FROM: %s TO: %s CONTENT: %s", m.timestr, m.type == MSG_PVT and "Private" or "Local Chat", $name, m.sender, msg))
								file.writeline(fileName, string.format("IGNORED PLAYER: [%s] NAME: %s", m.timestr, m.sender))
							end

							$chardb:setvalue('AUTO_RESPONDER', 'IgnoredGuys', table.tostring(Responder.Ignored))

							return
						end
					else
						Responder.MessageInfo[m.sender][State] = 0
					end
				else
					Responder.MessageInfo[m.sender] = {}
					Responder.MessageInfo[m.sender][State] = 0
				end

				if not Config.IgnoreMonsters then
					while maround(1, false) > 0 do
						wait(100, 200)
					end
				end

				local msg = Entry.r[Responder.MessageInfo[m.sender][State] + 1][math.random(1, #Entry.r[Responder.MessageInfo[m.sender][State] + 1])]

				if m.type ~= MSG_PVT then
					__waitcast(msg)
					say("Local Chat", msg)
				else
					__waitcast(msg)
					say("Local Chat", string.format("*%s* %s", m.sender, msg))
				end

				if Config.LogText then
					file.writeline(fileName, string.format("SENT: [%s] VIA: %s FROM: %s TO: %s CONTENT: %s", m.timestr, m.type == MSG_PVT and "Private" or "Local Chat", $name, m.sender, msg))
				end

				Responder.MessageInfo[m.sender][State], Responder.Timer = Responder.MessageInfo[m.sender][State] + 1, os.time()

				return
			end
		end
	end
end
