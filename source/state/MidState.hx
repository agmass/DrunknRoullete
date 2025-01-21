package state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import objects.Elevator;

class MidState extends TransitionableState
{
	var elevator:Elevator = new Elevator(0, 0);
	var bg:FlxSprite = new FlxSprite(0, 0, AssetPaths.elevator_buttons_bg__png);

	override function create()
	{
		elevator.screenCenter();
		add(elevator);
		add(bg);
		bg.scale.set(2, 2);
		bg.updateHitbox();
		super.create();
	}

	var s = 0.0;
	var targetAngle = 0.0;
	var originalAngle = 0.0;
	var breath = 1.0;

	override function update(elapsed:Float)
	{
		bg.x = elevator.x - (bg.width + 120);
		bg.y = elevator.y - 128;
		s += elapsed;
		breath += elapsed * 0.3;
		elevator.angle = FlxMath.lerp(originalAngle, targetAngle, breath);
		if (breath >= 1)
		{
			breath = 0;
			targetAngle = FlxG.random.float(-8, 8);
			originalAngle = elevator.angle;
		}
		if (FlxG.keys.justPressed.P)
		{
			FlxG.switchState(new PlayState());
		}
		elevator.y += Math.sin(s) * 0.3;
		super.update(elapsed);
	}
}