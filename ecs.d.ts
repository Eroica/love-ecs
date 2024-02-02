declare const Events: {
	draw: string;
	update: string;
	enter: string;
	leave: string;
	resize: string;
};

declare class Entity {
	private components;

	constructor();

	add<T extends new (...args: any[]) => any>(component: T, ...args: ConstructorParameters<T>): this;

	remove(component: any): this;

	get<T extends new (...args: any[]) => any>(...components: T[]): InstanceType<T>[];

	getComponent<T extends new (...args: any[]) => any>(component: T): InstanceType<T>;

	setComponent<T extends new (...args: any[]) => any>(cls: T, component: InstanceType<T>): void;

	destroy(): this;
}

declare class System {
	private requiredComponents;
	private eventListeners;

	constructor(...components: any[]);

	hasRequiredComponents(entity: Entity): boolean;

	addEventListener(event: string, listener: (...args: any[]) => void): this;

	fireEvent(event: string, ...args: any[]): this;
}

declare class Engine {
	private entities;
	private systems;
	private eventHandler;

	constructor();

	searchAndDestroy<T>(list: T[], target: T): void;

	addEntity(entity: Entity): this;

	getEntities(...components: any[]): Entity[];

	removeEntity(entity: Entity): this;

	addSystem(system: System): this;

	getSystems(): System[];

	removeSystem(system: System): this;

	addEventListener(event: string, listener: (...args: any[]) => void): this;

	fireEvent(event: string, ...args: any[]): this;
}

declare class StateManager {
	private stack;

	constructor();

	switch(engine: Engine): this;

	push(engine: Engine): this;

	pop(): boolean;

	current(): Engine;

	fireEvent(event: string, ...args: any[]): this;
}

export { Entity, System, Engine, StateManager, Events };
