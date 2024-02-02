/**
 * Copyright (c) 2020-2024 Eroica
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute
 * it freely, subject to the following restrictions:
 *
 *   1. The origin of this software must not be misrepresented; you must
 *      not claim that you wrote the original software. If you use this
 *      software in a product, an acknowledgment in the product
 *      documentation would be appreciated but is not required.
 *   2. Altered source versions must be plainly marked as such, and must
 *      not be misrepresented as being the original software.
 *   3. This notice may not be removed or altered from any source
 *      distribution.
 */

const Events = {
	draw: "draw",
	update: "update",
	enter: "enter",
	leave: "leave",
	resize: "resize"
}

class ComponentNotFound extends Error {
	constructor(message) {
		super(message);
		this.name = "ComponentNotFound";
	}
}

function Entity () {
	this.components = new WeakMap();
}
Entity.prototype.add = function (component, ...args) {
	this.components.set(component, new component(...args));
	return this;
};
Entity.prototype.remove = function (component) {
	this.components.delete(component);
	return this;
};
Entity.prototype.get = function (...components) {
	return components.map((component) => this.components.get(component));
};
Entity.prototype.getComponent = function (component) {
	const c = this.components.get(component);
	if (c == null) {
		throw new ComponentNotFound(`Component ${component} was not found in this entity!`);
	}

	return c;
};
Entity.prototype.setComponent = function (cls, component) {
	this.components.set(cls, component);
};
Entity.prototype.destroy = function () {
	if (this.engine !== undefined) {
		this.engine.removeEntity(this);
	}
	return this;
};

function System (...components) {
	this.requiredComponents = components.flat();
	this.eventListeners = {};
}
System.prototype.hasRequiredComponents = function (entity) {
	if (this.requiredComponents.length === 0) {
		return true;
	}

	for (let i=0; i < this.requiredComponents.length; i++) {
		if (entity.components.get(this.requiredComponents[i]) === undefined) {
			return false;
		}
	}

	return true;
};
System.prototype.addEventListener = function (event, listener) {
	this.eventListeners[event] = this.eventListeners[event] || [];
	this.eventListeners[event].push(listener);
	return this;
};
System.prototype.fireEvent = function (event, ...args) {
	const listeners = this.eventListeners[event] || [];
	for (let listener of listeners) {
		listener(...args);
	}
	return this;
};

function Engine () {
	this.entities = [];
	this.systems = [];
	this.eventHandler = new System();
}
Engine.prototype.searchAndDestroy = function (list, target) {
	for (let i = 0; i < list.length; i++) {
		if (list[i] === target) {
			list.splice(i, 1);
			return;
		}
	}
};
Engine.prototype.addEntity = function (entity) {
	this.entities.push(entity);
	entity.engine = this;
	return this;
};
Engine.prototype.getEntities = function (...components) {
	if (components.length === 0) {
		return this.entities;
	} else {
		const rtn = [];

		loopAllEntities: for (let entity of this.entities) {
			for (let component of components) {
				if (entity.get(component)[0] === undefined) {
					continue loopAllEntities;
				}
			}
			rtn.push(entity);
		}

		return rtn;
	}
};
Engine.prototype.removeEntity = function (entity) {
	this.searchAndDestroy(this.entities, entity);
	return this;
};
Engine.prototype.addSystem = function (system) {
	this.systems.push(system);
	return this;
};
Engine.prototype.getSystems = function () {
	return this.systems;
};
Engine.prototype.removeSystem = function (system) {
	this.searchAndDestroy(this.systems, system);
	return this;
};
Engine.prototype.addEventListener = function (...args) {
	this.eventHandler.addEventListener(...args);
	return this;
};
Engine.prototype.fireEvent = function (event, ...args) {
	this.eventHandler.fireEvent(event, ...args);
	for (let system of this.systems) {
		for (let entity of this.entities) {
			if (system.hasRequiredComponents(entity)) {
				system.fireEvent(event, entity, ...args);
			}
		}
	}

	return this;
};

function StateManager () {
	this.stack = [new Engine()];
}
StateManager.prototype.switch = function (engine) {
	const prev = this.current().fireEvent(Events.leave);
	this.stack = [engine];
	this.fireEvent(Events.enter, prev);
	return this;
};
StateManager.prototype.push = function (engine) {
	this.current().fireEvent(Events.leave);
	this.stack.push(engine);
	this.fireEvent(Events.enter, this.stack[this.stack.length - 2]);
	return this;
};
StateManager.prototype.pop = function () {
	if (this.stack.length > 1) {
		const engine = this.stack.pop();
		engine.fireEvent(Events.leave);
		this.fireEvent(Events.enter, engine);
		return true;
	} else {
		return false;
	}
};
StateManager.prototype.current = function () {
	return this.stack[this.stack.length - 1];
};
StateManager.prototype.fireEvent = function (...args) {
	this.current().fireEvent(...args);
	return this;
};

export {Entity, System, Engine, StateManager, Events};
