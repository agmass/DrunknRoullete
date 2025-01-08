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


		All following sounds are by creators from Freesound.

		\"Sword Swings\" by samsterbirdies
		\"Swoosh\" by porkmucher
		\"Rock Hit\" by link boy
	";

	public static var FPS:FPS;
	public static var subtitles:Map<String, Float> = [];

	public function new()
	{
		super();
		trace(attribution);
		FPS = new FPS(0, 20, FlxColor.WHITE);
		addChild(FPS);
		addChild(new FlxGame(0, 0, PlayState));
		MultiSoundManager.loadMultiSounds();
		MultiSoundManager.loadSurfaces();
		Language.refreshLanguages();
		Language.changeLanguage("en_us");

	}	
}
