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
	local playerGold = getPlayerItemCount(cid, 2148)
	local playerPlat = getPlayerItemCount(cid, 2152) * 100
	local playerCrys = getPlayerItemCount(cid, 2160) * 10000
	local playerMoney = playerGold + playerPlat + playerCrys

	if msgcontains(msg, "dungeon") and getPlayerLevel(cid) < 3 then
		npcHandler:say("There are some dungeons on this isle, but almost all of them are too dangerous for you at the moment.", cid)
	elseif msgcontains(msg, "dungeon") and getPlayerLevel(cid) > 2 then
		npcHandler:say("There are some dungeons on this isle. You should be strong enough to explore them now, but make sure to take a rope with you.", cid)
	elseif (msgcontains(msg, "mission") or msgcontains(msg, "quest")) and getPlayerLevel(cid) < 4 then
		npcHandler:say("You are pretty inexperienced. I think killing rats is a suitable challenge for you. For each fresh rat I will give you two shiny coins of gold.", cid)
	elseif (msgcontains(msg, "mission") or msgcontains(msg, "quest")) and getPlayerLevel(cid) > 3 then
		npcHandler:say("Well I would like to send our king a little present, but I do not have a suitable box. If you find a nice box, please bring it to me.", cid)
	elseif msgcontains(msg, "key") then
		npcHandler:say("Do you want to buy the Key to Adventure for 5 gold coins?", cid)
		talkState[stateKey] = 1
	elseif msgcontains(msg, "yes") and state == 1 and playerMoney >= 5 then
		npcHandler:say("Here you are.", cid)
		doPlayerRemoveMoney(cid, 5)
		local key = doPlayerAddItem(cid, 2088, 1)
		doSetItemActionId(key, 4600)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "yes") and state == 1 and playerMoney < 5 then
		npcHandler:say("You don't have enough money.", cid)
	elseif msgcontains(msg, "no") and state == 1 then
		npcHandler:say("As you wish.", cid)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "box") then
		npcHandler:say("Do you have a suitable present box for me?", cid)
		talkState[stateKey] = 2
	elseif msgcontains(msg, "yes") and state == 2 and getPlayerItemCount(cid, 1990) >= 1 then
		npcHandler:say("THANK YOU! Here is a helmet that will serve you well.", cid)
		doPlayerRemoveItem(cid, 1990, 1)
		doPlayerAddItem(cid, 2480, 1)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "yes") and state == 2 and getPlayerItemCount(cid, 1990) == 0 then
		npcHandler:say("HEY! You don't have one! Stop playing tricks on fooling me or I will give you some extra work!", cid)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "bye") and state >= 1 and state <= 2 then
		npcHandler:say("See you later.", cid)
		talkState[stateKey] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
