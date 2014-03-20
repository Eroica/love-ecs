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
	local ent = ecs.Entity()

	it("adds components via their constructor", function()
		ent:add(emptyComponent)
	end)

	it("can access components via constructor", function()
		assert.is_not_nil(ent:get(emptyComponent))
	end)

	it("passes any additional arguments to the component constructors", function()
		ent:add(rectangleComponent, 100, 100, 50, 50)
		local rect = ent:get(rectangleComponent)
		assert.is.truthy(rect.x, rect.y, rect.width, rect.height)
	end)

	it("allows chaining", function()
		assert.is_true(
			ent
				:add(movementComponent, 400)
				:add(drawingComponent, function(entity)
					local rect = entity:get(rectangleComponent)
					love.graphics.rectangle('fill', rect.x, rect.y, rect.width, rect.height)
				end)
			== ent
		)
	end)

	it("allows grabbing multiple components", function()
		local rectangle, movement, drawing = ent:get(
			rectangleComponent,
			movementComponent,
			drawingComponent)

		assert.is.truthy(rectangle, movement, drawing)
	end)

	it("removes components by their constructor", function()
		ent:remove(emptyComponent)
		assert.is.falsy(ent:get(emptyComponent))
	end)

	it("errors when given a nil component", function()
		assert.has.errors(function()
			ent:add(undefinedComponent)
		end)
	end)
end)
