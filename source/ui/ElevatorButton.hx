package ui;

import flixel.FlxSprite;

class ElevatorButton extends FlxSprite
{
	public var icon:FlxSprite = new FlxSprite();

	override public function new(id)
	{
		super();
		loadGraphic(AssetPaths.elevator_button__png, true, 64, 64);
		icon.loadGraphic(AssetPaths.elevator_button_top__png, true, 64, 64);
		animation.add("i", [0]);
		animation.add("p", [1]);
		icon.animation.add("i", [id]);
		icon.animation.play("i");
		scale.set(2.5, 2.5);
		updateHitbox();

		icon.scale.set(2.5, 2.5);
		icon.updateHitbox();
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