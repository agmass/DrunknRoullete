package state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import util.Language;

class MenuState extends TransitionableState
{
	var title:FlxText = new FlxText(0, 0, 0, "Drunk'n'Roullete", 64);
	var play:FlxText = new FlxText(0, 0, 0, Language.get("button.start"), 32);
	var options:FlxText = new FlxText(0, 0, 0, Language.get("button.options"), 32);
	var connectedPlayers:FlxText = new FlxText(20, 20, 0, "No Players Connected", 16);

	override function create()
	{
		Main.run = null;
		title.screenCenter();
		add(title);
		title.y -= 128;
		add(play);
		add(options);
		add(connectedPlayers);
		super.create();
	}

	var selection = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.ONE && FlxG.keys.pressed.TWO && FlxG.keys.pressed.FOUR)
		{
			Main.playVideo(AssetPaths.unknowncaller__mp4);
		}
		Main.detectConnections();
		var gamepadAccepted = false;
		if (Main.activeInputs.length == 0)
		{
			connectedPlayers.text = "No Players Connected";
		}
		else
		{
			connectedPlayers.text = "Players Connected:\n";
		}
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
		if (selection >= 2)
		{
			selection = 0;
		}
		play.color = FlxColor.WHITE;
		play.scale.set(0.75, 0.75);
		play.alpha = 0.75;

		options.color = FlxColor.WHITE;
		options.scale.set(0.75, 0.75);
		options.alpha = 0.75;
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
		switch (selection)
		{
			case 0:
				play.color = FlxColor.YELLOW;
				play.scale.set(1.25, 1.25);
				play.alpha = 1;
				if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed || gamepadAccepted)
				{
					FlxG.switchState(new PlayState());
				}
			case 1:
				options.color = FlxColor.YELLOW;
				options.scale.set(1.25, 1.25);
				options.alpha = 1;
				if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed || gamepadAccepted)
				{
					// FlxG.switchState(new MenuState());
				}
		}

		play.screenCenter();
		options.screenCenter();
		options.y += 64;
		super.update(elapsed);
	}
}