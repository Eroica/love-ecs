local function System(...)
	local self = {}
	local requiredComponents = {...}
	local eventListeners = {}

	local function hasRequiredComponents(entity)
		for i,component in ipairs(requiredComponents) do
			if not entity:get(component) then
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
		for i,listener in ipairs(eventListeners[event] or {}) do
			for i,entity in ipairs(entities) do
				if hasRequiredComponents(entity) then
					listener(entity, ...)
				end
			end
		end
		return self
	end

	return self
end

return System
