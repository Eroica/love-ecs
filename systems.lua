function DrawingSystem()
	return System(Drawing)
		:addEventListener("draw", function(entity)
			entity:get(Drawing):draw(entity)
		end)
end

function VelocitySystem()
	return System(Rectangle, Velocity)
		:addEventListener("update", function(entity, dt)
			local rectangle = entity:get(Rectangle)
			local velocity = entity:get(Velocity)
			local vx, vy = velocity:getVector()
			rectangle:move(vx, vy, dt)
		end)
end

function GravitySystem()
	return System(Velocity, Gravity)
		:addEventListener("update", function(entity, dt)
			local velocity = entity:get(Velocity)
			local gravity = entity:get(Gravity)
			velocity:add(0, gravity.force, dt)
		end)
end

function YFloorSystem(floor)
	return System(Rectangle, Velocity, Gravity)
		:addEventListener("update", function(entity, dt)
			local rectangle = entity:get(Rectangle)
			local velocity = entity:get(Velocity)
			local x, y, width, height = rectangle:getBBox()
			if y + height > floor then
				rectangle:setPosition(x, floor - height)
				velocity:setVector(nil, 0)
			end
		end)
end

function WalkingSystem()
	return System()
end

function InputSystem()
	return System(PlayerControls, Rectangle, Velocity, Walking, Jumping)
		:addEventListener("update", function(entity, dt)
			local input = entity:get(PlayerControls)
			local rectangle = entity:get(Rectangle)
			local walking = entity:get(Walking)

			if input:movingLeft() then
				rectangle:move(-walking.speed, 0, dt)
			end
			if input:movingRight() then
				rectangle:move(walking.speed, 0, dt)
			end
		end)
		:addEventListener("keypressed", function(entity, key)
			local input = entity:get(PlayerControls)
			local velocity = entity:get(Velocity)
			local jumping = entity:get(Jumping)

			if input:jumping(key) then
				velocity:setVector(nil, -jumping.speed)
			end
		end)
end
