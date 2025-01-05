package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.util.FlxColor;
import openfl.display.FPS;
import openfl.display.Sprite;
import sound.FootstepManager;
import util.Language;

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

	public static var FPS:FPS;

	public function new()
	{
		super();
		trace(attribution);
		FPS = new FPS(0, 20, FlxColor.WHITE);
		addChild(FPS);
		addChild(new FlxGame(0, 0, PlayState));
		FootstepManager.loadSurface("concrete");
		FootstepManager.loadSurface("wood");
		FootstepManager.loadSurface("carpet");
		Language.refreshLanguages();
		Language.changeLanguage("en_us");

	}	
}
