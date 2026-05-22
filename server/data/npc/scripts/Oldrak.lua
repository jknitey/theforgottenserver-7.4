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

	if msgcontains(msg, "hugo") then
		npcHandler:say("Ah, the bane of the Plains of Havoc, the hidden beast, the unbeatable foe. I live here for years and I am sure it's only a myth.", cid)
		talkState[stateKey] = 1
	elseif msgcontains(msg, "myth") and state == 1 then
		npcHandler:say("There are many tales about the fearsome Hugo. It's said it is an abomination, accidentally created by Yenny the Gentle. It's halve demon, halve something else and people say it's still alive after dozens of years.", cid)
		talkState[stateKey] = 2
	elseif msgcontains(msg, "yenny the gentle") and state == 2 then
		npcHandler:say("Yenny, known as the Gentle, was one of most powerfull magicwielders in ancient times and known throughout the world for her mercy and kindness.", cid)
		setPlayerStorageValue(cid, 6664, 1)
		talkState[stateKey] = 3
	elseif msgcontains(msg, "no") and state >= 1 and state <= 3 then
		npcHandler:say("Good Bye. " .. getPlayerName(cid) .. "!", cid)
		talkState[stateKey] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
