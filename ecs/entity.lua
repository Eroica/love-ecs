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
		local componentList = {}
		for i,component in ipairs{...} do
			componentList[i] = components[component]
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

return Entity
