local function Engine()
	local self = {}
	local entities = {}
	local systems = {}

	function self:addEntity(entity)
		assert(entity, "No entity given to add to engine.")
		table.insert(entities, entity)
		entity.engine = self
		return self
	end

	function self:removeEntity(entity)
		for i=1, #entities do
			if entities[i] == entity then
				table.remove(entities, i)
				return self
			end
		end
	end

	function self:addSystem(system)
		assert(system, "No system given to add to engine.")
		table.insert(systems, system)
		return self
	end

	function self:fireEvent(event, ...)
		for i=1, #systems do
			systems[i]:fireEvent(event, entities, ...)
		end
		return self
	end

	return self
end

local function System(...)
	local self = {}
	local requiredComponents = {...}
	local eventListeners = {}

	local function hasRequiredComponents(entity)
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

	function self:fireEvent(event, entities, ...)
		local listeners = eventListeners[event] or {}
		for i=1, #listeners do
			for j=1, #entities do
				if hasRequiredComponents(entities[j]) then
					listeners[i](entities[j], ...)
				end
			end
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

	function self:addToEngine(engine)
		engine:addEntity(self)
	end

	function self:destroy()
		if self.engine then
			self.engine:removeEntity(self)
		end
		return self
	end

	return self
end

return {
	Entity = Entity,
	System = System,
	Engine = Engine,
}
