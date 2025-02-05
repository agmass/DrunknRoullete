// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 2.0.36
// 
package schema;


import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class Entity extends Schema {
	@:type("number")
	public var x: Dynamic = 0;

	@:type("number")
	public var y: Dynamic = 0;

	@:type("number")
	public var angle: Dynamic = 0;

	@:type("number")
	public var health: Dynamic = 0;

	@:type("string")
	public var entityClass: String = "";

	@:type("string")
	public var targetGroup:String = "";

}
