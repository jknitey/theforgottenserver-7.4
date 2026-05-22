dofile("data/npc/lib/_npcsystem.lua")
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local talkState = {}

local function getPlayerKey(cid)
	if type(cid) == "userdata" and cid.getId ~= nil then
		return cid:getId()
	end

	return cid
end

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local stateKey = getPlayerKey(cid)
	local state = talkState[stateKey] or 0

	if msgcontains(msg, "key") then
		npcHandler:say("I would sell you a key for 50 gold, ok?", cid)
		talkState[stateKey] = 1
	elseif msgcontains(msg, "yes") and state == 1 then
		if doPlayerRemoveMoney(cid, 50) == TRUE then
			local key = doPlayerAddItem(cid, 2087, 1)
			doSetItemActionId(key, 3033)
			npcHandler:say("Here it is.", cid)
			talkState[stateKey] = 0
		else
			npcHandler:say("You don't have enough money.", cid)
		end
	elseif msgcontains(msg, "no") and state == 1 then
		npcHandler:say("Have a nice day.", cid)
		talkState[stateKey] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
