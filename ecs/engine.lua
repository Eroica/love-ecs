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

return Engine
