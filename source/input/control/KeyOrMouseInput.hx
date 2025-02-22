package input.control;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton;

class KeyOrMouseInput implements Input{
    public var key:Array<FlxKey>;
    public var mouse:Array<FlxMouseButton>;
	public var hiddenFromControls:Bool = false;

    public function new(?key:Array<FlxKey>, ?mouse:Array<FlxMouseButton>) {
        this.key = key;
        this.mouse = mouse;
    }

    public function value():Dynamic {
        return pressed();
    }

    public function justPressed():Bool {
        if (FlxG.keys.anyJustPressed(key)) {
            return true;
        }
        for (m in mouse) {
            if (m.justPressed) {
                return true;
            }
        }
        return false;
    }


    public function pressed():Bool {
        if (FlxG.keys.anyPressed(key)) {
            return true;
        }
        for (m in mouse) {
            if (m.pressed) {
                return true;
            }
        }
        return false;
    }
	public function name():String
	{
		var txt = "";
		for (d in mouse)
		{
			txt += "MOUSE" + d.ID + ", ";
		}
		for (d in key)
		{
			txt += FlxKey.toStringMap.get(d) + ", ";
		}
		txt = txt.substring(0, txt.length - 2);
		return txt;
	}

	public function nameWithOr():String
	{
		var txt = "";
		for (d in mouse)
		{
			txt += "MOUSE" + d.ID + " or ";
		}
		for (d in key)
		{
			txt += FlxKey.toStringMap.get(d) + " or ";
		}
		txt = txt.substring(0, txt.length - 4);
		return txt;
	}
}