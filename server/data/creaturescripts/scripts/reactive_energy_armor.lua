local REACTIVE_ENERGY_ARMOR_STORAGE = 95001
local MANA_PER_TRIGGER = 5

local function getEnergyStrikeDamage(player)
	local level = player:getLevel()
	local maglevel = player:getMagicLevel()
	local min = -((level * 2) + (maglevel * 3)) * 0.25
	local max = -((level * 2) + (maglevel * 3)) * 0.55
	return min, max
end

function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature:isPlayer() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	if primaryDamage <= 0 and secondaryDamage <= 0 then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	if creature:getStorageValue(REACTIVE_ENERGY_ARMOR_STORAGE) < os.time() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	if not attacker or not attacker:isMonster() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	local min, max = getEnergyStrikeDamage(creature)
	doTargetCombatHealth(creature, attacker, COMBAT_ENERGYDAMAGE, min, max, CONST_ME_TELEPORT)
	creature:addMana(MANA_PER_TRIGGER)

	return primaryDamage, primaryType, secondaryDamage, secondaryType
end
