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

	return true
end

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

shopModule:addSellableItem({"empty", "vial", "mana fluid", "manafluid", "life fluid", "lifefluid"}, 2006, 2, "vial")
shopModule:addBuyableItem({"spellbook"}, 2175, 150, "spellbook")
shopModule:addBuyableItem({"life fluid", "lifefluid"}, 2006, 5, 10, "life fluid")
shopModule:addBuyableItem({"mana fluid", "manafluid"}, 2006, 5, 7, "mana fluid")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
