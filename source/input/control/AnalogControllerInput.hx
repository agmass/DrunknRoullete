package input.control;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadAnalogStick;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton;
import flixel.ui.FlxAnalog;

class AnalogControllerInput implements Input {
    public var stick:Array<FlxGamepadInputID> = new Array();
    public var positiveKey:Array<FlxGamepadInputID> = new Array();
    public var negativeKey:Array<FlxGamepadInputID> = new Array();
    public var direction:ControllerDirection;
    var gamepad:FlxGamepad;
	public var hiddenFromControls:Bool = false;

	public function new(gamepad, dir = ControllerDirection.BOTH, ?stick:Array<FlxGamepadInputID>, ?positiveKey:Array<FlxGamepadInputID>,
			?negativeKey:Array<FlxGamepadInputID>,)
	{
		if (stick != null)
			this.stick = stick;
		if (positiveKey != null)
			this.positiveKey = positiveKey;
		if (negativeKey != null)
			this.negativeKey = negativeKey;
        direction = dir;
        this.gamepad = gamepad;
    }

	public function name():String
	{
		var txt = "";
		for (d in stick)
		{
			txt += FlxGamepadInputID.toStringMap.get(d) + ", ";
		}
		return txt;
	} // we dont change positive or negative keys because i really dont want to make a more complicated input changing system so uhh sowwy :3

    public function value():Float {
        var finalValue = 0.0;
        for (stickID in stick) {
            var currentStick = gamepad.getAnalogAxes(stickID);
            switch (direction) {
                case ControllerDirection.X:
                    finalValue += currentStick.x;
                case ControllerDirection.Y:
                    finalValue += currentStick.y;
                case ControllerDirection.BOTH:
                    finalValue += currentStick.y;
                    finalValue += currentStick.x;
            }
        }
        if (gamepad.anyPressed(positiveKey))
            finalValue += 1;
        if (gamepad.anyPressed(negativeKey))
            finalValue -= 1;
        return finalValue;
    }


}