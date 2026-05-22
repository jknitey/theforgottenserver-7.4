local REACTIVE_ENERGY_ARMOR_STORAGE = 95001
local REACTIVE_ENERGY_ARMOR_DURATION_SECONDS = 8

function onCastSpell(creature, var)
	if getCreatureCondition(creature, CONDITION_PACIFIED) then
		creature:sendCancelMessage(RETURNVALUE_YOUAREEXHAUSTED)
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if creature:getStorageValue(REACTIVE_ENERGY_ARMOR_STORAGE) >= os.time() then
		creature:sendCancelMessage("Reactive Energy Armor is already active.")
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	creature:setStorageValue(REACTIVE_ENERGY_ARMOR_STORAGE, os.time() + REACTIVE_ENERGY_ARMOR_DURATION_SECONDS)
	creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	return true
end
