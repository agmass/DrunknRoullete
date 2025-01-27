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
import util.Language;

class MenuState extends TransitionableState
{
	var title:FlxText = new FlxText(0, 0, 0, "Drunk'n'Roullete", 64);
	var play:FlxText = new FlxText(0, 0, 0, Language.get("button.start"), 32);
	var continueButton:FlxText = new FlxText(0, 0, 0, Language.get("button.continue"), 32);
	var intro:FlxText = new FlxText(0, 0, 0, Language.get("button.intro"), 32);
	var fullscreen:FlxText = new FlxText(0, 0, 0, Language.get("button.fullscreen"), 32);
	var options:FlxText = new FlxText(0, 0, 0, Language.get("button.options"), 32);
	var credits:FlxText = new FlxText(0, 0, 0, Language.get("button.credits"), 32);
	var connectedPlayers:FlxText = new FlxText(20, 20, 0, "No Players Connected", 16);
	var itchIsBroken:FlxText = new FlxText(0, 0, 0, Language.get("button.start"), 32);
	var wasPlayingVideo = false;
	var highScore:FlxText = new FlxText(0, FlxG.height - 48, "HIGHEST TOKENS: 0", 32);

	override function create()
	{
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
		super.create();
	}

	var s = new AttributesSlotTextShader();
	var selection = 0;
	override function update(elapsed:Float)
	{
		s.elapsed.value[0] += elapsed;
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
					FlxG.sound.play(AssetPaths.menu_select__ogg);
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
				FlxG.sound.play(AssetPaths.menu_accept__ogg);
				gamepadAccepted = true;
			}
		}
		if (selection <= -1)
		{
			selection = 50;
		}
		if (selection >= 6)
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
		continueButton.color = FlxColor.WHITE;
		continueButton.scale.set(0.75, 0.75);
		continueButton.alpha = 0.75;
		credits.color = FlxColor.WHITE;
		credits.scale.set(0.75, 0.75);
		credits.alpha = 0.75;
		if (FlxG.mouse.overlaps(play) && selection != 0)
		{
			FlxG.sound.play(AssetPaths.menu_select__ogg);
			selection = 0;
		}
		if (FlxG.mouse.overlaps(continueButton) && selection != 1 && FlxG.save.data.run != null) 
		{
			FlxG.sound.play(AssetPaths.menu_select__ogg);
			selection = 1;
		}
		if (FlxG.mouse.overlaps(options) && selection != 2)
		{
			FlxG.sound.play(AssetPaths.menu_select__ogg);
			selection = 2;
		}
		if (FlxG.mouse.overlaps(credits) && selection != 4)
		{
			FlxG.sound.play(AssetPaths.menu_select__ogg);
			selection = 4;
		}
		if (FlxG.save.data.seenIntro)
		{
			if (FlxG.mouse.overlaps(intro) && selection != 5)
			{
				FlxG.sound.play(AssetPaths.menu_select__ogg);
				selection = 5;
			}
		}
		else
		{
			intro.visible = false;
			if (selection >= 5)
			{
				selection = 0;
			}
		}
		if (FlxG.mouse.overlaps(fullscreen) && selection != 3)
		{
			FlxG.sound.play(AssetPaths.menu_select__ogg);
			selection = 3;
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
				continueButton.color = FlxColor.YELLOW;
				continueButton.scale.set(1.25, 1.25);
				continueButton.alpha = 1;
				if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed || gamepadAccepted)
				{
					MidState.readSaveFile();
					FlxG.switchState(new MidState());
				}
			case 2:
				options.color = FlxColor.YELLOW;
				options.scale.set(1.25, 1.25);
				options.alpha = 1;
				if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed || gamepadAccepted)
				{
					var tempState:SettingsSubState = new SettingsSubState();
					openSubState(tempState);
				}
			case 4:
				credits.color = FlxColor.YELLOW;
				credits.scale.set(1.25, 1.25);
				credits.alpha = 1;
				if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed || gamepadAccepted)
				{
					var tempState:CreditsSubState = new CreditsSubState();
					openSubState(tempState);
				}
			case 5:
				intro.color = FlxColor.YELLOW;
				intro.scale.set(1.25, 1.25);
				intro.alpha = 1;
				if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed || gamepadAccepted)
				{
					Main.playVideo(AssetPaths.intro__mp4);
				}
			case 3:
				fullscreen.color = FlxColor.YELLOW;
				fullscreen.scale.set(1.25, 1.25);
				fullscreen.alpha = 1;
				if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed || gamepadAccepted)
				{
					FlxG.fullscreen = !FlxG.fullscreen;
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