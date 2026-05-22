local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)

local area = createCombatArea(AREA_SQUARE1X1)
combat:setArea(area)

local PULSE_INTERVAL_MS = 2000
local PULSE_COUNT = 5
local EXORI_SANCT_PULSE_STORAGE = 95002

function onGetFormulaValues(player, skill, attack)
	local level = player:getLevel()
	local weaponSkill = skill or 0
	local min = -((level * 2) + (weaponSkill * 3)) * 0.10
	local max = -((level * 2) + (weaponSkill * 3)) * 0.55
	return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

local function executePulse(creatureId, pulseIndex)
	local creature = Creature(creatureId)
	if not creature then
		return
	end

	creature:setStorageValue(EXORI_SANCT_PULSE_STORAGE, 1)
	combat:execute(creature, Variant(creature:getPosition()))
	creature:setStorageValue(EXORI_SANCT_PULSE_STORAGE, -1)

	if pulseIndex < PULSE_COUNT then
		addEvent(executePulse, PULSE_INTERVAL_MS, creatureId, pulseIndex + 1)
	end
end

function onCastSpell(creature, var)
	if getCreatureCondition(creature, CONDITION_PACIFIED) then
		creature:sendCancelMessage(RETURNVALUE_YOUAREEXHAUSTED)
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	executePulse(creature:getId(), 1)
	return true
end
