dofile("data/npc/lib/_npcsystem.lua")
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local destination = {x = 32205, y = 31756, z = 6}
local pendingTravel = {}

local function getPlayerKey(cid)
	if type(cid) == "userdata" and cid.getId ~= nil then
		return cid:getId()
	end

	return cid
end

local function clearPending(cid)
	pendingTravel[getPlayerKey(cid)] = nil
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

	if msgcontains(msg, "continent") or msgcontains(msg, "tibia") then
		pendingTravel[getPlayerKey(cid)] = true
		npcHandler:say("Friends of Dalbrect are my friends too! So you are looking for a passage to the continent for 20 gold?", cid)
		return true
	end

	if msgcontains(msg, "yes") and pendingTravel[getPlayerKey(cid)] then
		if getPlayerStorageValue(cid, 99998) ~= -1 then
			npcHandler:say("Without the abbots permission I won't take sail you anywhere! Go and ask him for a passage first.", cid)
		elseif hasCondition(cid, CONDITION_INFIGHT) == 1 then
			npcHandler:say("First get rid of those blood stains! You are not going to ruin my vehicle!", cid)
		elseif getPlayerMoney(cid) < 20 then
			npcHandler:say("You don't have enough money.", cid)
		else
			npcHandler:say("Have a nice trip!", cid)
			doPlayerRemoveMoney(cid, 20)
			npcHandler:releaseFocus(cid)
			doTeleportThing(cid, destination)
			doSendMagicEffect(getCreaturePosition(cid), 10)
		end

		clearPending(cid)
		return true
	end

	if msgcontains(msg, "no") and pendingTravel[getPlayerKey(cid)] then
		npcHandler:say("Ok, come back when you want then!", cid)
		clearPending(cid)
		return true
	end

	return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
