function love.load()
	io.stdout:setvbuf('no')
	ecs = require 'ecs'

	require "components"
	require "systems"
	require "functions"
	require "engines"

	local gamestate = ecs.StateKeeper()
	gamestate:registerEvents()
	gamestate:switch(MainMenu(gamestate))
end

function love.keypressed(k)
	if k == 'escape' then
		love.event.quit()
	end
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setNewFont(12)
	love.graphics.print(love.timer.getFPS(), 10, 10)
end
