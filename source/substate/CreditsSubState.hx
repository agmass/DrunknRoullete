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
import state.CppVideoState;
import state.MenuState;

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
		bg.resize(FlxG.width / 3, (FlxG.height - 100) / 1.75);
		bg.screenCenter();
		add(bg);
		var attributions:FlxText = new FlxText(bg.x + 4, bg.y + 4, 0, StringTools.replace(StringTools.replace(Main.attribution, "	", ""), "\\n", ""), 8);
		attributions.applyMarkup(attributions.text, [
			new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GREEN.getLightened(0.2)), "$"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.PINK), "`"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.BLUE.getLightened(0.2)), "^")
		]);
		bg.camera = uicam;
		add(back);
		attributions.color = FlxColor.BLACK;
		attributions.camera = uicam;
		add(attributions);
		back.camera = uicam;
		back.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		back.scrollFactor.set(0, 0);
		back.x = bg.x + FlxG.width / 3;
		back.y = bg.y;
		back.x -= back.width;
		back.updateHitbox();
	}


	override function close()
	{
		// FlxG.cameras.remove(uicam);
		// uicam.destroy();
		super.close();
	}

	override function destroy()
	{
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		if (Main.playingVideo)
			return;
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
		if (FlxG.mouse.justPressed && FlxG.mouse.x > 419 && FlxG.mouse.x < 453 && FlxG.mouse.y > 149 && FlxG.mouse.y < 165)
		{
			#if html5
			Main.playVideo(AssetPaths.thespinningwheel__mp4);
			#end
			#if cpp
			FlxG.switchState(new CppVideoState(AssetPaths.thespinningwheel__mp4, () ->
			{
				FlxG.switchState(new MenuState());
			}));
			#end
		}

		Main.detectConnections();
		for (i in Main.activeInputs)
		{
			if (i.ui_deny)
			{
				close();
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			close();
		}
		super.update(elapsed);
	}
}