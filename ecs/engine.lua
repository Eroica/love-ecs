local function Engine()
	local self = {}
	local entities = {}
	local systems = {}

	function self:addEntity(entity)
		assert(entity, "No entity given to add to engine.")
		table.insert(entities, entity)
		return self
	end

	function self:addSystem(system)
		assert(system, "No system given to add to engine.")
		table.insert(systems, system)
		return self
	end

	function self:fireEvent(event, ...)
		for i,system in ipairs(systems) do
			system:fireEvent(event, entities, ...)
		end
		return self
	end

	return self
end

return Engine
