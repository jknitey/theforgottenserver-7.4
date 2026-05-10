if NpcSystem == nil then
	dofile("data/npc/lib/_npcsystem.lua")
end

if getItemInfo == nil then
	function getItemInfo(itemId)
		local itemType = ItemType(itemId)
		if itemType == nil or itemType:getId() == 0 then
			return false
		end

		return {
			itemid = itemType:getId(),
			name = itemType:getName(),
			plural = itemType:getPluralName(),
			article = itemType:getArticle(),
			description = itemType:getDescription(),
			weight = itemType:getWeight(1) / 100,
			slotPosition = itemType:getSlotPosition(),
			charges = itemType:getCharges(),
			fluidSource = itemType:getFluidSource(),
			capacity = itemType:getCapacity(),
			stackable = itemType:isStackable(),
			readable = itemType:isReadable(),
			writable = itemType:isWritable(),
			rune = itemType:isRune(),
			movable = itemType:isMovable(),
			door = itemType:isDoor(),
			container = itemType:isContainer(),
			fluidContainer = itemType:isFluidContainer(),
			corpse = itemType:isCorpse(),
		}
	end
end

if getNpcId == nil and getNpcCid ~= nil then
	getNpcId = getNpcCid
end

if errors == nil then
	function errors(...)
		return
	end
end

if isValidPosition == nil then
	function isValidPosition(position)
		return type(position) == "table" and
			type(position.x) == "number" and position.x > 0 and
			type(position.y) == "number" and position.y > 0 and
			type(position.z) == "number" and position.z >= 0
	end
end

function selfSayChannel(cid, message)
	return selfSay(message, cid, false)
end

function selfMoveToThing(id)
	local t = getThingPosition(id)
	selfMoveTo(t.x, t.y, t.z)
	return
end

function selfMoveTo(x, y, z)
	local position = {x = 0, y = 0, z = 0}
	if(type(x) ~= "table") then
		position = Position(x, y, z)
	else
		position = x
	end

	if(isValidPosition(position)) then
		doSteerCreature(getNpcId(), position)
	end
end

function selfMove(direction, flags)
	local flags = flags or 0
	doMoveCreature(getNpcId(), direction, flags)
end

function selfTurn(direction)
	doCreatureSetLookDirection(getNpcId(), direction)
end

function getNpcDistanceTo(id)
	local c = getCreaturePosition(id)
	if(not isValidPosition(c)) then
		return nil
	end

	local s = getCreaturePosition(getNpcId())
	if(not isValidPosition(s) or s.z ~= c.z) then
		return nil
	end

	return math.max(math.abs(s.x - c.x), math.abs(s.y - c.y))
end

function doMessageCheck(message, keyword, exact)
	local exact = exact or false
	if(type(keyword) == "table") then
		return isInArray(keyword, message, exact)
	end

	if(exact) then
		return message == keyword
	end

	local a, b = message:lower(), keyword:lower()
	return a == b or (a:find(b) and not a:find('(%w+)' .. b))
end

function doNpcSellItem(cid, itemid, amount, subType, ignoreCap, inBackpacks, backpack)
	local amount, subType, ignoreCap, inBackpacks, backpack  = amount or 1, subType or 0, ignoreCap or false, inBackpacks or false, backpack or 1988

	local exhaustionNPC = getBooleanFromString(getConfigValue('exhaustionNPC'))
	if(exhaustionNPC) then
		local exhaustionInSeconds = getConfigValue('exhaustionInSecondsNPC')
		local storage = 45814
		if(exhaustion.check(cid, storage) == true) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You cant buy it so fast.")
			return false
		end
		exhaustion.set(cid, storage, exhaustionInSeconds)
	end

	local item, a = nil, 0
	if(inBackpacks) then
		local custom, stackable = 1, isItemStackable(itemid)
		if(stackable) then
			custom = math.max(1, subType)
			subType = amount
			amount = math.max(1, math.floor(amount / 100))
		end

		local container, b = doCreateItemEx(backpack, 1), 1
		for i = 1, amount * custom do
			item = doAddContainerItem(container, itemid, subType)
			if(itemid == ITEM_PARCEL) then
				doAddContainerItem(item, ITEM_LABEL)
			end

			if(isInArray({(getContainerCapById(backpack) * b), amount}, i)) then
				if(doPlayerAddItemEx(cid, container, ignoreCap) ~= RETURNVALUE_NOERROR) then
					b = b - 1
					break
				end

				a = i
				if(amount > i) then
					container = doCreateItemEx(backpack, 1)
					b = b + 1
				end
			end
		end

		if(not stackable) then
			return a, b
		end

		return (a * subType / custom), b
	end

	if(isItemStackable(itemid)) then
		a = amount * math.max(1, subType)
		repeat
			local tmp = math.min(100, a)
			item = doCreateItemEx(itemid, tmp)
			if(doPlayerAddItemEx(cid, item, ignoreCap) ~= RETURNVALUE_NOERROR) then
				return 0, 0
			end

			a = a - tmp
		until a == 0
		return amount, 0
	end

	for i = 1, amount do
		item = doCreateItemEx(itemid, subType)
		if(itemid == ITEM_PARCEL) then
			doAddContainerItem(item, ITEM_LABEL)
		end

		if(doPlayerAddItemEx(cid, item, ignoreCap) ~= RETURNVALUE_NOERROR) then
			break
		end

		a = i
	end

	return a, 0
end

if doPlayerBuyItem == nil then
	function doPlayerBuyItem(cid, itemid, amount, cost, subType, ignoreCap)
		local amount = amount or 1
		local cost = cost or 0
		local subType = subType or 0

		if getPlayerMoney(cid) < cost then
			return false
		end

		local addedAmount = doNpcSellItem(cid, itemid, amount, subType, ignoreCap or false, false)
		if addedAmount ~= amount then
			local itemInfo = getItemInfo(itemid)
			if itemInfo then
				local removeSubType = subType
				if itemInfo.stackable or removeSubType < 1 then
					removeSubType = -1
				end

				if addedAmount and addedAmount > 0 then
					doPlayerRemoveItem(cid, itemid, addedAmount, removeSubType, true)
				end
			end
			return false
		end

		return doPlayerRemoveMoney(cid, cost)
	end
end

if doPlayerSellItem == nil then
	function doPlayerSellItem(cid, itemid, amount, cost, subType, ignoreEquipped)
		local amount = amount or 1
		local cost = cost or 0
		local itemInfo = getItemInfo(itemid)
		if not itemInfo then
			return false
		end

		local removeSubType = subType or 0
		if itemInfo.stackable or removeSubType < 1 then
			removeSubType = -1
		end

		if not doPlayerRemoveItem(cid, itemid, amount, removeSubType, ignoreEquipped) then
			return false
		end

		return doPlayerAddMoney(cid, cost)
	end
end

if doPlayerBuyItemContainer == nil then
	function doPlayerBuyItemContainer(cid, containerid, itemid, amount, cost, subType)
		local amount = amount or 1
		local cost = cost or 0
		local subType = subType or 0

		if getPlayerMoney(cid) < cost then
			return false
		end

		for i = 1, amount do
			local container = doCreateItemEx(containerid, 1)
			for slot = 1, getContainerCapById(containerid) do
				doAddContainerItem(container, itemid, subType)
			end

			if doPlayerAddItemEx(cid, container, true) ~= RETURNVALUE_NOERROR then
				return false
			end
		end

		return doPlayerRemoveMoney(cid, cost)
	end
end

function doRemoveItemIdFromPosition(id, n, position)
	local thing = getTileItemById(position, id)
	if(thing.itemid < 101) then
		return false
	end

	doRemoveItem(thing.uid, n)
	return true
end

function getNpcName()
	return getCreatureName(getNpcId())
end

function getNpcPosition()
	return getThingPosition(getNpcId())
end

function selfGetPosition()
	local t = getThingPosition(getNpcId())
	return t.x, t.y, t.z
end

msgcontains = doMessageCheck
moveToPosition = selfMoveTo
moveToCreature = selfMoveToThing
selfMoveToCreature = selfMoveToThing
selfMoveToPosition = selfMoveTo
isPlayerPremiumCallback = isPremium
doPosRemoveItem = doRemoveItemIdFromPosition
doRemoveItemIdFromPos = doRemoveItemIdFromPosition
doNpcBuyItem = doPlayerRemoveItem
if selfFocus == nil and doNpcSetCreatureFocus ~= nil then
	selfFocus = doNpcSetCreatureFocus
end
if getNpcId ~= nil then
	getNpcCid = getNpcId
end
getDistanceTo = getNpcDistanceTo
getDistanceToCreature = getNpcDistanceTo
getNpcDistanceToCreature = getNpcDistanceTo
getNpcPos = getNpcPosition
