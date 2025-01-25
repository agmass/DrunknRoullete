package state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import substate.SettingsSubState;
import util.Language;

class MenuState extends TransitionableState
{
	var title:FlxText = new FlxText(0, 0, 0, "Drunk'n'Roullete", 64);
	var play:FlxText = new FlxText(0, 0, 0, Language.get("button.start"), 32);
	var intro:FlxText = new FlxText(0, 0, 0, Language.get("button.intro"), 32);
	var fullscreen:FlxText = new FlxText(0, 0, 0, Language.get("button.fullscreen"), 32);
	var options:FlxText = new FlxText(0, 0, 0, Language.get("button.options"), 32);
	var connectedPlayers:FlxText = new FlxText(20, 20, 0, "No Players Connected", 16);
	var itchIsBroken:FlxText = new FlxText(0, 0, 0, Language.get("button.start"), 32);
	var wasPlayingVideo = false;

	override function create()
	{
		FlxG.save.bind("brj2025");
		Main.run = null;
		title.screenCenter();
		add(title);
		title.y -= 128;
		add(play);
		add(options);
		add(intro);
		add(fullscreen);
		add(connectedPlayers);
		super.create();
	}

	var selection = 0;
	override function update(elapsed:Float)
	{
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
		connectedPlayers.text = #if html5 Language.get("menu.itchWarning") + "\n" + #end
		Language.get("menu.controllerWarning");
		var e = 0;
		for (i in Main.activeInputs)
		{
			e++;
			connectedPlayers.text += "\n\nPlayer " + e + " (" + Language.get(i.translationKey) + ")";
			if (FlxMath.roundDecimal(i.getMovementVector().y, 1) != FlxMath.roundDecimal(i.lastMovement.y, 1))
			{
				if (i.getMovementVector().y == 1)
				{
					FlxG.sound.play(AssetPaths.menu_select__ogg);
					selection += 1;
				}
				if (i.getMovementVector().y == -1)
				{
					FlxG.sound.play(AssetPaths.menu_select__ogg);
					selection -= 1;
				}
			}
			i.lastMovement.y = i.getMovementVector().y;
			if (i.ui_accept)
			{
				FlxG.sound.play(AssetPaths.menu_accept__ogg);
				gamepadAccepted = true;
			}
		}
		if (selection <= -1)
		{
			selection = 50;
		}
		if (selection >= 4)
		{
			selection = 0;
		}
		play.color = FlxColor.WHITE;
		play.scale.set(0.75, 0.75);
		play.alpha = 0.75;

		options.color = FlxColor.WHITE;
		options.scale.set(0.75, 0.75);
		options.alpha = 0.75;
		intro.color = FlxColor.WHITE;
		intro.scale.set(0.75, 0.75);
		intro.alpha = 0.75;

		fullscreen.color = FlxColor.WHITE;
		fullscreen.scale.set(0.75, 0.75);
		fullscreen.alpha = 0.75;
		if (FlxG.mouse.overlaps(play) && selection != 0)
		{
			FlxG.sound.play(AssetPaths.menu_select__ogg);
			selection = 0;
		}
		if (FlxG.mouse.overlaps(options) && selection != 1)
		{
			FlxG.sound.play(AssetPaths.menu_select__ogg);
			selection = 1;
		}
		if (FlxG.save.data.seenIntro)
		{
			if (FlxG.mouse.overlaps(intro) && selection != 3)
			{
				FlxG.sound.play(AssetPaths.menu_select__ogg);
				selection = 3;
			}
		}
		else
		{
			intro.visible = false;
			if (selection >= 3)
			{
				selection = 0;
			}
		}
		if (FlxG.mouse.overlaps(fullscreen) && selection != 2)
		{
			FlxG.sound.play(AssetPaths.menu_select__ogg);
			selection = 2;
		}
		switch (selection)
		{
			case 0:
				play.color = FlxColor.YELLOW;
				play.scale.set(1.25, 1.25);
				play.alpha = 1;
				if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed || gamepadAccepted)
				{
					if (!FlxG.save.data.seenIntro)
					{
						FlxG.save.data.seenIntro = true;
						FlxG.save.flush();
						Main.playVideo(AssetPaths.intro__mp4);
					}
					else
					{
						FlxG.switchState(new PlayState());
					}
				}
			case 1:
				options.color = FlxColor.YELLOW;
				options.scale.set(1.25, 1.25);
				options.alpha = 1;
				if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed || gamepadAccepted)
				{
					var tempState:SettingsSubState = new SettingsSubState();
					openSubState(tempState);
				}
			case 3:
				intro.color = FlxColor.YELLOW;
				intro.scale.set(1.25, 1.25);
				intro.alpha = 1;
				if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed || gamepadAccepted)
				{
					Main.playVideo(AssetPaths.intro__mp4);
				}
			case 2:
				fullscreen.color = FlxColor.YELLOW;
				fullscreen.scale.set(1.25, 1.25);
				fullscreen.alpha = 1;
				if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed || gamepadAccepted)
				{
					FlxG.fullscreen = !FlxG.fullscreen;
				}
		}

		play.screenCenter();
		options.screenCenter();
		options.y += 64;
		fullscreen.screenCenter();
		fullscreen.y += 128;
		intro.screenCenter();
		intro.y += 128 + 64;
		super.update(elapsed);
	}
}