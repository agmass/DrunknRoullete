package entity.bosses;

import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class TutorialBoss extends Entity
{
	var dialouge:FlxTypeText = new FlxTypeText(0, 0, 0, "", 48);
	var face:FlxText = new FlxText(0, 0, 0, "z_z", 64);
	var state = 0;

	override public function new()
	{
		super();
		makeGraphic(750, 500, FlxColor.BLACK);
	}

	override function update(elapsed:Float)
	{
		dialouge.screenCenter();
		face.x = x + ((width - face.width) / 2);
		face.y = y + ((height - face.height) / 2);
		dialouge.update(elapsed);
		screenCenter(X);
		super.update(elapsed);
	}

	override function draw()
	{
		dialouge.draw();
		face.draw();
		super.draw();
	}
}