import { Schema, Context, type, ArraySchema, MapSchema } from "@colyseus/schema";


export class Entity extends Schema {

  @type("number") x: number = 0;
  @type("number") y: number = 0;
  @type("number") angle: number = 0;
  @type("number") health: number = 100;
  @type("string") entityClass: string = "";
  @type("string") targetGroup: string = "";

}


export class NetEquippedEntity extends Schema {

  @type("string") weapon1Class: string = "";
  @type("string") weapon2Class: string = "";

}

export class NetPlayer extends Entity {

  @type("boolean") attackPressed: boolean = false;
  @type("boolean") jumpPressed: boolean = false;
  @type("boolean") dashPressed: boolean = false;
  @type("boolean") backslotPressed: boolean = false;
  @type("boolean") altFirePressed: boolean = false;
  @type("boolean") interactPressed: boolean = false;

  @type("boolean") ui_acceptPressed: boolean = false;
  @type("boolean") ui_denyPressed: boolean = false;
  @type("boolean") ui_menuPressed: boolean = false;

  @type("number") movement_x: number = 0;
  @type("number") movement_y: number = 0;
  @type("number") lastTimestamp: number = 0;
  @type("number") randomAtLastTimestamp: number = 0;
}

export class MyRoomState extends Schema {

  @type({ map: NetPlayer }) players  = new MapSchema<NetPlayer>();
  @type({ map: Entity }) networkedSprites  = new MapSchema<Entity>();

  @type("number") seed: number = 0;
  @type("number") inseed: number = 0;
  @type("number") ui_selection: number = 0;
  @type("number") globalTimer: number = 0;

  @type("string") currentState: string = "";
  @type("string") encodedRun: string = "";
  @type("string") hostId: string = "";
}
