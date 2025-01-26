package substate;

import flixel.FlxSprite;
import flixel.FlxSubState;

class RoulleteSubState extends FlxSubState
{
	var wheel:FlxSprite = new FlxSprite(0, 0, AssetPaths.roulette__png);
	var ball:FlxSprite = new FlxSprite(0, 0, AssetPaths.ball__png);

	override function create()
	{
		super.create();
		wheel.scale.set(4, 4);
		wheel.updateHitbox();
		wheel.screenCenter();
		add(wheel);
	}

	override function update(elapsed:Float)
	{
		wheel.angle -= elapsed * 80;
		super.update(elapsed);
	}
}