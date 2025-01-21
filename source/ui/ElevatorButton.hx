package ui;

import flixel.FlxSprite;

class ElevatorButton extends FlxSprite
{
	public var icon:FlxSprite;

	override public function new()
	{
		super();
		loadGraphic(AssetPaths.elevator_button__png, true, 64, 64);
		icon.loadGraphic(AssetPaths.elevator_button_top__png, true, 64, 64);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function draw()
	{
		super.draw();
		icon.x = x;
		icon.y = y;
		icon.draw();
	}
}