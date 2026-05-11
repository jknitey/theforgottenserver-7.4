-- Advanced NPC System (Created by Jiddo),
-- Modified by TheForgottenServer Team,
-- Modified by The OTX Server Team.

if getDataDir == nil then
	function getDataDir()
		return 'data/'
	end
end

if getConfigValue == nil and getConfigInfo ~= nil then
	function getConfigValue(key)
		return getConfigInfo(key)
	end
end

if getBooleanFromString == nil then
	function getBooleanFromString(value)
		if type(value) == 'boolean' then
			return value
		end

		if type(value) == 'number' then
			return value ~= 0
		end

		if type(value) ~= 'string' then
			return false
		end

		value = value:lower()
		return value == '1' or value == 'true' or value == 'yes' or value == 'on'
	end
end

if EMPTY_STORAGE == nil then
	EMPTY_STORAGE = -1
end

if errors == nil then
	function errors(value)
		return value
	end
end

if isValidPosition == nil then
	function isValidPosition(position)
		return type(position) == 'table'
			and type(position.x) == 'number'
			and type(position.y) == 'number'
			and type(position.z) == 'number'
			and position.x >= 0
			and position.y >= 0
			and position.z >= 0
	end
end

if getNpcId == nil and getNpcCid ~= nil then
	function getNpcId()
		return getNpcCid()
	end
end

if doNpcSetCreatureFocus == nil then
	function doNpcSetCreatureFocus(cid)
		if selfFocus ~= nil then
			return selfFocus(cid)
		end

		return true
	end
end

if getItemInfo == nil and ItemType ~= nil then
	function getItemInfo(itemId)
		local itemType = ItemType(itemId)
		if itemType:getId() == 0 then
			return {
				itemid = 0,
				name = '',
				article = '',
				plural = '',
				description = '',
				weight = 0,
				stackable = false,
				rune = false,
				movable = false,
				pickupable = false,
				fluidcontainer = false,
				container = false,
				charges = 0
			}
		end

		return {
			itemid = itemType:getId(),
			name = itemType:getName(),
			article = itemType:getArticle(),
			plural = itemType:getPluralName(),
			description = itemType:getDescription(),
			weight = itemType:getWeight() / 100,
			stackable = itemType:isStackable(),
			rune = itemType:isRune(),
			movable = itemType:isMovable(),
			pickupable = itemType:isMovable(),
			fluidcontainer = itemType:isFluidContainer(),
			container = itemType:isContainer(),
			charges = itemType:getCharges()
		}
	end
end

local npcSystemCompatibilityLoaded = npcSystemCompatibilityLoaded or {}

local function loadNpcLibFile(path)
	if npcSystemCompatibilityLoaded[path] then
		return true
	end

	local result, errorMessage = pcall(dofile, path)
	if not result then
		error(errorMessage)
	end

	npcSystemCompatibilityLoaded[path] = true
	return true
end

local function normalizeNpcLibPath(path)
	path = tostring(path or ''):gsub('\\', '/')
	while path:sub(-1) == '/' do
		path = path:sub(1, -2)
	end

	return path
end

local function loadNpcSystemDirectory(path)
	local dataDir = normalizeNpcLibPath(getDataDir())
	local normalizedPath = normalizeNpcLibPath(path)
	local expectedPath = dataDir .. '/npc/lib/npcsystem'

	if normalizedPath ~= expectedPath and normalizedPath ~= 'data/npc/lib/npcsystem' then
		error('Unsupported npc library directory: ' .. tostring(path))
	end

	if msgcontains == nil or doNpcSellItem == nil then
		loadNpcLibFile(dataDir .. '/npc/lib/npc.lua')
	end

	loadNpcLibFile(expectedPath .. '/keywordhandler.lua')
	loadNpcLibFile(expectedPath .. '/queue.lua')
	loadNpcLibFile(expectedPath .. '/modules.lua')
	loadNpcLibFile(expectedPath .. '/npchandler.lua')
	return true
end

if doDirectory == nil then
	function doDirectory(path, recursive)
		return loadNpcSystemDirectory(path)
	end
end

if dodirectory == nil then
	function dodirectory(path, recursive)
		return loadNpcSystemDirectory(path)
	end
end

if(NpcSystem == nil) then
	-- Loads the underlying classes of the npcsystem.
	dodirectory(getDataDir() .. 'npc/lib/npcsystem')

	if doPlayerBuyItem == nil then
		function doPlayerBuyItem(cid, itemid, count, cost, subType)
			if not doPlayerRemoveMoney(cid, cost) then
				return false
			end

			local amount = tonumber(count) or 1
			local itemSubType = tonumber(subType) or 0
			local soldAmount = doNpcSellItem(cid, itemid, amount, itemSubType, false, false)
			if soldAmount ~= amount then
				doPlayerAddMoney(cid, cost)
				return false
			end

			return true
		end
	end

	if doPlayerBuyItemContainer == nil then
		function doPlayerBuyItemContainer(cid, container, itemid, count, cost, subType)
			if not doPlayerRemoveMoney(cid, cost) then
				return false
			end

			local amount = tonumber(count) or 1
			local itemSubType = tonumber(subType) or 0
			local soldAmount = doNpcSellItem(cid, itemid, amount, itemSubType, false, true, container)
			if soldAmount ~= amount then
				doPlayerAddMoney(cid, cost)
				return false
			end

			return true
		end
	end

	if doPlayerSellItem == nil then
		function doPlayerSellItem(cid, itemid, count, cost)
			local amount = tonumber(count) or 1
			if not doPlayerRemoveItem(cid, itemid, amount) then
				return false
			end

			doPlayerAddMoney(cid, cost)
			return true
		end
	end

	-- Global npc constants:

	-- Keyword nestling behavior. For more information look at the top of keywordhandler.lua
	KEYWORD_BEHAVIOR = BEHAVIOR_NORMAL_EXTENDED

	-- Greeting and unGreeting keywords. For more information look at the top of modules.lua
	FOCUS_GREETWORDS = {'hi', 'hello'}
	FOCUS_FAREWELLWORDS = {'bye', 'farewell'}

	-- The word for requesting trade window. For more information look at the top of modules.lua
	SHOP_TRADEREQUEST = {'offer', 'trade'}

	-- The word for accepting/declining an offer. CAN ONLY CONTAIN ONE FIELD! For more information look at the top of modules.lua
	SHOP_YESWORD = {'yes'}
	SHOP_NOWORD = {'no'}

	-- Pattern used to get the amount of an item a player wants to buy/sell.
	PATTERN_COUNT = '%d+'

	-- Talkdelay behavior. For more information, look at the top of npchandler.lua.
	NPCHANDLER_TALKDELAY = TALKDELAY_ONTHINK

	-- Conversation behavior. For more information, look at the top of npchandler.lua.
	NPCHANDLER_CONVBEHAVIOR = CONVERSATION_DEFAULT

	-- Constant strings defining the keywords to replace in the default messages.
	--	For more information, look at the top of npchandler.lua...
	TAG_PLAYERNAME = '|PLAYERNAME|'
	TAG_ITEMCOUNT = '|ITEMCOUNT|'
	TAG_TOTALCOST = '|TOTALCOST|'
	TAG_ITEMNAME = '|ITEMNAME|'
	TAG_QUEUESIZE = '|QUEUESIZE|'

	NpcSystem = {}

	-- Gets an npcparameter with the specified key. Returns nil if no such parameter is found.
	function NpcSystem.getParameter(key)
		local ret = getNpcParameter(tostring(key))
		if((type(ret) == 'number' and ret == 0) or ret == nil) then
			return nil
		else
			return ret
		end
	end

	-- Parses all known parameters for the npc. Also parses parseable modules.
	function NpcSystem.parseParameters(npcHandler)
		local ret = NpcSystem.getParameter('idletime')
		if(ret ~= nil) then
			npcHandler.idleTime = tonumber(ret)
		end
		local ret = NpcSystem.getParameter('talkradius')
		if(ret ~= nil) then
			npcHandler.talkRadius = tonumber(ret)
		end
		local ret = NpcSystem.getParameter('message_greet')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_GREET, ret)
		end
		local ret = NpcSystem.getParameter('message_farewell')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_FAREWELL, ret)
		end
		local ret = NpcSystem.getParameter('message_decline')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_DECLINE, ret)
		end
		local ret = NpcSystem.getParameter('message_needmorespace')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_NEEDMORESPACE, ret)
		end
		local ret = NpcSystem.getParameter('message_needspace')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_NEEDSPACE, ret)
		end
		local ret = NpcSystem.getParameter('message_sendtrade')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_SENDTRADE, ret)
		end
		local ret = NpcSystem.getParameter('message_noshop')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_NOSHOP, ret)
		end
		local ret = NpcSystem.getParameter('message_oncloseshop')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_ONCLOSESHOP, ret)
		end
		local ret = NpcSystem.getParameter('message_onbuy')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_ONBUY, ret)
		end
		local ret = NpcSystem.getParameter('message_onsell')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_ONSELL, ret)
		end
		local ret = NpcSystem.getParameter('message_missingmoney')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_MISSINGMONEY, ret)
		end
		local ret = NpcSystem.getParameter('message_needmoney')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_NEEDMONEY, ret)
		end
		local ret = NpcSystem.getParameter('message_missingitem')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_MISSINGITEM, ret)
		end
		local ret = NpcSystem.getParameter('message_needitem')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_NEEDITEM, ret)
		end
		local ret = NpcSystem.getParameter('message_idletimeout')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_IDLETIMEOUT, ret)
		end
		local ret = NpcSystem.getParameter('message_walkaway')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_WALKAWAY, ret)
		end
		local ret = NpcSystem.getParameter('message_alreadyfocused')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_ALREADYFOCUSED, ret)
		end
		local ret = NpcSystem.getParameter('message_placedinqueue')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_PLACEDINQUEUE, ret)
		end
		local ret = NpcSystem.getParameter('message_buy')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_BUY, ret)
		end
		local ret = NpcSystem.getParameter('message_sell')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_SELL, ret)
		end
		local ret = NpcSystem.getParameter('message_bought')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_BOUGHT, ret)
		end
		local ret = NpcSystem.getParameter('message_sold')
		if(ret ~= nil) then
			npcHandler:setMessage(MESSAGE_SOLD, ret)
		end

		-- Parse modules.
		for parameter, module in pairs(Modules.parseableModules) do
			local ret = NpcSystem.getParameter(parameter)
			if(ret ~= nil) then
				local number = tonumber(ret)
				if(number ~= nil and number ~= 0) then
					npcHandler:addModule(module:new())
				end
			end
		end
	end
end
