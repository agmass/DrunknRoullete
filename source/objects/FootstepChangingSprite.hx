package objects;

import entity.Entity;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.util.FlxColor;

class FootstepChangingSprite extends FlxNapeSprite
{
	public var footstepSoundName = "concrete";

	override public function new(x, y, surfaceName)
	{
		super(x, y, null, false, true);
		footstepSoundName = surfaceName;
	}
	override function makeGraphic(width:Int, height:Int, color:FlxColor = FlxColor.WHITE, unique:Bool = false, ?key:String):FlxSprite
	{
		var graphiced = super.makeGraphic(width, height, color, unique, key);
		createRectangularBody();
		body.allowMovement = false;
		body.allowRotation = false;
		return graphiced;
	}
}