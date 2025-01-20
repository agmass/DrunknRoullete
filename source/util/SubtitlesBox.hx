package util;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class SubtitlesBox extends FlxSprite
{
	public var subtitleTexts:FlxTypedSpriteGroup<FlxText> = new FlxTypedSpriteGroup();

	override public function new()
	{
		super(0, 0);
		makeGraphic(1, 1, FlxColor.BLACK);
	}

	override function update(elapsed:Float)
	{
		for (f in Main.subtitles.keys())
		{
			Main.subtitles.set(f, Main.subtitles.get(f) - elapsed * 2);
			if (Main.subtitles.get(f) < 0.2)
			{
				Main.subtitles.remove(f);
			}
		}
		var i = 0;
		var curHeight = 0.0;
		var usedTexts = [];
		subtitleTexts.forEach((t) ->
		{
			usedTexts.push(t.text);
		});
		for (f in Main.subtitles.keys())
		{
			if (!usedTexts.contains(f))
			{
				subtitleTexts.add(new FlxText(0, 0, 0, f, 24));
			}
		}
		subtitleTexts.forEach((t) ->
		{
			i++;
			t.x = 20;
			t.y = FlxG.height - ((20 * i) + curHeight);
			t.y -= 80;
			curHeight += t.height / 1.3;
			if (Main.subtitles.exists(t.text))
			{
				t.alpha = Main.subtitles.get(t.text) / 4;
			}
			else
			{
				subtitleTexts.remove(t);
			}
		});
		y = FlxG.height - ((20 * i) + curHeight);
		y -= 60;
		x = 20;
		scale.set(subtitleTexts.width, (20 * i) + curHeight);
		updateHitbox();
		super.update(elapsed);
	}

	override function draw()
	{
		subtitleTexts.camera = camera;
		alpha = 0.75;
		super.draw();
		subtitleTexts.draw();
	}
}