package util;

import flixel.math.FlxMath;
import flixel.math.FlxRandom;

class ServerDecidedRandom extends FlxRandom
{
	public var cappedSeed = 0;

	override function float(Min:Float = 0, Max:Float = 1, ?Excludes:Array<Float>):Float
	{
		currentSeed = cappedSeed;
		initialSeed = cappedSeed;
		return super.float(Min, Max, Excludes);
	}

	override function int(Min:Int = 0, Max:Int = FlxMath.MAX_VALUE_INT, ?Excludes:Array<Int>):Int
	{
		currentSeed = cappedSeed;
		initialSeed = cappedSeed;
		return super.int(Min, Max, Excludes);
	}
}