# love-ecs

A basic ECS implementation, originally made by [itsMapleLeaf](https://github.com/itsMapleLeaf) in Lua for [LÖVE](https://love2d.org). See `lua/` directory for the original code.

When I needed a simple ECS library for some three.js projects, I converted the code to JavaScript.

## Reference

### Entity

You can call `get(ComponentA, ComponentB)` or `getComponent(ComponentA)` on an entity. The first returns an array of components, but it can contain `undefined` if that component was not added to the entity. Use the latter as a "non-nullable" variant because it will throw an error if the component was not found.

## Example usage

```javascript
import * as ecs from "ecs";

/* Components are classes that define your game entities' data. */
class RectangleComponent {
    constructor (x, y, width, height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
   }
}

/* Component can also be classic JavaScript "functional classes" */
function MovingComponent (speed) {
    this.speed = speed;
}

/* Systems are event listeners and entity handlers.
   Arguments are the required components for entities. */
const moveStuff = new ecs.System(RectangleComponent, MovingComponent)
/* Listeners take in any extra args given when fired. Chaining is allowed. */
    .addEventListener(ecs.Events.update, (entity, dt) => {
        /* Get the components by their constructor */
        const rect = entity.getComponent(RectangleComponent);
        /* Use destructuring to simplify variable access */
        const { speed } = entity.getComponent(MovingComponent);

        rect.x = rect.x + speed * dt;
    });

/* Entities are "bags" of components. */
const player = new ecs.Entity()
    /* Add new components using `add()`. Arguments are the component
       constructor function, and then its arguments afterward */
    .add(RectangleComponent, 100, 100, 50, 50)
    .add(MovingComponent, 100)
    /* Remove components using `remove()`, using the component constructor. */
    .remove(RectangleComponent);

const engine = new ecs.Engine()
    .addEntity(player)
    .addSystem(moveStuff)
    .addSystem(drawRect);

engine.fireEvent(ecs.Events.update, dt);
```

### Events

Events are just keywords. You usually make up yor own events, and `fire(...)` them with any kind of
parameters. The arguments after the event name appear as the parameters of the `addEventListener`
callback, either with `entity` as an extra argument (in case of a `System`) or not (for `Engine`).

The "pre-defined" names were just taken from the original LÖVE events:

```javascript
const Events = {
    draw: "draw",
    update: "update",
    enter: "enter",
    leave: "leave",
    resize: "resize"
}
```

## License

```
Copyright (c) 2020-2024 Eroica

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute
it freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must
     not claim that you wrote the original software. If you use this
     software in a product, an acknowledgment in the product
     documentation would be appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must
     not be misrepresented as being the original software.
  3. This notice may not be removed or altered from any source
     distribution.
```
