local DURATION_MS = 8000

local regeneration = Condition(CONDITION_REGENERATION)
regeneration:setParameter(CONDITION_PARAM_TICKS, DURATION_MS)
regeneration:setParameter(CONDITION_PARAM_HEALTHGAIN, 15)
regeneration:setParameter(CONDITION_PARAM_HEALTHTICKS, 1000)

local haste = Condition(CONDITION_HASTE)
haste:setParameter(CONDITION_PARAM_TICKS, DURATION_MS)
-- Speed delta equals base speed, which doubles movement speed for the duration.
haste:setFormula(1.0, 0, 1.0, 0)

function onCastSpell(creature, var)
	creature:addCondition(regeneration)
	creature:addCondition(haste)
	creature:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	return true
end
