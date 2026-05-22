dofile("data/npc/lib/_npcsystem.lua")
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local pendingTravel = {}
local freeTravelStorages = {30010, 30011, 30012, 30013}
local ghostshipDestination = {x = 33330, y = 32172, z = 5, stackpos = 0}
local vipIslandDestination = nil

local function getPlayerKey(cid)
	if type(cid) == "userdata" and cid.getId ~= nil then
		return cid:getId()
	end

	return cid
end

local function getTownTravelPosition(_, fallback)
	return {x = fallback.x, y = fallback.y, z = fallback.z, stackpos = 0}
end

local routes = {
	["vip"] = {
		name = "vip island",
		cost = 0,
		destination = vipIslandDestination,
		requiresStorage = 30009,
		requiresPremium = false,
		farewell = "You are not VIP."
	},
	["carlin"] = {
		name = "Carlin",
		cost = 130,
		destination = getTownTravelPosition("Carlin", {x = 32388, y = 31821, z = 6}),
		requiresPremium = false
	},
	["thais"] = {
		name = "Thais",
		cost = 0,
		destination = getTownTravelPosition("Thais", {x = 32310, y = 32210, z = 7}),
		requiresPremium = false
	},
	["ab'dendriel"] = {
		name = "Ab'Dendriel",
		cost = 90,
		destination = getTownTravelPosition("Ab'Dendriel", {x = 32734, y = 31669, z = 7}),
		requiresPremium = false
	},
	["darashia"] = {
		name = "Darashia",
		cost = 60,
		destination = getTownTravelPosition("Darashia", {x = 33290, y = 32481, z = 7}),
		requiresPremium = false,
		ghostshipChance = 10,
		ghostshipDestination = ghostshipDestination
	},
	["edron"] = {
		name = "Edron",
		cost = 40,
		destination = getTownTravelPosition("Edron", {x = 33176, y = 31764, z = 7}),
		requiresPremium = false
	},
	["ankrahmun"] = {
		name = "Ankrahmun",
		cost = 150,
		destination = getTownTravelPosition("Ankrahmun", {x = 33092, y = 32884, z = 7}),
		requiresPremium = false
	},
	["port hope"] = {
		name = "Port Hope",
		cost = 160,
		destination = getTownTravelPosition("Port Hope", {x = 32530, y = 32784, z = 6}),
		requiresPremium = false
	}
}

local function clearPending(cid)
	pendingTravel[getPlayerKey(cid)] = nil
end

local function hasFreeTravel(cid)
	for _, storageId in ipairs(freeTravelStorages) do
		if getPlayerStorageValue(cid, storageId) == 1 then
			return true
		end
	end

	return false
end

local function getRouteCost(cid, route)
	if route.requiresStorage then
		return route.cost
	end

	if hasFreeTravel(cid) then
		return 0
	end

	return route.cost
end

local function askTravel(cid, route)
	if route.requiresStorage and getPlayerStorageValue(cid, route.requiresStorage) ~= 1 then
		npcHandler:say(route.farewell or "You may not travel there yet.", cid)
		clearPending(cid)
		return
	end

	local cost = getRouteCost(cid, route)
	local priceText = cost == 0 and "for free" or string.format("for %d gold", cost)
	pendingTravel[getPlayerKey(cid)] = route
	npcHandler:say(string.format("Do you seek a passage to %s %s?", route.name, priceText), cid)
end

local function handleTravel(cid, route)
	local cost = getRouteCost(cid, route)
	if route.requiresPremium and not isPremium(cid) then
		npcHandler:say("I'm sorry, but you need a premium account in order to travel onboard our ships.", cid)
	elseif hasCondition(cid, CONDITION_INFIGHT) == 1 then
		npcHandler:say("First get rid of those blood stains! You are not going to ruin my vehicle!", cid)
	elseif route.destination == nil then
		npcHandler:say("This passage is currently unavailable.", cid)
	elseif cost > 0 and getPlayerMoney(cid) < cost then
		npcHandler:say("You don't have enough money.", cid)
	else
		local destination = route.destination
		if route.ghostshipChance and math.random(1, route.ghostshipChance) == 1 then
			destination = route.ghostshipDestination or destination
		end

		if cost > 0 then
			doPlayerRemoveMoney(cid, cost)
		end

		npcHandler:say("Set the sails!", cid)
		npcHandler:releaseFocus(cid)
		doTeleportThing(cid, destination)
		doSendMagicEffect(getCreaturePosition(cid), 10)
	end

	clearPending(cid)
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

	return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
