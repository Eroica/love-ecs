local allEvents = {
	'update', 'draw',
	'keypressed', 'keyreleased', 'textinput',
	'mousepressed', 'mousereleased', 'mousefocus',
	'focus', 'resize', 'visible',
	'quit',
}

local function Engine()
	local self = {}
	local entities = {}
	local systems = {}

	local function searchAndDestroy(list, target)
		for i=1, #list do
			if list[i] == target then
				table.remove(list, i)
				return
			end
		end
	end

	function self:addEntity(entity)
		assert(entity, "No entity given to add to engine.")
		table.insert(entities, entity)
		entity.engine = self
		return self
	end

	function self:removeEntity(entity)
		searchAndDestroy(entities, entity)
		return self
	end

	function self:addSystem(system)
		assert(system, "No system given to add to engine.")
		table.insert(systems, system)
		return self
	end

	function self:removeSystem(system)
		searchAndDestroy(systems, system)
		return self
	end

	function self:fireEvent(event, ...)
		for i=1, #systems do
			local system = systems[i]
			for i=1, #entities do
				local entity = entities[i]
				if system:hasRequiredComponents(entity) then
					system:fireEvent(event, entity, ...)
				end
			end
		end
		return self
	end

	return self
end

local function System(...)
	local self = {}
	local requiredComponents = {...}
	local eventListeners = {}

	function self:hasRequiredComponents(entity)
		if #requiredComponents == 0 then
			return true
		end
		for i=1, #requiredComponents do
			if not entity:get(requiredComponents[i]) then
				return false
			end
		end
		return true
	end

	function self:addEventListener(event, listener)
		eventListeners[event] = eventListeners[event] or {}
		table.insert(eventListeners[event], listener)
		return self
	end

	function self:fireEvent(event, ...)
		local listeners = eventListeners[event] or {}
		for i=1, #listeners do
			listeners[i](...)
		end
		return self
	end

	return self
end

local function Entity()
	local self = {}
	local components = {}

	function self:add(component, ...)
		assert(component, "No component given to add to entity.")
		components[component] = component(...)
		return self
	end

	function self:remove(component)
		components[component] = nil
		return self
	end

	function self:get(...)
		local args = {...}
		local componentList = {}
		for i=1, #args do
			componentList[i] = components[args[i]]
		end
		return unpack(componentList)
	end

	function self:destroy()
		if self.engine then
			self.engine:removeEntity(self)
		end
		return self
	end

	return self
end

local function EngineStack()
	local self = {}
	local stack = { Engine() }

	function self:switch(engine)
		local prev = self:current():fireEvent("leave")
		stack = { engine }
		self:fireEvent("enter", prev)
		return self
	end

	function self:push(engine)
		table.insert(stack, engine)
		self:fireEvent("enter", stack[#stack - 1])
		return self
	end

	function self:pop()
		local engine = table.remove(stack, #stack)
		engine:fireEvent("leave")
		return self
	end

	function self:current()
		return stack[#stack]
	end

	function self:fireEvent(...)
		self:current():fireEvent(...)
		return self
	end

	function self:registerEvents(events)
		events = events or allEvents
		return self
	end

	return self
end

return {
	Entity = Entity,
	System = System,
	Engine = Engine,
	EngineStack = EngineStack,
}
