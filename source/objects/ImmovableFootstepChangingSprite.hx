package objects;

import entity.Entity;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.util.FlxColor;

class ImmovableFootstepChangingSprite extends FootstepChangingSprite
{
	public var ambientEdition:FootstepChangingSprite;

	override public function new(x, y, surfaceName)
	{
		super(x, y, surfaceName);
		ambientEdition = new FootstepChangingSprite(x, y, surfaceName);
	}

	override function makeGraphic(width:Int, height:Int, color:FlxColor = FlxColor.WHITE, unique:Bool = false, ?key:String):FlxSprite
	{
		var graphiced = super.makeGraphic(width, height, color, unique, key);
		body.allowMovement = false;
		body.allowRotation = false;
		ambientEdition.makeGraphic(width, height, color, unique, key);
		ambientEdition.body.allowMovement = false;
		ambientEdition.body.allowRotation = false;
		ambientEdition.body.space = Main.napeSpaceAmbient;
		return graphiced;
	}
}