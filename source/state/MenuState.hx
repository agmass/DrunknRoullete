package state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import util.Language;

class MenuState extends FlxState
{
	var title:FlxText = new FlxText(0, 0, 0, "Drunk'n'Roullete", 64);
	var play:FlxText = new FlxText(0, 0, 0, Language.get("button.start"), 32);
	var options:FlxText = new FlxText(0, 0, 0, Language.get("button.options"), 32);

	override function create()
	{
		super.create();
		title.screenCenter();
		add(title);
		title.y -= 128;
		add(play);
		add(options);
	}

	var selection = 0;

	override function update(elapsed:Float)
	{
		Main.detectConnections();
		var gamepadAccepted = false;
		for (i in Main.activeGamepads)
		{
			if (i.pressed.DPAD_DOWN || i.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) > 0.2 && i.analog.justMoved.LEFT_STICK)
			{
				selection += 1;
			}
			if (i.pressed.DPAD_UP || i.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) < 0.2 && i.analog.justMoved.LEFT_STICK)
			{
				selection -= 1;
			}
			if (i.pressed.A)
			{
				gamepadAccepted = true;
			}
		}
		if (FlxG.keys.justPressed.UP)
		{
			selection -= 1;
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			selection += 1;
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
		if (FlxG.mouse.overlaps(play))
		{
			selection = 0;
		}
		if (FlxG.mouse.overlaps(options))
		{
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