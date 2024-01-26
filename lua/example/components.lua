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
	local self = {}
	local speed = walkSpeed
	local walking = false
	local direction = 1

	function self:setWalking(_direction)
		if _direction and _direction ~= 0 then
			direction = math.sign(_direction)
		end
		walking = _direction ~= 0
		return self
	end

	function self:getSpeed()
		return speed
	end

	function self:getWalking()
		return walking, direction
	end

	return self
end

function Jumping(jumpSpeed)
	local self = {}
	jumpSpeed = jumpSpeed or 800

	function self:jump(entity)
		local velocity = entity:get(Velocity)
		if velocity then
			velocity:setVector(nil, -jumpSpeed)
		end
	end

	return self
end

function Gravity(force)
	return { force = force or 1000 }
end

function Menu(...)
	local args = {...}
	assert(#args > 0, "No arguments given to menu component.")
	assert(#args % 2 == 0, "Length of arguments for menu component must be even \
		(string, function, string, function, ...).")

	local self = { selection = 1, options = {} }

	for i=1, #args, 2 do
		table.insert(self.options, {
			label = args[i],
			action = args[i + 1],
		})
	end

	return self
end
