love-ecs
========

love-ecs is an implementation of the [entity-component system game design pattern](http://en.wikipedia.org/wiki/Entity_component_system) using closure-based OO.

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
