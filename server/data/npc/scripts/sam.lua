dofile("data/npc/lib/_npcsystem.lua")
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local buyItems = {
	['battle hammer'] = {itemid = 2417, cost = 350},
	['brass armor'] = {itemid = 2465, cost = 450},
	['chain armor'] = {itemid = 2464, cost = 200},
	['chain helmet'] = {itemid = 2458, cost = 52},
	['chain legs'] = {itemid = 2648, cost = 80},
	['hand axe'] = {itemid = 2380, cost = 8},
	['leather armor'] = {itemid = 2467, cost = 35},
	['leather helmet'] = {itemid = 2461, cost = 12},
	['steel shield'] = {itemid = 2509, cost = 240},
	['throwing knife'] = {itemid = 2410, cost = 25},
	['throwing knives'] = {itemid = 2410, cost = 25},
	['wooden shield'] = {itemid = 2512, cost = 15},
	['axe'] = {itemid = 2386, cost = 20},
	['dagger'] = {itemid = 2379, cost = 5},
	['mace'] = {itemid = 2398, cost = 90},
	['rapier'] = {itemid = 2384, cost = 15},
	['sabre'] = {itemid = 2385, cost = 35},
	['spear'] = {itemid = 2389, cost = 10},
	['sword'] = {itemid = 2376, cost = 85}
}

local sellItems = {
	['battle axe'] = {itemid = 2378, cost = 80},
	['double axe'] = {itemid = 2387, cost = 260},
	['battle hammer'] = {itemid = 2417, cost = 120},
	['battle shield'] = {itemid = 2513, cost = 95},
	['brass armor'] = {itemid = 2465, cost = 150},
	['brass shield'] = {itemid = 2511, cost = 15},
	['chain armor'] = {itemid = 2464, cost = 70},
	['chain helmet'] = {itemid = 2458, cost = 17},
	['chain legs'] = {itemid = 2648, cost = 25},
	['hand axe'] = {itemid = 2380, cost = 4},
	['leather armor'] = {itemid = 2467, cost = 12},
	['leather helmet'] = {itemid = 2461, cost = 4},
	['morning star'] = {itemid = 2394, cost = 90},
	['plate armor'] = {itemid = 2463, cost = 400},
	['short sword'] = {itemid = 2406, cost = 10},
	['steel helmet'] = {itemid = 2457, cost = 190},
	['steel shield'] = {itemid = 2509, cost = 80},
	['two handed sword'] = {itemid = 2377, cost = 450},
	['wooden shield'] = {itemid = 2512, cost = 5},
	['axe'] = {itemid = 2386, cost = 7},
	['dagger'] = {itemid = 2379, cost = 2},
	['halberd'] = {itemid = 2381, cost = 400},
	['mace'] = {itemid = 2398, cost = 30},
	['rapier'] = {itemid = 2384, cost = 5},
	['sabre'] = {itemid = 2385, cost = 12},
	['spear'] = {itemid = 2389, cost = 3},
	['sword'] = {itemid = 2376, cost = 25}
}

local function parseTradeRequest(message, verb)
	local amount, itemName = message:match('^' .. verb .. '%s+(%d+)%s+(.+)$')
	if amount and itemName then
		return tonumber(amount) or 1, itemName
	end

	itemName = message:match('^' .. verb .. '%s+(.+)$')
	if itemName then
		return 1, itemName
	end

	return nil, nil
end

local function completeDirectBuy(cid, amount, item)
	local totalCost = amount * item.cost
	if doPlayerBuyItem(cid, item.itemid, amount, totalCost) then
		npcHandler:say('Here you are.', cid)
	else
		npcHandler:say('You do not have enough money or capacity.', cid)
	end
	return true
end

local function completeDirectSell(cid, amount, item)
	local totalCost = amount * item.cost
	if doPlayerSellItem(cid, item.itemid, amount, totalCost) then
		npcHandler:say('Here you are.', cid)
	else
		npcHandler:say('You do not have that item.', cid)
	end
	return true
end

local function shouldHandleDirectTrade(message)
	if message == 'trade' or message == 'offer' then
		return true
	end

	local _, buyItemName = parseTradeRequest(message, 'buy')
	if buyItemName and buyItems[buyItemName] then
		return true
	end

	local _, sellItemName = parseTradeRequest(message, 'sell')
	if sellItemName and sellItems[sellItemName] then
		return true
	end

	return false
end

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onThink()						npcHandler:onThink()						end

function onCreatureSay(cid, type, msg)
	local message = msg:lower()
	if shouldHandleDirectTrade(message) then
		if not npcHandler:isFocused(cid) and npcHandler:isInRange(cid) then
			npcHandler:addFocus(cid)
		end

		if not npcHandler:isFocused(cid) then
			return
		end

		if message == 'trade' or message == 'offer' then
			npcHandler:say('Say buy itemname or sell itemname. For example: buy sword or sell battle axe.', cid)
			return
		end

		local buyAmount, buyItemName = parseTradeRequest(message, 'buy')
		local buyItem = buyItemName and buyItems[buyItemName]
		if buyItem then
			completeDirectBuy(cid, buyAmount, buyItem)
			return
		end

		local sellAmount, sellItemName = parseTradeRequest(message, 'sell')
		local sellItem = sellItemName and sellItems[sellItemName]
		if sellItem then
			completeDirectSell(cid, sellAmount, sellItem)
			return
		end
	end

	npcHandler:onCreatureSay(cid, type, msg)
end

function creatureSayCallback(cid, type, msg)
	if(npcHandler.focus ~= cid) then
		return false
	end
	
	-- Inicio Sam by Rodrigo (Nottinghster)
	if msgcontains(msg, 'magic plate armor') then
	npcHandler:say('WOW! Do you really want to sell me a MAGIC plate armor?')
	talk_state = 3
	
	elseif msgcontains(msg, 'yes') and talk_state == 3 then
	npcHandler:say('Oh, unbelievable! I would pay 6400 gold for this wonderful piece of armor. Are you still interested?')
	talk_state = 4
	elseif msgcontains(msg, 'no') and talk_state == 3 then
	npcHandler:say('Hmmm, what a pity! I am looking for such an armor since I live in Thais.')
	talk_state = 0
	
	elseif msgcontains(msg, 'yes') and talk_state == 4 and getPlayerItemCount(cid, 2472) >= 1 then
	npcHandler:say('Finally it is mine! Here is your money. Can I be of any further help?')
	doPlayerAddMoney(cid, 6400)
	doPlayerRemoveItem(cid, 2472, 1)
	talk_state = 0
	elseif msgcontains(msg, 'yes') and talk_state == 4 and getPlayerItemCount(cid, 2472) == 0 then
	npcHandler:say('Argl! You do not have one! Trying to tease me? Get lost or I call the guards!')
	elseif msgcontains(msg, 'no') and talk_state == 4 then
	npcHandler:say('Maybe my offer is too low? Unfortunately I can not bring up more money, I am just a smith.')
	talk_state = 0
	
	elseif msgcontains(msg, 'backpack') or msgcontains(msg, 'old backpack') then
	npcHandler:say('What? Are you telling me you found my old adventurer\'s backpack that I lost years ago??')
	talk_state = 5
	
	elseif msgcontains(msg, 'yes') and talk_state == 5 and getPlayerItemCount(cid, 3960) >= 1 then
	npcHandler:say('Thank you verry much! This brings back good old memories! Please, as a reward, travel to kazordoon and ask my old friend Kroox to provide you a special dwarven armor. ...')
	npcHandler:say('I will mail him about you immediately. Just tell him, his old buddy sam is sending you.')
	setPlayerStorageValue(cid, 289, 1)
	doPlayerRemoveItem(cid, 3960, 1)
	talk_state = 0
	elseif msgcontains(msg, 'yes') and talk_state == 5 and getPlayerItemCount(cid, 3960) == 0 then
	npcHandler:say('No, you don\'t have my old backpack. What a pity.')
	talk_state = 0
	elseif msgcontains(msg, 'no') and talk_state == 5 then
	npcHandler:say('What a pity.')
	talk_state = 0
	end
	return TRUE
	end
	
local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

-- Itens para vender
shopModule:addSellableItem({'battle axe'},2378,80,'battle axe')
shopModule:addSellableItem({'double axe'},2387,260,'double axe')
shopModule:addSellableItem({'battle hammer'},2417,120,'battle hammer')
shopModule:addSellableItem({'battle shield'},2513,95,'battle shield')
shopModule:addSellableItem({'brass armor'},2465,150,'brass armor')
shopModule:addSellableItem({'brass shield'},2511,15,'brass shield')
shopModule:addSellableItem({'chain armor'},2464,70,'chain armor')
shopModule:addSellableItem({'chain helmet'},2458,17,'chain helmet')
shopModule:addSellableItem({'chain legs'},2648,25,'chain legs')
shopModule:addSellableItem({'hand axe'},2380,4,'hand axe')
shopModule:addSellableItem({'leather armor'},2467,12,'leather armor')
shopModule:addSellableItem({'leather helmet'},2461,4,'leather helmet')
shopModule:addSellableItem({'morning star'},2394,90,'morning star')
shopModule:addSellableItem({'plate armor'},2463,400,'plate armor')
shopModule:addSellableItem({'short sword'},2406,10,'short sword')
shopModule:addSellableItem({'steel helmet'},2457,190,'steel helmet')
shopModule:addSellableItem({'steel shield'},2509,80,'steel shield')
shopModule:addSellableItem({'two handed sword'},2377,450,'two handed sword')
shopModule:addSellableItem({'wooden shield'},2512,5,'wooden shield')
shopModule:addSellableItem({'axe'},2386,7,'axe')
shopModule:addSellableItem({'dagger'},2379,2,'dagger')
shopModule:addSellableItem({'halberd'},2381,400,'halberd')
shopModule:addSellableItem({'mace'},2398,30,'mace')
shopModule:addSellableItem({'rapier'},2384,5,'rapier')
shopModule:addSellableItem({'sabre'},2385,12,'sabre')
shopModule:addSellableItem({'spear'},2389,3,'spear')
shopModule:addSellableItem({'sword'},2376,25,'sword')

-- Itens para comprar
shopModule:addBuyableItem({'battle hammer'},2417,350,'battle hammer')
shopModule:addBuyableItem({'brass armor'},2465,450,'brass armor')
shopModule:addBuyableItem({'chain armor'},2464,200,'chain armor')
shopModule:addBuyableItem({'chain helmet'},2458,52,'chain helmet')
shopModule:addBuyableItem({'chain legs'},2648,80,'chain legs')
shopModule:addBuyableItem({'hand axe'},2380,8,'hand axe')
shopModule:addBuyableItem({'leather armor'},2467,35,'leather armor')
shopModule:addBuyableItem({'leather helmet'},2461,12,'leather helmet')
shopModule:addBuyableItem({'steel shield'},2509,240,'steel shield')
shopModule:addBuyableItem({'throwing knife'},2410,25,'throwing knife')
shopModule:addBuyableItem({'wooden shield'},2512,15,'wooden shield')
shopModule:addBuyableItem({'axe'},2386,20,'axe')
shopModule:addBuyableItem({'dagger'},2379,5,'dagger')
shopModule:addBuyableItem({'mace'},2398,90,'mace')
shopModule:addBuyableItem({'rapier'},2384,15,'rapier')
shopModule:addBuyableItem({'sabre'},2385,35,'sabre')
shopModule:addBuyableItem({'spear'},2389,10,'spear')
shopModule:addBuyableItem({'sword'},2376,85,'sword')
	
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
