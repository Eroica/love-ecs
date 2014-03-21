local ecs = require "ecs"

function emptyComponent()
	return {}
end

function rectangleComponent(x, y, width, height)
	return { x = x, y = y, width = width, height = height }
end

function movementComponent(speed)
	return { speed = speed }
end

function drawingComponent(drawFunc)
	return { draw = drawFunc }
end

function speechComponent(name)
	return { speak = function()
		print("I am an entity, and my name is " .. name)
	end }
end

describe("Component", function()
	it("is just a function!", function()
		assert.is_true(type(emptyComponent) == "function")
	end)
end)

describe("Entity", function()
	it("adds components via their constructor", function()
		local ent = ecs.Entity()
		ent:add(emptyComponent)
	end)

	it("can access components via constructor", function()
		local ent = ecs.Entity()
		ent:add(emptyComponent)
		assert.is_not_nil(ent:get(emptyComponent))
	end)

	it("passes any additional arguments to the component constructors", function()
		local ent = ecs.Entity()
		ent:add(rectangleComponent, 100, 100, 50, 50)
		local rect = ent:get(rectangleComponent)
		assert.is.truthy(rect.x, rect.y, rect.width, rect.height)
	end)

	it("allows chaining", function()
		local ent = ecs.Entity()
		assert.is_true(
			ent
				:add(rectangleComponent, 100, 100, 50, 50)
				:add(movementComponent, 400)
				:add(drawingComponent, function() end) == ent
		)
	end)

	it("allows grabbing multiple components", function()
		local ent = ecs.Entity()
			:add(rectangleComponent, 100, 100, 50, 50)
			:add(movementComponent, 400)
			:add(drawingComponent, function() end)

		local rectangle, movement, drawing = ent:get(
			rectangleComponent,
			movementComponent,
			drawingComponent)

		assert.is.truthy(rectangle, movement, drawing)
	end)

	it("removes components by their constructor", function()
		local ent = ecs.Entity()
			:add(emptyComponent)
			:remove(emptyComponent)

		assert.is.falsy(ent:get(emptyComponent))
	end)

	it("errors when given a nil component", function()
		assert.has.errors(function()
			ecs.Entity():add(undefinedComponent)
		end)
	end)
end)

describe("System", function()
	it("optionally accepts required components for entities", function()
		assert.has_no.errors(function()
			ecs.System()
			ecs.System(rectangleComponent, movementComponent)
		end)
	end)

	it("uses event listeners, accepts an event and passes extra args to event handlers", function()
		local system = ecs.System(rectangleComponent)
		system:addEventListener("move-everything", function(entity, distance)
			local rect = entity:get(rectangleComponent)
			rect.x = rect.x + distance
		end)

		local ent = ecs.Entity():add(rectangleComponent, 0, 0, 50, 50)
		local orig_x = ent:get(rectangleComponent).x
		local distance = 100

		system:fireEvent("move-everything", ent, distance)

		assert.is_true(ent:get(rectangleComponent).x == orig_x + distance)
	end)

	it("allows chaining", function()
		local system = ecs.System()
		assert.is_true(
			system
				:addEventListener("chain", function()
					print "I was fired through chaining!"
				end)
				:fireEvent("chain") == system
		)
	end)
end)

describe("Engine", function()
	local engine = ecs.Engine()

	it("holds entities", function()
		assert.has_no.errors(function()
			engine:addEntity(ecs.Entity())
		end)
	end)

	it("removes entities", function()
		assert.has_no.errors(function()
			local ent = ecs.Entity()
			engine:addEntity(ent)
			engine:removeEntity(ent)
		end)
	end)

	it("errors on nil entities", function()
		assert.has.errors(function()
			engine:addEntity(undefinedEntity)
		end)
	end)

	it("holds systems", function()
		assert.has_no.errors(function()
			engine:addSystem(ecs.System())
		end)
	end)

	it("removes systems", function()
		assert.has_no.errors(function()
			local ent = ecs.System()
			engine:addSystem(ent)
			engine:removeSystem(ent)
		end)
	end)

	it("errors on nil systems", function()
		assert.has.errors(function()
			engine:addSystem(undefinedSystem)
		end)
	end)

	it("allows chaining!", function()
		local engine = ecs.Engine()
		assert.is_true(
			engine
				:addEntity(ecs.Entity())
				:addSystem(ecs.System()) == engine
		)
	end)

	it("passes events to systems and uses its entities as arguments", function()
		assert.has_no.errors(function()
			local entity1 = ecs.Entity():add(speechComponent, "generic entity no. 1")
			local entity2 = ecs.Entity():add(speechComponent, "generic entity no. 2")

			local speechSystem = ecs.System(speechComponent)
				:addEventListener("speak", function(entity)
					entity:get(speechComponent).speak()
				end)

			local engine = ecs.Engine()
				:addEntity(entity1)
				:addEntity(entity2)
				:addSystem(speechSystem)

			engine:fireEvent("speak")
		end)
	end)

	it("can bind events that don't process entities", function()
		assert.has_no.errors(function()
			ecs.Engine()
				:addEventListener("test", function(msg) print(msg) end)
				:fireEvent("test", "Engine event handler test!")
		end)
	end)
end)

describe("State Manager", function()
	it("emulates gamestate functionality with engines", function()
		assert.has_no.errors(function()
			local menu = ecs.Engine():addEventListener("print-current", function()
				print "current state: menu"
			end)

			local game = ecs.Engine():addEventListener("print-current", function()
				print "current state: game"
			end)

			local stateman = ecs.StateManager()
			stateman:switch(menu)
			stateman:fireEvent("print-current")
			stateman:switch(game)
			stateman:fireEvent("print-current")
		end)
	end)

	it("also chains!", function()
		local num = 0
		local counter = ecs.Engine():addEventListener("count",
			function() num = num + 1; print(num) end)
		local stateman = ecs.StateManager()
		assert.is.equal(
			stateman
				:switch(counter)
				:fireEvent("count")
				:fireEvent("count")
				:fireEvent("count"),
			stateman
		)
	end)

	it("can obtain the current state", function()
		local stateman = ecs.StateManager()
		local game = ecs.Engine()

		stateman:switch(game)
		assert.is.equal(stateman:current(), game)
	end)

	it("sends events to the current state", function()
		local updated = false
		local game = ecs.Engine():addEventListener("update", function() updated = true end)

		ecs.StateManager():switch(game):fireEvent("update")
		assert.is_true(updated)
	end)

	it("can register events in LOVE's event handlers", function()
		local updated, drawn, gameupdate, gamedraw

		love = {
			update = function() updated = true end,
			draw = function() drawn = true end,
		}


		local game = ecs.Engine()
			:addEventListener("update", function() gameupdate = true end)
			:addEventListener("draw", function() gamedraw = true end)

		-- the state manager's events
		ecs.StateManager()
			:registerEvents()
			:switch(game)
			:fireEvent("update")
			:fireEvent("draw")

		-- the love.run event loop
		love.update()
		love.draw()

		assert.is_true(updated)
		assert.is_true(drawn)
		assert.is_true(gameupdate)
		assert.is_true(gamedraw)
	end)

	it("sends enter (with previous state) and leave events when switching", function()
		local stateman = ecs.StateManager()
		local entered = false
		local left = false

		local game = ecs.Engine()
			:addEventListener("enter", function(prev)
				assert.truthy(prev)
				entered = true
			end)
			:addEventListener("leave", function()
				left = true
			end)

		stateman:switch(game)
		stateman:switch(ecs.Engine())

		assert.is_true(entered)
		assert.is_true(left)
	end)

	it("has a state stack", function()
		local stateman = ecs.StateManager()
		local game = ecs.Engine()
		local pause = ecs.Engine()

		stateman:switch(game)
		stateman:push(pause)
		stateman:pop()

		assert.is.equal(stateman:current(), game)
	end)

	it("returns false on :pop() if there is only one state in the stack", function()
		local stateman = ecs.StateManager():switch(ecs.Engine())
		assert.is_false(stateman:pop())
	end)
end)
