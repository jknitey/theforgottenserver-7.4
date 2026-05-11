dofile("data/npc/lib/_npcsystem.lua")

local focus = 0
local talkStart = 0
local talkState = 0
local pendingChoice = nil

local cities = {
	thais = {
		town = 3,
		destination = {x = 32369, y = 32241, z = 7}
	},
	carlin = {
		town = 5,
		destination = {x = 32360, y = 31782, z = 7}
	},
	venore = {
		town = 4,
		destination = {x = 32957, y = 32076, z = 7}
	}
}

local vocations = {
	sorcerer = 1,
	druid = 2,
	paladin = 3,
	knight = 4
}

local function resetOracleState()
	talkState = 0
	pendingChoice = nil
end

local function isFocused(cid)
	return focus == cid
end

local function containsWord(message, word)
	return message == word or message:find(word, 1, true) ~= nil
end

local function chooseCity(msg)
	for cityName, data in pairs(cities) do
		if containsWord(msg, cityName) then
			return cityName, data
		end
	end

	return nil, nil
end

local function chooseVocation(msg)
	for vocationName, vocationId in pairs(vocations) do
		if containsWord(msg, vocationName) then
			return vocationName, vocationId
		end
	end

	return nil, nil
end

function onCreatureAppear(cid)
end

function onCreatureDisappear(cid)
	if focus == cid then
		selfSay("Good bye then.")
		focus = 0
		talkStart = 0
		resetOracleState()
	end
end

function onCreatureMove(creature, oldPos, newPos)
end

function onCreatureSay(cid, type, msg)
	msg = string.lower(msg)

	if containsWord(msg, "hi") or containsWord(msg, "hello") then
		if focus == 0 then
			if getPlayerLevel(cid) < 8 then
				selfSay("COME BACK WHEN YOU GROW UP, CHILD!")
				return
			end

			focus = cid
			talkStart = os.time()
			resetOracleState()
			selfSay("Hello " .. getCreatureName(cid) .. ". Are you prepared to face your destiny?")
		elseif focus == cid then
			selfSay(getCreatureName(cid) .. ", I am already talking to you.")
			talkStart = os.time()
		else
			selfSay("Sorry, " .. getCreatureName(cid) .. "! I talk to you in a minute.")
		end
		return
	end

	if not isFocused(cid) then
		return
	end

	talkStart = os.time()

	if containsWord(msg, "bye") or containsWord(msg, "farewell") then
		selfSay("Good bye, " .. getCreatureName(cid) .. "!")
		focus = 0
		talkStart = 0
		resetOracleState()
		return
	end

	if talkState == 0 then
		if containsWord(msg, "yes") then
			selfSay("What city do you wish to live in? {Thais}, {Carlin} or {Venore}?")
			talkState = 1
		elseif containsWord(msg, "no") then
			selfSay("Then come back when you are ready.")
			focus = 0
			talkStart = 0
			resetOracleState()
		end
		return
	end

	if talkState == 1 then
		local cityName, cityData = chooseCity(msg)
		if cityData then
			pendingChoice = {
				town = cityData.town,
				destination = cityData.destination
			}
			selfSay(cityName:sub(1, 1):upper() .. cityName:sub(2) .. ", eh? So what vocation do you wish to become? {Sorcerer}, {Druid}, {Paladin} or {Knight}?")
			talkState = 2
		end
		return
	end

	if talkState == 2 then
		local vocationName, vocationId = chooseVocation(msg)
		if vocationId then
			pendingChoice.vocation = vocationId

			if vocationName == "sorcerer" then
				selfSay("So, you wish to be a powerful magician? Are you sure about that? This decision is irreversible!")
			elseif vocationName == "druid" then
				selfSay("Are you sure that a druid is what you wish to become? This decision is irreversible!")
			elseif vocationName == "paladin" then
				selfSay("A ranged marksman. Are you sure? This decision is irreversible!")
			else
				selfSay("A mighty warrior. Is that your final decision? This decision is irreversible!")
			end

			talkState = 3
		end
		return
	end

	if talkState == 3 then
		if containsWord(msg, "yes") then
			if getPlayerLevel(cid) < 8 then
				selfSay("You must first reach level 8!")
			elseif getPlayerVocation(cid) > 0 then
				selfSay("Sorry, you already have a vocation!")
			elseif pendingChoice ~= nil then
				local currentPosition = getCreaturePosition(cid)
				doPlayerSetVocation(cid, pendingChoice.vocation)
				doPlayerSetTown(cid, pendingChoice.town)
				doTeleportThing(cid, pendingChoice.destination)
				doSendMagicEffect(currentPosition, CONST_ME_POFF)
				doSendMagicEffect(pendingChoice.destination, CONST_ME_TELEPORT)
			end

			focus = 0
			talkStart = 0
			resetOracleState()
		elseif containsWord(msg, "no") then
			selfSay("Then what vocation do you want to become? {Sorcerer}, {Druid}, {Paladin} or {Knight}?")
			talkState = 2
		end
	end
end

function onCreatureChangeOutfit(creature)
end

function onThink()
	if focus == 0 then
		return
	end
end
