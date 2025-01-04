package objects;

import entity.Entity;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;

class FootstepChangingSprite extends FlxSprite
{
	public var footstepSoundName = "concrete";

	override public function new(x, y, surfaceName)
	{
		super(x, y);
		footstepSoundName = surfaceName;
	}
}