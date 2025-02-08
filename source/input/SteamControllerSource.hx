package input;

#if cpp
import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton;
import flixel.math.FlxPoint;
import input.control.AnalogControllerInput;
import input.control.ButtonControllerInput;
import input.control.ControllerDirection;
import input.control.KeyOrMouseInput;
import steamwrap.api.Controller;
import steamwrap.api.Steam;

// To finish
class SteamControllerSource extends InputSource
{
	public var gamepadId:Int;

	public function new(gamepad:Int)
	{
		super();
		this.gamepadId = gamepad;
		translationKey = "Steam Input";
	}

	override function update()
	{
		super.update();
	}
}
#end