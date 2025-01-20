package objects.hitbox;

import entity.Entity;
import flixel.FlxSprite;

/*
 * Hitboxes (or "hurtboxes") are not physics based and should be used when making consistent, predictable weapon output.
 * For physics based objects like beer bottle's alt fire, extend Projectile instead
 */

class Hitbox extends FlxSprite
{
	public var damage = 0.0;
	public var shooter:Entity;
	public var hitEntities:Array<Entity> = [];
	public var inactive = false;

	public function onHitWall() {}

	public function onHit(victim:Entity)
	{
		if (victim == shooter)
			return;
		victim.damage(damage, shooter);
		hitEntities.push(victim);
	}
}