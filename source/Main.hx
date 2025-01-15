package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxColor;
import nape.geom.Vec2;
import nape.space.Space;
import openfl.display.FPS;
import openfl.display.Sprite;
import sound.FootstepManager;
import state.MenuState;
import util.EnviornmentsLoader;
import util.Language;
#if html5
import js.Browser;
#end

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

		\"Empty Weapons (Sound effect)\" by BoostSound
		https://www.youtube.com/watch?v=dBJUIYv52Xw


		All following sounds are by creators from Pixabay.

		\"Glass Bottle Smash\" by Universfield
		\"Glass Hit\" by Universfield

		All following sounds are by creators from Freesound.

		\"Sword Swings\" by samsterbirdies
		\"Swoosh\" by porkmucher
		\"Rock Hit\" by link boy
		
		# Silly Quotes

		\"drunk soviet simulator\" - __REDACTED__
	";

	public static var FPS:FPS;
	public static var subtitles:Map<String, Float> = [];
	public static var audioPanner:FlxSprite;
	public static var activeGamepads:Array<FlxGamepad> = [];
	public static var kbmConnected = false;
	public static var connectionsDirty = false;
	public static var napeSpace:Space;

	public function new()
	{
		super();
		trace(attribution);
		FPS = new FPS(0, 20, FlxColor.WHITE);
		addChild(FPS);
		napeSpace = new Space(new Vec2(0, 1200));
		MultiSoundManager.loadMultiSounds();
		MultiSoundManager.loadSurfaces();
		EnviornmentsLoader.loadEnviornments();
		Language.refreshLanguages();
		Language.changeLanguage("en_us");
		MultiSoundManager.footstepVolume.set("carpet", 0.15);
		MultiSoundManager.footstepVolume.set("wood", 0.75);
		addChild(new FlxGame(0, 0, MenuState));
		#if html5
		FlxG.stage.showDefaultContextMenu = false;
		Browser.document.addEventListener("mousedown", (event) ->
		{
			event.preventDefault();
		}, {capture: false, passive: false});
		#end
	}

	public static function detectConnections()
	{
		if (FlxG.keys.justPressed.O)
			FlxG.fullscreen = !FlxG.fullscreen;
		for (gamepad in FlxG.gamepads.getActiveGamepads())
		{
			if (!Main.activeGamepads.contains(gamepad))
			{
				Main.activeGamepads.push(gamepad);
				connectionsDirty = true;
			}
		}
		if (FlxG.keys.firstPressed() != -1 || FlxG.mouse.justPressed)
		{
			kbmConnected = true;
			connectionsDirty = true;
		}
	}
}
