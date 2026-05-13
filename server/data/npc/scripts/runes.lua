dofile("data/npc/lib/_npcsystem.lua")
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}
local pendingPurchase = {}

local FLUID_MANA = 7
local FLUID_LIFE = 10

local function giveFluidBackpack(cid, fluidType)
	local backpack = doPlayerAddItem(cid, 2000, 1)
	if not backpack then
		return false
	end

	for _ = 1, 20 do
		doAddContainerItem(backpack, 2006, fluidType)
	end
	return true
end

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) 			end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) 		end
function onThink() 							npcHandler:onThink() 						end
function onPlayerEndTrade(cid)				npcHandler:onPlayerEndTrade(cid)			end
function onPlayerCloseChannel(cid)			npcHandler:onPlayerCloseChannel(cid)		end

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

shopModule:addBuyableItem({'spellbook'}, 2175, 150,'spellbook')
shopModule:addBuyableItem({'magic lightwand'}, 2163, 400, 'magic lightwand')
shopModule:addBuyableItem({'mana fluid', 'manafluid'}, 2006, 5, 7, 'mana fluid')
shopModule:addBuyableItem({'life fluid', 'lifefluid'}, 2006, 50, 10, 'life fluid')
shopModule:addBuyableItemContainer({'bp mf'}, 2000, 2006, 100, 7, 'backpack of mana fluids')
shopModule:addBuyableItemContainer({'bp lf'}, 2000, 2006, 1000, 10, 'backpack of life fluids')

shopModule:addBuyableItem({'amulet of loss', 'aol'}, 2173, 50000, 'amulet of loss')

shopModule:addBuyableItem({'animate dead'}, 2316, 375, 1, 'animate dead rune')
shopModule:addBuyableItem({'blank rune'}, 2260, 10, 1, 'blank rune')
shopModule:addBuyableItem({'desintegrate'}, 2310, 26, 1, 'desintegrate rune')
shopModule:addBuyableItem({'energy bomb'}, 2262, 162, 1, 'energy bomb rune')
shopModule:addBuyableItem({'fireball'}, 2302, 30, 1, 'fireball rune')
shopModule:addBuyableItem({'holy missile'}, 2295, 16, 1, 'holy missile rune')
shopModule:addBuyableItem({'icicle'}, 2271, 30, 1, 'icicle rune')
shopModule:addBuyableItem({'magic wall'}, 2293, 116, 1, 'magic wall rune')
shopModule:addBuyableItemContainer({'bp mwall'}, 2000, 2293, 2500, 1, 'backpack of magic wall rune')
shopModule:addBuyableItem({'paralyze'}, 2278, 700, 1, 'paralyze rune')
shopModule:addBuyableItem({'poison bomb'}, 2286, 85, 1, 'poison bomb rune')
shopModule:addBuyableItem({'soulfire'}, 2308, 46, 1, 'soulfire rune')
shopModule:addBuyableItem({'stone shower'}, 2288, 37, 1, 'stone shower rune')
shopModule:addBuyableItem({'thunderstorm'}, 2315, 37, 1, 'thunderstorm rune')
shopModule:addBuyableItem({'wild growth'}, 2269, 160, 1, 'wild growth rune')

shopModule:addBuyableItem({'avalanche'}, 2274, 45, 1, 'avalanche rune')
shopModule:addBuyableItem({'antidote'}, 2266, 65, 1, 'antidote rune')
shopModule:addBuyableItem({'chameleon'}, 2291, 210, 1, 'chameleon rune')
shopModule:addBuyableItem({'convince creature'}, 2290, 80, 1, 'convince creature rune')
shopModule:addBuyableItem({'destroy field'}, 2261, 15, 1, 'destroy field rune')
shopModule:addBuyableItem({'energy field'}, 2277, 38, 1, 'energy field rune')
shopModule:addBuyableItem({'energy wall'}, 2279, 85, 1, 'energy wall rune')
shopModule:addBuyableItem({'explosion rune'}, 2313, 31, 1, 'explosion rune')
shopModule:addBuyableItemContainer({'bp explosion'}, 2000, 2313, 1500, 1, 'backpack of explosion rune')
shopModule:addBuyableItem({'fire bomb'}, 2305, 117, 1, 'fire bomb rune')
shopModule:addBuyableItem({'fire field'}, 2301, 28, 1, 'fire field rune')
shopModule:addBuyableItem({'fire wall'}, 2303, 61, 1, 'fire wall rune')
shopModule:addBuyableItem({'great fireball'}, 2304, 45, 1, 'great fireball rune')
shopModule:addBuyableItem({'heavy magic missile'}, 2311, 12, 1, 'heavy magic missile rune')
shopModule:addBuyableItemContainer({'bp hmm'}, 2000, 2311, 150, 1, 'backpack of sudden heavy magic missile rune')
shopModule:addBuyableItem({'intense healing'}, 2265, 95, 1, 'intense healing rune')
shopModule:addBuyableItem({'light magic missile'}, 2287, 4, 1, 'light magic missile rune')
shopModule:addBuyableItemContainer({'bp lmm'}, 2000, 2287, 100, 1, 'backpack of light magic missile rune')
shopModule:addBuyableItem({'poison field'}, 2285, 21, 1, 'poison field rune')
shopModule:addBuyableItem({'poison wall'}, 2289, 52, 1, 'poison wall rune')
shopModule:addBuyableItem({'stalagmite'}, 2292, 12, 1, 'stalagmite rune')
shopModule:addBuyableItem({'sudden death'}, 2268, 108, 1, 'sudden death rune')
shopModule:addBuyableItemContainer({'bp sd'}, 2000, 2268, 2200, 1, 'backpack of sudden death rune')
shopModule:addBuyableItem({'ultimate healing'}, 2273, 175, 1, 'ultimate healing rune')
shopModule:addBuyableItemContainer({'bp uh'}, 2000, 2273, 2200, 1, 'backpack of ultimate healing rune')
shopModule:addBuyableItemContainer({'bp gfb'}, 2000, 2304, 1700, 1, 'backpack of adori mas flam rune')


shopModule:addBuyableItem({'wand of vortex', 'vortex'}, 2190, 500, 'wand of vortex')
shopModule:addBuyableItem({'wand of dragonbreath', 'dragonbreath'}, 2191, 1000, 'wand of dragonbreath')
shopModule:addBuyableItem({'wand of plague', 'plague'}, 2188, 5000, 'wand of plague')
shopModule:addBuyableItem({'wand of cosmic energy', 'cosmic energy'}, 2189, 10000, 'wand of cosmic energy')
shopModule:addBuyableItem({'wand of inferno', 'inferno'}, 2187, 15000, 'wand of inferno')

shopModule:addBuyableItem({'snakebite rod', 'snakebite'}, 2182, 500, 'snakebite rod')
shopModule:addBuyableItem({'moonlight rod', 'moonlight'}, 2186, 1000, 'moonlight rod')
shopModule:addBuyableItem({'volcanic rod', 'volcanic'}, 2185, 5000, 'volcanic rod')
shopModule:addBuyableItem({'quagmire rod', 'quagmire'}, 2181, 10000, 'quagmire rod')
shopModule:addBuyableItem({'tempest rod', 'tempest'}, 2183, 15000, 'tempest rod')

shopModule:addSellableItem({'vial', 'flask'}, 2006, 25, 'vial')

shopModule:addSellableItem({'wand of vortex', 'vortex'}, 2190, 100, 'wand of vortex')
shopModule:addSellableItem({'wand of dragonbreath', 'dragonbreath'}, 2191, 200, 'wand of dragonbreath')
shopModule:addSellableItem({'wand of plague', 'plague'}, 2188, 1000, 'wand of plague')
shopModule:addSellableItem({'wand of cosmic energy', 'cosmic energy'}, 2189, 2000, 'wand of cosmic energy')
shopModule:addSellableItem({'wand of inferno', 'inferno'}, 2187, 3000, 'wand of inferno')

shopModule:addSellableItem({'snakebite rod', 'snakebite'}, 2182, 100, 'snakebite rod')
shopModule:addSellableItem({'moonlight rod', 'moonlight'}, 2186, 200, 'moonlight rod')
shopModule:addSellableItem({'volcanic rod', 'volcanic'}, 2185, 1000, 'volcanic rod')
shopModule:addSellableItem({'quagmire rod', 'quagmire'}, 2181, 2000, 'quagmire rod')
shopModule:addSellableItem({'tempest rod', 'tempest'}, 2183, 3000, 'tempest rod')

local items = {[1] = 2190, [2] = 2182, [5] = 2190, [6] = 2182}

local function getFluidPurchaseRequest(message)
	local amount, itemName = message:match('^buy%s+(%d+)%s+(.+)$')
	if amount and itemName then
		amount = tonumber(amount) or 1
		if itemName == 'mana fluid' or itemName == 'manafluid' then
			return 'mana_fluid', amount
		elseif itemName == 'life fluid' or itemName == 'lifefluid' then
			return 'life_fluid', amount
		end
	end

	if message == 'buy mana fluid' or message == 'buy manafluid' then
		return 'mana_fluid', 1
	elseif message == 'buy life fluid' or message == 'buy lifefluid' then
		return 'life_fluid', 1
	elseif message == 'buy bp mf' or message == 'buy backpack of mana fluid' or message == 'buy backpack of mana fluids' then
		return 'bp_mf', 1
	elseif message == 'buy bp lf' or message == 'buy backpack of life fluid' or message == 'buy backpack of life fluids' then
		return 'bp_lf', 1
	end

	return nil, nil
end

local function getVialSellRequest(message)
	local amount, itemName = message:match('^sell%s+(%d+)%s+(.+)$')
	if amount and itemName then
		amount = tonumber(amount) or 1
		if itemName == 'vial' or itemName == 'vials' or itemName == 'flask' or itemName == 'flasks' then
			return amount
		end
	end

	if message == 'sell vial' or message == 'sell vials' or message == 'sell flask' or message == 'sell flasks' then
		return 1
	end

	return nil
end

local function isDirectShopMessage(message)
	if message == 'trade' then
		return true
	end

	local purchaseType = getFluidPurchaseRequest(message)
	if purchaseType ~= nil then
		return true
	end

	return getVialSellRequest(message) ~= nil
end

local function completeFluidPurchase(cid, purchaseKind, amount)
	if purchaseKind == 'mana_fluid' then
		local totalCost = amount * 5
		if doPlayerBuyItem(cid, 2006, amount, totalCost, FLUID_MANA) then
			selfSay('Here you are.', cid)
		else
			selfSay('You do not have enough money or capacity.', cid)
		end
		return true
	elseif purchaseKind == 'life_fluid' then
		local totalCost = amount * 50
		if doPlayerBuyItem(cid, 2006, amount, totalCost, FLUID_LIFE) then
			selfSay('Here you are.', cid)
		else
			selfSay('You do not have enough money or capacity.', cid)
		end
		return true
	elseif purchaseKind == 'bp_mf' then
		if not doPlayerRemoveMoney(cid, 100) then
			selfSay('You do not have enough money.', cid)
			return true
		end
		if not giveFluidBackpack(cid, FLUID_MANA) then
			doPlayerAddMoney(cid, 100)
			selfSay('You do not have enough capacity.', cid)
			return true
		end
		selfSay('Here you are.', cid)
		return true
	elseif purchaseKind == 'bp_lf' then
		if not doPlayerRemoveMoney(cid, 1000) then
			selfSay('You do not have enough money.', cid)
			return true
		end
		if not giveFluidBackpack(cid, FLUID_LIFE) then
			doPlayerAddMoney(cid, 1000)
			selfSay('You do not have enough capacity.', cid)
			return true
		end
		selfSay('Here you are.', cid)
		return true
	end

	return false
end

local function completeVialSale(cid, amount)
	local totalValue = amount * 25
	if doPlayerSellItem(cid, 2006, amount, totalValue) then
		selfSay('Here you are.', cid)
	else
		selfSay('You do not have enough vials.', cid)
	end
	return true
end

local function shouldHandleDirectly(cid, msg)
	local message = msg:lower()
	if isDirectShopMessage(message) then
		return true
	end

	local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid
	if (message == 'yes' or message == 'no') and (talkState[talkUser] == 1 or talkState[talkUser] == 2 or pendingPurchase[talkUser] ~= nil) then
		return true
	end

	if not npcHandler:isFocused(cid) then
		return false
	end

	return msgcontains(msg, 'first rod') or msgcontains(msg, 'first wand')
end

function onCreatureSay(cid, type, msg)
	if shouldHandleDirectly(cid, msg) then
		local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid
		if not npcHandler:isFocused(cid) and npcHandler:isInRange(cid) and (isDirectShopMessage(msg:lower()) or pendingPurchase[talkUser] ~= nil or talkState[talkUser] ~= nil) then
			npcHandler:addFocus(cid)
		end
		creatureSayCallback(cid, type, msg)
		return
	end

	npcHandler:onCreatureSay(cid, type, msg)
end

function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid
	local message = msg:lower()
	local purchaseType, purchaseAmount = getFluidPurchaseRequest(message)
	local sellVialAmount = getVialSellRequest(message)

	if message == 'trade' then
		selfSay('The trade window is unavailable right now. Say buy mana fluid, buy life fluid, buy bp mf, buy bp lf, or sell vial.', cid)
		return true
	elseif purchaseType == 'mana_fluid' then
		return completeFluidPurchase(cid, purchaseType, purchaseAmount)
	elseif purchaseType == 'life_fluid' then
		return completeFluidPurchase(cid, purchaseType, purchaseAmount)
	elseif sellVialAmount then
		return completeVialSale(cid, sellVialAmount)
	elseif purchaseType == 'bp_mf' then
		selfSay('Do you want to buy a backpack of mana fluids for 100 gold coins?', cid)
		talkState[talkUser] = 2
		pendingPurchase[talkUser] = {type = purchaseType, amount = 1}
		return true
	elseif purchaseType == 'bp_lf' then
		selfSay('Do you want to buy a backpack of life fluids for 1000 gold coins?', cid)
		talkState[talkUser] = 2
		pendingPurchase[talkUser] = {type = purchaseType, amount = 1}
		return true
	elseif message == 'yes' and talkState[talkUser] == 2 then
		local purchase = pendingPurchase[talkUser]
		talkState[talkUser] = 0
		pendingPurchase[talkUser] = nil
		if not purchase then
			return true
		end

		local purchaseKind = type(purchase) == 'table' and purchase.type or purchase
		local amount = type(purchase) == 'table' and purchase.amount or 1

		return completeFluidPurchase(cid, purchaseKind, amount)
	elseif message == 'no' and talkState[talkUser] == 2 then
		selfSay('Ok then.', cid)
		talkState[talkUser] = 0
		pendingPurchase[talkUser] = nil
		return true
	end

	if(msgcontains(msg, 'first rod') or msgcontains(msg, 'first wand')) then
		if(isSorcerer(cid) or isDruid(cid)) then
			if(getPlayerStorageValue(cid, 50111) <= 0) then
				selfSay('So you ask me for a ' .. getItemNameById(items[getPlayerVocation(cid)]) .. ' to begin your advanture?', cid)
				talkState[talkUser] = 1
			else
				selfSay('What? I have already gave you one ' .. getItemNameById(items[getPlayerVocation(cid)]) .. '!', cid)
			end
		else
			selfSay('Sorry, you aren\'t a druid either a sorcerer.', cid)
		end
	elseif(msgcontains(msg, 'yes')) then
		if(talkState[talkUser] == 1) then
			doPlayerAddItem(cid, items[getPlayerVocation(cid)], 1)
			selfSay('Here you are young adept, take care yourself.', cid)
			setPlayerStorageValue(cid, 50111, 1)
		end
		talkState[talkUser] = 0
	elseif(msgcontains(msg, 'no') and isInArray({1}, talkState[talkUser])) then
		selfSay('Ok then.', cid)
		talkState[talkUser] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
