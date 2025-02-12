package;

import entity.Entity;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.input.gamepad.FlxGamepad;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;
import haxe.Log;
import input.ControllerSource;
import input.InputSource;
import input.KeyboardSource;
import input.control.Input;
import nape.geom.Vec2;
import nape.space.Space;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.display.StageQuality;
import openfl.display.StageScaleMode;
import sound.FootstepManager;
import state.MenuState;
import state.MidState;
import substate.InputManagerSubState;
import util.EnviornmentsLoader;
import util.Language;
import util.Run;
import util.SubtitlesBox;
#if cpp
import steamwrap.api.Steam;
#end
#if html5
import js.Browser;
import js.html.Console;
import js.html.LinkElement;
#end

class Main extends Sprite
{
	public static var attribution:String = "

		`Programming by agmas`
		$Art by moi$
		^Music by [[LUCA]]^

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
		\"Coin Donation 2\" by floraphonic
		\"Dog Toy\" by freesound_community
		\"Digging v1\" by freesound_community

		All following sounds are by creators from Freesound.

		\"Sword Swings\" by samsterbirdies
		\"Swoosh\" by porkmucher
		\"Rock Hit\" by link boy
		
		# Silly Quotes

		\"drunk soviet simulator\" - __REDACTED__
		\"you should make the elevator come in with a stock image of a forklift\" - my brother
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
	public static var napeSpaceAmbient:Space;
	public static var run:Run;
	public static var saveFileVersion = "1.0";
	public static var gameMusic:FlxSound = new FlxSound();

	public static var PLAYER_SOUND_VOLUME = 1.0;
	public static var ENEMY_SOUND_VOLUME = 0.9;
	public static var OTHER_VOLUME = 1.0;
	public static var UI_VOLUME = 0.75;
	public static var MUSIC_VOLUME = 1.0;
	#if html5
	public static var linkElement:LinkElement;
	#end

	public function new()
	{
		super();
		#if cpp
		Steam.init(3520760);
		#end
		FlxG.save.bind("brj2025");
		trace(attribution);
		FPS = new FPS(0, 20, FlxColor.WHITE);
		addChild(FPS);
		napeSpace = new Space(new Vec2(0, 1200));
		napeSpaceAmbient = new Space(new Vec2(0, 1200));
		MultiSoundManager.loadMultiSounds();
		MultiSoundManager.loadSurfaces();
		EnviornmentsLoader.loadEnviornments();
		Language.refreshLanguages();
		Language.changeLanguage("en_us");
		MultiSoundManager.footstepVolume.set("carpet", 0.15);
		MultiSoundManager.footstepVolume.set("wood", 0.75);
		addChild(new FlxGame(0, 0, MenuState));
		#if cpp
		FlxG.drawFramerate = 240;
		FlxG.updateFramerate = 240;
		#end
		#if html5
		linkElement = Browser.document.createLinkElement();
		linkElement.href = "assets/data/pixelScaling.css";
		linkElement.type = "text/css";
		linkElement.rel = "stylesheet";
		linkElement.media = "screen,print";
		linkElement.disabled = true;
		Browser.document.head.appendChild(linkElement);
		var link = Browser.document.createLinkElement();
		link.href = "assets/data/styles.css";
		link.type = "text/css";
		link.rel = "stylesheet";
		link.media = "screen,print";
		Browser.document.head.appendChild(link);
		FlxG.stage.showDefaultContextMenu = false;
		FlxG.stage.quality = StageQuality.BEST;
		Browser.document.addEventListener("mousedown", (event) ->
		{
			event.preventDefault();
		}, {capture: false, passive: false});
		Browser.document.addEventListener('keydown', function(event)
		{
			#if !debug
			if (event.key != "F11")
			{
				event.preventDefault();
			}
			#end
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
		FlxG.console.registerClass(MidState);
		FlxG.console.registerClass(PlayState);
		FlxG.console.registerFunction("restart", () ->
		{
			FlxG.resetState();
		});
		FlxG.console.registerFunction("kill", () ->
		{
			for (sprite in cast(FlxG.state, PlayState).playerLayer)
			{
				cast(sprite, Entity).health = 0;
			}
		});
		FlxG.console.registerFunction("cheats", () ->
		{
			FlxG.save.data.cheats = !FlxG.save.data.cheats;
		});
	}

	public static function detectConnections()
	{
		#if cpp
		Steam.onEnterFrame();
		#end
		var previousConnectionsSize = activeInputs.length;
		var shouldDirty = false;
		#if html5
		linkElement.disabled = !FlxG.save.data.pixelScaling;
		#end
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
		#if html5
		if ((FlxG.keys.pressed.ALT && FlxG.keys.justPressed.ENTER) || (FlxG.keys.justPressed.ALT && FlxG.keys.pressed.ENTER))
			FlxG.fullscreen = !FlxG.fullscreen;
		#end
		for (gamepad in FlxG.gamepads.getActiveGamepads())
		{
			if (!Main.activeGamepads.contains(gamepad))
			{
				Main.activeGamepads.push(gamepad);
				activeInputs.push(new ControllerSource(gamepad));
				shouldDirty = true;
			}
		}
		if (FlxG.save.data.disableKeyboard)
		{
			kbmConnected = false;
		}
		if (FlxG.keys.firstPressed() != -1)
		{
			if (!kbmConnected)
			{
				if (FlxG.save.data.disableKeyboard)
					return;
				kbmConnected = true;
				shouldDirty = true;
				activeInputs.push(new KeyboardSource());
			}
		}
		if (previousConnectionsSize == 1 && activeInputs.length == 2)
		{
			Main.connectionsDirty = false;
			FlxG.state.openSubState(new InputManagerSubState(activeInputs[1]));
		}
		else
		{
			if (shouldDirty) 
				connectionsDirty = true;
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
