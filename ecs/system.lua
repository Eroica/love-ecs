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

return System
