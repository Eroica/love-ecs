
function MainMenu(gamestate)
	local menu = ecs.Entity():add(Menu,
		'Option1', function() print "This option does nothing!" end,
		'Option2', function() print "This option does nothing!" end,
		'Option3', function() print "This option does nothing!" end,
		'Game Start!', function() gamestate:switch(Game(gamestate)) end,
		'Quit', function() love.event.quit() end)

	return ecs.Engine()
		:addEntity(menu)
		:addSystem(MenuSystem())
		:addEventListener("keypressed", function(k)
			if k == 'escape' then
				love.event.quit()
			end
		end)
end

function Game(gamestate)
	return ecs.Engine()
		:addEntity(createPlayer())

		:addSystem(DrawingSystem())
		:addSystem(VelocitySystem())
		:addSystem(GravitySystem())
		:addSystem(YFloorSystem(love.window.getHeight()))
		:addSystem(InputSystem())
		:addSystem(WalkingSystem())

		:addEventListener("keypressed", function(k)
			if k == 'escape' then
				gamestate:switch(MainMenu(gamestate))
			end
		end)
end
