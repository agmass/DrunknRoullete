package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.util.FlxColor;
import openfl.display.FPS;
import openfl.display.Sprite;
import sound.FootstepManager;

class Main extends Sprite
{
	public var attribution:String = "
		-----------
		Attribution
		-----------

		# Sounds

		AudioElk's \"Free Sounds - Footsteps Collection\"
		https://audioelk.itch.io/free-sounds-footsteps-collection

		\"Footstep Sounds by Dryoma\"
		https://dryoma.itch.io/footsteps-sounds
	";


	public function new()
	{
		super();
		trace(attribution);
		addChild(new FlxGame(0, 0, PlayState));
		addChild(new FPS(FlxG.width-80,20,FlxColor.WHITE));
		FootstepManager.loadSurface("concrete");
		FootstepManager.loadSurface("wood");
		FootstepManager.loadSurface("carpet");
	}	
}
