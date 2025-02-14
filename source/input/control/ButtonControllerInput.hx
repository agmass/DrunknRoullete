package input.control;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadAnalogStick;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton;

class ButtonControllerInput implements Input {
    public var positiveKey:Array<FlxGamepadInputID> = new Array();
    var gamepad:FlxGamepad;
	public var hiddenFromControls:Bool = false;

	public function new(gamepad, ?positiveKey:Array<FlxGamepadInputID>)
	{
        this.positiveKey = positiveKey;
        this.gamepad = gamepad;
	}
    public function value():Bool {
        return pressed();
    }

    public function pressed():Bool {
        return gamepad.anyPressed(positiveKey);
    }
    public function justPressed():Bool {
        return gamepad.anyJustPressed(positiveKey);
    }


	public function name():String
	{
		var txt = "";
		for (d in positiveKey)
		{
			txt += FlxGamepadInputID.toStringMap.get(d) + ", ";
		}
		return txt;
	}
}