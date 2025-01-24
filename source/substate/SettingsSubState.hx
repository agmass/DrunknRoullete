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

class SettingsSubState extends FlxSubState
{
	var bg:FlxUITabMenu;
	var uicam:FlxCamera = new FlxCamera();
	var subtitles:FlxUICheckBox = new FlxUICheckBox(10, 30, null, null, "Subtitles", 200);
	var disableKeyboard:FlxUICheckBox = new FlxUICheckBox(10, 60, null, null, "No Keyboard", 200);
	var friendlyFire:FlxUICheckBox = new FlxUICheckBox(10, 90, null, null, "Friendly Fire", 200);
	var disableShaders:FlxUICheckBox = new FlxUICheckBox(10, 120, null, null, "Performance Mode", 200);
	var lookAtMovement:FlxUICheckBox = new FlxUICheckBox(10, 150, null, null, "Controller - Look at Movement", 400);
	var frameRateInfo:FlxUICheckBox = new FlxUICheckBox(10, 180, null, null, "Debug Info (FPS Counter)", 200);
	var playerInfo:FlxUICheckBox = new FlxUICheckBox(10, 210, null, null, "Debug Info (PlayerInfo)", 200);
	var back:FlxText = new FlxText(0, 0, 0, "Back", 24);
	var selectionSprite:FlxSprite = new FlxSprite(1, 1);
	var selectable:Array<FlxUICheckBox> = [];

	override public function create():Void
	{
		uicam.bgColor.alpha = 0;
		FlxG.cameras.add(uicam, false);
		uicam.zoom = 1.75;
		bg = new FlxUITabMenu(null, []);
		bg.scrollFactor.set();
		subtitles.scrollFactor.set();
		disableKeyboard.scrollFactor.set();
		friendlyFire.scrollFactor.set();
		disableShaders.scrollFactor.set();
		lookAtMovement.scrollFactor.set();
		frameRateInfo.scrollFactor.set();
		playerInfo.scrollFactor.set();
		FlxG.save.bind("brj2025");
		super.create();
		bg.resize(FlxG.width / 3, FlxG.height / 3);
		bg.screenCenter();
		subtitles.checked = FlxG.save.data.subtitles;
		disableKeyboard.checked = FlxG.save.data.disableKeyboard;
		friendlyFire.checked = FlxG.save.data.friendlyFire;
		disableShaders.checked = FlxG.save.data.shadersDisabled;
		lookAtMovement.checked = FlxG.save.data.lookAtMovement;
		frameRateInfo.checked = FlxG.save.data.fpsshown;
		playerInfo.checked = FlxG.save.data.playerInfoShown;
		add(bg);
		selectionSprite.camera = uicam;
		selectionSprite.makeGraphic(1, 1);
		selectionSprite.color = FlxColor.ORANGE;
		selectionSprite.alpha = 0.8;
		FlxTween.tween(selectionSprite, {alpha: 0.65}, 1, {type: PINGPONG});
		add(selectionSprite);
		bg.add(subtitles);
		bg.add(disableKeyboard);
		bg.add(friendlyFire);
		bg.add(disableShaders);
		bg.add(lookAtMovement);
		bg.add(frameRateInfo);
		bg.add(playerInfo);
		selectable = [
			subtitles,
			disableKeyboard,
			friendlyFire,
			disableShaders,
			lookAtMovement,
			frameRateInfo,
			playerInfo
		];
		bg.camera = uicam;
		subtitles.camera = uicam;
		disableKeyboard.camera = uicam;
		disableShaders.camera = uicam;
		lookAtMovement.camera = uicam;
		frameRateInfo.camera = uicam;
		playerInfo.camera = uicam;
		friendlyFire.camera = uicam;
		add(subtitles);
		add(disableKeyboard);
		add(friendlyFire);
		add(disableShaders);
		add(lookAtMovement);
		add(frameRateInfo);
		add(playerInfo);
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
		FlxG.save.data.fpsshown = frameRateInfo.checked;
		FlxG.save.data.playerInfoShown = playerInfo.checked;
		if (FlxG.keys.justPressed.ESCAPE)
		{
			close();
		}
		super.update(elapsed);
	}
}