function math.sign(n)
	return n > 0 and 1 or n < 0 and -1 or 0
end

function drawRect(entity)
	local rectangle = entity:get(Rectangle)
	if rectangle then
		love.graphics.rectangle('fill', rectangle:getBBox())
	end
end
