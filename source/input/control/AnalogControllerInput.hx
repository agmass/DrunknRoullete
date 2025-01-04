package input.control;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadAnalogStick;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton;

class AnalogControllerInput implements Input {
    public var stick:Array<FlxGamepadInputID> = new Array();
    public var positiveKey:Array<FlxGamepadInputID> = new Array();
    public var negativeKey:Array<FlxGamepadInputID> = new Array();
    public var direction:ControllerDirection;
    var gamepad:FlxGamepad;

    public function new(gamepad, dir=ControllerDirection.BOTH,?stick:Array<FlxGamepadInputID>, ?positiveKey:Array<FlxGamepadInputID>, ?negativeKey:Array<FlxGamepadInputID>) {
        this.stick = stick;
        this.positiveKey = positiveKey;
        this.negativeKey = negativeKey;
        direction = dir;
        this.gamepad = gamepad;
    }
    

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