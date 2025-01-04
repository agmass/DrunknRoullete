package input;

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

class ControllerSource extends InputSource {

    public var shoot:ButtonControllerInput;
    public var vertical:AnalogControllerInput;
    public var horizontal:AnalogControllerInput;
    public var dash:ButtonControllerInput;
    public var jump:ButtonControllerInput;
    public var gamepad:FlxGamepad;

    public function new(gamepad:FlxGamepad) {
        super();
        this.gamepad = gamepad;
        vertical = new AnalogControllerInput(gamepad,ControllerDirection.Y,[FlxGamepadInputID.LEFT_ANALOG_STICK],[FlxGamepadInputID.DPAD_DOWN],[FlxGamepadInputID.DPAD_UP]);
        horizontal = new AnalogControllerInput(gamepad,ControllerDirection.X,[FlxGamepadInputID.LEFT_ANALOG_STICK],[FlxGamepadInputID.DPAD_RIGHT],[FlxGamepadInputID.DPAD_LEFT]);
        shoot = new ButtonControllerInput(gamepad,[FlxGamepadInputID.LEFT_TRIGGER]);
        jump = new ButtonControllerInput(gamepad,[FlxGamepadInputID.A]);
        dash = new ButtonControllerInput(gamepad,[FlxGamepadInputID.B]);
    }

    override function update() {
        attackJustPressed = shoot.justPressed();
        attackPressed = shoot.pressed();
        jumpJustPressed = jump.justPressed();
        jumpPressed = jump.pressed();
        dashJustPressed = dash.justPressed();
        dashPressed = dash.pressed();
        super.update();
    }

    override function getMovementVector():FlxPoint {
        return new FlxPoint(horizontal.value(), vertical.value());
    }
    
}