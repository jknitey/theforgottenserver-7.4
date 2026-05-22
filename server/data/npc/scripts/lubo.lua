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
	local queststate = getPlayerStorageValue(cid, 6666)

	if msgcontains(msg, "crunor's cottage") and queststate == 1 then
		npcHandler:say("Ah yes, I remember my grandfather talking about that name. This house used to be an inn a long time ago. My family bought it from some of these flower", cid)
		talkState[stateKey] = 1
	elseif msgcontains(msg, "flower guys") and state == 1 then
		npcHandler:say("Oh, I mean druids of course. They sold the cottage to my family after some of them died in an accident or something like that.", cid)
		talkState[stateKey] = 2
	elseif msgcontains(msg, "accident") and state == 2 then
		npcHandler:say("As far as I can remember the story, a pet escaped its stable behind the inn. It got somehow involved with powerfull magic at a ritual and was transformed in some way.", cid)
		talkState[stateKey] = 3
	elseif msgcontains(msg, "stable") and state == 3 then
		npcHandler:say("My grandpa told me, in the old days there were some behind this cottage. Nothing big though, just small ones, for chicken or rabbits.", cid)
		setPlayerStorageValue(cid, 6667, 1)
		talkState[stateKey] = 4
	elseif msgcontains(msg, "bye") and state >= 1 and state <= 4 then
		npcHandler:say("Farewell.", cid)
		talkState[stateKey] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
