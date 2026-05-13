local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)

local area = createCombatArea(AREA_SQUARE1X1)
combat:setArea(area)

local function getDamageFactor(attackFactor)
	if attackFactor >= 1.9 then
		return 0.5
	elseif attackFactor >= 1.1 then
		return 0.75
	end

	return 1.0
end

function onGetFormulaValues(player, skill, attack, attackFactor)
	local damageFactor = getDamageFactor(attackFactor)
	local level = player:getLevel()
	skill = skill or 0
	attack = attack or 0

	local scaledDamage = 2.05 * (skill + (2 * attack)) * damageFactor
	local min = -((level / 5) * damageFactor)
	local max = -((scaledDamage + level) / 5)
	return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

function onCastSpell(creature, var)
	-- check for stairHop delay
	if not getCreatureCondition(creature, CONDITION_PACIFIED) then
		return combat:execute(creature, var)
	else
		creature:sendCancelMessage(RETURNVALUE_YOUAREEXHAUSTED)
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end
end
