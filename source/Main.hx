package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.util.FlxColor;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, PlayState));
		addChild(new FPS(FlxG.width-80,20,FlxColor.WHITE));
	}
}
