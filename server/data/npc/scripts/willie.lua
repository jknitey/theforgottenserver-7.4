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

	if msgcontains(msg, "banana") or msgcontains(msg, "quest") or msgcontains(msg, "reward") then
		npcHandler:say("Have you found a banana for me?", cid)
		talkState[stateKey] = 1
	elseif msgcontains(msg, "yes") and talkState[stateKey] == 1 and getPlayerItemCount(cid, 2676) >= 1 then
		npcHandler:say("A banana! Great. Take this shield, so the &#@&* monsters don't beat the &@*&@ out of you.", cid)
		doPlayerAddItem(cid, 2526, 1)
		doPlayerRemoveItem(cid, 2676, 1)
		setPlayerStorageValue(cid, 3034, 1)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "yes") and talkState[stateKey] == 1 and getPlayerItemCount(cid, 2676) == 0 then
		npcHandler:say("I'd love to try a banana pie but I lack the bananas. If you get me one, I'll reward you.", cid)
		talkState[stateKey] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
