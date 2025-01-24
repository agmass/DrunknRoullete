package input;

import flixel.math.FlxPoint;

class ModifiableInputSource extends InputSource
{
	public var movement:FlxPoint = new FlxPoint();
	public var look:Float = 0;

	override function getMovementVector():FlxPoint
	{
		return movement;
	}

	override function getLookAngle(origin:FlxPoint):Float
	{
		return look;
	}
}