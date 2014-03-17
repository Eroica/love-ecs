function drawRect(entity)
	local rectangle = entity:get(Rectangle)
	if rectangle then
		love.graphics.rectangle('fill', rectangle:getBBox())
	end
end
