package objects.hitbox;

import abilities.attributes.Attribute;
import entity.Entity;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import objects.hitbox.Hitbox;

class SweepHitbox extends Hitbox
{
	override public function new(x, y, size)
	{
		super(x, y);
		damage = 10;
		loadGraphic(AssetPaths.sweep__png, true, 32, 8);
		scale.set(4 + size, 4 + size);
		updateHitbox();
		animation.add("sweep", [0, 1, 2, 3, 4, 5], 15, false);
		animation.play("sweep");
	}

	override function onHit(victim:Entity)
	{
		super.onHit(victim);
		if (victim == shooter)
			return;
		victim.velocity = velocity.scaleNew(shooter.attributes.get(Attribute.ATTACK_KNOCKBACK).getValue()).scalePoint(new FlxPoint(3, 1.5));
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