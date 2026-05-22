dofile("data/npc/lib/_npcsystem.lua")
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, messageType, msg) npcHandler:onCreatureSay(cid, messageType, msg) end
function onThink() npcHandler:onThink() end

function creatureSayCallback(cid, messageType, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	return true
end

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

shopModule:addBuyableItem({"cheese"}, 2696, 5, "cheese")
shopModule:addBuyableItem({"cherry"}, 2679, 1, "cherry")
shopModule:addBuyableItem({"melon"}, 2682, 8, "melon")
shopModule:addBuyableItem({"pumpkin"}, 2683, 10, "pumpkin")

shopModule:addSellableItem({"bread"}, 2689, 2, "bread")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
