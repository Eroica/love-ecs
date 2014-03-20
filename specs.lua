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
				:addEventListener("update", function()
					print "I was fired through chaining!"
				end)
				:fireEvent("update") == system
		)
	end)
end)
