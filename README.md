love-ecs
========

love-ecs is an implementation of the [entity-component system game design pattern](http://en.wikipedia.org/wiki/Entity_component_system) using closure-based OO.

Reference
---------

### Entities
The entity is a container for components that define its behavior. Constructor: `entity = ecs.Entity()`

`entity:add(component, arg1, arg2, ...)`: Adds a component to an entity. Accepts component _constructors_, not the components themselves.

`entity:remove(component)`: Removes a component by constructor.

`local comp1, comp2, compn = entity:get(component1, component2, ...)`: Get one or more components from the entity, again, by constructor.

`entity:destroy()`: Removes the entity from the engine.

### Components
Components are simply functions or functables that return a table to be stored in an entity.

```lua
function myComponent(value)
  return { value = value }
end
```

### Systems
Systems are the logic in your game that operate on the components of entities. You have the option of passing a set of components that each entity used by the system is required to have. Constructor: `system = ecs.System(requiredComponent1, requiredComponent2, ...)`

`system:addEventListener(event, func)`: Create an event listener for the system. The listener function receives an entity to operate on, and any additional event arguments.

`system:fireEvent(event, entityList, ...)`: Fire an event on an individual system and a list of entities.

### Engines
The engine is the container for entities and systems to be used, and is a middle-man group object for event handling towards systems. Constructor: `engine = ecs.Engine()`

`engine:addEntity(entity)`: Add an entity to the engine.

`engine:removeEntity(entity)`: Remove an entity from the engine.

`engine:addSystem(system)`: Add a system to the engine.

`engine:removeSystem(system)`: Remove a system from the engine.

`engine:fireEvent(event, ...)`: Send an event to systems in the engine.

Example Usage
-------------
```lua
function love.load()
  -- require the library
  ecs = require "ecs"
  
  -- components are functions that return tables (or any value, if you prefer)
  -- they define your game entities' behaviors
  -- can also tie methods to them for use by systems if you like, such as :getPosition() or :setPosition()
  function rectangleComponent(x, y, width, height)
    return { x = x, y = y, width = width, height = height }
  end
  
  function movingComponent(speed)
    return { speed = speed }
  end
  
  -- systems are event listeners and entity handlers
  -- arguments are the required components for entities
  
  -- example movement system
  moveStuff = ecs.System(rectangleComponent, movingComponent)
    -- listeners take in any extra args given when fired
    -- chaining is allowed
    :addEventListener("update", function(entity, dt)
      -- get the components by constructor
      local rect, movement = entity:get(rectangleComponent, movingComponent)
      
      -- use it accordingly
      rect.x = rect.x + movement.speed * dt
    end)
  
  -- example rectangle drawing system
  drawRect = ecs.System(rectangleComponent)
    :addEventListener("draw", function(entity)
      local rect = entity:get(rectangleComponent)
      love.graphics.rectangle('fill', rect.x, rect.y, rect.width, rect.height)
    end)
  
  -- entities are "bags" of components
  player = ecs.Entity()
    -- add new components using :add()
    -- arguments are the component constructor function, and then its arguments afterward
    -- also chaining!
    :add(rectangleComponent, 100, 100, 50, 50)
    :add(movingComponent, 100)
    
    -- remove components using :remove(), using the component reference
    -- :remove(rectangleComponent)
  
  -- put everything together with an engine!
  engine = ecs.Engine()
    -- add entities
    :addEntity(player)
    
    -- add systems
    :addSystem(moveStuff)
    :addSystem(drawRect)
end

-- we'll need to send the necessary events to the engine, so the systems receive them.
function love.update(dt)
  engine:fireEvent("update", dt)
end

function love.draw()
  engine:fireEvent("draw")
end
```

A more advanced example can be found in the example folder.
