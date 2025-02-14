package substate;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIBar;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIGroup;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUITabMenu;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import input.ControllerSource;
import input.KeyboardSource;
import input.control.AnalogControllerInput;
import input.control.ButtonControllerInput;
import input.control.Input;
import input.control.KeyOrMouseInput;
import ui.FlxUIInput;
import ui.SavedUICheckBox;
import util.Language;

class SettingsSubState extends FlxSubState
{
	var bg:FlxUITabMenu;
	var uicam:FlxCamera = new FlxCamera();
	var subtitles:SavedUICheckBox = new SavedUICheckBox(0, 0, null, null, Language.get("options.subtitles"), 200, "subtitles");
	var disableKeyboard:SavedUICheckBox = new SavedUICheckBox(0, 0, null, null, Language.get("options.nokeyboard"), 200, "disableKeyboard");
	var friendlyFire:SavedUICheckBox = new SavedUICheckBox(0, 0, null, null, Language.get("options.friendlyFire"), 200, "friendlyFire");
	var disableShaders:SavedUICheckBox = new SavedUICheckBox(0, 0, null, null, Language.get("options.performance"), 200, "shadersDisabled");
	var disableChroma:SavedUICheckBox = new SavedUICheckBox(0, 0, null, null, Language.get("options.noChroma"), 200, "disableChroma");
	var frameRateInfo:SavedUICheckBox = new SavedUICheckBox(0, 0, null, null, Language.get("options.debugFPS"), 200, "fpsshown");
	var playerInfo:SavedUICheckBox = new SavedUICheckBox(0, 0, null, null, Language.get("options.debugPlayer"), 200, "playerInfoShown");
	var cheats:SavedUICheckBox = new SavedUICheckBox(0, 0, null, null, Language.get("options.cheats"), 200, "cheats");
	#if html5
	var pixelScaling:SavedUICheckBox = new SavedUICheckBox(0, 0, null, null, Language.get("options.nearestNeighbour"), 200, "pixelScaling");
	#end
	var fullscreen:FlxUICheckBox = new FlxUICheckBox(0, 0, null, null, Language.get("options.fullscreen"), 200);
	var back:FlxText = new FlxText(0, 0, 0, "Back", 24);
	var selectionSprite:FlxSprite = new FlxSprite(1, 1);
	var selectable:Array<FlxSprite> = [];
	var controlsTip:FlxText = new FlxText(0, 0, 0, "", 24);
	var generalGroup:FlxUIGroup = new FlxUIGroup();
	override public function create():Void
	{
		uicam.bgColor.alpha = 0;
		FlxG.cameras.add(uicam, false);
		uicam.zoom = 1.75;
		var groups = [{name: "general", label: "General"}];

		var e = 0;
		var groupsToAdd = [];
		for (i in Main.activeInputs)
		{
			var inputTabGroup = new FlxUIGroup(0, 0);
			groups.push({
				name: "input." + e,
				label: Language.get(i.translationKey).substr(0, 10) + (Language.get(i.translationKey).length >= 10 ? "..." : "")
			});
			inputTabGroup.name = "input." + e;
			for (s in Reflect.fields(i))
			{
				if (Reflect.field(i, s) is Input)
				{
					if (!cast(Reflect.field(i, s), Input).hiddenFromControls)
					{
						var inputChanger:FlxUIInput = new FlxUIInput(i, s);
						inputTabGroup.add(inputChanger);
					}
				}
			}
			groupsToAdd.push(inputTabGroup);
			e++;
		}
		bg = new FlxUITabMenu(null, null, groups);
		e = 0;
		for (source in groupsToAdd)
		{
			bg.addGroup(source);
			var oldCallback = cast(bg.getTab("input." + e), FlxUIButton).onUp.callback;
			var y = e;
			cast(bg.getTab("input." + e), FlxUIButton).onUp.callback = () ->
			{
				oldCallback();
				selectionSprite.setGraphicSize(0, 0);
				controlsTip.visible = true;
				if (Main.activeInputs[y] is KeyboardSource)
				{
					controlsTip.text = Language.get("options.controls.keyboard");
				}
				else
				{
					controlsTip.text = Language.get("options.controls.controller");
				}
				selectable = source.members;
				selection = -6;
			};
			e++;
		}
		FlxG.save.bind("brj2025");
		super.create();
		bg.resize(FlxG.width / 3, FlxG.height / 3);
		bg.screenCenter();
		fullscreen.checked = FlxG.fullscreen;
		add(bg);
		selectionSprite.camera = uicam;
		selectionSprite.makeGraphic(1, 1);
		selectionSprite.color = FlxColor.ORANGE;
		selectionSprite.alpha = 0.6;
		FlxTween.tween(selectionSprite, {alpha: 0.2}, 1, {type: PINGPONG});
		add(selectionSprite);
		generalGroup.add(subtitles);
		generalGroup.add(disableKeyboard);
		generalGroup.add(friendlyFire);
		generalGroup.add(disableShaders);
		generalGroup.add(disableChroma);
		generalGroup.add(frameRateInfo);
		generalGroup.add(playerInfo);
		generalGroup.add(fullscreen);
		generalGroup.add(cheats);
		#if html5
		generalGroup.add(pixelScaling);
		#end
		generalGroup.name = "general";

		var oldCallback = cast(bg.getTab("general"), FlxUIButton).onUp.callback;
		cast(bg.getTab("general"), FlxUIButton).onUp.callback = () ->
		{
			oldCallback();
			selectable = generalGroup.members;
			selectionSprite.setGraphicSize(0, 0);
			controlsTip.visible = false;
			selection = -6;
		};
		bg.addGroup(generalGroup);
		selectable = [
			subtitles,
			disableKeyboard,
			friendlyFire,
			disableShaders,
			frameRateInfo,
			playerInfo,
			disableChroma,
			fullscreen,
			cheats
		];
		#if html5
		selectable = [
			subtitles,
			disableKeyboard,
			friendlyFire,
			disableShaders,
			frameRateInfo,
			playerInfo,
			disableChroma,
			fullscreen,
			cheats,
			pixelScaling
		];
		#end
		add(generalGroup);

		bg.camera = uicam;
		back.camera = uicam;
		back.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		back.scrollFactor.set(0, 0);
		back.x = (bg.x + bg.width) - back.width;
		back.y = (bg.y + bg.height) - back.height;
		back.updateHitbox();
		add(back);
		add(controlsTip);
	}

	var selection = -6;


	override function destroy()
	{
		FlxG.save.flush();
		/*var e = 0;
			for (i in Main.activeInputs)
			{
				var save = new FlxSave();
				save.bind("dnr_controls_p" + e + "_" + i.translationKey);
				for (s in Reflect.fields(i))
				{
					if (Reflect.field(i, s) is KeyOrMouseInput)
					{
						var ss = Std.string(cast(Reflect.field(i, s), KeyOrMouseInput).key);
						Reflect.setField(save, s + "_keys", ss.substring(1, ss.length - 2));
						ss = Std.string(cast(Reflect.field(i, s), KeyOrMouseInput).mouse);
						Reflect.setField(save, s + "_mouse", ss.substring(1, ss.length - 2));
					}
				}
				e++;
			}

			todo later

		 */
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		var b = 0;
		for (box in selectable)
		{
			box.camera = uicam;
			box.y = 30 + (b % 300) + bg.y;
			box.x = bg.x + 10 + (Math.floor(b / 300) * 250);
			b += 30;
		}
		controlsTip.screenCenter();
		controlsTip.alignment = FlxTextAlign.CENTER;
		controlsTip.y = (bg.y + bg.width) - 30;
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
		FlxG.fullscreen = fullscreen.checked;

		Main.detectConnections();
		var gamepadAccepted = false;
		var gamepadDenied = false;
		var gamepadMenud = false;
		var focused = false;
		for (sprite in selectable)
		{
			if (sprite is FlxUIInput)
			{
				if (cast(sprite, FlxUIInput).hasFocus)
				{
					if (gamepadMenud || FlxG.keys.justPressed.ESCAPE)
					{
						cast(sprite, FlxUIInput).hasFocus = false;
					}
					focused = true;
				}
			}
		}
		for (i in Main.activeInputs)
		{
			if (i is KeyboardSource)
				continue;
			if (FlxMath.roundDecimal(i.getMovementVector().y, 1) != FlxMath.roundDecimal(i.lastMovement.y, 1) && !focused)
			{
				if (selection == -6)
				{
					selection = -1;
				}
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
			if (i.ui_left && !focused)
			{
				FlxG.sound.play(AssetPaths.menu_select__ogg, Main.UI_VOLUME);
				if (bg.selected_tab - 1 < 0)
				{
					bg.selected_tab = bg.numTabs - 1;
				}
				else
				{
					bg.selected_tab -= 1;
				}
				cast(bg.getTab(bg.selected_tab), FlxUIButton).onUp.fire();
			}
			if (i.ui_right && !focused)
			{
				FlxG.sound.play(AssetPaths.menu_select__ogg, Main.UI_VOLUME);
				if (bg.numTabs <= bg.selected_tab + 1)
				{
					bg.selected_tab = 0;
				}
				else
				{
					bg.selected_tab += 1;
				}
				cast(bg.getTab(bg.selected_tab), FlxUIButton).onUp.fire();
			}
			if (i.ui_menu)
			{
				gamepadMenud = true;
			}
			if (i.ui_deny)
			{
				gamepadDenied = true;
			}
		}
		if (selection <= -1 && selection != -6)
		{
			selection = 8;
		}
		if (selection >= 9)
		{
			selection = 0;
		}

		if (selection >= 0 && !focused)
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
					if (checkBox is FlxUIInput)
					{
						if (gamepadMenud)
						{
							if (!focused)
							{
								if (cast(checkBox, FlxUIInput).source is ControllerSource)
								{
									if (Reflect.getProperty(cast(checkBox, FlxUIInput).source, cast(checkBox, FlxUIInput).target) is ButtonControllerInput)
									{
										cast(Reflect.getProperty(cast(checkBox, FlxUIInput).source,
											cast(checkBox, FlxUIInput).target), ButtonControllerInput).positiveKey.resize(0);
									}
									if (Reflect.getProperty(cast(checkBox, FlxUIInput).source, cast(checkBox, FlxUIInput).target) is AnalogControllerInput)
									{
										cast(Reflect.getProperty(cast(checkBox, FlxUIInput).source,
											cast(checkBox, FlxUIInput).target), AnalogControllerInput).positiveKey.resize(0);
										cast(Reflect.getProperty(cast(checkBox, FlxUIInput).source,
											cast(checkBox, FlxUIInput).target), AnalogControllerInput).negativeKey.resize(0);
										cast(Reflect.getProperty(cast(checkBox, FlxUIInput).source,
											cast(checkBox, FlxUIInput).target), AnalogControllerInput).stick.resize(0);
									}
									focused = true;
								}
							}
							focused = true;
						}
						if (gamepadAccepted)
						{
							cast(checkBox, FlxUIInput).hasFocus = true;
						}
					}
					if (checkBox is FlxUICheckBox)
					{
						cast(checkBox, FlxUICheckBox).checkbox_dirty = true;
						if (gamepadAccepted)
						{
							cast(checkBox, FlxUICheckBox).checked = !cast(checkBox, FlxUICheckBox).checked;
						}
					}
				}
			}
		}
		if ((gamepadDenied || gamepadMenud || FlxG.keys.justPressed.ESCAPE) && !focused)
		{
			close();
		}
		if (focused)
		{
			selectionSprite.scale.set(0, 0);
		}
		super.update(elapsed);
	}

}