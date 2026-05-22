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

	if msgcontains(msg, "gamel rebel") or msgcontains(msg, "gamel is rebel") or msgcontains(msg, "gamel is a rebel") then
		npcHandler:say("Are you saying that Gamel is a member of the rebellion?", cid)
		talkState[stateKey] = 1
	elseif msgcontains(msg, "yes") and state == 1 then
		npcHandler:say("Do you know what his plans are about?", cid)
		talkState[stateKey] = 2
	elseif msgcontains(msg, "no") and state == 1 then
		npcHandler:say("Then don't bother me with that. I am a busy man.", cid)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "magic crystal") and state == 2 then
		npcHandler:say("That is terrible! Will you give me the crystal?", cid)
		talkState[stateKey] = 3
	elseif msgcontains(msg, "yes") and state == 3 and getPlayerItemCount(cid, 2177) >= 1 then
		npcHandler:say("Thank you! Take this ring. If you ever need a healing, come, bring the scroll, and ask me to 'heal'.", cid)
		doPlayerRemoveItem(cid, 2177, 1)
		doPlayerAddItem(cid, 2168, 1)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "yes") and state == 3 and getPlayerItemCount(cid, 2177) == 0 then
		npcHandler:say("Sorry, you have none.", cid)
	elseif msgcontains(msg, "no") and state == 3 then
		npcHandler:say("Traitor!", cid)
		talkState[stateKey] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
