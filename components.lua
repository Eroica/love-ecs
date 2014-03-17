function Rectangle(x, y, width, height)
	local self = {}
	x = x or 0
	y = y or 0
	width = width or 64
	height = height or 64

	function self:getPosition()
		return x, y
	end

	function self:getDimensions()
		return width, height
	end

	function self:getBBox()
		return x, y, width, height
	end

	function self:setPosition(_x, _y)
		x = _x or x
		y = _y or y
		return self
	end

	function self:move(dx, dy, dt)
		x = x + (dx or 0) * (dt or 1)
		y = y + (dy or 0) * (dt or 1)
		return self
	end

	return self
end

function Velocity(x, y)
	local self = {}
	x = x or 0
	y = y or 0

	function self:getVector()
		return x, y
	end

	function self:setVector(_x, _y)
		x = _x or x
		y = _y or y
	end

	function self:add(dx, dy, dt)
		x = x + (dx or 0) * (dt or 1)
		y = y + (dy or 0) * (dt or 1)
	end

	return self
end

function Drawing(drawFunc)
	assert(drawFunc, "No function given for drawing component.")
	
	local self = {}

	function self:draw(entity)
		drawFunc(entity)
	end

	return self
end

function PlayerControls()
	local self = {}

	function self:movingLeft()
		return love.keyboard.isDown('left', 'a')
	end

	function self:movingRight()
		return love.keyboard.isDown('right', 'd')
	end

	function self:jumping(k)
		return k == 'up' or k == 'w'
	end

	return self
end

function Walking(walkSpeed)
	return { speed = walkSpeed or 400 }
end

function Jumping(jumpSpeed)
	return { speed = jumpSpeed or 800 }
end

function Gravity(force)
	return { force = force or 1000 }
end
