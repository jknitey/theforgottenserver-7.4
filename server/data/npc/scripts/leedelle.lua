dofile("data/npc/lib/_npcsystem.lua")
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	if msgcontains(msg, "mission") or msgcontains(msg, "quest") or msgcontains(msg, "reward") then
		npcHandler:say("I really love flowers. Sadly my favourites, honey flowers are very rare on this isle. If you can find me one, I'll give you a little reward.", cid)
	elseif msgcontains(msg, "honey flower") and getPlayerItemCount(cid, 2103) >= 1 then
		npcHandler:say("Oh, thank you so much! Please take this piece of armor as reward.", cid)
		doPlayerAddItem(cid, 2468, 1)
		doPlayerRemoveItem(cid, 2103, 1)
		setPlayerStorageValue(cid, 3030, 1)
	elseif msgcontains(msg, "honey flower") then
		npcHandler:say("Honey flowers are my favourites <sigh>.", cid)
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
