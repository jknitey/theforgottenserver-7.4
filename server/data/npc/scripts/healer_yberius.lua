dofile("data/npc/lib/_npcsystem.lua")
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local healthyMessage = "You aren't looking that bad. Sorry, I can't help you. If you are looking for additional protection, you should go on the pilgrimage of ashes."

local function tryHealPlayer(cid)
	if hasCondition(cid, CONDITION_FIRE) == TRUE then
		npcHandler:say("You are burning. I will help you.", cid)
		doRemoveCondition(cid, CONDITION_FIRE)
		doSendMagicEffect(getCreaturePosition(cid), 14)
	elseif hasCondition(cid, CONDITION_POISON) == TRUE then
		npcHandler:say("You are poisoned. I will help you.", cid)
		doRemoveCondition(cid, CONDITION_POISON)
		doSendMagicEffect(getCreaturePosition(cid), 13)
	elseif getCreatureHealth(cid) < 65 then
		npcHandler:say("You are looking really bad. Let me heal your wounds.", cid)
		doCreatureAddHealth(cid, 65 - getCreatureHealth(cid))
		doSendMagicEffect(getCreaturePosition(cid), 12)
	else
		npcHandler:say(healthyMessage, cid)
	end
end

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	if not msgcontains(msg, "heal") then
		return false
	end

	tryHealPlayer(cid)
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
