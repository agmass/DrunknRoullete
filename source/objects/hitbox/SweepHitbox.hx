package objects.hitbox;

import entity.Entity;
import flixel.FlxSprite;
import objects.hitbox.Hitbox;

class SweepHitbox extends Hitbox
{
	override public function new(x, y)
	{
		super(x, y);
		damage = 10;
		loadGraphic(AssetPaths.sweep__png, true, 32, 8);
		scale.set(4, 4);
		updateHitbox();
		animation.add("sweep", [0, 1, 2, 3, 4, 5], 15, false);
		animation.play("sweep");
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (animation.finished)
		{
			visible = false;
			inactive = true;
		}
	}
}