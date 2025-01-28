package state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import shader.AttributesSlotTextShader;
import substate.CreditsSubState;
import substate.SettingsSubState;
import ui.MenuTextButton;
import util.Language;
#if cpp
import hxvlc.flixel.FlxVideoSprite;
#end

class MenuState extends TransitionableState
{
	var title:FlxText = new FlxText(0, 0, 0, "Drunk'n'Roullete", 64);
	var play:MenuTextButton = new MenuTextButton(0, 0, 0, Language.get("button.start"), 32);
	var continueButton:MenuTextButton = new MenuTextButton(0, 0, 0, Language.get("button.continue"), 32, () ->
	{
		MidState.readSaveFile();
		FlxG.switchState(new MidState());
	});
	var intro:MenuTextButton = new MenuTextButton(0, 0, 0, Language.get("button.intro"), 32);
	var fullscreen:MenuTextButton = new MenuTextButton(0, 0, 0, Language.get("button.fullscreen"), 32, () ->
	{
		FlxG.fullscreen = !FlxG.fullscreen;
	});
	var options:MenuTextButton = new MenuTextButton(0, 0, 0, Language.get("button.options"), 32,);
	var credits:MenuTextButton = new MenuTextButton(0, 0, 0, Language.get("button.credits"), 32);
	var connectedPlayers:FlxText = new FlxText(20, 20, 0, "No Players Connected", 16);
	var itchIsBroken:FlxText = new FlxText(0, 0, 0, Language.get("button.start"), 32);
	var menuSelectables:Array<MenuTextButton> = [];
	var wasPlayingVideo = false;
	var highScore:FlxText = new FlxText(0, FlxG.height - 48, "HIGHEST TOKENS: 0", 32);
	#if cpp
	var video = new FlxVideoSprite(0, 0);
	#end

	override function create()
	{
		credits.onUsed = () ->
		{
			var tempState:CreditsSubState = new CreditsSubState();
			openSubState(tempState);
		};
		options.onUsed = () ->
		{
			var tempState:SettingsSubState = new SettingsSubState();
			openSubState(tempState);
		}
		intro.onUsed = () -> {
			#if html5
			Main.playVideo(AssetPaths.intro__mp4);
			#end
			#if cpp
			video.play();
			#end
		};
		play.onUsed = () ->
		{
			if (!FlxG.save.data.seenIntro)
			{
				FlxG.save.data.seenIntro = true;
				FlxG.save.flush();
				#if html5
				Main.playVideo(AssetPaths.intro__mp4);
				#end
				#if cpp
				video.play();
				#end
			}
			else
			{
				if (waitForFadeOut < 0)
					FlxG.switchState(new PlayState());
			}
		};
		FlxG.save.bind("brj2025");
		Main.run = null;
		if (FlxG.save.data.seenIntro)
		{
			var casnio = new FlxSprite(0, 0, AssetPaths.casniobackground__png);
			casnio.alpha = 0.2;
			add(casnio);
		}
		title.screenCenter();
		add(title);
		title.y -= 128;
		add(play);
		add(options);
		add(intro);
		add(fullscreen);
		add(connectedPlayers);
		add(continueButton);
		add(credits);
		menuSelectables = [play, continueButton, options, fullscreen, credits, intro];
		highScore.color = FlxColor.LIME;
		if (FlxG.save.data.highestTokens != null)
		{
			add(highScore);
			highScore.text = "HIGHEST TOKENS: " + FlxG.save.data.highestTokens;
			highScore.screenCenter(X);
			if (!FlxG.save.data.shadersDisabled)
			{
				s.modulo.value[0] = 999;
				highScore.shader = s;
			}
			else
			{
				highScore.color = FlxColor.YELLOW;
			}
		}
		#if cpp
		video.active = false;
		video.antialiasing = true;
		video.load(AssetPaths.intro__mp4);
		add(video);
		#end
		super.create();
	}

	var s = new AttributesSlotTextShader();
	var selection = 0;
	var waitForFadeOut = 0.3;
	override function update(elapsed:Float)
	{
		s.elapsed.value[0] += elapsed;
		waitForFadeOut -= elapsed;
		#if cpp
		if (video.bitmap.isPlaying)
		{
			wasPlayingVideo = true;
			return;
		}
		#end
		if (Main.playingVideo)
		{
			wasPlayingVideo = true;
			return;
		}
		if (wasPlayingVideo)
		{
			FlxG.switchState(new PlayState());
			return;
		}
		Main.detectConnections();
		var gamepadAccepted = false;
		connectedPlayers.text = Language.get("menu.controllerWarning");
		var e = 0;
		for (i in Main.activeInputs)
		{
			e++;
			connectedPlayers.text += "\n\nPlayer " + e + " (" + Language.get(i.translationKey) + ")";
			if (FlxMath.roundDecimal(i.getMovementVector().y, 1) != FlxMath.roundDecimal(i.lastMovement.y, 1))
			{
				if (i.getMovementVector().y == 1)
				{
					FlxG.sound.play(AssetPaths.menu_select__ogg, Main.UI_VOLUME);
					selection += 1;
					if (FlxG.save.data.run == null)
					{
						if (selection == 1)
						{
							selection = 2;
						}
					}
				}
				if (i.getMovementVector().y == -1)
				{
					FlxG.sound.play(AssetPaths.menu_select__ogg, Main.UI_VOLUME);
					selection -= 1;
					if (FlxG.save.data.run == null)
					{
						if (selection == 1)
						{
							selection = 0;
						}
					}
				}
			}
			i.lastMovement.y = i.getMovementVector().y;
			if (i.ui_accept)
			{
				FlxG.sound.play(AssetPaths.menu_accept__ogg, Main.UI_VOLUME);
				gamepadAccepted = true;
			}
		}
		var i = 0;
		for (menuText in menuSelectables)
		{
			menuText.selected = false;
			if (FlxG.mouse.overlaps(menuText) && selection != i)
			{
				selection = i;
				FlxG.sound.play(AssetPaths.menu_select__ogg, Main.UI_VOLUME);
			}
			if (selection == i)
			{
				menuText.selected = true;
				if (gamepadAccepted)
				{
					menuText.onUsed();
				}
			}
			i++;
		}
		if (selection <= -1)
		{
			selection = i - 1;
		}
		if (selection >= menuSelectables.length)
		{
			selection = 0;
		}
		if (FlxG.save.data.run != null) 
		{
			continueButton.visible = true;
		}
		else
		{
			continueButton.visible = true;
		}
		if (FlxG.save.data.seenIntro)
		{
			intro.visible = true;
		}
		else
		{
			intro.visible = false;
			if (selection >= 5)
			{
				selection = 0;
			}
		}

		play.screenCenter();
		continueButton.visible = FlxG.save.data.run != null;
		if (FlxG.save.data.run == null)
		{
			options.screenCenter();
			options.y += 64;
			fullscreen.screenCenter();
			fullscreen.y += 128;
			credits.screenCenter();
			credits.y += 128 + 64;
			intro.screenCenter();
			intro.y += 128 + 64 + 64;
		}
		else
		{
			continueButton.screenCenter();
			continueButton.y += 64;
			options.screenCenter();
			options.y += 128;
			fullscreen.screenCenter();
			fullscreen.y += 128 + 64;
			credits.screenCenter();
			credits.y += 128 + 64 + 64;
			intro.screenCenter();
			intro.y += 128 + 64 + 64 + 64;
		}
		super.update(elapsed);
	}
}