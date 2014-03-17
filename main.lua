function love.load()
	Entity = require "ecs.entity"
	System = require "ecs.system"
	Engine = require "ecs.engine"

	require "components"
	require "systems"
	require "functions"

	local player = Entity()
		:add(Rectangle, 10, 10, 50, 50)
		:add(Velocity)
		:add(Drawing, drawRect)
		:add(Gravity, 2500)
		:add(Walking, 400)
		:add(Jumping, 800)
		:add(PlayerControls)

	local engine = Engine()
		:addEntity(player)
		:addSystem(DrawingSystem())
		:addSystem(VelocitySystem())
		:addSystem(GravitySystem())
		:addSystem(YFloorSystem(love.window.getHeight()))
		:addSystem(InputSystem())

	function love.keypressed(k)
		if k == 'escape' then
			love.event.quit()
			return
		end
		engine:fireEvent("keypressed", k)
	end

	function love.update(dt)
		engine:fireEvent("update", dt)
	end

	function love.draw()
		engine:fireEvent("draw")
	end
end
