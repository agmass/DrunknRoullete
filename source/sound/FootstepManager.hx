package sound;

import entity.Entity;
import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.system.FlxAssets;
import haxe.ds.HashMap;
import openfl.Assets;

class FootstepManager
{
	public static var surfaceMap:Map<String, Array<String>> = new Map();

	/*
		WARNING!! expensive if a lot of assets. only use when initializingg
	 */
	public static function loadSurface(surfaceName:String)
	{
		surfaceMap.set(surfaceName, []);
		for (i in AssetPaths.allFiles)
		{
			if (StringTools.startsWith(i, "assets/sounds/footsteps/" + surfaceName))
			{
				surfaceMap.get(surfaceName).push(i);
			}
		}
	}

	public static function playFootstepForEntity(entity:Entity)
	{
		if (entity.isTouching(FLOOR))
		{
			if (entity.footstepCount >= surfaceMap.get(entity.steppingOn).length - 1)
			{
				entity.footstepCount = -1;
			}
			entity.footstepCount++;
			FlxG.sound.play(surfaceMap.get(entity.steppingOn)[entity.footstepCount]);
		}
	}
}