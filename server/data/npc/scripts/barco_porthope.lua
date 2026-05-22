dofile("data/npc/lib/_npcsystem.lua")

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local pendingTravel = {}

local function getPlayerKey(cid)
	if type(cid) == "userdata" and cid.getId ~= nil then
		return cid:getId()
	end

	return cid
end

local routes = {
	["thais"] = {name = "Thais", cost = 0, level = 8, premium = true, destination = {x = 32310, y = 32210, z = 7}},
	["darashia"] = {name = "Darashia", cost = 0, level = 8, premium = true, destination = {x = 33290, y = 32481, z = 7}},
	["venore"] = {name = "Venore", cost = 0, level = 8, premium = true, destination = {x = 32954, y = 32022, z = 7}},
	["ankrahmun"] = {name = "Ankrahmun", cost = 0, level = 8, premium = true, destination = {x = 33092, y = 32884, z = 7}},
	["edron"] = {name = "Edron", cost = 0, level = 8, premium = true, destination = {x = 33176, y = 31764, z = 7}},
}

local function clearPending(cid)
	pendingTravel[getPlayerKey(cid)] = nil
end

local function askTravel(cid, route)
	pendingTravel[getPlayerKey(cid)] = route
	npcHandler:say(string.format("Do you want to travel to %s for %d gold coins?", route.name, route.cost), cid)
end

local function handleTravel(cid, route)
	if route.premium and not isPremium(cid) then
		npcHandler:say("I'm sorry, but you need a premium account in order to travel onboard our ships.", cid)
	elseif getPlayerLevel(cid) < route.level then
		npcHandler:say("You must reach level " .. route.level .. " before I can let you go there.", cid)
	elseif isPlayerPzLocked(cid) then
		npcHandler:say("First get rid of those blood stains! You are not going to ruin my vehicle!", cid)
	elseif not doPlayerRemoveMoney(cid, route.cost) then
		npcHandler:say("You don't have enough money.", cid)
	else
		npcHandler:say("Set the sails!", cid)
		npcHandler:releaseFocus(cid)
		doTeleportThing(cid, route.destination, false)
		doSendMagicEffect(route.destination, CONST_ME_TELEPORT)
	end

	clearPending(cid)
	npcHandler:resetNpc(cid)
end

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

function creatureSayCallback(cid, type, msg)
	msg = string.lower(msg)

	if not npcHandler:isFocused(cid) then
		return false
	end

	if msgcontains(msg, "destination") or msgcontains(msg, "destinations") or msgcontains(msg, "sail") or msgcontains(msg, "passage") or msgcontains(msg, "trip") or msgcontains(msg, "route") or msgcontains(msg, "go") then
		npcHandler:say("Where do you want to go? To Thais, Darashia, Venore, Ankrahmun or Edron?", cid)
		return true
	end

	for keyword, route in pairs(routes) do
		if msgcontains(msg, keyword) then
			askTravel(cid, route)
			return true
		end
	end

	if msgcontains(msg, "yes") then
		local route = pendingTravel[getPlayerKey(cid)]
		if route then
			handleTravel(cid, route)
			return true
		end
	elseif msgcontains(msg, "no") then
		if pendingTravel[getPlayerKey(cid)] then
			npcHandler:say("Ok, come back when you want then!", cid)
			clearPending(cid)
			return true
		end
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
