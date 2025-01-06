package objects.hitbox;

import entity.Entity;
import flixel.FlxSprite;

class Hitbox extends FlxSprite
{
	public var damage = 0;
	public var shooter:Entity;
	public var hitEntities:Array<Entity> = [];
	public var inactive = false;

	public function onHit(victim:Entity)
	{
		victim.health -= damage;
		hitEntities.push(victim);
	}
}