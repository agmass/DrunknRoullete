package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxColor;
import input.ControllerSource;
import input.InputSource;
import input.KeyboardSource;
import input.control.Input;
import nape.geom.Vec2;
import nape.space.Space;
import openfl.display.FPS;
import openfl.display.Sprite;
import sound.FootstepManager;
import state.MenuState;
import util.EnviornmentsLoader;
import util.Language;
import util.Run;
import util.SubtitlesBox;
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

		\"Snake's SECOND Authentic Gun Sounds Pack\"
		https://f8studios.itch.io/snakes-second-authentic-gun-sounds-pack
		
		\"Empty Weapons (Sound effect)\" by BoostSound
		https://www.youtube.com/watch?v=dBJUIYv52Xw


		All following sounds are by creators from Pixabay.

		\"Glass Bottle Smash\" by Universfield
		\"Glass Hit\" by Universfield
		\"gun cocking sound\" by FreeSoundxx
		\"Clank1\" by freesound_community
		\"Rattle1\" by freesound_community
		\"Mechanical1\" by freesound_community

		All following sounds are by creators from Freesound.

		\"Sword Swings\" by samsterbirdies
		\"Swoosh\" by porkmucher
		\"Rock Hit\" by link boy
		
		# Silly Quotes

		\"drunk soviet simulator\" - __REDACTED__
		\"Cant believe how evil red guy is\" - smorrebrot
	";

	public static var FPS:FPS;
	public static var subtitlesBox:SubtitlesBox;
	public static var subtitles:Map<String, Float> = [];
	public static var audioPanner:FlxSprite;
	public static var activeGamepads:Array<FlxGamepad> = [];
	public static var activeInputs:Array<InputSource> = [];
	public static var kbmConnected = false;
	public static var connectionsDirty = false;
	public static var napeSpace:Space;
	public static var run:Run;

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
		subtitlesBox = new SubtitlesBox();
	}

	public static function detectConnections()
	{
		for (source in activeInputs)
		{
			source.update();
		}
		if (FlxG.keys.justPressed.O)
			FlxG.fullscreen = !FlxG.fullscreen;
		for (gamepad in FlxG.gamepads.getActiveGamepads())
		{
			if (!Main.activeGamepads.contains(gamepad))
			{
				Main.activeGamepads.push(gamepad);
				activeInputs.push(new ControllerSource(gamepad));
				connectionsDirty = true;
			}
		}
		if (FlxG.keys.firstPressed() != -1 || FlxG.mouse.justPressed)
		{
			if (!kbmConnected)
			{
				kbmConnected = true;
				connectionsDirty = true;
				activeInputs.push(new KeyboardSource());
			}
		}
	}
}
