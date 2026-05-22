dofile("data/npc/lib/_npcsystem.lua")
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, messageType, msg) npcHandler:onCreatureSay(cid, messageType, msg) end
function onThink() npcHandler:onThink() end
function onPlayerEndTrade(cid) npcHandler:onPlayerEndTrade(cid) end
function onPlayerCloseChannel(cid) npcHandler:onPlayerCloseChannel(cid) end

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

shopModule:addBuyableItem({"meat"}, 2666, 10, 1)
shopModule:addBuyableItem({"ham"}, 2671, 15, 1)
shopModule:addBuyableItem({"dragon ham"}, 2672, 25, 1)
shopModule:addBuyableItem({"brown mushroom"}, 2789, 10, 1)

npcHandler:addModule(FocusModule:new())
