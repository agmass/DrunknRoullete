package sound;

import entity.Entity;
import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.system.FlxAssets;
import haxe.ds.HashMap;
import openfl.Assets;
import util.Language;

class MultiSoundManager
{
	public static var surfaceMap:Map<String, Array<String>> = new Map();
	public static var footstepVolume:Map<String, Float> = new Map();
	public static var multiSounds:Map<String, Array<String>> = new Map();

	/**
	 *	WARNING!! expensive if a lot of assets. only use when initializing
	 */
	public static function loadSurfaces()
	{
		for (i in AssetPaths.allFiles)
		{
			if (StringTools.startsWith(i, "assets/sounds/footsteps/"))
			{
				var cut = i.substring(24).split("/")[0];
				if (!surfaceMap.exists(cut))
				{
					surfaceMap.set(cut, []);
					trace("Found new footstep surface: " + cut);
				}
				surfaceMap.get(cut).push(i);
			}
		}
	}

	/**
		WARNING!! expensive if a lot of assets. only use when initializing
	 */
	public static function loadMultiSounds()
	{
		for (i in AssetPaths.allFiles)
		{
			if (StringTools.startsWith(i, "assets/sounds/multisound/"))
			{
				var cut = i.substring(25).split("/")[0];
				if (!multiSounds.exists(cut))
				{
					trace("Found new multisound: " + cut);
					multiSounds.set(cut, []);
				}
				multiSounds.get(cut).push(i);
			}
		}
	}

	public static function playRandomSoundByItself(x, y, soundName:String, ?pitch = 1.0, ?volume = 1.0)
	{
		Main.subtitles.set(Language.get("subtitle." + soundName), 4);
		var sound = FlxG.sound.play(multiSounds.get(soundName)[FlxG.random.int(0, multiSounds.get(soundName).length - 1)]);
		sound.proximity(x, y, Main.audioPanner, 1920, true);
		sound.pitch = pitch;
		sound.volume = volume;
	}
	public static function playRandomSound(entity:Entity, soundName:String, ?pitch = 1.0, ?volume = 1.0)
	{
		Main.subtitles.set(Language.get("subtitle." + soundName), 4);
		var sound = FlxG.sound.play(multiSounds.get(soundName)[FlxG.random.int(0, multiSounds.get(soundName).length - 1)]);
		sound.proximity(entity.x, entity.y, Main.audioPanner, 1920, true);
		sound.pitch = pitch;
		sound.volume = volume;
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
			Main.subtitles.set(Language.get("subtitle.footsteps"), 4);
			var sound = FlxG.sound.play(surfaceMap.get(entity.steppingOn)[entity.footstepCount]);
			sound.proximity(entity.x, entity.y, Main.audioPanner, 1920, true);
			sound.volume = footstepVolume.exists(entity.steppingOn) ? footstepVolume.get(entity.steppingOn) : 1;
		}
	}
}