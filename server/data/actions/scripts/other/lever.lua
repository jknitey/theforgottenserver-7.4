function onUse(player, item, fromPosition, target, toPosition)
	local itemId = item:getId()
	if itemId == 1945 then
		item:transform(1946)
	elseif itemId == 1946 then
		item:transform(1945)
	else
		return false
	end
	return true
end
