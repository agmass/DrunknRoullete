// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 2.0.36
//
package schema;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class NetPlayer extends Entity {
	@:type("boolean")
	public var attackPressed: Bool = false;

	@:type("boolean")
	public var jumpPressed: Bool = false;

	@:type("boolean")
	public var dashPressed: Bool = false;

	@:type("boolean")
	public var backslotPressed: Bool = false;

	@:type("boolean")
	public var altFirePressed: Bool = false;

	@:type("boolean")
	public var interactPressed: Bool = false;

	@:type("boolean")
	public var ui_acceptPressed: Bool = false;

	@:type("boolean")
	public var ui_denyPressed: Bool = false;

	@:type("boolean")
	public var ui_menuPressed: Bool = false;

	@:type("number")
	public var movement_x: Dynamic = 0;

	@:type("number")
	public var movement_y: Dynamic = 0;

	@:type("number")
	public var lastTimestamp:Dynamic = 0;

	@:type("number")
	public var randomAtLastTimestamp:Dynamic = 0;

}
