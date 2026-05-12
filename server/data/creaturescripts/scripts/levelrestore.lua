function onAdvance(player, skill, oldLevel, newLevel)
	if skill ~= SKILL_LEVEL or newLevel <= oldLevel then
		return true
	end

	player:addHealth(player:getMaxHealth() - player:getHealth())
	player:addMana(player:getMaxMana() - player:getMana())
	return true
end
