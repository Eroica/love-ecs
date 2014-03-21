function love.load()
	ecs = require 'ecs'

	require "components"
	require "systems"
	require "functions"
	require "game"

	local gamestate = ecs.StateMachine()
	gamestate:switch(Game())

	function love.keypressed(k)
		gamestate:fireEvent("keypressed", k)
	end

	function love.update(dt)
		gamestate:fireEvent("update", dt)
	end

	function love.draw()
		gamestate:fireEvent("draw")
		love.graphics.print(love.timer.getFPS(), 10, 10)
	end
end
