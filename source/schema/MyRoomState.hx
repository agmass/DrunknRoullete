// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 2.0.36
// 
package schema;


import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class MyRoomState extends Schema {
	@:type("map", NetPlayer)
	public var players: MapSchema<NetPlayer> = new MapSchema<NetPlayer>();

	@:type("map", Entity)
	public var networkedSprites:MapSchema<Entity> = new MapSchema<Entity>();

	@:type("number")
	public var seed: Dynamic = 0;

	@:type("number")
	public var inseed: Dynamic = 0;

	@:type("number")
	public var ui_selection:Dynamic = 0;

	@:type("number")
	public var globalTimer:Dynamic = 0;

	@:type("string")
	public var currentState: String = "";

	@:type("string")
	public var encodedRun:String = "";

	@:type("string")
	public var hostId: String = "";

}
