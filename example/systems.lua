function DrawingSystem()
	return ecs.System(Drawing)
		:addEventListener("draw", function(entity)
			entity:get(Drawing):draw(entity)
		end)
end

function VelocitySystem()
	return ecs.System(Rectangle, Velocity)
		:addEventListener("update", function(entity, dt)
			local rectangle, velocity = entity:get(Rectangle, Velocity)
			local vx, vy = velocity:getVector()
			rectangle:move(vx, vy, dt)
		end)
end

function GravitySystem()
	return ecs.System(Velocity, Gravity)
		:addEventListener("update", function(entity, dt)
			local velocity, gravity = entity:get(Velocity, Gravity)
			velocity:add(0, gravity.force, dt)
		end)
end

function YFloorSystem(floor)
	return ecs.System(Rectangle, Velocity, Gravity)
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
	return ecs.System(Rectangle, Walking)
		:addEventListener("update", function(entity, dt)
			local walking, rectangle = entity:get(Walking, Rectangle)
			local isWalking, direction = walking:getWalking()
			if isWalking then
				rectangle:move(walking:getSpeed() * direction, 0, dt)
			end
		end)
end

function InputSystem()
	return ecs.System(PlayerControls, Walking, Jumping)
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
			local input, jumping = entity:get(PlayerControls, Jumping)
			if input:jumping(key) then
				jumping:jump(entity)
			end
		end)
end

function MenuSystem()
	local x, y = 50, 50
	return ecs.System(Menu)
		:addEventListener("keypressed", function(entity, k)
			local menu = entity:get(Menu)
			if k == 'down' then
				menu.selection = menu.selection < #menu.options and menu.selection + 1 or 1
			elseif k == 'up' then
				menu.selection = menu.selection > 1 and menu.selection - 1 or #menu.options
			elseif k == 'return' then
				menu.options[menu.selection].action()
			end
		end)

		:addEventListener("draw", function(entity)
			local menu = entity:get(Menu)
			love.graphics.setNewFont(36)

			for i,option in ipairs(menu.options) do
				if i == menu.selection then
					love.graphics.setColor(255, 255, 255)
				else
					love.graphics.setColor(120, 120, 120)
				end
				love.graphics.print(option.label, x, y + (i - 1)*40)
			end
		end)
end
