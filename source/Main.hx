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

		\"Spin Prize Wheel Sound Effects All Sounds\" by All Sounds
		https://www.youtube.com/watch?v=FvGBTtaV-6U


		All following sounds are by creators from Pixabay.

		\"Glass Bottle Smash\" by Universfield
		\"Glass Hit\" by Universfield
		\"gun cocking sound\" by FreeSoundxx
		\"Clank1\" by freesound_community
		\"Rattle1\" by freesound_community
		\"Mechanical1\" by freesound_community
		\"Hit Flesh 02\" by u_xjrmmgxfru

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
		FlxG.save.bind("brj2025");
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
		var link = Browser.document.createLinkElement();
		link.href = "assets/data/styles.css";
		link.type = "text/css";
		link.rel = "stylesheet";
		link.media = "screen,print";
		Browser.document.head.appendChild(link);
		FlxG.stage.showDefaultContextMenu = false;
		Browser.document.addEventListener("mousedown", (event) ->
		{
			event.preventDefault();
		}, {capture: false, passive: false});
		Browser.document.addEventListener('keydown', function(event)
		{
			if (event.key == "Enter")
			{
				if (Browser.document.getElementById("cutscene") != null)
				{
					Browser.document.getElementById("openfl-content").hidden = false;
					Browser.document.getElementById("cutscene").remove();
					Browser.document.getElementById("cutsceneNotice").remove();
					playingVideo = false;
					for (camera in FlxG.cameras.list)
					{
						camera.fade(FlxColor.BLACK, 0.5, true);
					}
				}
			}
		});
		#end
		subtitlesBox = new SubtitlesBox();
	}

	public static function detectConnections()
	{
		for (source in activeInputs)
		{
			source.update();
			if (FlxG.save.data.disableKeyboard && source is KeyboardSource)
			{
				activeInputs.remove(source);
			}
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
				if (FlxG.save.data.disableKeyboard)
					return;
				kbmConnected = true;
				connectionsDirty = true;
				activeInputs.push(new KeyboardSource());
			}
		}
	}
	public static var playingVideo = false;

	#if html5
	public static function playVideo(url)
	{
		// taken from the flopped game site-2d i made like a year ago

		if (!playingVideo)
		{
			playingVideo = true;
			var fallenKingdom = Browser.document.createVideoElement();
			fallenKingdom.autoplay = true;
			fallenKingdom.setAttribute("disablePictureInPicture", "true");
			fallenKingdom.width = 1920;
			fallenKingdom.id = "cutscene";
			fallenKingdom.height = 1080;
			fallenKingdom.style.position = "absolute";
			fallenKingdom.src = url;
			Browser.document.body.appendChild(fallenKingdom);
			var notice = Browser.document.createElement("h1");
			notice.style.color = "red";
			notice.className = "notice";
			notice.id = "cutsceneNotice";
			notice.style.zIndex = "99";
			Browser.document.body.appendChild(notice);
			Browser.document.getElementById("openfl-content").hidden = true;
			fallenKingdom.addEventListener("ended", (e) ->
			{
				Browser.document.getElementById("openfl-content").hidden = false;
				Browser.document.body.removeChild(fallenKingdom);
				fallenKingdom.remove();
				Browser.document.body.removeChild(notice);
				notice.remove();
				playingVideo = false;

				for (camera in FlxG.cameras.list)
				{
					camera.fade(FlxColor.BLACK, 0.5, true);
				}
			});
			fallenKingdom.play();
		}
	}
	#else
	public static function playVideo(url)
	{
		trace("Cannot play video on Non-html5 target");
	}
	#end
}
