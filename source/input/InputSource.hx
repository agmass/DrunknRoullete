package input;

/*

    Modified code
    File originally from "Iris", 2024 by agmas (me! :3)

*/

import flixel.math.FlxPoint;
import input.control.Input;
import input.control.KeyOrMouseInput;

class InputSource {

    public var hiddenFromMenus:Bool = false;
    public var controlsSaveName:String = "";

    // Above variables aren't implemented yet, but could be used for making online modes and control options

	public var translationKey:String = "none";
    public var attackPressed = false;
    public var attackJustPressed = false;

    public var jumpPressed = false;
    public var jumpJustPressed = false;

    public var dashPressed = false;
    public var dashJustPressed = false;

	public var backslotPressed = false;
	public var backslotJustPressed = false;

	public var altFirePressed = false;
	public var altFireJustPressed = false;

	public var interactFirePressed = false;
	public var interactJustPressed = false;

	public var ui_accept = false;
	public var ui_left = false;
	public var ui_right = false;
	public var ui_hold_accept = false;
	public var ui_deny = false;
	public var ui_menu = false;
	public var lastMovement = new FlxPoint();

    public function new() {}

    public function update() {}

    public function getMovementVector():FlxPoint {
        return new FlxPoint(0,0);
    }

	public function getLookAngle(origin:FlxPoint):Float
	{
		return 0;
	}

	public function toString():String
    {
        var string = "";
        for (s in Reflect.fields(this)) {
            if (Reflect.getProperty(this, s) is Input) {
                var inp = cast(Reflect.getProperty(this, s), Input);
                string += "\n      " + s + ": " + Std.string(inp.value());
            }
        }
        string += "\n      Movement: " + getMovementVector();
        return string;
    }
	public function uiAcceptName():String
	{
		return "[Undefined]";
	}
    
}