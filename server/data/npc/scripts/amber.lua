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

	if msgcontains(msg, "book") or msgcontains(msg, "notebook") then
		npcHandler:say("Do you bring me my notebook?", cid)
		talkState[stateKey] = 1
	elseif msgcontains(msg, "yes") and state == 1 and getPlayerItemCount(cid, 1955) >= 1 then
		npcHandler:say("Excellent. Here, take this short sword, that might serve you well.", cid)
		doPlayerAddItem(cid, 2406)
		doPlayerRemoveItem(cid, 1955, 1)
		setPlayerStorageValue(cid, 3028, 1)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "yes") and state == 1 and getPlayerItemCount(cid, 1955) == 0 then
		npcHandler:say("Hm, you don't have it.", cid)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "no") and state == 1 then
		npcHandler:say("Too bad.", cid)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "orcish") or msgcontains(msg, "language") or msgcontains(msg, "prisoner") then
		npcHandler:say("I speak some orcish words, not much though, just 'yes' and 'no' and such basic.", cid)
		talkState[stateKey] = 2
	elseif msgcontains(msg, "yes") and state == 2 then
		npcHandler:say("It's 'mok' in orcish. I help you more about that if you have some food.", cid)
	elseif msgcontains(msg, "no") and state == 2 then
		npcHandler:say("In orcish that's 'burp'. I help you more about that if you have some food.", cid)
	elseif msgcontains(msg, "food") then
		npcHandler:say("My favorite dish is salmon. Oh please, bring me some of it.", cid)
	elseif msgcontains(msg, "salmon") then
		npcHandler:say("Yeah! If you give me some salmon I will tell you more about the orcish language.", cid)
		talkState[stateKey] = 3
	elseif msgcontains(msg, "yes") and state == 3 and getPlayerItemCount(cid, 2668) >= 1 then
		npcHandler:say("Thank you. Orcs call arrows 'pixo'.", cid)
		doPlayerRemoveItem(cid, 2668, 1)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "yes") and state == 3 and getPlayerItemCount(cid, 2668) == 0 then
		npcHandler:say("You don't have one!", cid)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "bye") and state >= 1 and state <= 3 then
		npcHandler:say("See you later.", cid)
		talkState[stateKey] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
