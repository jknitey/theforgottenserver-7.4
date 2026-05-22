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

	if msgcontains(msg, "rat") then
		npcHandler:say("Do you bring a freshly killed rat for a bounty of 1 gold?", cid)
		talkState[stateKey] = 1
	elseif msgcontains(msg, "yes") and state == 1 then
		if getPlayerItemCount(cid, 2813) >= 1 then
			doPlayerRemoveItem(cid, 2813, 1)
			doPlayerAddMoney(cid, 1)
			npcHandler:say("Here is your reward. You will become a great warrior some day.", cid)
		else
			npcHandler:say("You do not have a freshly killed rat with you.", cid)
		end
		talkState[stateKey] = 0
	elseif msgcontains(msg, "no") and state == 1 then
		npcHandler:say("Come on. Don't waste my time with your jests.", cid)
		talkState[stateKey] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
