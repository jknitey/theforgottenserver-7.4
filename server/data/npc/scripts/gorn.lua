dofile("data/npc/lib/_npcsystem.lua")
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local buyItems = {
	['book'] = {itemid = 1971, cost = 15},
	['backpack'] = {itemid = 1988, cost = 20},
	['bag'] = {itemid = 1987, cost = 5},
	['document'] = {itemid = 1968, cost = 12},
	['fishing rod'] = {itemid = 2580, cost = 150},
	['machete'] = {itemid = 2420, cost = 40},
	['parchment'] = {itemid = 1969, cost = 8},
	['pick'] = {itemid = 2553, cost = 50},
	['plate'] = {itemid = 2035, cost = 6},
	['present'] = {itemid = 1990, cost = 10},
	['rope'] = {itemid = 2120, cost = 50},
	['scroll'] = {itemid = 1949, cost = 5},
	['scythe'] = {itemid = 2550, cost = 50},
	['shovel'] = {itemid = 2554, cost = 50},
	['torch'] = {itemid = 2050, cost = 2},
	['torches'] = {itemid = 2050, cost = 2},
	['worm'] = {itemid = 3976, cost = 1},
	['worms'] = {itemid = 3976, cost = 1}
}

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) 			end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) 		end
function onThink() 							npcHandler:onThink() 						end
function onPlayerEndTrade(cid)				npcHandler:onPlayerEndTrade(cid)			end
function onPlayerCloseChannel(cid)			npcHandler:onPlayerCloseChannel(cid)		end

local function parseBuyRequest(message)
	local amount, itemName = message:match('^buy%s+(%d+)%s+(.+)$')
	if amount and itemName then
		return tonumber(amount) or 1, itemName
	end

	itemName = message:match('^buy%s+(.+)$')
	if itemName then
		return 1, itemName
	end

	return nil, nil
end

local function isDirectTradeMessage(message)
	if message == 'trade' or message == 'offer' then
		return true
	end

	local _, itemName = parseBuyRequest(message)
	return itemName ~= nil and buyItems[itemName] ~= nil
end

function onCreatureSay(cid, type, msg)
	local message = msg:lower()
	if isDirectTradeMessage(message) then
		if not npcHandler:isFocused(cid) and npcHandler:isInRange(cid) then
			npcHandler:addFocus(cid)
		end

		if not npcHandler:isFocused(cid) then
			return
		end

		if message == 'trade' or message == 'offer' then
			npcHandler:say('Say buy itemname. For example: buy backpack or buy 3 torches.', cid)
			return
		end

		local amount, itemName = parseBuyRequest(message)
		local item = itemName and buyItems[itemName]
		if item then
			if doPlayerBuyItem(cid, item.itemid, amount, amount * item.cost) then
				npcHandler:say('Here you are.', cid)
			else
				npcHandler:say('You do not have enough money or capacity.', cid)
			end
			return
		end
	end

	npcHandler:onCreatureSay(cid, type, msg)
end

npcHandler:addModule(FocusModule:new())
