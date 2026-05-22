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

	if msgcontains(msg, "magic plate armor") then
		npcHandler:say("WOW! Do you really want to sell me a MAGIC plate armor?", cid)
		talkState[stateKey] = 3
	elseif msgcontains(msg, "yes") and state == 3 then
		npcHandler:say("Oh, unbelievable! I would pay 6400 gold for this wonderful piece of armor. Are you still interested?", cid)
		talkState[stateKey] = 4
	elseif msgcontains(msg, "no") and state == 3 then
		npcHandler:say("Hmmm, what a pity! I am looking for such an armor since I live in Thais.", cid)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "yes") and state == 4 and getPlayerItemCount(cid, 2472) >= 1 then
		npcHandler:say("Finally it is mine! Here is your money. Can I be of any further help?", cid)
		doPlayerAddMoney(cid, 6400)
		doPlayerRemoveItem(cid, 2472, 1)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "yes") and state == 4 and getPlayerItemCount(cid, 2472) == 0 then
		npcHandler:say("Argl! You do not have one! Trying to tease me? Get lost or I call the guards!", cid)
	elseif msgcontains(msg, "no") and state == 4 then
		npcHandler:say("Maybe my offer is too low? Unfortunately I can not bring up more money, I am just a smith.", cid)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "backpack") or msgcontains(msg, "old backpack") then
		npcHandler:say("What? Are you telling me you found my old adventurer's backpack that I lost years ago??", cid)
		talkState[stateKey] = 5
	elseif msgcontains(msg, "yes") and state == 5 and getPlayerItemCount(cid, 3960) >= 1 then
		npcHandler:say("Thank you verry much! This brings back good old memories! Please, as a reward, travel to kazordoon and ask my old friend Kroox to provide you a special dwarven armor. ...", cid)
		npcHandler:say("I will mail him about you immediately. Just tell him, his old buddy sam is sending you.", cid)
		setPlayerStorageValue(cid, 289, 1)
		doPlayerRemoveItem(cid, 3960, 1)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "yes") and state == 5 and getPlayerItemCount(cid, 3960) == 0 then
		npcHandler:say("No, you don't have my old backpack. What a pity.", cid)
		talkState[stateKey] = 0
	elseif msgcontains(msg, "no") and state == 5 then
		npcHandler:say("What a pity.", cid)
		talkState[stateKey] = 0
	end

	return true
end

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)
shopModule:addBuyableItem({"lyre"}, 2071, 120, "lyre")
shopModule:addBuyableItem({"lute"}, 2072, 195, "lute")
shopModule:addBuyableItem({"drum"}, 2073, 140, "drum")
shopModule:addBuyableItem({"simple fanfare"}, 2075, 150, "fanfare")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
