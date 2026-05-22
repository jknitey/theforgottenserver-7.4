dofile("data/npc/lib/_npcsystem.lua")
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end
function onPlayerEndTrade(cid) npcHandler:onPlayerEndTrade(cid) end
function onPlayerCloseChannel(cid) npcHandler:onPlayerCloseChannel(cid) end

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

shopModule:addBuyableItem({"oil"}, 2006, 20, 11, "oil")
shopModule:addBuyableItem({"blood"}, 2006, 15, 2, "blood")
shopModule:addBuyableItem({"urine"}, 2006, 10, 13, "urine")
shopModule:addBuyableItem({"slime"}, 2006, 12, 12, "slime")
shopModule:addBuyableItem({"water"}, 2006, 8, 1, "water")
shopModule:addBuyableItemContainer({"bp mf", "bp of mf", "bp manafluid", "bp of manafluid", "bp of mana fluid", "backpack of mana fluid", "backpack of mana fluids"}, 2000, 2006, 100, 7, "backpack of mana fluids", 20)
shopModule:addBuyableItemContainer({"bp lf", "bp of lf", "bp lifefluid", "bp of lifefluid", "bp of life fluid", "backpack of life fluid", "backpack of life fluids"}, 2000, 2006, 100, 10, "backpack of life fluids", 20)
shopModule:addBuyableItem({"mana fluid", "manafluid", "mf"}, 2006, 5, 7, "mana fluid")
shopModule:addBuyableItem({"life fluid", "lifefluid", "lf"}, 2006, 5, 10, "life fluid")
shopModule:addSellableItem({"vial", "flask", "mana fluid", "manafluid", "life fluid", "lifefluid"}, 2006, 2, "vial")

npcHandler:addModule(FocusModule:new())
