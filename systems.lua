function DrawingSystem()
	return System(Drawing)
		:addEventListener("draw", function(entity)
			entity:get(Drawing):draw(entity)
		end)
end

function VelocitySystem()
	return System(Rectangle, Velocity)
		:addEventListener("update", function(entity, dt)
			local rectangle, velocity = entity:get(Rectangle, Velocity)
			local vx, vy = velocity:getVector()
			rectangle:move(vx, vy, dt)
		end)
end

function GravitySystem()
	return System(Velocity, Gravity)
		:addEventListener("update", function(entity, dt)
			local velocity, gravity = entity:get(Velocity, Gravity)
			velocity:add(0, gravity.force, dt)
		end)
end

function YFloorSystem(floor)
	return System(Rectangle, Velocity, Gravity)
		:addEventListener("update", function(entity, dt)
			local rectangle, velocity = entity:get(Rectangle, Velocity)
			local x, y, width, height = rectangle:getBBox()
			if y + height > floor then
				rectangle:setPosition(x, floor - height)
				velocity:setVector(nil, 0)
			end
		end)
end

function WalkingSystem()
	return System(Rectangle, Walking)
		:addEventListener("update", function(entity, dt)
			local walking, rectangle = entity:get(Walking, Rectangle)
			local isWalking, direction = walking:getWalking()
			if isWalking then
				rectangle:move(walking:getSpeed() * direction, 0, dt)
			end
		end)
end

function InputSystem()
	return System(PlayerControls, Velocity, Walking, Jumping)
		:addEventListener("update", function(entity, dt)
			local input, walking = entity:get(PlayerControls, Walking)
			local dir = 0
			if input:movingLeft() then
				dir = dir - 1
			end
			if input:movingRight() then
				dir = dir + 1
			end
			walking:setWalking(dir)
		end)

		:addEventListener("keypressed", function(entity, key)
			local input, velocity, jumping = entity:get(PlayerControls, Velocity, Jumping)
			if input:jumping(key) then
				velocity:setVector(nil, -jumping.speed)
			end
		end)
end
