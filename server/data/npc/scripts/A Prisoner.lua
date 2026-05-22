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
	local questState = getPlayerStorageValue(cid, 6667)

	if msgcontains(msg, "math") and questState == 1 then
		npcHandler:say("My surreal numbers are based on astonishing facts. Are you interested in learning the secret of mathemagics?", cid)
		talkState[stateKey] = 1
	elseif msgcontains(msg, "yes") and state == 1 then
		npcHandler:say("But first tell me your favourite colour please!", cid)
		talkState[stateKey] = 2
	elseif msgcontains(msg, "green") and state == 2 then
		npcHandler:say("Very interesting. So are you ready to proceed in you lesson in mathemagics?", cid)
		doPlayerRemoveMoney(cid, 1000)
		talkState[stateKey] = 3
	elseif msgcontains(msg, "yes") and state == 3 then
		npcHandler:say("So know that everthing is based on the simple fact that 1 + 1 = 2!", cid)
		setPlayerStorageValue(cid, 6668, 1)
		talkState[stateKey] = 4
	elseif msgcontains(msg, "bye") and state >= 1 and state <= 4 then
		npcHandler:say("Next time we should talk about my surreal numbers.", cid)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "key") then
		npcHandler:say("Do you want a key to the mad mage room?", cid)
		talkState[stateKey] = 5
	elseif msgcontains(msg, "yes") and state == 5 then
		npcHandler:say("Here you are a special key.", cid)
		local key = doPlayerAddItem(cid, 2088, 1)
		doSetItemActionId(key, 3666)
		talkState[stateKey] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
