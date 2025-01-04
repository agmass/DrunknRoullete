package input;

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

    public function new() {}

    public function update() {}

    public function getMovementVector():FlxPoint {
        return new FlxPoint(0,0);
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
    
}