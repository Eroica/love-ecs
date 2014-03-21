function love.load()
	ecs = require 'ecs'

	require "components"
	require "systems"
	require "functions"
	require "game"

	local gamestate = ecs.StateMachine()
	gamestate:registerEvents()
	gamestate:switch(Game())
end

function love.keypressed(k)
	if k == 'escape' then
		love.event.quit()
	end
end

function love.draw()
	love.graphics.print(love.timer.getFPS(), 10, 10)
end
