local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_EXPLOSIONAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_BURSTARROW)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, false)

local area = createCombatArea({
	{0, 0, 1, 1, 1, 0, 0},
	{0, 1, 1, 1, 1, 1, 0},
	{1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 3, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1},
	{0, 1, 1, 1, 1, 1, 0},
	{0, 0, 1, 1, 1, 0, 0}
})
combat:setArea(area)

local BURST_ARROW_ATTACK = 37

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
	local distanceSkill = player:getSkillLevel(SKILL_DISTANCE)
	local attackValue = BURST_ARROW_ATTACK

	min = -((level / 5) * damageFactor)
	max = -((((distanceSkill * attackValue * 0.09 * damageFactor) + level) / 5))
	return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

function onUseWeapon(player, variant)
	return combat:execute(player, variant)
end
