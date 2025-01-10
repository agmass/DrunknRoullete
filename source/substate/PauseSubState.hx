package substate;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import state.MenuState;
import util.Language;

class PauseSubState extends FlxSubState
{
	var selection:Int = 0;
	var locked = false;
	var title:FlxText;
	var play:FlxText;
	var menu:FlxText;
	var uicam:FlxCamera = new FlxCamera();
	var saves:FlxText;

	var sprite:FlxSprite = new FlxSprite(0, 0);

	override public function create():Void
	{
		uicam.zoom = 1.6;
		uicam.bgColor.alpha = 0;
		FlxG.cameras.add(uicam, false);
		sprite.scrollFactor.set(0, 0);
		sprite.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		sprite.alpha = 0;
		FlxTween.tween(sprite, {alpha: 0.5}, 0.25);
		add(sprite);
		super.create();
		title = new FlxText(0, 0, 0, "Drunk'n'Roullete", 32);
		title.screenCenter();
		title.scrollFactor.set(0, 0);
		title.y -= 64;
		title.alpha = 0;
		FlxTween.tween(title, {alpha: 1}, 0.1);
		title.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
		add(title);

		play = new FlxText(0, 0, 0, Language.get("pause.play"), 16);
		play.screenCenter();
		play.scrollFactor.set(0, 0);
		play.y -= 32;
		play.alpha = 0;
		FlxTween.tween(play, {alpha: 0.75}, 0.1);
		play.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
		add(play);

		menu = new FlxText(0, 0, 0, Language.get("pause.menu"), 16);
		menu.screenCenter();
		menu.scrollFactor.set(0, 0);
		menu.alpha = 0;
		FlxTween.tween(menu, {alpha: 0.75}, 0.1);
		menu.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
		add(menu);

		saves = new FlxText(0, 0, 0, Language.get("button.options"), 16);
		saves.screenCenter();
		saves.scrollFactor.set(0, 0);
		saves.alpha = 0;
		saves.y += 32;
		FlxTween.tween(saves, {alpha: 0.75}, 0.1);
		saves.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
		add(saves);

		menu.camera = uicam;
		saves.camera = uicam;
		play.camera = uicam;
		title.camera = uicam;
		subStateOpened.add((s) ->
		{
			locked = true;
		});
		subStateClosed.add((s) ->
		{
			locked = false;
		});
	}

	override public function update(elapsed:Float):Void
	{
		if (!locked)
		{
			Main.detectConnections();
			if (FlxG.keys.justPressed.UP)
			{
				selection -= 1;
			}
			if (FlxG.keys.justPressed.DOWN)
			{
				selection += 1;
			}
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

			menu.color = FlxColor.WHITE;
			menu.scale.set(0.75, 0.75);
			menu.alpha = 0.75;
			saves.color = FlxColor.GRAY;
			saves.scale.set(0.75, 0.75);
			saves.alpha = 0.75;
			if (FlxG.mouse.overlaps(play))
			{
				selection = 0;
			}
			if (FlxG.mouse.overlaps(menu))
			{
				selection = 1;
			}
			if (FlxG.mouse.overlaps(saves))
			{
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
						close();
					}
				case 1:
					menu.color = FlxColor.YELLOW;
					menu.scale.set(1.25, 1.25);
					menu.alpha = 1;
					if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed || gamepadAccepted)
					{
						FlxG.switchState(new MenuState());
					}
				case 2:
					// saves.color = FlxColor.YELLOW;
					saves.scale.set(1.25, 1.25);
					saves.alpha = 1;
					if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed || gamepadAccepted)
					{
						// var tempState:OptionsSubState = new OptionsSubState();
						// openSubState(tempState);
					}
			}
		}
		// persistentDraw = true;
		// persistentUpdate = true;

		super.update(elapsed);
	}
}