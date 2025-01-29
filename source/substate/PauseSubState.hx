package substate;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import state.MenuState;
import state.TransitionableState;
import ui.MenuTextButton;
import util.Language;

class PauseSubState extends FlxSubState
{
	var selection:Int = 0;
	var locked = false;
	var title:FlxText;
	var play:MenuTextButton;
	var menu:MenuTextButton;
	var uicam:FlxCamera = new FlxCamera();
	var saves:MenuTextButton;

	var sprite:FlxSprite = new FlxSprite(0, 0);
	var menuSelectables = [];

	override public function create():Void
	{
		uicam.zoom = 1.6;
		uicam.bgColor.alpha = 0;
		FlxG.cameras.add(uicam, false);
		sprite.scrollFactor.set(0, 0);
		sprite.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		sprite.alpha = 0;
		FlxTween.tween(sprite, {alpha: 0.5}, 0.25);
		sprite.camera = uicam;
		add(sprite);
		super.create();
		title = new MenuTextButton(0, 0, 0, "Drunk'n'Roullete", 32);
		title.screenCenter();
		title.scrollFactor.set(0, 0);
		title.y -= 64;
		title.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
		add(title);

		play = new MenuTextButton(0, 0, 0, Language.get("pause.play"), 16, () ->
		{
			close();
		});
		play.screenCenter();
		play.scrollFactor.set(0, 0);
		play.y -= 32;
		play.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
		add(play);

		menu = new MenuTextButton(0, 0, 0, Language.get("pause.menu"), 16, () ->
		{
			TransitionableState.screengrab();
			FlxG.switchState(new MenuState());
		});
		menu.screenCenter();
		menu.scrollFactor.set(0, 0);
		menu.alpha = 0;
		menu.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
		add(menu);

		saves = new MenuTextButton(0, 0, 0, Language.get("button.options"), 16, () ->
		{
			var tempState:SettingsSubState = new SettingsSubState();
			openSubState(tempState);
		});
		saves.screenCenter();
		saves.scrollFactor.set(0, 0);
		saves.y += 32;
		FlxTween.tween(saves, {alpha: 0.75}, 0.1);
		saves.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
		add(saves);
		menuSelectables = [play, menu, saves];

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

		add(Main.subtitlesBox);
	}

	override function destroy()
	{
		remove(Main.subtitlesBox);

		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		if (!locked)
		{
			Main.detectConnections();
			var gamepadAccepted = FlxG.mouse.justPressed;
			for (i in Main.activeInputs)
			{
				if (FlxMath.roundDecimal(i.getMovementVector().y, 1) != FlxMath.roundDecimal(i.lastMovement.y, 1))
				{
					if (i.getMovementVector().y == 1)
					{
						FlxG.sound.play(AssetPaths.menu_select__ogg, Main.UI_VOLUME);
						selection += 1;
					}
					if (i.getMovementVector().y == -1)
					{
						FlxG.sound.play(AssetPaths.menu_select__ogg, Main.UI_VOLUME);
						selection -= 1;
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
		}
		// persistentDraw = true;
		// persistentUpdate = true;
		super.update(elapsed);
	}
}