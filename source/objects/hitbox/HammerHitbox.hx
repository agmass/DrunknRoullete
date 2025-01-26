package objects.hitbox;

import entity.Entity;
import entity.EquippedEntity;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class HammerHitbox extends Hitbox
{
	var timeAlive = 0.05;

	override public function new(x, y)
	{
		super(x, y);
		damage = FlxG.random.int(8, 15);
		makeGraphic(72, 72, FlxColor.TRANSPARENT);
	}

	override function onHit(victim:Entity)
	{
		super.onHit(victim);
		if (victim == shooter)
			return;
		if (flipX)
		{
			victim.velocity.x = new FlxPoint(300, 300).rotateByDegrees(angle + 180).negate().x;
			victim.velocity.y = new FlxPoint(300, 300).rotateByDegrees(angle + 180).negate().y;
		}
		else
		{
			victim.velocity.x = new FlxPoint(300, 300).rotateByDegrees(angle).negate().x;
			victim.velocity.y = new FlxPoint(300, 300).rotateByDegrees(angle).negate().y;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		timeAlive -= elapsed;
		if (timeAlive < 0)
		{
			if (shooter is EquippedEntity)
			{
				cast(shooter, EquippedEntity).hitboxes.remove(this);
				destroy();
			}
		}
	}
}