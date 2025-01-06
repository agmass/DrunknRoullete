package input;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton;
import flixel.math.FlxPoint;
import input.control.KeyOrMouseInput;

class KeyboardSource extends InputSource {

    public var shoot:KeyOrMouseInput = new KeyOrMouseInput([], [FlxMouseButton.getByID(FlxMouseButtonID.LEFT)]);
    public var W:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.W,FlxKey.UP], []);
    public var A:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.A,FlxKey.LEFT], []);
    public var S:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.S,FlxKey.DOWN], []);
    public var D:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.D,FlxKey.RIGHT], []);
	public var backslot:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.F], []);
    public var dash:KeyOrMouseInput = new KeyOrMouseInput([FlxKey.SPACE, FlxKey.SHIFT], []);

    override function update() {
        attackJustPressed = shoot.justPressed();
        attackPressed = shoot.pressed();
        jumpJustPressed = W.justPressed();
        jumpPressed = W.pressed();
        dashJustPressed = dash.justPressed();
        dashPressed = dash.pressed();
		backslotJustPressed = backslot.justPressed();
		backslotPressed = backslot.pressed();
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
    
}