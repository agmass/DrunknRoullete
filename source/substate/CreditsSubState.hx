package substate;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUITabMenu;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import input.KeyboardSource;

class CreditsSubState extends FlxSubState
{
	var bg:FlxUITabMenu;
	var uicam:FlxCamera = new FlxCamera();
	var back:FlxText = new FlxText(0, 0, 0, "Back", 24);

	override public function create():Void
	{
		uicam.bgColor.alpha = 0;
		FlxG.cameras.add(uicam, false);
		uicam.zoom = 1.75;
		bg = new FlxUITabMenu(null, []);
		bg.scrollFactor.set();
		FlxG.save.bind("brj2025");
		super.create();
		bg.resize(FlxG.width / 3, FlxG.height - 40);
		bg.screenCenter();
		add(bg);
		bg.camera = uicam;
		add(back);
		back.camera = uicam;
		back.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		back.scrollFactor.set(0, 0);
		back.x = bg.x + FlxG.width / 3;
		back.y = bg.y;
		back.x -= back.width;
		back.updateHitbox();
	}

	var selection = -6;

	override function close()
	{
		// FlxG.cameras.remove(uicam);
		// uicam.destroy();
		super.close();
	}

	override function destroy()
	{
		FlxG.save.flush();
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		back.color = FlxColor.WHITE;
		back.scale.set(1, 1);
		if (FlxG.mouse.overlaps(back, uicam))
		{
			back.scale.set(1.2, 1.2);
			back.color = FlxColor.YELLOW;
			if (FlxG.mouse.justPressed)
			{
				close();
			}
		}

		Main.detectConnections();
		var gamepadAccepted = false;
		for (i in Main.activeInputs)
		{
			if (i is KeyboardSource)
				continue;
			if (FlxMath.roundDecimal(i.getMovementVector().y, 1) != FlxMath.roundDecimal(i.lastMovement.y, 1))
			{
				if (selection == -6)
				{
					selection = -1;
				}
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
			if (i.ui_deny)
			{
				close();
			}
		}
		if (selection <= -1 && selection != -6)
		{
			selection = 7;
		}
		if (selection >= 8)
		{
			selection = 0;
		}

		if (selection >= 0)
		{
			if (selection < selectable.length)
			{
				if (selectable[selection] != null)
				{
					var checkBox = selectable[selection];
					selectionSprite.x = (checkBox.x - 2);
					selectionSprite.y = (checkBox.y - 2);
					selectionSprite.scale.set(checkBox.width + 4, checkBox.height + 4);
					selectionSprite.updateHitbox();
					checkBox.checkbox_dirty = true;
					if (gamepadAccepted)
					{
						checkBox.checked = !checkBox.checked;
					}
				}
			}
		}

		FlxG.save.data.disableKeyboard = disableKeyboard.checked;
		FlxG.save.data.friendlyFire = friendlyFire.checked;
		FlxG.save.data.shadersDisabled = disableShaders.checked;
		FlxG.save.data.lookAtMovement = lookAtMovement.checked;
		FlxG.save.data.disableChroma = disableChroma.checked;
		FlxG.save.data.fpsshown = frameRateInfo.checked;
		FlxG.save.data.playerInfoShown = playerInfo.checked;
		if (FlxG.keys.justPressed.ESCAPE)
		{
			close();
		}
		super.update(elapsed);
	}
}