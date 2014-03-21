function math.sign(n)
	return n > 0 and 1 or n < 0 and -1 or 0
end

function createPlayer()
	return ecs.Entity()
		:add(Rectangle, 10, 10, 50, 50)
		:add(Velocity)
		:add(Drawing, drawRect)
		:add(Gravity, 2500)
		:add(Walking, 400)
		:add(Jumping, 800)
		:add(PlayerControls)
end

function drawRect(entity)
	local rectangle = entity:get(Rectangle)
	if rectangle then
		love.graphics.rectangle('fill', rectangle:getBBox())
	end
end
