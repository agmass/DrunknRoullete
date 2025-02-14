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
	public var vertical_look:AnalogControllerInput;
	public var horizontal_look:AnalogControllerInput;
    public var dash:ButtonControllerInput;
    public var jump:ButtonControllerInput;
	public var backslot:ButtonControllerInput;
	public var alt_fire:ButtonControllerInput;
	public var interact:ButtonControllerInput;
	public var accept:ButtonControllerInput;
	public var deny:ButtonControllerInput;
	public var menu:ButtonControllerInput;
	public var right:ButtonControllerInput;
	public var left:ButtonControllerInput;
    public var gamepad:FlxGamepad;

    public function new(gamepad:FlxGamepad) {
        super();
        this.gamepad = gamepad;
		translationKey = gamepad.name;
        vertical = new AnalogControllerInput(gamepad,ControllerDirection.Y,[FlxGamepadInputID.LEFT_ANALOG_STICK],[FlxGamepadInputID.DPAD_DOWN],[FlxGamepadInputID.DPAD_UP]);
        horizontal = new AnalogControllerInput(gamepad,ControllerDirection.X,[FlxGamepadInputID.LEFT_ANALOG_STICK],[FlxGamepadInputID.DPAD_RIGHT],[FlxGamepadInputID.DPAD_LEFT]);
		vertical_look = new AnalogControllerInput(gamepad, ControllerDirection.Y, [FlxGamepadInputID.RIGHT_ANALOG_STICK], []);
		horizontal_look = new AnalogControllerInput(gamepad, ControllerDirection.X, [FlxGamepadInputID.RIGHT_ANALOG_STICK], []);

		shoot = new ButtonControllerInput(gamepad, [FlxGamepadInputID.RIGHT_TRIGGER]);
		alt_fire = new ButtonControllerInput(gamepad, [FlxGamepadInputID.LEFT_TRIGGER]);
        jump = new ButtonControllerInput(gamepad,[FlxGamepadInputID.A]);
        dash = new ButtonControllerInput(gamepad,[FlxGamepadInputID.B]);
		backslot = new ButtonControllerInput(gamepad, [FlxGamepadInputID.Y]);
		interact = new ButtonControllerInput(gamepad, [FlxGamepadInputID.X]);
		accept = new ButtonControllerInput(gamepad, [FlxGamepadInputID.A]);
		deny = new ButtonControllerInput(gamepad, [FlxGamepadInputID.B]);
		menu = new ButtonControllerInput(gamepad, [FlxGamepadInputID.START]);
		right = new ButtonControllerInput(gamepad, [FlxGamepadInputID.RIGHT_SHOULDER]);
		left = new ButtonControllerInput(gamepad, [FlxGamepadInputID.LEFT_SHOULDER]);
    }


    override function update() {
        attackJustPressed = shoot.justPressed();
        attackPressed = shoot.pressed();
        jumpJustPressed = jump.justPressed();
        jumpPressed = jump.pressed();
        dashJustPressed = dash.justPressed();
        dashPressed = dash.pressed();
		backslotJustPressed = backslot.justPressed();
		backslotPressed = backslot.pressed();
		altFireJustPressed = alt_fire.justPressed();
		altFirePressed = alt_fire.pressed();
		interactJustPressed = interact.justPressed();
		interactFirePressed = interact.pressed();
		ui_deny = deny.pressed();
		ui_accept = accept.justPressed();
		ui_hold_accept = accept.pressed();
		ui_menu = menu.justPressed();
		ui_right = right.pressed();
		ui_left = left.justPressed();
		menu.hiddenFromControls = true;
		right.hiddenFromControls = true;
		left.hiddenFromControls = true;
        super.update();
	}
	var lastView = 0.0;

	override function getLookAngle(origin:FlxPoint):Float
	{
		if (FlxG.save.data.lookAtMovement)
		{
			return new FlxPoint(-horizontal.value(), -vertical.value()).degrees;
		}
		if (!new FlxPoint(-horizontal_look.value(), -vertical_look.value()).isZero())
		{
			lastView = new FlxPoint(-horizontal_look.value(), -vertical_look.value()).degrees;
		}
		return lastView;
	}

    override function getMovementVector():FlxPoint {
        return new FlxPoint(horizontal.value(), vertical.value());
    }

	override function uiAcceptName():String
	{
		return accept.positiveKey[0].toString();
	}
    
}