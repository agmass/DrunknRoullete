package input;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton;
import flixel.math.FlxPoint;
import input.control.KeyOrMouseInput;

class KeyboardSource extends InputSource {

	public var shoot:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.X], [FlxMouseButton.getByID(FlxMouseButtonID.LEFT)]);
	public var alt_fire:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.C], [FlxMouseButton.getByID(FlxMouseButtonID.RIGHT)]);
    public var W:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.W,FlxKey.UP], []);
    public var A:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.A,FlxKey.LEFT], []);
    public var S:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.S,FlxKey.DOWN], []);
    public var D:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.D,FlxKey.RIGHT], []);
	public var interact:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.E], []);
	public var backslot:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.F], []);
	public var accept:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.SPACE, FlxKey.ENTER], [FlxMouseButton.getByID(FlxMouseButtonID.LEFT)]);
	public var deny:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.ESCAPE, FlxKey.B], []);
	public var dash:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.SPACE, FlxKey.SHIFT], []);

	override public function new()
	{
		super();
		translationKey = "input.keyboard";
	}

    override function update() {
        attackJustPressed = shoot.justPressed();
        attackPressed = shoot.pressed();
        jumpJustPressed = W.justPressed();
        jumpPressed = W.pressed();
        dashJustPressed = dash.justPressed();
        dashPressed = dash.pressed();
		backslotJustPressed = backslot.justPressed();
		backslotPressed = backslot.pressed();
		altFireJustPressed = alt_fire.justPressed();
		altFirePressed = alt_fire.pressed();
		interactJustPressed = interact.justPressed();
		interactFirePressed = interact.pressed();
		ui_accept = accept.justPressed();
		ui_hold_accept = accept.pressed();
		ui_deny = deny.justPressed();
        super.update();
    }

	override function getLookAngle(origin:FlxPoint):Float
	{
		return origin.degreesFrom(new FlxPoint(FlxG.mouse.x, FlxG.mouse.y));
	}

    override function getMovementVector():FlxPoint {
        var x = 0;
        var y = 0;
        if (!(A.pressed() && D.pressed())) {
            if (A.pressed()) {
                x = -1;
            } else if (D.pressed()) {
                x = 1;
            }
        }
        if (!(W.pressed() && S.pressed())) {
            if (W.pressed()) {
                y = -1;
            } else if (S.pressed()) {
                y = 1;
            }
        }
        return new FlxPoint(x,y);
    }
    
	override function uiAcceptName():String
	{
		return accept.key[0].toString();
	}
}