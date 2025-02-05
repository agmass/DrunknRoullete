package entity.bosses;

import flixel.addons.text.FlxTypeText;
import flixel.util.FlxColor;

class TutorialBoss extends Entity
{
	var dialouge:FlxTypeText = new FlxTypeText(0, 0, 0, "", 48);

	override public function new()
	{
		super();
		makeGraphic(750, 500, FlxColor.BLACK);
	}

	override function update(elapsed:Float)
	{
		dialouge.update(elapsed);
		screenCenter(X);
		super.update(elapsed);
	}

	override function draw()
	{
		dialouge.draw();
		super.draw();
	}
}