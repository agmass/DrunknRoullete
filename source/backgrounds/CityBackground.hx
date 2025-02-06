package backgrounds;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class CityBackground extends FlxTypedGroup<FlxSprite>
{
	var window:FlxSprite;

	override public function new()
	{
		super();
		window = new FlxSprite(184 * 1.5, 10 * 1.5);
		window.loadGraphic(AssetPaths.window__png, true, 145, 63);
		window.animation.add("fixed", [0]);
		window.animation.add("broken", [1]);
		if (PlayState.storyMode)
		{
			window.loadGraphic(AssetPaths.window_hidden__png, true, 149, 69);
			window.animation.add("fixed", [0]);
			window.animation.add("broken", [0]);
		}
		window.scale.set(1.5, 1.5);
		window.animation.play("fixed");
		window.updateHitbox();
		add(window);
	}

	override function update(elapsed:Float)
	{
		if (Main.run.brokeWindow)
		{
			window.animation.play("broken");
		}
		super.update(elapsed);
	}
}