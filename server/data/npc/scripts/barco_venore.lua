local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local pendingDestination = {}

local destinations = {
	["thais"] = {
		name = "Thais",
		cost = 0,
		position = {x = 32311, y = 32210, z = 7},
	},
	["carlin"] = {
		name = "Carlin",
		cost = 0,
		position = {x = 32389, y = 31821, z = 7},
	},
	["ab'dendriel"] = {
		name = "Ab'Dendriel",
		cost = 0,
		position = {x = 32735, y = 31668, z = 7},
	},
	["ab dendriel"] = {
		name = "Ab'Dendriel",
		cost = 0,
		position = {x = 32735, y = 31668, z = 7},
	},
	["port hope"] = {
		name = "Port Hope",
		cost = 0,
		position = {x = 32531, y = 32784, z = 7},
	},
	["edron"] = {
		name = "Edron",
		cost = 0,
		position = {x = 33173, y = 31764, z = 6},
	},
	["darashia"] = {
		name = "Darashia",
		cost = 0,
		position = {x = 33291, y = 32481, z = 7},
	},
	["ankrahmun"] = {
		name = "Ankrahmun",
		cost = 0,
		position = {x = 33093, y = 32884, z = 7},
	},
}

local destinationList = "I can take you to {Thais}, {Carlin}, {Ab'Dendriel}, {Port Hope}, {Edron}, {Darashia} and {Ankrahmun}."

local function getPlayerKey(cid)
	local player = Player(cid)
	return player and player:getId() or cid
end

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid)
	pendingDestination[getPlayerKey(cid)] = nil
	npcHandler:onCreatureDisappear(cid)
end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local function clearPending(cid)
	pendingDestination[getPlayerKey(cid)] = nil
end

local function travelPlayer(cid, destination)
	local cost = destination.cost or 0
	if isPlayerPzLocked(cid) then
		npcHandler:say("First get rid of those blood stains! You are not going to ruin my vehicle!", cid)
		clearPending(cid)
		return true
	end

	if cost > 0 and not doPlayerRemoveMoney(cid, cost) then
		npcHandler:say("You don't have enough money.", cid)
		clearPending(cid)
		return true
	end

	npcHandler:say("Set the sails!", cid)
	doTeleportThing(cid, destination.position, false)
	doSendMagicEffect(destination.position, CONST_ME_TELEPORT)
	clearPending(cid)
	npcHandler:releaseFocus(cid)
	return true
end

function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local playerKey = getPlayerKey(cid)
	local message = msg:lower()
	local destination = destinations[message]
	if destination ~= nil then
		pendingDestination[playerKey] = destination
		npcHandler:say("Do you want to travel to " .. destination.name .. " for " .. destination.cost .. " gold coins?", cid)
		return true
	end

	if msgcontains(message, "destination") or msgcontains(message, "destinations") or msgcontains(message, "sail") or msgcontains(message, "travel") or msgcontains(message, "passage") or msgcontains(message, "go") then
		npcHandler:say(destinationList, cid)
		return true
	end

	if msgcontains(message, "job") or msgcontains(message, "captain") then
		npcHandler:say("I'm the captain of this sailing ship.", cid)
		return true
	end

	if msgcontains(message, "yes") then
		local pending = pendingDestination[playerKey]
		if pending ~= nil then
			return travelPlayer(cid, pending)
		end
		return false
	end

	if msgcontains(message, "no") then
		if pendingDestination[playerKey] ~= nil then
			npcHandler:say("Ok, come back when you want then!", cid)
			clearPending(cid)
			return true
		end
		return false
	end

	return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
